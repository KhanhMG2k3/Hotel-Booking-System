<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../common/header.jsp">
    <jsp:param name="pageTitle" value="Đăng ký trở thành Host - Sogo Homestay" />
</jsp:include>

<jsp:include page="../common/navbar.jsp" />

<section class="section bg-light" style="padding-top: 120px; padding-bottom: 80px;">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-6">

                <div class="text-center mb-5">
                    <h2 class="heading mb-2">Trở thành Host</h2>
                    <p class="text-muted">
                        Đăng ký hồ sơ Host để bắt đầu đăng homestay và nhận đặt phòng từ khách hàng.
                        Hồ sơ sẽ được Admin xem xét trước khi phê duyệt.
                    </p>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger" role="alert">
                        <c:out value="${error}" />
                    </div>
                </c:if>

                <div class="bg-white p-4 p-md-5 shadow-sm rounded">
                    <form method="post" action="${pageContext.request.contextPath}/become-host" novalidate>

                        <div class="form-group mb-4">
                            <label for="businessName" class="font-weight-bold">
                                Tên doanh nghiệp / Homestay <span class="text-danger">*</span>
                            </label>
                            <input type="text"
                                   class="form-control"
                                   id="businessName"
                                   name="businessName"
                                   placeholder="Ví dụ: Sogo Homestay Đà Lạt"
                                   required
                                   maxlength="150"
                                   value="${param.businessName != null ? param.businessName : ''}">
                        </div>

                        <div class="form-group mb-4">
                            <label for="businessType" class="font-weight-bold">Loại hình kinh doanh</label>
                            <select class="form-control" id="businessType" name="businessType">
                                <option value="">-- Chọn loại hình --</option>
                                <option value="HOMESTAY" ${param.businessType == 'HOMESTAY' ? 'selected' : ''}>Homestay</option>
                                <option value="HOTEL" ${param.businessType == 'HOTEL' ? 'selected' : ''}>Khách sạn</option>
                                <option value="VILLA" ${param.businessType == 'VILLA' ? 'selected' : ''}>Villa</option>
                                <option value="APARTMENT" ${param.businessType == 'APARTMENT' ? 'selected' : ''}>Căn hộ</option>
                                <option value="OTHER" ${param.businessType == 'OTHER' ? 'selected' : ''}>Khác</option>
                            </select>
                        </div>

                        <div class="form-group mb-4">
                            <label for="phone" class="font-weight-bold">Số điện thoại liên hệ</label>
                            <input type="text"
                                   class="form-control"
                                   id="phone"
                                   name="phone"
                                   placeholder="Ví dụ: 0901234567"
                                   maxlength="20"
                                   value="${param.phone != null ? param.phone : ''}">
                        </div>

                        <div class="alert alert-info small mb-4">
                            <i class="fa fa-info-circle mr-1"></i>
                            Sau khi gửi đăng ký, trạng thái hồ sơ sẽ là <strong>PENDING</strong>.
                            Bạn chỉ được đăng property sau khi Admin phê duyệt.
                        </div>

                        <div class="form-group mb-0">
                            <button type="submit" class="btn btn-primary btn-block py-3 font-weight-bold">
                                Gửi đăng ký Host
                            </button>
                        </div>

                        <div class="text-center mt-3">
                            <a href="${pageContext.request.contextPath}/home" class="text-muted small">
                                ← Quay về trang chủ
                            </a>
                        </div>
                    </form>
                </div>

            </div>
        </div>
    </div>
</section>

<jsp:include page="../common/footer.jsp" />