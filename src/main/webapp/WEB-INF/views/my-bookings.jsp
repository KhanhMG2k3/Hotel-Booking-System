<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Lịch Sử Đặt Phòng - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<style>
  .my-bookings-hero {
    background: linear-gradient(135deg, rgba(29, 33, 36, 0.9) 0%, rgba(59, 89, 152, 0.85) 100%),
                url('${pageContext.request.contextPath}/images/hero_4.jpg') center/cover no-repeat;
    padding: 70px 0 50px 0;
    color: #fff;
    margin-bottom: 30px;
  }
  .booking-card-item {
    background: #fff;
    border-radius: 14px;
    border: 1px solid #e9ecef;
    box-shadow: 0 4px 14px rgba(0,0,0,0.05);
    margin-bottom: 24px;
    overflow: hidden;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
  }
  .booking-card-item:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 24px rgba(0,0,0,0.08);
  }
  .booking-card-header {
    background: #f8f9fa;
    border-bottom: 1px solid #eef2f5;
    padding: 14px 20px;
  }
  .booking-thumb-img {
    width: 100%;
    height: 140px;
    object-fit: cover;
    border-radius: 10px;
  }
  .booking-code-badge {
    font-family: 'Roboto Mono', Menlo, Consolas, monospace;
    font-weight: 700;
    color: #3b5998;
    background: #eef3ff;
    padding: 4px 10px;
    border-radius: 6px;
    border: 1px solid #d4e2ff;
    font-size: 0.95rem;
  }
  .filter-tab-pill {
    padding: 10px 22px;
    border-radius: 30px;
    font-weight: 600;
    font-size: 0.92rem;
    color: #495057;
    background: #f1f3f5;
    margin-right: 8px;
    margin-bottom: 10px;
    display: inline-block;
    transition: all 0.2s ease;
    text-decoration: none !important;
  }
  .filter-tab-pill:hover {
    background: #e2e6ea;
    color: #212529;
  }
  .filter-tab-pill.active {
    background: linear-gradient(135deg, #3b5998 0%, #203a73 100%);
    color: #fff;
    box-shadow: 0 4px 10px rgba(59, 89, 152, 0.25);
  }
  .filter-tab-pill .badge {
    margin-left: 6px;
    font-size: 0.78rem;
  }
  .empty-state-box {
    background: #fff;
    border-radius: 16px;
    border: 2px dashed #dee2e6;
    padding: 60px 20px;
    text-align: center;
  }
  .empty-state-icon {
    width: 80px;
    height: 80px;
    background: #f1f5f9;
    color: #94a3b8;
    border-radius: 50%;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 2.2rem;
    margin-bottom: 20px;
  }

  /* Scoped Dark Mode Overrides */
  [data-theme="dark"] .empty-state-box {
    background: #162032 !important;
    border-color: #334155 !important;
    color: #cbd5e1 !important;
  }
  [data-theme="dark"] .empty-state-box h3,
  [data-theme="dark"] .empty-state-box .h3 {
    color: #f8fafc !important;
  }
  [data-theme="dark"] .empty-state-box p {
    color: #94a3b8 !important;
  }
  [data-theme="dark"] .empty-state-icon {
    background: #111827 !important;
    color: #64748b !important;
  }
  [data-theme="dark"] .booking-card-item {
    background: #162032 !important;
    border-color: #243247 !important;
  }
  [data-theme="dark"] .booking-card-header {
    background: #111827 !important;
    border-color: #243247 !important;
  }
  [data-theme="dark"] .filter-tab-pill {
    background: #1e293b !important;
    color: #94a3b8 !important;
  }
  [data-theme="dark"] .filter-tab-pill.active {
    background: #ffba5a !important;
    color: #0f172a !important;
  }
  [data-theme="dark"] .booking-code-badge {
    background: rgba(96, 165, 250, 0.15) !important;
    color: #93c5fd !important;
    border-color: rgba(96, 165, 250, 0.3) !important;
  }
</style>

<!-- Hero Section -->
<section class="my-bookings-hero">
  <div class="container text-center">
    <h1 class="display-5 font-weight-bold mb-2">Lịch Sử Đặt Phòng</h1>
    <p class="lead mb-0 text-white-50">Xem lại và quản lý tất cả các đơn đặt phòng homestay của bạn</p>
  </div>
</section>

<!-- Content Section -->
<section class="section py-4">
  <div class="container">

    <!-- Flash message alerts -->
    <c:if test="${not empty messageSuccess || not empty sessionScope.messageSuccess}">
      <div class="alert alert-success alert-dismissible fade show mb-4 shadow-sm" role="alert">
        <i class="fa fa-check-circle mr-2"></i> ${not empty messageSuccess ? messageSuccess : sessionScope.messageSuccess}
        <button type="button" class="close" data-dismiss="alert">&times;</button>
      </div>
      <c:remove var="messageSuccess" scope="session" />
    </c:if>

    <c:if test="${not empty messageError || not empty sessionScope.messageError}">
      <div class="alert alert-danger alert-dismissible fade show mb-4 shadow-sm" role="alert">
        <i class="fa fa-exclamation-triangle mr-2"></i> ${not empty messageError ? messageError : sessionScope.messageError}
        <button type="button" class="close" data-dismiss="alert">&times;</button>
      </div>
      <c:remove var="messageError" scope="session" />
    </c:if>

    <!-- Filter Tabs -->
    <div class="mb-4">
      <a href="${pageContext.request.contextPath}/my-bookings?status=ALL"
         class="filter-tab-pill ${currentStatus == 'ALL' ? 'active' : ''}">
        Tất Cả <span class="badge ${currentStatus == 'ALL' ? 'badge-light text-dark' : 'badge-secondary'}">${countAll}</span>
      </a>
      <a href="${pageContext.request.contextPath}/my-bookings?status=CONFIRMED"
         class="filter-tab-pill ${currentStatus == 'CONFIRMED' ? 'active' : ''}">
        Đã Xác Nhận <span class="badge ${currentStatus == 'CONFIRMED' ? 'badge-light text-dark' : 'badge-success'}">${countConfirmed}</span>
      </a>
      <a href="${pageContext.request.contextPath}/my-bookings?status=PENDING"
         class="filter-tab-pill ${currentStatus == 'PENDING' ? 'active' : ''}">
        Chờ Xử Lý <span class="badge ${currentStatus == 'PENDING' ? 'badge-light text-dark' : 'badge-warning text-dark'}">${countPending}</span>
      </a>
      <a href="${pageContext.request.contextPath}/my-bookings?status=COMPLETED"
         class="filter-tab-pill ${currentStatus == 'COMPLETED' ? 'active' : ''}">
        Hoàn Thành <span class="badge ${currentStatus == 'COMPLETED' ? 'badge-light text-dark' : 'badge-info'}">${countCompleted}</span>
      </a>
      <a href="${pageContext.request.contextPath}/my-bookings?status=CANCELLED"
         class="filter-tab-pill ${currentStatus == 'CANCELLED' ? 'active' : ''}">
        Đã Hủy <span class="badge ${currentStatus == 'CANCELLED' ? 'badge-light text-dark' : 'badge-danger'}">${countCancelled}</span>
      </a>
    </div>

    <!-- Booking List or Empty State -->
    <c:choose>
      <c:when test="${empty bookings}">
        <div class="empty-state-box">
          <div class="empty-state-icon">
            <i class="fa fa-calendar-times-o"></i>
          </div>
          <h3 class="h4 font-weight-bold text-dark mb-2">Chưa có đơn đặt phòng nào</h3>
          <p class="text-muted mb-4 max-w-500 mx-auto">
            <c:choose>
              <c:when test="${currentStatus != 'ALL'}">
                Không tìm thấy đơn đặt phòng nào ở trạng thái đã chọn. Bạn có thể chọn tab "Tất Cả" để xem toàn bộ lịch sử.
              </c:when>
              <c:otherwise>
                Bạn chưa thực hiện đơn đặt phòng homestay nào. Hãy khám phá ngay các không gian nghỉ dưỡng tuyệt vời tại Sogo!
              </c:otherwise>
            </c:choose>
          </p>
          <a href="${pageContext.request.contextPath}/rooms" class="btn btn-primary font-weight-bold px-4 py-2 shadow-sm">
            <i class="fa fa-search mr-2"></i> Khám Phá Phòng Homestay
          </a>
        </div>
      </c:when>
      <c:otherwise>
        <c:forEach var="b" items="${bookings}">
          <div class="booking-card-item">
            <!-- Card Header -->
            <div class="booking-card-header d-flex flex-wrap align-items-center justify-content-between">
              <div class="d-flex align-items-center mb-2 mb-md-0">
                <span class="mr-2 text-muted small">Mã đơn:</span>
                <span class="booking-code-badge mr-3">${b.bookingCode}</span>
                <span class="text-muted small">
                  <i class="fa fa-clock-o mr-1"></i>
                  ${b.formattedCreatedAt}
                </span>
              </div>
              <div>
                <c:choose>
                  <c:when test="${b.status == 'CONFIRMED'}">
                    <span class="badge badge-success px-3 py-2">
                      <i class="fa fa-check-circle mr-1"></i> Đã Xác Nhận
                    </span>
                  </c:when>
                  <c:when test="${b.status == 'PENDING'}">
                    <span class="badge badge-warning text-dark px-3 py-2">
                      <i class="fa fa-hourglass-half mr-1"></i> Chờ Xử Lý
                    </span>
                  </c:when>
                  <c:when test="${b.status == 'COMPLETED'}">
                    <span class="badge badge-info px-3 py-2">
                      <i class="fa fa-flag-checkered mr-1"></i> Hoàn Thành
                    </span>
                  </c:when>
                  <c:when test="${b.status == 'CANCELLED'}">
                    <span class="badge badge-secondary px-3 py-2">
                      <i class="fa fa-times-circle mr-1"></i> Đã Hủy
                    </span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge badge-light border px-3 py-2">${b.status}</span>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>

            <!-- Card Body -->
            <div class="p-3 p-md-4">
              <div class="row align-items-center">
                <!-- Thumbnail -->
                <div class="col-md-3 col-lg-2 mb-3 mb-md-0">
                  <img src="${pageContext.request.contextPath}/${b.roomImageUrl}"
                       alt="${b.roomName}" class="booking-thumb-img shadow-sm" />
                </div>

                <!-- Info Details -->
                <div class="col-md-5 col-lg-6 mb-3 mb-md-0">
                  <div class="text-muted small mb-1">
                    <i class="fa fa-map-marker text-danger mr-1"></i> ${b.propertyName}
                  </div>
                  <h5 class="font-weight-bold text-dark mb-2">
                    <a href="${pageContext.request.contextPath}/room-detail?id=${b.roomId}" class="text-dark text-decoration-none">
                      ${b.roomName}
                    </a>
                  </h5>

                  <c:if test="${not empty b.bookingRooms && b.bookingRooms.size() > 1}">
                    <div class="mb-2">
                      <span class="badge badge-light border text-primary">
                        <i class="fa fa-cubes mr-1"></i> Đơn gồm ${b.bookingRooms.size()} phòng
                      </span>
                    </div>
                  </c:if>

                  <div class="small text-muted mb-1">
                    <i class="fa fa-calendar-check-o text-success mr-1"></i>
                    <strong>${b.formattedCheckInDate}</strong>
                    &nbsp;➔&nbsp;
                    <strong>${b.formattedCheckOutDate}</strong>
                    <span class="badge badge-light border text-muted ml-2">${b.numberOfNights} đêm</span>
                  </div>

                  <div class="small text-muted">
                    <i class="fa fa-user mr-1 text-info"></i> Khách đặt: <strong>${b.customerName}</strong>
                    &bull; <i class="fa fa-users mr-1 text-primary"></i> ${b.guestCount} người
                  </div>
                </div>

                <!-- Price & Actions -->
                <div class="col-md-4 col-lg-4 text-md-right border-left-md pl-md-4">
                  <div class="text-muted small">Tổng tiền thanh toán</div>
                  <div class="h4 font-weight-bold text-primary mb-3">
                    ${b.formattedTotalPrice} VNĐ
                  </div>

                  <div class="d-flex flex-column gap-2">
                    <a href="${pageContext.request.contextPath}/booking?step=success&code=${b.bookingCode}"
                       class="btn btn-outline-primary btn-sm font-weight-bold mb-2">
                      <i class="fa fa-file-text-o mr-1"></i> Chi Tiết & Hóa Đơn
                    </a>

                    <c:if test="${b.status == 'PENDING' || b.status == 'CONFIRMED'}">
                      <button type="button" class="btn btn-outline-danger btn-sm font-weight-bold mb-2"
                              data-toggle="modal" data-target="#cancelModal${b.id}">
                        <i class="fa fa-ban mr-1"></i> Hủy Đặt Phòng
                      </button>

                      <!-- Modal Confirm Cancel -->
                      <div class="modal fade text-left" id="cancelModal${b.id}" tabindex="-1" role="dialog" aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered" role="document">
                          <div class="modal-content">
                            <div class="modal-header">
                              <h5 class="modal-title font-weight-bold text-danger">
                                <i class="fa fa-exclamation-triangle mr-2"></i> Xác Nhận Hủy Đặt Phòng
                              </h5>
                              <button type="button" class="close" data-dismiss="modal">&times;</button>
                            </div>
                            <div class="modal-body">
                              <p>Bạn có chắc chắn muốn hủy đơn đặt phòng <strong>${b.bookingCode}</strong> cho phòng <strong>${b.roomName}</strong> không?</p>
                              <div class="alert alert-warning small mb-0">
                                <i class="fa fa-info-circle mr-1"></i>
                                Sau khi hủy, phòng sẽ được mở lại cho khách khác đặt và trạng thái đơn sẽ chuyển sang <strong>Đã Hủy</strong>.
                              </div>
                            </div>
                            <div class="modal-footer">
                              <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Đóng</button>
                              <form action="${pageContext.request.contextPath}/my-bookings" method="post" class="d-inline">
                                <input type="hidden" name="action" value="cancel" />
                                <input type="hidden" name="bookingId" value="${b.id}" />
                                <button type="submit" class="btn btn-danger btn-sm font-weight-bold">
                                  <i class="fa fa-trash-o mr-1"></i> Đồng Ý Hủy Đơn
                                </button>
                              </form>
                            </div>
                          </div>
                        </div>
                      </div>
                    </c:if>

                    <a href="${pageContext.request.contextPath}/booking?step=1&roomId=${b.roomId}"
                       class="btn btn-light btn-sm text-muted">
                      <i class="fa fa-repeat mr-1"></i> Đặt lại phòng này
                    </a>
                  </div>
                </div>

              </div>
            </div>
          </div>
        </c:forEach>
      </c:otherwise>
    </c:choose>

  </div>
</section>

<jsp:include page="common/footer.jsp" />
