<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Thông Báo - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<style>
  .hero-notifications {
    background-image: linear-gradient(rgba(0, 0, 0, 0.55), rgba(0, 0, 0, 0.65)), url('${pageContext.request.contextPath}/assets/images/slider-4.jpg');
    background-size: cover;
    background-position: center;
  }

  .notification-page-card {
    border-radius: 16px;
    border: none;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.06);
    background: #ffffff;
  }

  .nav-tabs-notifications .nav-link {
    font-weight: 600;
    color: #6c757d;
    border: none;
    border-bottom: 3px solid transparent;
    padding: 12px 18px;
    transition: all 0.25s ease;
  }
  .nav-tabs-notifications .nav-link:hover {
    color: #fd7e14;
    border-color: transparent;
  }
  .nav-tabs-notifications .nav-link.active {
    color: #fd7e14;
    border-bottom: 3px solid #fd7e14;
    background: transparent;
  }

  .notification-item {
    padding: 18px 20px;
    border-bottom: 1px solid #f1f3f5;
    transition: background 0.2s ease, transform 0.15s ease;
    display: flex;
    align-items: flex-start;
    gap: 16px;
    position: relative;
    cursor: pointer;
    text-decoration: none !important;
    color: inherit;
  }
  .notification-item:hover {
    background: #fdfdfd;
    box-shadow: inset 3px 0 0 #fd7e14;
  }
  .notification-item.unread {
    background: #f8fbff;
    font-weight: 500;
  }
  .notification-item.unread:hover {
    background: #f0f6ff;
    box-shadow: inset 4px 0 0 #007bff;
  }

  .notification-icon-box {
    width: 46px;
    height: 46px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.25rem;
    flex-shrink: 0;
    box-shadow: 0 4px 10px rgba(0,0,0,0.06);
  }
  .notification-icon-box.BOOKING { background: #e8f4fd; color: #0d6efd; }
  .notification-icon-box.PROMOTION { background: #ffebee; color: #dc3545; }
  .notification-icon-box.REVIEW { background: #fff8e1; color: #f59e0b; }
  .notification-icon-box.SYSTEM { background: #eef2f7; color: #495057; }

  .notification-unread-dot {
    width: 10px;
    height: 10px;
    background-color: #0d6efd;
    border-radius: 50%;
    position: absolute;
    top: 22px;
    right: 20px;
  }

  .empty-notification-box {
    padding: 60px 20px;
    text-align: center;
  }
  .empty-notification-icon {
    font-size: 4rem;
    color: #ced4da;
    margin-bottom: 15px;
  }
</style>

<!-- HERO BANNER -->
<section class="site-hero hero-notifications overlay" data-stellar-background-ratio="0.5">
  <div class="container">
    <div class="row site-hero-inner justify-content-center align-items-center">
      <div class="col-md-10 text-center" data-aos="fade-up">
        <span class="custom-caption text-uppercase text-white d-block mb-3">Tài khoản & Kỳ nghỉ</span>
        <h1 class="heading">Thông Báo Của Bạn</h1>
        <p class="text-white-50">Cập nhật kịp thời lịch đặt phòng, ưu đãi giá và phản hồi từ chủ nhà</p>
      </div>
    </div>
  </div>
</section>

<!-- MAIN CONTENT -->
<section class="section bg-light py-5">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-lg-10">

        <!-- THẺ THÔNG BÁO CHÍNH -->
        <div class="card notification-page-card shadow-sm">
          
          <!-- HEADER THẺ -->
          <div class="card-header bg-white border-bottom p-4 d-flex flex-wrap justify-content-between align-items-center">
            <div>
              <h4 class="mb-1 font-weight-bold text-dark">
                <i class="fa fa-bell text-warning mr-2"></i> Trung Tâm Thông Báo
              </h4>
              <p class="text-muted small mb-0">
                Bạn có <span class="badge badge-primary font-weight-bold" id="pageUnreadCount">${unreadCount}</span> thông báo chưa đọc
              </p>
            </div>
            <div class="mt-2 mt-sm-0">
              <button type="button" class="btn btn-outline-primary btn-sm rounded-pill px-3" onclick="markAllNotificationsRead();">
                <i class="fa fa-check-circle-o mr-1"></i> Đánh dấu tất cả là đã đọc
              </button>
            </div>
          </div>

          <!-- TABS LỌC -->
          <div class="px-4 pt-2 border-bottom bg-white">
            <ul class="nav nav-tabs nav-tabs-notifications border-0">
              <li class="nav-item">
                <a class="nav-link ${activeTab == 'all' ? 'active' : ''}" href="${pageContext.request.contextPath}/notifications?tab=all">
                  Tất cả
                </a>
              </li>
              <li class="nav-item">
                <a class="nav-link ${activeTab == 'unread' ? 'active' : ''}" href="${pageContext.request.contextPath}/notifications?tab=unread">
                  Chưa đọc <c:if test="${unreadCount > 0}"><span class="badge badge-danger ml-1">${unreadCount}</span></c:if>
                </a>
              </li>
              <li class="nav-item">
                <a class="nav-link ${activeTab == 'booking' ? 'active' : ''}" href="${pageContext.request.contextPath}/notifications?tab=booking">
                  <i class="fa fa-calendar-check-o mr-1"></i> Đặt phòng
                </a>
              </li>
              <li class="nav-item">
                <a class="nav-link ${activeTab == 'promotion' ? 'active' : ''}" href="${pageContext.request.contextPath}/notifications?tab=promotion">
                  <i class="fa fa-tag mr-1"></i> Khuyến mãi
                </a>
              </li>
              <li class="nav-item">
                <a class="nav-link ${activeTab == 'review' ? 'active' : ''}" href="${pageContext.request.contextPath}/notifications?tab=review">
                  <i class="fa fa-commenting-o mr-1"></i> Phản hồi & Đánh giá
                </a>
              </li>
            </ul>
          </div>

          <!-- DANH SÁCH THÔNG BÁO -->
          <div class="card-body p-0" id="notificationListContainer">
            <c:choose>
              <c:when test="${not empty notifications}">
                <c:forEach var="item" items="${notifications}">
                  <div class="notification-item ${item.read ? 'read' : 'unread'}" id="notif-item-${item.id}"
                       onclick="handleNotificationClick(${item.id}, '${item.targetUrl}', ${item.read});">
                    
                    <!-- Icon phân loại -->
                    <div class="notification-icon-box ${item.type}">
                      <i class="${item.iconClass}"></i>
                    </div>

                    <!-- Nội dung -->
                    <div class="flex-grow-1 pr-4">
                      <div class="d-flex align-items-center mb-1">
                        <span class="${item.badgeClass} mr-2">${item.typeLabel}</span>
                        <h6 class="mb-0 font-weight-bold text-dark">${item.title}</h6>
                      </div>
                      <p class="text-muted small mb-2">${item.message}</p>
                      <div class="d-flex align-items-center text-muted" style="font-size: 0.8rem;">
                        <span><i class="fa fa-clock-o mr-1"></i> ${item.timeAgo}</span>
                        <c:if test="${not empty item.targetUrl}">
                          <span class="mx-2">•</span>
                          <span class="text-primary font-weight-bold">Xem chi tiết <i class="fa fa-angle-right ml-1"></i></span>
                        </c:if>
                      </div>
                    </div>

                    <!-- Chấm xanh chưa đọc -->
                    <c:if test="${!item.read}">
                      <div class="notification-unread-dot" id="dot-${item.id}" title="Chưa đọc"></div>
                    </c:if>

                    <!-- Nút xóa -->
                    <button type="button" class="btn btn-link text-muted p-0 ml-2" 
                            title="Xóa thông báo" 
                            onclick="event.stopPropagation(); deleteNotificationItem(${item.id});" 
                            style="font-size: 0.85rem; opacity: 0.6;">
                      <i class="fa fa-trash-o"></i>
                    </button>
                  </div>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <!-- TRẠNG THÁI TRỐNG -->
                <div class="empty-notification-box">
                  <div class="empty-notification-icon">
                    <i class="fa fa-bell-slash-o"></i>
                  </div>
                  <h5 class="text-dark font-weight-bold">Không có thông báo nào</h5>
                  <p class="text-muted small">Bạn sẽ nhận được các thông tin quan trọng về chuyến đi và khuyến mãi tại đây.</p>
                  <a href="${pageContext.request.contextPath}/rooms" class="btn btn-primary btn-sm rounded-pill px-4 mt-2">
                    <i class="fa fa-search mr-1"></i> Khám phá phòng ngay
                  </a>
                </div>
              </c:otherwise>
            </c:choose>
          </div>

          <!-- PHÂN TRANG -->
          <c:if test="${totalPages > 1}">
            <div class="card-footer bg-white border-top p-3 d-flex justify-content-center">
              <ul class="pagination pagination-sm mb-0">
                <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                  <a class="page-link" href="${pageContext.request.contextPath}/notifications?tab=${activeTab}&page=${currentPage - 1}">Trước</a>
                </li>
                <c:forEach var="p" begin="1" end="${totalPages}">
                  <li class="page-item ${p == currentPage ? 'active' : ''}">
                    <a class="page-link" href="${pageContext.request.contextPath}/notifications?tab=${activeTab}&page=${p}">${p}</a>
                  </li>
                </c:forEach>
                <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                  <a class="page-link" href="${pageContext.request.contextPath}/notifications?tab=${activeTab}&page=${currentPage + 1}">Sau</a>
                </li>
              </ul>
            </div>
          </c:if>

        </div>
      </div>
    </div>
  </div>
</section>

<!-- JAVASCRIPT XỬ LÝ SỰ KIỆN -->
<script>
  function handleNotificationClick(id, targetUrl, isRead) {
    if (!isRead) {
      // Gọi API đánh dấu đã đọc
      fetch('${pageContext.request.contextPath}/api/notifications/mark-read', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'id=' + encodeURIComponent(id)
      }).then(res => res.json()).then(data => {
        if (data.success) {
          // Bỏ highlight và ẩn chấm xanh
          var item = document.getElementById('notif-item-' + id);
          if (item) {
            item.classList.remove('unread');
            item.classList.add('read');
          }
          var dot = document.getElementById('dot-' + id);
          if (dot) dot.style.display = 'none';

          // Cập nhật số unread
          updatePageAndHeaderBadge(data.unreadCount);
        }
      }).catch(err => console.error(err));
    }

    // Chuyển hướng tới trang liên quan nếu có targetUrl
    if (targetUrl && targetUrl.trim() !== '') {
      var fullUrl = targetUrl;
      if (!fullUrl.startsWith('http') && !fullUrl.startsWith('${pageContext.request.contextPath}')) {
        fullUrl = '${pageContext.request.contextPath}' + (fullUrl.startsWith('/') ? '' : '/') + fullUrl;
      }
      setTimeout(function() {
        window.location.href = fullUrl;
      }, 150);
    }
  }

  function markAllNotificationsRead() {
    fetch('${pageContext.request.contextPath}/api/notifications/mark-all-read', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: 'ajax=true'
    }).then(res => res.json()).then(data => {
      if (data.success) {
        document.querySelectorAll('.notification-item.unread').forEach(function(el) {
          el.classList.remove('unread');
          el.classList.add('read');
        });
        document.querySelectorAll('.notification-unread-dot').forEach(function(dot) {
          dot.style.display = 'none';
        });
        updatePageAndHeaderBadge(0);
      }
    }).catch(err => console.error(err));
  }

  function deleteNotificationItem(id) {
    if (!confirm('Bạn có chắc chắn muốn xóa thông báo này?')) return;

    fetch('${pageContext.request.contextPath}/api/notifications/delete', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'id=' + encodeURIComponent(id)
    }).then(res => res.json()).then(data => {
      if (data.success) {
        var el = document.getElementById('notif-item-' + id);
        if (el) {
          el.style.opacity = '0';
          setTimeout(function() {
            el.remove();
            if (document.querySelectorAll('.notification-item').length === 0) {
              location.reload();
            }
          }, 250);
        }
        updatePageAndHeaderBadge(data.unreadCount);
      }
    }).catch(err => console.error(err));
  }

  function updatePageAndHeaderBadge(count) {
    var pageBadge = document.getElementById('pageUnreadCount');
    if (pageBadge) pageBadge.textContent = count;

    var headerBadge = document.getElementById('navbarNotificationBadge');
    if (headerBadge) {
      headerBadge.textContent = count;
      headerBadge.style.display = (count > 0) ? 'inline-block' : 'none';
    }
  }
</script>

<jsp:include page="common/footer.jsp" />