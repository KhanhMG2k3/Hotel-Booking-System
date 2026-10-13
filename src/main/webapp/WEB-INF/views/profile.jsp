<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="common/header.jsp">
    <jsp:param name="pageTitle" value="Hồ sơ cá nhân - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<section class="section bg-light" style="padding-top: 120px; padding-bottom: 80px;">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-8">

                <div class="mb-4">
                    <h2 class="heading mb-1" style="font-family:'Playfair Display',serif;">Hồ sơ cá nhân</h2>
                    <p class="text-muted mb-0">Xem và cập nhật thông tin tài khoản của bạn</p>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger"><c:out value="${error}" /></div>
                </c:if>
                <c:if test="${not empty success}">
                    <div class="alert alert-success"><c:out value="${success}" /></div>
                </c:if>

                <c:set var="u" value="${profileUser}" />

                <div class="bg-white p-4 p-md-5 shadow-sm rounded mb-4">
                    <div class="d-flex align-items-center mb-4">
                        <c:choose>
                            <c:when test="${not empty u.avatarUrl}">
                                <img src="${u.avatarUrl}" alt="Avatar"
                                     class="rounded-circle mr-3"
                                     style="width:64px;height:64px;object-fit:cover;">
                            </c:when>
                            <c:otherwise>
                                <div class="rounded-circle mr-3 d-flex align-items-center justify-content-center"
                                     style="width:64px;height:64px;background:#ffba5a;color:#fff;font-size:1.5rem;font-weight:700;">
                                    ${fn:toUpperCase(fn:substring(u.fullName, 0, 1))}
                                </div>
                            </c:otherwise>
                        </c:choose>
                        <div>
                            <h5 class="mb-0" style="font-family:'Playfair Display',serif;">
                                <c:out value="${u.fullName}" />
                            </h5>
                            <small class="text-muted"><c:out value="${u.email}" /></small>
                            <div class="mt-1">
                                <c:choose>
                                    <c:when test="${u.roleId == 1}"><span class="badge badge-primary">Admin</span></c:when>
                                    <c:when test="${u.roleId == 3}"><span class="badge badge-warning">Host</span></c:when>
                                    <c:otherwise><span class="badge badge-secondary">Customer</span></c:otherwise>
                                </c:choose>
                                <c:if test="${not empty u.authProvider}">
                                    <span class="badge badge-light border ml-1">
                                        <c:out value="${u.authProvider}" />
                                    </span>
                                </c:if>
                            </div>
                        </div>
                    </div>

                    <form method="post" action="${pageContext.request.contextPath}/profile">
                        <input type="hidden" name="action" value="updateProfile">

                        <div class="form-group">
                            <label class="font-weight-bold">Họ và tên <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="fullName" required
                                   value="<c:out value='${u.fullName}' />" maxlength="100">
                        </div>

                        <div class="form-group">
                            <label class="font-weight-bold">Email</label>
                            <input type="email" class="form-control" value="<c:out value='${u.email}' />" readonly disabled>
                            <small class="text-muted">Email không thể thay đổi.</small>
                        </div>

                        <div class="form-group">
                            <label class="font-weight-bold">Số điện thoại</label>
                            <input type="text" class="form-control" name="phone"
                                   value="<c:out value='${u.phone}' />" maxlength="20"
                                   placeholder="Ví dụ: 0901234567">
                        </div>

                        <div class="form-group">
                            <label class="font-weight-bold">URL ảnh đại diện</label>
                            <input type="url" class="form-control" name="avatarUrl"
                                   value="<c:out value='${u.avatarUrl}' />"
                                   placeholder="https://...">
                            <small class="text-muted">Dán link ảnh (Google avatar hoặc URL công khai).</small>
                        </div>

                        <button type="submit" class="btn btn-primary px-4 font-weight-bold"
                                style="background:#ffba5a;border-color:#ffba5a;">
                            Lưu thay đổi
                        </button>
                    </form>
                </div>

                <%-- Đổi mật khẩu: chỉ hiện khi có password local --%>
                <c:if test="${not empty u.password}">
                    <div class="bg-white p-4 p-md-5 shadow-sm rounded">
                        <h5 class="mb-3" style="font-family:'Playfair Display',serif;">Đổi mật khẩu</h5>
                        <form method="post" action="${pageContext.request.contextPath}/profile">
                            <input type="hidden" name="action" value="changePassword">

                            <div class="form-group">
                                <label class="font-weight-bold">Mật khẩu hiện tại</label>
                                <input type="password" class="form-control" name="oldPassword" required>
                            </div>
                            <div class="form-group">
                                <label class="font-weight-bold">Mật khẩu mới</label>
                                <input type="password" class="form-control" name="newPassword" required minlength="8">
                                <small class="text-muted">Tối thiểu 8 ký tự.</small>
                            </div>
                            <div class="form-group">
                                <label class="font-weight-bold">Xác nhận mật khẩu mới</label>
                                <input type="password" class="form-control" name="confirmPassword" required minlength="8">
                            </div>

                            <button type="submit" class="btn btn-outline-secondary px-4 font-weight-bold">
                                Đổi mật khẩu
                            </button>
                        </form>
                    </div>
                </c:if>

                <c:if test="${empty u.password}">
                    <div class="alert alert-info mb-0">
                        Tài khoản đăng nhập bằng Google. Mật khẩu được quản lý bởi Google, không đổi tại đây.
                    </div>
                </c:if>

            </div>
        </div>
    </div>
</section>

<jsp:include page="common/footer.jsp" />