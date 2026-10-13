<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- Shared document head: metadata, page title, and site stylesheets. --%>
<!DOCTYPE HTML>
<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>${not empty pageTitle ? pageTitle : 'Sogo Homestay - Đặt Phòng Homestay Nhanh Chóng'}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="stylesheet" type="text/css" href="//fonts.googleapis.com/css?family=|Roboto+Sans:400,700|Playfair+Display:400,700">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/animate.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/owl.carousel.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/aos.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap-datepicker.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/jquery.timepicker.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/fancybox.min.css">
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/ionicons/css/ionicons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/font-awesome.min.css">

    <%-- Theme stylesheet. --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=20261011-eye-fix">

    <style>
      .password-input-wrap {
        position: relative !important;
        width: 100% !important;
      }
      .password-input-wrap .form-control {
        padding-right: 48px !important;
      }
      .password-input-wrap .btn-toggle-password {
        position: absolute !important;
        top: 50% !important;
        right: 12px !important;
        transform: translateY(-50%) !important;
        -webkit-transform: translateY(-50%) !important;
        background: transparent !important;
        border: none !important;
        padding: 4px !important;
        margin: 0 !important;
        cursor: pointer !important;
        color: #718096 !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        z-index: 5 !important;
        outline: none !important;
        box-shadow: none !important;
        line-height: 1 !important;
        transition: color 0.2s ease !important;
      }
      .password-input-wrap .btn-toggle-password:hover,
      .password-input-wrap .btn-toggle-password:focus {
        color: #f7a840 !important;
      }
      .password-input-wrap .btn-toggle-password svg {
        width: 20px !important;
        height: 20px !important;
        stroke: currentColor !important;
        pointer-events: none !important;
      }
    </style>

    <script>
      function togglePasswordVisibility(button, event) {
        if (event) {
          try {
            event.preventDefault();
            event.stopPropagation();
          } catch (e) {}
        }
        var wrap = button ? button.closest('.password-input-wrap') : null;
        if (!wrap) return;
        var input = wrap.querySelector('input');
        if (!input) return;
        var iconEye = button.querySelector('.icon-eye');
        var iconEyeOff = button.querySelector('.icon-eye-off');

        if (input.type === 'password') {
          input.type = 'text';
          if (iconEye) iconEye.style.display = 'none';
          if (iconEyeOff) iconEyeOff.style.display = 'block';
          button.setAttribute('aria-label', 'Ẩn mật khẩu');
        } else {
          input.type = 'password';
          if (iconEye) iconEye.style.display = 'block';
          if (iconEyeOff) iconEyeOff.style.display = 'none';
          button.setAttribute('aria-label', 'Hiện mật khẩu');
        }
        try {
          input.focus();
        } catch (e) {}
      }
    </script>
  </head>
  <body>
