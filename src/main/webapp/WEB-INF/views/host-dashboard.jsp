<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%-- Host Dashboard: Dynamic real-time revenue analytics, recent reservations, and property inventory. --%>
<%-- Shared page header and navigation. --%>
<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Host Dashboard - Doanh Thu & Đặt Phòng - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<style>
  /* Header ở Light Mode cho Host Dashboard */
  html:not([data-theme="dark"]) .site-header,
  body:not([data-theme="dark"]) .site-header {
    background: #ffffff !important;
    padding: 14px 0 !important;
    box-shadow: 0 2px 16px rgba(0, 0, 0, 0.08) !important;
    position: fixed !important;
    top: 0 !important;
    left: 0 !important;
    width: 100% !important;
    z-index: 1030 !important;
  }
  html:not([data-theme="dark"]) .site-header .site-logo a {
    color: #1a1a1a !important;
  }
  html:not([data-theme="dark"]) .site-header .site-menu-toggle span {
    background: #1a1a1a !important;
  }
  html:not([data-theme="dark"]) .site-header .user-name {
    color: #1a1a1a !important;
  }
  html:not([data-theme="dark"]) .site-header .user-caret {
    color: #1a1a1a !important;
  }
  html:not([data-theme="dark"]) .site-header .auth-link:not(.auth-link-primary) {
    color: #202b32 !important;
  }
  html:not([data-theme="dark"]) .site-header .auth-link:not(.auth-link-primary):hover {
    color: #f59e0b !important;
  }
  html:not([data-theme="dark"]) .site-header .auth-divider {
    color: rgba(32, 43, 50, 0.3) !important;
  }
  html:not([data-theme="dark"]) .site-header .user-menu-toggle {
    background: #f8f9fa !important;
    border-color: #e9ecef !important;
  }
  html:not([data-theme="dark"]) .site-header .user-menu-toggle:hover {
    background: #eef2f7 !important;
    border-color: #f59e0b !important;
  }
  html:not([data-theme="dark"]) .site-header .header-wishlist-link {
    color: #202b32 !important;
  }

  /* Header ở Dark Mode (Night Mode) cho Host Dashboard */
  [data-theme="dark"] .site-header {
    background: #0f172a !important;
    border-bottom: 1px solid #334155 !important;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5) !important;
    position: fixed !important;
    top: 0 !important;
    left: 0 !important;
    width: 100% !important;
    z-index: 1030 !important;
  }
  [data-theme="dark"] .site-header .site-logo a {
    color: #f8fafc !important;
  }
  [data-theme="dark"] .site-header .site-menu-toggle span {
    background: #f8fafc !important;
  }
  [data-theme="dark"] .site-header .auth-link:not(.auth-link-primary) {
    color: #cbd5e1 !important;
  }
  [data-theme="dark"] .site-header .auth-link:not(.auth-link-primary):hover {
    color: #f59e0b !important;
  }
  [data-theme="dark"] .site-header .auth-divider {
    color: #334155 !important;
  }
  [data-theme="dark"] .site-header .user-menu-toggle {
    background: rgba(255, 255, 255, 0.08) !important;
    border: 1px solid rgba(255, 255, 255, 0.16) !important;
  }
  [data-theme="dark"] .site-header .user-menu-toggle:hover {
    background: rgba(255, 255, 255, 0.15) !important;
    border-color: #f59e0b !important;
  }
  [data-theme="dark"] .site-header .user-name {
    color: #f8fafc !important;
  }
  [data-theme="dark"] .site-header .user-caret {
    color: #94a3b8 !important;
  }
  [data-theme="dark"] .site-header .header-wishlist-link {
    background: rgba(255, 255, 255, 0.08) !important;
    color: #f43f5e !important;
  }

  /* Host Dashboard Dark Mode Container & Cards */
  [data-theme="dark"] .host-dashboard-wrapper {
    background-color: var(--bg-body, #0b1120) !important;
  }
  [data-theme="dark"] .stat-card,
  [data-theme="dark"] .chart-card,
  [data-theme="dark"] .property-box {
    background: var(--bg-card, #1e293b) !important;
    border: 1px solid var(--border-color, #334155) !important;
  }
  [data-theme="dark"] .stat-value {
    color: var(--text-heading, #f8fafc) !important;
  }
  [data-theme="dark"] .stat-label {
    color: var(--text-muted, #94a3b8) !important;
  }

  .host-dashboard-wrapper {
    background-color: #f8fafc;
    padding-top: 125px !important;
    padding-bottom: 70px;
    min-height: 85vh;
  }
  .stat-card {
    background: #ffffff;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
    border: 1px solid #edf2f7;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    height: 100%;
  }
  .stat-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  }
  .stat-icon {
    width: 48px;
    height: 48px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
  }
  .stat-icon-revenue {
    background: #fff8eb;
    color: #f7a840;
  }
  .stat-icon-bookings {
    background: #eef2ff;
    color: #4f46e5;
  }
  .stat-icon-stays {
    background: #ecfdf5;
    color: #10b981;
  }
  .stat-icon-properties {
    background: #eff6ff;
    color: #3b82f6;
  }
  .stat-value {
    font-size: 26px;
    font-weight: 700;
    color: #1e293b;
    margin-top: 12px;
    margin-bottom: 4px;
    line-height: 1.2;
  }
  .stat-label {
    font-size: 13px;
    font-weight: 600;
    color: #64748b;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }
  .stat-badge {
    font-size: 12px;
    padding: 2px 8px;
    border-radius: 20px;
    font-weight: 600;
  }
  .chart-card {
    background: #ffffff;
    border-radius: 12px;
    padding: 28px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
    border: 1px solid #edf2f7;
    margin-bottom: 30px;
  }
  .table-custom {
    margin-bottom: 0;
  }
  .table-custom th {
    background-color: #f8fafc;
    color: #475569;
    font-weight: 600;
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    border-top: none;
    border-bottom: 1px solid #e2e8f0;
    padding: 14px 16px;
  }
  .table-custom td {
    vertical-align: middle;
    padding: 16px;
    border-top: 1px solid #f1f5f9;
    color: #334155;
    font-size: 14px;
  }
  .badge-status {
    padding: 6px 14px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    white-space: nowrap;
    display: inline-block;
  }
  .badge-status-completed {
    background-color: #d1fae5;
    color: #065f46;
  }
  .badge-status-confirmed {
    background-color: #dbeafe;
    color: #1e40af;
  }
  .badge-status-pending {
    background-color: #fef3c7;
    color: #92400e;
  }
  .badge-status-cancelled {
    background-color: #fee2e2;
    color: #991b1b;
  }
  .property-box {
    border-radius: 10px;
    border: 1px solid #e2e8f0;
    padding: 20px;
    background: #ffffff;
    margin-bottom: 20px;
    transition: border-color 0.2s ease;
  }
  .property-box:hover {
    border-color: #cbd5e1;
  }

  /* Booking Row & Modal Interaction */
  .booking-row {
    cursor: pointer;
    transition: background-color 0.15s ease-in-out;
  }
  .booking-row:hover {
    background-color: rgba(245, 158, 11, 0.08) !important;
  }
  .booking-code-link {
    text-decoration: none;
    transition: color 0.15s;
  }
  .booking-code-link:hover {
    text-decoration: underline;
    color: #d97706 !important;
  }

  .booking-detail-modal .modal-content {
    border-radius: 12px;
    overflow: hidden;
  }
  .booking-summary-banner {
    background-color: #f8fafc;
  }
  .booking-detail-card {
    background-color: #ffffff;
  }

  /* Night Mode Adaptations */
  [data-theme="dark"] .booking-row:hover {
    background-color: rgba(245, 158, 11, 0.15) !important;
  }
  [data-theme="dark"] .booking-detail-modal .modal-content {
    background-color: #141d2b !important;
    color: #e2e8f0 !important;
    border-color: #24354b !important;
    box-shadow: 0 20px 45px rgba(0, 0, 0, 0.7) !important;
  }
  [data-theme="dark"] .booking-detail-modal .modal-header,
  [data-theme="dark"] .booking-detail-modal .modal-footer {
    border-color: #24354b !important;
    background-color: #162032 !important;
  }
  [data-theme="dark"] .booking-detail-modal .modal-title,
  [data-theme="dark"] .booking-detail-modal h6,
  [data-theme="dark"] .booking-detail-modal .text-dark {
    color: #f1f5f9 !important;
  }
  [data-theme="dark"] .booking-detail-modal .close {
    color: #cbd5e1 !important;
  }
  [data-theme="dark"] .booking-detail-modal .booking-summary-banner {
    background-color: #182337 !important;
    border-color: #2a3d5a !important;
  }
  [data-theme="dark"] .booking-detail-modal .booking-detail-card {
    background-color: #162032 !important;
    border-color: #24354b !important;
  }
  [data-theme="dark"] .booking-detail-modal .bg-light {
    background-color: #111a28 !important;
    border-color: #24354b !important;
    color: #cbd5e1 !important;
  }
  [data-theme="dark"] .booking-detail-modal .stay-period-box {
    background-color: #111a28 !important;
    border-color: #2a3d5a !important;
  }
  [data-theme="dark"] .booking-detail-modal .thead-light th {
    background-color: #182337 !important;
    color: #e2e8f0 !important;
    border-color: #24354b !important;
  }
  [data-theme="dark"] .booking-detail-modal .table-striped tbody tr:nth-of-type(odd) {
    background-color: rgba(255, 255, 255, 0.03) !important;
  }
  [data-theme="dark"] .booking-detail-modal .table td,
  [data-theme="dark"] .booking-detail-modal .table th {
    border-color: #24354b !important;
    color: #cbd5e1 !important;
  }

  /* Edit Room Modal & Card Styling */
  .room-inventory-card {
    transition: transform 0.15s ease, box-shadow 0.15s ease, border-color 0.15s ease;
  }
  .room-inventory-card:hover {
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
    border-color: #cbd5e1 !important;
  }
  .edit-room-modal .modal-content {
    border-radius: 12px;
    overflow: hidden;
  }
  .edit-room-modal .input-group-text {
    font-size: 13px;
    background-color: #f1f5f9;
    border-color: #cbd5e1;
    color: #475569;
  }

  /* Night Mode Adaptations for Edit Modal */
  [data-theme="dark"] .room-inventory-card {
    background-color: #111a28 !important;
    border-color: #24354b !important;
  }
  [data-theme="dark"] .room-inventory-card strong.text-dark {
    color: #f8fafc !important;
  }
  [data-theme="dark"] .edit-room-modal .modal-content {
    background-color: #141d2b !important;
    color: #e2e8f0 !important;
    border-color: #24354b !important;
    box-shadow: 0 20px 45px rgba(0, 0, 0, 0.7) !important;
  }
  [data-theme="dark"] .edit-room-modal .modal-header,
  [data-theme="dark"] .edit-room-modal .modal-footer {
    border-color: #24354b !important;
    background-color: #162032 !important;
  }
  [data-theme="dark"] .edit-room-modal .modal-title,
  [data-theme="dark"] .edit-room-modal label,
  [data-theme="dark"] .edit-room-modal .text-dark {
    color: #f1f5f9 !important;
  }
  [data-theme="dark"] .edit-room-modal .close {
    color: #cbd5e1 !important;
  }
  [data-theme="dark"] .edit-room-modal .form-control,
  [data-theme="dark"] .edit-room-modal .custom-select {
    background-color: #0d1522 !important;
    border-color: #2a3d5a !important;
    color: #f1f5f9 !important;
  }
  [data-theme="dark"] .edit-room-modal .form-control:focus,
  [data-theme="dark"] .edit-room-modal .custom-select:focus {
    border-color: #f59e0b !important;
    box-shadow: 0 0 0 0.2rem rgba(245, 158, 11, 0.25) !important;
  }
  [data-theme="dark"] .edit-room-modal .input-group-text {
    background-color: #182337 !important;
    border-color: #2a3d5a !important;
    color: #94a3b8 !important;
  }
  [data-theme="dark"] .edit-room-modal .custom-control-label {
    color: #cbd5e1 !important;
  }

</style>

<%-- Main Dashboard Section --%>
<main class="host-dashboard-wrapper">
  <div class="container">
    
    <%-- Top Welcome & Header Banner --%>
    <div class="row align-items-center mb-4">
      <div class="col-md-8">
        <span class="badge badge-warning text-uppercase px-3 py-1 mb-2 font-weight-bold" style="background:#fef3c7; color:#92400e;">
          Đối tác Homestay chính thức
        </span>
        <h1 class="h2 font-weight-bold text-dark mb-1">
          Bảng điều khiển & Doanh thu
        </h1>
        <p class="text-muted mb-0">
          Xin chào, <strong><c:out value="${hostName}" /></strong>! Dưới đây là phân tích doanh thu và các đơn đặt phòng mới nhất của bạn.
        </p>
      </div>
      <div class="col-md-4 text-md-right mt-3 mt-md-0 d-flex flex-column align-items-md-end justify-content-center">
        <div class="d-flex flex-wrap justify-content-md-end mb-2">
          <a href="${pageContext.request.contextPath}/host/calendar" class="btn btn-primary font-weight-bold px-3 py-2 shadow-sm mr-2 mb-1" style="background:#2563eb; border-color:#1d4ed8; color:#ffffff;">
            <i class="fa fa-calendar-check-o mr-1"></i> Lịch Đặt Phòng
          </a>
          <a href="${pageContext.request.contextPath}/host/vouchers" class="btn btn-warning font-weight-bold px-3 py-2 shadow-sm mb-1" style="background:#f59e0b; border-color:#d97706; color:#ffffff;">
            <i class="fa fa-ticket mr-1"></i> Quản lý Voucher
          </a>
        </div>
        <div>
          <span class="text-muted small">Dữ liệu năm: </span>
          <span class="font-weight-bold text-primary"><c:out value="${currentYear}" /></span>
        </div>
      </div>
    </div>

    
    <%-- Thông Báo Trạng Thái Thao Tác --%>
    <c:if test="${not empty sessionScope.messageSuccess}">
      <div class="alert alert-success alert-dismissible fade show shadow-sm mb-4" role="alert">
        <div class="d-flex align-items-center">
          <i class="fa fa-check-circle fa-lg mr-2 text-success"></i>
          <div><c:out value="${sessionScope.messageSuccess}" /></div>
        </div>
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <c:remove var="messageSuccess" scope="session" />
    </c:if>

    <c:if test="${not empty sessionScope.messageError}">
      <div class="alert alert-danger alert-dismissible fade show shadow-sm mb-4" role="alert">
        <div class="d-flex align-items-center">
          <i class="fa fa-exclamation-triangle fa-lg mr-2 text-danger"></i>
          <div><c:out value="${sessionScope.messageError}" /></div>
        </div>
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <c:remove var="messageError" scope="session" />
    </c:if>

    <c:choose>
      <%-- Case 1: Approved Host with Dynamic Revenue & Operations --%>
      <c:when test="${applicationApproved}">

        <%-- Row 1: KPI Statistic Summary Cards --%>
        <div class="row mb-4">
          <%-- Card 1: Total Revenue --%>
          <div class="col-sm-6 col-lg-3 mb-3 mb-lg-0">
            <div class="stat-card">
              <div class="d-flex justify-content-between align-items-center">
                <span class="stat-label">Tổng doanh thu</span>
                <div class="stat-icon stat-icon-revenue">
                  <i class="fa fa-money" aria-hidden="true"></i>
                </div>
              </div>
              <div class="stat-value text-primary">
                <fmt:formatNumber value="${totalRevenue}" pattern="#,##0" /> ₫
              </div>
              <div class="d-flex align-items-center mt-2">
                <span class="stat-badge bg-success text-white mr-2">Thời gian thực</span>
                <small class="text-muted">Đơn đã xác nhận & xong</small>
              </div>
            </div>
          </div>

          <%-- Card 2: Total Bookings --%>
          <div class="col-sm-6 col-lg-3 mb-3 mb-lg-0">
            <div class="stat-card">
              <div class="d-flex justify-content-between align-items-center">
                <span class="stat-label">Lượt đặt phòng</span>
                <div class="stat-icon stat-icon-bookings">
                  <i class="fa fa-calendar-check-o" aria-hidden="true"></i>
                </div>
              </div>
              <div class="stat-value">
                <c:out value="${totalBookings}" />
              </div>
              <div class="d-flex align-items-center mt-2">
                <small class="text-muted">Tổng đơn khách đã đặt</small>
              </div>
            </div>
          </div>

          <%-- Card 3: Completed Stays --%>
          <div class="col-sm-6 col-lg-3 mb-3 mb-lg-0">
            <div class="stat-card">
              <div class="d-flex justify-content-between align-items-center">
                <span class="stat-label">Đã hoàn thành</span>
                <div class="stat-icon stat-icon-stays">
                  <i class="fa fa-check-circle-o" aria-hidden="true"></i>
                </div>
              </div>
              <div class="stat-value">
                <c:out value="${completedStays}" />
              </div>
              <div class="d-flex align-items-center mt-2">
                <small class="text-muted">Khách đã trả phòng</small>
              </div>
            </div>
          </div>

          <%-- Card 4: Properties & Rooms --%>
          <div class="col-sm-6 col-lg-3 mb-3 mb-lg-0">
            <div class="stat-card">
              <div class="d-flex justify-content-between align-items-center">
                <span class="stat-label">Cơ sở Homestay</span>
                <div class="stat-icon stat-icon-properties">
                  <i class="fa fa-building-o" aria-hidden="true"></i>
                </div>
              </div>
              <div class="stat-value">
                <c:out value="${properties.size()}" />
              </div>
              <div class="d-flex align-items-center mt-2">
                <small class="text-muted">Đang mở đón khách</small>
              </div>
            </div>
          </div>
        </div>

        <%-- Row 2: Dynamic Monthly Revenue Chart --%>
        <div class="chart-card">
          <div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
            <div>
              <h3 class="h5 font-weight-bold mb-1">
                Biểu đồ Doanh Thu Theo Tháng (<c:out value="${currentYear}" />)
              </h3>
              <p class="text-muted small mb-0">
                Dữ liệu biến động doanh thu thực tế được tổng hợp tự động từ các đơn đặt phòng của bạn.
              </p>
            </div>
            <div class="mt-2 mt-sm-0">
              <span class="badge badge-light border px-3 py-2 text-muted">
                Đơn vị: VNĐ
              </span>
            </div>
          </div>

          <div style="position: relative; height: 320px; width: 100%;">
            <canvas id="revenueChart"></canvas>
          </div>
        </div>

        <%-- Row 3: Recent Bookings Table --%>
        <div class="chart-card p-0 overflow-hidden mb-4">
          <div class="p-4 border-bottom d-flex justify-content-between align-items-center">
            <div>
              <h3 class="h5 font-weight-bold mb-1">Đơn Đặt Phòng Gần Đây</h3>
              <p class="text-muted small mb-0">Các đơn đặt phòng mới nhất cần theo dõi tiếp đón khách</p>
            </div>
            <span class="badge badge-primary px-3 py-2">
              <c:out value="${recentBookings.size()}" /> đơn mới nhất
            </span>
          </div>

          <div class="table-responsive">
            <table class="table table-custom table-hover mb-0">
              <thead>
                <tr>
                  <th>Mã đơn</th>
                  <th>Khách hàng</th>
                  <th>Phòng homestay</th>
                  <th>Thời gian lưu trú</th>
                  <th>Số khách</th>
                  <th>Tổng tiền</th>
                  <th>Trạng thái</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="booking" items="${recentBookings}">
                  <tr class="booking-row" 
                      data-toggle="modal" 
                      data-target="#bookingDetailModal${booking.id}"
                      title="Nhấn để xem chi tiết đơn phòng #${booking.bookingCode}">
                    <td>
                      <a href="javascript:void(0)" class="font-weight-bold text-primary font-monospace booking-code-link text-nowrap"
                         data-toggle="modal" data-target="#bookingDetailModal${booking.id}">
                        <i class="fa fa-ticket mr-1 text-muted"></i><c:out value="${booking.bookingCode}" />
                      </a>
                      <div class="small text-muted">
                        <fmt:formatDate value="${booking.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                      </div>
                    </td>
                    <td>
                      <strong class="text-dark"><c:out value="${booking.customerName}" /></strong>
                      <c:if test="${not empty booking.customerPhone}">
                        <div class="small text-muted"><i class="fa fa-phone mr-1"></i><c:out value="${booking.customerPhone}" /></div>
                      </c:if>
                    </td>
                    <td>
                      <span class="text-dark font-weight-500"><c:out value="${booking.roomName}" /></span>
                      <div class="small text-muted"><i class="fa fa-building-o mr-1"></i><c:out value="${booking.propertyName}" /></div>
                    </td>
                    <td>
                      <fmt:formatDate value="${booking.checkInDate}" pattern="dd/MM/yyyy" />
                      <span class="text-muted">→</span>
                      <fmt:formatDate value="${booking.checkOutDate}" pattern="dd/MM/yyyy" />
                      <div class="small text-muted font-italic">${booking.numberOfNights} đêm</div>
                    </td>
                    <td>
                      <c:out value="${booking.guestCount}" /> người
                    </td>
                    <td>
                      <strong class="text-primary text-nowrap">
                        <fmt:formatNumber value="${booking.totalPrice}" pattern="#,##0" /> ₫
                      </strong>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${booking.status == 'COMPLETED'}">
                          <span class="badge-status badge-status-completed">Hoàn thành</span>
                        </c:when>
                        <c:when test="${booking.status == 'CONFIRMED'}">
                          <span class="badge-status badge-status-confirmed">Đã xác nhận</span>
                        </c:when>
                        <c:when test="${booking.status == 'PENDING'}">
                          <span class="badge-status badge-status-pending">Chờ duyệt</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge-status badge-status-cancelled"><c:out value="${booking.status}" /></span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty recentBookings}">
                  <tr>
                    <td colspan="7" class="text-center py-4 text-muted">
                      Chưa có đơn đặt phòng nào được ghi nhận cho các cơ sở của bạn.
                    </td>
                  </tr>
                </c:if>
              </tbody>
            </table>
          </div>

        <%-- Modal Chi Tiết Từng Đơn Đặt Phòng Cho Host --%>
        <c:forEach var="booking" items="${recentBookings}">
          <div class="modal fade booking-detail-modal text-left" id="bookingDetailModal${booking.id}" tabindex="-1" role="dialog" aria-labelledby="modalLabel${booking.id}" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
              <div class="modal-content shadow-lg">
                <div class="modal-header d-flex align-items-center justify-content-between pb-3">
                  <div class="d-flex align-items-center flex-wrap">
                    <h5 class="modal-title font-weight-bold mb-0 text-dark" id="modalLabel${booking.id}">
                      <i class="fa fa-id-card-o text-warning mr-2"></i>Chi Tiết Đơn Đặt Phòng
                    </h5>
                    <span class="badge badge-primary px-3 py-1 font-monospace ml-2 font-weight-bold" style="font-size: 13px;">
                      #<c:out value="${booking.bookingCode}" />
                    </span>
                  </div>
                  <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                  </button>
                </div>
                
                <div class="modal-body p-4">
                  <!-- Banner Tổng quan Trạng Thái & Ngày tạo & Tổng tiền -->
                  <div class="booking-summary-banner p-3 rounded mb-4 d-flex flex-wrap justify-content-between align-items-center border">
                    <div class="d-flex align-items-center mb-2 mb-md-0">
                      <div class="mr-3">
                        <c:choose>
                          <c:when test="${booking.status == 'COMPLETED'}">
                            <span class="badge badge-success px-3 py-2" style="font-size: 13px;"><i class="fa fa-check-circle mr-1"></i> Đã hoàn thành</span>
                          </c:when>
                          <c:when test="${booking.status == 'CONFIRMED'}">
                            <span class="badge badge-primary px-3 py-2" style="font-size: 13px;"><i class="fa fa-calendar-check-o mr-1"></i> Đã xác nhận</span>
                          </c:when>
                          <c:when test="${booking.status == 'PENDING'}">
                            <span class="badge badge-warning px-3 py-2 text-dark font-weight-bold" style="font-size: 13px;"><i class="fa fa-hourglass-half mr-1"></i> Đang chờ duyệt</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge badge-danger px-3 py-2" style="font-size: 13px;"><i class="fa fa-ban mr-1"></i> Đã hủy</span>
                          </c:otherwise>
                        </c:choose>
                      </div>
                      <div class="small text-muted">
                        <div><i class="fa fa-clock-o mr-1"></i> Ngày đặt: <strong><fmt:formatDate value="${booking.createdAt}" pattern="dd/MM/yyyy HH:mm" /></strong></div>
                      </div>
                    </div>
                    <div class="text-right">
                      <div class="small text-muted">Tổng thanh toán</div>
                      <div class="h4 font-weight-bold text-primary mb-0">
                        <fmt:formatNumber value="${booking.totalPrice}" pattern="#,##0" /> ₫
                      </div>
                    </div>
                  </div>

                  <!-- 2 Cột: Thông tin Khách hàng & Thông tin Homestay/Phòng -->
                  <div class="row">
                    <!-- Cột 1: Thông tin Khách hàng -->
                    <div class="col-md-6 mb-3">
                      <div class="booking-detail-card h-100 p-3 rounded border">
                        <h6 class="font-weight-bold text-dark border-bottom pb-2 mb-3">
                          <i class="fa fa-user-circle-o text-primary mr-2"></i>Thông Tin Khách Hàng
                        </h6>
                        <div class="info-group mb-2">
                          <span class="text-muted small d-block">Họ và tên khách:</span>
                          <strong class="text-dark font-weight-600"><c:out value="${booking.customerName}" /></strong>
                        </div>
                        <div class="info-group mb-2">
                          <span class="text-muted small d-block">Số điện thoại liên hệ:</span>
                          <c:choose>
                            <c:when test="${not empty booking.customerPhone}">
                              <a href="tel:${booking.customerPhone}" class="text-primary font-weight-500">
                                <i class="fa fa-phone text-success mr-1"></i><c:out value="${booking.customerPhone}" />
                              </a>
                            </c:when>
                            <c:otherwise>
                              <span class="text-muted italic">Chưa cập nhật</span>
                            </c:otherwise>
                          </c:choose>
                        </div>
                        <div class="info-group mb-2">
                          <span class="text-muted small d-block">Địa chỉ Email:</span>
                          <c:choose>
                            <c:when test="${not empty booking.customerEmail}">
                              <a href="mailto:${booking.customerEmail}" class="text-primary font-weight-500">
                                <i class="fa fa-envelope text-info mr-1"></i><c:out value="${booking.customerEmail}" />
                              </a>
                            </c:when>
                            <c:otherwise>
                              <span class="text-muted italic">Chưa cập nhật</span>
                            </c:otherwise>
                          </c:choose>
                        </div>
                        <div class="info-group mb-0">
                          <span class="text-muted small d-block">Số lượng khách lưu trú:</span>
                          <span class="font-weight-bold text-dark">
                            <i class="fa fa-users text-warning mr-1"></i><c:out value="${booking.guestCount}" /> khách
                            <small class="text-muted">(${booking.adults} người lớn, ${booking.children} trẻ em)</small>
                          </span>
                        </div>
                      </div>
                    </div>

                    <!-- Cột 2: Thông tin Phòng Homestay & Thời gian lưu trú -->
                    <div class="col-md-6 mb-3">
                      <div class="booking-detail-card h-100 p-3 rounded border">
                        <h6 class="font-weight-bold text-dark border-bottom pb-2 mb-3">
                          <i class="fa fa-home text-warning mr-2"></i>Thông Tin Homestay & Phòng
                        </h6>
                        <div class="d-flex align-items-center mb-3">
                          <img src="${pageContext.request.contextPath}/assets/${not empty booking.roomImageUrl ? booking.roomImageUrl : 'images/img_1.jpg'}"
                               alt="${booking.roomName}" 
                               class="rounded mr-3 border shadow-sm"
                               style="width: 70px; height: 70px; object-fit: cover;"
                               onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/img_1.jpg';">
                          <div>
                            <div class="font-weight-bold text-dark"><c:out value="${booking.roomName}" /></div>
                            <c:if test="${not empty booking.roomNumber}">
                              <span class="badge badge-secondary px-2 py-1 small">Mã phòng: <c:out value="${booking.roomNumber}" /></span>
                            </c:if>
                            <div class="small text-muted mt-1"><i class="fa fa-building-o mr-1"></i><c:out value="${booking.propertyName}" /></div>
                          </div>
                        </div>

                        <c:if test="${not empty booking.propertyAddress}">
                          <div class="info-group mb-2">
                            <span class="text-muted small d-block">Địa chỉ homestay:</span>
                            <span class="small text-dark"><i class="fa fa-map-marker text-danger mr-1"></i><c:out value="${booking.propertyAddress}" /></span>
                          </div>
                        </c:if>

                        <div class="p-2 rounded bg-light border stay-period-box mt-2">
                          <div class="d-flex justify-content-between align-items-center mb-1">
                            <span class="small text-muted"><i class="fa fa-sign-in text-success mr-1"></i>Nhận phòng (Check-in):</span>
                            <strong class="text-dark small"><fmt:formatDate value="${booking.checkInDate}" pattern="dd/MM/yyyy" /> <span class="text-muted">(từ 14:00)</span></strong>
                          </div>
                          <div class="d-flex justify-content-between align-items-center mb-1">
                            <span class="small text-muted"><i class="fa fa-sign-out text-danger mr-1"></i>Trả phòng (Check-out):</span>
                            <strong class="text-dark small"><fmt:formatDate value="${booking.checkOutDate}" pattern="dd/MM/yyyy" /> <span class="text-muted">(trước 12:00)</span></strong>
                          </div>
                          <div class="d-flex justify-content-between align-items-center border-top pt-1 mt-1">
                            <span class="small text-muted">Thời gian lưu trú:</span>
                            <strong class="text-primary small">${booking.numberOfNights} đêm</strong>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- Danh sách phòng chi tiết nếu đơn có nhiều phòng -->
                  <c:if test="${not empty booking.bookingRooms and booking.bookingRooms.size() > 0}">
                    <div class="mb-3">
                      <h6 class="font-weight-bold text-dark mb-2">
                        <i class="fa fa-bed text-info mr-2"></i>Danh Sách Phòng Trong Đơn (${booking.bookingRooms.size()} phòng)
                      </h6>
                      <div class="table-responsive rounded border">
                        <table class="table table-sm table-striped mb-0">
                          <thead class="thead-light">
                            <tr>
                              <th>Phòng</th>
                              <th>Loại phòng</th>
                              <th>Số khách</th>
                              <th class="text-right">Đơn giá / đêm</th>
                              <th class="text-right">Số đêm</th>
                              <th class="text-right">Thành tiền</th>
                            </tr>
                          </thead>
                          <tbody>
                            <c:forEach var="item" items="${booking.bookingRooms}">
                              <tr>
                                <td>
                                  <strong><c:out value="${item.roomName}" /></strong>
                                </td>
                                <td><c:out value="${item.roomTypeName}" /></td>
                                <td><c:out value="${item.capacity}" /> khách</td>
                                <td class="text-right"><fmt:formatNumber value="${item.pricePerNight}" pattern="#,##0" /> ₫</td>
                                <td class="text-right">${item.numberOfNights}</td>
                                <td class="text-right font-weight-bold text-primary">
                                  <fmt:formatNumber value="${item.subtotal}" pattern="#,##0" /> ₫
                                </td>
                              </tr>
                            </c:forEach>
                          </tbody>
                        </table>
                      </div>
                    </div>
                  </c:if>

                  <!-- Ghi chú & Yêu cầu đặc biệt từ khách hàng -->
                  <div class="row">
                    <div class="col-md-6 mb-2">
                      <div class="p-3 rounded border h-100 bg-light">
                        <span class="small font-weight-bold text-dark d-block mb-1">
                          <i class="fa fa-pencil-square-o text-muted mr-1"></i>Ghi chú từ khách:
                        </span>
                        <div class="small text-muted">
                          <c:out value="${not empty booking.notes ? booking.notes : 'Không có ghi chú thêm.'}" />
                        </div>
                      </div>
                    </div>
                    <div class="col-md-6 mb-2">
                      <div class="p-3 rounded border h-100 bg-light">
                        <span class="small font-weight-bold text-dark d-block mb-1">
                          <i class="fa fa-bell-o text-muted mr-1"></i>Yêu cầu đặc biệt:
                        </span>
                        <div class="small text-muted">
                          <c:out value="${not empty booking.specialRequests ? booking.specialRequests : 'Không có yêu cầu đặc biệt.'}" />
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="modal-footer d-flex justify-content-between">
                  <div>
                    <c:if test="${not empty booking.customerPhone}">
                      <a href="tel:${booking.customerPhone}" class="btn btn-outline-success btn-sm">
                        <i class="fa fa-phone mr-1"></i>Gọi khách: <c:out value="${booking.customerPhone}" />
                      </a>
                    </c:if>
                    <c:if test="${not empty booking.customerEmail}">
                      <a href="mailto:${booking.customerEmail}" class="btn btn-outline-info btn-sm ml-1">
                        <i class="fa fa-envelope mr-1"></i>Gửi email
                      </a>
                    </c:if>
                  </div>
                  <button type="button" class="btn btn-secondary btn-sm px-4" data-dismiss="modal">
                    <i class="fa fa-times mr-1"></i>Đóng
                  </button>
                </div>
              </div>
            </div>
          </div>
        </c:forEach>
        </div>

        <%-- Row 4: Managed Properties & Rooms Inventory --%>
        <div class="chart-card">
          <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
              <h3 class="h5 font-weight-bold mb-1">Danh Sách Cơ Sở & Phòng</h3>
              <p class="text-muted small mb-0">Các cơ sở homestay và danh sách phòng thuộc quyền sở hữu của bạn</p>
            </div>
          </div>

          <c:forEach var="property" items="${properties}">
            <div class="property-box">
              <div class="d-flex flex-wrap justify-content-between align-items-center mb-2">
                <h4 class="h5 font-weight-bold text-dark mb-1">
                  <i class="fa fa-map-marker text-danger mr-2"></i><c:out value="${property.propertyName}" />
                </h4>
                <span class="badge badge-success px-3 py-1 font-weight-normal">
                  <c:out value="${property.status}" />
                </span>
              </div>
              <p class="text-muted small mb-3">
                <c:out value="${property.address}" />,
                <c:out value="${property.ward}" />,
                <c:out value="${property.district}" />,
                <c:out value="${property.city}" />
              </p>

              <div class="border-top pt-3">
                <h5 class="small font-weight-bold text-uppercase text-muted mb-3">Các phòng hiện có:</h5>
                <div class="row">
                  <c:forEach var="room" items="${property.rooms}">
                    <div class="col-md-6 mb-3">
                      <div class="p-3 bg-light rounded border h-100 d-flex flex-column justify-content-between room-inventory-card">
                        <div>
                          <div class="d-flex justify-content-between align-items-start">
                            <div>
                              <strong class="text-dark" style="font-size: 15px;"><c:out value="${room.roomName}" /></strong>
                              <span class="badge badge-secondary ml-1 font-weight-normal text-uppercase" style="font-size: 11px;">
                                <c:out value="${not empty room.roomTypeName ? room.roomTypeName : 'DOUBLE'}" />
                              </span>
                            </div>
                            <span class="text-primary font-weight-bold ml-2 text-nowrap">
                              <fmt:formatNumber value="${room.pricePerNight}" pattern="#,##0" /> ₫ <small class="text-muted font-weight-normal">/ đêm</small>
                            </span>
                          </div>
                          <div class="small text-muted mt-2">
                            <span class="mr-3"><i class="fa fa-users mr-1 text-primary"></i>Tối đa <strong><c:out value="${room.maxGuests}" /></strong> khách</span>
                            <span class="mr-3"><i class="fa fa-bed mr-1 text-info"></i><strong><c:out value="${room.bedCount}" /></strong> giường</span>
                            <span><i class="fa fa-bath mr-1 text-success"></i><strong><c:out value="${room.bathroomCount}" /></strong> phòng tắm</span>
                          </div>
                          <c:if test="${not empty room.amenities}">
                            <div class="small text-muted mt-2 border-top pt-2 d-flex flex-wrap align-items-center">
                              <span class="font-weight-bold mr-2"><i class="fa fa-check-circle-o mr-1 text-warning"></i>Tiện ích:</span>
                              <c:forEach var="amenity" items="${room.amenities}">
                                <span class="badge badge-light border mr-1 mb-1 font-weight-normal"><c:out value="${amenity}" /></span>
                              </c:forEach>
                            </div>
                          </c:if>
                        </div>

                        <div class="mt-3 pt-2 border-top d-flex justify-content-end align-items-center">
                          <a href="${pageContext.request.contextPath}/host/calendar?propertyId=${property.id}&roomId=${room.id}" class="btn btn-sm btn-outline-primary font-weight-bold px-3 mr-2 shadow-none">
                            <i class="fa fa-calendar mr-1"></i>Lịch phòng
                          </a>
                          <button type="button" class="btn btn-sm btn-outline-warning font-weight-bold px-3 shadow-none" 
                                  data-toggle="modal" data-target="#editRoomModal${room.id}">
                            <i class="fa fa-pencil mr-1"></i>Chỉnh sửa phòng
                          </button>
                        </div>
                      </div>
                    </div>

                    <!-- Modal Chỉnh Sửa Phòng -->
                    <div class="modal fade edit-room-modal text-left" id="editRoomModal${room.id}" tabindex="-1" role="dialog" aria-labelledby="editRoomModalLabel${room.id}" aria-hidden="true">
                      <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
                        <div class="modal-content shadow-lg">
                          <form action="${pageContext.request.contextPath}/host/dashboard" method="post">
                            <input type="hidden" name="action" value="editRoom" />
                            <input type="hidden" name="propertyId" value="${property.id}" />
                            <input type="hidden" name="roomId" value="${room.id}" />

                            <div class="modal-header d-flex align-items-center justify-content-between pb-3">
                              <div class="d-flex align-items-center flex-wrap">
                                <h5 class="modal-title font-weight-bold mb-0 text-dark" id="editRoomModalLabel${room.id}">
                                  <i class="fa fa-pencil text-warning mr-2"></i>Chỉnh Sửa Thông Tin Phòng
                                </h5>
                                <span class="badge badge-info px-2 py-1 ml-2 font-weight-normal" style="font-size: 12px;">
                                  <c:out value="${property.propertyName}" />
                                </span>
                              </div>
                              <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                              </button>
                            </div>

                            <div class="modal-body p-4">
                              <div class="form-row">
                                <div class="form-group col-md-7">
                                  <label class="font-weight-bold text-dark small mb-1">
                                    <i class="fa fa-tag mr-1 text-primary"></i>Tên phòng <span class="text-danger">*</span>
                                  </label>
                                  <input type="text" class="form-control" name="roomName" value="<c:out value="${room.roomName}" />" required maxlength="120" placeholder="Ví dụ: Deluxe Ocean View 101" />
                                </div>

                                <div class="form-group col-md-5">
                                  <label class="font-weight-bold text-dark small mb-1">
                                    <i class="fa fa-th-large mr-1 text-primary"></i>Loại phòng <span class="text-danger">*</span>
                                  </label>
                                  <select class="form-control custom-select" name="roomType" required>
                                    <option value="SINGLE" ${room.roomTypeName == 'SINGLE' ? 'selected' : ''}>Phòng Đơn (Single)</option>
                                    <option value="DOUBLE" ${room.roomTypeName == 'DOUBLE' || empty room.roomTypeName ? 'selected' : ''}>Phòng Đôi (Double)</option>
                                    <option value="TWIN" ${room.roomTypeName == 'TWIN' ? 'selected' : ''}>Phòng 2 Giường (Twin)</option>
                                    <option value="FAMILY" ${room.roomTypeName == 'FAMILY' ? 'selected' : ''}>Phòng Gia Đình (Family)</option>
                                    <option value="SUITE" ${room.roomTypeName == 'SUITE' ? 'selected' : ''}>Phòng Cao Cấp (Suite)</option>
                                    <option value="OTHER" ${room.roomTypeName == 'OTHER' ? 'selected' : ''}>Loại Khác (Other)</option>
                                  </select>
                                </div>
                              </div>

                              <div class="form-row">
                                <div class="form-group col-md-6">
                                  <label class="font-weight-bold text-dark small mb-1">
                                    <i class="fa fa-money mr-1 text-success"></i>Giá thuê mỗi đêm (VNĐ) <span class="text-danger">*</span>
                                  </label>
                                  <div class="input-group">
                                    <input type="number" class="form-control" name="pricePerNight" value="<fmt:formatNumber value="${room.pricePerNight}" pattern="0" />" min="10000" max="99999999" step="10000" required placeholder="500000" />
                                    <div class="input-group-append">
                                      <span class="input-group-text font-weight-bold">₫ / đêm</span>
                                    </div>
                                  </div>
                                </div>

                                <div class="form-group col-md-6">
                                  <label class="font-weight-bold text-dark small mb-1">
                                    <i class="fa fa-sort-numeric-asc mr-1 text-muted"></i>Thứ tự hiển thị
                                  </label>
                                  <input type="number" class="form-control" name="sortOrder" value="${room.sortOrder}" min="0" max="100" />
                                </div>
                              </div>

                              <div class="form-row">
                                <div class="form-group col-md-4">
                                  <label class="font-weight-bold text-dark small mb-1">
                                    <i class="fa fa-users mr-1 text-primary"></i>Sức chứa tối đa <span class="text-danger">*</span>
                                  </label>
                                  <div class="input-group">
                                    <input type="number" class="form-control" name="maxGuests" value="${room.maxGuests}" min="1" max="50" required />
                                    <div class="input-group-append">
                                      <span class="input-group-text">khách</span>
                                    </div>
                                  </div>
                                </div>

                                <div class="form-group col-md-4">
                                  <label class="font-weight-bold text-dark small mb-1">
                                    <i class="fa fa-bed mr-1 text-info"></i>Số lượng giường <span class="text-danger">*</span>
                                  </label>
                                  <div class="input-group">
                                    <input type="number" class="form-control" name="bedCount" value="${room.bedCount}" min="1" max="20" required />
                                    <div class="input-group-append">
                                      <span class="input-group-text">giường</span>
                                    </div>
                                  </div>
                                </div>

                                <div class="form-group col-md-4">
                                  <label class="font-weight-bold text-dark small mb-1">
                                    <i class="fa fa-bath mr-1 text-success"></i>Số phòng tắm <span class="text-danger">*</span>
                                  </label>
                                  <div class="input-group">
                                    <input type="number" class="form-control" name="bathroomCount" value="${room.bathroomCount > 0 ? room.bathroomCount : 1}" min="1" max="10" required />
                                    <div class="input-group-append">
                                      <span class="input-group-text">phòng</span>
                                    </div>
                                  </div>
                                </div>
                              </div>

                              <div class="form-group mb-0">
                                <label class="font-weight-bold text-dark small mb-2 d-block">
                                  <i class="fa fa-list-ul mr-1 text-warning"></i>Tiện ích phòng
                                </label>
                                <div class="row">
                                  <c:set var="amList" value="${room.amenities}" />
                                  <div class="col-6 col-md-4 mb-2">
                                    <div class="custom-control custom-checkbox">
                                      <input type="checkbox" class="custom-control-input" id="am_wifi_${room.id}" name="amenities" value="Wifi miễn phí" ${amList != null && amList.contains('Wifi miễn phí') ? 'checked' : ''} />
                                      <label class="custom-control-label small" for="am_wifi_${room.id}">Wifi miễn phí</label>
                                    </div>
                                  </div>
                                  <div class="col-6 col-md-4 mb-2">
                                    <div class="custom-control custom-checkbox">
                                      <input type="checkbox" class="custom-control-input" id="am_ac_${room.id}" name="amenities" value="Điều hòa không khí" ${amList != null && amList.contains('Điều hòa không khí') ? 'checked' : ''} />
                                      <label class="custom-control-label small" for="am_ac_${room.id}">Điều hòa không khí</label>
                                    </div>
                                  </div>
                                  <div class="col-6 col-md-4 mb-2">
                                    <div class="custom-control custom-checkbox">
                                      <input type="checkbox" class="custom-control-input" id="am_tv_${room.id}" name="amenities" value="TV thông minh" ${amList != null && amList.contains('TV thông minh') ? 'checked' : ''} />
                                      <label class="custom-control-label small" for="am_tv_${room.id}">TV thông minh</label>
                                    </div>
                                  </div>
                                  <div class="col-6 col-md-4 mb-2">
                                    <div class="custom-control custom-checkbox">
                                      <input type="checkbox" class="custom-control-input" id="am_fridge_${room.id}" name="amenities" value="Tủ lạnh / Minibar" ${amList != null && amList.contains('Tủ lạnh / Minibar') ? 'checked' : ''} />
                                      <label class="custom-control-label small" for="am_fridge_${room.id}">Tủ lạnh / Minibar</label>
                                    </div>
                                  </div>
                                  <div class="col-6 col-md-4 mb-2">
                                    <div class="custom-control custom-checkbox">
                                      <input type="checkbox" class="custom-control-input" id="am_hotwater_${room.id}" name="amenities" value="Bình nóng lạnh" ${amList != null && amList.contains('Bình nóng lạnh') ? 'checked' : ''} />
                                      <label class="custom-control-label small" for="am_hotwater_${room.id}">Bình nóng lạnh</label>
                                    </div>
                                  </div>
                                  <div class="col-6 col-md-4 mb-2">
                                    <div class="custom-control custom-checkbox">
                                      <input type="checkbox" class="custom-control-input" id="am_dryer_${room.id}" name="amenities" value="Máy sấy tóc" ${amList != null && amList.contains('Máy sấy tóc') ? 'checked' : ''} />
                                      <label class="custom-control-label small" for="am_dryer_${room.id}">Máy sấy tóc</label>
                                    </div>
                                  </div>
                                  <div class="col-6 col-md-4 mb-2">
                                    <div class="custom-control custom-checkbox">
                                      <input type="checkbox" class="custom-control-input" id="am_balcony_${room.id}" name="amenities" value="Ban công view đẹp" ${amList != null && amList.contains('Ban công view đẹp') ? 'checked' : ''} />
                                      <label class="custom-control-label small" for="am_balcony_${room.id}">Ban công view đẹp</label>
                                    </div>
                                  </div>
                                  <div class="col-6 col-md-4 mb-2">
                                    <div class="custom-control custom-checkbox">
                                      <input type="checkbox" class="custom-control-input" id="am_kitchen_${room.id}" name="amenities" value="Bếp nấu ăn" ${amList != null && amList.contains('Bếp nấu ăn') ? 'checked' : ''} />
                                      <label class="custom-control-label small" for="am_kitchen_${room.id}">Bếp nấu ăn</label>
                                    </div>
                                  </div>
                                  <div class="col-6 col-md-4 mb-2">
                                    <div class="custom-control custom-checkbox">
                                      <input type="checkbox" class="custom-control-input" id="am_bathtub_${room.id}" name="amenities" value="Bồn tắm / Jacuzzi" ${amList != null && amList.contains('Bồn tắm / Jacuzzi') ? 'checked' : ''} />
                                      <label class="custom-control-label small" for="am_bathtub_${room.id}">Bồn tắm / Jacuzzi</label>
                                    </div>
                                  </div>
                                  <div class="col-6 col-md-4 mb-2">
                                    <div class="custom-control custom-checkbox">
                                      <input type="checkbox" class="custom-control-input" id="am_desk_${room.id}" name="amenities" value="Bàn làm việc" ${amList != null && amList.contains('Bàn làm việc') ? 'checked' : ''} />
                                      <label class="custom-control-label small" for="am_desk_${room.id}">Bàn làm việc</label>
                                    </div>
                                  </div>
                                  <div class="col-6 col-md-4 mb-2">
                                    <div class="custom-control custom-checkbox">
                                      <input type="checkbox" class="custom-control-input" id="am_kettle_${room.id}" name="amenities" value="Ấm siêu tốc" ${amList != null && amList.contains('Ấm siêu tốc') ? 'checked' : ''} />
                                      <label class="custom-control-label small" for="am_kettle_${room.id}">Ấm siêu tốc</label>
                                    </div>
                                  </div>
                                  <div class="col-6 col-md-4 mb-2">
                                    <div class="custom-control custom-checkbox">
                                      <input type="checkbox" class="custom-control-input" id="am_iron_${room.id}" name="amenities" value="Bàn ủi / Là quần áo" ${amList != null && amList.contains('Bàn ủi / Là quần áo') ? 'checked' : ''} />
                                      <label class="custom-control-label small" for="am_iron_${room.id}">Bàn ủi / Là quần áo</label>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </div>

                            <div class="modal-footer d-flex justify-content-between">
                              <button type="button" class="btn btn-secondary btn-sm px-4" data-dismiss="modal">
                                <i class="fa fa-times mr-1"></i>Hủy bỏ
                              </button>
                              <button type="submit" class="btn btn-warning btn-sm px-4 font-weight-bold" style="background:#f59e0b; border-color:#d97706; color:#ffffff;">
                                <i class="fa fa-save mr-1"></i>Lưu Thay Đổi
                              </button>
                            </div>
                          </form>
                        </div>
                      </div>
                    </div>
                  </c:forEach>
                </div>
              </div>
            </div>
          </c:forEach>

          <c:if test="${empty properties}">
            <div class="text-center py-4 text-muted">
              Hiện chưa có homestay nào được kích hoạt.
            </div>
          </c:if>
        </div>

      </c:when>

      <%-- Case 2: Host account active but application pending approval --%>
      <c:otherwise>
        <div class="card border-0 shadow-sm p-4 p-md-5 text-center">
          <div class="py-5">
            <i class="fa fa-hourglass-half text-warning fa-3x mb-3"></i>
            <h2 class="h4 font-weight-bold">Đơn Đăng Ký Host Đang Được Xét Duyệt</h2>
            <p class="text-muted max-w-500 mx-auto">
              Hệ thống đã ghi nhận hồ sơ đăng ký của bạn. Bảng điều khiển doanh thu và công cụ quản lý phòng sẽ tự động kích hoạt ngay sau khi Admin phê duyệt.
            </p>
          </div>
        </div>
      </c:otherwise>
    </c:choose>

  </div>
</main>

<%-- Load Chart.js CDN for Dynamic Interactive Charts --%>
<script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
<script>
  document.addEventListener("DOMContentLoaded", function() {
    var chartCanvas = document.getElementById("revenueChart");
    if (!chartCanvas) return;

    var monthlyData = <c:out value="${monthlyRevenueJson}" default="[0,0,0,0,0,0,0,0,0,0,0,0]" escapeXml="false" />;
    var ctx = chartCanvas.getContext("2d");

    // Create a smooth gradient for the chart bars
    var gradient = ctx.createLinearGradient(0, 0, 0, 300);
    gradient.addColorStop(0, "rgba(247, 168, 64, 0.85)");
    gradient.addColorStop(1, "rgba(247, 168, 64, 0.15)");

    var labels = [
      "Tháng 1", "Tháng 2", "Tháng 3", "Tháng 4", 
      "Tháng 5", "Tháng 6", "Tháng 7", "Tháng 8", 
      "Tháng 9", "Tháng 10", "Tháng 11", "Tháng 12"
    ];

    new Chart(ctx, {
      type: "bar",
      data: {
        labels: labels,
        datasets: [{
          label: "Doanh thu (VNĐ)",
          data: monthlyData,
          backgroundColor: gradient,
          borderColor: "#f7a840",
          borderWidth: 2,
          borderRadius: 6,
          borderSkipped: false
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            backgroundColor: "#1e293b",
            titleFont: { size: 13, weight: "bold" },
            bodyFont: { size: 14 },
            padding: 12,
            cornerRadius: 8,
            callbacks: {
              label: function(context) {
                var val = context.raw || 0;
                return "Doanh thu: " + val.toLocaleString("vi-VN") + " ₫";
              }
            }
          }
        },
        scales: {
          x: {
            grid: {
              display: false
            },
            ticks: {
              font: { size: 12 },
              color: "#64748b"
            }
          },
          y: {
            beginAtZero: true,
            grid: {
              color: "#f1f5f9"
            },
            ticks: {
              font: { size: 12 },
              color: "#64748b",
              callback: function(value) {
                if (value >= 1000000) {
                  return (value / 1000000).toFixed(1) + " tr";
                }
                return value.toLocaleString("vi-VN");
              }
            }
          }
        }
      }
    });
  });
</script>

<%-- Shared page footer and scripts. --%>
<jsp:include page="common/footer.jsp" />
