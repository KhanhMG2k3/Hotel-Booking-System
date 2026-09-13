package com.homestay.controller;

import com.homestay.dao.RoomDAO;
import com.homestay.model.Room;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
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
        List<Room> rooms = roomDAO.findAll();
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
