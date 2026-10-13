/**
 * Administration panel for reviewing host applications.
 * The flow loads the applicant queue, renders the selected record, and submits approve or reject actions with CSRF validation.
 */
(function () {
  'use strict';

  const page = document.getElementById('host-applications-admin');
  if (!page) {
    return;
  }

  const apiBase = page.dataset.apiBase;
  const alertBox = document.getElementById('admin-host-alert');
  const loading = document.getElementById('host-application-loading');
  const table = document.getElementById('host-application-table');
  const rows = document.getElementById('host-application-rows');
  const empty = document.getElementById('host-application-empty');
  const pagination = document.getElementById('host-application-pagination');
  const listPanel = document.getElementById('host-application-list');
  const detailPanel = document.getElementById('host-application-detail');
  const detailContent = document.getElementById('host-detail-content');
  const rejectDialog = document.getElementById('host-reject-dialog');
  const state = {
    applications: [],
    csrfToken: null,
    page: 1,
    pageSize: 10,
    selectedApplication: null,
    busy: false
  };

/**
 * Displays a top-level admin notification for the current review action.
 * @param {string} message - Error or success text to show.
 * @param {string} type - Bootstrap alert variant.
 * @returns {void}
 */
  function showAlert(message, type) {
    alertBox.className = 'alert alert-' + type;
    alertBox.textContent = message;
    alertBox.classList.remove('d-none');
    alertBox.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }

/**
 * Clears the active admin alert.
 * @returns {void}
 */
  function clearAlert() {
    alertBox.textContent = '';
    alertBox.className = 'alert d-none';
  }

/**
 * Disable interactive controls while a review request is in progress.
 * @param {boolean} busy - Whether the page should be locked.
 * @returns {void}
 */
  function setBusy(busy) {
    state.busy = busy;
    page.querySelectorAll('button, select, input, textarea').forEach(function (control) {
      control.disabled = busy;
    });
    page.setAttribute('aria-busy', String(busy));
  }

/**
 * Parses and validates the JSON response returned by the review API.
 * @param {Response} response - HTTP response object.
 * @returns {Promise<Object>} The server response payload.
 */
  async function readResponse(response) {
    const contentType = response.headers.get('content-type') || '';
    const body = contentType.includes('application/json') ? await response.json() : {};
    if (!response.ok) {
      throw new Error(body.message || 'The request could not be completed.');
    }
    return body;
  }

/**
 * Builds the review list URL with the selected status filter.
 * @returns {string} The filtered listing endpoint.
 */
  function listUrl() {
    const status = document.getElementById('host-application-status').value;
    return apiBase + (status ? '?status=' + encodeURIComponent(status) : '');
  }

/**
 * Loads the application queue and resets the table to page one.
 * @returns {Promise<void>} Resolves after the list is refreshed.
 */
  async function loadApplications() {
    loading.classList.remove('d-none');
    table.classList.add('d-none');
    const response = await fetch(listUrl(), {
      credentials: 'same-origin',
      headers: { Accept: 'application/json' }
    });
    const body = await readResponse(response);
    state.csrfToken = body.csrfToken;
    state.applications = Array.isArray(body.applications) ? body.applications : [];
    state.page = 1;
    renderApplications();
    loading.classList.add('d-none');
    table.classList.remove('d-none');
  }

/**
 * Loads one application record for the detail panel.
 * @param {string|number} applicationId - Application identifier.
 * @returns {Promise<Object>} Detailed application payload.
 */
  async function loadDetail(applicationId) {
    const response = await fetch(apiBase + '/' + encodeURIComponent(applicationId), {
      credentials: 'same-origin',
      headers: { Accept: 'application/json' }
    });
    return readResponse(response);
  }

/**
 * Posts an approval or rejection decision and refreshes the list afterward.
 * @param {string} action - Review action: approve or reject.
 * @param {string} [reason] - Rejection reason when applicable.
 * @returns {Promise<Object>} Server confirmation payload.
 */
  async function submitReview(action, reason) {
    const application = state.selectedApplication;
    if (!application || application.status !== 'PENDING') {
      throw new Error('Only pending applications can be reviewed.');
    }
    // CSRF must be refreshed before each approval/rejection request because the server invalidates it.
    if (!state.csrfToken) {
      await loadApplications();
    }

    const body = new URLSearchParams();
    body.set('csrfToken', state.csrfToken);
    if (action === 'reject') {
      body.set('rejectionReason', reason);
    }

    let result;
    let requestError;
    try {
      const response = await fetch(apiBase + '/' + application.id + '/' + action, {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
        },
        body: body.toString()
      });
      result = await readResponse(response);
    } catch (error) {
      requestError = error;
    }
    // Each review POST consumes its CSRF token, whether it succeeds or fails.
    try {
      await loadApplications();
    } catch (error) {
      if (!requestError) {
        requestError = error;
      }
    }
    if (requestError) {
      throw requestError;
    }
    return result;
  }

/**
 * Formats a JavaScript date for the detail panel.
 * @param {string|null} value - ISO timestamp or null value.
 * @returns {string} Human-friendly date text.
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
 * Creates a styled status label for the application table.
 * @param {string} status - Application status such as PENDING or APPROVED.
 * @returns {HTMLElement} The badge element.
 */
  function createStatusBadge(status) {
    const badge = document.createElement('span');
    badge.className = 'admin-host-badge ' + status.toLowerCase();
    badge.textContent = status.charAt(0) + status.slice(1).toLowerCase();
    return badge;
  }

/**
 * Normalizes a table cell value and shows a placeholder when empty.
 * @param {*} value - Raw table value.
 * @returns {HTMLTableCellElement} The created cell element.
 */
  function createCell(value) {
    const cell = document.createElement('td');
    cell.textContent = value === null || value === undefined || value === ''
      ? '—' : String(value);
    return cell;
  }

/**
 * Filters the current application list by the admin search term.
 * @returns {Array<Object>} Matching application records.
 */
  function filteredApplications() {
    const term = document.getElementById('host-application-search').value
      .trim().toLocaleLowerCase();
    if (!term) {
      return state.applications;
    }
    return state.applications.filter(function (application) {
      return [
        application.applicantName,
        application.applicantEmail,
        application.propertyName
      ].some(function (value) {
        return String(value || '').toLocaleLowerCase().includes(term);
      });
    });
  }

/**
 * Renders the filtered list and pagination summary for the current page.
 * @returns {void}
 */
  function renderApplications() {
    const applications = filteredApplications();
    const pageCount = Math.max(1, Math.ceil(applications.length / state.pageSize));
    state.page = Math.min(state.page, pageCount);
    const start = (state.page - 1) * state.pageSize;
    const visibleApplications = applications.slice(start, start + state.pageSize);
    rows.replaceChildren();

    visibleApplications.forEach(function (application) {
      const row = document.createElement('tr');
      row.appendChild(createCell(application.id));
      row.appendChild(createCell(application.applicantName));
      row.appendChild(createCell(application.applicantEmail));
      row.appendChild(createCell(application.propertyName));
      row.appendChild(createCell(application.propertyType));
      row.appendChild(createCell(formatDate(application.submittedAt)));

      const status = document.createElement('td');
      status.appendChild(createStatusBadge(application.status));
      row.appendChild(status);

      const actions = document.createElement('td');
      const view = document.createElement('button');
      view.type = 'button';
      view.className = 'btn btn-sm btn-outline-primary';
      view.textContent = 'View';
      view.dataset.applicationId = application.id;
      view.dataset.action = 'view';
      actions.appendChild(view);
      row.appendChild(actions);
      rows.appendChild(row);
    });

    const hasResults = applications.length > 0;
    empty.classList.toggle('d-none', hasResults);
    table.classList.toggle('d-none', !hasResults && loading.classList.contains('d-none'));
    pagination.classList.toggle('d-none', !hasResults);
    document.getElementById('host-application-page-summary').textContent =
      hasResults ? 'Page ' + state.page + ' of ' + pageCount
        + ' · ' + applications.length + ' application(s)' : '';
    document.getElementById('host-application-prev').disabled = state.page <= 1;
    document.getElementById('host-application-next').disabled = state.page >= pageCount;
  }

/**
 * Adds a labeled metadata section to the application detail panel.
 * @param {string} title - Section heading.
 * @param {Array<Object>} entries - Fields and values for the section.
 * @returns {void}
 */
  function addDetailSection(title, entries) {
    const section = document.createElement('section');
    section.className = 'admin-host-detail-section';
    const heading = document.createElement('h3');
    heading.className = 'h5 mb-3';
    heading.textContent = title;
    const list = document.createElement('dl');
    list.className = 'row admin-host-detail-list mb-0';
    entries.forEach(function (entry) {
      const term = document.createElement('dt');
      const value = document.createElement('dd');
      term.className = 'col-sm-4';
      value.className = 'col-sm-8';
      term.textContent = entry.label;
      if (entry.href) {
        const link = document.createElement('a');
        link.href = entry.href;
        link.target = '_blank';
        link.rel = 'noopener';
        link.textContent = entry.value || 'View document';
        value.appendChild(link);
      } else {
        value.textContent = entry.value === null || entry.value === undefined || entry.value === ''
          ? '—' : String(entry.value);
      }
      list.append(term, value);
    });
    section.append(heading, list);
    detailContent.appendChild(section);
  }

/**
 * Renders room cards inside the selected application detail view.
 * @param {Array<Object>} rooms - Room records attached to the application.
 * @returns {void}
 */
  function renderRooms(rooms) {
    const section = document.createElement('section');
    section.className = 'admin-host-detail-section';
    const heading = document.createElement('h3');
    heading.className = 'h5 mb-3';
    heading.textContent = 'Room Information';
    section.appendChild(heading);
    if (!rooms || !rooms.length) {
      const note = document.createElement('p');
      note.className = 'text-muted';
      note.textContent = 'No rooms were included in this application.';
      section.appendChild(note);
      detailContent.appendChild(section);
      return;
    }

    rooms.forEach(function (room) {
      const card = document.createElement('article');
      card.className = 'admin-host-room';
      const title = document.createElement('h4');
      title.className = 'h6';
      title.textContent = room.roomName || 'Room';
      const details = document.createElement('p');
      details.className = 'mb-2';
      details.textContent = [
        'Type: ' + (room.roomType || '—'),
        'Price: ' + (room.pricePerNight || '—'),
        'Maximum guests: ' + (room.maxGuests || '—'),
        'Beds: ' + (room.bedCount || '—'),
        'Bathrooms: ' + (room.bathroomCount || '—')
      ].join(' · ');
      const amenities = document.createElement('p');
      amenities.className = 'small text-muted mb-2';
      amenities.textContent = 'Amenities: '
        + ((room.amenities || []).length ? room.amenities.join(', ') : 'None listed');
      card.append(title, details, amenities);

      if (room.images && room.images.length) {
        const imageList = document.createElement('div');
        imageList.className = 'admin-host-images';
        room.images.forEach(function (image) {
          if (image.mediaType === 'VIDEO') {
            const preview = document.createElement('video');
            preview.src = image.url;
            preview.controls = true;
            preview.preload = 'metadata';
            imageList.appendChild(preview);
          } else {
            const link = document.createElement('a');
            link.href = image.url;
            link.target = '_blank';
            link.rel = 'noopener';
            const preview = document.createElement('img');
            preview.src = image.url;
            preview.alt = 'Room photo';
            link.appendChild(preview);
            imageList.appendChild(link);
          }
        });
        card.appendChild(imageList);
      }
      section.appendChild(card);
    });
    detailContent.appendChild(section);
  }

/**
 * Populates the detail panel with the selected host application record.
 * @param {Object} application - Full application payload from the server.
 * @returns {void}
 */
  function renderDetail(application) {
    // The detail view is driven by the selected review record, so keep the current record in state.
    state.selectedApplication = application;
    document.getElementById('host-detail-title').textContent =
      'Host Application #' + application.id;
    detailContent.replaceChildren();

    addDetailSection('Applicant Information', [
      { label: 'Full name', value: application.applicantName },
      { label: 'Email', value: application.applicantEmail },
      { label: 'Phone', value: application.applicantPhone },
      { label: 'User ID', value: application.userId },
      { label: 'Identification', value: application.identificationType
        ? application.identificationType + ' · ' + (application.identificationNumber || '')
        : application.identificationNumber }
    ]);
    addDetailSection('Property Information', [
      { label: 'Property name', value: application.propertyName },
      { label: 'Property type', value: application.propertyType },
      { label: 'Description', value: application.propertyDescription },
      { label: 'Address', value: application.propertyAddress },
      { label: 'City', value: application.propertyCity },
      { label: 'District', value: application.propertyDistrict },
      { label: 'Ward', value: application.propertyWard },
      { label: 'Location', value: application.latitude !== null && application.longitude !== null
        ? application.latitude + ', ' + application.longitude : null },
      { label: 'Rooms / maximum guests', value: application.roomCount !== null
        ? application.roomCount + ' / ' + application.maxGuests : null }
    ]);
    renderRooms(application.rooms);

    const documents = [
      { label: 'Identity document', href: application.identityDocumentUrl },
      { label: 'Property ownership / authorization document', href: application.ownershipDocumentUrl },
      { label: 'Business document', href: application.businessDocumentUrl }
    ];
    addDetailSection('Verification Information', documents.map(function (document) {
      return {
        label: document.label,
        value: document.href ? 'Open uploaded document' : 'Not provided',
        href: document.href
      };
    }));

    const history = [
      { label: 'Status', value: application.status },
      { label: 'Submitted date', value: formatDate(application.submittedAt) },
      { label: 'Reviewed date', value: formatDate(application.reviewedAt) },
      { label: 'Reviewer', value: application.reviewerName },
      { label: 'Previous application ID', value: application.supersedesApplicationId },
      { label: 'Rejection reason', value: application.rejectionReason }
    ];
    addDetailSection('Application Information', history);

    const canReview = application.status === 'PENDING';
    document.getElementById('host-detail-approve').classList.toggle('d-none', !canReview);
    document.getElementById('host-detail-reject').classList.toggle('d-none', !canReview);
    listPanel.classList.add('d-none');
    detailPanel.classList.remove('d-none');
  }

/**
 * Opens the rejection modal and focuses the reason field.
 * @returns {void}
 */
  function openRejectDialog() {
    document.getElementById('host-rejection-reason').value = '';
    rejectDialog.classList.remove('d-none');
    document.getElementById('host-rejection-reason').focus();
  }

/**
 * Hides the rejection modal without clearing the selected application.
 * @returns {void}
 */
  function closeRejectDialog() {
    rejectDialog.classList.add('d-none');
  }

/**
 * Submits the final decision and refreshes the detail panel afterward.
 * @param {string} action - Review action: approve or reject.
 * @param {string} [reason] - Rejection reason text.
 * @returns {Promise<void>} Resolves after the decision is completed.
 */
  async function review(action, reason) {
    // Finalize the decision and refresh the detail panel so the admin queue stays in sync.
    setBusy(true);
    clearAlert();
    try {
      await submitReview(action, reason);
      closeRejectDialog();
      const message = action === 'approve'
        ? 'Host Application approved. The Customer account has been promoted to HOST.'
        : 'Host Application rejected. The applicant remains a CUSTOMER.';
      showAlert(message, 'success');
      if (state.selectedApplication) {
        const updated = await loadDetail(state.selectedApplication.id);
        renderDetail(updated);
      }
    } catch (error) {
      showAlert(error.message, 'danger');
    } finally {
      setBusy(false);
    }
  }

  rows.addEventListener('click', async function (event) {
    const button = event.target.closest('[data-action="view"]');
    if (!button || state.busy) {
      return;
    }
    setBusy(true);
    clearAlert();
    document.getElementById('host-detail-loading').classList.remove('d-none');
    listPanel.classList.add('d-none');
    detailPanel.classList.remove('d-none');
    detailContent.replaceChildren();
    try {
      const application = await loadDetail(button.dataset.applicationId);
      renderDetail(application);
    } catch (error) {
      detailPanel.classList.add('d-none');
      listPanel.classList.remove('d-none');
      showAlert(error.message, 'danger');
    } finally {
      document.getElementById('host-detail-loading').classList.add('d-none');
      setBusy(false);
    }
  });

  document.getElementById('host-detail-close').addEventListener('click', function () {
    detailPanel.classList.add('d-none');
    listPanel.classList.remove('d-none');
    state.selectedApplication = null;
  });

  document.getElementById('host-detail-approve').addEventListener('click', function () {
    if (state.busy || !state.selectedApplication
        || state.selectedApplication.status !== 'PENDING') {
      return;
    }
    if (window.confirm('Are you sure you want to approve this Host application?')) {
      review('approve', '');
    }
  });

  document.getElementById('host-detail-reject').addEventListener('click', function () {
    if (!state.busy && state.selectedApplication
        && state.selectedApplication.status === 'PENDING') {
      openRejectDialog();
    }
  });

  document.getElementById('host-reject-confirm').addEventListener('click', function () {
    if (state.busy) {
      return;
    }
    const field = document.getElementById('host-rejection-reason');
    const reason = field.value.trim();
    if (reason.length < 10 || reason.length > 500) {
      field.setCustomValidity('Enter a rejection reason between 10 and 500 characters.');
      field.reportValidity();
      field.setCustomValidity('');
      field.focus();
      return;
    }
    review('reject', reason);
  });

  document.getElementById('host-reject-cancel').addEventListener('click', closeRejectDialog);
  rejectDialog.addEventListener('click', function (event) {
    if (event.target.matches('[data-dialog-close]') && !state.busy) {
      closeRejectDialog();
    }
  });
  document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape' && !state.busy) {
      closeRejectDialog();
    }
  });

  document.getElementById('host-application-status').addEventListener('change', async function () {
    if (state.busy) {
      return;
    }
    setBusy(true);
    clearAlert();
    try {
      await loadApplications();
    } catch (error) {
      showAlert(error.message, 'danger');
    } finally {
      setBusy(false);
    }
  });

  document.getElementById('host-application-search').addEventListener('input', function () {
    state.page = 1;
    renderApplications();
  });

  document.getElementById('host-application-prev').addEventListener('click', function () {
    if (state.page > 1) {
      state.page--;
      renderApplications();
    }
  });

  document.getElementById('host-application-next').addEventListener('click', function () {
    state.page++;
    renderApplications();
  });

  loadApplications().catch(function (error) {
    loading.classList.add('d-none');
    table.classList.add('d-none');
    showAlert(error.message, 'danger');
  });
}());
