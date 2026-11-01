<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="../common/header.jsp">
    <jsp:param name="pageTitle" value="Host Dashboard - Sogo Homestay" />
</jsp:include>

<jsp:include page="../common/navbar.jsp" />

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
    .host-dash { padding-top: 100px; padding-bottom: 80px; background: #f2f4fb; min-height: 70vh; }
    .host-dash .page-title {
        font-family: "Playfair Display", serif;
        font-weight: 700;
        color: #1a1a1a;
        margin-bottom: 0.25rem;
    }
    .host-dash .page-sub { color: #6c757d; font-size: 0.95rem; }
    .stat-card, .profile-card, .property-card, .wallet-card {
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 2px 12px rgba(0,0,0,.06);
        border: 1px solid rgba(0,0,0,.04);
        transition: box-shadow .2s ease, transform .2s ease;
    }
    .stat-card:hover, .property-card:hover {
        box-shadow: 0 8px 24px rgba(0,0,0,.1);
        transform: translateY(-2px);
    }
    .stat-card { padding: 1.25rem 1.5rem; height: 100%; }
    .stat-card .stat-label { font-size: .8rem; color: #6c757d; text-transform: uppercase; letter-spacing: .04em; margin-bottom: .35rem; }
    .stat-card .stat-value { font-family: "Playfair Display", serif; font-size: 1.6rem; font-weight: 700; color: #1a1a1a; line-height: 1.2; }
    .stat-card .stat-icon {
        width: 44px; height: 44px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center;
        background: rgba(255,186,90,.15); color: #e09a2e; font-size: 1.15rem;
    }
    .stat-card.wallet-stat-card {
        background: linear-gradient(135deg, #ffffff 0%, #f0fdf4 100%);
        border: 1px solid #bbf7d0;
    }
    .stat-card.wallet-stat-card .stat-icon {
        background: #dcfce7;
        color: #15803d;
    }
    .stat-card.wallet-stat-card .stat-value {
        color: #15803d;
    }
    .profile-card { padding: 1.5rem; height: 100%; }
    .profile-card h5 {
        font-family: "Playfair Display", serif; font-weight: 700; font-size: 1.15rem; margin-bottom: 1rem;
    }
    .profile-meta { font-size: .9rem; margin-bottom: .75rem; }
    .profile-meta .label { color: #6c757d; font-size: .75rem; display: block; margin-bottom: 2px; }
    .badge-status {
        display: inline-block; padding: .35em .75em; border-radius: 50px;
        font-size: .75rem; font-weight: 600; letter-spacing: .02em;
    }
    .badge-approved { background: #d4edda; color: #155724; }
    .badge-pending { background: #fff3cd; color: #856404; }
    .badge-rejected { background: #f8d7da; color: #721c24; }
    .badge-draft { background: #e2e3e5; color: #383d41; }
    .badge-active { background: #cce5ff; color: #004085; }
    .btn-host-primary {
        background: #ffba5a; border-color: #ffba5a; color: #fff;
        font-weight: 600; border-radius: 6px; padding: .6rem 1.25rem;
    }
    .btn-host-primary:hover { background: #e09a2e; border-color: #e09a2e; color: #fff; }
    .property-card { overflow: hidden; height: 100%; display: flex; flex-direction: column; }
    .property-card .card-img-wrap {
        height: 160px; background: #e9ecef; position: relative; overflow: hidden;
    }
    .property-card .card-img-wrap img {
        width: 100%; height: 100%; object-fit: cover;
    }
    .property-card .card-img-placeholder {
        width: 100%; height: 100%;
        background: linear-gradient(135deg, #f8f1e5 0%, #ffe8c4 100%);
        display: flex; align-items: center; justify-content: center;
        color: #c49a4a; font-size: 2.5rem;
    }
    .property-card .card-body { padding: 1.15rem 1.25rem 1.25rem; flex: 1; display: flex; flex-direction: column; }
    .property-card .card-title {
        font-family: "Playfair Display", serif; font-weight: 700; font-size: 1.1rem;
        margin-bottom: .35rem; color: #1a1a1a;
    }
    .property-card .card-loc { font-size: .85rem; color: #6c757d; margin-bottom: .5rem; }
    .property-card .card-loc i { color: #ffba5a; margin-right: 4px; }
    .property-card .card-desc {
        font-size: .85rem; color: #6c757d; flex: 1;
        display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
    }
    .empty-state {
        background: #fff; border-radius: 12px; padding: 3rem 1.5rem;
        text-align: center; box-shadow: 0 2px 12px rgba(0,0,0,.05);
    }
    .empty-state .empty-icon {
        width: 72px; height: 72px; border-radius: 50%;
        background: rgba(255,186,90,.12); color: #ffba5a;
        display: inline-flex; align-items: center; justify-content: center;
        font-size: 1.75rem; margin-bottom: 1rem;
    }
    .section-label {
        font-family: "Playfair Display", serif; font-weight: 700; font-size: 1.25rem; margin-bottom: 1rem;
    }
    .badge-tx-credit { background: #dcfce7; color: #15803d; font-weight: 600; }
    .badge-tx-debit { background: #fee2e2; color: #b91c1c; font-weight: 600; }
    .badge-tx-topup { background: #e0f2fe; color: #0369a1; font-weight: 600; }
    .badge-tx-withdrawal { background: #e0e7ff; color: #4338ca; font-weight: 600; }
</style>

<section class="host-dash">
    <div class="container">

        <!-- Header -->
        <div class="d-flex flex-wrap justify-content-between align-items-start mb-4">
            <div class="mb-3 mb-md-0">
                <h1 class="page-title">Host Dashboard</h1>
                <p class="page-sub mb-0">
                    Xin chào
                    <strong><c:out value="${sessionScope.userName}" /></strong>
                    — quản lý homestay và property của bạn
                </p>
            </div>
            <div class="d-flex flex-wrap">
                <a href="${pageContext.request.contextPath}/host/refunds" class="btn btn-outline-danger mr-2 shadow-sm font-weight-bold">
                    <i class="fa fa-undo mr-1"></i> Quản lý hoàn tiền
                </a>
                <a href="${pageContext.request.contextPath}/host/property/create" class="btn btn-host-primary shadow-sm">
                    <i class="fa fa-plus mr-1"></i> Tạo property mới
                </a>
            </div>
        </div>

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
        <c:if test="${not empty error}">
            <div class="alert alert-danger shadow-sm border-0 rounded mb-4">
                <c:out value="${error}" />
            </div>
        </c:if>

        <c:if test="${not empty hostProfile}">
            <!-- Stats -->
            <div class="row mb-4">
                <!-- SỐ DƯ VÍ KHẢ DỤNG (Model 2) -->
                <div class="col-6 col-md-3 mb-3">
                    <div class="stat-card wallet-stat-card d-flex flex-column justify-content-between h-100">
                        <div class="d-flex align-items-center justify-content-between">
                            <div>
                                <div class="stat-label text-success font-weight-bold">
                                    <i class="fa fa-shield mr-1"></i> Số dư ví Host
                                </div>
                                <div class="stat-value text-success font-weight-bold">
                                    <fmt:formatNumber value="${hostBalance}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                                </div>
                            </div>
                            <div class="stat-icon"><i class="fa fa-credit-card"></i></div>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mt-2 pt-2 border-top">
                            <small class="text-muted" style="font-size: 11px;">
                                <i class="fa fa-check-circle text-success mr-1"></i>Khả dụng hoàn tiền
                            </small>
                            <button type="button" class="btn btn-xs btn-sm btn-link text-success p-0 font-weight-bold" onclick="openTopupModal()">
                                + Nạp ví
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Properties -->
                <div class="col-6 col-md-3 mb-3">
                    <div class="stat-card d-flex align-items-center justify-content-between">
                        <div>
                            <div class="stat-label">Homestay / Property</div>
                            <div class="stat-value">
                                <c:choose>
                                    <c:when test="${empty properties}">0</c:when>
                                    <c:otherwise>${fn:length(properties)}</c:otherwise>
                                </c:choose>
                            </div>
                            <small class="text-muted" style="font-size: 11px;">Cơ sở đang vận hành</small>
                        </div>
                        <div class="stat-icon"><i class="fa fa-building"></i></div>
                    </div>
                </div>

                <!-- Trạng thái Host -->
                <div class="col-6 col-md-3 mb-3">
                    <div class="stat-card d-flex align-items-center justify-content-between">
                        <div>
                            <div class="stat-label">Trạng thái Host</div>
                            <div class="stat-value" style="font-size:1.1rem;padding-top:.35rem;">
                                <c:choose>
                                    <c:when test="${hostProfile.verificationStatus == 'APPROVED'}">
                                        <span class="badge-status badge-approved">Đã duyệt</span>
                                    </c:when>
                                    <c:when test="${hostProfile.verificationStatus == 'PENDING'}">
                                        <span class="badge-status badge-pending">Chờ duyệt</span>
                                    </c:when>
                                    <c:when test="${hostProfile.verificationStatus == 'REJECTED'}">
                                        <span class="badge-status badge-rejected">Từ chối</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-status badge-draft"><c:out value="${hostProfile.verificationStatus}" /></span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <small class="text-muted" style="font-size: 11px;">Xác minh danh tính</small>
                        </div>
                        <div class="stat-icon"><i class="fa fa-check-circle"></i></div>
                    </div>
                </div>

                <!-- Liên hệ -->
                <div class="col-6 col-md-3 mb-3">
                    <div class="stat-card d-flex align-items-center justify-content-between">
                        <div>
                            <div class="stat-label">Hotline Liên hệ</div>
                            <div class="stat-value" style="font-size:1.1rem;word-break:break-all;">
                                <c:out value="${empty hostProfile.phone ? '0912345678' : hostProfile.phone}" />
                            </div>
                            <small class="text-muted" style="font-size: 11px;">Hỗ trợ khách hàng</small>
                        </div>
                        <div class="stat-icon"><i class="fa fa-phone"></i></div>
                    </div>
                </div>
            </div>

            <div class="row">
                <!-- Profile side -->
                <div class="col-lg-4 mb-4">
                    <div class="profile-card">
                        <h5><i class="fa fa-id-card-o mr-2" style="color:#ffba5a;"></i>Hồ sơ Host</h5>
                        <div class="profile-meta">
                            <span class="label">Tên doanh nghiệp / Homestay</span>
                            <strong><c:out value="${empty hostProfile.businessName ? '—' : hostProfile.businessName}" /></strong>
                        </div>
                        <div class="profile-meta">
                            <span class="label">Loại hình</span>
                            <strong><c:out value="${empty hostProfile.businessType ? '—' : hostProfile.businessType}" /></strong>
                        </div>
                        <div class="profile-meta">
                            <span class="label">Số điện thoại</span>
                            <strong><c:out value="${empty hostProfile.phone ? '—' : hostProfile.phone}" /></strong>
                        </div>
                        <div class="profile-meta">
                            <span class="label">Trạng thái xác minh</span>
                            <c:choose>
                                <c:when test="${hostProfile.verificationStatus == 'APPROVED'}">
                                    <span class="badge-status badge-approved">APPROVED</span>
                                </c:when>
                                <c:when test="${hostProfile.verificationStatus == 'PENDING'}">
                                    <span class="badge-status badge-pending">PENDING</span>
                                </c:when>
                                <c:when test="${hostProfile.verificationStatus == 'REJECTED'}">
                                    <span class="badge-status badge-rejected">REJECTED</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge-status badge-draft"><c:out value="${hostProfile.verificationStatus}" /></span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <hr>
                        <a href="${pageContext.request.contextPath}/host/property/create" class="btn btn-outline-warning btn-block font-weight-bold" style="color:#e09a2e; border-color:#ffba5a;">
                            <i class="fa fa-plus mr-1"></i> Thêm property
                        </a>
                    </div>
                </div>

                <!-- Properties side -->
                <div class="col-lg-8 mb-4">
                    <h5 class="section-label">Danh sách property</h5>
                    <c:choose>
                        <c:when test="${empty properties}">
                            <div class="empty-state">
                                <div class="empty-icon"><i class="fa fa-home"></i></div>
                                <h5 class="mb-2" style="font-family:'Playfair Display',serif;">Chưa có property nào</h5>
                                <p class="text-muted mb-3">Bắt đầu bằng việc thêm homestay hoặc property đầu tiên của bạn.</p>
                                <a href="${pageContext.request.contextPath}/host/property/create" class="btn btn-host-primary">
                                    <i class="fa fa-plus mr-1"></i> Tạo property mới
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="row">
                                <c:forEach var="property" items="${properties}">
                                    <div class="col-md-6 mb-3">
                                        <div class="property-card">
                                            <div class="card-img-wrap">
                                                <div class="card-img-placeholder">
                                                    <i class="fa fa-picture-o"></i>
                                                </div>
                                                <div class="position-absolute" style="top:10px;left:10px;">
                                                    <span class="badge-status badge-approved">
                                                        <c:out value="${property.status}" />
                                                    </span>
                                                </div>
                                            </div>
                                            <div class="card-body">
                                                <h6 class="card-title">
                                                    <c:out value="${property.name}" />
                                                </h6>
                                                <div class="card-loc">
                                                    <i class="fa fa-map-marker"></i>
                                                    <c:out value="${property.address}" />
                                                    <c:if test="${not empty property.city}">
                                                        , <c:out value="${property.city}" />
                                                    </c:if>
                                                </div>
                                                <c:if test="${not empty property.description}">
                                                    <p class="card-desc mb-2"><c:out value="${property.description}" /></p>
                                                </c:if>
                                                <c:if test="${not empty property.propertyType}">
                                                    <span class="badge badge-light border text-muted small">
                                                        <c:out value="${property.propertyType}" />
                                                    </span>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <!-- Host Bookings & Revenue Withdrawal (Model 2) -->
                    <div class="card border-0 shadow-sm rounded-12 mt-4" style="border-radius: 12px; overflow: hidden;">
                        <div class="card-header bg-white border-bottom py-3 d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="font-weight-bold mb-0 text-dark">
                                    <i class="fa fa-calendar-check-o text-success mr-2"></i>Đơn đặt phòng & Rút doanh thu về ngân hàng
                                </h6>
                                <small class="text-muted">Rút tiền doanh thu từ từng đơn đặt phòng về trực tiếp tài khoản ngân hàng của bạn</small>
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0" style="font-size: 13px;">
                                    <thead class="thead-light">
                                        <tr>
                                            <th>Mã đơn</th>
                                            <th>Homestay / Phòng</th>
                                            <th>Khách hàng</th>
                                            <th>Thời gian ở</th>
                                            <th>Doanh thu</th>
                                            <th>Trạng thái</th>
                                            <th class="text-right">Rút tiền ngân hàng</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty hostBookings}">
                                                <tr>
                                                    <td colspan="7" class="text-center py-4 text-muted">
                                                        Chưa có đơn đặt phòng nào cho cơ sở của bạn.
                                                    </td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="b" items="${hostBookings}">
                                                    <tr>
                                                        <td>
                                                            <div class="font-weight-bold font-monospace text-dark">${b.bookingCode}</div>
                                                            <small class="text-muted"><fmt:formatDate value="${b.createdAt}" pattern="dd/MM/yyyy HH:mm"/></small>
                                                        </td>
                                                        <td>
                                                            <div class="font-weight-bold text-dark">${b.propertyName}</div>
                                                            <small class="text-secondary">${b.roomName}</small>
                                                        </td>
                                                        <td>
                                                            <div class="font-weight-bold text-dark">${b.customerName}</div>
                                                            <small class="text-muted">${b.customerPhone}</small>
                                                        </td>
                                                        <td class="text-muted text-nowrap">
                                                            <fmt:formatDate value="${b.checkInDate}" pattern="dd/MM/yyyy"/>
                                                            <i class="fa fa-arrow-right mx-1 small text-muted"></i>
                                                            <fmt:formatDate value="${b.checkOutDate}" pattern="dd/MM/yyyy"/>
                                                        </td>
                                                        <td>
                                                            <span class="font-weight-bold text-success font-monospace" style="font-size: 14px;">
                                                                <fmt:formatNumber value="${b.totalAmount}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${b.status == 'CONFIRMED'}">
                                                                    <span class="badge badge-success px-2 py-1">Đã xác nhận</span>
                                                                </c:when>
                                                                <c:when test="${b.status == 'REFUNDED'}">
                                                                    <span class="badge badge-secondary px-2 py-1">Đã hoàn tiền</span>
                                                                </c:when>
                                                                <c:when test="${b.status == 'PENDING'}">
                                                                    <span class="badge badge-warning px-2 py-1">Chờ thanh toán</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge badge-light border text-muted">${b.status}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td class="text-right">
                                                            <c:choose>
                                                                <c:when test="${b.canWithdraw()}">
                                                                    <button type="button" class="btn btn-sm btn-primary rounded-pill px-3 font-weight-bold shadow-sm"
                                                                            onclick="openWithdrawModal(${b.id}, '${b.bookingCode}', ${b.totalAmount})">
                                                                        <i class="fa fa-university mr-1"></i> Rút về ngân hàng
                                                                    </button>
                                                                </c:when>
                                                                <c:when test="${b.isWithdrawn()}">
                                                                    <span class="badge badge-info px-2 py-1 text-white">
                                                                        <i class="fa fa-check mr-1"></i> Đã rút tiền
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${b.status == 'REFUNDED'}">
                                                                    <span class="text-muted small font-italic">Đã hoàn tiền khách</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-muted small">Không khả dụng</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- Recent Wallet Transactions (Model 2) -->
                    <div class="card border-0 shadow-sm rounded-12 mt-4" style="border-radius: 12px; overflow: hidden;">
                        <div class="card-header bg-white border-bottom py-3 d-flex justify-content-between align-items-center">
                            <h6 class="font-weight-bold mb-0 text-dark">
                                <i class="fa fa-history text-primary mr-2"></i>Biến động số dư Ví Host gần đây
                            </h6>
                            <a href="${pageContext.request.contextPath}/host/refunds" class="btn btn-sm btn-link text-primary font-weight-bold p-0">
                                Quản lý hoàn tiền & Chi tiết ví <i class="fa fa-angle-right ml-1"></i>
                            </a>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0" style="font-size: 13px;">
                                    <thead class="thead-light">
                                        <tr>
                                            <th>Thời gian</th>
                                            <th>Loại GD</th>
                                            <th>Số tiền</th>
                                            <th>Số dư sau GD</th>
                                            <th>Nội dung</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty recentTransactions}">
                                                <tr>
                                                    <td colspan="5" class="text-center py-4 text-muted">
                                                        Chưa có biến động số dư nào trong ví.
                                                    </td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="tx" items="${recentTransactions}">
                                                    <tr>
                                                        <td class="text-muted text-nowrap">
                                                            <fmt:formatDate value="${tx.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${tx.transactionType == 'CREDIT_BOOKING'}">
                                                                    <span class="badge badge-tx-credit px-2 py-1">Doanh thu phòng</span>
                                                                </c:when>
                                                                <c:when test="${tx.transactionType == 'DEBIT_REFUND'}">
                                                                    <span class="badge badge-tx-debit px-2 py-1">Hoàn tiền khách</span>
                                                                </c:when>
                                                                <c:when test="${tx.transactionType == 'DEBIT_WITHDRAWAL'}">
                                                                    <span class="badge badge-tx-withdrawal px-2 py-1">Rút về ngân hàng</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge badge-tx-topup px-2 py-1">Nạp tiền ký quỹ</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td class="font-weight-bold">
                                                            <c:choose>
                                                                <c:when test="${tx.transactionType == 'DEBIT_REFUND' or tx.transactionType == 'DEBIT_WITHDRAWAL'}">
                                                                    <span class="text-danger">-<fmt:formatNumber value="${tx.amount}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/></span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-success">+<fmt:formatNumber value="${tx.amount}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/></span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td class="text-muted">
                                                            <fmt:formatNumber value="${tx.balanceAfter}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                                                        </td>
                                                        <td>
                                                            <c:out value="${tx.description}"/>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </c:if>

        <c:if test="${empty hostProfile and empty error}">
            <div class="empty-state">
                <div class="empty-icon"><i class="fa fa-user-plus"></i></div>
                <h5 class="mb-2" style="font-family:'Playfair Display',serif;">Chưa có hồ sơ Host</h5>
                <p class="text-muted mb-3">Đăng ký trở thành Host để quản lý property tại đây.</p>
                <a href="${pageContext.request.contextPath}/become-host" class="btn btn-host-primary">Trở thành Host</a>
            </div>
        </c:if>

    </div>
</section>

<!-- ========================================== -->
<!-- MODAL RÚT TIỀN VỀ NGÂN HÀNG HOST (MODEL 2) -->
<!-- ========================================== -->
<div class="modal fade" id="withdrawModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px; overflow: hidden;">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title font-weight-bold">
                    <i class="fa fa-university mr-2"></i>Rút Doanh Thu Đơn Phòng Về Ngân Hàng Host
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <form action="${pageContext.request.contextPath}/host/dashboard" method="post" id="withdrawForm">
                <input type="hidden" name="action" value="withdraw" />
                <input type="hidden" name="bookingId" id="withdrawBookingId" />
                <div class="modal-body p-4">
                    <p class="text-muted mb-3" style="font-size: 13.5px;">
                        Rút tiền doanh thu của đơn đặt phòng <strong id="withdrawBookingCode" class="text-dark font-monospace"></strong> về tài khoản ngân hàng của bạn.
                    </p>

                    <!-- Summary box -->
                    <div class="p-3 bg-light rounded mb-3 border">
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">Doanh thu đơn phòng:</span>
                            <span id="withdrawAmountDisplay" class="font-weight-bold text-success" style="font-size: 17px;"></span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">Số dư ví Host hiện tại:</span>
                            <span class="font-weight-bold text-dark" style="font-size: 15px;">
                                <fmt:formatNumber value="${hostBalance}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="d-flex justify-content-between pt-2 border-top">
                            <span class="text-muted">Số dư ví sau khi rút:</span>
                            <span id="withdrawBalanceAfter" class="font-weight-bold" style="font-size: 15px;"></span>
                        </div>

                        <div id="withdrawInsufficientAlert" class="alert alert-danger py-2 px-3 mb-0 mt-3 small" style="display: none;">
                            <i class="fa fa-exclamation-triangle mr-1"></i> Số dư ví hiện tại không đủ để thực hiện rút tiền!
                        </div>
                    </div>

                    <!-- Bank details -->
                    <div class="form-group mb-2">
                        <label class="font-weight-bold text-dark" style="font-size: 13px;">Ngân hàng nhận tiền <span class="text-danger">*</span></label>
                        <select name="bankCode" class="form-control font-weight-bold" required>
                            <option value="TPBANK" selected>TPBank (Ngân hàng Tiên Phong)</option>
                            <option value="MB">MBBank (Ngân hàng Quân Đội)</option>
                            <option value="VCB">Vietcombank (Ngoại Thương Việt Nam)</option>
                            <option value="TCB">Techcombank (Kỹ Thương Việt Nam)</option>
                            <option value="BIDV">BIDV (Đầu tư và Phát triển VN)</option>
                            <option value="ICB">VietinBank (Công Thương Việt Nam)</option>
                            <option value="VPB">VPBank (Việt Nam Thịnh Vượng)</option>
                            <option value="ACB">ACB (Á Châu)</option>
                        </select>
                    </div>

                    <div class="form-group mb-2">
                        <label class="font-weight-bold text-dark" style="font-size: 13px;">Số tài khoản thụ hưởng <span class="text-danger">*</span></label>
                        <input type="text" name="accountNumber" class="form-control font-monospace font-weight-bold" value="22465786789" required />
                    </div>

                    <div class="form-group mb-2">
                        <label class="font-weight-bold text-dark" style="font-size: 13px;">Tên chủ tài khoản <span class="text-danger">*</span></label>
                        <input type="text" name="accountHolder" class="form-control font-weight-bold text-uppercase" value="NGUYEN THANH HAI" required />
                    </div>

                    <div class="form-group mb-0">
                        <label class="font-weight-bold text-dark" style="font-size: 13px;">Ghi chú rút tiền:</label>
                        <input type="text" name="notes" class="form-control" value="Rút tiền doanh thu phòng về ngân hàng Host" />
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-dismiss="modal">Đóng</button>
                    <button type="submit" id="btnConfirmWithdraw" class="btn btn-primary rounded-pill px-4 font-weight-bold">
                        <i class="fa fa-university mr-1"></i> Xác Nhận Rút Tiền Về Ngân Hàng
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ========================================== -->
<!-- MODAL TOP-UP WALLET (NẠP TIỀN VÍ HOST)      -->
<!-- ========================================== -->
<div class="modal fade" id="topupModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px; overflow: hidden;">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title font-weight-bold">
                    <i class="fa fa-credit-card mr-2"></i>Nạp Tiền Vào Ví Host
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <form action="${pageContext.request.contextPath}/host/dashboard" method="post" id="topupForm">
                <input type="hidden" name="action" value="topup" />
                <div class="modal-body p-4">
                    <p class="text-muted mb-3" style="font-size: 13px;">
                        Nạp thêm số dư vào ví Host để dự phòng thanh toán hoàn tiền hoặc lưu giữ quỹ.
                    </p>

                    <div class="form-group">
                        <label class="font-weight-bold text-dark" style="font-size: 13px;">Chọn nhanh số tiền nạp:</label>
                        <div class="d-flex flex-wrap gap-2 mb-2">
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill mr-2 mb-2 font-weight-bold" onclick="selectTopupAmount(500000)">+ 500.000đ</button>
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill mr-2 mb-2 font-weight-bold" onclick="selectTopupAmount(2000000)">+ 2.000.000đ</button>
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill mr-2 mb-2 font-weight-bold" onclick="selectTopupAmount(5000000)">+ 5.000.000đ</button>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="font-weight-bold text-dark" style="font-size: 13px;">Số tiền nạp (VNĐ): <span class="text-danger">*</span></label>
                        <input type="number" step="1000" min="1000" name="amount" id="topupAmountInput" class="form-control form-control-lg font-weight-bold text-success" placeholder="Nhập số tiền VNĐ..." required value="2000000" />
                    </div>

                    <div class="form-group mb-0">
                        <label class="font-weight-bold text-dark" style="font-size: 13px;">Nội dung nạp tiền:</label>
                        <input type="text" name="note" class="form-control" value="Nạp tiền bổ sung Ví Host" />
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-success rounded-pill px-4 font-weight-bold">
                        <i class="fa fa-arrow-down mr-1"></i> Xác Nhận Nạp Tiền
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />

<script>
    var currentHostBal = ${hostBalance != null ? hostBalance : 0};

    function openWithdrawModal(bookingId, bookingCode, amount) {
        document.getElementById('withdrawBookingId').value = bookingId;
        document.getElementById('withdrawBookingCode').textContent = '#' + bookingCode;

        var formattedAmount = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
        document.getElementById('withdrawAmountDisplay').textContent = formattedAmount;

        var balAfter = currentHostBal - amount;
        var formattedBalAfter = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(balAfter);
        var balAfterElem = document.getElementById('withdrawBalanceAfter');
        balAfterElem.textContent = formattedBalAfter;

        var alertInsufficient = document.getElementById('withdrawInsufficientAlert');
        var btnConfirm = document.getElementById('btnConfirmWithdraw');

        if (currentHostBal >= amount) {
            balAfterElem.className = 'font-weight-bold text-success';
            alertInsufficient.style.display = 'none';
            btnConfirm.disabled = false;
        } else {
            balAfterElem.className = 'font-weight-bold text-danger';
            alertInsufficient.style.display = 'block';
            btnConfirm.disabled = true;
        }

        $('#withdrawModal').modal('show');
    }

    function openTopupModal() {
        $('#topupModal').modal('show');
    }

    function selectTopupAmount(val) {
        document.getElementById('topupAmountInput').value = val;
    }
</script>
