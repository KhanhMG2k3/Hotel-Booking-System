<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<header class="site-header js-site-header">
    <div class="container-fluid">
        <div class="row align-items-center">
            <div class="col-6 col-lg-4 site-logo" data-aos="fade">
                <a href="${pageContext.request.contextPath}/home">Sogo Homestay</a>
            </div>
            <div class="col-6 col-lg-8 header-actions-container">
                <div class="auth-actions">
                    <c:choose>
                        <c:when test="${not empty sessionScope.userId}">
                            <c:set var="navAvatarSrc" value="" />
                            <c:if test="${not empty sessionScope.avatar}">
                                <c:choose>
                                    <c:when test="${fn:startsWith(sessionScope.avatar, 'http://') or fn:startsWith(sessionScope.avatar, 'https://')}">
                                        <c:set var="navAvatarSrc" value="${sessionScope.avatar}" />
                                    </c:when>
                                    <c:when test="${fn:startsWith(sessionScope.avatar, '/assets/')}">
                                        <c:set var="navAvatarSrc" value="${pageContext.request.contextPath}${sessionScope.avatar}" />
                                    </c:when>
                                    <c:when test="${fn:startsWith(sessionScope.avatar, 'assets/')}">
                                        <c:set var="navAvatarSrc" value="${pageContext.request.contextPath}/${sessionScope.avatar}" />
                                    </c:when>
                                    <c:when test="${fn:startsWith(sessionScope.avatar, '/')}">
                                        <c:set var="navAvatarSrc" value="${pageContext.request.contextPath}/assets${sessionScope.avatar}" />
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="navAvatarSrc" value="${pageContext.request.contextPath}/assets/${sessionScope.avatar}" />
                                    </c:otherwise>
                                </c:choose>
                            </c:if>

                            <div class="user-menu" id="userMenuContainer">
                                <button class="user-menu-toggle" id="userMenuToggle" type="button" aria-haspopup="true" aria-expanded="false" title="Tài khoản của tôi">
                                    <c:choose>
                                        <c:when test="${not empty navAvatarSrc}">
                                            <img src="${navAvatarSrc}" alt="Avatar" class="user-avatar-img"
                                                 onerror="this.style.display='none'; document.getElementById('navbarAvatarFallback').style.display='inline-flex';">
                                            <span id="navbarAvatarFallback" class="user-avatar-fallback" style="display:none;">
                                                ${fn:toUpperCase(fn:substring(sessionScope.userName, 0, 1))}
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="user-avatar-fallback">
                                                ${fn:toUpperCase(fn:substring(sessionScope.userName, 0, 1))}
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                    <span class="user-name"><c:out value="${sessionScope.userName}" /></span>
                                    <i class="fa fa-angle-down user-caret ml-1"></i>
                                </button>

                                <div class="user-dropdown" id="userDropdown" role="menu">
                                    <div class="user-dropdown-header">
                                        <div class="user-dropdown-name"><c:out value="${sessionScope.userName}" /></div>
                                        <c:if test="${not empty sessionScope.userEmail}">
                                            <span class="user-dropdown-email"><c:out value="${sessionScope.userEmail}" /></span>
                                        </c:if>
                                        <c:set var="uRoleName" value="${not empty sessionScope.user.role.roleName ? sessionScope.user.role.roleName : ''}" />
                                        <c:set var="uRoleId" value="${sessionScope.roleId}" />
                                        <c:set var="isUserAdmin" value="${uRoleId == 5 || uRoleName == 'ADMIN' || uRoleName == 'ROLE_ADMIN'}" />
                                        <c:set var="isUserHost" value="${uRoleId == 2 || uRoleId == 3 || uRoleName == 'HOST' || uRoleName == 'ROLE_HOST' || uRoleName == 'HOTEL_OWNER'}" />

                                        <c:choose>
                                            <c:when test="${isUserAdmin}">
                                                <span class="user-role-badge"><i class="fa fa-shield mr-1"></i> Quản trị viên</span>
                                            </c:when>
                                            <c:when test="${isUserHost}">
                                                <span class="user-role-badge"><i class="fa fa-home mr-1"></i> Chủ Homestay</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="user-role-badge"><i class="fa fa-user mr-1"></i> Khách hàng</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="user-dropdown-divider"></div>
                                    <a href="${pageContext.request.contextPath}/profile" class="user-dropdown-item" role="menuitem">
                                        <i class="fa fa-user-circle-o"></i> Hồ sơ cá nhân
                                    </a>
                                    <a href="${pageContext.request.contextPath}/my-bookings" class="user-dropdown-item" role="menuitem">
                                        <i class="fa fa-calendar-check-o"></i> Lịch sử đặt phòng
                                    </a>
                                    <c:if test="${!isUserAdmin && !isUserHost}">
                                        <a href="${pageContext.request.contextPath}/become-host" class="user-dropdown-item" role="menuitem">
                                            <i class="fa fa-home"></i> Trở thành Host
                                        </a>
                                    </c:if>
                                    <c:if test="${isUserHost}">
                                        <a href="${pageContext.request.contextPath}/host/dashboard" class="user-dropdown-item" role="menuitem">
                                            <i class="fa fa-dashboard"></i> Host Dashboard
                                        </a>
                                    </c:if>
                                    <c:if test="${isUserAdmin}">
                                        <a href="${pageContext.request.contextPath}/admin/dashboard" class="user-dropdown-item" role="menuitem">
                                            <i class="fa fa-cogs"></i> Trang Quản Trị
                                        </a>
                                    </c:if>
                                    <div class="user-dropdown-divider"></div>
                                    <button type="button" class="user-dropdown-item user-dropdown-logout" data-toggle="modal" data-target="#logoutModal" role="menuitem">
                                        <i class="fa fa-sign-out"></i> Đăng xuất
                                    </button>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <a class="auth-link" href="${pageContext.request.contextPath}/login">Đăng nhập</a>
                            <a class="auth-link auth-link-primary" href="${pageContext.request.contextPath}/register">Đăng ký</a>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="site-menu-toggle js-site-menu-toggle" data-aos="fade" title="Menu điều hướng">
                    <span></span>
                    <span></span>
                    <span></span>
                </div>
                <!-- END menu-toggle -->

                <div class="site-navbar js-site-navbar" id="siteNavbarOverlay">
                    <!-- Lớp phủ làm tối và mờ nền khi mở menu -->
                    <div class="site-navbar-backdrop" onclick="closeSiteNavbar()" title="Nhấn để đóng menu"></div>

                    <!-- Thanh điều hướng dạng cột dọc một bên (Sidebar Drawer kiểu Antigravity) -->
                    <aside class="site-navbar-drawer" role="navigation" aria-label="Menu điều hướng">
                        
                        <!-- Header Drawer: Logo & Nút đóng X -->
                        <div class="drawer-header">
                            <div class="drawer-brand">
                                <span class="drawer-brand-badge"><i class="fa fa-compass"></i></span>
                                <div class="drawer-brand-text">
                                    <span class="drawer-brand-title">Sogo Homestay</span>
                                    <span class="drawer-brand-sub">Khám phá & Nghỉ dưỡng</span>
                                </div>
                            </div>
                            <button type="button" class="drawer-close-btn" onclick="closeSiteNavbar()" title="Đóng menu" aria-label="Close">
                                <i class="fa fa-times"></i>
                            </button>
                        </div>

                        <!-- Thân Drawer cuộn mượt mà -->
                        <div class="drawer-body">

                            <!-- Thẻ tóm tắt thông tin người dùng (Đã đăng nhập vs Khách) -->
                            <c:choose>
                                <c:when test="${not empty sessionScope.userId}">
                                    <div class="drawer-user-card">
                                        <div class="drawer-user-avatar-wrap">
                                            <c:choose>
                                                <c:when test="${not empty navAvatarSrc}">
                                                    <img src="${navAvatarSrc}" alt="Avatar" class="drawer-user-avatar"
                                                         onerror="this.style.display='none'; var fb=document.getElementById('drawerAvatarFallback'); if(fb) fb.style.setProperty('display', 'inline-flex', 'important');">
                                                    <span id="drawerAvatarFallback" class="drawer-user-avatar-fallback" style="display:none !important;">
                                                        ${fn:toUpperCase(fn:substring(sessionScope.userName, 0, 1))}
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="drawer-user-avatar-fallback">
                                                        ${fn:toUpperCase(fn:substring(sessionScope.userName, 0, 1))}
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                            <span class="drawer-user-status-dot" title="Đang hoạt động"></span>
                                        </div>
                                        <div class="drawer-user-info">
                                            <h6 class="drawer-user-name"><c:out value="${sessionScope.userName}" /></h6>
                                            <c:if test="${not empty sessionScope.userEmail}">
                                                <span class="drawer-user-email"><c:out value="${sessionScope.userEmail}" /></span>
                                            </c:if>
                                            <div class="mt-1">
                                                <c:choose>
                                                    <c:when test="${isUserAdmin}">
                                                        <span class="drawer-role-pill role-admin"><i class="fa fa-shield mr-1"></i> Quản trị viên</span>
                                                    </c:when>
                                                    <c:when test="${isUserHost}">
                                                        <span class="drawer-role-pill role-host"><i class="fa fa-home mr-1"></i> Chủ Homestay</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="drawer-role-pill role-customer"><i class="fa fa-user mr-1"></i> Khách hàng</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="drawer-guest-card">
                                        <div class="drawer-guest-header">
                                            <div class="drawer-guest-icon"><i class="fa fa-user-circle"></i></div>
                                            <div>
                                                <h6 class="drawer-guest-title">Chào mừng quý khách!</h6>
                                                <p class="drawer-guest-desc">Đăng nhập để đặt phòng và hưởng ưu đãi.</p>
                                            </div>
                                        </div>
                                        <div class="drawer-guest-actions">
                                            <a href="${pageContext.request.contextPath}/login" class="drawer-btn drawer-btn-secondary" onclick="closeSiteNavbar()">
                                                <i class="fa fa-sign-in mr-1"></i> Đăng nhập
                                            </a>
                                            <a href="${pageContext.request.contextPath}/register" class="drawer-btn drawer-btn-primary" onclick="closeSiteNavbar()">
                                                <i class="fa fa-user-plus mr-1"></i> Đăng ký
                                            </a>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>

                            <!-- Khối 1: ĐIỀU HƯỚNG CHÍNH -->
                            <div class="drawer-section">
                                <div class="drawer-section-label">ĐIỀU HƯỚNG CHÍNH</div>
                                <ul class="drawer-nav-list">
                                    <li class="drawer-nav-item ${activePage == 'home' ? 'active' : ''}">
                                        <a href="${pageContext.request.contextPath}/home" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                            <span class="drawer-nav-icon icon-home"><i class="fa fa-home"></i></span>
                                            <span class="drawer-nav-text">Trang Chủ</span>
                                            <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                        </a>
                                    </li>
                                    <li class="drawer-nav-item ${activePage == 'rooms' ? 'active' : ''}">
                                        <a href="${pageContext.request.contextPath}/rooms" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                            <span class="drawer-nav-icon icon-rooms"><i class="fa fa-bed"></i></span>
                                            <span class="drawer-nav-text">Danh Sách & Đặt Phòng</span>
                                            <span class="drawer-nav-badge">Hot</span>
                                            <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                        </a>
                                    </li>
                                    <li class="drawer-nav-item ${activePage == 'reservation' ? 'active' : ''}">
                                        <a href="${pageContext.request.contextPath}/reservation" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                            <span class="drawer-nav-icon icon-reservation"><i class="fa fa-calendar-check-o"></i></span>
                                            <span class="drawer-nav-text">Đặt Phòng Nhanh</span>
                                            <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                        </a>
                                    </li>
                                    <li class="drawer-nav-item">
                                        <a href="${pageContext.request.contextPath}/assets/about.html" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                            <span class="drawer-nav-icon icon-about"><i class="fa fa-info-circle"></i></span>
                                            <span class="drawer-nav-text">Về Chúng Tôi</span>
                                            <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                        </a>
                                    </li>
                                    <li class="drawer-nav-item">
                                        <a href="${pageContext.request.contextPath}/assets/contact.html" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                            <span class="drawer-nav-icon icon-contact"><i class="fa fa-envelope-o"></i></span>
                                            <span class="drawer-nav-text">Liên Hệ</span>
                                            <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                        </a>
                                    </li>
                                </ul>
                            </div>

                            <!-- Khối 2: TÀI KHOẢN & DỊCH VỤ (Khi đã đăng nhập) -->
                            <c:if test="${not empty sessionScope.userId}">
                                <div class="drawer-section">
                                    <div class="drawer-section-label">TÀI KHOẢN & DỊCH VỤ</div>
                                    <ul class="drawer-nav-list">
                                        <li class="drawer-nav-item">
                                            <a href="${pageContext.request.contextPath}/profile" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                                <span class="drawer-nav-icon icon-profile"><i class="fa fa-user-circle-o"></i></span>
                                                <span class="drawer-nav-text">Hồ Sơ Cá Nhân</span>
                                                <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                            </a>
                                        </li>
                                        <li class="drawer-nav-item">
                                            <a href="${pageContext.request.contextPath}/my-bookings" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                                <span class="drawer-nav-icon icon-bookings"><i class="fa fa-calendar-check-o"></i></span>
                                                <span class="drawer-nav-text">Lịch Sử Đặt Phòng</span>
                                                <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                            </a>
                                        </li>
                                        <c:if test="${!isUserAdmin && !isUserHost}">
                                            <li class="drawer-nav-item">
                                                <a href="${pageContext.request.contextPath}/become-host" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                                    <span class="drawer-nav-icon icon-host"><i class="fa fa-home"></i></span>
                                                    <span class="drawer-nav-text">Trở Thành Host</span>
                                                    <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                                </a>
                                            </li>
                                        </c:if>
                                        <c:if test="${isUserHost}">
                                            <li class="drawer-nav-item">
                                                <a href="${pageContext.request.contextPath}/host/dashboard" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                                    <span class="drawer-nav-icon icon-dashboard"><i class="fa fa-dashboard"></i></span>
                                                    <span class="drawer-nav-text">Host Dashboard</span>
                                                    <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                                </a>
                                            </li>
                                        </c:if>
                                        <c:if test="${isUserAdmin}">
                                            <li class="drawer-nav-item">
                                                <a href="${pageContext.request.contextPath}/admin/dashboard" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                                    <span class="drawer-nav-icon icon-admin"><i class="fa fa-cogs"></i></span>
                                                    <span class="drawer-nav-text">Trang Quản Trị</span>
                                                    <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                                </a>
                                            </li>
                                        </c:if>
                                        <li class="drawer-nav-item">
                                            <a href="javascript:void(0)" class="drawer-nav-link text-danger" data-toggle="modal" data-target="#logoutModal" onclick="closeSiteNavbar()">
                                                <span class="drawer-nav-icon icon-logout"><i class="fa fa-sign-out"></i></span>
                                                <span class="drawer-nav-text font-weight-bold">Đăng Xuất</span>
                                                <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                            </c:if>

                            <!-- Khối hỗ trợ nhanh Hotline -->
                            <div class="drawer-help-card">
                                <div class="drawer-help-icon"><i class="fa fa-phone"></i></div>
                                <div class="drawer-help-info">
                                    <span class="drawer-help-label">Hotline hỗ trợ 24/7</span>
                                    <a href="tel:19008888" class="drawer-help-phone">1900 8888</a>
                                </div>
                            </div>

                        </div>

                        <!-- Footer Drawer: Mạng xã hội & Bản quyền -->
                        <div class="drawer-footer">
                            <div class="drawer-social-links">
                                <a href="#" class="drawer-social-btn" title="Facebook"><i class="fa fa-facebook"></i></a>
                                <a href="#" class="drawer-social-btn" title="Instagram"><i class="fa fa-instagram"></i></a>
                                <a href="#" class="drawer-social-btn" title="Youtube"><i class="fa fa-youtube-play"></i></a>
                            </div>
                            <div class="drawer-copyright">
                                &copy; 2026 Sogo Homestay. All rights reserved.
                            </div>
                        </div>

                    </aside>
                </div>
            </div>
        </div>
    </div>
</header>
<!-- END head -->

<!-- Modal Xác nhận Đăng xuất (Chuẩn theme Sogo Homestay) -->
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
                    <c:if test="${not empty sessionScope.userName}">
                        <strong><c:out value="${sessionScope.userName}" /></strong>
                    </c:if>
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

<!-- Toast Thông báo Đăng xuất thành công -->
<c:if test="${param.logout == 'success'}">
    <div class="sogo-toast alert alert-dismissible fade show" role="alert" id="logoutSuccessToast">
        <div class="toast-content">
            <i class="fa fa-check-circle toast-icon mr-2"></i>
            <span>Bạn đã đăng xuất thành công khỏi hệ thống!</span>
        </div>
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true">&times;</span>
        </button>
    </div>
</c:if>

<script>
    function closeSiteNavbar() {
        if (typeof $ !== 'undefined') {
            $('.site-menu-toggle').removeClass('open');
            $('.js-site-navbar').fadeOut(280);
            $('body').removeClass('menu-open');
        } else {
            var nav = document.getElementById('siteNavbarOverlay');
            if (nav) nav.style.display = 'none';
            var toggle = document.querySelector('.site-menu-toggle');
            if (toggle) toggle.classList.remove('open');
            document.body.classList.remove('menu-open');
        }
    }

    // Đóng drawer khi nhấn phím Escape
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' || e.keyCode === 27) {
            closeSiteNavbar();
        }
    });

    document.addEventListener('DOMContentLoaded', function () {
        var menuContainer = document.getElementById('userMenuContainer');
        var toggle = document.getElementById('userMenuToggle');
        var dropdown = document.getElementById('userDropdown');

        if (toggle && dropdown && menuContainer) {
            toggle.addEventListener('click', function (e) {
                e.stopPropagation();
                var isOpen = dropdown.classList.toggle('show');
                menuContainer.classList.toggle('open', isOpen);
                toggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
            });

            document.addEventListener('click', function (e) {
                if (!menuContainer.contains(e.target)) {
                    dropdown.classList.remove('show');
                    menuContainer.classList.remove('open');
                    toggle.setAttribute('aria-expanded', 'false');
                }
            });
        }

        // Tự động ẩn toast logout sau 4.5s
        var toast = document.getElementById('logoutSuccessToast');
        if (toast) {
            setTimeout(function () {
                if (typeof $ !== 'undefined') {
                    $(toast).fadeOut(400, function () {
                        $(this).remove();
                    });
                } else {
                    toast.style.display = 'none';
                }
            }, 4500);
        }
    });
</script>