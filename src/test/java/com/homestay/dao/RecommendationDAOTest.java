package com.homestay.dao;

import com.homestay.model.Recommendation;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * RecommendationDAOTest - Unit and integration tests for AI-powered personalized recommendations.
 * Feature: Personalized Room Recommendations
 * Module: AI — Catalog & Discovery
 * Actor: Customer
 * UI / Component: "Recommended for You"
 */
public class RecommendationDAOTest {

    private RecommendationDAO recommendationDAO;

    @BeforeEach
    public void setUp() {
        recommendationDAO = new RecommendationDAO();
    }

    @Test
    public void testGetPopularRecommendationsForGuest() {
        // Guests (userId = null) should receive top rated popular recommendations
        List<Recommendation> recommendations = recommendationDAO.getPersonalizedRecommendations(null, 4);

        assertNotNull(recommendations, "Recommendations list should not be null for guest");
        assertFalse(recommendations.isEmpty(), "Should return at least one popular recommendation");
        assertTrue(recommendations.size() <= 4, "Should not exceed requested limit of 4");

        for (Recommendation rec : recommendations) {
            assertNotNull(rec.getRoom(), "Each recommendation must be populated with room details");
            assertNotNull(rec.getRecommendationType(), "Recommendation type must not be null");
            assertTrue(rec.getScore() > 0.0, "Score should be positive");
            assertTrue(rec.getMatchPercentage() >= 70 && rec.getMatchPercentage() <= 100,
                    "Match percentage should be in realistic range 70-100%");
            assertNotNull(rec.getReason(), "Reason must be provided");
            assertNotNull(rec.getTypeLabel(), "Type label should not be null");
            assertNotNull(rec.getTypeBadgeClass(), "Badge class should not be null");
            assertNotNull(rec.getTypeIcon(), "Type icon should not be null");
        }
    }

    @Test
    public void testGetPersonalizedRecommendationsForRegisteredUser() {
        // Test with registered user (e.g. userId = 2 who has bookings/wishlist seeded)
        List<Recommendation> recommendations = recommendationDAO.getPersonalizedRecommendations(2, 4);

        assertNotNull(recommendations, "Recommendations list should not be null for registered user");
        assertFalse(recommendations.isEmpty(), "Should return personalized recommendations");

        for (Recommendation rec : recommendations) {
            assertNotNull(rec.getRoom(), "Room details should be populated");
            assertTrue(rec.getRoom().getId() > 0, "Room ID must be valid");
            assertNotNull(rec.getRoom().getRoomName(), "Room name must be present");
            assertNotNull(rec.getReason(), "AI reason must explain why it's recommended");
        }
    }

    @Test
    public void testRecommendationModelHelpers() {
        Recommendation recBudget = new Recommendation(1, 10, "BUDGET_MATCH", 0.96, "Test reason budget");
        assertEquals(96, recBudget.getMatchPercentage());
        assertEquals("Phù hợp ngân sách", recBudget.getTypeLabel());
        assertEquals("badge-ai-budget", recBudget.getTypeBadgeClass());
        assertEquals("fa-money", recBudget.getTypeIcon());

        Recommendation recContent = new Recommendation(1, 11, "CONTENT_BASED", 0.93, "Test reason content");
        assertEquals(93, recContent.getMatchPercentage());
        assertEquals("Dựa trên sở thích", recContent.getTypeLabel());
        assertEquals("badge-ai-preference", recContent.getTypeBadgeClass());
        assertEquals("fa-compass", recContent.getTypeIcon());

        Recommendation recBehavior = new Recommendation(1, 12, "BEHAVIOR_BASED", 0.91, "Test reason behavior");
        assertEquals(91, recBehavior.getMatchPercentage());
        assertEquals("Tương tự đã xem", recBehavior.getTypeLabel());
        assertEquals("badge-ai-behavior", recBehavior.getTypeBadgeClass());
        assertEquals("fa-heart", recBehavior.getTypeIcon());

        Recommendation recPopular = new Recommendation(1, 13, "POPULAR", 0.98, "Test reason popular");
        assertEquals(98, recPopular.getMatchPercentage());
        assertEquals("Được yêu thích nhất", recPopular.getTypeLabel());
        assertEquals("badge-ai-popular", recPopular.getTypeBadgeClass());
        assertEquals("fa-fire", recPopular.getTypeIcon());
    }
}

