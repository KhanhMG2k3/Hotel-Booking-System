<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="../common/header.jsp">
  <jsp:param name="pageTitle" value="Quản Trị About Us - Sogo Homestay" />
</jsp:include>

<jsp:include page="../common/navbar.jsp" />

<style>
    /* 1. BẢNG MÀU DARK THEME */
    :root {
        --bg-main: #121316;
        --bg-card: #1c1e24;
        --bg-subcard: #16181e;
        --bg-input: #15171c;
        --border-color: #2e323b;
        --accent-gold: #f59e0b;
        --accent-hover: #d97706;
        --text-main: #f3f4f6;
        --text-muted: #9ca3af;
    }

    body {
        background-color: var(--bg-main) !important;
        color: var(--text-main) !important;
    }

    /* 2. CỐ ĐỊNH HEADER NỀN TỐI SẮC NÉT */
    .site-header {
        background: #17191f !important;
        padding: 12px 0 !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.45) !important;
        border-bottom: 1px solid var(--border-color) !important;
        position: fixed !important;
        top: 0 !important;
        left: 0 !important;
        width: 100% !important;
        z-index: 1030 !important;
    }
    .site-header .site-logo a { color: #ffffff !important; }
    .site-header .site-menu-toggle span { background: #ffffff !important; }
    .site-header .user-name, .site-header .user-caret { color: #ffffff !important; }
    .site-header .auth-link:not(.auth-link-primary) { color: #d1d5db !important; }
    .site-header .auth-link:not(.auth-link-primary):hover { color: var(--accent-gold) !important; }
    .site-header .auth-divider { color: rgba(255, 255, 255, 0.2) !important; }

    /* 3. ĐẨY FORM XUỐNG DƯỚI HEADER */
    .admin-about-wrapper {
        max-width: 1100px;
        margin: 125px auto 60px auto;
        padding: 0 20px;
        position: relative;
        z-index: 1;
    }

    /* 4. CARD VÀ INPUT DARK THEME */
    .card-dark {
        background-color: var(--bg-card);
        border: 1px solid var(--border-color);
        border-radius: 8px;
        margin-bottom: 25px;
        overflow: hidden;
    }
    .card-header-dark {
        background-color: rgba(255, 255, 255, 0.02);
        border-bottom: 1px solid var(--border-color);
        padding: 16px 22px;
        color: var(--accent-gold);
        font-weight: 700;
        font-size: 1.05rem;
    }
    .form-control-dark {
        width: 100%;
        background-color: var(--bg-input) !important;
        border: 1px solid var(--border-color) !important;
        border-radius: 6px !important;
        color: #ffffff !important;
        padding: 10px 14px;
        font-size: 14px;
        transition: border-color 0.2s ease, box-shadow 0.2s ease;
    }
    .form-control-dark:focus {
        border-color: var(--accent-gold) !important;
        background-color: #191c22 !important;
        color: #ffffff !important;
        outline: none;
        box-shadow: 0 0 0 2px rgba(245, 158, 11, 0.25) !important;
    }
    .sub-card-box {
        background-color: var(--bg-subcard);
        border: 1px solid var(--border-color);
        border-radius: 6px;
        padding: 16px;
    }
    .member-preview-dark {
        background-color: var(--bg-input);
        border: 1px solid var(--border-color);
        border-radius: 6px;
        padding: 10px 14px;
    }

    /* 5. DROPDOWN TÍCH CHỌN ICON CHUẨN (HIỂN THỊ ĐẦY ĐỦ NỘI DUNG, KHÔNG BỊ CHE NỬA CHỮ) */
    .card-icon-select {
        height: 48px !important;
        min-height: 48px !important;
        line-height: 1.5 !important;
        padding: 8px 40px 8px 14px !important;
        font-size: 14.5px !important;
        font-weight: 500 !important;
        color: #ffffff !important;
        background-color: var(--bg-input) !important;
        border: 1px solid var(--border-color) !important;
        border-radius: 6px !important;
        cursor: pointer;
        display: block;
        width: 100%;
        box-sizing: border-box !important;
        appearance: none;
        -webkit-appearance: none;
        -moz-appearance: none;
        background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23f59e0b' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e") !important;
        background-repeat: no-repeat !important;
        background-position: right 14px center !important;
        background-size: 16px !important;
        transition: border-color 0.2s ease, box-shadow 0.2s ease;
    }
    .card-icon-select:focus {
        border-color: var(--accent-gold) !important;
        background-color: #191c22 !important;
        box-shadow: 0 0 0 2px rgba(245, 158, 11, 0.25) !important;
        outline: none !important;
    }
    .card-icon-select option {
        background-color: #1c1e24 !important;
        color: #ffffff !important;
        padding: 10px 14px !important;
        font-size: 14px !important;
    }
    .card-icon-preview-box {
        width: 48px;
        height: 48px;
        background: #14161a;
        border: 1px solid var(--border-color);
        border-radius: 6px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }
    .card-icon-preview-box i {
        font-size: 24px;
        color: var(--accent-gold);
        line-height: 1;
    }
</style>

<div class="admin-about-wrapper">

    <!-- KHỐI TIÊU ĐỀ TRANG -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 pb-3 border-bottom" style="border-color: var(--border-color) !important;">
      <div>
        <h2 class="font-weight-bold mb-1" style="color: #ffffff; font-size: 1.65rem;">
          <i class="fa fa-pencil-square-o mr-2" style="color: var(--accent-gold);"></i>Chỉnh Sửa Trang "Về Chúng Tôi"
        </h2>
        <span style="color: var(--text-muted); font-size: 0.92rem;">Quản trị toàn bộ thông tin giới thiệu, thẻ lý do cam kết và đội ngũ nhân sự</span>
      </div>
      <div class="mt-3 mt-md-0">
        <a href="${pageContext.request.contextPath}/about" target="_blank" class="btn btn-outline-warning font-weight-bold px-3 py-2 shadow-sm" style="border-color: var(--accent-gold); color: var(--accent-gold);">
          <i class="fa fa-external-link mr-1"></i> Xem Trang About Thực Tế
        </a>
      </div>
    </div>

    <!-- THÔNG BÁO LƯU -->
    <c:if test="${param.success == 'true'}">
      <div class="alert alert-success alert-dismissible fade show shadow-sm mb-4" role="alert" style="background: rgba(34, 197, 94, 0.15); border: 1px solid #22c55e; color: #4ade80;">
        <i class="fa fa-check-circle mr-2"></i><strong>Thành công!</strong> Dữ liệu đã được lưu vào cơ sở dữ liệu và đồng bộ ra trang giới thiệu.
        <button type="button" class="close text-white" data-dismiss="alert">&times;</button>
      </div>
    </c:if>
    <c:if test="${param.error == 'failed'}">
      <div class="alert alert-danger alert-dismissible fade show shadow-sm mb-4" role="alert" style="background: rgba(239, 68, 68, 0.15); border: 1px solid #ef4444; color: #f87171;">
        <i class="fa fa-times-circle mr-2"></i><strong>Lỗi:</strong> Không thể lưu vào cơ sở dữ liệu. Vui lòng kiểm tra lại!
        <button type="button" class="close text-white" data-dismiss="alert">&times;</button>
      </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/admin/about/edit" method="post">
      
      <!-- KHỐI 1: LỜI CHÀO & CÂU CHUYỆN HOMESTAY -->
      <div class="card-dark shadow-sm">
        <div class="card-header-dark">
          <i class="fa fa-home mr-2"></i>1. Lời Chào, Đoạn Văn Giới Thiệu & Nút Bấm
        </div>
        <div class="p-4">
          <div class="form-group mb-3">
            <label class="font-weight-bold text-white mb-2">Tiêu Đề Lời Chào (Gộp 1 dòng):</label>
            <input type="text" name="title" class="form-control-dark" 
                   value="<c:out value='${not empty about.title ? about.title : "Chào mừng đến với Sogo Homestay"}'/>" required>
          </div>

          <div class="form-group mb-3">
            <label class="font-weight-bold text-white mb-2">Nội Dung Giới Thiệu (Hỗ trợ nhiều đoạn văn):</label>
            <textarea name="introContent" rows="6" class="form-control-dark" required><c:out value="${about.introContent}"/></textarea>
            <small style="color: var(--text-muted); display: block; margin-top: 5px;">
              <i class="fa fa-info-circle mr-1"></i>Nhấn phím Enter xuống dòng để tách thành các đoạn văn riêng biệt khi hiển thị.
            </small>
          </div>

          <div class="row">
            <div class="col-md-6 form-group mb-0">
              <label class="font-weight-bold text-white mb-2">Tên Nút 1 (Nút vàng):</label>
              <input type="text" name="btnExploreText" class="form-control-dark" 
                     value="<c:out value='${not empty about.btnExploreText ? about.btnExploreText : "Khám Phá Phòng"}'/>">
            </div>
            <div class="col-md-6 form-group mb-0 mt-3 mt-md-0">
              <label class="font-weight-bold text-white mb-2">Tên Nút 2 (Nút text link):</label>
              <input type="text" name="btnBookText" class="form-control-dark" 
                     value="<c:out value='${not empty about.btnBookText ? about.btnBookText : "Đặt Phòng Ngay"}'/>">
            </div>
          </div>
        </div>
      </div>

      <!-- KHỐI 2: CAM KẾT CỦA CHÚNG TÔI (THẺ LÝ DO ĐỘNG) -->
      <div class="card-dark shadow-sm">
        <div class="card-header-dark d-flex justify-content-between align-items-center">
          <span><i class="fa fa-shield mr-2"></i>2. Khối Cam Kết Của Chúng Tôi (Thẻ Lý Do Động)</span>
          <button type="button" class="btn btn-sm btn-warning font-weight-bold text-dark px-3 py-1 shadow-sm" onclick="addCommitCard()" style="background: var(--accent-gold); border: none;">
            <i class="fa fa-plus mr-1"></i> Thêm Thẻ Lý Do
          </button>
        </div>
        <div class="p-4">
          <div class="form-group mb-4">
            <label class="font-weight-bold text-white mb-2">Tiêu Đề Khối Cam Kết:</label>
            <input type="text" name="commitTitle" class="form-control-dark" 
                   value="<c:out value='${not empty about.commitTitle ? about.commitTitle : "Tại Sao Khách Hàng Chọn Sogo?"}'/>">
          </div>

          <label class="font-weight-bold text-white d-block mb-3">Danh Sách Các Thẻ Lý Do:</label>
          <div class="row" id="commitCardsContainer">
            <c:forEach var="card" items="${about.commitCards}" varStatus="loop">
              <div class="col-md-6 mb-3 commit-card-item">
                <div class="sub-card-box position-relative h-100">
                  <div class="d-flex justify-content-between align-items-center mb-2 pb-2 border-bottom" style="border-color: var(--border-color) !important;">
                    <span class="badge badge-warning text-dark font-weight-bold px-2 py-1" style="background: var(--accent-gold);">
                      <i class="${card.icon} mr-1 preview-badge-icon"></i> Thẻ Lý Do
                    </span>
                    <button type="button" class="btn btn-sm btn-outline-danger py-0 px-2" onclick="removeCommitCard(this)" title="Xóa thẻ này">
                      <i class="fa fa-trash mr-1"></i> Xóa
                    </button>
                  </div>

                  <!-- DROPDOWN TÍCH CHỌN ICON (HIỂN THỊ ĐẦY ĐỦ NỘI DUNG, KHÔNG BỊ CHE CHỮ) -->
                  <div class="form-group mb-2">
                    <label class="small font-weight-bold text-white mb-1">Chọn Icon:</label>
                    <div class="d-flex align-items-center">
                      <div class="mr-2 card-icon-preview-box" title="Icon xem trước">
                        <i class="${card.icon} preview-card-icon"></i>
                      </div>
                      <select name="cardIcon" class="card-icon-select" onchange="updateCardIconPreview(this)">
                        <option value="fa fa-home" ${card.icon == 'fa fa-home' || card.icon == 'ion-ios-home' ? 'selected' : ''}>🏠 Ngôi nhà (Không gian ấm cúng)</option>
                        <option value="fa fa-bed" ${card.icon == 'fa fa-bed' ? 'selected' : ''}>🛏️ Giường ngủ (Tiện nghi êm ái)</option>
                        <option value="fa fa-map-marker" ${card.icon == 'fa fa-map-marker' || card.icon == 'ion-ios-location' ? 'selected' : ''}>📍 Vị trí (Vị trí đắc địa, gần biển)</option>
                        <option value="fa fa-heart" ${card.icon == 'fa fa-heart' || card.icon == 'ion-ios-heart' ? 'selected' : ''}>❤️ Trái tim (Phục vụ tận tâm)</option>
                        <option value="fa fa-shield" ${card.icon == 'fa fa-shield' ? 'selected' : ''}>🛡️ Khiên bảo vệ (An ninh 24/7, an toàn)</option>
                        <option value="fa fa-star" ${card.icon == 'fa fa-star' || card.icon == 'ion-ios-star' ? 'selected' : ''}>⭐ Ngôi sao (Chất lượng đánh giá cao)</option>
                        <option value="fa fa-tag" ${card.icon == 'fa fa-tag' || card.icon == 'ion-ios-pricetag' ? 'selected' : ''}>🏷️ Bảng giá (Minh bạch, giá tốt nhất)</option>
                        <option value="fa fa-wifi" ${card.icon == 'fa fa-wifi' ? 'selected' : ''}>📶 Wifi (Internet tốc độ cao)</option>
                        <option value="fa fa-coffee" ${card.icon == 'fa fa-coffee' ? 'selected' : ''}>☕ Cafe & Ẩm thực (Điểm tâm miễn phí)</option>
                        <option value="fa fa-headphones" ${card.icon == 'fa fa-headphones' ? 'selected' : ''}>🎧 Hỗ trợ 24/7 (Tư vấn chu đáo)</option>
                        <option value="fa fa-leaf" ${card.icon == 'fa fa-leaf' ? 'selected' : ''}>🌿 Thiên nhiên (Không gian xanh mát)</option>
                        <option value="fa fa-building" ${card.icon == 'fa fa-building' ? 'selected' : ''}>🏢 Tòa nhà (Căn hộ / Khách sạn)</option>
                        <option value="fa fa-key" ${card.icon == 'fa fa-key' ? 'selected' : ''}>🔑 Chìa khóa (Check-in linh hoạt)</option>
                        <option value="fa fa-bath" ${card.icon == 'fa fa-bath' ? 'selected' : ''}>🛁 Bồn tắm (Thư giãn thoải mái)</option>
                        <option value="fa fa-television" ${card.icon == 'fa fa-television' ? 'selected' : ''}>📺 TV thông minh (Giải trí đa dạng)</option>
                        <option value="fa fa-snowflake-o" ${card.icon == 'fa fa-snowflake-o' ? 'selected' : ''}>❄️ Điều hòa (Mát lạnh mùa hè)</option>
                        <option value="fa fa-fire" ${card.icon == 'fa fa-fire' ? 'selected' : ''}>🔥 Lò sưởi (Ấm áp mùa đông)</option>
                        <option value="fa fa-umbrella" ${card.icon == 'fa fa-umbrella' ? 'selected' : ''}>🏖️ Bãi biển (Gần biển & Du lịch)</option>
                        <option value="fa fa-car" ${card.icon == 'fa fa-car' ? 'selected' : ''}>🚗 Đỗ xe ô tô (Bãi đỗ xe an toàn)</option>
                        <option value="fa fa-motorcycle" ${card.icon == 'fa fa-motorcycle' ? 'selected' : ''}>🏍️ Thuê xe máy (Khám phá phố phường)</option>
                        <option value="fa fa-plane" ${card.icon == 'fa fa-plane' ? 'selected' : ''}>✈️ Đưa đón (Dịch vụ xe sân bay)</option>
                        <option value="fa fa-diamond" ${card.icon == 'fa fa-diamond' ? 'selected' : ''}>💎 Sang trọng (Nội thất cao cấp)</option>
                        <option value="fa fa-lock" ${card.icon == 'fa fa-lock' ? 'selected' : ''}>🔒 Bảo mật (Riêng tư tuyệt đối)</option>
                        <option value="fa fa-thumbs-up" ${card.icon == 'fa fa-thumbs-up' ? 'selected' : ''}>👍 Hài lòng (100% khách yêu thích)</option>
                        <option value="fa fa-check-circle" ${card.icon == 'fa fa-check-circle' ? 'selected' : ''}>✔️ Đã kiểm duyệt (Xác thực tiêu chuẩn)</option>
                        <option value="fa fa-cutlery" ${card.icon == 'fa fa-cutlery' ? 'selected' : ''}>🍳 Bếp nấu (Tự do nấu ăn)</option>
                        <option value="fa fa-glass" ${card.icon == 'fa fa-glass' ? 'selected' : ''}>🍷 Đồ uống & Chill (Quầy bar mini)</option>
                        <option value="fa fa-clock-o" ${card.icon == 'fa fa-clock-o' ? 'selected' : ''}>🕒 Linh hoạt giờ (Check-in/out tự do)</option>
                        <option value="fa fa-bell" ${card.icon == 'fa fa-bell' ? 'selected' : ''}>🔔 Dịch vụ phòng (Chu đáo 24/7)</option>
                        <option value="fa fa-sun-o" ${card.icon == 'fa fa-sun-o' ? 'selected' : ''}>🌞 Ban công (Đón nắng và gió biển)</option>
                      </select>
                    </div>
                  </div>

                  <div class="form-group mb-2">
                    <label class="small font-weight-bold text-white mb-1">Tiêu đề phụ lý do:</label>
                    <input type="text" name="cardTitle" class="form-control-dark" style="height: 40px;" value="<c:out value='${card.title}'/>" required placeholder="Nhập tiêu đề lý do...">
                  </div>

                  <div class="form-group mb-0">
                    <label class="small font-weight-bold text-white mb-1">Nội dung lý do:</label>
                    <textarea name="cardDesc" rows="2" class="form-control-dark" required placeholder="Nhập mô tả chi tiết..."><c:out value="${card.description}"/></textarea>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>
        </div>
      </div>

      <!-- KHỐI 3: GẶP GỠ ĐỘI NGŨ -->
      <div class="card-dark shadow-sm">
        <div class="card-header-dark d-flex justify-content-between align-items-center">
          <span><i class="fa fa-users mr-2"></i>3. Khối Đội Ngũ Quản Lý & Vận Hành (Chọn Từ Bảng Users)</span>
          <button type="button" class="btn btn-sm btn-warning font-weight-bold text-dark px-3 py-1 shadow-sm" onclick="addTeamMemberSlot()" style="background: var(--accent-gold); border: none;">
            <i class="fa fa-user-plus mr-1"></i> Thêm Nhân Sự
          </button>
        </div>
        <div class="p-4">
          <div class="form-group mb-4">
            <label class="font-weight-bold text-white mb-2">Tiêu Đề Khối Đội Ngũ:</label>
            <input type="text" name="teamTitle" class="form-control-dark" 
                   value="<c:out value='${not empty about.teamTitle ? about.teamTitle : "Đội Ngũ Quản Lý & Vận Hành"}'/>">
          </div>

          <label class="font-weight-bold text-white d-block mb-3">Chọn Nhân Sự Hiển Thị (Lấy từ bảng <code>users</code>):</label>
          <div class="row" id="teamMembersContainer">
            <c:forEach var="selectedMember" items="${about.teamMembers}" varStatus="mLoop">
              <div class="col-md-6 mb-3 team-member-slot">
                <div class="sub-card-box h-100">
                  <div class="d-flex justify-content-between align-items-center mb-2 pb-2 border-bottom" style="border-color: var(--border-color) !important;">
                    <span class="font-weight-bold small" style="color: var(--accent-gold);">
                      <i class="fa fa-id-badge mr-1"></i> Vị trí nhân sự
                    </span>
                    <button type="button" class="btn btn-sm btn-outline-danger py-0 px-2" onclick="removeTeamMemberSlot(this)">
                      <i class="fa fa-trash mr-1"></i> Xóa
                    </button>
                  </div>

                  <div class="form-group mb-3">
                    <label class="small font-weight-bold text-white mb-1">Chọn từ danh sách User:</label>
                    <select name="teamUserIds" class="form-control-dark team-user-select" style="height: 44px;" onchange="updateMemberPreview(this)">
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

                  <div class="d-flex align-items-center member-preview-dark member-preview-box">
                    <img src="${pageContext.request.contextPath}/assets/images/person_3.jpg" 
                         alt="Avatar" class="rounded-circle mr-3 member-preview-img" 
                         style="width: 52px; height: 52px; object-fit: cover; border: 2px solid var(--border-color);"
                         onerror="this.src='${pageContext.request.contextPath}/assets/images/person_3.jpg';">
                    <div>
                      <h6 class="mb-0 font-weight-bold text-white member-preview-name"></h6>
                      <small class="font-weight-bold member-preview-role" style="color: var(--accent-gold);"></small>
                    </div>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>
        </div>
      </div>

      <!-- NÚT LƯU CẬP NHẬT -->
      <div class="d-flex justify-content-between align-items-center pt-3 mt-4 border-top" style="border-color: var(--border-color) !important;">
        <a href="${pageContext.request.contextPath}/about" class="btn btn-outline-secondary px-4 py-2" style="border-color: var(--border-color); color: #d1d5db;">
          <i class="fa fa-arrow-left mr-1"></i> Quay Lại
        </a>
        <button type="submit" class="btn btn-warning text-dark font-weight-bold px-5 py-2 shadow" style="background: var(--accent-gold); border: none; font-size: 15px;">
          <i class="fa fa-floppy-o mr-2"></i> Lưu & Đồng Bộ Bảng About Us
        </button>
      </div>

    </form>
</div>

<!-- TEMPLATE DÀNH CHO THÊM NHÂN SỰ MỚI TỪ BẢNG USERS -->
<template id="teamMemberTemplate">
  <div class="col-md-6 mb-3 team-member-slot">
    <div class="sub-card-box h-100">
      <div class="d-flex justify-content-between align-items-center mb-2 pb-2 border-bottom" style="border-color: var(--border-color) !important;">
        <span class="font-weight-bold small" style="color: var(--accent-gold);">
          <i class="fa fa-id-badge mr-1"></i> Vị trí nhân sự mới
        </span>
        <button type="button" class="btn btn-sm btn-outline-danger py-0 px-2" onclick="removeTeamMemberSlot(this)">
          <i class="fa fa-trash mr-1"></i> Xóa
        </button>
      </div>
      <div class="form-group mb-3">
        <label class="small font-weight-bold text-white mb-1">Chọn từ danh sách User:</label>
        <select name="teamUserIds" class="form-control-dark team-user-select" style="height: 44px;" onchange="updateMemberPreview(this)">
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
      <div class="d-flex align-items-center member-preview-dark member-preview-box">
        <img src="${pageContext.request.contextPath}/assets/images/person_3.jpg" 
             alt="Avatar" class="rounded-circle mr-3 member-preview-img" 
             style="width: 52px; height: 52px; object-fit: cover; border: 2px solid var(--border-color);"
             onerror="this.src='${pageContext.request.contextPath}/assets/images/person_3.jpg';">
        <div>
          <h6 class="mb-0 font-weight-bold text-white member-preview-name"></h6>
          <small class="font-weight-bold member-preview-role" style="color: var(--accent-gold);"></small>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  // Cập nhật khung xem trước icon và badge khi chọn trong dropdown
  function updateCardIconPreview(selectEl) {
    var cardItem = selectEl.closest('.commit-card-item');
    if (!cardItem) return;
    var iconClass = selectEl.value;
    var previewIcon = cardItem.querySelector('.preview-card-icon');
    if (previewIcon) {
      previewIcon.className = iconClass + ' preview-card-icon';
    }
    var badgeIcon = cardItem.querySelector('.preview-badge-icon');
    if (badgeIcon) {
      badgeIcon.className = iconClass + ' mr-1 preview-badge-icon';
    }
  }

  // Danh sách các tùy chọn icon chuẩn hóa dành cho thẻ mới
  var COMMIT_CARD_ICON_OPTIONS = ''
    + '<option value="fa fa-home">🏠 Ngôi nhà (Không gian ấm cúng)</option>'
    + '<option value="fa fa-bed">🛏️ Giường ngủ (Tiện nghi êm ái)</option>'
    + '<option value="fa fa-map-marker">📍 Vị trí (Vị trí đắc địa, gần biển)</option>'
    + '<option value="fa fa-heart">❤️ Trái tim (Phục vụ tận tâm)</option>'
    + '<option value="fa fa-shield">🛡️ Khiên bảo vệ (An ninh 24/7, an toàn)</option>'
    + '<option value="fa fa-star" selected>⭐ Ngôi sao (Chất lượng đánh giá cao)</option>'
    + '<option value="fa fa-tag">🏷️ Bảng giá (Minh bạch, giá tốt nhất)</option>'
    + '<option value="fa fa-wifi">📶 Wifi (Internet tốc độ cao)</option>'
    + '<option value="fa fa-coffee">☕ Cafe & Ẩm thực (Điểm tâm miễn phí)</option>'
    + '<option value="fa fa-headphones">🎧 Hỗ trợ 24/7 (Tư vấn chu đáo)</option>'
    + '<option value="fa fa-leaf">🌿 Thiên nhiên (Không gian xanh mát)</option>'
    + '<option value="fa fa-building">🏢 Tòa nhà (Căn hộ / Khách sạn)</option>'
    + '<option value="fa fa-key">🔑 Chìa khóa (Check-in linh hoạt)</option>'
    + '<option value="fa fa-bath">🛁 Bồn tắm (Thư giãn thoải mái)</option>'
    + '<option value="fa fa-television">📺 TV thông minh (Giải trí đa dạng)</option>'
    + '<option value="fa fa-snowflake-o">❄️ Điều hòa (Mát lạnh mùa hè)</option>'
    + '<option value="fa fa-fire">🔥 Lò sưởi (Ấm áp mùa đông)</option>'
    + '<option value="fa fa-umbrella">🏖️ Bãi biển (Gần biển & Du lịch)</option>'
    + '<option value="fa fa-car">🚗 Đỗ xe ô tô (Bãi đỗ xe an toàn)</option>'
    + '<option value="fa fa-motorcycle">🏍️ Thuê xe máy (Khám phá phố phường)</option>'
    + '<option value="fa fa-plane">✈️ Đưa đón (Dịch vụ xe sân bay)</option>'
    + '<option value="fa fa-diamond">💎 Sang trọng (Nội thất cao cấp)</option>'
    + '<option value="fa fa-lock">🔒 Bảo mật (Riêng tư tuyệt đối)</option>'
    + '<option value="fa fa-thumbs-up">👍 Hài lòng (100% khách yêu thích)</option>'
    + '<option value="fa fa-check-circle">✔️ Đã kiểm duyệt (Xác thực tiêu chuẩn)</option>'
    + '<option value="fa fa-cutlery">🍳 Bếp nấu (Tự do nấu ăn)</option>'
    + '<option value="fa fa-glass">🍷 Đồ uống & Chill (Quầy bar mini)</option>'
    + '<option value="fa fa-clock-o">🕒 Linh hoạt giờ (Check-in/out tự do)</option>'
    + '<option value="fa fa-bell">🔔 Dịch vụ phòng (Chu đáo 24/7)</option>'
    + '<option value="fa fa-sun-o">🌞 Ban công (Đón nắng và gió biển)</option>';

  // Thêm thẻ lý do mới có sẵn dropdown chọn icon hiển thị đầy đủ nội dung
  function addCommitCard() {
    var container = document.getElementById('commitCardsContainer');
    var div = document.createElement('div');
    div.className = 'col-md-6 mb-3 commit-card-item';
    div.innerHTML = ''
      + '<div class="sub-card-box position-relative h-100">'
      + '  <div class="d-flex justify-content-between align-items-center mb-2 pb-2 border-bottom" style="border-color: var(--border-color) !important;">'
      + '    <span class="badge badge-warning text-dark font-weight-bold px-2 py-1" style="background: var(--accent-gold);">'
      + '      <i class="fa fa-star mr-1 preview-badge-icon"></i> Thẻ Lý Do Mới'
      + '    </span>'
      + '    <button type="button" class="btn btn-sm btn-outline-danger py-0 px-2" onclick="removeCommitCard(this)" title="Xóa thẻ này">'
      + '      <i class="fa fa-trash mr-1"></i> Xóa'
      + '    </button>'
      + '  </div>'
      + '  <div class="form-group mb-2">'
      + '    <label class="small font-weight-bold text-white mb-1">Chọn Icon:</label>'
      + '    <div class="d-flex align-items-center">'
      + '      <div class="mr-2 card-icon-preview-box" title="Icon xem trước">'
      + '        <i class="fa fa-star preview-card-icon"></i>'
      + '      </div>'
      + '      <select name="cardIcon" class="card-icon-select" onchange="updateCardIconPreview(this)">'
      +          COMMIT_CARD_ICON_OPTIONS
      + '      </select>'
      + '    </div>'
      + '  </div>'
      + '  <div class="form-group mb-2">'
      + '    <label class="small font-weight-bold text-white mb-1">Tiêu đề phụ lý do:</label>'
      + '    <input type="text" name="cardTitle" class="form-control-dark" style="height: 40px;" required placeholder="Nhập tiêu đề lý do...">'
      + '  </div>'
      + '  <div class="form-group mb-0">'
      + '    <label class="small font-weight-bold text-white mb-1">Nội dung lý do:</label>'
      + '    <textarea name="cardDesc" rows="2" class="form-control-dark" required placeholder="Nhập mô tả chi tiết..."></textarea>'
      + '  </div>'
      + '</div>';
    container.appendChild(div);
    var newSelect = div.querySelector('.card-icon-select');
    if (newSelect) updateCardIconPreview(newSelect);
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
    if (!tpl || !container) return;
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
    // Khởi tạo preview cho toàn bộ nhân sự
    var selects = document.querySelectorAll('#teamMembersContainer .team-user-select');
    for (var i = 0; i < selects.length; i++) {
      updateMemberPreview(selects[i]);
    }
    // Khởi tạo preview cho toàn bộ icon commit card
    var iconSelects = document.querySelectorAll('#commitCardsContainer .card-icon-select');
    for (var j = 0; j < iconSelects.length; j++) {
      updateCardIconPreview(iconSelects[j]);
    }
  });
</script>

<jsp:include page="../common/footer.jsp" />