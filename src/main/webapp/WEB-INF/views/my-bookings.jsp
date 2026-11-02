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

    /* Scoped Dark Mode Overrides */
    [data-theme="dark"] .my-bookings-hero-header {
        background: #111827 !important;
        border-color: #1e293b !important;
    }
    [data-theme="dark"] .my-bookings-hero-header h1,
    [data-theme="dark"] .my-bookings-hero-header .text-dark,
    [data-theme="dark"] .my-bookings-hero-header .breadcrumb-item.active {
        color: #f8fafc !important;
    }
    [data-theme="dark"] .booking-card {
        background: #162032 !important;
        border-color: #243247 !important;
    }
    [data-theme="dark"] .booking-card-header {
        background: #111827 !important;
        border-color: #243247 !important;
    }
    [data-theme="dark"] .booking-card-header .text-dark,
    [data-theme="dark"] .booking-card-body .text-dark {
        color: #f8fafc !important;
    }
    [data-theme="dark"] .filter-tab-btn {
        background: #1e293b !important;
        color: #94a3b8 !important;
        border-color: #334155 !important;
    }
    [data-theme="dark"] .filter-tab-btn.active {
        background: #ffba5a !important;
        color: #0f172a !important;
    }
    [data-theme="dark"] .booking-filter-nav {
        border-color: #334155 !important;
    }
    [data-theme="dark"] .modal-content {
        background: #162032 !important;
        color: #f8fafc !important;
        border-color: #334155 !important;
    }
    [data-theme="dark"] .modal-header,
    [data-theme="dark"] .modal-footer {
        background: #111827 !important;
        border-color: #243247 !important;
    }
    [data-theme="dark"] .modal-title,
    [data-theme="dark"] .text-dark {
        color: #f8fafc !important;
    }
    [data-theme="dark"] .bg-light {
        background: #1e293b !important;
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

                                        <c:if test="${not empty booking.bookingRooms && booking.bookingRooms.size() > 1}">
                                            <div class="mb-2">
                                                <span class="badge badge-light border text-primary">
                                                    <i class="fa fa-cubes mr-1"></i> Đơn gồm ${booking.bookingRooms.size()} phòng
                                                </span>
                                            </div>
                                        </c:if>

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
                                    <a href="${pageContext.request.contextPath}/booking?step=success&code=${booking.bookingCode}"
                                       class="btn btn-sm btn-outline-primary rounded-pill px-3 font-weight-bold mr-1">
                                        <i class="fa fa-file-text-o mr-1"></i> Chi tiết
                                    </a>

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

                                    <!-- Direct cancel for PENDING bookings -->
                                    <c:if test="${booking.status == 'PENDING'}">
                                        <form action="${pageContext.request.contextPath}/my-bookings" method="post" class="d-inline ml-1"
                                              onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn đặt phòng này?');">
                                            <input type="hidden" name="action" value="cancel" />
                                            <input type="hidden" name="bookingId" value="${booking.id}" />
                                            <button type="submit" class="btn btn-sm btn-outline-secondary rounded-pill px-3">
                                                <i class="fa fa-ban mr-1"></i> Hủy đơn
                                            </button>
                                        </form>
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
