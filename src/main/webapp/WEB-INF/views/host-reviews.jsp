<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Host Reviews: list of reviews of the Host's properties, with a public reply form. --%>
<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Quản Lý Đánh Giá - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

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
<section class="section bg-light py-5">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-lg-10">

        <!-- FLASH MESSAGES (set by HostReviewController after a reply) -->
        <c:if test="${not empty hostReviewMsg}">
          <div class="alert alert-success shadow-sm border-0 mb-4">
            <i class="fa fa-check-circle mr-2"></i><c:out value="${hostReviewMsg}" />
          </div>
        </c:if>
        <c:if test="${not empty hostReviewErr}">
          <div class="alert alert-danger shadow-sm border-0 mb-4">
            <i class="fa fa-exclamation-circle mr-2"></i><c:out value="${hostReviewErr}" />
          </div>
        </c:if>

        <!-- FILTER TABS -->
        <div class="host-review-tabs mb-4">
          <a class="${filter == 'all' ? 'active' : ''}"
             href="${pageContext.request.contextPath}/host/reviews?filter=all">Tất cả</a>
          <a class="${filter == 'unreplied' ? 'active' : ''}"
             href="${pageContext.request.contextPath}/host/reviews?filter=unreplied">
            Chưa phản hồi
            <c:if test="${unrepliedCount > 0}"><span class="badge badge-danger ml-1">${unrepliedCount}</span></c:if>
          </a>
          <a class="${filter == 'replied' ? 'active' : ''}"
             href="${pageContext.request.contextPath}/host/reviews?filter=replied">Đã phản hồi</a>
          <a class="${filter == 'low' ? 'active' : ''}"
             href="${pageContext.request.contextPath}/host/reviews?filter=low">Cần ưu tiên (1-3 sao)</a>
        </div>

        <p class="text-muted small mb-3">Tìm thấy <strong>${totalReviews}</strong> đánh giá.</p>

        <!-- EMPTY STATE -->
        <c:if test="${empty reviews}">
          <div class="bg-white rounded border text-center p-5 shadow-sm">
            <i class="fa fa-comments-o text-muted mb-3" style="font-size: 42px;"></i>
            <p class="mb-0 text-muted">Chưa có đánh giá nào phù hợp với bộ lọc này.</p>
          </div>
        </c:if>

        <!-- REVIEW LIST -->
        <c:forEach var="rv" items="${reviews}">
          <div class="host-review-card bg-white rounded border shadow-sm p-4 mb-4">

            <!-- Reviewer, rating and stay info -->
            <div class="d-flex justify-content-between flex-wrap">
              <div class="d-flex align-items-center mb-2">
                <span class="reviewer-fallback mr-3"><c:out value="${rv.reviewerInitial}" /></span>
                <div>
                  <strong class="text-dark"><c:out value="${rv.userDisplayName}" /></strong>
                  <div class="review-stars">
                    <c:forEach begin="1" end="5" var="i">
                      <i class="fa ${i <= rv.rating ? 'fa-star' : 'fa-star-o'}"></i>
                    </c:forEach>
                    <span class="text-muted small ml-2">${rv.formattedDate}</span>
                  </div>
                </div>
              </div>
              <div class="text-md-right small text-muted mb-2">
                <div><i class="fa fa-home mr-1"></i><c:out value="${rv.propertyName}" /> &middot; <c:out value="${rv.roomName}" /></div>
                <c:if test="${not empty rv.bookingCode}">
                  <div>Mã đơn: <strong><c:out value="${rv.bookingCode}" /></strong></div>
                </c:if>
              </div>
            </div>

            <h5 class="font-weight-bold text-dark mt-2"><c:out value="${rv.title}" /></h5>
            <p class="review-text mb-3"><c:out value="${rv.comment}" /></p>

            <c:choose>
              <%-- Already answered: show the public reply --%>
              <c:when test="${not empty rv.reply}">
                <div class="review-reply">
                  <div class="review-reply-label">
                    <i class="fa fa-reply mr-1"></i> Phản hồi từ Chủ nhà
                    <span class="text-muted small ml-2">${rv.reply.formattedDate}</span>
                  </div>
                  <p class="review-text mb-0"><c:out value="${rv.reply.replyContent}" /></p>
                </div>
              </c:when>

              <%-- Not answered yet: reply form --%>
              <c:otherwise>
                <button type="button" class="btn btn-outline-primary btn-sm px-4"
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
                    <textarea class="form-control review-textarea" name="replyContent" rows="4"
                              maxlength="1000" required
                              placeholder="Cảm ơn khách hoặc giải thích thêm một cách lịch sự (10 - 1000 ký tự). Phản hồi sẽ hiển thị công khai."></textarea>
                    <div class="d-flex justify-content-between align-items-center mt-2">
                      <small class="text-muted">Mỗi đánh giá chỉ được phản hồi một lần.</small>
                      <button type="submit" class="btn btn-primary btn-sm px-4 text-white font-weight-bold">
                        <i class="fa fa-paper-plane mr-1"></i> Gửi phản hồi công khai
                      </button>
                    </div>
                  </form>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
        </c:forEach>

        <!-- PAGINATION -->
        <c:if test="${totalPages > 1}">
          <nav class="host-review-paging text-center mt-4">
            <c:forEach begin="1" end="${totalPages}" var="p">
              <a class="${p == currentPage ? 'active' : ''}"
                 href="${pageContext.request.contextPath}/host/reviews?filter=${filter}&page=${p}">${p}</a>
            </c:forEach>
          </nav>
        </c:if>

      </div>
    </div>
  </div>
</section>

<!-- Client-side validation: same 10 - 1000 character rule as the server -->
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