<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" language="java"  %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Câu Hỏi Thường Gặp (FAQ) | Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<style>
  /* ==========================================================================
     FAQ PAGE STYLES - LIGHT MODE (DEFAULT)
     ========================================================================== */
  .faq-page-wrap {
    background-color: #f8fafc;
    min-height: 100vh;
    padding-top: 100px;
    padding-bottom: 80px;
    transition: background-color 0.25s ease;
  }
  .admin-manage-bar {
    background: #fff8ee;
    border: 1px solid #ffba5a;
    border-radius: 12px;
    padding: 12px 20px;
    transition: all 0.25s ease;
  }
  .admin-manage-bar .admin-manage-sub {
    color: #64748b;
  }
  .faq-search-wrapper {
    background-color: #ffffff;
    border: 1.5px solid #e2e8f0;
    border-radius: 50px;
    padding: 6px 8px 6px 20px;
    display: flex;
    align-items: center;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
    transition: all 0.25s ease;
  }
  .faq-search-wrapper:focus-within {
    border-color: #ffba5a;
    box-shadow: 0 4px 20px rgba(255, 186, 90, 0.2);
  }
  .faq-search-input {
    background: transparent !important;
    border: none !important;
    color: #1e293b !important;
    font-size: 1.05rem;
    box-shadow: none !important;
    outline: none !important;
  }
  .faq-search-input::placeholder {
    color: #94a3b8;
  }
  .faq-search-btn {
    background-color: #ffba5a;
    color: #0f172a;
    font-weight: 700;
    border-radius: 40px;
    padding: 10px 28px;
    border: none;
    transition: all 0.25s ease;
    white-space: nowrap;
  }
  .faq-search-btn:hover {
    background-color: #f59e0b;
    color: #0f172a;
    transform: translateY(-1px);
  }
  .faq-cat-btn {
    background: #ffffff;
    color: #475569;
    border: 1px solid #cbd5e1;
    font-weight: 500;
    padding: 6px 18px;
    transition: all 0.2s ease;
    text-decoration: none !important;
  }
  .faq-cat-btn:hover {
    background: #f1f5f9;
    color: #0f172a;
  }
  .faq-cat-btn.active {
    background: #ffba5a !important;
    border-color: #ffba5a !important;
    color: #0f172a !important;
    font-weight: 700;
    box-shadow: 0 2px 8px rgba(255, 186, 90, 0.35);
  }
  .faq-card {
    background-color: #ffffff !important;
    border: 1px solid #e2e8f0 !important;
    border-radius: 12px !important;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.03) !important;
    transition: all 0.2s ease-in-out;
    overflow: hidden;
  }
  .faq-card:hover {
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.07) !important;
  }
  .faq-card-header button {
    color: #1e293b !important;
    font-size: 1.05rem;
    text-decoration: none !important;
  }
  .faq-card-header button:hover {
    color: #d97706 !important;
  }
  .faq-category-badge {
    font-size: 0.85rem;
    background-color: #f1f5f9;
    color: #475569;
    border: 1px solid #e2e8f0;
    border-radius: 6px;
  }
  .faq-question-text {
    color: inherit;
  }
  .faq-answer {
    color: #475569 !important;
    line-height: 1.7;
    font-size: 0.98rem;
    border-top: 1px solid #f1f5f9 !important;
  }
  .faq-chevron {
    color: #ffba5a;
    transition: transform 0.3s ease;
  }
  .collapsed .faq-chevron {
    transform: rotate(0deg);
  }
  :not(.collapsed) > span > .faq-chevron {
    transform: rotate(180deg);
  }
  .faq-empty-state {
    background-color: #ffffff;
    border: 1px solid #e2e8f0;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.04);
  }
  .faq-empty-state h5 {
    color: #1e293b;
  }

  /* ==========================================================================
     FAQ PAGE STYLES - DARK MODE OVERRIDES
     ========================================================================== */
  [data-theme="dark"] .faq-page-wrap,
  html.dark-mode .faq-page-wrap,
  body.dark-mode .faq-page-wrap {
    background-color: #0b0f19 !important;
  }
  [data-theme="dark"] .admin-manage-bar,
  html.dark-mode .admin-manage-bar,
  body.dark-mode .admin-manage-bar {
    background: #162032 !important;
    border-color: rgba(251, 191, 36, 0.4) !important;
  }
  [data-theme="dark"] .admin-manage-bar .admin-manage-sub,
  html.dark-mode .admin-manage-bar .admin-manage-sub {
    color: #94a3b8 !important;
  }
  [data-theme="dark"] .faq-search-wrapper,
  html.dark-mode .faq-search-wrapper,
  body.dark-mode .faq-search-wrapper {
    background-color: #162032 !important;
    border-color: #243247 !important;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35) !important;
  }
  [data-theme="dark"] .faq-search-wrapper:focus-within,
  html.dark-mode .faq-search-wrapper:focus-within {
    border-color: #ffba5a !important;
  }
  [data-theme="dark"] .faq-search-input,
  html.dark-mode .faq-search-input,
  body.dark-mode .faq-search-input {
    color: #f8fafc !important;
  }
  [data-theme="dark"] .faq-search-input::placeholder,
  html.dark-mode .faq-search-input::placeholder {
    color: #64748b;
  }
  [data-theme="dark"] .faq-cat-btn,
  html.dark-mode .faq-cat-btn,
  body.dark-mode .faq-cat-btn {
    background: #1e293b !important;
    color: #94a3b8 !important;
    border-color: #334155 !important;
  }
  [data-theme="dark"] .faq-cat-btn:hover,
  html.dark-mode .faq-cat-btn:hover {
    background: #334155 !important;
    color: #f8fafc !important;
  }
  [data-theme="dark"] .faq-cat-btn.active,
  html.dark-mode .faq-cat-btn.active {
    background: #ffba5a !important;
    border-color: #ffba5a !important;
    color: #0f172a !important;
    font-weight: 700;
  }
  [data-theme="dark"] .faq-card,
  html.dark-mode .faq-card,
  body.dark-mode .faq-card {
    background-color: #162032 !important;
    border-color: #243247 !important;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.25) !important;
  }
  [data-theme="dark"] .faq-card:hover,
  html.dark-mode .faq-card:hover {
    background-color: #1c2a42 !important;
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.4) !important;
  }
  [data-theme="dark"] .faq-card-header button,
  html.dark-mode .faq-card-header button,
  body.dark-mode .faq-card-header button {
    color: #f8fafc !important;
  }
  [data-theme="dark"] .faq-card-header button:hover,
  html.dark-mode .faq-card-header button:hover {
    color: #ffba5a !important;
  }
  [data-theme="dark"] .faq-category-badge,
  html.dark-mode .faq-category-badge {
    background-color: #111827 !important;
    color: #94a3b8 !important;
    border-color: #243247 !important;
  }
  [data-theme="dark"] .faq-answer,
  html.dark-mode .faq-answer,
  body.dark-mode .faq-answer {
    color: #cbd5e1 !important;
    border-color: #243247 !important;
  }
  [data-theme="dark"] .faq-empty-state,
  html.dark-mode .faq-empty-state,
  body.dark-mode .faq-empty-state {
    background-color: #162032 !important;
    border-color: #243247 !important;
  }
  [data-theme="dark"] .faq-empty-state h5,
  html.dark-mode .faq-empty-state h5 {
    color: #f8fafc !important;
  }
</style>

<div class="container-fluid faq-page-wrap">
  <div class="container">

    <%-- Step 1: Check Admin or Host privileges to display the FAQ Management toolbar --%>
    <c:set var="uRole" value="${fn:toUpperCase(not empty sessionScope.role ? sessionScope.role : (not empty sessionScope.user.role.name ? sessionScope.user.role.name : (not empty sessionScope.user.role.roleName ? sessionScope.user.role.roleName : '')))}" />
    <c:set var="uRoleId" value="${not empty sessionScope.roleId ? sessionScope.roleId : sessionScope.user.roleId}" />
    <c:set var="isRoleAdmin" value="${isAdmin || uRole == 'ADMIN' || uRole == 'ROLE_ADMIN' || uRole == 'ADMINISTRATOR' || (empty uRole && (uRoleId == 1 || uRoleId == 5))}" />
    <c:set var="isRoleHost" value="${isHost || uRole == 'HOST' || uRole == 'ROLE_HOST' || uRole == 'HOTEL_OWNER' || (empty uRole && uRoleId == 3)}" />
    <c:set var="showManageButton" value="${canManageFaq || isRoleAdmin || isRoleHost}" />

    <%-- Step 2: Render FAQ Management banner and shortcut button for Admin and Host --%>
    <c:if test="${showManageButton}">
      <div class="row justify-content-center mb-4">
        <div class="col-md-9">
          <div class="admin-manage-bar d-flex justify-content-between align-items-center flex-wrap shadow-sm">
            <div class="my-1">
              <span class="badge badge-warning px-2 py-1 mr-2 text-dark font-weight-bold">
                <c:choose>
                  <c:when test="${isRoleAdmin}">
                    <i class="fa fa-shield"></i> Chế độ Xem Admin
                  </c:when>
                  <c:otherwise>
                    <i class="fa fa-home"></i> Chế độ Xem Host
                  </c:otherwise>
                </c:choose>
              </span>
              <span class="admin-manage-sub small">Bạn đang xem giao diện FAQ của khách. Nhấn nút bên cạnh để vào phần quản lý thêm, sửa, xóa FAQ.</span>
            </div>
            <a href="${pageContext.request.contextPath}/admin/faqs" class="btn btn-warning font-weight-bold px-3 py-2 shadow-sm text-dark my-1" style="white-space: nowrap;">
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
             class="btn btn-sm m-1 rounded-pill faq-cat-btn ${empty selectedCategory || selectedCategory == 'ALL' ? 'active' : ''}">
            Tất cả
          </a>
          <a href="${pageContext.request.contextPath}/faq?cat=Đặt phòng${not empty searchKeyword ? '&q='.concat(searchKeyword) : ''}" 
             class="btn btn-sm m-1 rounded-pill faq-cat-btn ${selectedCategory == 'Đặt phòng' ? 'active' : ''}">
            Đặt phòng
          </a>
          <a href="${pageContext.request.contextPath}/faq?cat=Thanh toán & Cọc${not empty searchKeyword ? '&q='.concat(searchKeyword) : ''}" 
             class="btn btn-sm m-1 rounded-pill faq-cat-btn ${selectedCategory == 'Thanh toán & Cọc' || selectedCategory == 'Thanh toán' ? 'active' : ''}">
            Thanh toán & Cọc
          </a>
          <a href="${pageContext.request.contextPath}/faq?cat=Quy định lưu trú${not empty searchKeyword ? '&q='.concat(searchKeyword) : ''}" 
             class="btn btn-sm m-1 rounded-pill faq-cat-btn ${selectedCategory == 'Quy định lưu trú' || selectedCategory == 'Quy định' ? 'active' : ''}">
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
                          <span class="badge faq-category-badge mr-2 py-1 px-2 font-weight-normal">
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
                    <div class="card-body pt-1 pb-4 px-4 faq-answer border-top">
                      ${faq.answer}
                    </div>
                  </div>
                </div>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <div class="text-center py-5 rounded faq-empty-state">
                <span class="fa fa-search fa-3x text-muted mb-3 d-block"></span>
                <h5>Không tìm thấy câu hỏi phù hợp với từ khóa "${searchKeyword}".</h5>
                <p class="text-muted small">Hãy thử tìm kiếm với từ khóa khác hoặc xem toàn bộ câu hỏi.</p>
                <a href="${pageContext.request.contextPath}/faq" class="btn btn-outline-warning mt-2 font-weight-bold">
                  Xem tất cả câu hỏi
                </a>
              </div>
            </c:otherwise>
          </c:choose>
        </div>

        <div id="noRealtimeResults" class="text-center py-5 rounded d-none faq-empty-state">
          <span class="fa fa-question-circle fa-3x text-muted mb-3 d-block"></span>
          <h5>Không có câu hỏi nào khớp với từ khóa vừa gõ.</h5>
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
