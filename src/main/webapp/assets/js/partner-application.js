/**
 * Host application wizard for collecting applicant, property, room, and document details.
 * The flow loads the draft, validates each step, persists room data, and submits the final request with CSRF protection.
 */
(function () {
  'use strict';

  const page = document.getElementById('partner-application');
  if (!page) {
    return;
  }

  const apiBase = page.dataset.apiBase;
  const homeUrl = page.dataset.homeUrl;
/**
 * Builds a consistent API endpoint for the host-application workflow.
 * @param {string} path - API route relative to the base URL.
 * @returns {string} The resolved API URL.
 */
  const apiUrl = function (path) {
    return apiBase.replace(/\/+$/, '') + '/' + String(path || '').replace(/^\/+/, '');
  };
  const alertBox = document.getElementById('partner-alert');
  const loading = document.getElementById('partner-loading');
  const statusPanel = document.getElementById('partner-status');
  const wizard = document.getElementById('partner-wizard');
  const roomList = document.getElementById('partner-room-list');
  const documentList = document.getElementById('partner-document-list');
  const stepSections = Array.from(document.querySelectorAll('[data-step]'));
  const stepIndicators = Array.from(document.querySelectorAll('[data-step-indicator]'));
  const state = {
    application: null,
    profile: null,
    csrfToken: null,
    rooms: [],
    step: 0,
    busy: false,
    initialRejected: null
  };

  const applicationFields = {
    applicantName: 'applicant-name',
    applicantEmail: 'applicant-email',
    applicantPhone: 'applicant-phone',
    identificationType: 'identification-type',
    identificationNumber: 'identification-number',
    propertyName: 'property-name',
    propertyType: 'property-type',
    propertyDescription: 'property-description',
    propertyAddress: 'property-address',
    propertyCity: 'property-city',
    propertyDistrict: 'property-district',
    propertyWard: 'property-ward',
    latitude: 'property-latitude',
    longitude: 'property-longitude',
    applicationNote: 'application-note'
  };

  const roomAmenities = [
    'Wi-Fi', 'Air conditioning', 'Kitchen', 'Private bathroom',
    'Television', 'Washer', 'Parking', 'Workspace'
  ];
  const maxMediaSize = 50 * 1024 * 1024;
  let alertTimeout;
  const allowedMedia = {
    jpg: 'image/jpeg',
    jpeg: 'image/jpeg',
    png: 'image/png',
    mp4: 'video/mp4',
    webm: 'video/webm'
  };

  const documentTypes = [
    { key: 'identity', label: 'Identity document', field: 'identityDocumentUrl', required: true },
    { key: 'ownership', label: 'Property ownership / authorization document', field: 'ownershipDocumentUrl', required: true },
    { key: 'business', label: 'Business document', field: 'businessDocumentUrl', required: false }
  ];

/**
 * Displays a toast alert and auto-dismisses it after a short timeout.
 * @param {string} message - User-facing status text.
 * @param {string} type - Alert variant such as success, warning, or danger.
 * @returns {void}
 */
  function showAlert(message, type) {
    window.clearTimeout(alertTimeout);
    const closeButton = document.createElement('button');
    closeButton.type = 'button';
    closeButton.className = 'partner-toast-close';
    closeButton.setAttribute('aria-label', 'Dismiss notification');
    closeButton.textContent = '×';
    closeButton.addEventListener('click', dismissAlert);
    alertBox.replaceChildren(document.createTextNode(message), closeButton);
    alertBox.className = 'alert alert-' + type + ' partner-toast';
    alertBox.classList.remove('d-none');
    alertTimeout = window.setTimeout(dismissAlert, 7000);
  }

/**
 * Hides the active toast without clearing the page state.
 * @returns {void}
 */
  function dismissAlert() {
    window.clearTimeout(alertTimeout);
    alertBox.classList.add('partner-toast-hide');
    window.setTimeout(function () {
      alertBox.classList.add('d-none');
      alertBox.classList.remove('partner-toast-hide');
    }, 200);
  }

/**
 * Clears the current alert and resets the toast styling.
 * @returns {void}
 */
  function clearAlert() {
    window.clearTimeout(alertTimeout);
    alertBox.replaceChildren();
    alertBox.className = 'alert d-none partner-toast';
  }

/**
 * Locks the wizard while a request is in flight.
 * @param {boolean} busy - Whether all controls should be disabled.
 * @returns {void}
 */
  function setBusy(busy) {
    state.busy = busy;
    page.querySelectorAll('button').forEach(function (button) {
      button.disabled = busy;
    });
    page.setAttribute('aria-busy', String(busy));
  }

/**
 * Creates a user-friendly offline error for fetch failures.
 * @param {string} action - Action being performed when the connection was lost.
 * @returns {Error} A descriptive application error.
 */
  function networkError(action) {
    return new Error('The connection was lost while ' + action
      + '. Check that Tomcat is running and the application is deployed at localhost:8080. '
      + 'The result is unknown; verify the application data before retrying.');
  }

/**
 * Wraps fetch for consistent network error handling.
 * @param {string} url - Request target URL.
 * @param {RequestInit} [options] - Fetch options.
 * @param {string} action - User-visible action name used in error text.
 * @returns {Promise<Response>} The raw fetch response.
 */
  async function fetchApi(url, options, action) {
    try {
      return await fetch(url, options);
    } catch (error) {
      if (error instanceof TypeError) {
        throw networkError(action);
      }
      throw error;
    }
  }

/**
 * Builds a readable message from an HTTP error code.
 * @param {number} status - HTTP status returned by the server.
 * @param {string} action - Action being executed when the error occurred.
 * @returns {string} The translated error message.
 */
  function httpErrorMessage(status, action) {
    if (status === 404) {
      return 'The server could not find the endpoint for ' + action
        + '. Redeploy the latest application from NetBeans and try again.';
    }
    if (status === 413) {
      return 'The server rejected ' + action + ' because the request is too large. '
        + 'For room media, choose a file no larger than 50 MB.';
    }
    if (status >= 500) {
      return 'The server encountered an internal error while ' + action
        + '. Check the Tomcat Output/log for the detailed cause.';
    }
    return 'The server rejected ' + action + ' (HTTP ' + status + ').';
  }

/**
 * Parses the API JSON payload and throws a readable error if the request fails.
 * @param {Response} response - HTTP response object.
 * @param {string} action - Action used in the error text.
 * @returns {Promise<Object>} The decoded JSON body.
 */
  async function readResponse(response, action) {
    const contentType = response.headers.get('content-type') || '';
    let body = {};
    if (contentType.includes('application/json')) {
      try {
        body = await response.json();
      } catch (error) {
        throw new Error(httpErrorMessage(response.status, action));
      }
    }
    if (!response.ok) {
      throw new Error(body.message || httpErrorMessage(response.status, action));
    }
    return body;
  }

/**
 * Requests a fresh CSRF token from the server before a protected POST.
 * @returns {Promise<void>} Resolves after the token is stored in state.
 */
  async function refreshCsrfToken() {
    const response = await fetchApi(apiUrl('me'), {
      credentials: 'same-origin',
      headers: { Accept: 'application/json' }
    }, 'checking your session');
    const body = await readResponse(response, 'checking your session');
    state.csrfToken = body.csrfToken;
  }

/**
 * Executes a JSON read request without sending a form body.
 * @param {string} path - Relative API route.
 * @param {Object} [options] - Fetch options for the request.
 * @param {string} [action] - Action label used in error messages.
 * @returns {Promise<Object>} Parsed JSON response body.
 */
  async function request(path, options, action) {
    const requestAction = action || 'loading application data';
    const response = await fetchApi(apiUrl(path), Object.assign({
      credentials: 'same-origin',
      headers: { Accept: 'application/json' }
    }, options || {}), requestAction);
    return readResponse(response, requestAction);
  }

/**
 * Sends a POST payload and refreshes the CSRF token after every call.
 * @param {string} path - Relative API route.
 * @param {URLSearchParams|FormData} body - Request payload.
 * @param {boolean} multipart - Whether the payload is multipart form data.
 * @param {string} [action] - User-facing action description.
 * @returns {Promise<Object>} Parsed JSON response body.
 */
  async function post(path, body, multipart, action) {
    const requestAction = action || 'saving your changes';
    // The server rotates the CSRF token on each protected POST, so refresh it before the request.
    if (!state.csrfToken) {
      await refreshCsrfToken();
    }
    let response;
    if (multipart) {
      body.append('csrfToken', state.csrfToken);
      response = await fetchApi(apiUrl(path), {
        method: 'POST',
        credentials: 'same-origin',
        headers: { Accept: 'application/json' },
        body: body
      }, requestAction);
    } else {
      body.set('csrfToken', state.csrfToken);
      response = await fetchApi(apiUrl(path), {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
        },
        body: body.toString()
      }, requestAction);
    }

    let result;
    let requestError;
    try {
      result = await readResponse(response, requestAction);
    } catch (error) {
      requestError = error;
    }
    // POST consumes the session token, including when the request fails validation.
    try {
      await refreshCsrfToken();
    } catch (error) {
      state.csrfToken = null;
      if (!requestError) {
        throw error;
      }
    }
    if (requestError) {
      throw requestError;
    }
    return result;
  }

/**
 * Reads a trimmed value from a form field by application key.
 * @param {string} fieldName - Field name defined in the wizard schema.
 * @returns {string} The field value after trimming.
 */
  function formValue(fieldName) {
    const field = document.getElementById(applicationFields[fieldName]);
    return field ? field.value.trim() : '';
  }

/**
 * Writes a value back into the matching form field.
 * @param {string} fieldName - Field name defined in the wizard schema.
 * @param {*} value - The new value to assign.
 * @returns {void}
 */
  function setFormValue(fieldName, value) {
    const field = document.getElementById(applicationFields[fieldName]);
    if (field && value !== null && value !== undefined) {
      field.value = value;
    }
  }

/**
 * Collects all application form fields into a URL-encoded payload.
 * @returns {URLSearchParams} The serialized application data.
 */
  function readApplicationFields() {
    const values = new URLSearchParams();
    Object.keys(applicationFields).forEach(function (fieldName) {
      const field = document.getElementById(applicationFields[fieldName]);
      if (field) {
        values.set(fieldName, field.value.trim());
      }
    });
    return values;
  }

/**
 * Saves the current application draft and merges any unsaved room entries.
 * @returns {Promise<Object>} Saved application payload from the server.
 */
  async function saveApplication() {
    const values = readApplicationFields();
    const current = state.application;
    const unsavedRooms = state.rooms.filter(function (room) {
      return !room.id;
    });
    const path = current && current.status === 'DRAFT'
      ? '/' + current.id
      : '';
    const saved = await post(path, values, false, 'saving your application draft');
    state.application = saved;
    state.rooms = (Array.isArray(saved.rooms) ? saved.rooms : [])
      .concat(unsavedRooms);
    return saved;
  }

/**
 * Prefills the wizard from the saved application or the user profile.
 * @param {Object|null} application - Existing application draft.
 * @param {Object|null} profile - Current user profile data.
 * @returns {void}
 */
  function setFormFromApplication(application, profile) {
    const defaults = {
      applicantName: profile ? profile.fullName : '',
      applicantEmail: profile ? profile.email : '',
      applicantPhone: profile ? profile.phone : ''
    };
    Object.keys(applicationFields).forEach(function (fieldName) {
      const value = application && application[fieldName] !== undefined
        ? application[fieldName]
        : defaults[fieldName];
      if (value !== undefined && value !== null) {
        setFormValue(fieldName, value);
      }
    });
  }

/**
 * Formats a date string for the review panel.
 * @param {string|null} value - ISO date or null.
 * @returns {string} Presentation-safe date text.
 */
  function formatDate(value) {
    if (!value) {
      return 'Not available';
    }
    const date = new Date(value);
    return Number.isNaN(date.getTime())
      ? value
      : new Intl.DateTimeFormat(undefined, { dateStyle: 'medium', timeStyle: 'short' }).format(date);
  }

/**
 * Adds a key/value pair to the application status panel.
 * @param {string} label - Field label.
 * @param {string} value - Detailed value to render.
 * @returns {void}
 */
  function addStatusDetail(label, value) {
    const list = document.getElementById('partner-status-details');
    const term = document.createElement('dt');
    const description = document.createElement('dd');
    term.className = 'col-sm-4';
    description.className = 'col-sm-8';
    term.textContent = label;
    description.textContent = value || 'Not provided';
    list.append(term, description);
  }

/**
 * Renders the status view after an application has been saved or reviewed.
 * @param {Object} application - Application data returned by the server.
 * @returns {void}
 */
  function showStatus(application) {
    wizard.classList.add('d-none');
    statusPanel.classList.remove('d-none');
    document.getElementById('partner-status-details').replaceChildren();
    document.getElementById('partner-rejection').classList.add('d-none');
    document.getElementById('partner-edit-rejected').classList.add('d-none');
    document.getElementById('partner-resubmit-rejected').classList.add('d-none');
    document.getElementById('partner-host-dashboard').classList.add('d-none');

    const status = application.status;
    const title = status === 'PENDING' ? 'Application under review'
      : status === 'APPROVED' ? 'Application approved'
        : 'Application not approved';
    const message = status === 'PENDING'
      ? 'Your application has been submitted. We will contact you after the review is complete.'
      : status === 'APPROVED'
        ? 'Your property application has been approved. Your account now has Host access.'
        : 'Your application was rejected. Review the feedback, make changes, and submit it again.';
    document.getElementById('partner-status-title').textContent = title;
    document.getElementById('partner-status-message').textContent = message;

    const badge = document.getElementById('partner-status-badge');
    badge.textContent = status.charAt(0) + status.slice(1).toLowerCase();
    badge.className = 'partner-status-badge ' + status.toLowerCase();
    addStatusDetail('Property', application.propertyName);
    addStatusDetail('Submitted', formatDate(application.submittedAt));
    addStatusDetail('Reviewed', formatDate(application.reviewedAt));
    addStatusDetail('Reviewed by', application.reviewerName);

    if (status === 'REJECTED') {
      document.getElementById('partner-rejection-reason').textContent =
        application.rejectionReason || 'No reason was provided.';
      document.getElementById('partner-rejection').classList.remove('d-none');
      document.getElementById('partner-edit-rejected').classList.remove('d-none');
      document.getElementById('partner-resubmit-rejected').classList.remove('d-none');
    }
    if (status === 'APPROVED') {
      document.getElementById('partner-host-dashboard').classList.remove('d-none');
    }
  }

/**
 * Creates the editable DOM card for a room entry in the wizard.
 * @param {Object} room - Existing room data or a blank template.
 * @param {string} temporaryKey - Local key used before the server assigns an ID.
 * @returns {HTMLElement} The rendered room card element.
 */
  function createRoomCard(room, temporaryKey) {
    const card = document.createElement('article');
    card.className = 'partner-room-card';
    card.dataset.roomId = room.id || temporaryKey;
    card.innerHTML =
      '<div class="d-flex flex-wrap align-items-center justify-content-between mb-3">' +
        '<h3 class="h5 mb-2">Room details</h3>' +
        '<button class="btn btn-sm btn-outline-danger" type="button" data-room-action="remove">Remove room</button>' +
      '</div>' +
      '<div class="form-row">' +
        '<div class="form-group col-md-6"><label>Room name <span class="text-danger">*</span></label><input class="form-control" data-room-field="roomName" maxlength="120" required></div>' +
        '<div class="form-group col-md-6"><label>Room type <span class="text-danger">*</span></label><select class="form-control" data-room-field="roomType" required>' +
          '<option value="">Choose a type</option><option value="SINGLE">Single</option><option value="DOUBLE">Double</option><option value="TWIN">Twin</option><option value="FAMILY">Family</option><option value="SUITE">Suite</option><option value="OTHER">Other</option>' +
        '</select></div>' +
      '</div>' +
      '<div class="form-row">' +
        '<div class="form-group col-md-3"><label>Price per night <strong>(VNĐ)</strong> <span class="text-danger">*</span></label>' +
          '<div class="input-group">' +
            '<input class="form-control" data-room-field="pricePerNight" type="number" min="1000" max="99999999" step="1000" placeholder="VD: 500000" required>' +
            '<div class="input-group-append"><span class="input-group-text font-weight-bold">₫</span></div>' +
          '</div>' +
          '<small class="form-text text-muted">Nhập giá số nguyên (VNĐ)</small>' +
        '</div>' +
        '<div class="form-group col-md-3"><label>Maximum guests <span class="text-danger">*</span></label><input class="form-control" data-room-field="maxGuests" type="number" min="1" max="65535" step="1" required></div>' +
        '<div class="form-group col-md-3"><label>Number of beds <span class="text-danger">*</span></label><input class="form-control" data-room-field="bedCount" type="number" min="1" max="65535" step="1" required></div>' +
        '<div class="form-group col-md-3"><label>Bathrooms <span class="text-danger">*</span></label><input class="form-control" data-room-field="bathroomCount" type="number" min="1" max="65535" step="1" required></div>' +
      '</div>' +
      '<fieldset class="form-group"><legend class="h6">Amenities</legend><div class="partner-amenities" data-room-amenities></div>' +
        '<label class="mt-3">Other amenities <span class="text-muted">(comma-separated)</span></label><input class="form-control" data-room-field="customAmenities" maxlength="500"></fieldset>' +
      '<div class="form-group"><label>Room photos and videos <span class="text-muted">(JPG/PNG/MP4/WebM, up to 10 files, 50 MB each)</span></label>' +
        '<input class="form-control-file" data-room-images type="file" accept=".jpg,.jpeg,.png,.mp4,.webm,image/jpeg,image/png,video/mp4,video/webm" multiple>' +
        '<small class="form-text text-muted" data-image-upload-status></small><div class="partner-room-images mt-2" data-room-image-list></div></div>' +
      '<button class="btn btn-outline-primary" type="button" data-room-action="save">Save Room</button>';

    const selectedAmenities = room.amenities || [];
    const amenityContainer = card.querySelector('[data-room-amenities]');
    roomAmenities.forEach(function (amenity, index) {
      const label = document.createElement('label');
      label.className = 'custom-control custom-checkbox';
      const checkbox = document.createElement('input');
      checkbox.className = 'custom-control-input';
      checkbox.type = 'checkbox';
      checkbox.value = amenity;
      checkbox.checked = selectedAmenities.includes(amenity);
      checkbox.name = 'amenity-' + index;
      const text = document.createElement('span');
      text.className = 'custom-control-label';
      text.textContent = amenity;
      label.append(checkbox, text);
      amenityContainer.appendChild(label);
    });

    const values = {
      roomName: room.roomName,
      roomType: room.roomType,
      pricePerNight: room.pricePerNight,
      maxGuests: room.maxGuests,
      bedCount: room.bedCount,
      bathroomCount: room.bathroomCount
    };
    Object.keys(values).forEach(function (name) {
      const field = card.querySelector('[data-room-field="' + name + '"]');
      field.value = values[name] === null || values[name] === undefined ? '' : values[name];
    });

    const predefined = new Set(roomAmenities);
    card.querySelector('[data-room-field="customAmenities"]').value =
      selectedAmenities.filter(function (amenity) {
        return !predefined.has(amenity);
      }).join(', ');
    renderRoomImages(card, room.images || []);
    return card;
  }

/**
 * Renders uploaded room thumbnails and media previews for a room card.
 * @param {HTMLElement} card - Room card container.
 * @param {Array<Object>} images - Uploaded media entries from the server.
 * @returns {void}
 */
  function renderRoomImages(card, images) {
    const container = card.querySelector('[data-room-image-list]');
    container.replaceChildren();
    images.forEach(function (media) {
      const wrapper = document.createElement('div');
      wrapper.className = 'partner-room-media';
      let preview;
      if (media.mediaType === 'VIDEO') {
        preview = document.createElement('video');
        preview.controls = true;
        preview.preload = 'metadata';
      } else {
        preview = document.createElement('img');
        preview.alt = 'Uploaded room photo';
      }
      preview.className = 'partner-room-image rounded';
      preview.src = media.url;
      const remove = document.createElement('button');
      remove.type = 'button';
      remove.className = 'partner-room-media-remove';
      remove.textContent = '×';
      remove.setAttribute('aria-label', 'Remove uploaded media');
      remove.dataset.roomAction = 'remove-image';
      remove.dataset.imageId = media.id;
      remove.dataset.staged = String(Boolean(media.staged));
      wrapper.append(preview, remove);
      container.appendChild(wrapper);
    });
  }

/**
 * Renders the room cards from the current draft state.
 * @returns {void}
 */
  function renderRooms() {
    roomList.replaceChildren();
    if (state.rooms.length === 0) {
      const message = document.createElement('p');
      message.className = 'text-muted';
      message.textContent = 'No rooms added yet.';
      roomList.appendChild(message);
    }
    state.rooms.forEach(function (room) {
      roomList.appendChild(createRoomCard(room, 'new-' + room.localId));
    });
  }

/**
 * Lists the uploaded verification documents and required status badges.
 * @returns {void}
 */
  function renderDocuments() {
    documentList.replaceChildren();
    documentTypes.forEach(function (documentType) {
      const row = document.createElement('div');
      row.className = 'partner-document-row';
      const description = document.createElement('div');
      const title = document.createElement('strong');
      title.textContent = documentType.label + (documentType.required ? ' *' : '');
      const stateText = document.createElement('small');
      stateText.className = 'form-text text-muted';
      const url = state.application && state.application[documentType.field];
      stateText.textContent = url ? 'Uploaded' : documentType.required ? 'Required before submission' : 'Optional';
      description.append(title, stateText);

      const controls = document.createElement('div');
      controls.className = 'partner-document-actions';
      if (url) {
        const view = document.createElement('a');
        view.href = url;
        view.target = '_blank';
        view.rel = 'noopener';
        view.className = 'btn btn-sm btn-outline-secondary partner-document-action';
        view.textContent = 'View file';
        controls.appendChild(view);
        const remove = document.createElement('button');
        remove.type = 'button';
        remove.className = 'btn btn-sm btn-outline-danger partner-document-action';
        remove.textContent = 'Remove';
        remove.dataset.documentAction = 'remove';
        remove.dataset.documentType = documentType.key;
        controls.appendChild(remove);
      }
      const upload = document.createElement('label');
      upload.className = 'btn btn-sm btn-outline-primary mb-0 partner-document-action';
      upload.textContent = url ? 'Replace file' : 'Upload file';
      const input = document.createElement('input');
      input.type = 'file';
      input.accept = 'application/pdf,image/png,image/jpeg';
      input.className = 'sr-only';
      input.dataset.documentType = documentType.key;
      upload.appendChild(input);
      controls.appendChild(upload);
      row.append(description, controls);
      documentList.appendChild(row);
    });
  }

/**
 * Adds a review subsection to the final summary panel.
 * @param {string} title - Section heading.
 * @param {Array<Array<string>>} entries - Label/value pairs for the section.
 * @returns {void}
 */
  function addReviewSection(title, entries) {
    const section = document.createElement('section');
    section.className = 'partner-review-section';
    const heading = document.createElement('h3');
    heading.className = 'h5';
    heading.textContent = title;
    section.appendChild(heading);
    const list = document.createElement('dl');
    list.className = 'row partner-summary-list mb-0';
    entries.forEach(function (entry) {
      const term = document.createElement('dt');
      const value = document.createElement('dd');
      term.className = 'col-sm-4';
      value.className = 'col-sm-8';
      term.textContent = entry[0];
      value.textContent = entry[1] || 'Not provided';
      list.append(term, value);
    });
    section.appendChild(list);
    document.getElementById('partner-review-summary').appendChild(section);
  }

/**
 * Builds the final verification summary before the application is submitted.
 * @returns {void}
 */
  function renderReview() {
    // Assemble the final confirmation summary from the active wizard state.
    const summary = document.getElementById('partner-review-summary');
    summary.replaceChildren();
    addReviewSection('Applicant', [
      ['Full name', formValue('applicantName')],
      ['Email', formValue('applicantEmail')],
      ['Phone', formValue('applicantPhone')],
      ['Identification', formValue('identificationType') + ' — ' + formValue('identificationNumber')]
    ]);
    addReviewSection('Property', [
      ['Name', formValue('propertyName')],
      ['Type', formValue('propertyType')],
      ['Description', formValue('propertyDescription')],
      ['Address', [formValue('propertyAddress'), formValue('propertyWard'),
        formValue('propertyDistrict'), formValue('propertyCity')].filter(Boolean).join(', ')],
      ['Coordinates', formValue('latitude') && formValue('longitude')
        ? formValue('latitude') + ', ' + formValue('longitude') : 'Not provided']
    ]);
    state.rooms.forEach(function (room, index) {
      addReviewSection('Room ' + (index + 1) + ': ' + (room.roomName || 'Room'), [
        ['Type', room.roomType],
        ['Price per night', room.pricePerNight],
        ['Maximum guests', room.maxGuests],
        ['Beds / bathrooms', room.bedCount + ' / ' + room.bathroomCount],
        ['Amenities', (room.amenities || []).join(', ')],
        ['Images', String((room.images || []).length)]
      ]);
    });
    addReviewSection('Verification documents', documentTypes.map(function (documentType) {
      return [documentType.label, state.application && state.application[documentType.field]
        ? 'Uploaded' : documentType.required ? 'Missing' : 'Not provided'];
    }));
  }

/**
 * Advances the wizard to a specific step and updates completion states.
 * @param {number} step - Zero-based step index.
 * @returns {void}
 */
  function changeStep(step) {
    // Advance the wizard state and refresh the visible panels to match the current step.
    state.step = step;
    stepSections.forEach(function (section) {
      section.classList.toggle('d-none', Number(section.dataset.step) !== step);
    });
    stepIndicators.forEach(function (indicator) {
      const index = Number(indicator.dataset.stepIndicator);
      indicator.classList.toggle('active', index === step);
      indicator.classList.toggle('complete', index < step);
    });
    document.getElementById('partner-back').disabled = step === 0;
    document.getElementById('partner-next').classList.toggle('d-none', step === 4);
    document.getElementById('partner-submit').classList.toggle('d-none', step !== 4);
    document.getElementById('partner-submit').textContent =
      state.application && state.application.supersedesApplicationId
        ? 'Resubmit Application' : 'Submit Application';
    if (step === 4) {
      renderReview();
    }
  }

  // Danh mục 63 mã tỉnh/thành phố trực thuộc TW hợp lệ theo quy chuẩn CCCD Bộ Công an
  const CCCD_PROVINCES = {
    '001': 'Hà Nội', '002': 'Hà Giang', '004': 'Cao Bằng', '006': 'Bắc Kạn', '008': 'Tuyên Quang',
    '010': 'Lào Cai', '011': 'Điện Biên', '012': 'Lai Châu', '014': 'Sơn La', '015': 'Yên Bái',
    '017': 'Hòa Bình', '019': 'Thái Nguyên', '020': 'Lạng Sơn', '022': 'Quảng Ninh', '024': 'Bắc Giang',
    '025': 'Phú Thọ', '026': 'Vĩnh Phúc', '027': 'Bắc Ninh', '030': 'Hải Dương', '031': 'Hải Phòng',
    '033': 'Hưng Yên', '034': 'Thái Bình', '035': 'Hà Nam', '036': 'Nam Định', '037': 'Ninh Bình',
    '038': 'Thanh Hóa', '040': 'Nghệ An', '042': 'Hà Tĩnh', '044': 'Quảng Bình', '045': 'Quảng Trị',
    '046': 'Thừa Thiên Huế', '048': 'Đà Nẵng', '049': 'Quảng Nam', '051': 'Quảng Ngãi', '052': 'Bình Định',
    '054': 'Phú Yên', '056': 'Khánh Hòa', '058': 'Ninh Thuận', '060': 'Bình Thuận', '062': 'Kon Tum',
    '064': 'Gia Lai', '066': 'Đắk Lắk', '067': 'Đắk Nông', '068': 'Lâm Đồng', '070': 'Bình Phước',
    '072': 'Tây Ninh', '074': 'Bình Dương', '075': 'Đồng Nai', '077': 'Bà Rịa - Vũng Tàu',
    '079': 'TP. Hồ Chí Minh', '080': 'Long An', '082': 'Tiền Giang', '083': 'Bến Tre', '084': 'Trà Vinh',
    '086': 'Vĩnh Long', '087': 'Đồng Tháp', '089': 'An Giang', '091': 'Kiên Giang', '092': 'Cần Thơ',
    '093': 'Hậu Giang', '094': 'Sóc Trăng', '095': 'Bạc Liêu', '096': 'Cà Mau'
  };

  /**
   * Validates Vietnamese National ID (CCCD 12 digits).
   * @param {string} cccd - The CCCD string to validate.
   * @returns {{ valid: boolean, error?: string, info?: string }}
   */
  function validateCccd(cccd) {
    if (!cccd || !cccd.trim()) {
      return { valid: false, error: 'Vui lòng nhập số CCCD.' };
    }
    const clean = cccd.trim();
    if (!/^\d+$/.test(clean)) {
      return { valid: false, error: 'Số CCCD chỉ được chứa các chữ số (0-9).' };
    }
    if (clean.length !== 12) {
      return { valid: false, error: 'Số CCCD phải bao gồm đúng 12 chữ số (hiện tại: ' + clean.length + '/12).' };
    }
    const provinceCode = clean.substring(0, 3);
    const provinceName = CCCD_PROVINCES[provinceCode];
    if (!provinceName) {
      return { valid: false, error: 'Mã tỉnh/thành phố (' + provinceCode + ') không hợp lệ trên hệ thống CCCD Việt Nam.' };
    }
    const genderDigit = clean.charCodeAt(3) - 48;
    if (genderDigit < 0 || genderDigit > 9) {
      return { valid: false, error: 'Ký tự giới tính/thế kỷ sinh không hợp lệ.' };
    }
    const gender = (genderDigit % 2 === 0) ? 'Nam' : 'Nữ';
    const centuryBase = 1900 + Math.floor(genderDigit / 2) * 100;
    const birthYear = centuryBase + parseInt(clean.substring(4, 6), 10);
    const randomSuffix = clean.substring(6);
    if (randomSuffix === '000000') {
      return { valid: false, error: 'Dãy 6 số định danh ngẫu nhiên không hợp lệ.' };
    }
    return {
      valid: true,
      info: 'CCCD hợp lệ • Cấp tại: ' + provinceName + ' • ' + gender + ', sinh năm ' + birthYear
    };
  }

  /**
   * Updates real-time feedback UI for National ID / Passport input field.
   */
  function updateIdentificationValidationUI() {
    const numInput = document.getElementById('identification-number');
    const typeSelect = document.getElementById('identification-type');
    const feedbackEl = document.getElementById('identification-feedback');
    if (!numInput || !typeSelect || !feedbackEl) return;

    const type = typeSelect.value;
    const value = (numInput.value || '').trim();

    // Dynamically adjust input restrictions based on type
    if (type === 'NATIONAL_ID') {
      numInput.setAttribute('maxlength', '12');
      numInput.setAttribute('inputmode', 'numeric');
      numInput.setAttribute('placeholder', 'Nhập đúng 12 chữ số CCCD (VD: 001204000006)');
    } else if (type === 'PASSPORT') {
      numInput.setAttribute('maxlength', '20');
      numInput.setAttribute('inputmode', 'text');
      numInput.setAttribute('placeholder', 'Nhập số hộ chiếu (VD: B1234567)');
    } else {
      numInput.setAttribute('maxlength', '50');
      numInput.removeAttribute('inputmode');
      numInput.setAttribute('placeholder', 'Số CCCD (12 chữ số) hoặc số hộ chiếu');
    }

    if (!value) {
      feedbackEl.className = 'small mt-1 d-none font-weight-500';
      feedbackEl.textContent = '';
      numInput.classList.remove('is-valid', 'is-invalid');
      return;
    }

    if (type === 'NATIONAL_ID') {
      feedbackEl.classList.remove('d-none');
      const res = validateCccd(value);
      if (res.valid) {
        feedbackEl.className = 'small mt-1 text-success font-weight-bold';
        feedbackEl.innerHTML = '<i class="fa fa-check-circle mr-1"></i>' + res.info;
        numInput.classList.remove('is-invalid');
        numInput.classList.add('is-valid');
      } else {
        feedbackEl.className = 'small mt-1 text-danger font-weight-bold';
        feedbackEl.innerHTML = '<i class="fa fa-exclamation-circle mr-1"></i>' + res.error;
        numInput.classList.remove('is-valid');
        numInput.classList.add('is-invalid');
      }
    } else if (type === 'PASSPORT') {
      feedbackEl.classList.remove('d-none');
      const passValid = /^[A-Za-z0-9]{6,15}$/.test(value);
      if (passValid) {
        feedbackEl.className = 'small mt-1 text-success font-weight-bold';
        feedbackEl.innerHTML = '<i class="fa fa-check-circle mr-1"></i>✓ Định dạng số hộ chiếu hợp lệ';
        numInput.classList.remove('is-invalid');
        numInput.classList.add('is-valid');
      } else {
        feedbackEl.className = 'small mt-1 text-danger font-weight-bold';
        feedbackEl.innerHTML = '<i class="fa fa-exclamation-circle mr-1"></i>Số hộ chiếu phải gồm 6 - 15 ký tự chữ và số.';
        numInput.classList.remove('is-valid');
        numInput.classList.add('is-invalid');
      }
    } else {
      feedbackEl.className = 'small mt-1 d-none';
      numInput.classList.remove('is-invalid');
      numInput.classList.add('is-valid');
    }
  }

/**
 * Validates the current wizard step before moving forward.
 * @param {number} step - Wizard step index to validate.
 * @returns {boolean} True when the current step passes validation.
 */
  function validateStep(step) {
    const current = stepSections.find(function (section) {
      return Number(section.dataset.step) === step;
    });

    // Clear previous invalid highlights
    current.querySelectorAll('.is-invalid').forEach(function (el) {
      el.classList.remove('is-invalid');
    });

    const requiredFields = Array.from(current.querySelectorAll('[required]'));
    for (const field of requiredFields) {
      if (!field.checkValidity()) {
        field.classList.add('is-invalid');
        field.reportValidity();
        field.scrollIntoView({ behavior: 'smooth', block: 'center' });
        field.focus();
        
        // Remove invalid border once user starts typing
        field.addEventListener('input', function onInputClear() {
          field.classList.remove('is-invalid');
          field.removeEventListener('input', onInputClear);
        });
        return false;
      }
    }
    // Validate the applicant contact details and identification before moving beyond the profile step.
    if (step === 0) {
      const phone = formValue('applicantPhone');
      const phoneInput = document.getElementById('applicant-phone');
      if (!/^[0-9+() .-]{7,30}$/.test(phone)) {
        if (phoneInput) {
          phoneInput.classList.add('is-invalid');
          phoneInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
          phoneInput.focus();
        }
        showAlert('Vui lòng nhập số điện thoại hợp lệ (từ 7 đến 30 chữ số).', 'danger');
        return false;
      }

      const idType = formValue('identificationType');
      const idTypeInput = document.getElementById('identification-type');
      if (!idType) {
        if (idTypeInput) {
          idTypeInput.classList.add('is-invalid');
          idTypeInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
          idTypeInput.focus();
        }
        showAlert('Vui lòng chọn loại giấy tờ định danh (Document type).', 'danger');
        return false;
      }

      const idNumber = formValue('identificationNumber');
      const idNumInput = document.getElementById('identification-number');
      if (idType === 'NATIONAL_ID') {
        const cccdRes = validateCccd(idNumber);
        if (!cccdRes.valid) {
          if (idNumInput) {
            idNumInput.classList.add('is-invalid');
            idNumInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
            idNumInput.focus();
          }
          showAlert(cccdRes.error, 'danger');
          updateIdentificationValidationUI();
          return false;
        }
      } else if (idType === 'PASSPORT') {
        if (!/^[A-Za-z0-9]{6,15}$/.test(idNumber)) {
          if (idNumInput) {
            idNumInput.classList.add('is-invalid');
            idNumInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
            idNumInput.focus();
          }
          showAlert('Số hộ chiếu không hợp lệ (từ 6 đến 15 ký tự chữ và số).', 'danger');
          updateIdentificationValidationUI();
          return false;
        }
      } else {
        if (!idNumber || idNumber.trim().length < 4) {
          if (idNumInput) {
            idNumInput.classList.add('is-invalid');
            idNumInput.focus();
          }
          showAlert('Vui lòng nhập số giấy tờ hợp lệ (tối thiểu 4 ký tự).', 'danger');
          return false;
        }
      }
    }
    // Coordinates are optional together, but they must be submitted as a pair.
    if (step === 1) {
      const latitude = formValue('latitude');
      const longitude = formValue('longitude');
      const latInput = document.getElementById('property-latitude');
      const lngInput = document.getElementById('property-longitude');
      if ((latitude && !longitude) || (!latitude && longitude)) {
        if (!latitude && latInput) latInput.classList.add('is-invalid');
        if (!longitude && lngInput) lngInput.classList.add('is-invalid');
        showAlert('Enter both latitude and longitude, or leave both blank.', 'danger');
        return false;
      }
    }
    // A draft is not ready until every room is saved and no temporary cards remain.
    // Each room must have at least 1 image uploaded.
    if (step === 2) {
      const unsaved = roomList.querySelector('[data-room-id^="new-"]');
      if (!state.rooms.length || unsaved) {
        showAlert(unsaved
          ? 'Save or remove each room before continuing.'
          : 'Add and save at least one room before continuing.', 'warning');
        return false;
      }

      // Check mandatory room photos (at least 1 photo per room)
      for (const room of state.rooms) {
        if (!room.images || room.images.length === 0) {
          const card = roomList.querySelector('[data-room-id="' + (room.id || 'new-' + room.localId) + '"]');
          if (card) {
            const imgInput = card.querySelector('[data-room-images]');
            if (imgInput) {
              imgInput.classList.add('is-invalid');
              card.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
          }
          showAlert('Mỗi phòng bắt buộc phải có ít nhất 1 hình ảnh giới thiệu phòng. Vui lòng tải ảnh cho phòng: ' + (room.roomName || 'chưa đặt tên'), 'warning');
          return false;
        }
      }
    }
    // The verification step requires all mandatory documents before final approval can be requested.
    if (step === 3) {
      const missing = documentTypes.find(function (documentType) {
        return documentType.required
          && !(state.application && state.application[documentType.field]);
      });
      if (missing) {
        showAlert('Upload the required ' + missing.label.toLowerCase() + ' before continuing.', 'warning');
        return false;
      }
    }
    return true;
  }

/**
 * Saves the active draft and moves to the next wizard step when validation passes.
 * @returns {Promise<void>} Resolves after the next step is shown.
 */
  async function moveForward() {
    clearAlert();
    if (!validateStep(state.step)) {
      return;
    }
    // Save the latest draft before the wizard moves to the next step or review screen.
    await saveApplication();
    if (state.step === 2) {
      await saveAllRooms();
      renderRooms();
    }
    changeStep(state.step + 1);
  }

/**
 * Serializes a room card into the payload expected by the server.
 * @param {HTMLElement} card - Editable room card element.
 * @returns {URLSearchParams} The room fields and amenities payload.
 */
  function roomPayload(card) {
    const values = new URLSearchParams();
    card.querySelectorAll('[data-room-field]').forEach(function (field) {
      if (field.dataset.roomField !== 'customAmenities') {
        values.set(field.dataset.roomField, field.value.trim());
      }
    });
    const amenities = Array.from(card.querySelectorAll('[data-room-amenities] input:checked'))
      .map(function (field) { return field.value; });
    card.querySelector('[data-room-field="customAmenities"]').value.split(',')
      .map(function (amenity) { return amenity.trim(); })
      .filter(Boolean).forEach(function (amenity) { amenities.push(amenity); });
    amenities.forEach(function (amenity) {
      values.append('amenities', amenity);
    });
    values.set('sortOrder', String(Array.from(roomList.children).indexOf(card)));
    const room = state.rooms.find(function (item) {
      return String(item.id || 'new-' + item.localId) === card.dataset.roomId;
    });
    if (room && room.clientRoomKey) {
      values.set('clientRoomKey', room.clientRoomKey);
    }
    return values;
  }

/**
 * Persist every room in the current draft before the final application review.
 * @returns {Promise<void>} Resolves after each room card is saved.
 */
  async function saveAllRooms() {
    if (!state.application) {
      return;
    }
    const cards = Array.from(roomList.querySelectorAll('[data-room-id]'));
    for (const card of cards) {
      const roomId = card.dataset.roomId;
      const fields = Array.from(card.querySelectorAll('[required]'));
      const invalid = fields.find(function (field) {
        return !field.checkValidity();
      });
      if (invalid) {
        throw new Error('Complete or remove each room before saving the draft.');
      }
      const room = state.rooms.find(function (item) {
        return String(item.id || 'new-' + item.localId) === roomId;
      });
      if (!room) {
        continue;
      }
      const path = state.application.id + '/rooms' + (room.id ? '/' + room.id : '');
      const savedRoom = await post(
        path, roomPayload(card), false, 'saving the room details');
      updateRoomState(savedRoom, roomId);
      card.dataset.roomId = String(savedRoom.id);
      renderRoomImages(card, savedRoom.images || []);
    }
  }

/**
 * Replaces the local room object with the server response and preserves the new ID.
 * @param {Object} savedRoom - Server-saved room payload.
 * @param {string} oldId - Previous local or server room ID.
 * @returns {void}
 */
  function updateRoomState(savedRoom, oldId) {
    const index = state.rooms.findIndex(function (room) {
      return String(room.id || 'new-' + room.localId) === String(oldId);
    });
    if (index >= 0) {
      state.rooms[index] = savedRoom;
    } else {
      state.rooms.push(savedRoom);
    }
  }

  roomList.addEventListener('click', async function (event) {
    const button = event.target.closest('[data-room-action]');
    if (!button || state.busy) {
      return;
    }
    const card = button.closest('[data-room-id]');
    const roomId = card.dataset.roomId;
    const room = state.rooms.find(function (item) {
      return String(item.id || 'new-' + item.localId) === roomId;
    });
    if (!room) {
      return;
    }
    clearAlert();
    setBusy(true);
    try {
      if (button.dataset.roomAction === 'save') {
        let firstInvalid = null;
        card.querySelectorAll('.is-invalid').forEach(function (el) {
          el.classList.remove('is-invalid');
        });

        card.querySelectorAll('[required]').forEach(function (field) {
          if (!field.checkValidity() || (field.value && !field.value.trim())) {
            field.classList.add('is-invalid');
            if (!firstInvalid) firstInvalid = field;
            field.addEventListener('input', function onClear() {
              field.classList.remove('is-invalid');
              field.removeEventListener('input', onClear);
            });
          }
        });

        if (firstInvalid) {
          firstInvalid.reportValidity();
          firstInvalid.focus();
          return;
        }

        // Validate that room has at least 1 image
        if (!room.images || room.images.length === 0) {
          const imgInput = card.querySelector('[data-room-images]');
          if (imgInput) imgInput.classList.add('is-invalid');
          showAlert('Vui lòng tải lên ít nhất 1 hình ảnh hoặc video cho phòng trước khi lưu!', 'warning');
          return;
        }
        const savedApplication = await saveApplication();
        const oldId = roomId;
        const path = savedApplication.id + '/rooms' + (room.id ? '/' + room.id : '');
        const savedRoom = await post(
          path, roomPayload(card), false, 'saving the room details');
        updateRoomState(savedRoom, oldId);
        card.dataset.roomId = String(savedRoom.id);
        renderRoomImages(card, savedRoom.images || []);
        showAlert('Room and its uploaded photos/videos saved successfully.', 'success');
      } else if (button.dataset.roomAction === 'remove') {
        if (room.id) {
          await post(state.application.id + '/rooms/' + room.id + '/delete',
            new URLSearchParams(), false);
        } else if (state.application && room.clientRoomKey) {
          for (const media of room.images.filter(function (item) {
            return item.staged;
          })) {
            await post(state.application.id + '/media/' + room.clientRoomKey + '/'
              + media.id + '/delete', new URLSearchParams(), false);
          }
        }
        state.rooms = state.rooms.filter(function (item) {
          return String(item.id || 'new-' + item.localId) !== roomId;
        });
        card.remove();
        if (!state.rooms.length) {
          renderRooms();
        }
      } else if (button.dataset.roomAction === 'remove-image') {
        if (button.dataset.staged === 'true') {
          await post(state.application.id + '/media/' + room.clientRoomKey + '/'
            + button.dataset.imageId + '/delete', new URLSearchParams(), false);
          room.images = room.images.filter(function (media) {
            return String(media.id) !== button.dataset.imageId;
          });
        } else {
          await post(state.application.id + '/rooms/' + room.id + '/images/'
            + button.dataset.imageId + '/delete', new URLSearchParams(), false);
          const updatedRoom = await request('/' + state.application.id + '/rooms/' + room.id);
          room.images = updatedRoom.images || [];
        }
        renderRoomImages(card, room.images || []);
      }
    } catch (error) {
      showAlert(error.message, 'danger');
    } finally {
      setBusy(false);
    }
  });

  roomList.addEventListener('change', async function (event) {
    const input = event.target.closest('[data-room-images]');
    if (!input || !input.files.length || state.busy) {
      return;
    }
    const card = input.closest('[data-room-id]');
    const roomId = card.dataset.roomId;
    const room = state.rooms.find(function (item) {
      return String(item.id || 'new-' + item.localId) === roomId;
    });
    if (!room) {
      showAlert('The room form could not be found. Add the room again and retry.', 'danger');
      input.value = '';
      return;
    }
    setBusy(true);
    try {
      const remaining = 10 - (room.images || []).length;
      const files = Array.from(input.files);
      if (files.length > remaining) {
        throw new Error('A room can have up to 10 photos and videos.');
      }
      for (const file of files) {
        const extension = file.name.split('.').pop().toLowerCase();
        const expectedType = allowedMedia[extension];
        if (!expectedType || file.type && file.type !== expectedType) {
          throw new Error(file.name + ' is not supported. Choose JPG, PNG, MP4, or WebM.');
        }
        if (file.size > maxMediaSize) {
          throw new Error(file.name + ' is larger than the 50 MB limit.');
        }
      }
      const status = card.querySelector('[data-image-upload-status]');
      if (!state.application || !state.application.id) {
        await saveApplication();
      }
      for (const file of files) {
        const data = new FormData();
        data.append('file', file);
        status.textContent = 'Uploading ' + file.name + '...';
        const path = room.id
          ? state.application.id + '/rooms/' + room.id + '/images'
          : state.application.id + '/media/' + room.clientRoomKey;
        const uploaded = await post(
          path, data, true, 'uploading the selected photo or video');
        if (room.id) {
          const updated = await request('/' + state.application.id + '/rooms/' + room.id);
          room.images = updated.images || [];
        } else {
          uploaded.staged = true;
          room.images.push(uploaded);
        }
      }
      card.querySelector('[data-image-upload-status]').textContent = '';
      renderRoomImages(card, room.images || []);
      showAlert('Photos and videos uploaded. Save the room details when ready.', 'success');
    } catch (error) {
      showAlert(error.message, 'danger');
    } finally {
      input.value = '';
      setBusy(false);
    }
  });

  document.getElementById('partner-add-room').addEventListener('click', function () {
    if (state.rooms.length >= 20) {
      showAlert('You can add up to 20 rooms per application.', 'warning');
      return;
    }
    const localId = Date.now();
    const room = {
      localId: localId,
      clientRoomKey: 'room-' + localId + '-' + Math.random().toString(36).slice(2, 10),
      amenities: [],
      images: []
    };
    state.rooms.push(room);
    roomList.querySelector('p')?.remove();
    roomList.appendChild(createRoomCard(room, 'new-' + room.localId));
  });

  documentList.addEventListener('change', async function (event) {
    const input = event.target.closest('input[type="file"][data-document-type]');
    if (!input || !input.files.length || state.busy) {
      return;
    }
    const file = input.files[0];
    const type = input.dataset.documentType;
    setBusy(true);
    try {
      if (file.size > 5 * 1024 * 1024) {
        throw new Error('Each verification document must be 5 MB or smaller.');
      }
      await saveApplication();
      const data = new FormData();
      data.append('file', file);
      await post(state.application.id + '/documents/' + type, data, true);
      state.application = await request('/' + state.application.id);
      renderDocuments();
      showAlert('Verification document uploaded.', 'success');
    } catch (error) {
      showAlert(error.message, 'danger');
    } finally {
      input.value = '';
      setBusy(false);
    }
  });

  documentList.addEventListener('click', async function (event) {
    const button = event.target.closest('[data-document-action="remove"]');
    if (!button || state.busy || !state.application) {
      return;
    }
    setBusy(true);
    try {
      await post(state.application.id + '/documents/' + button.dataset.documentType + '/delete',
        new URLSearchParams(), false);
      state.application = await request('/' + state.application.id);
      renderDocuments();
      showAlert('Document removed. Required documents must be uploaded before submission.', 'success');
    } catch (error) {
      showAlert(error.message, 'danger');
    } finally {
      setBusy(false);
    }
  });

  document.getElementById('partner-back').addEventListener('click', function () {
    if (!state.busy && state.step > 0) {
      changeStep(state.step - 1);
    }
  });

  document.getElementById('partner-next').addEventListener('click', async function () {
    if (state.busy) {
      return;
    }
    setBusy(true);
    try {
      await moveForward();
    } catch (error) {
      showAlert(error.message, 'danger');
    } finally {
      setBusy(false);
    }
  });

  document.getElementById('partner-save-draft').addEventListener('click', async function () {
    if (state.busy) {
      return;
    }
    setBusy(true);
    try {
      await saveApplication();
      await saveAllRooms();
      showAlert('Draft saved. You can return to complete it later.', 'success');
    } catch (error) {
      showAlert(error.message, 'danger');
    } finally {
      setBusy(false);
    }
  });

/**
 * Sends the final host application after all required sections are valid.
 * @returns {Promise<Object>} Server confirmation payload.
 */
  async function submitApplication() {
    clearAlert();
    for (let step = 0; step < 4; step++) {
      if (!validateStep(step)) {
        changeStep(step);
        return;
      }
    }
    const application = await saveApplication();
    const submitted = await post(application.id + '/submit', new URLSearchParams(), false);
    state.application = submitted;
    showStatus(submitted);
    showAlert('Application submitted successfully.', 'success');
  }

  document.getElementById('partner-submit').addEventListener('click', async function () {
    if (state.busy) {
      return;
    }
    setBusy(true);
    try {
      await submitApplication();
    } catch (error) {
      showAlert(error.message, 'danger');
    } finally {
      setBusy(false);
    }
  });

/**
 * Reopens a rejected draft so the applicant can edit and resubmit it.
 * @param {Object} rejectedApplication - Rejected draft object from the server.
 * @param {boolean} openReview - Whether the review panel should be displayed immediately.
 * @returns {Promise<void>} Resolves after the wizard is repopulated.
 */
  async function startRejectedDraft(rejectedApplication, openReview) {
    const values = new URLSearchParams();
    Object.keys(applicationFields).forEach(function (fieldName) {
      const value = rejectedApplication[fieldName];
      if (value !== null && value !== undefined) {
        values.set(fieldName, value);
      }
    });
    state.application = await post('', values, false);
    state.rooms = Array.isArray(state.application.rooms) ? state.application.rooms : [];
    setFormFromApplication(state.application, state.profile);
    renderRooms();
    renderDocuments();
    statusPanel.classList.add('d-none');
    wizard.classList.remove('d-none');
    changeStep(openReview ? 4 : 0);
    return state.application;
  }

  document.getElementById('partner-edit-rejected').addEventListener('click', async function () {
    if (state.busy || !state.initialRejected) {
      return;
    }
    setBusy(true);
    try {
      await startRejectedDraft(state.initialRejected, false);
      showAlert('Your rejected application has been copied into a new draft. Update it and resubmit.', 'info');
    } catch (error) {
      showAlert(error.message, 'danger');
    } finally {
      setBusy(false);
    }
  });

  document.getElementById('partner-resubmit-rejected').addEventListener('click', async function () {
    if (state.busy || !state.initialRejected) {
      return;
    }
    setBusy(true);
    try {
      await startRejectedDraft(state.initialRejected, true);
      await submitApplication();
    } catch (error) {
      showAlert(error.message, 'danger');
    } finally {
      setBusy(false);
    }
  });

/**
 * Initializes client-side OCR document recognition using Tesseract.js.
 * Scans uploaded National ID or Passport images and auto-fills applicant details.
 * @returns {void}
 */
/**
 * Initializes client-side OCR document recognition using Tesseract.js.
 * Scans uploaded National ID (CCCD) front and back images, extracts 12-digit number and name,
 * and auto-fills applicant details with instant feedback and visual animations.
 * @returns {void}
 */
function setupOcrRecognition() {
  const frontInput = document.getElementById('ocr-front-file');
  const backInput = document.getElementById('ocr-back-file');
  const frontDropzone = document.getElementById('ocr-dropzone-front');
  const backDropzone = document.getElementById('ocr-dropzone-back');
  const frontPreview = document.getElementById('ocr-front-preview');
  const backPreview = document.getElementById('ocr-back-preview');
  const frontPlaceholder = document.getElementById('ocr-front-placeholder');
  const backPlaceholder = document.getElementById('ocr-back-placeholder');
  const frontBadge = document.getElementById('ocr-front-badge');
  const backBadge = document.getElementById('ocr-back-badge');
  const progressBox = document.getElementById('ocr-progress-box');
  const progressBar = document.getElementById('ocr-progress-bar');
  const progressText = document.getElementById('ocr-status-text');
  const percentageText = document.getElementById('ocr-percentage');
  const resultBox = document.getElementById('ocr-result-box');
  const resultBadge = document.getElementById('ocr-result-badge');
  const resultDetails = document.getElementById('ocr-result-details');
  const sidesBadge = document.getElementById('ocr-sides-badge');
  const autofillHint = document.getElementById('ocr-autofill-hint');

  const ocrState = window.__ocrState || (window.__ocrState = {
    frontFile: null,
    backFile: null,
    frontData: null,
    backData: null,
    extractedNumber: '',
    extractedName: '',
    detectedType: 'NATIONAL_ID',
    worker: null
  });

  /** Parses raw OCR text for Vietnamese National ID (CCCD), Passport, and MRZ code. */
  function parseCccdText(text, side) {
    if (!text) return { number: '', type: 'NATIONAL_ID', name: '' };

    let number = '';
    let type = 'NATIONAL_ID';
    let name = '';

    // 1. Look for MRZ on back side: e.g. IDVNM0012010123456<<<<<<<<<<<<<
    const mrz12Match = text.match(/IDVNM\s*(\d{12})/i);
    const id12ColonMatch = text.match(/(?:Số|So|No\.?|SỐ|CCCD|CMND|Số\s*ĐDCN|ĐDCN)\s*[:：]?\s*(\d{12})/i);
    const id12Strict = text.match(/\b(0\d{11})\b/);
    const id12Any = text.match(/\b(\d{12})\b/);
    const passportMatch = text.match(/\b([A-Z]\d{7,8})\b/i);
    const id9Match = text.match(/\b(\d{9})\b/);

    if (mrz12Match) {
      number = mrz12Match[1];
      type = 'NATIONAL_ID';
    } else if (id12ColonMatch) {
      number = id12ColonMatch[1];
      type = 'NATIONAL_ID';
    } else if (id12Strict) {
      number = id12Strict[1];
      type = 'NATIONAL_ID';
    } else if (id12Any) {
      number = id12Any[1];
      type = 'NATIONAL_ID';
    } else if (passportMatch) {
      number = passportMatch[1].toUpperCase();
      type = 'PASSPORT';
    } else if (id9Match) {
      number = id9Match[1];
      type = 'NATIONAL_ID';
    }

    // 2. Extract Full Name
    const lines = text.split('\n').map(function (l) { return l.trim(); }).filter(Boolean);
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      if (/Họ\s*v[àa]\s*tên|Full\s*name/i.test(line)) {
        const parts = line.split(/[:：]/);
        if (parts.length > 1 && parts[1].trim().length > 3) {
          name = parts[1].trim();
          break;
        } else if (i + 1 < lines.length) {
          const nextLine = lines[i + 1].trim();
          if (/^[A-ZÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴĐ\s]{3,}$/.test(nextLine)) {
            name = nextLine;
            break;
          }
        }
      }
    }

    // Check MRZ format for name: e.g. NGUYEN<<VAN<A<<<<<<<<<<<<<<<
    if (!name) {
      const mrzNameMatch = text.match(/([A-Z]+)<<([A-Z<]+)/);
      if (mrzNameMatch) {
        const surname = mrzNameMatch[1];
        const givenNames = mrzNameMatch[2].replace(/</g, ' ').trim();
        if (surname && givenNames) {
          name = (surname + ' ' + givenNames).trim();
        }
      }
    }

    // Fallback uppercase line (Vietnamese name)
    if (!name) {
      for (let j = 0; j < lines.length; j++) {
        const line = lines[j];
        if (/^[A-ZÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴĐ]{2,}\s+[A-ZÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴĐ\s]+$/.test(line)
            && !/CỘNG\s*HÒA|VIỆT\s*NAM|ĐỘC\s*LẬP|CĂN\s*CƯỚC|CỤC\s*TRƯỞNG|GIÁM\s*ĐỐC|CÔNG\s*AN/i.test(line)) {
          name = line;
          break;
        }
      }
    }

    return { number: number, type: type, name: name };
  }

  /** Ensures Tesseract library is loaded. */
  function ensureTesseract() {
    return new Promise(function (resolve, reject) {
      if (typeof Tesseract !== 'undefined') {
        return resolve(window.Tesseract);
      }
      const script = document.createElement('script');
      script.src = 'https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js';
      script.onload = function () {
        if (typeof Tesseract !== 'undefined') {
          resolve(window.Tesseract);
        } else {
          reject(new Error('Tesseract script loaded but global Tesseract object missing.'));
        }
      };
      script.onerror = function () {
        // Fallback CDN
        const fallback = document.createElement('script');
        fallback.src = 'https://cdnjs.cloudflare.com/ajax/libs/tesseract.js/5.0.5/tesseract.min.js';
        fallback.onload = function () { resolve(window.Tesseract); };
        fallback.onerror = function () { reject(new Error('Không thể tải thư viện Tesseract OCR.')); };
        document.head.appendChild(fallback);
      };
      document.head.appendChild(script);
    });
  }

  /** Reuses or initializes Tesseract worker for high performance. */
  async function getWorker() {
    if (!ocrState.worker) {
      await ensureTesseract();
      ocrState.worker = await Tesseract.createWorker(['vie', 'eng'], 1, {
        logger: function (m) {
          if (m.status === 'recognizing text' && progressBar && percentageText) {
            const p = Math.round(m.progress * 100);
            progressBar.style.width = p + '%';
            percentageText.textContent = p + '%';
          }
        }
      });
    }
    return ocrState.worker;
  }

  /** Pre-scales large photos to max 1600px on canvas to speed up recognition & prevent mobile crashes. */
  function prepareImageForOcr(file) {
    return new Promise(function (resolve) {
      const img = new Image();
      const url = URL.createObjectURL(file);
      img.onload = function () {
        URL.revokeObjectURL(url);
        const maxDim = 1600;
        let w = img.width;
        let h = img.height;
        if (w > maxDim || h > maxDim) {
          if (w > h) {
            h = Math.round((h * maxDim) / w);
            w = maxDim;
          } else {
            w = Math.round((w * maxDim) / h);
            h = maxDim;
          }
        }
        const canvas = document.createElement('canvas');
        canvas.width = w;
        canvas.height = h;
        const ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0, w, h);
        canvas.toBlob(function (blob) {
          resolve(blob || file);
        }, 'image/jpeg', 0.92);
      };
      img.onerror = function () { resolve(file); };
      img.src = url;
    });
  }

  /** Merges front and back images vertically into a single image. */
  function mergeImages(file1, file2) {
    return new Promise(function (resolve) {
      const img1 = new Image();
      const img2 = new Image();
      const u1 = URL.createObjectURL(file1);
      const u2 = URL.createObjectURL(file2);
      let loaded = 0;

      function onLoaded() {
        loaded++;
        if (loaded < 2) return;
        URL.revokeObjectURL(u1);
        URL.revokeObjectURL(u2);

        const maxW = 1200;
        const s1 = maxW / img1.width;
        const w1 = maxW;
        const h1 = img1.height * s1;

        const s2 = maxW / img2.width;
        const w2 = maxW;
        const h2 = img2.height * s2;

        const canvas = document.createElement('canvas');
        canvas.width = maxW;
        canvas.height = Math.round(h1 + h2 + 20);
        const ctx = canvas.getContext('2d');

        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        ctx.drawImage(img1, 0, 0, w1, h1);
        ctx.drawImage(img2, 0, h1 + 20, w2, h2);

        canvas.toBlob(function (blob) {
          resolve(blob || file1);
        }, 'image/jpeg', 0.9);
      }

      img1.onload = onLoaded;
      img1.onerror = function () { resolve(file1); };
      img2.onload = onLoaded;
      img2.onerror = function () { resolve(file1); };

      img1.src = u1;
      img2.src = u2;
    });
  }

  /** Uploads composite identity document (front + back) or single image to Step 4. */
  async function uploadCombinedIdentityDocument() {
    if (!state.application || state.application.status !== 'DRAFT') return;

    try {
      let fileToUpload = ocrState.frontFile || ocrState.backFile;
      if (ocrState.frontFile && ocrState.backFile) {
        fileToUpload = await mergeImages(ocrState.frontFile, ocrState.backFile);
      }
      if (!fileToUpload) return;

      const formData = new FormData();
      formData.append('file', fileToUpload, 'identity_document.jpg');
      await post(state.application.id + '/documents/identity', formData, true, 'tải tài liệu định danh');
      state.application = await request('/' + state.application.id);
      renderDocuments();
    } catch (err) {
      // Non-blocking background sync
    }
  }

  /** Updates and auto-fills results into the form. */
  async function updateResults() {
    const front = ocrState.frontData || {};
    const back = ocrState.backData || {};

    const finalNumber = front.number || back.number || '';
    const finalName = front.name || back.name || '';
    const finalType = front.type || back.type || 'NATIONAL_ID';

    ocrState.extractedNumber = finalNumber;
    ocrState.extractedName = finalName;
    ocrState.detectedType = finalType;

    const numInput = document.getElementById('identification-number');
    const typeSelect = document.getElementById('identification-type');
    const nameInput = document.getElementById('applicant-name');

    if (finalNumber) {
      // 1. Auto-fill Document number
      setFormValue('identificationNumber', finalNumber);
      if (numInput) {
        numInput.value = finalNumber;
        numInput.classList.remove('is-invalid');
        numInput.classList.add('is-valid');
        numInput.classList.remove('ocr-highlight-success');
        void numInput.offsetWidth; // Trigger reflow for animation
        numInput.classList.add('ocr-highlight-success');
        setTimeout(function () {
          numInput.classList.remove('ocr-highlight-success');
        }, 3500);
        numInput.dispatchEvent(new Event('input', { bubbles: true }));
        numInput.dispatchEvent(new Event('change', { bubbles: true }));
      }

      // 2. Auto-select Document type
      setFormValue('identificationType', finalType);
      if (typeSelect) {
        typeSelect.value = finalType;
        typeSelect.dispatchEvent(new Event('change', { bubbles: true }));
      }
      updateIdentificationValidationUI();

      // 3. Auto-fill Name if available and current input is empty
      if (finalName && nameInput && !nameInput.value.trim()) {
        nameInput.value = finalName;
        setFormValue('applicantName', finalName);
        nameInput.dispatchEvent(new Event('input', { bubbles: true }));
      }

      // 4. Update Result Card
      if (resultBox && resultBadge && resultDetails) {
        resultBox.classList.remove('d-none', 'ocr-error');
        resultBadge.className = 'badge badge-success px-2 py-1 mr-2 mb-1';
        resultBadge.textContent = '✓ eKYC Nhận diện thành công';
        if (autofillHint) autofillHint.classList.remove('d-none');

        let detailsHtml = '<strong>Số CCCD:</strong> <span class="badge badge-primary px-2 py-1" style="font-size:0.95rem; font-family: monospace;">' + finalNumber + '</span>';
        if (finalName) {
          detailsHtml += ' &nbsp;|&nbsp; <strong>Họ tên:</strong> ' + finalName;
        }
        resultDetails.innerHTML = detailsHtml;

        if (sidesBadge) {
          const frontStatus = ocrState.frontData ? (ocrState.frontData.number ? 'Mặt trước: ✓' : 'Mặt trước: Đã quét') : 'Mặt trước: Chưa tải';
          const backStatus = ocrState.backData ? (ocrState.backData.number ? 'Mặt sau: ✓' : 'Mặt sau: Đã quét') : 'Mặt sau: Chưa tải';
          sidesBadge.textContent = '(' + frontStatus + ' | ' + backStatus + ')';
        }
      }

      showAlert('eKYC OCR: Đã trích xuất và tự động điền số CCCD (' + finalNumber + ') vào Document number.', 'success');

      // 5. Combine front and back images for Step 4 Identity Document
      uploadCombinedIdentityDocument();
    } else {
      // Neither side returned a valid number
      if (resultBox && resultBadge && resultDetails) {
        resultBox.classList.remove('d-none');
        resultBox.classList.add('ocr-error');
        resultBadge.className = 'badge badge-danger px-2 py-1 mr-2 mb-1';
        resultBadge.textContent = '⚠️ Chưa nhận diện được số CCCD';
        if (autofillHint) autofillHint.classList.add('d-none');
        resultDetails.innerHTML = '<span class="text-danger font-weight-bold">Ảnh bị mờ, lóa sáng hoặc mất góc.</span> Vui lòng chụp lại ảnh rõ nét hoặc tự nhập tay số CCCD vào trường bên dưới.';
        if (sidesBadge) {
          sidesBadge.textContent = '(Vui lòng tải thêm mặt còn lại hoặc chụp lại)';
        }
      }
    }
  }

  /**
   * Scans a single side (front or back).
   * Can be invoked from change event, drop event, or inline window.handleOcrFileScan().
   */
  async function handleFileScan(side, target) {
    let file = null;
    if (target instanceof File) {
      file = target;
    } else if (target && target.files && target.files[0]) {
      file = target.files[0];
    } else if (typeof target === 'object' && target && target.name && target.size) {
      file = target;
    }

    if (!file) return;

    const isFront = side === 'front';
    if (isFront) {
      ocrState.frontFile = file;
    } else {
      ocrState.backFile = file;
    }

    // Step 1: Immediate visual preview & badge update
    const previewImg = isFront ? frontPreview : backPreview;
    const placeholder = isFront ? frontPlaceholder : backPlaceholder;
    const sideBadge = isFront ? frontBadge : backBadge;

    if (previewImg) {
      previewImg.src = URL.createObjectURL(file);
      previewImg.classList.remove('d-none');
    }
    if (placeholder) {
      placeholder.classList.add('d-none');
    }
    if (sideBadge) {
      sideBadge.className = 'badge badge-warning ocr-badge';
      sideBadge.innerHTML = '<span class="spinner-border spinner-border-sm mr-1"></span> Đang quét...';
    }

    if (progressBox) {
      progressBox.classList.remove('d-none');
    }
    if (progressBar) {
      progressBar.style.width = '20%';
    }
    if (percentageText) {
      percentageText.textContent = '20%';
    }
    if (progressText) {
      progressText.textContent = 'Đang tiền xử lý ảnh mặt ' + (isFront ? 'trước' : 'sau') + ' CCCD...';
    }

    try {
      setBusy(true);

      // Preprocess image
      const preprocessedBlob = await prepareImageForOcr(file);

      if (progressBar) progressBar.style.width = '40%';
      if (percentageText) percentageText.textContent = '40%';
      if (progressText) progressText.textContent = 'Đang nhận diện ký tự (OCR)...';

      const worker = await getWorker();
      const result = await worker.recognize(preprocessedBlob);
      const text = (result && result.data && result.data.text) ? result.data.text : '';

      const parsed = parseCccdText(text, side);
      if (isFront) {
        ocrState.frontData = parsed;
      } else {
        ocrState.backData = parsed;
      }

      if (sideBadge) {
        if (parsed.number) {
          sideBadge.className = 'badge badge-success ocr-badge';
          sideBadge.textContent = '✓ Số: ' + parsed.number;
        } else {
          sideBadge.className = 'badge badge-info ocr-badge';
          sideBadge.textContent = '✓ Đã quét';
        }
      }

      if (progressBar) progressBar.style.width = '100%';
      if (percentageText) percentageText.textContent = '100%';
      if (progressText) progressText.textContent = 'Đã quét xong mặt ' + (isFront ? 'trước' : 'sau') + '!';

      await updateResults();
    } catch (err) {
      if (sideBadge) {
        sideBadge.className = 'badge badge-danger ocr-badge';
        sideBadge.textContent = 'Lỗi quét';
      }
      if (progressText) {
        progressText.textContent = 'Không thể quét ảnh: ' + (err.message || 'Lỗi xử lý OCR');
      }
      showAlert('Lỗi quét ảnh: ' + (err.message || 'Vui lòng kiểm tra lại ảnh hoặc tự nhập số định danh'), 'warning');
    } finally {
      setBusy(false);
      setTimeout(function () {
        if (progressBox) progressBox.classList.add('d-none');
      }, 1800);
    }
  }

  // Expose globally so inline onchange can call it directly
  window.handleOcrFileScan = handleFileScan;

  // Front file change listener
  if (frontInput && !frontInput.dataset.ocrAttached) {
    frontInput.dataset.ocrAttached = 'true';
    frontInput.addEventListener('change', function () {
      handleFileScan('front', this);
    });
  }

  // Back file change listener
  if (backInput && !backInput.dataset.ocrAttached) {
    backInput.dataset.ocrAttached = 'true';
    backInput.addEventListener('change', function () {
      handleFileScan('back', this);
    });
  }

  // Drag and drop support
  function setupDragDrop(zone, side) {
    if (!zone || zone.dataset.dropAttached) return;
    zone.dataset.dropAttached = 'true';

    ['dragenter', 'dragover'].forEach(function (eventName) {
      zone.addEventListener(eventName, function (e) {
        e.preventDefault();
        e.stopPropagation();
        zone.classList.add('dragover');
      });
    });
    ['dragleave', 'drop'].forEach(function (eventName) {
      zone.addEventListener(eventName, function (e) {
        e.preventDefault();
        e.stopPropagation();
        zone.classList.remove('dragover');
      });
    });
    zone.addEventListener('drop', function (e) {
      const dt = e.dataTransfer;
      const file = dt && dt.files && dt.files[0];
      if (file) {
        handleFileScan(side, file);
      }
    });
  }

  setupDragDrop(frontDropzone, 'front');
  setupDragDrop(backDropzone, 'back');
}

// Ensure OCR is initialized as soon as script runs or DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', setupOcrRecognition);
} else {
  setupOcrRecognition();
}

/**
 * Loads the page state, user profile, and any existing draft before showing the wizard.
 * @returns {Promise<void>} Resolves after the page data is hydrated.
 */
  async function loadPage() {
    const response = await request('/me');
    state.csrfToken = response.csrfToken;
    state.profile = response.profile || {};
    state.application = response.application || null;
    setFormFromApplication(state.application, state.profile);
    state.rooms = state.application && Array.isArray(state.application.rooms)
      ? state.application.rooms : [];
    if (state.application && state.application.status === 'DRAFT') {
      const stagedMedia = await request('/' + state.application.id + '/media');
      const stagedRooms = new Map();
      stagedMedia.forEach(function (media) {
        let room = stagedRooms.get(media.clientRoomKey);
        if (!room) {
          room = {
            localId: Date.now() + stagedRooms.size,
            clientRoomKey: media.clientRoomKey,
            amenities: [],
            images: []
          };
          stagedRooms.set(media.clientRoomKey, room);
        }
        media.staged = true;
        room.images.push(media);
      });
      stagedRooms.forEach(function (room) {
        state.rooms.push(room);
      });
    }

    loading.classList.add('d-none');
    if (state.application && ['PENDING', 'APPROVED', 'REJECTED'].includes(state.application.status)) {
      state.initialRejected = state.application.status === 'REJECTED' ? state.application : null;
      showStatus(state.application);
      return;
    }
    wizard.classList.remove('d-none');
    renderRooms();
    renderDocuments();
    setupOcrRecognition();
    setupAddressAutocomplete();
    setupIdentificationValidation();
    changeStep(0);
    if (state.application) {
      showAlert('Your saved draft has been restored.', 'info');
    }
  }

  /**
   * Initializes address search/autocomplete using Nominatim OpenStreetMap and GPS Geolocation.
   */
  function setupAddressAutocomplete() {
    const addressInput = document.getElementById('property-address');
    const searchBtn = document.getElementById('btn-search-address');
    const gpsBtn = document.getElementById('btn-use-gps');
    const suggestionsList = document.getElementById('address-suggestions');
    const hintText = document.getElementById('address-search-hint');

    if (!addressInput) return;

    let debounceTimer;

    async function searchLocation(query) {
      if (!query || query.trim().length < 3) {
        if (suggestionsList) suggestionsList.classList.add('d-none');
        return;
      }

      try {
        if (hintText) hintText.textContent = 'Đang tìm kiếm địa chỉ trên bản đồ...';
        const url = 'https://nominatim.openstreetmap.org/search?format=json&addressdetails=1&limit=5&countrycodes=vn&q=' + encodeURIComponent(query);
        const res = await fetch(url, { headers: { 'Accept-Language': 'vi' } });
        const data = await res.json();

        if (!suggestionsList) return;
        suggestionsList.replaceChildren();

        if (!data || data.length === 0) {
          if (hintText) hintText.textContent = 'Không tìm thấy địa chỉ phù hợp. Bạn có thể tự điền các trường bên dưới.';
          suggestionsList.classList.add('d-none');
          return;
        }

        data.forEach(function (place) {
          const item = document.createElement('button');
          item.type = 'button';
          item.className = 'list-group-item list-group-item-action py-2 text-left';
          item.innerHTML = '<strong>' + (place.display_name.split(',')[0]) + '</strong> <small class="text-muted d-block">' + place.display_name + '</small>';
          
          item.addEventListener('click', function () {
            applyAddressData(place);
            suggestionsList.classList.add('d-none');
          });

          suggestionsList.appendChild(item);
        });

        suggestionsList.classList.remove('d-none');
        if (hintText) hintText.textContent = 'Chọn một địa chỉ từ danh sách gợi ý để tự động điền.';
      } catch (err) {
        if (hintText) hintText.textContent = 'Không thể kết nối dịch vụ bản đồ. Bạn có thể tự điền tay địa chỉ.';
      }
    }

    function applyAddressData(place) {
      if (!place) return;
      const addr = place.address || {};
      
      addressInput.value = place.display_name.split(',')[0] || addressInput.value;
      
      const city = addr.city || addr.province || addr.state || addr.municipality || '';
      if (city) setFormValue('propertyCity', city);

      const district = addr.suburb || addr.district || addr.county || addr.city_district || '';
      if (district) setFormValue('propertyDistrict', district);

      const ward = addr.quarter || addr.neighbourhood || addr.village || addr.ward || '';
      if (ward) setFormValue('propertyWard', ward);

      if (place.lat) setFormValue('latitude', parseFloat(place.lat).toFixed(6));
      if (place.lon) setFormValue('longitude', parseFloat(place.lon).toFixed(6));

      if (hintText) {
        hintText.innerHTML = '<span class="text-success font-weight-bold">✓ Đã tự động cập nhật Tỉnh/Thành phố, Quận/Huyện và Tọa độ bản đồ!</span>';
      }
    }

    if (searchBtn) {
      searchBtn.addEventListener('click', function () {
        searchLocation(addressInput.value);
      });
    }

    addressInput.addEventListener('input', function () {
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(function () {
        searchLocation(addressInput.value);
      }, 600);
    });

    document.addEventListener('click', function (e) {
      if (suggestionsList && !suggestionsList.contains(e.target) && e.target !== addressInput && e.target !== searchBtn) {
        suggestionsList.classList.add('d-none');
      }
    });

    if (gpsBtn) {
      gpsBtn.addEventListener('click', function () {
        if (!navigator.geolocation) {
          showAlert('Trình duyệt của bạn không hỗ trợ định vị GPS.', 'warning');
          return;
        }

        gpsBtn.disabled = true;
        gpsBtn.textContent = '⏳ Đang lấy vị trí...';

        navigator.geolocation.getCurrentPosition(
          async function (pos) {
            const lat = pos.coords.latitude;
            const lng = pos.coords.longitude;
            setFormValue('latitude', lat.toFixed(6));
            setFormValue('longitude', lng.toFixed(6));

            try {
              const revUrl = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=' + lat + '&lon=' + lng;
              const res = await fetch(revUrl, { headers: { 'Accept-Language': 'vi' } });
              const place = await res.json();
              if (place) {
                applyAddressData(place);
                showAlert('Đã xác định vị trí hiện tại và tự động điền địa chỉ!', 'success');
              }
            } catch (e) {
              showAlert('Đã cập nhật tọa độ GPS thành công!', 'success');
            } finally {
              gpsBtn.disabled = false;
              gpsBtn.textContent = '📍 Lấy tọa độ GPS hiện tại';
            }
          },
          function (err) {
            gpsBtn.disabled = false;
            gpsBtn.textContent = '📍 Lấy tọa độ GPS hiện tại';
            showAlert('Không thể lấy vị trí hiện tại: ' + (err.message || 'Quyền truy cập bị từ chối'), 'warning');
          },
          { timeout: 10000, enableHighAccuracy: true }
        );
      });
    }
  }

  /**
   * Initializes real-time validation and format helper for National ID (CCCD) and Passport.
   */
  function setupIdentificationValidation() {
    const numInput = document.getElementById('identification-number');
    const typeSelect = document.getElementById('identification-type');
    const feedbackEl = document.getElementById('identification-feedback');
    if (!numInput || !typeSelect || !feedbackEl) return;

    // Filter input characters and validate on typing
    numInput.addEventListener('input', function () {
      if (typeSelect.value === 'NATIONAL_ID') {
        // Strip non-digits and cap at 12 digits
        const stripped = this.value.replace(/\D/g, '').slice(0, 12);
        if (this.value !== stripped) {
          this.value = stripped;
        }
      }
      setFormValue('identificationNumber', this.value);
      updateIdentificationValidationUI();
    });

    // Update rules and placeholder when document type changes
    typeSelect.addEventListener('change', function () {
      setFormValue('identificationType', this.value);
      if (this.value === 'NATIONAL_ID' && numInput.value) {
        numInput.value = numInput.value.replace(/\D/g, '').slice(0, 12);
        setFormValue('identificationNumber', numInput.value);
      }
      updateIdentificationValidationUI();
    });

    // Initial check on load
    updateIdentificationValidationUI();
  }

  loadPage().catch(function (error) {
    loading.classList.add('d-none');
    showAlert(error.message, 'danger');
    const signIn = document.createElement('a');
    signIn.className = 'btn btn-primary';
    signIn.href = homeUrl;
    signIn.textContent = 'Return to home';
    alertBox.appendChild(document.createElement('br'));
    alertBox.appendChild(signIn);
  });
}());
