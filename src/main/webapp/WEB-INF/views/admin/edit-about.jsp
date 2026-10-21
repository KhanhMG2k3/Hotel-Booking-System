<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="../common/header.jsp">
  <jsp:param name="pageTitle" value="Quản Trị About Us - Sogo Homestay" />
</jsp:include>

<jsp:include page="../common/navbar.jsp" />

<section class="section bg-light py-5">
  <div class="container py-4">

    <!-- HEADER & ACTION -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 pb-3 border-bottom">
      <div>
        <h2 class="font-weight-bold text-dark mb-1">
          <i class="fa fa-pencil-square-o text-primary mr-2"></i>Chỉnh Sửa Trang "Về Chúng Tôi"
        </h2>
        <span class="text-muted">Quản trị toàn bộ thông tin giới thiệu, thẻ lý do cam kết và đội ngũ nhân sự</span>
      </div>
      <div class="mt-3 mt-md-0">
        <a href="${pageContext.request.contextPath}/about" target="_blank" class="btn btn-outline-primary font-weight-bold px-3 py-2">
          <i class="fa fa-external-link mr-1"></i> Xem Trang About Thực Tế
        </a>
      </div>
    </div>

    <!-- THÔNG BÁO THÀNH CÔNG / THẤT BẠI -->
    <c:if test="${param.success == 'true'}">
      <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
        <i class="fa fa-check-circle mr-2"></i><strong>Thành công!</strong> Dữ liệu đã được lưu vào bảng <code>about_us</code> và đồng bộ ra trang khách hàng.
        <button type="button" class="close" data-dismiss="alert">&times;</button>
      </div>
    </c:if>
    <c:if test="${param.error == 'failed'}">
      <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
        <i class="fa fa-times-circle mr-2"></i><strong>Lỗi:</strong> Không thể lưu vào cơ sở dữ liệu. Vui lòng kiểm tra lại!
        <button type="button" class="close" data-dismiss="alert">&times;</button>
      </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/admin/about/edit" method="post">
      
      <!-- KHỐI 1: LỜI CHÀO & CÂU CHUYỆN HOMESTAY -->
      <div class="card border-0 shadow-sm rounded mb-4">
        <div class="card-header bg-white font-weight-bold text-primary">
          <i class="fa fa-home mr-2"></i>1. Lời Chào, Đoạn Văn Giới Thiệu & Nút Bấm
        </div>
        <div class="card-body p-4">
          <div class="form-group mb-3">
            <label class="font-weight-bold text-dark">Tiêu Đề Lời Chào (Gộp 1 dòng):</label>
            <input type="text" name="title" class="form-control form-control-lg" 
                   value="<c:out value='${not empty about.title ? about.title : "Chào mừng đến với Sogo Homestay"}'/>" required>
          </div>

          <div class="form-group mb-3">
            <label class="font-weight-bold text-dark">Nội Dung Giới Thiệu (Hỗ trợ nhiều đoạn văn):</label>
            <textarea name="introContent" rows="6" class="form-control" required><c:out value="${about.introContent}"/></textarea>
            <small class="text-muted">Nhấn phím Enter xuống dòng để tách thành các đoạn văn riêng biệt.</small>
          </div>

          <div class="row">
            <div class="col-md-6 form-group mb-0">
              <label class="font-weight-bold text-dark">Tên Nút 1 (Nút vàng):</label>
              <input type="text" name="btnExploreText" class="form-control" 
                     value="<c:out value='${not empty about.btnExploreText ? about.btnExploreText : "Khám Phá Phòng"}'/>">
            </div>
            <div class="col-md-6 form-group mb-0">
              <label class="font-weight-bold text-dark">Tên Nút 2 (Nút text link):</label>
              <input type="text" name="btnBookText" class="form-control" 
                     value="<c:out value='${not empty about.btnBookText ? about.btnBookText : "Đặt Phòng Ngay"}'/>">
            </div>
          </div>
        </div>
      </div>

      <!-- KHỐI 2: CAM KẾT CỦA CHÚNG TÔI (DANH SÁCH THẺ ĐỘNG: THÊM / SỬA / XÓA) -->
      <div class="card border-0 shadow-sm rounded mb-4">
        <div class="card-header bg-white d-flex justify-content-between align-items-center">
          <span class="font-weight-bold text-primary">
            <i class="fa fa-shield mr-2"></i>2. Khối Cam Kết Của Chúng Tôi (Thẻ Lý Do Động)
          </span>
          <button type="button" class="btn btn-sm btn-primary font-weight-bold px-3 py-1" onclick="addCommitCard()">
            <i class="fa fa-plus mr-1"></i> Thêm Thẻ Lý Do
          </button>
        </div>
        <div class="card-body p-4">
          <div class="form-group mb-4">
            <label class="font-weight-bold text-dark">Tiêu Đề Khối Cam Kết:</label>
            <input type="text" name="commitTitle" class="form-control" 
                   value="<c:out value='${not empty about.commitTitle ? about.commitTitle : "Tại Sao Khách Hàng Chọn Sogo?"}'/>">
          </div>

          <label class="font-weight-bold text-dark d-block mb-3">Danh Sách Các Thẻ Lý Do:</label>
          <div class="row" id="commitCardsContainer">
            <c:forEach var="card" items="${about.commitCards}" varStatus="loop">
              <div class="col-md-6 mb-3 commit-card-item">
                <div class="p-3 border rounded bg-light position-relative h-100">
                  <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="badge badge-warning text-dark font-weight-bold px-2 py-1">
                      <i class="${card.icon} mr-1 preview-card-icon"></i> Thẻ Lý Do
                    </span>
                    <button type="button" class="btn btn-sm btn-outline-danger py-0 px-2" onclick="removeCommitCard(this)" title="Xóa thẻ này">
                      <i class="fa fa-trash mr-1"></i> Xóa
                    </button>
                  </div>

                  <div class="form-group mb-2">
                    <label class="small font-weight-bold mb-1">Chọn Icon:</label>
                    <select name="cardIcon" class="form-control form-control-sm" onchange="updateCardIconPreview(this)">
                      <option value="ion-ios-home" ${card.icon == 'ion-ios-home' ? 'selected' : ''}>🏠 Ngôi nhà (Không gian)</option>
                      <option value="ion-ios-location" ${card.icon == 'ion-ios-location' ? 'selected' : ''}>📍 Vị trí (Địa điểm)</option>
                      <option value="ion-ios-heart" ${card.icon == 'ion-ios-heart' ? 'selected' : ''}>❤️ Trái tim (Tận tâm)</option>
                      <option value="ion-ios-pricetag" ${card.icon == 'ion-ios-pricetag' ? 'selected' : ''}>🏷️ Bảng giá (Minh bạch)</option>
                      <option value="fa fa-star" ${card.icon == 'fa fa-star' ? 'selected' : ''}>⭐ Ngôi sao (Chất lượng)</option>
                      <option value="fa fa-shield" ${card.icon == 'fa fa-shield' ? 'selected' : ''}>🛡️ Khiên bảo vệ (An ninh)</option>
                      <option value="fa fa-wifi" ${card.icon == 'fa fa-wifi' ? 'selected' : ''}>📶 Wifi (Tiện nghi)</option>
                      <option value="fa fa-coffee" ${card.icon == 'fa fa-coffee' ? 'selected' : ''}>☕ Cafe & Ẩm thực</option>
                      <option value="fa fa-headphones" ${card.icon == 'fa fa-headphones' ? 'selected' : ''}>🎧 Hỗ trợ 24/7</option>
                      <option value="fa fa-leaf" ${card.icon == 'fa fa-leaf' ? 'selected' : ''}>🌿 Thiên nhiên xanh mát</option>
                    </select>
                  </div>

                  <div class="form-group mb-2">
                    <label class="small font-weight-bold mb-1">Tiêu đề phụ lý do:</label>
                    <input type="text" name="cardTitle" class="form-control form-control-sm" value="<c:out value='${card.title}'/>" required placeholder="Nhập tiêu đề lý do...">
                  </div>

                  <div class="form-group mb-0">
                    <label class="small font-weight-bold mb-1">Nội dung lý do:</label>
                    <textarea name="cardDesc" rows="2" class="form-control form-control-sm" required placeholder="Nhập mô tả chi tiết..."><c:out value="${card.description}"/></textarea>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>
        </div>
      </div>

      <!-- KHỐI 3: GẶP GỠ ĐỘI NGŨ (CHỌN TỪ BẢNG USERS - HIỂN THỊ AVATAR, TÊN, CHỨC VỤ) -->
      <div class="card border-0 shadow-sm rounded mb-4">
        <div class="card-header bg-white d-flex justify-content-between align-items-center">
          <span class="font-weight-bold text-primary">
            <i class="fa fa-users mr-2"></i>3. Khối Đội Ngũ Quản Lý & Vận Hành (Chọn Từ Bảng Users)
          </span>
          <button type="button" class="btn btn-sm btn-primary font-weight-bold px-3 py-1" onclick="addTeamMemberSlot()">
            <i class="fa fa-user-plus mr-1"></i> Thêm Nhân Sự
          </button>
        </div>
        <div class="card-body p-4">
          <div class="form-group mb-4">
            <label class="font-weight-bold text-dark">Tiêu Đề Khối Đội Ngũ:</label>
            <input type="text" name="teamTitle" class="form-control" 
                   value="<c:out value='${not empty about.teamTitle ? about.teamTitle : "Đội Ngũ Quản Lý & Vận Hành"}'/>">
          </div>

          <label class="font-weight-bold text-dark d-block mb-3">Chọn Nhân Sự Hiển Thị (Lấy từ bảng <code>users</code>):</label>
          <div class="row" id="teamMembersContainer">
            <c:forEach var="selectedMember" items="${about.teamMembers}" varStatus="mLoop">
              <div class="col-md-6 mb-3 team-member-slot">
                <div class="p-3 border rounded bg-light h-100">
                  <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="font-weight-bold text-secondary small">
                      <i class="fa fa-id-badge mr-1"></i> Vị trí nhân sự
                    </span>
                    <button type="button" class="btn btn-sm btn-outline-danger py-0 px-2" onclick="removeTeamMemberSlot(this)">
                      <i class="fa fa-trash mr-1"></i> Xóa
                    </button>
                  </div>

                  <div class="form-group mb-3">
                    <label class="small font-weight-bold mb-1">Chọn từ danh sách User:</label>
                    <select name="teamUserIds" class="form-control team-user-select" onchange="updateMemberPreview(this)">
                      <c:forEach var="u" items="${allUsers}">
                        <c:set var="uRoleText" value="${not empty u.role.description ? u.role.description : (not empty u.role.roleName ? u.role.roleName : 'Thành viên')}" />
                        <c:set var="uAvatar" value="${pageContext.request.contextPath}/assets/images/person_3.jpg" />
                        <c:if test="${not empty u.avatarUrl}">
                          <c:choose>
                            <c:when test="${fn:startsWith(u.avatarUrl, 'http://') or fn:startsWith(u.avatarUrl, 'https://')}">
                              <c:set var="uAvatar" value="${u.avatarUrl}" />
                            </c:when>
                            <c:when test="${fn:startsWith(u.avatarUrl, '/assets/')}">
                              <c:set var="uAvatar" value="${pageContext.request.contextPath}${u.avatarUrl}" />
                            </c:when>
                            <c:when test="${fn:startsWith(u.avatarUrl, 'assets/')}">
                              <c:set var="uAvatar" value="${pageContext.request.contextPath}/${u.avatarUrl}" />
                            </c:when>
                            <c:when test="${fn:startsWith(u.avatarUrl, '/')}">
                              <c:set var="uAvatar" value="${pageContext.request.contextPath}/assets${u.avatarUrl}" />
                            </c:when>
                            <c:otherwise>
                              <c:set var="uAvatar" value="${pageContext.request.contextPath}/assets/${u.avatarUrl}" />
                            </c:otherwise>
                          </c:choose>
                        </c:if>
                        <option value="${u.id}" 
                                data-name="<c:out value='${u.fullName}'/>"
                                data-role="<c:out value='${uRoleText}'/>"
                                data-avatar="<c:out value='${uAvatar}'/>"
                                ${u.id == selectedMember.id ? 'selected' : ''}>
                          <c:out value="${u.fullName}"/> — (<c:out value="${uRoleText}"/>)
                        </option>
                      </c:forEach>
                    </select>
                  </div>

                  <!-- KHUNG HIỂN THỊ XEM TRƯỚC ẢNH ĐẠI DIỆN + TÊN + CHỨC VỤ -->
                  <div class="d-flex align-items-center p-2 bg-white rounded border member-preview-box">
                    <img src="${pageContext.request.contextPath}/assets/images/person_3.jpg" 
                         alt="Avatar" class="rounded-circle mr-3 member-preview-img" 
                         style="width: 56px; height: 56px; object-fit: cover;"
                         onerror="this.src='${pageContext.request.contextPath}/assets/images/person_3.jpg';">
                    <div>
                      <h6 class="mb-0 font-weight-bold text-dark member-preview-name"></h6>
                      <small class="text-primary font-weight-bold member-preview-role"></small>
                    </div>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>
        </div>
      </div>

      <!-- NÚT LƯU CẬP NHẬT -->
      <div class="d-flex justify-content-between align-items-center pt-3 border-top">
        <a href="${pageContext.request.contextPath}/about" class="btn btn-secondary px-4 py-2">
          <i class="fa fa-arrow-left mr-1"></i> Quay Lại
        </a>
        <button type="submit" class="btn btn-warning text-dark font-weight-bold px-5 py-2 shadow">
          <i class="fa fa-floppy-o mr-2"></i> Lưu & Đồng Bộ Bảng About Us
        </button>
      </div>

    </form>
  </div>
</section>

<!-- TEMPLATE ẨN ĐỂ THÊM NHÂN SỰ MỚI -->
<div id="teamMemberTemplate" style="display: none;">
  <div class="col-md-6 mb-3 team-member-slot">
    <div class="p-3 border rounded bg-light h-100">
      <div class="d-flex justify-content-between align-items-center mb-2">
        <span class="font-weight-bold text-secondary small">
          <i class="fa fa-id-badge mr-1"></i> Vị trí nhân sự
        </span>
        <button type="button" class="btn btn-sm btn-outline-danger py-0 px-2" onclick="removeTeamMemberSlot(this)">
          <i class="fa fa-trash mr-1"></i> Xóa
        </button>
      </div>
      <div class="form-group mb-3">
        <label class="small font-weight-bold mb-1">Chọn từ danh sách User:</label>
        <select name="teamUserIds" class="form-control team-user-select" onchange="updateMemberPreview(this)">
          <c:forEach var="u" items="${allUsers}">
            <c:set var="uRoleText" value="${not empty u.role.description ? u.role.description : (not empty u.role.roleName ? u.role.roleName : 'Thành viên')}" />
            <c:set var="uAvatar" value="${pageContext.request.contextPath}/assets/images/person_3.jpg" />
            <c:if test="${not empty u.avatarUrl}">
              <c:choose>
                <c:when test="${fn:startsWith(u.avatarUrl, 'http://') or fn:startsWith(u.avatarUrl, 'https://')}">
                  <c:set var="uAvatar" value="${u.avatarUrl}" />
                </c:when>
                <c:when test="${fn:startsWith(u.avatarUrl, '/assets/')}">
                  <c:set var="uAvatar" value="${pageContext.request.contextPath}${u.avatarUrl}" />
                </c:when>
                <c:when test="${fn:startsWith(u.avatarUrl, 'assets/')}">
                  <c:set var="uAvatar" value="${pageContext.request.contextPath}/${u.avatarUrl}" />
                </c:when>
                <c:when test="${fn:startsWith(u.avatarUrl, '/')}">
                  <c:set var="uAvatar" value="${pageContext.request.contextPath}/assets${u.avatarUrl}" />
                </c:when>
                <c:otherwise>
                  <c:set var="uAvatar" value="${pageContext.request.contextPath}/assets/${u.avatarUrl}" />
                </c:otherwise>
              </c:choose>
            </c:if>
            <option value="${u.id}" 
                    data-name="<c:out value='${u.fullName}'/>"
                    data-role="<c:out value='${uRoleText}'/>"
                    data-avatar="<c:out value='${uAvatar}'/>">
              <c:out value="${u.fullName}"/> — (<c:out value="${uRoleText}"/>)
            </option>
          </c:forEach>
        </select>
      </div>
      <div class="d-flex align-items-center p-2 bg-white rounded border member-preview-box">
        <img src="${pageContext.request.contextPath}/assets/images/person_3.jpg" 
             alt="Avatar" class="rounded-circle mr-3 member-preview-img" 
             style="width: 56px; height: 56px; object-fit: cover;"
             onerror="this.src='${pageContext.request.contextPath}/assets/images/person_3.jpg';">
        <div>
          <h6 class="mb-0 font-weight-bold text-dark member-preview-name"></h6>
          <small class="text-primary font-weight-bold member-preview-role"></small>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
  function updateCardIconPreview(selectEl) {
    var wrapper = selectEl.closest('.commit-card-item');
    if (!wrapper) return;
    var iconEl = wrapper.querySelector('.preview-card-icon');
    if (iconEl) {
      iconEl.className = selectEl.value + ' mr-1 preview-card-icon';
    }
  }

  function addCommitCard() {
    var container = document.getElementById('commitCardsContainer');
    var div = document.createElement('div');
    div.className = 'col-md-6 mb-3 commit-card-item';
    div.innerHTML = ''
      + '<div class="p-3 border rounded bg-light position-relative h-100">'
      + '  <div class="d-flex justify-content-between align-items-center mb-2">'
      + '    <span class="badge badge-warning text-dark font-weight-bold px-2 py-1">'
      + '      <i class="ion-ios-home mr-1 preview-card-icon"></i> Thẻ Lý Do Mới'
      + '    </span>'
      + '    <button type="button" class="btn btn-sm btn-outline-danger py-0 px-2" onclick="removeCommitCard(this)">'
      + '      <i class="fa fa-trash mr-1"></i> Xóa'
      + '    </button>'
      + '  </div>'
      + '  <div class="form-group mb-2">'
      + '    <label class="small font-weight-bold mb-1">Chọn Icon:</label>'
      + '    <select name="cardIcon" class="form-control form-control-sm" onchange="updateCardIconPreview(this)">'
      + '      <option value="ion-ios-home">🏠 Ngôi nhà (Không gian)</option>'
      + '      <option value="ion-ios-location">📍 Vị trí (Địa điểm)</option>'
      + '      <option value="ion-ios-heart">❤️ Trái tim (Tận tâm)</option>'
      + '      <option value="ion-ios-pricetag">🏷️ Bảng giá (Minh bạch)</option>'
      + '      <option value="fa fa-star">⭐ Ngôi sao (Chất lượng)</option>'
      + '      <option value="fa fa-shield">🛡️ Khiên bảo vệ (An ninh)</option>'
      + '      <option value="fa fa-wifi">📶 Wifi (Tiện nghi)</option>'
      + '      <option value="fa fa-coffee">☕ Cafe & Ẩm thực</option>'
      + '      <option value="fa fa-headphones">🎧 Hỗ trợ 24/7</option>'
      + '      <option value="fa fa-leaf">🌿 Thiên nhiên xanh mát</option>'
      + '    </select>'
      + '  </div>'
      + '  <div class="form-group mb-2">'
      + '    <label class="small font-weight-bold mb-1">Tiêu đề phụ lý do:</label>'
      + '    <input type="text" name="cardTitle" class="form-control form-control-sm" required placeholder="Nhập tiêu đề lý do...">'
      + '  </div>'
      + '  <div class="form-group mb-0">'
      + '    <label class="small font-weight-bold mb-1">Nội dung lý do:</label>'
      + '    <textarea name="cardDesc" rows="2" class="form-control form-control-sm" required placeholder="Nhập mô tả chi tiết..."></textarea>'
      + '  </div>'
      + '</div>';
    container.appendChild(div);
  }

  function removeCommitCard(btn) {
    var items = document.querySelectorAll('#commitCardsContainer .commit-card-item');
    if (items.length <= 1) {
      alert('Cần giữ lại ít nhất 1 thẻ lý do!');
      return;
    }
    var card = btn.closest('.commit-card-item');
    if (card) card.remove();
  }

  function updateMemberPreview(selectEl) {
    var slot = selectEl.closest('.team-member-slot');
    if (!slot) return;
    var opt = selectEl.options[selectEl.selectedIndex];
    if (!opt) return;
    var img = slot.querySelector('.member-preview-img');
    var nameEl = slot.querySelector('.member-preview-name');
    var roleEl = slot.querySelector('.member-preview-role');
    if (img) img.src = opt.getAttribute('data-avatar') || '${pageContext.request.contextPath}/assets/images/person_3.jpg';
    if (nameEl) nameEl.textContent = opt.getAttribute('data-name') || '';
    if (roleEl) roleEl.textContent = opt.getAttribute('data-role') || '';
  }

  function addTeamMemberSlot() {
    var tpl = document.getElementById('teamMemberTemplate');
    var container = document.getElementById('teamMembersContainer');
    var wrapper = document.createElement('div');
    wrapper.innerHTML = tpl.innerHTML;
    var newSlot = wrapper.firstElementChild;
    container.appendChild(newSlot);
    var selectEl = newSlot.querySelector('.team-user-select');
    if (selectEl) updateMemberPreview(selectEl);
  }

  function removeTeamMemberSlot(btn) {
    var slots = document.querySelectorAll('#teamMembersContainer .team-member-slot');
    if (slots.length <= 1) {
      alert('Cần giữ lại ít nhất 1 nhân sự!');
      return;
    }
    var slot = btn.closest('.team-member-slot');
    if (slot) slot.remove();
  }

  document.addEventListener('DOMContentLoaded', function() {
    var selects = document.querySelectorAll('#teamMembersContainer .team-user-select');
    for (var i = 0; i < selects.length; i++) {
      updateMemberPreview(selects[i]);
    }
  });
</script>

<jsp:include page="../common/footer.jsp" />