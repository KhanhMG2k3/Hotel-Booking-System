<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Danh Sách Yêu Thích - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<style>
  /* STYLES CHO TRANG WISHLIST */
  .hero-wishlist {
    background-image: linear-gradient(rgba(0, 0, 0, 0.55), rgba(0, 0, 0, 0.65)), url('${pageContext.request.contextPath}/assets/images/slider-2.jpg');
    background-size: cover;
    background-position: center;
  }

  .wishlist-card {
    transition: transform 0.25s ease, box-shadow 0.25s ease;
    border-radius: 14px;
    overflow: hidden;
    position: relative;
  }
  .wishlist-card:hover {
    transform: translateY(-6px);
    box-shadow: 0 14px 28px rgba(0, 0, 0, 0.12) !important;
  }

  .room-card-image {
    height: 230px;
    object-fit: cover;
    transition: transform 0.4s ease;
  }
  .wishlist-card:hover .room-card-image {
    transform: scale(1.05);
  }

  .btn-wishlist-remove {
    position: absolute;
    top: 14px;
    right: 14px;
    width: 38px;
    height: 38px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.92);
    border: none;
    box-shadow: 0 3px 10px rgba(0, 0, 0, 0.15);
    display: inline-flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    z-index: 10;
    color: #e63946;
  }
  .btn-wishlist-remove:hover {
    transform: scale(1.15);
    background: #e63946;
    color: #fff;
  }

  .sogo-rating-badge {
    background: #fff8e7;
    color: #b7791f;
    font-weight: 700;
    padding: 3px 8px;
    border-radius: 6px;
    font-size: 0.85rem;
    border: 1px solid #fef08a;
  }

  .wishlist-empty-box {
    background: #fdfdfd;
    border: 2px dashed #e2e8f0;
    border-radius: 20px;
    padding: 60px 20px;
    text-align: center;
  }

  .wishlist-empty-icon {
    width: 90px;
    height: 90px;
    border-radius: 50%;
    background: #fff1f2;
    color: #f43f5e;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 42px;
    margin-bottom: 20px;
    box-shadow: 0 8px 20px rgba(244, 63, 94, 0.15);
  }

  /* Scoped Dark Mode Overrides */
  [data-theme="dark"] .wishlist-empty-box {
    background: #162032 !important;
    border-color: #334155 !important;
    color: #cbd5e1 !important;
  }
  [data-theme="dark"] .wishlist-empty-box h3 {
    color: #f8fafc !important;
  }
  [data-theme="dark"] .wishlist-empty-box p {
    color: #94a3b8 !important;
  }
  [data-theme="dark"] .wishlist-empty-icon {
    background: rgba(244, 63, 94, 0.15) !important;
    color: #fb7185 !important;
    box-shadow: 0 8px 20px rgba(244, 63, 94, 0.25) !important;
  }
  [data-theme="dark"] .wishlist-card {
    background: #162032 !important;
    border-color: #243247 !important;
  }
  [data-theme="dark"] .wishlist-card .room-info {
    background: #162032 !important;
  }
  [data-theme="dark"] .btn-wishlist-remove {
    background: rgba(15, 23, 42, 0.85) !important;
    color: #f43f5e !important;
  }
</style>

<!-- HERO SECTION -->
<section class="site-hero inner-page overlay hero-wishlist" data-stellar-background-ratio="0.5">
  <div class="container">
    <div class="row site-hero-inner justify-content-center align-items-center">
      <div class="col-md-10 text-center" data-aos="fade">
        <h1 class="heading mb-3"><i class="fa fa-heart text-danger mr-2"></i> Danh Sách Yêu Thích</h1>
        <ul class="custom-breadcrumbs mb-4">
          <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
          <li>&bullet;</li>
          <li><a href="${pageContext.request.contextPath}/rooms">Phòng Nghỉ</a></li>
          <li>&bullet;</li>
          <li>Yêu Thích Của Tôi</li>
        </ul>
      </div>
    </div>
  </div>
</section>

<!-- MAIN CONTENT SECTION -->
<section class="section bg-light py-5">
  <div class="container">

    <!-- HEADER BAR: SỐ LƯỢNG & NÚT XÓA TẤT CẢ -->
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap bg-white p-3 rounded shadow-sm border">
      <div>
        <h4 class="font-weight-bold mb-1 text-dark">
          <i class="fa fa-bookmark text-primary mr-2"></i>Phòng Nghỉ Đã Lưu
        </h4>
        <span class="text-muted small">
          Hiện có <strong class="text-primary font-weight-bold" id="wishlistCountDisplay">${wishlistCount}</strong> phòng trong danh sách yêu thích của bạn
        </span>
      </div>
      <div class="mt-2 mt-md-0 d-flex align-items-center">
        <a href="${pageContext.request.contextPath}/rooms" class="btn btn-outline-primary btn-sm font-weight-bold mr-2">
          <i class="fa fa-search mr-1"></i> Khám Phá Thêm
        </a>
        <c:if test="${not empty wishlistItems}">
          <button type="button" class="btn btn-outline-danger btn-sm" onclick="clearAllWishlist()">
            <i class="fa fa-trash-o mr-1"></i> Xóa Tất Cả
          </button>
        </c:if>
      </div>
    </div>

    <!-- DANH SÁCH PHÒNG YÊU THÍCH -->
    <div class="row" id="wishlistGrid">
      <c:choose>
        <c:when test="${not empty wishlistItems}">
          <c:forEach var="item" items="${wishlistItems}">
            <c:set var="room" value="${item.room}" />
            <c:if test="${not empty room}">
              <div class="col-md-6 col-lg-4 mb-4 wishlist-item-col" id="wishlist-col-${room.id}" data-aos="fade-up">
                <div class="room border rounded overflow-hidden shadow-sm h-100 d-flex flex-column bg-white wishlist-card">

                  <!-- NÚT BỎ YÊU THÍCH -->
                  <button type="button" class="btn-wishlist-remove" title="Bỏ khỏi danh sách yêu thích"
                          onclick="removeFromWishlist(${room.id})">
                    <i class="fa fa-heart"></i>
                  </button>

                  <!-- ẢNH PHÒNG CÓ LINK -->
                  <a href="${pageContext.request.contextPath}/room-detail?id=${room.id}"
                     class="d-block position-relative overflow-hidden">
                    <img src="${pageContext.request.contextPath}/assets/${not empty room.imageUrl ? room.imageUrl : 'images/img_1.jpg'}"
                         alt="${room.roomName}" class="img-fluid w-100 room-card-image" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/img_1.jpg';">
                    <span class="badge badge-primary position-absolute px-3 py-2 font-weight-bold"
                          style="top: 14px; left: 14px; border-radius: 8px;">
                      Mã: ${room.roomNumber}
                    </span>
                  </a>

                  <!-- THÔNG TIN PHÒNG -->
                  <div class="p-4 text-center room-info flex-grow-1 d-flex flex-column justify-content-between">
                    <div>
                      <div class="d-flex justify-content-between align-items-center mb-2">
                        <span class="badge badge-light border text-muted">${room.roomType.typeName}</span>
                        <span class="sogo-rating-badge">
                          <i class="fa fa-star text-warning"></i> <fmt:formatNumber value="${room.rating}" minFractionDigits="1" maxFractionDigits="1" />
                          <small class="text-muted font-weight-normal">(${room.reviewCount})</small>
                        </span>
                      </div>

                      <h2 class="h5 font-weight-bold mb-1">
                        <a href="${pageContext.request.contextPath}/room-detail?id=${room.id}"
                           class="text-dark hover-primary">${room.roomName}</a>
                      </h2>

                      <c:if test="${not empty room.provinceName}">
                        <div class="text-muted small text-left mb-2">
                          <i class="fa fa-map-marker text-danger mr-1"></i>
                          <span class="font-weight-bold text-dark">${room.provinceName}</span>
                          <c:if test="${not empty room.propertyName}">
                            <span class="text-muted">&bull; ${room.propertyName}</span>
                          </c:if>
                        </div>
                      </c:if>

                      <p class="text-muted small text-left mb-3">${room.description}</p>
                    </div>

                    <div class="mt-3 pt-3 border-top">
                      <div class="d-flex justify-content-between align-items-center mb-2 text-muted small">
                        <span><i class="fa fa-users text-primary mr-1"></i> ${room.capacity} Khách</span>
                        <span><i class="fa fa-arrows-alt text-primary mr-1"></i> ${room.size} m²</span>
                        <span><i class="fa fa-bed text-primary mr-1"></i> ${not empty room.bedType ? room.bedType : 'Giường lớn'}</span>
                      </div>

                      <!-- GIÁ TIỀN VNĐ -->
                      <div class="d-flex justify-content-between align-items-center mb-3">
                        <span class="text-muted small">Giá thuê:</span>
                        <span class="h5 mb-0 text-primary font-weight-bold">
                          ${room.formattedPrice} VNĐ <small class="text-muted font-weight-normal">/đêm</small>
                        </span>
                      </div>

                      <!-- CÁC NÚT HÀNH ĐỘNG -->
                      <div class="row no-gutters">
                        <div class="col-6 pr-1">
                          <a href="${pageContext.request.contextPath}/room-detail?id=${room.id}"
                             class="btn btn-outline-primary btn-block btn-sm py-2 font-weight-bold">
                            <i class="fa fa-eye mr-1"></i> Chi Tiết
                          </a>
                        </div>
                        <div class="col-6 pl-1">
                          <a href="${pageContext.request.contextPath}/reservation?roomId=${room.id}"
                             class="btn btn-primary btn-block btn-sm py-2 font-weight-bold text-white shadow-sm">
                            <i class="fa fa-calendar-check-o mr-1"></i> Đặt Ngay
                          </a>
                        </div>
                      </div>
                    </div>

                  </div>

                </div>
              </div>
            </c:if>
          </c:forEach>
        </c:when>

        <c:otherwise>
          <!-- GIAO DIỆN KHI CHƯA CÓ PHÒNG YÊU THÍCH -->
          <div class="col-12" id="wishlistEmptyState">
            <div class="wishlist-empty-box shadow-sm">
              <div class="wishlist-empty-icon">
                <i class="fa fa-heart-o"></i>
              </div>
              <h3 class="font-weight-bold text-dark mb-2">Danh sách yêu thích của bạn đang trống!</h3>
              <p class="text-muted mb-4 max-w-md mx-auto" style="max-width: 520px;">
                Hãy dạo một vòng khám phá những homestay độc đáo tại Đà Nẵng, Hà Nội, Đà Lạt, Sài Gòn,... và bấm vào biểu tượng trái tim để lưu lại căn phòng bạn yêu thích nhé!
              </p>
              <a href="${pageContext.request.contextPath}/rooms" class="btn btn-primary font-weight-bold px-4 py-3 shadow">
                <i class="fa fa-compass mr-2"></i> Khám Phá Phòng Nghỉ Ngay
              </a>
            </div>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

  </div>
</section>

<!-- TOAST THÔNG BÁO -->
<div id="wishlistToast" class="sogo-wishlist-toast">
  <i class="fa fa-check-circle text-success mr-2 font-weight-bold" id="toastIcon"></i>
  <span id="toastMessage">Thông báo</span>
</div>

<jsp:include page="common/footer.jsp" />

<script>
  function showToast(msg, isSuccess = true) {
    var toast = document.getElementById('wishlistToast');
    var icon = document.getElementById('toastIcon');
    var text = document.getElementById('toastMessage');

    text.innerText = msg;
    if (isSuccess) {
      icon.className = 'fa fa-check-circle text-success mr-2';
    } else {
      icon.className = 'fa fa-exclamation-circle text-danger mr-2';
    }

    toast.style.display = 'flex';
    clearTimeout(window._wishlistToastTimer);
    window._wishlistToastTimer = setTimeout(function() {
      toast.style.display = 'none';
    }, 2800);
  }

  function removeFromWishlist(roomId) {

    var cardCol = document.getElementById('wishlist-col-' + roomId);
    if (cardCol) {
      cardCol.style.transition = 'all 0.35s ease';
      cardCol.style.opacity = '0.4';
      cardCol.style.transform = 'scale(0.95)';
    }

    fetch('${pageContext.request.contextPath}/api/wishlist/remove', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: 'roomId=' + encodeURIComponent(roomId)
    })
    .then(function(res) { return res.json(); })
    .then(function(data) {
      if (data.success) {
        if (cardCol) {
          cardCol.remove();
        }
        showToast(data.message || 'Đã xóa phòng khỏi danh sách yêu thích!');

        // Update count display
        var countEl = document.getElementById('wishlistCountDisplay');
        if (countEl) {
          countEl.innerText = data.count;
        }
        var badges = document.querySelectorAll('#navbarWishlistBadge, .header-wishlist-badge');
        badges.forEach(function(b) {
          b.innerText = data.count;
        });

        // If count becomes 0, show empty state
        if (data.count === 0) {
          var grid = document.getElementById('wishlistGrid');
          grid.innerHTML = '<div class="col-12" id="wishlistEmptyState">' +
            '<div class="wishlist-empty-box shadow-sm">' +
            '<div class="wishlist-empty-icon"><i class="fa fa-heart-o"></i></div>' +
            '<h3 class="font-weight-bold text-dark mb-2">Danh sách yêu thích của bạn đang trống!</h3>' +
            '<p class="text-muted mb-4 max-w-md mx-auto" style="max-width: 520px;">' +
            'Hãy dạo một vòng khám phá những homestay độc đáo và lưu lại những căn phòng bạn yêu thích nhé!' +
            '</p>' +
            '<a href="${pageContext.request.contextPath}/rooms" class="btn btn-primary font-weight-bold px-4 py-3 shadow">' +
            '<i class="fa fa-compass mr-2"></i> Khám Phá Phòng Nghỉ Ngay' +
            '</a>' +
            '</div></div>';
        }
      } else {
        if (cardCol) {
          cardCol.style.opacity = '1';
          cardCol.style.transform = 'none';
        }
        showToast(data.message || 'Có lỗi xảy ra, vui lòng thử lại.', false);
      }
    })
    .catch(function(err) {
      if (cardCol) {
        cardCol.style.opacity = '1';
        cardCol.style.transform = 'none';
      }
      showToast('Lỗi kết nối máy chủ!', false);
    });
  }

  function clearAllWishlist() {
    if (!confirm('Bạn có chắc chắn muốn xóa toàn bộ danh sách phòng yêu thích không?')) {
      return;
    }

    fetch('${pageContext.request.contextPath}/api/wishlist/clear', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: 'action=clear'
    })
    .then(function(res) { return res.json(); })
    .then(function(data) {
      if (data.success) {
        location.reload();
      } else {
        showToast(data.message || 'Không thể xóa danh sách yêu thích.', false);
      }
    })
    .catch(function(err) {
      showToast('Lỗi kết nối máy chủ!', false);
    });
  }
</script>
