<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="${pageTitle}" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

    <!-- BANNER HERO -->
    <section class="site-hero inner-page overlay" style="background-image: url(${pageContext.request.contextPath}/assets/images/hero_4.jpg)" data-stellar-background-ratio="0.5">
      <div class="container">
        <div class="row site-hero-inner justify-content-center align-items-center">
          <div class="col-md-10 text-center" data-aos="fade">
            <h1 class="heading mb-3">Điều Khoản & Chính Sách</h1>
            <ul class="custom-breadcrumbs mb-4">
              <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
              <li>&bullet;</li>
              <li>Quy Định Dịch Vụ</li>
            </ul>
          </div>
        </div>
      </div>
      <a class="mouse smoothscroll" href="#terms-content">
        <div class="mouse-icon">
          <span class="mouse-wheel"></span>
        </div>
      </a>
    </section>

    <!-- NỘI DUNG ĐIỀU KHOẢN -->
    <section class="section bg-light" id="terms-content">
      <div class="container">
        <div class="row">
          
          <!-- SIDEBAR ĐIỀU HƯỚNG NHANH -->
          <div class="col-lg-4 mb-5">
            <div class="bg-white p-4 rounded shadow-sm border" style="position: sticky; top: 90px;">
              <h4 class="font-weight-bold mb-3 pb-2 border-bottom text-primary">Mục Lục Điều Khoản</h4>
              <ul class="nav flex-column terms-nav">
                <li class="nav-item mb-2">
                  <a class="nav-link text-dark py-1 px-2 font-weight-bold" href="#section-1">
                    <span class="fa fa-angle-right mr-2 text-primary"></span> 1. Nhận & Trả Phòng (Check-in/out)
                  </a>
                </li>
                <li class="nav-item mb-2">
                  <a class="nav-link text-dark py-1 px-2 font-weight-bold" href="#section-2">
                    <span class="fa fa-angle-right mr-2 text-primary"></span> 2. Thanh Toán & Đặt Cọc
                  </a>
                </li>
                <li class="nav-item mb-2">
                  <a class="nav-link text-dark py-1 px-2 font-weight-bold" href="#section-3">
                    <span class="fa fa-angle-right mr-2 text-primary"></span> 3. Chính Sách Hoàn Hủy Phòng
                  </a>
                </li>
                <li class="nav-item mb-2">
                  <a class="nav-link text-dark py-1 px-2 font-weight-bold" href="#section-4">
                    <span class="fa fa-angle-right mr-2 text-primary"></span> 4. Quy Định Lưu Trú & An Ninh
                  </a>
                </li>
                <li class="nav-item mb-2">
                  <a class="nav-link text-dark py-1 px-2 font-weight-bold" href="#section-5">
                    <span class="fa fa-angle-right mr-2 text-primary"></span> 5. Bảo Mật & Quyền Riêng Tư
                  </a>
                </li>
              </ul>
              <div class="mt-4 p-3 bg-light rounded text-center">
                <small class="text-muted d-block mb-2">Bạn có thắc mắc khác?</small>
                <a href="${pageContext.request.contextPath}/reservation" class="btn btn-sm btn-outline-primary btn-block">Liên Hệ Hỗ Trợ</a>
              </div>
            </div>
          </div>

          <!-- NỘI DUNG CHI TIẾT -->
          <div class="col-lg-8">
            <div class="bg-white p-4 p-md-5 rounded shadow-sm border">
              <div class="mb-4 pb-3 border-bottom">
                <h2 class="h3 font-weight-bold text-primary mb-2">${page.title}</h2>
                <small class="text-muted">
                  <span class="fa fa-clock-o mr-1"></span> Cập nhật lần cuối: 
                  <c:choose>
                    <c:when test="${not empty page.updatedAt}">
                      <fmt:formatDate value="${page.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                    </c:when>
                    <c:otherwise>2026</c:otherwise>
                  </c:choose>
                </small>
              </div>

              <!-- Mục 1 -->
              <div id="section-1" class="mb-5">
                <h4 class="font-weight-bold text-dark mb-3">1. Quy Định Nhận Phòng & Trả Phòng</h4>
                <ul>
                  <li><strong>Giờ nhận phòng (Check-in):</strong> từ <strong>14:00</strong> của ngày bắt đầu lưu trú.</li>
                  <li><strong>Giờ trả phòng (Check-out):</strong> trước <strong>12:00</strong> trưa của ngày kết thúc lưu trú.</li>
                  <li><strong>Nhận phòng sớm / Trả phòng trễ:</strong> Tùy thuộc vào tình trạng phòng trống tại thời điểm đó và có thể áp dụng phụ phí theo quy định:
                    <ul>
                      <li>Trả phòng trễ từ 12:00 đến 18:00: Phụ thu 50% tiền phòng 1 đêm.</li>
                      <li>Trả phòng sau 18:00: Tính 100% tiền phòng 1 đêm.</li>
                    </ul>
                  </li>
                  <li>Khách vui lòng xuất trình CCCD/Hộ chiếu hợp lệ của tất cả các khách lưu trú để hoàn tất thủ tục đăng ký tạm trú với cơ quan quản lý.</li>
                </ul>
              </div>

              <!-- Mục 2 -->
              <div id="section-2" class="mb-5">
                <h4 class="font-weight-bold text-dark mb-3">2. Quy Định Thanh Toán & Đặt Cọc</h4>
                <p>Nhằm đảm bảo việc giữ phòng, khách hàng cần thực hiện đặt cọc theo tỷ lệ sau:</p>
                <ul>
                  <li><strong>Đặt cọc giữ chỗ:</strong> Tối thiểu <strong>50%</strong> tổng giá trị đơn đặt phòng trong vòng 24 giờ kể từ khi gửi yêu cầu.</li>
                  <li><strong>Thanh toán số tiền còn lại:</strong> 50% còn lại được thanh toán trực tiếp tại quầy lễ tân khi làm thủ tục Check-in.</li>
                  <li><strong>Phương thức chấp nhận:</strong> Chuyển khoản ngân hàng trực tuyến (QR Pay), thẻ tín dụng/ghi nợ nội địa và tiền mặt.</li>
                </ul>
                <div class="alert alert-info">
                  <span class="fa fa-info-circle mr-2"></span> Đơn đặt phòng sẽ chỉ được coi là <strong>XÁC NHẬN (CONFIRMED)</strong> khi chúng tôi nhận đủ số tiền cọc hợp lệ.
                </div>
              </div>

              <!-- Mục 3 -->
              <div id="section-3" class="mb-5">
                <h4 class="font-weight-bold text-dark mb-3">3. Chính Sách Hoàn Tiền & Hủy Đặt Phòng</h4>
                <table class="table table-bordered table-sm my-3">
                  <thead class="thead-light">
                    <tr>
                      <th>Thời Gian Thông Báo Hủy</th>
                      <th>Chính Sách Hoàn Cọc</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>Trước <strong>07 ngày</strong> so với ngày nhận phòng</td>
                      <td class="text-success font-weight-bold">Hoàn 100% tiền đặt cọc (trừ phí chuyển khoản nếu có)</td>
                    </tr>
                    <tr>
                      <td>Từ <strong>03 đến 06 ngày</strong> trước ngày nhận phòng</td>
                      <td class="text-warning font-weight-bold">Hoàn 50% tiền đặt cọc</td>
                    </tr>
                    <tr>
                      <td>Dưới <strong>03 ngày</strong> hoặc Không đến (No-show)</td>
                      <td class="text-danger font-weight-bold">Không hoàn lại tiền cọc</td>
                    </tr>
                  </tbody>
                </table>
                <small class="text-muted d-block">* Trường hợp bất khả kháng (thiên tai, dịch bệnh theo công bố của nhà nước), quý khách được hỗ trợ đổi ngày miễn phí trong vòng 30 ngày.</small>
              </div>

              <!-- Mục 4 -->
              <div id="section-4" class="mb-5">
                <h4 class="font-weight-bold text-dark mb-3">4. Nội Quy Lưu Trú & An Ninh Homestay</h4>
                <ul>
                  <li><strong>Không hút thuốc lá:</strong> Tuyệt đối không hút thuốc trong phòng ngủ. Khách có thể hút thuốc tại khu vực sân vườn hoặc ban công mở.</li>
                  <li><strong>Giờ yên tĩnh:</strong> Từ <strong>22:30</strong> đến <strong>06:00</strong> sáng hôm sau nhằm đảm bảo sự riêng tư và giấc ngủ của các phòng xung quanh.</li>
                  <li><strong>Chất cấm & Vũ khí:</strong> Nghiêm cấm mang theo các chất gây cháy nổ, vũ khí, chất kích thích hoặc thực hiện các hành vi vi phạm pháp luật Việt Nam trong khuôn viên homestay.</li>
                  <li><strong>Vật nuôi (Thú cưng):</strong> Vui lòng thông báo trước với quản lý homestay. Phí dọn dẹp vệ sinh phòng thú cưng có thể được áp dụng.</li>
                  <li><strong>Bảo quản tài sản:</strong> Quý khách có trách nhiệm giữ gìn trang thiết bị và đồ dùng trong phòng. Nếu xảy ra hư hỏng, mất mát sẽ bồi thường theo bảng giá niêm yết của homestay.</li>
                </ul>
              </div>

              <!-- Mục 5 -->
              <div id="section-5">
                <h4 class="font-weight-bold text-dark mb-3">5. Chính Sách Bảo Mật Quyền Riêng Tư</h4>
                <p>
                  Sogo Homestay cam kết bảo mật tuyệt đối các thông tin cá nhân của quý khách (họ tên, số điện thoại, email, thông tin thanh toán). Mọi dữ liệu chỉ được sử dụng cho mục đích liên hệ xác nhận đơn đặt phòng và đăng ký tạm trú theo luật định.
                </p>
                <div class="alert alert-secondary mt-3">
                  Nếu bạn cần thêm thông tin giải đáp về các điều khoản trên, xin vui lòng gọi đến hotline <strong>(+84) 090 123 4567</strong> hoặc gửi email tới <strong>support@sogohomestay.com</strong>.
                </div>
              </div>

            </div>
          </div>

        </div>
      </div>
    </section>

<jsp:include page="common/footer.jsp" />