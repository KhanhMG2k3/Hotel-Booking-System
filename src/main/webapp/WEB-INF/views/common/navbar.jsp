<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%-- Shared navigation: account actions, role-specific links, and primary site menu. --%>
    <header class="site-header js-site-header">
      <div class="container-fluid">
        <div class="row align-items-center">
          <div class="col-5 col-lg-4 site-logo" data-aos="fade">
            <a href="${pageContext.request.contextPath}/">Sogo Homestay</a>
          </div>
          <div class="col-7 col-lg-8 site-header-nav-column">
            <div class="site-header-actions">
              <c:if test="${sessionScope.role == 'CUSTOMER'}">
                <a class="site-partner-cta" href="${pageContext.request.contextPath}/become-host">
                  Become our partner
                </a>
              </c:if>
              <div class="site-account-actions">
              <c:choose>
                <c:when test="${not empty sessionScope.userId}">
                  <details class="site-account-menu">
                    <summary aria-label="Account menu">
                      <c:choose>
                        <c:when test="${not empty sessionScope.avatarUrl}">
                          <img class="site-account-avatar"
                               src="<c:out value='${sessionScope.avatarUrl}' />"
                               alt="">
                        </c:when>
                        <c:otherwise>
                          <span class="site-account-avatar site-account-avatar-initial">
                            <c:choose>
                              <c:when test="${not empty sessionScope.displayName}">
                                <c:out value="${fn:toUpperCase(fn:substring(sessionScope.displayName, 0, 1))}" />
                              </c:when>
                              <c:otherwise>
                                <c:out value="${fn:toUpperCase(fn:substring(sessionScope.username, 0, 1))}" />
                              </c:otherwise>
                            </c:choose>
                          </span>
                        </c:otherwise>
                      </c:choose>
                      <span class="site-account-name">
                        <c:choose>
                          <c:when test="${not empty sessionScope.displayName}">
                            <c:out value="${sessionScope.displayName}" />
                          </c:when>
                          <c:otherwise>
                            <c:out value="${sessionScope.username}" />
                          </c:otherwise>
                        </c:choose>
                      </span>
                      <span class="site-account-chevron" aria-hidden="true"></span>
                    </summary>
                    <div class="site-account-dropdown">
                      <a href="${pageContext.request.contextPath}/profile">My Profile</a>
                      <c:if test="${sessionScope.role == 'HOST'}">
                        <a href="${pageContext.request.contextPath}/host/dashboard">Host Dashboard</a>
                      </c:if>
                      <c:if test="${sessionScope.role == 'CUSTOMER'}">
                        <a href="${pageContext.request.contextPath}/become-host">Become our partner</a>
                      </c:if>
                      <c:if test="${sessionScope.role == 'ADMIN'}">
                        <a href="${pageContext.request.contextPath}/admin/host-applications">Host Applications</a>
                      </c:if>
                      <form action="${pageContext.request.contextPath}/logout" method="post">
                        <input type="hidden" name="csrfToken"
                               value="<c:out value='${sessionScope.logoutCsrfToken}' />">
                        <button type="submit">Sign out</button>
                      </form>
                    </div>
                  </details>
                </c:when>
                <c:otherwise>
                  <a class="site-account-link" href="${pageContext.request.contextPath}/login">Sign in</a>
                  <a class="site-account-link site-account-create"
                     href="${pageContext.request.contextPath}/register">Create account</a>
                </c:otherwise>
              </c:choose>
              </div>
              <button class="site-menu-toggle js-site-menu-toggle" data-aos="fade"
                      type="button" aria-label="Open website navigation"
                      aria-controls="site-navigation" aria-expanded="false">
                <span></span>
                <span></span>
                <span></span>
              </button>
            </div>

            <%-- End menu toggle controls. --%>

            <div id="site-navigation" class="site-navbar js-site-navbar" aria-hidden="true">
              <nav role="navigation">
                <div class="container">
                  <div class="row full-height align-items-center">
                    <div class="col-md-6 mx-auto">
                      <ul class="list-unstyled menu">
                        <li class="${activePage == 'home' ? 'active' : ''}">
                          <a href="${pageContext.request.contextPath}/">Trang Chủ (Giới Thiệu)</a>
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
    <%-- End shared site header and navigation. --%>
