Tôi muốn css phải code ra file riêng, và tôi muốn dùng scss chứ không dùng css.

Khi code ví dụ Code Register thì phải lấy tất cả thuộc tính của User, xem cái nào phải điền thì Register form phải có. Tôi đang lấy ví dụ nếu như code các file khác cũng hãy xem các file liên quan của nó để code đồng bộ.

lưu ý tối ưu file scss cho gắn gọn nhất, code phải sạch rõ ràng.

# General Rules
Always read this file first before execution.

Follow MVC pattern:
JSP → Servlet → DAO → DB → back to DAO → Servlet → JSP.

Show the file being edited so progress can be tracked.
Do not auto‑code. Only code when explicitly instructed.
Variable names must be short, consistent, and clear.
If a new model is needed → first design DB table with attributes → then create model.
All features must include validation.
Code must be in English with simple, clear comments.
Only one SQL file exists.

# Roles & Permissions
Guest:
- Can view/search rooms.
- Must login to book → becomes Customer.

Customer:
- Can book rooms, use host vouchers.
- Can manage profile, wishlist, notifications, reviews.
- Can request refund/cancel booking.
- Can apply to become Host.

Host:
- Must be Customer first, then apply → wait for Admin approval.
- Can CRUD own rooms only.
- Can manage own vouchers.
- Can view/manage bookings for own rooms.
- Cannot edit other Hosts’ properties.

Admin:
- Can approve/reject Host requests.
- Can delete Hosts (not Admins).
- Cannot delete other Admins or self.
- Can view reports, manage support messages.

# Business Flow
- Guest: Browse homepage, search, view property detail. Booking requires login.
- Customer: Full booking flow (select room → confirm → payment → confirmation). Can manage account, wishlist, reviews, notifications.
- Host: After approval, can manage rooms, vouchers, booking calendar, refunds, reply to reviews.
- Admin: Approve Hosts, view revenue reports, manage support.

# Code Comment Rules
Every code block must have section comments that explain the flow step by step.
Use English comments only.
Follow standard comment syntax for Java, JSP, HTML, SCSS, SQL.
Comments must describe what this section does and where the flow goes next.
