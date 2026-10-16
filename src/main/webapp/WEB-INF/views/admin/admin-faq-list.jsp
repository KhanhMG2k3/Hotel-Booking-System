<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../common/header.jsp">
  <jsp:param name="pageTitle" value="Quản Trị FAQ - Sogo Homestay" />
</jsp:include>

<div class="container py-5 my-5">
  <div class="d-flex justify-content-between align-items-center mb-4 pb-2 border-bottom">
    <h2 class="font-weight-bold text-dark">Quản Lý Câu Hỏi Thường Gặp (FAQ)</h2>
    <div>
      <a href="${pageContext.request.contextPath}/admin/pages/edit?slug=about-us" class="btn btn-outline-secondary mr-2">Sửa About Us</a>
      <a href="${pageContext.request.contextPath}/admin/pages/edit?slug=terms-and-conditions" class="btn btn-outline-secondary mr-2">Sửa Chính Sách</a>
      <button class="btn btn-primary" data-toggle="modal" data-target="#modalAddFaq">
        <span class="fa fa-plus mr-1"></span> Thêm Câu Hỏi Mới
      </button>
    </div>
  </div>

  <c:if test="${param.msg == 'saved'}">
    <div class="alert alert-success">Đã lưu thông tin câu hỏi thành công!</div>
  </c:if>
  <c:if test="${param.msg == 'deleted'}">
    <div class="alert alert-warning">Đã xóa câu hỏi khỏi hệ thống!</div>
  </c:if>

  <!-- BẢNG DANH SÁCH FAQ CHO ADMIN -->
  <div class="bg-white rounded shadow-sm border p-4">
    <table class="table table-hover table-bordered mb-0">
      <thead class="thead-light">
        <tr>
          <th width="5%">STT</th>
          <th width="15%">Chuyên Mục</th>
          <th width="35%">Câu Hỏi</th>
          <th width="25%">Câu Trả Lời</th>
          <th width="10%">Trạng Thái</th>
          <th width="10%">Thao Tác</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="faq" items="${faqList}" varStatus="loop">
          <tr>
            <td>${faq.orderIndex}</td>
            <td><span class="badge badge-info">${faq.category}</span></td>
            <td class="font-weight-bold">${faq.question}</td>
            <td class="small text-muted text-truncate" style="max-width: 250px;">${faq.answer}</td>
            <td>
              <span class="badge ${faq.status == 'ACTIVE' ? 'badge-success' : 'badge-secondary'}">
                ${faq.status}
              </span>
            </td>
            <td>
              <a href="${pageContext.request.contextPath}/admin/faqs/delete?id=${faq.id}" 
                 onclick="return confirm('Bạn có chắc chắn muốn xóa câu hỏi này?')" 
                 class="btn btn-sm btn-outline-danger">Xóa</a>
            </td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
  </div>
</div>

<!-- MODAL THÊM CÂU HỎI MỚI -->
<div class="modal fade" id="modalAddFaq" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <form action="${pageContext.request.contextPath}/admin/faqs/add" method="post">
        <div class="modal-header">
          <h5 class="modal-title font-weight-bold">Thêm Câu Hỏi Thường Gặp (FAQ)</h5>
          <button type="button" class="close" data-dismiss="modal">&times;</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="font-weight-bold">Chuyên mục:</label>
            <select name="category" class="form-control">
              <option value="Đặt phòng">Đặt phòng</option>
              <option value="Thanh toán">Thanh toán & Cọc</option>
              <option value="Quy định">Quy định lưu trú</option>
              <option value="Dịch vụ">Dịch vụ homestay</option>
            </select>
          </div>
          <div class="form-group">
            <label class="font-weight-bold">Câu hỏi:</label>
            <input type="text" name="question" class="form-control" placeholder="Nhập câu hỏi..." required>
          </div>
          <div class="form-group">
            <label class="font-weight-bold">Câu trả lời:</label>
            <textarea name="answer" rows="4" class="form-control" placeholder="Nhập câu trả lời chi tiết..." required></textarea>
          </div>
          <div class="row">
            <div class="col-md-6 form-group">
              <label class="font-weight-bold">Thứ tự ưu tiên (Order):</label>
              <input type="number" name="orderIndex" value="1" class="form-control">
            </div>
            <div class="col-md-6 form-group">
              <label class="font-weight-bold">Trạng thái:</label>
              <select name="status" class="form-control">
                <option value="ACTIVE">Hiển thị (ACTIVE)</option>
                <option value="INACTIVE">Tạm ẩn (INACTIVE)</option>
              </select>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
          <button type="submit" class="btn btn-primary font-weight-bold">Lưu Câu Hỏi</button>
        </div>
      </form>
    </div>
  </div>
</div>

<jsp:include page="../common/footer.jsp" />