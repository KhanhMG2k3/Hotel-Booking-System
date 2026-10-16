<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="${pageTitle}" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

    <!-- HERO BANNER -->
    <section class="site-hero inner-page overlay" style="background-image: url(${pageContext.request.contextPath}/assets/images/hero_4.jpg)" data-stellar-background-ratio="0.5">
      <div class="container">
        <div class="row site-hero-inner justify-content-center align-items-center">
          <div class="col-md-10 text-center" data-aos="fade">
            <h1 class="heading mb-3">Hỏi Đáp & Trợ Giúp (FAQ)</h1>
            <ul class="custom-breadcrumbs mb-4">
              <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
              <li>&bullet;</li>
              <li>FAQ</li>
            </ul>
          </div>
        </div>
      </div>
      <a class="mouse smoothscroll" href="#faq-section">
        <div class="mouse-icon">
          <span class="mouse-wheel"></span>
        </div>
      </a>
    </section>

    <!-- KHỐI TÌM KIẾM & DANH SÁCH CÂU HỎI -->
    <section class="section bg-light" id="faq-section">
      <div class="container">
        
        <!-- THANH TÌM KIẾM & BỘ LỌC -->
        <div class="row justify-content-center mb-5">
          <div class="col-md-8">
            <form action="${pageContext.request.contextPath}/faq" method="get" class="p-3 bg-white rounded shadow-sm border">
              <div class="input-group">
                <input type="text" name="q" value="${searchKeyword}" class="form-control form-control-lg border-0" placeholder="Nhập từ khóa câu hỏi bạn cần tìm...">
                <div class="input-group-append">
                  <button type="submit" class="btn btn-primary px-4 font-weight-bold">
                    <span class="fa fa-search mr-1"></span> Tìm Kiếm
                  </button>
                </div>
              </div>
            </form>

            <!-- LỌC THEO DANH MỤC NHANH -->
            <div class="d-flex justify-content-center flex-wrap mt-3">
              <a href="${pageContext.request.contextPath}/faq" class="badge ${empty selectedCategory ? 'badge-primary' : 'badge-light border'} p-2 m-1">Tất cả</a>
              <a href="${pageContext.request.contextPath}/faq?cat=Đặt phòng" class="badge ${selectedCategory == 'Đặt phòng' ? 'badge-primary' : 'badge-light border'} p-2 m-1">Đặt phòng</a>
              <a href="${pageContext.request.contextPath}/faq?cat=Thanh toán" class="badge ${selectedCategory == 'Thanh toán' ? 'badge-primary' : 'badge-light border'} p-2 m-1">Thanh toán & Cọc</a>
              <a href="${pageContext.request.contextPath}/faq?cat=Quy định" class="badge ${selectedCategory == 'Quy định' ? 'badge-primary' : 'badge-light border'} p-2 m-1">Quy định lưu trú</a>
            </div>
          </div>
        </div>

        <!-- DANH SÁCH ACCORDION CÂU HỎI -->
        <div class="row justify-content-center">
          <div class="col-md-9">
            <div class="accordion" id="accordionFaq">
              <c:choose>
                <c:when test="${not empty faqs}">
                  <c:forEach var="faq" items="${faqs}" varStatus="status">
                    <div class="card mb-3 border-0 rounded shadow-sm">
                      <div class="card-header bg-white p-3 border-bottom-0" id="heading-${faq.id}">
                        <h2 class="mb-0">
                          <button class="btn btn-link btn-block text-left font-weight-bold text-dark d-flex justify-content-between align-items-center ${status.first ? '' : 'collapsed'}" 
                                  type="button" data-toggle="collapse" data-target="#collapse-${faq.id}" 
                                  aria-expanded="${status.first ? 'true' : 'false'}" aria-controls="collapse-${faq.id}"
                                  style="text-decoration: none; font-size: 1.05rem;">
                            <span>
                              <span class="badge badge-secondary mr-2 font-weight-normal">${faq.category}</span>
                              ${faq.question}
                            </span>
                            <span class="fa fa-chevron-down text-primary ml-2"></span>
                          </button>
                        </h2>
                      </div>

                      <div id="collapse-${faq.id}" class="collapse ${status.first ? 'show' : ''}" 
                           aria-labelledby="heading-${faq.id}" data-parent="#accordionFaq">
                        <div class="card-body pt-0 pb-4 px-4 text-secondary leading-relaxed border-top">
                          ${faq.answer}
                        </div>
                      </div>
                    </div>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <div class="text-center py-5 bg-white rounded shadow-sm">
                    <span class="fa fa-question-circle fa-3x text-muted mb-3 d-block"></span>
                    <h5 class="text-muted">Không tìm thấy câu hỏi phù hợp với từ khóa của bạn.</h5>
                    <a href="${pageContext.request.contextPath}/faq" class="btn btn-outline-primary mt-2">Xem tất cả câu hỏi</a>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>

      </div>
    </section>

<jsp:include page="common/footer.jsp" />