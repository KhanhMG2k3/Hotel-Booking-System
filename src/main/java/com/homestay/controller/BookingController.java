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
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.format.DateTimeParseException;
import java.time.format.ResolverStyle;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

/**
 * BookingController - Handles both the rich 2-step booking flow (Multi-room, Vouchers, Min/Max stay)
 * and single-step reservation submissions.
 * Redirects to Checkout for VietQR / online payment when required.
 */
@WebServlet(name = "BookingController", urlPatterns = {"/booking", "/reservation"})
public class BookingController extends HttpServlet {

    public static final String SESSION_BOOKING_DRAFT = "bookingDraft";
    public static final int MIN_STAY_NIGHTS = 1;
    public static final int MAX_STAY_NIGHTS = 30;

    private RoomDAO roomDAO;
    private BookingDAO bookingDAO;
    private VoucherDAO voucherDAO;

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
                if (request.getParameter("checkin_date") != null) {
                    handleSingleStepReservation(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/booking?step=1");
                }
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
        request.getRequestDispatcher("/WEB-INF/views/reservation.jsp").forward(request, response);
    }

    private void handlePostStep1(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String roomIdStr = request.getParameter("room_id");
        String checkInStr = request.getParameter("check_in");
        String checkOutStr = request.getParameter("check_out");
        String adultsStr = request.getParameter("adults");
        String childrenStr = request.getParameter("children");

        if (roomIdStr == null || roomIdStr.trim().isEmpty() ||
            checkInStr == null || checkInStr.trim().isEmpty() ||
            checkOutStr == null || checkOutStr.trim().isEmpty()) {
            request.setAttribute("messageError", "Vui lòng chọn phòng, ngày nhận phòng và ngày trả phòng.");
            handleGetStep1(request, response);
            return;
        }

        int roomId;
        LocalDate checkIn;
        LocalDate checkOut;
        int adults = 1;
        int children = 0;

        try {
            roomId = Integer.parseInt(roomIdStr.trim());
            checkIn = parseBookingDate(checkInStr.trim());
            checkOut = parseBookingDate(checkOutStr.trim());
            if (adultsStr != null && !adultsStr.trim().isEmpty()) {
                adults = Math.max(1, Integer.parseInt(adultsStr.trim()));
            }
            if (childrenStr != null && !childrenStr.trim().isEmpty()) {
                children = Math.max(0, Integer.parseInt(childrenStr.trim()));
            }
        } catch (Exception e) {
            request.setAttribute("messageError", "Dữ liệu nhập vào không hợp lệ. Vui lòng kiểm tra lại ngày tháng.");
            handleGetStep1(request, response);
            return;
        }

        LocalDate today = LocalDate.now();
        if (checkIn.isBefore(today)) {
            request.setAttribute("messageError", "Ngày nhận phòng không thể ở trong quá khứ.");
            handleGetStep1(request, response);
            return;
        }

        long nights = ChronoUnit.DAYS.between(checkIn, checkOut);
        if (nights < MIN_STAY_NIGHTS) {
            request.setAttribute("messageError", "Thời gian lưu trú tối thiểu là " + MIN_STAY_NIGHTS + " đêm.");
            handleGetStep1(request, response);
            return;
        }

        if (nights > MAX_STAY_NIGHTS) {
            request.setAttribute("messageError", "Thời gian lưu trú tối đa cho mỗi đơn đặt phòng là " + MAX_STAY_NIGHTS + " đêm.");
            handleGetStep1(request, response);
            return;
        }

        Optional<Room> roomOpt = roomDAO.findById(roomId);
        if (roomOpt.isEmpty()) {
            request.setAttribute("messageError", "Phòng đã chọn không tồn tại hoặc đã ngừng hoạt động.");
            handleGetStep1(request, response);
            return;
        }

        Room room = roomOpt.get();
        int totalGuests = adults + children;
        if (totalGuests > room.getCapacity()) {
            request.setAttribute("messageError", "Số lượng khách (" + totalGuests + " người) vượt quá sức chứa tối đa của phòng (" + room.getCapacity() + " người). Bạn có thể đặt thêm phòng ở Bước 2.");
            handleGetStep1(request, response);
            return;
        }

        Date sqlCheckIn = Date.valueOf(checkIn);
        Date sqlCheckOut = Date.valueOf(checkOut);

        boolean available = bookingDAO.isRoomAvailable(roomId, sqlCheckIn, sqlCheckOut, null);
        if (!available) {
            request.setAttribute("messageError", "Phòng [" + room.getRoomName() + "] đã có khách đặt trong khoảng thời gian từ " + checkIn + " đến " + checkOut + ". Vui lòng chọn ngày khác hoặc chọn phòng khác.");
            handleGetStep1(request, response);
            return;
        }

        BigDecimal pricePerNight = room.getPricePerNight();
        BigDecimal subtotal = pricePerNight.multiply(BigDecimal.valueOf(nights));

        BookingRoomItem primaryItem = new BookingRoomItem(
                room.getId(),
                room.getRoomName(),
                room.getRoomType() != null ? room.getRoomType().getTypeName() : "Tiêu chuẩn",
                room.getImageUrl(),
                room.getProperty() != null ? room.getProperty().getPropertyName() : "Sogo Homestay",
                sqlCheckIn,
                sqlCheckOut,
                adults,
                children,
                room.getCapacity(),
                (int) nights,
                pricePerNight,
                subtotal
        );

        BookingDraft draft = new BookingDraft();
        draft.addRoom(primaryItem);

        HttpSession session = request.getSession();
        session.setAttribute(SESSION_BOOKING_DRAFT, draft);

        response.sendRedirect(request.getContextPath() + "/booking?step=2");
    }

    // =========================================================================
    // STEP 2 HANDLERS: Multi-Room Management, Voucher, Customer Info & Confirm
    // =========================================================================

    private void handleGetStep2(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        BookingDraft draft = (BookingDraft) session.getAttribute(SESSION_BOOKING_DRAFT);

        if (draft == null || draft.getRooms().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/booking?step=1");
            return;
        }

        BookingRoomItem primary = draft.getPrimaryRoom();
        List<Room> availableRooms = bookingDAO.findAvailableRooms(primary.getCheckInDate(), primary.getCheckOutDate(), null);

        List<Room> otherAvailableRooms = new ArrayList<>();
        for (Room r : availableRooms) {
            boolean alreadyInDraft = draft.getRooms().stream().anyMatch(item -> item.getRoomId() == r.getId());
            if (!alreadyInDraft) {
                otherAvailableRooms.add(r);
            }
        }

        List<Voucher> publicVouchers = voucherDAO.findActivePublicVouchers();

        request.setAttribute("draft", draft);
        request.setAttribute("otherAvailableRooms", otherAvailableRooms);
        request.setAttribute("publicVouchers", publicVouchers);
        request.setAttribute("step", "2");

        request.getRequestDispatcher("/WEB-INF/views/reservation.jsp").forward(request, response);
    }

    private void handlePostAddRoom(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        BookingDraft draft = (BookingDraft) session.getAttribute(SESSION_BOOKING_DRAFT);

        if (draft == null || draft.getPrimaryRoom() == null) {
            response.sendRedirect(request.getContextPath() + "/booking?step=1");
            return;
        }

        String addRoomIdStr = request.getParameter("add_room_id");
        if (addRoomIdStr != null && !addRoomIdStr.trim().isEmpty()) {
            try {
                int addRoomId = Integer.parseInt(addRoomIdStr.trim());
                BookingRoomItem primary = draft.getPrimaryRoom();

                boolean avail = bookingDAO.isRoomAvailable(addRoomId, primary.getCheckInDate(), primary.getCheckOutDate(), null);
                if (avail) {
                    Optional<Room> addRoomOpt = roomDAO.findById(addRoomId);
                    if (addRoomOpt.isPresent()) {
                        Room room = addRoomOpt.get();
                        BigDecimal subtotal = room.getPricePerNight().multiply(BigDecimal.valueOf(primary.getNumberOfNights()));
                        BookingRoomItem newItem = new BookingRoomItem(
                                room.getId(),
                                room.getRoomName(),
                                room.getRoomType() != null ? room.getRoomType().getTypeName() : "Tiêu chuẩn",
                                room.getImageUrl(),
                                room.getProperty() != null ? room.getProperty().getPropertyName() : "Sogo Homestay",
                                primary.getCheckInDate(),
                                primary.getCheckOutDate(),
                                Math.min(2, room.getCapacity()),
                                0,
                                room.getCapacity(),
                                primary.getNumberOfNights(),
                                room.getPricePerNight(),
                                subtotal
                        );
                        draft.addRoom(newItem);
                        session.setAttribute(SESSION_BOOKING_DRAFT, draft);
                    }
                } else {
                    request.setAttribute("messageError", "Phòng đã chọn vừa có khách khác đặt hoặc không còn khả dụng.");
                }
            } catch (NumberFormatException ignored) {}
        }
        response.sendRedirect(request.getContextPath() + "/booking?step=2");
    }

    private void handlePostRemoveRoom(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        BookingDraft draft = (BookingDraft) session.getAttribute(SESSION_BOOKING_DRAFT);

        if (draft != null) {
            String removeRoomIdStr = request.getParameter("remove_room_id");
            if (removeRoomIdStr != null && !removeRoomIdStr.trim().isEmpty()) {
                try {
                    int removeRoomId = Integer.parseInt(removeRoomIdStr.trim());
                    draft.removeRoom(removeRoomId);
                    session.setAttribute(SESSION_BOOKING_DRAFT, draft);
                } catch (NumberFormatException ignored) {}
            }
        }
        response.sendRedirect(request.getContextPath() + "/booking?step=2");
    }

    private void handlePostApplyVoucher(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        BookingDraft draft = (BookingDraft) session.getAttribute(SESSION_BOOKING_DRAFT);

        if (draft == null) {
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

        voucherCode = voucherCode.trim().toUpperCase();
        Optional<Voucher> voucherOpt = voucherDAO.findByCode(voucherCode);

        if (voucherOpt.isEmpty()) {
            request.setAttribute("voucherError", "Mã giảm giá [" + voucherCode + "] không tồn tại hoặc đã hết hạn.");
            handleGetStep2(request, response);
            return;
        }

        Voucher v = voucherOpt.get();
        LocalDate now = LocalDate.now();

        if (v.getStartDate() != null && now.isBefore(v.getStartDate().toLocalDate())) {
            request.setAttribute("voucherError", "Mã giảm giá này chưa đến ngày có hiệu lực.");
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

        if (customerName == null || customerName.trim().isEmpty() ||
            customerEmail == null || customerEmail.trim().isEmpty() ||
            customerPhone == null || customerPhone.trim().isEmpty()) {
            request.setAttribute("messageError", "Vui lòng nhập đầy đủ Họ tên, Email và Số điện thoại liên hệ.");
            handleGetStep2(request, response);
            return;
        }

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
        booking.setStatus("PENDING");

        User loggedUser = (User) session.getAttribute("user");
        if (loggedUser != null) {
            booking.setUserId(loggedUser.getId());
        }

        boolean success = bookingDAO.insertMultiRoomBooking(booking, draft.getRooms());
        if (success) {
            session.removeAttribute(SESSION_BOOKING_DRAFT);
            response.sendRedirect(request.getContextPath() + "/checkout?bookingId=" + booking.getId());
        } else {
            request.setAttribute("messageError", "Có lỗi xảy ra khi lưu đơn đặt phòng vào cơ sở dữ liệu. Vui lòng thử lại!");
            handleGetStep2(request, response);
        }
    }

    // =========================================================================
    // SINGLE-STEP RESERVATION HANDLER (Fallback from reservation.jsp direct form)
    // =========================================================================

    private void handleSingleStepReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String name = request.getParameter("name");
            String phone = request.getParameter("phone");
            String email = request.getParameter("email");
            String checkinDateStr = request.getParameter("checkin_date");
            String checkoutDateStr = request.getParameter("checkout_date");
            String adultsStr = request.getParameter("adults");
            String childrenStr = request.getParameter("children");
            String notes = request.getParameter("notes");
            String roomIdParam = request.getParameter("room_id");

            if (name == null || name.isBlank() || phone == null || phone.isBlank() ||
                email == null || email.isBlank() || checkinDateStr == null || checkinDateStr.isBlank() ||
                checkoutDateStr == null || checkoutDateStr.isBlank() || roomIdParam == null || roomIdParam.isBlank()) {
                preserveFormInputs(request);
                request.setAttribute("messageError", "Vui lòng nhập đầy đủ các trường thông tin bắt buộc.");
                handleGetStep1(request, response);
                return;
            }

            if (!isValidEmail(email.trim())) {
                preserveFormInputs(request);
                request.setAttribute("messageError", "Định dạng email không hợp lệ.");
                handleGetStep1(request, response);
                return;
            }

            int roomId = Integer.parseInt(roomIdParam.trim());
            int adults = Integer.parseInt(adultsStr != null && !adultsStr.isBlank() ? adultsStr.trim() : "1");
            int children = Integer.parseInt(childrenStr != null && !childrenStr.isBlank() ? childrenStr.trim() : "0");

            LocalDate checkin = parseBookingDate(checkinDateStr);
            LocalDate checkout = parseBookingDate(checkoutDateStr);

            if (checkin.isBefore(LocalDate.now())) {
                preserveFormInputs(request);
                request.setAttribute("messageError", "Ngày nhận phòng không thể ở trong quá khứ.");
                handleGetStep1(request, response);
                return;
            }

            long nights = ChronoUnit.DAYS.between(checkin, checkout);
            if (nights <= 0) {
                preserveFormInputs(request);
                request.setAttribute("messageError", "Ngày trả phòng phải sau ngày nhận phòng ít nhất 1 đêm.");
                handleGetStep1(request, response);
                return;
            }

            Optional<Room> roomOpt = roomDAO.findById(roomId);
            if (roomOpt.isEmpty()) {
                preserveFormInputs(request);
                request.setAttribute("messageError", "Phòng đã chọn không tồn tại.");
                handleGetStep1(request, response);
                return;
            }

            Room room = roomOpt.get();
            Date sqlCheckIn = Date.valueOf(checkin);
            Date sqlCheckOut = Date.valueOf(checkout);

            if (!bookingDAO.isRoomAvailable(roomId, sqlCheckIn, sqlCheckOut, null)) {
                preserveFormInputs(request);
                request.setAttribute("messageError", "Phòng đã được đặt trong khoảng thời gian này.");
                handleGetStep1(request, response);
                return;
            }

            BigDecimal pricePerNight = room.getPricePerNight() != null ? room.getPricePerNight() : BigDecimal.valueOf(1000000);
            BigDecimal total = pricePerNight.multiply(BigDecimal.valueOf(nights));

            Booking booking = new Booking();
            booking.setRoomId(roomId);
            booking.setPropertyId(room.getPropertyId() > 0 ? room.getPropertyId() : 1);
            booking.setCustomerName(name.trim());
            booking.setCustomerPhone(phone.trim());
            booking.setEmail(email.trim());
            booking.setCheckInDate(sqlCheckIn);
            booking.setCheckOutDate(sqlCheckOut);
            booking.setAdults(adults);
            booking.setChildren(children);
            booking.setGuestCount(adults + children);
            booking.setNotes(notes != null ? notes.trim() : null);
            booking.setTotalPrice(total);
            booking.setStatus("PENDING");

            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("userId") instanceof Integer uId) {
                booking.setUserId(uId);
            }

            int bookingId = bookingDAO.createBooking(booking);
            if (bookingId > 0) {
                response.sendRedirect(request.getContextPath() + "/checkout?bookingId=" + bookingId);
            } else {
                preserveFormInputs(request);
                request.setAttribute("messageError", "Có lỗi xảy ra khi tạo đơn đặt phòng. Vui lòng thử lại!");
                handleGetStep1(request, response);
            }
        } catch (DateTimeParseException e) {
            preserveFormInputs(request);
            request.setAttribute("messageError", "Định dạng ngày không hợp lệ.");
            handleGetStep1(request, response);
        } catch (Exception e) {
            preserveFormInputs(request);
            request.setAttribute("messageError", "Lỗi: " + e.getMessage());
            handleGetStep1(request, response);
        }
    }

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

    public LocalDate parseBookingDate(String dateString) {
        if (dateString == null || dateString.isBlank()) {
            throw new DateTimeParseException("Ngày không được để trống", dateString == null ? "" : dateString, 0);
        }
        String value = dateString.trim();
        try {
            return LocalDate.parse(value, DATEPICKER_FORMAT);
        } catch (DateTimeParseException ignored) {}
        try {
            return LocalDate.parse(value, DATEPICKER_FORMAT_SHORT);
        } catch (DateTimeParseException ignored) {}
        try {
            return LocalDate.parse(value, DateTimeFormatter.ISO_LOCAL_DATE);
        } catch (DateTimeParseException ignored) {}
        try {
            return LocalDate.parse(value, VIETNAMESE_DATE_FORMAT);
        } catch (DateTimeParseException ignored) {}
        try {
            return LocalDate.parse(value, DASH_DATE_FORMAT);
        } catch (DateTimeParseException ignored) {}

        throw new DateTimeParseException("Định dạng ngày không được hỗ trợ: " + value, value, 0);
    }

    private boolean isValidEmail(String email) {
        return email != null && email.length() <= 254 &&
               email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
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
