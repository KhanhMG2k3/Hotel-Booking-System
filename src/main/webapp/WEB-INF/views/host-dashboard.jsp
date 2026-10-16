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
  /* Header cố định nền trắng sắc nét cho Host Dashboard - tránh đè giao diện */
  .site-header {
    background: #ffffff !important;
    padding: 14px 0 !important;
    box-shadow: 0 2px 16px rgba(0, 0, 0, 0.08) !important;
    position: fixed !important;
    top: 0 !important;
    left: 0 !important;
    width: 100% !important;
    z-index: 1030 !important;
  }
  .site-header .site-logo a {
    color: #1a1a1a !important;
  }
  .site-header .site-menu-toggle span {
    background: #1a1a1a !important;
  }
  .site-header .user-name {
    color: #1a1a1a !important;
  }
  .site-header .user-caret {
    color: #1a1a1a !important;
  }
  .site-header .auth-link:not(.auth-link-primary) {
    color: #202b32 !important;
  }
  .site-header .auth-link:not(.auth-link-primary):hover {
    color: #f59e0b !important;
  }
  .site-header .auth-divider {
    color: rgba(32, 43, 50, 0.3) !important;
  }
  .site-header .user-menu-toggle {
    background: #f8f9fa !important;
    border-color: #e9ecef !important;
  }
  .site-header .user-menu-toggle:hover {
    background: #eef2f7 !important;
    border-color: #f59e0b !important;
  }
  .site-header .header-wishlist-link {
    color: #202b32 !important;
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
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
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
        <a href="${pageContext.request.contextPath}/host/vouchers" class="btn btn-warning font-weight-bold px-3 py-2 shadow-sm mb-2" style="background:#f59e0b; border-color:#d97706; color:#ffffff;">
          <i class="fa fa-ticket mr-1"></i> Quản lý Voucher
        </a>
        <div>
          <span class="text-muted small">Dữ liệu năm: </span>
          <span class="font-weight-bold text-primary"><c:out value="${currentYear}" /></span>
        </div>
      </div>
    </div>

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
            <table class="table table-custom table-hover">
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
                  <tr>
                    <td>
                      <span class="font-weight-bold text-dark font-monospace">
                        <c:out value="${booking.bookingCode}" />
                      </span>
                    </td>
                    <td>
                      <strong><c:out value="${booking.customerName}" /></strong>
                      <c:if test="${not empty booking.customerPhone}">
                        <div class="small text-muted"><c:out value="${booking.customerPhone}" /></div>
                      </c:if>
                    </td>
                    <td>
                      <span class="text-dark font-weight-500"><c:out value="${booking.roomName}" /></span>
                      <div class="small text-muted"><c:out value="${booking.propertyName}" /></div>
                    </td>
                    <td>
                      <fmt:formatDate value="${booking.checkInDate}" pattern="dd/MM/yyyy" />
                      <span class="text-muted">→</span>
                      <fmt:formatDate value="${booking.checkOutDate}" pattern="dd/MM/yyyy" />
                    </td>
                    <td>
                      <c:out value="${booking.guestCount}" /> người
                    </td>
                    <td>
                      <strong class="text-primary">
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
                      <div class="p-3 bg-light rounded border">
                        <div class="d-flex justify-content-between align-items-center">
                          <strong><c:out value="${room.roomName}" /></strong>
                          <span class="text-primary font-weight-bold">
                            <fmt:formatNumber value="${room.pricePerNight}" pattern="#,##0" /> ₫ / đêm
                          </span>
                        </div>
                        <div class="small text-muted mt-1">
                          <i class="fa fa-users mr-1"></i>Tối đa <c:out value="${room.maxGuests}" /> khách ·
                          <i class="fa fa-bed mr-1"></i><c:out value="${room.bedCount}" /> giường ·
                          <i class="fa fa-bath mr-1"></i><c:out value="${room.bathroomCount}" /> phòng tắm
                        </div>
                        <c:if test="${not empty room.amenities}">
                          <div class="small text-muted mt-2 border-top pt-2">
                            Tiện ích: <c:out value="${room.amenities}" />
                          </div>
                        </c:if>
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
