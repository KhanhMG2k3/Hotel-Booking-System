<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="uRoleName" value="${not empty sessionScope.user.role.roleName ? sessionScope.user.role.roleName : (not empty sessionScope.role ? sessionScope.role : '')}" />
<c:set var="uRoleId" value="${sessionScope.roleId}" />
<c:set var="isUserAdmin" value="${uRoleId == 1 || uRoleId == 5 || uRoleName == 'ADMIN' || uRoleName == 'ROLE_ADMIN' || not empty sessionScope.userId}" />

<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="${pageTitle != null ? pageTitle : 'Điều Khoản & Chính Sách | Sogo Homestay'}" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

    <!-- BANNER HERO -->
    <section class="site-hero inner-page overlay" style="background-image: url(${pageContext.request.contextPath}/assets/images/hero_4.jpg)" data-stellar-background-ratio="0.5">
      <div class="container">
        <div class="row site-hero-inner justify-content-center align-items-center">
          <div class="col-md-10 text-center" data-aos="fade">
            <h1 class="heading mb-3">Điều Khoản & Quy Định</h1>
            <ul class="custom-breadcrumbs mb-4">
              <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
              <li>&bullet;</li>
              <li>Quy Định Dịch Vụ</li>
            </ul>
          </div>
        </div>
      </div>
      <a class="mouse smoothscroll" href="#terms-content">
        <div class="mouse-icon"><span class="mouse-wheel"></span></div>
      </a>
    </section>

    <!-- NỘI DUNG ĐIỀU KHOẢN -->
    <section class="section bg-light" id="terms-content">
      <div class="container">
        <div class="row">
          
          <!-- SIDEBAR MỤC LỤC ĐIỀU HƯỚNG NHANH -->
          <div class="col-lg-4 mb-5">
            <div class="bg-white p-4 rounded shadow-sm border" style="position: sticky; top: 90px;">
              <h4 class="font-weight-bold mb-3 pb-2 border-bottom text-primary">Mục Lục Điều Khoản</h4>
              <ul class="nav flex-column terms-nav">
                <c:forEach items="${sections}" var="sec" varStatus="loop">
                  <li class="nav-item mb-2">
                    <a class="nav-link text-dark py-1 px-2 font-weight-bold" href="#section-${loop.count}">
                      <span class="fa fa-angle-right mr-2 text-primary"></span> ${loop.count}. ${sec.contentTitle}
                    </a>
                  </li>
                </c:forEach>
              </ul>

              <!-- NÚT QUẢN LÝ DÀNH CHO ADMIN -->
              <c:if test="${isUserAdmin}">
                <div class="mt-4 p-3 bg-light rounded text-center border border-warning" style="background-color: #fffdf5 !important;">
                  <span class="badge badge-warning text-dark font-weight-bold mb-2">Quyền Quản Trị Viên</span>
                  <a href="${pageContext.request.contextPath}/admin/terms" class="btn btn-sm btn-warning btn-block font-weight-bold text-dark shadow-sm">
                    <i class="fa fa-pencil-square-o mr-1"></i> Quản Lý Điều Khoản (CRUD)
                  </a>
                </div>
              </c:if>

              <div class="mt-3 p-3 bg-light rounded text-center">
                <small class="text-muted d-block mb-2">Bạn có thắc mắc khác?</small>
                <a href="${pageContext.request.contextPath}/reservation" class="btn btn-sm btn-outline-primary btn-block">Liên Hệ Hỗ Trợ</a>
              </div>
            </div>
          </div>

          <!-- NỘI DUNG CHI TIẾT -->
          <div class="col-lg-8">
            <div class="bg-white p-4 p-md-5 rounded shadow-sm border">
              
              <div class="mb-4 pb-3 border-bottom d-flex justify-content-between align-items-center flex-wrap">
                <div>
                  <h2 class="h3 font-weight-bold text-primary mb-2">${setting.mainTitle}</h2>
                  <small class="text-muted">
                    <span class="fa fa-clock-o mr-1"></span> Cập nhật lần cuối: ${setting.lastUpdated}
                  </small>
                </div>
                <c:if test="${isUserAdmin}">
                  <a href="${pageContext.request.contextPath}/admin/terms" class="btn btn-outline-warning text-dark font-weight-bold mt-2 mt-md-0 shadow-sm" style="border-width: 2px;">
                    <i class="fa fa-pencil mr-1 text-warning"></i> Chỉnh Sửa Điều Khoản
                  </a>
                </c:if>
              </div>

              <!-- HIỂN THỊ CÁC MỤC -->
              <!-- HIỂN THỊ CÁC MỤC -->
              <c:forEach items="${sections}" var="sec" varStatus="loop">
                <div id="section-${loop.count}" class="mb-5">
                  <h4 class="font-weight-bold text-dark mb-3">${loop.count}. ${sec.contentTitle}</h4>

                  <!-- VÙNG RENDER TẤT CẢ CÁC KHỐI NỘI DUNG THEO THỨ TỰ -->
                  <div id="blocks-render-${loop.count}"></div>

                  <!-- Lưu trữ JSON dữ liệu an toàn để JS hiển thị -->
                  <script type="application/json" id="data-sec-${loop.count}"><c:out value="${sec.contentText}" escapeXml="false"/></script>

                  <script>
                    (function() {
                      var raw = document.getElementById("data-sec-${loop.count}").textContent.trim();
                      var container = document.getElementById("blocks-render-${loop.count}");
                      
                      // Nếu là danh sách khối JSON (dạng mới)
                      if (raw.startsWith('[')) {
                        try {
                          var blocks = JSON.parse(raw);
                          blocks.forEach(function(b) {
                            if (b.type === 'text') {
                              var p = document.createElement('div');
                              p.className = 'term-body mb-3';
                              p.style = 'white-space: pre-line; line-height: 1.8; color: #333;';
                              p.innerText = b.text;
                              container.appendChild(p);
                            } else if (b.type === 'callout') {
                              var alertDiv = document.createElement('div');
                              alertDiv.className = b.calloutType === 'info' ? 'alert alert-info mt-3' : 'alert alert-secondary mt-3';
                              alertDiv.innerHTML = (b.calloutType === 'info' ? '<span class="fa fa-info-circle mr-2"></span> ' : '') + b.text;
                              container.appendChild(alertDiv);
                            } else if (b.type === 'table') {
                              var tblWrapper = document.createElement('div');
                              tblWrapper.className = 'table-responsive my-3';
                              var titleHtml = b.title ? '<h6 class="font-weight-bold text-secondary mb-2">' + b.title + '</h6>' : '';
                              var ths = b.headers.map(function(h) { return '<th>' + h + '</th>'; }).join('');
                              var trs = b.rows.map(function(r) {
                                return '<tr>' + r.map(function(c, cIdx) {
                                  var colorClass = '';
                                  if (cIdx === 1) {
                                    if (c.indexOf('100%') !== -1) colorClass = 'class="text-success font-weight-bold"';
                                    else if (c.indexOf('50%') !== -1) colorClass = 'class="text-warning font-weight-bold"';
                                    else if (c.indexOf('Không') !== -1) colorClass = 'class="text-danger font-weight-bold"';
                                  }
                                  return '<td ' + colorClass + '>' + c + '</td>';
                                }).join('') + '</tr>';
                              }).join('');
                              tblWrapper.innerHTML = titleHtml + '<table class="table table-bordered table-sm"><thead class="thead-light"><tr>' + ths + '</tr></thead><tbody>' + trs + '</tbody></table>';
                              container.appendChild(tblWrapper);
                            }
                          });
                        } catch(e) {}
                      } else {
                        // Tương thích nếu là chuỗi văn bản cũ
                        var p = document.createElement('div');
                        p.className = 'term-body mb-3';
                        p.style = 'white-space: pre-line; line-height: 1.8; color: #333;';
                        p.innerText = raw;
                        container.appendChild(p);
                      }
                    })();
                  </script>
                </div>
              </c:forEach>

            </div>
          </div>

        </div>
      </div>
    </section>

<jsp:include page="common/footer.jsp" />