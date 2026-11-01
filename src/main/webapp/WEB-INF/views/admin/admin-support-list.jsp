<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="../common/header.jsp">
    <jsp:param name="pageTitle" value="Quản Lý Yêu Cầu Hỗ Trợ - Sogo Homestay" />
</jsp:include>

<jsp:include page="../common/navbar.jsp" />

<style>
    .site-header {
        background: #ffffff !important;
        padding: 15px 0 !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.06) !important;
    }
    .site-header .site-logo a,
    .site-header .user-name,
    .site-header .user-caret,
    .site-header .auth-link:not(.auth-link-primary) {
        color: #1a1a1a !important;
    }
    .admin-support-wrap {
        padding-top: 110px;
        padding-bottom: 80px;
        background: #f4f6fb;
        min-height: 85vh;
        font-family: 'Roboto Sans', sans-serif;
    }
    .page-kpi-card {
        background: #ffffff;
        border-radius: 12px;
        padding: 1.25rem 1.5rem;
        box-shadow: 0 4px 14px rgba(0,0,0,0.04);
        border: 1px solid rgba(0,0,0,0.05);
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 1.25rem;
        transition: transform 0.15s ease;
        text-decoration: none !important;
    }
    .page-kpi-card:hover {
        transform: translateY(-2px);
    }
    .kpi-title {
        font-size: 0.8rem;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        font-weight: 700;
        color: #718096;
        margin-bottom: 0.25rem;
    }
    .kpi-number {
        font-size: 1.85rem;
        font-weight: 700;
        color: #1a202c;
        line-height: 1.1;
    }
    .kpi-icon {
        width: 48px;
        height: 48px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.35rem;
    }
    .kpi-icon-total { background: #e0f2fe; color: #0284c7; }
    .kpi-icon-new { background: #fef3c7; color: #d97706; }
    .kpi-icon-proc { background: #e0e7ff; color: #4f46e5; }
    .kpi-icon-res { background: #dcfce7; color: #16a34a; }

    .support-filter-card {
        background: #ffffff;
        border-radius: 12px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.04);
        border: 1px solid rgba(0,0,0,0.05);
        padding: 1.25rem;
        margin-bottom: 1.5rem;
    }
    .table-support {
        background: #ffffff;
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 4px 16px rgba(0,0,0,0.04);
        border: 1px solid rgba(0,0,0,0.05);
        width: 100%;
    }
    .table-support .table-responsive {
        margin-bottom: 0;
        overflow-x: auto;
    }
    .table-support table {
        table-layout: fixed;
        width: 100%;
        margin-bottom: 0;
    }
    .table-support thead th {
        background: #f8fafc;
        color: #475569;
        font-size: 0.78rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        padding: 0.85rem 0.65rem;
        border-bottom: 2px solid #e2e8f0;
        vertical-align: middle;
        white-space: nowrap !important;
    }
    .table-support tbody td {
        padding: 0.85rem 0.65rem;
        vertical-align: middle;
        border-bottom: 1px solid #f1f5f9;
        font-size: 0.88rem;
    }
    .table-support tbody tr:hover {
        background: #fbfcfe;
    }
    .badge-status-new {
        background: #fffbeb;
        color: #b45309;
        border: 1px solid #fef3c7;
        font-weight: 700;
        padding: 5px 10px;
        border-radius: 50px;
        font-size: 0.76rem;
        white-space: nowrap !important;
        display: inline-flex !important;
        align-items: center;
        justify-content: center;
        gap: 5px;
        line-height: 1;
    }
    .badge-status-proc {
        background: #eff6ff;
        color: #1d4ed8;
        border: 1px solid #dbeafe;
        font-weight: 700;
        padding: 5px 10px;
        border-radius: 50px;
        font-size: 0.76rem;
        white-space: nowrap !important;
        display: inline-flex !important;
        align-items: center;
        justify-content: center;
        gap: 5px;
        line-height: 1;
    }
    .badge-status-res {
        background: #f0fdf4;
        color: #15803d;
        border: 1px solid #dcfce7;
        font-weight: 700;
        padding: 5px 10px;
        border-radius: 50px;
        font-size: 0.76rem;
        white-space: nowrap !important;
        display: inline-flex !important;
        align-items: center;
        justify-content: center;
        gap: 5px;
        line-height: 1;
    }
    .badge-role-customer {
        background: #e0f2fe;
        color: #0369a1;
        font-size: 0.72rem;
        padding: 2px 7px;
        border-radius: 4px;
        font-weight: 600;
        white-space: nowrap !important;
        display: inline-block;
    }
    .badge-role-host {
        background: #fef3c7;
        color: #b45309;
        font-size: 0.72rem;
        padding: 2px 7px;
        border-radius: 4px;
        font-weight: 600;
        white-space: nowrap !important;
        display: inline-block;
    }
    .badge-role-admin {
        background: #fee2e2;
        color: #b91c1c;
        font-size: 0.72rem;
        padding: 2px 7px;
        border-radius: 4px;
        font-weight: 600;
        white-space: nowrap !important;
        display: inline-block;
    }
    .ticket-code-link {
        font-family: monospace;
        font-weight: 700;
        color: #0284c7;
        font-size: 0.88rem;
        white-space: nowrap !important;
        display: inline-block;
    }
    .ticket-code-link:hover {
        text-decoration: underline;
        color: #0369a1;
    }
    .btn-action-view {
        background: #f1f5f9;
        color: #334155;
        border: 1px solid #cbd5e1;
        font-weight: 600;
        font-size: 0.8rem;
        padding: 0.35rem 0.65rem;
        border-radius: 6px;
        transition: all 0.15s ease;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 4px;
        white-space: nowrap !important;
        text-decoration: none !important;
    }
    .btn-action-view:hover {
        background: #0284c7;
        color: #ffffff;
        border-color: #0284c7;
    }
    .btn-action-view:hover {
        background: #0284c7;
        color: #ffffff;
        border-color: #0284c7;
    }
</style>

<div class="admin-support-wrap">
    <div class="container-fluid" style="max-width: 1400px;">

        <!-- Top Breadcrumb & Heading -->
        <div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
            <div>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb bg-transparent p-0 mb-1" style="font-size: 0.85rem;">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard" class="text-muted"><i class="fa fa-dashboard mr-1"></i>Trang Quản Trị</a></li>
                        <li class="breadcrumb-item active text-dark font-weight-bold" aria-current="page">Quản Lý Yêu Cầu Hỗ Trợ</li>
                    </ol>
                </nav>
                <h1 class="h3 font-weight-bold text-dark mb-1">
                    <i class="fa fa-life-ring text-danger mr-2"></i>Quản Lý Yêu Cầu Hỗ Trợ (Support Tickets)
                </h1>
                <p class="text-muted small mb-0">Tiếp nhận, xử lý và phản hồi yêu cầu hỗ trợ từ Khách hàng và Đối tác Host</p>
            </div>
            <div class="mt-2 mt-md-0">
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-secondary btn-sm font-weight-bold">
                    <i class="fa fa-arrow-left mr-1"></i> Quay lại Dashboard
                </a>
            </div>
        </div>

        <!-- Flash Notification Messages -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
                <i class="fa fa-check-circle mr-1"></i> <strong>Thành công:</strong> <c:out value="${successMessage}" />
                <button type="button" class="close" data-dismiss="alert">&times;</button>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                <i class="fa fa-exclamation-triangle mr-1"></i> <strong>Lưu ý:</strong> <c:out value="${errorMessage}" />
                <button type="button" class="close" data-dismiss="alert">&times;</button>
            </div>
        </c:if>

        <!-- KPI Summary Cards -->
        <div class="row">
            <div class="col-12 col-sm-6 col-lg-3">
                <a href="${pageContext.request.contextPath}/admin/support?status=ALL" class="page-kpi-card">
                    <div>
                        <div class="kpi-title">Tổng số yêu cầu</div>
                        <div class="kpi-number">${kpiStats['TOTAL'] != null ? kpiStats['TOTAL'] : 0}</div>
                    </div>
                    <div class="kpi-icon kpi-icon-total">
                        <i class="fa fa-inbox"></i>
                    </div>
                </a>
            </div>
            <div class="col-12 col-sm-6 col-lg-3">
                <a href="${pageContext.request.contextPath}/admin/support?status=NEW" class="page-kpi-card">
                    <div>
                        <div class="kpi-title text-warning">Chờ tiếp nhận (NEW)</div>
                        <div class="kpi-number text-warning">${kpiStats['NEW'] != null ? kpiStats['NEW'] : 0}</div>
                    </div>
                    <div class="kpi-icon kpi-icon-new">
                        <i class="fa fa-clock-o"></i>
                    </div>
                </a>
            </div>
            <div class="col-12 col-sm-6 col-lg-3">
                <a href="${pageContext.request.contextPath}/admin/support?status=PROCESSING" class="page-kpi-card">
                    <div>
                        <div class="kpi-title text-primary">Đang xử lý (PROCESSING)</div>
                        <div class="kpi-number text-primary">${kpiStats['PROCESSING'] != null ? kpiStats['PROCESSING'] : 0}</div>
                    </div>
                    <div class="kpi-icon kpi-icon-proc">
                        <i class="fa fa-spinner"></i>
                    </div>
                </a>
            </div>
            <div class="col-12 col-sm-6 col-lg-3">
                <a href="${pageContext.request.contextPath}/admin/support?status=RESOLVED" class="page-kpi-card">
                    <div>
                        <div class="kpi-title text-success">Đã giải quyết (RESOLVED)</div>
                        <div class="kpi-number text-success">${kpiStats['RESOLVED'] != null ? kpiStats['RESOLVED'] : 0}</div>
                    </div>
                    <div class="kpi-icon kpi-icon-res">
                        <i class="fa fa-check-circle"></i>
                    </div>
                </a>
            </div>
        </div>

                <!-- Filter & Search Toolbar -->
        <div class="support-filter-card">
            <form method="get" action="${pageContext.request.contextPath}/admin/support" class="form-row align-items-end">
                
                <!-- 1. Từ khóa tìm kiếm: đổi sang col-md-3 -->
                <div class="form-group col-12 col-md-3 mb-2">
                    <label class="small font-weight-bold text-muted mb-1"><i class="fa fa-search mr-1"></i>Từ khóa tìm kiếm</label>
                    <input type="text" name="search" class="form-control form-control-sm"
                           value="<c:out value="${searchKeyword}" />"
                           placeholder="Mã ticket, họ tên, email, tiêu đề...">
                </div>

                <!-- 2. Trạng thái: giữ col-md-2 -->
                <div class="form-group col-6 col-md-2 mb-2">
                    <label class="small font-weight-bold text-muted mb-1"><i class="fa fa-filter mr-1"></i>Trạng thái</label>
                    <select name="status" class="form-control form-control-sm">
                        <option value="ALL" ${statusFilter == 'ALL' ? 'selected' : ''}>-- Tất cả --</option>
                        <c:forEach var="st" items="${statuses}">
                            <option value="${st.name()}" ${statusFilter == st.name() ? 'selected' : ''}>${st.displayName}</option>
                        </c:forEach>
                    </select>
                </div>

                <!-- 3. Chuyên mục: giữ col-md-2 -->
                <div class="form-group col-6 col-md-2 mb-2">
                    <label class="small font-weight-bold text-muted mb-1"><i class="fa fa-tags mr-1"></i>Chuyên mục</label>
                    <select name="category" class="form-control form-control-sm">
                        <option value="ALL" ${categoryFilter == 'ALL' ? 'selected' : ''}>-- Tất cả --</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.name()}" ${categoryFilter == cat.name() ? 'selected' : ''}>${cat.displayName}</option>
                        </c:forEach>
                    </select>
                </div>

                <!-- 4. Sắp xếp: giữ col-md-2 -->
                <div class="form-group col-6 col-md-2 mb-2">
                    <label class="small font-weight-bold text-muted mb-1"><i class="fa fa-sort mr-1"></i>Sắp xếp</label>
                    <select name="sortBy" class="form-control form-control-sm">
                        <option value="updated_at" ${sortBy == 'updated_at' ? 'selected' : ''}>Mới cập nhật</option>
                        <option value="created_at" ${sortBy == 'created_at' ? 'selected' : ''}>Ngày gửi yêu cầu</option>
                        <option value="status" ${sortBy == 'status' ? 'selected' : ''}>Trạng thái</option>
                        <option value="category" ${sortBy == 'category' ? 'selected' : ''}>Chuyên mục</option>
                    </select>
                </div>

                <!-- 5. Thứ tự: giữ col-md-1 -->
                <div class="form-group col-6 col-md-1 mb-2">
                    <label class="small font-weight-bold text-muted mb-1">Thứ tự</label>
                    <select name="sortOrder" class="form-control form-control-sm">
                        <option value="DESC" ${sortOrder == 'DESC' ? 'selected' : ''}>Giảm dần</option>
                        <option value="ASC" ${sortOrder == 'ASC' ? 'selected' : ''}>Tăng dần</option>
                    </select>
                </div>

                <!-- 6. Cụm nút bấm: tăng lên col-md-2 để đủ chỗ cho cả 2 nút -->
                <div class="form-group col-12 col-md-2 mb-2 d-flex">
                    <button type="submit" class="btn btn-primary btn-sm flex-fill font-weight-bold mr-1" title="Lọc dữ liệu">
                        <i class="fa fa-filter mr-1"></i> Lọc
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/support" class="btn btn-outline-secondary btn-sm" title="Đặt lại bộ lọc" style="width: 36px; display: inline-flex; align-items: center; justify-content: center;">
                        <i class="fa fa-refresh"></i>
                    </a>
                </div>
            </form>
        </div>

        <!-- Support Tickets Data Table -->
        <div class="table-support">
            <c:choose>
                <c:when test="${empty tickets}">
                    <div class="text-center py-5">
                        <div class="text-muted mb-3" style="font-size: 3rem;"><i class="fa fa-inbox"></i></div>
                        <h5 class="font-weight-bold text-dark">Không tìm thấy yêu cầu hỗ trợ nào</h5>
                        <p class="text-muted small mb-3">Không có bản ghi nào phù hợp với bộ lọc tìm kiếm hiện tại.</p>
                        <a href="${pageContext.request.contextPath}/admin/support" class="btn btn-sm btn-outline-primary">
                            <i class="fa fa-refresh mr-1"></i> Đặt lại bộ lọc
                        </a>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th style="width: 13%;">Mã Yêu Cầu</th>
                                    <th style="width: 16%;">Người Gửi</th>
                                    <th style="width: 12%;">Chuyên Mục</th>
                                    <th style="width: 23%;">Tiêu Đề</th>
                                    <th style="width: 12%;" class="text-center">Trạng Thái</th>
                                    <th style="width: 6%;" class="text-center">Phản Hồi</th>
                                    <th style="width: 10%;">Cập Nhật</th>
                                    <th style="width: 8%;" class="text-center">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="t" items="${tickets}">
                                    <tr>
                                        <td style="white-space: nowrap;">
                                            <a href="${pageContext.request.contextPath}/admin/support/detail?id=${t.messageId}" class="ticket-code-link">
                                                <c:out value="${t.ticketCode}" />
                                            </a>
                                            <c:if test="${not empty t.bookingCode}">
                                                <div class="small text-muted" title="Mã đặt phòng liên quan" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                                    <i class="fa fa-bookmark-o text-info mr-1"></i><c:out value="${t.bookingCode}" />
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <div class="font-weight-bold text-dark text-truncate" title="<c:out value="${t.fullName}" />">
                                                <c:out value="${t.fullName}" />
                                            </div>
                                            <div class="small text-muted text-truncate" title="<c:out value="${t.email}" />">
                                                <c:out value="${t.email}" />
                                            </div>
                                            <c:choose>
                                                <c:when test="${t.senderRole == 'ROLE_HOST' || t.senderRole == 'HOST'}">
                                                    <span class="badge-role-host"><i class="fa fa-home mr-1"></i>Host</span>
                                                </c:when>
                                                <c:when test="${t.senderRole == 'ROLE_ADMIN' || t.senderRole == 'ADMIN'}">
                                                    <span class="badge-role-admin"><i class="fa fa-shield mr-1"></i>Admin</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-role-customer"><i class="fa fa-user mr-1"></i>Khách hàng</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="badge badge-light border text-secondary font-weight-normal py-1 px-2 d-inline-block text-truncate" style="max-width: 100%; font-size: 0.78rem;" title="<c:out value="${t.category != null ? t.category.displayName : t.categoryCode}" />">
                                                <c:out value="${t.category != null ? t.category.displayName : t.categoryCode}" />
                                            </span>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/admin/support/detail?id=${t.messageId}" class="text-dark font-weight-bold text-decoration-none d-block text-truncate" title="<c:out value="${t.subject}" />">
                                                <c:out value="${t.subject}" />
                                            </a>
                                            <div class="small text-muted text-truncate" title="<c:out value="${t.message}" />">
                                                <c:out value="${t.message}" />
                                            </div>
                                        </td>
                                        <td class="text-center" style="white-space: nowrap;">
                                            <c:choose>
                                                <c:when test="${t.status == 'NEW'}">
                                                    <span class="badge-status-new"><i class="fa fa-dot-circle-o mr-1"></i>Mới tạo</span>
                                                </c:when>
                                                <c:when test="${t.status == 'PROCESSING'}">
                                                    <span class="badge-status-proc"><i class="fa fa-spinner fa-spin mr-1"></i>Đang xử lý</span>
                                                </c:when>
                                                <c:when test="${t.status == 'RESOLVED'}">
                                                    <span class="badge-status-res"><i class="fa fa-check-circle mr-1"></i>Đã giải quyết</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-secondary"><c:out value="${t.status}" /></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center font-weight-bold text-muted" style="white-space: nowrap;">
                                            <c:choose>
                                                <c:when test="${t.replyCount > 0}">
                                                    <span class="badge badge-primary px-2 py-1"><i class="fa fa-comments mr-1"></i>${t.replyCount}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-light border text-muted px-2 py-1">0</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <div class="small font-weight-bold text-dark">
                                                <fmt:formatDate value="${t.updatedAt}" pattern="dd/MM/yyyy" />
                                            </div>
                                            <div class="small text-muted" title="Thời gian cập nhật">
                                                <fmt:formatDate value="${t.updatedAt}" pattern="HH:mm" />
                                            </div>
                                        </td>
                                        <td class="text-center" style="white-space: nowrap;">
                                            <a href="${pageContext.request.contextPath}/admin/support/detail?id=${t.messageId}" class="btn-action-view" title="Xem chi tiết và xử lý">
                                                <span>Chi tiết</span> <i class="fa fa-chevron-right ml-1"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>

            <!-- Table Footer with Pagination Controls -->
            <c:if test="${totalPages > 1}">
                <div class="d-flex flex-wrap justify-content-between align-items-center p-3 border-top bg-light">
                    <div class="small text-muted mb-2 mb-md-0">
                        Hiển thị trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong> (Tổng cộng <strong>${totalTickets}</strong> yêu cầu)
                    </div>
                    <nav aria-label="Phân trang danh sách hỗ trợ">
                        <ul class="pagination pagination-sm mb-0">
                            <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/admin/support?page=${currentPage - 1}&status=${statusFilter}&category=${categoryFilter}&search=<c:out value="${searchKeyword}" />&sortBy=${sortBy}&sortOrder=${sortOrder}">
                                    <i class="fa fa-angle-left"></i> Trước
                                </a>
                            </li>

                            <c:forEach var="p" begin="1" end="${totalPages}">
                                <c:if test="${p >= currentPage - 2 && p <= currentPage + 2}">
                                    <li class="page-item ${p == currentPage ? 'active' : ''}">
                                        <a class="page-link" href="${pageContext.request.contextPath}/admin/support?page=${p}&status=${statusFilter}&category=${categoryFilter}&search=<c:out value="${searchKeyword}" />&sortBy=${sortBy}&sortOrder=${sortOrder}">${p}</a>
                                    </li>
                                </c:if>
                            </c:forEach>

                            <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/admin/support?page=${currentPage + 1}&status=${statusFilter}&category=${categoryFilter}&search=<c:out value="${searchKeyword}" />&sortBy=${sortBy}&sortOrder=${sortOrder}">
                                    Sau <i class="fa fa-angle-right"></i>
                                </a>
                            </li>
                        </ul>
                    </nav>
                </div>
            </c:if>
        </div>

    </div>
</div>

<jsp:include page="../common/footer.jsp" />
