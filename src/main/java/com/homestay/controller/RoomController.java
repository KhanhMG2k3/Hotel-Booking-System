package com.homestay.controller;

import com.homestay.dao.RoomDAO;
import com.homestay.model.Room;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Date;
import java.util.List;
import java.util.Optional;

/**
 * RoomController - Handles listing and viewing rich details of homestay rooms.
 */
@WebServlet(name = "RoomController", urlPatterns = {"/rooms", "/room-detail"})
public class RoomController extends HttpServlet {

    private RoomDAO roomDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.roomDAO = new RoomDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();

        if ("/room-detail".equals(servletPath)) {
            handleRoomDetail(request, response);
        } else {
            handleRoomList(request, response);
        }
    }

    private void handleRoomList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String location = request.getParameter("location");
        String checkIn = request.getParameter("checkIn");
        String checkOut = request.getParameter("checkOut");
        String guestsParam = request.getParameter("guests");

        boolean isSearch = (location != null && !location.trim().isEmpty())
                || (checkIn != null && !checkIn.trim().isEmpty())
                || (checkOut != null && !checkOut.trim().isEmpty())
                || (guestsParam != null && !guestsParam.trim().isEmpty());

        List<Room> rooms;

        if (isSearch) {
            String searchError = null;
            Integer guests = null;
            Date checkInDate = null;
            Date checkOutDate = null;

            if (guestsParam != null && !guestsParam.trim().isEmpty()) {
                try {
                    guests = Integer.parseInt(guestsParam.trim());

                    if (guests < 1) {
                        searchError = "Số khách phải lớn hơn hoặc bằng 1.";
                    }
                } catch (NumberFormatException e) {
                    searchError = "Số khách không hợp lệ.";
                }
            }

            boolean hasCheckIn = checkIn != null && !checkIn.trim().isEmpty();
            boolean hasCheckOut = checkOut != null && !checkOut.trim().isEmpty();

            if (searchError == null && hasCheckIn != hasCheckOut) {
                searchError = "Vui lòng nhập cả ngày nhận phòng và ngày trả phòng.";
            }

            if (searchError == null && hasCheckIn && hasCheckOut) {
                try {
                    checkInDate = Date.valueOf(checkIn);
                    checkOutDate = Date.valueOf(checkOut);

                    if (!checkOutDate.after(checkInDate)) {
                        searchError = "Ngày trả phòng phải sau ngày nhận phòng.";
                    }
                } catch (IllegalArgumentException e) {
                    searchError = "Ngày nhận/trả phòng không hợp lệ.";
                }
            }

            if (searchError == null) {
                rooms = roomDAO.searchRooms(
                        location,
                        checkInDate,
                        checkOutDate,
                        guests
                );
            } else {
                rooms = roomDAO.findAll();
                request.setAttribute("searchError", searchError);
            }

            request.setAttribute("searchLocation", location);
            request.setAttribute("searchCheckIn", checkIn);
            request.setAttribute("searchCheckOut", checkOut);
            request.setAttribute("searchGuests", guestsParam);
        } else {
            rooms = roomDAO.findAll();
        }

        request.setAttribute("rooms", rooms);
        request.setAttribute("activePage", "rooms");

        request.getRequestDispatcher("/WEB-INF/views/rooms.jsp").forward(request, response);
    }

    private void handleRoomDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");

        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int id = Integer.parseInt(idParam.trim());
                Optional<Room> roomOpt = roomDAO.findById(id);

                if (roomOpt.isPresent()) {
                    request.setAttribute("room", roomOpt.get());
                    request.setAttribute("activePage", "rooms");
                    request.getRequestDispatcher("/WEB-INF/views/room-detail.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException ignored) {
            }
        }

        response.sendRedirect(request.getContextPath() + "/rooms");
    }
}
