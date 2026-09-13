package com.homestay.context;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DBContext - Manages database connections using JDBC.
 * Implements Singleton pattern for properties loading and connection factory.
 */
public class DBContext {

    private static final Logger LOGGER = Logger.getLogger(DBContext.class.getName());
    private static final Properties properties = new Properties();

    static {
        try (InputStream input = DBContext.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (input != null) {
                properties.load(input);
                Class.forName(properties.getProperty("db.driver", "com.mysql.cj.jdbc.Driver"));
            } else {
                LOGGER.warning("db.properties not found, using default settings.");
                Class.forName("com.mysql.cj.jdbc.Driver");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to load database driver or properties", e);
        }
    }

    /**
     * Obtains a new database connection.
     * @return Connection object
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        String url = properties.getProperty("db.url", 
                "jdbc:mysql://localhost:3306/homestay_db?useSSL=false&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8");
        String user = properties.getProperty("db.user", "root");
        String pass = properties.getProperty("db.password", "");
        return DriverManager.getConnection(url, user, pass);
    }

    /**
     * Utility method to safely close a connection.
     * @param connection Connection to close
     */
    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error while closing connection", e);
            }
        }
    }
}
