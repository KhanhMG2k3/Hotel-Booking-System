<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="${pageTitle}" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

    <!-- BANNER HERO -->
    <section class="site-hero inner-page overlay" style="background-image: url(${pageContext.request.contextPath}/assets/images/hero_4.jpg)" data-stellar-background-ratio="0.5">
      <div class="container">
        <div class="row site-hero-inner justify-content-center align-items-center">
          <div class="col-md-10 text-center" data-aos="fade">
            <h1 class="heading mb-3">Về Chúng Tôi</h1>
            <ul class="custom-breadcrumbs mb-4">
              <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
              <li>&bullet;</li>
              <li>Giới Thiệu</li>
            </ul>
          </div>
        </div>
      </div>
      <a class="mouse smoothscroll" href="#about-story">
        <div class="mouse-icon">
          <span class="mouse-wheel"></span>
        </div>
      </a>
    </section>

    <!-- PHẦN CÂU CHUYỆN HOMESTAY -->
    <section class="py-5 bg-light" id="about-story">
      <div class="container">
        <div class="row align-items-center">
          <div class="col-md-12 col-lg-7 ml-auto order-lg-2 position-relative mb-5" data-aos="fade-up">
            <figure class="img-absolute">
              <img src="${pageContext.request.contextPath}/assets/images/food-1.jpg" alt="Ẩm thực homestay" class="img-fluid rounded shadow">
            </figure>
            <img src="${pageContext.request.contextPath}/assets/images/img_1.jpg" alt="Không gian Sogo Homestay" class="img-fluid rounded shadow-sm">
          </div>
          <div class="col-md-12 col-lg-4 order-lg-1" data-aos="fade-up">
            <span class="text-primary font-weight-bold text-uppercase letter-spacing-1 d-block mb-2">Chào mừng đến với</span>
            <h2 class="heading mb-4">Sogo Homestay</h2>
            <p class="mb-4 text-secondary leading-relaxed">
              ${page.content}
            </p>
            <p class="mb-4 text-secondary">
              Được thành lập với mong muốn tạo nên một điểm dừng chân mang phong cách kiến trúc mộc mạc kết hợp tiện nghi hiện đại, Sogo Homestay là nơi bạn tìm thấy sự bình yên giữa nhịp sống hối hả.
            </p>
            <p>
              <a href="${pageContext.request.contextPath}/rooms" class="btn btn-primary text-white py-2 px-4 mr-3">Khám Phá Phòng</a>
              <span class="mr-3 font-family-serif"><em>hoặc</em></span>
              <a href="${pageContext.request.contextPath}/reservation" class="text-uppercase letter-spacing-1 font-weight-bold text-primary">Đặt Phòng Ngay</a>
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- 4 GIÁ TRỊ CỐT LÕI -->
    <section class="section">
      <div class="container">
        <div class="row justify-content-center text-center mb-5">
          <div class="col-md-8">
            <span class="text-primary font-weight-bold text-uppercase letter-spacing-1 d-block mb-2">Cam Kết Của Chúng Tôi</span>
            <h2 class="heading" data-aos="fade-up">Tại Sao Khách Hàng Chọn Sogo?</h2>
          </div>
        </div>
        <div class="row">
          <div class="col-md-6 col-lg-3 text-center mb-4" data-aos="fade-up" data-aos-delay="100">
            <div class="p-4 border rounded bg-white shadow-sm h-100">
              <span class="ion-ios-home h1 text-primary mb-3 d-block"></span>
              <h4 class="h5 font-weight-bold mb-3">Không Gian Ấm Cúng</h4>
              <p class="text-muted small">Phòng nghỉ bài trí tinh tế, sạch sẽ tuyệt đối, mang lại cảm giác thân quen như chính ngôi nhà của bạn.</p>
            </div>
          </div>
          <div class="col-md-6 col-lg-3 text-center mb-4" data-aos="fade-up" data-aos-delay="200">
            <div class="p-4 border rounded bg-white shadow-sm h-100">
              <span class="ion-ios-location h1 text-primary mb-3 d-block"></span>
              <h4 class="h5 font-weight-bold mb-3">Vị Trí Đắc Địa</h4>
              <p class="text-muted small">Thuận tiện di chuyển ra bãi biển, các danh lam thắng cảnh và khu phố ẩm thực sầm uất.</p>
            </div>
          </div>
          <div class="col-md-6 col-lg-3 text-center mb-4" data-aos="fade-up" data-aos-delay="300">
            <div class="p-4 border rounded bg-white shadow-sm h-100">
              <span class="ion-ios-heart h1 text-primary mb-3 d-block"></span>
              <h4 class="h5 font-weight-bold mb-3">Phục Vụ Tận Tâm</h4>
              <p class="text-muted small">Đội ngũ hỗ trợ 24/7 sẵn sàng tư vấn lịch trình, gợi ý địa điểm ăn uống ngon và hỗ trợ thuê xe.</p>
            </div>
          </div>
          <div class="col-md-6 col-lg-3 text-center mb-4" data-aos="fade-up" data-aos-delay="400">
            <div class="p-4 border rounded bg-white shadow-sm h-100">
              <span class="ion-ios-pricetag h1 text-primary mb-3 d-block"></span>
              <h4 class="h5 font-weight-bold mb-3">Giá Cả Minh Bạch</h4>
              <p class="text-muted small">Cam kết không phụ phí ẩn, chính sách đặt cọc và hoàn hủy linh hoạt, minh bạch rõ ràng.</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ĐỘI NGŨ QUẢN LÝ / NHÂN SỰ -->
    <section class="section bg-light">
      <div class="container">
        <div class="row justify-content-center text-center mb-5">
          <div class="col-md-7">
            <span class="text-primary font-weight-bold text-uppercase letter-spacing-1 d-block mb-2">Gặp Gỡ Đội Ngũ</span>
            <h2 class="heading" data-aos="fade-up">Đội Ngũ Quản Lý & Vận Hành</h2>
          </div>
        </div>
        <div class="row justify-content-center">
          <div class="col-md-6 col-lg-4 mb-4" data-aos="fade-up" data-aos-delay="100">
            <div class="block-2">
              <div class="flipper">
                <div class="front" style="background-image: url(${pageContext.request.contextPath}/assets/images/person_3.jpg);">
                  <div class="box">
                    <h2>Nguyễn Văn An</h2>
                    <p>Quản Lý Trưởng (Homestay Manager)</p>
                  </div>
                </div>
                <div class="back">
                  <blockquote>
                    <p>&ldquo;Chúng tôi luôn nỗ lực để mỗi chuyến đi của du khách là một kỷ niệm đáng nhớ tràn ngập tiếng cười.&rdquo;</p>
                  </blockquote>
                  <div class="author d-flex">
                    <div class="image mr-3 align-self-center">
                      <img src="${pageContext.request.contextPath}/assets/images/person_3.jpg" alt="Nguyễn Văn An">
                    </div>
                    <div class="name align-self-center">
                      Nguyễn Văn An <span class="d-block">Founder & Host</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="col-md-6 col-lg-4 mb-4" data-aos="fade-up" data-aos-delay="200">
            <div class="block-2">
              <div class="flipper">
                <div class="front" style="background-image: url(${pageContext.request.contextPath}/assets/images/person_1.jpg);">
                  <div class="box">
                    <h2>Trần Minh Phương</h2>
                    <p>Trưởng Bộ Phận Dịch Vụ Khách Hàng</p>
                  </div>
                </div>
                <div class="back">
                  <blockquote>
                    <p>&ldquo;Sự hài lòng và an tâm của khách hàng là thước đo giá trị cao nhất trong công việc của chúng tôi.&rdquo;</p>
                  </blockquote>
                  <div class="author d-flex">
                    <div class="image mr-3 align-self-center">
                      <img src="${pageContext.request.contextPath}/assets/images/person_1.jpg" alt="Trần Minh Phương">
                    </div>
                    <div class="name align-self-center">
                      Trần Minh Phương <span class="d-block">Customer Care Lead</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

<jsp:include page="common/footer.jsp" />