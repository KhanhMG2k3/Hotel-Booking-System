<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../common/header.jsp">
    <jsp:param name="pageTitle" value="Trang Quản Trị Hệ Thống - Sogo Homestay" />
</jsp:include>

<jsp:include page="../common/navbar.jsp" />

<style>
    /* Header ở Light Mode cho trang quản trị */
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
    html:not([data-theme="dark"]) .site-header .auth-link:not(.auth-link-primary) {
        color: #1a1a1a !important;
    }

    /* Header ở Dark Mode (Night Mode) cho Admin Dashboard */
    [data-theme="dark"] .site-header {
        background: #0f172a !important;
        border-bottom: 1px solid #334155 !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5) !important;
    }
    [data-theme="dark"] .site-header .site-logo a {
        color: #f8fafc !important;
    }
    [data-theme="dark"] .site-header .site-menu-toggle span {
        background: #f8fafc !important;
    }
    [data-theme="dark"] .site-header .user-name {
        color: #f8fafc !important;
    }
    [data-theme="dark"] .site-header .user-caret {
        color: #94a3b8 !important;
    }
    [data-theme="dark"] .site-header .auth-link:not(.auth-link-primary) {
        color: #cbd5e1 !important;
    }
    [data-theme="dark"] .site-header .user-menu-toggle {
        background: rgba(255, 255, 255, 0.08) !important;
        border: 1px solid rgba(255, 255, 255, 0.16) !important;
    }
    [data-theme="dark"] .site-header .user-menu-toggle:hover {
        background: rgba(255, 255, 255, 0.15) !important;
        border-color: #f59e0b !important;
    }

    .admin-dash {
        padding-top: 110px;
        padding-bottom: 80px;
        background: #f4f6fb;
        min-height: 85vh;
        font-family: 'Roboto Sans', sans-serif;
    }

    .admin-header {
        margin-bottom: 2rem;
    }
    .admin-title {
        font-family: "Playfair Display", serif;
        font-weight: 700;
        font-size: 2rem;
        color: #1a1a1a;
        margin-bottom: 0.25rem;
    }
    .admin-subtitle {
        color: #6c757d;
        font-size: 0.95rem;
    }
    .admin-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 14px;
        border-radius: 50px;
        font-size: 0.85rem;
        font-weight: 600;
        background: #ffe8d6;
        color: #b24700;
    }

    /* KPI Stat Cards */
    .kpi-card {
        background: #ffffff;
        border-radius: 14px;
        padding: 1.5rem;
        box-shadow: 0 4px 18px rgba(0, 0, 0, 0.04);
        border: 1px solid rgba(0, 0, 0, 0.04);
        transition: transform 0.2s ease, box-shadow 0.2s ease;
        display: flex;
        align-items: center;
        justify-content: space-between;
        height: 100%;
    }
    .kpi-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
    }
    .kpi-label {
        font-size: 0.82rem;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        color: #718096;
        margin-bottom: 0.35rem;
        font-weight: 600;
    }
    .kpi-val {
        font-family: "Playfair Display", serif;
        font-size: 2rem;
        font-weight: 700;
        color: #1a202c;
        line-height: 1.2;
    }
    .kpi-icon-wrap {
        width: 52px;
        height: 52px;
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.4rem;
    }
    .kpi-icon-warning {
        background: #fff8e6;
        color: #e69500;
    }
    .kpi-icon-primary {
        background: #ebf5ff;
        color: #2b6cb0;
    }
    .kpi-icon-success {
        background: #ebfaf0;
        color: #28a745;
    }
    .kpi-icon-info {
        background: #f0eaff;
        color: #6f42c1;
    }

    /* Tabs Card */
    .dashboard-panel {
        background: #ffffff;
        border-radius: 16px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
        border: 1px solid rgba(0, 0, 0, 0.04);
        padding: 1.75rem;
        margin-top: 2rem;
    }

    .nav-tabs-custom {
        border-bottom: 2px solid #e9ecef;
        margin-bottom: 1.5rem;
    }
    .nav-tabs-custom .nav-link {
        font-size: 0.95rem;
        font-weight: 600;
        color: #6c757d;
        border: none;
        border-bottom: 3px solid transparent;
        padding: 0.75rem 1.25rem;
        margin-bottom: -2px;
        transition: all 0.2s ease;
    }
    .nav-tabs-custom .nav-link:hover {
        color: #1a1a1a;
        border-color: #dee2e6;
    }
    .nav-tabs-custom .nav-link.active {
        color: #d97706;
        border-bottom-color: #d97706;
        background: transparent;
    }

    /* Custom Tables */
    .table-custom {
        width: 100%;
        margin-bottom: 0;
        font-size: 0.92rem;
    }
    .table-custom thead th {
        background: #f8fafc;
        color: #4a5568;
        font-weight: 700;
        text-transform: uppercase;
        font-size: 0.78rem;
        letter-spacing: 0.04em;
        border-top: none;
        border-bottom: 2px solid #e2e8f0;
        padding: 0.85rem 1rem;
        vertical-align: middle;
    }
    .table-custom tbody td {
        padding: 1rem;
        vertical-align: middle;
        border-bottom: 1px solid #edf2f7;
        color: #2d3748;
    }
    .table-custom tbody tr:hover {
        background: #fbfcfe;
    }

    /* Badges */
    .status-badge {
        display: inline-block;
        padding: 0.35em 0.8em;
        border-radius: 50px;
        font-size: 0.76rem;
        font-weight: 600;
    }
    .status-pending { background: #fff3cd; color: #856404; }
    .status-approved, .status-active { background: #d4edda; color: #155724; }
    .status-published { background: #d1ecf1; color: #0c5460; }
    .status-draft { background: #e2e3e5; color: #383d41; }
    .status-customer { background: #e8f4fd; color: #1976d2; }
    .status-host { background: #fef3e2; color: #b76e00; }
    .status-admin { background: #fde8e8; color: #c81e1e; }

    /* Action Buttons */
    .btn-approve {
        background: #28a745;
        color: #ffffff;
        font-weight: 600;
        font-size: 0.85rem;
        border: none;
        padding: 0.45rem 1rem;
        border-radius: 8px;
        transition: all 0.2s ease;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .btn-approve:hover {
        background: #218838;
        color: #ffffff;
        transform: translateY(-1px);
        box-shadow: 0 4px 10px rgba(40, 167, 69, 0.3);
    }

    /* Empty State */
    .empty-state-box {
        text-align: center;
        padding: 3.5rem 1.5rem;
    }
    .empty-icon-circle {
        width: 76px;
        height: 76px;
        border-radius: 50%;
        background: #ebfaf0;
        color: #28a745;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 2.2rem;
        margin-bottom: 1.25rem;
    }
    .empty-title {
        font-family: "Playfair Display", serif;
        font-weight: 700;
        font-size: 1.35rem;
        color: #1a202c;
        margin-bottom: 0.5rem;
    }
    .empty-desc {
        color: #718096;
        font-size: 0.95rem;
        max-width: 480px;
        margin: 0 auto;
    }

    .cursor-pointer {
        cursor: pointer;
    }
    .cursor-pointer:hover {
        color: #d97706 !important;
    }
    .avatar-circle-sm {
        width: 38px;
        height: 38px;
        border-radius: 50%;
        background: #e2e8f0;
        color: #4a5568;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-weight: 700;
        font-size: 1rem;
    }

    /* Role Select Control in Member Table */
    .role-select-box {
        height: 32px;
        font-size: 0.82rem;
        font-weight: 700;
        border-radius: 8px;
        padding: 2px 8px;
        cursor: pointer;
        transition: all 0.2s ease;
    }
    .role-select-host {
        border: 1px solid #f59e0b;
        color: #b45309;
        background-color: #fffbeb;
    }
    .role-select-host:hover {
        background-color: #fef3c7;
    }
    .role-select-admin {
        border: 1px solid #f87171;
        color: #b91c1c;
        background-color: #fef2f2;
    }
    .role-select-admin:hover {
        background-color: #fee2e2;
    }
    /* ==========================================================================
       ADMIN DASHBOARD DARK MODE RULES
       ========================================================================== */
    [data-theme="dark"] .admin-dash {
        background: var(--bg-body) !important;
    }
    [data-theme="dark"] .admin-title {
        color: var(--text-heading) !important;
    }
    [data-theme="dark"] .admin-subtitle {
        color: var(--text-muted) !important;
    }
    [data-theme="dark"] .admin-badge {
        background: rgba(245, 158, 11, 0.15) !important;
        color: #fbbf24 !important;
    }
    [data-theme="dark"] .kpi-card {
        background: var(--bg-card) !important;
        border-color: var(--border-color) !important;
        box-shadow: var(--shadow-card) !important;
    }
    [data-theme="dark"] .kpi-label {
        color: var(--text-muted) !important;
    }
    [data-theme="dark"] .kpi-val {
        color: #f8fafc !important;
    }
    [data-theme="dark"] .kpi-icon-warning {
        background: rgba(245, 158, 11, 0.15) !important;
        color: #fbbf24 !important;
    }
    [data-theme="dark"] .kpi-icon-primary {
        background: rgba(59, 130, 246, 0.15) !important;
        color: #93c5fd !important;
    }
    [data-theme="dark"] .kpi-icon-success {
        background: rgba(16, 185, 129, 0.15) !important;
        color: #6ee7b7 !important;
    }
    [data-theme="dark"] .kpi-icon-info {
        background: rgba(147, 51, 234, 0.15) !important;
        color: #c084fc !important;
    }
    [data-theme="dark"] .dashboard-panel {
        background: var(--bg-card) !important;
        border-color: var(--border-color) !important;
        box-shadow: var(--shadow-card) !important;
    }
    [data-theme="dark"] .nav-tabs-custom {
        border-bottom-color: var(--border-color) !important;
    }
    [data-theme="dark"] .nav-tabs-custom .nav-link {
        color: var(--text-muted) !important;
    }
    [data-theme="dark"] .nav-tabs-custom .nav-link:hover {
        color: var(--text-heading) !important;
        border-color: transparent !important;
    }
    [data-theme="dark"] .nav-tabs-custom .nav-link.active {
        color: var(--primary-accent) !important;
        border-bottom-color: var(--primary-accent) !important;
    }
    [data-theme="dark"] .table-custom thead th {
        background: var(--bg-surface) !important;
        color: var(--text-heading) !important;
        border-bottom-color: var(--border-color) !important;
    }
    [data-theme="dark"] .table-custom tbody td {
        color: var(--text-body) !important;
        border-bottom-color: var(--border-color) !important;
    }
    [data-theme="dark"] .table-custom tbody tr:hover {
        background: rgba(255, 255, 255, 0.04) !important;
    }
    [data-theme="dark"] .empty-title {
        color: var(--text-heading) !important;
    }
    [data-theme="dark"] .empty-desc {
        color: var(--text-muted) !important;
    }
    [data-theme="dark"] .empty-icon-circle {
        background: rgba(16, 185, 129, 0.15) !important;
        color: #6ee7b7 !important;
    }
    [data-theme="dark"] .avatar-circle-sm {
        background: rgba(255, 255, 255, 0.1) !important;
        color: #cbd5e1 !important;
    }
    [data-theme="dark"] .role-select-host {
        background-color: rgba(245, 158, 11, 0.18) !important;
        color: #fbbf24 !important;
        border-color: rgba(245, 158, 11, 0.4) !important;
    }
    [data-theme="dark"] .role-select-host:hover {
        background-color: rgba(245, 158, 11, 0.28) !important;
    }
    [data-theme="dark"] .role-select-admin {
        background-color: rgba(239, 68, 68, 0.18) !important;
        color: #f87171 !important;
        border-color: rgba(239, 68, 68, 0.4) !important;
    }
    [data-theme="dark"] .role-select-admin:hover {
        background-color: rgba(239, 68, 68, 0.28) !important;
    }
    [data-theme="dark"] .status-host {
        background: rgba(245, 158, 11, 0.15) !important;
        color: #fbbf24 !important;
        border: 1px solid rgba(245, 158, 11, 0.3) !important;
    }
    [data-theme="dark"] .status-customer {
        background: rgba(59, 130, 246, 0.15) !important;
        color: #93c5fd !important;
        border: 1px solid rgba(59, 130, 246, 0.3) !important;
    }
    [data-theme="dark"] .status-admin {
        background: rgba(239, 68, 68, 0.15) !important;
        color: #f87171 !important;
        border: 1px solid rgba(239, 68, 68, 0.3) !important;
    }
    [data-theme="dark"] .status-active, [data-theme="dark"] .status-approved {
        background: rgba(16, 185, 129, 0.15) !important;
        color: #6ee7b7 !important;
        border: 1px solid rgba(16, 185, 129, 0.3) !important;
    }
    [data-theme="dark"] .status-pending {
        background: rgba(245, 158, 11, 0.15) !important;
        color: #fbbf24 !important;
        border: 1px solid rgba(245, 158, 11, 0.3) !important;
    }
    [data-theme="dark"] .btn-outline-danger {
        border-color: rgba(239, 68, 68, 0.5) !important;
        color: #f87171 !important;
        background: rgba(239, 68, 68, 0.08) !important;
    }
    [data-theme="dark"] .btn-outline-danger:hover {
        background: #dc3545 !important;
        color: #ffffff !important;
        border-color: #dc3545 !important;
    }
    [data-theme="dark"] a.text-dark,
    [data-theme="dark"] strong.text-dark,
    [data-theme="dark"] .text-dark {
        color: var(--text-heading) !important;
    }
</style>

<section class="admin-dash">
    <div class="container">

        <!-- Top Welcome & Actions -->
        <div class="d-flex flex-wrap justify-content-between align-items-center admin-header">
            <div>
                <div class="d-flex align-items-center gap-2 mb-2">
                    <span class="admin-badge">
                        <i class="fa fa-shield"></i> Trang Quản Trị Hệ Thống
                    </span>
                </div>
                <h1 class="admin-title">Bảng Điều Khiển Quản Trị</h1>
                <p class="admin-subtitle mb-0">
                    Chào mừng <strong><c:out value="${sessionScope.userName}" /></strong> (<c:out value="${sessionScope.userEmail}" />) &mdash; Quản lý toàn diện tài khoản, đối tác Host và chỗ nghỉ trên Sogo Homestay
                </p>
            </div>
            <div class="mt-3 mt-md-0 d-flex gap-2">
                <a href="${pageContext.request.contextPath}/admin/support" class="btn btn-outline-danger font-weight-bold" style="border-radius: 8px;">
                    <i class="fa fa-life-ring mr-1"></i> Quản Lý Hỗ Trợ
                </a>
                <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-secondary font-weight-bold" style="border-radius: 8px;">
                    <i class="fa fa-home mr-1"></i> Xem Trang Chủ
                </a>
                <a href="${pageContext.request.contextPath}/rooms" class="btn btn-warning text-white font-weight-bold" style="background:#ffba5a; border-color:#ffba5a; border-radius: 8px;">
                    <i class="fa fa-bed mr-1"></i> Xem Danh Sách Phòng
                </a>
            </div>
        </div>

        <!-- Flash Alert Messages -->
        <c:if test="${not empty messageSuccess}">
            <div class="alert alert-success alert-dismissible fade show mb-4" role="alert">
                <i class="fa fa-check-circle mr-2"></i> <strong>Thành công!</strong> <c:out value="${messageSuccess}" />
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </c:if>
        <c:if test="${not empty messageError}">
            <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                <i class="fa fa-exclamation-triangle mr-2"></i> <strong>Lỗi:</strong> <c:out value="${messageError}" />
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </c:if>

        <!-- 4 KPI Stat Cards -->
        <div class="row">
            <div class="col-12 col-sm-6 col-lg-3 mb-3">
                <div class="kpi-card">
                    <div>
                        <div class="kpi-label">Hồ sơ chờ duyệt</div>
                        <div class="kpi-val text-warning">${totalPendingHosts}</div>
                    </div>
                    <div class="kpi-icon-wrap kpi-icon-warning">
                        <i class="fa fa-user-plus"></i>
                    </div>
                </div>
            </div>

            <div class="col-12 col-sm-6 col-lg-3 mb-3">
                <div class="kpi-card">
                    <div>
                        <div class="kpi-label">Tổng thành viên</div>
                        <div class="kpi-val">${totalUsers}</div>
                    </div>
                    <div class="kpi-icon-wrap kpi-icon-primary">
                        <i class="fa fa-users"></i>
                    </div>
                </div>
            </div>

            <div class="col-12 col-sm-6 col-lg-3 mb-3">
                <div class="kpi-card">
                    <div>
                        <div class="kpi-label">Tài khoản Host</div>
                        <div class="kpi-val text-success">${totalHosts}</div>
                    </div>
                    <div class="kpi-icon-wrap kpi-icon-success">
                        <i class="fa fa-user-circle"></i>
                    </div>
                </div>
            </div>

            <div class="col-12 col-sm-6 col-lg-3 mb-3">
                <div class="kpi-card">
                    <div>
                        <div class="kpi-label">Đơn đặt phòng</div>
                        <div class="kpi-val">${totalBookings}</div>
                    </div>
                    <div class="kpi-icon-wrap kpi-icon-info">
                        <i class="fa fa-calendar-check-o"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Main Panel Tabs -->
        <div class="dashboard-panel">
            <ul class="nav nav-tabs nav-tabs-custom" id="adminTabs" role="tablist">
                <li class="nav-item">
                    <a class="nav-link active" id="hosts-tab" data-toggle="tab" href="#tab-hosts" role="tab" aria-controls="tab-hosts" aria-selected="true">
                        <i class="fa fa-id-card-o mr-1"></i> Hồ sơ Host chờ duyệt 
                        <c:if test="${totalPendingHosts > 0}">
                            <span class="badge badge-warning ml-1">${totalPendingHosts}</span>
                        </c:if>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" id="properties-tab" data-toggle="tab" href="#tab-properties" role="tab" aria-controls="tab-properties" aria-selected="false">
                        <i class="fa fa-users mr-1"></i> Quản lý tài khoản Host (${totalHosts})
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" id="users-tab" data-toggle="tab" href="#tab-users" role="tab" aria-controls="tab-users" aria-selected="false">
                        <i class="fa fa-user-circle-o mr-1"></i> Danh sách Thành viên (${totalUsers})
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" id="bookings-tab" data-toggle="tab" href="#tab-bookings" role="tab" aria-controls="tab-bookings" aria-selected="false">
                        <i class="fa fa-bookmark-o mr-1"></i> Đơn đặt gần đây (${totalBookings})
                    </a>
                </li>
            </ul>

            <div class="tab-content" id="adminTabsContent">
                
                <!-- TAB 1: HỒ SƠ HOST CHỜ DUYỆT -->
                <div class="tab-pane fade show active" id="tab-hosts" role="tabpanel" aria-labelledby="hosts-tab">
                    <c:choose>
                        <c:when test="${empty pendingHostApplications && empty pendingHostProfiles}">
                            <div class="empty-state-box">
                                <div class="empty-icon-circle">
                                    <i class="fa fa-check"></i>
                                </div>
                                <h3 class="empty-title">Không có hồ sơ nào chờ duyệt</h3>
                                <p class="empty-desc">
                                    Tất cả hồ sơ đăng ký trở thành Host của đối tác đã được xem xét và xử lý hoàn tất. Khi có khách hàng gửi yêu cầu trở thành Host, danh sách sẽ xuất hiện tại đây.
                                </p>
                            </div>
                        </c:when>

                        <c:otherwise>
                            <div class="table-responsive">
                                <table class="table table-custom">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>User ID</th>
                                            <th>Người nộp / Tên Chỗ nghỉ</th>
                                            <th>Loại hình & Quy mô</th>
                                            <th>Số điện thoại / CCCD</th>
                                            <th>Thời gian gửi</th>
                                            <th>Trạng thái</th>
                                            <th class="text-right">Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%-- Danh sách hồ sơ đăng ký mới (HostApplication) --%>
                                        <c:forEach var="app" items="${pendingHostApplications}">
                                            <tr>
                                                <td class="font-weight-bold">#${app.id}</td>
                                                <td><span class="badge badge-light">User #${app.userId}</span></td>
                                                <td>
                                                    <strong class="text-dark"><c:out value="${app.propertyName}" /></strong>
                                                    <div class="small text-muted">
                                                        <i class="fa fa-user-circle-o mr-1"></i><c:out value="${app.applicantName}" />
                                                        <c:if test="${not empty app.applicantEmail}"> &bull; <c:out value="${app.applicantEmail}" /></c:if>
                                                    </div>
                                                </td>
                                                <td>
                                                    <span class="badge badge-info"><c:out value="${app.propertyType}" /></span>
                                                    <div class="small text-muted mt-1">
                                                        <c:out value="${app.roomCount != null ? app.roomCount : 1}" /> phòng &bull; <c:out value="${app.maxGuests != null ? app.maxGuests : 2}" /> khách
                                                    </div>
                                                </td>
                                                <td>
                                                    <div><i class="fa fa-phone text-muted mr-1"></i><c:out value="${app.applicantPhone}" /></div>
                                                    <c:if test="${not empty app.identificationNumber}">
                                                        <div class="small text-muted"><i class="fa fa-id-card-o mr-1"></i>CCCD: <strong><c:out value="${app.identificationNumber}" /></strong></div>
                                                    </c:if>
                                                </td>
                                                <td>
                                                    <div class="small font-weight-bold text-dark">
                                                        <fmt:formatDate value="${app.submittedAt}" pattern="dd/MM/yyyy HH:mm" />
                                                    </div>
                                                </td>
                                                <td>
                                                    <span class="status-badge status-pending">
                                                        <i class="fa fa-clock-o mr-1"></i> Chờ duyệt
                                                    </span>
                                                </td>
                                                <td class="text-right" style="white-space: nowrap;">
                                                    <a href="${pageContext.request.contextPath}/admin/host-applications?id=${app.id}"
                                                        class="btn btn-sm btn-info font-weight-bold mr-1"
                                                        style="border-radius: 8px; padding: 0.45rem 0.85rem; display: inline-flex; align-items: center; gap: 5px; color: #fff; background-color: #0ea5e9; border-color: #0ea5e9; box-shadow: 0 2px 5px rgba(14,165,233,0.25);"
                                                        title="Chuyển sang trang kiểm tra chi tiết hồ sơ, ảnh và tài liệu">
                                                         <i class="fa fa-folder-open-o"></i> Kiểm tra hồ sơ
                                                     </a>
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/host/approve" style="display:inline-block;" onsubmit="return confirm('Bạn có chắc chắn muốn phê duyệt hồ sơ này và cấp quyền HOST? Chỗ nghỉ sẽ được tạo tự động.');">
                                                        <input type="hidden" name="applicationId" value="${app.id}">
                                                        <button type="submit" class="btn-approve">
                                                            <i class="fa fa-check"></i> Duyệt Host
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/host/reject" style="display:inline-block; margin-left: 4px;" onsubmit="var r = prompt('Nhập lý do từ chối (tối thiểu 10 ký tự):', 'Hồ sơ chưa đạt tiêu chuẩn xác thực thông tin đối tác của Sogo Homestay.'); if(!r || r.trim().length < 10) return false; this.rejectionReason.value = r.trim(); return true;">
                                                        <input type="hidden" name="applicationId" value="${app.id}">
                                                        <input type="hidden" name="rejectionReason" value="">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger font-weight-bold" style="border-radius: 8px; padding: 0.45rem 0.75rem;">
                                                            <i class="fa fa-times"></i> Từ chối
                                                        </button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>

                                        <%-- Hồ sơ HostProfile phụ (nếu có) --%>
                                        <c:forEach var="profile" items="${pendingHostProfiles}">
                                            <tr>
                                                <td class="font-weight-bold">#${profile.id}</td>
                                                <td><span class="badge badge-light">User #${profile.userId}</span></td>
                                                <td>
                                                    <strong class="text-dark"><c:out value="${profile.businessName}" /></strong>
                                                </td>
                                                <td><c:out value="${profile.businessType}" /></td>
                                                <td><i class="fa fa-phone text-muted mr-1"></i><c:out value="${profile.phone}" /></td>
                                                <td>-</td>
                                                <td>
                                                    <span class="status-badge status-pending">
                                                        <i class="fa fa-clock-o mr-1"></i> ${profile.verificationStatus}
                                                    </span>
                                                </td>
                                                <td class="text-right">
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/host/approve" style="display:inline-block;" onsubmit="return confirm('Bạn có chắc chắn muốn phê duyệt hồ sơ này và cấp quyền HOST?');">
                                                        <input type="hidden" name="profileId" value="${profile.id}">
                                                        <button type="submit" class="btn-approve">
                                                            <i class="fa fa-check"></i> Duyệt Host
                                                        </button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- TAB 2: QUẢN LÝ TÀI KHOẢN HOST -->
                <div class="tab-pane fade" id="tab-properties" role="tabpanel" aria-labelledby="properties-tab">
                    <c:choose>
                        <c:when test="${empty allHostAccounts}">
                            <div class="empty-state-box">
                                <div class="empty-icon-circle">
                                    <i class="fa fa-users"></i>
                                </div>
                                <h3 class="empty-title">Chưa có tài khoản Host nào</h3>
                                <p class="empty-desc">
                                    Hệ thống hiện tại chưa ghi nhận đối tác Host nào. Khi các đơn đăng ký trở thành Host được phê duyệt, danh sách tài khoản Host sẽ hiển thị ở đây.
                                </p>
                            </div>
                        </c:when>

                        <c:otherwise>
                            <div class="table-responsive">
                                <table class="table table-custom">
                                    <thead>
                                        <tr>
                                            <th style="width: 80px;">MÃ HOST</th>
                                            <th>HỌ TÊN & LIÊN HỆ</th>
                                            <th>QUY MÔ KINH DOANH</th>
                                            <th class="text-center" style="width: 170px;">TRẠNG THÁI</th>
                                            <th class="text-center" style="width: 230px;">DANH SÁCH PHÒNG</th>
                                            <th class="text-right" style="width: 190px;">HÀNH ĐỘNG</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="host" items="${allHostAccounts}">
                                            <tr>
                                                <td class="font-weight-bold text-muted">
                                                    #${host.userId}
                                                </td>
                                                <td>
                                                    <div class="d-flex align-items-center">
                                                        <a href="${pageContext.request.contextPath}/admin/host-detail?id=${host.userId}" title="Nhấp để xem màn hình chi tiết Host">
                                                            <c:choose>
                                                                <c:when test="${not empty host.avatarUrl}">
                                                                    <img src="${host.avatarUrl}" alt="${fn:escapeXml(host.fullName)}" class="rounded-circle mr-3" style="width: 44px; height: 44px; object-fit: cover; border: 2px solid #e2e8f0;">
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <div class="avatar-circle-sm mr-3">
                                                                        <i class="fa fa-user"></i>
                                                                    </div>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </a>
                                                        <div>
                                                            <div>
                                                                <a href="${pageContext.request.contextPath}/admin/host-detail?id=${host.userId}" 
                                                                   class="text-dark font-weight-bold cursor-pointer" 
                                                                   title="Mở màn hình riêng xem thông tin cá nhân và các phòng của Host"
                                                                   style="font-size: 1rem; text-decoration: none;">
                                                                    <c:out value="${host.fullName}" />
                                                                </a>
                                                                <span class="badge badge-light ml-1 text-muted" style="font-size: 0.75rem;">@<c:out value="${host.username}" /></span>
                                                            </div>
                                                            <div class="small text-muted mt-1">
                                                                <i class="fa fa-envelope-o mr-1"></i><c:out value="${host.email}" />
                                                                <c:if test="${not empty host.phone}">
                                                                    &bull; <i class="fa fa-phone mr-1"></i><c:out value="${host.phone}" />
                                                                </c:if>
                                                            </div>
                                                            <c:if test="${not empty host.createdAt}">
                                                                <div class="small text-muted" style="font-size: 0.75rem;">
                                                                    <i class="fa fa-calendar mr-1"></i>Tham gia: <fmt:formatDate value="${host.createdAt}" pattern="dd/MM/yyyy" />
                                                                </div>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="d-flex flex-column gap-1">
                                                        <div>
                                                            <span class="badge badge-warning text-dark font-weight-bold" style="padding: 5px 9px; font-size: 0.8rem; background-color: #fef3c7;">
                                                                <i class="fa fa-building-o mr-1 text-warning"></i> ${host.propertyCount} Chỗ nghỉ
                                                            </span>
                                                        </div>
                                                        <div class="mt-1">
                                                            <span class="badge badge-info font-weight-bold" style="padding: 5px 9px; font-size: 0.8rem; background-color: #e0f2fe; color: #0369a1;">
                                                                <i class="fa fa-bed mr-1"></i> ${host.roomCount} Phòng ngủ
                                                            </span>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${host.status == 'BANNED'}">
                                                            <span class="status-badge" style="background: #fee2e2; color: #991b1b; font-weight: 700; border: 1px solid #f87171;">
                                                                <i class="fa fa-ban mr-1"></i> ĐÃ BỊ KHÓA
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${host.status == 'ACTIVE'}">
                                                            <span class="status-badge status-active" style="font-weight: 700; border: 1px solid #86efac;">
                                                                <i class="fa fa-check-circle mr-1"></i> HOẠT ĐỘNG
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-badge status-draft font-weight-bold">
                                                                <c:out value="${host.status}" />
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/admin/host-detail?id=${host.userId}" 
                                                       class="btn btn-sm btn-info text-white font-weight-bold" 
                                                       style="border-radius: 8px; padding: 0.45rem 0.95rem; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 2px 6px rgba(14,165,233,0.3); background-color: #0284c7; border-color: #0284c7;"
                                                       title="Mở màn hình riêng hiển thị thông tin cá nhân và tất cả phòng của Host">
                                                        <i class="fa fa-bed"></i> Xem chi tiết & phòng (${host.roomCount})
                                                    </a>
                                                </td>
                                                <td class="text-right" style="white-space: nowrap;">
                                                    <c:choose>
                                                        <c:when test="${host.status == 'BANNED'}">
                                                            <form method="post" action="${pageContext.request.contextPath}/admin/dashboard" style="display:inline-block;" onsubmit="return confirm('Bạn có chắc chắn muốn MỞ KHÓA tài khoản cho Host #${host.userId} (${fn:escapeXml(host.fullName)})? Sau khi mở khóa, tài khoản Host có thể đăng nhập và hoạt động bình thường.');">
                                                                <input type="hidden" name="action" value="unbanHost">
                                                                <input type="hidden" name="hostId" value="${host.userId}">
                                                                <button type="submit" class="btn btn-sm btn-success font-weight-bold" style="border-radius: 8px; padding: 0.45rem 0.85rem; display: inline-flex; align-items: center; gap: 5px;">
                                                                    <i class="fa fa-unlock"></i> Mở khóa
                                                                </button>
                                                            </form>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <form method="post" action="${pageContext.request.contextPath}/admin/dashboard" style="display:inline-block;" onsubmit="return confirm('CẢNH BÁO QUAN TRỌNG:\nBạn có chắc chắn muốn KHÓA (BAN) tài khoản Host #${host.userId} (${fn:escapeXml(host.fullName)})?\n\nHost sẽ bị khóa tài khoản và không thể đăng nhập vào hệ thống Sogo Homestay.');">
                                                                <input type="hidden" name="action" value="banHost">
                                                                <input type="hidden" name="hostId" value="${host.userId}">
                                                                <button type="submit" class="btn btn-sm btn-outline-danger font-weight-bold" style="border-radius: 8px; padding: 0.45rem 0.85rem; display: inline-flex; align-items: center; gap: 5px;">
                                                                    <i class="fa fa-ban"></i> Khóa tài khoản
                                                                </button>
                                                            </form>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- TAB 3: DANH SÁCH THÀNH VIÊN -->
                <div class="tab-pane fade" id="tab-users" role="tabpanel" aria-labelledby="users-tab">
                    <div class="table-responsive">
                        <table class="table table-custom">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Họ và Tên</th>
                                    <th>Email</th>
                                    <th>Số điện thoại</th>
                                    <th style="min-width: 170px;">Vai trò</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="usr" items="${allUsers}">
                                    <tr>
                                        <td class="font-weight-bold">#${usr.id}</td>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <i class="fa fa-user-circle text-secondary mr-2" style="font-size: 1.25rem;"></i>
                                                <strong class="text-dark"><c:out value="${usr.fullName}" /></strong>
                                            </div>
                                        </td>
                                        <td><c:out value="${usr.email}" /></td>
                                        <td><c:out value="${not empty usr.phone ? usr.phone : '---'}" /></td>
                                        <td>
                                            <c:choose>
                                                <%-- Trường hợp 1: Tài khoản Admin đang đăng nhập --%>
                                                <c:when test="${usr.id == sessionScope.userId}">
                                                    <span class="status-badge status-admin" title="Tài khoản Quản trị viên hiện tại của bạn">
                                                        <i class="fa fa-shield mr-1"></i> ADMIN (Bạn)
                                                    </span>
                                                </c:when>

                                                <%-- Trường hợp 2: Tài khoản ADMIN khác -> Có thể chuyển lại thành HOST --%>
                                                <c:when test="${usr.role.roleName == 'ROLE_ADMIN' || usr.roleId == 1 || usr.roleId == 5}">
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/dashboard" class="d-inline-flex align-items-center m-0">
                                                        <input type="hidden" name="action" value="updateRole">
                                                        <input type="hidden" name="userId" value="${usr.id}">
                                                        <select name="newRoleId" class="custom-select custom-select-sm role-select-box role-select-admin" 
                                                                title="Thay đổi vai trò cho tài khoản này"
                                                                onchange="if(this.value == '3'){ if(confirm('Bạn có chắc chắn muốn chuyển tài khoản [' + '${fn:escapeXml(usr.fullName)}' + '] từ ADMIN về lại HOST?')) { this.form.submit(); } else { this.value='1'; } }">
                                                            <option value="1" selected>🛡️ ADMIN</option>
                                                            <option value="3">🏠 Hạ xuống HOST</option>
                                                        </select>
                                                    </form>
                                                </c:when>

                                                <%-- Trường hợp 3: Tài khoản HOST -> Có thể nâng hạng lên ADMIN --%>
                                                <c:when test="${usr.role.roleName == 'ROLE_HOST' || usr.roleId == 3}">
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/dashboard" class="d-inline-flex align-items-center m-0">
                                                        <input type="hidden" name="action" value="updateRole">
                                                        <input type="hidden" name="userId" value="${usr.id}">
                                                        <select name="newRoleId" class="custom-select custom-select-sm role-select-box role-select-host" 
                                                                title="Nâng hạng quyền hạn tài khoản Host này lên Admin"
                                                                onchange="if(this.value == '1'){ if(confirm('XÁC NHẬN NÂNG HẠNG:\nBạn có chắc chắn muốn nâng hạng Host [' + '${fn:escapeXml(usr.fullName)}' + '] lên thành ADMIN (Quản trị viên) không?')) { this.form.submit(); } else { this.value='3'; } }">
                                                            <option value="3" selected>🏠 HOST</option>
                                                            <option value="1">⭐ Nâng lên ADMIN</option>
                                                        </select>
                                                    </form>
                                                </c:when>

                                                <%-- Trường hợp 4: Khách hàng CUSTOMER -> Chỉ hiển thị badge, muốn thành Host phải qua luồng xét duyệt hồ sơ --%>
                                                <c:otherwise>
                                                    <span class="status-badge status-customer" title="Khách hàng muốn trở thành Host phải nộp hồ sơ theo quy trình kiểm duyệt">
                                                        <i class="fa fa-user mr-1"></i> CUSTOMER
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="status-badge status-active">${usr.status}</span>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- TAB 4: ĐƠN ĐẶT PHÒNG -->
                <div class="tab-pane fade" id="tab-bookings" role="tabpanel" aria-labelledby="bookings-tab">
                    <div class="table-responsive">
                        <table class="table table-custom">
                            <thead>
                                <tr>
                                    <th>Mã Đơn</th>
                                    <th>Khách hàng</th>
                                    <th>Ngày Check-in</th>
                                    <th>Ngày Check-out</th>
                                    <th>Tổng tiền</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="bk" items="${allBookings}">
                                    <tr>
                                        <td class="font-weight-bold">#${bk.id}</td>
                                        <td>User #${bk.userId}</td>
                                        <td><i class="fa fa-sign-in text-success mr-1"></i>${bk.checkInDate}</td>
                                        <td><i class="fa fa-sign-out text-danger mr-1"></i>${bk.checkOutDate}</td>
                                        <td class="font-weight-bold text-dark">
                                            <fmt:formatNumber value="${bk.totalPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                        </td>
                                        <td>
                                            <span class="status-badge status-approved">${bk.status}</span>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>

    </div>
</section>

<script>
document.addEventListener("DOMContentLoaded", function() {
    // Tự động chuyển tab theo query param ?tab=tab-properties hoặc hash
    var urlParams = new URLSearchParams(window.location.search);
    var tabParam = urlParams.get('tab');
    var hashParam = window.location.hash;
    
    if (tabParam === 'tab-properties' || tabParam === 'tab-hosts-manage' || hashParam === '#tab-properties') {
        if (typeof $ !== 'undefined' && $('#properties-tab').length) {
            $('#properties-tab').tab('show');
        }
    } else if (tabParam === 'tab-users' || hashParam === '#tab-users') {
        if (typeof $ !== 'undefined' && $('#users-tab').length) {
            $('#users-tab').tab('show');
        }
    } else if (tabParam === 'tab-bookings' || hashParam === '#tab-bookings') {
        if (typeof $ !== 'undefined' && $('#bookings-tab').length) {
            $('#bookings-tab').tab('show');
        }
    }
});
</script>

<jsp:include page="../common/footer.jsp" />
