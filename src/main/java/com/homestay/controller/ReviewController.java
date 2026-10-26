package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.ReviewDAO;
import com.homestay.dao.RoomDAO;
import com.homestay.model.Booking;
import com.homestay.model.Review;
import com.homestay.model.Room;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.Optional;

/**
 *
 * @author admin
 */
@WebServlet(name = "ReviewController", urlPatterns = {"/write-review"})
public class ReviewController extends HttpServlet {

    private ReviewDAO reviewDAO;
    private BookingDAO bookingDAO;
    private RoomDAO roomDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.reviewDAO = new ReviewDAO();
        this.bookingDAO = new BookingDAO();
        this.roomDAO = new RoomDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Step 1: Check authentication
        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        // Step 2: Validate bookingId parameter
// Step 2: Validate or Auto-detect bookingId parameter
        String bookingIdStr = request.getParameter("bookingId");
        int bookingId;
        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            // Tự động tìm đơn phòng COMPLETED chưa review của user này
            Optional<Integer> pendingBookingIdOpt = reviewDAO.findLatestPendingReviewBookingId(userId);
            if (pendingBookingIdOpt.isPresent()) {
                bookingId = pendingBookingIdOpt.get(); // Tìm thấy đơn tự động!
            } else {
                session.setAttribute("errorMessage", "Bạn hiện không có đơn đặt phòng nào đã hoàn thành để viết đánh giá.");
                response.sendRedirect(request.getContextPath() + "/rooms");
                return;
            }
        } else {
            try {
                bookingId = Integer.parseInt(bookingIdStr.trim());
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        }
        // Step 3: Check eligibility
        if (reviewDAO.hasReviewed(bookingId)) {
            session.setAttribute("errorMessage", "Đơn đặt phòng này đã được đánh giá trước đó.");
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }
        if (!reviewDAO.isBookingEligibleForReview(bookingId, userId)) {
            session.setAttribute("errorMessage", "Bạn chỉ có thể đánh giá sau khi đã hoàn thành kỳ nghỉ tại homestay.");
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }
        // Step 4: Load booking and room info for display
        Optional<Booking> bookingOpt = bookingDAO.findById(bookingId);
        if (bookingOpt.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        Booking booking = bookingOpt.get();
        Optional<Room> roomOpt = roomDAO.findById(booking.getRoomId());
        request.setAttribute("booking", booking);
        roomOpt.ifPresent(room -> request.setAttribute("room", room));
        // Step 5: Forward to JSP
        request.getRequestDispatcher("/WEB-INF/views/write-review.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Step 1: Check authentication
        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        // Step 2: Extract form parameters
        String bookingIdStr = request.getParameter("bookingId");
        String ratingStr = request.getParameter("rating");
        String title = request.getParameter("title");
        String comment = request.getParameter("comment");
        int bookingId;
        int rating = 0;
        try {
            bookingId = Integer.parseInt(bookingIdStr.trim());
            rating = Integer.parseInt(ratingStr.trim());
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Dữ liệu gửi lên không hợp lệ.");
            doGet(request, response);
            return;
        }
        // Step 3: Server-side validation
        if (rating < 1 || rating > 5) {
            request.setAttribute("errorMessage", "Vui lòng chọn số sao đánh giá từ 1 đến 5 sao.");
            retainFormDataAndForward(request, response, bookingId, rating, title, comment);
            return;
        }
        if (title == null || title.trim().length() < 3 || title.trim().length() > 150) {
            request.setAttribute("errorMessage", "Tiêu đề đánh giá phải từ 3 đến 150 ký tự.");
            retainFormDataAndForward(request, response, bookingId, rating, title, comment);
            return;
        }
        if (comment == null || comment.trim().length() < 10 || comment.trim().length() > 1000) {
            request.setAttribute("errorMessage", "Nội dung nhận xét phải từ 10 đến 1000 ký tự.");
            retainFormDataAndForward(request, response, bookingId, rating, title, comment);
            return;
        }
        // Step 4: Re-verify eligibility
        if (!reviewDAO.isBookingEligibleForReview(bookingId, userId)) {
            session.setAttribute("errorMessage", "Đơn đặt phòng không hợp lệ hoặc đã được đánh giá.");
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }
        // Step 5: Construct and persist review entity
        Optional<Booking> bookingOpt = bookingDAO.findById(bookingId);
        if (bookingOpt.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        Booking booking = bookingOpt.get();
        Optional<Room> roomOpt = roomDAO.findById(booking.getRoomId());
        int propertyId = roomOpt.map(Room::getPropertyId).orElse(1);
        Review review = new Review();
        review.setBookingId(bookingId);
        review.setUserId(userId);
        review.setRoomId(booking.getRoomId());
        review.setPropertyId(propertyId);
        review.setRating(rating);
        review.setTitle(title.trim());
        review.setComment(comment.trim());
        review.setStatus("APPROVED");
        boolean success = reviewDAO.insert(review);
        if (success) {
            // Synchronize room average rating
            reviewDAO.syncRoomRatingAndCount(booking.getRoomId());
            session.setAttribute("successMessage", "Cảm ơn bạn! Đánh giá của bạn đã được ghi nhận thành công.");
            response.sendRedirect(request.getContextPath() + "/room-detail?id=" + booking.getRoomId() + "#reviews");
        } else {
            request.setAttribute("errorMessage", "Có lỗi xảy ra trong quá trình lưu đánh giá. Vui lòng thử lại.");
            retainFormDataAndForward(request, response, bookingId, rating, title, comment);
        }
    }

    private void retainFormDataAndForward(HttpServletRequest request, HttpServletResponse response,
            int bookingId, int rating, String title, String comment)
            throws ServletException, IOException {
        request.setAttribute("enteredRating", rating);
        request.setAttribute("enteredTitle", title);
        request.setAttribute("enteredComment", comment);
        Optional<Booking> bookingOpt = bookingDAO.findById(bookingId);
        bookingOpt.ifPresent(booking -> {
            request.setAttribute("booking", booking);
            roomDAO.findById(booking.getRoomId()).ifPresent(room -> request.setAttribute("room", room));
        });
        request.getRequestDispatcher("/WEB-INF/views/write-review.jsp").forward(request, response);
    }
}
