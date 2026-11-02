<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" language="java"  %>
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

<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="common/header.jsp">
    <jsp:param name="pageTitle" value="Lịch Sử Đặt Phòng & Hoàn Tiền - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<style>
    .site-header {
        position: fixed !important;
        background: #ffffff !important;
        padding: 16px 0 !important;
        box-shadow: 0 2px 12px rgba(0,0,0,0.06) !important;
        z-index: 1000 !important;
    }
    .site-header .site-logo a,
    .site-logo a {
        color: #1a1a1a !important;
    }
    .site-header .user-name {
        color: #1a1a1a !important;
    }
    .site-header .user-caret {
        color: #64748b !important;
    }
    .site-header .user-menu-toggle {
        background: #f8fafc !important;
        border: 1px solid #e2e8f0 !important;
    }
    .site-header .site-menu-toggle span {
        background: #1a1a1a !important;
    }
    .my-bookings-hero-header {
        margin-top: 75px;
        background: linear-gradient(135deg, #f8fafc 0%, #eef2f6 100%);
        border-bottom: 1px solid #e2e8f0;
        padding: 35px 0 25px 0;
    }
    .booking-filter-nav {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-bottom: 25px;
        border-bottom: 2px solid #e2e8f0;
        padding-bottom: 12px;
    }
    .filter-tab-btn {
        padding: 8px 18px;
        border-radius: 9999px;
        font-size: 14px;
        font-weight: 600;
        text-decoration: none;
        color: #64748b;
        background: #f1f5f9;
        transition: all 0.2s ease;
        border: 1px solid transparent;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .filter-tab-btn:hover {
        background: #e2e8f0;
        color: #0f172a;
        text-decoration: none;
    }
    .filter-tab-btn.active {
        background: #ffba5a;
        color: #ffffff;
    }
    .filter-tab-btn .badge-pill-count {
        background: rgba(0, 0, 0, 0.12);
        color: inherit;
        font-size: 11px;
        padding: 2px 7px;
        border-radius: 10px;
    }
    .filter-tab-btn.active .badge-pill-count {
        background: #ffffff;
        color: #d97706;
    }
    .booking-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        overflow: hidden;
        margin-bottom: 22px;
        box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
        transition: transform 0.2s, box-shadow 0.2s;
    }
    .booking-card:hover {
        box-shadow: 0 10px 15px -3px rgba(0,0,0,0.08);
    }
    .booking-card-header {
        background: #f8fafc;
        padding: 14px 20px;
        border-bottom: 1px solid #e2e8f0;
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 10px;
    }
    .booking-card-body {
        padding: 20px;
    }
    .booking-thumb {
        width: 130px;
        height: 105px;
        object-fit: cover;
        border-radius: 8px;
    }
    .booking-status-badge {
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    .badge-status-confirmed { background: #dcfce7; color: #15803d; }
    .badge-status-pending { background: #fef3c7; color: #b45309; }
    .badge-status-cancelled { background: #fee2e2; color: #b91c1c; }
    .badge-status-refunded { background: #ede9fe; color: #6d28d9; }

    /* Timeline Stepper for Refund Tracking */
    .refund-stepper {
        position: relative;
        padding: 20px 0;
        margin-bottom: 25px;
    }
    .stepper-item {
        position: relative;
        display: flex;
        align-items: flex-start;
        margin-bottom: 25px;
    }
    .stepper-icon {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: #e2e8f0;
        color: #64748b;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 700;
        font-size: 16px;
        z-index: 2;
        flex-shrink: 0;
    }
    .stepper-item.completed .stepper-icon {
        background: #22c55e;
        color: #fff;
    }
    .stepper-item.current .stepper-icon {
        background: #3b82f6;
        color: #fff;
        box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.2);
    }
    .stepper-item.rejected .stepper-icon {
        background: #ef4444;
        color: #fff;
    }
    .stepper-content {
        margin-left: 15px;
        flex-grow: 1;
    }
    .stepper-line {
        position: absolute;
        top: 40px;
        left: 20px;
        width: 2px;
        height: calc(100% - 30px);
        background: #e2e8f0;
        z-index: 1;
    }
    .stepper-item.completed + .stepper-line {
        background: #22c55e;
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
                       alt="${b.roomName}" class="booking-thumb-img shadow-sm" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/img_1.jpg';" />
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



<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="common/header.jsp">
    <jsp:param name="pageTitle" value="Lịch Sử Đặt Phòng & Hoàn Tiền - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<style>
    .site-header {
        position: fixed !important;
        background: #ffffff !important;
        padding: 16px 0 !important;
        box-shadow: 0 2px 12px rgba(0,0,0,0.06) !important;
        z-index: 1000 !important;
    }
    .site-header .site-logo a,
    .site-logo a {
        color: #1a1a1a !important;
    }
    .site-header .user-name {
        color: #1a1a1a !important;
    }
    .site-header .user-caret {
        color: #64748b !important;
    }
    .site-header .user-menu-toggle {
        background: #f8fafc !important;
        border: 1px solid #e2e8f0 !important;
    }
    .site-header .site-menu-toggle span {
        background: #1a1a1a !important;
    }
    .my-bookings-hero-header {
        margin-top: 75px;
        background: linear-gradient(135deg, #f8fafc 0%, #eef2f6 100%);
        border-bottom: 1px solid #e2e8f0;
        padding: 35px 0 25px 0;
    }
    .booking-filter-nav {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-bottom: 25px;
        border-bottom: 2px solid #e2e8f0;
        padding-bottom: 12px;
    }
    .filter-tab-btn {
        padding: 8px 18px;
        border-radius: 9999px;
        font-size: 14px;
        font-weight: 600;
        text-decoration: none;
        color: #64748b;
        background: #f1f5f9;
        transition: all 0.2s ease;
        border: 1px solid transparent;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .filter-tab-btn:hover {
        background: #e2e8f0;
        color: #0f172a;
        text-decoration: none;
    }
    .filter-tab-btn.active {
        background: #ffba5a;
        color: #ffffff;
    }
    .filter-tab-btn .badge-pill-count {
        background: rgba(0, 0, 0, 0.12);
        color: inherit;
        font-size: 11px;
        padding: 2px 7px;
        border-radius: 10px;
    }
    .filter-tab-btn.active .badge-pill-count {
        background: #ffffff;
        color: #d97706;
    }
    .booking-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        overflow: hidden;
        margin-bottom: 22px;
        box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
        transition: transform 0.2s, box-shadow 0.2s;
    }
    .booking-card:hover {
        box-shadow: 0 10px 15px -3px rgba(0,0,0,0.08);
    }
    .booking-card-header {
        background: #f8fafc;
        padding: 14px 20px;
        border-bottom: 1px solid #e2e8f0;
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 10px;
    }
    .booking-card-body {
        padding: 20px;
    }
    .booking-thumb {
        width: 130px;
        height: 105px;
        object-fit: cover;
        border-radius: 8px;
    }
    .booking-status-badge {
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    .badge-status-confirmed { background: #dcfce7; color: #15803d; }
    .badge-status-pending { background: #fef3c7; color: #b45309; }
    .badge-status-cancelled { background: #fee2e2; color: #b91c1c; }
    .badge-status-refunded { background: #ede9fe; color: #6d28d9; }

    /* Timeline Stepper for Refund Tracking */
    .refund-stepper {
        position: relative;
        padding: 20px 0;
        margin-bottom: 25px;
    }
    .stepper-item {
        position: relative;
        display: flex;
        align-items: flex-start;
        margin-bottom: 25px;
    }
    .stepper-icon {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: #e2e8f0;
        color: #64748b;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 700;
        font-size: 16px;
        z-index: 2;
        flex-shrink: 0;
    }
    .stepper-item.completed .stepper-icon {
        background: #22c55e;
        color: #fff;
    }
    .stepper-item.current .stepper-icon {
        background: #3b82f6;
        color: #fff;
        box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.2);
    }
    .stepper-item.rejected .stepper-icon {
        background: #ef4444;
        color: #fff;
    }
    .stepper-content {
        margin-left: 15px;
        flex-grow: 1;
    }
    .stepper-line {
        position: absolute;
        top: 40px;
        left: 20px;
        width: 2px;
        height: calc(100% - 30px);
        background: #e2e8f0;
        z-index: 1;
    }
    .stepper-item.completed + .stepper-line {
        background: #22c55e;
    }
</style>

<div class="my-bookings-hero-header">
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb bg-transparent p-0 mb-2">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home" class="text-secondary">Trang Chủ</a></li>
                <li class="breadcrumb-item active text-dark font-weight-bold" aria-current="page">Lịch Sử Đặt Phòng</li>
            </ol>
        </nav>
        <div class="d-flex justify-content-between align-items-center flex-wrap">
            <div>
                <h1 class="h3 font-weight-bold mb-1 text-dark">Lịch Sử Đặt Phòng & Hoàn Tiền</h1>
                <p class="text-muted mb-0">Theo dõi thông tin các kỳ nghỉ, tình trạng thanh toán và quản lý yêu cầu hoàn tiền của bạn.</p>
            </div>
            <div class="mt-3 mt-md-0">
                <a href="${pageContext.request.contextPath}/rooms" class="btn btn-warning text-white rounded-pill px-4 font-weight-bold shadow-sm" style="background:#ffba5a; border-color:#ffba5a;">
                    <i class="fa fa-search mr-1"></i> Tìm phòng mới
                </a>
            </div>
        </div>
    </div>
</div>

<div class="container py-5">
    <!-- Success / Error notification -->
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show shadow-sm mb-4" role="alert">
            <i class="fa fa-check-circle mr-2"></i> ${successMessage}
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>
    </c:if>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show shadow-sm mb-4" role="alert">
            <i class="fa fa-exclamation-circle mr-2"></i> ${errorMessage}
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>
    </c:if>

    <!-- Filter navigation tabs -->
    <div class="booking-filter-nav">
        <a href="${pageContext.request.contextPath}/my-bookings?status=ALL"
           class="filter-tab-btn ${currentFilter == 'ALL' ? 'active' : ''}">
            Tất cả <span class="badge-pill-count">${totalCount}</span>
        </a>
        <a href="${pageContext.request.contextPath}/my-bookings?status=PENDING"
           class="filter-tab-btn ${currentFilter == 'PENDING' ? 'active' : ''}">
            Chờ thanh toán <span class="badge-pill-count">${pendingCount}</span>
        </a>
        <a href="${pageContext.request.contextPath}/my-bookings?status=CONFIRMED"
           class="filter-tab-btn ${currentFilter == 'CONFIRMED' ? 'active' : ''}">
            Đã xác nhận <span class="badge-pill-count">${confirmedCount}</span>
        </a>
        <a href="${pageContext.request.contextPath}/my-bookings?status=CANCELLED"
           class="filter-tab-btn ${currentFilter == 'CANCELLED' ? 'active' : ''}">
            Đã hủy <span class="badge-pill-count">${cancelledCount}</span>
        </a>
        <a href="${pageContext.request.contextPath}/my-bookings?status=REFUNDED"
           class="filter-tab-btn ${currentFilter == 'REFUNDED' ? 'active' : ''}">
            Đã hoàn tiền <span class="badge-pill-count">${refundedCount}</span>
        </a>
    </div>

    <!-- Search filter bar -->
    <div class="row mb-4">
        <div class="col-md-6 col-lg-5">
            <form action="${pageContext.request.contextPath}/my-bookings" method="get" class="d-flex">
                <input type="hidden" name="status" value="${currentFilter}" />
                <input type="text" name="q" value="${searchKeyword}" class="form-control rounded-left"
                       placeholder="Tìm theo mã đơn hoặc tên homestay..." />
                <button type="submit" class="btn btn-primary rounded-right px-3">
                    <i class="fa fa-search"></i>
                </button>
            </form>
        </div>
    </div>

    <!-- Booking list -->
    <c:choose>
        <c:when test="${empty bookings}">
                <div class="text-center py-5 bg-white rounded-lg shadow-sm border border-light">
                    <div style="font-size: 50px; color: #cbd5e1; margin-bottom: 15px;">
                        <i class="fa fa-calendar-times-o"></i>
                    </div>
                    <h4 class="font-weight-bold text-dark mb-2">Chưa có đơn đặt phòng nào</h4>
                    <p class="text-muted mb-4">Không tìm thấy đơn đặt phòng nào phù hợp với bộ lọc hiện tại.</p>
                    <a href="${pageContext.request.contextPath}/rooms" class="btn btn-primary rounded-pill px-4">
                        Khám phá homestay ngay
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="booking" items="${bookings}">
                    <div class="booking-card">
                        <div class="booking-card-header">
                            <div>
                                <span class="font-weight-bold text-dark mr-2">Mã đơn:</span>
                                <span class="badge badge-secondary px-2 py-1 font-monospace" style="font-size: 13px;">
                                    ${booking.bookingCode}
                                </span>
                                <span class="text-muted ml-3" style="font-size: 13px;">
                                    <i class="fa fa-clock-o mr-1"></i>
                                    <fmt:formatDate value="${booking.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                </span>
                            </div>
                            <div>
                                <c:choose>
                                    <c:when test="${booking.status == 'CONFIRMED'}">
                                        <span class="booking-status-badge badge-status-confirmed">
                                            <i class="fa fa-check-circle mr-1"></i> Đã xác nhận
                                        </span>
                                    </c:when>
                                    <c:when test="${booking.status == 'PENDING'}">
                                        <span class="booking-status-badge badge-status-pending">
                                            <i class="fa fa-hourglass-half mr-1"></i> Chờ thanh toán
                                        </span>
                                    </c:when>
                                    <c:when test="${booking.status == 'REFUNDED'}">
                                        <span class="booking-status-badge badge-status-refunded">
                                            <i class="fa fa-undo mr-1"></i> Đã hoàn tiền
                                        </span>
                                    </c:when>
                                    <c:when test="${booking.status == 'CANCELLED'}">
                                        <span class="booking-status-badge badge-status-cancelled">
                                            <i class="fa fa-ban mr-1"></i> Đã hủy
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="booking-status-badge badge-secondary">${booking.status}</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="booking-card-body">
                            <div class="row align-items-center">
                                <div class="col-md-7 mb-3 mb-md-0">
                                    <div class="media align-items-center">
                                        <img src="${pageContext.request.contextPath}/assets/${not empty booking.roomImageUrl ? booking.roomImageUrl : 'images/img_1.jpg'}"
                                             class="mr-3 booking-thumb shadow-sm" alt="Room preview"
                                             onerror="this.src='${pageContext.request.contextPath}/assets/images/img_1.jpg'" />
                                        <div class="media-body">
                                            <h5 class="mt-0 font-weight-bold text-dark mb-1">
                                                ${not empty booking.propertyName ? booking.propertyName : 'Sogo Homestay'}
                                            </h5>
                                            <p class="text-primary font-weight-bold mb-2" style="font-size: 14px;">
                                                <i class="fa fa-bed mr-1"></i> ${not empty booking.roomName ? booking.roomName : 'Phòng tiêu chuẩn'}
                                            </p>
                                            <div class="text-muted" style="font-size: 13px;">
                                                <span class="mr-3">
                                                    <i class="fa fa-calendar-check-o text-success mr-1"></i>
                                                    Nhận: <strong><fmt:formatDate value="${booking.checkInDate}" pattern="dd/MM/yyyy" /></strong>
                                                </span>
                                                <span>
                                                    <i class="fa fa-calendar-times-o text-danger mr-1"></i>
                                                    Trả: <strong><fmt:formatDate value="${booking.checkOutDate}" pattern="dd/MM/yyyy" /></strong>
                                                </span>
                                            </div>
                                            <div class="text-muted mt-1" style="font-size: 12px;">
                                                <i class="fa fa-users mr-1"></i> ${booking.adults} người lớn, ${booking.children} trẻ em
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-md-5 text-md-right border-left-md">
                                    <div class="mb-2">
                                        <div class="text-muted" style="font-size: 12px;">Tổng chi phí:</div>
                                        <div class="font-weight-bold text-danger" style="font-size: 20px;">
                                            <fmt:formatNumber value="${booking.totalAmount}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                                        </div>
                                    </div>

                                    <!-- Refund indicator pill -->
                                    <c:if test="${not empty booking.refund}">
                                        <div class="mb-3">
                                            <c:choose>
                                                <c:when test="${booking.refund.status == 'REQUESTED'}">
                                                    <span class="badge badge-warning px-2 py-1 font-weight-bold text-dark">
                                                        <i class="fa fa-clock-o mr-1"></i> Yêu cầu hoàn tiền đang chờ Host duyệt
                                                    </span>
                                                </c:when>
                                                <c:when test="${booking.refund.status == 'APPROVED' || booking.refund.status == 'SUCCEEDED'}">
                                                    <span class="badge badge-success px-2 py-1 font-weight-bold">
                                                        <i class="fa fa-check-circle mr-1"></i> Host đã duyệt hoàn tiền
                                                    </span>
                                                </c:when>
                                                <c:when test="${booking.refund.status == 'REJECTED'}">
                                                    <span class="badge badge-danger px-2 py-1 font-weight-bold">
                                                        <i class="fa fa-times-circle mr-1"></i> Host đã từ chối hoàn tiền
                                                    </span>
                                                </c:when>
                                            </c:choose>
                                        </div>
                                    </c:if>

                                    <!-- Action Buttons -->
                                    <div class="btn-group-responsive">
                                        <c:if test="${booking.status == 'PENDING'}">
                                            <a href="${pageContext.request.contextPath}/checkout?bookingId=${booking.id}"
                                               class="btn btn-sm btn-success rounded-pill px-3 shadow-sm font-weight-bold">
                                                <i class="fa fa-credit-card mr-1"></i> Thanh toán ngay
                                            </a>
                                        </c:if>

                                        <!-- Cancel & Refund Request button: available for CONFIRMED bookings without pending refund -->
                                        <c:if test="${booking.status == 'CONFIRMED' && (empty booking.refund || booking.refund.status == 'REJECTED')}">
                                            <button type="button" class="btn btn-sm btn-outline-danger rounded-pill px-3 font-weight-bold"
                                                    onclick="openRefundModal(${booking.id}, '${booking.bookingCode}', '${booking.propertyName}', '${booking.totalAmount}')">
                                                <i class="fa fa-undo mr-1"></i> Yêu cầu hủy & hoàn tiền
                                            </button>
                                        </c:if>

                                        <!-- Refund Tracking button: available whenever a refund record exists -->
                                        <c:if test="${not empty booking.refund}">
                                            <button type="button" class="btn btn-sm btn-outline-info rounded-pill px-3 font-weight-bold ml-1"
                                                    onclick="openTrackingModal(${booking.id})">
                                                <i class="fa fa-line-chart mr-1"></i> Theo dõi hoàn tiền
                                            </button>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
</div>

<!-- ========================================== -->
<!-- MODAL 1: REQUEST CANCELLATION & REFUND      -->
<!-- ========================================== -->
<div class="modal fade" id="refundRequestModal" tabindex="-1" role="dialog" aria-labelledby="refundModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px; overflow: hidden;">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title font-weight-bold" id="refundModalTitle">
                    <i class="fa fa-undo mr-2"></i>Yêu Cầu Hủy Phòng & Hoàn Tiền
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <form id="refundForm" action="${pageContext.request.contextPath}/refund/request" method="post">
                <input type="hidden" name="bookingId" id="modalBookingId" />
                <div class="modal-body p-4">
                    <div class="alert alert-warning py-2 mb-3" style="font-size: 13px;">
                        <i class="fa fa-info-circle mr-1"></i> Sau khi bạn gửi yêu cầu, Host sẽ xem xét và thực hiện chuyển tiền hoàn về tài khoản ngân hàng của bạn.
                    </div>

                    <div class="bg-light p-3 rounded mb-3">
                        <div class="d-flex justify-content-between mb-1">
                            <span class="text-muted" style="font-size: 13px;">Mã đặt phòng:</span>
                            <strong id="modalBookingCode" class="text-dark font-monospace">-</strong>
                        </div>
                        <div class="d-flex justify-content-between mb-1">
                            <span class="text-muted" style="font-size: 13px;">Cơ sở lưu trú:</span>
                            <strong id="modalPropertyName" class="text-dark">-</strong>
                        </div>
                        <div class="d-flex justify-content-between">
                            <span class="text-muted" style="font-size: 13px;">Số tiền hoàn dự kiến:</span>
                            <strong id="modalTotalAmount" class="text-danger font-weight-bold" style="font-size: 16px;">-</strong>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="font-weight-bold text-dark" style="font-size: 13px;">Lý do hủy phòng <span class="text-danger">*</span></label>
                        <textarea name="reason" class="form-control" rows="2" placeholder="Ví dụ: Thay đổi kế hoạch cá nhân, bận việc đột xuất..." required></textarea>
                    </div>

                    <h6 class="font-weight-bold text-dark mt-3 mb-2" style="font-size: 14px;">
                        <i class="fa fa-university mr-1 text-primary"></i> Thông Tin Nhận Tiền Hoàn
                    </h6>

                    <div class="form-group mb-2">
                        <label class="text-muted mb-1" style="font-size: 12px;">Ngân hàng thụ hưởng <span class="text-danger">*</span></label>
                        <select name="bankName" class="form-control" required>
                            <option value="">-- Chọn ngân hàng --</option>
                            <option value="Vietcombank">Vietcombank (VCB)</option>
                            <option value="MBBank">MBBank (Ngân hàng Quân Đội)</option>
                            <option value="TPBank">TPBank (Tiên Phong)</option>
                            <option value="Techcombank">Techcombank (TCB)</option>
                            <option value="BIDV">BIDV</option>
                            <option value="Agribank">Agribank</option>
                            <option value="VietinBank">VietinBank</option>
                            <option value="VPBank">VPBank</option>
                            <option value="ACB">ACB</option>
                            <option value="OCB">OCB</option>
                            <option value="Sacombank">Sacombank</option>
                            <option value="MoMo">Ví MoMo</option>
                        </select>
                    </div>

                    <div class="form-row">
                        <div class="col-md-6 form-group mb-2">
                            <label class="text-muted mb-1" style="font-size: 12px;">Số tài khoản / SĐT MoMo <span class="text-danger">*</span></label>
                            <input type="text" name="accountNumber" class="form-control" placeholder="Ví dụ: 0914690031" required />
                        </div>
                        <div class="col-md-6 form-group mb-2">
                            <label class="text-muted mb-1" style="font-size: 12px;">Tên chủ tài khoản <span class="text-danger">*</span></label>
                            <input type="text" name="accountHolder" class="form-control" placeholder="NGUYEN THANH HAI" style="text-transform: uppercase;" required />
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-danger rounded-pill px-4 font-weight-bold">
                        <i class="fa fa-paper-plane mr-1"></i> Gửi Yêu Cầu
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ========================================== -->
<!-- MODAL 2: REFUND TRACKING TIMELINE          -->
<!-- ========================================== -->
<div class="modal fade" id="refundTrackingModal" tabindex="-1" role="dialog" aria-labelledby="trackingModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px; overflow: hidden;">
            <div class="modal-header bg-dark text-white">
                <h5 class="modal-title font-weight-bold" id="trackingModalTitle">
                    <i class="fa fa-line-chart mr-2 text-info"></i>Tiến Trình Hoàn Tiền
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body p-4">
                <div id="trackingLoading" class="text-center py-4">
                    <i class="fa fa-spinner fa-spin fa-2x text-primary mb-2"></i>
                    <p class="text-muted mb-0">Đang tải thông tin tiến trình...</p>
                </div>

                <div id="trackingDetails" style="display: none;">
                    <div class="d-flex justify-content-between align-items-center mb-3 pb-2 border-bottom">
                        <div>
                            <span class="text-muted" style="font-size: 13px;">Mã đơn:</span>
                            <span id="trackBookingCode" class="font-weight-bold text-dark font-monospace ml-1"></span>
                        </div>
                        <div id="trackStatusBadge"></div>
                    </div>

                    <!-- STEPPER -->
                    <div class="refund-stepper">
                        <!-- Step 1 -->
                        <div class="stepper-item completed">
                            <div class="stepper-icon"><i class="fa fa-check"></i></div>
                            <div class="stepper-content">
                                <h6 class="font-weight-bold mb-1 text-dark">1. Gửi yêu cầu hoàn tiền</h6>
                                <p class="text-muted mb-0" style="font-size: 12px;">Khách hàng gửi yêu cầu hủy và hoàn tiền.</p>
                                <span id="trackCreatedAt" class="text-muted font-italic" style="font-size: 11px;"></span>
                            </div>
                        </div>

                        <!-- Step 2 -->
                        <div class="stepper-item" id="step2Item">
                            <div class="stepper-icon" id="step2Icon">2</div>
                            <div class="stepper-content">
                                <h6 class="font-weight-bold mb-1 text-dark" id="step2Title">2. Host xem xét & phê duyệt</h6>
                                <p class="text-muted mb-0" style="font-size: 12px;" id="step2Desc">Đang chờ Host kiểm tra thông tin và chính sách hủy phòng.</p>
                                <div id="trackHostNoteBox" class="mt-2 p-2 bg-light rounded" style="display:none; font-size: 12px;">
                                    <strong>Phản hồi từ Host:</strong> <span id="trackHostNote"></span>
                                </div>
                            </div>
                        </div>

                        <!-- Step 3 -->
                        <div class="stepper-item" id="step3Item">
                            <div class="stepper-icon" id="step3Icon">3</div>
                            <div class="stepper-content">
                                <h6 class="font-weight-bold mb-1 text-dark" id="step3Title">3. Hoàn tất tiền hoàn</h6>
                                <p class="text-muted mb-0" style="font-size: 12px;" id="step3Desc">Tiền được chuyển về tài khoản ngân hàng của bạn.</p>
                                <span id="trackCompletedAt" class="text-muted font-italic" style="font-size: 11px;"></span>
                            </div>
                        </div>
                    </div>

                    <!-- Bank details info box -->
                    <div class="bg-light p-3 rounded mt-3">
                        <div class="d-flex justify-content-between mb-1" style="font-size: 13px;">
                            <span class="text-muted">Số tiền hoàn:</span>
                            <span id="trackAmount" class="font-weight-bold text-danger"></span>
                        </div>
                        <div class="d-flex justify-content-between mb-1" style="font-size: 13px;">
                            <span class="text-muted">Tài khoản nhận:</span>
                            <span id="trackBankInfo" class="font-weight-bold text-dark"></span>
                        </div>
                        <div class="d-flex justify-content-between" style="font-size: 13px;">
                            <span class="text-muted">Lý do hủy:</span>
                            <span id="trackReason" class="text-dark"></span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer bg-light">
                <button type="button" class="btn btn-secondary rounded-pill px-4" data-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="common/footer.jsp" />

<script>
    function openRefundModal(bookingId, bookingCode, propertyName, totalAmount) {
        document.getElementById('modalBookingId').value = bookingId;
        document.getElementById('modalBookingCode').textContent = bookingCode;
        document.getElementById('modalPropertyName').textContent = propertyName;
        
        var formatted = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(totalAmount);
        document.getElementById('modalTotalAmount').textContent = formatted;
        
        $('#refundRequestModal').modal('show');
    }

    function openTrackingModal(bookingId) {
        $('#refundTrackingModal').modal('show');
        document.getElementById('trackingLoading').style.display = 'block';
        document.getElementById('trackingDetails').style.display = 'none';

        fetch('${pageContext.request.contextPath}/refund/status?bookingId=' + bookingId)
            .then(function(res) { return res.json(); })
            .then(function(data) {
                document.getElementById('trackingLoading').style.display = 'none';
                document.getElementById('trackingDetails').style.display = 'block';

                document.getElementById('trackBookingCode').textContent = data.bookingCode;
                var formattedAmount = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(data.amount);
                document.getElementById('trackAmount').textContent = formattedAmount;
                document.getElementById('trackBankInfo').textContent = data.customerBankInfo || 'Chưa cung cấp';
                document.getElementById('trackReason').textContent = data.reason || 'N/A';
                document.getElementById('trackCreatedAt').textContent = 'Thời gian gửi: ' + (data.createdAt || '');

                var statusBadge = document.getElementById('trackStatusBadge');
                var step2Item = document.getElementById('step2Item');
                var step2Icon = document.getElementById('step2Icon');
                var step3Item = document.getElementById('step3Item');
                var step3Icon = document.getElementById('step3Icon');
                var hostNoteBox = document.getElementById('trackHostNoteBox');
                var hostNoteSpan = document.getElementById('trackHostNote');

                if (data.hostNote) {
                    hostNoteBox.style.display = 'block';
                    hostNoteSpan.textContent = data.hostNote;
                } else {
                    hostNoteBox.style.display = 'none';
                }

                if (data.status === 'REQUESTED') {
                    statusBadge.innerHTML = '<span class="badge badge-warning px-3 py-1 font-weight-bold">ĐANG CHỜ DUYỆT</span>';
                    step2Item.className = 'stepper-item current';
                    step2Icon.innerHTML = '<i class="fa fa-clock-o"></i>';
                    step3Item.className = 'stepper-item';
                    step3Icon.textContent = '3';
                    document.getElementById('trackCompletedAt').textContent = '';
                } else if (data.status === 'APPROVED' || data.status === 'SUCCEEDED') {
                    statusBadge.innerHTML = '<span class="badge badge-success px-3 py-1 font-weight-bold">ĐÃ HOÀN TIỀN</span>';
                    step2Item.className = 'stepper-item completed';
                    step2Icon.innerHTML = '<i class="fa fa-check"></i>';
                    step3Item.className = 'stepper-item completed';
                    step3Icon.innerHTML = '<i class="fa fa-check"></i>';
                    document.getElementById('step3Desc').textContent = 'Host đã xác nhận và trừ tiền từ Ví Host hoàn về tài khoản ngân hàng của bạn thành công.';
                    document.getElementById('trackCompletedAt').textContent = 'Hoàn tất lúc: ' + (data.completedAt || '');
                } else if (data.status === 'REJECTED') {
                    statusBadge.innerHTML = '<span class="badge badge-danger px-3 py-1 font-weight-bold">TỪ CHỐI HOÀN TIỀN</span>';
                    step2Item.className = 'stepper-item rejected';
                    step2Icon.innerHTML = '<i class="fa fa-times"></i>';
                    document.getElementById('step2Title').textContent = '2. Host đã từ chối yêu cầu';
                    step3Item.className = 'stepper-item';
                    step3Icon.textContent = '3';
                    document.getElementById('step3Desc').textContent = 'Yêu cầu không được phê duyệt.';
                    document.getElementById('trackCompletedAt').textContent = '';
                }
            })
            .catch(function(err) {
                document.getElementById('trackingLoading').innerHTML = '<div class="alert alert-danger mb-0">Không thể tải thông tin hoàn tiền: ' + err + '</div>';
            });
    }
</script>

<jsp:include page="common/footer.jsp" />
