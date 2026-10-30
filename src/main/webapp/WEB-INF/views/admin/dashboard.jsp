<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
                        <div class="kpi-label">Chỗ nghỉ / Homestay</div>
                        <div class="kpi-val">${totalProperties}</div>
                    </div>
                    <div class="kpi-icon-wrap kpi-icon-success">
                        <i class="fa fa-home"></i>
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
                        <i class="fa fa-building-o mr-1"></i> Quản lý Chỗ nghỉ (${totalProperties})
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

                <!-- TAB 2: QUẢN LÝ CHỖ NGHỈ -->
                <div class="tab-pane fade" id="tab-properties" role="tabpanel" aria-labelledby="properties-tab">
                    <div class="table-responsive">
                        <table class="table table-custom">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tên Homestay / Chỗ nghỉ</th>
                                    <th>Loại hình</th>
                                    <th>Địa chỉ & Thành phố</th>
                                    <th>Host ID</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="prop" items="${allProperties}">
                                    <tr>
                                        <td class="font-weight-bold">#${prop.id}</td>
                                        <td>
                                            <strong class="text-dark"><c:out value="${prop.name}" /></strong>
                                        </td>
                                        <td><c:out value="${prop.propertyType}" /></td>
                                        <td>
                                            <i class="fa fa-map-marker text-danger mr-1"></i>
                                            <c:out value="${prop.address}" />, <c:out value="${prop.city}" />
                                        </td>
                                        <td><span class="badge badge-light">Host #${prop.hostId}</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${prop.status == 'PUBLISHED'}">
                                                    <span class="status-badge status-published">Đang hiển thị</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-draft">${prop.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
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
                                    <th>Vai trò</th>
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
                                                <c:when test="${usr.role.roleName == 'ROLE_ADMIN' || usr.roleId == 1 || usr.roleId == 5}">
                                                    <span class="status-badge status-admin"><i class="fa fa-shield mr-1"></i> ADMIN</span>
                                                </c:when>
                                                <c:when test="${usr.role.roleName == 'ROLE_HOST' || usr.roleId == 3}">
                                                    <span class="status-badge status-host"><i class="fa fa-home mr-1"></i> HOST</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-customer"><i class="fa fa-user mr-1"></i> CUSTOMER</span>
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


<jsp:include page="../common/footer.jsp" />
