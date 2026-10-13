/**
 * password-policy.js
 * Reusable dynamic password checklist validation and confirmation matcher.
 */
(function (global) {
  'use strict';

  /**
   * Initializes real-time password policy validation on target input fields.
   * @param {Object} options Configuration options
   * @param {string} options.passwordInputId ID of the password input
   * @param {string} [options.confirmInputId] ID of the confirmation input
   * @param {string} [options.usernameInputId] ID or string of username to blacklist
   * @param {string} [options.emailInputId] ID or string of email to blacklist
   * @param {string} [options.feedbackId] ID of the confirm password feedback element
   * @param {string} [options.ruleListId] ID of the rule list container (default: 'pwdRuleList')
   * @param {Function} [options.onChange] Callback when valid state changes (boolean isValid)
   */
  function initPasswordPolicy(options) {
    var pwdInput = document.getElementById(options.passwordInputId);
    var confirmInput = options.confirmInputId ? document.getElementById(options.confirmInputId) : null;
    var feedback = options.feedbackId ? document.getElementById(options.feedbackId) : null;

    if (!pwdInput) return;

    function getBlacklistValues() {
      var u = '';
      var e = '';

      if (options.usernameInputId) {
        var uEl = document.getElementById(options.usernameInputId);
        u = (uEl ? uEl.value : options.usernameInputId).toLowerCase().trim();
      }
      if (options.emailInputId) {
        var eEl = document.getElementById(options.emailInputId);
        e = (eEl ? eEl.value : options.emailInputId).toLowerCase().trim();
      }

      var eLocal = e.indexOf('@') !== -1 ? e.substring(0, e.indexOf('@')) : e;
      return { username: u, emailLocal: eLocal };
    }

    function updateRule(elementId, isValid) {
      var el = document.getElementById(elementId);
      if (!el) return;
      var icon = el.querySelector('.rule-icon');
      if (isValid) {
        el.className = 'text-success font-weight-bold';
        if (icon) icon.textContent = '✓';
      } else {
        el.className = 'text-muted';
        if (icon) icon.textContent = '⚪';
      }
    }

    function checkRules() {
      var val = pwdInput.value;
      var blacklist = getBlacklistValues();

      // Rule: Length 8-128 & no space
      var validLength = val.length >= 8 && val.length <= 128 && val.indexOf(' ') === -1;
      updateRule('rule-length', validLength);

      // Rule: Upper and lower case
      var validCasing = /[a-z]/.test(val) && /[A-Z]/.test(val);
      updateRule('rule-casing', validCasing);

      // Rule: Number and special char
      var validNumSpecial = /\d/.test(val) && /[!@#$%^&*()_+\-=\[\]{}|;:',.<>?/\\`~]/.test(val);
      updateRule('rule-number-special', validNumSpecial);

      // Rule: Not containing username or email local-part
      var lower = val.toLowerCase();
      var containsIdentity = false;
      if (blacklist.username && blacklist.username.length >= 3 && lower.indexOf(blacklist.username) !== -1) {
        containsIdentity = true;
      }
      if (blacklist.emailLocal && blacklist.emailLocal.length >= 3 && lower.indexOf(blacklist.emailLocal) !== -1) {
        containsIdentity = true;
      }
      var validNotUser = val.length > 0 && !containsIdentity;
      updateRule('rule-not-user', validNotUser);

      var isAllValid = validLength && validCasing && validNumSpecial && validNotUser;

      if (confirmInput) {
        checkConfirmMatch();
      }

      if (typeof options.onChange === 'function') {
        options.onChange(isAllValid);
      }

      return isAllValid;
    }

    function checkConfirmMatch() {
      if (!confirmInput) return true;
      var newP = pwdInput.value;
      var confP = confirmInput.value;

      if (!confP) {
        if (feedback) feedback.className = 'form-text mt-1 d-none';
        return false;
      }

      if (newP === confP) {
        if (feedback) {
          feedback.className = 'form-text mt-1 text-success font-weight-bold';
          feedback.textContent = '✓ Mật khẩu xác nhận khớp.';
        }
        return true;
      } else {
        if (feedback) {
          feedback.className = 'form-text mt-1 text-danger';
          feedback.textContent = '✗ Mật khẩu xác nhận chưa khớp.';
        }
        return false;
      }
    }

    pwdInput.addEventListener('input', checkRules);
    if (confirmInput) {
      confirmInput.addEventListener('input', checkConfirmMatch);
    }

    if (options.usernameInputId && document.getElementById(options.usernameInputId)) {
      document.getElementById(options.usernameInputId).addEventListener('input', checkRules);
    }
    if (options.emailInputId && document.getElementById(options.emailInputId)) {
      document.getElementById(options.emailInputId).addEventListener('input', checkRules);
    }

    return {
      isValid: checkRules,
      isMatch: checkConfirmMatch
    };
  }

  global.initPasswordPolicy = initPasswordPolicy;
})(window);
