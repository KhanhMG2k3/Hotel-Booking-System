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
                            <div class="user-menu" id="userMenuContainer">
                                <button class="user-menu-toggle" id="userMenuToggle" type="button" aria-haspopup="true" aria-expanded="false" title="Tài khoản của tôi">
                                    <c:choose>
                                        <c:when test="${not empty sessionScope.avatar}">
                                            <img src="${sessionScope.avatar}" alt="Avatar" class="user-avatar-img">
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
                                        <c:choose>
                                            <c:when test="${sessionScope.roleId == 1}">
                                                <span class="user-role-badge"><i class="fa fa-shield mr-1"></i> Quản trị viên</span>
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

                <div class="site-navbar js-site-navbar">
                    <nav role="navigation">
                        <div class="container">
                            <div class="row full-height align-items-center">
                                <div class="col-md-6 mx-auto">
                                    <ul class="list-unstyled menu">
                                        <li class="${activePage == 'home' ? 'active' : ''}">
                                            <a href="${pageContext.request.contextPath}/home">Trang Chủ (Giới Thiệu)</a>
                                        </li>
                                        <li class="${activePage == 'rooms' ? 'active' : ''}">
                                            <a href="${pageContext.request.contextPath}/rooms">Danh Sách & Đặt Phòng</a>
                                        </li>
                                        <li class="${activePage == 'reservation' ? 'active' : ''}">
                                            <a href="${pageContext.request.contextPath}/reservation">Đặt Phòng Nhanh</a>
                                        </li>
                                        <li>
                                            <a href="${pageContext.request.contextPath}/assets/about.html">Về Chúng Tôi</a>
                                        </li>
                                        <li>
                                            <a href="${pageContext.request.contextPath}/assets/contact.html">Liên Hệ</a>
                                        </li>
                                        <c:choose>
                                            <c:when test="${not empty sessionScope.userId}">
                                                <li>
                                                    <a href="${pageContext.request.contextPath}/profile">
                                                        <i class="fa fa-user-circle-o mr-2"></i> Hồ sơ cá nhân
                                                    </a>
                                                </li>
                                                <li>
                                                    <a href="${pageContext.request.contextPath}/my-bookings">
                                                        <i class="fa fa-calendar-check-o mr-2"></i> Lịch sử đặt phòng
                                                    </a>
                                                </li>
                                                <li>
                                                    <a href="javascript:void(0)" class="text-danger font-weight-bold" data-toggle="modal" data-target="#logoutModal" onclick="closeSiteNavbar()">
                                                        <i class="fa fa-sign-out mr-2"></i> Đăng xuất
                                                    </a>
                                                </li>
                                            </c:when>
                                            <c:otherwise>
                                                <li><a href="${pageContext.request.contextPath}/login"><i class="fa fa-sign-in mr-2"></i> Đăng nhập</a></li>
                                                <li><a href="${pageContext.request.contextPath}/register"><i class="fa fa-user-plus mr-2"></i> Đăng ký</a></li>
                                            </c:otherwise>
                                        </c:choose>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </nav>
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
            $('.js-site-navbar').fadeOut(200);
            $('body').removeClass('menu-open');
        }
    }

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
                    $(toast).fadeOut(400, function () { $(this).remove(); });
                } else {
                    toast.style.display = 'none';
                }
            }, 4500);
        }
    });
</script>