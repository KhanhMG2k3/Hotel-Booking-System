<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="com.homestay.context.DBContext" %>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng nhập | Sogo Homestay</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link
            href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Roboto:wght@400;500;700&display=swap"
            rel="stylesheet">
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/font-awesome.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/login.css">
    </head>

    <body>
        <div class="login-shell">
            <header class="login-header">
                <a class="brand" href="${pageContext.request.contextPath}/home">Sogo <span>Homestay</span></a>
                <nav class="header-nav" aria-label="Điều hướng chính">
                    <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
                    <a href="${pageContext.request.contextPath}/rooms">Khám phá phòng</a>
                    <a class="header-cta" href="${pageContext.request.contextPath}/home">Về trang chính</a>
                </nav>
            </header>

            <main class="login-main">
                <section class="login-card" aria-labelledby="login-title">
                    <div class="card-kicker">Sogo Homestay</div>
                    <h1 id="login-title">Chào mừng bạn trở lại</h1>
                    <p class="intro">Đăng nhập để tiếp tục hành trình nghỉ dưỡng và quản lý những đặt phòng của bạn.</p>

                    <div class="social-stack">
                        <!<!-- Start Code gg login  -->
                        <div id="g_id_onload"
                             data-client_id="<%= DBContext.getAppProperty("google.client.id", "") %>"        
                             data-callback="handleGoogleCredentialResponse">
                        </div>
                        <div class="social-button google" id="googleSignInBtn"></div>

                        <script src="https://accounts.google.com/gsi/client"async defer ></script>
                        <script>
                            window.onload = function () {
                                google.accounts.id.renderButton(
                                        document.getElementById("googleSignInBtn"),
                                        {theme: "outline", size: "large", width: "100%", text: "continue_with"}
                                );
                            };

                            function handleGoogleCredentialResponse(response) {
                                fetch('${pageContext.request.contextPath}/google-login', {
                                    method: 'POST',
                                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                                    body: 'credential=' + encodeURIComponent(response.credential)
                                }).then(() => {
                                    window.location.href = '${pageContext.request.contextPath}/home';
                                });
                            }
                        </script>
                        <!<!-- End Code gg login -->

                        <button class="social-button facebook" type="button"
                                onclick="alert('Đăng nhập Facebook đang được cập nhật.')"><i class="fa fa-facebook-square"
                                                                                     aria-hidden="true"></i> Đăng nhập bằng Facebook</button>
                    </div>

                    <div class="divider"><span>hoặc dùng tài khoản Sogo</span></div>

                    <% if (request.getAttribute("error") !=null) { %>
                    <p class="error-message" role="alert">
                        <%= request.getAttribute("error") %>
                    </p>
                    <% } %>

                    <form action="${pageContext.request.contextPath}/login" method="post">
                        <div class="field">
                            <label for="username">Tên đăng nhập hoặc email</label>
                            <input id="username" name="username" type="text" autocomplete="username"
                                   placeholder="Ví dụ: admin" required>
                        </div>
                        <div class="field">
                            <div class="password-row"><label for="password">Mật khẩu</label><a href="#"
                                                                                               onclick="return false;">Quên mật khẩu?</a></div>
                            <input id="password" name="password" type="password" autocomplete="current-password"
                                   placeholder="Nhập mật khẩu của bạn" required>
                        </div>
                        <button class="submit-button" type="submit">Đăng nhập</button>
                    </form>

                    <p class="register-note">Chưa có tài khoản? <a
                            href="${pageContext.request.contextPath}/register">Tạo tài khoản mới</a></p>
                    <p class="fine-print">Bằng việc tiếp tục, bạn đồng ý với điều khoản sử dụng và chính sách
                        bảo mật của Sogo.</p>
                </section>
            </main>
        </div>
    </body>

</html>