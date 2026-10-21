<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../common/header.jsp">
  <jsp:param name="pageTitle" value="Quản Trị FAQ - Sogo Homestay" />
</jsp:include>

<div class="container py-5 my-4">
  <div class="d-flex justify-content-between align-items-center mb-4 pb-2 border-bottom">
    <div>
      <h2 class="font-weight-bold text-dark mb-1">
        <i class="fa fa-question-circle text-primary mr-2"></i>Quản Lý FAQ Hệ Thống
      </h2>
      <p class="text-muted small mb-0">Thêm, sửa, xóa câu hỏi và bật/tắt hiển thị lên trang FAQ tĩnh cho khách hàng</p>
    </div>
    <div>
      <a href="${pageContext.request.contextPath}/faq" class="btn btn-outline-info mr-2">
        <span class="fa fa-eye mr-1"></span> Xem Trang FAQ Khách
      </a>
      <button class="btn btn-primary font-weight-bold shadow-sm" data-toggle="modal" data-target="#modalAddFaq">
        <span class="fa fa-plus-circle mr-1"></span> Thêm Câu Hỏi Mới
      </button>
    </div>
  </div>

  <c:if test="${param.msg == 'added'}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
      <strong><i class="fa fa-check-circle mr-1"></i> Thành công!</strong> Đã thêm mới câu hỏi vào hệ thống!
      <button type="button" class="close" data-dismiss="alert">&times;</button>
    </div>
  </c:if>
  <c:if test="${param.msg == 'updated'}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
      <strong><i class="fa fa-check-circle mr-1"></i> Thành công!</strong> Đã cập nhật nội dung câu hỏi và câu trả lời!
      <button type="button" class="close" data-dismiss="alert">&times;</button>
    </div>
  </c:if>
  <c:if test="${param.msg == 'toggled'}">
    <div class="alert alert-info alert-dismissible fade show" role="alert">
      <strong><i class="fa fa-info-circle mr-1"></i> Cập nhật trạng thái!</strong> Đã thay đổi trạng thái hiển thị của câu hỏi lên trang khách!
      <button type="button" class="close" data-dismiss="alert">&times;</button>
    </div>
  </c:if>
  <c:if test="${param.msg == 'deleted'}">
    <div class="alert alert-warning alert-dismissible fade show" role="alert">
      <strong><i class="fa fa-trash mr-1"></i> Đã xóa!</strong> Đã xóa toàn bộ câu hỏi và câu trả lời thành công!
      <button type="button" class="close" data-dismiss="alert">&times;</button>
    </div>
  </c:if>
  <c:if test="${param.msg == 'error'}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
      <strong><i class="fa fa-exclamation-triangle mr-1"></i> Lỗi!</strong> Đã xảy ra lỗi trong quá trình xử lý dữ liệu.
      <button type="button" class="close" data-dismiss="alert">&times;</button>
    </div>
  </c:if>

  <div class="card mb-4 border-0 shadow-sm bg-light">
    <div class="card-body p-3">
      <form action="${pageContext.request.contextPath}/admin/faqs" method="get" class="form-inline justify-content-between">
        <div class="input-group" style="width: 450px;">
          <input type="text" name="search" value="${searchKeyword}" class="form-control" placeholder="Tìm kiếm theo từ khóa câu hỏi, câu trả lời, chuyên mục...">
          <div class="input-group-append">
            <button type="submit" class="btn btn-primary font-weight-bold">
              <i class="fa fa-search mr-1"></i> Tìm
            </button>
          </div>
        </div>
        <c:if test="${not empty searchKeyword}">
          <a href="${pageContext.request.contextPath}/admin/faqs" class="btn btn-outline-secondary btn-sm">
            <i class="fa fa-refresh mr-1"></i> Bỏ lọc tìm kiếm
          </a>
        </c:if>
      </form>
    </div>
  </div>

  <div class="bg-white rounded shadow-sm border p-3">
    <div class="table-responsive">
      <table class="table table-hover table-bordered mb-0 align-middle">
        <thead class="thead-light text-center">
          <tr>
            <th style="width: 50px;">Thứ tự</th>
            <th style="width: 150px;">Chuyên Mục</th>
            <th style="width: 280px;">Câu Hỏi</th>
            <th>Câu Trả Lời</th>
            <th style="width: 170px;">Hiển Thị Trang Khách</th>
            <th style="width: 140px;">Thao Tác</th>
          </tr>
        </thead>
        <tbody>
          <c:choose>
            <c:when test="${not empty faqList}">
              <c:forEach var="faq" items="${faqList}">
                <tr>
                  <td class="text-center font-weight-bold text-muted">${faq.orderIndex}</td>
                  <td class="text-center">
                    <span class="badge badge-secondary p-2" style="font-size: 0.85rem;">
                      ${faq.category}
                    </span>
                  </td>
                  <td class="font-weight-bold text-dark">${faq.question}</td>
                  <td class="text-secondary small" style="white-space: pre-line;">${faq.answer}</td>
                  <td class="text-center">
                    <c:choose>
                      <c:when test="${faq.status == 'ACTIVE'}">
                        <span class="badge badge-success mb-1 d-block py-1">
                          <i class="fa fa-check-circle mr-1"></i> Đang hiển thị
                        </span>
                        <a href="${pageContext.request.contextPath}/admin/faqs/toggle?id=${faq.id}" 
                           class="btn btn-sm btn-outline-secondary btn-block" 
                           title="Nhấn để ẩn câu hỏi này khỏi trang FAQ khách">
                          <i class="fa fa-eye-slash mr-1"></i> Tắt hiển thị
                        </a>
                      </c:when>
                      <c:otherwise>
                        <span class="badge badge-secondary mb-1 d-block py-1">
                          <i class="fa fa-eye-slash mr-1"></i> Đang ẩn
                        </span>
                        <a href="${pageContext.request.contextPath}/admin/faqs/toggle?id=${faq.id}" 
                           class="btn btn-sm btn-outline-success btn-block" 
                           title="Nhấn để đưa câu hỏi này lên trang FAQ khách">
                          <i class="fa fa-eye mr-1"></i> Bật hiển thị
                        </a>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td class="text-center">
                    <div class="btn-group btn-group-sm" role="group">
                      <button type="button" class="btn btn-outline-primary btn-edit-faq"
                              data-id="${faq.id}"
                              data-category="${faq.category}"
                              data-question="${faq.question}"
                              data-answer="${faq.answer}"
                              data-order="${faq.orderIndex}"
                              data-status="${faq.status}"
                              title="Sửa câu hỏi và câu trả lời">
                        <i class="fa fa-edit"></i> Sửa
                      </button>
                      <a href="${pageContext.request.contextPath}/admin/faqs/delete?id=${faq.id}" 
                         onclick="return confirm('Bạn có chắc chắn muốn xóa câu hỏi này khỏi hệ thống?')" 
                         class="btn btn-outline-danger" 
                         title="Xóa cả câu hỏi">
                        <i class="fa fa-trash"></i> Xóa
                      </a>
                    </div>
                  </td>
                </tr>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <tr>
                <td colspan="6" class="text-center py-4 text-muted">
                  <i class="fa fa-info-circle fa-2x mb-2 d-block"></i>
                  Không có câu hỏi nào. Nhấn nút "Thêm Câu Hỏi Mới" để tạo câu hỏi đầu tiên.
                </td>
              </tr>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>
    </div>
  </div>
</div>

<!-- MODAL THÊM CÂU HỎI MỚI -->
<div class="modal fade" id="modalAddFaq" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <form action="${pageContext.request.contextPath}/admin/faqs/add" method="post">
        <div class="modal-header bg-primary text-white">
          <h5 class="modal-title font-weight-bold">
            <i class="fa fa-plus-circle mr-1"></i> Thêm Câu Hỏi Thường Gặp (FAQ) Mới
          </h5>
          <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="font-weight-bold">Chuyên mục:</label>
            <select name="category" class="form-control" required>
              <option value="Đặt phòng">Đặt phòng</option>
              <option value="Thanh toán & Cọc">Thanh toán & Cọc</option>
              <option value="Thanh toán & Hủy phòng">Thanh toán & Hủy phòng</option>
              <option value="Quy định lưu trú">Quy định lưu trú</option>
              <option value="Dịch vụ tiện ích">Dịch vụ tiện ích</option>
            </select>
          </div>
          <div class="form-group">
            <label class="font-weight-bold">Câu hỏi: <span class="text-danger">*</span></label>
            <input type="text" name="question" class="form-control" placeholder="Ví dụ: Giờ nhận phòng và trả phòng là mấy giờ?" required>
          </div>
          <div class="form-group">
            <label class="font-weight-bold">Câu trả lời: <span class="text-danger">*</span></label>
            <textarea name="answer" rows="5" class="form-control" placeholder="Nhập câu trả lời chi tiết và rõ ràng cho khách hàng..." required></textarea>
          </div>
          <div class="row">
            <div class="col-md-6 form-group">
              <label class="font-weight-bold">Thứ tự hiển thị (Order Index):</label>
              <input type="number" name="orderIndex" value="1" min="1" class="form-control" required>
              <small class="text-muted">Số nhỏ hơn sẽ hiển thị lên trước.</small>
            </div>
            <div class="col-md-6 form-group">
              <label class="font-weight-bold">Trạng thái hiển thị lên trang khách:</label>
              <select name="status" class="form-control">
                <option value="ACTIVE" selected>Hiển thị lên trang FAQ khách (ACTIVE)</option>
                <option value="INACTIVE">Tạm ẩn, không hiển thị (INACTIVE)</option>
              </select>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
          <button type="submit" class="btn btn-primary font-weight-bold">
            <i class="fa fa-save mr-1"></i> Lưu Câu Hỏi
          </button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- MODAL SỬA CÂU HỎI & CÂU TRẢ LỜI -->
<div class="modal fade" id="modalEditFaq" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <form action="${pageContext.request.contextPath}/admin/faqs/edit" method="post">
        <input type="hidden" name="id" id="edit-id">
        <div class="modal-header bg-dark text-white">
          <h5 class="modal-title font-weight-bold">
            <i class="fa fa-edit mr-1"></i> Chỉnh Sửa Câu Hỏi & Câu Trả Lời
          </h5>
          <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="font-weight-bold">Chuyên mục:</label>
            <select name="category" id="edit-category" class="form-control" required>
              <option value="Đặt phòng">Đặt phòng</option>
              <option value="Thanh toán & Cọc">Thanh toán & Cọc</option>
              <option value="Thanh toán & Hủy phòng">Thanh toán & Hủy phòng</option>
              <option value="Quy định lưu trú">Quy định lưu trú</option>
              <option value="Dịch vụ tiện ích">Dịch vụ tiện ích</option>
            </select>
          </div>
          <div class="form-group">
            <label class="font-weight-bold">Câu hỏi: <span class="text-danger">*</span></label>
            <input type="text" name="question" id="edit-question" class="form-control" required>
          </div>
          <div class="form-group">
            <label class="font-weight-bold">Câu trả lời: <span class="text-danger">*</span></label>
            <textarea name="answer" id="edit-answer" rows="5" class="form-control" required></textarea>
          </div>
          <div class="row">
            <div class="col-md-6 form-group">
              <label class="font-weight-bold">Thứ tự hiển thị (Order Index):</label>
              <input type="number" name="orderIndex" id="edit-order" min="1" class="form-control" required>
            </div>
            <div class="col-md-6 form-group">
              <label class="font-weight-bold">Trạng thái hiển thị lên trang khách:</label>
              <select name="status" id="edit-status" class="form-control">
                <option value="ACTIVE">Hiển thị lên trang FAQ khách (ACTIVE)</option>
                <option value="INACTIVE">Tạm ẩn, không hiển thị (INACTIVE)</option>
              </select>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
          <button type="submit" class="btn btn-success font-weight-bold">
            <i class="fa fa-check mr-1"></i> Cập Nhật Thay Đổi
          </button>
        </div>
      </form>
    </div>
  </div>
</div>

<jsp:include page="../common/footer.jsp" />

<script>
  document.addEventListener('DOMContentLoaded', function () {
    var editButtons = document.querySelectorAll('.btn-edit-faq');
    editButtons.forEach(function (button) {
      button.addEventListener('click', function () {
        var id = this.getAttribute('data-id');
        var category = this.getAttribute('data-category');
        var question = this.getAttribute('data-question');
        var answer = this.getAttribute('data-answer');
        var order = this.getAttribute('data-order');
        var status = this.getAttribute('data-status');

        document.getElementById('edit-id').value = id;
        document.getElementById('edit-category').value = category;
        document.getElementById('edit-question').value = question;
        document.getElementById('edit-answer').value = answer;
        document.getElementById('edit-order').value = order;
        document.getElementById('edit-status').value = status;

        $('#modalEditFaq').modal('show');
      });
    });
  });
</script>