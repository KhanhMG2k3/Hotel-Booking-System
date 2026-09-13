<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Sogo Homestay - Đặt Phòng Trực Tuyến" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

    <section class="site-hero inner-page overlay" style="background-image: url(${pageContext.request.contextPath}/assets/images/hero_4.jpg)" data-stellar-background-ratio="0.5">
      <div class="container">
        <div class="row site-hero-inner justify-content-center align-items-center">
          <div class="col-md-10 text-center" data-aos="fade">
            <h1 class="heading mb-3">Đặt Phòng Trực Tuyến</h1>
            <ul class="custom-breadcrumbs mb-4">
              <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
              <li>&bullet;</li>
              <li><a href="${pageContext.request.contextPath}/rooms">Danh Sách Phòng</a></li>
              <li>&bullet;</li>
              <li>Đặt Phòng</li>
            </ul>
          </div>
        </div>
      </div>

      <a class="mouse smoothscroll" href="#next">
        <div class="mouse-icon">
          <span class="mouse-wheel"></span>
        </div>
      </a>
    </section>
    <!-- END section -->

    <section class="section contact-section" id="next">
      <div class="container">
        <div class="row">
          <div class="col-md-7" data-aos="fade-up" data-aos-delay="100">
            
            <c:if test="${not empty messageSuccess}">
              <div class="alert alert-success mb-4 shadow-sm" role="alert">
                <i class="fa fa-check-circle mr-2"></i> ${messageSuccess}
              </div>
            </c:if>

            <c:if test="${not empty messageError}">
              <div class="alert alert-danger mb-4 shadow-sm" role="alert">
                <i class="fa fa-exclamation-triangle mr-2"></i> ${messageError}
              </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/reservation" method="post" class="bg-white p-md-5 p-4 mb-5 border rounded shadow-sm">
              <h3 class="h4 font-weight-bold text-dark mb-4 border-bottom pb-2">Thông Tin Khách Hàng</h3>

              <div class="row">
                <div class="col-md-6 form-group">
                  <label class="text-black font-weight-bold" for="name">Họ và tên *</label>
                  <input type="text" id="name" name="name" class="form-control" required placeholder="Ví dụ: Nguyễn Văn A">
                </div>
                <div class="col-md-6 form-group">
                  <label class="text-black font-weight-bold" for="phone">Số điện thoại *</label>
                  <input type="text" id="phone" name="phone" class="form-control" required placeholder="Ví dụ: 0901234567">
                </div>
              </div>
          
              <div class="row">
                <div class="col-md-12 form-group">
                  <label class="text-black font-weight-bold" for="email">Địa chỉ Email *</label>
                  <input type="email" id="email" name="email" class="form-control" required placeholder="email@example.com">
                </div>
              </div>

              <h3 class="h4 font-weight-bold text-dark mt-4 mb-4 border-bottom pb-2">Thông Tin Phòng & Lịch Trình</h3>

              <div class="row">
                <div class="col-md-12 form-group">
                  <label class="text-black font-weight-bold" for="room_id">Chọn Phòng Homestay *</label>
                  <select name="room_id" id="room_id" class="form-control" required>
                    <c:forEach var="r" items="${rooms}">
                      <option value="${r.id}" ${r.id == selectedRoomId ? 'selected' : ''}>
                        ${r.roomName} (${r.roomType.typeName}) - <fmt:formatNumber value="${r.pricePerNight}" pattern="#,###" /> VNĐ/đêm
                      </option>
                    </c:forEach>
                  </select>
                </div>
              </div>

              <div class="row">
                <div class="col-md-6 form-group">
                  <label class="text-black font-weight-bold" for="checkin_date">Ngày nhận phòng *</label>
                  <input type="text" id="checkin_date" name="checkin_date" class="form-control" autocomplete="off" required placeholder="Chọn ngày đến">
                </div>
                <div class="col-md-6 form-group">
                  <label class="text-black font-weight-bold" for="checkout_date">Ngày trả phòng *</label>
                  <input type="text" id="checkout_date" name="checkout_date" class="form-control" autocomplete="off" required placeholder="Chọn ngày đi">
                </div>
              </div>

              <div class="row">
                <div class="col-md-6 form-group">
                  <label for="adults" class="font-weight-bold text-black">Người lớn</label>
                  <div class="field-icon-wrap">
                    <div class="icon"><span class="ion-ios-arrow-down"></span></div>
                    <select name="adults" id="adults" class="form-control">
                      <option value="1">1 người</option>
                      <option value="2">2 người</option>
                      <option value="3">3 người</option>
                      <option value="4">4+ người</option>
                    </select>
                  </div>
                </div>
                <div class="col-md-6 form-group">
                  <label for="children" class="font-weight-bold text-black">Trẻ em</label>
                  <div class="field-icon-wrap">
                    <div class="icon"><span class="ion-ios-arrow-down"></span></div>
                    <select name="children" id="children" class="form-control">
                      <option value="0">0 trẻ em</option>
                      <option value="1">1 trẻ em</option>
                      <option value="2">2 trẻ em</option>
                      <option value="3">3+ trẻ em</option>
                    </select>
                  </div>
                </div>
              </div>

              <div class="row mb-4">
                <div class="col-md-12 form-group">
                  <label class="text-black font-weight-bold" for="notes">Ghi chú thêm</label>
                  <textarea name="notes" id="notes" class="form-control" cols="30" rows="3" placeholder="Giờ check-in dự kiến, yêu cầu xe đưa đón hoặc các lưu ý đặc biệt..."></textarea>
                </div>
              </div>
              
              <div class="row">
                <div class="col-md-12 form-group">
                  <input type="submit" value="Xác Nhận Đặt Phòng (Thanh Toán Khi Check-in)" class="btn btn-primary btn-block text-white font-weight-bold py-3 shadow">
                </div>
              </div>
            </form>

          </div>
          <div class="col-md-5" data-aos="fade-up" data-aos-delay="200">
            <div class="bg-white p-4 rounded border shadow-sm mb-4">
              <h4 class="h5 font-weight-bold text-primary mb-3"><i class="fa fa-phone-square mr-2"></i> Liên Hệ Hỗ Trợ Trực Tiếp</h4>
              <p class="text-muted small mb-2"><span class="font-weight-bold text-dark">Địa chỉ:</span> 123 Đường Võ Nguyên Giáp, Sơn Trà, Đà Nẵng</p>
              <p class="text-muted small mb-2"><span class="font-weight-bold text-dark">Hotline / Zalo:</span> (+84) 090 123 4567</p>
              <p class="text-muted small mb-2"><span class="font-weight-bold text-dark">Email:</span> info@sogohomestay.com</p>
              <p class="text-muted small mb-0"><span class="font-weight-bold text-dark">Thời gian phục vụ:</span> 24/7 hàng ngày</p>
            </div>

            <div class="bg-light p-4 rounded border">
              <h5 class="font-weight-bold text-dark mb-2"><i class="fa fa-credit-card text-primary mr-2"></i> Phương Thức Thanh Toán</h5>
              <p class="text-muted small mb-0">Hỗ trợ chuyển khoản ngân hàng, quét mã QR VietQR hoặc thanh toán tiền mặt trực tiếp khi nhận phòng tại quầy lễ tân Homestay.</p>
            </div>
          </div>
        </div>
      </div>
    </section>

<jsp:include page="common/footer.jsp" />
