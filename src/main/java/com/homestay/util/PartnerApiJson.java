package com.homestay.util;

import com.homestay.model.HostApplication;
import com.homestay.model.PartnerApplicationRoom;
import com.homestay.model.PartnerApplicationRoom.RoomImage;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Builds API response maps and serializes them as JSON without external dependencies. */
public final class PartnerApiJson {
    private PartnerApiJson() {
    }

    /** Writes a no-cache JSON response with the supplied HTTP status and body. */
    public static void write(HttpServletResponse response, int status, Object body)
            throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");
        response.getWriter().write(toJson(body));
    }

    /** Maps application fields to the API response shape, including document links. */
    public static Map<String, Object> application(HostApplication application,
                                                   String contextPath,
                                                   boolean adminView) {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("id", application.getId());
        result.put("userId", application.getUserId());
        result.put("supersedesApplicationId", application.getSupersedesApplicationId());
        result.put("applicationNote", application.getApplicationNote());
        result.put("status", application.getStatus());
        result.put("submittedAt", application.getSubmittedAt());
        result.put("reviewedBy", application.getReviewedBy());
        result.put("reviewedAt", application.getReviewedAt());
        result.put("rejectionReason", application.getRejectionReason());
        result.put("applicantName", application.getApplicantName());
        result.put("applicantEmail", application.getApplicantEmail());
        result.put("applicantPhone", application.getApplicantPhone());
        result.put("identificationType", application.getIdentificationType());
        result.put("identificationNumber", application.getIdentificationNumber());
        result.put("propertyName", application.getPropertyName());
        result.put("propertyType", application.getPropertyType());
        result.put("propertyDescription", application.getPropertyDescription());
        result.put("propertyAddress", application.getPropertyAddress());
        result.put("propertyCity", application.getPropertyCity());
        result.put("propertyDistrict", application.getPropertyDistrict());
        result.put("propertyWard", application.getPropertyWard());
        result.put("latitude", application.getLatitude());
        result.put("longitude", application.getLongitude());
        result.put("roomCount", application.getRoomCount());
        result.put("maxGuests", application.getMaxGuests());
        result.put("documentStatus", application.getDocumentStatus());
        result.put("identityDocumentUrl", documentUrl(application.getIdentityDocumentUrl(),
                contextPath, application.getId(), "identity", adminView));
        result.put("ownershipDocumentUrl", documentUrl(application.getOwnershipDocumentUrl(),
                contextPath, application.getId(), "ownership", adminView));
        result.put("businessDocumentUrl", documentUrl(application.getBusinessDocumentUrl(),
                contextPath, application.getId(), "business", adminView));
        result.put("reviewerName", application.getReviewerName());
        return result;
    }

    /** Maps a room and its media links to the API response shape. */
    public static Map<String, Object> room(PartnerApplicationRoom room, String contextPath,
                                           boolean adminView) {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("id", room.getId());
        result.put("applicationId", room.getApplicationId());
        result.put("roomName", room.getRoomName());
        result.put("roomType", room.getRoomType());
        result.put("pricePerNight", room.getPricePerNight());
        result.put("maxGuests", room.getMaxGuests());
        result.put("bedCount", room.getBedCount());
        result.put("bathroomCount", room.getBathroomCount());
        result.put("sortOrder", room.getSortOrder());
        result.put("amenities", room.getAmenities());
        List<Map<String, Object>> images = new java.util.ArrayList<>();
        for (RoomImage image : room.getImages()) {
            Map<String, Object> imageResult = new LinkedHashMap<>();
            imageResult.put("id", image.getId());
            imageResult.put("mediaType", image.getMediaType());
            imageResult.put("contentType", image.getContentType());
            imageResult.put("sortOrder", image.getSortOrder());
            imageResult.put("url", contextPath + (adminView
                    ? "/api/admin/partner-applications/"
                    : "/api/partner-applications/") + room.getApplicationId()
                    + "/rooms/" + room.getId() + "/images/" + image.getId());
            images.add(imageResult);
        }
        result.put("images", images);
        return result;
    }

    private static String documentUrl(String storedPath, String contextPath,
                                      int applicationId, String documentType, boolean adminView) {
        String apiPath = adminView
                ? "/api/admin/partner-applications/"
                : "/api/partner-applications/";
        return storedPath == null || storedPath.isBlank()
                ? null : contextPath + apiPath + applicationId + "/documents/" + documentType;
    }

    /** Serializes supported scalar, map, and list values into JSON text. */
    private static String toJson(Object value) {
        if (value == null) {
            return "null";
        }
        if (value instanceof String || value instanceof Timestamp || value instanceof Enum<?>) {
            return quote(value instanceof Timestamp
                    ? ((Timestamp) value).toInstant().toString()
                    : value instanceof Enum<?> ? ((Enum<?>) value).name() : (String) value);
        }
        if (value instanceof Number || value instanceof Boolean) {
            return value.toString();
        }
        if (value instanceof Map<?, ?> map) {
            StringBuilder json = new StringBuilder("{");
            boolean first = true;
            for (Map.Entry<?, ?> entry : map.entrySet()) {
                if (!first) {
                    json.append(',');
                }
                first = false;
                json.append(quote(String.valueOf(entry.getKey())))
                        .append(':')
                        .append(toJson(entry.getValue()));
            }
            return json.append('}').toString();
        }
        if (value instanceof List<?> list) {
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < list.size(); i++) {
                if (i > 0) {
                    json.append(',');
                }
                json.append(toJson(list.get(i)));
            }
            return json.append(']').toString();
        }
        return quote(value.toString());
    }

    /** Escapes a Java string and wraps it as a valid JSON string literal. */
    private static String quote(String value) {
        StringBuilder escaped = new StringBuilder(value.length() + 2).append('"');
        for (int i = 0; i < value.length(); i++) {
            char character = value.charAt(i);
            switch (character) {
                case '"' -> escaped.append("\\\"");
                case '\\' -> escaped.append("\\\\");
                case '\b' -> escaped.append("\\b");
                case '\f' -> escaped.append("\\f");
                case '\n' -> escaped.append("\\n");
                case '\r' -> escaped.append("\\r");
                case '\t' -> escaped.append("\\t");
                default -> {
                    if (character < 0x20) {
                        escaped.append(String.format("\\u%04x", (int) character));
                    } else {
                        escaped.append(character);
                    }
                }
            }
        }
        return escaped.append('"').toString();
    }
}
