<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="common/header.jsp">
    <jsp:param name="pageTitle" value="Thông tin tài khoản - Sogo Homestay" />
</jsp:include>

<c:set var="u" value="${profileUser}" />

<!-- Xác định đường dẫn Avatar chuẩn: URL ngoại dùng trực tiếp, file upload cục bộ dùng contextPath -->
<c:choose>
    <c:when test="${not empty u.avatarUrl and (fn:startsWith(u.avatarUrl, 'http://') or fn:startsWith(u.avatarUrl, 'https://'))}">
        <c:set var="userAvatarSrc" value="${u.avatarUrl}" />
    </c:when>
    <c:when test="${not empty u.avatarUrl}">
        <c:set var="userAvatarSrc" value="${pageContext.request.contextPath}/assets/${u.avatarUrl}" />
    </c:when>
    <c:otherwise>
        <c:set var="userAvatarSrc" value="" />
    </c:otherwise>
</c:choose>

<style>
    /* Scoped CSS thiết kế chuẩn xác 100% theo mẫu FITFLOW của người dùng */
    /* Ẩn triệt để thanh Header & Hero banner trên trang Profile */
    .site-header,
    .js-site-header,
    .site-hero {
        display: none !important;
    }

    .fitflow-wrapper {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif !important;
        background: linear-gradient(rgba(0, 0, 0, 0.45), rgba(0, 0, 0, 0.55)), url('${pageContext.request.contextPath}/assets/images/hero_4.jpg') no-repeat center center fixed !important;
        background-size: cover !important;
        min-height: 100vh !important;
        padding: 55px 0 85px !important;
    }

    /* Thiết lập font-family chuẩn sans-serif cho các phần tử chữ nhưng tuyệt đối không ghi đè FontAwesome */
    .fitflow-wrapper *:not(.fa):not(i):not([class*="fa-"]):not([class*="fa-"]::before) {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    }

    .fitflow-wrapper *,
    .fitflow-wrapper *::before,
    .fitflow-wrapper *::after {
        box-sizing: border-box !important;
    }

    /* Bảo đảm toàn bộ icon FontAwesome trong trang hiển thị sắc nét, không bị lỗi ô vuông */
    .fa,
    i.fa,
    .fitflow-wrapper .fa,
    .fitflow-wrapper i,
    .fitflow-wrapper [class*="fa-"],
    .fitflow-wrapper .fa::before,
    .fitflow-wrapper [class*="fa-"]::before,
    .fitflow-back-btn .fa,
    .fitflow-back-btn i {
        font-family: 'FontAwesome' !important;
        font-style: normal !important;
        font-weight: normal !important;
        font-variant: normal !important;
        text-transform: none !important;
        line-height: 1 !important;
        speak: none;
        -webkit-font-smoothing: antialiased !important;
        -moz-osx-font-smoothing: grayscale !important;
    }

    /* Nút mũi tên nhỏ quay lại trang chủ ở góc trái màn hình */
    .fitflow-back-btn {
        position: fixed !important;
        top: 24px !important;
        left: 24px !important;
        width: 44px !important;
        height: 44px !important;
        border-radius: 50% !important;
        background: rgba(255, 255, 255, 0.9) !important;
        backdrop-filter: blur(10px) !important;
        border: 1px solid rgba(255, 255, 255, 0.6) !important;
        box-shadow: 0 4px 18px rgba(0, 0, 0, 0.22) !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        color: #1F2937 !important;
        font-size: 16px !important;
        text-decoration: none !important;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1) !important;
        z-index: 9999 !important;
        cursor: pointer !important;
    }

    .fitflow-back-btn:hover {
        background: #ffffff !important;
        color: #EAA32B !important;
        transform: scale(1.08) translateX(-3px) !important;
        box-shadow: 0 6px 24px rgba(0, 0, 0, 0.3) !important;
    }

    .fitflow-back-btn:active {
        transform: scale(0.96) !important;
    }

    @media (max-width: 768px) {
        .fitflow-back-btn {
            top: 16px !important;
            left: 16px !important;
            width: 40px !important;
            height: 40px !important;
            font-size: 15px !important;
        }
    }

    .fitflow-card {
        background: #ffffff !important;
        border-radius: 22px !important;
        border: 1px solid rgba(255, 255, 255, 0.3) !important;
        box-shadow: 0 16px 40px rgba(0, 0, 0, 0.22) !important;
        padding: 34px 28px !important;
    }

    /* Khung Avatar tròn cố định 104px có lớp phủ Camera khi di chuột */
    .fitflow-avatar-box {
        position: relative !important;
        width: 104px !important;
        height: 104px !important;
        min-width: 104px !important;
        min-height: 104px !important;
        max-width: 104px !important;
        max-height: 104px !important;
        margin: 0 auto 16px !important;
        border-radius: 50% !important;
        overflow: hidden !important;
        cursor: pointer !important;
        border: 3px solid #ffba5a !important;
        background: #ffffff !important;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08) !important;
    }

    .fitflow-avatar-box img {
        width: 100% !important;
        height: 100% !important;
        max-width: 100% !important;
        max-height: 100% !important;
        object-fit: cover !important;
        object-position: center !important;
        border-radius: 50% !important;
        display: block !important;
        margin: 0 !important;
    }

    .fitflow-avatar-fallback {
        width: 100% !important;
        height: 100% !important;
        border-radius: 50% !important;
        background: linear-gradient(135deg, #ffba5a 0%, #e67e22 100%) !important;
        color: #ffffff !important;
        font-size: 2.5rem !important;
        font-weight: 700 !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        line-height: 1 !important;
    }

    .fitflow-avatar-overlay {
        position: absolute !important;
        top: 0 !important;
        left: 0 !important;
        width: 100% !important;
        height: 100% !important;
        border-radius: 50% !important;
        background: rgba(0, 0, 0, 0.52) !important;
        display: flex !important;
        flex-direction: column !important;
        align-items: center !important;
        justify-content: center !important;
        color: #ffffff !important;
        opacity: 0 !important;
        transition: opacity 0.25s ease-in-out !important;
    }

    .fitflow-avatar-box:hover .fitflow-avatar-overlay {
        opacity: 1 !important;
    }

    .fitflow-avatar-overlay i {
        font-size: 24px !important;
        color: #ffffff !important;
        margin-bottom: 2px !important;
    }

    .fitflow-avatar-overlay span {
        font-size: 11px !important;
        font-weight: 600 !important;
        text-transform: uppercase !important;
        letter-spacing: 0.5px !important;
        color: #ffffff !important;
    }

    /* Tên người dùng và vai trò */
    .fitflow-user-name {
        font-size: 1.25rem !important;
        font-weight: 700 !important;
        color: #1F2937 !important;
        margin-bottom: 4px !important;
    }

    .fitflow-role-badge {
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        padding: 5px 14px !important;
        border-radius: 20px !important;
        font-size: 13px !important;
        font-weight: 600 !important;
        margin-bottom: 18px !important;
        letter-spacing: 0.2px !important;
    }

    .fitflow-role-badge i {
        font-size: 12px !important;
        margin-right: 6px !important;
    }

    /* Khách hàng - Màu cam nhạt chuẩn ảnh mẫu */
    .fitflow-role-customer {
        background: #FFF7ED !important;
        border: 1px solid #FED7AA !important;
        color: #B45309 !important;
    }

    /* Quản trị viên - Màu đỏ nhạt */
    .fitflow-role-admin {
        background: #FEF2F2 !important;
        border: 1px solid #FECACA !important;
        color: #DC2626 !important;
    }

    /* Host / Chủ Homestay - Màu xanh dương nhạt */
    .fitflow-role-host {
        background: #EFF6FF !important;
        border: 1px solid #BFDBFE !important;
        color: #2563EB !important;
    }

    /* Các nút điều hướng Sidebar */
    .fitflow-nav-btn {
        display: block !important;
        width: 100% !important;
        text-align: center !important;
        padding: 12px 16px !important;
        border-radius: 12px !important;
        font-size: 14px !important;
        font-weight: 600 !important;
        margin-bottom: 10px !important;
        text-decoration: none !important;
        transition: all 0.2s ease !important;
        border: 1px solid #E5E7EB !important;
        background: #ffffff !important;
        color: #374151 !important;
        cursor: pointer !important;
    }

    .fitflow-nav-btn:hover {
        background: #F9FAFB !important;
        color: #111827 !important;
        border-color: #D1D5DB !important;
    }

    .fitflow-nav-btn.active {
        background: #FFF9E6 !important;
        border-color: #FBD38D !important;
        color: #B45309 !important;
        box-shadow: 0 2px 6px rgba(255, 186, 90, 0.15) !important;
    }

    .fitflow-nav-btn.btn-home {
        background: #EEF2FF !important;
        border-color: #E0E7FF !important;
        color: #4F46E5 !important;
    }

    .fitflow-nav-btn.btn-home:hover {
        background: #E0E7FF !important;
        color: #4338CA !important;
    }

    .fitflow-nav-btn.btn-danger-logout {
        background: #DC2626 !important;
        border-color: #DC2626 !important;
        color: #ffffff !important;
    }

    .fitflow-nav-btn.btn-danger-logout:hover {
        background: #B91C1C !important;
        color: #ffffff !important;
    }

    /* Tiêu đề & Mô tả Form Cột phải */
    .fitflow-title {
        font-size: 1.55rem !important;
        font-weight: 700 !important;
        color: #111827 !important;
        margin-bottom: 4px !important;
    }

    .fitflow-subtitle {
        font-size: 13.5px !important;
        color: #6B7280 !important;
        margin-bottom: 24px !important;
    }

    /* Nhãn & Ô input theo mẫu */
    .fitflow-label {
        font-size: 13px !important;
        font-weight: 600 !important;
        color: #4B5563 !important;
        margin-bottom: 6px !important;
        display: block !important;
    }

    .fitflow-input {
        width: 100% !important;
        border-radius: 10px !important;
        border: 1px solid #E5E7EB !important;
        padding: 11px 16px !important;
        height: 48px !important;
        font-size: 14px !important;
        color: #1F2937 !important;
        background-color: #ffffff !important;
        transition: all 0.2s ease !important;
        display: block !important;
        box-sizing: border-box !important;
    }

    select.fitflow-input {
        appearance: none !important;
        -webkit-appearance: none !important;
        -moz-appearance: none !important;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23343a40' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M2 5l6 6 6-6'/%3e%3c/svg%3e") !important;
        background-repeat: no-repeat !important;
        background-position: right 14px center !important;
        background-size: 14px 10px !important;
        padding-right: 36px !important;
    }

    .fitflow-input:focus {
        border-color: #EAA32B !important;
        box-shadow: 0 0 0 3px rgba(234, 163, 43, 0.2) !important;
        outline: none !important;
    }

    /* Nút Lưu thay đổi vàng cam toàn chiều ngang */
    .fitflow-btn-submit {
        background: #EAA32B !important;
        border: 1px solid #EAA32B !important;
        color: #ffffff !important;
        font-weight: 600 !important;
        font-size: 15px !important;
        border-radius: 10px !important;
        padding: 13px 24px !important;
        width: 100% !important;
        transition: all 0.25s ease !important;
        box-shadow: 0 3px 10px rgba(234, 163, 43, 0.25) !important;
        cursor: pointer !important;
        margin-top: 10px !important;
    }

    .fitflow-btn-submit:hover {
        background: #D8911E !important;
        border-color: #D8911E !important;
        color: #ffffff !important;
        box-shadow: 0 5px 15px rgba(234, 163, 43, 0.35) !important;
    }

    /* Eye toggle password */
    .fitflow-pass-wrap {
        position: relative !important;
    }

    .fitflow-pass-toggle {
        position: absolute !important;
        right: 14px !important;
        top: 50% !important;
        transform: translateY(-50%) !important;
        background: none !important;
        border: none !important;
        color: #9CA3AF !important;
        cursor: pointer !important;
        font-size: 15px !important;
        padding: 4px !important;
        z-index: 5 !important;
    }

    .fitflow-pass-toggle:hover {
        color: #374151 !important;
    }
</style>

<!-- Nút quay lại trang chủ dạng mũi tên nhỏ ở góc trái màn hình -->
<a href="${pageContext.request.contextPath}/home" class="fitflow-back-btn" title="Về trang chính">
    <i class="fa fa-arrow-left"></i>
</a>

<!-- MAIN CONTENT SECTION: Giao diện chuẩn xác 100% theo ảnh mẫu -->
<section class="fitflow-wrapper">
    <div class="container">
        <div class="row justify-content-center">

            <!-- CỘT TRÁI (COL-LG-4): SIDEBAR AVATAR & MENU ĐIỀU HƯỚNG -->
            <div class="col-lg-4 col-md-5 mb-4">
                <div class="fitflow-card text-center">
                    
                    <!-- Avatar tròn 104px: di chuột vào hiện biểu tượng camera, click vào cho phép upload file từ thiết bị -->
                    <div class="fitflow-avatar-box" onclick="document.getElementById('avatarFileInput').click();" title="Nhấn để đổi ảnh đại diện từ thiết bị" style="width: 104px; height: 104px; min-width: 104px; min-height: 104px; max-width: 104px; max-height: 104px; margin: 0 auto 16px; border-radius: 50%; overflow: hidden; cursor: pointer; border: 3px solid #ffba5a; position: relative; background: #ffffff;">
                        <img src="${userAvatarSrc}" alt="Avatar" id="sidebarAvatarImg"
                             style="width: 100%; height: 100%; max-width: 100%; max-height: 100%; object-fit: cover; border-radius: 50%; display: block; margin: 0; ${empty userAvatarSrc ? 'display:none;' : ''}"
                             onerror="this.style.display='none'; document.getElementById('sidebarAvatarFallback').style.display='flex';">
                        <div id="sidebarAvatarFallback" class="fitflow-avatar-fallback" style="width: 100%; height: 100%; border-radius: 50%; ${not empty userAvatarSrc ? 'display:none;' : ''}">
                            ${fn:toUpperCase(fn:substring(u.fullName, 0, 1))}
                        </div>
                        <!-- Lớp phủ icon camera khi hover -->
                        <div class="fitflow-avatar-overlay">
                            <i class="fa fa-camera"></i>
                            <span>Đổi ảnh</span>
                        </div>
                    </div>

                    <!-- Tên người dùng -->
                    <h4 class="fitflow-user-name">
                        <c:out value="${u.fullName}" />
                    </h4>

                    <!-- Vai trò người dùng dạng badge viên thuốc có màu sắc theo từng role -->
                    <div>
                        <c:set var="puRoleName" value="${not empty u.role.roleName ? u.role.roleName : ''}" />
                        <c:set var="puRoleId" value="${u.roleId}" />
                        <c:choose>
                            <c:when test="${puRoleId == 5 || puRoleName == 'ADMIN' || puRoleName == 'ROLE_ADMIN'}">
                                <span class="fitflow-role-badge fitflow-role-admin">
                                    <i class="fa fa-shield"></i> Quản trị viên
                                </span>
                            </c:when>
                            <c:when test="${puRoleId == 2 || puRoleId == 3 || puRoleName == 'HOST' || puRoleName == 'ROLE_HOST' || puRoleName == 'HOTEL_OWNER'}">
                                <span class="fitflow-role-badge fitflow-role-host">
                                    <i class="fa fa-home"></i> Chủ Homestay
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="fitflow-role-badge fitflow-role-customer">
                                    <i class="fa fa-user"></i> Khách hàng
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Ngày tham gia & Trạng thái tài khoản (Giữ lại theo yêu cầu) -->
                    <div class="p-2 mb-4 rounded text-left small text-muted" style="background:#F9FAFB; border:1px solid #E5E7EB;">
                        <div class="d-flex justify-content-between mb-1">
                            <span><i class="fa fa-calendar-check-o mr-1 text-warning"></i> Tham gia:</span>
                            <strong class="text-dark">
                                <c:choose>
                                    <c:when test="${not empty u.createdAt}">
                                        <fmt:formatDate value="${u.createdAt}" pattern="dd/MM/yyyy" />
                                    </c:when>
                                    <c:otherwise>2026</c:otherwise>
                                </c:choose>
                            </strong>
                        </div>
                        <div class="d-flex justify-content-between">
                            <span><i class="fa fa-shield mr-1 text-success"></i> Trạng thái:</span>
                            <span class="badge badge-success px-2 py-1">${u.status}</span>
                        </div>
                    </div>

                    <!-- Các nút điều hướng theo mẫu -->
                    <div class="nav flex-column" id="profileTabs" role="tablist">
                        <a class="fitflow-nav-btn ${activeTab != 'password' ? 'active' : ''}"
                           id="tab-profile-link" data-toggle="pill" href="#tab-profile" role="tab">
                            Thông tin cá nhân
                        </a>
                        <a class="fitflow-nav-btn ${activeTab == 'password' ? 'active' : ''}"
                           id="tab-security-link" data-toggle="pill" href="#tab-security" role="tab">
                            Đổi mật khẩu
                        </a>
                        <a class="fitflow-nav-btn btn-danger-logout" href="#" data-toggle="modal" data-target="#logoutModal">
                            Đăng xuất
                        </a>
                    </div>

                </div>
            </div>

            <!-- CỘT PHẢI (COL-LG-8): NỘI DUNG FORM -->
            <div class="col-lg-8 col-md-7">

                <!-- Alert Thông Báo Lỗi / Thành Công -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius:12px;">
                        <div class="d-flex align-items-center">
                            <i class="fa fa-exclamation-triangle fa-2x mr-3 text-danger"></i>
                            <div>
                                <strong class="d-block">Có lỗi xảy ra:</strong>
                                <span><c:out value="${error}" /></span>
                            </div>
                        </div>
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </c:if>

                <c:if test="${not empty success}">
                    <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius:12px;">
                        <div class="d-flex align-items-center">
                            <i class="fa fa-check-circle fa-2x mr-3 text-success"></i>
                            <div>
                                <strong class="d-block">Thành công:</strong>
                                <span><c:out value="${success}" /></span>
                            </div>
                        </div>
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </c:if>

                <div class="tab-content" id="profileTabContent">

                    <!-- ==========================================
                         TAB 1: THÔNG TIN TÀI KHOẢN (Chuẩn theo ảnh mẫu)
                         ========================================== -->
                    <div class="tab-pane fade ${activeTab != 'password' ? 'show active' : ''}" id="tab-profile" role="tabpanel">
                        <div class="fitflow-card">
                            
                            <h4 class="fitflow-title">Thông tin tài khoản</h4>
                            <p class="fitflow-subtitle">Cập nhật thông tin liên hệ để nhận hỗ trợ nhanh hơn từ Sogo Homestay.</p>

                            <form method="post" action="${pageContext.request.contextPath}/profile" id="profileForm" enctype="multipart/form-data">
                                <input type="hidden" name="action" value="updateProfile">

                                <!-- Input file ẩn: Được kích hoạt khi nhấn vào avatar ở sidebar -->
                                <input type="file" id="avatarFileInput" name="avatarFile" accept="image/*" style="display:none;" onchange="handleAvatarFileSelect(this)">

                                <!-- Thông báo tạm thời khi vừa chọn file avatar mới -->
                                <div id="avatarSelectedAlert" class="alert alert-warning py-2 px-3 small mb-3" style="display:none; border-radius:10px;">
                                    <i class="fa fa-check-circle text-success mr-1"></i> <span id="avatarFileNameText">Đã chọn ảnh mới.</span> 
                                    Nhớ nhấn <strong>Lưu thay đổi</strong> ở bên dưới để lưu vào hệ thống!
                                </div>

                                <!-- 1. Họ và tên -->
                                <div class="form-group mb-3">
                                    <label class="fitflow-label">Họ và tên</label>
                                    <input type="text" class="fitflow-input" name="fullName" required
                                           value="<c:out value='${u.fullName}' />" maxlength="100"
                                           placeholder="Nhập họ và tên">
                                </div>

                                <!-- 2. Số điện thoại -->
                                <div class="form-group mb-3">
                                    <label class="fitflow-label">Số điện thoại</label>
                                    <input type="text" class="fitflow-input" name="phone"
                                           value="<c:out value='${u.phone}' />" maxlength="20"
                                           placeholder="Nhập số điện thoại">
                                </div>

                                <!-- 3. Email (Readonly) -->
                                <div class="form-group mb-3">
                                    <label class="fitflow-label">Email</label>
                                    <input type="email" class="fitflow-input" style="background-color: #F9FAFB !important; cursor: not-allowed;"
                                           value="<c:out value='${u.email}' />" readonly disabled>
                                </div>

                                <!-- 4. Địa chỉ -->
                                <div class="form-group mb-3">
                                    <label class="fitflow-label">Địa chỉ</label>
                                    <input type="text" class="fitflow-input" name="address"
                                           value="<c:out value='${u.address}' />" maxlength="255"
                                           placeholder="Nhập địa chỉ cư trú">
                                </div>

                                <!-- 5. Giới tính -->
                                <div class="form-group mb-3">
                                    <label class="fitflow-label">Giới tính</label>
                                    <select name="gender" class="fitflow-input custom-select">
                                        <option value="" ${empty u.gender ? 'selected' : ''}>Chưa chọn</option>
                                        <option value="NAM" ${u.gender == 'NAM' ? 'selected' : ''}>Nam</option>
                                        <option value="NU" ${u.gender == 'NU' ? 'selected' : ''}>Nữ</option>
                                        <option value="KHAC" ${u.gender == 'KHAC' ? 'selected' : ''}>Khác</option>
                                    </select>
                                </div>

                                <!-- 6. Ngày sinh -->
                                <div class="form-group mb-4">
                                    <label class="fitflow-label">Ngày sinh</label>
                                    <input type="date" class="fitflow-input" name="dateOfBirth"
                                           value="${u.dateOfBirth}">
                                </div>

                                <!-- Nút Lưu thay đổi (To, màu vàng hổ phách bo góc như ảnh mẫu) -->
                                <button type="submit" class="fitflow-btn-submit">
                                    Lưu thay đổi
                                </button>

                            </form>
                        </div>
                    </div>

                    <!-- ==========================================
                         TAB 2: ĐỔI MẬT KHẨU
                         ========================================== -->
                    <div class="tab-pane fade ${activeTab == 'password' ? 'show active' : ''}" id="tab-security" role="tabpanel">
                        <div class="fitflow-card">

                            <h4 class="fitflow-title">Đổi mật khẩu</h4>
                            <p class="fitflow-subtitle">Để bảo mật tài khoản, vui lòng không chia sẻ mật khẩu cho người khác.</p>

                            <c:choose>
                                <%-- TRƯỜNG HỢP 1: Tài khoản thường (Email + Mật khẩu local) --%>
                                <c:when test="${not empty u.password}">
                                    
                                    <div class="p-3 mb-4 rounded" style="background:#FFF9E6; border-left:4px solid #EAA32B;">
                                        <h6 class="font-weight-bold text-dark mb-1 small">
                                            <i class="fa fa-info-circle text-warning mr-1"></i> Hướng dẫn mật khẩu an toàn
                                        </h6>
                                        <ul class="text-muted small mb-0 pl-3">
                                            <li>Mật khẩu mới phải có tối thiểu <strong>8 ký tự</strong>.</li>
                                            <li>Nên kết hợp chữ cái viết hoa, chữ thường, chữ số và ký tự đặc biệt.</li>
                                        </ul>
                                    </div>

                                    <form method="post" action="${pageContext.request.contextPath}/profile" id="changePasswordForm">
                                        <input type="hidden" name="action" value="changePassword">

                                        <div class="form-group mb-3">
                                            <label class="fitflow-label">Mật khẩu hiện tại <span class="text-danger">*</span></label>
                                            <div class="fitflow-pass-wrap">
                                                <input type="password" class="fitflow-input" name="oldPassword" id="oldPasswordInput" required
                                                       placeholder="Nhập mật khẩu hiện tại">
                                                <button type="button" class="fitflow-pass-toggle" onclick="togglePasswordVisibility('oldPasswordInput', this)" title="Ẩn/hiện mật khẩu">
                                                    <i class="fa fa-eye"></i>
                                                </button>
                                            </div>
                                        </div>

                                        <div class="form-group mb-3">
                                            <label class="fitflow-label">Mật khẩu mới <span class="text-danger">*</span></label>
                                            <div class="fitflow-pass-wrap">
                                                <input type="password" class="fitflow-input" name="newPassword" id="newPasswordInput" required minlength="8"
                                                       placeholder="Tối thiểu 8 ký tự" oninput="checkPasswordMatch()">
                                                <button type="button" class="fitflow-pass-toggle" onclick="togglePasswordVisibility('newPasswordInput', this)" title="Ẩn/hiện mật khẩu">
                                                    <i class="fa fa-eye"></i>
                                                </button>
                                            </div>
                                        </div>

                                        <div class="form-group mb-4">
                                            <label class="fitflow-label">Xác nhận mật khẩu mới <span class="text-danger">*</span></label>
                                            <div class="fitflow-pass-wrap">
                                                <input type="password" class="fitflow-input" name="confirmPassword" id="confirmPasswordInput" required minlength="8"
                                                       placeholder="Nhập lại mật khẩu mới" oninput="checkPasswordMatch()">
                                                <button type="button" class="fitflow-pass-toggle" onclick="togglePasswordVisibility('confirmPasswordInput', this)" title="Ẩn/hiện mật khẩu">
                                                    <i class="fa fa-eye"></i>
                                                </button>
                                            </div>
                                            <div id="passwordMatchMessage" class="small mt-1" style="display:none;"></div>
                                        </div>

                                        <button type="submit" class="fitflow-btn-submit">
                                            Lưu thay đổi
                                        </button>

                                    </form>

                                </c:when>

                                <%-- TRƯỜNG HỢP 2: Tài khoản đăng nhập qua Google --%>
                                <c:otherwise>
                                    <div class="text-center py-5 rounded" style="background:#F9FAFB; border:1px solid #E5E7EB;">
                                        <div class="mb-3">
                                            <span class="fa-stack fa-2x">
                                                <i class="fa fa-circle fa-stack-2x text-light"></i>
                                                <i class="fa fa-google fa-stack-1x text-danger"></i>
                                            </span>
                                        </div>
                                        <h5 class="font-weight-bold text-dark mb-2">Tài Khoản Đăng Nhập Bằng Google</h5>
                                        <p class="text-muted small mb-4" style="max-width: 480px; margin: 0 auto; line-height: 1.8;">
                                            Tài khoản của bạn được liên kết trực tiếp với dịch vụ định danh Google (<strong><c:out value="${u.email}" /></strong>). 
                                            Mật khẩu được quản lý an toàn bởi Google Account, không cần thay đổi mật khẩu trên Sogo Homestay.
                                        </p>
                                        <div class="d-inline-flex align-items-center px-3 py-2 rounded border bg-white shadow-sm">
                                            <i class="fa fa-shield text-success mr-2"></i>
                                            <span class="small font-weight-bold text-dark">Bảo vệ 2 lớp bởi Google Security</span>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>

                        </div>
                    </div>

                </div>

            </div>

        </div>
    </div>
</section>

<script>
    // Xử lý khi người dùng chọn file ảnh từ thiết bị qua việc nhấn vào Avatar
    function handleAvatarFileSelect(input) {
        if (!input.files || !input.files[0]) {
            return;
        }
        var file = input.files[0];
        
        // Hiện thông báo đã chọn ảnh mới
        var alertBox = document.getElementById('avatarSelectedAlert');
        var fileNameText = document.getElementById('avatarFileNameText');
        if (alertBox && fileNameText) {
            fileNameText.innerText = 'Đã chọn ảnh: ' + file.name + ' (' + (file.size / 1024).toFixed(1) + ' KB).';
            alertBox.style.display = 'block';
        }

        // Đọc và xem trước ảnh ngay lập tức trên Avatar tròn
        var reader = new FileReader();
        reader.onload = function(e) {
            var dataUrl = e.target.result;
            
            var sidebarImg = document.getElementById('sidebarAvatarImg');
            var sidebarFallback = document.getElementById('sidebarAvatarFallback');
            if (sidebarImg) {
                sidebarImg.src = dataUrl;
                sidebarImg.style.display = 'block';
            }
            if (sidebarFallback) {
                sidebarFallback.style.display = 'none';
            }
        };
        reader.readAsDataURL(file);
    }

    // Hàm ẩn/hiện mật khẩu
    function togglePasswordVisibility(inputId, btn) {
        var input = document.getElementById(inputId);
        var icon = btn.querySelector('i');
        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
        } else {
            input.type = 'password';
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
        }
    }

    // Kiểm tra khớp mật khẩu thời gian thực
    function checkPasswordMatch() {
        var newPass = document.getElementById('newPasswordInput');
        var confirmPass = document.getElementById('confirmPasswordInput');
        var msg = document.getElementById('passwordMatchMessage');
        if (!newPass || !confirmPass || !msg) return;

        if (confirmPass.value.length === 0) {
            msg.style.display = 'none';
            return;
        }

        msg.style.display = 'block';
        if (newPass.value === confirmPass.value) {
            msg.className = 'small mt-1 text-success font-weight-bold';
            msg.innerHTML = '<i class="fa fa-check mr-1"></i> Mật khẩu xác nhận hoàn toàn trùng khớp.';
        } else {
            msg.className = 'small mt-1 text-danger font-weight-bold';
            msg.innerHTML = '<i class="fa fa-times mr-1"></i> Mật khẩu xác nhận chưa khớp.';
        }
    }

    // Đồng bộ URL hash với Bootstrap tabs
    document.addEventListener('DOMContentLoaded', function() {
        var hash = window.location.hash;
        if (hash === '#tab-security' || hash === '#security') {
            $('#tab-security-link').tab('show');
        } else if (hash === '#tab-profile' || hash === '#profile') {
            $('#tab-profile-link').tab('show');
        }

        $('a[data-toggle="pill"]').on('shown.bs.tab', function (e) {
            var target = $(e.target).attr("href");
            if (target === '#tab-security') {
                window.location.hash = 'security';
            } else if (target === '#tab-profile') {
                window.location.hash = 'profile';
            }
        });
    });
</script>

<!-- Modal Xác nhận Đăng xuất (Dành riêng cho trang Profile khi không nạp navbar) -->
<div class="modal fade sogo-modal" id="logoutModal" tabindex="-1" role="dialog" aria-labelledby="logoutModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header border-0 pb-0 justify-content-end">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body text-center pt-0 px-4 pb-4">
                <div class="modal-icon-wrap mb-3">
                    <i class="fa fa-sign-out"></i>
                </div>
                <h4 class="modal-title mb-2" id="logoutModalTitle">Xác nhận đăng xuất</h4>
                <p class="text-muted mb-4">
                    Bạn có chắc chắn muốn đăng xuất khỏi tài khoản
                    <strong><c:out value="${profileUser.fullName}" /></strong>
                    không?
                </p>
                <div class="d-flex justify-content-center">
                    <button type="button" class="btn btn-stay px-4 py-2 rounded-pill font-weight-bold mr-3" data-dismiss="modal">
                        Ở lại
                    </button>
                    <form action="${pageContext.request.contextPath}/logout" method="post" class="m-0 d-inline">
                        <button type="submit" class="btn btn-logout px-4 py-2 rounded-pill font-weight-bold">
                            <i class="fa fa-sign-out mr-1"></i> Đăng xuất
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="common/footer.jsp" />