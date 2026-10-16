package com.homestay.context;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DBContext - Manages database connections using JDBC. Implements Singleton
 * pattern for properties loading and connection factory.
 */
public class DBContext {

    private static final Logger LOGGER = Logger.getLogger(DBContext.class.getName());
    private static final Properties properties = new Properties();
    private static final Properties appProperties = new Properties();

    static {
        try (InputStream input = DBContext.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (input != null) {
                properties.load(input);
            } else {
                LOGGER.log(Level.WARNING, "db.properties not found in classpath");
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to load db.properties", e);
        }

        // Load application configuration
        try (InputStream input = DBContext.class.getClassLoader().getResourceAsStream("app.properties")) {
            if (input != null) {
                appProperties.load(input);
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to load app.properties", e);
        }
    }

    /**
     * Obtains a new database connection.
     *
     * @return Connection object
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        String url = properties.getProperty("db.url",
                "jdbc:mysql://localhost:3306/homestay_iter1_test?useSSL=false&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8");
        String user = properties.getProperty("db.user", "root");
        String pass = properties.getProperty("db.password", "");

        // Explicitly load MySQL JDBC Driver.
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "MySQL JDBC Driver not found in classpath", e);
            throw new SQLException("MySQL JDBC Driver not found. Check mysql-connector-j dependency.", e);
        }

        return DriverManager.getConnection(url, user, pass);
    }

    /**
     * Utility method to safely close a connection.
     *
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

    /**
     * Đọc một giá trị bất kỳ từ db.properties.
     *
     * @param key tên property
     * @param defaultValue giá trị mặc định nếu không tìm thấy key
     * @return giá trị cấu hình
     */
    public static String getProperty(String key, String defaultValue) {
        return properties.getProperty(key, defaultValue);
    }

    /**
     * Đọc một giá trị từ app.properties.
     *
     * @param key tên property
     * @param defaultValue giá trị mặc định nếu không tìm thấy key
     * @return giá trị cấu hình
     */
    public static String getAppProperty(String key, String defaultValue) {
        return appProperties.getProperty(key, defaultValue);
    }

    /**
     * Hàm test nhanh kết nối database.
     */
    public static void main(String[] args) {
        try (Connection conn = getConnection()) {
            System.out.println("✅ Kết nối DB thành công: " + !conn.isClosed());
            System.out.println("   URL: " + conn.getMetaData().getURL());
            System.out.println("   User: " + conn.getMetaData().getUserName());
        } catch (SQLException e) {
            System.out.println("❌ Kết nối DB thất bại:");
            e.printStackTrace();
        }
    }
}
