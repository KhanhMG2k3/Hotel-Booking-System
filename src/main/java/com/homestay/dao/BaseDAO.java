package com.homestay.dao;

import com.homestay.context.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * BaseDAO - Abstract DAO class that provides standard JDBC lifecycle and resource cleanup.
 */
public abstract class BaseDAO {

    protected final Logger logger = Logger.getLogger(getClass().getName());

    /**
     * Gets a connection from DBContext.
     */
    protected Connection getConnection() throws SQLException {
        return DBContext.getConnection();
    }

    /**
     * Closes JDBC resources safely (AutoCloseable helper).
     */
    protected void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                logger.log(Level.WARNING, "Error closing ResultSet", e);
            }
        }
        if (ps != null) {
            try {
                ps.close();
            } catch (SQLException e) {
                logger.log(Level.WARNING, "Error closing PreparedStatement", e);
            }
        }
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                logger.log(Level.WARNING, "Error closing Connection", e);
            }
        }
    }
}
