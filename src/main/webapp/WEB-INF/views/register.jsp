<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Registration flow: collect account details and link existing users to sign in. --%>
<%-- Shared page header and navigation. --%>
<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Đăng ký tài khoản - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<%-- Page content: registration feedback and account creation form. --%>
<section class="section">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-md-8 col-lg-6">
        <div class="text-center mb-4">
          <span class="text-primary font-weight-bold text-uppercase letter-spacing-1">Tài khoản</span>
          <h1 class="heading mt-2">Đăng ký</h1>
          <p class="text-muted">Tạo tài khoản để bắt đầu trải nghiệm Sogo Homestay.</p>
        </div>

        <c:if test="${not empty messageSuccess}">
          <div class="alert alert-success" role="status">
            <c:out value="${messageSuccess}" />
          </div>
        </c:if>
        <c:if test="${not empty messageError}">
          <div class="alert alert-danger" role="alert">
            <c:out value="${messageError}" />
          </div>
        </c:if>

        <%-- Submit validated account details to the registration route. --%>
        <form action="${pageContext.request.contextPath}/register" method="post">
          <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">

          <div class="form-group">
            <label for="username">Tên đăng nhập</label>
            <input type="text" id="username" name="username" class="form-control"
                   maxlength="50" autocomplete="username" required
                   value="<c:out value='${username}' />">
          </div>

          <div class="form-group">
            <label for="phone">Số điện thoại</label>
            <input type="tel" id="phone" name="phone" class="form-control"
                   maxlength="20" autocomplete="tel" required
                   value="<c:out value='${phone}' />">
          </div>

          <div class="form-group">
            <label for="email">Email</label>
            <input type="email" id="email" name="email" class="form-control"
                   maxlength="100" autocomplete="email" required
                   value="<c:out value='${email}' />">
          </div>

          <div class="form-group">
            <label for="password">Mật khẩu <span class="text-danger">*</span></label>
            <div class="password-input-wrap">
              <input type="password" id="password" name="password" class="form-control"
                     minlength="8" maxlength="128" autocomplete="new-password" required
                     placeholder="Tối thiểu 8 ký tự (hoa, thường, số, ký tự đặc biệt)">
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

            <%-- Reusable password requirement checklist --%>
            <div class="password-rules-box mt-3 p-3 bg-light rounded border">
              <span class="d-block font-weight-bold small text-muted mb-2">Tiêu chuẩn mật khẩu:</span>
              <ul class="list-unstyled mb-0 small" id="pwdRuleList">
                <li id="rule-length" class="text-muted">
                  <span class="rule-icon mr-1">⚪</span> Từ 8 đến 128 ký tự (không chứa khoảng trắng)
                </li>
                <li id="rule-casing" class="text-muted">
                  <span class="rule-icon mr-1">⚪</span> Có ít nhất 1 chữ hoa (A-Z) và 1 chữ thường (a-z)
                </li>
                <li id="rule-number-special" class="text-muted">
                  <span class="rule-icon mr-1">⚪</span> Có ít nhất 1 chữ số (0-9) và 1 ký tự đặc biệt (!@#$%^&*...)
                </li>
                <li id="rule-not-user" class="text-muted">
                  <span class="rule-icon mr-1">⚪</span> Không chứa tên đăng nhập hoặc email
                </li>
              </ul>
            </div>
          </div>

          <div class="form-group">
            <label for="confirmPassword">Xác nhận mật khẩu <span class="text-danger">*</span></label>
            <div class="password-input-wrap">
              <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                     minlength="8" maxlength="128" autocomplete="new-password" required
                     placeholder="Nhập lại mật khẩu để xác nhận">
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
            <small id="confirmFeedback" class="form-text mt-1 d-none"></small>
          </div>

          <button type="submit" id="btnRegisterSubmit" class="btn btn-primary btn-block py-3">Tạo tài khoản</button>
        </form>
        <p class="text-center mt-4">
          Đã có tài khoản?
          <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
        </p>
      </div>
    </div>
  </div>
</section>

<script src="${pageContext.request.contextPath}/assets/js/password-policy.js"></script>
<script>
  document.addEventListener('DOMContentLoaded', function () {
    initPasswordPolicy({
      passwordInputId: 'password',
      confirmInputId: 'confirmPassword',
      usernameInputId: 'username',
      emailInputId: 'email',
      feedbackId: 'confirmFeedback'
    });
  });
</script>

<%-- Shared page footer and scripts. --%>
<jsp:include page="common/footer.jsp" />
