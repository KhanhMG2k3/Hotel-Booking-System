<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="../common/header.jsp">
    <jsp:param name="pageTitle" value="Chi Tiết Yêu Cầu ${ticket.ticketCode} - Sogo Homestay" />
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
    .admin-detail-wrap {
        padding-top: 110px;
        padding-bottom: 80px;
        background: #f4f6fb;
        min-height: 85vh;
        font-family: 'Roboto Sans', sans-serif;
    }
    .card-box {
        background: #ffffff;
        border-radius: 12px;
        box-shadow: 0 2px 12px rgba(0,0,0,0.04);
        border: 1px solid rgba(0,0,0,0.05);
        margin-bottom: 1.5rem;
        overflow: hidden;
    }
    .card-box-header {
        padding: 1rem 1.25rem;
        border-bottom: 1px solid #f1f5f9;
        background: #fafbfd;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .card-box-body {
        padding: 1.25rem;
    }
    .badge-status-new {
        background: #fffbeb;
        color: #b45309;
        border: 1px solid #fef3c7;
        font-weight: 700;
        padding: 6px 14px;
        border-radius: 50px;
        font-size: 0.85rem;
        white-space: nowrap !important;
        display: inline-flex !important;
        align-items: center;
        gap: 6px;
    }
    .badge-status-proc {
        background: #eff6ff;
        color: #1d4ed8;
        border: 1px solid #dbeafe;
        font-weight: 700;
        padding: 6px 14px;
        border-radius: 50px;
        font-size: 0.85rem;
        white-space: nowrap !important;
        display: inline-flex !important;
        align-items: center;
        gap: 6px;
    }
    .badge-status-res {
        background: #f0fdf4;
        color: #15803d;
        border: 1px solid #dcfce7;
        font-weight: 700;
        padding: 6px 14px;
        border-radius: 50px;
        font-size: 0.85rem;
        white-space: nowrap !important;
        display: inline-flex !important;
        align-items: center;
        gap: 6px;
    }

    /* Reply Timeline Styles */
    .timeline-item {
        border-left: 3px solid #e2e8f0;
        padding-left: 1.25rem;
        margin-left: 0.75rem;
        margin-bottom: 1.5rem;
        position: relative;
    }
    .timeline-item:last-child {
        margin-bottom: 0.5rem;
    }
    .timeline-item::before {
        content: '';
        position: absolute;
        left: -8px;
        top: 4px;
        width: 13px;
        height: 13px;
        border-radius: 50%;
        background: #94a3b8;
        border: 2px solid #ffffff;
    }
    .timeline-admin {
        border-left-color: #3b82f6;
    }
    .timeline-admin::before {
        background: #3b82f6;
    }
     .timeline-content-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 0.85rem 1.15rem;
        box-shadow: 0 1px 4px rgba(0,0,0,0.03);
        display: inline-block;
        width: fit-content;
        min-width: 290px;
        max-width: 100%;
    }
    .timeline-admin .timeline-content-card {
        background: #f8faff;
        border-color: #dbeafe;
    }
    .original-msg-box {
        background: #f8fafc;
        border-left: 4px solid #0284c7;
        padding: 1rem 1.25rem;
        border-radius: 0 8px 8px 0;
        font-size: 0.95rem;
        line-height: 1.6;
        white-space: pre-wrap;
        word-break: break-word;
        display: inline-block;
        width: fit-content;
        max-width: 100%;
    }
    .reply-text {
        white-space: pre-wrap;
        word-break: break-word;
        font-size: 0.92rem;
        line-height: 1.6;
        color: #334155;
        margin-top: 6px;
    }
    
    .sender-avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: #e2e8f0;
        color: #475569;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-weight: 700;
        font-size: 1.1rem;
    }
    .sender-avatar-admin {
        background: #eff6ff;
        color: #1d4ed8;
    }
    /* CHONG TRAN NGANG TREN VIEWPORT NHO 320PX - 575PX CHO THE TIN NHAN TIMELINE (DOT 6) */
    @media (max-width: 575.98px) {
        .timeline-content-card {
            min-width: 0;
            width: 100%;
        }
        .admin-detail-wrap {
            padding-top: 90px;
            padding-bottom: 50px;
        }
        .card-box-body, .card-box-header {
            padding: 0.9rem 1rem;
        }
    }
</style>

<div class="admin-detail-wrap">
    <div class="container-fluid" style="max-width: 1300px;">

        <!-- Top Breadcrumb & Actions Bar -->
        <div class="d-flex flex-wrap justify-content-between align-items-center mb-3">
            <div>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb bg-transparent p-0 mb-1" style="font-size: 0.85rem;">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard" class="text-muted"><i class="fa fa-dashboard mr-1"></i>Trang Quản Trị</a></li>
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/support" class="text-muted">Quản Lý Hỗ Trợ</a></li>
                        <li class="breadcrumb-item active text-dark font-weight-bold" aria-current="page"><c:out value="${ticket.ticketCode}" /></li>
                    </ol>
                </nav>
                <div class="d-flex align-items-center flex-wrap gap-2">
                    <h1 class="h3 font-weight-bold text-dark mb-0 mr-3">
                        <i class="fa fa-ticket text-primary mr-1"></i>Yêu Cầu #<c:out value="${ticket.ticketCode}" />
                    </h1>
                    <c:choose>
                        <c:when test="${ticket.status == 'NEW'}">
                            <span class="badge-status-new"><i class="fa fa-dot-circle-o mr-1"></i>MỚI TIẾP NHẬN</span>
                        </c:when>
                        <c:when test="${ticket.status == 'PROCESSING'}">
                            <span class="badge-status-proc"><i class="fa fa-spinner fa-spin mr-1"></i>ĐANG XỬ LÝ</span>
                        </c:when>
                        <c:when test="${ticket.status == 'RESOLVED'}">
                            <span class="badge-status-res"><i class="fa fa-check-circle mr-1"></i>ĐÃ GIẢI QUYẾT</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge badge-secondary py-2 px-3"><c:out value="${ticket.status}" /></span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Action Transition Buttons (Optimistic Concurrency Guarded) -->
            <div class="mt-3 mt-md-0 d-flex flex-wrap gap-2">
                <a href="${pageContext.request.contextPath}/admin/support" class="btn btn-outline-secondary font-weight-bold mr-2">
                    <i class="fa fa-arrow-left mr-1"></i> Quay lại danh sách
                </a>

                <c:if test="${ticket.status == 'NEW'}">
                    <form method="post" action="${pageContext.request.contextPath}/admin/support/status" class="d-inline"
                          onsubmit="return confirm('Bạn có chắc chắn muốn TIẾP NHẬN xử lý yêu cầu hỗ trợ này?');">
                        <input type="hidden" name="csrfToken" value="${csrfToken}">
                        <input type="hidden" name="ticketId" value="${ticket.messageId}">
                        <input type="hidden" name="expectedStatus" value="${ticket.status.name()}">
                        <input type="hidden" name="newStatus" value="PROCESSING">
                        <button type="submit" class="btn btn-primary font-weight-bold shadow-sm">
                            <i class="fa fa-play mr-1"></i> Tiếp nhận xử lý (PROCESSING)
                        </button>
                    </form>
                </c:if>

                <c:if test="${ticket.status == 'PROCESSING'}">
                    <form method="post" action="${pageContext.request.contextPath}/admin/support/status" class="d-inline"
                          onsubmit="return confirm('Bạn có chắc chắn muốn xác nhận ĐÃ GIẢI QUYẾT yêu cầu hỗ trợ này?');">
                        <input type="hidden" name="csrfToken" value="${csrfToken}">
                        <input type="hidden" name="ticketId" value="${ticket.messageId}">
                        <input type="hidden" name="expectedStatus" value="${ticket.status.name()}">
                        <input type="hidden" name="newStatus" value="RESOLVED">
                        <button type="submit" class="btn btn-success font-weight-bold shadow-sm">
                            <i class="fa fa-check-circle mr-1"></i> Đánh dấu đã giải quyết (RESOLVED)
                        </button>
                    </form>
                </c:if>

                <c:if test="${ticket.status == 'RESOLVED'}">
                    <form method="post" action="${pageContext.request.contextPath}/admin/support/status" class="d-inline"
                          onsubmit="return confirm('Bạn có muốn MỞ LẠI trạng thái Đang xử lý cho yêu cầu này?');">
                        <input type="hidden" name="csrfToken" value="${csrfToken}">
                        <input type="hidden" name="ticketId" value="${ticket.messageId}">
                        <input type="hidden" name="expectedStatus" value="${ticket.status.name()}">
                        <input type="hidden" name="newStatus" value="PROCESSING">
                        <button type="submit" class="btn btn-warning text-white font-weight-bold shadow-sm">
                            <i class="fa fa-undo mr-1"></i> Mở lại xử lý (PROCESSING)
                        </button>
                    </form>
                </c:if>
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
                <i class="fa fa-exclamation-triangle mr-1"></i> <strong>Cảnh báo:</strong> <c:out value="${errorMessage}" />
                <button type="button" class="close" data-dismiss="alert">&times;</button>
            </div>
        </c:if>

        <!-- Main Content 2-Column Grid -->
        <div class="row">

            <!-- Left Column: Thread & Reply Form (8 cols) -->
            <div class="col-12 col-lg-8">

                <!-- 1. Original Support Request Box -->
                <div class="card-box">
                    <div class="card-box-header">
                        <div>
                            <span class="badge badge-primary px-2 py-1 mr-2">Yêu Cầu Ban Đầu</span>
                            <span class="badge badge-light border text-secondary">
                                <i class="fa fa-tag mr-1"></i><c:out value="${ticket.category != null ? ticket.category.displayName : ticket.categoryCode}" />
                            </span>
                        </div>
                        <div class="small text-muted">
                            <i class="fa fa-clock-o mr-1"></i>
                            <fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm:ss" />
                        </div>
                    </div>
                    <div class="card-box-body">
                        <h4 class="font-weight-bold text-dark mb-3"><c:out value="${ticket.subject}" /></h4>
                        <div class="original-msg-box"><c:out value="${fn:trim(ticket.message)}" /></div>
                    </div>
                </div>

                <!-- 2. Message History / Thread Timeline -->
                <div class="card-box">
                    <div class="card-box-header">
                        <div class="font-weight-bold text-dark">
                            <i class="fa fa-comments text-info mr-1"></i> Lịch Sử Trao Đổi
                            <span class="badge badge-pill badge-light border ml-1">${not empty ticket.replies ? fn:length(ticket.replies) : 0} tin nhắn</span>
                        </div>
                        <div class="small text-muted">Sắp xếp theo thứ tự thời gian</div>
                    </div>
                    <div class="card-box-body">
                        <c:choose>
                            <c:when test="${empty ticket.replies}">
                                <div class="text-center py-4 text-muted">
                                    <i class="fa fa-commenting-o mb-2" style="font-size: 2rem;"></i>
                                    <p class="small mb-0">Chưa có phản hồi nào cho yêu cầu này. Hãy gửi phản hồi bên dưới để hỗ trợ người dùng.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="timeline-wrap">
                                    <div class="timeline-wrap">
                                        <c:forEach var="reply" items="${ticket.replies}">
                                            <c:set var="isAdminReply" value="${reply.senderRole == 'ROLE_ADMIN' || reply.senderRole == 'ADMIN'}" />
                                            <%-- <div class="timeline-item ${isAdminReply ? 'timeline-admin' : ''}"> --%>
                                            <%-- BO SUNG ID ANCHOR CHO TUNG PHAN HOI DE LINK THONG BAO (#reply-{replyId}) CUON DEN DUNG TIN NHAN (DOT 5) --%>
                                            <div id="reply-${reply.replyId}" class="timeline-item ${isAdminReply ? 'timeline-admin' : ''}">
                                                <div class="timeline-content-card">
                                                    <div class="d-flex justify-content-between align-items-center mb-2 pb-1 border-bottom">
                                                        <div class="d-flex align-items-center">
                                                            <div class="sender-avatar mr-2 ${isAdminReply ? 'sender-avatar-admin' : ''}">
                                                                <i class="fa ${isAdminReply ? 'fa-shield' : 'fa-user'}"></i>
                                                            </div>
                                                            <div>
                                                                <span class="font-weight-bold text-dark">
                                                                    <c:out value="${not empty reply.senderName ? reply.senderName : 'Quản trị viên'}" />
                                                                </span>
                                                                <c:choose>
                                                                    <c:when test="${isAdminReply}">
                                                                        <span class="badge badge-danger ml-1" style="font-size: 0.72rem;">Quản Trị Viên (Hỗ Trợ)</span>
                                                                    </c:when>
                                                                    <c:when test="${reply.senderRole == 'ROLE_HOST' || reply.senderRole == 'HOST'}">
                                                                        <span class="badge badge-warning ml-1" style="font-size: 0.72rem;">Đối Tác Host</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="badge badge-primary ml-1" style="font-size: 0.72rem;">Khách Hàng</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                        <div class="small text-muted">
                                                            <fmt:formatDate value="${reply.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                        </div>
                                                    </div>
                                                    <div class="reply-text"><c:out value="${fn:trim(reply.message)}" /></div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- 3. Admin Reply Form -->
                <div class="card-box">
                    <div class="card-box-header">
                        <div class="font-weight-bold text-dark">
                            <i class="fa fa-reply text-primary mr-1"></i> Gửi Phản Hồi Từ Quản Trị Viên
                        </div>
                    </div>
                    <div class="card-box-body">
                        <form method="post" action="${pageContext.request.contextPath}/admin/support/reply" id="adminReplyForm">
                            <input type="hidden" name="csrfToken" value="${csrfToken}">
                            <input type="hidden" name="ticketId" value="${ticket.messageId}">

                            <div class="form-group mb-2">
                                <label for="adminReplyMessage" class="font-weight-bold small text-muted">Nội dung phản hồi tới người gửi (Plain text):</label>
                                <%-- <textarea name="message" id="adminReplyMessage" class="form-control" rows="5"
                                          placeholder="Nhập nội dung phản hồi chi tiết, hướng dẫn hoặc giải pháp hỗ trợ..."
                                          required minlength="2" maxlength="2000"></textarea> --%>
                                <%-- GIU LAI NOI DUNG NHAP (REPLYDRAFT) KHI CO LOI VALIDATION/CSRF/RATE-LIMIT/DB (DOT 6) --%>
                                <textarea name="message" id="adminReplyMessage" class="form-control" rows="5"
                                          placeholder="Nhập nội dung phản hồi chi tiết, hướng dẫn hoặc giải pháp hỗ trợ..."
                                          required minlength="2" maxlength="2000"><c:out value="${replyDraft}" /></textarea>
                                <div class="d-flex justify-content-between align-items-center mt-1">
                                    <small class="text-muted">Độ dài từ 2 đến 2000 ký tự. Không chứa mã HTML/Script độc hại.</small>
                                    <small class="text-muted"><span id="charCount">0</span>/2000 ký tự</small>
                                </div>
                            </div>

                            <c:if test="${ticket.status == 'NEW'}">
                                <div class="form-check mb-3">
                                    <input class="form-check-input" type="checkbox" name="changeToProcessing" id="chkChangeProcessing" value="true" checked>
                                    <label class="form-check-label font-weight-bold text-dark small" for="chkChangeProcessing">
                                        Đồng thời chuyển trạng thái yêu cầu sang <span class="badge-status-proc">Đang xử lý (PROCESSING)</span>
                                    </label>
                                </div>
                            </c:if>

                            <div class="d-flex justify-content-between align-items-center mt-3 pt-2 border-top">
                                <div class="small text-muted">
                                    <i class="fa fa-info-circle mr-1"></i> Việc gửi phản hồi không tự động đánh dấu đã giải quyết (RESOLVED) yêu cầu.
                                </div>
                                <button type="submit" class="btn btn-primary font-weight-bold px-4" id="btnSubmitReply">
                                    <i class="fa fa-paper-plane mr-1"></i> Gửi Phản Hồi
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

            </div>

            <!-- Right Column: Sender Info, Booking & Metadata (4 cols) -->
            <div class="col-12 col-lg-4">

                <!-- 1. Sender Info Card -->
                <div class="card-box">
                    <div class="card-box-header">
                        <div class="font-weight-bold text-dark">
                            <i class="fa fa-user-circle text-primary mr-1"></i> Người Gửi Yêu Cầu
                        </div>
                    </div>
                    <div class="card-box-body">
                        <div class="d-flex align-items-center mb-3">
                            <div class="sender-avatar mr-3">
                                <%-- ${fn:toUpperCase(fn:substring(ticket.fullName, 0, 1))} --%>
                                <%-- ESCAPE KY TU DAU TEN NGUOI GUI DE CHONG XSS NEU HO TEN CHUA KY TU HTML DAC BIET (DOT 6) --%>
                                <c:out value="${fn:toUpperCase(fn:substring(ticket.fullName, 0, 1))}" />
                            </div>
                            <div>
                                <h6 class="font-weight-bold text-dark mb-0"><c:out value="${ticket.fullName}" /></h6>
                                <c:choose>
                                    <c:when test="${ticket.senderRole == 'ROLE_HOST' || ticket.senderRole == 'HOST'}">
                                        <span class="badge badge-warning" style="font-size: 0.75rem;"><i class="fa fa-home mr-1"></i>Đối tác Host</span>
                                    </c:when>
                                    <c:when test="${ticket.senderRole == 'ROLE_ADMIN' || ticket.senderRole == 'ADMIN'}">
                                        <span class="badge badge-danger" style="font-size: 0.75rem;"><i class="fa fa-shield mr-1"></i>Quản trị viên</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-primary" style="font-size: 0.75rem;"><i class="fa fa-user mr-1"></i>Khách hàng</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <ul class="list-unstyled mb-0 small">
                            <li class="mb-2">
                                <span class="text-muted d-block">Địa chỉ Email:</span>
                                <strong class="text-dark"><i class="fa fa-envelope-o mr-1"></i><c:out value="${ticket.email}" /></strong>
                            </li>
                            <li class="mb-2">
                                <span class="text-muted d-block">Số điện thoại:</span>
                                <c:choose>
                                    <c:when test="${not empty ticket.phone}">
                                        <strong class="text-dark"><i class="fa fa-phone mr-1"></i><c:out value="${ticket.phone}" /></strong>
                                        </c:when>
                                        <c:otherwise>
                                        <span class="text-muted font-italic">Chưa cung cấp</span>
                                    </c:otherwise>
                                </c:choose>
                            </li>
                            <c:if test="${ticket.userId != null}">
                                <li>
                                    <span class="text-muted d-block">Tài khoản User ID:</span>
                                    <span class="badge badge-light border">User #${ticket.userId}</span>
                                </li>
                            </c:if>
                        </ul>
                    </div>
                </div>

                <!-- 2. Related Booking Card (Sanitized, Strictly No Sensitive Financial Info) -->
                <c:if test="${not empty relatedBooking}">
                    <div class="card-box">
                        <div class="card-box-header">
                            <div class="font-weight-bold text-dark">
                                <i class="fa fa-bookmark text-info mr-1"></i> Đặt Phòng Liên Quan
                            </div>
                            <span class="badge badge-info">${relatedBooking.status}</span>
                        </div>
                        <div class="card-box-body small">
                            <div class="mb-2">
                                <span class="text-muted d-block">Mã đặt phòng:</span>
                                <strong class="text-dark font-weight-bold" style="font-family: monospace; font-size: 1rem;">
                                    <c:out value="${relatedBooking.bookingCode != null ? relatedBooking.bookingCode : relatedBooking.id}" />
                                </strong>
                            </div>
                            <div class="mb-2">
                                <span class="text-muted d-block">Chỗ nghỉ / Phòng:</span>
                                <strong class="text-dark"><c:out value="${relatedBooking.roomName}" /></strong>
                            </div>
                            <div class="mb-2">
                                <span class="text-muted d-block">Thời gian lưu trú:</span>
                                <span class="text-dark">
                                    <fmt:formatDate value="${relatedBooking.checkInDate}" pattern="dd/MM/yyyy" /> &mdash;
                                    <fmt:formatDate value="${relatedBooking.checkOutDate}" pattern="dd/MM/yyyy" />
                                </span>
                            </div>
                            <div>
                                <span class="text-muted d-block">Số lượng khách:</span>
                                <span class="text-dark font-weight-bold">${relatedBooking.guestCount} khách</span>
                            </div>
                        </div>
                    </div>
                </c:if>

                <!-- 3. Audit & Tracking Metadata Card -->
                <div class="card-box">
                    <div class="card-box-header">
                        <div class="font-weight-bold text-dark">
                            <i class="fa fa-info-circle text-secondary mr-1"></i> Thông Tin Kiểm Soát
                        </div>
                    </div>
                    <div class="card-box-body small">
                        <ul class="list-unstyled mb-0">
                            <li class="d-flex justify-content-between mb-2 pb-1 border-bottom">
                                <span class="text-muted">Mã bản ghi (ID):</span>
                                <span class="font-weight-bold text-dark">#${ticket.messageId}</span>
                            </li>
                            <li class="d-flex justify-content-between mb-2 pb-1 border-bottom">
                                <span class="text-muted">Mã theo dõi:</span>
                                <span class="font-weight-bold text-dark" style="font-family: monospace;"><c:out value="${ticket.ticketCode}" /></span>
                            </li>
                            <li class="d-flex justify-content-between mb-2 pb-1 border-bottom">
                                <span class="text-muted">Thời điểm tạo:</span>
                                <span class="text-dark"><fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm" /></span>
                            </li>
                            <li class="d-flex justify-content-between mb-2 pb-1 border-bottom">
                                <span class="text-muted">Cập nhật lần cuối:</span>
                                <span class="text-dark"><fmt:formatDate value="${ticket.updatedAt}" pattern="dd/MM/yyyy HH:mm" /></span>
                            </li>
                            <li class="d-flex justify-content-between">
                                <span class="text-muted">Tổng số phản hồi:</span>
                                <span class="badge badge-light border font-weight-bold">${ticket.replyCount}</span>
                            </li>
                        </ul>
                    </div>
                </div>

            </div>

        </div>

    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        var replyArea = document.getElementById("adminReplyMessage");
        var charCount = document.getElementById("charCount");
        if (replyArea && charCount) {
            // CAP NHAT BO DEM KY TU NGAY KHI TRANG TAI LAI CO DUNG LUONG REPLYDRAFT (DOT 6)
            charCount.textContent = replyArea.value.length;
            replyArea.addEventListener("input", function () {
                charCount.textContent = replyArea.value.length;
            });
        }
    });
</script>

<jsp:include page="../common/footer.jsp" />
