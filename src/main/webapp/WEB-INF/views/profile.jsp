<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%-- Profile flow: update editable personal details and review account metadata. --%>
<%-- Shared page header and navigation. --%>
<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="My Profile - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<%-- Page content: save profile changes and display account details. --%>
<section class="section">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-md-10 col-lg-8">
        <div class="text-center mb-5">
          <span class="text-primary font-weight-bold text-uppercase letter-spacing-1">Customer account</span>
          <h1 class="heading mt-2">My Profile</h1>
          <p class="text-muted">View and update your account information.</p>
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

        <div class="card border-0 shadow-sm mb-4">
          <div class="card-body p-4 p-md-5">
            <h2 class="h4 mb-4">Personal information</h2>
            <%-- Submit editable profile fields. --%>
            <form action="${pageContext.request.contextPath}/profile" method="post">
              <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">

              <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" class="form-control"
                       maxlength="50" autocomplete="username" required
                       value="<c:out value='${profile.username}' />">
              </div>

              <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" class="form-control" readonly
                       value="<c:out value='${profile.email}' />">
                <small class="form-text text-muted">Email address cannot be changed here.</small>
              </div>

              <div class="form-group">
                <label for="phone">Phone number</label>
                <input type="tel" id="phone" name="phone" class="form-control"
                       maxlength="20" autocomplete="tel"
                       value="<c:out value='${profile.phone}' />">
                <small class="form-text text-muted">Optional. Leave blank if you do not want to add one.</small>
              </div>

              <div class="form-group border-top pt-3 mt-4">
                <label class="d-block font-weight-bold mb-2">Bảo mật hai lớp (2FA)</label>
                <div class="custom-control custom-switch">
                  <input type="checkbox" class="custom-control-input" id="twoFactorEnabled" name="twoFactorEnabled"
                         <c:if test="${profile.twoFactorEnabled}">checked</c:if>>
                  <label class="custom-control-label" for="twoFactorEnabled">
                    Kích hoạt xác thực 2 bước (Email OTP) khi đăng nhập
                  </label>
                </div>
                <small class="form-text text-muted">
                  Khi bật tính năng này, hệ thống sẽ gửi một mã OTP gồm 6 chữ số đến email của bạn mỗi lần đăng nhập.
                </small>
              </div>

              <button type="submit" class="btn btn-primary py-2 px-4">Save changes</button>
            </form>
          </div>
        </div>

        <%-- Change password card. --%>
        <div class="card border-0 shadow-sm mb-4">
          <div class="card-body p-4 p-md-5">
            <h2 class="h4 mb-3">Đổi mật khẩu</h2>
            <p class="text-muted small mb-4">
              Để bảo vệ tài khoản, hãy đảm bảo mật khẩu mới đủ mạnh và không chia sẻ cho bất kỳ ai.
            </p>

            <c:if test="${not empty messagePasswordSuccess}">
              <div class="alert alert-success" role="status">
                <c:out value="${messagePasswordSuccess}" />
              </div>
            </c:if>
            <c:if test="${not empty messagePasswordError}">
              <div class="alert alert-danger" role="alert">
                <c:out value="${messagePasswordError}" />
              </div>
            </c:if>

            <c:choose>
              <c:when test="${hasPassword}">
                <%-- Form to change password for accounts with local credentials. --%>
                <form id="changePasswordForm" action="${pageContext.request.contextPath}/profile" method="post">
                  <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">
                  <input type="hidden" name="action" value="changePassword">

                  <%-- Current password input. --%>
                  <div class="form-group">
                    <label for="currentPassword" class="font-weight-bold">Mật khẩu hiện tại <span class="text-danger">*</span></label>
                    <div class="input-group">
                      <input type="password" id="currentPassword" name="currentPassword" class="form-control"
                             autocomplete="current-password" required placeholder="Nhập mật khẩu đang sử dụng">
                      <div class="input-group-append">
                        <button type="button" class="btn btn-outline-secondary toggle-password" data-target="currentPassword" title="Ẩn/Hiện mật khẩu">
                          👁
                        </button>
                      </div>
                    </div>
                  </div>

                  <%-- New password input. --%>
                  <div class="form-group">
                    <label for="newPassword" class="font-weight-bold">Mật khẩu mới <span class="text-danger">*</span></label>
                    <div class="input-group">
                      <input type="password" id="newPassword" name="newPassword" class="form-control"
                             autocomplete="new-password" minlength="8" maxlength="128" required
                             placeholder="Tối thiểu 8 ký tự (hoa, thường, số, ký tự đặc biệt)">
                      <div class="input-group-append">
                        <button type="button" class="btn btn-outline-secondary toggle-password" data-target="newPassword" title="Ẩn/Hiện mật khẩu">
                          👁
                        </button>
                      </div>
                    </div>

                    <%-- Dynamic password requirement checklist. --%>
                    <div class="password-rules-box mt-3 p-3 bg-light rounded border">
                      <span class="d-block font-weight-bold small text-muted mb-2">Tiêu chuẩn mật khẩu mới:</span>
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

                  <%-- Confirm new password input. --%>
                  <div class="form-group">
                    <label for="confirmPassword" class="font-weight-bold">Xác nhận mật khẩu mới <span class="text-danger">*</span></label>
                    <div class="input-group">
                      <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                             autocomplete="new-password" minlength="8" maxlength="128" required
                             placeholder="Nhập lại mật khẩu mới">
                      <div class="input-group-append">
                        <button type="button" class="btn btn-outline-secondary toggle-password" data-target="confirmPassword" title="Ẩn/Hiện mật khẩu">
                          👁
                        </button>
                      </div>
                    </div>
                    <small id="confirmFeedback" class="form-text mt-1 d-none"></small>
                  </div>

                  <button type="submit" class="btn btn-warning text-dark font-weight-bold py-2 px-4 mt-2">
                    Lưu mật khẩu mới
                  </button>
                </form>
              </c:when>
              <c:otherwise>
                <%-- Account signed in exclusively via Google without local password. --%>
                <div class="alert alert-info mb-0">
                  <p class="mb-2 font-weight-bold">Tài khoản này đang đăng nhập bằng Google</p>
                  <p class="mb-0 small">
                    Bạn hiện chưa thiết lập mật khẩu cục bộ. Nếu muốn tạo mật khẩu để có thể đăng nhập trực tiếp bằng email,
                    vui lòng sử dụng chức năng
                    <a href="${pageContext.request.contextPath}/forgot-password" class="font-weight-bold text-dark text-underline">
                      Quên mật khẩu
                    </a> để hệ thống gửi liên kết thiết lập mật khẩu đến email của bạn.
                  </p>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
        </div>

        <%-- Read-only account type, status, sign-in method, and membership date. --%>
        <div class="card border-0 shadow-sm">
          <div class="card-body p-4">
            <h2 class="h5 mb-4">Account details</h2>
            <dl class="row mb-0">
              <dt class="col-sm-5">Account type</dt>
              <dd class="col-sm-7"><c:out value="${accountRole}" /></dd>

              <dt class="col-sm-5">Account status</dt>
              <dd class="col-sm-7"><c:out value="${profile.status}" /></dd>

              <dt class="col-sm-5">Sign-in method</dt>
              <dd class="col-sm-7"><c:out value="${loginMethod}" /></dd>

              <dt class="col-sm-5">Member since</dt>
              <dd class="col-sm-7">
                <fmt:formatDate value="${profile.createdAt}" pattern="dd MMM yyyy" />
              </dd>
            </dl>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

<%-- Client-side validation & toggle visibility scripts. --%>
<script>
  document.addEventListener('DOMContentLoaded', function () {
    // Toggle password visibility
    document.querySelectorAll('.toggle-password').forEach(function (button) {
      button.addEventListener('click', function () {
        var targetId = this.getAttribute('data-target');
        var input = document.getElementById(targetId);
        if (!input) return;
        if (input.type === 'password') {
          input.type = 'text';
          this.textContent = '🔒';
        } else {
          input.type = 'password';
          this.textContent = '👁';
        }
      });
    });

    // Dynamic password checklist via shared script
    initPasswordPolicy({
      passwordInputId: 'newPassword',
      confirmInputId: 'confirmPassword',
      usernameInputId: '<c:out value="${profile.username}" />',
      emailInputId: '<c:out value="${profile.email}" />',
      feedbackId: 'confirmFeedback'
    });
  });
</script>
<script src="${pageContext.request.contextPath}/assets/js/password-policy.js"></script>

<%-- Shared page footer and scripts. --%>
<jsp:include page="common/footer.jsp" />

