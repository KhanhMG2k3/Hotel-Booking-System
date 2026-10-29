<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../common/header.jsp">
  <jsp:param name="pageTitle" value="Quản Lý Điều Khoản - Sogo Homestay" />
</jsp:include>

<jsp:include page="../common/navbar.jsp" />

<style>
    :root {
        --bg-main: #121316; --bg-card: #1c1e24; --bg-input: #15171c;
        --border-color: #2e323b; --accent-gold: #c99742; --danger: #ef4444;
        --success: #22c55e; --warning: #f59e0b;
    }
    body { background-color: var(--bg-main) !important; color: #f3f4f6; }
    .admin-terms-wrapper { 
        max-width: 1100px; 
        margin: 130px auto 50px auto; 
        padding: 0 20px; 
        position: relative;
        z-index: 1;
    }
    .card-dark { background-color: var(--bg-card); border: 1px solid var(--border-color); border-radius: 8px; padding: 24px; margin-bottom: 25px; }
    .gold-title { color: var(--accent-gold); font-size: 18px; font-weight: bold; }
    .form-control-dark { width: 100%; padding: 9px 12px; background-color: var(--bg-input); border: 1px solid var(--border-color); border-radius: 6px; color: #fff; font-size: 14px; }
    .form-control-dark:focus { border-color: var(--accent-gold); outline: none; background-color: #191c22; }
    .section-card { background-color: #17191f; border: 1px solid var(--border-color); border-radius: 8px; padding: 20px; margin-bottom: 25px; }
    .badge-order { background: rgba(201,151,66,0.15); color: var(--accent-gold); padding: 5px 12px; border-radius: 20px; font-weight: bold; }
    .btn-del-sec { background: rgba(239,68,68,0.15); color: var(--danger); border: 1px solid rgba(239,68,68,0.3); padding: 6px 14px; border-radius: 6px; cursor: pointer; }
    .btn-del-sec:hover { background: var(--danger); color: #fff; }
    
    .content-block { background: #131418; border: 1px dashed #3a3f4d; border-radius: 6px; padding: 15px; margin-top: 14px; }
    .btn-add-block { background: #222630; color: #d1d5db; border: 1px solid #3b4252; padding: 7px 14px; border-radius: 4px; font-size: 13px; cursor: pointer; margin-right: 8px; margin-top: 8px; }
    .btn-add-block:hover { border-color: var(--accent-gold); color: var(--accent-gold); }
    
    .dynamic-table-container { overflow-x: auto; margin-top: 10px; }
    .table-dynamic { width: 100%; border-collapse: collapse; min-width: 500px; }
    .table-dynamic th, .table-dynamic td { padding: 8px 6px; border: 1px solid #2e323b; vertical-align: middle; }
    .table-dynamic th { background: #1a1d24; }
    .btn-save-main { background: linear-gradient(135deg, var(--accent-gold), #b38234); color: #000; font-weight: bold; border: none; padding: 12px 28px; border-radius: 6px; cursor: pointer; font-size: 15px; }
</style>

<div class="admin-terms-wrapper">
    <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom" style="border-color: var(--border-color) !important;">
        <div>
            <h2 class="gold-title" style="font-size: 24px; margin-bottom: 0;">
                <i class="fa fa-file-text-o mr-2"></i> Quản Lý Điều Khoản & Quy Định
            </h2>
        </div>
        <a href="${pageContext.request.contextPath}/terms" target="_blank" class="btn btn-warning btn-sm font-weight-bold text-dark shadow-sm">
            <i class="fa fa-external-link mr-1"></i> Xem Trang Điều Khoản
        </a>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger mb-4"><i class="fa fa-exclamation-triangle mr-2"></i> ${error}</div>
    </c:if>
    <c:if test="${not empty sessionScope.msg}">
        <div class="alert alert-success mb-4"><i class="fa fa-check-circle mr-2"></i> ${sessionScope.msg}</div>
        <c:remove var="msg" scope="session" />
    </c:if>

    <form action="${pageContext.request.contextPath}/admin/terms" method="post" id="adminTermsForm" onsubmit="return validateForm()">
        
        <!-- TIÊU ĐỀ CHÍNH -->
        <div class="card-dark">
            <h4 class="gold-title mb-3"><i class="fa fa-sliders mr-2"></i> Tiêu Đề Chính Của Trang</h4>
            <div class="form-group mb-2">
                <input type="text" name="mainTitle" id="mainTitle" class="form-control-dark" value="${setting.mainTitle}" placeholder="Nhập tiêu đề chính..." required>
            </div>
            <small class="text-muted"><i class="fa fa-clock-o mr-1"></i> Thời gian cập nhật sẽ được hệ thống <strong>tự động ghi nhận</strong> ngay khi nhấn "Lưu".</small>
        </div>

        <!-- DANH SÁCH MỤC LỤC -->
        <div class="card-dark">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="gold-title mb-0"><i class="fa fa-list-ol mr-2"></i> Danh Sách Mục Lục & Nội Dung</h4>
                <small class="text-muted">Khi xóa mục bất kỳ, số thứ tự sẽ tự động cập nhật lại từ 1 đến hết</small>
            </div>

            <div id="sectionContainer">
                <c:forEach items="${sections}" var="sec" varStatus="loop">
                    <div class="section-card" id="sec-card-${loop.index}">
                        <div class="d-flex justify-content-between align-items-center pb-2 mb-3 border-bottom" style="border-color: var(--border-color) !important;">
                            <span class="badge-order order-label">Mục ${loop.count}</span>
                            <button type="button" class="btn-del-sec" onclick="deleteSection(this)">
                                <i class="fa fa-trash mr-1"></i> Xóa mục này
                            </button>
                        </div>

                        <!-- 1 TIÊU ĐỀ MỤC DUY NHẤT -->
                        <div class="form-group mb-3">
                            <label class="text-muted font-weight-bold">Tiêu đề mục (*)</label>
                            <input type="text" name="sectionTitle" class="form-control-dark req-title" 
                                   value="${sec.contentTitle}" placeholder="Ví dụ: Quy Định Nhận Phòng & Trả Phòng" required>
                        </div>

                        <!-- LƯU TRỮ TEXT BAN ĐẦU AN TOÀN (DÙNG TEXTAREA ĐỂ KHÔNG BỊ LỖI NEWLINE) -->
                        <textarea class="raw-db-content" style="display:none;"><c:out value="${sec.contentText}"/></textarea>
                        <textarea class="raw-db-table" style="display:none;"><c:out value="${sec.tableJson}"/></textarea>
                        <input type="hidden" class="raw-db-callout" value="<c:out value='${sec.calloutText}'/>">
                        <input type="hidden" class="raw-db-callout-type" value="${sec.calloutType}">

                        <!-- VÙNG CHỨA CÁC KHỐI NỘI DUNG (SẼ ĐƯỢC LOAD VÀ CÓ THỂ CHÈN THÊM Ô TEXT MỚI Ở DƯỚI) -->
                        <div class="blocks-container" id="blocks-container-${loop.index}"></div>

                        <!-- THANH NÚT THÊM NỘI DUNG -->
                        <div class="mt-3 pt-2 border-top" style="border-color: #252830 !important;">
                            <span class="text-muted mr-2" style="font-size: 13px;">Thêm khối nội dung:</span>
                            <button type="button" class="btn-add-block" onclick="addTextBlock(${loop.index})">
                                <i class="fa fa-align-left text-primary mr-1"></i> + Thêm Nội Dung Chính (Ô Text Mới)
                            </button>
                            <button type="button" class="btn-add-block" onclick="addTableBlock(${loop.index})">
                                <i class="fa fa-table text-warning mr-1"></i> + Thêm Bảng Table
                            </button>
                            <button type="button" class="btn-add-block" onclick="addCalloutBlock(${loop.index})">
                                <i class="fa fa-info-circle text-info mr-1"></i> + Thêm Chú Thích
                            </button>
                        </div>

                        <input type="hidden" name="sectionBlocksJson" class="input-section-blocks" value="">
                    </div>
                </c:forEach>
            </div>

            <div class="d-flex justify-content-between align-items-center mt-4">
                <button type="button" class="btn-add-block" style="padding: 10px 18px; font-weight: bold; border-color: var(--accent-gold); color: var(--accent-gold);" onclick="addNewSection()">
                    <i class="fa fa-plus mr-1"></i> Thêm Mục Mới
                </button>
                <button type="submit" class="btn-save-main">
                    <i class="fa fa-save mr-1"></i> Lưu & Cập Nhật Lên Hệ Thống
                </button>
            </div>
        </div>
    </form>
</div>

<jsp:include page="../common/footer.jsp" />

<script>
    function deleteSection(btn) {
        if (confirm("Bạn có chắc chắn muốn xóa mục này? Số thứ tự các mục còn lại sẽ tự động dồn lại từ 1 đến hết.")) {
            btn.closest('.section-card').remove();
            reOrderSections();
        }
    }

    function reOrderSections() {
        var labels = document.querySelectorAll('.order-label');
        labels.forEach(function(label, index) {
            label.innerText = 'Mục ' + (index + 1);
        });
    }

    function removeBlock(btn) {
        btn.closest('.content-block').remove();
    }

    // 1. CHÈN THÊM Ô TEXT MỚI Ở DƯỚI
    function addTextBlock(secIdx, initialText) {
        var container = document.getElementById('blocks-container-' + secIdx);
        var div = document.createElement('div');
        div.className = 'content-block block-item block-text';
        div.dataset.type = 'text';
        div.innerHTML = `
            <div class="d-flex justify-content-between align-items-center mb-2">
                <span class="text-white font-weight-bold">
                    <i class="fa fa-align-left text-primary mr-1"></i> Nội Dung Chính (Văn bản / Gạch đầu dòng)
                </span>
                <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeBlock(this)">
                    <i class="fa fa-times mr-1"></i> Xóa khối văn bản này
                </button>
            </div>
            <textarea class="form-control-dark block-val-text" rows="4" placeholder="Nhập nội dung văn bản, bắt đầu mỗi dòng bằng • hoặc -"></textarea>
        `;
        container.appendChild(div);
        var textarea = div.querySelector('textarea');
        if (initialText !== undefined && initialText !== null) {
            textarea.value = initialText;
        } else {
            textarea.focus();
        }
    }

    // 2. CHÈN THÊM KHỐI CHÚ THÍCH (CALLOUT) Ở DƯỚI
    function addCalloutBlock(secIdx, initialText, initialType) {
        var container = document.getElementById('blocks-container-' + secIdx);
        var div = document.createElement('div');
        div.className = 'content-block block-item block-callout';
        div.dataset.type = 'callout';
        var typeVal = initialType || 'info';
        div.innerHTML = `
            <div class="d-flex justify-content-between align-items-center mb-2">
                <span class="text-white font-weight-bold">
                    <i class="fa fa-info-circle text-info mr-1"></i> Hộp Chú Thích (Callout Box)
                </span>
                <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeBlock(this)">
                    <i class="fa fa-times mr-1"></i> Xóa chú thích
                </button>
            </div>
            <div class="form-row">
                <div class="col-md-8 mb-2">
                    <input type="text" class="form-control-dark block-val-callout-text" placeholder="Nhập ghi chú nổi bật...">
                </div>
                <div class="col-md-4 mb-2">
                    <select class="form-control-dark block-val-callout-type">
                        <option value="info" \${typeVal === 'info' ? 'selected' : ''}>Hộp Thông Báo (Xanh Lam)</option>
                        <option value="note" \${typeVal === 'note' ? 'selected' : ''}>Hộp Liên Hệ (Xám)</option>
                    </select>
                </div>
            </div>
        `;
        container.appendChild(div);
        var input = div.querySelector('input');
        if (initialText) input.value = initialText;
        else input.focus();
    }

    // 3. CHÈN THÊM KHỐI BẢNG DỮ LIỆU (TABLE) Ở DƯỚI
    function addTableBlock(secIdx, initialData) {
        var container = document.getElementById('blocks-container-' + secIdx);
        var div = document.createElement('div');
        div.className = 'content-block block-item block-table';
        div.dataset.type = 'table';

        var tData = initialData || {
            title: "Bảng Chính Sách Hoàn Tiền",
            headers: ["Thời Gian Thông Báo Hủy", "Chính Sách Hoàn Cọc"],
            rows: [
                ["Trước 07 ngày so với ngày nhận phòng", "Hoàn 100% tiền đặt cọc (trừ phí chuyển khoản nếu có)"],
                ["Từ 03 đến 06 ngày trước ngày nhận phòng", "Hoàn 50% tiền đặt cọc"],
                ["Dưới 03 ngày hoặc Không đến (No-show)", "Không hoàn lại tiền cọc"]
            ]
        };

        div.innerHTML = `
            <div class="d-flex justify-content-between align-items-center mb-2">
                <span class="text-white font-weight-bold">
                    <i class="fa fa-table text-warning mr-1"></i> Bảng Dữ Liệu (Table Động)
                </span>
                <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeBlock(this)">
                    <i class="fa fa-times mr-1"></i> Xóa bảng
                </button>
            </div>
            <div class="form-group mb-2">
                <label class="text-muted font-weight-bold" style="font-size: 13px;">Tên / Tiêu đề bảng:</label>
                <input type="text" class="form-control-dark block-val-tbl-title" placeholder="Nhập tiêu đề cho bảng...">
            </div>
            <div class="d-flex align-items-center mb-2">
                <button type="button" class="btn-add-block" style="border-color: #38bdf8; color: #38bdf8;" onclick="addColumnToTable(this)">
                    <i class="fa fa-columns mr-1"></i> + Thêm Cột
                </button>
                <button type="button" class="btn-add-block" style="border-color: var(--accent-gold); color: var(--accent-gold);" onclick="addRowToTable(this)">
                    <i class="fa fa-plus mr-1"></i> + Thêm Hàng
                </button>
            </div>
            <div class="dynamic-table-container">
                <table class="table-dynamic">
                    <thead><tr class="header-row"></tr></thead>
                    <tbody class="body-rows"></tbody>
                </table>
            </div>
        `;
        container.appendChild(div);
        div.querySelector('.block-val-tbl-title').value = tData.title || '';
        renderTableRowsInside(div, tData);
    }

    function renderTableRowsInside(blockDiv, tData) {
        var theadRow = blockDiv.querySelector('.header-row');
        var tbody = blockDiv.querySelector('.body-rows');
        theadRow.innerHTML = '';
        tbody.innerHTML = '';

        tData.headers.forEach(function(h) {
            var th = document.createElement('th');
            th.innerHTML = `
                <div class="d-flex align-items-center">
                    <input type="text" class="form-control-dark tbl-header-input" value="\${escapeHtml(h)}" placeholder="Tên cột...">
                    <button type="button" class="btn btn-sm btn-outline-danger ml-1 p-1" title="Xóa cột" onclick="deleteColumnFromTable(this)">
                        <i class="fa fa-times"></i>
                    </button>
                </div>
            `;
            theadRow.appendChild(th);
        });
        var thDel = document.createElement('th');
        thDel.style.width = '45px';
        thDel.innerHTML = '<span class="text-muted" style="font-size: 11px;">Xóa</span>';
        theadRow.appendChild(thDel);

        tData.rows.forEach(function(r) {
            var tr = document.createElement('tr');
            tData.headers.forEach(function(h, idx) {
                var td = document.createElement('td');
                var val = r[idx] !== undefined ? r[idx] : '';
                td.innerHTML = `<input type="text" class="form-control-dark tbl-cell-input" value="\${escapeHtml(val)}" placeholder="Nội dung...">`;
                tr.appendChild(td);
            });
            var tdDel = document.createElement('td');
            tdDel.innerHTML = `<button type="button" class="btn btn-sm btn-outline-danger p-1" title="Xóa hàng" onclick="this.closest('tr').remove()"><i class="fa fa-trash"></i></button>`;
            tr.appendChild(tdDel);
            tbody.appendChild(tr);
        });
    }

    function addColumnToTable(btn) {
        var block = btn.closest('.block-table');
        var theadRow = block.querySelector('.header-row');
        var tbody = block.querySelector('.body-rows');
        var currentCols = theadRow.children.length - 1;

        var th = document.createElement('th');
        th.innerHTML = `
            <div class="d-flex align-items-center">
                <input type="text" class="form-control-dark tbl-header-input" value="Cột \${currentCols + 1}">
                <button type="button" class="btn btn-sm btn-outline-danger ml-1 p-1" title="Xóa cột" onclick="deleteColumnFromTable(this)">
                    <i class="fa fa-times"></i>
                </button>
            </div>
        `;
        theadRow.insertBefore(th, theadRow.lastElementChild);

        tbody.querySelectorAll('tr').forEach(function(tr) {
            var td = document.createElement('td');
            td.innerHTML = `<input type="text" class="form-control-dark tbl-cell-input" value="" placeholder="Nội dung...">`;
            tr.insertBefore(td, tr.lastElementChild);
        });
    }

    function deleteColumnFromTable(btn) {
        var th = btn.closest('th');
        var theadRow = th.parentElement;
        if (theadRow.children.length <= 2) {
            alert("Bảng phải có ít nhất 1 cột!");
            return;
        }
        var colIdx = Array.from(theadRow.children).indexOf(th);
        var tbody = theadRow.closest('table').querySelector('.body-rows');
        tbody.querySelectorAll('tr').forEach(function(tr) {
            if (tr.children[colIdx]) tr.children[colIdx].remove();
        });
        th.remove();
    }

    function addRowToTable(btn) {
        var block = btn.closest('.block-table');
        var theadRow = block.querySelector('.header-row');
        var tbody = block.querySelector('.body-rows');
        var colCount = theadRow.children.length - 1;

        if (colCount <= 0) {
            addColumnToTable(btn);
            colCount = 1;
        }

        var tr = document.createElement('tr');
        for (var i = 0; i < colCount; i++) {
            var td = document.createElement('td');
            td.innerHTML = `<input type="text" class="form-control-dark tbl-cell-input" value="" placeholder="Nội dung...">`;
            tr.appendChild(td);
        }
        var tdDel = document.createElement('td');
        tdDel.innerHTML = `<button type="button" class="btn btn-sm btn-outline-danger p-1" title="Xóa hàng" onclick="this.closest('tr').remove()"><i class="fa fa-trash"></i></button>`;
        tr.appendChild(tdDel);
        tbody.appendChild(tr);
    }

    function addNewSection() {
        var container = document.getElementById('sectionContainer');
        var newIndex = document.querySelectorAll('.section-card').length + 1;
        var secIdx = newIndex - 1;

        var div = document.createElement('div');
        div.className = 'section-card';
        div.id = 'sec-card-' + secIdx;
        div.innerHTML = `
            <div class="d-flex justify-content-between align-items-center pb-2 mb-3 border-bottom" style="border-color: var(--border-color) !important;">
                <span class="badge-order order-label">Mục \${newIndex}</span>
                <button type="button" class="btn-del-sec" onclick="deleteSection(this)">
                    <i class="fa fa-trash mr-1"></i> Xóa mục này
                </button>
            </div>
            <div class="form-group mb-3">
                <label class="text-muted font-weight-bold">Tiêu đề mục (*)</label>
                <input type="text" name="sectionTitle" class="form-control-dark req-title" placeholder="Nhập tiêu đề mục mới..." required>
            </div>
            <div class="blocks-container" id="blocks-container-\${secIdx}"></div>
            <div class="mt-3 pt-2 border-top" style="border-color: #252830 !important;">
                <span class="text-muted mr-2" style="font-size: 13px;">Thêm khối nội dung:</span>
                <button type="button" class="btn-add-block" onclick="addTextBlock(\${secIdx})"><i class="fa fa-align-left text-primary mr-1"></i> + Thêm Nội Dung Chính (Ô Text Mới)</button>
                <button type="button" class="btn-add-block" onclick="addTableBlock(\${secIdx})"><i class="fa fa-table text-warning mr-1"></i> + Thêm Bảng Table</button>
                <button type="button" class="btn-add-block" onclick="addCalloutBlock(\${secIdx})"><i class="fa fa-info-circle text-info mr-1"></i> + Thêm Chú Thích</button>
            </div>
            <input type="hidden" name="sectionBlocksJson" class="input-section-blocks" value="">
        `;
        container.appendChild(div);
        reOrderSections();
        addTextBlock(secIdx);
        div.scrollIntoView({ behavior: 'smooth' });
    }

    function packSectionBlocks() {
        var cards = document.querySelectorAll('.section-card');
        cards.forEach(function(card) {
            var container = card.querySelector('.blocks-container');
            var blockItems = container.querySelectorAll('.block-item');
            var blocksData = [];

            blockItems.forEach(function(item) {
                var type = item.dataset.type;
                if (type === 'text') {
                    var val = item.querySelector('.block-val-text').value.trim();
                    if (val) blocksData.push({ type: 'text', text: val });
                } else if (type === 'callout') {
                    var cText = item.querySelector('.block-val-callout-text').value.trim();
                    var cType = item.querySelector('.block-val-callout-type').value;
                    if (cText) blocksData.push({ type: 'callout', text: cText, calloutType: cType });
                } else if (type === 'table') {
                    var title = item.querySelector('.block-val-tbl-title').value.trim();
                    var headers = [];
                    item.querySelectorAll('.tbl-header-input').forEach(function(inp) { headers.push(inp.value.trim()); });
                    var rows = [];
                    item.querySelectorAll('.body-rows tr').forEach(function(tr) {
                        var r = [];
                        tr.querySelectorAll('.tbl-cell-input').forEach(function(inp) { r.push(inp.value.trim()); });
                        rows.push(r);
                    });
                    if (headers.length > 0) {
                        blocksData.push({ type: 'table', title: title, headers: headers, rows: rows });
                    }
                }
            });

            card.querySelector('.input-section-blocks').value = JSON.stringify(blocksData);
        });
    }

    function validateForm() {
        packSectionBlocks();
        var titles = document.querySelectorAll('.req-title');
        var cards = document.querySelectorAll('.section-card');

        for (var i = 0; i < titles.length; i++) {
            if (!titles[i].value.trim()) {
                alert("Mục thứ " + (i + 1) + " chưa nhập Tiêu đề! Vui lòng không để trống.");
                titles[i].focus();
                return false;
            }
            var blocksJson = cards[i].querySelector('.input-section-blocks').value;
            if (!blocksJson || blocksJson === '[]') {
                alert("Mục \"" + titles[i].value + "\" chưa có bất kỳ khối nội dung nào! Hãy bấm \"+ Thêm Nội Dung Chính\" hoặc bảng/chú thích.");
                return false;
            }
        }
        return true;
    }

    function escapeHtml(text) {
        if (!text) return '';
        return String(text).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
    }

    // TỰ ĐỘNG KHÔI PHỤC VÀ HIỂN THỊ TOÀN BỘ NỘI DUNG TỪ DATABASE KHI MỞ TRANG
    window.onload = function() {
        document.querySelectorAll('.section-card').forEach(function(card, secIdx) {
            var rawText = card.querySelector('.raw-db-content').value;
            var rawTable = card.querySelector('.raw-db-table').value;
            var rawCallout = card.querySelector('.raw-db-callout').value;
            var rawCalloutType = card.querySelector('.raw-db-callout-type').value;

            // Nếu dữ liệu đã là mảng các khối JSON
            if (rawText && rawText.trim().startsWith('[')) {
                try {
                    var parsedBlocks = JSON.parse(rawText);
                    parsedBlocks.forEach(function(b) {
                        if (b.type === 'text') addTextBlock(secIdx, b.text);
                        else if (b.type === 'callout') addCalloutBlock(secIdx, b.text, b.calloutType);
                        else if (b.type === 'table') addTableBlock(secIdx, b);
                    });
                } catch(e) {}
            } else {
                // Khởi tạo hiển thị dữ liệu gốc của Sogo Homestay
                if (rawText && rawText.trim()) {
                    addTextBlock(secIdx, rawText);
                }
                if (rawTable && rawTable !== '[]' && rawTable.trim()) {
                    try {
                        var parsedTbl = JSON.parse(rawTable);
                        addTableBlock(secIdx, Array.isArray(parsedTbl) ? { title: "Bảng Chính Sách Hoàn Tiền", headers: ["Thời Gian Thông Báo Hủy", "Chính Sách Hoàn Cọc"], rows: parsedTbl.map(function(r){return [r.col1||'', r.col2||''];}) } : parsedTbl);
                    } catch(e) {}
                }
                if (rawCallout && rawCallout.trim()) {
                    addCalloutBlock(secIdx, rawCallout, rawCalloutType);
                }
            }
        });
    };
</script>