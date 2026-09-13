<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Sogo Homestay - Giới Thiệu & Trải Nghiệm Không Gian Nghỉ Dưỡng" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

    <!-- HERO SECTION - GIỚI THIỆU TỔNG QUAN -->
    <section class="site-hero overlay" style="background-image: url(${pageContext.request.contextPath}/assets/images/hero_4.jpg)" data-stellar-background-ratio="0.5">
      <div class="container">
        <div class="row site-hero-inner justify-content-center align-items-center">
          <div class="col-md-10 text-center" data-aos="fade-up">
            <span class="custom-caption text-uppercase text-white d-block mb-3">Chào Mừng Tới <span class="fa fa-star text-primary"></span> Sogo Homestay</span>
            <h1 class="heading mb-4">Không Gian Nghỉ Dưỡng Bình Yên & Trải Nghiệm Đáng Nhớ</h1>
            <p class="lead text-white mb-5">Hòa mình vào thiên nhiên tươi mát, tận hưởng sự thoải mái ấm cúng như chính ngôi nhà của bạn.</p>
            <p>
              <a href="#about-story" class="btn btn-primary text-white py-3 px-4 mr-3 font-weight-bold smoothscroll">Khám Phá Homestay</a>
              <a href="${pageContext.request.contextPath}/rooms" class="btn btn-outline-light py-3 px-4 font-weight-bold">Xem Danh Sách Phòng</a>
            </p>
          </div>
        </div>
      </div>

      <a class="mouse smoothscroll" href="#about-story">
        <div class="mouse-icon">
          <span class="mouse-wheel"></span>
        </div>
      </a>
    </section>
    <!-- END HERO SECTION -->

    <!-- PHẦN 1: CÂU CHUYỆN & GIỚI THIỆU VỀ SOGO HOMESTAY -->
    <section class="py-5 bg-light" id="about-story">
      <div class="container py-5">
        <div class="row align-items-center">
          <div class="col-md-12 col-lg-7 ml-auto order-lg-2 position-relative mb-5" data-aos="fade-up">
            <figure class="img-absolute">
              <img src="${pageContext.request.contextPath}/assets/images/food-1.jpg" alt="Ẩm thực Homestay" class="img-fluid rounded shadow">
            </figure>
            <img src="${pageContext.request.contextPath}/assets/images/img_1.jpg" alt="Không gian Sogo Homestay" class="img-fluid rounded shadow-lg">
          </div>
          <div class="col-md-12 col-lg-4 order-lg-1" data-aos="fade-up" data-aos-delay="100">
            <span class="text-primary font-weight-bold text-uppercase letter-spacing-1 d-block mb-2">Về chúng tôi</span>
            <h2 class="heading mb-4">Nơi Dừng Chân Lý Tưởng Dành Cho Bạn</h2>
            <p class="mb-4 text-muted">Sogo Homestay được xây dựng với mong muốn mang lại cho du khách một chốn dừng chân thanh bình, ấm cúng và đầy ắp tiếng cười. Nằm tại vị trí thuận lợi gần biển và các điểm du lịch nổi tiếng, chúng tôi kết hợp hài hòa giữa nét mộc mạc bản địa và tiện nghi hiện đại.</p>
            <p class="mb-4 text-muted">Dù bạn đi du lịch một mình, cùng người thương hay cả gia đình, Sogo luôn sẵn sàng chào đón bạn với lòng hiếu khách nồng hậu nhất.</p>
            <p>
              <a href="${pageContext.request.contextPath}/rooms" class="btn btn-primary text-white py-2 px-4 mr-3">Khám Phá Các Hạng Phòng</a>
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- PHẦN 2: TIỆN ÍCH & TRẢI NGHIỆM ĐẶC QUYỀN TẠI HOMESTAY -->
    <section class="section">
      <div class="container">
        <div class="row justify-content-center text-center mb-5">
          <div class="col-md-8">
            <span class="text-primary font-weight-bold text-uppercase letter-spacing-1 d-block mb-2">Dịch vụ & Tiện ích</span>
            <h2 class="heading" data-aos="fade-up">Trải Nghiệm Độc Đáo Tại Sogo</h2>
            <p class="text-muted" data-aos="fade-up" data-aos-delay="100">Mỗi khoảnh khắc tại Sogo Homestay đều được chăm chút kỹ lưỡng để mang đến cho bạn kỳ nghỉ trọn vẹn và thư thái nhất.</p>
          </div>
        </div>
        
        <div class="row">
          <div class="col-md-6 col-lg-4 mb-4" data-aos="fade-up">
            <div class="media d-block room border rounded p-4 text-center h-100 bg-white shadow-sm">
              <div class="display-4 text-primary mb-3">
                <span class="fa fa-coffee"></span>
              </div>
              <div class="media-body">
                <h3 class="mt-0 h5 font-weight-bold">Bữa Sáng & Cafe Sân Vườn</h3>
                <p class="text-muted small">Thưởng thức ly cafe sáng thơm nồng và các món ăn bản địa hấp dẫn trong khuôn viên vườn xanh mát.</p>
              </div>
            </div>
          </div>

          <div class="col-md-6 col-lg-4 mb-4" data-aos="fade-up" data-aos-delay="100">
            <div class="media d-block room border rounded p-4 text-center h-100 bg-white shadow-sm">
              <div class="display-4 text-primary mb-3">
                <span class="fa fa-cutlery"></span>
              </div>
              <div class="media-body">
                <h3 class="mt-0 h5 font-weight-bold">Bếp Tự Nấu & Tiệc BBQ</h3>
                <p class="text-muted small">Không gian bếp mở đầy đủ dụng cụ và khu vực sân nướng BBQ ngoài trời dành cho gia đình, nhóm bạn.</p>
              </div>
            </div>
          </div>

          <div class="col-md-6 col-lg-4 mb-4" data-aos="fade-up" data-aos-delay="200">
            <div class="media d-block room border rounded p-4 text-center h-100 bg-white shadow-sm">
              <div class="display-4 text-primary mb-3">
                <span class="fa fa-wifi"></span>
              </div>
              <div class="media-body">
                <h3 class="mt-0 h5 font-weight-bold">Wifi Tốc Độ Cao & Không Gian Làm Việc</h3>
                <p class="text-muted small">Phủ sóng wifi tốc độ cao toàn bộ khuôn viên, thích hợp cho làm việc từ xa (Workation) kết hợp nghỉ ngơi.</p>
              </div>
            </div>
          </div>

          <div class="col-md-6 col-lg-4 mb-4" data-aos="fade-up">
            <div class="media d-block room border rounded p-4 text-center h-100 bg-white shadow-sm">
              <div class="display-4 text-primary mb-3">
                <span class="fa fa-bicycle"></span>
              </div>
              <div class="media-body">
                <h3 class="mt-0 h5 font-weight-bold">Mượn Xe Đạp Dạo Biển Miễn Phí</h3>
                <p class="text-muted small">Khám phá các con đường ven biển thanh bình và ngắm bình minh/hoàng hôn bằng xe đạp miễn phí.</p>
              </div>
            </div>
          </div>

          <div class="col-md-6 col-lg-4 mb-4" data-aos="fade-up" data-aos-delay="100">
            <div class="media d-block room border rounded p-4 text-center h-100 bg-white shadow-sm">
              <div class="display-4 text-primary mb-3">
                <span class="fa fa-map-marker"></span>
              </div>
              <div class="media-body">
                <h3 class="mt-0 h5 font-weight-bold">Tư Vấn Tour & Điểm Check-in</h3>
                <p class="text-muted small">Đội ngũ homestay nhiệt tình gợi ý những địa điểm ăn ngon, quán cafe đẹp và tour trải nghiệm địa phương.</p>
              </div>
            </div>
          </div>

          <div class="col-md-6 col-lg-4 mb-4" data-aos="fade-up" data-aos-delay="200">
            <div class="media d-block room border rounded p-4 text-center h-100 bg-white shadow-sm">
              <div class="display-4 text-primary mb-3">
                <span class="fa fa-heart"></span>
              </div>
              <div class="media-body">
                <h3 class="mt-0 h5 font-weight-bold">Hỗ Trợ Tận Tâm 24/7</h3>
                <p class="text-muted small">Luôn đồng hành và hỗ trợ khách hàng mọi lúc để đảm bảo bạn có một trải nghiệm nghỉ dưỡng suôn sẻ nhất.</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- PHẦN 3: HÌNH ẢNH KHÔNG GIAN HOMESTAY (SLIDER) -->
    <section class="section slider-section bg-light">
      <div class="container">
        <div class="row justify-content-center text-center mb-5">
          <div class="col-md-7">
            <h2 class="heading" data-aos="fade-up">Góc Ảnh Không Gian Sogo</h2>
            <p class="text-muted" data-aos="fade-up" data-aos-delay="100">Một thoáng nhìn ngắm vẻ đẹp tinh tế, mộc mạc và thư thái tại Sogo Homestay.</p>
          </div>
        </div>
        <div class="row">
          <div class="col-md-12">
            <div class="home-slider major-caousel owl-carousel mb-5" data-aos="fade-up" data-aos-delay="200">
              <div class="slider-item">
                <a href="${pageContext.request.contextPath}/assets/images/slider-1.jpg" data-fancybox="images" data-caption="Khuôn viên Homestay">
                  <img src="${pageContext.request.contextPath}/assets/images/slider-1.jpg" alt="Khuôn viên" class="img-fluid rounded">
                </a>
              </div>
              <div class="slider-item">
                <a href="${pageContext.request.contextPath}/assets/images/slider-2.jpg" data-fancybox="images" data-caption="Phòng sinh hoạt chung">
                  <img src="${pageContext.request.contextPath}/assets/images/slider-2.jpg" alt="Phòng khách" class="img-fluid rounded">
                </a>
              </div>
              <div class="slider-item">
                <a href="${pageContext.request.contextPath}/assets/images/slider-3.jpg" data-fancybox="images" data-caption="Không gian mở ấm cúng">
                  <img src="${pageContext.request.contextPath}/assets/images/slider-3.jpg" alt="Không gian mở" class="img-fluid rounded">
                </a>
              </div>
              <div class="slider-item">
                <a href="${pageContext.request.contextPath}/assets/images/slider-4.jpg" data-fancybox="images" data-caption="Ban công ngắm cảnh">
                  <img src="${pageContext.request.contextPath}/assets/images/slider-4.jpg" alt="Ban công" class="img-fluid rounded">
                </a>
              </div>
              <div class="slider-item">
                <a href="${pageContext.request.contextPath}/assets/images/slider-5.jpg" data-fancybox="images" data-caption="Bể bơi & sân tắm nắng">
                  <img src="${pageContext.request.contextPath}/assets/images/slider-5.jpg" alt="Bể bơi" class="img-fluid rounded">
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- PHẦN 4: ĐÁNH GIÁ CỦA DU KHÁCH (TESTIMONIALS) -->
    <section class="section testimonial-section">
      <div class="container">
        <div class="row justify-content-center text-center mb-5">
          <div class="col-md-7">
            <span class="text-primary font-weight-bold text-uppercase letter-spacing-1 d-block mb-2">Cảm nhận khách hàng</span>
            <h2 class="heading" data-aos="fade-up">Khách Hàng Nói Gì Về Chúng Tôi</h2>
          </div>
        </div>
        <div class="row">
          <div class="js-carousel-2 owl-carousel mb-5" data-aos="fade-up" data-aos-delay="200">
            <div class="testimonial text-center slider-item">
              <div class="author-image mb-3">
                <img src="${pageContext.request.contextPath}/assets/images/person_1.jpg" alt="Khách hàng" class="rounded-circle mx-auto">
              </div>
              <blockquote>
                <p>&ldquo;Không gian homestay thật sự rất yên tĩnh và thư giãn. Chủ nhà vô cùng nhiệt tình, chỉ cho bọn mình rất nhiều quán ăn ngon của người địa phương. Chắc chắn sẽ quay lại!&rdquo;</p>
              </blockquote>
              <p><em>&mdash; Minh Anh (Hà Nội)</em></p>
            </div> 

            <div class="testimonial text-center slider-item">
              <div class="author-image mb-3">
                <img src="${pageContext.request.contextPath}/assets/images/person_2.jpg" alt="Khách hàng" class="rounded-circle mx-auto">
              </div>
              <blockquote>
                <p>&ldquo;Phòng ốc sạch sẽ, decor rất có gu và view sân vườn cực chill. Bọn mình đã có một buổi tối nướng BBQ rất vui vẻ bên bạn bè tại khuôn viên Sogo.&rdquo;</p>
              </blockquote>
              <p><em>&mdash; Hoàng Dũng (Đà Nẵng)</em></p>
            </div>

            <div class="testimonial text-center slider-item">
              <div class="author-image mb-3">
                <img src="${pageContext.request.contextPath}/assets/images/person_3.jpg" alt="Khách hàng" class="rounded-circle mx-auto">
              </div>
              <blockquote>
                <p>&ldquo;Trải nghiệm tuyệt vời vượt ngoài mong đợi! Vị trí rất gần biển, sáng sớm mượn xe đạp ra ngắm bình minh cực kỳ thích. 10/10 cho dịch vụ tại đây!&rdquo;</p>
              </blockquote>
              <p><em>&mdash; Phương Thảo (TP. Hồ Chí Minh)</em></p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- PHẦN 5: BANNER KÊU GỌI HÀNH ĐỘNG (CTA SANG TRANG ROOMS) -->
    <section class="section bg-primary text-white text-center py-5">
      <div class="container py-4">
        <div class="row justify-content-center">
          <div class="col-md-9" data-aos="fade-up">
            <h2 class="text-white font-weight-bold mb-3">Sẵn Sàng Cho Kỳ Nghỉ Tuyệt Vời Của Bạn?</h2>
            <p class="lead text-white-50 mb-4">Khám phá các hạng phòng đơn, phòng đôi và phòng gia đình với giá ưu đãi tốt nhất ngay hôm nay.</p>
            <a href="${pageContext.request.contextPath}/rooms" class="btn btn-warning text-dark font-weight-bold px-5 py-3 shadow-lg">
              Xem Danh Sách & Đặt Phòng Ngay <i class="fa fa-arrow-right ml-2"></i>
            </a>
          </div>
        </div>
      </div>
    </section>

<jsp:include page="common/footer.jsp" />
