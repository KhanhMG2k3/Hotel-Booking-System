package com.homestay.controller;

import com.homestay.dao.UserDAO;
import com.homestay.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.util.Optional;

@WebServlet(name = "ProfileServlet", urlPatterns = { "/profile" })
@jakarta.servlet.annotation.MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 25    // 25MB
)
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO;

    public ProfileServlet() {
        this(new UserDAO());
    }

    ProfileServlet(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("userId") instanceof Integer)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        Optional<User> userOpt = userDAO.findById(userId);

        if (userOpt.isEmpty()) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String tab = request.getParameter("tab");
        request.setAttribute("activeTab", (tab != null && !tab.trim().isEmpty()) ? tab.trim() : "profile");
        request.setAttribute("profileUser", userOpt.get());
        request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("userId") instanceof Integer)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String action = request.getParameter("action");
        if (action == null) {
            action = "updateProfile";
        }

        Optional<User> userOpt = userDAO.findById(userId);
        if (userOpt.isEmpty()) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User current = userOpt.get();

        if ("changePassword".equals(action)) {
            request.setAttribute("activeTab", "password");
            handleChangePassword(request, response, session, current);
            return;
        }

        request.setAttribute("activeTab", "profile");

        // ---- update profile ----
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String gender = request.getParameter("gender");
        String address = request.getParameter("address");
        String dateOfBirthStr = request.getParameter("dateOfBirth");

        fullName = fullName == null ? "" : fullName.trim();
        phone = phone == null ? "" : phone.trim();
        gender = (gender != null && !gender.trim().isEmpty()) ? gender.trim() : null;
        address = (address != null && !address.trim().isEmpty()) ? address.trim() : null;

        java.sql.Date dateOfBirth = null;
        if (dateOfBirthStr != null && !dateOfBirthStr.trim().isEmpty()) {
            try {
                dateOfBirth = java.sql.Date.valueOf(dateOfBirthStr.trim());
            } catch (IllegalArgumentException ignored) {}
        }

        if (fullName.isEmpty()) {
            request.setAttribute("error", "Họ tên không được để trống.");
            request.setAttribute("profileUser", current);
            request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
            return;
        }

        if (!phone.isEmpty() && !phone.matches("^[0-9+() .-]{8,20}$")) {
            request.setAttribute("error", "Số điện thoại không hợp lệ.");
            request.setAttribute("profileUser", current);
            request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
            return;
        }

        // Xử lý upload avatar từ thiết bị
        String avatarToSave = current.getAvatarUrl();
        try {
            jakarta.servlet.http.Part filePart = request.getPart("avatarFile");
            if (filePart != null && filePart.getSize() > 0 && filePart.getSubmittedFileName() != null) {
                String submittedName = filePart.getSubmittedFileName().trim();
                if (!submittedName.isEmpty()) {
                    String ext = "";
                    int dot = submittedName.lastIndexOf('.');
                    if (dot >= 0) {
                        ext = submittedName.substring(dot).toLowerCase();
                    }
                    if (ext.equals(".jpg") || ext.equals(".jpeg") || ext.equals(".png") || ext.equals(".webp") || ext.equals(".gif")) {
                        String uploadDir = request.getServletContext().getRealPath("/assets/uploads/avatars");
                        java.io.File dir = new java.io.File(uploadDir);
                        if (!dir.exists()) {
                            dir.mkdirs();
                        }
                        String fileName = "avatar_" + userId + "_" + System.currentTimeMillis() + ext;
                        java.io.File target = new java.io.File(dir, fileName);
                        filePart.write(target.getAbsolutePath());
                        avatarToSave = "uploads/avatars/" + fileName;
                    }
                }
            }
        } catch (Exception ignored) {}

        boolean ok;
        if (dateOfBirth != null || gender != null || address != null) {
            ok = userDAO.updateProfile(userId, fullName, phone, avatarToSave, dateOfBirth, gender, address);
        } else {
            ok = userDAO.updateProfile(userId, fullName, phone, avatarToSave);
        }
        if (!ok) {
            request.setAttribute("error", "Không thể cập nhật hồ sơ. Vui lòng thử lại.");
            request.setAttribute("profileUser", current);
            request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
            return;
        }

        // Cập nhật lại session
        Optional<User> refreshed = userDAO.findById(userId);
        if (refreshed.isPresent()) {
            User u = refreshed.get();
            session.setAttribute("user", u);
            session.setAttribute("userName", u.getFullName());
            session.setAttribute("avatar", u.getAvatarUrl());
            session.setAttribute("userEmail", u.getEmail());
            session.setAttribute("roleId", u.getRoleId());
            request.setAttribute("profileUser", u);
        } else {
            request.setAttribute("profileUser", current);
        }

        request.setAttribute("success", "Cập nhật hồ sơ thành công.");
        request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
    }

    private void handleChangePassword(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession session,
            User current) throws ServletException, IOException {

        // Google user không có password local
        if (current.getPassword() == null || current.getPassword().isBlank()) {
            request.setAttribute("error", "Tài khoản đăng nhập bằng Google không thể đổi mật khẩu tại đây.");
            request.setAttribute("profileUser", current);
            request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
            return;
        }

        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (oldPassword == null || newPassword == null || confirmPassword == null) {
            request.setAttribute("error", "Vui lòng điền đầy đủ thông tin mật khẩu.");
            request.setAttribute("profileUser", current);
            request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
            return;
        }

        if (!BCrypt.checkpw(oldPassword, current.getPassword())) {
            request.setAttribute("error", "Mật khẩu hiện tại không đúng.");
            request.setAttribute("profileUser", current);
            request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
            return;
        }

        if (newPassword.length() < 8) {
            request.setAttribute("error", "Mật khẩu mới tối thiểu 8 ký tự.");
            request.setAttribute("profileUser", current);
            request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.setAttribute("profileUser", current);
            request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
            return;
        }

        String hashed = BCrypt.hashpw(newPassword, BCrypt.gensalt());
        boolean ok = userDAO.updatePassword(current.getId(), hashed);

        if (!ok) {
            request.setAttribute("error", "Không thể đổi mật khẩu. Vui lòng thử lại.");
        } else {
            request.setAttribute("success", "Đổi mật khẩu thành công.");
            // refresh user trong session
            userDAO.findById(current.getId()).ifPresent(u -> session.setAttribute("user", u));
        }

        request.setAttribute("profileUser", userDAO.findById(current.getId()).orElse(current));
        request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
    }
}