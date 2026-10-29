/**
 * Sogo Homestay - Theme Toggle Controller (Light / Dark Mode)
 * Supports desktop navbar toggle & mobile drawer toggle with smooth state syncing.
 */
(function() {
  'use strict';

  var STORAGE_KEY = 'sogo_theme';

  function getSystemPreference() {
    return (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) ? 'dark' : 'light';
  }

  function getCurrentTheme() {
    var stored = null;
    try {
      stored = localStorage.getItem(STORAGE_KEY);
    } catch (e) {
      console.warn('LocalStorage not accessible for theme persistence:', e);
    }
    return stored || getSystemPreference();
  }

  function updateToggleUI(theme) {
    var isDark = (theme === 'dark');
    var toggleButtons = document.querySelectorAll('.theme-toggle-btn');
    var toggleLabels = document.querySelectorAll('.theme-toggle-label');
    var drawerStatus = document.getElementById('drawerThemeStatus');

    toggleButtons.forEach(function(btn) {
      btn.setAttribute('aria-checked', isDark ? 'true' : 'false');
      btn.setAttribute('title', isDark ? 'Chuyển sang Giao diện Sáng' : 'Chuyển sang Giao diện Tối');
    });

    toggleLabels.forEach(function(label) {
      label.textContent = isDark ? 'Tối' : 'Sáng';
    });

    if (drawerStatus) {
      drawerStatus.textContent = isDark ? 'Chế độ Tối' : 'Chế độ Sáng';
    }
  }

  function applyTheme(theme, persist) {
    if (theme !== 'dark' && theme !== 'light') {
      theme = 'light';
    }

    document.documentElement.setAttribute('data-theme', theme);
    if (document.body) {
      document.body.setAttribute('data-theme', theme);
    }

    if (theme === 'dark') {
      document.documentElement.classList.add('dark-mode');
      document.documentElement.classList.remove('light-mode');
      if (document.body) {
        document.body.classList.add('dark-mode');
        document.body.classList.remove('light-mode');
      }
    } else {
      document.documentElement.classList.remove('dark-mode');
      document.documentElement.classList.add('light-mode');
      if (document.body) {
        document.body.classList.remove('dark-mode');
        document.body.classList.add('light-mode');
      }
    }

    if (persist !== false) {
      try {
        localStorage.setItem(STORAGE_KEY, theme);
      } catch (e) {
        console.warn('Could not save theme to LocalStorage:', e);
      }
    }

    updateToggleUI(theme);

    // Dispatch custom event for any widgets or charts that need to react
    try {
      var event = new CustomEvent('sogo:themechange', { detail: { theme: theme, isDark: theme === 'dark' } });
      window.dispatchEvent(event);
    } catch (e) {}
  }

  function toggleTheme() {
    var current = document.documentElement.getAttribute('data-theme') || getCurrentTheme();
    var nextTheme = (current === 'dark') ? 'light' : 'dark';
    applyTheme(nextTheme, true);
  }

  // Global exposure
  window.SogoTheme = {
    get: function() { return document.documentElement.getAttribute('data-theme') || getCurrentTheme(); },
    set: applyTheme,
    toggle: toggleTheme
  };

  // Immediate sync of UI elements if DOM is already parsed
  function init() {
    var theme = document.documentElement.getAttribute('data-theme') || getCurrentTheme();
    applyTheme(theme, false);

    // Delegate click for any theme toggle button (desktop and mobile)
    document.addEventListener('click', function(e) {
      var btn = e.target.closest('.theme-toggle-btn');
      if (btn) {
        e.preventDefault();
        e.stopPropagation();
        toggleTheme();
      }
    });

    // Listen to OS preference change if user hasn't set an explicit preference
    if (window.matchMedia) {
      try {
        var mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
        var handleOSChange = function(e) {
          var hasExplicitChoice = false;
          try {
            hasExplicitChoice = !!localStorage.getItem(STORAGE_KEY);
          } catch (err) {}
          if (!hasExplicitChoice) {
            applyTheme(e.matches ? 'dark' : 'light', false);
          }
        };
        if (mediaQuery.addEventListener) {
          mediaQuery.addEventListener('change', handleOSChange);
        } else if (mediaQuery.addListener) {
          mediaQuery.addListener(handleOSChange);
        }
      } catch (e) {}
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
