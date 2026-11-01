<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="common/header.jsp">
    <jsp:param name="pageTitle" value="Yêu Cầu Hỗ Trợ Của Tôi - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<style>
  .ticket-status-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 5px 12px;
    border-radius: 50px;
    font-size: 0.8rem;
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

  .nav-pills-support .nav-link {
    font-weight: 600;
    color: #495057;
    background-color: #f8f9fa;
    border: 1px solid #dee2e6;
    margin-right: 8px;
    margin-bottom: 8px;
    border-radius: 20px;
    padding: 8px 18px;
    transition: all 0.2s ease;
  }
  .nav-pills-support .nav-link:hover {
    color: #ffba5a;
    background-color: #ffffff;
    border-color: #ffba5a;
  }
  .nav-pills-support .nav-link.active {
    color: #ffffff;
    background-color: #ffba5a;
    border-color: #ffba5a;
  }

  .ticket-card-item {
    transition: transform 0.15s ease, box-shadow 0.15s ease;
    border-radius: 12px;
  }
  .ticket-card-item:hover {
    box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08) !important;
  }
  .ticket-subject-text {
    word-break: break-word;
    overflow-wrap: break-word;
  }
</style>

<section class="site-hero inner-page overlay" style="background-image: linear-gradient(rgba(0, 0, 0, 0.55), rgba(0, 0, 0, 0.65)), url('${pageContext.request.contextPath}/assets/images/hero_4.jpg'); min-height: 280px; height: 320px;" data-stellar-background-ratio="0.5">
  <div class="container">
    <div class="row site-hero-inner justify-content-center align-items-center" style="min-height: 280px; height: 320px;">
      <div class="col-md-10 text-center" data-aos="fade">
        <h1 class="heading mb-2">Yêu Cầu Hỗ Trợ Của Tôi</h1>
        <ul class="custom-breadcrumbs mb-0">
          <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
          <li>&bullet;</li>
          <li>Hỗ Trợ</li>
          <li>&bullet;</li>
          <li>Danh Sách Yêu Cầu</li>
        </ul>
      </div>
    </div>
  </div>
</section>

<section class="section bg-light py-5">
  <div class="container">

    <c:if test="${not empty param.error}">
      <div class="alert alert-warning alert-dismissible fade show mb-4 shadow-sm" role="alert">
        <i class="fa fa-exclamation-triangle mr-2"></i> <c:out value="${param.error}" />
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
    </c:if>

    <!-- THANH TIÊU ĐỀ & NÚT TẠO MỚI -->
    <div class="d-flex justify-content-between align-items-center flex-wrap mb-4 pb-2">
      <div>
        <h3 class="font-weight-bold text-dark mb-1">Lịch Sử Yêu Cầu Hỗ Trợ</h3>
        <p class="text-muted mb-0 small">Theo dõi trạng thái và trao đổi trực tiếp với Quản trị viên Sogo</p>
      </div>
      <div class="mt-3 mt-sm-0">
        <a href="${pageContext.request.contextPath}/contact" class="btn btn-primary text-white font-weight-bold px-4 py-2 shadow-sm rounded-pill">
          <i class="fa fa-plus mr-1"></i> Tạo Yêu Cầu Mới
        </a>
      </div>
    </div>

    <!-- BỘ LỌC TRẠNG THÁI (STATUS PILLS) -->
    <ul class="nav nav-pills nav-pills-support mb-4">
      <li class="nav-item">
        <a class="nav-link ${empty statusFilter || statusFilter == 'ALL' ? 'active' : ''}" 
           href="${pageContext.request.contextPath}/support/my-tickets?status=ALL">
          Tất cả
        </a>
      </li>
      <li class="nav-item">
        <a class="nav-link ${statusFilter == 'NEW' ? 'active' : ''}" 
           href="${pageContext.request.contextPath}/support/my-tickets?status=NEW">
          Mới gửi
        </a>
      </li>
      <li class="nav-item">
        <a class="nav-link ${statusFilter == 'PROCESSING' ? 'active' : ''}" 
           href="${pageContext.request.contextPath}/support/my-tickets?status=PROCESSING">
          Đang xử lý
        </a>
      </li>
      <li class="nav-item">
        <a class="nav-link ${statusFilter == 'RESOLVED' ? 'active' : ''}" 
           href="${pageContext.request.contextPath}/support/my-tickets?status=RESOLVED">
          Đã giải quyết
        </a>
      </li>
    </ul>

    <!-- DANH SÁCH TICKET -->
    <c:choose>
      <c:when test="${empty tickets}">
        <div class="bg-white rounded p-5 text-center shadow-sm border my-4">
          <div class="text-muted mb-3"><i class="fa fa-folder-open-o fa-4x text-secondary"></i></div>
          <h5 class="font-weight-bold text-dark">Chưa có yêu cầu hỗ trợ nào</h5>
          <p class="text-muted mx-auto mb-4" style="max-width: 480px;">
            <c:choose>
              <c:when test="${statusFilter != 'ALL'}">
                Không tìm thấy yêu cầu hỗ trợ nào phù hợp với trạng thái đã chọn.
              </c:when>
              <c:otherwise>
                Bạn chưa gửi yêu cầu hỗ trợ nào đến ban quản trị. Nếu bạn gặp thắc mắc hoặc cần giải quyết sự cố, hãy gửi yêu cầu ngay.
              </c:otherwise>
            </c:choose>
          </p>
          <a href="${pageContext.request.contextPath}/contact" class="btn btn-outline-primary font-weight-bold px-4 py-2">
            <i class="fa fa-pencil-square-o mr-1"></i> Gửi Yêu Cầu Hỗ Trợ Ngay
          </a>
        </div>
      </c:when>

      <c:otherwise>
        <div class="ticket-list-wrapper">
          <c:forEach items="${tickets}" var="t">
            <div class="card ticket-card-item bg-white border shadow-sm mb-3">
              <div class="card-body p-4">
                <div class="row align-items-center">
                  <!-- Cột thông tin chính -->
                  <div class="col-lg-8 col-md-7 mb-3 mb-md-0">
                    <div class="d-flex align-items-center flex-wrap gap-2 mb-2">
                      <span class="badge badge-light border text-monospace font-weight-bold px-2 py-1">
                        <c:out value="${t.ticketCode}" />
                      </span>
                      <span class="badge badge-secondary px-2 py-1">
                        <c:out value="${t.category.displayName}" />
                      </span>
                      <c:if test="${not empty t.bookingCode}">
                        <span class="badge badge-info px-2 py-1">
                          <i class="fa fa-tag"></i> Booking: <c:out value="${t.bookingCode}" />
                        </span>
                      </c:if>
                    </div>

                    <h5 class="font-weight-bold mb-2 ticket-subject-text">
                      <a href="${pageContext.request.contextPath}/support/ticket?code=${t.ticketCode}" class="text-dark text-decoration-none">
                        <c:out value="${t.subject}" />
                      </a>
                    </h5>

                    <div class="text-muted small d-flex flex-wrap gap-3">
                      <span class="mr-3">
                        <i class="fa fa-calendar-o mr-1"></i> Ngày gửi: 
                        <fmt:formatDate value="${t.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                      </span>
                      <c:if test="${not empty t.updatedAt && t.updatedAt != t.createdAt}">
                        <span class="mr-3">
                          <i class="fa fa-clock-o mr-1"></i> Cập nhật: 
                          <fmt:formatDate value="${t.updatedAt}" pattern="dd/MM/yyyy HH:mm" />
                        </span>
                      </c:if>
                      <span>
                        <i class="fa fa-comments-o mr-1"></i> Phản hồi: <strong>${t.replyCount}</strong>
                      </span>
                    </div>
                  </div>

                  <!-- Cột trạng thái & Hành động -->
                  <div class="col-lg-4 col-md-5 text-md-right d-flex flex-md-column justify-content-between align-items-md-end align-items-center">
                    <div class="mb-md-3">
                      <c:choose>
                        <c:when test="${t.status == 'NEW'}">
                          <span class="ticket-status-badge ticket-status-new">
                            <i class="fa fa-circle" style="font-size: 8px;"></i> Mới tiếp nhận
                          </span>
                        </c:when>
                        <c:when test="${t.status == 'PROCESSING'}">
                          <span class="ticket-status-badge ticket-status-processing">
                            <i class="fa fa-spinner fa-spin" style="font-size: 8px;"></i> Đang xử lý
                          </span>
                        </c:when>
                        <c:when test="${t.status == 'RESOLVED'}">
                          <span class="ticket-status-badge ticket-status-resolved">
                            <i class="fa fa-check-circle"></i> Đã giải quyết
                          </span>
                        </c:when>
                      </c:choose>
                    </div>

                    <div>
                      <a href="${pageContext.request.contextPath}/support/ticket?code=${t.ticketCode}" 
                         class="btn btn-sm btn-outline-primary font-weight-bold px-3 py-2 rounded-pill">
                        Xem Chi Tiết & Trao Đổi <i class="fa fa-arrow-right ml-1"></i>
                      </a>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>

        <!-- PHÂN TRANG (PAGINATION) -->
        <c:if test="${totalPages > 1}">
          <nav aria-label="Ticket pagination" class="mt-4">
            <ul class="pagination justify-content-center">
              <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                <a class="page-link" href="${pageContext.request.contextPath}/support/my-tickets?status=${statusFilter}&page=${currentPage - 1}">
                  <i class="fa fa-angle-left"></i> Trước
                </a>
              </li>
              <c:forEach begin="1" end="${totalPages}" var="p">
                <li class="page-item ${p == currentPage ? 'active' : ''}">
                  <a class="page-link" href="${pageContext.request.contextPath}/support/my-tickets?status=${statusFilter}&page=${p}">
                    ${p}
                  </a>
                </li>
              </c:forEach>
              <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                <a class="page-link" href="${pageContext.request.contextPath}/support/my-tickets?status=${statusFilter}&page=${currentPage + 1}">
                  Sau <i class="fa fa-angle-right"></i>
                </a>
              </li>
            </ul>
          </nav>
        </c:if>

      </c:otherwise>
    </c:choose>

  </div>
</section>

<jsp:include page="common/footer.jsp" />
