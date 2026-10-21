<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Câu Hỏi Thường Gặp (FAQ) | Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<style>
  .faq-search-wrapper {
    background-color: #1a1a1a;
    border: 1px solid #333333;
    border-radius: 50px;
    padding: 6px 8px 6px 20px;
    display: flex;
    align-items: center;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
  }
  .faq-search-input {
    background: transparent !important;
    border: none !important;
    color: #ffffff !important;
    font-size: 1.05rem;
    box-shadow: none !important;
    outline: none !important;
  }
  .faq-search-input::placeholder {
    color: #888888;
  }
  .faq-search-btn {
    background-color: #f7a030;
    color: #ffffff;
    font-weight: 700;
    border-radius: 40px;
    padding: 10px 28px;
    border: none;
    transition: all 0.3s ease;
    white-space: nowrap;
  }
  .faq-search-btn:hover {
    background-color: #e58d1f;
    color: #fff;
    transform: translateY(-1px);
  }
  .faq-card {
    background-color: #1e1e1e !important;
    border: 1px solid #2e2e2e !important;
    border-radius: 8px !important;
    transition: all 0.2s ease-in-out;
  }
  .faq-card-header button {
    color: #ffffff !important;
    font-size: 1.05rem;
    text-decoration: none !important;
  }
  .faq-answer {
    color: #b5b5b5 !important;
    line-height: 1.7;
    font-size: 0.98rem;
  }
  .faq-chevron {
    color: #f7a030;
    transition: transform 0.3s ease;
  }
  .collapsed .faq-chevron {
    transform: rotate(0deg);
  }
  :not(.collapsed) > span > .faq-chevron {
    transform: rotate(180deg);
  }
  .admin-manage-bar {
    background: #1c1c1c;
    border: 1px solid #f7a030;
    border-radius: 10px;
    padding: 12px 20px;
  }
</style>

<div class="container-fluid" style="background-color: #121212; min-height: 100vh; padding-top: 100px; padding-bottom: 80px;">
  <div class="container">

    <!-- KIỂM TRA ĐIỀU KIỆN ADMIN ĐỂ HIỆN NÚT BUTTON QUẢN LÝ FAQ -->
    <c:set var="uRole" value="${not empty sessionScope.role ? sessionScope.role : (not empty sessionScope.user.role.name ? sessionScope.user.role.name : sessionScope.user.role.roleName)}" />
    <c:set var="uRoleId" value="${not empty sessionScope.roleId ? sessionScope.roleId : sessionScope.user.roleId}" />
    <c:set var="isRoleAdmin" value="${uRoleId == 1 || uRoleId == 5 || fn:toLowerCase(uRole) == 'admin' || fn:toLowerCase(uRole) == 'role_admin' || fn:toLowerCase(uRole) == 'administrator'}" />
    <c:set var="showAdminButton" value="${isAdmin || isRoleAdmin || sessionScope.displayName == 'Administrator'}" />

    <!-- NÚT BUTTON DÀNH CHO ADMIN SAU KHI ĐÃ VÀO XEM TRANG FAQ -->
    <c:if test="${showAdminButton}">
      <div class="row justify-content-center mb-4">
        <div class="col-md-9">
          <div class="admin-manage-bar d-flex justify-content-between align-items-center shadow-sm">
            <div class="text-white">
              <span class="badge badge-warning px-2 py-1 mr-2 text-dark font-weight-bold">
                <i class="fa fa-shield"></i> Chế độ Xem Admin
              </span>
              <span class="text-white-50 small">Bạn đang xem giao diện FAQ của khách. Nhấn nút bên cạnh để vào phần quản lý thêm, sửa, xóa FAQ.</span>
            </div>
            <!-- BUTTON CHUYỂN SANG TRANG QUẢN TRỊ FAQ -->
            <a href="${pageContext.request.contextPath}/admin/faqs" class="btn btn-warning font-weight-bold px-3 py-2 shadow-sm text-dark ml-3" style="white-space: nowrap;">
              <i class="fa fa-cogs mr-1"></i> Quản Lý FAQ
            </a>
          </div>
        </div>
      </div>
    </c:if>

    <!-- THANH TÌM KIẾM TỪ KHÓA CÂU HỎI -->
    <div class="row justify-content-center mb-4">
      <div class="col-md-8">
        <form action="${pageContext.request.contextPath}/faq" method="get">
          <div class="faq-search-wrapper">
            <input type="text" 
                   name="q" 
                   id="faqSearchInput"
                   value="${searchKeyword}" 
                   class="form-control faq-search-input" 
                   placeholder="Nhập từ khóa câu hỏi bạn cần tìm..." 
                   autocomplete="off">
            <button type="submit" class="faq-search-btn">
              <span class="fa fa-search mr-1"></span> Tìm Kiếm
            </button>
          </div>
          <c:if test="${not empty selectedCategory}">
            <input type="hidden" name="cat" value="${selectedCategory}">
          </c:if>
        </form>

        <!-- BỘ LỌC DANH MỤC CÂU HỎI -->
        <div class="d-flex justify-content-center flex-wrap mt-3">
          <a href="${pageContext.request.contextPath}/faq${not empty searchKeyword ? '?q='.concat(searchKeyword) : ''}" 
             class="btn btn-sm m-1 rounded-pill ${empty selectedCategory || selectedCategory == 'ALL' ? 'btn-warning text-dark font-weight-bold' : 'btn-outline-secondary text-light'}">
            Tất cả
          </a>
          <a href="${pageContext.request.contextPath}/faq?cat=Đặt phòng${not empty searchKeyword ? '&q='.concat(searchKeyword) : ''}" 
             class="btn btn-sm m-1 rounded-pill ${selectedCategory == 'Đặt phòng' ? 'btn-warning text-dark font-weight-bold' : 'btn-outline-secondary text-light'}">
            Đặt phòng
          </a>
          <a href="${pageContext.request.contextPath}/faq?cat=Thanh toán & Cọc${not empty searchKeyword ? '&q='.concat(searchKeyword) : ''}" 
             class="btn btn-sm m-1 rounded-pill ${selectedCategory == 'Thanh toán & Cọc' || selectedCategory == 'Thanh toán' ? 'btn-warning text-dark font-weight-bold' : 'btn-outline-secondary text-light'}">
            Thanh toán & Cọc
          </a>
          <a href="${pageContext.request.contextPath}/faq?cat=Quy định lưu trú${not empty searchKeyword ? '&q='.concat(searchKeyword) : ''}" 
             class="btn btn-sm m-1 rounded-pill ${selectedCategory == 'Quy định lưu trú' || selectedCategory == 'Quy định' ? 'btn-warning text-dark font-weight-bold' : 'btn-outline-secondary text-light'}">
            Quy định lưu trú
          </a>
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
                <div class="card faq-card mb-3 faq-item" 
                     data-question="${faq.question.toLowerCase()}" 
                     data-answer="${faq.answer.toLowerCase()}">
                  <div class="card-header faq-card-header bg-transparent p-3 border-0" id="heading-${faq.id}">
                    <h2 class="mb-0">
                      <button class="btn btn-link btn-block text-left font-weight-bold d-flex justify-content-between align-items-center ${status.first ? '' : 'collapsed'}" 
                              type="button" 
                              data-toggle="collapse" 
                              data-target="#collapse-${faq.id}" 
                              aria-expanded="${status.first ? 'true' : 'false'}" 
                              aria-controls="collapse-${faq.id}">
                        <span>
                          <span class="badge badge-secondary mr-2 py-1 px-2 font-weight-normal" style="font-size: 0.85rem; background-color: #383838;">
                            ${faq.category}
                          </span>
                          <span class="faq-question-text">${faq.question}</span>
                        </span>
                        <span>
                          <i class="fa fa-chevron-down faq-chevron"></i>
                        </span>
                      </button>
                    </h2>
                  </div>

                  <div id="collapse-${faq.id}" 
                       class="collapse ${status.first ? 'show' : ''}" 
                       aria-labelledby="heading-${faq.id}" 
                       data-parent="#accordionFaq">
                    <div class="card-body pt-1 pb-4 px-4 faq-answer border-top" style="border-color: #2c2c2c !important;">
                      ${faq.answer}
                    </div>
                  </div>
                </div>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <div class="text-center py-5 rounded" style="background-color: #1e1e1e; border: 1px solid #333;">
                <span class="fa fa-search fa-3x text-muted mb-3 d-block"></span>
                <h5 class="text-light">Không tìm thấy câu hỏi phù hợp với từ khóa "${searchKeyword}".</h5>
                <p class="text-muted small">Hãy thử tìm kiếm với từ khóa khác hoặc xem toàn bộ câu hỏi.</p>
                <a href="${pageContext.request.contextPath}/faq" class="btn btn-outline-warning mt-2">
                  Xem tất cả câu hỏi
                </a>
              </div>
            </c:otherwise>
          </c:choose>
        </div>

        <div id="noRealtimeResults" class="text-center py-5 rounded d-none" style="background-color: #1e1e1e; border: 1px solid #333;">
          <span class="fa fa-question-circle fa-3x text-muted mb-3 d-block"></span>
          <h5 class="text-light">Không có câu hỏi nào khớp với từ khóa vừa gõ.</h5>
        </div>

      </div>
    </div>

  </div>
</div>

<jsp:include page="common/footer.jsp" />

<script>
  document.addEventListener('DOMContentLoaded', function () {
    var searchInput = document.getElementById('faqSearchInput');
    var faqItems = document.querySelectorAll('.faq-item');
    var noResultsDiv = document.getElementById('noRealtimeResults');

    if (searchInput) {
      searchInput.addEventListener('input', function () {
        var query = this.value.trim().toLowerCase();
        var matchCount = 0;

        faqItems.forEach(function (item) {
          var question = item.getAttribute('data-question') || '';
          var answer = item.getAttribute('data-answer') || '';

          if (query === '' || question.indexOf(query) !== -1 || answer.indexOf(query) !== -1) {
            item.style.display = '';
            matchCount++;
            if (query !== '') {
              var collapseEl = item.querySelector('.collapse');
              if (collapseEl && !collapseEl.classList.contains('show')) {
                $(collapseEl).collapse('show');
              }
            }
          } else {
            item.style.display = 'none';
          }
        });

        if (matchCount === 0 && faqItems.length > 0) {
          noResultsDiv.classList.remove('d-none');
        } else {
          noResultsDiv.classList.add('d-none');
        }
      });
    }
  });
</script>