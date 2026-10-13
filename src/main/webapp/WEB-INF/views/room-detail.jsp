<%@ page contentType="text/html;charset=UTF-8" language="java" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

      <jsp:include page="common/header.jsp">
        <jsp:param name="pageTitle" value="${room.roomName} - Chi Tiết Phòng Sogo Homestay" />
      </jsp:include>

      <jsp:include page="common/navbar.jsp" />

      <!-- HERO / BREADCRUMBS -->
      <section class="site-hero inner-page overlay hero-room-detail"
        data-hero-image="${pageContext.request.contextPath}/assets/${not empty room.imageUrl ? room.imageUrl : 'images/hero_4.jpg'}"
        data-stellar-background-ratio="0.5">
        <div class="container">
          <div class="row site-hero-inner justify-content-center align-items-center">
            <div class="col-md-10 text-center" data-aos="fade">
              <span class="custom-caption text-uppercase text-white d-block mb-3">${room.roomType.typeName} &bull; Mã:
                ${room.roomNumber}</span>
              <h1 class="heading mb-3">${room.roomName}</h1>
              <ul class="custom-breadcrumbs mb-4">
                <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
                <li>&bullet;</li>
                <li><a href="${pageContext.request.contextPath}/rooms">Danh Sách Phòng</a></li>
                <li>&bullet;</li>
                <li>Chi Tiết Phòng</li>
              </ul>
            </div>
          </div>
        </div>

        <a class="mouse smoothscroll" href="#room-detail-content">
          <div class="mouse-icon">
            <span class="mouse-wheel"></span>
          </div>
        </a>
      </section>
      <!-- END HERO -->

      <!-- CHI TIẾT PHÒNG & BỘ SƯU TẬP ẢNH -->
      <section class="section pb-5" id="room-detail-content">
        <div class="container">

          <!-- BỘ SƯU TẬP HÌNH ẢNH (PHOTO GALLERY) -->
          <div class="row mb-5" data-aos="fade-up">
            <div class="col-12">
              <span class="text-primary font-weight-bold text-uppercase letter-spacing-1 d-block mb-2">Hình ảnh thực
                tế</span>
              <h2 class="heading mb-4">Không Gian Phòng & Tiện Nghi</h2>
            </div>

            <div class="col-lg-8 mb-4">
              <div class="main-image-wrap rounded overflow-hidden shadow">
                <a href="${pageContext.request.contextPath}/assets/${room.imageUrl}" data-fancybox="gallery"
                  data-caption="${room.roomName} - Ảnh Chính">
                  <img src="${pageContext.request.contextPath}/assets/${room.imageUrl}" alt="${room.roomName}"
                    class="img-fluid w-100 room-detail-image">
                </a>
              </div>
            </div>

            <div class="col-lg-4">
              <div class="row">
                <c:forEach var="img" items="${room.images}" varStatus="status">
                  <c:if test="${status.index < 4}">
                    <div class="col-6 mb-3">
                      <div class="thumbnail-wrap rounded overflow-hidden shadow-sm">
                        <a href="${pageContext.request.contextPath}/assets/${img}" data-fancybox="gallery"
                          data-caption="${room.roomName} - Ảnh ${status.index + 1}">
                          <img src="${pageContext.request.contextPath}/assets/${img}" alt="Thumbnail"
                            class="img-fluid w-100 h-100">
                        </a>
                      </div>
                    </div>
                  </c:if>
                </c:forEach>
                <div class="col-12 mt-2 text-right">
                  <small class="text-muted"><i class="fa fa-search-plus"></i> Nhấp vào ảnh để phóng to và xem toàn bộ
                    album</small>
                </div>
              </div>
            </div>
          </div>

          <!-- THÔNG SỐ & MÔ TẢ CHI TIẾT -->
          <div class="row">

            <!-- CỘT TRÁI: THÔNG TIN CHI TIẾT -->
            <div class="col-lg-8" data-aos="fade-up">

              <!-- THÔNG SỐ CƠ BẢN -->
              <div class="bg-light p-4 rounded mb-5 border">
                <div class="row text-center">
                  <div class="col-md-3 col-6 mb-3 mb-md-0 border-right">
                    <span class="d-block text-muted small"><i class="fa fa-users text-primary"></i> Sức chứa</span>
                    <strong class="h5 text-dark">${room.capacity} Khách</strong>
                  </div>
                  <div class="col-md-3 col-6 mb-3 mb-md-0 border-right">
                    <span class="d-block text-muted small"><i class="fa fa-arrows-alt text-primary"></i> Diện
                      tích</span>
                    <strong class="h5 text-dark">${room.size} m²</strong>
                  </div>
                  <div class="col-md-3 col-6 border-right">
                    <span class="d-block text-muted small"><i class="fa fa-bed text-primary"></i> Loại giường</span>
                    <strong class="h6 text-dark">${not empty room.bedType ? room.bedType : 'Giường đôi King'}</strong>
                  </div>
                  <div class="col-md-3 col-6">
                    <span class="d-block text-muted small"><i class="fa fa-tag text-primary"></i> Mã phòng</span>
                    <strong class="h5 text-primary">${room.roomNumber}</strong>
                  </div>
                </div>
              </div>

              <!-- GIỚI THIỆU KHÔNG GIAN -->
              <div class="mb-5">
                <h3 class="h4 font-weight-bold text-dark mb-3">Mô Tả Không Gian Phòng</h3>
                <p class="text-muted lead room-description">${room.description}</p>
                <p class="text-muted room-description">
                  Phòng được thiết kế theo phong cách hiện đại kết hợp các chất liệu mộc mạc tự nhiên, tận dụng tối đa
                  ánh sáng tự nhiên từ cửa sổ và ban công lớn. Không gian được trang bị nệm cao cấp giúp bạn có giấc ngủ
                  sâu và thư thái sau những giờ phút khám phá cảnh đẹp.
                </p>
              </div>

              <!-- DANH SÁCH TIỆN NGHI -->
              <div class="mb-5">
                <h3 class="h4 font-weight-bold text-dark mb-4">Tiện Nghi & Dịch Vụ Đi Kèm</h3>
                <div class="row">
                  <c:forEach var="amenity" items="${room.amenities}">
                    <div class="col-md-6 mb-3">
                      <div class="d-flex align-items-center">
                        <span class="fa fa-check-circle text-success mr-3 h5 mb-0"></span>
                        <span class="text-dark font-weight-500">${amenity}</span>
                      </div>
                    </div>
                  </c:forEach>
                </div>
              </div>

              <!-- NỘI QUY & CHÍNH SÁCH -->
              <div class="p-4 rounded border bg-white mb-5">
                <h4 class="h5 font-weight-bold text-dark mb-3"><i class="fa fa-info-circle text-primary mr-2"></i> Quy
                  Định & Nội Quy Lưu Trú</h4>
                <ul class="text-muted small pl-3 mb-0 room-amenities">
                  <li><strong>Giờ nhận phòng:</strong> 14:00 | <strong>Giờ trả phòng:</strong> 12:00 trưa hôm sau.</li>
                  <li>Không hút thuốc lá trong phòng ngủ (có khu vực hút thuốc riêng ngoài ban công/sân vườn).</li>
                  <li>Vui lòng giữ trật tự và không mở nhạc lớn sau 22:00 để đảm bảo không gian yên tĩnh cho các phòng
                    xung quanh.</li>
                  <li>Hủy phòng miễn phí trước 48 giờ tính từ ngày nhận phòng.</li>
                </ul>
              </div>

            </div>

            <!-- CỘT PHẢI: KHUNG ĐẶT PHÒNG STICKY -->
            <div class="col-lg-4" data-aos="fade-up" data-aos-delay="100">
              <div class="card border-0 shadow-lg p-4 rounded sticky-top" style="top: 100px;">
                <span class="text-uppercase letter-spacing-1 text-muted small font-weight-bold">Giá ưu đãi trực
                  tuyến</span>
                <div class="my-3">
                  <span class="h2 font-weight-bold text-primary">
                    <fmt:formatNumber value="${room.pricePerNight}" pattern="#,###" />
                  </span>
                  <span class="text-muted font-weight-bold"> VNĐ / đêm</span>
                </div>
                <p class="text-muted small mb-4">Đã bao gồm thuế, phí dịch vụ và bữa sáng tự chọn tiêu chuẩn.</p>

                <div class="border-top pt-3 mb-4">
                  <div class="d-flex justify-content-between mb-2 small">
                    <span class="text-muted">Trạng thái:</span>
                    <span class="badge badge-success px-2 py-1">${room.status == 'AVAILABLE' ? 'Còn trống' :
                      room.status}</span>
                  </div>
                  <div class="d-flex justify-content-between mb-2 small">
                    <span class="text-muted">Hạng phòng:</span>
                    <strong class="text-dark">${room.roomType.typeName}</strong>
                  </div>
                  <div class="d-flex justify-content-between small">
                    <span class="text-muted">Phù hợp:</span>
                    <strong class="text-dark">Tối đa ${room.capacity} người lớn</strong>
                  </div>
                </div>

                <a href="${pageContext.request.contextPath}/reservation?roomId=${room.id}"
                  class="btn btn-primary btn-block text-white font-weight-bold py-3 shadow mb-3">
                  <i class="fa fa-calendar-check-o mr-2"></i> Tiến Hành Đặt Phòng
                </a>

                <div class="text-center">
                  <p class="text-muted small mb-1">Cần hỗ trợ tư vấn nhanh?</p>
                  <a href="tel:0901234567" class="text-dark font-weight-bold"><i
                      class="fa fa-phone text-primary mr-1"></i> Hotline: 090 123 4567</a>
                </div>
              </div>
            </div>

          </div>

        </div>
      </section>

      <jsp:include page="common/footer.jsp" />