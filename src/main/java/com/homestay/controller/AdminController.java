package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.HostApplicationDAO;
import com.homestay.dao.HostProfileDAO;
import com.homestay.dao.PropertyDAO;
import com.homestay.dao.RoomDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.Booking;
import com.homestay.model.HostAccount;
import com.homestay.model.HostApplication;
import com.homestay.model.HostProfile;
import com.homestay.model.Property;
import com.homestay.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

@WebServlet(name = "AdminController", urlPatterns = {"/admin/dashboard"})
public class AdminController extends HttpServlet {

    private final HostApplicationDAO hostApplicationDAO = new HostApplicationDAO();
    private final HostProfileDAO hostProfileDAO = new HostProfileDAO();
    private final UserDAO userDAO = new UserDAO();
    private final PropertyDAO propertyDAO = new PropertyDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final RoomDAO roomDAO = new RoomDAO();

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

        // Consume flash messages if present
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

        List<HostApplication> pendingHostApplications;
        try {
            pendingHostApplications = hostApplicationDAO.findPendingApplications();
        } catch (SQLException e) {
            pendingHostApplications = Collections.emptyList();
            e.printStackTrace();
        }

        List<HostProfile> pendingHostProfiles = hostProfileDAO.findPendingProfiles();
        List<User> allUsers = userDAO.findAll();
        List<Property> allProperties = propertyDAO.findAll();
        List<Booking> allBookings = bookingDAO.findAll();
        List<HostAccount> allHostAccounts = userDAO.findAllHostAccounts();
        for (HostAccount host : allHostAccounts) {
            host.setRooms(roomDAO.findRoomsByHostId(host.getUserId()));
        }

        request.setAttribute("pendingHostApplications", pendingHostApplications);
        request.setAttribute("pendingHostProfiles", pendingHostProfiles);
        request.setAttribute("allUsers", allUsers);
        request.setAttribute("allProperties", allProperties);
        request.setAttribute("allBookings", allBookings);
        request.setAttribute("allHostAccounts", allHostAccounts);

        int totalPending = pendingHostApplications.size() + pendingHostProfiles.size();
        request.setAttribute("totalPendingHosts", totalPending);
        request.setAttribute("totalUsers", allUsers.size());
        request.setAttribute("totalProperties", allProperties.size());
        request.setAttribute("totalHosts", allHostAccounts.size());
        request.setAttribute("totalBookings", allBookings.size());

        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
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
        if ("toggleHostStatus".equals(action) || "banHost".equals(action) || "unbanHost".equals(action)) {
            String hostIdParam = request.getParameter("hostId");
            String statusParam = request.getParameter("status"); // "BANNED" or "ACTIVE"
            if (hostIdParam != null && !hostIdParam.isBlank()) {
                try {
                    int hostId = Integer.parseInt(hostIdParam.trim());
                    String targetStatus = "banHost".equals(action) ? "BANNED"
                            : ("unbanHost".equals(action) ? "ACTIVE" : statusParam);
                    if (!"BANNED".equals(targetStatus) && !"ACTIVE".equals(targetStatus)) {
                        targetStatus = "ACTIVE";
                    }

                    boolean updated = userDAO.updateUserStatus(hostId, targetStatus);
                    if (updated) {
                        String statusLabel = "BANNED".equals(targetStatus) ? "Khóa (Ban)" : "Mở khóa (Active)";
                        session.setAttribute("messageSuccess", "Đã cập nhật trạng thái tài khoản Host #" + hostId + " thành: " + statusLabel + " thành công!");
                    } else {
                        session.setAttribute("messageError", "Không thể cập nhật trạng thái Host #" + hostId + ". Vui lòng thử lại.");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("messageError", "Mã Host không hợp lệ.");
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=tab-properties");
            return;
        }

        if ("updateRole".equals(action) || "upgradeHostToAdmin".equals(action)) {
            String userIdParam = request.getParameter("userId");
            String newRoleIdParam = request.getParameter("newRoleId");
            if (userIdParam != null && !userIdParam.isBlank()) {
                try {
                    int targetUserId = Integer.parseInt(userIdParam.trim());
                    int newRoleId = (newRoleIdParam != null && !newRoleIdParam.isBlank())
                            ? Integer.parseInt(newRoleIdParam.trim()) : 1; // Default to 1 (ROLE_ADMIN)

                    Optional<User> targetUserOpt = userDAO.findById(targetUserId);
                    if (targetUserOpt.isEmpty()) {
                        session.setAttribute("messageError", "Không tìm thấy người dùng #" + targetUserId);
                    } else {
                        User targetUser = targetUserOpt.get();
                        int currentRoleId = targetUser.getRoleId();
                        String currentRoleName = targetUser.getRole() != null ? targetUser.getRole().getName() : "";
                        boolean isHost = currentRoleId == 3 || "ROLE_HOST".equalsIgnoreCase(currentRoleName);
                        boolean isTargetAdmin = currentRoleId == 1 || currentRoleId == 5
                                || "ROLE_ADMIN".equalsIgnoreCase(currentRoleName)
                                || "ADMIN".equalsIgnoreCase(currentRoleName);

                        // Enforce business rule: Only HOST can be upgraded to ADMIN. CUSTOMER cannot be upgraded directly here.
                        if (!isHost && !isTargetAdmin) {
                            session.setAttribute("messageError", "Chỉ có thể nâng hạng người đang là Host lên Admin. Khách hàng (Customer) muốn trở thành Host phải nộp hồ sơ đăng ký theo quy trình chuẩn.");
                        } else if (newRoleId != 1 && newRoleId != 3) {
                            session.setAttribute("messageError", "Vai trò không hợp lệ. Chỉ hỗ trợ chuyển đổi giữa Host và Admin.");
                        } else {
                            Integer currentSessionUserId = (session.getAttribute("userId") instanceof Number)
                                    ? ((Number) session.getAttribute("userId")).intValue() : null;
                            if (currentSessionUserId != null && currentSessionUserId == targetUserId && newRoleId != 1) {
                                session.setAttribute("messageError", "Bạn không thể tự hạ quyền Admin của chính tài khoản đang đăng nhập!");
                            } else {
                                boolean updated = userDAO.updateUserRole(targetUserId, newRoleId);
                                if (updated) {
                                    String roleLabel = (newRoleId == 1) ? "ADMIN (Quản trị viên)" : "HOST (Chủ nhà)";
                                    session.setAttribute("messageSuccess", "Đã cập nhật vai trò cho thành viên [" + targetUser.getFullName() + "] thành " + roleLabel + " thành công!");
                                } else {
                                    session.setAttribute("messageError", "Không thể cập nhật vai trò người dùng #" + targetUserId + ". Vui lòng thử lại.");
                                }
                            }
                        }
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("messageError", "Mã người dùng hoặc vai trò không hợp lệ.");
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=tab-users");
            return;
        }

        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Admin Dashboard Controller";
    }
}
