/**
 * Shared landing-page behavior for the site header, sliders, and smooth scrolling.
 * The flow wires the menu, carousel widgets, and scroll-state helpers after the page loads.
 */
(function ($) {
  'use strict';

  // Support for dynamic hero images via data attribute
  document.querySelectorAll('[data-hero-image]').forEach(function (hero) {
    hero.style.backgroundImage = 'url("' + hero.dataset.heroImage + '")';
  });

  // Drawer menu toggle for responsive navigation
  $('.site-menu-toggle').click(function () {
    var $this = $(this);
    if ($('body').hasClass('menu-open')) {
      $this.removeClass('open');
      $('.js-site-navbar').fadeOut(400);
      $('body').removeClass('menu-open');
    } else {
      $this.addClass('open');
      $('.js-site-navbar').fadeIn(400);
      $('body').addClass('menu-open');
    }
  });

  $('nav .dropdown').hover(function () {
    var $this = $(this);
    $this.addClass('show');
    $this.find('> a').attr('aria-expanded', true);
    $this.find('.dropdown-menu').addClass('show');
  }, function () {
    var $this = $(this);
    $this.removeClass('show');
    $this.find('> a').attr('aria-expanded', false);
    $this.find('.dropdown-menu').removeClass('show');
  });

  $('#dropdown04').on('show.bs.dropdown', function () {
    console.log('show');
  });

  // aos animation
  if (typeof AOS !== 'undefined') {
    AOS.init({
      duration: 1000
    });
  }

  // home slider
  $('.home-slider').owlCarousel({
    loop: true,
    autoplay: true,
    margin: 10,
    animateOut: 'fadeOut',
    animateIn: 'fadeIn',
    nav: true,
    autoplayHoverPause: true,
    items: 1,
    autoheight: true,
    navText: ["<span class='ion-chevron-left'></span>", "<span class='ion-chevron-right'></span>"],
    responsive: {
      0: {
        items: 1,
        nav: false
      },
      600: {
        items: 1,
        nav: false
      },
      1000: {
        items: 1,
        nav: true
      }
    }
  });

  // owl carousel 1
  var majorCarousel = $('.js-carousel-1');
  majorCarousel.owlCarousel({
    loop: true,
    autoplay: true,
    stagePadding: 7,
    margin: 20,
    animateOut: 'fadeOut',
    animateIn: 'fadeIn',
    nav: true,
    autoplayHoverPause: true,
    items: 3,
    navText: ["<span class='ion-chevron-left'></span>", "<span class='ion-chevron-right'></span>"],
    responsive: {
      0: {
        items: 1,
        nav: false
      },
      600: {
        items: 2,
        nav: false
      },
      1000: {
        items: 3,
        nav: true,
        loop: false
      }
    }
  });

  // owl carousel 2
  var major2Carousel = $('.js-carousel-2');
  major2Carousel.owlCarousel({
    loop: true,
    autoplay: true,
    stagePadding: 7,
    margin: 20,
    nav: true,
    autoplayHoverPause: true,
    autoHeight: true,
    items: 3,
    navText: ["<span class='ion-chevron-left'></span>", "<span class='ion-chevron-right'></span>"],
    responsive: {
      0: {
        items: 1,
        nav: false
      },
      600: {
        items: 2,
        nav: false
      },
      1000: {
        items: 3,
        dots: true,
        nav: true,
        loop: false
      }
    }
  });

  // Parallax with stellar
  var siteStellar = function () {
    if ($.fn.stellar) {
      $(window).stellar({
        responsive: false,
        parallaxBackgrounds: true,
        parallaxElements: true,
        horizontalScrolling: false,
        hideDistantElements: false,
        scrollProperty: 'scroll'
      });
    }
  };
  siteStellar();

  // Smooth scroll
  var smoothScroll = function () {
    var $root = $('html, body');
    $('a.smoothscroll[href^="#"]').click(function () {
      $root.animate({
        scrollTop: $($.attr(this, 'href')).offset().top
      }, 500);
      return false;
    });
  };
  smoothScroll();

  // Date and time pickers
  var dateAndTime = function () {
    if ($.fn.datepicker) {
      $('#m_date').datepicker({
        'format': 'm/d/yyyy',
        'autoclose': true
      });
      $('#checkin_date, #checkout_date').datepicker({
        'format': 'd MM, yyyy',
        'autoclose': true
      });
    }
    if ($.fn.timepicker) {
      $('#m_time').timepicker();
    }
  };
  dateAndTime();

  // Header scroll state
  var windowScroll = function () {
    $(window).scroll(function () {
      var $win = $(window);
      if ($win.scrollTop() > 200) {
        $('.js-site-header').addClass('scrolled');
      } else {
        $('.js-site-header').removeClass('scrolled');
      }
    });
  };
  windowScroll();

  // Back to top
  var goToTop = function () {
    $('.js-gotop').on('click', function (event) {
      event.preventDefault();
      $('html, body').animate({
        scrollTop: $('html').offset().top
      }, 500, 'easeInOutExpo');
      return false;
    });

    $(window).scroll(function () {
      var $win = $(window);
      if ($win.scrollTop() > 200) {
        $('.js-top').addClass('active');
      } else {
        $('.js-top').removeClass('active');
      }
    });
  };
  goToTop();

  // Toggle visibility of password input fields when clicking eye button
  $(document).on('click', '.btn-toggle-password', function (event) {
    event.preventDefault();
    var $btn = $(this);
    var targetId = $btn.data('target');
    var $input = targetId ? $('#' + targetId) : $btn.closest('.password-input-wrap').find('input');
    var $icon = $btn.find('i, span');

    if ($input.length) {
      if ($input.attr('type') === 'password') {
        $input.attr('type', 'text');
        $icon.removeClass('fa-eye').addClass('fa-eye-slash');
        $btn.attr('aria-label', 'Ẩn mật khẩu');
      } else {
        $input.attr('type', 'password');
        $icon.removeClass('fa-eye-slash').addClass('fa-eye');
        $btn.attr('aria-label', 'Hiện mật khẩu');
      }
    }
  });

})(jQuery);