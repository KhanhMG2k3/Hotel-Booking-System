<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Admin Dashboard</title>
    </head>
    <body>
        <c:forEach var="profile"
                   items="${pendingHostProfiles}">
        <tr>
            <td>${profile.id}</td>
            <td>${profile.businessName}</td>
            <td>${profile.businessType}</td>
            <td>${profile.phone}</td>
            <td>${profile.verificationStatus}</td>
            <td>
                <form method="post"
                      action="${pageContext.request.contextPath}/admin/host/approve">

                    <input type="hidden"
                           name="profileId"
                           value="${profile.id}">

                    <button type="submit">
                        Duyệt
                    </button>
                </form>
            </td>
        </tr>
    </c:forEach>
    <h2>Hồ sơ Host chờ duyệt</h2>

    <c:choose>
        <c:when test="${empty pendingHostProfiles}">
            <p>Hiện không có hồ sơ Host nào chờ duyệt.</p>
        </c:when>

        <c:otherwise>
            <table border="1">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>User ID</th>
                        <th>Tên doanh nghiệp</th>
                        <th>Loại hình</th>
                        <th>Số điện thoại</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>

                <tbody>
                    <c:forEach
                        var="profile"
                        items="${pendingHostProfiles}">
                        <tr>
                            <td>${profile.id}</td>
                            <td>${profile.userId}</td>
                            <td>${profile.businessName}</td>
                            <td>${profile.businessType}</td>
                            <td>${profile.phone}</td>
                            <td>${profile.verificationStatus}</td>
                            <td>
                                <form method="post"
                                      action="${pageContext.request.contextPath}/admin/host/approve">

                                    <input type="hidden"
                                           name="profileId"
                                           value="${profile.id}">

                                    <button type="submit">
                                        Duyệt
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:otherwise>
    </c:choose>
</body>
</html>