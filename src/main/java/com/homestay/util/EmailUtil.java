package com.homestay.util;

import com.homestay.context.AppConfig;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.internet.MimeUtility;

import java.nio.charset.StandardCharsets;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Utility for sending system emails such as password reset links.
 */
public final class EmailUtil {
    private static final Logger LOGGER = Logger.getLogger(EmailUtil.class.getName());

    static {
        System.setProperty("mail.mime.charset", StandardCharsets.UTF_8.name());
    }

    private EmailUtil() {
    }

    /**
     * Encodes email subject explicitly in UTF-8 Base64 format (RFC 2047) to avoid any platform charset issues.
     */
    private static String encodeSubject(String subject) {
        try {
            return MimeUtility.encodeText(subject, StandardCharsets.UTF_8.name(), "B");
        } catch (Exception e) {
            return subject;
        }
    }

    /**
     * Sends a password reset email to the specified user.
     * If SMTP is not configured, logs the reset URL to the server console for testing.
     * 
     * @param toEmail The recipient's email address
     * @param recipientName The recipient's display name
     * @param resetLink The complete password reset URL with token
     * @return true if successfully processed
     */
    public static boolean sendResetPasswordEmail(String toEmail, String recipientName, String resetLink) {
        // Step 1: Always log reset link to console for local testing and developer convenience
        LOGGER.info("================================================================================");
        LOGGER.info("📧 [PASSWORD RESET LINK] Sent to: " + toEmail);
        LOGGER.info("👉 URL: " + resetLink);
        LOGGER.info("================================================================================");

        // Step 2: Read SMTP configuration from properties
        String host = AppConfig.getProperty("mail.smtp.host", null);
        String port = AppConfig.getProperty("mail.smtp.port", "587");
        String username = AppConfig.getProperty("mail.smtp.username", null);
        String password = AppConfig.getProperty("mail.smtp.password", null);
        String from = AppConfig.getProperty("mail.from", "no-reply@sogohomestay.com");

        // Step 3: If SMTP credentials are missing, rely on the logged link in development mode
        if (host == null || host.isBlank() || username == null || username.isBlank() || password == null || password.isBlank()) {
            LOGGER.info("SMTP configuration is not set; reset link was logged to console.");
            return true;
        }

        // Step 4: Configure mail session properties
        Properties props = new Properties();
        props.put("mail.smtp.host", host.trim());
        props.put("mail.smtp.port", port.trim());
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        props.put("mail.smtp.ssl.trust", host.trim());
        props.put("mail.mime.charset", "UTF-8");
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");

        // Step 5: Send the HTML email message via Jakarta Mail
        try {
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(username.trim(), password.trim());
                }
            });

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from, "Sogo Homestay", StandardCharsets.UTF_8.name()));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            String encodedSubject = encodeSubject("Đặt lại mật khẩu - Sogo Homestay");
            message.setSubject(encodedSubject);
            message.setHeader("Subject", encodedSubject);

            String safeName = (recipientName != null && !recipientName.isBlank()) ? recipientName : "Quý khách";
            String htmlContent = "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;'>"
                    + "<h2 style='color: #f7a840; text-align: center;'>Sogo Homestay</h2>"
                    + "<p>Xin chào <strong>" + safeName + "</strong>,</p>"
                    + "<p>Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản liên kết với email này.</p>"
                    + "<p>Vui lòng nhấn vào nút bên dưới để tiến hành đổi mật khẩu mới (liên kết có hiệu lực trong <strong>15 phút</strong>):</p>"
                    + "<div style='text-align: center; margin: 30px 0;'>"
                    + "<a href='" + resetLink + "' style='background-color: #f7a840; color: #ffffff; padding: 12px 24px; text-decoration: none; border-radius: 4px; font-weight: bold; display: inline-block;'>Đặt lại mật khẩu</a>"
                    + "</div>"
                    + "<p style='color: #666; font-size: 13px;'>Nếu bạn không yêu cầu hành động này, vui lòng bỏ qua email này. Mật khẩu hiện tại của bạn vẫn an toàn.</p>"
                    + "<hr style='border: none; border-top: 1px solid #eee; margin: 20px 0;'/>"
                    + "<p style='color: #999; font-size: 12px; text-align: center;'>Sogo Homestay Booking System</p>"
                    + "</div>";

            message.setContent(htmlContent, "text/html; charset=UTF-8");
            message.setHeader("Content-Type", "text/html; charset=UTF-8");
            message.setHeader("Content-Transfer-Encoding", "8bit");
            Transport.send(message);
            LOGGER.info("Reset password email successfully sent to: " + toEmail);
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to send reset password email via SMTP to " + toEmail + ", fallback to console link.", e);
            return true; // Still return true as reset token was generated and logged
        }
    }

    /**
     * Sends a 2FA verification OTP email to the specified user.
     * If SMTP is not configured, logs the OTP code to the server console for testing.
     * 
     * @param toEmail The recipient's email address
     * @param recipientName The recipient's display name
     * @param otpCode The 6-digit OTP code
     * @return true if successfully processed
     */
    public static boolean sendOtpEmail(String toEmail, String recipientName, String otpCode) {
        // Step 1: Always log OTP to console for local testing and developer convenience
        LOGGER.info("================================================================================");
        LOGGER.info("🔐 [2FA EMAIL OTP] Sent to: " + toEmail);
        LOGGER.info("👉 OTP CODE: " + otpCode);
        LOGGER.info("================================================================================");

        // Step 2: Read SMTP configuration from properties
        String host = AppConfig.getProperty("mail.smtp.host", null);
        String port = AppConfig.getProperty("mail.smtp.port", "587");
        String username = AppConfig.getProperty("mail.smtp.username", null);
        String password = AppConfig.getProperty("mail.smtp.password", null);
        String from = AppConfig.getProperty("mail.from", "no-reply@sogohomestay.com");

        // Step 3: If SMTP credentials are missing, rely on the logged code in development mode
        if (host == null || host.isBlank() || username == null || username.isBlank() || password == null || password.isBlank()) {
            LOGGER.info("SMTP configuration is not set; 2FA OTP was logged to console.");
            return true;
        }

        // Step 4: Configure mail session properties
        Properties props = new Properties();
        props.put("mail.smtp.host", host.trim());
        props.put("mail.smtp.port", port.trim());
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        props.put("mail.smtp.ssl.trust", host.trim());
        props.put("mail.mime.charset", "UTF-8");
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");

        // Step 5: Send the HTML email message via Jakarta Mail
        try {
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(username.trim(), password.trim());
                }
            });

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from, "Sogo Homestay", StandardCharsets.UTF_8.name()));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            String encodedSubject = encodeSubject("Mã xác thực 2 bước (2FA) - Sogo Homestay");
            message.setSubject(encodedSubject);
            message.setHeader("Subject", encodedSubject);

            String safeName = (recipientName != null && !recipientName.isBlank()) ? recipientName : "Quý khách";
            String htmlContent = "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;'>"
                    + "<h2 style='color: #f7a840; text-align: center;'>Sogo Homestay</h2>"
                    + "<p>Xin chào <strong>" + safeName + "</strong>,</p>"
                    + "<p>Bạn đang thực hiện đăng nhập hoặc xác thực bảo mật cho tài khoản của mình.</p>"
                    + "<p>Dưới đây là mã xác thực 2 bước (OTP) của bạn (có hiệu lực trong <strong>5 phút</strong>):</p>"
                    + "<div style='text-align: center; margin: 30px 0;'>"
                    + "<div style='display: inline-block; background-color: #fff8ee; border: 2px dashed #f7a840; border-radius: 8px; padding: 16px 36px; font-size: 32px; font-weight: bold; letter-spacing: 8px; color: #f7a840;'>"
                    + otpCode
                    + "</div>"
                    + "</div>"
                    + "<p style='color: #666; font-size: 13px;'>Tuyệt đối không chia sẻ mã này với bất kỳ ai để bảo vệ tài khoản của bạn.</p>"
                    + "<hr style='border: none; border-top: 1px solid #eee; margin: 20px 0;'/>"
                    + "<p style='color: #999; font-size: 12px; text-align: center;'>Sogo Homestay Booking System</p>"
                    + "</div>";

            message.setContent(htmlContent, "text/html; charset=UTF-8");
            message.setHeader("Content-Type", "text/html; charset=UTF-8");
            message.setHeader("Content-Transfer-Encoding", "8bit");
            Transport.send(message);
            LOGGER.info("2FA OTP email successfully sent to: " + toEmail);
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to send 2FA OTP email via SMTP to " + toEmail + ", fallback to console OTP.", e);
            return true;
        }
    }

    /**
     * Sends a security alert email when sensitive security events happen (password changed, 2FA toggled).
     *
     * @param toEmail The recipient's email address
     * @param recipientName The recipient's display name
     * @param actionDescription Description of the security action performed
     * @return true if successfully processed
     */
    public static boolean sendSecurityAlertEmail(String toEmail, String recipientName, String actionDescription) {
        // Step 1: Always log security alert to console for local testing and audit
        LOGGER.info("================================================================================");
        LOGGER.info("🛡️ [SECURITY ALERT] Sent to: " + toEmail);
        LOGGER.info("👉 EVENT: " + actionDescription);
        LOGGER.info("================================================================================");

        // Step 2: Read SMTP configuration from properties
        String host = AppConfig.getProperty("mail.smtp.host", null);
        String port = AppConfig.getProperty("mail.smtp.port", "587");
        String username = AppConfig.getProperty("mail.smtp.username", null);
        String password = AppConfig.getProperty("mail.smtp.password", null);
        String from = AppConfig.getProperty("mail.from", "no-reply@sogohomestay.com");

        // Step 3: If SMTP credentials are missing, rely on the logged alert in development mode
        if (host == null || host.isBlank() || username == null || username.isBlank() || password == null || password.isBlank()) {
            LOGGER.info("SMTP configuration is not set; Security Alert was logged to console.");
            return true;
        }

        // Step 4: Configure mail session properties
        Properties props = new Properties();
        props.put("mail.smtp.host", host.trim());
        props.put("mail.smtp.port", port.trim());
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        props.put("mail.smtp.ssl.trust", host.trim());
        props.put("mail.mime.charset", "UTF-8");
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");

        // Step 5: Send the HTML email message via Jakarta Mail
        try {
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(username.trim(), password.trim());
                }
            });

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from, "Sogo Homestay Security", StandardCharsets.UTF_8.name()));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            String encodedSubject = encodeSubject("Cảnh báo bảo mật tài khoản - Sogo Homestay");
            message.setSubject(encodedSubject);
            message.setHeader("Subject", encodedSubject);

            String safeName = (recipientName != null && !recipientName.isBlank()) ? recipientName : "Quý khách";
            String currentTime = java.time.ZonedDateTime.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh"))
                    .format(java.time.format.DateTimeFormatter.ofPattern("HH:mm:ss dd/MM/yyyy"));

            String htmlContent = "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;'>"
                    + "<h2 style='color: #d9534f; text-align: center;'>🛡️ Cảnh báo bảo mật tài khoản</h2>"
                    + "<p>Xin chào <strong>" + safeName + "</strong>,</p>"
                    + "<p>Chúng tôi thông báo về một hoạt động bảo mật vừa được thực hiện trên tài khoản của bạn:</p>"
                    + "<div style='background-color: #f8f9fa; border-left: 4px solid #f7a840; padding: 15px; margin: 20px 0; border-radius: 4px;'>"
                    + "<p style='margin: 0; font-weight: bold; color: #333;'>" + actionDescription + "</p>"
                    + "<p style='margin: 8px 0 0 0; font-size: 13px; color: #777;'>Thời gian: " + currentTime + " (Giờ Việt Nam)</p>"
                    + "</div>"
                    + "<p style='color: #c9302c; font-size: 13px; font-weight: bold;'>Nếu bạn KHÔNG thực hiện thay đổi này, hãy ngay lập tức đặt lại mật khẩu của bạn hoặc liên hệ bộ phận hỗ trợ của chúng tôi để được bảo vệ tài khoản.</p>"
                    + "<hr style='border: none; border-top: 1px solid #eee; margin: 20px 0;'/>"
                    + "<p style='color: #999; font-size: 12px; text-align: center;'>Sogo Homestay Security Team</p>"
                    + "</div>";

            message.setContent(htmlContent, "text/html; charset=UTF-8");
            message.setHeader("Content-Type", "text/html; charset=UTF-8");
            message.setHeader("Content-Transfer-Encoding", "8bit");
            Transport.send(message);
            LOGGER.info("Security alert email successfully sent to: " + toEmail);
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to send security alert email via SMTP to " + toEmail + ", fallback to console log.", e);
            return true;
        }
    }
}
