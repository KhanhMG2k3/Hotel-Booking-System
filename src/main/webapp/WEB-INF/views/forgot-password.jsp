<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Forgot password flow: user requests a temporary reset link via email. --%>
<%-- Shared page header and navigation. --%>
<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Quên mật khẩu - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<%-- Main content section: email input form and status feedback. --%>
<section class="section">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-md-8 col-lg-6">
        <div class="text-center mb-4">
          <span class="text-primary font-weight-bold text-uppercase letter-spacing-1">Bảo mật</span>
          <h1 class="heading mt-2">Quên mật khẩu</h1>
          <p class="text-muted">Nhập địa chỉ email của bạn để nhận liên kết đặt lại mật khẩu qua thư điện tử.</p>
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

        <%-- Forgot password request form. --%>
        <form action="${pageContext.request.contextPath}/forgot-password" method="post">
          <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">

          <div class="form-group">
            <label for="email">Địa chỉ Email</label>
            <input type="email" id="email" name="email" class="form-control"
                   maxlength="254" autocomplete="email" required
                   placeholder="name@example.com"
                   value="<c:out value='${param.email}' />">
            <small class="form-text text-muted">
              Hệ thống sẽ gửi một liên kết an toàn có hiệu lực trong 15 phút.
            </small>
          </div>

          <button type="submit" class="btn btn-primary btn-block py-3">Gửi liên kết đặt lại mật khẩu</button>
        </form>

        <%-- Navigation back to login or registration. --%>
        <div class="text-center mt-4">
          <p class="mb-1">
            Nhớ mật khẩu?
            <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
          </p>
          <p>
            Chưa có tài khoản?
            <a href="${pageContext.request.contextPath}/register">Đăng ký</a>
          </p>
        </div>
      </div>
    </div>
  </div>
</section>

<%-- Shared page footer and scripts. --%>
<jsp:include page="common/footer.jsp" />
