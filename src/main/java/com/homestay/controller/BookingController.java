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

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;

/**
 * BookingController - Handles reservation forms and booking submissions.
 */
@WebServlet(name = "BookingController", urlPatterns = {"/reservation", "/booking"})
public class BookingController extends HttpServlet {

    private RoomDAO roomDAO;
    private BookingDAO bookingDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.roomDAO = new RoomDAO();
        this.bookingDAO = new BookingDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Room> rooms = roomDAO.findAll();
        request.setAttribute("rooms", rooms);
        request.setAttribute("activePage", "reservation");

        String selectedRoomId = request.getParameter("roomId");
        if (selectedRoomId != null) {
            request.setAttribute("selectedRoomId", selectedRoomId);
        }

        request.getRequestDispatcher("/WEB-INF/views/reservation.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String checkinStr = request.getParameter("checkin_date");
        String checkoutStr = request.getParameter("checkout_date");
        String adultsStr = request.getParameter("adults");
        String childrenStr = request.getParameter("children");
        String roomIdStr = request.getParameter("room_id");
        String notes = request.getParameter("notes");

        try {
            int roomId = (roomIdStr != null && !roomIdStr.isEmpty()) ? Integer.parseInt(roomIdStr) : 1;
            int adults = (adultsStr != null && !adultsStr.isEmpty()) ? Integer.parseInt(adultsStr) : 1;
            int children = (childrenStr != null && !childrenStr.isEmpty()) ? Integer.parseInt(childrenStr) : 0;

            LocalDate checkIn = (checkinStr != null && !checkinStr.isEmpty()) 
                    ? LocalDate.parse(checkinStr) 
                    : LocalDate.now();
            LocalDate checkOut = (checkoutStr != null && !checkoutStr.isEmpty()) 
                    ? LocalDate.parse(checkoutStr) 
                    : checkIn.plusDays(1);

            long days = ChronoUnit.DAYS.between(checkIn, checkOut);
            if (days <= 0) {
                days = 1;
            }

            Optional<Room> roomOpt = roomDAO.findById(roomId);
            BigDecimal pricePerNight = roomOpt.map(Room::getPricePerNight).orElse(BigDecimal.valueOf(100.0));
            BigDecimal totalPrice = pricePerNight.multiply(BigDecimal.valueOf(days));

            Booking booking = new Booking();
            booking.setCustomerName(name != null ? name : "Guest Customer");
            booking.setEmail(email != null ? email : "guest@example.com");
            booking.setCustomerPhone(phone != null ? phone : "");
            booking.setRoomId(roomId);
            booking.setCheckInDate(Date.valueOf(checkIn));
            booking.setCheckOutDate(Date.valueOf(checkOut));
            booking.setAdults(adults);
            booking.setChildren(children);
            booking.setTotalPrice(totalPrice);
            booking.setNotes(notes);
            booking.setStatus("PENDING");

            boolean success = bookingDAO.insert(booking);
            if (success) {
                request.setAttribute("messageSuccess", "Đặt phòng thành công! Chúng tôi sẽ liên hệ với bạn sớm nhất.");
            } else {
                request.setAttribute("messageError", "Có lỗi xảy ra khi lưu đơn đặt phòng. Vui lòng thử lại!");
            }
        } catch (Exception e) {
            request.setAttribute("messageError", "Dữ liệu nhập vào không hợp lệ: " + e.getMessage());
        }

        doGet(request, response);
    }
}
