package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.RoomDAO;
import com.homestay.model.Booking;
import com.homestay.model.Room;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.format.DateTimeParseException;
import java.time.format.ResolverStyle;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

/**
 * BookingController - Handles reservation forms and booking submissions.
 *
 * Iteration 2:
 * - Requires authentication before creating a booking.
 * - Associates bookings with the authenticated user.
 * - Validates booking information.
 * - Supports UI datepicker ("d MMMM, yyyy"), ISO ("yyyy-MM-dd") and VN ("dd/MM/yyyy").
 * - Retrieves propertyId from the selected room.
 * - Calculates booking subtotal.
 * - Creates booking with PENDING status.
 * - Redirects to Checkout after successful insertion.
 */
@WebServlet(
        name = "BookingController",
        urlPatterns = {"/reservation", "/booking"}
)
public class BookingController extends HttpServlet {

    private RoomDAO roomDAO;
    private BookingDAO bookingDAO;

    private static final DateTimeFormatter VIETNAMESE_DATE_FORMAT =
            DateTimeFormatter.ofPattern("d/M/uuuu")
                    .withResolverStyle(ResolverStyle.SMART);

    private static final DateTimeFormatter DATEPICKER_FORMAT =
            new DateTimeFormatterBuilder()
                    .parseCaseInsensitive()
                    .appendPattern("d MMMM, yyyy")
                    .toFormatter(Locale.ENGLISH);

    private static final DateTimeFormatter DATEPICKER_FORMAT_SHORT =
            new DateTimeFormatterBuilder()
                    .parseCaseInsensitive()
                    .appendPattern("d MMM, yyyy")
                    .toFormatter(Locale.ENGLISH);

    private static final DateTimeFormatter DASH_DATE_FORMAT =
            DateTimeFormatter.ofPattern("d-M-uuuu")
                    .withResolverStyle(ResolverStyle.SMART);

    @Override
    public void init() throws ServletException {
        super.init();
        this.roomDAO = new RoomDAO();
        this.bookingDAO = new BookingDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        List<Room> rooms = roomDAO.findAll();

        request.setAttribute("rooms", rooms);
        request.setAttribute("activePage", "reservation");

        String selectedRoomId = request.getParameter("roomId");

        if (selectedRoomId != null && !selectedRoomId.trim().isEmpty()) {
            request.setAttribute("selectedRoomId", selectedRoomId);
        }

        request.getRequestDispatcher(
                "/WEB-INF/views/reservation.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // ==================== AUTHENTICATION ====================

        HttpSession session = request.getSession(false);

        if (session == null ||
                !(session.getAttribute("userId") instanceof Integer)) {

            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Vui lòng đăng nhập trước khi đặt phòng."
            );
            return;
        }

        int currentUserId =
                (Integer) session.getAttribute("userId");

        if (currentUserId <= 0) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Phiên đăng nhập không hợp lệ."
            );
            return;
        }

        // ==================== READ FORM DATA ====================

        String name = trimToNull(request.getParameter("name"));
        String email = trimToNull(request.getParameter("email"));
        String phone = trimToNull(request.getParameter("phone"));
        String checkinStr = trimToNull(request.getParameter("checkin_date"));
        String checkoutStr = trimToNull(request.getParameter("checkout_date"));
        String adultsStr = trimToNull(request.getParameter("adults"));
        String childrenStr = trimToNull(request.getParameter("children"));
        String roomIdStr = trimToNull(request.getParameter("room_id"));
        String notes = trimToNull(request.getParameter("notes"));

        try {

            // ==================== VALIDATE CUSTOMER ====================

            if (name == null) {
                throw new IllegalArgumentException(
                        "Vui lòng nhập họ tên."
                );
            }

            if (email == null || !isValidEmail(email)) {
                throw new IllegalArgumentException(
                        "Vui lòng nhập email hợp lệ."
                );
            }

            if (phone == null) {
                throw new IllegalArgumentException(
                        "Vui lòng nhập số điện thoại."
                );
            }

            // ==================== VALIDATE ROOM ====================

            if (roomIdStr == null) {
                throw new IllegalArgumentException(
                        "Vui lòng chọn phòng."
                );
            }

            int roomId = Integer.parseInt(roomIdStr);

            if (roomId <= 0) {
                throw new IllegalArgumentException(
                        "Mã phòng không hợp lệ."
                );
            }

            Optional<Room> roomOpt = roomDAO.findById(roomId);

            if (roomOpt.isEmpty()) {
                throw new IllegalArgumentException(
                        "Không tìm thấy phòng đã chọn."
                );
            }

            Room room = roomOpt.get();

            if (room.getPropertyId() == null) {
                throw new IllegalStateException(
                        "Phòng chưa được liên kết với Homestay."
                );
            }

            if (room.getPricePerNight() == null ||
                    room.getPricePerNight().compareTo(BigDecimal.ZERO) <= 0) {

                throw new IllegalStateException(
                        "Giá phòng không hợp lệ."
                );
            }

            if (!"AVAILABLE".equalsIgnoreCase(room.getStatus())) {
                throw new IllegalArgumentException(
                        "Phòng hiện không khả dụng."
                );
            }

            // ==================== VALIDATE DATES ====================

            if (checkinStr == null || checkoutStr == null) {
                throw new IllegalArgumentException(
                        "Vui lòng chọn ngày nhận phòng và trả phòng."
                );
            }

            LocalDate checkIn = parseBookingDate(checkinStr);
            LocalDate checkOut = parseBookingDate(checkoutStr);

            if (checkIn.isBefore(LocalDate.now())) {
                throw new IllegalArgumentException(
                        "Ngày nhận phòng không được ở trong quá khứ."
                );
            }

            if (!checkOut.isAfter(checkIn)) {
                throw new IllegalArgumentException(
                        "Ngày trả phòng phải sau ngày nhận phòng."
                );
            }

            long nights = ChronoUnit.DAYS.between(
                    checkIn,
                    checkOut
            );

            // ==================== VALIDATE GUESTS ====================

            int adults = adultsStr != null
                    ? Integer.parseInt(adultsStr)
                    : 1;

            int children = childrenStr != null
                    ? Integer.parseInt(childrenStr)
                    : 0;

            if (adults < 1) {
                throw new IllegalArgumentException(
                        "Phải có ít nhất một người lớn."
                );
            }

            if (children < 0) {
                throw new IllegalArgumentException(
                        "Số trẻ em không hợp lệ."
                );
            }

            if (adults + children > room.getCapacity()) {
                throw new IllegalArgumentException(
                        "Số khách (" + (adults + children) + ") vượt quá sức chứa của phòng ("
                                + room.getCapacity() + " người)."
                );
            }

            // ==================== CALCULATE PRICE ====================

            BigDecimal subtotal = room.getPricePerNight()
                    .multiply(BigDecimal.valueOf(nights));

            // Voucher will be calculated in Checkout.
            BigDecimal discountAmount = BigDecimal.ZERO;

            BigDecimal totalAmount = subtotal.subtract(
                    discountAmount
            );

            // ==================== CREATE BOOKING ====================

            Booking booking = new Booking();

            // Always get userId from authenticated session.
            booking.setUserId(currentUserId);

            booking.setCustomerName(name);
            booking.setCustomerEmail(email);
            booking.setCustomerPhone(phone);

            booking.setRoomId(roomId);
            booking.setPropertyId(room.getPropertyId());

            booking.setCheckInDate(Date.valueOf(checkIn));
            booking.setCheckOutDate(Date.valueOf(checkOut));

            booking.setAdults(adults);
            booking.setChildren(children);

            booking.setSubtotal(subtotal);
            booking.setDiscountAmount(discountAmount);
            booking.setTotalAmount(totalAmount);

            // Keep compatibility with existing code.
            booking.setTotalPrice(totalAmount);

            booking.setNotes(notes);
            booking.setStatus("PENDING");

            // ==================== SAVE BOOKING ====================

            boolean success = bookingDAO.insert(booking);

            if (!success || booking.getId() <= 0) {
                throw new IllegalStateException(
                        "Không thể lưu đơn đặt phòng. Vui lòng thử lại."
                );
            }

            // ==================== REDIRECT TO CHECKOUT ====================

            response.sendRedirect(
                    request.getContextPath()
                            + "/checkout?bookingId="
                            + booking.getId()
            );

        } catch (NumberFormatException e) {

            preserveFormInputs(request);
            request.setAttribute(
                    "messageError",
                    "Mã phòng hoặc số lượng khách không hợp lệ."
            );
            doGet(request, response);

        } catch (DateTimeParseException e) {

            preserveFormInputs(request);
            request.setAttribute(
                    "messageError",
                    "Định dạng ngày không hợp lệ. Vui lòng chọn ngày từ lịch hoặc nhập định dạng ngày/tháng/năm (ví dụ: 15/11/2026 hoặc 15 November, 2026)."
            );
            doGet(request, response);

        } catch (IllegalArgumentException |
                 IllegalStateException e) {

            preserveFormInputs(request);
            request.setAttribute(
                    "messageError",
                    e.getMessage()
            );
            doGet(request, response);
        }
    }

    /**
     * Preserves user-entered form inputs so they are not wiped out on validation error.
     */
    private void preserveFormInputs(HttpServletRequest request) {
        request.setAttribute("enteredName", request.getParameter("name"));
        request.setAttribute("enteredPhone", request.getParameter("phone"));
        request.setAttribute("enteredEmail", request.getParameter("email"));
        request.setAttribute("enteredCheckinDate", request.getParameter("checkin_date"));
        request.setAttribute("enteredCheckoutDate", request.getParameter("checkout_date"));
        request.setAttribute("enteredAdults", request.getParameter("adults"));
        request.setAttribute("enteredChildren", request.getParameter("children"));
        request.setAttribute("enteredNotes", request.getParameter("notes"));
        request.setAttribute("selectedRoomId", request.getParameter("room_id"));
    }

    /**
     * Parses booking dates in any of the following supported formats:
     * 1. d MMMM, yyyy (example: "4 October, 2026") - UI bootstrap-datepicker format
     * 2. d MMM, yyyy (example: "4 Oct, 2026")
     * 3. yyyy-MM-dd (example: "2026-10-30") - Standard ISO / HTML5 date format
     * 4. d/M/uuuu (example: "30/10/2026") - Vietnamese day/month/year format
     * 5. d-M-uuuu (example: "30-10-2026")
     */
    public LocalDate parseBookingDate(String dateString) {

        if (dateString == null || dateString.isBlank()) {
            throw new DateTimeParseException(
                    "Ngày không được để trống",
                    dateString == null ? "" : dateString,
                    0
            );
        }

        String value = dateString.trim();

        // 1. Format: d MMMM, yyyy (e.g. "4 October, 2026") from UI Datepicker
        try {
            return LocalDate.parse(value, DATEPICKER_FORMAT);
        } catch (DateTimeParseException ignored) {
        }

        // 2. Format: d MMM, yyyy (e.g. "4 Oct, 2026")
        try {
            return LocalDate.parse(value, DATEPICKER_FORMAT_SHORT);
        } catch (DateTimeParseException ignored) {
        }

        // 3. Format: yyyy-MM-dd (ISO / HTML5)
        try {
            return LocalDate.parse(value, DateTimeFormatter.ISO_LOCAL_DATE);
        } catch (DateTimeParseException ignored) {
        }

        // 4. Format: dd/MM/yyyy or d/M/yyyy (Vietnamese format)
        try {
            return LocalDate.parse(value, VIETNAMESE_DATE_FORMAT);
        } catch (DateTimeParseException ignored) {
        }

        // 5. Format: dd-MM-yyyy or d-M-yyyy
        try {
            return LocalDate.parse(value, DASH_DATE_FORMAT);
        } catch (DateTimeParseException ignored) {
        }

        throw new DateTimeParseException(
                "Định dạng ngày không được hỗ trợ: " + value,
                value,
                0
        );
    }

    /**
     * Returns null for null, empty or whitespace-only strings.
     */
    private String trimToNull(String value) {

        if (value == null) {
            return null;
        }

        String trimmed = value.trim();

        return trimmed.isEmpty() ? null : trimmed;
    }

    /**
     * Basic email format validation.
     */
    private boolean isValidEmail(String email) {

        return email != null
                && email.length() <= 254
                && email.matches(
                        "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
                );
    }
}
