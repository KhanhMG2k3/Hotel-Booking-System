package com.homestay.controller;

import com.homestay.dao.HostApplicationDAO;
import com.homestay.dao.PropertyDAO;
import com.homestay.dao.RoomDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.HostAccount;
import com.homestay.model.HostApplication;
import com.homestay.model.Property;
import com.homestay.model.Room;
import com.homestay.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

/**
 * Controller for dedicated Admin Host Details & Rooms view.
 */
@WebServlet(name = "AdminHostDetailController", urlPatterns = {"/admin/host-detail"})
public class AdminHostDetailController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserDAO userDAO = new UserDAO();
    private final PropertyDAO propertyDAO = new PropertyDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final HostApplicationDAO hostApplicationDAO = new HostApplicationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer roleId = (session != null) ? (Integer) session.getAttribute("roleId") : null;
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        String roleName = (user != null && user.getRole() != null) ? user.getRole().getRoleName() : "";

        boolean isAdmin = (roleId != null && (roleId == 1 || roleId == 5))
                || "ROLE_ADMIN".equalsIgnoreCase(roleName)
                || "ADMIN".equalsIgnoreCase(roleName);

        if (!isAdmin) {
            response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            idParam = request.getParameter("hostId");
        }

        if (idParam == null || idParam.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=tab-properties");
            return;
        }

        int hostId;
        try {
            hostId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=tab-properties");
            return;
        }

        Optional<HostAccount> hostOpt = userDAO.findHostAccountById(hostId);
        if (hostOpt.isEmpty()) {
            if (session != null) {
                session.setAttribute("messageError", "Không tìm thấy thông tin của tài khoản Host #" + hostId);
            }
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=tab-properties");
            return;
        }

        HostAccount hostAccount = hostOpt.get();
        User hostUser = userDAO.findById(hostId).orElse(null);
        List<Property> properties = propertyDAO.findByHostId(hostId);
        List<Room> rooms = roomDAO.findRoomsByHostId(hostId);

        hostAccount.setProperties(properties);
        hostAccount.setRooms(rooms);
        hostAccount.setPropertyCount(properties.size());
        hostAccount.setRoomCount(rooms.size());

        HostApplication hostApp = null;
        try {
            hostApp = hostApplicationDAO.findLatestByUserId(hostId);
        } catch (Exception ignored) {
        }

        // Flash message consumption
        if (session != null) {
            if (session.getAttribute("messageSuccess") != null) {
                request.setAttribute("messageSuccess", session.getAttribute("messageSuccess"));
                session.removeAttribute("messageSuccess");
            }
            if (session.getAttribute("messageError") != null) {
                request.setAttribute("messageError", session.getAttribute("messageError"));
                session.removeAttribute("messageError");
            }
        }

        long availableRooms = rooms.stream().filter(r -> "AVAILABLE".equalsIgnoreCase(r.getStatus()) || "active".equalsIgnoreCase(r.getStatus())).count();
        long bookedRooms = rooms.stream().filter(r -> "BOOKED".equalsIgnoreCase(r.getStatus())).count();
        long maintenanceRooms = rooms.stream().filter(r -> "MAINTENANCE".equalsIgnoreCase(r.getStatus())).count();

        request.setAttribute("hostAccount", hostAccount);
        request.setAttribute("hostUser", hostUser);
        request.setAttribute("hostApp", hostApp);
        request.setAttribute("properties", properties);
        request.setAttribute("rooms", rooms);
        request.setAttribute("availableRoomsCount", availableRooms);
        request.setAttribute("bookedRoomsCount", bookedRooms);
        request.setAttribute("maintenanceRoomsCount", maintenanceRooms);

        request.getRequestDispatcher("/WEB-INF/views/admin/host-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer roleId = (session != null) ? (Integer) session.getAttribute("roleId") : null;
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        String roleName = (user != null && user.getRole() != null) ? user.getRole().getRoleName() : "";

        boolean isAdmin = (roleId != null && (roleId == 1 || roleId == 5))
                || "ROLE_ADMIN".equalsIgnoreCase(roleName)
                || "ADMIN".equalsIgnoreCase(roleName);

        if (!isAdmin) {
            response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        String hostIdParam = request.getParameter("hostId");
        if (hostIdParam != null && !hostIdParam.isBlank()) {
            try {
                int hostId = Integer.parseInt(hostIdParam.trim());
                String targetStatus = "banHost".equals(action) ? "BANNED"
                        : ("unbanHost".equals(action) ? "ACTIVE" : request.getParameter("status"));
                if (!"BANNED".equals(targetStatus) && !"ACTIVE".equals(targetStatus)) {
                    targetStatus = "ACTIVE";
                }

                boolean updated = userDAO.updateUserStatus(hostId, targetStatus);
                if (updated) {
                    String statusLabel = "BANNED".equals(targetStatus) ? "Khóa (Ban)" : "Mở khóa (Active)";
                    if (session != null) {
                        session.setAttribute("messageSuccess", "Đã cập nhật trạng thái tài khoản Host #" + hostId + " thành: " + statusLabel + " thành công!");
                    }
                } else {
                    if (session != null) {
                        session.setAttribute("messageError", "Không thể cập nhật trạng thái Host #" + hostId + ". Vui lòng thử lại.");
                    }
                }
                response.sendRedirect(request.getContextPath() + "/admin/host-detail?id=" + hostId);
                return;
            } catch (NumberFormatException e) {
                if (session != null) {
                    session.setAttribute("messageError", "Mã Host không hợp lệ.");
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=tab-properties");
    }

    @Override
    public String getServletInfo() {
        return "Admin Host Detail Controller";
    }
}

