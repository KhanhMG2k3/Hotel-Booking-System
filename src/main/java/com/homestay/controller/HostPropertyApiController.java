package com.homestay.controller;

import com.homestay.dao.PropertyDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.Property;
import com.homestay.model.Room;
import com.homestay.model.Room.RoomImage;
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
import java.math.BigDecimal;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/** Provides CRUD endpoints for properties and rooms owned by the signed-in Host. */
public class HostPropertyApiController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final int MAX_BODY_SIZE = 64 * 1024;
    private static final Logger LOGGER =
            Logger.getLogger(HostPropertyApiController.class.getName());

    private final PropertyDAO propertyDAO = new PropertyDAO();
    private final UserDAO userDAO = new UserDAO();

    /** Lists or retrieves only properties and rooms owned by the authenticated Host. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Resolve the current Host from the database before selecting any resources.
            User host = requireHost(request, response);
            if (host == null) {
                return;
            }
            String[] path = pathParts(request);
            if (path.length == 1 && "properties".equals(path[0])) {
                List<Map<String, Object>> properties = new ArrayList<>();
                for (Property property : propertyDAO.findByOwnerId(host.getId())) {
                    properties.add(propertyJson(property, request));
                }
                Map<String, Object> result = new LinkedHashMap<>();
                result.put("properties", properties);
                result.put("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
                PartnerApiJson.write(response, HttpServletResponse.SC_OK, result);
                return;
            }
            if (path.length == 2 && "properties".equals(path[0])) {
                int propertyId = parseId(path[1], "Property");
                // Scope the lookup by owner so another Host's property is never returned.
                Property property = propertyDAO.findByIdAndOwner(propertyId, host.getId());
                if (property == null) {
                    writeResourceError(response, propertyDAO.belongsToAnotherHost(
                            propertyId, host.getId()), "Property");
                    return;
                }
                property.setRooms(propertyDAO.findRoomsByPropertyAndOwner(
                        propertyId, host.getId()));
                PartnerApiJson.write(response, HttpServletResponse.SC_OK,
                        propertyJson(property, request));
                return;
            }
            if (path.length == 3 && "properties".equals(path[0])
                    && "rooms".equals(path[2])) {
                int propertyId = parseId(path[1], "Property");
                if (!requireOwnedProperty(propertyId, host.getId(), response)) {
                    return;
                }
                List<Map<String, Object>> rooms = new ArrayList<>();
                for (Room room : propertyDAO.findRoomsByPropertyAndOwner(
                        propertyId, host.getId())) {
                    rooms.add(roomJson(room, request));
                }
                PartnerApiJson.write(response, HttpServletResponse.SC_OK, rooms);
                return;
            }
            if (path.length == 6 && "properties".equals(path[0])
                    && "rooms".equals(path[2]) && "images".equals(path[4])) {
                sendRoomImage(host.getId(), path, response);
                return;
            }
            if (path.length == 4 && "properties".equals(path[0])
                    && "rooms".equals(path[2])) {
                int propertyId = parseId(path[1], "Property");
                int roomId = parseId(path[3], "Room");
                if (!requireOwnedRoom(propertyId, roomId, host.getId(), response)) {
                    return;
                }
                Room room = propertyDAO.findRoomByIdAndOwner(roomId, host.getId());
                PartnerApiJson.write(response, HttpServletResponse.SC_OK,
                        roomJson(room, request));
                return;
            }
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "API endpoint was not found.");
        } catch (IllegalArgumentException e) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (SQLException e) {
            writeFailure(response, e);
        }
    }

    /** Creates a Host-owned property or room from validated request data. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        try {
            User host = requireHost(request, response);
            if (host == null) {
                return;
            }
            // Require the one-time token before accepting any create operation.
            if (!requireCsrf(request, response)) {
                return;
            }
            refreshCsrf(response, request);
            String[] path = pathParts(request);
            if (path.length == 1 && "properties".equals(path[0])) {
                // Parse request fields into a model; the DAO performs authoritative validation.
                Property property = readProperty(request);
                int propertyId = propertyDAO.create(host.getId(), property);
                if (propertyId <= 0) {
                    writeError(response, HttpServletResponse.SC_BAD_REQUEST,
                            "Property data is invalid or the Host account is no longer eligible.");
                    return;
                }
                Property created = propertyDAO.findByIdAndOwner(propertyId, host.getId());
                Map<String, Object> result = propertyJson(created, request);
                result.put("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
                PartnerApiJson.write(response, HttpServletResponse.SC_CREATED, result);
                return;
            }
            if (path.length == 3 && "properties".equals(path[0])
                    && "rooms".equals(path[2])) {
                int propertyId = parseId(path[1], "Property");
                if (!requireOwnedProperty(propertyId, host.getId(), response)) {
                    refreshCsrf(response, request);
                    return;
                }
                Room room = readRoom(request);
                int roomId = propertyDAO.createRoom(host.getId(), propertyId, room);
                if (roomId <= 0) {
                    writeError(response, HttpServletResponse.SC_BAD_REQUEST,
                            "Room data is invalid or the property cannot accept more rooms.");
                    return;
                }
                Room created = propertyDAO.findRoomByIdAndOwner(roomId, host.getId());
                Map<String, Object> result = roomJson(created, request);
                result.put("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
                PartnerApiJson.write(response, HttpServletResponse.SC_CREATED, result);
                return;
            }
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "API endpoint was not found.");
        } catch (IllegalArgumentException e) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (SQLException e) {
            writeFailure(response, e);
        }
    }

    /** Updates an owned property or room after parsing and validating the request body. */
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        try {
            User host = requireHost(request, response);
            if (host == null) {
                return;
            }
            // Read bounded form data and validate its one-time token before applying updates.
            Map<String, String[]> parameters = readBodyParameters(request);
            if (!requireCsrf(request, response, parameters.get("csrfToken"))) {
                return;
            }
            refreshCsrf(response, request);
            String[] path = pathParts(request);
            if (path.length == 2 && "properties".equals(path[0])) {
                int propertyId = parseId(path[1], "Property");
                if (!requireOwnedProperty(propertyId, host.getId(), response)) {
                    refreshCsrf(response, request);
                    return;
                }
                if (!propertyDAO.update(host.getId(), propertyId, readProperty(parameters))) {
                    writeError(response, HttpServletResponse.SC_BAD_REQUEST,
                            "Property data is invalid or could not be saved.");
                    return;
                }
                Property updated = propertyDAO.findByIdAndOwner(propertyId, host.getId());
                Map<String, Object> result = propertyJson(updated, request);
                result.put("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
                PartnerApiJson.write(response, HttpServletResponse.SC_OK, result);
                return;
            }
            if (path.length == 4 && "properties".equals(path[0])
                    && "rooms".equals(path[2])) {
                int propertyId = parseId(path[1], "Property");
                int roomId = parseId(path[3], "Room");
                if (!requireOwnedRoom(propertyId, roomId, host.getId(), response)) {
                    refreshCsrf(response, request);
                    return;
                }
                if (!propertyDAO.updateRoom(
                        host.getId(), propertyId, roomId, readRoom(parameters))) {
                    writeError(response, HttpServletResponse.SC_BAD_REQUEST,
                            "Room data is invalid or could not be saved.");
                    return;
                }
                Room updated = propertyDAO.findRoomByIdAndOwner(roomId, host.getId());
                Map<String, Object> result = roomJson(updated, request);
                result.put("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
                PartnerApiJson.write(response, HttpServletResponse.SC_OK, result);
                return;
            }
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "API endpoint was not found.");
        } catch (IllegalArgumentException e) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (SQLException e) {
            writeFailure(response, e);
        }
    }

    /** Deletes an owned property or room after checking CSRF and ownership. */
    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        try {
            User host = requireHost(request, response);
            if (host == null) {
                return;
            }
            // Destructive operations use the same bounded-body and one-time-token checks.
            Map<String, String[]> parameters = readBodyParameters(request);
            if (!requireCsrf(request, response, parameters.get("csrfToken"))) {
                return;
            }
            refreshCsrf(response, request);
            String[] path = pathParts(request);
            if (path.length == 2 && "properties".equals(path[0])) {
                int propertyId = parseId(path[1], "Property");
                if (!requireOwnedProperty(propertyId, host.getId(), response)) {
                    refreshCsrf(response, request);
                    return;
                }
                if (!propertyDAO.delete(host.getId(), propertyId)) {
                    writeError(response, HttpServletResponse.SC_CONFLICT,
                            "The property could not be deleted.");
                    return;
                }
                writeMutationSuccess(response, request, Map.of(
                        "deleted", true, "propertyId", propertyId));
                return;
            }
            if (path.length == 4 && "properties".equals(path[0])
                    && "rooms".equals(path[2])) {
                int propertyId = parseId(path[1], "Property");
                int roomId = parseId(path[3], "Room");
                if (!requireOwnedRoom(propertyId, roomId, host.getId(), response)) {
                    refreshCsrf(response, request);
                    return;
                }
                if (!propertyDAO.deleteRoom(host.getId(), propertyId, roomId)) {
                    writeError(response, HttpServletResponse.SC_CONFLICT,
                            "The room could not be deleted.");
                    return;
                }
                writeMutationSuccess(response, request, Map.of(
                        "deleted", true, "roomId", roomId));
                return;
            }
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "API endpoint was not found.");
        } catch (IllegalArgumentException e) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (SQLException e) {
            writeFailure(response, e);
        }
    }

    /** Returns the active approved Host or writes an authorization error response. */
    private User requireHost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {
        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("userId") instanceof Number)) {
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED,
                    "Authentication is required.");
            return null;
        }
        int userId = ((Number) session.getAttribute("userId")).intValue();
        // Reload role and approval data so a stale session cannot retain Host privileges.
        User user = userDAO.findById(userId).orElse(null);
        if (user == null || !"ACTIVE".equals(user.getStatus())) {
            session.invalidate();
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED,
                    "The account is unavailable. Please sign in again.");
            return null;
        }
        String roleName = user.getRole() != null ? user.getRole().getName() : "";
        if (!roleName.contains("HOST") || !propertyDAO.isApprovedHost(userId)) {
            writeError(response, HttpServletResponse.SC_FORBIDDEN,
                    "Only an approved Host can manage properties and rooms.");
            return null;
        }
        session.setAttribute("role", "HOST");
        return user;
    }

    /** Confirms property ownership and writes not-found or forbidden status otherwise. */
    private boolean requireOwnedProperty(int propertyId, int ownerId,
                                         HttpServletResponse response)
            throws SQLException, IOException {
        if (propertyDAO.findByIdAndOwner(propertyId, ownerId) != null) {
            return true;
        }
        writeResourceError(response,
                propertyDAO.belongsToAnotherHost(propertyId, ownerId), "Property");
        return false;
    }

    /** Confirms both room ownership and its parent property before allowing access. */
    private boolean requireOwnedRoom(int propertyId, int roomId, int ownerId,
                                     HttpServletResponse response)
            throws SQLException, IOException {
        Room room = propertyDAO.findRoomByIdAndOwner(roomId, ownerId);
        if (room != null && room.getPropertyId() == propertyId) {
            return true;
        }
        if (propertyDAO.belongsToAnotherHost(propertyId, ownerId)
                || propertyDAO.roomBelongsToAnotherHost(roomId, ownerId)) {
            writeError(response, HttpServletResponse.SC_FORBIDDEN,
                    "This room or property belongs to another Host.");
        } else {
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "Room was not found.");
        }
        return false;
    }

    /** Streams an image only after resolving its room through the Host ownership scope. */
    private void sendRoomImage(int ownerId, String[] path, HttpServletResponse response)
            throws IOException, SQLException {
        int propertyId = parseId(path[1], "Property");
        int roomId = parseId(path[3], "Room");
        int imageId = parseId(path[5], "Image");
        String storedName = propertyDAO.findRoomImagePath(
                ownerId, propertyId, roomId, imageId);
        if (storedName == null) {
            boolean forbidden = propertyDAO.belongsToAnotherHost(propertyId, ownerId)
                    || propertyDAO.roomBelongsToAnotherHost(roomId, ownerId)
                    || propertyDAO.roomImageBelongsToAnotherHost(imageId, ownerId);
            writeResourceError(response, forbidden, "Room image");
            return;
        }
        var imagePath = PartnerDocumentStorage.resolve(storedName);
        response.setContentType(PartnerDocumentStorage.getContentType(storedName));
        response.setHeader("Content-Disposition", "inline");
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("Cache-Control", "private, no-store");
        response.setContentLengthLong(java.nio.file.Files.size(imagePath));
        try (var input = java.nio.file.Files.newInputStream(imagePath)) {
            input.transferTo(response.getOutputStream());
        }
    }

    /** Builds a property model from servlet parameters for the DAO validation layer. */
    private Property readProperty(HttpServletRequest request) {
        return readProperty(request::getParameter);
    }

    /** Builds a property model from parsed request-body parameters. */
    private Property readProperty(Map<String, String[]> parameters) {
        return readProperty(name -> first(parameters.get(name)));
    }

    /** Maps named property inputs and optional coordinates into a property model. */
    private Property readProperty(ParameterReader reader) {
        Property property = new Property();
        property.setPropertyName(reader.get("propertyName"));
        property.setPropertyType(reader.get("propertyType"));
        property.setDescription(reader.get("description"));
        property.setAddress(reader.get("address"));
        property.setCity(reader.get("city"));
        property.setDistrict(reader.get("district"));
        property.setWard(reader.get("ward"));
        property.setLatitude(parseOptionalDouble(reader.get("latitude"), "latitude"));
        property.setLongitude(parseOptionalDouble(reader.get("longitude"), "longitude"));
        return property;
    }

    /** Builds a room model from a servlet form request. */
    private Room readRoom(HttpServletRequest request) {
        Room room = new Room();
        room.setRoomName(request.getParameter("roomName"));
        room.setRoomType(request.getParameter("roomType"));
        room.setPricePerNight(parsePrice(request.getParameter("pricePerNight")));
        room.setMaxGuests(parseRequiredInteger(request.getParameter("maxGuests"), "maxGuests"));
        room.setBedCount(parseRequiredInteger(request.getParameter("bedCount"), "bedCount"));
        room.setBathroomCount(
                parseRequiredInteger(request.getParameter("bathroomCount"), "bathroomCount"));
        room.setSortOrder(parseOptionalInteger(request.getParameter("sortOrder"), "sortOrder", 0));
        room.setAmenities(List.of(request.getParameterValues("amenities") == null
                ? new String[0] : request.getParameterValues("amenities")));
        return room;
    }

    /** Builds a room model from parsed request-body parameters. */
    private Room readRoom(Map<String, String[]> parameters) {
        Room room = new Room();
        room.setRoomName(first(parameters.get("roomName")));
        room.setRoomType(first(parameters.get("roomType")));
        room.setPricePerNight(parsePrice(first(parameters.get("pricePerNight"))));
        room.setMaxGuests(parseRequiredInteger(first(parameters.get("maxGuests")), "maxGuests"));
        room.setBedCount(parseRequiredInteger(first(parameters.get("bedCount")), "bedCount"));
        room.setBathroomCount(
                parseRequiredInteger(first(parameters.get("bathroomCount")), "bathroomCount"));
        room.setSortOrder(parseOptionalInteger(first(parameters.get("sortOrder")), "sortOrder", 0));
        String[] amenities = parameters.get("amenities");
        room.setAmenities(amenities == null ? List.of() : List.of(amenities));
        return room;
    }

    /** Maps a property and any loaded rooms into the JSON response shape. */
    private Map<String, Object> propertyJson(Property property, HttpServletRequest request)
            throws SQLException {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("id", property.getId());
        result.put("ownerId", property.getOwnerId());
        result.put("applicationId", property.getApplicationId() == 0
                ? null : property.getApplicationId());
        result.put("propertyName", property.getPropertyName());
        result.put("propertyType", property.getPropertyType());
        result.put("description", property.getDescription());
        result.put("address", property.getAddress());
        result.put("city", property.getCity());
        result.put("district", property.getDistrict());
        result.put("ward", property.getWard());
        result.put("latitude", property.getLatitude());
        result.put("longitude", property.getLongitude());
        result.put("roomCount", property.getRoomCount());
        result.put("maxGuests", property.getMaxGuests());
        result.put("status", property.getStatus());
        if (!property.getRooms().isEmpty()) {
            List<Map<String, Object>> rooms = new ArrayList<>();
            for (Room room : property.getRooms()) {
                rooms.add(roomJson(room, request));
            }
            result.put("rooms", rooms);
        }
        return result;
    }

    /** Maps a room and its image links into the JSON response shape. */
    private Map<String, Object> roomJson(Room room, HttpServletRequest request) {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("id", room.getId());
        result.put("propertyId", room.getPropertyId());
        result.put("roomName", room.getRoomName());
        result.put("roomType", room.getRoomType());
        result.put("pricePerNight", room.getPricePerNight());
        result.put("maxGuests", room.getMaxGuests());
        result.put("bedCount", room.getBedCount());
        result.put("bathroomCount", room.getBathroomCount());
        result.put("sortOrder", room.getSortOrder());
        result.put("amenities", room.getAmenities());
        List<Map<String, Object>> images = new ArrayList<>();
        for (RoomImage image : room.getRoomImages()) {
            Map<String, Object> imageJson = new LinkedHashMap<>();
            imageJson.put("id", image.getId());
            imageJson.put("mediaType", image.getMediaType());
            imageJson.put("contentType", image.getContentType());
            imageJson.put("sortOrder", image.getSortOrder());
            imageJson.put("url", request.getContextPath() + "/api/host/properties/"
                    + room.getPropertyId() + "/rooms/" + room.getId()
                    + "/images/" + image.getId());
            images.add(imageJson);
        }
        result.put("images", images);
        return result;
    }

    /** Validates a form token and emits a forbidden response when it is invalid. */
    private boolean requireCsrf(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        return requireCsrf(request, response, request.getParameter("csrfToken"));
    }

    private boolean requireCsrf(HttpServletRequest request, HttpServletResponse response,
                                String[] submittedTokens) throws IOException {
        return requireCsrf(request, response, first(submittedTokens));
    }

    private boolean requireCsrf(HttpServletRequest request, HttpServletResponse response,
                                String submittedToken) throws IOException {
        if (LoginUtil.consumeCsrfToken(request, submittedToken)) {
            return true;
        }
        writeError(response, HttpServletResponse.SC_FORBIDDEN,
                "CSRF token is missing, expired, or invalid. Fetch a fresh token and retry.");
        return false;
    }

    /** Returns a refreshed token in the response header after a token is consumed. */
    private void refreshCsrf(HttpServletResponse response, HttpServletRequest request)
            throws IOException {
        response.setHeader("X-CSRF-Token", LoginUtil.getOrCreateCsrfToken(request));
    }

    /** Adds the next CSRF token and writes a successful mutation response. */
    private void writeMutationSuccess(HttpServletResponse response,
                                      HttpServletRequest request,
                                      Map<String, Object> result) throws IOException {
        result.put("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
        PartnerApiJson.write(response, HttpServletResponse.SC_OK, result);
    }

    /** Uses a forbidden response for another Host's resource, otherwise not found. */
    private void writeResourceError(HttpServletResponse response, boolean forbidden,
                                    String resource) throws IOException {
        if (forbidden) {
            writeError(response, HttpServletResponse.SC_FORBIDDEN,
                    resource + " belongs to another Host.");
        } else {
            writeError(response, HttpServletResponse.SC_NOT_FOUND, resource + " was not found.");
        }
    }

    private void writeError(HttpServletResponse response, int status, String message)
            throws IOException {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("message", message);
        PartnerApiJson.write(response, status, result);
    }

    private void writeFailure(HttpServletResponse response, SQLException exception)
            throws IOException {
        LOGGER.log(Level.SEVERE, "Host property API database operation failed.", exception);
        writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "The property or room request could not be completed.");
    }

    /** Reads a bounded request body into parameters and rejects malformed input. */
    private Map<String, String[]> readBodyParameters(HttpServletRequest request)
            throws IOException {
        if (request.getContentLengthLong() > MAX_BODY_SIZE) {
            throw new IllegalArgumentException("The request body is too large.");
        }
        byte[] body = request.getInputStream().readNBytes(MAX_BODY_SIZE + 1);
        if (body.length > MAX_BODY_SIZE) {
            throw new IllegalArgumentException("The request body is too large.");
        }
        String content = new String(body,
                StandardCharsets.UTF_8);
        Map<String, List<String>> values = new LinkedHashMap<>();
        if (!content.isBlank()) {
            for (String pair : content.split("&")) {
                String[] parts = pair.split("=", 2);
                String key = URLDecoder.decode(parts[0], StandardCharsets.UTF_8);
                String value = parts.length == 2
                        ? URLDecoder.decode(parts[1], StandardCharsets.UTF_8) : "";
                values.computeIfAbsent(key, ignored -> new ArrayList<>()).add(value);
            }
        }
        Map<String, String[]> parameters = new LinkedHashMap<>();
        values.forEach((key, value) -> parameters.put(key, value.toArray(String[]::new)));
        return parameters;
    }

    private String[] pathParts(HttpServletRequest request) {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.isBlank() || "/".equals(pathInfo)) {
            return new String[0];
        }
        return java.util.Arrays.stream(pathInfo.split("/"))
                .filter(part -> !part.isBlank()).toArray(String[]::new);
    }

    /** Parses a positive resource ID and includes its resource name in validation errors. */
    private int parseId(String value, String name) {
        try {
            int id = Integer.parseInt(value);
            if (id > 0) {
                return id;
            }
        } catch (NumberFormatException ignored) {
            // Return one consistent validation message for malformed identifiers.
        }
        throw new IllegalArgumentException(name + " ID must be a positive integer.");
    }

    /** Parses a required integer value or throws a field-specific validation error. */
    private Integer parseRequiredInteger(String value, String name) {
        Integer parsed = parseOptionalInteger(value, name, null);
        if (parsed == null) {
            throw new IllegalArgumentException(name + " is required.");
        }
        return parsed;
    }

    /** Parses an optional integer value, returning the supplied default when absent. */
    private Integer parseOptionalInteger(String value, String name, Integer defaultValue) {
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(name + " must be an integer.");
        }
    }

    /** Parses an optional nightly price or reports an invalid numeric amount. */
    private BigDecimal parsePrice(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return new BigDecimal(value.trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("pricePerNight must be a valid amount.");
        }
    }

    /** Parses an optional finite coordinate or reports a field-specific input error. */
    private Double parseOptionalDouble(String value, String name) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            double parsed = Double.parseDouble(value.trim());
            if (Double.isFinite(parsed)) {
                return parsed;
            }
        } catch (NumberFormatException ignored) {
            // Use a field-specific validation message below.
        }
        throw new IllegalArgumentException(name + " must be a valid number.");
    }

    private String first(String[] values) {
        return values == null || values.length == 0 ? null : values[0];
    }

    /** Supplies named values from either servlet parameters or parsed body data. */
    @FunctionalInterface
    private interface ParameterReader {
        String get(String name);
    }

}
