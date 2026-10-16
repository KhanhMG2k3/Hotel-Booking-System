<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Login flow: authenticate with account credentials or Google, with registration fallback. --%>
<%-- Shared page header and navigation. --%>
<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Đăng nhập - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<%-- Page content: credential form, Google sign-in, and authentication feedback. --%>
<section class="section">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-md-8 col-lg-6">
        <div class="text-center mb-4">
          <span class="text-primary font-weight-bold text-uppercase letter-spacing-1">Tài khoản</span>
          <h1 class="heading mt-2">Đăng nhập</h1>
        </div>

        <c:if test="${not empty messageError}">
          <div class="alert alert-danger" role="alert">
            <c:out value="${messageError}" />
          </div>
        </c:if>

        <c:if test="${not empty loginError}">
          <div class="alert alert-danger" role="alert">
            <c:out value="${loginError}" />
          </div>
        </c:if>

        <c:if test="${not empty param.loggedOut}">
          <div class="alert alert-success" role="status">
            Bạn đã đăng xuất thành công.
          </div>
        </c:if>

        <c:if test="${param.resetSuccess == '1'}">
          <div class="alert alert-success" role="alert">
            Mật khẩu của bạn đã được cập nhật thành công. Vui lòng đăng nhập bằng mật khẩu mới.
          </div>
        </c:if>

        <c:if test="${param.passwordChanged == '1'}">
          <div class="alert alert-success" role="alert">
            Mật khẩu đã được thay đổi thành công. Vì lý do bảo mật, vui lòng đăng nhập lại bằng mật khẩu mới.
          </div>
        </c:if>

        <%-- Submit account credentials. --%>
        <form action="${pageContext.request.contextPath}/login" method="post">
          <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">
          <div class="form-group">
            <label for="loginIdentifier">Email hoặc tên đăng nhập</label>
            <input type="text" id="loginIdentifier" name="loginIdentifier" class="form-control"
                   maxlength="100" autocomplete="username" required
                   value="<c:out value='${loginIdentifier}' />">
            <small class="form-text text-muted">
              Nhập email hoặc tên đăng nhập bạn đã dùng khi đăng ký.
            </small>
          </div>

          <div class="form-group">
            <div class="d-flex justify-content-between align-items-center mb-2">
              <label for="password" class="mb-0">Mật khẩu</label>
              <a href="${pageContext.request.contextPath}/forgot-password" class="small text-primary">Quên mật khẩu?</a>
            </div>
            <div class="password-input-wrap">
              <input type="password" id="password" name="password" class="form-control"
                     maxlength="128" autocomplete="current-password" required>
              <button type="button" class="btn-toggle-password" onclick="togglePasswordVisibility(this, event)" aria-label="Hiện mật khẩu" tabindex="-1">
                <svg class="icon-eye" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                  <circle cx="12" cy="12" r="3"></circle>
                </svg>
                <svg class="icon-eye-off" style="display:none;" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                  <line x1="1" y1="1" x2="23" y2="23"></line>
                </svg>
              </button>
            </div>
          </div>

          <button type="submit" class="btn btn-primary btn-block py-3 font-weight-bold">Đăng nhập</button>
        </form>

        <div class="text-center my-4">
          <span class="text-muted">Hoặc đăng nhập bằng</span>
        </div>

        <div id="googleLoginError" class="alert alert-danger d-none" role="alert"></div>
        <p class="text-muted text-center small">
          Nếu email Google đã có tài khoản, đăng nhập Google sẽ dùng chung tài khoản đó.
        </p>

        <%-- Render Google sign-in when configured, then provide its callback handling. --%>
        <c:choose>
          <c:when test="${not empty googleClientId}">
            <div id="g_id_onload"
                 data-client_id="<c:out value='${googleClientId}' />"
                 data-callback="handleGoogleCredential"
                 data-ux_mode="popup"
                 data-auto_prompt="false">
            </div>
            <div class="g_id_signin text-center d-flex justify-content-center"
                 data-type="standard"
                 data-size="large"
                 data-theme="outline"
                 data-text="signin_with"
                 data-shape="rectangular"
                 data-logo_alignment="left">
            </div>
            <script src="https://accounts.google.com/gsi/client" async defer></script>
          </c:when>
          <c:otherwise>
            <p class="text-muted text-center small">
              Đăng nhập Google chưa được cấu hình trên máy chủ.
            </p>
          </c:otherwise>
        </c:choose>

        <input type="hidden" id="googleCsrfToken" value="<c:out value='${csrfToken}' />">
        <script>
          async function handleGoogleCredential(googleResponse) {
            const errorBox = document.getElementById("googleLoginError");
            errorBox.classList.add("d-none");

            try {
              const response = await fetch("${pageContext.request.contextPath}/login/google", {
                method: "POST",
                credentials: "same-origin",
                headers: {
                  "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
                },
                body: new URLSearchParams({
                  credential: googleResponse.credential,
                  csrfToken: document.getElementById("googleCsrfToken").value
                })
              });
              const result = await response.json();

              if (!response.ok) {
                errorBox.textContent = result.message || "Đăng nhập Google thất bại.";
                errorBox.classList.remove("d-none");
                return;
              }

              window.location.assign(result.redirectUrl || "${pageContext.request.contextPath}/");
            } catch (error) {
              errorBox.textContent = "Không thể kết nối để đăng nhập Google. Vui lòng thử lại.";
              errorBox.classList.remove("d-none");
            }
          }
        </script>

        <%-- Link new users to account registration. --%>
        <p class="text-center mt-4">
          Chưa có tài khoản?
          <a href="${pageContext.request.contextPath}/register" class="font-weight-bold">Đăng ký ngay</a>
        </p>
      </div>
    </div>
  </div>
</section>

<%-- Shared page footer and scripts. --%>
<jsp:include page="common/footer.jsp" />
