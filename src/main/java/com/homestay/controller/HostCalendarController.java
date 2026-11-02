package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.PropertyDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.Booking;
import com.homestay.model.CalendarDay;
import com.homestay.model.CalendarDay.RoomStatusItem;
import com.homestay.model.Property;
import com.homestay.model.Room;
import com.homestay.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Controller for the Host Booking Calendar.
 * Provides month-view visual schedule of booked vs. available dates per room and homestay.
 */
@WebServlet(name = "HostCalendarController", urlPatterns = {"/host/calendar"})
public class HostCalendarController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String VIEW = "/WEB-INF/views/host/calendar.jsp";

    private final UserDAO userDAO = new UserDAO();
    private final PropertyDAO propertyDAO = new PropertyDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("userId") instanceof Number)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int userId = ((Number) session.getAttribute("userId")).intValue();
            User user = userDAO.findById(userId).orElse(null);
            if (user == null || !"ACTIVE".equals(user.getStatus())) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            String roleName = user.getRole() != null ? user.getRole().getName() : "";
            if (!roleName.contains("HOST") || !propertyDAO.isApprovedHost(userId)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            request.setAttribute("hostName", user.getDisplayName() == null
                    || user.getDisplayName().isBlank() ? user.getUsername() : user.getDisplayName());

            // 1. Fetch properties owned by Host
            List<Property> properties = propertyDAO.findByOwnerId(userId);
            request.setAttribute("properties", properties);

            if (properties.isEmpty()) {
                request.setAttribute("activePage", "host-calendar");
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }

            // 2. Resolve selected property
            int propertyId = parseInt(request.getParameter("propertyId"), 0);
            Property selectedProperty = null;
            if (propertyId > 0) {
                for (Property p : properties) {
                    if (p.getId() == propertyId) {
                        selectedProperty = p;
                        break;
                    }
                }
            }
            if (selectedProperty == null) {
                selectedProperty = properties.get(0);
                propertyId = selectedProperty.getId();
            }
            request.setAttribute("selectedProperty", selectedProperty);
            request.setAttribute("propertyId", propertyId);

            // 3. Resolve selected room
            List<Room> rooms = selectedProperty.getRooms() != null ? selectedProperty.getRooms() : List.of();
            request.setAttribute("rooms", rooms);

            int roomId = parseInt(request.getParameter("roomId"), 0);
            Room selectedRoom = null;
            if (roomId > 0) {
                for (Room r : rooms) {
                    if (r.getId() == roomId) {
                        selectedRoom = r;
                        break;
                    }
                }
                if (selectedRoom == null) {
                    roomId = 0;
                }
            }
            request.setAttribute("selectedRoom", selectedRoom);
            request.setAttribute("roomId", roomId);

            // 4. Resolve Month and Year
            LocalDate today = LocalDate.now();
            int year = parseInt(request.getParameter("year"), today.getYear());
            int month = parseInt(request.getParameter("month"), today.getMonthValue());
            if (month < 1 || month > 12) {
                month = today.getMonthValue();
            }
            if (year < 2020 || year > 2050) {
                year = today.getYear();
            }

            YearMonth yearMonth = YearMonth.of(year, month);
            LocalDate startOfMonth = yearMonth.atDay(1);
            LocalDate endOfMonth = yearMonth.atEndOfMonth();
            int daysInMonth = yearMonth.lengthOfMonth();

            YearMonth prevYm = yearMonth.minusMonths(1);
            YearMonth nextYm = yearMonth.plusMonths(1);

            request.setAttribute("year", year);
            request.setAttribute("month", month);
            request.setAttribute("daysInMonth", daysInMonth);
            request.setAttribute("prevYear", prevYm.getYear());
            request.setAttribute("prevMonth", prevYm.getMonthValue());
            request.setAttribute("nextYear", nextYm.getYear());
            request.setAttribute("nextMonth", nextYm.getMonthValue());

            // 5. Fetch active bookings overlapping this month
            List<Booking> bookings = bookingDAO.findBookingsForCalendar(
                    userId, propertyId, roomId, startOfMonth, endOfMonth.plusDays(1));
            request.setAttribute("bookings", bookings);

            // 6. Build 7-column calendar matrix
            List<CalendarDay> calendarDays = new ArrayList<>();
            int firstDayOfWeek = startOfMonth.getDayOfWeek().getValue(); // 1 = Monday, 7 = Sunday
            int leadingPadding = firstDayOfWeek - 1;

            // Padding days from previous month
            for (int i = leadingPadding - 1; i >= 0; i--) {
                LocalDate padDate = startOfMonth.minusDays(i + 1);
                CalendarDay padDay = new CalendarDay(padDate, false);
                calendarDays.add(padDay);
            }

            // Current month days
            for (int dayNum = 1; dayNum <= daysInMonth; dayNum++) {
                LocalDate curDate = yearMonth.atDay(dayNum);
                CalendarDay day = new CalendarDay(curDate, true);

                if (selectedRoom != null) {
                    // Single room mode
                    Booking matched = null;
                    boolean isCheckIn = false;
                    boolean isCheckOut = false;

                    for (Booking b : bookings) {
                        if (b.getRoomId() == selectedRoom.getId()) {
                            LocalDate checkInDate = b.getCheckInDate() != null
                                    ? b.getCheckInDate().toLocalDate() : null;
                            LocalDate checkOutDate = b.getCheckOutDate() != null
                                    ? b.getCheckOutDate().toLocalDate() : null;

                            if (checkInDate != null && checkOutDate != null) {
                                if (!curDate.isBefore(checkInDate) && curDate.isBefore(checkOutDate)) {
                                    matched = b;
                                }
                                if (curDate.equals(checkInDate)) {
                                    isCheckIn = true;
                                }
                                if (curDate.equals(checkOutDate)) {
                                    isCheckOut = true;
                                }
                            }
                        }
                    }

                    if (matched != null) {
                        day.setBooked(true);
                        day.setAvailable(false);
                        day.setBooking(matched);
                        day.setCheckIn(isCheckIn);
                        day.setCheckOut(isCheckOut);
                    } else {
                        day.setBooked(false);
                        day.setAvailable(true);
                        day.setCheckIn(isCheckIn);
                        day.setCheckOut(isCheckOut);
                        day.setPrice(selectedRoom.getPricePerNight());
                    }
                } else {
                    // All rooms in property mode
                    int totalRooms = rooms.size();
                    int bookedRoomsCount = 0;
                    List<RoomStatusItem> statusList = new ArrayList<>();

                    for (Room r : rooms) {
                        Booking matched = null;
                        boolean isCheckIn = false;
                        boolean isCheckOut = false;

                        for (Booking b : bookings) {
                            if (b.getRoomId() == r.getId()) {
                                LocalDate checkInDate = b.getCheckInDate() != null
                                        ? b.getCheckInDate().toLocalDate() : null;
                                LocalDate checkOutDate = b.getCheckOutDate() != null
                                        ? b.getCheckOutDate().toLocalDate() : null;

                                if (checkInDate != null && checkOutDate != null) {
                                    if (!curDate.isBefore(checkInDate) && curDate.isBefore(checkOutDate)) {
                                        matched = b;
                                    }
                                    if (curDate.equals(checkInDate)) {
                                        isCheckIn = true;
                                    }
                                    if (curDate.equals(checkOutDate)) {
                                        isCheckOut = true;
                                    }
                                }
                            }
                        }

                        boolean isRoomBooked = (matched != null);
                        if (isRoomBooked) {
                            bookedRoomsCount++;
                        }
                        statusList.add(new RoomStatusItem(r, isRoomBooked, matched, isCheckIn, isCheckOut));
                    }

                    day.setTotalRooms(totalRooms);
                    day.setBookedRoomsCount(bookedRoomsCount);
                    day.setAvailableRoomsCount(Math.max(0, totalRooms - bookedRoomsCount));
                    day.setRoomStatuses(statusList);
                    day.setBooked(bookedRoomsCount > 0);
                    day.setAvailable(bookedRoomsCount < totalRooms);
                }

                calendarDays.add(day);
            }

            // Trailing padding days to fill 7-column rows
            int remainder = calendarDays.size() % 7;
            if (remainder != 0) {
                int trailingCount = 7 - remainder;
                for (int i = 1; i <= trailingCount; i++) {
                    LocalDate nextDate = endOfMonth.plusDays(i);
                    CalendarDay nextDay = new CalendarDay(nextDate, false);
                    calendarDays.add(nextDay);
                }
            }

            request.setAttribute("calendarDays", calendarDays);

            // 7. Calculate Monthly KPI Statistics
            int totalRoomsScope = selectedRoom != null ? 1 : Math.max(1, rooms.size());
            int totalRoomNightsInMonth = daysInMonth * totalRoomsScope;
            int bookedNightsCount = 0;
            BigDecimal estimatedRevenue = BigDecimal.ZERO;

            for (CalendarDay day : calendarDays) {
                if (day.isCurrentMonth()) {
                    if (selectedRoom != null) {
                        if (day.isBooked()) {
                            bookedNightsCount++;
                            if (selectedRoom.getPricePerNight() != null) {
                                estimatedRevenue = estimatedRevenue.add(selectedRoom.getPricePerNight());
                            }
                        }
                    } else {
                        bookedNightsCount += day.getBookedRoomsCount();
                        for (RoomStatusItem item : day.getRoomStatuses()) {
                            if (item.isBooked() && item.getRoom() != null && item.getRoom().getPricePerNight() != null) {
                                estimatedRevenue = estimatedRevenue.add(item.getRoom().getPricePerNight());
                            }
                        }
                    }
                }
            }

            int availableNightsCount = Math.max(0, totalRoomNightsInMonth - bookedNightsCount);
            int occupancyRate = totalRoomNightsInMonth > 0
                    ? (int) Math.round(((double) bookedNightsCount / totalRoomNightsInMonth) * 100) : 0;

            Set<Integer> distinctBookingIds = new HashSet<>();
            for (Booking b : bookings) {
                distinctBookingIds.add(b.getId());
            }

            request.setAttribute("totalRoomNightsInMonth", totalRoomNightsInMonth);
            request.setAttribute("bookedNightsCount", bookedNightsCount);
            request.setAttribute("availableNightsCount", availableNightsCount);
            request.setAttribute("occupancyRate", occupancyRate);
            request.setAttribute("estimatedRevenue", estimatedRevenue);
            request.setAttribute("totalBookingsCount", distinctBookingIds.size());
            request.setAttribute("activePage", "host-calendar");

            request.getRequestDispatcher(VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load the host booking calendar.", e);
        }
    }

    private int parseInt(String value, int defaultValue) {
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}

