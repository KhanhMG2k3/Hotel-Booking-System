<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="../common/header.jsp">
    <jsp:param name="pageTitle" value="Host Dashboard - Sogo Homestay" />
</jsp:include>

<jsp:include page="../common/navbar.jsp" />

<style>
    .host-dash { padding-top: 110px; padding-bottom: 80px; background: #f2f4fb; min-height: 70vh; }
    .host-dash .page-title {
        font-family: "Playfair Display", serif;
        font-weight: 700;
        color: #1a1a1a;
        margin-bottom: 0.25rem;
    }
    .host-dash .page-sub { color: #6c757d; font-size: 0.95rem; }
    .stat-card, .profile-card, .property-card {
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 2px 12px rgba(0,0,0,.06);
        border: 1px solid rgba(0,0,0,.04);
        transition: box-shadow .2s ease, transform .2s ease;
    }
    .stat-card:hover, .property-card:hover {
        box-shadow: 0 8px 24px rgba(0,0,0,.1);
        transform: translateY(-2px);
    }
    .stat-card { padding: 1.25rem 1.5rem; height: 100%; }
    .stat-card .stat-label { font-size: .8rem; color: #6c757d; text-transform: uppercase; letter-spacing: .04em; margin-bottom: .35rem; }
    .stat-card .stat-value { font-family: "Playfair Display", serif; font-size: 1.75rem; font-weight: 700; color: #1a1a1a; line-height: 1.2; }
    .stat-card .stat-icon {
        width: 44px; height: 44px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center;
        background: rgba(255,186,90,.15); color: #e09a2e; font-size: 1.15rem;
    }
    .profile-card { padding: 1.5rem; height: 100%; }
    .profile-card h5 {
        font-family: "Playfair Display", serif; font-weight: 700; font-size: 1.15rem; margin-bottom: 1rem;
    }
    .profile-meta { font-size: .9rem; margin-bottom: .75rem; }
    .profile-meta .label { color: #6c757d; font-size: .75rem; display: block; margin-bottom: 2px; }
    .badge-status {
        display: inline-block; padding: .35em .75em; border-radius: 50px;
        font-size: .75rem; font-weight: 600; letter-spacing: .02em;
    }
    .badge-approved { background: #d4edda; color: #155724; }
    .badge-pending { background: #fff3cd; color: #856404; }
    .badge-rejected { background: #f8d7da; color: #721c24; }
    .badge-draft { background: #e2e3e5; color: #383d41; }
    .badge-active { background: #cce5ff; color: #004085; }
    .btn-host-primary {
        background: #ffba5a; border-color: #ffba5a; color: #fff;
        font-weight: 600; border-radius: 6px; padding: .6rem 1.25rem;
    }
    .btn-host-primary:hover { background: #e09a2e; border-color: #e09a2e; color: #fff; }
    .btn-host-outline {
        border: 1.5px solid #ffba5a; color: #e09a2e; background: transparent;
        font-weight: 600; border-radius: 6px; padding: .55rem 1.1rem;
    }
    .btn-host-outline:hover { background: #ffba5a; color: #fff; }
    .property-card { overflow: hidden; height: 100%; display: flex; flex-direction: column; }
    .property-card .card-img-wrap {
        height: 160px; background: #e9ecef; position: relative; overflow: hidden;
    }
    .property-card .card-img-wrap img {
        width: 100%; height: 100%; object-fit: cover;
    }
    .property-card .card-img-placeholder {
        width: 100%; height: 100%;
        background: linear-gradient(135deg, #f8f1e5 0%, #ffe8c4 100%);
        display: flex; align-items: center; justify-content: center;
        color: #c49a4a; font-size: 2.5rem;
    }
    .property-card .card-body { padding: 1.15rem 1.25rem 1.25rem; flex: 1; display: flex; flex-direction: column; }
    .property-card .card-title {
        font-family: "Playfair Display", serif; font-weight: 700; font-size: 1.1rem;
        margin-bottom: .35rem; color: #1a1a1a;
    }
    .property-card .card-loc { font-size: .85rem; color: #6c757d; margin-bottom: .5rem; }
    .property-card .card-loc i { color: #ffba5a; margin-right: 4px; }
    .property-card .card-desc {
        font-size: .85rem; color: #6c757d; flex: 1;
        display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
    }
    .empty-state {
        background: #fff; border-radius: 12px; padding: 3rem 1.5rem;
        text-align: center; box-shadow: 0 2px 12px rgba(0,0,0,.05);
    }
    .empty-state .empty-icon {
        width: 72px; height: 72px; border-radius: 50%;
        background: rgba(255,186,90,.12); color: #ffba5a;
        display: inline-flex; align-items: center; justify-content: center;
        font-size: 1.75rem; margin-bottom: 1rem;
    }
    .section-label {
        font-family: "Playfair Display", serif; font-weight: 700; font-size: 1.25rem; margin-bottom: 1rem;
    }
</style>

<section class="host-dash">
    <div class="container">

        <!-- Header -->
        <div class="d-flex flex-wrap justify-content-between align-items-start mb-4">
            <div class="mb-3 mb-md-0">
                <h1 class="page-title">Host Dashboard</h1>
                <p class="page-sub mb-0">
                    Xin chào
                    <strong><c:out value="${sessionScope.userName}" /></strong>
                    — quản lý homestay và property của bạn
                </p>
            </div>
            <a href="${pageContext.request.contextPath}/host/property/create" class="btn btn-host-primary">
                <i class="fa fa-plus mr-1"></i> Tạo property mới
            </a>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger shadow-sm border-0 rounded mb-4">
                <c:out value="${error}" />
            </div>
        </c:if>

        <c:if test="${not empty hostProfile}">
            <!-- Stats -->
            <div class="row mb-4">
                <div class="col-6 col-md-3 mb-3">
                    <div class="stat-card d-flex align-items-center justify-content-between">
                        <div>
                            <div class="stat-label">Property</div>
                            <div class="stat-value">
                                <c:choose>
                                    <c:when test="${empty properties}">0</c:when>
                                    <c:otherwise>${fn:length(properties)}</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="stat-icon"><i class="fa fa-building"></i></div>
                    </div>
                </div>
                <div class="col-6 col-md-3 mb-3">
                    <div class="stat-card d-flex align-items-center justify-content-between">
                        <div>
                            <div class="stat-label">Trạng thái Host</div>
                            <div class="stat-value" style="font-size:1.1rem;padding-top:.35rem;">
                                <c:choose>
                                    <c:when test="${hostProfile.verificationStatus == 'APPROVED'}">
                                        <span class="badge-status badge-approved">Đã duyệt</span>
                                    </c:when>
                                    <c:when test="${hostProfile.verificationStatus == 'PENDING'}">
                                        <span class="badge-status badge-pending">Chờ duyệt</span>
                                    </c:when>
                                    <c:when test="${hostProfile.verificationStatus == 'REJECTED'}">
                                        <span class="badge-status badge-rejected">Từ chối</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-status badge-draft"><c:out value="${hostProfile.verificationStatus}" /></span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="stat-icon"><i class="fa fa-check-circle"></i></div>
                    </div>
                </div>
                <div class="col-6 col-md-3 mb-3">
                    <div class="stat-card d-flex align-items-center justify-content-between">
                        <div>
                            <div class="stat-label">Loại hình</div>
                            <div class="stat-value" style="font-size:1.15rem;">
                                <c:out value="${empty hostProfile.businessType ? '—' : hostProfile.businessType}" />
                            </div>
                        </div>
                        <div class="stat-icon"><i class="fa fa-home"></i></div>
                    </div>
                </div>
                <div class="col-6 col-md-3 mb-3">
                    <div class="stat-card d-flex align-items-center justify-content-between">
                        <div>
                            <div class="stat-label">Liên hệ</div>
                            <div class="stat-value" style="font-size:1rem;word-break:break-all;">
                                <c:out value="${empty hostProfile.phone ? '—' : hostProfile.phone}" />
                            </div>
                        </div>
                        <div class="stat-icon"><i class="fa fa-phone"></i></div>
                    </div>
                </div>
            </div>

            <div class="row">
                <!-- Profile side -->
                <div class="col-lg-4 mb-4">
                    <div class="profile-card">
                        <h5><i class="fa fa-id-card-o mr-2" style="color:#ffba5a;"></i>Hồ sơ Host</h5>
                        <div class="profile-meta">
                            <span class="label">Tên doanh nghiệp / Homestay</span>
                            <strong><c:out value="${hostProfile.businessName}" /></strong>
                        </div>
                        <div class="profile-meta">
                            <span class="label">Loại hình</span>
                            <c:out value="${empty hostProfile.businessType ? 'Chưa cập nhật' : hostProfile.businessType}" />
                        </div>
                        <div class="profile-meta">
                            <span class="label">Số điện thoại</span>
                            <c:out value="${empty hostProfile.phone ? 'Chưa cập nhật' : hostProfile.phone}" />
                        </div>
                        <div class="profile-meta mb-0">
                            <span class="label">Trạng thái xác minh</span>
                            <c:choose>
                                <c:when test="${hostProfile.verificationStatus == 'APPROVED'}">
                                    <span class="badge-status badge-approved">APPROVED</span>
                                </c:when>
                                <c:when test="${hostProfile.verificationStatus == 'PENDING'}">
                                    <span class="badge-status badge-pending">PENDING</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge-status badge-draft"><c:out value="${hostProfile.verificationStatus}" /></span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <hr class="my-3">
                        <a href="${pageContext.request.contextPath}/host/property/create" class="btn btn-host-outline btn-block btn-sm">
                            <i class="fa fa-plus mr-1"></i> Thêm property
                        </a>
                    </div>
                </div>

                <!-- Property list -->
                <div class="col-lg-8 mb-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h3 class="section-label mb-0">Danh sách property</h3>
                    </div>

                    <c:choose>
                        <c:when test="${empty properties}">
                            <div class="empty-state">
                                <div class="empty-icon"><i class="fa fa-building-o"></i></div>
                                <h5 class="mb-2" style="font-family:'Playfair Display',serif;">Chưa có property nào</h5>
                                <p class="text-muted mb-3">Tạo property đầu tiên để bắt đầu nhận đặt phòng từ khách.</p>
                                <a href="${pageContext.request.contextPath}/host/property/create" class="btn btn-host-primary">
                                    <i class="fa fa-plus mr-1"></i> Tạo property đầu tiên
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="row">
                                <c:forEach var="property" items="${properties}" varStatus="st">
                                    <div class="col-md-6 mb-3">
                                        <div class="property-card">
                                            <div class="card-img-wrap">
                                                <%-- Chưa có ảnh property → placeholder theo theme --%>
                                                <div class="card-img-placeholder">
                                                    <i class="fa fa-image"></i>
                                                </div>
                                                <div style="position:absolute;top:10px;left:10px;">
                                                    <c:choose>
                                                        <c:when test="${property.status == 'ACTIVE' || property.status == 'PUBLISHED'}">
                                                            <span class="badge-status badge-active"><c:out value="${property.status}" /></span>
                                                        </c:when>
                                                        <c:when test="${property.status == 'DRAFT'}">
                                                            <span class="badge-status badge-draft">DRAFT</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-status badge-pending"><c:out value="${property.status}" /></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                            <div class="card-body">
                                                <div class="card-title"><c:out value="${property.name}" /></div>
                                                <div class="card-loc">
                                                    <i class="fa fa-map-marker"></i>
                                                    <c:out value="${property.address}" />
                                                    <c:if test="${not empty property.city}">
                                                        , <c:out value="${property.city}" />
                                                    </c:if>
                                                </div>
                                                <c:if test="${not empty property.description}">
                                                    <p class="card-desc mb-2"><c:out value="${property.description}" /></p>
                                                </c:if>
                                                <c:if test="${not empty property.propertyType}">
                                                    <span class="badge badge-light border text-muted small">
                                                        <c:out value="${property.propertyType}" />
                                                    </span>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:if>

        <c:if test="${empty hostProfile and empty error}">
            <div class="empty-state">
                <div class="empty-icon"><i class="fa fa-user-plus"></i></div>
                <h5 class="mb-2" style="font-family:'Playfair Display',serif;">Chưa có hồ sơ Host</h5>
                <p class="text-muted mb-3">Đăng ký trở thành Host để quản lý property tại đây.</p>
                <a href="${pageContext.request.contextPath}/become-host" class="btn btn-host-primary">Trở thành Host</a>
            </div>
        </c:if>

    </div>
</section>

<jsp:include page="../common/footer.jsp" />