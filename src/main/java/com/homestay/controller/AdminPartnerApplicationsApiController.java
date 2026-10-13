package com.homestay.controller;

import com.homestay.dao.HostApplicationDAO;
import com.homestay.dao.PartnerApplicationRoomDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.HostApplication;
import com.homestay.model.HostApplication.Status;
import com.homestay.model.PartnerApplicationRoom;
import com.homestay.model.User;
import com.homestay.util.LoginUtil;
import com.homestay.util.PartnerApiJson;
import com.homestay.util.PartnerDocumentStorage;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/** Exposes administrator endpoints for reviewing Host applications and media. */
public class AdminPartnerApplicationsApiController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER =
            Logger.getLogger(AdminPartnerApplicationsApiController.class.getName());

    private final HostApplicationDAO applicationDAO = new HostApplicationDAO();
    private final PartnerApplicationRoomDAO roomDAO = new PartnerApplicationRoomDAO();
    private final UserDAO userDAO = new UserDAO();

    /** Lists applications or returns an owned administrative application resource. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Authorize every API request before reading application or document data.
            User admin = requireAdmin(request, response);
            if (admin == null) {
                return;
            }

            String[] path = pathParts(request);
            if (path.length == 0) {
                Status status = parseStatus(request.getParameter("status"));
                List<Map<String, Object>> results = new ArrayList<>();
                // Convert database entities to the public API shape before serializing the list.
                for (HostApplication application : applicationDAO.findApplications(status)) {
                    results.add(PartnerApiJson.application(
                            application, request.getContextPath(), true));
                }
                Map<String, Object> body = new LinkedHashMap<>();
                body.put("applications", results);
                body.put("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
                PartnerApiJson.write(response, HttpServletResponse.SC_OK, body);
                return;
            }

            int applicationId = parseId(path[0]);
            if (path.length == 1) {
                HostApplication application = applicationDAO.findForAdmin(applicationId);
                if (application == null) {
                    writeError(response, HttpServletResponse.SC_NOT_FOUND,
                            "Partner application was not found.");
                    return;
                }
                PartnerApiJson.write(response, HttpServletResponse.SC_OK,
                        applicationJson(application, request));
                return;
            }

            if (path.length == 5 && "rooms".equals(path[1])
                    && "images".equals(path[3])) {
                int roomId = parseId(path[2]);
                int imageId = parseId(path[4]);
                PartnerApplicationRoom room = roomDAO.findByIdForAdmin(roomId);
                if (room == null || room.getApplicationId() != applicationId) {
                    writeError(response, HttpServletResponse.SC_NOT_FOUND, "Room was not found.");
                    return;
                }
                String storedName = roomDAO.findImagePathForAdmin(roomId, imageId);
                if (storedName == null) {
                    writeError(response, HttpServletResponse.SC_NOT_FOUND, "Image was not found.");
                    return;
                }
                // Stream only the image resolved through the authorized application and room.
                PartnerDocumentStorage.writeMediaResponse(storedName, response);
                return;
            }

            if (path.length == 2 && "rooms".equals(path[1])) {
                List<Map<String, Object>> rooms = new ArrayList<>();
                for (PartnerApplicationRoom room : roomDAO.findByApplicationForAdmin(applicationId)) {
                    rooms.add(PartnerApiJson.room(room, request.getContextPath(), true));
                }
                PartnerApiJson.write(response, HttpServletResponse.SC_OK, rooms);
                return;
            }

            if (path.length == 3 && "documents".equals(path[1])) {
                String storedPath = applicationDAO.findDocumentPath(applicationId, path[2]);
                if (storedPath == null) {
                    writeError(response, HttpServletResponse.SC_NOT_FOUND,
                            "Document was not found.");
                    return;
                }
                // Stream a document only after its application path has been authorized.
                PartnerDocumentStorage.writeResponse(storedPath, response);
                return;
            }

            writeError(response, HttpServletResponse.SC_NOT_FOUND, "API endpoint was not found.");
        } catch (IllegalArgumentException e) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (SQLException e) {
            writeFailure(response, e);
        }
    }

    /** Validates an administrator decision and records it through the application DAO. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        try {
            // Confirm the current database-backed administrator role before accepting a decision.
            User admin = requireAdmin(request, response);
            if (admin == null) {
                return;
            }
            if (!LoginUtil.consumeCsrfToken(request, request.getParameter("csrfToken"))) {
                writeError(response, HttpServletResponse.SC_FORBIDDEN,
                        "CSRF token is missing, expired, or invalid.");
                return;
            }

            String[] path = pathParts(request);
            if (path.length != 2 || !"approve".equals(path[1]) && !"reject".equals(path[1])) {
                writeError(response, HttpServletResponse.SC_NOT_FOUND,
                        "API endpoint was not found.");
                return;
            }
            int applicationId = parseId(path[0]);
            Status decision = "approve".equals(path[1]) ? Status.APPROVED : Status.REJECTED;
            String rejectionReason = valueOrEmpty(request.getParameter("rejectionReason"));
            if (decision == Status.REJECTED
                    && (rejectionReason.length() < 10 || rejectionReason.length() > 500)) {
                writeError(response, HttpServletResponse.SC_BAD_REQUEST,
                        "Rejection reason must contain 10 to 500 characters.");
                return;
            }

            // Apply the state transition in the DAO, which enforces review eligibility.
            boolean reviewed = applicationDAO.review(
                    applicationId, admin.getId(), decision,
                    decision == Status.REJECTED ? rejectionReason : null);
            if (!reviewed) {
                writeError(response, HttpServletResponse.SC_CONFLICT,
                        "Only a complete pending application can be reviewed, and the action must be valid for the current account.");
                return;
            }
            HostApplication application = applicationDAO.findForAdmin(applicationId);
            PartnerApiJson.write(response, HttpServletResponse.SC_OK,
                    applicationJson(application, request));
        } catch (IllegalArgumentException e) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (SQLException e) {
            writeFailure(response, e);
        }
    }

    /** Returns the active administrator or writes the appropriate authorization error. */
    private User requireAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {
        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("userId") instanceof Number)) {
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED,
                    "Authentication is required.");
            return null;
        }
        User user = userDAO.findById(((Number) session.getAttribute("userId")).intValue());
        if (user == null || !"ACTIVE".equals(user.getStatus())) {
            session.invalidate();
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED,
                    "The account is unavailable. Please sign in again.");
            return null;
        }
        if (user.getRole() == null || !"ADMIN".equals(user.getRole().getName())) {
            writeError(response, HttpServletResponse.SC_FORBIDDEN,
                    "Administrator access is required.");
            return null;
        }
        session.setAttribute("role", "ADMIN");
        return user;
    }

    /** Parses an optional list filter and rejects unsupported application states. */
    private Status parseStatus(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            Status status = Status.valueOf(value.trim().toUpperCase(Locale.ROOT));
            if (status == Status.DRAFT) {
                throw new IllegalArgumentException();
            }
            return status;
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException(
                    "Status must be PENDING, APPROVED, or REJECTED.");
        }
    }

    /** Builds the application response and includes its room summaries. */
    private Map<String, Object> applicationJson(HostApplication application,
                                                HttpServletRequest request) throws SQLException {
        Map<String, Object> body =
                PartnerApiJson.application(application, request.getContextPath(), true);
        List<Map<String, Object>> rooms = new ArrayList<>();
        for (PartnerApplicationRoom room :
                roomDAO.findByApplicationForAdmin(application.getId())) {
            rooms.add(PartnerApiJson.room(room, request.getContextPath(), true));
        }
        body.put("rooms", rooms);
        return body;
    }

    /** Splits the request path into non-empty API resource segments. */
    private String[] pathParts(HttpServletRequest request) {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.isBlank() || "/".equals(pathInfo)) {
            return new String[0];
        }
        return java.util.Arrays.stream(pathInfo.split("/"))
                .filter(part -> !part.isBlank())
                .toArray(String[]::new);
    }

    /** Parses a positive resource ID or throws a client-input error. */
    private int parseId(String value) {
        try {
            int id = Integer.parseInt(value);
            if (id <= 0) {
                throw new NumberFormatException();
            }
            return id;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Application ID must be a positive integer.");
        }
    }

    private String valueOrEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    /** Writes a JSON error response with the supplied status and message. */
    private void writeError(HttpServletResponse response, int status, String message)
            throws IOException {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("message", message);
        PartnerApiJson.write(response, status, body);
    }

    /** Logs a database failure and returns a generic API error to the caller. */
    private void writeFailure(HttpServletResponse response, SQLException exception)
            throws IOException {
        LOGGER.log(Level.SEVERE, "Admin partner application API database operation failed.",
                exception);
        writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "The partner application request could not be completed.");
    }
}
