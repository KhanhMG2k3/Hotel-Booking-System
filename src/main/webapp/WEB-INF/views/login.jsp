<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đăng nhập Host - Sogo Homestay</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">

    <style>
        body {
            min-height: 100vh;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
            background: #f5f6f8;
            font-family: Arial, sans-serif;
        }

        .login-card {
            width: 100%;
            max-width: 440px;
            padding: 36px;
            background: #fff;
            border-radius: 14px;
            box-shadow: 0 8px 30px rgba(0, 0, 0, .08);
        }

        .login-card h1 {
            margin-bottom: 8px;
            font-size: 27px;
            font-weight: 700;
        }

        .login-description {
            margin-bottom: 26px;
            color: #6c757d;
        }

        .form-label {
            font-weight: 600;
        }

        .form-control {
            min-height: 46px;
        }

        .btn-login {
            width: 100%;
            min-height: 46px;
            margin-top: 8px;
            font-weight: 600;
        }

        .back-link {
            display: block;
            margin-top: 22px;
            text-align: center;
        }
    </style>
</head>

<body>
<div class="login-card">
    <h1>Sogo Homestay</h1>
    <p class="login-description">Đăng nhập dành cho Host</p>

    <c:if test="${not empty param.loggedOut}">
        <div class="alert alert-success" role="status">
            Bạn đã đăng xuất thành công.
        </div>
    </c:if>

    <c:if test="${not empty loginError}">
        <div class="alert alert-danger" role="alert">
            <c:out value="${loginError}"/>
        </div>
    </c:if>

    <form method="post"
          action="${pageContext.request.contextPath}/login">

        <input type="hidden" name="csrfToken"
               value="<c:out value='${sessionScope.csrfToken}'/>">

        <div class="mb-3">
            <label for="username" class="form-label">
                Tên đăng nhập
            </label>
            <input type="text"
                   id="username"
                   name="username"
                   class="form-control"
                   autocomplete="username"
                   maxlength="100"
                   required>
        </div>

        <div class="mb-3">
            <label for="password" class="form-label">
                Mật khẩu
            </label>
            <input type="password"
                   id="password"
                   name="password"
                   class="form-control"
                   autocomplete="current-password"
                   required>
        </div>

        <button type="submit" class="btn btn-primary btn-login">
            Đăng nhập
        </button>
    </form>

    <a class="back-link"
       href="${pageContext.request.contextPath}/home">
        Quay lại trang chủ
    </a>
</div>
</body>
</html>
