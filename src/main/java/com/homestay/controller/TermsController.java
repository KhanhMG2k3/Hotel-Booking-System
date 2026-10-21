package com.homestay.controller;

import com.homestay.dao.TermDAO;
import com.homestay.model.TermSection;
import com.homestay.model.TermSetting;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;

/**
 *
 * @author admin
 */
public class TermsController extends HttpServlet {

    private final TermDAO termDAO = new TermDAO();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        TermSetting setting = termDAO.getSetting();
        List<TermSection> sections = termDAO.getAllSections();
        request.setAttribute("setting", setting);
        request.setAttribute("sections", sections);
        request.getRequestDispatcher("/WEB-INF/views/term.jsp").forward(request, response);
    }

}
