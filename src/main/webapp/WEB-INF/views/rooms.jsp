<%@ page contentType="text/html;charset=UTF-8" language="java" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

      <jsp:include page="common/header.jsp">
        <jsp:param name="pageTitle" value="Sogo Homestay - Danh Sách Phòng & Đặt Phòng" />
      </jsp:include>

      <jsp:include page="common/navbar.jsp" />

      <!-- HERO SECTION -->
      <section class="site-hero inner-page overlay hero-rooms" data-stellar-background-ratio="0.5">
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
          <div class="row justify-content-center text-center mb-4">
            <div class="col-md-8">
              <span class="text-primary font-weight-bold text-uppercase letter-spacing-1 d-block mb-2">Hệ thống phòng
                nghỉ</span>
              <h2 class="heading" data-aos="fade-up">Chọn Phòng & Khám Phá Không Gian</h2>
              <p class="text-muted" data-aos="fade-up" data-aos-delay="100">
                Tìm kiếm phòng nghỉ phù hợp theo nhu cầu, mức giá và đánh giá của khách hàng.
              </p>
            </div>
          </div>

          <!-- BỘ LỌC TÌM KIẾM (SEARCH & FILTERS) -->
          <div class="sogo-filter-card p-4 mb-4" data-aos="fade-up">
            <form action="${pageContext.request.contextPath}/rooms" method="GET" id="searchFilterForm">
              <div class="row">
                <!-- 1. Từ khóa -->
                <div class="col-lg-3 col-md-6 mb-3">
                  <label class="sogo-filter-label"><i class="fa fa-search text-primary mr-1"></i> Tìm kiếm phòng</label>
                  <input type="text" name="keyword" class="form-control" placeholder="Tên phòng, địa điểm..." value="${keyword}">
                </div>

                <!-- 2. Tỉnh / Thành phố -->
                <div class="col-lg-3 col-md-6 mb-3">
                  <label class="sogo-filter-label"><i class="fa fa-map-marker text-danger mr-1"></i> Tỉnh / Thành phố</label>
                  <select name="provinceId" class="form-control">
                    <option value="">Tất cả tỉnh thành</option>
                    <c:forEach var="p" items="${provinces}">
                      <option value="${p.id}" ${p.id == provinceId ? 'selected' : ''}>📍 ${p.provinceName}</option>
                    </c:forEach>
                  </select>
                </div>

                <!-- 3. Loại phòng -->
                <div class="col-lg-2 col-md-6 mb-3">
                  <label class="sogo-filter-label"><i class="fa fa-th-large text-primary mr-1"></i> Loại phòng</label>
                  <select name="typeId" class="form-control">
                    <option value="">Tất cả loại phòng</option>
                    <c:forEach var="rt" items="${roomTypes}">
                      <option value="${rt.id}" ${rt.id == typeId ? 'selected' : ''}>${rt.typeName}</option>
                    </c:forEach>
                  </select>
                </div>

                <!-- 4. Sức chứa / Số khách -->
                <div class="col-lg-2 col-md-6 mb-3">
                  <label class="sogo-filter-label"><i class="fa fa-users text-primary mr-1"></i> Sức chứa</label>
                  <select name="capacity" class="form-control">
                    <option value="">Tất cả</option>
                    <option value="1" ${capacity == 1 ? 'selected' : ''}>1 Khách</option>
                    <option value="2" ${capacity == 2 ? 'selected' : ''}>2 Khách trở lên</option>
                    <option value="4" ${capacity == 4 ? 'selected' : ''}>4 Khách trở lên</option>
                    <option value="6" ${capacity == 6 ? 'selected' : ''}>6 Khách trở lên</option>
                  </select>
                </div>

                <!-- 5. Đánh giá sao -->
                <div class="col-lg-2 col-md-6 mb-3">
                  <label class="sogo-filter-label"><i class="fa fa-star text-warning mr-1"></i> Đánh giá sao</label>
                  <select name="rating" class="form-control">
                    <option value="">Tất cả đánh giá</option>
                    <option value="5.0" ${rating == '5.0' or rating == '4.8' ? 'selected' : ''}>⭐ 5.0 sao (4.8 - 5.0)</option>
                    <option value="4.5" ${rating == '4.5' ? 'selected' : ''}>⭐ 4.5 sao (4.5 - 4.7)</option>
                    <option value="4.0" ${rating == '4.0' ? 'selected' : ''}>⭐ 4.0 sao (4.0 - 4.4)</option>
                    <option value="3.5" ${rating == '3.5' ? 'selected' : ''}>⭐ 3.5 sao (3.5 - 3.9)</option>
                  </select>
                </div>
              </div>

              <!-- Hàng thứ hai: Khoảng giá, Sắp xếp & Nút tìm kiếm -->
              <div class="row align-items-center pt-2 border-top">
                <div class="col-lg-5 col-md-12 mb-3 mb-lg-0">
                  <div class="d-flex align-items-center flex-wrap">
                    <span class="sogo-filter-label mr-3 mb-1"><i class="fa fa-money text-success mr-1"></i> Mức giá (VNĐ):</span>
                    <div class="d-inline-flex align-items-center mb-1 mr-2" style="max-width: 320px;">
                      <input type="number" id="minPriceInput" name="minPrice" class="form-control form-control-sm mr-2" placeholder="Từ (VNĐ)" value="${minPrice}" min="0" step="50000" style="width: 130px;">
                      <span class="text-muted mr-2">-</span>
                      <input type="number" id="maxPriceInput" name="maxPrice" class="form-control form-control-sm" placeholder="Đến (VNĐ)" value="${maxPrice}" min="0" step="50000" style="width: 130px;">
                    </div>
                    <div class="quick-presets d-inline-block">
                      <button type="button" class="quick-price-btn" onclick="setPriceRange('', 700000)">&lt; 700k</button>
                      <button type="button" class="quick-price-btn" onclick="setPriceRange(700000, 1200000)">700k - 1.2tr</button>
                      <button type="button" class="quick-price-btn" onclick="setPriceRange(1200000, '')">&gt; 1.2tr</button>
                      <button type="button" class="quick-price-btn text-danger" onclick="setPriceRange('', '')">Xóa giá</button>
                    </div>
                  </div>
                </div>

                <!-- Sắp xếp -->
                <div class="col-lg-3 col-md-6 mb-3 mb-lg-0">
                  <div class="d-flex align-items-center">
                    <label class="sogo-filter-label mr-2 mb-0 text-nowrap"><i class="fa fa-sort text-primary mr-1"></i> Sắp xếp:</label>
                    <select name="sortBy" class="form-control form-control-sm">
                      <option value="">Mặc định</option>
                      <option value="price_asc" ${sortBy == 'price_asc' ? 'selected' : ''}>Giá: Thấp đến Cao</option>
                      <option value="price_desc" ${sortBy == 'price_desc' ? 'selected' : ''}>Giá: Cao đến Thấp</option>
                      <option value="rating_desc" ${sortBy == 'rating_desc' ? 'selected' : ''}>Đánh giá cao nhất ⭐</option>
                      <option value="capacity_desc" ${sortBy == 'capacity_desc' ? 'selected' : ''}>Sức chứa lớn nhất</option>
                    </select>
                  </div>
                </div>

                <div class="col-lg-4 col-md-6 text-lg-right">
                  <div class="d-flex justify-content-lg-end">
                    <button type="submit" class="btn btn-primary px-4 font-weight-bold shadow-sm mr-2">
                      <i class="fa fa-filter mr-1"></i> Áp Dụng Lọc
                    </button>
                    <a href="${pageContext.request.contextPath}/rooms" class="btn btn-outline-secondary px-3" title="Đặt lại bộ lọc">
                      <i class="fa fa-refresh mr-1"></i> Đặt Lại
                    </a>
                  </div>
                </div>
              </div>
            </form>
          </div>

          <!-- THỐNG KÊ KẾT QUẢ & CÁC TAG LỌC ĐANG CHỌN -->
          <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap">
            <div>
              <span class="h6 font-weight-bold text-dark mb-0">
                Tìm thấy <span class="text-primary font-weight-bold">${totalRoomsFound}</span> phòng phù hợp
              </span>
            </div>
            <div class="mt-2 mt-md-0">
              <c:if test="${not empty keyword}">
                <span class="filter-active-pill">
                  Từ khóa: <strong>${keyword}</strong>
                </span>
              </c:if>
              <c:if test="${not empty provinceId}">
                <c:forEach var="p" items="${provinces}">
                  <c:if test="${p.id == provinceId}">
                    <span class="filter-active-pill">
                      <i class="fa fa-map-marker text-danger mr-1"></i> <strong>${p.provinceName}</strong>
                    </span>
                  </c:if>
                </c:forEach>
              </c:if>
              <c:if test="${not empty rating}">
                <span class="filter-active-pill">
                  Đánh giá: <strong>
                    <c:choose>
                      <c:when test="${rating == '5.0' or rating == '4.8'}">⭐ 5.0 sao (4.8 - 5.0)</c:when>
                      <c:when test="${rating == '4.5'}">⭐ 4.5 sao (4.5 - 4.7)</c:when>
                      <c:when test="${rating == '4.0'}">⭐ 4.0 sao (4.0 - 4.4)</c:when>
                      <c:when test="${rating == '3.5'}">⭐ 3.5 sao (3.5 - 3.9)</c:when>
                      <c:otherwise>⭐ ${rating}</c:otherwise>
                    </c:choose>
                  </strong>
                </span>
              </c:if>
              <c:if test="${not empty capacity}">
                <span class="filter-active-pill">
                  Khách: <strong>&ge; ${capacity}</strong>
                </span>
              </c:if>
              <c:if test="${not empty minPrice or not empty maxPrice}">
                <span class="filter-active-pill">
                  Giá: <strong>
                    <c:choose>
                      <c:when test="${not empty minPrice and not empty maxPrice}">
                        <fmt:formatNumber value="${minPrice}" pattern="#,###"/> - <fmt:formatNumber value="${maxPrice}" pattern="#,###"/> đ
                      </c:when>
                      <c:when test="${not empty minPrice}">
                        &ge; <fmt:formatNumber value="${minPrice}" pattern="#,###"/> đ
                      </c:when>
                      <c:otherwise>
                        &le; <fmt:formatNumber value="${maxPrice}" pattern="#,###"/> đ
                      </c:otherwise>
                    </c:choose>
                  </strong>
                </span>
              </c:if>
              <c:if test="${not empty keyword or not empty typeId or not empty provinceId or not empty capacity or not empty rating or not empty minRating or not empty minPrice or not empty maxPrice or not empty sortBy}">
                <a href="${pageContext.request.contextPath}/rooms" class="badge badge-light border text-danger p-2 ml-1" title="Xóa tất cả bộ lọc">
                  <i class="fa fa-times mr-1"></i> Bỏ lọc
                </a>
              </c:if>
            </div>
          </div>

          <div class="row">
            <c:choose>
              <c:when test="${not empty rooms}">
                <c:forEach var="room" items="${rooms}">
                  <div class="col-md-6 col-lg-4 mb-5" data-aos="fade-up">
                    <div class="room border rounded overflow-hidden shadow-sm h-100 d-flex flex-column bg-white">

                      <!-- HÌNH ẢNH CÓ LINK SANG CHI TIẾT PHÒNG -->
                      <a href="${pageContext.request.contextPath}/room-detail?id=${room.id}"
                        class="d-block position-relative overflow-hidden">
                        <img
                          src="${pageContext.request.contextPath}/assets/${not empty room.imageUrl ? room.imageUrl : 'images/img_1.jpg'}"
                          alt="${room.roomName}" class="img-fluid w-100 room-card-image">
                        <span class="badge badge-primary position-absolute px-3 py-2 font-weight-bold room-code-badge">
                          Mã: ${room.roomNumber}
                        </span>
                        <span class="badge badge-dark position-absolute px-2 py-1 room-gallery-badge">
                          <i class="fa fa-camera mr-1"></i> Xem album ảnh
                        </span>
                      </a>

                      <div class="p-4 text-center room-info flex-grow-1 d-flex flex-column justify-content-between">
                        <div>
                          <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="badge badge-light border text-muted">${room.roomType.typeName}</span>
                            <span class="sogo-rating-badge">
                              <i class="fa fa-star text-warning"></i> <fmt:formatNumber value="${room.rating}" minFractionDigits="1" maxFractionDigits="1" />
                              <small class="text-muted font-weight-normal">(${room.reviewCount})</small>
                            </span>
                          </div>
                          <h2 class="h5 font-weight-bold mb-1">
                            <a href="${pageContext.request.contextPath}/room-detail?id=${room.id}"
                              class="text-dark hover-primary">${room.roomName}</a>
                          </h2>
                          <c:if test="${not empty room.provinceName}">
                            <div class="text-muted small text-left mb-2">
                              <i class="fa fa-map-marker text-danger mr-1"></i>
                              <span class="font-weight-bold text-dark">${room.provinceName}</span>
                              <c:if test="${not empty room.propertyName}">
                                <span class="text-muted">&bull; ${room.propertyName}</span>
                              </c:if>
                            </div>
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
                              <fmt:formatNumber value="${room.pricePerNight}" pattern="#,###" /> VNĐ <small
                                class="text-muted font-weight-normal">/đêm</small>
                            </span>
                          </div>

                          <!-- CÁC NÚT HÀNH ĐỘNG -->
                          <div class="row no-gutters">
                            <div class="col-6 pr-1">
                              <a href="${pageContext.request.contextPath}/room-detail?id=${room.id}"
                                class="btn btn-outline-primary btn-block btn-sm py-2 font-weight-bold">
                                <i class="fa fa-eye mr-1"></i> Chi Tiết
                              </a>
                            </div>
                            <div class="col-6 pl-1">
                              <a href="${pageContext.request.contextPath}/reservation?roomId=${room.id}"
                                class="btn btn-primary btn-block btn-sm text-white py-2 font-weight-bold shadow-sm">
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
                <div class="col-12 py-4">
                  <div class="empty-search-box text-center">
                    <div class="mb-3 text-warning">
                      <i class="fa fa-search fa-3x"></i>
                    </div>
                    <h3 class="h4 font-weight-bold text-dark mb-2">Không tìm thấy phòng phù hợp</h3>
                    <p class="text-muted mb-4" style="max-width: 500px; margin: 0 auto;">
                      Không có phòng nào thỏa mãn các tiêu chí tìm kiếm hiện tại. Vui lòng thử nới lỏng mức giá, giảm tiêu chuẩn số sao đánh giá hoặc bấm nút bên dưới để xem lại tất cả phòng.
                    </p>
                    <a href="${pageContext.request.contextPath}/rooms" class="btn btn-primary px-4 py-2 font-weight-bold shadow-sm">
                      <i class="fa fa-refresh mr-1"></i> Xem Tất Cả Phòng Nghỉ
                    </a>
                  </div>
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
              <span class="text-primary font-weight-bold text-uppercase letter-spacing-1 d-block mb-2">Thông tin lưu
                ý</span>
              <h2 class="heading" data-aos="fade-up">Chính Sách & Quy Định Homestay</h2>
            </div>
          </div>

          <div class="row">
            <div class="col-md-4 mb-4" data-aos="fade-up">
              <div class="bg-white p-4 rounded border h-100 shadow-sm">
                <h4 class="h5 font-weight-bold text-primary mb-3"><i class="fa fa-clock-o mr-2"></i> Giờ Nhận & Trả
                  Phòng</h4>
                <ul class="list-unstyled text-muted small mb-0">
                  <li class="mb-2"><strong>Nhận phòng (Check-in):</strong> Từ 14:00 trở đi.</li>
                  <li class="mb-2"><strong>Trả phòng (Check-out):</strong> Trước 12:00 trưa hôm sau.</li>
                  <li>Hỗ trợ giữ hành lý miễn phí trước khi nhận phòng hoặc sau khi trả phòng.</li>
                </ul>
              </div>
            </div>

            <div class="col-md-4 mb-4" data-aos="fade-up" data-aos-delay="100">
              <div class="bg-white p-4 rounded border h-100 shadow-sm">
                <h4 class="h5 font-weight-bold text-primary mb-3"><i class="fa fa-shield mr-2"></i> Chính Sách Giữ Chỗ &
                  Hủy Phòng</h4>
                <ul class="list-unstyled text-muted small mb-0">
                  <li class="mb-2">Giá niêm yết bằng Việt Nam Đồng (VNĐ) đã bao gồm đầy đủ tiện ích cơ bản.</li>
                  <li class="mb-2">Hủy phòng hoàn toàn miễn phí trước 48h so với ngày nhận phòng.</li>
                  <li>Không phát sinh phụ phí vệ sinh hoặc tiện ích chung.</li>
                </ul>
              </div>
            </div>

            <div class="col-md-4 mb-4" data-aos="fade-up" data-aos-delay="200">
              <div class="bg-white p-4 rounded border h-100 shadow-sm">
                <h4 class="h5 font-weight-bold text-primary mb-3"><i class="fa fa-support mr-2"></i> Hỗ Trợ Đặt Phòng
                  Nhanh</h4>
                <p class="text-muted small mb-2">Bạn cần tư vấn chọn phòng cho đoàn đông người hoặc có yêu cầu đặc biệt?
                </p>
                <p class="text-muted small mb-2">Hotline / Zalo: <strong>090 123 4567</strong></p>
                <a href="${pageContext.request.contextPath}/reservation" class="btn btn-outline-primary btn-sm mt-2">Đi
                  đến Form Đặt Phòng</a>
              </div>
            </div>
          </div>
        </div>
      </section>

      <script>
        function setPriceRange(min, max) {
          var minInput = document.getElementById('minPriceInput');
          var maxInput = document.getElementById('maxPriceInput');
          if (minInput) minInput.value = min;
          if (maxInput) maxInput.value = max;
          var form = document.getElementById('searchFilterForm');
          if (form) form.submit();
        }
      </script>

      <jsp:include page="common/footer.jsp" />