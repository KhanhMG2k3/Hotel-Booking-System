<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="common/header.jsp">
    <jsp:param name="pageTitle" value="Liên Hệ & Hỗ Trợ - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<section class="site-hero inner-page overlay" style="background-image: linear-gradient(rgba(0, 0, 0, 0.55), rgba(0, 0, 0, 0.65)), url('${pageContext.request.contextPath}/assets/images/hero_4.jpg');" data-stellar-background-ratio="0.5">
  <div class="container">
    <div class="row site-hero-inner justify-content-center align-items-center">
      <div class="col-md-10 text-center" data-aos="fade">
        <h1 class="heading mb-3">Liên Hệ & Hỗ Trợ</h1>
        <ul class="custom-breadcrumbs mb-4">
          <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
          <li>&bullet;</li>
          <li>Liên Hệ</li>
        </ul>
      </div>
    </div>
  </div>
</section>

<section class="section contact-section bg-light" id="contact-info">
  <div class="container">
    <!-- KHỐI 1: THÔNG TIN LIÊN HỆ DOANH NGHIỆP CHÍNH THỨC -->
    <div class="row mb-5">
      <div class="col-md-4 mb-4" data-aos="fade-up">
        <div class="bg-white p-4 h-100 rounded shadow-sm border text-center contact-card">
          <div class="icon-wrap mb-3 text-primary"><span class="ion-ios-location h2"></span></div>
          <h5 class="font-weight-bold mb-2">Trung Tâm Điều Hành</h5>
          <p class="text-muted mb-0">123 Đường Ven Biển, TP. Du Lịch, Việt Nam</p>
          <small class="text-secondary">(Trụ sở Sogo Homestay)</small>
        </div>
      </div>
      <div class="col-md-4 mb-4" data-aos="fade-up" data-aos-delay="100">
        <div class="bg-white p-4 h-100 rounded shadow-sm border text-center contact-card">
          <div class="icon-wrap mb-3 text-primary"><span class="ion-ios-telephone h2"></span></div>
          <h5 class="font-weight-bold mb-2">Đường Dây Nóng (Hotline)</h5>
          <p class="text-dark font-weight-bold mb-0">(+84) 090 123 4567</p>
          <small class="text-muted">Hỗ trợ 24/7 mọi thắc mắc và cứu trợ lưu trú</small>
        </div>
      </div>
      <div class="col-md-4 mb-4" data-aos="fade-up" data-aos-delay="200">
        <div class="bg-white p-4 h-100 rounded shadow-sm border text-center contact-card">
          <div class="icon-wrap mb-3 text-primary"><span class="ion-ios-email h2"></span></div>
          <h5 class="font-weight-bold mb-2">Hộp Thư Điện Tử</h5>
          <p class="text-dark mb-0">support@sogohomestay.com</p>
          <small class="text-muted">info@sogohomestay.com</small>
        </div>
      </div>
    </div>

    <!-- KHỐI 2: FORM GỬI YÊU CẦU HOẶC LỜI NHẮC ĐĂNG NHẬP -->
    <div class="row justify-content-center">
      <div class="col-lg-9" data-aos="fade-up" data-aos-delay="250">
        <div class="bg-white p-4 p-md-5 rounded shadow-sm border">

          <c:choose>
            <%-- Trường hợp 1: KHÁCH VÃNG LAI (GUEST) CHƯA ĐĂNG NHẬP --%>
            <c:when test="${!isLoggedIn}">
              <div class="text-center py-4">
                <div class="mb-3 text-warning">
                  <i class="fa fa-lock fa-3x"></i>
                </div>
                <h4 class="font-weight-bold text-dark mb-3">Yêu Cầu Đăng Nhập Để Gửi Hỗ Trợ</h4>
                <p class="text-muted mx-auto mb-4" style="max-width: 620px;">
                  Để bảo vệ quyền riêng tư, theo dõi tiến độ xử lý và trao đổi hai chiều với Ban Quản Trị, 
                  bạn vui lòng đăng nhập vào tài khoản Khách hàng hoặc Chủ nhà trước khi gửi yêu cầu.
                </p>
                <div class="d-flex justify-content-center flex-wrap gap-3">
                  <a href="${pageContext.request.contextPath}/login?redirect=/contact" class="btn btn-primary text-white font-weight-bold px-4 py-2 m-2 shadow-sm">
                    <i class="fa fa-sign-in mr-2"></i> Đăng Nhập Ngay
                  </a>
                  <a href="${pageContext.request.contextPath}/register" class="btn btn-outline-secondary font-weight-bold px-4 py-2 m-2">
                    <i class="fa fa-user-plus mr-2"></i> Đăng Ký Tài Khoản
                  </a>
                </div>
                <div class="mt-4 pt-3 border-top">
                  <span class="text-muted small">Cần giải đáp gấp? Bạn có thể xem nhanh tại trang </span>
                  <a href="${pageContext.request.contextPath}/faq" class="text-primary font-weight-bold small">Hỏi Đáp Thường Gặp (FAQ)</a>
                </div>
              </div>
            </c:when>

            <%-- Trường hợp 2: NGƯỜI DÙNG ĐÃ ĐĂNG NHẬP (CUSTOMER / HOST) --%>
            <c:otherwise>
              <div class="d-flex justify-content-between align-items-center flex-wrap border-bottom pb-3 mb-4">
                <div>
                  <h4 class="font-weight-bold text-dark mb-1">Gửi Yêu Cầu Hỗ Trợ</h4>
                  <p class="text-muted mb-0 small">Điền thông tin bên dưới để gửi phản ánh hoặc đề nghị trợ giúp đến Ban Quản Trị Sogo</p>
                </div>
                <div class="mt-2 mt-md-0">
                  <a href="${pageContext.request.contextPath}/support/my-tickets" class="btn btn-sm btn-outline-primary font-weight-bold">
                    <i class="fa fa-list mr-1"></i> Yêu Cầu Của Tôi
                  </a>
                </div>
              </div>

              <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                  <i class="fa fa-exclamation-circle mr-2"></i> <c:out value="${errorMessage}" />
                  <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                  </button>
                </div>
              </c:if>

              <form action="${pageContext.request.contextPath}/contact" method="post" id="supportContactForm">
                <%-- Token CSRF một lần để chống CSRF và chống submit lặp --%>
                <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">

                <!-- Thông tin người gửi (Lấy từ session tài khoản) -->
                <div class="row">
                  <div class="col-md-6 form-group">
                    <label class="font-weight-bold small text-muted">HỌ VÀ TÊN NGƯỜI GỬI</label>
                    <input type="text" class="form-control bg-light" value="<c:out value='${currentUser.fullName}' />" readonly>
                  </div>
                  <div class="col-md-6 form-group">
                    <label class="font-weight-bold small text-muted">EMAIL LIÊN HỆ</label>
                    <input type="email" class="form-control bg-light" value="<c:out value='${currentUser.email}' />" readonly>
                  </div>
                </div>

                <!-- Danh mục hỗ trợ & Đặt phòng liên quan -->
                <div class="row">
                  <div class="col-md-6 form-group">
                    <label for="category" class="font-weight-bold small">DANH MỤC HỖ TRỢ <span class="text-danger">*</span></label>
                    <select name="category" id="category" class="form-control custom-select" required>
                      <c:forEach items="${ticketCategories}" var="cat">
                        <option value="${cat.name()}" ${cat.name() == formCategory ? 'selected' : ''}>
                          ${cat.displayName}
                        </option>
                      </c:forEach>
                    </select>
                  </div>

                  <div class="col-md-6 form-group">
                    <label for="bookingId" class="font-weight-bold small">ĐẶT PHÒNG LIÊN QUAN <small class="text-muted">(Tùy chọn)</small></label>
                    <select name="bookingId" id="bookingId" class="form-control custom-select">
                      <option value="">-- Không gắn với đặt phòng cụ thể --</option>
                      <c:forEach items="${userBookings}" var="b">
                        <option value="${b.id}" ${b.id == formBookingId ? 'selected' : ''}>
                          Mã: <c:out value="${b.bookingCode != null ? b.bookingCode : b.id}" /> 
                          <c:if test="${not empty b.roomName}"> - <c:out value="${b.roomName}" /></c:if>
                          (${b.checkInDate} đến ${b.checkOutDate})
                        </option>
                      </c:forEach>
                    </select>
                    <small class="form-text text-muted">Chỉ hiển thị các đơn đặt phòng thuộc quyền sở hữu của bạn.</small>
                  </div>
                </div>

                <!-- Tiêu đề yêu cầu -->
                <div class="form-group">
                  <label for="subject" class="font-weight-bold small">TIÊU ĐỀ YÊU CẦU <span class="text-danger">*</span></label>
                  <input type="text" name="subject" id="subject" class="form-control" 
                         value="<c:out value='${formSubject}' />" 
                         placeholder="Tóm tắt ngắn gọn vấn đề cần hỗ trợ (từ 5 đến 150 ký tự)" 
                         minlength="5" maxlength="150" required>
                  <small class="form-text text-muted">Vui lòng nêu tóm tắt rõ ràng vấn đề để được điều phối xử lý nhanh nhất.</small>
                </div>

                <!-- Nội dung yêu cầu chi tiết -->
                <div class="form-group">
                  <label for="message" class="font-weight-bold small">NỘI DUNG CHI TIẾT <span class="text-danger">*</span></label>
                  <textarea name="message" id="message" rows="6" class="form-control" 
                            placeholder="Mô tả cụ thể nội dung cần hỗ trợ, các mốc thời gian hoặc câu hỏi phát sinh (từ 10 đến 3000 ký tự)..." 
                            minlength="10" maxlength="3000" required><c:out value='${formMessage}' /></textarea>
                  <div class="d-flex justify-content-between mt-1">
                    <small class="text-muted">Hỗ trợ định dạng plain text an toàn.</small>
                    <small id="charCounter" class="text-muted">0 / 3000 ký tự</small>
                  </div>
                </div>

                <div class="form-group mb-0 mt-4 text-right">
                  <button type="submit" id="btnSubmitTicket" class="btn btn-primary text-white font-weight-bold px-4 py-2 shadow-sm">
                    <i class="fa fa-paper-plane mr-1"></i> Gửi Yêu Cầu Hỗ Trợ
                  </button>
                </div>
              </form>
            </c:otherwise>
          </c:choose>

        </div>
      </div>
    </div>
  </div>
</section>

<script>
  document.addEventListener('DOMContentLoaded', function () {
    var messageInput = document.getElementById('message');
    var charCounter = document.getElementById('charCounter');
    var submitBtn = document.getElementById('btnSubmitTicket');
    var contactForm = document.getElementById('supportContactForm');

    if (messageInput && charCounter) {
      function updateCount() {
        var len = messageInput.value.length;
        charCounter.textContent = len + ' / 3000 ký tự';
        if (len > 3000) {
          charCounter.classList.add('text-danger');
        } else {
          charCounter.classList.remove('text-danger');
        }
      }
      messageInput.addEventListener('input', updateCount);
      updateCount();
    }

    if (contactForm && submitBtn) {
      contactForm.addEventListener('submit', function () {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fa fa-spinner fa-spin mr-1"></i> Đang gửi...';
      });
    }
  });
</script>

<jsp:include page="common/footer.jsp" />
