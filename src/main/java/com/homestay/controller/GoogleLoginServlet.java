package com.homestay.controller;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.homestay.dao.UserDAO;
import com.homestay.model.User;
import com.homestay.context.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Collections;
import java.util.Optional;

@WebServlet(name = "GoogleLoginServlet", urlPatterns = {"/google-login"})
public class GoogleLoginServlet extends HttpServlet {

    // Dán đúng Client ID vừa tạo ở Google Cloud Console (PHẢI trùng với Client ID trong Login.jsp)
    private static final String CLIENT_ID
            = com.homestay.context.DBContext.getAppProperty("google.client.id", "");
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idTokenString = request.getParameter("credential");

        GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                new NetHttpTransport(), GsonFactory.getDefaultInstance())
                .setAudience(Collections.singletonList(CLIENT_ID))
                .build();

        try {
            GoogleIdToken idToken = verifier.verify(idTokenString);

            if (idToken == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("text/plain;charset=UTF-8");
                response.getWriter().write("Xác thực Google thất bại, token không hợp lệ.");
                return;
            }

            GoogleIdToken.Payload payload = idToken.getPayload();
            String googleId = payload.getSubject();
            String email = payload.getEmail();
            String name = (String) payload.get("name");
            String picture = (String) payload.get("picture");

            User user = userDAO.findByGoogleId(googleId).orElse(null);

            if (user == null) {
                Optional<User> byEmail = userDAO.findByEmail(email);
                if (byEmail.isPresent()) {
                    // Email đã có tài khoản đăng ký thường trước đó -> liên kết thêm Google
                    user = byEmail.get();
                    userDAO.linkGoogleAccount(user.getId(), googleId, picture);
                } else {
                    // Chưa từng có tài khoản -> tạo mới
                    int newId = userDAO.createGoogleUser(email, name, googleId, picture);
                    user = userDAO.findById(newId).orElse(null);
                }
            }

            if (user == null) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.setContentType("text/plain;charset=UTF-8");
                response.getWriter().write("Không thể tạo hoặc tìm tài khoản trên hệ thống.");
                return;
            }

            HttpSession session = request.getSession();
            session.setAttribute("userId", user.getId());
            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("userName", user.getFullName());
            session.setAttribute("roleId", user.getRoleId());
            session.setAttribute("avatar", user.getAvatarUrl());
            session.setAttribute("user", user);

            response.setContentType("text/plain");
            response.getWriter().write("OK");

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/plain");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("ERROR");
        }
    }
}
