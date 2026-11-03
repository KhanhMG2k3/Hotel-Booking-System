<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Host Reviews: Quản lý đánh giá của khách hàng và gửi phản hồi công khai --%>
<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Quản Lý Đánh Giá - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<style>
  /* ================== CSS CHO TABS VÀ PHÂN TRANG HOST REVIEWS ================== */
  
  /* 1. KHUNG VÀ NÚT TABS */
  .host-review-tabs-container {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 12px;
    background: rgba(255, 255, 255, 0.05);
    padding: 8px 12px;
    border-radius: 35px;
    border: 1px solid rgba(255, 255, 255, 0.12);
    margin-bottom: 24px;
    backdrop-filter: blur(8px);
  }

  .host-review-tab-btn {
    display: inline-flex;
    align-items: center;
    padding: 10px 22px;
    border-radius: 25px;
    color: #cbd5e1;
    font-weight: 600;
    font-size: 0.92rem;
    text-decoration: none !important;
    transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
    background: transparent;
    border: 1px solid transparent;
  }

  .host-review-tab-btn:hover {
    color: #ffffff;
    background: rgba(255, 255, 255, 0.12);
    transform: translateY(-2px);
  }

  /* Trạng thái tab đang chọn (Active) */
  .host-review-tab-btn.active {
    background: #ffba5a;
    color: #1a202c !important;
    font-weight: 700;
    border-color: #ffba5a;
    box-shadow: 0 4px 15px rgba(255, 186, 90, 0.4);
    transform: translateY(-1px);
  }

  .host-review-tab-btn .badge-pill-count {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 22px;
    height: 22px;
    padding: 0 6px;
    border-radius: 12px;
    font-size: 0.75rem;
    font-weight: 700;
    margin-left: 8px;
    background: #dc3545;
    color: #ffffff;
    box-shadow: 0 2px 6px rgba(220, 53, 69, 0.4);
  }

  .host-review-tab-btn.active .badge-pill-count {
    background: #1a202c;
    color: #ffba5a;
  }

  /* 2. THẺ ĐÁNH GIÁ (REVIEW CARD) */
  .host-review-card {
    background: #1e2530 !important;
    border: 1px solid rgba(255, 255, 255, 0.08) !important;
    border-left: 5px solid #ffba5a !important;
    border-radius: 16px !important;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.28) !important;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
  }

  .host-review-card:hover {
    box-shadow: 0 12px 30px rgba(0, 0, 0, 0.4) !important;
  }

  .reviewer-fallback {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 48px;
    height: 48px;
    border-radius: 50%;
    background: linear-gradient(135deg, #ffba5a, #e69526);
    color: #1a202c;
    font-weight: 800;
    font-size: 1.15rem;
    box-shadow: 0 4px 12px rgba(255, 186, 90, 0.35);
  }

  .review-stars {
    color: #ffba5a;
    font-size: 0.95rem;
  }

  .review-text {
    color: #cbd5e1;
    line-height: 1.7;
    font-size: 0.95rem;
  }

  /* Khối phản hồi đã trả lời */
  .review-reply {
    background: rgba(255, 186, 90, 0.08);
    border-left: 3px solid #ffba5a;
    border-radius: 12px;
    padding: 16px 20px;
    margin-top: 16px;
    border-top: 1px solid rgba(255, 186, 90, 0.15);
  }

  .review-reply-label {
    color: #ffba5a;
    font-weight: 700;
    font-size: 0.95rem;
    margin-bottom: 8px;
  }

  /* 3. KHỐI PHÂN TRANG (PAGINATION) */
  .host-pagination-wrapper {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 8px;
    margin-top: 40px;
    margin-bottom: 25px;
  }

  .host-page-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 42px;
    height: 42px;
    padding: 0 16px;
    border-radius: 12px;
    background: rgba(255, 255, 255, 0.06);
    color: #cbd5e1;
    font-size: 0.92rem;
    font-weight: 600;
    text-decoration: none !important;
    border: 1px solid rgba(255, 255, 255, 0.14);
    transition: all 0.2s ease;
  }

  .host-page-btn:hover:not(.disabled):not(.active) {
    background: rgba(255, 255, 255, 0.16);
    color: #ffffff;
    transform: translateY(-2px);
    border-color: rgba(255, 255, 255, 0.3);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.25);
  }

  .host-page-btn.active {
    background: #ffba5a;
    color: #1a202c !important;
    border-color: #ffba5a;
    font-weight: 800;
    box-shadow: 0 4px 15px rgba(255, 186, 90, 0.4);
    cursor: default;
  }

  .host-page-btn.disabled {
    opacity: 0.35;
    cursor: not-allowed;
    pointer-events: none;
    background: transparent;
  }
</style>

<!-- HERO BREADCRUMB -->
<section class="site-hero inner-page overlay hero-review-page"
  data-hero-image="${pageContext.request.contextPath}/assets/images/hero_4.jpg"
  data-stellar-background-ratio="0.5">
  <div class="container">
    <div class="row site-hero-inner justify-content-center align-items-center">
      <div class="col-md-10 text-center" data-aos="fade">
        <h1 class="heading mb-3">Đánh Giá Từ Khách Hàng</h1>
        <ul class="custom-breadcrumbs mb-4">
          <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
          <li>&bullet;</li>
          <li><a href="${pageContext.request.contextPath}/host/dashboard">Host Dashboard</a></li>
          <li>&bullet;</li>
          <li>Quản Lý Đánh Giá</li>
        </ul>
      </div>
    </div>
  </div>
</section>

<!-- MAIN SECTION -->
<section class="section py-5" style="background-color: #121820; min-height: 70vh;">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-lg-10">

        <!-- THÔNG BÁO FLASH MESSAGE -->
        <c:if test="${not empty hostReviewMsg}">
          <div class="alert alert-success shadow-sm border-0 mb-4 rounded-pill px-4">
            <i class="fa fa-check-circle mr-2"></i><c:out value="${hostReviewMsg}" />
          </div>
        </c:if>
        <c:if test="${not empty hostReviewErr}">
          <div class="alert alert-danger shadow-sm border-0 mb-4 rounded-pill px-4">
            <i class="fa fa-exclamation-circle mr-2"></i><c:out value="${hostReviewErr}" />
          </div>
        </c:if>

        <!-- BỘ LỌC TABS ĐƯỢC THIẾT KẾ DẠNG PILLS NỔI BẬT -->
        <div class="host-review-tabs-container">
          <!-- Tab 1: Tất cả -->
          <a class="host-review-tab-btn ${filter == 'all' ? 'active' : ''}"
             href="${pageContext.request.contextPath}/host/reviews?filter=all">
            <i class="fa fa-list mr-2"></i> Tất cả
          </a>

          <!-- Tab 2: Chưa phản hồi -->
          <a class="host-review-tab-btn ${filter == 'unreplied' ? 'active' : ''}"
             href="${pageContext.request.contextPath}/host/reviews?filter=unreplied">
            <i class="fa fa-clock-o mr-2"></i> Chưa phản hồi
            <c:if test="${unrepliedCount > 0}">
              <span class="badge-pill-count">${unrepliedCount}</span>
            </c:if>
          </a>

          <!-- Tab 3: Đã phản hồi -->
          <a class="host-review-tab-btn ${filter == 'replied' ? 'active' : ''}"
             href="${pageContext.request.contextPath}/host/reviews?filter=replied">
            <i class="fa fa-check-circle mr-2"></i> Đã phản hồi
          </a>

          <!-- Tab 4: Cần ưu tiên (1-3 sao) -->
          <a class="host-review-tab-btn ${filter == 'low' ? 'active' : ''}"
             href="${pageContext.request.contextPath}/host/reviews?filter=low">
            <i class="fa fa-exclamation-triangle mr-2 text-warning"></i> Cần ưu tiên (1-3 sao)
          </a>
        </div>

        <p class="text-white-50 small mb-3">
          <i class="fa fa-search mr-1"></i> Tìm thấy <strong class="text-white">${totalReviews}</strong> đánh giá.
        </p>

        <!-- TRẠNG THÁI TRỐNG KHI KHÔNG CÓ ĐÁNH GIÁ -->
        <c:if test="${empty reviews}">
          <div class="host-review-card text-center p-5 mb-4">
            <i class="fa fa-comments-o text-muted mb-3" style="font-size: 48px;"></i>
            <h5 class="text-white font-weight-bold">Không có đánh giá nào</h5>
            <p class="mb-0 text-white-50 small">Chưa có đánh giá nào phù hợp với bộ lọc đang chọn.</p>
          </div>
        </c:if>

        <!-- DANH SÁCH REVIEW CARDS -->
        <c:forEach var="rv" items="${reviews}">
          <div class="host-review-card p-4 mb-4">

            <!-- Thông tin người đánh giá, số sao và homestay -->
            <div class="d-flex justify-content-between flex-wrap align-items-start">
              <div class="d-flex align-items-center mb-3">
                <span class="reviewer-fallback mr-3"><c:out value="${rv.reviewerInitial}" /></span>
                <div>
                  <h6 class="text-white font-weight-bold mb-1"><c:out value="${rv.userDisplayName}" /></h6>
                  <div class="review-stars">
                    <c:forEach begin="1" end="5" var="i">
                      <i class="fa ${i <= rv.rating ? 'fa-star' : 'fa-star-o'}"></i>
                    </c:forEach>
                    <span class="text-white-50 small ml-2"><i class="fa fa-calendar mr-1"></i>${rv.formattedDate}</span>
                  </div>
                </div>
              </div>

              <div class="text-md-right small text-white-50 mb-3">
                <div><i class="fa fa-home text-warning mr-1"></i><strong class="text-white"><c:out value="${rv.propertyName}" /></strong> &middot; <c:out value="${rv.roomName}" /></div>
                <c:if test="${not empty rv.bookingCode}">
                  <div class="mt-1">Mã đơn: <span class="badge badge-secondary px-2"><c:out value="${rv.bookingCode}" /></span></div>
                </c:if>
              </div>
            </div>

            <!-- Tiêu đề và nội dung nhận xét -->
            <h5 class="font-weight-bold text-white mt-1"><c:out value="${rv.title}" /></h5>
            <p class="review-text mb-3"><c:out value="${rv.comment}" /></p>

            <c:choose>
              <%-- Đã có phản hồi: Hiển thị hộp phản hồi công khai --%>
              <c:when test="${not empty rv.reply}">
                <div class="review-reply">
                  <div class="review-reply-label d-flex align-items-center">
                    <i class="fa fa-reply mr-2"></i> Phản hồi từ Chủ nhà
                    <span class="text-white-50 small ml-auto"><i class="fa fa-clock-o mr-1"></i>${rv.reply.formattedDate}</span>
                  </div>
                  <p class="review-text text-white mb-0"><c:out value="${rv.reply.replyContent}" /></p>
                </div>
              </c:when>

              <%-- Chưa phản hồi: Nút mở form trả lời --%>
              <c:otherwise>
                <button type="button" class="btn btn-outline-warning btn-sm px-4 rounded-pill font-weight-bold"
                        data-toggle="collapse" data-target="#reply-${rv.id}">
                  <i class="fa fa-reply mr-1"></i> Phản hồi đánh giá
                </button>
                <div class="collapse mt-3" id="reply-${rv.id}">
                  <form action="${pageContext.request.contextPath}/host/reviews" method="POST"
                        onsubmit="return validateReply(this);">
                    <input type="hidden" name="reviewId" value="${rv.id}">
                    <input type="hidden" name="csrfToken" value="${csrfToken}">
                    <input type="hidden" name="filter" value="${filter}">
                    <input type="hidden" name="page" value="${currentPage}">
                    <textarea class="form-control" name="replyContent" rows="4"
                              maxlength="1000" required
                              style="background: #151a22; border: 1px solid rgba(255,255,255,0.15); color: #fff; border-radius: 12px; padding: 12px;"
                              placeholder="Cảm ơn khách hoặc giải thích thêm một cách lịch sự (10 - 1000 ký tự). Phản hồi sẽ hiển thị công khai."></textarea>
                    <div class="d-flex justify-content-between align-items-center mt-3">
                      <small class="text-white-50"><i class="fa fa-info-circle mr-1"></i> Mỗi đánh giá chỉ được phản hồi một lần.</small>
                      <button type="submit" class="btn btn-warning btn-sm px-4 rounded-pill font-weight-bold text-dark">
                        <i class="fa fa-paper-plane mr-1"></i> Gửi phản hồi công khai
                      </button>
                    </div>
                  </form>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
        </c:forEach>

        <!-- THANH PHÂN TRANG HIỆN ĐẠI (PAGINATION) -->
        <c:if test="${totalPages > 1}">
          <nav class="host-pagination-wrapper" aria-label="Phân trang đánh giá">
            <!-- Nút Trang trước -->
            <a class="host-page-btn ${currentPage <= 1 ? 'disabled' : ''}"
               href="${pageContext.request.contextPath}/host/reviews?filter=${filter}&page=${currentPage - 1}">
              <i class="fa fa-chevron-left mr-1"></i> Trước
            </a>

            <!-- Các nút số trang 1, 2, 3... -->
            <c:forEach begin="1" end="${totalPages}" var="p">
              <a class="host-page-btn ${p == currentPage ? 'active' : ''}"
                 href="${pageContext.request.contextPath}/host/reviews?filter=${filter}&page=${p}">${p}</a>
            </c:forEach>

            <!-- Nút Trang sau -->
            <a class="host-page-btn ${currentPage >= totalPages ? 'disabled' : ''}"
               href="${pageContext.request.contextPath}/host/reviews?filter=${filter}&page=${currentPage + 1}">
              Sau <i class="fa fa-chevron-right ml-1"></i>
            </a>
          </nav>
        </c:if>

      </div>
    </div>
  </div>
</section>

<!-- Kiểm tra độ dài phản hồi trước khi gửi (10 - 1000 ký tự) -->
<script>
  function validateReply(form) {
    var len = form.replyContent.value.trim().length;
    if (len < 10) {
      alert("Nội dung phản hồi phải từ 10 ký tự trở lên!");
      form.replyContent.focus();
      return false;
    }
    return true;
  }
</script>

<jsp:include page="common/footer.jsp" />