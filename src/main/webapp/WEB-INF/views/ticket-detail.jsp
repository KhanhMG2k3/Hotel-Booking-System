<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="common/header.jsp">
    <jsp:param name="pageTitle" value="Chi Tiết Yêu Cầu ${ticket.ticketCode} - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<style>
  .ticket-status-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 14px;
    border-radius: 50px;
    font-size: 0.85rem;
    font-weight: 700;
    white-space: nowrap !important;
  }
  .ticket-status-new {
    background-color: #e3f2fd;
    color: #1976d2;
    border: 1px solid #bbdefb;
  }
  .ticket-status-processing {
    background-color: #fff3e0;
    color: #e65100;
    border: 1px solid #ffe0b2;
  }
  .ticket-status-resolved {
    background-color: #e8f5e9;
    color: #2e7d32;
    border: 1px solid #c8e6c9;
  }

  .text-content-pre {
    white-space: pre-wrap;
    word-break: break-word;
    overflow-wrap: break-word;
    font-size: 0.95rem;
    line-height: 1.6;
    color: #2c3e50;
  }

  .reply-thread-item {
    border-radius: 12px;
    border: 1px solid #e9ecef;
    margin-bottom: 20px;
    transition: box-shadow 0.2s ease;
  }
  .reply-thread-admin {
    background-color: #fffdf9;
    border-left: 4px solid #ffba5a;
  }
  .reply-thread-user {
    background-color: #fcfdff;
    border-left: 4px solid #3498db;
  }
</style>

<section class="site-hero inner-page overlay" style="background-image: linear-gradient(rgba(0, 0, 0, 0.55), rgba(0, 0, 0, 0.65)), url('${pageContext.request.contextPath}/assets/images/hero_4.jpg'); min-height: 240px; height: 260px;" data-stellar-background-ratio="0.5">
  <div class="container">
    <div class="row site-hero-inner justify-content-center align-items-center" style="min-height: 240px; height: 260px;">
      <div class="col-md-10 text-center" data-aos="fade">
        <h1 class="heading mb-1" style="font-size: 1.8rem;">Chi Tiết Yêu Cầu Hỗ Trợ</h1>
        <ul class="custom-breadcrumbs mb-0">
          <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
          <li>&bullet;</li>
          <li><a href="${pageContext.request.contextPath}/support/my-tickets">Yêu Cầu Của Tôi</a></li>
          <li>&bullet;</li>
          <li><c:out value="${ticket.ticketCode}" /></li>
        </ul>
      </div>
    </div>
  </div>
</section>

<section class="section bg-light py-5">
  <div class="container">

    <div class="mb-4">
      <a href="${pageContext.request.contextPath}/support/my-tickets" class="btn btn-sm btn-outline-secondary font-weight-bold">
        <i class="fa fa-arrow-left mr-1"></i> Quay lại danh sách yêu cầu
      </a>
    </div>

    <!-- THÔNG BÁO VỪA TẠO HOẶC VỪA PHẢN HỒI THÀNH CÔNG -->
    <c:if test="${justCreated}">
      <div class="alert alert-success alert-dismissible fade show shadow-sm mb-4" role="alert">
        <h5 class="alert-heading font-weight-bold mb-1">
          <i class="fa fa-check-circle mr-1"></i> Gửi yêu cầu hỗ trợ thành công!
        </h5>
        <p class="mb-0 small">
          Mã theo dõi yêu cầu của bạn là <strong><c:out value="${ticket.ticketCode}" /></strong>. 
          Quản trị viên đã nhận được thông tin và sẽ sớm phản hồi bạn ngay tại đây.
        </p>
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
    </c:if>

    <c:if test="${replySuccess}">
      <div class="alert alert-success alert-dismissible fade show shadow-sm mb-4" role="alert">
        <i class="fa fa-check mr-1"></i> Phản hồi của bạn đã được ghi nhận thành công.
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
    </c:if>

    <c:if test="${not empty replyError}">
      <div class="alert alert-danger alert-dismissible fade show shadow-sm mb-4" role="alert">
        <i class="fa fa-exclamation-circle mr-1"></i> <c:out value="${replyError}" />
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
    </c:if>

    <!-- THẺ TỔNG QUAN YÊU CẦU BAN ĐẦU -->
    <div class="card bg-white border shadow-sm mb-4" style="border-radius: 12px;">
      <div class="card-header bg-white border-bottom p-4 d-flex justify-content-between align-items-center flex-wrap gap-2">
        <div>
          <div class="d-flex align-items-center flex-wrap gap-2 mb-2">
            <span class="badge badge-dark text-monospace px-3 py-1 font-weight-bold" style="font-size: 0.9rem;">
              <c:out value="${ticket.ticketCode}" />
            </span>
            <span class="badge badge-secondary px-3 py-1" style="font-size: 0.85rem;">
              <c:out value="${ticket.category.displayName}" />
            </span>
            <c:if test="${not empty ticket.bookingCode}">
              <span class="badge badge-info px-3 py-1" style="font-size: 0.85rem;">
                <i class="fa fa-tag"></i> Booking: <c:out value="${ticket.bookingCode}" />
              </span>
            </c:if>
          </div>
          <h4 class="font-weight-bold text-dark mb-0 ticket-subject-text">
            <c:out value="${ticket.subject}" />
          </h4>
        </div>

        <div class="mt-2 mt-md-0">
          <c:choose>
            <c:when test="${ticket.status == 'NEW'}">
              <span class="ticket-status-badge ticket-status-new">
                <i class="fa fa-circle" style="font-size: 8px;"></i> Mới tiếp nhận
              </span>
            </c:when>
            <c:when test="${ticket.status == 'PROCESSING'}">
              <span class="ticket-status-badge ticket-status-processing">
                <i class="fa fa-spinner fa-spin" style="font-size: 8px;"></i> Đang xử lý
              </span>
            </c:when>
            <c:when test="${ticket.status == 'RESOLVED'}">
              <span class="ticket-status-badge ticket-status-resolved">
                <i class="fa fa-check-circle"></i> Đã giải quyết
              </span>
            </c:when>
          </c:choose>
        </div>
      </div>

      <div class="card-body p-4">
        <div class="d-flex justify-content-between align-items-center text-muted small border-bottom pb-3 mb-3">
          <span>
            <i class="fa fa-user-circle-o mr-1"></i> Người gửi: <strong><c:out value="${ticket.fullName}" /></strong> (<c:out value="${ticket.email}" />)
          </span>
          <span>
            <i class="fa fa-clock-o mr-1"></i> Gửi lúc: <fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm" />
          </span>
        </div>

        <h6 class="font-weight-bold text-muted small mb-2 text-uppercase">Nội dung ban đầu:</h6>
        <div class="text-content-pre p-3 rounded bg-light border"><c:out value="${ticket.message}" /></div>
      </div>
    </div>

    <!-- KHỐI LỊCH SỬ TRAO ĐỔI (THREADED REPLIES) -->
    <div class="mb-4">
      <h5 class="font-weight-bold text-dark mb-3">
        <i class="fa fa-comments mr-2 text-primary"></i> Lịch Sử Trao Đổi (${fn:length(ticket.replies)} phản hồi)
      </h5>

      <c:choose>
        <c:when test="${empty ticket.replies}">
          <div class="bg-white p-4 rounded text-center border text-muted shadow-sm mb-4">
            <i class="fa fa-clock-o mr-1"></i> Yêu cầu đang chờ Quản trị viên tiếp nhận và phản hồi. Bạn sẽ thấy các tin nhắn trao đổi tại đây.
          </div>
        </c:when>
        <c:otherwise>
          <div class="replies-thread-container">
            <c:forEach items="${ticket.replies}" var="reply">
              <div class="card reply-thread-item shadow-sm ${reply.adminReply ? 'reply-thread-admin' : 'reply-thread-user'}">
                <div class="card-body p-4">
                  <div class="d-flex justify-content-between align-items-center mb-2 flex-wrap">
                    <div class="d-flex align-items-center">
                      <span class="font-weight-bold text-dark mr-2">
                        <c:out value="${reply.senderName}" />
                      </span>
                      <c:choose>
                        <c:when test="${reply.adminReply}">
                          <span class="badge badge-warning text-dark font-weight-bold px-2 py-1">
                            <i class="fa fa-shield"></i> Ban Quản Trị
                          </span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-light border text-muted px-2 py-1">
                            Người gửi
                          </span>
                        </c:otherwise>
                      </c:choose>
                    </div>
                    <div class="text-muted small mt-1 mt-sm-0">
                      <i class="fa fa-clock-o mr-1"></i>
                      <fmt:formatDate value="${reply.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                    </div>
                  </div>

                  <div class="text-content-pre mt-3"><c:out value="${reply.message}" /></div>
                </div>
              </div>
            </c:forEach>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <!-- LƯU Ý KHI TRẠNG THÁI LÀ RESOLVED -->
    <c:if test="${ticket.status == 'RESOLVED'}">
      <div class="alert alert-info border-info shadow-sm mb-4" role="alert">
        <div class="d-flex align-items-start">
          <i class="fa fa-info-circle fa-2x mr-3 text-info"></i>
          <div>
            <h6 class="font-weight-bold mb-1">Yêu cầu này đã được đánh dấu là "Đã giải quyết"</h6>
            <p class="mb-0 small">
              Nếu vấn đề của bạn vẫn chưa được giải quyết triệt để hoặc phát sinh nội dung mới, 
              bạn chỉ cần gửi thêm tin nhắn phản hồi bên dưới. Hệ thống sẽ <strong>tự động mở lại yêu cầu</strong> sang trạng thái <strong>Đang xử lý</strong> để Quản trị viên tiếp tục hỗ trợ bạn.
            </p>
          </div>
        </div>
      </div>
    </c:if>

    <!-- FORM GỬI PHẢN HỒI BỔ SUNG -->
    <div class="card bg-white border shadow-sm" style="border-radius: 12px;">
      <div class="card-header bg-white border-bottom p-4">
        <h5 class="font-weight-bold text-dark mb-1">Gửi Phản Hồi Bổ Sung</h5>
        <p class="text-muted small mb-0">Trao đổi thêm thông tin với Quản trị viên về yêu cầu này</p>
      </div>

      <div class="card-body p-4">
        <form action="${pageContext.request.contextPath}/support/reply" method="post" id="replyForm">
          <%-- Token CSRF một lần --%>
          <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}' />">
          <input type="hidden" name="ticketId" value="${ticket.messageId}">

          <div class="form-group mb-3">
            <textarea name="message" id="replyMessage" rows="4" class="form-control" 
                      placeholder="Nhập nội dung trao đổi bổ sung (từ 2 đến 2000 ký tự)..." 
                      minlength="2" maxlength="2000" required></textarea>
            <div class="d-flex justify-content-between mt-1">
              <small class="text-muted">Hỗ trợ plain text an toàn, không chứa mã độc.</small>
              <small id="replyCounter" class="text-muted">0 / 2000 ký tự</small>
            </div>
          </div>

          <div class="text-right">
            <button type="submit" id="btnSubmitReply" class="btn btn-primary text-white font-weight-bold px-4 py-2 shadow-sm rounded-pill">
              <i class="fa fa-paper-plane mr-1"></i> Gửi Tin Nhắn Phản Hồi
            </button>
          </div>
        </form>
      </div>
    </div>

  </div>
</section>

<script>
  document.addEventListener('DOMContentLoaded', function () {
    var replyInput = document.getElementById('replyMessage');
    var replyCounter = document.getElementById('replyCounter');
    var replyBtn = document.getElementById('btnSubmitReply');
    var replyForm = document.getElementById('replyForm');

    if (replyInput && replyCounter) {
      function updateReplyCount() {
        var len = replyInput.value.length;
        replyCounter.textContent = len + ' / 2000 ký tự';
        if (len > 2000) {
          replyCounter.classList.add('text-danger');
        } else {
          replyCounter.classList.remove('text-danger');
        }
      }
      replyInput.addEventListener('input', updateReplyCount);
      updateReplyCount();
    }

    if (replyForm && replyBtn) {
      replyForm.addEventListener('submit', function () {
        replyBtn.disabled = true;
        replyBtn.innerHTML = '<i class="fa fa-spinner fa-spin mr-1"></i> Đang gửi...';
      });
    }
  });
</script>

<jsp:include page="common/footer.jsp" />
