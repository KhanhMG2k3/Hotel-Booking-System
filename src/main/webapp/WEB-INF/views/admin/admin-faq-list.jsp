<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../common/header.jsp">
  <jsp:param name="pageTitle" value="Quản Trị FAQ - Sogo Homestay" />
</jsp:include>

<!-- 1. THÊM THANH NAVBAR CHÍNH CỦA HỆ THỐNG -->
<jsp:include page="../common/navbar.jsp" />

<style>
  /* Khoảng cách đệm phía trên để không bị thanh header cố định che khuất */
  .admin-faq-container {
    padding-top: 115px;
    padding-bottom: 80px;
    min-height: 85vh;
  }

  /* Đường dẫn Breadcrumb */
  .custom-breadcrumb {
    font-size: 0.9rem;
    margin-bottom: 12px;
  }
  .custom-breadcrumb a {
    color: #f7a030;
    text-decoration: none;
  }
  .custom-breadcrumb a:hover {
    text-decoration: underline;
  }
  .custom-breadcrumb span {
    color: #888888;
    margin: 0 6px;
  }
  .custom-breadcrumb .active-crumb {
    color: #adb5bd;
  }

  /* Cột kéo thả với dấu gạch ngang */
  .drag-handle {
    cursor: grab;
    color: #888888;
    font-size: 1.15rem;
    transition: all 0.2s ease;
    user-select: none;
    width: 50px;
  }
  .drag-handle:hover {
    color: #f7a030;
    transform: scale(1.15);
  }
  .faq-row:active .drag-handle {
    cursor: grabbing;
  }
  .faq-row.dragging {
    opacity: 0.45;
    background-color: #fff3cd !important;
  }
  .faq-row.drag-over-top {
    border-top: 3px solid #f7a030 !important;
  }
  .faq-row.drag-over-bottom {
    border-bottom: 3px solid #f7a030 !important;
  }
</style>

<div class="container admin-faq-container">

  <!-- ĐƯỜNG DẪN BREADCRUMB QUAY VỀ TRANG CHÍNH -->
  <div class="custom-breadcrumb">
    <a href="${pageContext.request.contextPath}/home"><i class="fa fa-home mr-1"></i> Trang Chủ</a>
    <span>&gt;</span>
    <a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fa fa-cogs mr-1"></i> Trang Quản Trị</a>
    <span>&gt;</span>
    <span class="active-crumb">Quản Lý FAQ</span>
  </div>

  <!-- TIÊU ĐỀ & CÁC NÚT ĐIỀU HƯỚNG QUAY VỀ -->
  <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom flex-wrap" style="gap: 10px;">
    <div>
      <h2 class="font-weight-bold text-dark mb-1">
        <i class="fa fa-question-circle text-primary mr-2"></i>Quản Lý FAQ Hệ Thống
      </h2>
      <p class="text-muted small mb-0">Kéo thả dấu 3 gạch ngang để thay đổi thứ tự câu hỏi hiển thị lên trang khách</p>
    </div>

    <!-- CÁC NÚT ĐIỀU HƯỚNG CHÍNH -->
    <div class="d-flex align-items-center flex-wrap" style="gap: 8px;">
      <!-- Nút 1: Quay lại Trang Chủ -->
      <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-secondary btn-sm font-weight-bold">
        <i class="fa fa-arrow-left mr-1"></i> Về Trang Chủ
      </a>

      <!-- Nút 2: Quay lại Trang Quản Trị Admin Dashboard -->
      <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-dark btn-sm font-weight-bold">
        <i class="fa fa-cogs mr-1"></i> Trang Quản Trị
      </a>

      <!-- Nút 3: Xem Trang FAQ Khách -->
      <a href="${pageContext.request.contextPath}/faq" target="_blank" class="btn btn-outline-info btn-sm font-weight-bold">
        <i class="fa fa-eye mr-1"></i> Xem FAQ Khách
      </a>

      <!-- Nút 4: Thêm Câu Hỏi Mới -->
      <button class="btn btn-primary btn-sm font-weight-bold shadow-sm" data-toggle="modal" data-target="#modalAddFaq">
        <i class="fa fa-plus-circle mr-1"></i> Thêm Câu Hỏi Mới
      </button>
    </div>
  </div>

  <!-- CÁC THÔNG BÁO ALERT -->
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

  <!-- KHỐI TÌM KIẾM NHANH TRONG ADMIN -->
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

  <!-- BẢNG DANH SÁCH FAQ CHO ADMIN -->
  <div class="bg-white rounded shadow-sm border p-3">
    <div class="table-responsive">
      <table class="table table-hover table-bordered mb-0 align-middle">
        <thead class="thead-light text-center">
          <tr>
            <th style="width: 50px;" class="text-center" title="Kéo thả dấu 3 gạch ngang để thay đổi thứ tự">
              <i class="fa fa-bars text-muted"></i>
            </th>
            <th style="width: 150px;">Chuyên Mục</th>
            <th style="width: 280px;">Câu Hỏi</th>
            <th>Câu Trả Lời</th>
            <th style="width: 170px;">Hiển Thị Trang Khách</th>
            <th style="width: 140px;">Thao Tác</th>
          </tr>
        </thead>
        <tbody id="faqTableBody">
          <c:choose>
            <c:when test="${not empty faqList}">
              <c:forEach var="faq" items="${faqList}">
                <tr class="faq-row" data-id="${faq.id}">
                  <td class="text-center drag-handle" title="Nhấp giữ dấu gạch ngang và kéo lên/xuống để đổi thứ tự">
                    <i class="fa fa-bars"></i>
                  </td>
                  
                  <td class="text-center">
                    <span class="badge badge-secondary p-2" style="font-size: 0.85rem;">
                      ${faq.category}
                    </span>
                  </td>
                  
                  <td class="font-weight-bold text-dark" style="word-break: break-word;">
                    ${faq.question}
                  </td>
                  
                  <td class="text-secondary small" style="white-space: pre-line; word-break: break-word;">
                    ${faq.answer}
                  </td>
                  
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

<!-- ================= MODAL THÊM CÂU HỎI MỚI ================= -->
<div class="modal fade" id="modalAddFaq" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <form action="${pageContext.request.contextPath}/admin/faqs/add" method="post">
        <input type="hidden" name="orderIndex" value="999">
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
          <div class="form-group">
            <label class="font-weight-bold">Trạng thái hiển thị lên trang khách:</label>
            <select name="status" class="form-control">
              <option value="ACTIVE" selected>Hiển thị lên trang FAQ khách (ACTIVE)</option>
              <option value="INACTIVE">Tạm ẩn, không hiển thị (INACTIVE)</option>
            </select>
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

<!-- ================= MODAL SỬA CÂU HỎI & CÂU TRẢ LỜI ================= -->
<div class="modal fade" id="modalEditFaq" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <form action="${pageContext.request.contextPath}/admin/faqs/edit" method="post">
        <input type="hidden" name="id" id="edit-id">
        <input type="hidden" name="orderIndex" id="edit-order">

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
          <div class="form-group">
            <label class="font-weight-bold">Trạng thái hiển thị lên trang khách:</label>
            <select name="status" id="edit-status" class="form-control">
              <option value="ACTIVE">Hiển thị lên trang FAQ khách (ACTIVE)</option>
              <option value="INACTIVE">Tạm ẩn, không hiển thị (INACTIVE)</option>
            </select>
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

<!-- SCRIPT KÉO THẢ THỨ TỰ (DRAG & DROP) & GẮN DỮ LIỆU MODAL -->
<script>
  document.addEventListener('DOMContentLoaded', function () {
    // 1. Gắn dữ liệu vào Modal Sửa
    var editButtons = document.querySelectorAll('.btn-edit-faq');
    editButtons.forEach(function (button) {
      button.addEventListener('click', function () {
        document.getElementById('edit-id').value = this.getAttribute('data-id');
        document.getElementById('edit-category').value = this.getAttribute('data-category');
        document.getElementById('edit-question').value = this.getAttribute('data-question');
        document.getElementById('edit-answer').value = this.getAttribute('data-answer');
        document.getElementById('edit-order').value = this.getAttribute('data-order');
        document.getElementById('edit-status').value = this.getAttribute('data-status');
        $('#modalEditFaq').modal('show');
      });
    });

    // 2. Logic Kéo Thả (Drag & Drop) bảng FAQ
    var tableBody = document.getElementById('faqTableBody');
    var draggedRow = null;

    if (tableBody) {
      var rows = tableBody.querySelectorAll('tr.faq-row');
      rows.forEach(function (row) {
        row.setAttribute('draggable', 'true');

        row.addEventListener('dragstart', function (e) {
          draggedRow = this;
          this.classList.add('dragging');
          e.dataTransfer.effectAllowed = 'move';
          e.dataTransfer.setData('text/plain', this.getAttribute('data-id'));
        });

        row.addEventListener('dragover', function (e) {
          e.preventDefault();
          e.dataTransfer.dropEffect = 'move';
          if (!draggedRow || draggedRow === this) return;

          var rect = this.getBoundingClientRect();
          var midY = rect.top + rect.height / 2;

          rows.forEach(function (r) {
            r.classList.remove('drag-over-top', 'drag-over-bottom');
          });

          if (e.clientY < midY) {
            this.classList.add('drag-over-top');
          } else {
            this.classList.add('drag-over-bottom');
          }
        });

        row.addEventListener('dragleave', function () {
          this.classList.remove('drag-over-top', 'drag-over-bottom');
        });

        row.addEventListener('drop', function (e) {
          e.preventDefault();
          this.classList.remove('drag-over-top', 'drag-over-bottom');
          if (!draggedRow || draggedRow === this) return;

          var rect = this.getBoundingClientRect();
          var midY = rect.top + rect.height / 2;

          if (e.clientY < midY) {
            tableBody.insertBefore(draggedRow, this);
          } else {
            tableBody.insertBefore(draggedRow, this.nextSibling);
          }

          saveNewFaqOrder();
        });

        row.addEventListener('dragend', function () {
          this.classList.remove('dragging');
          rows.forEach(function (r) {
            r.classList.remove('drag-over-top', 'drag-over-bottom');
          });
          draggedRow = null;
        });
      });
    }

    function saveNewFaqOrder() {
      var allRows = tableBody.querySelectorAll('tr.faq-row');
      var ids = Array.from(allRows).map(function (r) {
        return r.getAttribute('data-id');
      });

      var params = new URLSearchParams();
      params.append('ids', ids.join(','));

      fetch('${pageContext.request.contextPath}/admin/faqs/reorder', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
        },
        body: params
      })
      .then(function (res) { return res.json(); })
      .then(function (data) {
        showReorderToast('Đã lưu thứ tự hiển thị mới thành công!');
      })
      .catch(function (err) {
        console.error('Lỗi lưu thứ tự FAQ:', err);
      });
    }

    function showReorderToast(msg) {
      var toast = document.getElementById('faqReorderToast');
      if (!toast) {
        toast = document.createElement('div');
        toast.id = 'faqReorderToast';
        toast.style.cssText = 'position:fixed;bottom:25px;right:25px;background:#28a745;color:#fff;padding:12px 22px;border-radius:6px;box-shadow:0 4px 15px rgba(0,0,0,0.25);z-index:99999;font-weight:bold;display:flex;align-items:center;gap:10px;';
        toast.innerHTML = '<i class="fa fa-check-circle" style="font-size:1.2rem;"></i> <span></span>';
        document.body.appendChild(toast);
      }
      toast.querySelector('span').innerText = msg;
      toast.style.display = 'flex';
      clearTimeout(window._toastTimer);
      window._toastTimer = setTimeout(function () {
        toast.style.display = 'none';
      }, 2500);
    }
  });
</script>