<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Two-factor authentication (2FA) flow: verify 6-digit email OTP. --%>
<%-- Shared page header and navigation. --%>
<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Xác thực 2 bước - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<%-- Main content section: OTP input form and validation feedback. --%>
<section class="section">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-md-8 col-lg-5">
        <div class="text-center mb-4">
          <span class="text-primary font-weight-bold text-uppercase letter-spacing-1">Bảo mật tài khoản</span>
          <h1 class="heading mt-2">Xác thực 2 bước</h1>
          <p class="text-muted">
            Vui lòng nhập mã xác thực OTP (6 chữ số) đã được gửi đến email:
            <br>
            <strong class="text-dark"><c:out value="${maskedEmail}" /></strong>
          </p>
        </div>

        <%-- Error notification banner. --%>
        <c:if test="${not empty messageError}">
          <div class="alert alert-danger" role="alert">
            <c:out value="${messageError}" />
          </div>
        </c:if>

        <%-- Success notification banner. --%>
        <c:if test="${not empty messageSuccess}">
          <div class="alert alert-success" role="alert">
            <c:out value="${messageSuccess}" />
          </div>
        </c:if>

        <%-- Attempt warning banner if failed attempts exist. --%>
        <c:if test="${not empty remainingAttempts && remainingAttempts < 5}">
          <div class="alert alert-warning py-2 px-3 small d-flex align-items-center mb-3">
            <span class="mr-2" style="font-size: 1.2rem;">⚠️</span>
            <div>
              <strong>Lưu ý bảo mật:</strong> Bạn còn <strong><c:out value="${remainingAttempts}" />/5</strong> lần thử trước khi phiên xác thực bị hủy.
            </div>
          </div>
        </c:if>

        <div class="card border-0 shadow-sm p-4">
          <%-- OTP submission form. --%>
          <form id="verifyOtpForm" action="${pageContext.request.contextPath}/verify-otp" method="post">
            <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">

            <div class="form-group text-center mb-4">
              <label for="otpCode" class="font-weight-bold">Mã OTP (6 chữ số)</label>
              <input type="text" id="otpCode" name="otpCode" class="form-control form-control-lg text-center"
                     maxlength="6" minlength="6" pattern="[0-9]{6}" inputmode="numeric"
                     placeholder="······" required autofocus
                     style="font-size: 28px; letter-spacing: 8px; font-weight: 700; height: 60px;">
              <small class="form-text text-muted mt-2">
                Mã OTP có hiệu lực trong 5 phút. Vui lòng không chia sẻ mã cho bất kỳ ai.
              </small>
            </div>

            <button type="submit" id="submitOtpBtn" class="btn btn-primary btn-block py-3 font-weight-bold">
              Xác nhận đăng nhập
            </button>
          </form>

          <%-- Resend OTP code action with cooldown timer. --%>
          <div class="border-top pt-3 mt-4 text-center">
            <p class="text-muted small mb-2">Chưa nhận được mã OTP?</p>
            <form id="resendOtpForm" action="${pageContext.request.contextPath}/verify-otp" method="post" class="d-inline">
              <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">
              <input type="hidden" name="action" value="resend">
              <button type="submit" id="resendBtn" class="btn btn-outline-secondary btn-sm px-3"
                      <c:if test="${not empty cooldownSeconds && cooldownSeconds > 0}">disabled</c:if>>
                <c:choose>
                  <c:when test="${not empty cooldownSeconds && cooldownSeconds > 0}">
                    Gửi lại mã OTP (<span id="cooldownTimer"><c:out value="${cooldownSeconds}" /></span>s)
                  </c:when>
                  <c:otherwise>
                    Gửi lại mã OTP
                  </c:otherwise>
                </c:choose>
              </button>
            </form>
          </div>
        </div>

        <%-- Cancel / Return to login. --%>
        <div class="text-center mt-4">
          <p class="small text-muted">
            Đăng nhập bằng tài khoản khác?
            <a href="${pageContext.request.contextPath}/login">Quay lại đăng nhập</a>
          </p>
        </div>
      </div>
    </div>
  </div>
</section>

<%-- Client-side timer and input restrictions script. --%>
<script>
  document.addEventListener('DOMContentLoaded', function () {
    // Only allow numeric digits for OTP
    var otpInput = document.getElementById('otpCode');
    if (otpInput) {
      otpInput.addEventListener('input', function () {
        this.value = this.value.replace(/[^0-9]/g, '');
      });
    }

    // Cooldown countdown management
    var initialCooldown = parseInt('<c:out value="${cooldownSeconds != null ? cooldownSeconds : 0}" />', 10);
    var resendBtn = document.getElementById('resendBtn');
    var timerSpan = document.getElementById('cooldownTimer');

    if (initialCooldown > 0 && resendBtn && timerSpan) {
      var remaining = initialCooldown;
      resendBtn.disabled = true;

      var interval = setInterval(function () {
        remaining--;
        if (remaining > 0) {
          timerSpan.textContent = remaining;
        } else {
          clearInterval(interval);
          resendBtn.disabled = false;
          resendBtn.innerHTML = 'Gửi lại mã OTP';
        }
      }, 1000);
    }
  });
</script>

<%-- Shared page footer and scripts. --%>
<jsp:include page="common/footer.jsp" />
