<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Reset password flow: user provides new credentials using verified token. --%>
<%-- Shared page header and navigation. --%>
<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Đặt lại mật khẩu - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<%-- Main content section: password update form or invalid token feedback. --%>
<section class="section">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-md-8 col-lg-6">
        <div class="text-center mb-4">
          <span class="text-primary font-weight-bold text-uppercase letter-spacing-1">Bảo mật</span>
          <h1 class="heading mt-2">Đặt lại mật khẩu</h1>
          <p class="text-muted">Nhập mật khẩu mới cho tài khoản của bạn.</p>
        </div>

        <%-- Error notification banner. --%>
        <c:if test="${not empty messageError}">
          <div class="alert alert-danger" role="alert">
            <c:out value="${messageError}" />
          </div>
        </c:if>

        <c:choose>
          <%-- Case 1: Token is invalid, expired, or already used. --%>
          <c:when test="${invalidToken}">
            <div class="text-center py-4">
              <p class="text-muted">
                Liên kết này không còn hiệu lực. Vui lòng gửi yêu cầu mới để nhận liên kết đặt lại mật khẩu.
              </p>
              <a href="${pageContext.request.contextPath}/forgot-password" class="btn btn-primary py-3 px-4">
                Yêu cầu liên kết mới
              </a>
            </div>
          </c:when>

          <%-- Case 2: Token is valid; display new password form. --%>
          <c:otherwise>
            <form action="${pageContext.request.contextPath}/reset-password" method="post">
              <input type="hidden" name="token" value="<c:out value='${token}' />">
              <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">

              <div class="form-group">
                <label for="password">Mật khẩu mới</label>
                <div class="password-input-wrap">
                  <input type="password" id="password" name="password" class="form-control"
                         minlength="8" maxlength="128" autocomplete="new-password" required>
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
                <small class="form-text text-muted mt-1">
                  Tối thiểu 8 ký tự, bao gồm ít nhất 1 chữ hoa, 1 chữ thường, 1 chữ số và 1 ký tự đặc biệt.
                </small>
              </div>

              <div class="form-group">
                <label for="confirmPassword">Xác nhận mật khẩu mới</label>
                <div class="password-input-wrap">
                  <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                         minlength="8" maxlength="128" autocomplete="new-password" required>
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

              <button type="submit" class="btn btn-primary btn-block py-3">Xác nhận đặt lại mật khẩu</button>
            </form>
          </c:otherwise>
        </c:choose>

        <%-- Navigation back to login. --%>
        <p class="text-center mt-4">
          Nhớ mật khẩu?
          <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
        </p>
      </div>
    </div>
  </div>
</section>

<%-- Shared page footer and scripts. --%>
<jsp:include page="common/footer.jsp" />
