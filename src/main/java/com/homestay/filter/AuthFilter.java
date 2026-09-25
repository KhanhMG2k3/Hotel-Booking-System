package com.homestay.filter;

import com.homestay.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * AuthFilter - Bắt buộc user phải đăng nhập mới được truy cập các URL được bảo vệ.
 * Đặt trước RoleFilter và HostFilter.
 */
@WebFilter(urlPatterns = {
        "/become-host",
        "/become-host/*",
        "/profile",
        "/profile/*",
        "/booking",
        "/booking/*"
        // Sau này muốn bảo vệ thêm URL nào thì chỉ cần thêm vào đây
})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false);

        User user = null;
        if (session != null) {
            Object userAttribute = session.getAttribute("user");
            if (userAttribute instanceof User) {
                user = (User) userAttribute;
            }
        }

        if (user == null) {
            // Chưa đăng nhập → chuyển về trang login
            // Có thể thêm ?redirect=... nếu muốn quay lại trang cũ sau khi login
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        // Đã đăng nhập → cho đi tiếp
        chain.doFilter(request, response);
    }
}