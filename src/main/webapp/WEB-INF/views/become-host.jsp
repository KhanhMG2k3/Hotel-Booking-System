<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Host application flow: review existing status or complete the five-step application wizard. --%>
<%-- Shared page header and navigation. --%>
<jsp:include page="common/header.jsp">
  <jsp:param name="pageTitle" value="Become a Host - Sogo Homestay" />
</jsp:include>

<jsp:include page="common/navbar.jsp" />

<%-- Page content: application status, personal details, property and room data, verification, and submission. --%>
<main id="partner-application" class="section partner-section"
      data-api-base="${pageContext.request.contextPath}/api/partner-applications"
      data-home-url="${pageContext.request.contextPath}/home">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-lg-10 col-xl-9">
        <header class="text-center mb-5">
          <span class="text-primary font-weight-bold text-uppercase letter-spacing-1">Host application</span>
          <h1 class="heading mt-2">Become a Host</h1>
          <p class="text-muted mb-0">Tell us about yourself and your property. Our team will review your application.</p>
        </header>

        <div id="partner-alert" class="alert d-none" role="alert" aria-live="polite"></div>
        <div id="partner-loading" class="text-center py-5" role="status">
          <span class="spinner-border text-primary" aria-hidden="true"></span>
          <p class="text-muted mt-3 mb-0">Loading your application...</p>
        </div>

        <%-- Existing application status and available follow-up actions. --%>
        <section id="partner-status" class="card border-0 shadow-sm d-none" aria-live="polite">
          <div class="card-body p-4 p-md-5">
            <div class="d-flex flex-wrap align-items-center justify-content-between mb-4">
              <div>
                <span class="partner-kicker">Host Application Status</span>
                <h2 id="partner-status-title" class="h3 mt-2 mb-0"></h2>
              </div>
              <span id="partner-status-badge" class="partner-status-badge"></span>
            </div>
            <div id="partner-status-message" class="mb-4"></div>
            <dl id="partner-status-details" class="row partner-summary-list"></dl>
            <div id="partner-rejection" class="alert alert-danger d-none" role="alert">
              <strong>Reason for rejection</strong>
              <p id="partner-rejection-reason" class="mb-0 mt-2"></p>
            </div>
            <div class="d-flex flex-wrap partner-actions">
              <button id="partner-edit-rejected" type="button" class="btn btn-outline-primary d-none">
                Edit Application
              </button>
              <button id="partner-resubmit-rejected" type="button" class="btn btn-primary d-none">
                Resubmit
              </button>
              <a id="partner-host-dashboard" class="btn btn-primary d-none"
                 href="${pageContext.request.contextPath}/host/dashboard">Go to Host Dashboard</a>
            </div>
          </div>
        </section>

        <%-- Multi-step application wizard. --%>
        <section id="partner-wizard" class="d-none">
          <nav class="partner-step-nav mb-4" aria-label="Application steps">
            <ol id="partner-step-list" class="partner-step-list">
              <li class="active" data-step-indicator="0"><span>1</span><small>Personal</small></li>
              <li data-step-indicator="1"><span>2</span><small>Property</small></li>
              <li data-step-indicator="2"><span>3</span><small>Rooms</small></li>
              <li data-step-indicator="3"><span>4</span><small>Verification</small></li>
              <li data-step-indicator="4"><span>5</span><small>Review</small></li>
            </ol>
          </nav>

          <div class="card border-0 shadow-sm">
            <div class="card-body p-4 p-md-5">
              <%-- Step 1: applicant contact and identification details. --%>
              <section class="partner-step" data-step="0">
                <span class="partner-kicker">Step 1 of 5</span>
                <h2 class="h3 mt-2">Personal information</h2>
                <p class="text-muted mb-4">Confirm how our team can contact you about your application.</p>
                <div class="form-row">
                  <div class="form-group col-md-6">
                    <label for="applicant-name">Full name <span class="text-danger">*</span></label>
                    <input id="applicant-name" class="form-control" name="applicantName"
                           maxlength="150" autocomplete="name" required>
                    <div class="invalid-feedback">Enter your full name.</div>
                  </div>
                  <div class="form-group col-md-6">
                    <label for="applicant-email">Email address <span class="text-danger">*</span></label>
                    <input id="applicant-email" class="form-control" name="applicantEmail"
                           type="email" maxlength="254" readonly required>
                    <small class="form-text text-muted">Use your account profile to change this email.</small>
                  </div>
                </div>
                <div class="form-group">
                  <label for="applicant-phone">Phone number <span class="text-danger">*</span></label>
                  <input id="applicant-phone" class="form-control" name="applicantPhone"
                         type="tel" maxlength="30" autocomplete="tel" required>
                  <div class="invalid-feedback">Enter a valid phone number.</div>
                </div>
                <hr class="my-4">
                <h3 class="h5">Identification</h3>

                <%-- OCR Smart Recognition Box --%>
                <div class="card p-3 mb-4 rounded border ocr-ekyc-card" style="clear: both; overflow: hidden;">
                  <div class="d-flex align-items-center mb-3">
                    <i class="fa fa-id-card text-primary mr-2" style="font-size: 1.8rem;"></i>
                    <div>
                      <strong class="d-block text-dark ocr-main-title">Quét ảnh CCCD tự động (eKYC OCR 2 mặt)</strong>
                      <small class="text-muted ocr-main-desc">Tải ảnh mặt trước và mặt sau rõ nét để hệ thống tự động bóc tách và điền Số định danh, Họ tên.</small>
                    </div>
                  </div>

                  <div class="row ocr-slots-grid">
                    <%-- Slot Mặt trước --%>
                    <div class="col-md-6 mb-3 mb-md-0">
                      <div class="ocr-side-slot p-3 border rounded text-center" id="ocr-slot-front">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                          <span class="font-weight-bold small text-uppercase ocr-slot-label">
                            <i class="fa fa-id-card-o text-primary mr-1"></i> Mặt trước CCCD
                          </span>
                          <span class="badge badge-secondary ocr-badge" id="ocr-front-badge">Chưa tải</span>
                        </div>
                        
                        <label for="ocr-front-file" class="ocr-dropzone mb-2 d-flex" id="ocr-dropzone-front" title="Bấm để chọn ảnh mặt trước" style="cursor: pointer;">
                          <div class="ocr-placeholder" id="ocr-front-placeholder">
                            <i class="fa fa-camera fa-2x mb-2 text-muted"></i>
                            <div class="small font-weight-bold ocr-drop-title">Chọn hoặc chụp ảnh mặt trước</div>
                            <div class="small text-muted">Chứa ảnh chân dung, Số CCCD và Họ tên</div>
                          </div>
                          <img id="ocr-front-preview" class="ocr-side-preview d-none" alt="Mặt trước CCCD">
                        </label>
                        
                        <input type="file" id="ocr-front-file" class="d-none" accept="image/*" onclick="this.value=null;" onchange="if(window.handleOcrFileScan){window.handleOcrFileScan('front', this);}">
                        <label for="ocr-front-file" class="btn btn-sm btn-outline-primary btn-block ocr-btn-choose mb-0" style="cursor: pointer;">
                          <i class="fa fa-upload mr-1"></i> Chọn ảnh mặt trước
                        </label></div>
                    </div>

                    <%-- Slot Mặt sau --%>
                    <div class="col-md-6">
                      <div class="ocr-side-slot p-3 border rounded text-center" id="ocr-slot-back">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                          <span class="font-weight-bold small text-uppercase ocr-slot-label">
                            <i class="fa fa-id-badge text-warning mr-1"></i> Mặt sau CCCD
                          </span>
                          <span class="badge badge-secondary ocr-badge" id="ocr-back-badge">Chưa tải</span>
                        </div>
                        
                        <label for="ocr-back-file" class="ocr-dropzone mb-2 d-flex" id="ocr-dropzone-back" title="Bấm để chọn ảnh mặt sau" style="cursor: pointer;">
                          <div class="ocr-placeholder" id="ocr-back-placeholder">
                            <i class="fa fa-qrcode fa-2x mb-2 text-muted"></i>
                            <div class="small font-weight-bold ocr-drop-title">Chọn hoặc chụp ảnh mặt sau</div>
                            <div class="small text-muted">Chứa chip, mã vạch/MRZ và ngày cấp</div>
                          </div>
                          <img id="ocr-back-preview" class="ocr-side-preview d-none" alt="Mặt sau CCCD">
                        </label>
                        
                        <input type="file" id="ocr-back-file" class="d-none" accept="image/*" onclick="this.value=null;" onchange="if(window.handleOcrFileScan){window.handleOcrFileScan('back', this);}">
                        <label for="ocr-back-file" class="btn btn-sm btn-outline-warning btn-block ocr-btn-choose mb-0" style="cursor: pointer;">
                          <i class="fa fa-upload mr-1"></i> Chọn ảnh mặt sau
                        </label></div>
                    </div>
                  </div>

                  <%-- OCR Scanning Progress --%>
                  <div id="ocr-progress-box" class="my-3 d-none">
                    <div class="d-flex justify-content-between align-items-center mb-1">
                      <small id="ocr-status-text" class="font-weight-bold text-primary">Đang quét nhận diện eKYC...</small>
                      <small id="ocr-percentage" class="text-muted font-weight-bold">0%</small>
                    </div>
                    <div class="progress" style="height: 8px;">
                      <div id="ocr-progress-bar" class="progress-bar progress-bar-striped progress-bar-animated bg-warning" role="progressbar" style="width: 0%"></div>
                    </div>
                  </div>

                  <%-- OCR Result Box --%>
                  <div id="ocr-result-box" class="mt-3 p-3 border rounded d-none ocr-result-card">
                    <div class="d-flex align-items-start">
                      <div class="mr-3 mt-1">
                        <span id="ocr-result-icon"><i class="fa fa-check-circle fa-2x text-success"></i></span>
                      </div>
                      <div class="flex-grow-1">
                        <div class="d-flex align-items-center flex-wrap mb-1">
                          <span id="ocr-result-badge" class="badge badge-success px-2 py-1 mr-2 mb-1">✓ eKYC Đã nhận diện</span>
                          <span id="ocr-sides-badge" class="small text-muted mb-1"></span>
                        </div>
                        <div id="ocr-result-details" class="small mb-1 font-weight-bold text-dark"></div>
                        <div id="ocr-autofill-hint" class="small text-success">
                          <i class="fa fa-check mr-1"></i> Đã tự động điền số CCCD vào trường <strong>Document number</strong> bên dưới.
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="form-row" style="clear: both; margin-top: 15px;">
                  <div class="form-group col-md-5">
                    <label for="identification-type">Document type <span class="text-danger">*</span></label>
                    <select id="identification-type" class="form-control" name="identificationType" required>
                      <option value="">Choose a document</option>
                      <option value="NATIONAL_ID">National ID (CCCD/CMND)</option>
                      <option value="PASSPORT">Passport (Hộ chiếu)</option>
                      <option value="OTHER">Other</option>
                    </select>
                  </div>
                  <div class="form-group col-md-7">
                    <label for="identification-number">Document number <span class="text-danger">*</span></label>
                    <input id="identification-number" class="form-control" name="identificationNumber"
                           maxlength="100" placeholder="Số CCCD (12 chữ số) hoặc số hộ chiếu" autocomplete="off" required>
                    <div id="identification-feedback" class="small mt-1 d-none font-weight-500"></div>
                  </div>
                </div>
              </section>

              <%-- Step 2: property description and location. --%>
              <section class="partner-step d-none" data-step="1">
                <span class="partner-kicker">Step 2 of 5</span>
                <h2 class="h3 mt-2">Property information</h2>
                <p class="text-muted mb-4">Provide the address, description, photos, and map details of your homestay.</p>
                <div class="form-row">
                  <div class="form-group col-md-8">
                    <label for="property-name">Property name <span class="text-danger">*</span></label>
                    <input id="property-name" class="form-control" name="propertyName"
                           maxlength="150" placeholder="Ví dụ: Sogo Homestay View Biển" required>
                  </div>
                  <div class="form-group col-md-4">
                    <label for="property-type">Property type <span class="text-danger">*</span></label>
                    <select id="property-type" class="form-control" name="propertyType" required>
                      <option value="">Choose a type</option>
                      <option value="Homestay">Homestay</option>
                      <option value="Apartment">Apartment</option>
                      <option value="Villa">Villa</option>
                      <option value="Hotel">Hotel</option>
                      <option value="Guesthouse">Guesthouse</option>
                    </select>
                  </div>
                </div>
                <div class="form-group">
                  <label for="property-description">Description <span class="text-danger">*</span></label>
                  <textarea id="property-description" class="form-control" name="propertyDescription"
                            rows="4" maxlength="5000" placeholder="Giới thiệu điểm nổi bật, không gian và trải nghiệm homestay..." required></textarea>
                </div>

                <%-- Street address with Auto-complete / Search & GPS button --%>
                <div class="form-group">
                  <div class="d-flex justify-content-between align-items-center mb-1">
                    <label for="property-address" class="mb-0">Street address <span class="text-danger">*</span></label>
                    <button type="button" id="btn-use-gps" class="btn btn-sm btn-outline-info" title="Lấy vị trí hiện tại">
                      📍 Lấy tọa độ GPS hiện tại
                    </button>
                  </div>
                  <div class="input-group">
                    <input id="property-address" class="form-control" name="propertyAddress"
                           maxlength="255" autocomplete="off" placeholder="Gõ số nhà, tên đường để tự động tìm kiếm..." required>
                    <div class="input-group-append">
                      <button class="btn btn-outline-secondary" type="button" id="btn-search-address" title="Tìm và phân tích địa chỉ">🔍 Tìm kiếm</button>
                    </div>
                  </div>
                  <small id="address-search-hint" class="form-text text-muted">
                    Nhập địa chỉ và bấm 🔍 hoặc chọn gợi ý để tự động điền Tỉnh/Thành phố, Quận/Huyện, Phường/Xã và Tọa độ bản đồ.
                  </small>
                  <div id="address-suggestions" class="list-group mt-1 d-none shadow" style="max-height: 180px; overflow-y: auto; z-index: 1000; position: relative;"></div>
                </div>

                <div class="form-row">
                  <div class="form-group col-md-4">
                    <label for="property-city">City / Province <span class="text-danger">*</span></label>
                    <input id="property-city" class="form-control" name="propertyCity"
                           maxlength="100" placeholder="Tỉnh / Thành phố" required>
                  </div>
                  <div class="form-group col-md-4">
                    <label for="property-district">District <span class="text-danger">*</span></label>
                    <input id="property-district" class="form-control" name="propertyDistrict"
                           maxlength="100" placeholder="Quận / Huyện" required>
                  </div>
                  <div class="form-group col-md-4">
                    <label for="property-ward">Ward <span class="text-danger">*</span></label>
                    <input id="property-ward" class="form-control" name="propertyWard"
                           maxlength="100" placeholder="Phường / Xã" required>
                  </div>
                </div>
                <div class="form-row">
                  <div class="form-group col-md-6">
                    <label for="property-latitude">Latitude (Vĩ độ) <span class="text-muted">(tự động qua bản đồ)</span></label>
                    <input id="property-latitude" class="form-control" name="latitude"
                           type="number" min="-90" max="90" step="any" placeholder="Ví dụ: 12.2388">
                  </div>
                  <div class="form-group col-md-6">
                    <label for="property-longitude">Longitude (Kinh độ) <span class="text-muted">(tự động qua bản đồ)</span></label>
                    <input id="property-longitude" class="form-control" name="longitude"
                           type="number" min="-180" max="180" step="any" placeholder="Ví dụ: 109.1967">
                  </div>
                </div>
                <div class="form-group">
                  <label for="application-note">Note for the review team <span class="text-muted">(optional)</span></label>
                  <textarea id="application-note" class="form-control" name="applicationNote"
                            rows="2" maxlength="1000" placeholder="Ghi chú thêm cho quản trị viên khi xét duyệt hồ sơ..."></textarea>
                </div>
              </section>

              <%-- Step 3: rooms and amenities. --%>
              <section class="partner-step d-none" data-step="2">
                <span class="partner-kicker">Step 3 of 5</span>
                <h2 class="h3 mt-2">Rooms &amp; amenities</h2>
                <p class="text-muted mb-4">Add each room you plan to offer. You can edit or remove rooms before submitting.</p>
                <div id="partner-room-list"></div>
                <button id="partner-add-room" class="btn btn-outline-primary mt-3" type="button">
                  <span aria-hidden="true">+</span> Add Room
                </button>
              </section>

              <%-- Step 4: verification documents. --%>
              <section class="partner-step d-none" data-step="3">
                <span class="partner-kicker">Step 4 of 5</span>
                <h2 class="h3 mt-2">Verification</h2>
                <p class="text-muted mb-4">Upload clear PDF, PNG, or JPEG files. Each file must be 5 MB or smaller.</p>
                <div id="partner-document-list"></div>
              </section>

              <%-- Step 5: review the application before submission. --%>
              <section class="partner-step d-none" data-step="4">
                <span class="partner-kicker">Step 5 of 5</span>
                <h2 class="h3 mt-2">Review &amp; submit</h2>
                <p class="text-muted mb-4">Check your details before sending the application for review.</p>
                <div id="partner-review-summary"></div>
                <div class="alert alert-info mt-4 mb-0">
                  By submitting, you confirm that the information and documents are accurate.
                </div>
              </section>

              <div class="partner-wizard-actions mt-5 pt-4 border-top">
                <button id="partner-back" class="btn btn-outline-secondary" type="button">Back</button>
                <div class="d-flex flex-wrap partner-actions">
                  <button id="partner-save-draft" class="btn btn-outline-primary" type="button">Save Draft</button>
                  <button id="partner-next" class="btn btn-primary" type="button">Continue</button>
                  <button id="partner-submit" class="btn btn-primary d-none" type="button">
                    Submit Application
                  </button>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
  </div>
</main>

<%-- Page-specific layout styles. --%>
<style>
  #partner-alert.partner-toast {
    align-items: flex-start;
    box-shadow: 0 .5rem 1.5rem rgba(0, 0, 0, .18);
    display: flex;
    gap: 1rem;
    justify-content: space-between;
    margin: 0;
    max-width: min(440px, calc(100vw - 2rem));
    opacity: 1;
    position: fixed;
    right: 1rem;
    top: 1rem;
    transform: translateX(0);
    transition: opacity .2s ease, transform .2s ease;
    white-space: pre-line;
    z-index: 1080;
  }
  #partner-alert.partner-toast-hide {
    opacity: 0;
    transform: translateX(1rem);
  }
  .partner-toast-close {
    background: transparent;
    border: 0;
    color: inherit;
    cursor: pointer;
    flex: 0 0 auto;
    font-size: 1.25rem;
    line-height: 1;
    opacity: .75;
    padding: 0;
  }
  .partner-toast-close:hover { opacity: 1; }
  .partner-section { min-height: 60vh; }
  .partner-kicker { color: #b0874e; font-size: .78rem; font-weight: 700; letter-spacing: .1em; text-transform: uppercase; }
  .partner-step-list { display: flex; justify-content: space-between; list-style: none; margin: 0; padding: 0; }
  .partner-step-list li { color: #8b8b8b; flex: 1; position: relative; text-align: center; }
  .partner-step-list li:not(:last-child)::after { background: #e4e4e4; content: ""; height: 2px; left: 50%; position: absolute; right: -50%; top: 17px; z-index: 0; }
  .partner-step-list li span { align-items: center; background: #e9ecef; border-radius: 50%; display: inline-flex; height: 36px; justify-content: center; position: relative; width: 36px; z-index: 1; }
  .partner-step-list li small { display: block; margin-top: .45rem; }
  .partner-step-list li.active, .partner-step-list li.complete { color: #b0874e; }
  .partner-step-list li.active span, .partner-step-list li.complete span { background: #b0874e; color: #fff; }
  .partner-step-nav { overflow-x: auto; }
  .partner-room-card { border: 1px solid #e8e8e8; border-radius: 4px; margin-bottom: 1.25rem; padding: 1.25rem; }
  .partner-amenities { display: grid; gap: .5rem 1rem; grid-template-columns: repeat(auto-fit, minmax(145px, 1fr)); }
  .partner-room-images { display: flex; flex-wrap: wrap; gap: .75rem; }
  .partner-room-media { position: relative; }
  .partner-room-image { background: #111; height: 110px; object-fit: cover; width: 150px; }
  .partner-room-media-remove { align-items: center; background: #dc3545; border: 0; border-radius: 50%; color: #fff; cursor: pointer; display: flex; font-size: 1.1rem; height: 25px; justify-content: center; line-height: 1; padding: 0; position: absolute; right: -7px; top: -7px; width: 25px; }
  .partner-document-row { align-items: center; border-bottom: 1px solid #e8e8e8; display: flex; flex-wrap: wrap; gap: 1rem; justify-content: space-between; padding: 1rem 0; }
  .partner-document-row:first-child { padding-top: 0; }
  .partner-document-row > div:first-child { flex: 1 1 240px; }
  .partner-document-actions { display: flex; flex: 0 0 auto; gap: .75rem; }
  .partner-document-action { align-items: center; display: inline-flex; height: 54px; justify-content: center; margin: 0; width: 145px; }
  .partner-summary-list dt { color: #666; }
  .partner-summary-list dd { overflow-wrap: anywhere; }
  .partner-status-badge { background: #edf0f2; border-radius: 30px; color: #495057; font-size: .85rem; font-weight: 700; padding: .45rem .9rem; }
  .partner-status-badge.pending { background: #fff3cd; color: #856404; }
  .partner-status-badge.approved { background: #d4edda; color: #155724; }
  .partner-status-badge.rejected { background: #f8d7da; color: #721c24; }
  .partner-wizard-actions { align-items: center; display: flex; flex-wrap: wrap; gap: .75rem; justify-content: space-between; }
  .partner-actions { gap: .75rem; }
  .partner-review-section { border-bottom: 1px solid #e8e8e8; margin-bottom: 1.25rem; padding-bottom: 1.25rem; }
  .partner-review-section:last-child { border-bottom: 0; margin-bottom: 0; }
  @media (max-width: 575.98px) {
    .partner-step-list li small { font-size: .68rem; }
    .partner-wizard-actions, .partner-wizard-actions > .partner-actions { width: 100%; }
    .partner-wizard-actions > .partner-actions .btn { flex: 1; }
  }
  @media (max-width: 767.98px) {
    .partner-document-row { align-items: stretch; flex-direction: column; }
    .partner-document-actions { width: 100%; }
    .partner-document-action { flex: 1 1 0; min-width: 0; width: auto; }
  }

  /* eKYC OCR 2-Side Recognition styles */
  .ocr-ekyc-card {
    background: #f8fafc;
    border-color: #e2e8f0;
    transition: all 0.3s ease;
  }
  .ocr-side-slot {
    background: #ffffff;
    border-color: #e2e8f0 !important;
    border-radius: 8px;
    transition: all 0.2s ease;
  }
  .ocr-side-slot:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  }
  .ocr-dropzone {
    align-items: center;
    background: #f8fafc;
    border: 2px dashed #cbd5e1;
    border-radius: 8px;
    cursor: pointer;
    display: flex;
    justify-content: center;
    min-height: 145px;
    overflow: hidden;
    padding: 10px;
    position: relative;
    transition: all 0.2s ease;
  }
  .ocr-dropzone:hover, .ocr-dropzone.dragover {
    background: #f1f5f9;
    border-color: #3b82f6;
  }
  .ocr-side-preview {
    border-radius: 6px;
    max-height: 130px;
    max-width: 100%;
    object-fit: contain;
  }
  .ocr-result-card {
    background: #f0fdf4;
    border-color: #bbf7d0 !important;
  }
  .ocr-result-card.ocr-error {
    background: #fef2f2;
    border-color: #fecaca !important;
  }
  @keyframes highlightPulse {
    0% { box-shadow: 0 0 0 0 rgba(40, 167, 69, 0.7); border-color: #28a745; }
    50% { box-shadow: 0 0 0 6px rgba(40, 167, 69, 0.3); border-color: #28a745; }
    100% { box-shadow: 0 0 0 0 rgba(40, 167, 69, 0); border-color: #28a745; }
  }
  .ocr-highlight-success {
    animation: highlightPulse 1.2s ease-in-out 3;
    border-color: #28a745 !important;
    background-color: #f0fdf4 !important;
  }

  /* Dark Theme Support for eKYC OCR */
  [data-theme="dark"] .ocr-ekyc-card {
    background: rgba(30, 41, 59, 0.8) !important;
    border-color: #334155 !important;
  }
  [data-theme="dark"] .ocr-side-slot {
    background: #0f172a !important;
    border-color: #334155 !important;
  }
  [data-theme="dark"] .ocr-dropzone {
    background: rgba(15, 23, 42, 0.6) !important;
    border-color: #475569 !important;
  }
  [data-theme="dark"] .ocr-dropzone:hover, [data-theme="dark"] .ocr-dropzone.dragover {
    background: rgba(30, 41, 59, 0.9) !important;
    border-color: #60a5fa !important;
  }
  [data-theme="dark"] .ocr-main-title,
  [data-theme="dark"] .ocr-slot-label,
  [data-theme="dark"] .ocr-drop-title,
  [data-theme="dark"] #ocr-result-details {
    color: #f8fafc !important;
  }
  [data-theme="dark"] .ocr-result-card {
    background: rgba(6, 78, 59, 0.3) !important;
    border-color: #059669 !important;
  }
  [data-theme="dark"] .ocr-result-card.ocr-error {
    background: rgba(127, 29, 29, 0.3) !important;
    border-color: #dc2626 !important;
  }
  [data-theme="dark"] .ocr-highlight-success {
    background-color: rgba(6, 78, 59, 0.4) !important;
    border-color: #10b981 !important;
    color: #f8fafc !important;
  }
</style>

<!-- Tesseract.js for Client-side OCR Document Recognition -->
<script src="https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/partner-application.js?v=<%= System.currentTimeMillis() %>"></script>
<%-- Shared page footer and scripts. --%>
<jsp:include page="common/footer.jsp" />
