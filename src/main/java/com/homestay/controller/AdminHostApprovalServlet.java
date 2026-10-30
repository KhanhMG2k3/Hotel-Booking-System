package com.homestay.controller;

import com.homestay.dao.HostApplicationDAO;
import com.homestay.dao.HostProfileDAO;
import com.homestay.model.HostApplication;
import com.homestay.model.HostProfile;
import com.homestay.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Optional;

@WebServlet(name = "AdminHostApprovalServlet", urlPatterns = {"/admin/host/approve", "/admin/host/reject"})
public class AdminHostApprovalServlet extends HttpServlet {

    private static final int ROLE_HOST_ID = 3;
    private final HostProfileDAO hostProfileDAO = new HostProfileDAO();
    private final HostApplicationDAO hostApplicationDAO = new HostApplicationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User sessionUser = (User) session.getAttribute("user");
        Integer sessionUserId = (Integer) session.getAttribute("userId");
        int adminUserId = (sessionUser != null && sessionUser.getId() > 0)
                ? sessionUser.getId()
                : (sessionUserId != null ? sessionUserId : 1);

        String uri = request.getRequestURI();
        boolean isReject = uri != null && uri.endsWith("/reject");

        // 1. Handle HostApplication submission review
        String applicationIdParameter = request.getParameter("applicationId");
        if (applicationIdParameter != null && !applicationIdParameter.isBlank()) {
            try {
                int applicationId = Integer.parseInt(applicationIdParameter.trim());
                if (isReject) {
                    String reason = request.getParameter("rejectionReason");
                    if (reason == null || reason.trim().length() < 10) {
                        reason = "Hồ sơ chưa đạt tiêu chuẩn xác thực thông tin đối tác của Sogo Homestay.";
                    }
                    boolean reviewed = hostApplicationDAO.review(applicationId, adminUserId,
                            HostApplication.Status.REJECTED, reason.trim());
                    if (reviewed) {
                        session.setAttribute("messageSuccess", "Đã từ chối đơn đăng ký Host #" + applicationId + ".");
                    } else {
                        session.setAttribute("messageError", "Không thể từ chối đơn #" + applicationId + ". Vui lòng kiểm tra lại trạng thái đơn.");
                    }
                } else {
                    boolean reviewed = hostApplicationDAO.review(applicationId, adminUserId,
                            HostApplication.Status.APPROVED, null);
                    if (reviewed) {
                        session.setAttribute("messageSuccess", "Phê duyệt đơn đăng ký Host #" + applicationId + " thành công! Tài khoản đã được nâng cấp lên Host và chỗ nghỉ đã được tạo.");
                    } else {
                        session.setAttribute("messageError", "Không thể phê duyệt đơn #" + applicationId + ". Đơn có thể không ở trạng thái chờ duyệt hoặc thiếu thông tin hợp lệ.");
                    }
                }
            } catch (NumberFormatException e) {
                session.setAttribute("messageError", "Mã đơn đăng ký không hợp lệ.");
            } catch (SQLException e) {
                session.setAttribute("messageError", "Lỗi cơ sở dữ liệu khi duyệt đơn: " + e.getMessage());
            }

            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }

        // 2. Legacy HostProfile support
        String profileIdParameter = request.getParameter("profileId");
        if (profileIdParameter != null && !profileIdParameter.isBlank()) {
            try {
                int profileId = Integer.parseInt(profileIdParameter.trim());
                Optional<HostProfile> profileOptional = hostProfileDAO.findById(profileId);
                if (profileOptional.isPresent()) {
                    HostProfile profile = profileOptional.get();
                    if ("PENDING".equals(profile.getVerificationStatus())) {
                        boolean approved = hostProfileDAO.approveAndAssignHostRole(
                                profile.getId(),
                                profile.getUserId(),
                                ROLE_HOST_ID
                        );
                        if (approved) {
                            session.setAttribute("messageSuccess", "Phê duyệt hồ sơ Host #" + profile.getId() + " thành công!");
                        } else {
                            session.setAttribute("messageError", "Không thể phê duyệt hồ sơ Host #" + profile.getId() + ".");
                        }
                    }
                }
            } catch (Exception e) {
                session.setAttribute("messageError", "Lỗi khi xử lý hồ sơ: " + e.getMessage());
            }

            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
    }

    @Override
    public String getServletInfo() {
        return "Admin Host Approval & Rejection Servlet";
    }
}
