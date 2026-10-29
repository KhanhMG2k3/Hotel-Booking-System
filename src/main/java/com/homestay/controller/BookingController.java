package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.RoomDAO;
import com.homestay.dao.VoucherDAO;
import com.homestay.model.Booking;
import com.homestay.model.BookingDraft;
import com.homestay.model.BookingRoomItem;
import com.homestay.model.Room;
import com.homestay.model.User;
import com.homestay.model.Voucher;
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
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * BookingController - Handles the 2-step booking flow:
 * Step 1: Select Room & Dates with Min/Max Stay validation and room availability check.
 * Step 2: Review & Confirm with Multi-Room support (optionally add more rooms), voucher, and customer info.
 * Step Success: Displays booking confirmation and receipt.
 */
@WebServlet(name = "BookingController", urlPatterns = {"/booking", "/reservation"})
public class BookingController extends HttpServlet {

    public static final String SESSION_BOOKING_DRAFT = "bookingDraft";
    public static final int MIN_STAY_NIGHTS = 1;
    public static final int MAX_STAY_NIGHTS = 30;

    private RoomDAO roomDAO;
    private BookingDAO bookingDAO;
    private VoucherDAO voucherDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.roomDAO = new RoomDAO();
        this.bookingDAO = new BookingDAO();
        this.voucherDAO = new VoucherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String step = request.getParameter("step");
        request.setAttribute("activePage", "reservation");
        request.setAttribute("minStay", MIN_STAY_NIGHTS);
        request.setAttribute("maxStay", MAX_STAY_NIGHTS);

        if ("2".equals(step)) {
            handleGetStep2(request, response);
        } else if ("success".equals(step)) {
            handleGetSuccess(request, response);
        } else {
            handleGetStep1(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }

        switch (action) {
            case "step1_submit":
                handlePostStep1(request, response);
                break;
            case "add_room":
                handlePostAddRoom(request, response);
                break;
            case "remove_room":
                handlePostRemoveRoom(request, response);
                break;
            case "apply_voucher":
                handlePostApplyVoucher(request, response);
                break;
            case "confirm":
                handlePostConfirm(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/booking?step=1");
                break;
        }
    }

    // =========================================================================
    // STEP 1 HANDLERS: Select Room & Dates (Validates Min/Max Stay & Availability)
    // =========================================================================

    private void handleGetStep1(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Room> rooms = roomDAO.findAll();
        request.setAttribute("rooms", rooms);
        request.setAttribute("step", "1");

        // Pre-select room if roomId parameter is provided (e.g. from /room-detail or /rooms)
        String roomIdParam = request.getParameter("roomId");
        if (roomIdParam == null || roomIdParam.isEmpty()) {
            roomIdParam = request.getParameter("room_id");
        }

        HttpSession session = request.getSession();
        BookingDraft draft = (BookingDraft) session.getAttribute(SESSION_BOOKING_DRAFT);

        Integer selectedRoomId = null;
        if (roomIdParam != null && !roomIdParam.isEmpty()) {
            try {
                selectedRoomId = Integer.parseInt(roomIdParam);
            } catch (NumberFormatException ignored) {}
        } else if (draft != null && draft.getPrimaryRoom() != null) {
            selectedRoomId = draft.getPrimaryRoom().getRoomId();
        }

        if (selectedRoomId == null && !rooms.isEmpty()) {
            selectedRoomId = rooms.get(0).getId();
        }
        request.setAttribute("selectedRoomId", selectedRoomId);

        // Default dates: tomorrow to the day after tomorrow
        LocalDate defaultCheckIn = LocalDate.now().plusDays(1);
        LocalDate defaultCheckOut = defaultCheckIn.plusDays(1);

        if (draft != null && draft.getPrimaryRoom() != null) {
            defaultCheckIn = draft.getPrimaryRoom().getCheckInDate().toLocalDate();
            defaultCheckOut = draft.getPrimaryRoom().getCheckOutDate().toLocalDate();
            request.setAttribute("adults", draft.getPrimaryRoom().getAdults());
            request.setAttribute("children", draft.getPrimaryRoom().getChildren());
        }

        request.setAttribute("checkinDate", defaultCheckIn.toString());
        request.setAttribute("checkoutDate", defaultCheckOut.toString());
        request.setAttribute("todayDate", LocalDate.now().toString());

        request.getRequestDispatcher("/WEB-INF/views/booking.jsp").forward(request, response);
    }

    private void handlePostStep1(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String roomIdStr = request.getParameter("room_id");
        String checkinStr = request.getParameter("checkin_date");
        String checkoutStr = request.getParameter("checkout_date");
        String adultsStr = request.getParameter("adults");
        String childrenStr = request.getParameter("children");

        int roomId;
        try {
            roomId = Integer.parseInt(roomIdStr);
        } catch (Exception e) {
            request.setAttribute("messageError", "Vui lòng chọn một phòng homestay hợp lệ.");
            handleGetStep1(request, response);
            return;
        }

        Optional<Room> roomOpt = roomDAO.findById(roomId);
        if (roomOpt.isEmpty()) {
            request.setAttribute("messageError", "Phòng đã chọn không tồn tại trong hệ thống.");
            handleGetStep1(request, response);
            return;
        }
        Room room = roomOpt.get();

        LocalDate checkIn;
        LocalDate checkOut;
        try {
            checkIn = LocalDate.parse(checkinStr);
            checkOut = LocalDate.parse(checkoutStr);
        } catch (DateTimeParseException | NullPointerException e) {
            request.setAttribute("messageError", "Định dạng ngày nhận/trả phòng không hợp lệ.");
            handleGetStep1(request, response);
            return;
        }

        // 1. Validate dates are not in the past
        LocalDate today = LocalDate.now();
        if (checkIn.isBefore(today)) {
            request.setAttribute("messageError", "Ngày nhận phòng không được ở trong quá khứ.");
            handleGetStep1(request, response);
            return;
        }

        if (!checkOut.isAfter(checkIn)) {
            request.setAttribute("messageError", "Ngày trả phòng phải sau ngày nhận phòng.");
            handleGetStep1(request, response);
            return;
        }

        // 2. Validate Min/Max Stay
        long nights = ChronoUnit.DAYS.between(checkIn, checkOut);
        if (nights < MIN_STAY_NIGHTS) {
            request.setAttribute("messageError", "Thời gian lưu trú tối thiểu (Min Stay) là " + MIN_STAY_NIGHTS + " đêm.");
            handleGetStep1(request, response);
            return;
        }

        if (nights > MAX_STAY_NIGHTS) {
            request.setAttribute("messageError", "Thời gian lưu trú tối đa (Max Stay) là " + MAX_STAY_NIGHTS + " đêm. Quý khách vui lòng chọn lại ngày hoặc liên hệ hỗ trợ cho nhu cầu thuê dài hạn.");
            handleGetStep1(request, response);
            return;
        }

        // 3. Validate number of guests
        int adults = 1;
        int children = 0;
        try {
            adults = Integer.parseInt(adultsStr);
            children = (childrenStr != null && !childrenStr.isEmpty()) ? Integer.parseInt(childrenStr) : 0;
        } catch (NumberFormatException ignored) {}

        if (adults < 1) {
            request.setAttribute("messageError", "Đơn đặt phòng phải có ít nhất 1 người lớn.");
            handleGetStep1(request, response);
            return;
        }

        int totalGuests = adults + children;
        int roomCapacity = room.getCapacity() > 0 ? room.getCapacity() : 2;
        if (totalGuests > roomCapacity) {
            request.setAttribute("messageError", "Số lượng khách (" + totalGuests + " người) vượt quá sức chứa tối đa của phòng [" + room.getRoomName() + "] (" + roomCapacity + " người). Quý khách có thể thêm phòng ở Bước 2 để đáp ứng số lượng người!");
            handleGetStep1(request, response);
            return;
        }

        // 4. Validate Room Availability
        Date sqlCheckIn = Date.valueOf(checkIn);
        Date sqlCheckOut = Date.valueOf(checkOut);
        boolean isAvailable = bookingDAO.isRoomAvailable(roomId, sqlCheckIn, sqlCheckOut, null);
        if (!isAvailable) {
            request.setAttribute("messageError", "Rất tiếc! Phòng [" + room.getRoomName() + "] đã có người đặt trong khoảng thời gian từ " + checkIn + " đến " + checkOut + ". Quý khách vui lòng chọn ngày khác hoặc phòng khác.");
            handleGetStep1(request, response);
            return;
        }

        // 5. Build BookingRoomItem and save into BookingDraft
        BigDecimal pricePerNight = room.getPricePerNight() != null ? room.getPricePerNight() : BigDecimal.valueOf(1000000.0);
        BigDecimal subtotal = pricePerNight.multiply(BigDecimal.valueOf(nights));

        BookingRoomItem primaryItem = new BookingRoomItem(
                room.getId(),
                room.getRoomName(),
                room.getRoomTypeName(),
                room.getImageUrl(),
                room.getPropertyName() != null ? room.getPropertyName() : "Sogo Homestay",
                sqlCheckIn,
                sqlCheckOut,
                adults,
                children,
                roomCapacity,
                (int) nights,
                pricePerNight,
                subtotal
        );

        HttpSession session = request.getSession();
        BookingDraft draft = new BookingDraft();
        draft.addRoom(primaryItem);

        // Pre-fill user contact info if logged in
        User loggedUser = (User) session.getAttribute("user");
        if (loggedUser != null) {
            draft.setCustomerName(loggedUser.getFullName());
            draft.setCustomerEmail(loggedUser.getEmail());
            draft.setCustomerPhone(loggedUser.getPhone());
        }

        session.setAttribute(SESSION_BOOKING_DRAFT, draft);
        response.sendRedirect(request.getContextPath() + "/booking?step=2");
    }

    // =========================================================================
    // STEP 2 HANDLERS: Review & Confirm (Multi-Room Support)
    // =========================================================================

    private void handleGetStep2(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        BookingDraft draft = (BookingDraft) session.getAttribute(SESSION_BOOKING_DRAFT);

        if (draft == null || draft.getRooms().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/booking?step=1&error=draft_empty");
            return;
        }

        BookingRoomItem primary = draft.getPrimaryRoom();
        List<Room> availableRooms = bookingDAO.findAvailableRooms(primary.getCheckInDate(), primary.getCheckOutDate(), null);

        // Remove rooms already included in current draft
        availableRooms.removeIf(r -> draft.hasRoom(r.getId()));

        request.setAttribute("step", "2");
        request.setAttribute("draft", draft);
        request.setAttribute("availableRooms", availableRooms);

        request.getRequestDispatcher("/WEB-INF/views/booking.jsp").forward(request, response);
    }

    private void handlePostAddRoom(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        BookingDraft draft = (BookingDraft) session.getAttribute(SESSION_BOOKING_DRAFT);

        if (draft == null || draft.getRooms().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/booking?step=1");
            return;
        }

        String extraRoomIdStr = request.getParameter("extra_room_id");
        String extraAdultsStr = request.getParameter("extra_adults");
        String extraChildrenStr = request.getParameter("extra_children");

        try {
            int extraRoomId = Integer.parseInt(extraRoomIdStr);
            if (draft.hasRoom(extraRoomId)) {
                request.setAttribute("messageError", "Phòng này đã có trong đơn đặt của bạn.");
                handleGetStep2(request, response);
                return;
            }

            Optional<Room> roomOpt = roomDAO.findById(extraRoomId);
            if (roomOpt.isEmpty()) {
                request.setAttribute("messageError", "Phòng được chọn không tồn tại.");
                handleGetStep2(request, response);
                return;
            }

            Room extraRoom = roomOpt.get();
            BookingRoomItem primary = draft.getPrimaryRoom();

            // Check availability for this room
            boolean available = bookingDAO.isRoomAvailable(extraRoomId, primary.getCheckInDate(), primary.getCheckOutDate(), null);
            if (!available) {
                request.setAttribute("messageError", "Phòng [" + extraRoom.getRoomName() + "] không còn trống trong khoảng thời gian đã chọn.");
                handleGetStep2(request, response);
                return;
            }

            int adults = 1;
            int children = 0;
            try {
                adults = Integer.parseInt(extraAdultsStr);
                children = (extraChildrenStr != null && !extraChildrenStr.isEmpty()) ? Integer.parseInt(extraChildrenStr) : 0;
            } catch (Exception ignored) {}

            int cap = extraRoom.getCapacity() > 0 ? extraRoom.getCapacity() : 2;
            if (adults + children > cap) {
                request.setAttribute("messageError", "Số khách phòng phụ vượt quá sức chứa tối đa (" + cap + " người).");
                handleGetStep2(request, response);
                return;
            }

            BigDecimal rate = extraRoom.getPricePerNight() != null ? extraRoom.getPricePerNight() : BigDecimal.valueOf(1000000.0);
            BigDecimal subtotal = rate.multiply(BigDecimal.valueOf(primary.getNumberOfNights()));

            BookingRoomItem extraItem = new BookingRoomItem(
                    extraRoom.getId(),
                    extraRoom.getRoomName(),
                    extraRoom.getRoomTypeName(),
                    extraRoom.getImageUrl(),
                    extraRoom.getPropertyName() != null ? extraRoom.getPropertyName() : "Sogo Homestay",
                    primary.getCheckInDate(),
                    primary.getCheckOutDate(),
                    adults,
                    children,
                    cap,
                    primary.getNumberOfNights(),
                    rate,
                    subtotal
            );

            draft.addRoom(extraItem);
            session.setAttribute(SESSION_BOOKING_DRAFT, draft);
            response.sendRedirect(request.getContextPath() + "/booking?step=2&added=1");
        } catch (Exception e) {
            request.setAttribute("messageError", "Có lỗi xảy ra khi thêm phòng: " + e.getMessage());
            handleGetStep2(request, response);
        }
    }

    private void handlePostRemoveRoom(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        BookingDraft draft = (BookingDraft) session.getAttribute(SESSION_BOOKING_DRAFT);

        if (draft != null) {
            String removeRoomIdStr = request.getParameter("remove_room_id");
            try {
                int removeRoomId = Integer.parseInt(removeRoomIdStr);
                if (draft.getRooms().size() > 1) {
                    draft.removeRoom(removeRoomId);
                    session.setAttribute(SESSION_BOOKING_DRAFT, draft);
                }
            } catch (Exception ignored) {}
        }

        response.sendRedirect(request.getContextPath() + "/booking?step=2");
    }

    private void handlePostApplyVoucher(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        BookingDraft draft = (BookingDraft) session.getAttribute(SESSION_BOOKING_DRAFT);

        if (draft == null || draft.getRooms().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/booking?step=1");
            return;
        }

        String voucherCode = request.getParameter("voucher_code");
        if (voucherCode == null || voucherCode.trim().isEmpty()) {
            draft.setVoucherCode(null);
            draft.setDiscountAmount(BigDecimal.ZERO);
            session.setAttribute(SESSION_BOOKING_DRAFT, draft);
            response.sendRedirect(request.getContextPath() + "/booking?step=2");
            return;
        }

        Optional<Voucher> voucherOpt = voucherDAO.findByCode(voucherCode.trim());
        if (voucherOpt.isEmpty()) {
            request.setAttribute("voucherError", "Mã giảm giá [" + voucherCode + "] không tồn tại hoặc đã hết hạn.");
            handleGetStep2(request, response);
            return;
        }

        Voucher v = voucherOpt.get();
        LocalDate now = LocalDate.now();
        if (v.getStartDate() != null && now.isBefore(v.getStartDate().toLocalDate())) {
            request.setAttribute("voucherError", "Mã giảm giá chưa đến thời gian áp dụng.");
            handleGetStep2(request, response);
            return;
        }

        if (v.getEndDate() != null && now.isAfter(v.getEndDate().toLocalDate())) {
            request.setAttribute("voucherError", "Mã giảm giá này đã hết hạn sử dụng.");
            handleGetStep2(request, response);
            return;
        }

        BigDecimal discount = BigDecimal.ZERO;
        BigDecimal subtotal = draft.getSubtotal();
        if ("PERCENTAGE".equalsIgnoreCase(v.getDiscountType())) {
            BigDecimal percent = v.getDiscountValue().divide(BigDecimal.valueOf(100));
            discount = subtotal.multiply(percent);
        } else {
            discount = v.getDiscountValue();
        }

        if (discount.compareTo(subtotal) > 0) {
            discount = subtotal;
        }

        draft.setVoucherCode(v.getCode());
        draft.setDiscountAmount(discount);
        session.setAttribute(SESSION_BOOKING_DRAFT, draft);
        response.sendRedirect(request.getContextPath() + "/booking?step=2&voucher_applied=1");
    }

    private void handlePostConfirm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        BookingDraft draft = (BookingDraft) session.getAttribute(SESSION_BOOKING_DRAFT);

        if (draft == null || draft.getRooms().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/booking?step=1");
            return;
        }

        String customerName = request.getParameter("customer_name");
        String customerEmail = request.getParameter("customer_email");
        String customerPhone = request.getParameter("customer_phone");
        String notes = request.getParameter("notes");
        String specialRequests = request.getParameter("special_requests");

        // Validate customer contact info
        if (customerName == null || customerName.trim().isEmpty() ||
            customerEmail == null || customerEmail.trim().isEmpty() ||
            customerPhone == null || customerPhone.trim().isEmpty()) {
            request.setAttribute("messageError", "Vui lòng nhập đầy đủ Họ tên, Email và Số điện thoại liên hệ.");
            handleGetStep2(request, response);
            return;
        }

        // Double check room availability for each room in draft
        BookingRoomItem primary = draft.getPrimaryRoom();
        for (BookingRoomItem item : draft.getRooms()) {
            boolean avail = bookingDAO.isRoomAvailable(item.getRoomId(), primary.getCheckInDate(), primary.getCheckOutDate(), null);
            if (!avail) {
                request.setAttribute("messageError", "Rất tiếc! Phòng [" + item.getRoomName() + "] vừa được khách khác đặt. Vui lòng kiểm tra lại danh sách phòng.");
                handleGetStep2(request, response);
                return;
            }
        }

        Booking booking = new Booking();
        booking.setCustomerName(customerName.trim());
        booking.setEmail(customerEmail.trim());
        booking.setCustomerPhone(customerPhone.trim());
        booking.setNotes(notes != null ? notes.trim() : "");
        booking.setSpecialRequests(specialRequests != null ? specialRequests.trim() : "");
        booking.setAdults(draft.getTotalGuests());
        booking.setChildren(0);
        booking.setGuestCount(draft.getTotalGuests());
        booking.setTotalPrice(draft.getTotalPrice());
        booking.setStatus("CONFIRMED");

        User loggedUser = (User) session.getAttribute("user");
        if (loggedUser != null) {
            booking.setUserId(loggedUser.getId());
        }

        boolean success = bookingDAO.insertMultiRoomBooking(booking, draft.getRooms());
        if (success) {
            session.removeAttribute(SESSION_BOOKING_DRAFT);
            response.sendRedirect(request.getContextPath() + "/booking?step=success&code=" + booking.getBookingCode());
        } else {
            request.setAttribute("messageError", "Có lỗi xảy ra khi lưu đơn đặt phòng vào cơ sở dữ liệu. Vui lòng thử lại!");
            handleGetStep2(request, response);
        }
    }

    // =========================================================================
    // STEP SUCCESS: Booking Confirmation & Receipt
    // =========================================================================

    private void handleGetSuccess(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String code = request.getParameter("code");
        if (code != null && !code.trim().isEmpty()) {
            Optional<Booking> bookingOpt = bookingDAO.findByBookingCode(code.trim());
            bookingOpt.ifPresent(booking -> request.setAttribute("booking", booking));
        }

        request.setAttribute("step", "success");
        request.getRequestDispatcher("/WEB-INF/views/booking.jsp").forward(request, response);
    }
}
