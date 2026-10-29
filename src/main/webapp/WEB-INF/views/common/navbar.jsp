<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%-- Shared responsive site header: brand logo, quick actions, collapsible desktop links, user menu, and side drawer. --%>
<header class="site-header js-site-header">
    <div class="container-fluid">
        <div class="header-bar-row">
            <div class="site-logo" data-aos="fade">
                <a href="${pageContext.request.contextPath}/home">Sogo Homestay</a>
            </div>
            <div class="header-actions-container">
                <div class="auth-actions">
                    <!-- NÚT DANH SÁCH YÊU THÍCH TRÊN HEADER -->
                    <a href="${pageContext.request.contextPath}/wishlist" class="header-wishlist-link" title="Danh sách phòng yêu thích">
                        <i class="fa fa-heart"></i>
                        <span class="header-wishlist-badge" id="navbarWishlistBadge">${not empty wishlistCount ? wishlistCount : (not empty sessionScope.wishlistCount ? sessionScope.wishlistCount : 0)}</span>
                    </a>

                    <!-- NÚT THÔNG BÁO TRÊN HEADER (IN-APP NOTIFICATIONS) -->
                    <c:if test="${not empty sessionScope.userId}">
                        <div class="header-notification-wrapper" id="headerNotificationWrapper">
                            <!-- Nút chuông dạng tròn đồng bộ với nút Wishlist -->
                            <a href="javascript:void(0);" class="header-notification-link" id="headerNotificationToggle"
                               aria-haspopup="true" aria-expanded="false" title="Thông báo của bạn">
                                <i class="fa fa-bell"></i>
                                <span class="header-notification-badge" id="navbarNotificationBadge">0</span>
                            </a>

                            <!-- POPUP DROPDOWN TOP 5 THÔNG BÁO -->
                            <div class="notification-header-dropdown shadow-lg" id="notificationHeaderDropdown" role="region" aria-label="Thông báo gần đây">

                                <div class="d-flex justify-content-between align-items-center p-3 border-bottom bg-light">
                                    <span class="font-weight-bold text-dark notif-dropdown-title">
                                        <i class="fa fa-bell text-warning mr-1"></i> Thông báo
                                    </span>
                                    <button type="button" class="btn btn-link btn-sm p-0 text-primary notif-mark-read-btn" id="btnHeaderMarkAllRead">
                                        Đánh dấu đã đọc
                                    </button>
                                </div>

                                <!-- Danh sách 5 thông báo nạp động qua AJAX -->
                                <div id="headerNotificationList" class="header-notification-list">
                                    <div class="text-center py-4 text-muted small">
                                        <i class="fa fa-spinner fa-spin mr-1"></i> Đang tải thông báo...
                                    </div>
                                </div>

                                <!-- Footer dẫn sang trang đầy đủ -->
                                <div class="p-2 text-center border-top bg-light">
                                    <a href="${pageContext.request.contextPath}/notifications" class="small text-primary font-weight-bold notif-footer-link">
                                        Xem tất cả thông báo <i class="fa fa-arrow-right ml-1"></i>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:if>

                    <%-- Desktop navigation links: shown inline when space suffices (>= 1200px) and accessible via the side drawer on smaller viewports. --%>
                    <div class="header-nav-links">
                        <!-- CÁC NÚT ĐIỀU HƯỚNG CHÍNH (Hiển thị cho cả khi chưa đăng nhập và đã đăng nhập) -->
                        <a class="auth-link ${activePage == 'rooms' ? 'font-weight-bold text-warning' : ''}" href="${pageContext.request.contextPath}/rooms">Danh Sách Phòng</a>
                        <a class="auth-link ${activePage == 'about' ? 'font-weight-bold text-warning' : ''}" href="${pageContext.request.contextPath}/about">Về Chúng Tôi</a>
                        <a class="auth-link ${activePage == 'terms' ? 'font-weight-bold text-warning' : ''}" href="${pageContext.request.contextPath}/terms">Điều Khoản</a>
                        <a class="auth-link ${activePage == 'faq' ? 'font-weight-bold text-warning' : ''}" href="${pageContext.request.contextPath}/faq">FAQ</a>
                        <!-- Dấu gạch đứng phân cách nhẹ -->
                        <span class="auth-divider" aria-hidden="true">|</span>
                    </div>

                    <c:choose>
                        <c:when test="${not empty sessionScope.userId}">
                            <c:set var="displayName" value="${not empty sessionScope.displayName ? sessionScope.displayName : sessionScope.userName}" />
                            <c:set var="navAvatarSrc" value="" />
                            <c:if test="${not empty sessionScope.avatar or not empty sessionScope.avatarUrl}">
                                <c:set var="rawAvatar" value="${not empty sessionScope.avatar ? sessionScope.avatar : sessionScope.avatarUrl}" />
                                <c:choose>
                                    <c:when test="${fn:startsWith(rawAvatar, 'http://') or fn:startsWith(rawAvatar, 'https://')}">
                                        <c:set var="navAvatarSrc" value="${rawAvatar}" />
                                    </c:when>
                                    <c:when test="${fn:startsWith(rawAvatar, '/assets/')}">
                                        <c:set var="navAvatarSrc" value="${pageContext.request.contextPath}${rawAvatar}" />
                                    </c:when>
                                    <c:when test="${fn:startsWith(rawAvatar, 'assets/')}">
                                        <c:set var="navAvatarSrc" value="${pageContext.request.contextPath}/${rawAvatar}" />
                                    </c:when>
                                    <c:when test="${fn:startsWith(rawAvatar, '/')}">
                                        <c:set var="navAvatarSrc" value="${pageContext.request.contextPath}/assets${rawAvatar}" />
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="navAvatarSrc" value="${pageContext.request.contextPath}/assets/${rawAvatar}" />
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
                                                ${fn:toUpperCase(fn:substring(displayName, 0, 1))}
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="user-avatar-fallback">
                                                ${fn:toUpperCase(fn:substring(displayName, 0, 1))}
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                    <span class="user-name"><c:out value="${displayName}" /></span>
                                    <i class="fa fa-angle-down user-caret ml-1"></i>
                                </button>
                                <div class="user-dropdown" id="userDropdown" role="menu">
                                    <div class="user-dropdown-header">
                                        <div class="user-dropdown-name"><c:out value="${displayName}" /></div>
                                        <c:if test="${not empty sessionScope.userEmail or not empty sessionScope.email}">
                                            <span class="user-dropdown-email"><c:out value="${not empty sessionScope.userEmail ? sessionScope.userEmail : sessionScope.email}" /></span>
                                        </c:if>
                                        <c:set var="uRoleName" value="${fn:toUpperCase(not empty sessionScope.user.role.roleName ? sessionScope.user.role.roleName : (not empty sessionScope.role ? sessionScope.role : ''))}" />
                                        <c:set var="uRoleId" value="${not empty sessionScope.roleId ? sessionScope.roleId : sessionScope.user.roleId}" />
                                        <c:set var="isUserAdmin" value="${uRoleName == 'ADMIN' || uRoleName == 'ROLE_ADMIN' || uRoleName == 'ADMINISTRATOR' || (empty uRoleName && (uRoleId == 1 || uRoleId == 5))}" />
                                        <c:set var="isUserHost" value="${uRoleName == 'HOST' || uRoleName == 'ROLE_HOST' || uRoleName == 'HOTEL_OWNER' || (empty uRoleName && uRoleId == 3)}" />
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

                                    <a href="${pageContext.request.contextPath}/notifications" class="user-dropdown-item" role="menuitem">
                                        <i class="fa fa-bell text-warning"></i> Thông báo của tôi
                                    </a>

                                    <a href="${pageContext.request.contextPath}/wishlist" class="user-dropdown-item" role="menuitem">
                                        <i class="fa fa-heart text-danger"></i> Danh sách yêu thích
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
                                        <a href="${pageContext.request.contextPath}/host/vouchers" class="user-dropdown-item" role="menuitem">
                                            <i class="fa fa-ticket"></i> Quản lý Voucher
                                        </a>
                                        <a href="${pageContext.request.contextPath}/host/reviews" class="user-dropdown-item" role="menuitem">
                                            <i class="fa fa-comments-o"></i> Quản lý Đánh giá
                                        </a>
                                    </c:if>
                                    <c:if test="${isUserAdmin}">
                                        <a href="${pageContext.request.contextPath}/admin/dashboard" class="user-dropdown-item" role="menuitem">
                                            <i class="fa fa-cogs"></i> Trang Quản Trị
                                        </a>
                                        <a href="${pageContext.request.contextPath}/admin/host-applications" class="user-dropdown-item" role="menuitem">
                                            <i class="fa fa-file-text-o"></i> Duyệt Đơn Host
                                        </a>
                                    </c:if>
                                    <%-- Shared content management shortcuts for both Admin and Host --%>
                                    <c:if test="${isUserAdmin || isUserHost}">
                                        <a href="${pageContext.request.contextPath}/admin/about/edit" class="user-dropdown-item" role="menuitem">
                                            <i class="fa fa-pencil-square-o text-warning"></i> Chỉnh Sửa About Us
                                        </a>
                                        <a href="${pageContext.request.contextPath}/admin/terms" class="user-dropdown-item" role="menuitem">
                                            <i class="fa fa-file-text-o text-info"></i> Quản Lý Điều Khoản
                                        </a>
                                        <a href="${pageContext.request.contextPath}/admin/faqs" class="user-dropdown-item" role="menuitem">
                                            <i class="fa fa-question-circle text-primary"></i> Quản Lý FAQ
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
                            <%-- Guest auth controls: inline buttons on >= 480px and compact login icon on narrow phones (full actions also in drawer). --%>
                            <div class="header-guest-auth">
                                <!-- Nút Đăng nhập & Đăng ký -->
                                <a class="auth-link" href="${pageContext.request.contextPath}/login">Đăng nhập</a>
                                <a class="auth-link auth-link-primary" href="${pageContext.request.contextPath}/register">Đăng ký</a>
                            </div>
                            <a class="header-guest-mobile-login" href="${pageContext.request.contextPath}/login" title="Đăng nhập" aria-label="Đăng nhập">
                                <i class="fa fa-user"></i>
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
                <%-- Keyboard-accessible drawer menu toggle button. --%>
                <div class="site-menu-toggle js-site-menu-toggle" role="button" tabindex="0"
                     aria-label="Menu điều hướng" aria-expanded="false" aria-controls="siteNavbarOverlay"
                     data-aos="fade" title="Menu điều hướng">
                    <span></span>
                    <span></span>
                    <span></span>
                </div>
                <!-- END menu-toggle -->
                <div class="site-navbar js-site-navbar" id="siteNavbarOverlay">
                    <!-- Lớp phủ làm tối và mờ nền khi mở menu -->
                    <div class="site-navbar-backdrop" onclick="closeSiteNavbar()" title="Nhấn để đóng menu"></div>
                    <!-- Thanh điều hướng dạng cột dọc một bên (Sidebar Drawer) -->
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
                                    <c:set var="displayName" value="${not empty sessionScope.displayName ? sessionScope.displayName : sessionScope.userName}" />
                                    <div class="drawer-user-card">
                                        <div class="drawer-user-avatar-wrap">
                                            <c:choose>
                                                <c:when test="${not empty navAvatarSrc}">
                                                    <img src="${navAvatarSrc}" alt="Avatar" class="drawer-user-avatar"
                                                         onerror="this.style.display='none'; var fb=document.getElementById('drawerAvatarFallback'); if(fb) fb.style.setProperty('display', 'inline-flex', 'important');">
                                                    <span id="drawerAvatarFallback" class="drawer-user-avatar-fallback" style="display:none !important;">
                                                        ${fn:toUpperCase(fn:substring(displayName, 0, 1))}
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="drawer-user-avatar-fallback">
                                                        ${fn:toUpperCase(fn:substring(displayName, 0, 1))}
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                            <span class="drawer-user-status-dot" title="Đang hoạt động"></span>
                                        </div>
                                        <div class="drawer-user-info">
                                            <h6 class="drawer-user-name"><c:out value="${displayName}" /></h6>
                                            <c:if test="${not empty sessionScope.userEmail or not empty sessionScope.email}">
                                                <span class="drawer-user-email"><c:out value="${not empty sessionScope.userEmail ? sessionScope.userEmail : sessionScope.email}" /></span>
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
                                    <li class="drawer-nav-item ${activePage == 'wishlist' ? 'active' : ''}">
                                        <a href="${pageContext.request.contextPath}/wishlist" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                            <span class="drawer-nav-icon" style="background:#fff1f2; color:#f43f5e;"><i class="fa fa-heart"></i></span>
                                            <span class="drawer-nav-text">Danh Sách Yêu Thích</span>
                                            <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                        </a>
                                    </li>
                                    <li class="drawer-nav-item ${activePage == 'about' ? 'active' : ''}">
                                        <a href="${pageContext.request.contextPath}/about" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                            <span class="drawer-nav-icon icon-about"><i class="fa fa-info-circle"></i></span>
                                            <span class="drawer-nav-text">Về Chúng Tôi</span>
                                            <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                        </a>
                                    </li>
                                    <li class="drawer-nav-item ${activePage == 'terms' ? 'active' : ''}">
                                        <a href="${pageContext.request.contextPath}/terms" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                            <span class="drawer-nav-icon icon-terms"><i class="fa fa-file-text-o"></i></span>
                                            <span class="drawer-nav-text">Điều Khoản & Chính Sách</span>
                                            <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                        </a>
                                    </li>
                                    <li class="drawer-nav-item ${activePage == 'faq' ? 'active' : ''}">
                                        <a href="${pageContext.request.contextPath}/faq" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                            <span class="drawer-nav-icon icon-faq"><i class="fa fa-question-circle"></i></span>
                                            <span class="drawer-nav-text">Hỏi Đáp (FAQ)</span>
                                            <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                        </a>
                                    </li>
                                    <li class="drawer-nav-item ${activePage == 'contact' ? 'active' : ''}">
                                        <a href="${pageContext.request.contextPath}/contact" class="drawer-nav-link" onclick="closeSiteNavbar()">
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
                                            <li class="drawer-nav-item ${activePage == 'host-dashboard' ? 'active' : ''}">
                                                <a href="${pageContext.request.contextPath}/host/dashboard" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                                    <span class="drawer-nav-icon icon-dashboard"><i class="fa fa-dashboard"></i></span>
                                                    <span class="drawer-nav-text">Host Dashboard</span>
                                                    <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                                </a>
                                            </li>
                                            <li class="drawer-nav-item ${activePage == 'host-vouchers' ? 'active' : ''}">
                                                <a href="${pageContext.request.contextPath}/host/vouchers" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                                    <span class="drawer-nav-icon" style="background:#fef3c7; color:#d97706;"><i class="fa fa-ticket"></i></span>
                                                    <span class="drawer-nav-text">Quản Lý Voucher</span>
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
                                            <li class="drawer-nav-item">
                                                <a href="${pageContext.request.contextPath}/admin/host-applications" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                                    <span class="drawer-nav-icon icon-admin"><i class="fa fa-file-text-o"></i></span>
                                                    <span class="drawer-nav-text">Duyệt Đơn Host</span>
                                                    <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                                </a>
                                            </li>
                                        </c:if>
                                        <%-- Shared content management links in drawer for both Admin and Host --%>
                                        <c:if test="${isUserAdmin || isUserHost}">
                                            <li class="drawer-nav-item">
                                                <a href="${pageContext.request.contextPath}/admin/about/edit" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                                    <span class="drawer-nav-icon" style="background:#e0f2fe; color:#0284c7;"><i class="fa fa-pencil"></i></span>
                                                    <span class="drawer-nav-text">Chỉnh Sửa About Us</span>
                                                    <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                                </a>
                                            </li>
                                            <li class="drawer-nav-item">
                                                <a href="${pageContext.request.contextPath}/admin/terms" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                                    <span class="drawer-nav-icon" style="background:#ecfeff; color:#0891b2;"><i class="fa fa-file-text-o"></i></span>
                                                    <span class="drawer-nav-text">Quản Lý Điều Khoản</span>
                                                    <span class="drawer-nav-arrow"><i class="fa fa-angle-right"></i></span>
                                                </a>
                                            </li>
                                            <li class="drawer-nav-item">
                                                <a href="${pageContext.request.contextPath}/admin/faqs" class="drawer-nav-link" onclick="closeSiteNavbar()">
                                                    <span class="drawer-nav-icon" style="background:#eef2ff; color:#4f46e5;"><i class="fa fa-question-circle"></i></span>
                                                    <span class="drawer-nav-text">Quản Lý FAQ</span>
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

<!-- Modal Xác nhận Đăng xuất -->
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
                    <c:set var="displayName" value="${not empty sessionScope.displayName ? sessionScope.displayName : sessionScope.userName}" />
                    <c:if test="${not empty displayName}">
                        <strong><c:out value="${displayName}" /></strong>
                    </c:if>
                    không?
                </p>
                <div class="d-flex justify-content-center">
                    <button type="button" class="btn btn-stay px-4 py-2 rounded-pill font-weight-bold mr-3" data-dismiss="modal">
                        Ở lại
                    </button>
                    <form action="${pageContext.request.contextPath}/logout" method="post" class="m-0 d-inline">
                        <c:if test="${not empty sessionScope.logoutCsrfToken}">
                            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.logoutCsrfToken}' />">
                        </c:if>
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
    /**
     * Close the responsive side drawer and synchronize toggle accessibility attributes.
     */
    function closeSiteNavbar() {
        var toggleEl = document.querySelector('.site-menu-toggle');
        if (toggleEl) {
            toggleEl.setAttribute('aria-expanded', 'false');
        }
        if (typeof $ !== 'undefined') {
            $('.site-menu-toggle').removeClass('open');
            $('.js-site-navbar').fadeOut(280);
            $('body').removeClass('menu-open');
        } else {
            var nav = document.getElementById('siteNavbarOverlay');
            if (nav) {
                nav.style.display = 'none';
            }
            if (toggleEl) {
                toggleEl.classList.remove('open');
            }
            document.body.classList.remove('menu-open');
        }
    }

    // Close open overlays (drawer, user dropdown, notification dropdown) when pressing Escape.
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' || e.keyCode === 27) {
            closeSiteNavbar();
            var userDrop = document.getElementById('userDropdown');
            var userMenu = document.getElementById('userMenuContainer');
            var userBtn = document.getElementById('userMenuToggle');
            if (userDrop && userDrop.classList.contains('show')) {
                userDrop.classList.remove('show');
                if (userMenu) userMenu.classList.remove('open');
                if (userBtn) userBtn.setAttribute('aria-expanded', 'false');
            }
            var notifDrop = document.getElementById('notificationHeaderDropdown');
            var notifBtn = document.getElementById('headerNotificationToggle');
            if (notifDrop && notifDrop.classList.contains('show')) {
                notifDrop.classList.remove('show');
                if (notifBtn) notifBtn.setAttribute('aria-expanded', 'false');
            }
        }
    });

    document.addEventListener('DOMContentLoaded', function () {
        // Step 1: Dynamically track actual fixed header height & optional top admin toolbar offset
        // so hero content, non-hero pages, and mobile dropdowns adapt at every viewport and zoom level.
        var siteHeader = document.querySelector('.js-site-header');
        var adminBar = document.querySelector('.about-admin-bar');

        if (!document.querySelector('.site-hero')) {
            document.body.classList.add('no-hero-banner');
            if (siteHeader) {
                siteHeader.classList.add('header-solid', 'scrolled');
            }
        }

        function syncHeaderMetrics() {
            var root = document.documentElement;
            if (siteHeader) {
                var headerH = Math.ceil(siteHeader.getBoundingClientRect().height);
                if (headerH > 0) {
                    root.style.setProperty('--site-header-height', headerH + 'px');
                }
            }
            if (adminBar) {
                var barBottom = Math.max(0, Math.round(adminBar.getBoundingClientRect().bottom));
                root.style.setProperty('--admin-bar-offset', barBottom + 'px');
            } else {
                root.style.setProperty('--admin-bar-offset', '0px');
            }
        }

        syncHeaderMetrics();
        window.addEventListener('resize', syncHeaderMetrics, { passive: true });
        window.addEventListener('scroll', syncHeaderMetrics, { passive: true });
        if (typeof ResizeObserver !== 'undefined') {
            var headerObserver = new ResizeObserver(syncHeaderMetrics);
            if (siteHeader) headerObserver.observe(siteHeader);
            if (adminBar) headerObserver.observe(adminBar);
        }

        // Step 2: Wire User Account dropdown toggle, mutual exclusion with notifications, and outside-click close.
        var menuContainer = document.getElementById('userMenuContainer');
        var userToggle = document.getElementById('userMenuToggle');
        var userDropdown = document.getElementById('userDropdown');
        var notifToggle = document.getElementById('headerNotificationToggle');
        var notifDropdown = document.getElementById('notificationHeaderDropdown');
        var notifBadge = document.getElementById('navbarNotificationBadge');
        var notifList = document.getElementById('headerNotificationList');
        var markAllBtn = document.getElementById('btnHeaderMarkAllRead');

        function closeUserDropdown() {
            if (userDropdown) userDropdown.classList.remove('show');
            if (menuContainer) menuContainer.classList.remove('open');
            if (userToggle) userToggle.setAttribute('aria-expanded', 'false');
        }

        function closeNotifDropdown() {
            if (notifDropdown) notifDropdown.classList.remove('show');
            if (notifToggle) notifToggle.setAttribute('aria-expanded', 'false');
        }

        if (userToggle && userDropdown && menuContainer) {
            userToggle.addEventListener('click', function (e) {
                e.stopPropagation();
                closeNotifDropdown();
                var isOpen = userDropdown.classList.toggle('show');
                menuContainer.classList.toggle('open', isOpen);
                userToggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
            });

            document.addEventListener('click', function (e) {
                if (!menuContainer.contains(e.target)) {
                    closeUserDropdown();
                }
            });
        }

        // Step 3: Auto-dismiss logout confirmation toast after 4.5 seconds.
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

        // ================= XỬ LÝ NÚT CHUÔNG THÔNG BÁO (NOTIFICATION) =================
        if (notifToggle && notifDropdown) {
            // 1. Tự động lấy số lượng chưa đọc khi tải trang
            function fetchUnreadBadge() {
                fetch('${pageContext.request.contextPath}/api/notifications/count')
                        .then(function (res) {
                            return res.json();
                        })
                        .then(function (data) {
                            if (data.success && data.loggedIn) {
                                if (data.unreadCount > 0) {
                                    notifBadge.textContent = data.unreadCount > 99 ? '99+' : data.unreadCount;
                                    notifBadge.style.display = 'inline-block';
                                } else {
                                    notifBadge.style.display = 'none';
                                }
                            }
                        })
                        .catch(function (err) {
                            console.warn('Lỗi lấy unread count:', err);
                        });
            }

            // 2. Tải 5 thông báo mới nhất khi mở dropdown
            function loadRecentNotifs() {
                notifList.innerHTML = '<div class="text-center py-4 text-muted small"><i class="fa fa-spinner fa-spin mr-1"></i> Đang tải...</div>';
                fetch('${pageContext.request.contextPath}/api/notifications/recent')
                        .then(function (res) {
                            return res.json();
                        })
                        .then(function (data) {
                            if (!data.success || !data.notifications || data.notifications.length === 0) {
                                notifList.innerHTML = '<div class="text-center py-4 text-muted small"><i class="fa fa-bell-slash-o d-block mb-2" style="font-size:1.8rem;"></i>Không có thông báo mới</div>';
                                return;
                            }
                            if (data.unreadCount > 0) {
                                notifBadge.textContent = data.unreadCount;
                                notifBadge.style.display = 'inline-block';
                            } else {
                                notifBadge.style.display = 'none';
                            }

                            var html = '';
                            data.notifications.forEach(function (item) {
                                var unreadStyle = !item.isRead ? 'background: #f4f8ff; font-weight: 500;' : 'background: #fff;';
                                html += '<div class="p-3 border-bottom dropdown-notif-item" style="cursor:pointer; transition:background 0.2s; ' + unreadStyle + '" ' +
                                        'onclick="onDropdownNotifClick(' + item.id + ', \'' + (item.targetUrl || '') + '\', ' + item.isRead + ');">' +
                                        '<div class="d-flex align-items-start">' +
                                        '<i class="' + item.iconClass + ' mr-2 mt-1" style="font-size:1.1rem;"></i>' +
                                        '<div class="flex-grow-1" style="min-width:0; overflow-wrap:break-word;">' +
                                        '<div class="text-dark small font-weight-bold mb-1">' + item.title + '</div>' +
                                        '<div class="text-muted" style="font-size: 0.78rem; line-height: 1.35; max-height: 2.7em; overflow: hidden;">' + item.message + '</div>' +
                                        '<div class="text-muted mt-1" style="font-size: 0.72rem;"><i class="fa fa-clock-o mr-1"></i>' + item.timeAgo + '</div>' +
                                        '</div>' +
                                        (!item.isRead ? '<span class="ml-2 flex-shrink-0" style="width:8px;height:8px;background:#0d6efd;border-radius:50%;display:inline-block;"></span>' : '') +
                                        '</div>' +
                                        '</div>';
                            });
                            notifList.innerHTML = html;
                        })
                        .catch(function (err) {
                            notifList.innerHTML = '<div class="text-center py-3 text-danger small">Lỗi tải thông báo</div>';
                        });
            }

            // 3. Sự kiện bấm vào nút chuông để bật/tắt Dropdown
            notifToggle.addEventListener('click', function (e) {
                e.stopPropagation();
                closeUserDropdown();
                var isOpening = !notifDropdown.classList.contains('show');
                notifDropdown.classList.toggle('show', isOpening);
                notifToggle.setAttribute('aria-expanded', isOpening ? 'true' : 'false');
                if (isOpening) {
                    loadRecentNotifs();
                }
            });

            // 4. Bấm ra ngoài màn hình thì tự đóng dropdown
            document.addEventListener('click', function (e) {
                var wrapper = document.getElementById('headerNotificationWrapper');
                if (wrapper && !wrapper.contains(e.target)) {
                    closeNotifDropdown();
                }
            });

            // 5. Bấm nút "Đánh dấu đã đọc" trong dropdown
            if (markAllBtn) {
                markAllBtn.addEventListener('click', function (e) {
                    e.stopPropagation();
                    fetch('${pageContext.request.contextPath}/api/notifications/mark-all-read', {
                        method: 'POST',
                        headers: {'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest'},
                        body: 'ajax=true'
                    }).then(function () {
                        notifBadge.style.display = 'none';
                        loadRecentNotifs();
                    });
                });
            }

            // 6. Hàm click vào 1 thông báo
            window.onDropdownNotifClick = function (id, targetUrl, isRead) {
                if (!isRead) {
                    fetch('${pageContext.request.contextPath}/api/notifications/mark-read', {
                        method: 'POST',
                        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                        body: 'id=' + encodeURIComponent(id)
                    }).then(function () {
                        fetchUnreadBadge();
                    });
                }
                if (targetUrl && targetUrl !== '') {
                    var fullUrl = targetUrl;
                    if (!fullUrl.startsWith('http') && !fullUrl.startsWith('${pageContext.request.contextPath}')) {
                        fullUrl = '${pageContext.request.contextPath}' + (fullUrl.startsWith('/') ? '' : '/') + fullUrl;
                    }
                    window.location.href = fullUrl;
                }
            };

            // Chạy kiểm tra unread badge ngay khi tải trang
            fetchUnreadBadge();
        }
    });
</script>
