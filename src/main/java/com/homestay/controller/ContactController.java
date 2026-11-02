package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.Booking;
import com.homestay.model.ContactMessage;
import com.homestay.model.TicketCategory;
import com.homestay.model.User;
import com.homestay.service.SupportService;
import com.homestay.util.LoginUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * ContactController - Serves public contact information and handles support ticket creation
 * for authenticated Customers and Hosts with CSRF, rate-limiting, and validation protection.
 */
@WebServlet(name = "ContactController", urlPatterns = {"/contact", "/contact-us"})
public class ContactController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ContactController.class.getName());
    private static final long SUBMISSION_COOLDOWN_MS = 15000; // 15 seconds rate limit cooldown

    private final SupportService supportService;
    private final BookingDAO bookingDAO;
    private final UserDAO userDAO;

    public ContactController() {
        this(new SupportService(), new BookingDAO(), new UserDAO());
    }

    public ContactController(SupportService supportService, BookingDAO bookingDAO, UserDAO userDAO) {
        this.supportService = supportService;
        this.bookingDAO = bookingDAO;
        this.userDAO = userDAO;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("activePage", "contact");

        User user = resolveUser(request);
        boolean isLoggedIn = (user != null);
        request.setAttribute("isLoggedIn", isLoggedIn);

        if (isLoggedIn) {
            request.setAttribute("currentUser", user);
            loadUserBookings(request, user);
            request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
        }

        // Available categories for form selection
        request.setAttribute("ticketCategories", TicketCategory.values());

        // Check for any flash message from redirection
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object flashSuccess = session.getAttribute("flashSuccessCode");
            if (flashSuccess != null) {
                request.setAttribute("flashSuccessCode", flashSuccess);
                session.removeAttribute("flashSuccessCode");
            }
        }

        request.getRequestDispatcher("/WEB-INF/views/contact.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("activePage", "contact");

        // 1. Authenticate user from session (do NOT trust parameters)
        User user = resolveUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=/contact");
            return;
        }

        HttpSession session = request.getSession(true);

        // 2. CSRF Token verification (one-time token consumption)
        String submittedCsrf = request.getParameter("csrfToken");
        if (!LoginUtil.consumeCsrfToken(request, submittedCsrf)) {
            renderFormWithError(request, response, user,
                    "Phiên bảo mật không hợp lệ hoặc biểu mẫu đã được gửi đi. Vui lòng kiểm tra lại.");
            return;
        }

        // 3. Rate limiting check
        Long lastSubmission = (Long) session.getAttribute("LAST_CONTACT_SUBMISSION_TIME");
        long now = System.currentTimeMillis();
        if (lastSubmission != null && (now - lastSubmission) < SUBMISSION_COOLDOWN_MS) {
            long remainingSeconds = Math.max(1, (SUBMISSION_COOLDOWN_MS - (now - lastSubmission)) / 1000);
            renderFormWithError(request, response, user,
                    "Vui lòng đợi thêm " + remainingSeconds + " giây trước khi gửi yêu cầu tiếp theo.");
            return;
        }

        // 4. Extract and validate parameters
        String subject = request.getParameter("subject");
        String categoryStr = request.getParameter("category");
        String message = request.getParameter("message");
        String bookingIdStr = request.getParameter("bookingId");

        String trimmedSubject = subject != null ? subject.trim() : "";
        String trimmedMessage = message != null ? message.trim() : "";
        TicketCategory category = TicketCategory.fromCode(categoryStr);
        Integer bookingId = null;

        if (trimmedSubject.length() < 5 || trimmedSubject.length() > 150) {
            renderFormWithError(request, response, user, "Tiêu đề yêu cầu phải có độ dài từ 5 đến 150 ký tự.");
            return;
        }

        if (category == null) {
            category = TicketCategory.GENERAL_FEEDBACK;
        }

        if (trimmedMessage.length() < 10 || trimmedMessage.length() > 3000) {
            renderFormWithError(request, response, user, "Nội dung yêu cầu phải có độ dài từ 10 đến 3000 ký tự.");
            return;
        }

        if (bookingIdStr != null && !bookingIdStr.isBlank()) {
            try {
                bookingId = Integer.parseInt(bookingIdStr.trim());
            } catch (NumberFormatException e) {
                renderFormWithError(request, response, user, "Mã đặt phòng liên quan không hợp lệ.");
                return;
            }
        }

        // 5. Build and submit ticket via SupportService
        ContactMessage ticket = new ContactMessage();
        ticket.setSubject(trimmedSubject);
        ticket.setCategory(category);
        ticket.setMessage(trimmedMessage);
        ticket.setBookingId(bookingId);

        try {
            ContactMessage createdTicket = supportService.createTicket(ticket, user);

            // Record timestamp for rate limiting
            session.setAttribute("LAST_CONTACT_SUBMISSION_TIME", now);
            session.setAttribute("flashSuccessCode", createdTicket.getTicketCode());

            // Post/Redirect/Get pattern
            response.sendRedirect(request.getContextPath() + "/support/ticket?code="
                    + createdTicket.getTicketCode() + "&created=1");
        } catch (IllegalArgumentException e) {
            renderFormWithError(request, response, user, e.getMessage());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error creating support ticket", e);
            renderFormWithError(request, response, user, "Có lỗi xảy ra trong quá trình xử lý yêu cầu. Vui lòng thử lại sau.");
        }
    }

    private void renderFormWithError(HttpServletRequest request, HttpServletResponse response,
                                    User user, String errorMessage) throws ServletException, IOException {
        request.setAttribute("isLoggedIn", true);
        request.setAttribute("currentUser", user);
        request.setAttribute("errorMessage", errorMessage);
        request.setAttribute("ticketCategories", TicketCategory.values());

        // Preserve input values
        request.setAttribute("formSubject", request.getParameter("subject"));
        request.setAttribute("formCategory", request.getParameter("category"));
        request.setAttribute("formBookingId", request.getParameter("bookingId"));
        request.setAttribute("formMessage", request.getParameter("message"));

        // Re-generate fresh CSRF token and reload user bookings
        loadUserBookings(request, user);
        request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));

        request.getRequestDispatcher("/WEB-INF/views/contact.jsp").forward(request, response);
    }

    private void loadUserBookings(HttpServletRequest request, User user) {
        List<Booking> bookings = new ArrayList<>();
        try {
            boolean isHost = user.getRole() != null &&
                    ("ROLE_HOST".equalsIgnoreCase(user.getRole().getRoleName()) || "HOST".equalsIgnoreCase(user.getRole().getRoleName()));

            if (isHost) {
                bookings = bookingDAO.findBookingsByHostProperties(user.getId());
            } else {
                bookings = bookingDAO.findBookingsByUserId(user.getId());
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to load bookings for user in contact form", e);
        }
        request.setAttribute("userBookings", bookings);
    }

    private User resolveUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }

        Object userObj = session.getAttribute("user");
        if (userObj instanceof User) {
            return (User) userObj;
        }

        Object uidObj = session.getAttribute("userId");
        if (uidObj instanceof Number) {
            int uid = ((Number) uidObj).intValue();
            User user = userDAO.findById(uid).orElse(null);
            if (user != null) {
                session.setAttribute("user", user);
            }
            return user;
        }
        return null;
    }
}
