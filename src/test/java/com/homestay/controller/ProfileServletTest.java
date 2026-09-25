package com.homestay.controller;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.homestay.dao.UserDAO;
import com.homestay.model.User;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.Optional;
import org.junit.jupiter.api.Test;

class ProfileServletTest {

    @Test
    void profileUpdateUsesSessionUserIdInsteadOfRequestUserId() throws Exception {
        int sessionUserId = 41;
        UserDAO userDAO = mock(UserDAO.class);
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        User currentUser = new User();
        currentUser.setAvatarUrl("avatar.png");

        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(sessionUserId);
        when(request.getParameter("userId")).thenReturn("999");
        when(request.getParameter("fullName")).thenReturn("Updated Name");
        when(request.getParameter("phone")).thenReturn("0901234567");
        when(request.getParameter("avatarUrl")).thenReturn("");
        when(userDAO.findById(sessionUserId))
                .thenReturn(Optional.of(currentUser))
                .thenReturn(Optional.of(currentUser));
        when(userDAO.updateProfile(sessionUserId, "Updated Name", "0901234567", "avatar.png"))
                .thenReturn(true);
        when(request.getRequestDispatcher(anyString())).thenReturn(dispatcher);

        new ProfileServlet(userDAO).doPost(request, response);

        verify(userDAO, times(2)).findById(sessionUserId);
        verify(userDAO, never()).findById(999);
        verify(userDAO).updateProfile(sessionUserId, "Updated Name", "0901234567", "avatar.png");
        verify(request, never()).getParameter("userId");
        verify(dispatcher).forward(request, response);
    }
}