<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Shared page footer: site links, contact details, newsletter form, and client scripts. --%>
<%-- Footer links, contact details, and newsletter form. --%>
    <%-- Responsive footer grid: 1 column on phones, 2x2 on tablets, and 4 columns on desktop. --%>
    <footer class="section footer-section">
      <div class="container">
        <div class="row mb-4">
          <div class="col-12 col-sm-6 col-lg-3 mb-4 mb-lg-5">
            <ul class="list-unstyled link">
              <li><a href="${pageContext.request.contextPath}/about">Về chúng tôi</a></li>
              <li><a href="${pageContext.request.contextPath}/terms">Chính sách & Điều khoản</a></li>
              <li><a href="${pageContext.request.contextPath}/rooms">Danh sách phòng</a></li>
              <li><a href="${pageContext.request.contextPath}/reservation">Đặt phòng nhanh</a></li>
            </ul>
          </div>
          <div class="col-12 col-sm-6 col-lg-3 mb-4 mb-lg-5">
            <ul class="list-unstyled link">
              <li><a href="#">Chính sách & Điều khoản</a></li>
              <li><a href="#">Dịch vụ Homestay</a></li>
              <li><a href="#">Địa điểm du lịch lân cận</a></li>
            </ul>
          </div>
          <div class="col-12 col-sm-6 col-lg-3 mb-4 mb-lg-5 pr-lg-4 contact-info">
            <p><span class="d-block"><span class="ion-ios-location h5 mr-3 text-primary"></span>Địa chỉ:</span> <span> 123 Đường Ven Biển, TP. Du Lịch, Việt Nam</span></p>
            <p><span class="d-block"><span class="ion-ios-telephone h5 mr-3 text-primary"></span>Điện thoại:</span> <span> (+84) 090 123 4567</span></p>
            <p><span class="d-block"><span class="ion-ios-email h5 mr-3 text-primary"></span>Email:</span> <span> info@sogohomestay.com</span></p>
          </div>
          <div class="col-12 col-sm-6 col-lg-3 mb-4 mb-lg-5">
            <p>Đăng ký nhận thông tin khuyến mãi</p>
            <form action="#" class="footer-newsletter">
              <div class="form-group">
                <input type="email" class="form-control" placeholder="Email của bạn...">
                <button type="submit" class="btn"><span class="fa fa-paper-plane"></span></button>
              </div>
            </form>
          </div>
        </div>
        <div class="row pt-4 pt-md-5 align-items-center">
          <p class="col-12 col-md-8 text-center text-md-left mb-3 mb-md-0">
            Copyright &copy;<script>document.write(new Date().getFullYear());</script> All rights reserved | Sogo Homestay Booking System
          </p>
          <p class="col-12 col-md-4 text-center text-md-right social mb-0">
            <a href="#"><span class="fa fa-tripadvisor"></span></a>
            <a href="#"><span class="fa fa-facebook"></span></a>
            <a href="#"><span class="fa fa-twitter"></span></a>
            <a href="#"><span class="fa fa-instagram"></span></a>
          </p>
        </div>
      </div>
    </footer>

    <%-- Load shared client-side libraries and site interactions. --%>
    <script src="${pageContext.request.contextPath}/assets/js/jquery-3.3.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/jquery-migrate-3.0.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/popper.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/owl.carousel.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/jquery.stellar.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/jquery.fancybox.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/aos.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap-datepicker.js"></script> 
    <script src="${pageContext.request.contextPath}/assets/js/jquery.timepicker.min.js"></script> 
    <script src="${pageContext.request.contextPath}/assets/js/main.js?v=20261029-responsive"></script>
  </body>
</html>
