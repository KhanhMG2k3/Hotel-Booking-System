<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="../common/header.jsp">
    <jsp:param name="pageTitle" value="Quản Lý Hoàn Tiền - Host Sogo Homestay" />
</jsp:include>

<jsp:include page="../common/navbar.jsp" />

<style>
    .site-header {
        position: fixed !important;
        background: #ffffff !important;
        padding: 16px 0 !important;
        box-shadow: 0 2px 12px rgba(0,0,0,0.06) !important;
        z-index: 1000 !important;
    }
    .site-header .site-logo a,
    .site-logo a {
        color: #1a1a1a !important;
    }
    .site-header .user-name {
        color: #1a1a1a !important;
    }
    .site-header .user-caret {
        color: #64748b !important;
    }
    .site-header .user-menu-toggle {
        background: #f8fafc !important;
        border: 1px solid #e2e8f0 !important;
    }
    .site-header .site-menu-toggle span {
        background: #1a1a1a !important;
    }
    .host-refund-page { padding-top: 100px; padding-bottom: 80px; background: #f2f4fb; min-height: 85vh; }
    .host-page-title {
        font-family: "Playfair Display", serif;
        font-weight: 700;
        color: #1a1a1a;
        margin-bottom: 0.25rem;
    }
    .stat-card {
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 2px 12px rgba(0,0,0,.06);
        border: 1px solid rgba(0,0,0,.04);
        padding: 1.25rem 1.5rem;
        height: 100%;
        transition: transform .2s ease;
    }
    .stat-card:hover {
        transform: translateY(-2px);
    }
    .stat-card.wallet-card {
        background: linear-gradient(135deg, #ffffff 0%, #f0fdf4 100%);
        border: 1.5px solid #86efac;
    }
    .stat-label { font-size: .8rem; color: #6c757d; text-transform: uppercase; letter-spacing: .04em; margin-bottom: .35rem; }
    .stat-value { font-family: "Playfair Display", serif; font-size: 1.6rem; font-weight: 700; color: #1a1a1a; line-height: 1.2; }
    .stat-icon {
        width: 44px; height: 44px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center;
        font-size: 1.15rem;
    }
    .stat-icon-wallet { background: #dcfce7; color: #15803d; }
    .stat-icon-warning { background: rgba(245, 158, 11, 0.15); color: #d97706; }
    .stat-icon-success { background: rgba(34, 197, 94, 0.15); color: #15803d; }
    .stat-icon-info { background: rgba(59, 130, 246, 0.15); color: #2563eb; }
    .stat-icon-danger { background: rgba(239, 68, 68, 0.15); color: #b91c1c; }

    .refund-table-card {
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 2px 12px rgba(0,0,0,.06);
        border: 1px solid rgba(0,0,0,.04);
        overflow: hidden;
    }
    .refund-filter-tabs {
        display: flex;
        gap: 8px;
        padding: 1rem 1.5rem;
        border-bottom: 1px solid #eef2f6;
        background: #fff;
        flex-wrap: wrap;
    }
    .filter-tab-btn {
        padding: 6px 16px;
        border-radius: 50px;
        font-size: 13px;
        font-weight: 600;
        text-decoration: none;
        color: #64748b;
        background: #f1f5f9;
        transition: all 0.2s;
    }
    .filter-tab-btn:hover { background: #e2e8f0; color: #0f172a; text-decoration: none; }
    .filter-tab-btn.active { background: #ffba5a; color: #fff; }
    
    .table-refunds th {
        background: #f8fafc;
        color: #475569;
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: .03em;
        font-weight: 700;
        border-top: none;
        padding: 14px 16px;
    }
    .table-refunds td {
        padding: 16px;
        vertical-align: middle;
        font-size: 13.5px;
        border-top: 1px solid #f1f5f9;
    }
    .badge-refund {
        padding: 5px 12px;
        border-radius: 20px;
        font-size: 11.5px;
        font-weight: 700;
        text-transform: uppercase;
    }
    .badge-refund-requested { background: #fef3c7; color: #b45309; }
    .badge-refund-approved { background: #dcfce7; color: #15803d; }
    .badge-refund-rejected { background: #fee2e2; color: #b91c1c; }
    .badge-tx-credit { background: #dcfce7; color: #15803d; font-weight: 600; }
    .badge-tx-debit { background: #fee2e2; color: #b91c1c; font-weight: 600; }
    .badge-tx-topup { background: #e0f2fe; color: #0369a1; font-weight: 600; }

    /* ==========================================================================
       DARK MODE OVERRIDES (Host Refunds & Wallet Ledger)
       ========================================================================== */
    [data-theme="dark"] .site-header,
    html.dark-mode .site-header,
    body.dark-mode .site-header {
        position: fixed !important;
        background: #0f172a !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4) !important;
        border-bottom: 1px solid #1e293b !important;
    }
    [data-theme="dark"] .site-header .site-logo a,
    html.dark-mode .site-header .site-logo a,
    [data-theme="dark"] .site-logo a,
    html.dark-mode .site-logo a {
        color: #f8fafc !important;
    }
    [data-theme="dark"] .site-header .user-name,
    html.dark-mode .site-header .user-name {
        color: #f8fafc !important;
    }
    [data-theme="dark"] .site-header .user-caret,
    html.dark-mode .site-header .user-caret {
        color: #94a3b8 !important;
    }
    [data-theme="dark"] .site-header .user-menu-toggle,
    html.dark-mode .site-header .user-menu-toggle {
        background: rgba(255, 255, 255, 0.08) !important;
        border: 1px solid rgba(255, 255, 255, 0.15) !important;
    }
    [data-theme="dark"] .site-header .site-menu-toggle span,
    html.dark-mode .site-header .site-menu-toggle span {
        background: #f8fafc !important;
    }

    /* Page Background & Typography */
    [data-theme="dark"] .host-refund-page,
    html.dark-mode .host-refund-page,
    body.dark-mode .host-refund-page {
        background: #0b0f19 !important;
        color: #cbd5e1 !important;
    }
    [data-theme="dark"] .host-page-title,
    html.dark-mode .host-page-title,
    body.dark-mode .host-page-title {
        color: #f8fafc !important;
    }
    [data-theme="dark"] .host-refund-page .text-muted,
    html.dark-mode .host-refund-page .text-muted,
    body.dark-mode .host-refund-page .text-muted {
        color: #94a3b8 !important;
    }
    [data-theme="dark"] .host-refund-page a.text-muted:hover,
    html.dark-mode .host-refund-page a.text-muted:hover {
        color: #ffba5a !important;
    }

    /* Top Action Buttons */
    [data-theme="dark"] .host-refund-page .btn-outline-success,
    html.dark-mode .host-refund-page .btn-outline-success {
        border-color: #10b981 !important;
        color: #34d399 !important;
        background: rgba(16, 185, 129, 0.12) !important;
    }
    [data-theme="dark"] .host-refund-page .btn-outline-success:hover,
    html.dark-mode .host-refund-page .btn-outline-success:hover {
        background: #10b981 !important;
        color: #0f172a !important;
    }
    [data-theme="dark"] .host-refund-page .btn-outline-secondary,
    html.dark-mode .host-refund-page .btn-outline-secondary {
        border-color: #334155 !important;
        color: #cbd5e1 !important;
        background: #1e293b !important;
    }
    [data-theme="dark"] .host-refund-page .btn-outline-secondary:hover,
    html.dark-mode .host-refund-page .btn-outline-secondary:hover {
        background: #334155 !important;
        color: #f8fafc !important;
    }

    /* Stat Cards */
    [data-theme="dark"] .stat-card,
    html.dark-mode .stat-card,
    body.dark-mode .stat-card {
        background: #162032 !important;
        border: 1px solid #243247 !important;
        box-shadow: 0 4px 18px rgba(0, 0, 0, 0.35) !important;
        color: #cbd5e1 !important;
    }
    [data-theme="dark"] .stat-card:hover,
    html.dark-mode .stat-card:hover {
        background: #1c2a42 !important;
        transform: translateY(-2px);
    }
    [data-theme="dark"] .stat-card .stat-label,
    html.dark-mode .stat-card .stat-label {
        color: #94a3b8 !important;
    }
    [data-theme="dark"] .stat-card .stat-value,
    html.dark-mode .stat-card .stat-value {
        color: #f8fafc !important;
    }
    [data-theme="dark"] .stat-card.wallet-card,
    html.dark-mode .stat-card.wallet-card {
        background: linear-gradient(135deg, #162032 0%, #064e3b 100%) !important;
        border: 1.5px solid #059669 !important;
        box-shadow: 0 4px 20px rgba(5, 150, 105, 0.25) !important;
    }
    [data-theme="dark"] .stat-card.wallet-card .stat-label,
    html.dark-mode .stat-card.wallet-card .stat-label {
        color: #34d399 !important;
    }
    [data-theme="dark"] .stat-card.wallet-card .stat-value,
    html.dark-mode .stat-card.wallet-card .stat-value {
        color: #4ade80 !important;
    }
    [data-theme="dark"] .stat-card .border-top,
    html.dark-mode .stat-card .border-top {
        border-color: #243247 !important;
    }
    [data-theme="dark"] .stat-icon-wallet,
    html.dark-mode .stat-icon-wallet {
        background: rgba(16, 185, 129, 0.2) !important;
        color: #34d399 !important;
    }
    [data-theme="dark"] .stat-icon-warning,
    html.dark-mode .stat-icon-warning {
        background: rgba(245, 158, 11, 0.2) !important;
        color: #fbbf24 !important;
    }
    [data-theme="dark"] .stat-icon-success,
    html.dark-mode .stat-icon-success {
        background: rgba(34, 197, 94, 0.2) !important;
        color: #4ade80 !important;
    }
    [data-theme="dark"] .stat-icon-danger,
    html.dark-mode .stat-icon-danger {
        background: rgba(239, 68, 68, 0.2) !important;
        color: #f87171 !important;
    }

    /* Refund Table Card & Filter Tabs */
    [data-theme="dark"] .refund-table-card,
    html.dark-mode .refund-table-card {
        background: #162032 !important;
        border: 1px solid #243247 !important;
        box-shadow: 0 4px 18px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .refund-filter-tabs,
    html.dark-mode .refund-filter-tabs {
        background: #111827 !important;
        border-bottom: 1px solid #243247 !important;
    }
    [data-theme="dark"] .filter-tab-btn,
    html.dark-mode .filter-tab-btn {
        background: #1e293b !important;
        color: #94a3b8 !important;
        border: 1px solid #334155 !important;
    }
    [data-theme="dark"] .filter-tab-btn:hover,
    html.dark-mode .filter-tab-btn:hover {
        background: #334155 !important;
        color: #f8fafc !important;
    }
    [data-theme="dark"] .filter-tab-btn.active,
    html.dark-mode .filter-tab-btn.active {
        background: #ffba5a !important;
        color: #0f172a !important;
        border-color: #ffba5a !important;
    }
    [data-theme="dark"] .refund-filter-tabs .form-control,
    html.dark-mode .refund-filter-tabs .form-control {
        background: #0b0f19 !important;
        border-color: #334155 !important;
        color: #f8fafc !important;
    }
    [data-theme="dark"] .refund-filter-tabs .form-control:focus,
    html.dark-mode .refund-filter-tabs .form-control:focus {
        border-color: #ffba5a !important;
        box-shadow: 0 0 0 0.2rem rgba(255, 186, 90, 0.25) !important;
    }
    [data-theme="dark"] .refund-filter-tabs .btn-dark,
    html.dark-mode .refund-filter-tabs .btn-dark {
        background: #334155 !important;
        border-color: #334155 !important;
        color: #f8fafc !important;
    }
    [data-theme="dark"] .refund-filter-tabs .btn-dark:hover,
    html.dark-mode .refund-filter-tabs .btn-dark:hover {
        background: #475569 !important;
        border-color: #475569 !important;
    }

    /* Table Refunds */
    [data-theme="dark"] .table-refunds,
    html.dark-mode .table-refunds {
        background: transparent !important;
        color: #cbd5e1 !important;
    }
    [data-theme="dark"] .table-refunds thead th,
    html.dark-mode .table-refunds thead th {
        background: #111827 !important;
        color: #94a3b8 !important;
        border-bottom: 2px solid #243247 !important;
        border-top: none !important;
    }
    [data-theme="dark"] .table-refunds tbody tr,
    html.dark-mode .table-refunds tbody tr {
        background: #162032 !important;
        border-bottom: 1px solid #243247 !important;
    }
    [data-theme="dark"] .table-refunds tbody tr:hover td,
    html.dark-mode .table-refunds tbody tr:hover td {
        background: #1c2a42 !important;
    }
    [data-theme="dark"] .table-refunds td,
    html.dark-mode .table-refunds td {
        background: transparent !important;
        color: #cbd5e1 !important;
        border-top: 1px solid #243247 !important;
    }
    [data-theme="dark"] .table-refunds .text-dark,
    html.dark-mode .table-refunds .text-dark {
        color: #f8fafc !important;
    }
    [data-theme="dark"] .table-refunds .text-secondary,
    html.dark-mode .table-refunds .text-secondary {
        color: #94a3b8 !important;
    }
    [data-theme="dark"] .table-refunds .badge-light,
    html.dark-mode .table-refunds .badge-light {
        background: #1e293b !important;
        border-color: #334155 !important;
        color: #f8fafc !important;
    }
    [data-theme="dark"] .table-refunds .fa-folder-open-o,
    html.dark-mode .table-refunds .fa-folder-open-o {
        color: #475569 !important;
    }

    /* Status Badges */
    [data-theme="dark"] .badge-refund-requested,
    html.dark-mode .badge-refund-requested {
        background: rgba(245, 158, 11, 0.2) !important;
        color: #fbbf24 !important;
        border: 1px solid rgba(245, 158, 11, 0.35) !important;
    }
    [data-theme="dark"] .badge-refund-approved,
    html.dark-mode .badge-refund-approved {
        background: rgba(34, 197, 94, 0.2) !important;
        color: #4ade80 !important;
        border: 1px solid rgba(34, 197, 94, 0.35) !important;
    }
    [data-theme="dark"] .badge-refund-rejected,
    html.dark-mode .badge-refund-rejected {
        background: rgba(239, 68, 68, 0.2) !important;
        color: #f87171 !important;
        border: 1px solid rgba(239, 68, 68, 0.35) !important;
    }
    [data-theme="dark"] .badge-tx-credit,
    html.dark-mode .badge-tx-credit {
        background: rgba(34, 197, 94, 0.2) !important;
        color: #4ade80 !important;
    }
    [data-theme="dark"] .badge-tx-debit,
    html.dark-mode .badge-tx-debit {
        background: rgba(239, 68, 68, 0.2) !important;
        color: #f87171 !important;
    }
    [data-theme="dark"] .badge-tx-topup,
    html.dark-mode .badge-tx-topup {
        background: rgba(14, 165, 233, 0.2) !important;
        color: #38bdf8 !important;
    }

    /* Ledger Card (Model 2 Wallet Transactions) */
    [data-theme="dark"] .card.rounded-12,
    html.dark-mode .card.rounded-12 {
        background: #162032 !important;
        border: 1px solid #243247 !important;
        box-shadow: 0 4px 18px rgba(0, 0, 0, 0.35) !important;
    }
    [data-theme="dark"] .card.rounded-12 .card-header,
    html.dark-mode .card.rounded-12 .card-header {
        background: #111827 !important;
        border-bottom: 1px solid #243247 !important;
    }
    [data-theme="dark"] .card.rounded-12 .card-header h5,
    html.dark-mode .card.rounded-12 .card-header h5 {
        color: #f8fafc !important;
    }
    [data-theme="dark"] .card.rounded-12 .table,
    html.dark-mode .card.rounded-12 .table {
        background: transparent !important;
        color: #cbd5e1 !important;
    }
    [data-theme="dark"] .card.rounded-12 .thead-light th,
    html.dark-mode .card.rounded-12 .thead-light th {
        background: #111827 !important;
        color: #94a3b8 !important;
        border-color: #243247 !important;
    }
    [data-theme="dark"] .card.rounded-12 .table td,
    html.dark-mode .card.rounded-12 .table td {
        background: transparent !important;
        color: #cbd5e1 !important;
        border-color: #243247 !important;
    }
    [data-theme="dark"] .card.rounded-12 .table tr:hover td,
    html.dark-mode .card.rounded-12 .table tr:hover td {
        background: #1c2a42 !important;
    }
    [data-theme="dark"] .card.rounded-12 .text-dark,
    html.dark-mode .card.rounded-12 .text-dark {
        color: #f8fafc !important;
    }

    /* Modals */
    [data-theme="dark"] .modal-content,
    html.dark-mode .modal-content {
        background: #162032 !important;
        border: 1px solid #243247 !important;
        color: #cbd5e1 !important;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.6) !important;
    }
    [data-theme="dark"] .modal-body,
    html.dark-mode .modal-body {
        background: #162032 !important;
        color: #cbd5e1 !important;
    }
    [data-theme="dark"] .modal-footer.bg-light,
    html.dark-mode .modal-footer.bg-light {
        background: #111827 !important;
        border-top: 1px solid #243247 !important;
    }
    [data-theme="dark"] .modal-body .bg-light,
    html.dark-mode .modal-body .bg-light {
        background: #111827 !important;
        border-color: #243247 !important;
    }
    [data-theme="dark"] .modal-body .bg-white,
    html.dark-mode .modal-body .bg-white {
        background: #1a273f !important;
        border-color: #243247 !important;
        color: #f8fafc !important;
    }
    [data-theme="dark"] .modal-body .border,
    html.dark-mode .modal-body .border,
    [data-theme="dark"] .modal-body .border-top,
    html.dark-mode .modal-body .border-top {
        border-color: #243247 !important;
    }
    [data-theme="dark"] .modal-body strong.text-dark,
    html.dark-mode .modal-body strong.text-dark,
    [data-theme="dark"] .modal-body label.text-dark,
    html.dark-mode .modal-body label.text-dark {
        color: #f8fafc !important;
    }
    [data-theme="dark"] .modal-body .form-control,
    html.dark-mode .modal-body .form-control {
        background: #0b0f19 !important;
        border-color: #334155 !important;
        color: #f8fafc !important;
    }
    [data-theme="dark"] .modal-body .form-control:focus,
    html.dark-mode .modal-body .form-control:focus {
        border-color: #ffba5a !important;
        box-shadow: 0 0 0 0.2rem rgba(255, 186, 90, 0.25) !important;
    }
    [data-theme="dark"] .modal-body .btn-outline-secondary,
    html.dark-mode .modal-body .btn-outline-secondary {
        border-color: #334155 !important;
        color: #cbd5e1 !important;
        background: #1e293b !important;
    }
    [data-theme="dark"] .modal-body .btn-outline-secondary:hover,
    html.dark-mode .modal-body .btn-outline-secondary:hover {
        background: #334155 !important;
        color: #f8fafc !important;
    }
    [data-theme="dark"] #approveBankInfo,
    html.dark-mode #approveBankInfo {
        background: #1a273f !important;
        color: #f8fafc !important;
        border-color: #243247 !important;
    }
    [data-theme="dark"] #refundVietQrSection,
    html.dark-mode #refundVietQrSection {
        background: #111827 !important;
        border-color: #243247 !important;
    }
    [data-theme="dark"] #refundVietQrSection .font-weight-bold.text-dark,
    html.dark-mode #refundVietQrSection .font-weight-bold.text-dark {
        color: #f8fafc !important;
    }
    [data-theme="dark"] #refundVietQrImg,
    html.dark-mode #refundVietQrImg {
        background: #ffffff !important;
        padding: 6px;
    }

</style>

<div class="host-refund-page">
    <div class="container">
        <!-- Top bar with breadcrumbs and actions -->
        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap">
            <div>
                <a href="${pageContext.request.contextPath}/host/dashboard" class="text-muted" style="font-size: 13px;">
                    <i class="fa fa-arrow-left mr-1"></i> Quay lại Host Dashboard
                </a>
                <h2 class="host-page-title mt-1">Quản Lý Yêu Cầu Hoàn Tiền</h2>
                <p class="text-muted mb-0" style="font-size: 14px;">
                    Xem xét và xử lý các yêu cầu hủy đặt phòng và hoàn tiền từ khách hàng cho các cơ sở của bạn.
                </p>
            </div>
            <div class="mt-3 mt-md-0 d-flex flex-wrap gap-2">
                <button type="button" class="btn btn-outline-success rounded-pill px-3 mr-2 font-weight-bold" onclick="openTopupModal()">
                    <i class="fa fa-plus-circle mr-1"></i> Nạp tiền vào Ví
                </button>
                <a href="${pageContext.request.contextPath}/host/dashboard" class="btn btn-outline-secondary rounded-pill px-3 mr-2">
                    <i class="fa fa-dashboard mr-1"></i> Dashboard
                </a>
                <a href="${pageContext.request.contextPath}/host/property/create" class="btn btn-warning rounded-pill px-3 font-weight-bold text-white" style="background: #ffba5a; border-color: #ffba5a;">
                    <i class="fa fa-plus mr-1"></i> Thêm Homestay
                </a>
            </div>
        </div>

        <!-- Notification alerts -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show shadow-sm mb-4" role="alert">
                <i class="fa fa-check-circle mr-2"></i> ${successMessage}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show shadow-sm mb-4" role="alert">
                <i class="fa fa-exclamation-circle mr-2"></i> ${errorMessage}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </c:if>

        <!-- KPI Statistic Cards (Model 2: Including Host Wallet Balance) -->
        <div class="row mb-4">
            <!-- SỐ DƯ VÍ KHẢ DỤNG -->
            <div class="col-12 col-md-4 col-lg-3 mb-3">
                <div class="stat-card wallet-card">
                    <div class="d-flex justify-content-between align-items-center mb-1">
                        <div>
                            <div class="stat-label text-success font-weight-bold">
                                <i class="fa fa-shield mr-1"></i> Số dư ví Host
                            </div>
                            <div class="stat-value text-success" id="displayHostBalance">
                                <fmt:formatNumber value="${hostBalance}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                            </div>
                        </div>
                        <div class="stat-icon stat-icon-wallet">
                            <i class="fa fa-credit-card"></i>
                        </div>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mt-2 pt-2 border-top">
                        <small class="text-muted" style="font-size: 11.5px;">Ví ký quỹ hoàn tiền</small>
                        <button type="button" class="btn btn-xs btn-sm btn-link text-success p-0 font-weight-bold" onclick="openTopupModal()">
                            + Nạp thêm ví
                        </button>
                    </div>
                </div>
            </div>

            <div class="col-6 col-md-4 col-lg-2 mb-3">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <div class="stat-label">Chờ xử lý</div>
                            <div class="stat-value text-warning">${stats.pendingCount}</div>
                            <small class="text-muted" style="font-size: 11px;">Cần Host duyệt</small>
                        </div>
                        <div class="stat-icon stat-icon-warning">
                            <i class="fa fa-clock-o"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-6 col-md-4 col-lg-2 mb-3">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <div class="stat-label">Đã duyệt hoàn</div>
                            <div class="stat-value text-success">${stats.approvedCount}</div>
                            <small class="text-muted" style="font-size: 11px;">Đã hoàn thành</small>
                        </div>
                        <div class="stat-icon stat-icon-success">
                            <i class="fa fa-check-circle-o"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-6 col-md-4 col-lg-2 mb-3">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <div class="stat-label">Đã từ chối</div>
                            <div class="stat-value text-danger">${stats.rejectedCount}</div>
                            <small class="text-muted" style="font-size: 11px;">Không hợp lệ</small>
                        </div>
                        <div class="stat-icon stat-icon-danger">
                            <i class="fa fa-times-circle-o"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-6 col-md-4 col-lg-3 mb-3">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <div class="stat-label">Tổng tiền hoàn trả</div>
                            <div class="stat-value text-danger" style="font-size: 1.35rem;">
                                <fmt:formatNumber value="${stats.totalRefundedAmount}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                            </div>
                            <small class="text-muted" style="font-size: 11px;">Trừ trực tiếp từ ví Host</small>
                        </div>
                        <div class="stat-icon stat-icon-danger">
                            <i class="fa fa-money"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Table Card -->
        <div class="refund-table-card mb-4">
            <!-- Filter Tabs & Search -->
            <div class="refund-filter-tabs d-flex justify-content-between align-items-center">
                <div class="d-flex gap-2 flex-wrap">
                    <a href="${pageContext.request.contextPath}/host/refunds?status=ALL"
                       class="filter-tab-btn ${currentFilter == 'ALL' ? 'active' : ''}">Tất cả</a>
                    <a href="${pageContext.request.contextPath}/host/refunds?status=REQUESTED"
                       class="filter-tab-btn ${currentFilter == 'REQUESTED' ? 'active' : ''}">Chờ xử lý (${stats.pendingCount})</a>
                    <a href="${pageContext.request.contextPath}/host/refunds?status=APPROVED"
                       class="filter-tab-btn ${currentFilter == 'APPROVED' ? 'active' : ''}">Đã phê duyệt (${stats.approvedCount})</a>
                    <a href="${pageContext.request.contextPath}/host/refunds?status=REJECTED"
                       class="filter-tab-btn ${currentFilter == 'REJECTED' ? 'active' : ''}">Đã từ chối (${stats.rejectedCount})</a>
                </div>
                <div class="mt-2 mt-md-0">
                    <form action="${pageContext.request.contextPath}/host/refunds" method="get" class="d-flex">
                        <input type="hidden" name="status" value="${currentFilter}" />
                        <input type="text" name="q" value="${searchKeyword}" placeholder="Tìm theo mã đơn, khách hàng..."
                               class="form-control form-control-sm rounded-left" style="width: 240px;" />
                        <button type="submit" class="btn btn-sm btn-dark rounded-right px-3">
                            <i class="fa fa-search"></i>
                        </button>
                    </form>
                </div>
            </div>

            <!-- Refunds Data Table -->
            <div class="table-responsive">
                <table class="table table-hover table-refunds mb-0">
                    <thead>
                        <tr>
                            <th>Mã đơn / Homestay</th>
                            <th>Khách hàng</th>
                            <th>Số tiền hoàn</th>
                            <th>TK Ngân hàng nhận tiền</th>
                            <th>Lý do hủy</th>
                            <th>Trạng thái</th>
                            <th>Thời gian</th>
                            <th class="text-right">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty refunds}">
                                <tr>
                                    <td colspan="8" class="text-center py-5 text-muted">
                                        <i class="fa fa-folder-open-o fa-3x mb-3 text-secondary d-block"></i>
                                        Không tìm thấy yêu cầu hoàn tiền nào phù hợp với bộ lọc hiện tại.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="refund" items="${refunds}">
                                    <tr>
                                        <td>
                                            <div class="font-weight-bold text-dark font-monospace">${refund.bookingCode}</div>
                                            <div class="text-muted" style="font-size: 12px;">${refund.propertyName}</div>
                                            <small class="text-secondary">${refund.roomName}</small>
                                        </td>
                                        <td>
                                            <div class="font-weight-bold text-dark">${refund.customerName}</div>
                                            <div class="text-muted" style="font-size: 12px;">${refund.customerEmail}</div>
                                            <small class="text-muted">${refund.customerPhone}</small>
                                        </td>
                                        <td>
                                            <div class="font-weight-bold text-danger" style="font-size: 15px;">
                                                <fmt:formatNumber value="${refund.amount}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                                            </div>
                                            <small class="text-muted">Hoàn tiền 100%</small>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty refund.customerBankInfo}">
                                                    <span class="badge badge-light border text-dark font-monospace p-2">
                                                        <i class="fa fa-bank text-primary mr-1"></i> ${refund.customerBankInfo}
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted font-italic" style="font-size: 12px;">Chưa cung cấp</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span title="${refund.reason}" style="max-width: 180px; display: inline-block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                                ${refund.reason}
                                            </span>
                                            <c:if test="${not empty refund.hostNote}">
                                                <div class="text-info font-italic mt-1" style="font-size: 11.5px;">
                                                    <i class="fa fa-comment-o mr-1"></i>Host: ${refund.hostNote}
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${refund.status == 'REQUESTED'}">
                                                    <span class="badge-refund badge-refund-requested">Chờ xử lý</span>
                                                </c:when>
                                                <c:when test="${refund.status == 'APPROVED' or refund.status == 'SUCCEEDED'}">
                                                    <span class="badge-refund badge-refund-approved">Đã hoàn tiền</span>
                                                </c:when>
                                                <c:when test="${refund.status == 'REJECTED'}">
                                                    <span class="badge-refund badge-refund-rejected">Đã từ chối</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-secondary">${refund.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-muted" style="font-size: 12px;">
                                            <fmt:formatDate value="${refund.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                        </td>
                                        <td class="text-right">
                                            <c:if test="${refund.status == 'REQUESTED'}">
                                                <div class="btn-group" role="group">
                                                    <button type="button" class="btn btn-sm btn-success font-weight-bold px-3 rounded mr-1"
                                                            onclick="openApproveModal(${refund.refundId}, '${refund.bookingCode}', ${refund.amount}, '${fn:escapeXml(refund.customerBankInfo)}', '${fn:escapeXml(refund.customerName)}')">
                                                        <i class="fa fa-check mr-1"></i> Duyệt
                                                    </button>
                                                    <button type="button" class="btn btn-sm btn-outline-danger font-weight-bold px-3 rounded"
                                                            onclick="openRejectModal(${refund.refundId}, '${refund.bookingCode}')">
                                                        <i class="fa fa-times mr-1"></i> Từ chối
                                                    </button>
                                                </div>
                                            </c:if>
                                            <c:if test="${refund.status != 'REQUESTED'}">
                                                <span class="text-muted" style="font-size: 12px;">Đã xử lý</span>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Wallet Transaction Ledger Card (Model 2) -->
        <div class="card border-0 shadow-sm rounded-12" style="border-radius: 12px; overflow: hidden;">
            <div class="card-header bg-white border-bottom py-3 d-flex justify-content-between align-items-center">
                <div>
                    <h5 class="font-weight-bold mb-0 text-dark">
                        <i class="fa fa-book text-success mr-2"></i>Sổ cái Lịch sử biến động Ví Host (Model 2)
                    </h5>
                    <small class="text-muted">Theo dõi minh bạch mọi dòng tiền cộng doanh thu phòng và trừ tiền khi duyệt hoàn</small>
                </div>
                <button type="button" class="btn btn-sm btn-outline-success font-weight-bold" onclick="openTopupModal()">
                    <i class="fa fa-plus-circle mr-1"></i> Nạp tiền ví
                </button>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0" style="font-size: 13.5px;">
                        <thead class="thead-light">
                            <tr>
                                <th>Thời gian</th>
                                <th>Mã GD</th>
                                <th>Loại giao dịch</th>
                                <th>Số tiền biến động</th>
                                <th>Số dư trước GD</th>
                                <th>Số dư sau GD</th>
                                <th>Nội dung diễn giải</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty walletTransactions}">
                                    <tr>
                                        <td colspan="7" class="text-center py-4 text-muted">
                                            Chưa có biến động số dư nào trong ví Host.
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="tx" items="${walletTransactions}">
                                        <tr>
                                            <td class="text-muted text-nowrap">
                                                <fmt:formatDate value="${tx.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                            </td>
                                            <td class="font-monospace text-muted">#TX-${tx.transactionId}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${tx.transactionType == 'CREDIT_BOOKING'}">
                                                        <span class="badge badge-tx-credit px-2 py-1">Doanh thu phòng</span>
                                                    </c:when>
                                                    <c:when test="${tx.transactionType == 'DEBIT_REFUND'}">
                                                        <span class="badge badge-tx-debit px-2 py-1">Hoàn tiền khách</span>
                                                    </c:when>
                                                    <c:when test="${tx.transactionType == 'DEBIT_WITHDRAWAL'}">
                                                        <span class="badge badge-info px-2 py-1">Rút về ngân hàng</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-tx-topup px-2 py-1">Nạp tiền ký quỹ</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="font-weight-bold">
                                                <c:choose>
                                                    <c:when test="${tx.transactionType == 'DEBIT_REFUND' or tx.transactionType == 'DEBIT_WITHDRAWAL'}">
                                                        <span class="text-danger">-<fmt:formatNumber value="${tx.amount}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/></span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-success">+<fmt:formatNumber value="${tx.amount}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/></span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-muted">
                                                <fmt:formatNumber value="${tx.balanceBefore}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                                            </td>
                                            <td class="font-weight-bold text-dark">
                                                <fmt:formatNumber value="${tx.balanceAfter}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                                            </td>
                                            <td><c:out value="${tx.description}"/></td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>
</div>

<!-- ========================================== -->
<!-- MODAL APPROVE REFUND (WITH WALLET CHECK)   -->
<!-- ========================================== -->
<div class="modal fade" id="approveModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px; overflow: hidden;">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title font-weight-bold">
                    <i class="fa fa-check-circle mr-2"></i>Duyệt Hoàn Tiền Từ Ví Host (Model 2)
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <form action="${pageContext.request.contextPath}/host/refunds/action" method="post" id="approveRefundForm">
                <input type="hidden" name="refundId" id="approveRefundId" />
                <input type="hidden" name="action" value="approve" />
                <div class="modal-body p-4">
                    <p class="text-muted mb-3" style="font-size: 13.5px;">
                        Bạn đang phê duyệt yêu cầu hoàn tiền cho đơn đặt phòng <strong id="approveBookingCode" class="text-dark"></strong> của khách hàng <strong id="approveCustomerName" class="text-dark"></strong>.
                    </p>

                    <!-- Wallet & Balance Check Box -->
                    <div class="p-3 bg-light rounded mb-3 border">
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">Số tiền cần hoàn:</span>
                            <span id="approveAmount" class="font-weight-bold text-danger" style="font-size: 18px;"></span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">Số dư ví Host hiện tại:</span>
                            <span id="approveHostBal" class="font-weight-bold text-success" style="font-size: 15px;">
                                <fmt:formatNumber value="${hostBalance}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="d-flex justify-content-between mb-2 pt-2 border-top">
                            <span class="text-muted">Số dư sau khi trừ hoàn tiền:</span>
                            <span id="approveHostBalAfter" class="font-weight-bold" style="font-size: 15px;"></span>
                        </div>

                        <!-- Wallet Status Banner -->
                        <div id="walletSufficientAlert" class="alert alert-success py-2 px-3 mb-0 mt-3 small" style="display: none;">
                            <i class="fa fa-check-circle mr-1"></i> Số dư ví đủ để hoàn tiền. Tiền sẽ được trừ trực tiếp từ Ví Host của bạn.
                        </div>
                        <div id="walletInsufficientAlert" class="alert alert-danger py-2 px-3 mb-0 mt-3 small" style="display: none;">
                            <i class="fa fa-exclamation-triangle mr-1"></i> Số dư ví không đủ để hoàn tiền! Vui lòng nạp thêm tiền vào ví.
                            <div class="mt-2 text-right">
                                <button type="button" class="btn btn-xs btn-sm btn-danger font-weight-bold" onclick="$('#approveModal').modal('hide'); openTopupModal();">
                                    <i class="fa fa-plus-circle mr-1"></i> Nạp tiền ngay
                                </button>
                            </div>
                        </div>

                        <div class="p-3 bg-white rounded border mt-3">
                            <div class="d-flex align-items-center mb-2">
                                <i class="fa fa-university text-primary mr-2" style="font-size: 18px;"></i>
                                <span class="font-weight-bold text-dark" style="font-size: 13.5px;">Tài khoản ngân hàng nhận tiền hoàn của khách:</span>
                            </div>
                            <div class="p-2 bg-light rounded font-weight-bold text-dark font-monospace border mb-3" id="approveBankInfo"></div>

                            <div class="alert alert-info py-2 px-3 mb-0 small" style="line-height: 1.5;">
                                <i class="fa fa-shield text-primary mr-1"></i>
                                <strong>Cơ chế hoàn tiền tự động (Model 2):</strong> Khi bấm Duyệt, hệ thống sẽ <strong>khấu trừ trực tiếp số tiền hoàn từ Số dư Ví Host</strong> của bạn để giải ngân hoàn tiền trực tiếp vào tài khoản ngân hàng của khách hàng. Host không cần phải mở app ngân hàng chuyển tiền thủ công ngoài đời.
                            </div>
                        </div>
                    </div>

                    <div class="form-group mb-0">
                        <label class="font-weight-bold text-dark" style="font-size: 13px;">Ghi chú duyệt hoàn tiền:</label>
                        <input type="text" name="hostNote" class="form-control" placeholder="Ghi chú hoàn tiền..." value="Hệ thống đã khấu trừ Ví Host và hoàn tất giải ngân cho khách" />
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-dismiss="modal">Đóng</button>
                    <button type="submit" id="btnConfirmApprove" class="btn btn-success rounded-pill px-4 font-weight-bold">
                        <i class="fa fa-check-circle mr-1"></i> Duyệt Hoàn Tiền Từ Ví Host
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ========================================== -->
<!-- MODAL TOP-UP WALLET (NẠP TIỀN VÍ HOST)      -->
<!-- ========================================== -->
<div class="modal fade" id="topupModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px; overflow: hidden;">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title font-weight-bold">
                    <i class="fa fa-credit-card mr-2"></i>Nạp Tiền Vào Ví Host (Ký Quỹ Hoàn Tiền)
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <form action="${pageContext.request.contextPath}/host/refunds/action" method="post" id="topupForm">
                <input type="hidden" name="action" value="topup" />
                <div class="modal-body p-4">
                    <p class="text-muted mb-3" style="font-size: 13px;">
                        Nạp thêm số dư vào ví Host để đảm bảo quỹ thanh toán hoàn tiền kịp thời cho khách hàng.
                    </p>

                    <div class="form-group">
                        <label class="font-weight-bold text-dark" style="font-size: 13px;">Chọn nhanh số tiền nạp:</label>
                        <div class="d-flex flex-wrap gap-2 mb-2">
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill mr-2 mb-2 font-weight-bold" onclick="selectTopupAmount(5000000)">+ 5.000.000đ</button>
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill mr-2 mb-2 font-weight-bold" onclick="selectTopupAmount(10000000)">+ 10.000.000đ</button>
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill mr-2 mb-2 font-weight-bold" onclick="selectTopupAmount(20000000)">+ 20.000.000đ</button>
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill mr-2 mb-2 font-weight-bold" onclick="selectTopupAmount(50000000)">+ 50.000.000đ</button>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="font-weight-bold text-dark" style="font-size: 13px;">Số tiền nạp (VNĐ): <span class="text-danger">*</span></label>
                        <input type="number" step="1000" min="1000" name="amount" id="topupAmountInput" class="form-control form-control-lg font-weight-bold text-success" placeholder="Nhập số tiền VNĐ..." required value="10000000" />
                    </div>

                    <div class="form-group mb-0">
                        <label class="font-weight-bold text-dark" style="font-size: 13px;">Nội dung nạp tiền:</label>
                        <input type="text" name="note" class="form-control" value="Nạp tiền bổ sung ký quỹ Ví Host" />
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-primary rounded-pill px-4 font-weight-bold">
                        <i class="fa fa-arrow-down mr-1"></i> Xác Nhận Nạp Tiền
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ========================================== -->
<!-- MODAL REJECT REFUND                        -->
<!-- ========================================== -->
<div class="modal fade" id="rejectModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px; overflow: hidden;">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title font-weight-bold">
                    <i class="fa fa-times-circle mr-2"></i>Từ Chối Yêu Cầu Hoàn Tiền
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <form action="${pageContext.request.contextPath}/host/refunds/action" method="post">
                <input type="hidden" name="refundId" id="rejectRefundId" />
                <input type="hidden" name="action" value="reject" />
                <div class="modal-body p-4">
                    <p class="text-muted mb-3" style="font-size: 13.5px;">
                        Từ chối hoàn tiền cho đơn đặt phòng <strong id="rejectBookingCode" class="text-dark"></strong>.
                    </p>

                    <div class="form-group mb-0">
                        <label class="font-weight-bold text-dark" style="font-size: 13px;">Lý do từ chối <span class="text-danger">*</span></label>
                        <textarea name="hostNote" class="form-control" rows="3"
                                  placeholder="Ví dụ: Hủy phòng quá sát giờ quy định nhận phòng (dưới 24h) theo chính sách hủy..." required></textarea>
                        <small class="form-text text-muted">Lý do này sẽ được gửi trong email thông báo tới khách hàng.</small>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary rounded-pill px-4" data-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-danger rounded-pill px-4 font-weight-bold">
                        <i class="fa fa-ban mr-1"></i> Xác Nhận Từ Chối
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />

<script>
    var currentHostBalance = ${hostBalance != null ? hostBalance : 0};

    function openApproveModal(refundId, bookingCode, amount, bankInfo, customerName) {
        document.getElementById('approveRefundId').value = refundId;
        document.getElementById('approveBookingCode').textContent = bookingCode;
        document.getElementById('approveCustomerName').textContent = customerName;
        document.getElementById('approveBankInfo').textContent = bankInfo || 'Chưa cung cấp';
        
        var formatted = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
        document.getElementById('approveAmount').textContent = formatted;



        // Balance calculation
        var balanceAfter = currentHostBalance - amount;
        var formattedAfter = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(balanceAfter);
        var balAfterElem = document.getElementById('approveHostBalAfter');
        balAfterElem.textContent = formattedAfter;

        var btnConfirm = document.getElementById('btnConfirmApprove');
        var alertSufficient = document.getElementById('walletSufficientAlert');
        var alertInsufficient = document.getElementById('walletInsufficientAlert');

        if (currentHostBalance >= amount) {
            balAfterElem.className = 'font-weight-bold text-success';
            alertSufficient.style.display = 'block';
            alertInsufficient.style.display = 'none';
            btnConfirm.disabled = false;
            btnConfirm.classList.remove('btn-secondary');
            btnConfirm.classList.add('btn-success');
        } else {
            balAfterElem.className = 'font-weight-bold text-danger';
            alertSufficient.style.display = 'none';
            alertInsufficient.style.display = 'block';
            btnConfirm.disabled = true;
            btnConfirm.classList.remove('btn-success');
            btnConfirm.classList.add('btn-secondary');
        }

        $('#approveModal').modal('show');
    }

    function openRejectModal(refundId, bookingCode) {
        document.getElementById('rejectRefundId').value = refundId;
        document.getElementById('rejectBookingCode').textContent = bookingCode;
        $('#rejectModal').modal('show');
    }

    function openTopupModal() {
        $('#topupModal').modal('show');
    }

    function selectTopupAmount(val) {
        document.getElementById('topupAmountInput').value = val;
    }
</script>
