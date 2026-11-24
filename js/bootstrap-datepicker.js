/**
 * Neutralized bootstrap-datepicker stub.
 * In this application, all date selection is strictly handled by
 * native HTML5 <input type="date"> (Vietnamese browser calendar).
 */
(function($) {
  'use strict';
  if (typeof $ !== 'undefined' && $) {
    $.fn.datepicker = function() {
      return this;
    };
    $.fn.datepicker.DPGlobal = {};
    $.fn.datepicker.noConflict = function() { return this; };
    $.fn.datepicker.defaults = {};
    $.fn.datepicker.dates = {};
  }
})(window.jQuery);