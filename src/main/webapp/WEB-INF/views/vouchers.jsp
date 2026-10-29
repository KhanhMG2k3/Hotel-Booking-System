<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="common/header.jsp">
    <jsp:param name="pageTitle" value="Quản lý voucher - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<style>
    .voucher-page {
        min-height: 75vh;
        padding-top: 125px !important;
        padding-bottom: 60px;
        background: #f7f8fa;
    }

    .voucher-panel, .stat-card {
        background: #fff;
        border-radius: 12px;
        padding: 24px;
        box-shadow: 0 4px 20px rgba(0,0,0,.05);
    }

    .voucher-label {
        color: #6c757d;
        font-size: 14px;
    }

    .voucher-code {
        font-weight: 700;
        letter-spacing: .5px;
    }

    .status-active {
        color: #146c43;
        background: #d1e7dd;
    }

    .status-inactive {
        color: #842029;
        background: #f8d7da;
    }

    .status-badge {
        display: inline-block;
        padding: 5px 10px;
        border-radius: 20px;
        font-size: 12px;
    }

    .form-panel {
        scroll-margin-top: 20px;
    }

    .action-forms {
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
    }

    .action-forms form {
        margin: 0;
    }
</style>

<main class="voucher-page">
    <div class="container">

        <c:if test="${not empty sessionScope.success}">
            <div class="alert alert-success" role="status">
                <c:out value="${sessionScope.success}" />
            </div>
            <c:remove var="success" scope="session" />
        </c:if>

        <c:if test="${not empty sessionScope.error}">
            <div class="alert alert-danger" role="alert">
                <c:out value="${sessionScope.error}" />
            </div>
            <c:remove var="error" scope="session" />
        </c:if>

        <div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
            <div>
                <a href="${pageContext.request.contextPath}/host/dashboard" class="text-primary font-weight-bold text-decoration-none small d-inline-flex align-items-center mb-1">
                    <i class="fa fa-arrow-left mr-1"></i> Quay lại Host Dashboard
                </a>
                <h1 class="h2 mb-2">Quản lý voucher</h1>
                <p class="text-muted mb-0">
                    Tạo và quản lý mã giảm giá cho khách đặt phòng.
                </p>
            </div>

            <div class="mt-3 mt-md-0 d-flex gap-2">
                <a class="btn btn-outline-secondary mr-2"
                   href="${pageContext.request.contextPath}/host/dashboard">
                    <i class="fa fa-dashboard mr-1"></i> Dashboard
                </a>
                <a class="btn btn-warning"
                   href="${pageContext.request.contextPath}/host/vouchers#voucher-form">
                    + Tạo voucher
                </a>
            </div>
        </div>

        <div class="row mb-4">
            <div class="col-md-6 mb-3">
                <div class="stat-card h-100">
                    <div class="voucher-label">Tổng voucher</div>
                    <div class="h3 mb-0">
                        <c:out value="${vouchers.size()}" />
                    </div>
                </div>
            </div>

            <div class="col-md-6 mb-3">
                <div class="stat-card h-100">
                    <div class="voucher-label">Voucher đang hoạt động</div>
                    <div class="h3 mb-0">
                        <c:set var="activeCount" value="0" />
                        <c:forEach var="v" items="${vouchers}">
                            <c:if test="${v.status eq 'ACTIVE'}">
                                <c:set var="activeCount"
                                       value="${activeCount + 1}" />
                            </c:if>
                        </c:forEach>
                        <c:out value="${activeCount}" />
                    </div>
                </div>
            </div>
        </div>

        <section class="voucher-panel mb-4 form-panel" id="voucher-form">
            <c:choose>
                <c:when test="${not empty editingVoucher}">
                    <h2 class="h4 mb-4">Chỉnh sửa voucher</h2>
                </c:when>
                <c:otherwise>
                    <h2 class="h4 mb-4">Tạo voucher mới</h2>
                </c:otherwise>
            </c:choose>

            <form method="post"
                  action="${pageContext.request.contextPath}/host/vouchers">

                <input type="hidden" name="csrfToken"
                       value="<c:out value='${sessionScope.csrfToken}' />" />

                <c:choose>
                    <c:when test="${not empty editingVoucher}">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="id"
                               value="<c:out value='${editingVoucher.id}' />">
                    </c:when>
                    <c:otherwise>
                        <input type="hidden" name="action" value="create">
                    </c:otherwise>
                </c:choose>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="code" class="form-label">Mã voucher</label>
                        <input class="form-control" id="code" name="code"
                               type="text" required maxlength="50"
                               pattern="[A-Za-z0-9_-]{3,50}"
                               placeholder="VD: SUMMER2026"
                               value="<c:out value='${editingVoucher.code}' />">
                        <small class="text-muted">
                            Từ 3–50 ký tự chữ, số, gạch ngang hoặc gạch dưới.
                        </small>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="discountType" class="form-label">
                            Loại giảm giá
                        </label>
                        <select class="form-control" id="discountType"
                                name="discountType" required>
                            <option value="PERCENTAGE"
                                <c:if test="${editingVoucher.discountType eq 'PERCENTAGE'}">selected</c:if>>
                                Phần trăm (%)
                            </option>
                            <option value="FIXED_AMOUNT"
                                <c:if test="${editingVoucher.discountType eq 'FIXED_AMOUNT'}">selected</c:if>>
                                Số tiền cố định
                            </option>
                        </select>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="discountValue" class="form-label">
                            Giá trị giảm
                        </label>
                        <input class="form-control" id="discountValue"
                               name="discountValue" type="number"
                               min="0.01" step="0.01" required
                               value="<c:out value='${editingVoucher.discountValue}' />">
                        <small class="text-muted">
                            Với giảm theo phần trăm, giá trị không vượt quá 100.
                        </small>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="usageLimit" class="form-label">
                            Giới hạn lượt sử dụng
                        </label>
                        <input class="form-control" id="usageLimit"
                               name="usageLimit" type="number"
                               min="1" required
                               value="<c:choose><c:when test='${not empty editingVoucher}'>${editingVoucher.usageLimit}</c:when><c:otherwise>100</c:otherwise></c:choose>">
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="startDate" class="form-label">
                            Ngày bắt đầu
                        </label>
                        <input class="form-control" id="startDate"
                               name="startDate" type="date" required
                               value="<fmt:formatDate value='${editingVoucher.startDate}' pattern='yyyy-MM-dd' />">
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="endDate" class="form-label">
                            Ngày kết thúc
                        </label>
                        <input class="form-control" id="endDate"
                               name="endDate" type="date" required
                               value="<fmt:formatDate value='${editingVoucher.endDate}' pattern='yyyy-MM-dd' />">
                    </div>
                </div>

                <button type="submit" class="btn btn-warning">
                    <c:choose>
                        <c:when test="${not empty editingVoucher}">
                            Lưu thay đổi
                        </c:when>
                        <c:otherwise>
                            Tạo voucher
                        </c:otherwise>
                    </c:choose>
                </button>

                <c:if test="${not empty editingVoucher}">
                    <a class="btn btn-outline-secondary"
                       href="${pageContext.request.contextPath}/host/vouchers">
                        Hủy
                    </a>
                </c:if>
            </form>
        </section>

        <section class="voucher-panel">
            <h2 class="h4 mb-4">Danh sách voucher</h2>

            <c:choose>
                <c:when test="${empty vouchers}">
                    <div class="text-center text-muted py-5">
                        <h3 class="h5">Chưa có voucher nào</h3>
                        <p class="mb-0">Tạo voucher đầu tiên để bắt đầu.</p>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="thead-light">
                            <tr>
                                <th>Mã voucher</th>
                                <th>Mức giảm</th>
                                <th>Thời hạn</th>
                                <th>Lượt sử dụng</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                            </thead>

                            <tbody>
                            <c:forEach var="v" items="${vouchers}">
                                <tr>
                                    <td>
                                        <span class="voucher-code">
                                            <c:out value="${v.code}" />
                                        </span>
                                    </td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${v.discountType eq 'PERCENTAGE'}">
                                                <c:out value="${v.discountValue}" />%
                                            </c:when>
                                            <c:otherwise>
                                                <c:out value="${v.discountValue}" />
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td>
                                        <c:out value="${v.startDate}" />
                                        <br>đến<br>
                                        <c:out value="${v.endDate}" />
                                    </td>

                                    <td>
                                        <c:out value="${v.usedCount}" /> /
                                        <c:out value="${v.usageLimit}" />
                                    </td>

                                    <td>
                                        <span class="status-badge ${v.status eq 'ACTIVE' ? 'status-active' : 'status-inactive'}">
                                            <c:choose>
                                                <c:when test="${v.status eq 'ACTIVE'}">
                                                    Đang hoạt động
                                                </c:when>
                                                <c:otherwise>
                                                    Đã tắt
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                    </td>

                                    <td>
                                        <div class="action-forms">
                                            <a class="btn btn-sm btn-outline-primary"
                                               href="${pageContext.request.contextPath}/host/vouchers?action=edit&amp;id=${v.id}#voucher-form">
                                                Sửa
                                            </a>

                                            <form method="post"
                                                  action="${pageContext.request.contextPath}/host/vouchers">
                                                <input type="hidden" name="csrfToken"
                                                       value="<c:out value='${sessionScope.csrfToken}' />">
                                                <input type="hidden" name="action" value="toggle">
                                                <input type="hidden" name="id"
                                                       value="<c:out value='${v.id}' />">
                                                <button type="submit"
                                                        class="btn btn-sm btn-outline-secondary">
                                                    <c:choose>
                                                        <c:when test="${v.status eq 'ACTIVE'}">
                                                            Tắt
                                                        </c:when>
                                                        <c:otherwise>
                                                            Bật
                                                        </c:otherwise>
                                                    </c:choose>
                                                </button>
                                            </form>

                                            <form method="post"
                                                  action="${pageContext.request.contextPath}/host/vouchers"
                                                  onsubmit="return confirm('Bạn có chắc muốn xóa voucher này?');">
                                                <input type="hidden" name="csrfToken"
                                                       value="<c:out value='${sessionScope.csrfToken}' />">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id"
                                                       value="<c:out value='${v.id}' />">
                                                <button type="submit"
                                                        class="btn btn-sm btn-outline-danger">
                                                    Xóa
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </div>
</main>

<jsp:include page="common/footer.jsp" />
