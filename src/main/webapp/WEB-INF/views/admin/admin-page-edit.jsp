<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../common/header.jsp">
  <jsp:param name="pageTitle" value="Chỉnh Sửa Trang Tĩnh - Sogo Homestay" />
</jsp:include>

<div class="container py-5 my-5">
  <div class="d-flex justify-content-between align-items-center mb-4 pb-2 border-bottom">
    <h2 class="font-weight-bold text-dark">Chỉnh Sửa Trang: ${pageData.slug}</h2>
    <div>
      <a href="${pageContext.request.contextPath}/admin/pages/edit?slug=about-us" class="btn ${pageData.slug == 'about-us' ? 'btn-primary' : 'btn-outline-primary'} mr-2">Về Chúng Tôi</a>
      <a href="${pageContext.request.contextPath}/admin/pages/edit?slug=terms-and-conditions" class="btn ${pageData.slug == 'terms-and-conditions' ? 'btn-primary' : 'btn-outline-primary'} mr-2">Chính Sách</a>
      <a href="${pageContext.request.contextPath}/admin/faqs" class="btn btn-outline-secondary">Quản Trị FAQ</a>
    </div>
  </div>

  <c:if test="${param.msg == 'updated'}">
    <div class="alert alert-success">Nội dung trang đã được cập nhật thành công!</div>
  </c:if>

  <div class="bg-white rounded shadow-sm border p-4 p-md-5">
    <form action="${pageContext.request.contextPath}/admin/pages/edit" method="post">
      <input type="hidden" name="slug" value="${pageData.slug}">

      <div class="form-group mb-3">
        <label class="font-weight-bold">Tiêu đề trang:</label>
        <input type="text" name="title" value="${pageData.title}" class="form-control" required>
      </div>

      <div class="form-group mb-3">
        <label class="font-weight-bold">Mô tả tóm tắt (SEO Meta Description):</label>
        <input type="text" name="metaDescription" value="${pageData.metaDescription}" class="form-control">
      </div>

      <div class="form-group mb-4">
        <label class="font-weight-bold">Nội dung chi tiết:</label>
        <textarea name="content" rows="10" class="form-control" required>${pageData.content}</textarea>
        <small class="text-muted">Nội dung này sẽ hiển thị trực tiếp cho khách hàng xem trên website.</small>
      </div>

      <button type="submit" class="btn btn-success font-weight-bold px-4 py-2">
        <span class="fa fa-save mr-1"></span> Lưu & Cập Nhật Trang
      </button>
    </form>
  </div>
</div>

<jsp:include page="../common/footer.jsp" />