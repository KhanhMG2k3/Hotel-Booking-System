<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../common/header.jsp">
    <jsp:param name="pageTitle" value="Thêm Homestay Mới - Sogo Homestay" />
</jsp:include>

<jsp:include page="../common/navbar.jsp" />

<section class="section py-5" style="padding-top: 120px !important; min-height: 85vh;">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-9 col-lg-7">

                <div class="d-flex align-items-center mb-3">
                    <a href="${pageContext.request.contextPath}/host/dashboard" class="btn btn-sm btn-outline-secondary font-weight-bold" style="border-radius: 8px;">
                        <i class="fa fa-arrow-left mr-1"></i> Quay lại Dashboard Host
                    </a>
                </div>

                <div class="card shadow-sm border-0 rounded-lg p-4 p-md-5">
                    <div class="text-center mb-4 pb-2 border-bottom">
                        <span class="badge badge-warning text-dark px-3 py-1 font-weight-bold mb-2" style="font-size: 0.85rem; border-radius: 30px;">
                            <i class="fa fa-plus-circle mr-1"></i> ĐỐI TÁC HOST
                        </span>
                        <h2 class="font-weight-bold mb-1" style="font-family: 'Playfair Display', serif;">Thêm Chỗ Nghỉ / Homestay Mới</h2>
                        <p class="text-muted small">Khởi tạo thông tin chỗ nghỉ của bạn để bắt đầu mở bán phòng trên hệ thống Sogo Homestay.</p>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                            <i class="fa fa-exclamation-circle mr-2"></i> <c:out value="${error}" />
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/host/property/create">
                        <div class="form-group mb-3">
                            <label class="font-weight-bold"><i class="fa fa-tag text-primary mr-1"></i> Tên Homestay / Chỗ nghỉ <span class="text-danger">*</span></label>
                            <input type="text" name="name" class="form-control" placeholder="Ví dụ: Sogo Pine Hill Villa Đà Lạt" required maxlength="150" value="${param.name != null ? param.name : ''}">
                        </div>

                        <div class="form-group mb-3">
                            <label class="font-weight-bold"><i class="fa fa-align-left text-primary mr-1"></i> Mô tả chỗ nghỉ</label>
                            <textarea name="description" rows="4" class="form-control" placeholder="Mô tả không gian, cảnh quan, trải nghiệm đặc sắc của homestay...">${param.description != null ? param.description : ''}</textarea>
                        </div>

                        <div class="form-group mb-3">
                            <label class="font-weight-bold"><i class="fa fa-building-o text-warning mr-1"></i> Loại hình chỗ nghỉ <span class="text-danger">*</span></label>
                            <select name="propertyType" class="form-control">
                                <option value="HOMESTAY" ${param.propertyType == 'HOMESTAY' ? 'selected' : ''}>Homestay nghỉ dưỡng</option>
                                <option value="HOTEL" ${param.propertyType == 'HOTEL' ? 'selected' : ''}>Khách sạn</option>
                                <option value="VILLA" ${param.propertyType == 'VILLA' ? 'selected' : ''}>Biệt thự Villa nguyên căn</option>
                                <option value="RESORT" ${param.propertyType == 'RESORT' ? 'selected' : ''}>Resort ven biển / vùng núi</option>
                            </select>
                        </div>

                        <div class="form-group mb-3">
                            <label class="font-weight-bold"><i class="fa fa-map-marker text-danger mr-1"></i> Địa chỉ chi tiết <span class="text-danger">*</span></label>
                            <input type="text" name="address" class="form-control" placeholder="Ví dụ: 88 Khe Sanh, Phường 10" required maxlength="255" value="${param.address != null ? param.address : ''}">
                        </div>

                        <div class="row">
                            <div class="col-md-6 form-group mb-4">
                                <label class="font-weight-bold"><i class="fa fa-compass text-info mr-1"></i> Thành phố / Tỉnh <span class="text-danger">*</span></label>
                                <input type="text" name="city" class="form-control" placeholder="Ví dụ: Đà Lạt" required maxlength="100" value="${param.city != null ? param.city : ''}">
                            </div>
                            <div class="col-md-6 form-group mb-4">
                                <label class="font-weight-bold"><i class="fa fa-globe text-success mr-1"></i> Quốc gia</label>
                                <input type="text" name="country" class="form-control" value="Việt Nam" readonly>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between align-items-center mt-3 pt-3 border-top">
                            <a href="${pageContext.request.contextPath}/host/dashboard" class="btn btn-outline-secondary font-weight-bold" style="border-radius: 8px;">
                                Hủy bỏ
                            </a>
                            <button type="submit" class="btn btn-primary font-weight-bold px-4 py-2" style="border-radius: 8px;">
                                <i class="fa fa-check mr-1"></i> Lưu và Tạo Homestay
                            </button>
                        </div>
                    </form>
                </div>

            </div>
        </div>
    </div>
</section>

<jsp:include page="../common/footer.jsp" />
