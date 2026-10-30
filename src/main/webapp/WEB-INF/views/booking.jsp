<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Sogo Homestay - Đặt Phòng Trực Tuyến 2 Bước" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<style>
  /* Completely hide and eliminate any bootstrap-datepicker popup overlay */
  .datepicker, .datepicker-dropdown, .datepicker-inline, .datepicker-orient-top, .datepicker-orient-bottom {
    display: none !important;
    visibility: hidden !important;
    opacity: 0 !important;
    pointer-events: none !important;
    z-index: -9999 !important;
  }

  /* Modern Wizard Stepper */
  .booking-stepper {
    display: flex;
    justify-content: space-between;
    position: relative;
    margin-bottom: 2.5rem;
    padding: 0 1rem;
  }
  .booking-stepper::before {
    content: '';
    position: absolute;
    top: 24px;
    left: 10%;
    right: 10%;
    height: 4px;
    background: #e9ecef;
    z-index: 1;
  }
  .booking-step-item {
    position: relative;
    z-index: 2;
    text-align: center;
    flex: 1;
  }
  .booking-step-circle {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    background: #fff;
    border: 3px solid #dee2e6;
    color: #6c757d;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 1.25rem;
    font-weight: 700;
    margin-bottom: 0.5rem;
    transition: all 0.3s ease;
    box-shadow: 0 4px 10px rgba(0,0,0,0.05);
  }
  .booking-step-item.active .booking-step-circle {
    border-color: #3b5998;
    background: linear-gradient(135deg, #3b5998 0%, #1d2124 100%);
    color: #fff;
    box-shadow: 0 6px 15px rgba(59, 89, 152, 0.3);
    transform: translateY(-2px);
  }
  .booking-step-item.completed .booking-step-circle {
    border-color: #28a745;
    background: #28a745;
    color: #fff;
  }
  .booking-step-label {
    font-size: 0.95rem;
    font-weight: 600;
    color: #6c757d;
  }
  .booking-step-item.active .booking-step-label {
    color: #1d2124;
    font-weight: 700;
  }

  /* Booking Card Enhancements */
  .booking-card {
    background: #ffffff;
    border-radius: 12px;
    border: 1px solid rgba(0, 0, 0, 0.08);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.04);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
  }
  .booking-card-header {
    background: #f8f9fa;
    border-bottom: 1px solid rgba(0, 0, 0, 0.06);
    padding: 1rem 1.25rem;
    border-top-left-radius: 12px;
    border-top-right-radius: 12px;
  }
  .booking-summary-sticky {
    position: sticky;
    top: 90px;
  }
  .room-selection-thumb {
    width: 100%;
    height: 180px;
    object-fit: cover;
    border-radius: 8px;
  }
  .badge-stay-limit {
    background-color: #e8f4fd;
    color: #0b72b9;
    border: 1px solid #bce1f8;
    font-size: 0.85rem;
  }
  .added-room-item {
    border-left: 4px solid #3b5998;
    background: #fafbfc;
  }
</style>

<!-- Hero Section -->
<section class="site-hero inner-page overlay hero-reservation" data-stellar-background-ratio="0.5">
  <div class="container">
    <div class="row site-hero-inner justify-content-center align-items-center">
      <div class="col-md-10 text-center" data-aos="fade">
        <h1 class="heading mb-3">Đặt Phòng Sogo Homestay</h1>
        <ul class="custom-breadcrumbs mb-4">
          <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
          <li>&bullet;</li>
          <li><a href="${pageContext.request.contextPath}/rooms">Danh Sách Phòng</a></li>
          <li>&bullet;</li>
          <li>Quy Trình Đặt Phòng</li>
        </ul>
      </div>
    </div>
  </div>
</section>

<!-- Main Booking Section -->
<section class="section bg-light py-5">
  <div class="container">

    <!-- Visual 3-Stage Progress Stepper -->
    <div class="row justify-content-center mb-4">
      <div class="col-lg-10">
        <div class="booking-stepper">
          <div class="booking-step-item ${step == '1' ? 'active' : (step == '2' || step == 'success' ? 'completed' : '')}">
            <div class="booking-step-circle">
              <c:choose>
                <c:when test="${step == '2' || step == 'success'}"><i class="fa fa-check"></i></c:when>
                <c:otherwise>1</c:otherwise>
              </c:choose>
            </div>
            <div class="booking-step-label">Bước 1: Chọn Phòng & Ngày</div>
          </div>
          <div class="booking-step-item ${step == '2' ? 'active' : (step == 'success' ? 'completed' : '')}">
            <div class="booking-step-circle">
              <c:choose>
                <c:when test="${step == 'success'}"><i class="fa fa-check"></i></c:when>
                <c:otherwise>2</c:otherwise>
              </c:choose>
            </div>
            <div class="booking-step-label">Bước 2: Xem Lại & Multi-Room</div>
          </div>
          <div class="booking-step-item ${step == 'success' ? 'active completed' : ''}">
            <div class="booking-step-circle">
              <i class="fa fa-flag-checkered"></i>
            </div>
            <div class="booking-step-label">Xác Nhận Thành Công</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Alert Notifications -->
    <c:if test="${not empty messageSuccess}">
      <div class="alert alert-success alert-dismissible fade show mb-4 shadow-sm" role="alert">
        <i class="fa fa-check-circle mr-2"></i> ${messageSuccess}
        <button type="button" class="close" data-dismiss="alert">&times;</button>
      </div>
    </c:if>

    <c:if test="${not empty messageError}">
      <div class="alert alert-danger alert-dismissible fade show mb-4 shadow-sm" role="alert">
        <i class="fa fa-exclamation-triangle mr-2"></i> ${messageError}
        <button type="button" class="close" data-dismiss="alert">&times;</button>
      </div>
    </c:if>

    <!-- =================================================================== -->
    <!-- STEP 1: Select Room & Dates (Validates Min/Max Stay & Availability) -->
    <!-- =================================================================== -->
    <c:if test="${step == '1'}">
      <div class="row">
        <div class="col-lg-8" data-aos="fade-up" data-aos-delay="100">
          <div class="booking-card mb-4 p-4 p-md-5">
            <h3 class="h4 font-weight-bold text-dark mb-4 border-bottom pb-3">
              <i class="fa fa-calendar-check-o text-primary mr-2"></i> Bước 1: Chọn Phòng & Lịch Trình Lưu Trú
            </h3>

            <div class="alert badge-stay-limit p-3 mb-4 rounded">
              <i class="fa fa-info-circle mr-2"></i>
              <strong>Chính sách lưu trú Sogo:</strong> Thời gian lưu trú tối thiểu <strong>${minStay} đêm</strong> và tối đa <strong>${maxStay} đêm</strong>.
            </div>

            <form action="${pageContext.request.contextPath}/booking" method="post" id="step1Form">
              <input type="hidden" name="action" value="step1_submit" />

              <!-- 1. Chọn phòng -->
              <div class="form-group mb-4">
                <label class="text-dark font-weight-bold" for="room_id">
                  <i class="fa fa-bed mr-1 text-muted"></i> Chọn Phòng Homestay *
                </label>
                <select name="room_id" id="room_id" class="form-control form-control-lg" required onchange="updateRoomPreview()">
                  <c:forEach var="r" items="${rooms}">
                    <option value="${r.id}"
                            data-name="${r.roomName}"
                            data-type="${r.roomTypeName}"
                            data-price="${r.pricePerNight}"
                            data-capacity="${r.capacity}"
                            data-image="${pageContext.request.contextPath}/${r.imageUrl}"
                            ${r.id == selectedRoomId ? 'selected' : ''}>
                      ${r.roomName} (${r.roomTypeName}) - <fmt:formatNumber value="${r.pricePerNight}" pattern="#,###" /> VNĐ/đêm (Tối đa ${r.capacity} khách)
                    </option>
                  </c:forEach>
                </select>
              </div>

              <!-- Preview phòng được chọn -->
              <div class="row align-items-center mb-4 p-3 bg-light rounded border">
                <div class="col-md-4">
                  <img src="${pageContext.request.contextPath}/images/img_1.jpg" id="previewRoomImg" class="room-selection-thumb" alt="Room preview" />
                </div>
                <div class="col-md-8">
                  <h5 id="previewRoomName" class="font-weight-bold text-dark mb-1">Tên phòng</h5>
                  <p class="text-muted small mb-2"><i class="fa fa-tag text-info mr-1"></i> <span id="previewRoomType">Loại phòng</span> &bull; <i class="fa fa-users text-primary mr-1"></i> Sức chứa tối đa: <strong id="previewRoomCapacity">2</strong> người</p>
                  <h4 class="text-primary font-weight-bold mb-0">
                    <span id="previewRoomPrice">0</span> VNĐ <small class="text-muted font-weight-normal">/ đêm</small>
                  </h4>
                </div>
              </div>

              <!-- 2. Chọn ngày đến và ngày đi -->
              <div class="row">
                <div class="col-md-6 form-group mb-4">
                  <label class="text-dark font-weight-bold" for="checkin_date">
                    <i class="fa fa-sign-in mr-1 text-success"></i> Ngày Nhận Phòng (Check-in) *
                  </label>
                  <input type="date" id="checkin_date" name="checkin_date" class="form-control"
                         min="${todayDate}" value="${checkinDate}" required onchange="onCheckInChange()" />
                </div>
                <div class="col-md-6 form-group mb-4">
                  <label class="text-dark font-weight-bold" for="checkout_date">
                    <i class="fa fa-sign-out mr-1 text-danger"></i> Ngày Trả Phòng (Check-out) *
                  </label>
                  <input type="date" id="checkout_date" name="checkout_date" class="form-control"
                         min="${todayDate}" value="${checkoutDate}" required onchange="calculateNights()" />
                </div>
              </div>

              <div id="stayDurationAlert" class="alert alert-info p-3 mb-4 rounded d-flex align-items-center justify-content-between">
                <div>
                  <i class="fa fa-moon-o mr-2"></i> Tổng thời gian lưu trú: <strong id="stayNightsText">1 đêm</strong>
                </div>
                <span class="badge badge-success px-3 py-2" id="stayStatusBadge">Hợp lệ</span>
              </div>

              <!-- 3. Số lượng khách -->
              <div class="row">
                <div class="col-md-6 form-group mb-4">
                  <label class="text-dark font-weight-bold" for="adults">
                    <i class="fa fa-user mr-1 text-muted"></i> Người Lớn (&ge; 13 tuổi) *
                  </label>
                  <select name="adults" id="adults" class="form-control" onchange="validateGuestCapacity()">
                    <option value="1" ${adults == 1 ? 'selected' : ''}>1 người lớn</option>
                    <option value="2" ${empty adults || adults == 2 ? 'selected' : ''}>2 người lớn</option>
                    <option value="3" ${adults == 3 ? 'selected' : ''}>3 người lớn</option>
                    <option value="4" ${adults == 4 ? 'selected' : ''}>4 người lớn</option>
                    <option value="5" ${adults == 5 ? 'selected' : ''}>5 người lớn</option>
                    <option value="6" ${adults == 6 ? 'selected' : ''}>6 người lớn</option>
                  </select>
                </div>
                <div class="col-md-6 form-group mb-4">
                  <label class="text-dark font-weight-bold" for="children">
                    <i class="fa fa-child mr-1 text-muted"></i> Trẻ Em (0 - 12 tuổi)
                  </label>
                  <select name="children" id="children" class="form-control" onchange="validateGuestCapacity()">
                    <option value="0" ${empty children || children == 0 ? 'selected' : ''}>0 trẻ em</option>
                    <option value="1" ${children == 1 ? 'selected' : ''}>1 trẻ em</option>
                    <option value="2" ${children == 2 ? 'selected' : ''}>2 trẻ em</option>
                    <option value="3" ${children == 3 ? 'selected' : ''}>3 trẻ em</option>
                  </select>
                </div>
              </div>

              <div id="capacityWarning" class="alert alert-warning mb-4 d-none">
                <i class="fa fa-exclamation-circle mr-2"></i>
                <span>Số khách vượt quá sức chứa tối đa của phòng này. Bạn có thể sang Bước 2 để <strong>thêm phòng khác</strong> vào cùng đơn!</span>
              </div>

              <hr class="my-4" />

              <div class="text-right">
                <button type="submit" class="btn btn-primary btn-lg font-weight-bold px-4 py-3 shadow">
                  Tiếp Tục: Xem Lại & Thêm Phòng (Bước 2) <i class="fa fa-arrow-right ml-2"></i>
                </button>
              </div>
            </form>
          </div>
        </div>

        <!-- Sidebar Step 1 -->
        <div class="col-lg-4" data-aos="fade-up" data-aos-delay="200">
          <div class="booking-card p-4 booking-summary-sticky">
            <h4 class="font-weight-bold text-dark border-bottom pb-3 mb-3">Tóm Tắt Ước Tính</h4>

            <div class="d-flex justify-content-between mb-2">
              <span class="text-muted">Đơn giá phòng:</span>
              <strong id="sideRoomPrice">0 VNĐ</strong>
            </div>
            <div class="d-flex justify-content-between mb-2">
              <span class="text-muted">Số đêm lưu trú:</span>
              <strong id="sideNights">1 đêm</strong>
            </div>
            <div class="d-flex justify-content-between mb-3">
              <span class="text-muted">Phí dịch vụ & dọn dẹp:</span>
              <span class="text-success font-weight-bold">Miễn phí</span>
            </div>
            <hr />
            <div class="d-flex justify-content-between align-items-center mb-4">
              <span class="h6 font-weight-bold text-dark mb-0">Tạm tính ước tính:</span>
              <span class="h4 font-weight-bold text-primary mb-0" id="sideTotalPrice">0 VNĐ</span>
            </div>

            <div class="p-3 bg-light rounded small text-muted">
              <div class="mb-2"><i class="fa fa-shield text-success mr-2"></i> <strong>Đảm bảo giá tốt nhất:</strong> Không thu phụ phí ẩn.</div>
              <div class="mb-2"><i class="fa fa-clock-o text-info mr-2"></i> <strong>Nhận phòng:</strong> Từ 14:00 | <strong>Trả phòng:</strong> Trước 12:00.</div>
              <div><i class="fa fa-phone text-warning mr-2"></i> <strong>Hỗ trợ trực tuyến:</strong> 090 123 4567 (24/7).</div>
            </div>
          </div>
        </div>
      </div>
    </c:if>

    <!-- =================================================================== -->
    <!-- STEP 2: Review & Confirm (Multi-Room Support)                       -->
    <!-- =================================================================== -->
    <c:if test="${step == '2'}">
      <div class="row">
        <div class="col-lg-8" data-aos="fade-up" data-aos-delay="100">

          <!-- 1. Danh sách phòng đã chọn (Multi-Room) -->
          <div class="booking-card mb-4 p-4 p-md-5">
            <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-4">
              <h3 class="h4 font-weight-bold text-dark mb-0">
                <i class="fa fa-list-ul text-primary mr-2"></i> 1. Các Phòng Đã Chọn (${draft.totalRooms} phòng)
              </h3>
              <a href="${pageContext.request.contextPath}/booking?step=1" class="btn btn-outline-secondary btn-sm">
                <i class="fa fa-pencil mr-1"></i> Sửa Lịch Trình
              </a>
            </div>

            <c:forEach var="item" items="${draft.rooms}" varStatus="status">
              <div class="added-room-item p-3 mb-3 rounded border">
                <div class="row align-items-center">
                  <div class="col-md-3">
                    <img src="${pageContext.request.contextPath}/${item.imageUrl}" class="img-fluid rounded shadow-sm" style="height: 100px; width: 100%; object-fit: cover;" alt="${item.roomName}" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/img_1.jpg';" />
                  </div>
                  <div class="col-md-6 my-2 my-md-0">
                    <h5 class="font-weight-bold text-dark mb-1">
                      Phòng ${status.count}: ${item.roomName}
                    </h5>
                    <p class="text-muted small mb-1">
                      <span class="badge badge-info">${item.roomTypeName}</span> &bull; ${item.adults} người lớn, ${item.children} trẻ em
                    </p>
                    <p class="text-muted small mb-0">
                      <i class="fa fa-calendar mr-1"></i> <fmt:formatDate value="${item.checkInDate}" pattern="dd/MM/yyyy" /> ➔ <fmt:formatDate value="${item.checkOutDate}" pattern="dd/MM/yyyy" /> (${item.numberOfNights} đêm)
                    </p>
                  </div>
                  <div class="col-md-3 text-md-right">
                    <div class="h5 font-weight-bold text-primary mb-1">
                      <fmt:formatNumber value="${item.subtotal}" pattern="#,###" /> VNĐ
                    </div>
                    <div class="text-muted small mb-2">
                      <fmt:formatNumber value="${item.pricePerNight}" pattern="#,###" /> đ/đêm
                    </div>
                    <c:if test="${draft.rooms.size() > 1}">
                      <form action="${pageContext.request.contextPath}/booking" method="post" class="d-inline" onsubmit="return confirm('Bạn có chắc chắn muốn xóa phòng này khỏi đơn đặt?');">
                        <input type="hidden" name="action" value="remove_room" />
                        <input type="hidden" name="remove_room_id" value="${item.roomId}" />
                        <button type="submit" class="btn btn-outline-danger btn-sm py-0 px-2" title="Xóa phòng này">
                          <i class="fa fa-trash mr-1"></i> Xóa
                        </button>
                      </form>
                    </c:if>
                  </div>
                </div>
              </div>
            </c:forEach>

            <!-- Tùy chọn đặt thêm phòng (Multi-Room Feature) -->
            <div class="mt-4 p-3 bg-light rounded border border-primary border-dashed">
              <div class="d-flex justify-content-between align-items-center cursor-pointer" data-toggle="collapse" data-target="#addRoomCollapse" aria-expanded="false">
                <span class="font-weight-bold text-dark">
                  <i class="fa fa-plus-circle text-success mr-2"></i> Đặt thêm phòng khác vào cùng chuyến đi này (Multi-Room)?
                </span>
                <button type="button" class="btn btn-sm btn-outline-primary" data-toggle="collapse" data-target="#addRoomCollapse">
                  <i class="fa fa-chevron-down"></i> Thêm Phòng
                </button>
              </div>

              <div class="collapse mt-3" id="addRoomCollapse">
                <c:choose>
                  <c:when test="${not empty availableRooms}">
                    <form action="${pageContext.request.contextPath}/booking" method="post">
                      <input type="hidden" name="action" value="add_room" />
                      <div class="row align-items-end">
                        <div class="col-md-6 form-group">
                          <label class="text-dark small font-weight-bold" for="extra_room_id">Chọn thêm phòng còn trống:</label>
                          <select name="extra_room_id" id="extra_room_id" class="form-control" required>
                            <c:forEach var="ar" items="${availableRooms}">
                              <option value="${ar.id}">
                                ${ar.roomName} (${not empty ar.roomTypeName ? ar.roomTypeName : (not empty ar.roomType ? ar.roomType.typeName : 'Phòng')}) - <fmt:formatNumber value="${ar.pricePerNight}" pattern="#,###"/> đ/đêm
                              </option>
                            </c:forEach>
                          </select>
                        </div>
                        <div class="col-md-3 form-group">
                          <label class="text-dark small font-weight-bold" for="extra_adults">Số người lớn:</label>
                          <select name="extra_adults" id="extra_adults" class="form-control">
                            <option value="1">1 người</option>
                            <option value="2" selected>2 người</option>
                            <option value="3">3 người</option>
                            <option value="4">4 người</option>
                          </select>
                        </div>
                        <div class="col-md-3 form-group">
                          <button type="submit" class="btn btn-success btn-block font-weight-bold">
                            <i class="fa fa-plus mr-1"></i> Thêm Phòng
                          </button>
                        </div>
                      </div>
                    </form>
                  </c:when>
                  <c:otherwise>
                    <p class="text-muted small mb-0 mt-2">
                      <i class="fa fa-info-circle mr-1"></i> Hiện tại các phòng còn lại đã có khách đặt trong khoảng ngày bạn đã chọn.
                    </p>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>
          </div>

          <!-- 2. Thông tin khách hàng & Xác nhận -->
          <div class="booking-card mb-4 p-4 p-md-5">
            <h3 class="h4 font-weight-bold text-dark mb-4 border-bottom pb-3">
              <i class="fa fa-user-circle-o text-primary mr-2"></i> 2. Thông Tin Khách Hàng Nhận Phòng
            </h3>

            <form action="${pageContext.request.contextPath}/booking" method="post" id="confirmBookingForm">
              <input type="hidden" name="action" value="confirm" />

              <div class="row">
                <div class="col-md-6 form-group mb-3">
                  <label class="text-dark font-weight-bold" for="customer_name">Họ và tên người nhận phòng *</label>
                  <input type="text" id="customer_name" name="customer_name" class="form-control" required
                         value="${draft.customerName}" placeholder="Ví dụ: Nguyễn Văn A" />
                </div>
                <div class="col-md-6 form-group mb-3">
                  <label class="text-dark font-weight-bold" for="customer_phone">Số điện thoại liên hệ *</label>
                  <input type="text" id="customer_phone" name="customer_phone" class="form-control" required
                         value="${draft.customerPhone}" placeholder="Ví dụ: 0901234567" />
                </div>
              </div>

              <div class="form-group mb-3">
                <label class="text-dark font-weight-bold" for="customer_email">Địa chỉ Email xác nhận *</label>
                <input type="email" id="customer_email" name="customer_email" class="form-control" required
                       value="${draft.customerEmail}" placeholder="email@example.com" />
                <small class="form-text text-muted">Chúng tôi sẽ gửi mã đặt phòng và phiếu xác nhận đến hòm thư này.</small>
              </div>

              <div class="form-group mb-4">
                <label class="text-dark font-weight-bold" for="notes">Ghi chú & Yêu cầu đặc biệt</label>
                <textarea id="notes" name="notes" class="form-control" rows="3"
                          placeholder="Giờ check-in dự kiến, yêu cầu tầng cao, giường phụ, hỗ trợ xe đưa đón...">${draft.notes}</textarea>
              </div>

              <div class="p-3 bg-light rounded border mb-4">
                <div class="custom-control custom-checkbox">
                  <input type="checkbox" class="custom-control-input" id="termsCheck" required checked />
                  <label class="custom-control-label small text-dark" for="termsCheck">
                    Tôi đã đọc và đồng ý với <a href="${pageContext.request.contextPath}/term" target="_blank" class="text-primary font-weight-bold">Điều khoản & Chính sách đặt phòng</a> của Sogo Homestay.
                  </label>
                </div>
              </div>

              <div class="d-flex justify-content-between align-items-center">
                <a href="${pageContext.request.contextPath}/booking?step=1" class="btn btn-outline-secondary px-4 py-3 font-weight-bold">
                  <i class="fa fa-arrow-left mr-1"></i> Quay lại Bước 1
                </a>
                <button type="submit" class="btn btn-primary btn-lg font-weight-bold px-5 py-3 shadow">
                  <i class="fa fa-check-circle mr-2"></i> Xác Nhận Đặt Phòng
                </button>
              </div>
            </form>
          </div>
        </div>

        <!-- Sidebar Step 2: Billing & Voucher -->
        <div class="col-lg-4" data-aos="fade-up" data-aos-delay="200">
          <div class="booking-card p-4 booking-summary-sticky">
            <h4 class="font-weight-bold text-dark border-bottom pb-3 mb-3">Chi Tiết Hóa Đơn</h4>

            <div class="d-flex justify-content-between mb-2">
              <span class="text-muted">Tổng số phòng:</span>
              <strong>${draft.totalRooms} phòng</strong>
            </div>
            <div class="d-flex justify-content-between mb-2">
              <span class="text-muted">Tổng số khách:</span>
              <strong>${draft.totalGuests} người</strong>
            </div>
            <div class="d-flex justify-content-between mb-2">
              <span class="text-muted">Tiền phòng (Tạm tính):</span>
              <strong><fmt:formatNumber value="${draft.subtotal}" pattern="#,###"/> VNĐ</strong>
            </div>

            <!-- Mã giảm giá (Voucher) -->
            <div class="my-3 pt-3 border-top">
              <label class="text-dark small font-weight-bold" for="voucher_code">Mã ưu đãi / Voucher:</label>
              <form action="${pageContext.request.contextPath}/booking" method="post" class="input-group mb-2">
                <input type="hidden" name="action" value="apply_voucher" />
                <input type="text" name="voucher_code" id="voucher_code" class="form-control text-uppercase"
                       placeholder="Nhập mã voucher" value="${draft.voucherCode}" />
                <div class="input-group-append">
                  <button class="btn btn-dark" type="submit">Áp dụng</button>
                </div>
              </form>

              <c:if test="${not empty voucherError}">
                <div class="text-danger small mb-2"><i class="fa fa-times-circle mr-1"></i> ${voucherError}</div>
              </c:if>

              <c:if test="${not empty draft.voucherCode}">
                <div class="d-flex justify-content-between text-success small mb-2">
                  <span><i class="fa fa-ticket mr-1"></i> Đã giảm (${draft.voucherCode}):</span>
                  <strong>- <fmt:formatNumber value="${draft.discountAmount}" pattern="#,###"/> VNĐ</strong>
                </div>
              </c:if>
            </div>

            <hr />
            <div class="d-flex justify-content-between align-items-center mb-4">
              <span class="h6 font-weight-bold text-dark mb-0">Tổng thanh toán:</span>
              <span class="h3 font-weight-bold text-primary mb-0">
                <fmt:formatNumber value="${draft.totalPrice}" pattern="#,###"/> <small class="h6 text-muted">VNĐ</small>
              </span>
            </div>

            <div class="alert alert-light border p-3 rounded small text-dark mb-0">
              <div class="font-weight-bold mb-1"><i class="fa fa-money text-success mr-1"></i> Hình thức thanh toán:</div>
              <div class="text-muted">Thanh toán trực tiếp khi nhận phòng tại Homestay (Tiền mặt hoặc Quét mã VietQR).</div>
            </div>
          </div>
        </div>
      </div>
    </c:if>

    <!-- =================================================================== -->
    <!-- STEP SUCCESS: Confirmation & Receipt                                -->
    <!-- =================================================================== -->
    <c:if test="${step == 'success'}">
      <div class="row justify-content-center">
        <div class="col-lg-8" data-aos="fade-up">
          <div class="booking-card p-4 p-md-5 text-center mb-4">
            <div class="mb-3">
              <div style="width: 80px; height: 80px; background: #e8f5e9; color: #2e7d32; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; font-size: 2.5rem;">
                <i class="fa fa-check"></i>
              </div>
            </div>
            <h2 class="h3 font-weight-bold text-dark mb-2">Đặt Phòng Thành Công!</h2>
            <p class="text-muted mb-4">Cảm ơn bạn đã lựa chọn Sogo Homestay. Thông tin đặt phòng chi tiết dưới đây:</p>

            <c:if test="${not empty booking}">
              <div class="p-3 bg-light rounded border text-left mb-4">
                <div class="row mb-2">
                  <div class="col-sm-5 text-muted">Mã Đơn Đặt Phòng:</div>
                  <div class="col-sm-7"><span class="badge badge-primary px-3 py-2 font-weight-bold h6 mb-0">${booking.bookingCode}</span></div>
                </div>
                <div class="row mb-2">
                  <div class="col-sm-5 text-muted">Khách Hàng:</div>
                  <div class="col-sm-7 font-weight-bold text-dark">${booking.customerName} &bull; ${booking.customerPhone}</div>
                </div>
                <div class="row mb-2">
                  <div class="col-sm-5 text-muted">Email Nhận Phiếu:</div>
                  <div class="col-sm-7 text-dark">${booking.customerEmail}</div>
                </div>
                <div class="row mb-2">
                  <div class="col-sm-5 text-muted">Lịch Trình Lưu Trú:</div>
                  <div class="col-sm-7 font-weight-bold text-dark">
                    <fmt:formatDate value="${booking.checkInDate}" pattern="dd/MM/yyyy" /> ➔ <fmt:formatDate value="${booking.checkOutDate}" pattern="dd/MM/yyyy" />
                  </div>
                </div>
                <div class="row mb-2">
                  <div class="col-sm-5 text-muted">Tổng Khách:</div>
                  <div class="col-sm-7 text-dark">${booking.adults} khách</div>
                </div>
                <div class="row mb-2">
                  <div class="col-sm-5 text-muted">Trạng Thái:</div>
                  <div class="col-sm-7"><span class="badge badge-success px-2 py-1">${booking.status}</span></div>
                </div>
                <hr />
                <div class="row align-items-center">
                  <div class="col-sm-5 h6 font-weight-bold text-dark mb-0">Tổng Tiền Thanh Toán:</div>
                  <div class="col-sm-7 h4 font-weight-bold text-primary mb-0">
                    <fmt:formatNumber value="${booking.totalPrice}" pattern="#,###"/> VNĐ
                  </div>
                </div>
              </div>

              <!-- Danh sách các phòng đã đặt -->
              <c:if test="${not empty booking.bookingRooms}">
                <div class="text-left mb-4">
                  <h5 class="font-weight-bold text-dark mb-3"><i class="fa fa-bed mr-2 text-primary"></i> Danh Sách Phòng Đã Đặt:</h5>
                  <div class="table-responsive">
                    <table class="table table-bordered table-sm bg-white">
                      <thead class="thead-light">
                        <tr>
                          <th>Tên Phòng</th>
                          <th>Loại Phòng</th>
                          <th>Số Đêm</th>
                          <th class="text-right">Đơn Giá</th>
                          <th class="text-right">Thành Tiền</th>
                        </tr>
                      </thead>
                      <tbody>
                        <c:forEach var="br" items="${booking.bookingRooms}">
                          <tr>
                            <td class="font-weight-bold text-dark">${br.roomName}</td>
                            <td>${br.roomTypeName}</td>
                            <td>${br.numberOfNights} đêm</td>
                            <td class="text-right"><fmt:formatNumber value="${br.pricePerNight}" pattern="#,###"/> đ</td>
                            <td class="text-right font-weight-bold text-primary"><fmt:formatNumber value="${br.subtotal}" pattern="#,###"/> đ</td>
                          </tr>
                        </c:forEach>
                      </tbody>
                    </table>
                  </div>
                </div>
              </c:if>
            </c:if>

            <div class="d-flex justify-content-center flex-wrap gap-2 pt-2">
              <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-secondary px-4 py-2 mr-2 font-weight-bold">
                <i class="fa fa-home mr-1"></i> Về Trang Chủ
              </a>
              <a href="${pageContext.request.contextPath}/rooms" class="btn btn-primary px-4 py-2 font-weight-bold">
                <i class="fa fa-bed mr-1"></i> Xem Thêm Phòng
              </a>
            </div>
          </div>
        </div>
      </div>
    </c:if>

  </div>
</section>

<script>
  function updateRoomPreview() {
    var select = document.getElementById('room_id');
    if (!select) return;
    var opt = select.options[select.selectedIndex];
    if (!opt) return;

    var name = opt.getAttribute('data-name');
    var type = opt.getAttribute('data-type');
    var price = parseFloat(opt.getAttribute('data-price')) || 0;
    var capacity = opt.getAttribute('data-capacity');
    var image = opt.getAttribute('data-image');

    document.getElementById('previewRoomName').innerText = name || '';
    document.getElementById('previewRoomType').innerText = type || '';
    document.getElementById('previewRoomCapacity').innerText = capacity || '2';
    document.getElementById('previewRoomPrice').innerText = price.toLocaleString('vi-VN');
    document.getElementById('sideRoomPrice').innerText = price.toLocaleString('vi-VN') + ' VNĐ';
    if (image) {
      document.getElementById('previewRoomImg').src = image;
    }

    calculateNights();
    validateGuestCapacity();
  }

  function getNightsCount() {
    var inInput = document.getElementById('checkin_date');
    var outInput = document.getElementById('checkout_date');
    if (!inInput || !outInput || !inInput.value || !outInput.value) return 0;

    var p1 = inInput.value.split('-');
    var p2 = outInput.value.split('-');
    if (p1.length !== 3 || p2.length !== 3) return 0;

    var y1 = parseInt(p1[0], 10), m1 = parseInt(p1[1], 10) - 1, d1 = parseInt(p1[2], 10);
    var y2 = parseInt(p2[0], 10), m2 = parseInt(p2[1], 10) - 1, d2 = parseInt(p2[2], 10);
    var utc1 = Date.UTC(y1, m1, d1);
    var utc2 = Date.UTC(y2, m2, d2);

    return Math.round((utc2 - utc1) / (1000 * 60 * 60 * 24));
  }

  function onCheckInChange() {
    var inInput = document.getElementById('checkin_date');
    var outInput = document.getElementById('checkout_date');
    if (!inInput || !outInput) return;

    var inVal = inInput.value;
    if (inVal) {
      var parts = inVal.split('-');
      if (parts.length === 3) {
        var d = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
        d.setDate(d.getDate() + 1);
        var yyyy = d.getFullYear();
        var mm = String(d.getMonth() + 1).padStart(2, '0');
        var dd = String(d.getDate()).padStart(2, '0');
        var minOut = yyyy + '-' + mm + '-' + dd;

        outInput.min = minOut;
        if (!outInput.value || outInput.value <= inVal) {
          outInput.value = minOut;
        }
      }
    }
    calculateNights();
  }

  function calculateNights() {
    var inInput = document.getElementById('checkin_date');
    var outInput = document.getElementById('checkout_date');
    if (!inInput || !outInput) return;

    var nightsText = document.getElementById('stayNightsText');
    var statusBadge = document.getElementById('stayStatusBadge');
    var sideNights = document.getElementById('sideNights');
    var sideTotalPrice = document.getElementById('sideTotalPrice');

    var select = document.getElementById('room_id');
    var opt = select ? select.options[select.selectedIndex] : null;
    var price = opt ? (parseFloat(opt.getAttribute('data-price')) || 0) : 0;

    if (!inInput.value || !outInput.value) {
      if (nightsText) nightsText.innerText = 'Vui lòng chọn ngày nhận và trả phòng';
      if (statusBadge) {
        statusBadge.className = 'badge badge-warning px-3 py-2';
        statusBadge.innerText = 'Chờ chọn ngày';
      }
      if (sideNights) sideNights.innerText = '0 đêm';
      if (sideTotalPrice) sideTotalPrice.innerText = '0 VNĐ';
      return;
    }

    var nights = getNightsCount();

    if (nights < 1) {
      if (nightsText) nightsText.innerText = 'Chưa hợp lệ (Ngày trả phòng phải sau ngày nhận phòng ít nhất 1 đêm)';
      if (statusBadge) {
        statusBadge.className = 'badge badge-danger px-3 py-2';
        statusBadge.innerText = 'Lỗi ngày';
      }
      if (sideNights) sideNights.innerText = '0 đêm';
      if (sideTotalPrice) sideTotalPrice.innerText = '0 VNĐ';
    } else if (nights > 30) {
      if (nightsText) nightsText.innerText = nights + ' đêm (Vượt quá tối đa 30 đêm)';
      if (statusBadge) {
        statusBadge.className = 'badge badge-danger px-3 py-2';
        statusBadge.innerText = 'Vượt Max Stay';
      }
      if (sideNights) sideNights.innerText = nights + ' đêm';
      if (sideTotalPrice) sideTotalPrice.innerText = 'Liên hệ hỗ trợ';
    } else {
      if (nightsText) nightsText.innerText = nights + ' đêm';
      if (statusBadge) {
        statusBadge.className = 'badge badge-success px-3 py-2';
        statusBadge.innerText = 'Hợp lệ';
      }
      if (sideNights) sideNights.innerText = nights + ' đêm';
      var total = price * nights;
      if (sideTotalPrice) sideTotalPrice.innerText = total.toLocaleString('vi-VN') + ' VNĐ';
    }
  }

  function validateGuestCapacity() {
    var select = document.getElementById('room_id');
    var adultsSelect = document.getElementById('adults');
    var childrenSelect = document.getElementById('children');
    var warning = document.getElementById('capacityWarning');

    if (!select || !adultsSelect || !childrenSelect || !warning) return;

    var opt = select.options[select.selectedIndex];
    var capacity = opt ? (parseInt(opt.getAttribute('data-capacity')) || 2) : 2;
    var adults = parseInt(adultsSelect.value) || 1;
    var children = parseInt(childrenSelect.value) || 0;
    var totalGuests = adults + children;

    if (totalGuests > capacity) {
      warning.classList.remove('d-none');
    } else {
      warning.classList.add('d-none');
    }
  }

  function cleanupBootstrapDatepicker() {
    if (window.jQuery && window.jQuery.fn && window.jQuery.fn.datepicker) {
      try {
        window.jQuery('#checkin_date, #checkout_date').datepicker('destroy');
      } catch (e) {}
    }
    var popups = document.querySelectorAll('.datepicker.datepicker-dropdown');
    for (var i = 0; i < popups.length; i++) {
      popups[i].remove();
    }
  }

  document.addEventListener('DOMContentLoaded', function() {
    updateRoomPreview();
    cleanupBootstrapDatepicker();

    var step1Form = document.getElementById('step1Form');
    if (step1Form) {
      step1Form.addEventListener('submit', function(e) {
        var nights = getNightsCount();
        if (nights < 1) {
          e.preventDefault();
          alert('Ngày trả phòng phải sau ngày nhận phòng ít nhất 1 đêm.');
          return false;
        }
        if (nights > 30) {
          e.preventDefault();
          alert('Thời gian lưu trú tối đa là 30 đêm. Quý khách vui lòng chọn lại ngày hoặc liên hệ hỗ trợ cho nhu cầu thuê dài hạn.');
          return false;
        }
      });
    }

    ['checkin_date', 'checkout_date'].forEach(function(id) {
      var el = document.getElementById(id);
      if (el) {
        el.addEventListener('click', function() {
          if (typeof this.showPicker === 'function') {
            try { this.showPicker(); } catch (err) {}
          }
        });
      }
    });
  });

  window.addEventListener('load', function() {
    cleanupBootstrapDatepicker();
    onCheckInChange();
  });
</script>

<jsp:include page="common/footer.jsp" />

<script>
  // Neutralize and destroy any jQuery datepicker on checkin_date / checkout_date
  (function() {
    if (typeof window.jQuery !== 'undefined') {
      try {
        window.jQuery('#checkin_date, #checkout_date').datepicker('destroy');
      } catch (e) {}
      window.jQuery('#checkin_date, #checkout_date').off('.datepicker');
      if (window.jQuery.fn) {
        window.jQuery.fn.datepicker = function() { return this; };
      }
    }
    var popups = document.querySelectorAll('.datepicker, .datepicker-dropdown');
    for (var i = 0; i < popups.length; i++) {
      popups[i].remove();
    }
  })();
</script>
