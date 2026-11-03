package com.homestay.controller;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
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

class ProfileControllerTest {

    @Test
    void profileUpdateUsesSessionUserIdInsteadOfRequestUserId() throws Exception {
        int sessionUserId = 41;
        UserDAO userDAO = mock(UserDAO.class);
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        User currentUser = new User();
        currentUser.setId(sessionUserId);
        currentUser.setUsername("testuser");
        currentUser.setFullName("Test User");
        currentUser.setStatus("ACTIVE");
        currentUser.setAvatarUrl("avatar.png");

        when(request.getSession(false)).thenReturn(session);
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(sessionUserId);
        when(request.getParameter("action")).thenReturn("updateProfile");
        when(request.getParameter("userId")).thenReturn("999");
        when(request.getParameter("fullName")).thenReturn("Updated Name");
        when(request.getParameter("phone")).thenReturn("0901234567");
        when(request.getParameter("gender")).thenReturn("");
        when(request.getParameter("address")).thenReturn("");
        when(request.getParameter("dateOfBirth")).thenReturn("");
        when(userDAO.findById(sessionUserId)).thenReturn(Optional.of(currentUser));
        when(userDAO.updateProfile(eq(sessionUserId), eq("Updated Name"), eq("0901234567"), eq("avatar.png"), any(), any(), any()))
                .thenReturn(true);
        when(request.getRequestDispatcher(anyString())).thenReturn(dispatcher);

        new ProfileController(userDAO).doPost(request, response);

        verify(userDAO, times(3)).findById(sessionUserId);
        verify(userDAO, never()).findById(999);
        verify(request, never()).getParameter("userId");
    }
}
