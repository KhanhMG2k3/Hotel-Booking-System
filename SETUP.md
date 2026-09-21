# SETUP.md — Hướng dẫn cài đặt sau khi pull code mới nhất

## 1. Pull code mới nhất về
```
git pull origin main
```
(hoặc đúng nhánh bạn đang được giao làm việc cùng)

## 2. Tạo file `db.properties` (bắt buộc, mỗi máy tự tạo riêng)

File này **không nằm trong Git** (đã gitignore) vì chứa mật khẩu MySQL riêng của từng máy — ai cũng phải tự tạo, không lấy được qua `git pull`.

- Vào `src/main/resources/`
- Copy file `db.properties.example` → đổi tên bản copy thành `db.properties`
- Mở file `db.properties` vừa tạo, điền đúng mật khẩu MySQL **của máy mình**:
```properties
db.password=<mật khẩu MySQL trên máy bạn>
```
Các dòng còn lại trong `db.properties.example` giữ nguyên, không cần sửa (trừ khi tên database/user MySQL trên máy bạn khác mặc định).

## 3. Không cần làm gì với `app.properties`

File này **có sẵn** trong code vừa pull về (đã commit lên Git bình thường), chứa Google Client ID dùng chung cho cả nhóm — không cần tạo, không cần sửa, không cần xin ai.

## 4. Clean and Build lại project
- NetBeans: chuột phải vào project → **Clean and Build**

## 5. Chạy thử và test
- Chạy `ServerRunner.java` (chuột phải → Run File)
- Test đăng nhập bằng cả 2 cách: email/mật khẩu thường, và nút Google Sign-In
- Báo lại nhóm ngay nếu gặp lỗi khi test

---

## Xử lý lỗi thường gặp

### Lỗi `Address already in use` khi chạy `ServerRunner`
Nghĩa là cổng 8080 đang bị 1 tiến trình cũ chiếm giữ. Mở Command Prompt, chạy:
```
netstat -ano | findstr :8080
taskkill /F /PID <số_PID_thấy_được_ở_cột_cuối>
```
Sau đó chạy lại `ServerRunner`.

### Lỗi `Access denied for user 'root'@'localhost'`
Nghĩa là mật khẩu trong `db.properties` sai, hoặc chưa tạo file `db.properties` (chỉ có `db.properties.example`) — quay lại bước 2.

### Lỗi `Missing required parameter: client_id` khi bấm đăng nhập Google
Nghĩa là chưa Clean and Build lại sau khi pull code, hoặc file `app.properties` chưa được copy vào `target/classes` — quay lại bước 4.

---

## Quy trình Git cần nhớ
- Code xong 1 phần, tạo nhánh riêng: `git checkout -b feature/ten-tinh-nang`
- Push nhánh đó lên: `git push -u origin feature/ten-tinh-nang`
- Tạo Pull Request trên GitHub để nhóm review trước khi merge vào `main`
- **Không push thẳng vào `main`**
