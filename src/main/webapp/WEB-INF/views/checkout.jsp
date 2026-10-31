<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="common/header.jsp">
    <jsp:param name="pageTitle" value="Sogo Homestay - Thanh Toán Đặt Phòng" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<section class="site-hero inner-page overlay hero-reservation"
         data-stellar-background-ratio="0.5">
    <div class="container">
        <div class="row site-hero-inner justify-content-center align-items-center">
            <div class="col-md-10 text-center" data-aos="fade">
                <h1 class="heading mb-3">
                    <c:choose>
                        <c:when test="${isConfirmed}">Xác Nhận Đặt Phòng Thành Công</c:when>
                        <c:otherwise>Thanh Toán Đặt Phòng</c:otherwise>
                    </c:choose>
                </h1>

                <ul class="custom-breadcrumbs mb-4">
                    <li>
                        <a href="${pageContext.request.contextPath}/home">Trang Chủ</a>
                    </li>
                    <li>&bullet;</li>
                    <li>
                        <a href="${pageContext.request.contextPath}/reservation">Đặt Phòng</a>
                    </li>
                    <li>&bullet;</li>
                    <li>
                        <c:choose>
                            <c:when test="${isConfirmed}">Hoàn Tất</c:when>
                            <c:otherwise>Thanh Toán</c:otherwise>
                        </c:choose>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</section>

<section class="section contact-section" id="next">
    <div class="container">

        <c:choose>
            <%-- ==================== TRƯỜNG HỢP: KHÔNG TÌM THẤY BOOKING ==================== --%>
            <c:when test="${empty booking}">
                <div class="alert alert-danger text-center shadow-sm p-4">
                    <i class="fa fa-exclamation-triangle fa-2x mb-3 text-danger d-block"></i>
                    <h4>Không tìm thấy thông tin đơn đặt phòng.</h4>
                    <p class="text-muted">Đơn đặt phòng có thể không tồn tại hoặc bạn không có quyền truy cập.</p>
                    <a href="${pageContext.request.contextPath}/rooms" class="btn btn-primary mt-2">
                        Quay Lại Danh Sách Phòng
                    </a>
                </div>
            </c:when>

            <%-- ==================== TRƯỜNG HỢP: ĐƠN ĐÃ BỊ HỦY ==================== --%>
            <c:when test="${isCancelled or booking.status eq 'CANCELLED'}">
                <div class="row justify-content-center">
                    <div class="col-md-8 text-center" data-aos="fade-up">
                        <div class="bg-white p-5 rounded border shadow-sm">
                            <i class="fa fa-ban text-danger fa-4x mb-3"></i>
                            <h2 class="h3 font-weight-bold text-dark mb-3">Đơn Đặt Phòng Đã Bị Hủy</h2>
                            <p class="text-muted mb-4">
                                Đơn đặt phòng <strong><c:out value="${booking.bookingCode}" /></strong> đã được hủy thành công.
                            </p>
                            <a href="${pageContext.request.contextPath}/rooms" class="btn btn-primary px-4 py-3">
                                Tìm Và Đặt Phòng Khác
                            </a>
                        </div>
                    </div>
                </div>
            </c:when>

            <%-- ==================== TRƯỜNG HỢP: ĐÃ THANH TOÁN THÀNH CÔNG ==================== --%>
            <c:when test="${isConfirmed or booking.status eq 'CONFIRMED' or booking.status eq 'PAID'}">
                <div class="row justify-content-center">
                    <div class="col-md-9" data-aos="fade-up">
                        <div class="bg-white p-md-5 p-4 rounded border shadow-sm text-center">
                            
                            <div class="mb-4">
                                <i class="fa fa-check-circle text-success" style="font-size: 5rem;"></i>
                            </div>

                            <h2 class="h3 font-weight-bold text-success mb-2">
                                Thanh Toán Đặt Phòng Thành Công!
                            </h2>
                            <p class="text-muted mb-4 lead">
                                Cảm ơn quý khách <strong><c:out value="${booking.customerName}" /></strong>.
                                Đơn đặt phòng của bạn đã được xác nhận hoàn tất.
                            </p>

                            <div class="card bg-light border-0 text-left p-4 mb-4">
                                <div class="row mb-3 pb-2 border-bottom">
                                    <div class="col-sm-6 text-muted">Mã Đặt Phòng:</div>
                                    <div class="col-sm-6 text-right">
                                        <span class="badge badge-success px-3 py-2 font-weight-bold" style="font-size: 1rem;">
                                            <c:out value="${booking.bookingCode}" />
                                        </span>
                                    </div>
                                </div>

                                <c:if test="${not empty payment}">
                                    <div class="row mb-3 pb-2 border-bottom">
                                        <div class="col-sm-6 text-muted">Mã Giao Dịch Thanh Toán:</div>
                                        <div class="col-sm-6 text-right font-weight-bold text-dark">
                                            <c:out value="${payment.transactionId}" />
                                        </div>
                                    </div>
                                </c:if>

                                <div class="row mb-3 pb-2 border-bottom">
                                    <div class="col-sm-6 text-muted">Phương Thức Thanh Toán:</div>
                                    <div class="col-sm-6 text-right font-weight-bold text-primary">
                                        Chuyển Khoản Ngân Hàng (VietQR)
                                    </div>
                                </div>

                                <div class="row mb-3 pb-2 border-bottom">
                                    <div class="col-sm-6 text-muted">Tổng Tiền Đã Thanh Toán:</div>
                                    <div class="col-sm-6 text-right font-weight-bold text-danger h5 mb-0">
                                        <fmt:formatNumber value="${totalAmount}" pattern="#,##0" /> VNĐ
                                    </div>
                                </div>

                                <div class="row mb-3 pb-2 border-bottom">
                                    <div class="col-sm-6 text-muted">Thời Gian Lưu Trú:</div>
                                    <div class="col-sm-6 text-right font-weight-bold text-dark">
                                        <fmt:formatDate value="${booking.checkInDate}" pattern="dd/MM/yyyy" />
                                        &rarr;
                                        <fmt:formatDate value="${booking.checkOutDate}" pattern="dd/MM/yyyy" />
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-sm-6 text-muted">Số Khách:</div>
                                    <div class="col-sm-6 text-right font-weight-bold text-dark">
                                        <c:out value="${booking.adults}" /> người lớn
                                        <c:if test="${booking.children > 0}">, <c:out value="${booking.children}" /> trẻ em</c:if>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex flex-wrap justify-content-center gap-2">
                                <button type="button" class="btn btn-outline-secondary px-4 py-3 mr-2 mb-2" onclick="window.print();">
                                    <i class="fa fa-print mr-2"></i> In Phiếu Xác Nhận
                                </button>
                                <a href="${pageContext.request.contextPath}/rooms" class="btn btn-primary px-4 py-3 mr-2 mb-2">
                                    <i class="fa fa-bed mr-2"></i> Xem Thêm Phòng
                                </a>
                                <a href="${pageContext.request.contextPath}/home" class="btn btn-light border px-4 py-3 mb-2">
                                    <i class="fa fa-home mr-2"></i> Quay Về Trang Chủ
                                </a>
                            </div>

                        </div>
                    </div>
                </div>
            </c:when>

            <%-- ==================== TRƯỜNG HỢP: CHỜ THANH TOÁN (PENDING) ==================== --%>
            <c:otherwise>

                <c:if test="${not empty messageError}">
                    <div class="alert alert-danger shadow-sm mb-4">
                        <i class="fa fa-exclamation-circle mr-2"></i>
                        <c:out value="${messageError}" />
                    </div>
                </c:if>

                <div class="row mb-4">
                    <div class="col-md-12" data-aos="fade-up">
                        <div class="alert alert-info shadow-sm d-flex align-items-center">
                            <i class="fa fa-info-circle fa-2x mr-3 text-info"></i>
                            <div>
                                Đơn đặt phòng <strong><c:out value="${booking.bookingCode}" /></strong> đã được tạo.
                                Quý khách vui lòng quét mã QR hoặc chuyển khoản ngân hàng theo thông tin dưới đây để hoàn tất thanh toán.
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">

                    <!-- ================= CỘT TRÁI: THÔNG TIN THANH TOÁN VIETQR ================= -->
                    <div class="col-md-7" data-aos="fade-up" data-aos-delay="100">

                        <!-- KHỐI QUÉT MÃ QR & THÔNG TIN CHUYỂN KHOẢN -->
                        <div class="bg-white p-md-5 p-4 mb-4 border rounded shadow-sm">

                            <h3 class="h4 font-weight-bold text-dark mb-4 border-bottom pb-2 d-flex align-items-center justify-content-between">
                                <span>
                                    <i class="fa fa-qrcode text-primary mr-2"></i>
                                    Thanh Toán Chuyển Khoản VietQR
                                </span>
                                <span class="badge badge-success small py-1 px-2" style="font-size: 0.8rem;">
                                    Tự động điền nội dung
                                </span>
                            </h3>

                            <!-- HIỂN THỊ ẢNH MÃ QR -->
                            <div class="text-center bg-light border rounded p-4 mb-4">
                                <div class="mb-3">
                                    <img src="${not empty qrImageUrl ? qrImageUrl : qrBase64}"
                                         onerror="this.onerror=null; this.src='${qrBase64}';"
                                         alt="VietQR Chuyển Khoản"
                                         class="img-fluid rounded border shadow-sm"
                                         style="max-width: 290px; width: 100%; height: auto; background: #fff; padding: 10px;" />
                                </div>
                                <p class="text-muted small mb-0">
                                    <i class="fa fa-mobile fa-lg mr-1 text-primary"></i>
                                    Quét bằng ứng dụng <strong>Ngân hàng bất kỳ</strong> hoặc <strong>MoMo, ZaloPay</strong>
                                </p>
                            </div>

                            <!-- BẢNG THÔNG TIN TÀI KHOẢN NHẬN TIỀN -->
                            <div class="bg-light border rounded p-3 mb-4">
                                
                                <div class="d-flex justify-content-between align-items-center mb-2 pb-2 border-bottom">
                                    <span class="text-muted small">Ngân hàng thụ hưởng:</span>
                                    <strong class="text-dark">
                                        <c:out value="${bankAccount.bankName}" /> (<c:out value="${bankAccount.bankCode}" />)
                                    </strong>
                                </div>

                                <div class="d-flex justify-content-between align-items-center mb-2 pb-2 border-bottom">
                                    <span class="text-muted small">Số tài khoản:</span>
                                    <span class="d-flex align-items-center">
                                        <strong class="text-primary font-weight-bold mr-2 h5 mb-0" id="accNumberVal">
                                            <c:out value="${bankAccount.accountNumber}" />
                                        </strong>
                                        <button type="button" class="btn btn-sm btn-outline-primary py-0 px-2"
                                                onclick="copyToClipboard('accNumberVal', this)" title="Sao chép số tài khoản">
                                            <i class="fa fa-copy"></i>
                                        </button>
                                    </span>
                                </div>

                                <div class="d-flex justify-content-between align-items-center mb-2 pb-2 border-bottom">
                                    <span class="text-muted small">Chủ tài khoản:</span>
                                    <strong class="text-dark text-uppercase">
                                        <c:out value="${bankAccount.accountHolder}" />
                                    </strong>
                                </div>

                                <div class="d-flex justify-content-between align-items-center mb-2 pb-2 border-bottom">
                                    <span class="text-muted small">Số tiền:</span>
                                    <span class="d-flex align-items-center">
                                        <strong class="text-danger font-weight-bold mr-2 h5 mb-0" id="amountVal">
                                            <fmt:formatNumber value="${totalAmount}" pattern="#,##0" /> VNĐ
                                        </strong>
                                        <button type="button" class="btn btn-sm btn-outline-danger py-0 px-2"
                                                onclick="copyText('${totalAmount.toPlainString()}', this)" title="Sao chép số tiền">
                                            <i class="fa fa-copy"></i>
                                        </button>
                                    </span>
                                </div>

                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="text-muted small">Nội dung chuyển khoản:</span>
                                    <span class="d-flex align-items-center">
                                        <strong class="text-dark bg-warning px-2 py-1 rounded mr-2 font-weight-bold" id="transferContentVal">
                                            <c:out value="${transferContent}" />
                                        </strong>
                                        <button type="button" class="btn btn-sm btn-outline-dark py-0 px-2"
                                                onclick="copyToClipboard('transferContentVal', this)" title="Sao chép nội dung">
                                            <i class="fa fa-copy"></i>
                                        </button>
                                    </span>
                                </div>

                            </div>

                            <!-- TRẠNG THÁI TỰ ĐỘNG ĐỐI SOÁT REAL-TIME -->
                            <div id="payment-live-box" class="alert alert-info d-flex align-items-center mb-3">
                                <div id="payment-live-spinner" class="spinner-border spinner-border-sm text-primary mr-2" role="status" style="width: 1.1rem; height: 1.1rem;">
                                    <span class="sr-only">Checking...</span>
                                </div>
                                <div class="small font-weight-bold" id="payment-live-text">
                                    Đang chờ nhận chuyển khoản từ ngân hàng... (Tự động cập nhật)
                                </div>
                            </div>

                            <!-- NÚT BẤM XÁC NHẬN THANH TOÁN -->
                            <form action="${pageContext.request.contextPath}/checkout" method="POST" class="mb-3">
                                <input type="hidden" name="csrfToken" value="${csrfToken}" />
                                <input type="hidden" name="bookingId" value="${booking.id}" />
                                <input type="hidden" name="action" value="confirm" />
                                
                                <button type="submit" class="btn btn-success btn-block btn-lg text-white font-weight-bold py-3 shadow">
                                    <i class="fa fa-check-circle mr-2"></i>
                                    Tôi Đã Chuyển Khoản Thành Công (Xác Nhận)
                                </button>
                            </form>

                            <!-- NÚT HỦY ĐƠN ĐẶT PHÒNG -->
                            <form action="${pageContext.request.contextPath}/checkout" method="POST"
                                  onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn đặt phòng này?');">
                                <input type="hidden" name="csrfToken" value="${csrfToken}" />
                                <input type="hidden" name="bookingId" value="${booking.id}" />
                                <input type="hidden" name="action" value="cancel" />

                                <button type="submit" class="btn btn-link btn-block text-muted small">
                                    <i class="fa fa-times-circle mr-1 text-danger"></i> Hủy đơn đặt phòng này
                                </button>
                            </form>

                            <p class="small text-muted text-center mt-3 mb-0">
                                <i class="fa fa-shield text-success mr-1"></i>
                                Giao dịch được bảo mật và tự động đối soát trên hệ thống Sogo Homestay.
                            </p>

                        </div>

                        <!-- THÔNG TIN CHI TIẾT ĐẶT PHÒNG -->
                        <div class="bg-white p-md-5 p-4 mb-4 border rounded shadow-sm">
                            <h3 class="h4 font-weight-bold text-dark mb-4 border-bottom pb-2">
                                <i class="fa fa-calendar-check-o text-primary mr-2"></i>
                                Thông Tin Đơn Đặt Phòng
                            </h3>

                            <div class="row mb-3">
                                <div class="col-sm-5 font-weight-bold text-dark">Mã đặt phòng</div>
                                <div class="col-sm-7 text-primary font-weight-bold">
                                    <c:out value="${booking.bookingCode}" />
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-sm-5 font-weight-bold text-dark">Họ và tên khách hàng</div>
                                <div class="col-sm-7"><c:out value="${booking.customerName}" /></div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-sm-5 font-weight-bold text-dark">Email</div>
                                <div class="col-sm-7"><c:out value="${booking.customerEmail}" /></div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-sm-5 font-weight-bold text-dark">Số điện thoại</div>
                                <div class="col-sm-7"><c:out value="${booking.customerPhone}" /></div>
                            </div>

                            <hr />

                            <div class="row mb-3">
                                <div class="col-sm-5 font-weight-bold text-dark">Ngày nhận phòng</div>
                                <div class="col-sm-7">
                                    <fmt:formatDate value="${booking.checkInDate}" pattern="dd/MM/yyyy" />
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-sm-5 font-weight-bold text-dark">Ngày trả phòng</div>
                                <div class="col-sm-7">
                                    <fmt:formatDate value="${booking.checkOutDate}" pattern="dd/MM/yyyy" />
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-sm-5 font-weight-bold text-dark">Số lượng khách</div>
                                <div class="col-sm-7">
                                    <c:out value="${booking.adults}" /> người lớn
                                    <c:if test="${booking.children > 0}">, <c:out value="${booking.children}" /> trẻ em</c:if>
                                </div>
                            </div>

                            <c:if test="${not empty booking.notes}">
                                <div class="row mb-3">
                                    <div class="col-sm-5 font-weight-bold text-dark">Ghi chú</div>
                                    <div class="col-sm-7 text-muted"><c:out value="${booking.notes}" /></div>
                                </div>
                            </c:if>
                        </div>

                    </div>

                    <!-- ================= CỘT PHẢI: CHI TIẾT TIỀN & HƯỚNG DẪN ================= -->
                    <div class="col-md-5" data-aos="fade-up" data-aos-delay="200">

                        <div class="bg-white p-4 rounded border shadow-sm mb-4">
                            <h4 class="h5 font-weight-bold text-dark mb-4 border-bottom pb-3">
                                <i class="fa fa-file-text-o text-primary mr-2"></i>
                                Chi Tiết Thanh Toán
                            </h4>

                            <div class="d-flex justify-content-between mb-3">
                                <span class="text-muted">Tiền phòng</span>
                                <strong class="text-dark">
                                    <fmt:formatNumber value="${subtotal}" pattern="#,##0" /> VNĐ
                                </strong>
                            </div>

                            <div class="d-flex justify-content-between mb-3">
                                <span class="text-muted">Giảm giá voucher</span>
                                <strong class="text-success">
                                    - <fmt:formatNumber value="${discountAmount}" pattern="#,##0" /> VNĐ
                                </strong>
                            </div>

                            <hr />

                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="font-weight-bold text-dark">Tổng Thanh Toán</span>
                                <span class="h4 font-weight-bold text-danger mb-0">
                                    <fmt:formatNumber value="${totalAmount}" pattern="#,##0" /> VNĐ
                                </span>
                            </div>

                            <div class="alert alert-light border small mb-0">
                                <i class="fa fa-shield mr-2 text-primary"></i>
                                Số tiền được tính toán an toàn từ hệ thống máy chủ Sogo Homestay.
                            </div>
                        </div>

                        <!-- HƯỚNG DẪN THANH TOÁN -->
                        <div class="bg-light p-4 rounded border mb-4">
                            <h5 class="font-weight-bold text-dark mb-3">
                                <i class="fa fa-question-circle text-primary mr-2"></i>
                                Hướng Dẫn Thanh Toán
                            </h5>

                            <ol class="text-muted small pl-3 mb-0" style="line-height: 1.8;">
                                <li>Mở ứng dụng ngân hàng hoặc ví điện tử trên điện thoại.</li>
                                <li>Chọn tính năng <strong>Quét mã QR</strong> và hướng camera vào mã QR ở trên.</li>
                                <li>Kiểm tra số tiền và nội dung chuyển khoản phải trùng khớp với thông tin hiển thị.</li>
                                <li>Xác nhận chuyển tiền trên app ngân hàng.</li>
                                <li>Nhấn nút <strong>"Tôi Đã Chuyển Khoản Thành Công"</strong> để hoàn tất đơn đặt phòng.</li>
                            </ol>
                        </div>

                        <!-- LƯU Ý -->
                        <div class="bg-light p-4 rounded border">
                            <h5 class="font-weight-bold text-dark mb-3">
                                <i class="fa fa-info-circle text-primary mr-2"></i>
                                Lưu Ý Quan Trọng
                            </h5>

                            <p class="text-muted small mb-2">
                                <i class="fa fa-check text-success mr-2"></i>
                                Vui lòng giữ đúng nội dung chuyển khoản để hệ thống đối soát chính xác.
                            </p>

                            <p class="text-muted small mb-2">
                                <i class="fa fa-check text-success mr-2"></i>
                                Sau khi thanh toán thành công, trạng thái đơn sẽ chuyển sang <strong>CONFIRMED</strong>.
                            </p>

                            <p class="text-muted small mb-0">
                                <i class="fa fa-phone text-success mr-2"></i>
                                Hỗ trợ khẩn cấp: Hotline <strong>090 123 4567</strong> (24/7).
                            </p>
                        </div>

                    </div>

                </div>

            </c:otherwise>
        </c:choose>

    </div>
</section>

<!-- SCRIPT SAO CHÉP CLIPBOARD -->
<script>
function copyToClipboard(elementId, btn) {
    var elem = document.getElementById(elementId);
    if (!elem) return;
    var text = elem.innerText.trim();
    copyText(text, btn);
}

function copyText(text, btn) {
    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(text).then(function() {
            showCopySuccess(btn);
        }).catch(function() {
            fallbackCopy(text, btn);
        });
    } else {
        fallbackCopy(text, btn);
    }
}

function fallbackCopy(text, btn) {
    var tempInput = document.createElement("input");
    tempInput.value = text;
    document.body.appendChild(tempInput);
    tempInput.select();
    try {
        document.execCommand("copy");
        showCopySuccess(btn);
    } catch (err) {
        alert("Đã chọn: " + text);
    }
    document.body.removeChild(tempInput);
}

function showCopySuccess(btn) {
    if (!btn) return;
    var originalHtml = btn.innerHTML;
    btn.innerHTML = '<i class="fa fa-check text-success"></i>';
    btn.classList.add("btn-success");
    btn.classList.remove("btn-outline-primary", "btn-outline-danger", "btn-outline-dark");
    setTimeout(function() {
        btn.innerHTML = originalHtml;
        btn.classList.remove("btn-success");
    }, 1500);
}

// Auto-polling payment status every 2 seconds
(function() {
    var bookingId = "${booking.id}";
    var isConfirmed = ${isConfirmed or booking.status eq 'CONFIRMED' or booking.status eq 'PAID'};
    if (isConfirmed || !bookingId) return;

    var pollCount = 0;
    var maxPoll = 300; // 10 minutes

    var pollInterval = setInterval(function() {
        pollCount++;
        if (pollCount > maxPoll) {
            clearInterval(pollInterval);
            return;
        }

        fetch('${pageContext.request.contextPath}/api/payment/status?bookingId=' + encodeURIComponent(bookingId), {
            cache: 'no-store'
        })
        .then(function(res) {
            if (!res.ok) throw new Error('HTTP ' + res.status);
            return res.json();
        })
        .then(function(data) {
            if (data && (data.isPaid === true || data.status === 'CONFIRMED' || data.status === 'PAID')) {
                clearInterval(pollInterval);
                var box = document.getElementById('payment-live-box');
                var text = document.getElementById('payment-live-text');
                var spinner = document.getElementById('payment-live-spinner');
                if (box) {
                    box.className = 'alert alert-success d-flex align-items-center mb-3';
                }
                if (spinner) {
                    spinner.style.display = 'none';
                }
                if (text) {
                    text.innerHTML = '<i class="fa fa-check-circle mr-2 text-success"></i><strong>Đã nhận tiền thành công!</strong> Đang chuyển đến màn hình xác nhận...';
                }
                setTimeout(function() {
                    window.location.reload();
                }, 1200);
            }
        })
        .catch(function(e) {
            // ignore network jitter
        });
    }, 2000);
})();
</script>

<jsp:include page="common/footer.jsp" />
