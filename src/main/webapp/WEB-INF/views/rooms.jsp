<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Sogo Homestay - Danh Sách Phòng & Đặt Phòng" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

    <!-- HERO SECTION -->
    <section class="site-hero inner-page overlay" style="background-image: url(${pageContext.request.contextPath}/assets/images/hero_4.jpg)" data-stellar-background-ratio="0.5">
      <div class="container">
        <div class="row site-hero-inner justify-content-center align-items-center">
          <div class="col-md-10 text-center" data-aos="fade">
            <h1 class="heading mb-3">Danh Sách Phòng & Đặt Chỗ</h1>
            <ul class="custom-breadcrumbs mb-4">
              <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
              <li>&bullet;</li>
              <li>Phòng Nghỉ & Đặt Chỗ</li>
            </ul>
          </div>
        </div>
      </div>

      <a class="mouse smoothscroll" href="#room-list">
        <div class="mouse-icon">
          <span class="mouse-wheel"></span>
        </div>
      </a>
    </section>
    <!-- END HERO SECTION -->

    <!-- DANH SÁCH CÁC HẠNG PHÒNG & ĐẶT PHÒNG -->
    <section class="section pb-5" id="room-list">
      <div class="container">

        <!-- FEATURE #4: BASIC SEARCH -->
        <div class="row justify-content-center mb-5">
          <div class="col-md-10">
            <div class="bg-light p-4 rounded border shadow-sm">

              <div class="text-center mb-4">
                <span class="text-primary font-weight-bold text-uppercase letter-spacing-1 d-block mb-2">
                  Tìm kiếm phòng
                </span>
                <h2 class="heading h3 mb-2">Tìm phòng phù hợp với nhu cầu</h2>
                <p class="text-muted mb-0">
                  Tìm theo địa điểm, ngày nhận phòng, ngày trả phòng và số lượng khách.
                </p>
              </div>

              <c:if test="${not empty searchError}">
                <div class="alert alert-danger" role="alert">
                  ${searchError}
                </div>
              </c:if>

              <form action="${pageContext.request.contextPath}/rooms" method="get">
                <div class="row">

                  <div class="col-md-6 col-lg-3 mb-3">
                    <label for="location" class="font-weight-bold">Địa điểm</label>
                    <input type="text"
                           id="location"
                           name="location"
                           class="form-control"
                           placeholder="Ví dụ: Đà Lạt"
                           value="${searchLocation}">
                  </div>

                  <div class="col-md-6 col-lg-3 mb-3">
                    <label for="checkIn" class="font-weight-bold">Ngày nhận phòng</label>
                    <input type="date"
                           id="checkIn"
                           name="checkIn"
                           class="form-control"
                           value="${searchCheckIn}">
                  </div>

                  <div class="col-md-6 col-lg-3 mb-3">
                    <label for="checkOut" class="font-weight-bold">Ngày trả phòng</label>
                    <input type="date"
                           id="checkOut"
                           name="checkOut"
                           class="form-control"
                           value="${searchCheckOut}">
                  </div>

                  <div class="col-md-6 col-lg-3 mb-3">
                    <label for="guests" class="font-weight-bold">Số khách</label>
                    <input type="number"
                           id="guests"
                           name="guests"
                           class="form-control"
                           min="1"
                           placeholder="Ví dụ: 2"
                           value="${searchGuests}">
                  </div>

                </div>

                <div class="text-center mt-2">
                  <button type="submit" class="btn btn-primary px-4">
                    <i class="fa fa-search mr-2"></i> Tìm kiếm
                  </button>

                  <a href="${pageContext.request.contextPath}/rooms"
                     class="btn btn-outline-secondary ml-2">
                    Xóa bộ lọc
                  </a>
                </div>
              </form>

            </div>
          </div>
        </div>
        <!-- END FEATURE #4 -->

        <div class="row justify-content-center text-center mb-5">
          <div class="col-md-8">
            <span class="text-primary font-weight-bold text-uppercase letter-spacing-1 d-block mb-2">Hệ thống phòng nghỉ</span>
            <h2 class="heading" data-aos="fade-up">Chọn Phòng & Khám Phá Không Gian</h2>
            <p class="text-muted" data-aos="fade-up" data-aos-delay="100">
              Nhấp vào phòng bất kỳ để xem chi tiết đầy đủ, album ảnh thực tế, tiện nghi và bảng giá bằng VNĐ.
            </p>
          </div>
        </div>

        <div class="row">
          <c:choose>
            <c:when test="${not empty rooms}">
              <c:forEach var="room" items="${rooms}">
                <div class="col-md-6 col-lg-4 mb-5" data-aos="fade-up">
                  <div class="room border rounded overflow-hidden shadow-sm h-100 d-flex flex-column bg-white">
                    
                    <!-- HÌNH ẢNH CÓ LINK SANG CHI TIẾT PHÒNG -->
                    <a href="${pageContext.request.contextPath}/room-detail?id=${room.id}" class="d-block position-relative overflow-hidden">
                      <img src="${pageContext.request.contextPath}/assets/${not empty room.imageUrl ? room.imageUrl : 'images/img_1.jpg'}" alt="${room.roomName}" class="img-fluid w-100" style="height: 240px; object-fit: cover; transition: transform 0.4s ease;">
                      <span class="badge badge-primary position-absolute px-3 py-2 font-weight-bold" style="top: 15px; left: 15px; font-size: 0.85rem; border-radius: 4px;">
                        Mã: ${room.roomNumber}
                      </span>
                      <span class="badge badge-dark position-absolute px-2 py-1" style="bottom: 15px; right: 15px; font-size: 0.8rem; background: rgba(0,0,0,0.7);">
                        <i class="fa fa-camera mr-1"></i> Xem album ảnh
                      </span>
                    </a>

                    <div class="p-4 text-center room-info flex-grow-1 d-flex flex-column justify-content-between">
                      <div>
                        <h2 class="h5 font-weight-bold mb-2">
                          <a href="${pageContext.request.contextPath}/room-detail?id=${room.id}" class="text-dark hover-primary">${room.roomName}</a>
                        </h2>
                        <span class="badge badge-light border text-muted mb-3">${room.roomType.typeName}</span>

                        <!-- FEATURE #4: LOCATION -->
                        <c:if test="${not empty room.location}">
                          <p class="text-primary small mb-2">
                            <i class="fa fa-map-marker mr-1"></i> ${room.location}
                          </p>
                        </c:if>

                        <p class="text-muted small text-left mb-3">${room.description}</p>
                      </div>

                      <div class="mt-3 pt-3 border-top">
                        <div class="d-flex justify-content-between align-items-center mb-2 text-muted small">
                          <span><i class="fa fa-users text-primary mr-1"></i> ${room.capacity} Khách</span>
                          <span><i class="fa fa-arrows-alt text-primary mr-1"></i> ${room.size} m²</span>
                          <span><i class="fa fa-bed text-primary mr-1"></i> Giường lớn</span>
                        </div>
                        
                        <!-- GIÁ TIỀN VNĐ -->
                        <div class="d-flex justify-content-between align-items-center mb-3">
                          <span class="text-muted small">Giá thuê:</span>
                          <span class="h5 mb-0 text-primary font-weight-bold">
                            <fmt:formatNumber value="${room.pricePerNight}" pattern="#,###" /> VNĐ <small class="text-muted font-weight-normal">/đêm</small>
                          </span>
                        </div>

                        <!-- CÁC NÚT HÀNH ĐỘNG -->
                        <div class="row no-gutters">
                          <div class="col-6 pr-1">
                            <a href="${pageContext.request.contextPath}/room-detail?id=${room.id}" class="btn btn-outline-primary btn-block btn-sm py-2 font-weight-bold">
                              <i class="fa fa-eye mr-1"></i> Chi Tiết
                            </a>
                          </div>
                          <div class="col-6 pl-1">
                            <a href="${pageContext.request.contextPath}/reservation?roomId=${room.id}" class="btn btn-primary btn-block btn-sm text-white py-2 font-weight-bold shadow-sm">
                              <i class="fa fa-calendar-check-o mr-1"></i> Đặt Ngay
                            </a>
                          </div>
                        </div>

                      </div>
                    </div>
                  </div>
                </div>
              </c:forEach>
            </c:when>

            <c:otherwise>
              <div class="col-12 text-center py-5">
                <i class="fa fa-search fa-3x text-muted mb-3"></i>
                <h4>Không tìm thấy phòng phù hợp</h4>
                <p class="text-muted">
                  Hãy thử thay đổi địa điểm, ngày nhận/trả phòng hoặc số lượng khách.
                </p>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </section>

    <!-- QUY ĐỊNH & CHÍNH SÁCH ĐẶT PHÒNG TẠI HOMESTAY -->
    <section class="section bg-light py-5">
      <div class="container">
        <div class="row justify-content-center text-center mb-5">
          <div class="col-md-8">
            <span class="text-primary font-weight-bold text-uppercase letter-spacing-1 d-block mb-2">Thông tin lưu ý</span>
            <h2 class="heading" data-aos="fade-up">Chính Sách & Quy Định Homestay</h2>
          </div>
        </div>

        <div class="row">
          <div class="col-md-4 mb-4" data-aos="fade-up">
            <div class="bg-white p-4 rounded border h-100 shadow-sm">
              <h4 class="h5 font-weight-bold text-primary mb-3"><i class="fa fa-clock-o mr-2"></i> Giờ Nhận & Trả Phòng</h4>
              <ul class="list-unstyled text-muted small mb-0">
                <li class="mb-2"><strong>Nhận phòng (Check-in):</strong> Từ 14:00 trở đi.</li>
                <li class="mb-2"><strong>Trả phòng (Check-out):</strong> Trước 12:00 trưa hôm sau.</li>
                <li>Hỗ trợ giữ hành lý miễn phí trước khi nhận phòng hoặc sau khi trả phòng.</li>
              </ul>
            </div>
          </div>

          <div class="col-md-4 mb-4" data-aos="fade-up" data-aos-delay="100">
            <div class="bg-white p-4 rounded border h-100 shadow-sm">
              <h4 class="h5 font-weight-bold text-primary mb-3"><i class="fa fa-shield mr-2"></i> Chính Sách Giữ Chỗ & Hủy Phòng</h4>
              <ul class="list-unstyled text-muted small mb-0">
                <li class="mb-2">Giá niêm yết bằng Việt Nam Đồng (VNĐ) đã bao gồm đầy đủ tiện ích cơ bản.</li>
                <li class="mb-2">Hủy phòng hoàn toàn miễn phí trước 48h so với ngày nhận phòng.</li>
                <li>Không phát sinh phụ phí vệ sinh hoặc tiện ích chung.</li>
              </ul>
            </div>
          </div>

          <div class="col-md-4 mb-4" data-aos="fade-up" data-aos-delay="200">
            <div class="bg-white p-4 rounded border h-100 shadow-sm">
              <h4 class="h5 font-weight-bold text-primary mb-3"><i class="fa fa-support mr-2"></i> Hỗ Trợ Đặt Phòng Nhanh</h4>
              <p class="text-muted small mb-2">Bạn cần tư vấn chọn phòng cho đoàn đông người hoặc có yêu cầu đặc biệt?</p>
              <p class="text-muted small mb-2">Hotline / Zalo: <strong>090 123 4567</strong></p>
              <a href="${pageContext.request.contextPath}/reservation" class="btn btn-outline-primary btn-sm mt-2">Đi đến Form Đặt Phòng</a>
            </div>
          </div>
        </div>
      </div>
    </section>

<jsp:include page="common/footer.jsp" />
