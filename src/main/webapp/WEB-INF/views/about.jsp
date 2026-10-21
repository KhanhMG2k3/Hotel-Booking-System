<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%
    // Đảm bảo trang khách hàng luôn luôn lấy dữ liệu mới nhất từ bảng about_us
    if (request.getAttribute("about") == null) {
        com.homestay.dao.AboutUsDAO fallbackAboutDao = new com.homestay.dao.AboutUsDAO();
        request.setAttribute("about", fallbackAboutDao.getAboutUs());
    }
%>

<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="${pageTitle}" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

    <!-- THANH CÔNG CỤ CHỈ HIỂN THỊ VỚI ADMIN VÀ HOST -->
    <c:set var="uRoleId" value="${sessionScope.roleId}" />
    <c:set var="uRoleName" value="${not empty sessionScope.user.role.roleName ? sessionScope.user.role.roleName : ''}" />
    <c:set var="canEditAbout" value="${uRoleId == 1 || uRoleId == 3 || uRoleId == 5 || uRoleName == 'ADMIN' || uRoleName == 'ROLE_ADMIN' || uRoleName == 'HOST' || uRoleName == 'ROLE_HOST'}" />

    <c:if test="${canEditAbout}">
      <div class="bg-dark text-white py-2 px-4 d-flex justify-content-between align-items-center shadow-sm" style="position: relative; z-index: 9999;">
        <span class="small">
          <i class="fa fa-shield text-warning mr-1"></i> Chế độ xem: Bạn đang đăng nhập với quyền <strong>Quản trị viên / Host</strong>.
        </span>
        <a href="${pageContext.request.contextPath}/admin/about/edit" class="btn btn-sm btn-warning text-dark font-weight-bold py-1 px-3 shadow">
          <i class="fa fa-pencil mr-1"></i> Chỉnh Sửa Nội Dung About Us
        </a>
      </div>
    </c:if>

    <!-- BANNER HERO -->
    <section class="site-hero inner-page overlay" style="background-image: url(${pageContext.request.contextPath}/assets/images/hero_4.jpg)" data-stellar-background-ratio="0.5">
      <div class="container">
        <div class="row site-hero-inner justify-content-center align-items-center">
          <div class="col-md-10 text-center" data-aos="fade">
            <h1 class="heading mb-3">Về Chúng Tôi</h1>
            <ul class="custom-breadcrumbs mb-4">
              <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
              <li>&bullet;</li>
              <li>Giới Thiệu</li>
            </ul>
          </div>
        </div>
      </div>
      <a class="mouse smoothscroll" href="#about-story">
        <div class="mouse-icon">
          <span class="mouse-wheel"></span>
        </div>
      </a>
    </section>

    <!-- PHẦN 1: CÂU CHUYỆN HOMESTAY -->
    <section class="py-5 bg-light" id="about-story">
      <div class="container">
        <div class="row align-items-center">
          <div class="col-md-12 col-lg-7 ml-auto order-lg-2 position-relative mb-5" data-aos="fade-up">
            <figure class="img-absolute">
              <img src="${pageContext.request.contextPath}/assets/images/food-1.jpg" alt="Ẩm thực homestay" class="img-fluid rounded shadow">
            </figure>
            <img src="${pageContext.request.contextPath}/assets/images/img_1.jpg" alt="Không gian Sogo Homestay" class="img-fluid rounded shadow-sm">
          </div>
          <div class="col-md-12 col-lg-4 order-lg-1" data-aos="fade-up">
            <!-- 1. TIÊU ĐỀ LỜI CHÀO ĐỘNG -->
            <h2 class="heading mb-4 font-weight-bold">
              <c:out value="${not empty about.title ? about.title : 'Chào mừng đến với Sogo Homestay'}"/>
            </h2>

            <!-- 2. ĐOẠN VĂN GIỚI THIỆU ĐỘNG -->
            <div class="mb-4 text-secondary leading-relaxed" style="white-space: pre-line; line-height: 1.8;">
              <c:out value="${about.introContent}"/>
            </div>

            <!-- 3. NÚT BẤM VỚI TÊN ĐỘNG -->
            <p>
              <a href="${pageContext.request.contextPath}/rooms" class="btn btn-primary text-white py-2 px-4 mr-3">
                <c:out value="${not empty about.btnExploreText ? about.btnExploreText : 'Khám Phá Phòng'}"/>
              </a>
              <span class="mr-3 font-family-serif"><em>hoặc</em></span>
              <a href="${pageContext.request.contextPath}/reservation" class="text-uppercase letter-spacing-1 font-weight-bold text-primary">
                <c:out value="${not empty about.btnBookText ? about.btnBookText : 'Đặt Phòng Ngay'}"/>
              </a>
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- PHẦN 2: CAM KẾT CỦA CHÚNG TÔI (CÁC THẺ LÝ DO ĐỘNG) -->
    <section class="section">
      <div class="container">
        <div class="row justify-content-center text-center mb-5">
          <div class="col-md-8">
            <span class="text-primary font-weight-bold text-uppercase letter-spacing-1 d-block mb-2">Cam Kết Của Chúng Tôi</span>
            <h2 class="heading" data-aos="fade-up">
              <c:out value="${not empty about.commitTitle ? about.commitTitle : 'Tại Sao Khách Hàng Chọn Sogo?'}"/>
            </h2>
          </div>
        </div>
        <div class="row justify-content-center">
          <c:forEach var="card" items="${about.commitCards}" varStatus="loop">
            <div class="col-md-6 col-lg-3 text-center mb-4" data-aos="fade-up" data-aos-delay="${(loop.index + 1) * 100}">
              <div class="p-4 border rounded bg-white shadow-sm h-100">
                <span class="${not empty card.icon ? card.icon : 'ion-ios-home'} h1 text-primary mb-3 d-block"></span>
                <h4 class="h5 font-weight-bold mb-3"><c:out value="${card.title}"/></h4>
                <p class="text-muted small mb-0"><c:out value="${card.description}"/></p>
              </div>
            </div>
          </c:forEach>
        </div>
      </div>
    </section>

    <!-- PHẦN 3: ĐỘI NGŨ QUẢN LÝ & VẬN HÀNH (HIỂN THỊ AVATAR + TÊN + CHỨC VỤ TỪ BẢNG USERS, ĐÃ BỎ QUOTE) -->
    <section class="section bg-light">
      <div class="container">
        <div class="row justify-content-center text-center mb-5">
          <div class="col-md-7">
            <span class="text-primary font-weight-bold text-uppercase letter-spacing-1 d-block mb-2">Gặp Gỡ Đội Ngũ</span>
            <h2 class="heading" data-aos="fade-up">
              <c:out value="${not empty about.teamTitle ? about.teamTitle : 'Đội Ngũ Quản Lý & Vận Hành'}"/>
            </h2>
          </div>
        </div>
        <div class="row justify-content-center">
          <c:forEach var="member" items="${about.teamMembers}" varStatus="mLoop">
            <c:set var="defaultImg" value="${mLoop.index % 2 == 0 ? '/assets/images/person_3.jpg' : '/assets/images/person_1.jpg'}" />
            <c:set var="memberAvatar" value="${pageContext.request.contextPath}${defaultImg}" />
            <c:if test="${not empty member.avatarUrl}">
              <c:choose>
                <c:when test="${fn:startsWith(member.avatarUrl, 'http://') or fn:startsWith(member.avatarUrl, 'https://')}">
                  <c:set var="memberAvatar" value="${member.avatarUrl}" />
                </c:when>
                <c:when test="${fn:startsWith(member.avatarUrl, '/assets/')}">
                  <c:set var="memberAvatar" value="${pageContext.request.contextPath}${member.avatarUrl}" />
                </c:when>
                <c:when test="${fn:startsWith(member.avatarUrl, 'assets/')}">
                  <c:set var="memberAvatar" value="${pageContext.request.contextPath}/${member.avatarUrl}" />
                </c:when>
                <c:when test="${fn:startsWith(member.avatarUrl, '/')}">
                  <c:set var="memberAvatar" value="${pageContext.request.contextPath}/assets${member.avatarUrl}" />
                </c:when>
                <c:otherwise>
                  <c:set var="memberAvatar" value="${pageContext.request.contextPath}/assets/${member.avatarUrl}" />
                </c:otherwise>
              </c:choose>
            </c:if>
            <c:set var="memberRoleText" value="${not empty member.role.description ? member.role.description : (not empty member.role.roleName ? member.role.roleName : 'Quản Lý Homestay')}" />

            <div class="col-md-6 col-lg-4 mb-4" data-aos="fade-up" data-aos-delay="${(mLoop.index + 1) * 100}">
              <div class="card border-0 shadow-sm rounded overflow-hidden h-100 text-center bg-white">
                <div style="height: 360px; overflow: hidden; background: #222;">
                  <img src="${memberAvatar}" 
                       alt="<c:out value='${member.fullName}'/>" 
                       style="width: 100%; height: 100%; object-fit: cover;"
                       onerror="this.src='${pageContext.request.contextPath}${defaultImg}';">
                </div>
                <div class="card-body py-4 px-3">
                  <h4 class="font-weight-bold mb-1"><c:out value="${member.fullName}"/></h4>
                  <p class="text-primary font-weight-bold mb-0"><c:out value="${memberRoleText}"/></p>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>
      </div>
    </section>

<jsp:include page="common/footer.jsp" />