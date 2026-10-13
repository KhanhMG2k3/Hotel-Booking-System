/**
 * Shared landing-page behavior for the site header, sliders, and smooth scrolling.
 * The flow wires the menu, carousel widgets, and scroll-state helpers after the page loads.
 */
(function($) {

	'use strict';

  var $siteHeader = $('.js-site-header');
  var $menuToggle = $('.js-site-menu-toggle');
/**
 * Toggles the site navigation menu and updates the aria state for accessibility.
 * @param {boolean} isOpen - Whether the menu should be expanded.
 * @returns {void}
 */
  var setSiteMenuOpen = function(isOpen) {
    $siteHeader.toggleClass('menu-open', isOpen);
    $menuToggle.toggleClass('open', isOpen)
      .attr('aria-expanded', isOpen)
      .attr('aria-label', isOpen ? 'Close website navigation' : 'Open website navigation');
    $siteHeader.find('.js-site-navbar').attr('aria-hidden', !isOpen);
  };

  $menuToggle.on('click', function(event) {
    event.stopPropagation();
    setSiteMenuOpen(!$siteHeader.hasClass('menu-open'));
  });

  $(document).on('click', function(event) {
    if (!$siteHeader.is(event.target) && $siteHeader.has(event.target).length === 0) {
      setSiteMenuOpen(false);
    }
  });

  $(document).on('keydown', function(event) {
    if (event.key === 'Escape') {
      setSiteMenuOpen(false);
    }
  });

  $siteHeader.find('.js-site-navbar a').on('click', function() {
    setSiteMenuOpen(false);
  });

	
	$('nav .dropdown').hover(function(){
		var $this = $(this);
		$this.addClass('show');
		$this.find('> a').attr('aria-expanded', true);
		$this.find('.dropdown-menu').addClass('show');
	}, function(){
		var $this = $(this);
			$this.removeClass('show');
			$this.find('> a').attr('aria-expanded', false);
			$this.find('.dropdown-menu').removeClass('show');
	});



	$('#dropdown04').on('show.bs.dropdown', function () {
	  console.log('show');
	});

  // aos
  AOS.init({
    duration: 1000
  });

	// home slider
	$('.home-slider').owlCarousel({
    loop:true,
    autoplay: true,
    margin:10,
    animateOut: 'fadeOut',
    animateIn: 'fadeIn',
    nav:true,
    autoplayHoverPause: true,
    items: 1,
    autoheight: true,
    navText : ["<span class='ion-chevron-left'></span>","<span class='ion-chevron-right'></span>"],
    responsive:{
      0:{
        items:1,
        nav:false
      },
      600:{
        items:1,
        nav:false
      },
      1000:{
        items:1,
        nav:true
      }
    }
	});

	// owl carousel
	var majorCarousel = $('.js-carousel-1');
	majorCarousel.owlCarousel({
    loop:true,
    autoplay: true,
    stagePadding: 7,
    margin: 20,
    animateOut: 'fadeOut',
    animateIn: 'fadeIn',
    nav: true,
    autoplayHoverPause: true,
    items: 3,
    navText : ["<span class='ion-chevron-left'></span>","<span class='ion-chevron-right'></span>"],
    responsive:{
      0:{
        items:1,
        nav:false
      },
      600:{
        items:2,
        nav:false
      },
      1000:{
        items:3,
        nav:true,
        loop:false
      }
  	}
	});

	// owl carousel
	var major2Carousel = $('.js-carousel-2');
	major2Carousel.owlCarousel({
    loop:true,
    autoplay: true,
    stagePadding: 7,
    margin: 20,
    // animateOut: 'fadeOut',
    // animateIn: 'fadeIn',
    nav: true,
    autoplayHoverPause: true,
    autoHeight: true,
    items: 3,
    navText : ["<span class='ion-chevron-left'></span>","<span class='ion-chevron-right'></span>"],
    responsive:{
      0:{
        items:1,
        nav:false
      },
      600:{
        items:2,
        nav:false
      },
      1000:{
        items:3,
        dots: true,
        nav:true,
        loop:false
      }
  	}
	});

/**
 * Initializes the parallax motion for page sections.
 * @returns {void}
 */
  var siteStellar = function() {
    $(window).stellar({
      responsive: false,
      parallaxBackgrounds: true,
      parallaxElements: true,
      horizontalScrolling: false,
      hideDistantElements: false,
      scrollProperty: 'scroll'
    });
  }
  siteStellar();

/**
 * Binds anchor links to a smooth scroll animation.
 * @returns {void}
 */
  var smoothScroll = function() {
    var $root = $('html, body');

    $('a.smoothscroll[href^="#"]').click(function () {
      $root.animate({
        scrollTop: $( $.attr(this, 'href') ).offset().top
      }, 500);
      return false;
    });
  }
  smoothScroll();

/**
 * Configures the date and time pickers used by the booking form.
 * @returns {void}
 */
  var dateAndTime = function() {
    $('#m_date').datepicker({
      'format': 'm/d/yyyy',
      'autoclose': true
    });
    $('#checkin_date, #checkout_date').datepicker({
      'format': 'd MM, yyyy',
      'autoclose': true
    });
    $('#m_time').timepicker();
  };
  dateAndTime();


/**
 * Adds the header shrink effect when the page scrolls past the hero area.
 * @returns {void}
 */
  var windowScroll = function() {

    $(window).scroll(function(){
      var $win = $(window);
      if ($win.scrollTop() > 200) {
        $('.js-site-header').addClass('scrolled');
      } else {
        $('.js-site-header').removeClass('scrolled');
      }

    });

  };
  windowScroll();


/**
 * Enables the back-to-top control and updates its scroll visibility.
 * @returns {void}
 */
  var goToTop = function() {

    $('.js-gotop').on('click', function(event){
      
      event.preventDefault();

      $('html, body').animate({
        scrollTop: $('html').offset().top
      }, 500, 'easeInOutExpo');
      
      return false;
    });

    $(window).scroll(function(){

      var $win = $(window);
      if ($win.scrollTop() > 200) {
        $('.js-top').addClass('active');
      } else {
        $('.js-top').removeClass('active');
      }

    });
  
  /**
   * Toggles visibility of password input fields when clicking eye button.
   */
  $(document).on('click', '.btn-toggle-password', function(event) {
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