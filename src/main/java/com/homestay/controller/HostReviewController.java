/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.homestay.controller;

import com.homestay.dao.ReviewReplyDAO;
import com.homestay.model.Review;
import com.homestay.model.ReviewReply;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.List;
import java.util.Set;

/**
 *
 * @author admin
 */
@WebServlet(name = "HostReviewController", urlPatterns = {"/host/reviews"})
public class HostReviewController extends HttpServlet {

    private static final int PAGE_SIZE = 5;
    private static final int MIN_REPLY = 10;
    private static final int MAX_REPLY = 1000;
    private static final String CSRF_KEY = "hostReplyCsrfToken";
    private static final Set<String> FILTERS = Set.of(
            ReviewReplyDAO.FILTER_ALL, ReviewReplyDAO.FILTER_UNREPLIED,
            ReviewReplyDAO.FILTER_REPLIED, ReviewReplyDAO.FILTER_LOW);
    private ReviewReplyDAO replyDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.replyDAO = new ReviewReplyDAO();
    }

    /**
     * Shows the Host's review list (filter + paging) and forwards to the JSP.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Step 1: Require a signed-in user
        HttpSession session = request.getSession(false);
        Integer hostId = (session != null) ? (Integer) session.getAttribute("userId") : null;
        if (hostId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        // Step 2: Read filter and page (fall back to safe defaults)
        String filter = readFilter(request.getParameter("filter"));
        int page = parsePositive(request.getParameter("page"), 1);
        // Step 3: Count, clamp the page, then load the page from DAO
        int total = replyDAO.countReviewsForHost(hostId, filter);
        int totalPages = Math.max(1, (int) Math.ceil((double) total / PAGE_SIZE));
        page = Math.min(page, totalPages);
        List<Review> reviews = replyDAO.findReviewsForHost(hostId, filter, (page - 1) * PAGE_SIZE, PAGE_SIZE);
        // Step 4: Move one-time flash messages from session to request
        moveFlash(session, request, "hostReviewMsg");
        moveFlash(session, request, "hostReviewErr");
        // Step 5: Expose data and the CSRF token, then forward to JSP
        request.setAttribute("reviews", reviews);
        request.setAttribute("filter", filter);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalReviews", total);
        request.setAttribute("unrepliedCount", replyDAO.countReviewsForHost(hostId, ReviewReplyDAO.FILTER_UNREPLIED));
        request.setAttribute("csrfToken", getOrCreateToken(session));
        request.getRequestDispatcher("/WEB-INF/views/host-reviews.jsp").forward(request, response);
    }

    /**
     * Validates and saves a Host reply, then redirects back to the list (PRG).
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        // Step 1: Require a signed-in user
        HttpSession session = request.getSession(false);
        Integer hostId = (session != null) ? (Integer) session.getAttribute("userId") : null;
        if (hostId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String filter = readFilter(request.getParameter("filter"));
        int page = parsePositive(request.getParameter("page"), 1);
        String backUrl = request.getContextPath() + "/host/reviews?filter=" + filter + "&page=" + page;
        // Step 2: Check the CSRF token
        if (!isValidToken(session, request.getParameter("csrfToken"))) {
            fail(session, response, backUrl, "Phiên làm việc hết hạn. Vui lòng thử lại.");
            return;
        }
        // Step 3: Validate input (review id + reply length)
        int reviewId = parsePositive(request.getParameter("reviewId"), 0);
        String content = request.getParameter("replyContent");
        content = content == null ? "" : content.trim();
        if (reviewId == 0) {
            fail(session, response, backUrl, "Không tìm thấy đánh giá cần phản hồi.");
            return;
        }
        if (content.length() < MIN_REPLY || content.length() > MAX_REPLY) {
            fail(session, response, backUrl, "Nội dung phản hồi phải từ " + MIN_REPLY + " đến " + MAX_REPLY + " ký tự.");
            return;
        }
        // Step 4: Host may only reply to reviews of own properties, and only once
        if (!replyDAO.isReviewOwnedByHost(reviewId, hostId)) {
            fail(session, response, backUrl, "Bạn chỉ có thể phản hồi đánh giá của homestay thuộc sở hữu của mình.");
            return;
        }
        if (replyDAO.findByReviewId(reviewId).isPresent()) {
            fail(session, response, backUrl, "Đánh giá này đã có phản hồi từ chủ nhà.");
            return;
        }

        // Step 5: Save the reply, then redirect back to the list
        ReviewReply reply = new ReviewReply();
        reply.setReviewId(reviewId);
        reply.setHostId(hostId);
        reply.setReplyContent(content);
        if (replyDAO.insert(reply)) {
            session.setAttribute("hostReviewMsg", "Đã gửi phản hồi công khai thành công.");
        } else {
            session.setAttribute("hostReviewErr", "Không thể lưu phản hồi. Vui lòng thử lại.");
        }
        response.sendRedirect(backUrl);
    }

    /**
     * Stores an error flash message and redirects back to the list.
     */
    private void fail(HttpSession session, HttpServletResponse response, String backUrl, String message)
            throws IOException {
        session.setAttribute("hostReviewErr", message);
        response.sendRedirect(backUrl);
    }

    /**
     * Returns the filter only if it is in the whitelist.
     */
    private String readFilter(String value) {
        return value != null && FILTERS.contains(value) ? value : ReviewReplyDAO.FILTER_ALL;
    }

    private int parsePositive(String value, int fallback) {
        try {
            int n = Integer.parseInt(value == null ? "" : value.trim());
            return n > 0 ? n : fallback;
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private void moveFlash(HttpSession session, HttpServletRequest request, String key) {
        Object value = session.getAttribute(key);
        if (value != null) {
            request.setAttribute(key, value);
            session.removeAttribute(key);
        }
    }

    /**
     * Returns a stable per-session CSRF token for the reply forms.
     */
    private String getOrCreateToken(HttpSession session) {
        synchronized (session) {
            String token = (String) session.getAttribute(CSRF_KEY);
            if (token == null) {
                byte[] bytes = new byte[32];
                new SecureRandom().nextBytes(bytes);
                token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
                session.setAttribute(CSRF_KEY, token);
            }
            return token;
        }
    }

    private boolean isValidToken(HttpSession session, String submitted) {
        String expected = (String) session.getAttribute(CSRF_KEY);
        return expected != null && submitted != null && MessageDigest.isEqual(
                expected.getBytes(StandardCharsets.UTF_8), submitted.getBytes(StandardCharsets.UTF_8));
    }
}
