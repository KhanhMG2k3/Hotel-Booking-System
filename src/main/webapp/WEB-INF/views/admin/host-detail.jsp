<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../common/header.jsp">
    <jsp:param name="pageTitle" value="Chi tiết Tài khoản Host - ${hostAccount.fullName}" />
</jsp:include>

<jsp:include page="../common/navbar.jsp" />

<style>
    /* Header styling */
    html:not([data-theme="dark"]) .site-header,
    body:not([data-theme="dark"]) .site-header {
        background: #ffffff !important;
        padding: 15px 0 !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.06) !important;
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

    [data-theme="dark"] .site-header {
        background: #0f172a !important;
        border-bottom: 1px solid #334155 !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5) !important;
    }
    [data-theme="dark"] .site-header .site-logo a,
    [data-theme="dark"] .site-header .user-name {
        color: #f8fafc !important;
    }

    .host-detail-page {
        padding-top: 110px;
        padding-bottom: 80px;
        background: #f4f6fb;
        min-height: 85vh;
        font-family: 'Roboto Sans', sans-serif;
    }

    /* Breadcrumbs */
    .breadcrumb-custom {
        background: transparent;
        padding: 0;
        margin-bottom: 1.25rem;
        font-size: 0.9rem;
    }
    .breadcrumb-custom a {
        color: #64748b;
        text-decoration: none;
    }
    .breadcrumb-custom a:hover {
        color: #d97706;
    }
    .breadcrumb-custom .active {
        color: #0f172a;
        font-weight: 600;
    }

    /* Cards */
    .detail-card {
        background: #ffffff;
        border-radius: 16px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
        border: 1px solid rgba(0, 0, 0, 0.05);
        padding: 1.75rem;
        margin-bottom: 1.75rem;
    }

    .card-title-custom {
        font-family: "Playfair Display", serif;
        font-size: 1.35rem;
        font-weight: 700;
        color: #1e293b;
        margin-bottom: 1.25rem;
        padding-bottom: 0.75rem;
        border-bottom: 1px solid #f1f5f9;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    /* Host Header Hero */
    .host-hero {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        justify-content: space-between;
        gap: 1.5rem;
    }
    .host-avatar {
        width: 88px;
        height: 88px;
        border-radius: 50%;
        object-fit: cover;
        border: 4px solid #fff;
        box-shadow: 0 4px 14px rgba(0, 0, 0, 0.1);
    }
    .host-avatar-default {
        width: 88px;
        height: 88px;
        border-radius: 50%;
        background: #e2e8f0;
        color: #475569;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 2.2rem;
        border: 4px solid #fff;
        box-shadow: 0 4px 14px rgba(0, 0, 0, 0.1);
    }

    /* Stat Widgets */
    .stat-widget {
        background: #f8fafc;
        border-radius: 12px;
        padding: 1rem 1.25rem;
        border: 1px solid #e2e8f0;
        text-align: center;
    }
    .stat-widget .stat-number {
        font-size: 1.75rem;
        font-weight: 700;
        font-family: "Playfair Display", serif;
        line-height: 1.2;
    }
    .stat-widget .stat-label {
        font-size: 0.8rem;
        text-transform: uppercase;
        color: #64748b;
        font-weight: 600;
        letter-spacing: 0.03em;
        margin-top: 4px;
    }

    /* Info Fields */
    .info-label {
        font-size: 0.82rem;
        color: #64748b;
        text-transform: uppercase;
        font-weight: 600;
        margin-bottom: 0.25rem;
    }
    .info-value {
        font-size: 0.98rem;
        color: #1e293b;
        font-weight: 600;
        margin-bottom: 1.25rem;
    }

    /* Room Table */
    .table-rooms {
        margin-bottom: 0;
        font-size: 0.92rem;
    }
    .table-rooms thead th {
        background: #f8fafc;
        color: #475569;
        font-weight: 700;
        text-transform: uppercase;
        font-size: 0.78rem;
        letter-spacing: 0.04em;
        border-top: none;
        border-bottom: 2px solid #e2e8f0;
        padding: 0.9rem 1rem;
        vertical-align: middle;
    }
    .table-rooms tbody td {
        padding: 1rem;
        vertical-align: middle;
        border-bottom: 1px solid #f1f5f9;
        color: #334155;
    }
    .table-rooms tbody tr:hover {
        background: #fbfcfe;
    }

    /* Badges */
    .status-badge {
        display: inline-block;
        padding: 0.35em 0.85em;
        border-radius: 50px;
        font-size: 0.78rem;
        font-weight: 700;
    }
    .badge-banned {
        background: #fee2e2;
        color: #991b1b;
        border: 1px solid #f87171;
    }
    .badge-active {
        background: #dcfce7;
        color: #166534;
        border: 1px solid #86efac;
    }

    /* Empty state */
    .empty-box {
        text-align: center;
        padding: 3rem 1.5rem;
    }
    .empty-icon {
        width: 68px;
        height: 68px;
        border-radius: 50%;
        background: #f1f5f9;
        color: #64748b;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 2rem;
        margin-bottom: 1rem;
    }
    /* ==========================================================================
       HOST DETAIL DARK MODE STYLES
       ========================================================================== */
    [data-theme="dark"] .host-detail-page {
        background: var(--bg-body) !important;
    }
    [data-theme="dark"] .detail-card {
        background: var(--bg-card) !important;
        border-color: var(--border-color) !important;
        box-shadow: var(--shadow-card) !important;
        color: var(--text-body) !important;
    }
    [data-theme="dark"] .card-title-custom {
        color: var(--text-heading) !important;
        border-bottom-color: var(--border-color) !important;
    }
    [data-theme="dark"] .breadcrumb-custom a {
        color: var(--text-muted) !important;
    }
    [data-theme="dark"] .breadcrumb-custom a:hover {
        color: var(--primary-accent) !important;
    }
    [data-theme="dark"] .breadcrumb-custom .active {
        color: var(--text-heading) !important;
    }
    [data-theme="dark"] .stat-widget {
        background: var(--bg-surface) !important;
        border-color: var(--border-color) !important;
    }
    [data-theme="dark"] .stat-widget .stat-number {
        color: var(--text-heading) !important;
    }
    [data-theme="dark"] .stat-widget .stat-label {
        color: var(--text-muted) !important;
    }
    [data-theme="dark"] .info-label {
        color: var(--text-muted) !important;
    }
    [data-theme="dark"] .info-value {
        color: var(--text-heading) !important;
    }
    [data-theme="dark"] .property-mini-card {
        background: var(--bg-surface) !important;
        border-color: var(--border-color) !important;
    }
    [data-theme="dark"] .table-rooms thead th {
        background: var(--bg-surface) !important;
        color: var(--text-heading) !important;
        border-bottom-color: var(--border-color) !important;
    }
    [data-theme="dark"] .table-rooms tbody td {
        color: var(--text-body) !important;
        border-bottom-color: var(--border-color) !important;
    }
    [data-theme="dark"] .table-rooms tbody tr:hover {
        background: rgba(255, 255, 255, 0.04) !important;
    }
    [data-theme="dark"] .empty-box {
        color: var(--text-muted) !important;
    }
    [data-theme="dark"] .empty-icon {
        background: var(--bg-surface) !important;
        color: var(--text-muted) !important;
    }
    [data-theme="dark"] .host-avatar-default {
        background: var(--bg-surface) !important;
        color: var(--text-muted) !important;
        border-color: var(--border-color) !important;
    }
    [data-theme="dark"] .room-thumb-empty {
        background: var(--bg-surface) !important;
        color: var(--text-muted) !important;
        border: 1px solid var(--border-color) !important;
    }
    [data-theme="dark"] .badge-banned {
        background: rgba(239, 68, 68, 0.18) !important;
        color: #f87171 !important;
        border-color: rgba(239, 68, 68, 0.4) !important;
    }
    [data-theme="dark"] .badge-active {
        background: rgba(16, 185, 129, 0.18) !important;
        color: #6ee7b7 !important;
        border-color: rgba(16, 185, 129, 0.4) !important;
    }
    [data-theme="dark"] .btn-outline-secondary {
        border-color: var(--border-color) !important;
        color: var(--text-muted) !important;
        background: var(--bg-surface) !important;
    }
    [data-theme="dark"] .btn-outline-secondary:hover {
        background: var(--bg-surface-alt) !important;
        color: var(--text-heading) !important;
    }
    [data-theme="dark"] a.text-dark,
    [data-theme="dark"] .text-dark {
        color: var(--text-heading) !important;
    }
</style>

<section class="host-detail-page">
    <div class="container">

        <!-- Breadcrumb & Back Button -->
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb breadcrumb-custom">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Bảng Quản Trị</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard?tab=tab-properties">Quản lý tài khoản Host</a></li>
                <li class="breadcrumb-item active" aria-current="page"><c:out value="${hostAccount.fullName}" /></li>
            </ol>
        </nav>

        <!-- Top Header & Actions -->
        <div class="d-flex flex-wrap justify-content-between align-items-center mb-3">
            <div>
                <a href="${pageContext.request.contextPath}/admin/dashboard?tab=tab-properties" class="btn btn-outline-secondary font-weight-bold" style="border-radius: 8px;">
                    <i class="fa fa-arrow-left mr-1"></i> Quay lại Danh sách Host
                </a>
            </div>
            <div class="d-flex gap-2 mt-2 mt-md-0">
                <c:choose>
                    <c:when test="${hostAccount.status == 'BANNED'}">
                        <form method="post" action="${pageContext.request.contextPath}/admin/host-detail" style="display:inline-block;" onsubmit="return confirm('Bạn có chắc chắn muốn MỞ KHÓA tài khoản Host #${hostAccount.userId} (${fn:escapeXml(hostAccount.fullName)})? Sau khi mở khóa, tài khoản Host có thể đăng nhập bình thường.');">
                            <input type="hidden" name="action" value="unbanHost">
                            <input type="hidden" name="hostId" value="${hostAccount.userId}">
                            <button type="submit" class="btn btn-success font-weight-bold" style="border-radius: 8px; padding: 0.5rem 1.25rem; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 4px 12px rgba(40,167,69,0.25);">
                                <i class="fa fa-unlock"></i> Mở khóa tài khoản Host
                            </button>
                        </form>
                    </c:when>
                    <c:otherwise>
                        <form method="post" action="${pageContext.request.contextPath}/admin/host-detail" style="display:inline-block;" onsubmit="return confirm('CẢNH BÁO QUAN TRỌNG:\nBạn có chắc chắn muốn KHÓA (BAN) tài khoản Host #${hostAccount.userId} (${fn:escapeXml(hostAccount.fullName)})?\nHost sẽ bị khóa tài khoản và chặn truy cập vào hệ thống.');">
                            <input type="hidden" name="action" value="banHost">
                            <input type="hidden" name="hostId" value="${hostAccount.userId}">
                            <button type="submit" class="btn btn-danger font-weight-bold" style="border-radius: 8px; padding: 0.5rem 1.25rem; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 4px 12px rgba(220,53,69,0.25);">
                                <i class="fa fa-ban"></i> Khóa tài khoản (Ban Host)
                            </button>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Flash Alert Messages -->
        <c:if test="${not empty messageSuccess}">
            <div class="alert alert-success alert-dismissible fade show mb-4" role="alert" style="border-radius: 10px;">
                <i class="fa fa-check-circle mr-2"></i> <strong>Thành công!</strong> <c:out value="${messageSuccess}" />
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </c:if>
        <c:if test="${not empty messageError}">
            <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert" style="border-radius: 10px;">
                <i class="fa fa-exclamation-triangle mr-2"></i> <strong>Lỗi:</strong> <c:out value="${messageError}" />
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </c:if>

        <!-- CARD 1: HOST PROFILE HEADER HERO -->
        <div class="detail-card">
            <div class="host-hero">
                <div class="d-flex align-items-center">
                    <c:choose>
                        <c:when test="${not empty hostAccount.avatarUrl}">
                            <img src="${hostAccount.avatarUrl}" alt="${fn:escapeXml(hostAccount.fullName)}" class="host-avatar mr-4">
                        </c:when>
                        <c:otherwise>
                            <div class="host-avatar-default mr-4">
                                <i class="fa fa-user"></i>
                            </div>
                        </c:otherwise>
                    </c:choose>
                    <div>
                        <div class="d-flex align-items-center flex-wrap gap-2 mb-1">
                            <h2 class="mb-0 font-weight-bold text-dark" style="font-size: 1.7rem;">
                                <c:out value="${hostAccount.fullName}" />
                            </h2>
                            <span class="badge badge-light border text-muted ml-2" style="font-size: 0.85rem;">
                                @<c:out value="${hostAccount.username}" />
                            </span>
                            <span class="badge badge-info ml-1" style="font-size: 0.8rem; background-color: #0284c7;">
                                <i class="fa fa-id-badge mr-1"></i> Mã Host #${hostAccount.userId}
                            </span>
                        </div>
                        <div class="mt-2 d-flex flex-wrap align-items-center gap-3 text-muted small">
                            <span><i class="fa fa-envelope text-primary mr-1"></i> <a href="mailto:${hostAccount.email}" class="text-dark font-weight-bold"><c:out value="${hostAccount.email}" /></a></span>
                            <c:if test="${not empty hostAccount.phone}">
                                <span>&bull; <i class="fa fa-phone text-success mr-1"></i> <a href="tel:${hostAccount.phone}" class="text-dark font-weight-bold"><c:out value="${hostAccount.phone}" /></a></span>
                            </c:if>
                            <c:if test="${not empty hostAccount.createdAt}">
                                <span>&bull; <i class="fa fa-calendar mr-1"></i> Ngày tham gia: <strong class="text-dark"><fmt:formatDate value="${hostAccount.createdAt}" pattern="dd/MM/yyyy HH:mm" /></strong></span>
                            </c:if>
                        </div>
                    </div>
                </div>

                <!-- Account Status Badge -->
                <div class="text-md-right">
                    <div class="text-muted small mb-1 font-weight-bold">TRẠNG THÁI TÀI KHOẢN</div>
                    <c:choose>
                        <c:when test="${hostAccount.status == 'BANNED'}">
                            <span class="status-badge badge-banned" style="font-size: 0.95rem; padding: 0.45rem 1.15rem;">
                                <i class="fa fa-ban mr-1"></i> ĐÃ BỊ KHÓA (BANNED)
                            </span>
                        </c:when>
                        <c:when test="${hostAccount.status == 'ACTIVE'}">
                            <span class="status-badge badge-active" style="font-size: 0.95rem; padding: 0.45rem 1.15rem;">
                                <i class="fa fa-check-circle mr-1"></i> ĐANG HOẠT ĐỘNG
                            </span>
                        </c:when>
                        <c:otherwise>
                            <span class="status-badge badge-secondary" style="font-size: 0.95rem; padding: 0.45rem 1.15rem;">
                                <c:out value="${hostAccount.status}" />
                            </span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- 4 Quick Metric Summary Cards -->
            <div class="row mt-4 pt-3 border-top">
                <div class="col-6 col-lg-3 mb-2">
                    <div class="stat-widget">
                        <div class="stat-number text-warning">${hostAccount.propertyCount}</div>
                        <div class="stat-label">Chỗ nghỉ / Homestay</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3 mb-2">
                    <div class="stat-widget">
                        <div class="stat-number text-primary">${hostAccount.roomCount}</div>
                        <div class="stat-label">Tổng số phòng ngủ</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3 mb-2">
                    <div class="stat-widget">
                        <div class="stat-number text-success">${availableRoomsCount}</div>
                        <div class="stat-label">Phòng còn trống</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3 mb-2">
                    <div class="stat-widget">
                        <div class="stat-number text-info">${bookedRoomsCount} / ${maintenanceRoomsCount}</div>
                        <div class="stat-label">Đang ở / Bảo trì</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- CARD 2: CHI TIẾT THÔNG TIN CÁ NHÂN & PHÁP LÝ HỒ SƠ -->
        <div class="detail-card">
            <h3 class="card-title-custom">
                <i class="fa fa-id-card-o text-warning"></i> Thông Tin Cá Nhân & Hồ Sơ Đối Tác
            </h3>

            <div class="row">
                <div class="col-12 col-md-6 col-lg-4">
                    <div class="info-label">Họ và tên đầy đủ</div>
                    <div class="info-value"><c:out value="${hostAccount.fullName}" /></div>
                </div>

                <div class="col-12 col-md-6 col-lg-4">
                    <div class="info-label">Tên đăng nhập (Username)</div>
                    <div class="info-value">@<c:out value="${hostAccount.username}" /></div>
                </div>

                <div class="col-12 col-md-6 col-lg-4">
                    <div class="info-label">Địa chỉ Email</div>
                    <div class="info-value"><c:out value="${hostAccount.email}" /></div>
                </div>

                <div class="col-12 col-md-6 col-lg-4">
                    <div class="info-label">Số điện thoại liên lạc</div>
                    <div class="info-value"><c:out value="${not empty hostAccount.phone ? hostAccount.phone : 'Chưa cập nhật'}" /></div>
                </div>

                <div class="col-12 col-md-6 col-lg-4">
                    <div class="info-label">Số CCCD / CMND</div>
                    <div class="info-value">
                        <c:choose>
                            <c:when test="${not empty hostApp && not empty hostApp.identificationNumber}">
                                <span class="badge badge-light border text-dark font-weight-bold px-2 py-1" style="font-size: 0.95rem;">
                                    <i class="fa fa-id-card mr-1 text-primary"></i> <c:out value="${hostApp.identificationNumber}" />
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="text-muted font-weight-normal">Chưa có thông tin CCCD</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-lg-4">
                    <div class="info-label">Địa chỉ cư trú / Doanh nghiệp</div>
                    <div class="info-value">
                        <c:choose>
                            <c:when test="${not empty hostUser && not empty hostUser.address}">
                                <c:out value="${hostUser.address}" />
                            </c:when>
                            <c:when test="${not empty hostApp && not empty hostApp.propertyAddress}">
                                <c:out value="${hostApp.propertyAddress}" />
                            </c:when>
                            <c:otherwise>
                                <span class="text-muted font-weight-normal">Chưa cập nhật địa chỉ</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <c:if test="${not empty hostApp}">
                    <div class="col-12 col-md-6 col-lg-4">
                        <div class="info-label">Hồ sơ đăng ký Host ban đầu</div>
                        <div class="info-value">
                            <a href="${pageContext.request.contextPath}/admin/host-applications?id=${hostApp.id}" class="text-primary font-weight-bold">
                                <i class="fa fa-folder-open-o mr-1"></i> Hồ sơ đối tác #${hostApp.id} (${hostApp.propertyName})
                            </a>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>

        <!-- CARD 3: DANH SÁCH HOMESTAY / CHỖ NGHỈ -->
        <c:if test="${not empty properties}">
            <div class="detail-card">
                <h3 class="card-title-custom">
                    <i class="fa fa-building-o text-warning"></i> Danh Sách Homestay Của Host (${properties.size()})
                </h3>
                <div class="row">
                    <c:forEach var="p" items="${properties}">
                        <div class="col-12 col-md-6 col-lg-4 mb-3">
                            <div class="p-3 border rounded property-mini-card" style="background: #fafbfe;">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <strong class="text-dark" style="font-size: 1.05rem;"><c:out value="${p.name}" /></strong>
                                    <span class="badge badge-light border">#${p.id}</span>
                                </div>
                                <div class="small text-muted mb-2">
                                    <span class="badge badge-warning text-dark">${p.propertyType}</span> &bull; 
                                    <i class="fa fa-map-marker text-danger mr-1"></i><c:out value="${p.city}" />
                                </div>
                                <div class="small text-muted mb-2">
                                    <c:out value="${p.address}" />
                                </div>
                                <div>
                                    <c:choose>
                                        <c:when test="${p.status == 'PUBLISHED'}">
                                            <span class="badge badge-success px-2 py-1"><i class="fa fa-check mr-1"></i> Đang hiển thị</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-secondary px-2 py-1">${p.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>

        <!-- CARD 4: DANH SÁCH TẤT CẢ CÁC PHÒNG VÀ TRẠNG THÁI -->
        <div class="detail-card">
            <h3 class="card-title-custom">
                <i class="fa fa-bed text-warning"></i> Danh Sách Tất Cả Các Phòng Nghỉ (${rooms.size()})
            </h3>

            <c:choose>
                <c:when test="${empty rooms}">
                    <div class="empty-box">
                        <div class="empty-icon">
                            <i class="fa fa-bed"></i>
                        </div>
                        <h4 class="font-weight-bold text-dark">Chưa có phòng nào</h4>
                        <p class="text-muted">Host này hiện tại chưa khởi tạo phòng nghỉ nào trên hệ thống Sogo Homestay.</p>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table table-rooms">
                            <thead>
                                <tr>
                                    <th style="width: 60px;">ID</th>
                                    <th style="width: 90px;" class="text-center">Hình ảnh</th>
                                    <th>Tên phòng & Số hiệu</th>
                                    <th>Thuộc Homestay</th>
                                    <th>Sức chứa & Tiện ích</th>
                                    <th>Giá thuê / đêm</th>
                                    <th style="width: 160px;" class="text-center">Trạng thái phòng</th>
                                    <th style="width: 100px;" class="text-right">Xem</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="rm" items="${rooms}">
                                    <tr>
                                        <td class="font-weight-bold text-muted">#${rm.id}</td>
                                        <td class="text-center p-2">
                                            <c:choose>
                                                <c:when test="${not empty rm.imageUrl}">
                                                    <img src="${pageContext.request.contextPath}/${rm.imageUrl}" alt="${fn:escapeXml(rm.roomName)}" style="width: 76px; height: 52px; object-fit: cover; border-radius: 8px; border: 1px solid #e2e8f0;" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/img/hero-carousel/hero-carousel-1.jpg';">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="room-thumb-empty" style="width: 76px; height: 52px; background: #e9ecef; border-radius: 8px; display: inline-flex; align-items: center; justify-content: center; color: #6c757d;">
                                                        <i class="fa fa-bed"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="font-weight-bold text-dark" style="font-size: 0.98rem;">
                                                <c:out value="${rm.roomName}" />
                                            </div>
                                            <c:if test="${not empty rm.roomNumber}">
                                                <div class="small text-muted mt-1">
                                                    Mã hiệu: <span class="badge badge-light border text-dark font-weight-bold">${rm.roomNumber}</span>
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <div class="font-weight-bold text-dark">
                                                <i class="fa fa-building-o text-muted mr-1"></i><c:out value="${rm.propertyName}" />
                                            </div>
                                            <div class="small text-muted mt-1">
                                                <i class="fa fa-map-marker text-danger mr-1"></i><c:out value="${rm.address}" />
                                            </div>
                                        </td>
                                        <td>
                                            <div class="small font-weight-bold text-dark">
                                                <i class="fa fa-users text-primary mr-1"></i> ${rm.capacity} khách tối đa
                                            </div>
                                            <div class="small text-muted mt-1">
                                                <i class="fa fa-bed mr-1"></i> ${rm.bedCount > 0 ? rm.bedCount : 1} giường &bull; <i class="fa fa-bath mr-1"></i> ${rm.bathroomCount > 0 ? rm.bathroomCount : 1} WC
                                            </div>
                                        </td>
                                        <td>
                                            <div class="font-weight-bold text-danger" style="font-size: 1rem;">
                                                <fmt:formatNumber value="${rm.pricePerNight}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                            </div>
                                            <div class="small text-muted">/ đêm</div>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${rm.status == 'AVAILABLE' || rm.status == 'active'}">
                                                    <span class="badge badge-success px-2 py-1 font-weight-bold" style="font-size: 0.8rem; background-color: #10b981;">
                                                        <i class="fa fa-check-circle mr-1"></i> Còn trống
                                                    </span>
                                                </c:when>
                                                <c:when test="${rm.status == 'BOOKED'}">
                                                    <span class="badge badge-primary px-2 py-1 font-weight-bold" style="font-size: 0.8rem; background-color: #3b82f6;">
                                                        <i class="fa fa-calendar-check-o mr-1"></i> Đang có khách
                                                    </span>
                                                </c:when>
                                                <c:when test="${rm.status == 'MAINTENANCE'}">
                                                    <span class="badge badge-warning px-2 py-1 font-weight-bold" style="font-size: 0.8rem; background-color: #f59e0b; color: #fff;">
                                                        <i class="fa fa-wrench mr-1"></i> Bảo trì
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-secondary px-2 py-1 font-weight-bold" style="font-size: 0.8rem;">
                                                        <c:out value="${rm.status}" />
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-right">
                                            <a href="${pageContext.request.contextPath}/room-detail?id=${rm.id}" target="_blank" class="btn btn-sm btn-outline-secondary" style="border-radius: 6px;" title="Xem trang chi tiết phòng công khai">
                                                <i class="fa fa-external-link"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

    </div>
</section>

<jsp:include page="../common/footer.jsp" />

