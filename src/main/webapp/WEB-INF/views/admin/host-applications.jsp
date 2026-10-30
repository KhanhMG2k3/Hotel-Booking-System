<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Admin flow: filter applications, inspect a submission, and approve or reject it. --%>
<%-- Shared page header and navigation. --%>
<jsp:include page="../common/header.jsp">
  <jsp:param name="pageTitle" value="Host Applications - Sogo Homestay" />
</jsp:include>

<jsp:include page="../common/navbar.jsp" />

<%-- Page content: application filters, results, details, and rejection dialog. --%>
<main id="host-applications-admin" class="section admin-host-applications"
      data-api-base="${pageContext.request.contextPath}/api/admin/partner-applications">
  <div class="container">
    <header class="d-flex flex-wrap justify-content-between align-items-center mb-4 pb-3 border-bottom">
      <div>
        <span class="text-primary font-weight-bold text-uppercase letter-spacing-1">Hệ Thống Quản Trị</span>
        <h1 class="heading mt-2 mb-1" style="font-size: 1.85rem;">Kiểm Tra & Duyệt Hồ Sơ Host</h1>
        <p class="text-muted mb-0">Kiểm tra thông tin chi tiết, hình ảnh, tài liệu CCCD/pháp lý và phòng của khách hàng gửi lên.</p>
      </div>
      <div class="mt-2 mt-md-0">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-primary font-weight-bold" style="border-radius: 8px; padding: 0.5rem 1rem;">
          <i class="fa fa-dashboard mr-1"></i> Về Trang Quản Trị
        </a>
      </div>
    </header>

    <div id="admin-host-alert" class="alert d-none" role="alert" aria-live="polite"></div>

    <%-- Filter and browse submitted Host applications. --%>
    <section id="host-application-list" class="card border-0 shadow-sm">
      <div class="card-body p-4">
        <div class="d-flex flex-wrap justify-content-between align-items-end mb-4 admin-host-filters">
          <div class="form-group mb-2">
            <label for="host-application-status">Filter by status</label>
            <select id="host-application-status" class="form-control">
              <option value="">All submitted applications</option>
              <option value="PENDING">Pending</option>
              <option value="APPROVED">Approved</option>
              <option value="REJECTED">Rejected</option>
            </select>
          </div>
          <div class="form-group mb-2 admin-host-search">
            <label for="host-application-search">Search applications</label>
            <input id="host-application-search" class="form-control" type="search"
                   placeholder="Applicant, email, or property">
          </div>
        </div>

        <div id="host-application-loading" class="text-center py-5" role="status">
          <span class="spinner-border text-primary" aria-hidden="true"></span>
          <p class="text-muted mt-3 mb-0">Loading Host Applications...</p>
        </div>

        <div class="table-responsive">
          <table id="host-application-table" class="table table-hover admin-host-table d-none">
            <thead>
              <tr>
                <th scope="col">Application ID</th>
                <th scope="col">Applicant</th>
                <th scope="col">Email</th>
                <th scope="col">Property</th>
                <th scope="col">Type</th>
                <th scope="col">Submitted</th>
                <th scope="col">Status</th>
                <th scope="col">Actions</th>
              </tr>
            </thead>
            <tbody id="host-application-rows"></tbody>
          </table>
        </div>

        <div id="host-application-empty" class="text-center text-muted py-4 d-none">
          No submitted Host Applications match your search.
        </div>
        <nav id="host-application-pagination" class="d-flex flex-wrap align-items-center justify-content-between mt-3 d-none"
             aria-label="Host application pages">
          <small id="host-application-page-summary" class="text-muted"></small>
          <div class="d-flex admin-host-actions">
            <button id="host-application-prev" class="btn btn-sm btn-outline-secondary"
                    type="button">Previous</button>
            <button id="host-application-next" class="btn btn-sm btn-outline-secondary"
                    type="button">Next</button>
          </div>
        </nav>
      </div>
    </section>

    <%-- Review selected application details and choose an approval outcome. --%>
    <section id="host-application-detail" class="card border-0 shadow-sm mt-4 d-none">
      <div class="card-body p-4 p-md-5">
        <div class="d-flex flex-wrap align-items-start justify-content-between mb-4 pb-3 border-bottom">
          <div>
            <span class="admin-host-kicker">Chi tiết hồ sơ đối tác</span>
            <h2 id="host-detail-title" class="h3 mt-1 mb-0 font-weight-bold text-dark"></h2>
          </div>
          <div class="d-flex align-items-center gap-2">
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-primary font-weight-bold mr-2" style="border-radius: 6px; padding: 0.4rem 0.9rem;">
              <i class="fa fa-arrow-left mr-1"></i> Về Trang Quản Trị
            </a>
            <button id="host-detail-close" class="btn btn-outline-secondary font-weight-bold" type="button" style="border-radius: 6px; padding: 0.4rem 0.9rem;">
              <i class="fa fa-list mr-1"></i> Danh sách tất cả đơn
            </button>
          </div>
        </div>
        <div id="host-detail-loading" class="text-center py-4 d-none" role="status">
          <span class="spinner-border spinner-border-sm text-primary" aria-hidden="true"></span>
          <span class="ml-2">Loading application details...</span>
        </div>
        <div id="host-detail-content"></div>
        <div class="d-flex flex-wrap admin-host-actions mt-4 align-items-center pt-3 border-top">
          <button id="host-detail-approve" class="btn btn-success font-weight-bold d-none" type="button" style="border-radius: 8px; padding: 0.55rem 1.4rem; font-size: 1rem;">
            <i class="fa fa-check mr-1"></i> Duyệt Đơn & Cấp Quyền Host
          </button>
          <button id="host-detail-reject" class="btn btn-outline-danger font-weight-bold d-none" type="button" style="border-radius: 8px; padding: 0.55rem 1.4rem; font-size: 1rem;">
            <i class="fa fa-times mr-1"></i> Từ Chối Đơn
          </button>
        </div>
      </div>
    </section>
  </div>
</main>

<%-- Collect a required reason when rejecting an application. --%>
<div id="host-reject-dialog" class="admin-host-dialog d-none" role="dialog"
     aria-modal="true" aria-labelledby="host-reject-title">
  <div class="admin-host-dialog-backdrop" data-dialog-close></div>
  <section class="admin-host-dialog-card">
    <div class="d-flex justify-content-between align-items-center mb-3">
      <h2 id="host-reject-title" class="h4 mb-0">Reject Host Application</h2>
      <button class="close" type="button" aria-label="Close" data-dialog-close>
        <span aria-hidden="true">&times;</span>
      </button>
    </div>
    <label for="host-rejection-reason">Rejection Reason <span class="text-danger">*</span></label>
    <textarea id="host-rejection-reason" class="form-control" rows="5"
              minlength="10" maxlength="500" required></textarea>
    <small class="form-text text-muted">Enter 10 to 500 characters.</small>
    <div class="d-flex justify-content-end admin-host-actions mt-4">
      <button id="host-reject-cancel" class="btn btn-outline-secondary" type="button">Cancel</button>
      <button id="host-reject-confirm" class="btn btn-danger" type="button">Reject Application</button>
    </div>
  </section>
</div>

<%-- Page-specific layout styles. --%>
<style>
  .admin-host-filters { gap: 1rem; }
  .admin-host-search { flex: 1 1 300px; max-width: 480px; }
  .admin-host-actions { gap: .65rem; }
  .admin-host-table th { white-space: nowrap; }
  .admin-host-kicker { color: #b0874e; font-size: .78rem; font-weight: 700; letter-spacing: .1em; text-transform: uppercase; }
  .admin-host-badge { border-radius: 20px; display: inline-block; font-size: .75rem; font-weight: 700; padding: .35rem .65rem; text-transform: capitalize; }
  .admin-host-badge.pending { background: #fff3cd; color: #856404; }
  .admin-host-badge.approved { background: #d4edda; color: #155724; }
  .admin-host-badge.rejected { background: #f8d7da; color: #721c24; }
  .admin-host-detail-section { border-bottom: 1px solid #e8e8e8; margin-bottom: 1.5rem; padding-bottom: 1.25rem; }
  .admin-host-detail-section:last-child { border-bottom: 0; }
  .admin-host-detail-list dt { color: #6c757d; }
  .admin-host-detail-list dd { overflow-wrap: anywhere; }
  .admin-host-room { border: 1px solid #e8e8e8; border-radius: 4px; margin-bottom: 1rem; padding: 1rem; }
  .admin-host-images { display: flex; flex-wrap: wrap; gap: .75rem; }
  .admin-host-images img, .admin-host-images video { border-radius: 4px; height: 110px; object-fit: cover; width: 145px; }
  .admin-host-document { display: inline-block; margin: 0 .75rem .5rem 0; }
  .admin-host-dialog { align-items: center; display: flex; inset: 0; justify-content: center; padding: 1rem; position: fixed; z-index: 1100; }
  .admin-host-dialog-backdrop { background: rgba(0, 0, 0, .55); inset: 0; position: absolute; }
  .admin-host-dialog-card { background: #fff; border-radius: 5px; max-width: 540px; padding: 1.5rem; position: relative; width: 100%; }
  @media (max-width: 575.98px) {
    .admin-host-filters, .admin-host-search { max-width: none; width: 100%; }
    #host-application-pagination { gap: .75rem; }
  }
</style>

<%-- Load application interactions, then render the shared footer. --%>
<script src="${pageContext.request.contextPath}/assets/js/admin-host-applications.js"></script>
<jsp:include page="../common/footer.jsp" />
