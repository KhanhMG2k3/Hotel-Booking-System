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
    <c:set var="uRoleId" value="${not empty sessionScope.roleId ? sessionScope.roleId : sessionScope.user.roleId}" />
    <c:set var="uRoleName" value="${not empty sessionScope.user.role.roleName ? sessionScope.user.role.roleName : (not empty sessionScope.role ? sessionScope.role : '')}" />
    <c:set var="isUserAdmin" value="${uRoleId == 1 || uRoleId == 5 || uRoleName == 'ADMIN' || uRoleName == 'ROLE_ADMIN'}" />
    <c:set var="isUserHost" value="${uRoleId == 3 || fn:contains(uRoleName, 'HOST') || uRoleName == 'HOTEL_OWNER'}" />
    <c:set var="canEditAbout" value="${isUserAdmin || isUserHost}" />

    <%-- Step 1: Render responsive Admin/Host edit toolbar that wraps or stacks cleanly on narrow screens. --%>
    <c:if test="${canEditAbout}">
      <div class="bg-dark text-white shadow-sm about-admin-bar">
        <span class="small about-admin-bar-text">
          <i class="fa fa-pencil-square-o text-warning mr-1"></i> Chế độ chỉnh sửa: Bạn đang đăng nhập với quyền 
          <strong><c:choose><c:when test="${isUserAdmin}">Quản trị viên (Admin)</c:when><c:otherwise>Chủ Homestay (Host)</c:otherwise></c:choose></strong>.
        </span>
        <a href="${pageContext.request.contextPath}/admin/about/edit" class="btn btn-sm btn-warning text-dark font-weight-bold py-1 px-3 shadow about-admin-bar-btn">
          <i class="fa fa-pencil mr-1"></i> Chỉnh Sửa Nội Dung About Us
        </a>
      </div>
    </c:if>
    <%-- Step 2: Inner-page hero banner with adaptive height and header-aware top spacing. --%>
    <!-- BANNER HERO -->
    <section class="site-hero inner-page overlay hero-about" data-stellar-background-ratio="0.5">
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

    <%-- Step 3: Homestay story section — two columns on large screens, single logical reading-order column on mobile/tablet. --%>
    <!-- PHẦN 1: CÂU CHUYỆN HOMESTAY -->
    <section class="py-5 bg-light" id="about-story">
      <div class="container">
        <div class="row align-items-center justify-content-between">
          <div class="col-12 col-lg-5 mb-5 mb-lg-0" data-aos="fade-up">
            <!-- 1. TIÊU ĐỀ LỜI CHÀO ĐỘNG -->
            <h2 class="heading mb-4 font-weight-bold">
              <c:out value="${not empty about.title ? about.title : 'Chào mừng đến với Sogo Homestay'}"/>
            </h2>

            <!-- 2. ĐOẠN VĂN GIỚI THIỆU ĐỘNG -->
            <div class="mb-4 text-secondary leading-relaxed about-intro-content">
              <c:out value="${about.introContent}"/>
            </div>

            <!-- 3. NÚT BẤM VỚI TÊN ĐỘNG -->
            <div class="about-cta-group">
              <a href="${pageContext.request.contextPath}/rooms" class="btn btn-primary text-white py-2 px-4">
                <c:out value="${not empty about.btnExploreText ? about.btnExploreText : 'Khám Phá Phòng'}"/>
              </a>
              <span class="about-cta-or">hoặc</span>
              <a href="${pageContext.request.contextPath}/reservation" class="text-uppercase letter-spacing-1 font-weight-bold text-primary about-cta-link">
                <c:out value="${not empty about.btnBookText ? about.btnBookText : 'Đặt Phòng Ngay'}"/>
              </a>
            </div>
          </div>
          <div class="col-12 col-lg-6 ml-lg-auto position-relative about-story-media" data-aos="fade-up">
            <figure class="img-absolute">
              <img src="${pageContext.request.contextPath}/assets/images/food-1.jpg" alt="Ẩm thực homestay" class="img-fluid rounded shadow">
            </figure>
            <img src="${pageContext.request.contextPath}/assets/images/img_1.jpg" alt="Không gian Sogo Homestay" class="img-fluid rounded shadow-sm">
          </div>
        </div>
      </div>
    </section>

    <%-- Step 4: Dynamic commitment cards with uniform circular icon sizing defined in SCSS. --%>
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
            <div class="col-12 col-md-6 col-lg-4 text-center mb-4" data-aos="fade-up" data-aos-delay="${(loop.index + 1) * 100}">
              <div class="p-4 border rounded bg-white shadow-sm h-100 commit-card-box">
                <!-- Khung tròn chuẩn hóa kích thước icon -->
                <div class="commit-card-icon-wrap">
                  <i class="${not empty card.icon ? card.icon : 'fa fa-home'}"></i>
                </div>
                <h4 class="h5 font-weight-bold mb-3"><c:out value="${card.title}"/></h4>
                <p class="text-muted small mb-0 commit-card-desc"><c:out value="${card.description}"/></p>
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

            <%-- Step 5: Responsive team member card with aspect-ratio portrait frame and text wrapping. --%>
            <div class="col-12 col-sm-6 col-lg-4 mb-4" data-aos="fade-up" data-aos-delay="${(mLoop.index + 1) * 100}">
              <div class="card border-0 shadow-sm rounded overflow-hidden h-100 text-center bg-white about-team-card">
                <div class="about-team-avatar-wrap">
                  <img src="${memberAvatar}" 
                       alt="<c:out value='${member.fullName}'/>" 
                       class="about-team-avatar"
                       onerror="this.src='${pageContext.request.contextPath}${defaultImg}';">
                </div>
                <div class="card-body py-4 px-3">
                  <h4 class="h5 font-weight-bold mb-1"><c:out value="${member.fullName}"/></h4>
                  <p class="text-primary font-weight-bold mb-0"><c:out value="${memberRoleText}"/></p>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>
      </div>
    </section>

<jsp:include page="common/footer.jsp" />