package com.homestay.context;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/** Loads application settings used by backend services. */
public final class AppConfig {
    private static final Logger LOGGER = Logger.getLogger(AppConfig.class.getName());
    private static final String CONFIG_FILE = "app.properties";
    private static volatile Properties properties = loadProperties();

    private AppConfig() {
    }

    /** Returns the configured Google OAuth client ID, or {@code null} when disabled. */
    public static String getGoogleClientId() {
        // Step 1: Reload properties if empty
        if (properties == null || properties.isEmpty()) {
            properties = loadProperties();
        }
        // Step 2: Extract and return the client ID
        String clientId = properties.getProperty("google.client.id");
        return clientId == null || clientId.isBlank() ? null : clientId.trim();
    }

    /** Returns property value or defaultValue if not found. */
    public static String getProperty(String key, String defaultValue) {
        if (properties == null || properties.isEmpty() || !properties.containsKey(key)) {
            properties = loadProperties();
        }
        return properties.getProperty(key, defaultValue);
    }

    /** Loads application properties from the classpath and returns the settings. */
    private static Properties loadProperties() {
        Properties properties = new Properties();
        // Check primary classpath location, then fallback to resources package prefix
        InputStream input = AppConfig.class.getClassLoader().getResourceAsStream(CONFIG_FILE);
        if (input == null) {
            input = AppConfig.class.getClassLoader().getResourceAsStream("resources/" + CONFIG_FILE);
        }

        if (input == null) {
            LOGGER.warning("app.properties not found; Google sign-in is disabled.");
            return properties;
        }

        try (InputStream stream = input) {
            properties.load(stream);
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Unable to load app.properties.", e);
            throw new ExceptionInInitializerError(e);
        }
        return properties;
    }
}
