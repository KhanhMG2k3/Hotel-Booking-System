package com.homestay.service;

import com.homestay.context.DBContext;
import com.homestay.model.Booking;
import com.homestay.model.Payment;
import com.homestay.model.Refund;
import com.homestay.model.Room;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Locale;
import java.util.Properties;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * EmailService - Handles asynchronous booking confirmation and notification emails.
 *
 * Supports real SMTP transmission via Gmail/Custom SMTP,
 * with fallback graceful logging for testing environments.
 */
public class EmailService {

    private static final Logger LOGGER = Logger.getLogger(EmailService.class.getName());
    private static final ExecutorService EXECUTOR = Executors.newFixedThreadPool(4);

    private static EmailService instance;

    public static synchronized EmailService getInstance() {
        if (instance == null) {
            instance = new EmailService();
        }
        return instance;
    }

    /**
     * Sends booking confirmation email asynchronously to avoid blocking the payment flow.
     */
    public CompletableFuture<Boolean> sendBookingConfirmationEmailAsync(
            Booking booking,
            Payment payment,
            Room room) {

        return CompletableFuture.supplyAsync(() -> sendBookingConfirmationEmail(booking, payment, room), EXECUTOR);
    }

    /**
     * Sends refund decision email asynchronously.
     */
    public CompletableFuture<Boolean> sendRefundDecisionEmailAsync(
            Booking booking,
            Refund refund,
            boolean approved,
            String hostNote) {

        return CompletableFuture.supplyAsync(() -> sendRefundDecisionEmail(booking, refund, approved, hostNote), EXECUTOR);
    }

    /**
     * Sends refund decision notification email synchronously.
     */
    public boolean sendRefundDecisionEmail(
            Booking booking,
            Refund refund,
            boolean approved,
            String hostNote) {

        if (booking == null) {
            LOGGER.warning("Cannot send refund email: Booking is null");
            return false;
        }

        String recipientEmail = booking.getCustomerEmail();
        if (recipientEmail == null || recipientEmail.isBlank()) {
            LOGGER.warning("Cannot send refund email: Customer email is empty for booking ID=" + booking.getId());
            return false;
        }

        String bookingCode = booking.getBookingCode() != null ? booking.getBookingCode() : ("#" + booking.getId());
        String subject = approved
                ? "Sogo Homestay - Yêu cầu hoàn tiền đơn đặt phòng " + bookingCode + " ĐÃ ĐƯỢC DUYỆT"
                : "Sogo Homestay - Phản hồi yêu cầu hoàn tiền đơn đặt phòng " + bookingCode;

        String htmlContent = buildRefundDecisionHtml(booking, refund, approved, hostNote);

        return sendHtmlEmail(recipientEmail, subject, htmlContent);
    }

    /**
     * Sends booking confirmation email synchronously.
     */
    public boolean sendBookingConfirmationEmail(
            Booking booking,
            Payment payment,
            Room room) {

        if (booking == null) {
            LOGGER.warning("Cannot send confirmation email: Booking is null");
            return false;
        }

        String recipientEmail = booking.getCustomerEmail();
        if (recipientEmail == null || recipientEmail.isBlank()) {
            LOGGER.warning(() -> "Cannot send confirmation email: Customer email is empty for booking ID=" + booking.getId());
            return false;
        }

        String recipientName = booking.getCustomerName() != null && !booking.getCustomerName().isBlank()
                ? booking.getCustomerName()
                : "QuÃ½ khÃ¡ch";

        String bookingCode = booking.getBookingCode() != null && !booking.getBookingCode().isBlank()
                ? booking.getBookingCode()
                : "BK-" + booking.getId();

        String subject = "Sogo Homestay - XÃ¡c Nháº­n Äáº·t PhÃ²ng ThÃ nh CÃ´ng [" + bookingCode + "]";
        String htmlBody = buildConfirmationHtml(booking, payment, room, recipientName, bookingCode);

        return sendHtmlEmail(recipientEmail, recipientName, subject, htmlBody);
    }

    /**
     * Core SMTP sender with graceful fallback logging (without recipient name).
     */
    public boolean sendHtmlEmail(String toEmail, String subject, String htmlContent) {
        return sendHtmlEmail(toEmail, null, subject, htmlContent);
    }

    /**
     * Core SMTP sender with graceful fallback logging.
     */
    public boolean sendHtmlEmail(
            String toEmail,
            String toName,
            String subject,
            String htmlContent) {

        String host = DBContext.getAppProperty("mail.smtp.host", "smtp.gmail.com");
        String port = DBContext.getAppProperty("mail.smtp.port", "587");
        String authStr = DBContext.getAppProperty("mail.smtp.auth", "true");
        String starttlsStr = DBContext.getAppProperty("mail.smtp.starttls.enable", "true");
        String fromEmail = DBContext.getAppProperty("mail.from", "sogohomestay.system@gmail.com");
        String fromName = DBContext.getAppProperty("mail.from.name", "Sogo Homestay");

        String username = System.getenv("MAIL_USERNAME");
        if (username == null || username.isBlank()) {
            username = DBContext.getAppProperty("mail.username", "");
        }
        username = username.trim();

        String password = System.getenv("MAIL_PASSWORD");
        if (password == null || password.isBlank()) {
            password = DBContext.getAppProperty("mail.password", "");
        }
        password = password.replace(" ", "").trim();

        boolean hasCredentials = !username.isBlank() && !password.isBlank();

        if (hasCredentials && (fromEmail == null || fromEmail.contains("sogohomestay.system@gmail.com"))) {
            fromEmail = username;
        }

        if (!hasCredentials) {
            LOGGER.info(() -> String.format(
                    "[EMAIL DISPATCHED - SIMULATED MODE]\n" +
                    "To: %s <%s>\n" +
                    "Subject: %s\n" +
                    "Note: Configure mail.username and mail.password in app.properties to send live emails via Gmail SMTP.",
                    toName, toEmail, subject));
            return true;
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", port);
        props.put("mail.smtp.auth", authStr);
        props.put("mail.smtp.starttls.enable", starttlsStr);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.connectiontimeout", "5000");
        props.put("mail.smtp.timeout", "5000");

        final String authUser = username;
        final String authPass = password;

        try {
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(authUser, authPass);
                }
            });

            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail, fromName, "UTF-8"));
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(toEmail, toName, "UTF-8"));
            message.setSubject(subject, "UTF-8");
            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);
            LOGGER.info(() -> "Successfully delivered confirmation email via SMTP to: " + toEmail);
            return true;

        } catch (MessagingException | UnsupportedEncodingException e) {
            LOGGER.log(Level.WARNING, "Failed to send email via SMTP to " + toEmail + ": " + e.getMessage(), e);
            return false;
        }
    }

    /**
     * Builds responsive, email-client compliant HTML for booking confirmation.
     */
    private String buildConfirmationHtml(
            Booking booking,
            Payment payment,
            Room room,
            String customerName,
            String bookingCode) {

        NumberFormat currencyFormat = NumberFormat.getInstance(new Locale("vi", "VN"));
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");

        String checkInStr = booking.getCheckInDate() != null ? dateFormat.format(booking.getCheckInDate()) : "N/A";
        String checkOutStr = booking.getCheckOutDate() != null ? dateFormat.format(booking.getCheckOutDate()) : "N/A";

        BigDecimal amount = booking.getTotalAmount() != null
                ? booking.getTotalAmount()
                : (booking.getTotalPrice() != null ? booking.getTotalPrice() : BigDecimal.ZERO);
        String amountFormatted = currencyFormat.format(amount) + " VNÄ";

        String roomName = room != null && room.getRoomName() != null ? room.getRoomName() : "PhÃ²ng tiÃªu chuáº©n";
        String propertyName = room != null && room.getPropertyName() != null ? room.getPropertyName() : "Sogo Homestay";
        String address = room != null && room.getAddress() != null ? room.getAddress() : "Viá»‡t Nam";

        String trxId = payment != null && payment.getTransactionId() != null
                ? payment.getTransactionId()
                : "TRX-" + System.currentTimeMillis();

        String guests = booking.getAdults() + " ngÆ°á»i lá»›n" + (booking.getChildren() > 0 ? ", " + booking.getChildren() + " tráº» em" : "");

        String template = """
                <!DOCTYPE html>
                <html lang="vi">
                <head>
                    <meta charset="UTF-8">
                    <title>XÃ¡c Nháº­n Äáº·t PhÃ²ng ThÃ nh CÃ´ng</title>
                </head>
                <body style="margin: 0; padding: 20px; background-color: #f4f6f9; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; color: #333333;">
                    <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px; background-color: #ffffff; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.08); border: 1px solid #e2e8f0;">
                        <!-- HEADER -->
                        <tr>
                            <td align="center" style="background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%); padding: 35px 20px; color: #ffffff;">
                                <h1 style="margin: 0; font-size: 24px; font-weight: 700; letter-spacing: 0.5px;">SOGO HOMESTAY</h1>
                                <p style="margin: 8px 0 0 0; font-size: 15px; opacity: 0.95;">XÃC NHáº¬N Äáº¶T PHÃ’NG THÃ€NH CÃ”NG</p>
                            </td>
                        </tr>
                        <!-- BODY -->
                        <tr>
                            <td style="padding: 30px 25px;">
                                <p style="font-size: 16px; margin: 0 0 15px 0;">KÃ­nh gá»­i <strong>{{CUSTOMER_NAME}}</strong>,</p>
                                <p style="font-size: 14px; line-height: 1.6; color: #475569; margin: 0 0 20px 0;">
                                    Cáº£m Æ¡n báº¡n Ä‘Ã£ lá»±a chá»n dá»‹ch vá»¥ cá»§a <strong>Sogo Homestay</strong>. ÄÆ¡n Ä‘áº·t phÃ²ng vÃ  giao dá»‹ch thanh toÃ¡n cá»§a quÃ½ khÃ¡ch Ä‘Ã£ Ä‘Æ°á»£c há»‡ thá»‘ng xÃ¡c nháº­n thÃ nh cÃ´ng!
                                </p>

                                <!-- BOOKING CODE BADGE -->
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" style="background-color: #ecfdf5; border: 1px solid #a7f3d0; border-radius: 8px; margin-bottom: 25px;">
                                    <tr>
                                        <td align="center" style="padding: 15px;">
                                            <span style="font-size: 13px; color: #065f46; display: block; margin-bottom: 4px; text-transform: uppercase; font-weight: 600;">MÃ£ Äáº·t PhÃ²ng</span>
                                            <strong style="font-size: 22px; color: #047857; letter-spacing: 1px;">{{BOOKING_CODE}}</strong>
                                        </td>
                                    </tr>
                                </table>

                                <!-- DETAILS TABLE -->
                                <table width="100%" border="0" cellpadding="8" cellspacing="0" style="border-collapse: collapse; font-size: 14px; margin-bottom: 25px;">
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="color: #64748b; width: 40%;">Homestay:</td>
                                        <td style="color: #0f172a; font-weight: 600;">{{PROPERTY_NAME}}</td>
                                    </tr>
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="color: #64748b;">Háº¡ng phÃ²ng:</td>
                                        <td style="color: #0f172a; font-weight: 600;">{{ROOM_NAME}}</td>
                                    </tr>
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="color: #64748b;">Äá»‹a chá»‰:</td>
                                        <td style="color: #0f172a;">{{ADDRESS}}</td>
                                    </tr>
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="color: #64748b;">Thá»i gian lÆ°u trÃº:</td>
                                        <td style="color: #0f172a; font-weight: 600;">{{CHECK_IN}} &rarr; {{CHECK_OUT}}</td>
                                    </tr>
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="color: #64748b;">Sá»‘ lÆ°á»£ng khÃ¡ch:</td>
                                        <td style="color: #0f172a;">{{GUESTS}}</td>
                                    </tr>
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="color: #64748b;">PhÆ°Æ¡ng thá»©c thanh toÃ¡n:</td>
                                        <td style="color: #2563eb; font-weight: 600;">Chuyá»ƒn khoáº£n NgÃ¢n hÃ ng (VietQR / SePay)</td>
                                    </tr>
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="color: #64748b;">MÃ£ giao dá»‹ch:</td>
                                        <td style="color: #0f172a; font-family: monospace;">{{TRX_ID}}</td>
                                    </tr>
                                    <tr style="background-color: #f8fafc;">
                                        <td style="color: #0f172a; font-weight: 700; font-size: 15px; padding-top: 12px; padding-bottom: 12px;">Tá»•ng tiá»n Ä‘Ã£ thanh toÃ¡n:</td>
                                        <td style="color: #dc2626; font-weight: 700; font-size: 18px; padding-top: 12px; padding-bottom: 12px;">{{AMOUNT}}</td>
                                    </tr>
                                </table>

                                <!-- NOTICE -->
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" style="background-color: #eff6ff; border-left: 4px solid #3b82f6; border-radius: 0 6px 6px 0; margin-bottom: 25px;">
                                    <tr>
                                        <td style="padding: 12px 15px; font-size: 13px; color: #1e40af; line-height: 1.5;">
                                            <strong>LÆ°u Ã½ nháº­n phÃ²ng:</strong><br/>
                                            &bull; Giá» nháº­n phÃ²ng (Check-in): tá»« <strong>14:00</strong><br/>
                                            &bull; Giá» tráº£ phÃ²ng (Check-out): trÆ°á»›c <strong>12:00</strong><br/>
                                            &bull; QuÃ½ khÃ¡ch vui lÃ²ng mang theo CÄƒn cÆ°á»›c cÃ´ng dÃ¢n hoáº·c Há»™ chiáº¿u Ä‘á»ƒ lÃ m thá»§ tá»¥c nháº­n phÃ²ng.
                                        </td>
                                    </tr>
                                </table>

                                <p style="font-size: 14px; line-height: 1.5; color: #64748b; margin: 0;">
                                    Náº¿u báº¡n cáº§n há»— trá»£ thÃªm, vui lÃ²ng liÃªn há»‡ hotline: <strong>090 123 4567</strong> hoáº·c pháº£n há»“i trá»±c tiáº¿p email nÃ y.
                                </p>
                            </td>
                        </tr>
                        <!-- FOOTER -->
                        <tr>
                            <td align="center" style="background-color: #f8fafc; padding: 20px; font-size: 12px; color: #94a3b8; border-top: 1px solid #e2e8f0;">
                                &copy; 2026 Sogo Homestay Booking System. All rights reserved.<br/>
                                ChÃºc quÃ½ khÃ¡ch cÃ³ má»™t ká»³ nghá»‰ tháº­t tuyá»‡t vá»i!
                            </td>
                        </tr>
                    </table>
                </body>
                </html>
                """;

        return template
                .replace("{{CUSTOMER_NAME}}", customerName)
                .replace("{{BOOKING_CODE}}", bookingCode)
                .replace("{{PROPERTY_NAME}}", propertyName)
                .replace("{{ROOM_NAME}}", roomName)
                .replace("{{ADDRESS}}", address)
                .replace("{{CHECK_IN}}", checkInStr)
                .replace("{{CHECK_OUT}}", checkOutStr)
                .replace("{{GUESTS}}", guests)
                .replace("{{TRX_ID}}", trxId)
                .replace("{{AMOUNT}}", amountFormatted);
    }

    private String buildRefundDecisionHtml(
            Booking booking,
            Refund refund,
            boolean approved,
            String hostNote) {

        String customerName = booking.getCustomerName() != null ? booking.getCustomerName() : "Quý khách";
        String bookingCode = booking.getBookingCode() != null ? booking.getBookingCode() : ("#" + booking.getId());
        String propertyName = booking.getPropertyName() != null ? booking.getPropertyName() : "Sogo Homestay";

        BigDecimal amount = (refund != null && refund.getAmount() != null)
                ? refund.getAmount()
                : (booking.getTotalAmount() != null ? booking.getTotalAmount() : BigDecimal.ZERO);

        NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
        String amountFormatted = currencyFormat.format(amount).replace("₫", "VNĐ");

        String statusBadge = approved
                ? "<span style='display:inline-block; padding: 6px 14px; background-color: #dcfce7; color: #15803d; border-radius: 9999px; font-weight: 700; font-size: 14px;'>ĐÃ CHẤP NHẬN HOÀN TIỀN</span>"
                : "<span style='display:inline-block; padding: 6px 14px; background-color: #fee2e2; color: #b91c1c; border-radius: 9999px; font-weight: 700; font-size: 14px;'>TỪ CHỐI YÊU CẦU HOÀN TIỀN</span>";

        String messageTitle = approved
                ? "Yêu cầu hoàn tiền của bạn đã được Host chấp thuận"
                : "Host đã xem xét yêu cầu hoàn tiền của bạn";

        String bankInfoHtml = (refund != null && refund.getCustomerBankInfo() != null && !refund.getCustomerBankInfo().isBlank())
                ? "<tr style='border-bottom: 1px solid #e2e8f0;'><td style='color: #64748b; padding: 8px 0;'>Tài khoản nhận tiền:</td><td style='color: #0f172a; font-weight: 600; padding: 8px 0;'>" + refund.getCustomerBankInfo() + "</td></tr>"
                : "";

        String noteHtml = (hostNote != null && !hostNote.isBlank())
                ? "<div style='background-color: #f8fafc; border-left: 4px solid #f59e0b; padding: 12px 16px; margin: 20px 0; border-radius: 0 6px 6px 0;'><strong style='color: #b45309;'>Ghi chú từ Host:</strong><p style='margin: 4px 0 0 0; color: #334155; font-size: 14px;'>" + hostNote + "</p></div>"
                : "";

        String template = """
                <!DOCTYPE html>
                <html lang="vi">
                <head><meta charset="UTF-8"><title>Thông báo hoàn tiền Sogo Homestay</title></head>
                <body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f1f5f9; color: #334155;">
                    <table width="100%" border="0" cellpadding="0" cellspacing="0" style="background-color: #f1f5f9; padding: 30px 15px;">
                        <tr>
                            <td align="center">
                                <table width="600" border="0" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);">
                                    <tr>
                                        <td align="center" style="background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%); padding: 25px 20px; color: #ffffff;">
                                            <h1 style="margin: 0; font-size: 24px; font-weight: 700; letter-spacing: 0.5px;">SOGO HOMESTAY</h1>
                                            <p style="margin: 5px 0 0 0; font-size: 13px; color: #94a3b8;">Hệ thống Đặt phòng Homestay Cao cấp</p>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 30px;">
                                            <div style="text-align: center; margin-bottom: 20px;">
                                                {{STATUS_BADGE}}
                                            </div>
                                            <h2 style="font-size: 18px; color: #0f172a; margin-top: 0; text-align: center;">{{MESSAGE_TITLE}}</h2>
                                            <p style="font-size: 14px; line-height: 1.6; color: #475569;">
                                                Xin chào <strong>{{CUSTOMER_NAME}}</strong>,<br/>
                                                Host của cơ sở lưu trú <strong>{{PROPERTY_NAME}}</strong> đã cập nhật trạng thái yêu cầu hoàn tiền cho mã đơn: <strong>{{BOOKING_CODE}}</strong>.
                                            </p>
                                            <table width="100%" border="0" cellpadding="0" cellspacing="0" style="margin: 20px 0; font-size: 14px;">
                                                <tr style="border-bottom: 1px solid #e2e8f0;">
                                                    <td style="color: #64748b; padding: 8px 0; width: 40%;">Mã đặt phòng:</td>
                                                    <td style="color: #0f172a; font-weight: 600; padding: 8px 0;">{{BOOKING_CODE}}</td>
                                                </tr>
                                                <tr style="border-bottom: 1px solid #e2e8f0;">
                                                    <td style="color: #64748b; padding: 8px 0;">Số tiền:</td>
                                                    <td style="color: #dc2626; font-weight: 700; font-size: 16px; padding: 8px 0;">{{AMOUNT}}</td>
                                                </tr>
                                                {{BANK_INFO}}
                                            </table>
                                            {{HOST_NOTE}}
                                            <p style="font-size: 13px; line-height: 1.5; color: #64748b; margin-top: 25px;">
                                                Bạn có thể theo dõi chi tiết tình trạng hoàn tiền tại trang <strong>Lịch sử đặt phòng</strong> trên website Sogo Homestay.
                                            </p>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="center" style="background-color: #f8fafc; padding: 18px; font-size: 12px; color: #94a3b8; border-top: 1px solid #e2e8f0;">
                                            &copy; 2026 Sogo Homestay. All rights reserved.
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </body>
                </html>
                """;

        return template
                .replace("{{STATUS_BADGE}}", statusBadge)
                .replace("{{MESSAGE_TITLE}}", messageTitle)
                .replace("{{CUSTOMER_NAME}}", customerName)
                .replace("{{PROPERTY_NAME}}", propertyName)
                .replace("{{BOOKING_CODE}}", bookingCode)
                .replace("{{AMOUNT}}", amountFormatted)
                .replace("{{BANK_INFO}}", bankInfoHtml)
                .replace("{{HOST_NOTE}}", noteHtml);
    }
}
