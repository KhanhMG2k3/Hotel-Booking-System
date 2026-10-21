/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.homestay.controller;

import com.homestay.dao.TermDAO;
import com.homestay.model.TermSection;
import com.homestay.model.TermSetting;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "AdminTermsController", urlPatterns = {"/admin/terms"})
public class AdminTermsController extends HttpServlet {

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
        request.getRequestDispatcher("/WEB-INF/views/admin/admin-terms.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String mainTitle = request.getParameter("mainTitle");
        String lastUpdated = new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date());

        String[] sectionTitles = request.getParameterValues("sectionTitle");
        String[] sectionBlocksJsons = request.getParameterValues("sectionBlocksJson");

        if (mainTitle == null || mainTitle.trim().isEmpty()) {
            request.setAttribute("error", "Tiêu đề chính không được để trống!");
            doGet(request, response);
            return;
        }

        List<TermSection> sectionList = new ArrayList<>();
        if (sectionTitles != null) {
            for (int i = 0; i < sectionTitles.length; i++) {
                String title = sectionTitles[i] != null ? sectionTitles[i].trim() : "";
                String blocksJson = (sectionBlocksJsons != null && i < sectionBlocksJsons.length) ? sectionBlocksJsons[i] : "[]";

                if (title.isEmpty()) {
                    request.setAttribute("error", "Mục thứ " + (i + 1) + " chưa nhập Tiêu đề!");
                    doGet(request, response);
                    return;
                }

                TermSection sec = new TermSection();
                sec.setSectionOrder(i + 1);
                sec.setSidebarTitle(title);
                sec.setContentTitle(title);
                sec.setContentType("multi-block");
                // Lưu toàn bộ danh sách các khối theo thứ tự vào contentText
                sec.setContentText(blocksJson);
                sec.setTableJson(null);
                sec.setCalloutText(null);
                sec.setCalloutType(null);

                sectionList.add(sec);
            }
        }

        TermSetting setting = new TermSetting(mainTitle, lastUpdated);
        boolean success = termDAO.saveAllTerms(setting, sectionList);
        if (success) {
            request.getSession().setAttribute("msg", "Đã lưu và cập nhật điều khoản thành công lúc " + lastUpdated + "!");
            response.sendRedirect(request.getContextPath() + "/admin/terms");
        } else {
            request.setAttribute("error", "Lưu thất bại! Đã xảy ra lỗi cơ sở dữ liệu.");
            doGet(request, response);
        }
    }
}
