package com.homestay.controller;

import com.homestay.dao.HostApplicationDAO;
import com.homestay.dao.PartnerApplicationRoomDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.HostApplication;
import com.homestay.model.HostApplication.IdentificationType;
import com.homestay.model.PartnerApplicationMedia;
import com.homestay.model.PartnerApplicationRoom;
import com.homestay.model.User;
import com.homestay.util.LoginUtil;
import com.homestay.util.PartnerApiJson;
import com.homestay.util.PartnerDocumentStorage;
import com.homestay.util.PartnerDocumentStorage.StoredDocument;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/** Provides customer endpoints for Host applications, rooms, and uploaded documents. */
@MultipartConfig(
        fileSizeThreshold = 64 * 1024,
        maxFileSize = PartnerDocumentStorage.MAX_MEDIA_FILE_SIZE,
        maxRequestSize = PartnerDocumentStorage.MAX_MEDIA_FILE_SIZE + 2L * 1024 * 1024
)
public class PartnerApplicationApiController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER =
            Logger.getLogger(PartnerApplicationApiController.class.getName());
    private static final int SC_UNPROCESSABLE_ENTITY = 422;

    private final HostApplicationDAO applicationDAO = new HostApplicationDAO();
    private final PartnerApplicationRoomDAO roomDAO = new PartnerApplicationRoomDAO();
    private final UserDAO userDAO = new UserDAO();

    /** Reads the caller's application resources and streams only their authorized files. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Authenticate and authorize the account before looking up application resources.
            String[] path = pathParts(request);
            User user = requireUser(request, response, "CUSTOMER", "HOST");
            if (user == null) {
                return;
            }

            if (path.length == 1 && "eligibility".equals(path[0])) {
                if (!requireRole(user, response, "CUSTOMER")) {
                    return;
                }
                HostApplication current = applicationDAO.findLatestByUserId(user.getId());
                Map<String, Object> body = new LinkedHashMap<>();
                body.put("canApply", applicationDAO.canApply(user.getId()));
                body.put("profile", profileJson(user));
                body.put("application", current == null ? null
                        : PartnerApiJson.application(current, request.getContextPath(), false));
                body.put("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
                PartnerApiJson.write(response, HttpServletResponse.SC_OK, body);
                return;
            }
            if (path.length == 1 && "me".equals(path[0])) {
                HostApplication application = applicationDAO.findLatestByUserId(user.getId());
                Map<String, Object> body = new LinkedHashMap<>();
                body.put("profile", profileJson(user));
                body.put("application", application == null ? null
                        : applicationJson(application, request));
                body.put("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
                PartnerApiJson.write(response, HttpServletResponse.SC_OK, body);
                return;
            }
            if (path.length == 2 && "rooms".equals(path[1])) {
                int applicationId = parseId(path[0]);
                HostApplication application = applicationDAO.findById(applicationId);
                if (application == null || application.getUserId() != user.getId()) {
                    writeError(response, HttpServletResponse.SC_NOT_FOUND,
                            "Partner application was not found.");
                    return;
                }
                writeRooms(response, request, roomDAO.findByApplication(applicationId, user.getId()));
                return;
            }
            if (path.length == 2 && "media".equals(path[1])) {
                int applicationId = parseId(path[0]);
                HostApplication application = applicationDAO.findById(applicationId);
                if (application == null || application.getUserId() != user.getId()) {
                    writeError(response, HttpServletResponse.SC_NOT_FOUND,
                            "Host application was not found.");
                    return;
                }
                List<Map<String, Object>> media = new ArrayList<>();
                for (PartnerApplicationMedia item
                        : roomDAO.findAllStagedMedia(applicationId, user.getId())) {
                    media.add(stagedMediaJson(item, request));
                }
                PartnerApiJson.write(response, HttpServletResponse.SC_OK, media);
                return;
            }
            if (path.length == 3 && "media".equals(path[1])) {
                sendStagedMedia(user, parseId(path[0]), parseId(path[2]), response);
                return;
            }
            if (path.length == 3 && "rooms".equals(path[1])) {
                int applicationId = parseId(path[0]);
                int roomId = parseId(path[2]);
                PartnerApplicationRoom room = roomDAO.findById(roomId, user.getId());
                if (room == null || room.getApplicationId() != applicationId) {
                    writeError(response, HttpServletResponse.SC_NOT_FOUND, "Room was not found.");
                    return;
                }
                PartnerApiJson.write(response, HttpServletResponse.SC_OK,
                        PartnerApiJson.room(room, request.getContextPath(), false));
                return;
            }
            if (path.length == 5 && "rooms".equals(path[1])
                    && "images".equals(path[3])) {
                sendOwnRoomImage(user, path[0], path[2], path[4], response);
                return;
            }
            if (path.length == 3 && "documents".equals(path[1])) {
                sendOwnDocument(user, path[0], path[2], response);
                return;
            }
            if (path.length == 1) {
                int applicationId = parseId(path[0]);
                HostApplication application = applicationDAO.findById(applicationId);
                if (application == null || application.getUserId() != user.getId()) {
                    writeError(response, HttpServletResponse.SC_NOT_FOUND,
                            "Partner application was not found.");
                    return;
                }
                PartnerApiJson.write(response, HttpServletResponse.SC_OK,
                        applicationJson(application, request));
                return;
            }
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "API endpoint was not found.");
        } catch (IllegalArgumentException e) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (SQLException e) {
            writeFailure(response, e);
        }
    }

    /** Creates or updates an application draft and manages its rooms and media. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        try {
            // Enforce the customer role and CSRF token before processing mutation routes.
            String[] path = pathParts(request);
            User user = requireUser(request, response, "CUSTOMER");
            if (user == null) {
                return;
            }
            if (!requireCsrf(request, response)) {
                return;
            }

            if (path.length == 0) {
                HostApplication previous = applicationDAO.findLatestByUserId(user.getId());
                HostApplication application = readApplication(request, new HostApplication(), user.getId());
                if (!applicationDAO.saveDraft(application)) {
                    writeError(response, HttpServletResponse.SC_CONFLICT,
                            "An active application already exists or the account cannot apply.");
                    return;
                }
                application = applicationDAO.findById(application.getId());
                writeApplication(response, previous == null || previous.isRejected()
                        ? HttpServletResponse.SC_CREATED : HttpServletResponse.SC_OK,
                        application, request);
                return;
            }

            if (path.length == 2 && "rooms".equals(path[1])) {
                int applicationId = parseId(path[0]);
                HostApplication application = applicationDAO.findById(applicationId);
                if (!isOwnedEditableApplication(application, user)
                        || application.getStatus() != HostApplication.Status.DRAFT) {
                    writeError(response, HttpServletResponse.SC_CONFLICT,
                            "Rooms can only be edited on your current draft.");
                    return;
                }
                PartnerApplicationRoom room = readRoom(request);
                // Validate the submitted room before persisting it or attaching staged media.
                String validationError = roomDAO.getValidationError(room);
                if (validationError != null) {
                    writeError(response, SC_UNPROCESSABLE_ENTITY, validationError);
                    return;
                }
                if (!roomDAO.save(applicationId, user.getId(), room)) {
                    writeError(response, HttpServletResponse.SC_CONFLICT,
                            "The room was not saved. The draft may no longer be editable, may "
                                    + "already contain 20 rooms, or its staged media may exceed "
                                    + "the 10-file limit. Refresh the draft to verify its current state.");
                    return;
                }
                PartnerApplicationRoom savedRoom = roomDAO.findById(room.getId(), user.getId());
                if (savedRoom == null) {
                    writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                            "The room was saved but could not be reloaded.");
                    return;
                }
                PartnerApiJson.write(response, HttpServletResponse.SC_CREATED,
                        PartnerApiJson.room(savedRoom, request.getContextPath(), false));
                return;
            }
            if (path.length == 3 && "rooms".equals(path[1])) {
                int applicationId = parseId(path[0]);
                int roomId = parseId(path[2]);
                PartnerApplicationRoom existing = roomDAO.findById(roomId, user.getId());
                if (existing == null || existing.getApplicationId() != applicationId) {
                    writeError(response, HttpServletResponse.SC_NOT_FOUND, "Room was not found.");
                    return;
                }
                PartnerApplicationRoom room = readRoom(request);
                room.setId(roomId);
                String validationError = roomDAO.getValidationError(room);
                if (validationError != null) {
                    writeError(response, SC_UNPROCESSABLE_ENTITY, validationError);
                    return;
                }
                if (!roomDAO.save(applicationId, user.getId(), room)) {
                    writeError(response, HttpServletResponse.SC_CONFLICT,
                            "The room was not saved. The draft may no longer be editable, may "
                                    + "already contain 20 rooms, or its staged media may exceed "
                                    + "the 10-file limit. Refresh the draft to verify its current state.");
                    return;
                }
                PartnerApplicationRoom updated = roomDAO.findById(roomId, user.getId());
                PartnerApiJson.write(response, HttpServletResponse.SC_OK,
                        PartnerApiJson.room(updated, request.getContextPath(), false));
                return;
            }
            if (path.length == 4 && "rooms".equals(path[1])
                    && "delete".equals(path[3])) {
                int applicationId = parseId(path[0]);
                int roomId = parseId(path[2]);
                List<PartnerApplicationRoom> rooms =
                        roomDAO.findByApplication(applicationId, user.getId());
                PartnerApplicationRoom room = rooms.stream()
                        .filter(candidate -> candidate.getId() == roomId).findFirst().orElse(null);
                if (room == null) {
                    writeError(response, HttpServletResponse.SC_CONFLICT,
                            "The room could not be removed.");
                    return;
                }
                // Preserve stored image references so the files can be removed after DB deletion.
                List<String> imageNames = new java.util.ArrayList<>();
                for (var image : room.getImages()) {
                    String imageName = roomDAO.findImagePath(roomId, image.getId(), user.getId());
                    if (imageName != null) {
                        imageNames.add(imageName);
                    }
                }
                if (!roomDAO.delete(applicationId, user.getId(), roomId)) {
                    writeError(response, HttpServletResponse.SC_CONFLICT,
                            "The room could not be removed.");
                    return;
                }
                imageNames.forEach(this::deleteStoredFile);
                PartnerApiJson.write(response, HttpServletResponse.SC_OK,
                        Map.of("deleted", true, "roomId", roomId));
                return;
            }
            if (path.length == 3 && "media".equals(path[1])) {
                uploadStagedMedia(request, response, user, path[0], path[2]);
                return;
            }
            if (path.length == 5 && "media".equals(path[1])
                    && "delete".equals(path[4])) {
                deleteStagedMedia(response, user, parseId(path[0]), path[2],
                        parseId(path[3]));
                return;
            }
            if (path.length == 4 && "rooms".equals(path[1])
                    && "images".equals(path[3])) {
                uploadRoomMedia(request, response, user, path[0], path[2]);
                return;
            }
            if (path.length == 4 && "documents".equals(path[1])
                    && "delete".equals(path[3])) {
                removeDocument(response, user, parseId(path[0]), path[2]);
                return;
            }
            if (path.length == 6 && "rooms".equals(path[1])
                    && "images".equals(path[3]) && "delete".equals(path[5])) {
                deleteRoomImage(request, response, user,
                        parseId(path[0]), parseId(path[2]), parseId(path[4]));
                return;
            }

            if (path.length == 1) {
                int applicationId = parseId(path[0]);
                HostApplication existing = applicationDAO.findById(applicationId);
                if (!isOwnedEditableApplication(existing, user)) {
                    writeError(response, HttpServletResponse.SC_CONFLICT,
                            "Only your draft or rejected application can be edited.");
                    return;
                }
                HostApplication application = readApplication(request, existing, user.getId());
                if (!applicationDAO.saveDraft(application)) {
                    writeError(response, HttpServletResponse.SC_CONFLICT,
                            "The application could not be saved in its current state.");
                    return;
                }
                writeApplication(response, application.getId() == applicationId
                                ? HttpServletResponse.SC_OK : HttpServletResponse.SC_CREATED,
                        application, request);
                return;
            }

            if (path.length == 2 && "submit".equals(path[1])) {
                int applicationId = parseId(path[0]);
                HostApplication application = applicationDAO.findById(applicationId);
                if (application == null || application.getUserId() != user.getId()) {
                    writeError(response, HttpServletResponse.SC_NOT_FOUND,
                            "Partner application was not found.");
                    return;
                }
                if (!applicationDAO.submitApplication(application)) {
                    writeError(response, SC_UNPROCESSABLE_ENTITY,
                            "The application is incomplete or cannot be submitted in its current state.");
                    return;
                }
                HostApplication submitted = applicationDAO.findById(applicationId);
                writeApplication(response, HttpServletResponse.SC_OK, submitted, request);
                return;
            }

            if (path.length == 3 && "documents".equals(path[1])) {
                uploadDocument(request, response, user, path[0], path[2]);
                return;
            }
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "API endpoint was not found.");
        } catch (IllegalArgumentException e) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (IllegalStateException e) {
            writeError(response, HttpServletResponse.SC_REQUEST_ENTITY_TOO_LARGE,
                    "The uploaded file exceeds the 50 MB limit.");
        } catch (SQLException e) {
            writeFailure(response, e);
        }
    }

    /** Stores a validated private document and updates its reference on the owned draft. */
    private void uploadDocument(HttpServletRequest request, HttpServletResponse response,
                                User user, String rawId, String documentType)
            throws IOException, SQLException {
        int applicationId = parseId(rawId);
        if (!"identity".equals(documentType) && !"ownership".equals(documentType)
                && !"business".equals(documentType)) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST,
                    "Document type must be identity, ownership, or business.");
            return;
        }

        HostApplication application = applicationDAO.findById(applicationId);
        if (!isOwnedEditableApplication(application, user)
                || application.getStatus() != HostApplication.Status.DRAFT) {
            writeError(response, HttpServletResponse.SC_CONFLICT,
                    "Documents can only be uploaded to your current draft.");
            return;
        }

        Part part;
        try {
            part = request.getPart("file");
        } catch (ServletException e) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST,
                    "A multipart file field named 'file' is required.");
            return;
        }
        if (part == null || part.getSize() == 0) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST,
                    "A non-empty document file is required.");
            return;
        }

        String previousPath = applicationDAO.findDocumentPath(applicationId, documentType);
        // Store and signature-check the upload before changing the database reference.
        StoredDocument stored;
        try {
            stored = PartnerDocumentStorage.store(part);
        } catch (IllegalArgumentException e) {
            writeError(response, HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE, e.getMessage());
            return;
        }

        // Remove the new file if the draft changed before its document reference was saved.
        if (!applicationDAO.updateDocument(user.getId(), applicationId, documentType,
                stored.getStoredName())) {
            PartnerDocumentStorage.delete(stored.getStoredName());
            writeError(response, HttpServletResponse.SC_CONFLICT,
                    "The application changed state before the document could be saved.");
            return;
        }
        deleteReplacedDocument(previousPath);

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("applicationId", applicationId);
        body.put("documentType", documentType);
        body.put("contentType", stored.getContentType());
        body.put("url", request.getContextPath() + "/api/partner-applications/"
                + applicationId + "/documents/" + documentType);
        PartnerApiJson.write(response, HttpServletResponse.SC_OK, body);
    }

    /** Removes an owned draft's document reference before deleting the unreferenced file. */
    private void removeDocument(HttpServletResponse response, User user, int applicationId,
                                String documentType) throws IOException, SQLException {
        HostApplication application = applicationDAO.findById(applicationId);
        if (!isOwnedEditableApplication(application, user)
                || application.getStatus() != HostApplication.Status.DRAFT) {
            writeError(response, HttpServletResponse.SC_NOT_FOUND,
                    "Partner application was not found.");
            return;
        }
        String storedName = applicationDAO.findDocumentPath(applicationId, documentType);
        if (storedName == null) {
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "Document was not found.");
            return;
        }
        if (!applicationDAO.removeDocument(user.getId(), applicationId, documentType)) {
            writeError(response, HttpServletResponse.SC_CONFLICT,
                    "Documents can only be removed from your current draft.");
            return;
        }
        deleteReplacedDocument(storedName);
        PartnerApiJson.write(response, HttpServletResponse.SC_OK,
                Map.of("deleted", true, "documentType", documentType));
    }

    /** Streams a document only after confirming the application belongs to the caller. */
    private void sendOwnDocument(User user, String rawId, String documentType,
                                 HttpServletResponse response)
            throws IOException, SQLException {
        int applicationId = parseId(rawId);
        HostApplication application = applicationDAO.findById(applicationId);
        if (application == null || application.getUserId() != user.getId()) {
            writeError(response, HttpServletResponse.SC_NOT_FOUND,
                    "Partner application was not found.");
            return;
        }
        String storedPath = applicationDAO.findDocumentPath(applicationId, documentType);
        if (storedPath == null) {
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "Document was not found.");
            return;
        }
        PartnerDocumentStorage.writeResponse(storedPath, response);
    }

    /** Maps supplied form fields into an application model, parsing typed values safely. */
    private HostApplication readApplication(HttpServletRequest request, HostApplication application,
                                            int userId) {
        application.setUserId(userId);
        if (hasParameter(request, "applicationNote")) {
            application.setApplicationNote(request.getParameter("applicationNote").trim());
        }
        setString(request, "applicantName", application::setApplicantName);
        setString(request, "applicantEmail", application::setApplicantEmail);
        setString(request, "applicantPhone", application::setApplicantPhone);
        setString(request, "identificationNumber", application::setIdentificationNumber);
        setString(request, "propertyName", application::setPropertyName);
        setString(request, "propertyType", application::setPropertyType);
        setString(request, "propertyDescription", application::setPropertyDescription);
        setString(request, "propertyAddress", application::setPropertyAddress);
        setString(request, "propertyCity", application::setPropertyCity);
        setString(request, "propertyDistrict", application::setPropertyDistrict);
        setString(request, "propertyWard", application::setPropertyWard);
        if (hasParameter(request, "identificationType")) {
            String value = request.getParameter("identificationType").trim();
            try {
                application.setIdentificationType(value.isEmpty() ? null
                        : IdentificationType.valueOf(value.toUpperCase(Locale.ROOT)));
            } catch (IllegalArgumentException e) {
                throw new IllegalArgumentException("Invalid identification type.");
            }
        }
        if (application.getIdentificationType() == IdentificationType.NATIONAL_ID
                && application.getIdentificationNumber() != null
                && !application.getIdentificationNumber().isBlank()) {
            String cccdError = com.homestay.util.CccdValidator.getValidationError(application.getIdentificationNumber());
            if (cccdError != null) {
                throw new IllegalArgumentException(cccdError);
            }
        }
        if (hasParameter(request, "latitude")) {
            application.setLatitude(parseDouble(request.getParameter("latitude"), "latitude"));
        }
        if (hasParameter(request, "longitude")) {
            application.setLongitude(parseDouble(request.getParameter("longitude"), "longitude"));
        }
        if (hasParameter(request, "roomCount")) {
            application.setRoomCount(parseInteger(request.getParameter("roomCount"), "roomCount"));
        }
        if (hasParameter(request, "maxGuests")) {
            application.setMaxGuests(parseInteger(request.getParameter("maxGuests"), "maxGuests"));
        }
        return application;
    }

    /** Builds a room model from submitted fields and parses required numeric inputs. */
    private PartnerApplicationRoom readRoom(HttpServletRequest request) {
        PartnerApplicationRoom room = new PartnerApplicationRoom();
        room.setRoomName(request.getParameter("roomName"));
        room.setRoomType(request.getParameter("roomType"));
        try {
            room.setPricePerNight(new java.math.BigDecimal(request.getParameter("pricePerNight")));
        } catch (NumberFormatException | NullPointerException e) {
            throw new IllegalArgumentException("Price per night must be a valid amount.");
        }
        room.setMaxGuests(parseRequiredInteger(request, "maxGuests"));
        room.setBedCount(parseRequiredInteger(request, "bedCount"));
        room.setBathroomCount(parseRequiredInteger(request, "bathroomCount"));
        room.setSortOrder(parseInteger(request.getParameter("sortOrder"), "sortOrder") == null
                ? 0 : parseInteger(request.getParameter("sortOrder"), "sortOrder"));
        String clientRoomKey = request.getParameter("clientRoomKey");
        room.setClientRoomKey(clientRoomKey == null ? null : clientRoomKey.trim());
        String[] amenities = request.getParameterValues("amenities");
        room.setAmenities(amenities == null ? java.util.List.of()
                : java.util.Arrays.asList(amenities));
        return room;
    }

    private int parseRequiredInteger(HttpServletRequest request, String name) {
        Integer value = parseInteger(request.getParameter(name), name);
        if (value == null) {
            throw new IllegalArgumentException(name + " is required.");
        }
        return value;
    }

    /** Stores media for an existing draft room after ownership and file checks. */
    private void uploadRoomMedia(HttpServletRequest request, HttpServletResponse response,
                                 User user, String rawApplicationId, String rawRoomId)
            throws IOException, SQLException {
        int applicationId = parseId(rawApplicationId);
        int roomId = parseId(rawRoomId);
        PartnerApplicationRoom room = roomDAO.findByIdForOwner(roomId, user.getId());
        if (room == null || room.getApplicationId() != applicationId) {
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "Room was not found.");
            return;
        }
        Part part;
        try {
            part = request.getPart("file");
        } catch (ServletException e) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST,
                    "A multipart file field named 'file' is required.");
            return;
        }
        if (part == null || part.getSize() == 0) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST,
                    "Choose a non-empty image or video file.");
            return;
        }
        StoredDocument stored;
        try {
            stored = PartnerDocumentStorage.storeMedia(part);
        } catch (IllegalArgumentException e) {
            writeError(response, HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE,
                    e.getMessage());
            return;
        }
        String mediaType = stored.getContentType().startsWith("image/") ? "IMAGE" : "VIDEO";
        if (!roomDAO.addImage(applicationId, user.getId(), roomId,
                stored.getStoredName(), mediaType, stored.getContentType())) {
            PartnerDocumentStorage.delete(stored.getStoredName());
            writeError(response, HttpServletResponse.SC_CONFLICT,
                    "Could not save the file. A room can have up to 10 media files.");
            return;
        }
        PartnerApplicationRoom updated = roomDAO.findById(roomId, user.getId());
        PartnerApiJson.write(response, HttpServletResponse.SC_CREATED,
                PartnerApiJson.room(updated, request.getContextPath(), false));
    }

    /** Stores media against a draft before a room is created and returns its reference. */
    private void uploadStagedMedia(HttpServletRequest request, HttpServletResponse response,
                                   User user, String rawApplicationId, String clientRoomKey)
            throws IOException, SQLException {
        int applicationId = parseId(rawApplicationId);
        if (clientRoomKey == null || !clientRoomKey.matches("^[A-Za-z0-9_-]{1,64}$")) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST,
                    "The room upload key is invalid.");
            return;
        }
        HostApplication application = applicationDAO.findById(applicationId);
        if (!isOwnedEditableApplication(application, user)
                || application.getStatus() != HostApplication.Status.DRAFT) {
            writeError(response, HttpServletResponse.SC_CONFLICT,
                    "Media can only be uploaded to your current draft.");
            return;
        }

        Part part;
        try {
            part = request.getPart("file");
        } catch (ServletException e) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST,
                    "A multipart file field named 'file' is required.");
            return;
        }
        if (part == null || part.getSize() <= 0) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST,
                    "Choose a non-empty image or video file.");
            return;
        }

        StoredDocument stored;
        try {
            stored = PartnerDocumentStorage.storeMedia(part);
        } catch (IllegalArgumentException e) {
            writeError(response, HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE, e.getMessage());
            return;
        }
        String mediaType = stored.getContentType().startsWith("image/") ? "IMAGE" : "VIDEO";
        PartnerApplicationMedia media = roomDAO.addStagedMedia(applicationId, user.getId(),
                clientRoomKey, stored.getStoredName(), mediaType, stored.getContentType());
        if (media == null) {
            deleteStoredFile(stored.getStoredName());
            writeError(response, HttpServletResponse.SC_CONFLICT,
                    "A room can have up to 10 media files, or this draft can no longer be edited.");
            return;
        }
        PartnerApiJson.write(response, HttpServletResponse.SC_CREATED,
                stagedMediaJson(media, request));
    }

    /** Streams staged media only when its application and owner match the caller. */
    private void sendStagedMedia(User user, int applicationId, int mediaId,
                                 HttpServletResponse response)
            throws IOException, SQLException {
        String storedName = roomDAO.findStagedMediaPath(applicationId, user.getId(), mediaId);
        if (storedName == null) {
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "Media was not found.");
            return;
        }
        PartnerDocumentStorage.writeMediaResponse(storedName, response);
    }

    /** Removes an owned staged-media record and deletes its file when no longer referenced. */
    private void deleteStagedMedia(HttpServletResponse response, User user, int applicationId,
                                   String clientRoomKey, int mediaId)
            throws IOException, SQLException {
        String storedName = roomDAO.deleteStagedMedia(
                applicationId, user.getId(), clientRoomKey, mediaId);
        if (storedName == null) {
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "Media was not found.");
            return;
        }
        deleteStoredFile(storedName);
        PartnerApiJson.write(response, HttpServletResponse.SC_OK,
                Map.of("deleted", true, "mediaId", mediaId));
    }

    private Map<String, Object> stagedMediaJson(PartnerApplicationMedia media,
                                                 HttpServletRequest request) {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("id", media.getId());
        result.put("clientRoomKey", media.getClientRoomKey());
        result.put("mediaType", media.getMediaType());
        result.put("contentType", media.getContentType());
        result.put("sortOrder", media.getSortOrder());
        result.put("staged", true);
        result.put("url", request.getContextPath() + "/api/partner-applications/"
                + media.getApplicationId() + "/media/" + media.getId());
        return result;
    }

    /** Streams a room image after confirming the room belongs to the caller's application. */
    private void sendOwnRoomImage(User user, String rawApplicationId, String rawRoomId,
                                  String rawImageId, HttpServletResponse response)
            throws IOException, SQLException {
        int applicationId = parseId(rawApplicationId);
        int roomId = parseId(rawRoomId);
        int imageId = parseId(rawImageId);
        PartnerApplicationRoom room = roomDAO.findByIdForOwner(roomId, user.getId());
        if (room == null || room.getApplicationId() != applicationId) {
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "Room was not found.");
            return;
        }
        String storedName = roomDAO.findImagePath(roomId, imageId, user.getId());
        if (storedName == null) {
            writeError(response, HttpServletResponse.SC_NOT_FOUND, "Image was not found.");
            return;
        }
        PartnerDocumentStorage.writeMediaResponse(storedName, response);
    }

    /** Deletes an owned room-image record and removes the file when it is unused. */
    private void deleteRoomImage(HttpServletRequest request, HttpServletResponse response,
                                 User user, int applicationId, int roomId, int imageId)
            throws IOException, SQLException {
        String storedName = roomDAO.deleteImage(applicationId, user.getId(), roomId, imageId);
        if (storedName == null) {
            writeError(response, HttpServletResponse.SC_CONFLICT,
                    "The room image could not be removed.");
            return;
        }
        deleteStoredFile(storedName);
        PartnerApiJson.write(response, HttpServletResponse.SC_OK,
                Map.of("deleted", true, "imageId", imageId));
    }

    /** Deletes a file only when no database record still refers to it. */
    private void deleteStoredFile(String storedName) {
        try {
            if (!roomDAO.isStoredNameInUse(storedName)) {
                PartnerDocumentStorage.delete(storedName);
            }
        } catch (IOException | SQLException e) {
            LOGGER.log(Level.WARNING, "An unreferenced partner upload could not be removed.", e);
        }
    }

    private void setString(HttpServletRequest request, String name,
                           java.util.function.Consumer<String> setter) {
        if (hasParameter(request, name)) {
            String value = request.getParameter(name);
            setter.accept(value == null || value.isBlank() ? null : value.trim());
        }
    }

    /** Checks ownership and permits editing only draft or rejected applications. */
    private boolean isOwnedEditableApplication(HostApplication application, User user) {
        return application != null && application.getUserId() == user.getId()
                && (application.getStatus() == HostApplication.Status.DRAFT
                || application.getStatus() == HostApplication.Status.REJECTED);
    }

    /** Consumes a one-time mutation token and writes an error when it is invalid. */
    private boolean requireCsrf(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (LoginUtil.consumeCsrfToken(request, request.getParameter("csrfToken"))) {
            return true;
        }
        writeError(response, HttpServletResponse.SC_FORBIDDEN,
                "CSRF token is missing, expired, or invalid. Fetch a fresh token and retry.");
        return false;
    }

    /** Reloads the active user and confirms that its role is allowed for this route. */
    private User requireUser(HttpServletRequest request, HttpServletResponse response,
                             String... allowedRoles) throws IOException, SQLException {
        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("userId") instanceof Number)) {
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED, "Authentication is required.");
            return null;
        }
        User user = userDAO.findById(((Number) session.getAttribute("userId")).intValue()).orElse(null);
        if (user == null || !"ACTIVE".equals(user.getStatus())) {
            session.invalidate();
            writeError(response, HttpServletResponse.SC_UNAUTHORIZED,
                    "The account is unavailable. Please sign in again.");
            return null;
        }
        String roleName = user.getRole() == null ? "" : user.getRole().getName();
        for (String allowedRole : allowedRoles) {
            if (allowedRole.equals(roleName) || roleName.equals("ROLE_" + allowedRole) || allowedRole.equals("ROLE_" + roleName)) {
                session.setAttribute("role", roleName);
                return user;
            }
        }
        writeError(response, HttpServletResponse.SC_FORBIDDEN,
                "This endpoint is not available for your account role.");
        return null;
    }

    private boolean requireRole(User user, HttpServletResponse response, String role)
            throws IOException {
        if (user.getRole() != null && role.equals(user.getRole().getName())) {
            return true;
        }
        writeError(response, HttpServletResponse.SC_FORBIDDEN,
                "This endpoint is not available for your account role.");
        return false;
    }

    /** Splits the API path into non-empty resource segments. */
    private String[] pathParts(HttpServletRequest request) {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.isBlank() || "/".equals(pathInfo)) {
            return new String[0];
        }
        return java.util.Arrays.stream(pathInfo.split("/"))
                .filter(part -> !part.isBlank())
                .toArray(String[]::new);
    }

    /** Parses a positive application or room identifier from a path segment. */
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

    /** Parses an optional integer form value or reports a client-input error. */
    private Integer parseInteger(String value, String fieldName) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(fieldName + " must be an integer.");
        }
    }

    /** Parses an optional finite decimal value or reports a client-input error. */
    private Double parseDouble(String value, String fieldName) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            double number = Double.parseDouble(value.trim());
            if (!Double.isFinite(number)) {
                throw new NumberFormatException();
            }
            return number;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(fieldName + " must be a valid number.");
        }
    }

    private boolean hasParameter(HttpServletRequest request, String name) {
        return request.getParameterMap().containsKey(name);
    }

    /** Serializes an application map to the response using the requested status. */
    private void writeApplication(HttpServletResponse response, int status,
                                  HostApplication application, HttpServletRequest request)
            throws IOException, SQLException {
        PartnerApiJson.write(response, status, applicationJson(application, request));
    }

    /** Maps safe profile fields into the application API response. */
    private Map<String, Object> profileJson(User user) {
        Map<String, Object> profile = new LinkedHashMap<>();
        profile.put("fullName", user.getDisplayName() == null || user.getDisplayName().isBlank()
                ? user.getUsername() : user.getDisplayName());
        profile.put("email", user.getEmail());
        profile.put("phone", user.getPhone());
        return profile;
    }

    /** Maps an application and its rooms into the API response shape. */
    private Map<String, Object> applicationJson(HostApplication application,
                                                HttpServletRequest request) throws SQLException {
        Map<String, Object> body =
                PartnerApiJson.application(application, request.getContextPath(), false);
        body.put("rooms", roomJson(application.getId(), request));
        return body;
    }

    /** Loads and maps the rooms belonging to an application. */
    private List<Map<String, Object>> roomJson(int applicationId, HttpServletRequest request)
            throws SQLException {
        List<Map<String, Object>> rooms = new ArrayList<>();
        int userId = ((Number) request.getSession(false).getAttribute("userId")).intValue();
        for (PartnerApplicationRoom room : roomDAO.findByApplication(applicationId, userId)) {
            rooms.add(PartnerApiJson.room(room, request.getContextPath(), false));
        }
        return rooms;
    }

    /** Writes a JSON array of rooms with the requested response status. */
    private void writeRooms(HttpServletResponse response, HttpServletRequest request,
                            List<PartnerApplicationRoom> rooms) throws IOException {
        List<Map<String, Object>> body = new java.util.ArrayList<>();
        for (PartnerApplicationRoom room : rooms) {
            body.add(PartnerApiJson.room(room, request.getContextPath(), false));
        }
        PartnerApiJson.write(response, HttpServletResponse.SC_OK, body);
    }

    /** Writes a JSON error object with the supplied HTTP status. */
    private void writeError(HttpServletResponse response, int status, String message)
            throws IOException {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("message", message);
        PartnerApiJson.write(response, status, body);
    }

    /** Logs a database failure and returns a generic API error response. */
    private void writeFailure(HttpServletResponse response, SQLException exception)
            throws IOException {
        LOGGER.log(Level.SEVERE, "Partner application API database operation failed.", exception);
        writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "The database could not process this request. Check that MySQL is running and "
                        + "inspect the Tomcat Output/log for the exact SQL error. If it reports "
                        + "a missing table or column, run database/schema.sql against homestaybooking.");
    }

    /** Removes an obsolete document only after confirming it is no longer referenced. */
    private void deleteReplacedDocument(String storedPath) {
        if (storedPath == null || storedPath.isBlank()) {
            return;
        }
        try {
            if (!roomDAO.isStoredNameInUse(storedPath)) {
                PartnerDocumentStorage.delete(storedPath);
            }
        } catch (IOException | SQLException e) {
            LOGGER.log(Level.WARNING, "A replaced partner document could not be removed.", e);
        }
    }
}
