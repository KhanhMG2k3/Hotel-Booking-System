<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tạo Property</title>
</head>
<body>

<h1>Tạo Property mới</h1>

<%
    String error = (String) request.getAttribute("error");
%>

<% if (error != null) { %>
    <p style="color: red"><%= error %></p>
<% } %>

<form method="post"
      action="${pageContext.request.contextPath}/host/property/create">

    <label>Tên property:</label>
    <br>
    <input type="text"
           name="name"
           required>
    <br><br>

    <label>Mô tả:</label>
    <br>
    <textarea name="description"></textarea>
    <br><br>

    <label>Loại property:</label>
    <br>
    <select name="propertyType">
        <option value="HOMESTAY">Homestay</option>
        <option value="HOTEL">Khách sạn</option>
        <option value="VILLA">Villa</option>
    </select>
    <br><br>

    <label>Địa chỉ:</label>
    <br>
    <input type="text"
           name="address"
           required>
    <br><br>

    <label>Thành phố:</label>
    <br>
    <input type="text"
           name="city">
    <br><br>

    <label>Quốc gia:</label>
    <br>
    <input type="text"
           name="country"
           value="Vietnam">
    <br><br>

    <button type="submit">
        Tạo property
    </button>
</form>

</body>
</html>