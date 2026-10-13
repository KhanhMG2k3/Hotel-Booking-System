<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng ký | Sogo Homestay</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link
            href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Roboto:wght@400;500;700&display=swap"
            rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/register.css">
    </head>

    <body>
        <div class="register-shell">
            <header class="register-header">
                <a class="brand" href="${pageContext.request.contextPath}/home">Sogo <span>Homestay</span></a>
                <a class="header-link" href="${pageContext.request.contextPath}/login">Đã có tài khoản? Đăng nhập</a>
            </header>

            <main class="register-main">
                <section class="register-card" aria-labelledby="register-title">
                    <div class="kicker">Sogo Homestay</div>
                    <h1 id="register-title">Tạo tài khoản mới</h1>
                    <p class="intro">Đăng ký để lưu những nơi bạn yêu thích và quản lý hành trình nghỉ dưỡng dễ dàng
                        hơn.</p>

                    <% if (request.getAttribute("error") !=null) { %>
                        <p class="error-message" role="alert">
                            <%= request.getAttribute("error") %>
                        </p>
                        <% } %>

                            <form action="${pageContext.request.contextPath}/register" method="post">
                                <div class="form-grid">
                                    <div class="field field-full">
                                        <label for="fullName">Họ và tên</label>
                                        <input id="fullName" name="fullName" type="text" autocomplete="name"
                                            placeholder="Nguyễn Văn A" required>
                                    </div>
                                    <div class="field">
                                        <label for="email">Email</label>
                                        <input id="email" name="email" type="email" autocomplete="email"
                                            placeholder="ban@example.com" required>
                                    </div>
                                    <div class="field">
                                        <label for="phone">Số điện thoại</label>
                                        <input id="phone" name="phone" type="tel" autocomplete="tel" inputmode="tel"
                                            placeholder="0901234567" maxlength="20" required>
                                    </div>
                                    <div class="field">
                                        <label for="password">Mật khẩu</label>
                                        <input id="password" name="password" type="password" autocomplete="new-password"
                                            placeholder="Tối thiểu 8 ký tự" minlength="8" required>
                                    </div>
                                    <div class="field">
                                        <label for="confirmPassword">Xác nhận mật khẩu</label>
                                        <input id="confirmPassword" name="confirmPassword" type="password"
                                            autocomplete="new-password" placeholder="Nhập lại mật khẩu" minlength="8"
                                            required>
                                    </div>
                                </div>
                                <p class="password-hint">Mật khẩu cần có ít nhất 8 ký tự.</p>
                                <button class="submit-button" type="submit">Tạo tài khoản</button>
                            </form>

                            <p class="login-note">Đã có tài khoản? <a
                                    href="${pageContext.request.contextPath}/login">Đăng nhập ngay</a></p>
                            <p class="fine-print">Bằng việc đăng ký, bạn đồng ý với điều khoản sử dụng và chính sách bảo
                                mật của Sogo.</p>
                </section>
            </main>
        </div>
    </body>

    </html>