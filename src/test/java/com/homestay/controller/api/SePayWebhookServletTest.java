package com.homestay.controller.api;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class SePayWebhookServletTest {

    private SePayWebhookServlet servlet;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private StringWriter stringWriter;

    @BeforeEach
    void setUp() throws Exception {
        servlet = new SePayWebhookServlet();
        servlet.init();

        request = Mockito.mock(HttpServletRequest.class);
        response = Mockito.mock(HttpServletResponse.class);
        stringWriter = new StringWriter();
        when(response.getWriter()).thenReturn(new PrintWriter(stringWriter));
    }

    @Test
    @DisplayName("doGet returns healthy service JSON")
    void testDoGetHealthCheck() throws Exception {
        servlet.doGet(request, response);

        String output = stringWriter.toString();
        assertTrue(output.contains("ACTIVE"), "Output should contain ACTIVE status");
        assertTrue(output.contains("SePay"), "Output should reference SePay");
    }

    @Test
    @DisplayName("doPost returns 400 when body is empty")
    void testDoPostEmptyBody() throws Exception {
        when(request.getReader()).thenReturn(new BufferedReader(new StringReader("")));

        servlet.doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        String output = stringWriter.toString();
        assertTrue(output.contains("Payload is empty"));
    }

    @Test
    @DisplayName("doPost ignores outgoing transfers (transferType=out)")
    void testDoPostIgnoresOutgoing() throws Exception {
        String json = """
                {
                    "gateway": "MBBank",
                    "transferType": "out",
                    "transferAmount": 500000,
                    "content": "Chuyen tien mua sam"
                }
                """;
        when(request.getReader()).thenReturn(new BufferedReader(new StringReader(json)));

        servlet.doPost(request, response);

        String output = stringWriter.toString();
        assertTrue(output.contains("Ignored outgoing transfer"));
    }

    @Test
    @DisplayName("doPost detects missing booking code in transaction content")
    void testDoPostMissingBookingCode() throws Exception {
        String json = """
                {
                    "gateway": "MBBank",
                    "transferType": "in",
                    "transferAmount": 500000,
                    "content": "Chuyen tien khong co ma don"
                }
                """;
        when(request.getReader()).thenReturn(new BufferedReader(new StringReader(json)));

        servlet.doPost(request, response);

        String output = stringWriter.toString();
        assertTrue(output.contains("Booking code not found"));
    }

    @Test
    @DisplayName("extractBookingCode handles code without hyphen like TPBank format")
    void testBookingCodeWithoutHyphen() throws Exception {
        String json = """
                {
                    "gateway": "TPBank",
                    "transferType": "in",
                    "transferAmount": 2000,
                    "content": "HOMESTAY BK898C39560561"
                }
                """;
        when(request.getReader()).thenReturn(new BufferedReader(new StringReader(json)));

        servlet.doPost(request, response);

        String output = stringWriter.toString();
        // It shouldn't complain "Booking code not found in transaction content"
        // It extracted BK-898C39560561 (may fail on DB since Mock is not attached, but not missing code)
        org.junit.jupiter.api.Assertions.assertFalse(
                output.contains("Booking code not found in transaction content"),
                "Should recognize BK898C39560561 even without hyphen"
        );
    }
}

