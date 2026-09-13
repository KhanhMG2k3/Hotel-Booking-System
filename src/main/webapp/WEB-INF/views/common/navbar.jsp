<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

    <header class="site-header js-site-header">
      <div class="container-fluid">
        <div class="row align-items-center">
          <div class="col-6 col-lg-4 site-logo" data-aos="fade">
            <a href="${pageContext.request.contextPath}/home">Sogo Homestay</a>
          </div>
          <div class="col-6 col-lg-8">

            <div class="site-menu-toggle js-site-menu-toggle" data-aos="fade">
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
