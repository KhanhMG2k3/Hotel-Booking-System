package com.homestay.controller;

import com.homestay.dao.HostProfileDAO;
import com.homestay.dao.PropertyDAO;
import com.homestay.dao.WalletDAO;
import com.homestay.model.HostProfile;
import com.homestay.model.Property;
import com.homestay.model.WalletTransaction;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * HostDashboardServlet - Dashboard overview for Host, including properties and wallet balance.
 */
@WebServlet(name = "HostDashboardServlet", urlPatterns = {"/host/dashboard"})
public class HostDashboardServlet extends HttpServlet {

    private final HostProfileDAO hostProfileDAO = new HostProfileDAO();
    private final PropertyDAO propertyDAO = new PropertyDAO();
    private final WalletDAO walletDAO = new WalletDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Object userIdAttribute = session.getAttribute("userId");
        if (!(userIdAttribute instanceof Integer)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int userId = (Integer) userIdAttribute;
        Optional<HostProfile> hostProfileOptional = hostProfileDAO.findByUserId(userId);

        if (hostProfileOptional.isEmpty()) {
            request.setAttribute("error", "Tài khoản chưa có hồ sơ Host.");
            request.getRequestDispatcher("/WEB-INF/views/host/dashboard.jsp").forward(request, response);
            return;
        }

        HostProfile hostProfile = hostProfileOptional.get();
        List<Property> properties = propertyDAO.findByHostId(hostProfile.getId());

        // Model 2: Host Wallet & Recent Transactions
        BigDecimal hostBalance = walletDAO.getHostBalance((long) userId);
        List<WalletTransaction> recentTransactions = walletDAO.getTransactionsByUserId((long) userId, 5);

        request.setAttribute("hostProfile", hostProfile);
        request.setAttribute("properties", properties);
        request.setAttribute("hostBalance", hostBalance);
        request.setAttribute("recentTransactions", recentTransactions);

        request.getRequestDispatcher("/WEB-INF/views/host/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Host Dashboard Controller";
    }
}
