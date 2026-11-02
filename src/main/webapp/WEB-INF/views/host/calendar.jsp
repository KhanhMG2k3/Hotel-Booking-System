<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <title>Lịch Đặt Phòng & Trạng Thái Trống - Sogo Homestay</title>
  
  <jsp:include page="../common/header.jsp" />

  <style>
    .calendar-wrapper {
      background-color: #f8fafc;
      min-height: calc(100vh - 160px);
      padding: 30px 0 60px;
    }
    .calendar-card {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 12px;
      box-shadow: 0 4px 15px rgba(0, 0, 0, 0.04);
      padding: 24px;
      margin-bottom: 24px;
    }
    .stat-kpi-card {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 12px;
      padding: 18px 20px;
      height: 100%;
      transition: transform 0.15s ease, box-shadow 0.15s ease;
    }
    .stat-kpi-card:hover {
      box-shadow: 0 4px 15px rgba(0, 0, 0, 0.06);
    }
    .stat-kpi-label {
      font-size: 13px;
      font-weight: 600;
      color: #64748b;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    .stat-kpi-val {
      font-size: 24px;
      font-weight: 700;
      color: #1e293b;
      margin-top: 4px;
    }
    .stat-kpi-icon {
      width: 44px;
      height: 44px;
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 20px;
    }
    .icon-occupancy { background: #e0f2fe; color: #0284c7; }
    .icon-booked { background: #fee2e2; color: #dc2626; }
    .icon-available { background: #dcfce7; color: #16a34a; }
    .icon-revenue { background: #fef3c7; color: #d97706; }

    /* Calendar Grid Table */
    .calendar-grid-wrapper {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
    }
    .calendar-table {
      width: 100%;
      border-collapse: collapse;
      table-layout: fixed;
    }
    .calendar-table th {
      background: #f1f5f9;
      color: #334155;
      font-size: 13px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      text-align: center;
      padding: 14px 6px;
      border-bottom: 2px solid #cbd5e1;
      width: 14.285%;
    }
    .calendar-table th.weekend-col {
      color: #e11d48;
      background: #fff1f2;
    }
    .calendar-cell {
      height: 125px;
      min-height: 125px;
      vertical-align: top;
      padding: 8px;
      border-right: 1px solid #f1f5f9;
      border-bottom: 1px solid #f1f5f9;
      position: relative;
      background: #ffffff;
      transition: background-color 0.15s ease;
    }
    .calendar-cell:nth-child(7n) {
      border-right: none;
    }
    .calendar-cell.other-month {
      background: #f8fafc;
      opacity: 0.55;
    }
    .calendar-cell.is-today {
      background: #eff6ff !important;
      border: 2px solid #3b82f6 !important;
    }
    .calendar-date-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 6px;
    }
    .calendar-date-num {
      font-size: 14px;
      font-weight: 700;
      color: #1e293b;
      width: 26px;
      height: 26px;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 50%;
    }
    .calendar-cell.is-today .calendar-date-num {
      background: #2563eb;
      color: #ffffff;
    }
    .calendar-today-badge {
      font-size: 10px;
      font-weight: 700;
      padding: 2px 6px;
      border-radius: 4px;
      background: #2563eb;
      color: #ffffff;
      text-transform: uppercase;
    }

    /* Slots inside cell */
    .slot-booked {
      background: #fee2e2;
      border: 1px solid #fca5a5;
      color: #991b1b;
      border-radius: 6px;
      padding: 5px 8px;
      font-size: 11px;
      margin-bottom: 4px;
      cursor: pointer;
      transition: all 0.15s ease;
      display: block;
      text-decoration: none !important;
    }
    .slot-booked:hover {
      background: #fecaca;
      border-color: #f87171;
      transform: translateY(-1px);
      box-shadow: 0 2px 6px rgba(220, 38, 38, 0.15);
      color: #7f1d1d;
    }
    .slot-available {
      background: #f0fdf4;
      border: 1px dashed #86efac;
      color: #166534;
      border-radius: 6px;
      padding: 5px 8px;
      font-size: 11px;
      margin-bottom: 4px;
    }
    .slot-pending {
      background: #fef3c7;
      border: 1px solid #fde68a;
      color: #92400e;
    }

    /* All rooms mode gauge & chips */
    .all-rooms-summary-bar {
      font-size: 11px;
      font-weight: 600;
      padding: 3px 6px;
      border-radius: 4px;
      margin-bottom: 4px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .gauge-free { background: #dcfce7; color: #166534; }
    .gauge-partial { background: #fef3c7; color: #92400e; }
    .gauge-full { background: #fee2e2; color: #991b1b; }

    .room-chip-mini {
      display: inline-block;
      font-size: 10px;
      padding: 1px 4px;
      border-radius: 3px;
      margin-right: 2px;
      margin-bottom: 2px;
      white-space: nowrap;
      max-width: 100%;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .chip-booked { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }
    .chip-available { background: #f1f5f9; color: #475569; border: 1px solid #e2e8f0; }

    /* Legend */
    .legend-item {
      display: inline-flex;
      align-items: center;
      font-size: 12px;
      font-weight: 600;
      color: #475569;
      margin-right: 18px;
      margin-bottom: 6px;
    }
    .legend-box {
      width: 14px;
      height: 14px;
      border-radius: 4px;
      margin-right: 6px;
    }
    .legend-available { background: #dcfce7; border: 1px solid #86efac; }
    .legend-booked { background: #fee2e2; border: 1px solid #fca5a5; }
    .legend-pending { background: #fef3c7; border: 1px solid #fde68a; }
    .legend-today { background: #eff6ff; border: 2px solid #3b82f6; }

    /* Dark Mode */
    [data-theme="dark"] .calendar-wrapper {
      background-color: #0b111e;
    }
    [data-theme="dark"] .calendar-card,
    [data-theme="dark"] .stat-kpi-card,
    [data-theme="dark"] .calendar-grid-wrapper {
      background: #141d2b !important;
      border-color: #24354b !important;
    }
    [data-theme="dark"] .stat-kpi-val {
      color: #f1f5f9 !important;
    }
    [data-theme="dark"] .calendar-table th {
      background: #162032 !important;
      color: #e2e8f0 !important;
      border-color: #24354b !important;
    }
    [data-theme="dark"] .calendar-table th.weekend-col {
      background: #2a1520 !important;
      color: #fb7185 !important;
    }
    [data-theme="dark"] .calendar-cell {
      background: #111a28 !important;
      border-color: #1e2c3f !important;
    }
    [data-theme="dark"] .calendar-cell.other-month {
      background: #0d1522 !important;
      opacity: 0.35;
    }
    [data-theme="dark"] .calendar-cell.is-today {
      background: #15253e !important;
      border-color: #3b82f6 !important;
    }
    [data-theme="dark"] .calendar-date-num {
      color: #f1f5f9 !important;
    }
    [data-theme="dark"] .slot-available {
      background: #0f291e !important;
      border-color: #166534 !important;
      color: #86efac !important;
    }
    [data-theme="dark"] .slot-booked {
      background: #331418 !important;
      border-color: #991b1b !important;
      color: #fca5a5 !important;
    }
    [data-theme="dark"] .slot-pending {
      background: #362208 !important;
      border-color: #92400e !important;
      color: #fde68a !important;
    }
    [data-theme="dark"] .form-control,
    [data-theme="dark"] .custom-select {
      background-color: #0d1522 !important;
      border-color: #2a3d5a !important;
      color: #f1f5f9 !important;
    }
    [data-theme="dark"] .legend-item {
      color: #94a3b8 !important;
    }
    [data-theme="dark"] .modal-content {
      background-color: #141d2b !important;
      color: #e2e8f0 !important;
      border-color: #24354b !important;
    }
    [data-theme="dark"] .modal-header,
    [data-theme="dark"] .modal-footer {
      background-color: #162032 !important;
      border-color: #24354b !important;
    }
    [data-theme="dark"] .modal-title,
    [data-theme="dark"] .text-dark {
      color: #f8fafc !important;
    }
    [data-theme="dark"] .close {
      color: #cbd5e1 !important;
    }
    [data-theme="dark"] .bg-light {
      background-color: #0d1522 !important;
      border-color: #24354b !important;
      color: #cbd5e1 !important;
    }
  </style>
</head>
<body>

<jsp:include page="../common/navbar.jsp" />

<main class="calendar-wrapper">
  <div class="container-fluid px-lg-5">
    
    <%-- Top Breadcrumb & Header --%>
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
      <div>
        <div class="d-flex align-items-center mb-1">
          <a href="${pageContext.request.contextPath}/host/dashboard" class="btn btn-sm btn-outline-secondary mr-2 font-weight-bold">
            <i class="fa fa-arrow-left mr-1"></i>Host Dashboard
          </a>
          <span class="badge badge-warning text-uppercase px-2 py-1 font-weight-bold" style="background:#fef3c7; color:#92400e;">
            Availability & Booking
          </span>
        </div>
        <h1 class="h3 font-weight-bold text-dark mb-0">
          <i class="fa fa-calendar-check-o text-primary mr-2"></i>Lịch Đặt Phòng & Trạng Thái Trống
        </h1>
        <p class="text-muted small mb-0 mt-1">
          Theo dõi lịch phòng đã đặt (Booked) và phòng sẵn sàng đón khách (Available) theo từng tháng.
        </p>
      </div>

      <div class="mt-3 mt-md-0 d-flex flex-wrap align-items-center">
        <a href="${pageContext.request.contextPath}/host/vouchers" class="btn btn-outline-warning font-weight-bold px-3 py-2 mr-2">
          <i class="fa fa-ticket mr-1"></i> Quản lý Voucher
        </a>
        <a href="${pageContext.request.contextPath}/host/dashboard" class="btn btn-primary font-weight-bold px-3 py-2 shadow-sm">
          <i class="fa fa-th-large mr-1"></i> Danh sách phòng
        </a>
      </div>
    </div>

    <%-- Filter & Month Navigation Bar --%>
    <div class="calendar-card mb-4">
      <form action="${pageContext.request.contextPath}/host/calendar" method="get" class="row align-items-end" id="calendarFilterForm">
        
        <%-- Homestay Selector --%>
        <div class="col-md-3 col-sm-6 mb-3 mb-md-0">
          <label class="font-weight-bold small text-dark mb-1">
            <i class="fa fa-building-o text-primary mr-1"></i>Cơ sở Homestay:
          </label>
          <select name="propertyId" class="form-control custom-select" onchange="document.getElementById('roomIdSelect').value='0'; this.form.submit();">
            <c:forEach var="prop" items="${properties}">
              <option value="${prop.id}" ${prop.id == propertyId ? 'selected' : ''}>
                <c:out value="${prop.propertyName}" />
              </option>
            </c:forEach>
          </select>
        </div>

        <%-- Room Selector --%>
        <div class="col-md-3 col-sm-6 mb-3 mb-md-0">
          <label class="font-weight-bold small text-dark mb-1">
            <i class="fa fa-bed text-info mr-1"></i>Xem theo phòng:
          </label>
          <select name="roomId" id="roomIdSelect" class="form-control custom-select" onchange="this.form.submit();">
            <option value="0" ${roomId == 0 ? 'selected' : ''}>-- Tất cả các phòng (${rooms.size()} phòng) --</option>
            <c:forEach var="rm" items="${rooms}">
              <option value="${rm.id}" ${rm.id == roomId ? 'selected' : ''}>
                <c:out value="${rm.roomName}" /> (<fmt:formatNumber value="${rm.pricePerNight}" pattern="#,##0" /> ₫)
              </option>
            </c:forEach>
          </select>
        </div>

        <%-- Month & Year Selector --%>
        <div class="col-md-3 col-sm-6 mb-3 mb-md-0">
          <label class="font-weight-bold small text-dark mb-1">
            <i class="fa fa-calendar mr-1 text-warning"></i>Tháng & Năm:
          </label>
          <div class="d-flex">
            <select name="month" class="form-control custom-select mr-1" onchange="this.form.submit();">
              <c:forEach var="m" begin="1" end="12">
                <option value="${m}" ${m == month ? 'selected' : ''}>Tháng ${m}</option>
              </c:forEach>
            </select>
            <select name="year" class="form-control custom-select" onchange="this.form.submit();">
              <c:forEach var="y" begin="${year - 1}" end="${year + 2}">
                <option value="${y}" ${y == year ? 'selected' : ''}>Năm ${y}</option>
              </c:forEach>
            </select>
          </div>
        </div>

        <%-- Quick Navigation Controls --%>
        <div class="col-md-3 col-sm-6 text-md-right d-flex justify-content-md-end align-items-center">
          <div class="btn-group shadow-sm">
            <a href="${pageContext.request.contextPath}/host/calendar?propertyId=${propertyId}&roomId=${roomId}&year=${prevYear}&month=${prevMonth}" class="btn btn-outline-secondary btn-sm px-3" title="Tháng trước">
              <i class="fa fa-chevron-left mr-1"></i>Tháng trước
            </a>
            <a href="${pageContext.request.contextPath}/host/calendar?propertyId=${propertyId}&roomId=${roomId}" class="btn btn-primary btn-sm px-3 font-weight-bold">
              Hôm nay
            </a>
            <a href="${pageContext.request.contextPath}/host/calendar?propertyId=${propertyId}&roomId=${roomId}&year=${nextYear}&month=${nextMonth}" class="btn btn-outline-secondary btn-sm px-3" title="Tháng sau">
              Tháng sau<i class="fa fa-chevron-right ml-1"></i>
            </a>
          </div>
        </div>
      </form>
    </div>

    <%-- Row 1: KPI Statistic Summary Cards --%>
    <div class="row mb-4">
      <%-- KPI 1: Occupancy Rate --%>
      <div class="col-sm-6 col-lg-3 mb-3 mb-lg-0">
        <div class="stat-kpi-card">
          <div class="d-flex justify-content-between align-items-center">
            <span class="stat-kpi-label">Tỷ lệ lấp đầy</span>
            <div class="stat-kpi-icon icon-occupancy">
              <i class="fa fa-pie-chart"></i>
            </div>
          </div>
          <div class="stat-kpi-val text-primary">
            ${occupancyRate}%
          </div>
          <div class="progress mt-2" style="height: 6px;">
            <div class="progress-bar bg-primary" role="progressbar" style="width: ${occupancyRate}%;" aria-valuenow="${occupancyRate}" aria-valuemin="0" aria-valuemax="100"></div>
          </div>
          <small class="text-muted d-block mt-2">
            ${bookedNightsCount} / ${totalRoomNightsInMonth} đêm phòng
          </small>
        </div>
      </div>

      <%-- KPI 2: Booked Nights --%>
      <div class="col-sm-6 col-lg-3 mb-3 mb-lg-0">
        <div class="stat-kpi-card">
          <div class="d-flex justify-content-between align-items-center">
            <span class="stat-kpi-label">Đêm đã đặt</span>
            <div class="stat-kpi-icon icon-booked">
              <i class="fa fa-calendar-check-o"></i>
            </div>
          </div>
          <div class="stat-kpi-val text-danger">
            ${bookedNightsCount} <span class="h6 font-weight-normal text-muted">đêm</span>
          </div>
          <small class="text-muted d-block mt-2">
            Từ <strong>${totalBookingsCount}</strong> đơn đặt phòng
          </small>
        </div>
      </div>

      <%-- KPI 3: Available Nights --%>
      <div class="col-sm-6 col-lg-3 mb-3 mb-lg-0">
        <div class="stat-kpi-card">
          <div class="d-flex justify-content-between align-items-center">
            <span class="stat-kpi-label">Đêm còn trống</span>
            <div class="stat-kpi-icon icon-available">
              <i class="fa fa-check-circle-o"></i>
            </div>
          </div>
          <div class="stat-kpi-val text-success">
            ${availableNightsCount} <span class="h6 font-weight-normal text-muted">đêm</span>
          </div>
          <small class="text-muted d-block mt-2">
            Sẵn sàng mở đón khách đặt mới
          </small>
        </div>
      </div>

      <%-- KPI 4: Estimated Revenue --%>
      <div class="col-sm-6 col-lg-3 mb-3 mb-lg-0">
        <div class="stat-kpi-card">
          <div class="d-flex justify-content-between align-items-center">
            <span class="stat-kpi-label">Doanh thu dự kiến</span>
            <div class="stat-kpi-icon icon-revenue">
              <i class="fa fa-money"></i>
            </div>
          </div>
          <div class="stat-kpi-val text-warning" style="color: #d97706 !important;">
            <fmt:formatNumber value="${estimatedRevenue}" pattern="#,##0" /> ₫
          </div>
          <small class="text-muted d-block mt-2">
            Tổng giá trị các đêm phòng trong tháng
          </small>
        </div>
      </div>
    </div>

    <%-- Legend & Calendar Month Header --%>
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-3">
      <div class="d-flex align-items-center mb-2 mb-md-0">
        <h2 class="h4 font-weight-bold text-dark mb-0 mr-3">
          Tháng ${month} / ${year}
        </h2>
        <span class="badge badge-light border text-muted px-2 py-1 font-weight-normal">
          <i class="fa fa-info-circle mr-1"></i>
          <c:choose>
            <c:when test="${not empty selectedRoom}">
              Đang xem phòng: <strong><c:out value="${selectedRoom.roomName}" /></strong>
            </c:when>
            <c:otherwise>
              Đang xem tổng hợp tất cả <strong>${rooms.size()}</strong> phòng tại <c:out value="${selectedProperty.propertyName}" />
            </c:otherwise>
          </c:choose>
        </span>
      </div>

      <%-- Status Legend --%>
      <div class="d-flex flex-wrap align-items-center">
        <div class="legend-item">
          <div class="legend-box legend-available"></div> Còn trống (Available)
        </div>
        <div class="legend-item">
          <div class="legend-box legend-booked"></div> Đã đặt (Booked)
        </div>
        <div class="legend-item">
          <div class="legend-box legend-today"></div> Hôm nay (Today)
        </div>
      </div>
    </div>

    <%-- Calendar Grid Table --%>
    <div class="calendar-grid-wrapper mb-4">
      <table class="calendar-table">
        <thead>
          <tr>
            <th>Thứ 2</th>
            <th>Thứ 3</th>
            <th>Thứ 4</th>
            <th>Thứ 5</th>
            <th>Thứ 6</th>
            <th>Thứ 7</th>
            <th class="weekend-col">Chủ Nhật</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="day" items="${calendarDays}" varStatus="status">
            <%-- Open row on Mondays (index 0, 7, 14, ...) --%>
            <c:if test="${status.index % 7 == 0}">
              <tr>
            </c:if>

            <td class="calendar-cell ${!day.currentMonth ? 'other-month' : ''} ${day.today ? 'is-today' : ''}">
              <div class="calendar-date-header">
                <span class="calendar-date-num">${day.dayOfMonth}</span>
                <c:if test="${day.today}">
                  <span class="calendar-today-badge">Hôm nay</span>
                </c:if>
              </div>

              <%-- Cell Body: Only render details if current month --%>
              <c:if test="${day.currentMonth}">
                <c:choose>
                  <%-- Case A: Single Room Mode --%>
                  <c:when test="${not empty selectedRoom}">
                    <c:choose>
                      <c:when test="${day.booked}">
                        <a href="javascript:void(0)" class="slot-booked" data-toggle="modal" data-target="#bookingModal_${day.booking.id}" title="Click xem chi tiết đơn phòng">
                          <div class="d-flex justify-content-between align-items-center font-weight-bold">
                            <span><i class="fa fa-user-circle mr-1"></i><c:out value="${day.booking.customerName}" /></span>
                            <span class="badge badge-danger font-monospace" style="font-size: 9px;">#<c:out value="${day.booking.bookingCode}" /></span>
                          </div>
                          <div class="d-flex justify-content-between align-items-center mt-1 text-muted" style="font-size: 10px;">
                            <span>
                              <c:if test="${day.checkIn}"><i class="fa fa-sign-in text-success mr-1" title="Nhận phòng"></i>Check-in</c:if>
                              <c:if test="${day.checkOut}"><i class="fa fa-sign-out text-danger mr-1" title="Trả phòng"></i>Check-out</c:if>
                              <c:if test="${!day.checkIn && !day.checkOut}">Đang lưu trú</c:if>
                            </span>
                            <span class="badge ${day.booking.status == 'CONFIRMED' ? 'badge-primary' : (day.booking.status == 'COMPLETED' ? 'badge-success' : 'badge-warning')} text-white" style="font-size: 9px;">
                              <c:out value="${day.booking.status}" />
                            </span>
                          </div>
                        </a>
                      </c:when>
                      <c:otherwise>
                        <div class="slot-available">
                          <div class="d-flex justify-content-between align-items-center font-weight-bold">
                            <span><i class="fa fa-check-circle text-success mr-1"></i>Còn trống</span>
                            <span class="text-success"><fmt:formatNumber value="${day.price}" pattern="#,##0" /> ₫</span>
                          </div>
                          <c:if test="${day.checkOut}">
                            <div class="text-muted mt-1" style="font-size: 9px;">
                              <i class="fa fa-sign-out text-danger mr-1"></i>Khách trả trưa nay
                            </div>
                          </c:if>
                        </div>
                      </c:otherwise>
                    </c:choose>
                  </c:when>

                  <%-- Case B: All Rooms in Property Mode --%>
                  <c:otherwise>
                    <div class="all-rooms-summary-bar ${day.bookedRoomsCount == 0 ? 'gauge-free' : (day.availableRoomsCount == 0 ? 'gauge-full' : 'gauge-partial')}">
                      <span>
                        <c:choose>
                          <c:when test="${day.bookedRoomsCount == 0}">
                            <i class="fa fa-check mr-1"></i>Trống ${day.totalRooms}/${day.totalRooms}
                          </c:when>
                          <c:when test="${day.availableRoomsCount == 0}">
                            <i class="fa fa-times-circle mr-1"></i>Kín phòng
                          </c:when>
                          <c:otherwise>
                            <i class="fa fa-calendar-check-o mr-1"></i>Đặt ${day.bookedRoomsCount}/${day.totalRooms}
                          </c:otherwise>
                        </c:choose>
                      </span>
                      <span>${day.totalRooms > 0 ? Math.round((day.bookedRoomsCount * 100) / day.totalRooms) : 0}%</span>
                    </div>

                    <%-- Mini chips for each room status --%>
                    <div class="d-flex flex-wrap mt-1">
                      <c:forEach var="item" items="${day.roomStatuses}">
                        <c:choose>
                          <c:when test="${item.booked}">
                            <a href="javascript:void(0)" class="room-chip-mini chip-booked" data-toggle="modal" data-target="#bookingModal_${item.booking.id}" title="${item.room.roomName}: Đã đặt bởi ${item.booking.customerName}">
                              🔴 <c:out value="${item.room.roomName}" />
                            </a>
                          </c:when>
                          <c:otherwise>
                            <span class="room-chip-mini chip-available" title="${item.room.roomName}: Còn trống">
                              🟢 <c:out value="${item.room.roomName}" />
                            </span>
                          </c:otherwise>
                        </c:choose>
                      </c:forEach>
                    </div>
                  </c:otherwise>
                </c:choose>
              </c:if>
            </td>

            <%-- Close row on Sundays (index 6, 13, 20, ...) --%>
            <c:if test="${status.index % 7 == 6}">
              </tr>
            </c:if>
          </c:forEach>
        </tbody>
      </table>
    </div>

    <%-- Modals for each booking active in this month --%>
    <c:forEach var="b" items="${bookings}">
      <div class="modal fade text-left" id="bookingModal_${b.id}" tabindex="-1" role="dialog" aria-labelledby="modalLabel_${b.id}" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
          <div class="modal-content shadow-lg border-0">
            <div class="modal-header d-flex justify-content-between align-items-center">
              <div class="d-flex align-items-center">
                <h5 class="modal-title font-weight-bold mb-0 text-dark" id="modalLabel_${b.id}">
                  <i class="fa fa-id-card-o text-warning mr-2"></i>Chi Tiết Đơn Đặt Phòng
                </h5>
                <span class="badge badge-primary px-2 py-1 ml-2 font-monospace font-weight-bold">
                  #<c:out value="${b.bookingCode}" />
                </span>
              </div>
              <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                <span aria-hidden="true">&times;</span>
              </button>
            </div>

            <div class="modal-body p-4">
              <!-- Summary banner -->
              <div class="p-3 bg-light rounded border mb-3 d-flex justify-content-between align-items-center">
                <div>
                  <span class="small text-muted d-block">Trạng thái đơn:</span>
                  <c:choose>
                    <c:when test="${b.status == 'CONFIRMED'}">
                      <span class="badge badge-primary px-2 py-1"><i class="fa fa-calendar-check-o mr-1"></i>Đã xác nhận</span>
                    </c:when>
                    <c:when test="${b.status == 'COMPLETED'}">
                      <span class="badge badge-success px-2 py-1"><i class="fa fa-check-circle mr-1"></i>Đã hoàn thành</span>
                    </c:when>
                    <c:when test="${b.status == 'PENDING'}">
                      <span class="badge badge-warning px-2 py-1 text-dark"><i class="fa fa-hourglass-half mr-1"></i>Chờ duyệt</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge badge-secondary px-2 py-1"><c:out value="${b.status}" /></span>
                    </c:otherwise>
                  </c:choose>
                </div>
                <div class="text-right">
                  <span class="small text-muted d-block">Tổng thanh toán:</span>
                  <span class="h5 font-weight-bold text-primary mb-0">
                    <fmt:formatNumber value="${b.totalPrice}" pattern="#,##0" /> ₫
                  </span>
                </div>
              </div>

              <!-- Customer info -->
              <div class="card border rounded p-3 mb-3">
                <h6 class="font-weight-bold text-dark border-bottom pb-2 mb-2">
                  <i class="fa fa-user-circle-o text-primary mr-1"></i>Thông Tin Khách Hàng
                </h6>
                <div class="row">
                  <div class="col-sm-6 mb-2">
                    <small class="text-muted d-block">Họ và tên:</small>
                    <strong class="text-dark"><c:out value="${b.customerName}" /></strong>
                  </div>
                  <div class="col-sm-6 mb-2">
                    <small class="text-muted d-block">Số điện thoại:</small>
                    <a href="tel:${b.customerPhone}" class="text-primary font-weight-bold"><c:out value="${b.customerPhone}" /></a>
                  </div>
                  <c:if test="${not empty b.customerEmail}">
                    <div class="col-12 mb-1">
                      <small class="text-muted d-block">Email:</small>
                      <span class="text-dark"><c:out value="${b.customerEmail}" /></span>
                    </div>
                  </c:if>
                </div>
              </div>

              <!-- Stay details -->
              <div class="card border rounded p-3">
                <h6 class="font-weight-bold text-dark border-bottom pb-2 mb-2">
                  <i class="fa fa-bed text-info mr-1"></i>Thông Tin Phòng & Lưu Trú
                </h6>
                <div class="mb-2">
                  <small class="text-muted d-block">Phòng homestay:</small>
                  <strong class="text-dark"><c:out value="${b.roomName}" /></strong>
                  <span class="text-muted small">(<c:out value="${b.propertyName}" />)</span>
                </div>
                <div class="row">
                  <div class="col-6 mb-2">
                    <small class="text-muted d-block"><i class="fa fa-sign-in text-success mr-1"></i>Nhận phòng (Check-in):</small>
                    <strong class="text-dark"><fmt:formatDate value="${b.checkInDate}" pattern="dd/MM/yyyy" /></strong>
                  </div>
                  <div class="col-6 mb-2">
                    <small class="text-muted d-block"><i class="fa fa-sign-out text-danger mr-1"></i>Trả phòng (Check-out):</small>
                    <strong class="text-dark"><fmt:formatDate value="${b.checkOutDate}" pattern="dd/MM/yyyy" /></strong>
                  </div>
                </div>
                <c:if test="${not empty b.notes}">
                  <div class="border-top pt-2 mt-1">
                    <small class="text-muted d-block"><i class="fa fa-comment-o mr-1"></i>Ghi chú:</small>
                    <span class="small text-muted"><c:out value="${b.notes}" /></span>
                  </div>
                </c:if>
              </div>
            </div>

            <div class="modal-footer d-flex justify-content-between">
              <div>
                <c:if test="${not empty b.customerPhone}">
                  <a href="tel:${b.customerPhone}" class="btn btn-sm btn-outline-success">
                    <i class="fa fa-phone mr-1"></i>Gọi khách
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
</main>

<jsp:include page="../common/footer.jsp" />

</body>
</html>

