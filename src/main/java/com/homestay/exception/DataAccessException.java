package com.homestay.exception;

/**
 * DataAccessException - Unchecked exception thrown by DAO and Data Access operations
 * to ensure database failures are propagated clearly and never mistaken for empty results or success.
 */
public class DataAccessException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public DataAccessException(String message) {
        super(message);
    }

    public DataAccessException(String message, Throwable cause) {
        super(message, cause);
    }
}
