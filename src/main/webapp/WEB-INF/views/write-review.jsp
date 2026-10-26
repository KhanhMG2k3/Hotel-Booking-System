<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Đánh Giá Kỳ Nghỉ - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<!-- HERO BREADCRUMB -->
<section class="site-hero inner-page overlay hero-review-page"
  data-hero-image="${pageContext.request.contextPath}/assets/images/hero_4.jpg"
  data-stellar-background-ratio="0.5">
  <div class="container">
    <div class="row site-hero-inner justify-content-center align-items-center">
      <div class="col-md-10 text-center" data-aos="fade">
        <h1 class="heading mb-3">Đánh Giá Kỳ Nghỉ Của Bạn</h1>
        <ul class="custom-breadcrumbs mb-4">
          <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
          <li>&bullet;</li>
          <li><a href="${pageContext.request.contextPath}/rooms">Danh Sách Phòng</a></li>
          <li>&bullet;</li>
          <li>Viết Đánh Giá</li>
        </ul>
      </div>
    </div>
  </div>
</section>

<!-- MAIN FORM SECTION -->
<section class="section bg-light py-5">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-lg-8" data-aos="fade-up">

        <!-- THẺ TÓM TẮT ĐƠN PHÒNG -->
        <div class="review-booking-card shadow-sm rounded bg-white p-4 mb-4 border">
          <div class="row align-items-center">
            <div class="col-md-4 mb-3 mb-md-0">
              <img src="${pageContext.request.contextPath}/assets/${not empty room.imageUrl ? room.imageUrl : 'images/img_1.jpg'}"
                   alt="${room.roomName}" class="img-fluid rounded w-100 review-room-thumbnail">
            </div>
            <div class="col-md-8">
              <span class="badge badge-warning text-dark font-weight-bold px-2 py-1 mb-2">Đã Hoàn Thành Kỳ Nghỉ</span>
              <h4 class="font-weight-bold text-dark mb-1">${room.roomName}</h4>
              <p class="text-muted small mb-2"><i class="fa fa-map-marker text-primary mr-1"></i> ${room.address}</p>
              <div class="small text-muted">
                <span><strong>Mã đơn:</strong> ${not empty booking.bookingCode ? booking.bookingCode : booking.id}</span> |
                <span><strong>Ngày ở:</strong> <fmt:formatDate value="${booking.checkInDate}" pattern="dd/MM/yyyy"/> - <fmt:formatDate value="${booking.checkOutDate}" pattern="dd/MM/yyyy"/></span>
              </div>
            </div>
          </div>
        </div>

        <!-- THÔNG BÁO LỖI NẾU CÓ -->
        <c:if test="${not empty errorMessage}">
          <div class="alert alert-danger shadow-sm border-0 mb-4" role="alert">
            <i class="fa fa-exclamation-circle mr-2"></i> ${errorMessage}
          </div>
        </c:if>

        <!-- FORM ĐÁNH GIÁ -->
        <div class="card border-0 shadow-sm rounded-lg p-4 p-md-5 bg-white">
          <h3 class="h4 font-weight-bold text-dark mb-3">Chia Sẻ Trải Nghiệm Thực Tế</h3>
          <p class="text-muted small mb-4">Đánh giá trung thực của bạn sẽ giúp những khách du lịch khác lựa chọn được phòng ưng ý và giúp chủ nhà nâng cao chất lượng dịch vụ.</p>

          <form action="${pageContext.request.contextPath}/write-review" method="POST" id="reviewForm" onsubmit="return validateReviewForm();">
            <input type="hidden" name="bookingId" value="${booking.id}">
            <input type="hidden" name="rating" id="selectedRating" value="${not empty enteredRating ? enteredRating : 5}">

            <!-- CHỌN ĐIỂM SAO TƯƠNG TÁC -->
            <div class="form-group mb-4 text-center p-3 bg-light rounded border">
              <label class="d-block font-weight-bold text-dark mb-2">Bạn chấm điểm kỳ nghỉ này mấy sao?</label>
              <div class="star-rating-widget my-2" id="starWidget">
                <i class="fa fa-star star-item" data-value="1"></i>
                <i class="fa fa-star star-item" data-value="2"></i>
                <i class="fa fa-star star-item" data-value="3"></i>
                <i class="fa fa-star star-item" data-value="4"></i>
                <i class="fa fa-star star-item" data-value="5"></i>
              </div>
              <div class="star-description font-weight-bold text-primary" id="starDescription">Tuyệt vời (5/5 sao)</div>
            </div>

            <!-- TIÊU ĐỀ ĐÁNH GIÁ -->
            <div class="form-group mb-4">
              <label for="reviewTitle" class="font-weight-bold text-dark">Tiêu đề đánh giá <span class="text-danger">*</span></label>
              <input type="text" class="form-control form-control-lg review-input" id="reviewTitle" name="title"
                     placeholder="Ví dụ: Phòng sạch sẽ, view ngắm biển tuyệt đẹp!"
                     value="<c:out value='${enteredTitle}' />" required maxlength="150">
              <small class="text-muted">Tóm tắt cảm nhận chung của bạn trong một câu ngắn (tối đa 150 ký tự).</small>
            </div>

            <!-- NỘI DUNG NHẬN XÉT -->
            <div class="form-group mb-4">
              <label for="reviewComment" class="font-weight-bold text-dark">Nội dung chi tiết <span class="text-danger">*</span></label>
              <textarea class="form-control review-textarea" id="reviewComment" name="comment" rows="6"
                        placeholder="Hãy chia sẻ thêm về không gian phòng, sự nhiệt tình của chủ nhà, tiện nghi, hoặc điều bạn thích nhất..."
                        required maxlength="1000" onkeyup="updateCharCounter()"><c:out value='${enteredComment}' /></textarea>
              <div class="d-flex justify-content-between mt-1">
                <small class="text-muted">Tối thiểu 10 ký tự, tối đa 1000 ký tự.</small>
                <small class="text-muted" id="charCounter">0 / 1000 ký tự</small>
              </div>
            </div>

            <!-- NÚT GỬI & QUAY LẠI -->
            <div class="d-flex justify-content-between align-items-center pt-3 border-top">
              <a href="${pageContext.request.contextPath}/rooms" class="btn btn-outline-secondary px-4 py-2">
                <i class="fa fa-arrow-left mr-1"></i> Quay Lại
              </a>
              <button type="submit" class="btn btn-primary px-5 py-2 font-weight-bold text-white shadow-sm btn-submit-review">
                <i class="fa fa-paper-plane mr-2"></i> Gửi Đánh Giá Ngay
              </button>
            </div>
          </form>
        </div>

      </div>
    </div>
  </div>
</section>

<!-- JAVASCRIPT XỬ LÝ CLICK CHỌN SAO & VALIDATION -->
<script>
  document.addEventListener("DOMContentLoaded", function () {
    const stars = document.querySelectorAll(".star-item");
    const ratingInput = document.getElementById("selectedRating");
    const descLabel = document.getElementById("starDescription");
    const descriptions = {
      1: "Rất tệ (1/5 sao)",
      2: "Chưa hài lòng (2/5 sao)",
      3: "Bình thường (3/5 sao)",
      4: "Hài lòng & Tốt (4/5 sao)",
      5: "Tuyệt vời (5/5 sao)"
    };

    function highlightStars(val) {
      stars.forEach(star => {
        const starVal = parseInt(star.getAttribute("data-value"));
        if (starVal <= val) {
          star.classList.add("active");
        } else {
          star.classList.remove("active");
        }
      });
      if (descLabel && descriptions[val]) {
        descLabel.textContent = descriptions[val];
      }
    }

    // Khởi tạo theo giá trị ban đầu
    const initialVal = parseInt(ratingInput.value) || 5;
    highlightStars(initialVal);
    updateCharCounter();

    // Hover effect
    stars.forEach(star => {
      star.addEventListener("mouseenter", function () {
        const hoverVal = parseInt(this.getAttribute("data-value"));
        highlightStars(hoverVal);
      });

      star.addEventListener("mouseleave", function () {
        const currentVal = parseInt(ratingInput.value) || 5;
        highlightStars(currentVal);
      });

      star.addEventListener("click", function () {
        const clickVal = parseInt(this.getAttribute("data-value"));
        ratingInput.value = clickVal;
        highlightStars(clickVal);
      });
    });
  });

  function updateCharCounter() {
    const textarea = document.getElementById("reviewComment");
    const counter = document.getElementById("charCounter");
    if (textarea && counter) {
      counter.textContent = textarea.value.length + " / 1000 ký tự";
    }
  }

  function validateReviewForm() {
    const rating = parseInt(document.getElementById("selectedRating").value);
    const title = document.getElementById("reviewTitle").value.trim();
    const comment = document.getElementById("reviewComment").value.trim();

    if (isNaN(rating) || rating < 1 || rating > 5) {
      alert("Vui lòng chọn số sao từ 1 đến 5 sao!");
      return false;
    }
    if (title.length < 3) {
      alert("Tiêu đề đánh giá phải từ 3 ký tự trở lên!");
      document.getElementById("reviewTitle").focus();
      return false;
    }
    if (comment.length < 10) {
      alert("Nội dung nhận xét phải từ 10 ký tự trở lên!");
      document.getElementById("reviewComment").focus();
      return false;
    }
    return true;
  }
</script>

<jsp:include page="common/footer.jsp" />