package com.homestay.dao;

import com.homestay.model.Room;
import org.junit.jupiter.api.Test;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

public class RoomDAOTest {

    @Test
    public void testFindAllAndPagination() {
        RoomDAO roomDAO = new RoomDAO();
        List<Room> allRooms = roomDAO.findAll();
        assertNotNull(allRooms);
        assertTrue(allRooms.size() >= 18, "Database must have at least 18 seeded rooms");

        int totalCount = roomDAO.countRooms(null, null, null, null, null, null, null, null);
        assertTrue(totalCount >= 18, "Total count must be at least 18");

        List<Room> page1 = roomDAO.searchRooms(null, null, null, null, null, null, null, null, null, 0, 6);
        assertNotNull(page1);
        assertEquals(6, page1.size(), "Page 1 must contain 6 rooms");

        List<Room> page2 = roomDAO.searchRooms(null, null, null, null, null, null, null, null, null, 6, 6);
        assertNotNull(page2);
        assertEquals(6, page2.size(), "Page 2 must contain 6 rooms");

        List<Room> page3 = roomDAO.searchRooms(null, null, null, null, null, null, null, null, null, 12, 6);
        assertNotNull(page3);
        assertEquals(6, page3.size(), "Page 3 must contain 6 rooms");
    }
}
