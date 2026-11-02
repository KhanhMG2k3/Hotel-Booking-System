-- MySQL dump 10.13  Distrib 8.0.40, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: homestay_iter1_test
-- ------------------------------------------------------
-- Server version	9.1.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `customer_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `room_id` int NOT NULL,
  `check_in_date` date NOT NULL,
  `check_out_date` date NOT NULL,
  `adults` int NOT NULL DEFAULT '1',
  `children` int NOT NULL DEFAULT '0',
  `guest_count` smallint unsigned NOT NULL DEFAULT '1',
  `total_price` decimal(12,2) NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `special_requests` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('PENDING','CONFIRMED','CANCELLED','COMPLETED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_code` (`booking_code`),
  KEY `fk_bookings_user` (`user_id`),
  KEY `fk_bookings_room` (`room_id`),
  CONSTRAINT `fk_bookings_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bookings_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=129 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookings`
--

LOCK TABLES `bookings` WRITE;
/*!40000 ALTER TABLE `bookings` DISABLE KEYS */;
INSERT INTO `bookings` VALUES (1,'BK-SOGO-1001',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',2,'2026-10-15','2026-10-18',2,1,3,3450000.00,'Khách đến nhận phòng lúc 14:00, yêu cầu chuẩn bị thêm 1 nệm phụ.',NULL,'CONFIRMED','2026-10-13 10:23:02'),(2,'BK-SOGO-1002',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',5,'2026-10-20','2026-10-22',2,0,2,2500000.00,'Check-in muộn lúc 19:00.',NULL,'PENDING','2026-10-13 10:23:02'),(101,'BK-TEST-101',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',1,'2026-10-10','2026-10-13',2,0,2,1350000.00,'Khách hoàn tất kỳ nghỉ phòng Cozy Studio 101. Chưa viết đánh giá.',NULL,'COMPLETED','2026-10-26 02:38:18'),(102,'BK-TEST-102',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',3,'2026-10-14','2026-10-17',2,1,3,4800000.00,'Khách đã trả phòng Penthouse Rooftop. Đã đánh giá 4 sao.',NULL,'COMPLETED','2026-10-26 02:38:18'),(103,'BK-TEST-103',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',4,'2026-10-12','2026-10-15',2,0,2,1650000.00,'Khách An Nguyễn hoàn thành lưu trú.',NULL,'COMPLETED','2026-10-26 09:38:18'),(104,'BK-TEST-104',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',5,'2026-10-01','2026-10-03',2,0,2,2500000.00,'Đã đánh giá 5 sao & Host đã phản hồi.',NULL,'COMPLETED','2026-10-26 03:09:16'),(105,'BK-TEST-105',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',8,'2026-10-05','2026-10-07',2,0,2,2700000.00,'Khách đánh giá 2 sao. Chờ Host phản hồi.',NULL,'COMPLETED','2026-10-26 03:09:16'),(106,'BK-TEST-106',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',12,'2026-10-08','2026-10-10',2,0,2,5300000.00,'Khách đánh giá 4 sao. Chờ Host phản hồi.',NULL,'COMPLETED','2026-10-26 03:09:16'),(107,'BK-TEST-107',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',2,'2026-10-20','2026-10-24',4,1,2,4600000.00,'Kỳ nghỉ hoàn thành tại Family Suite Cầu Rồng 201. Chưa viết review.',NULL,'COMPLETED','2026-10-26 04:00:00'),(108,'BK-TEST-108',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',7,'2026-10-22','2026-10-25',2,0,1,1800000.00,'Kỳ nghỉ hoàn thành tại Rustic Wooden Bungalow Đà Lạt. Chưa viết review.',NULL,'COMPLETED','2026-10-26 05:00:00'),(109,'BK-TEST-109',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',14,'2026-10-18','2026-10-21',2,0,2,3600000.00,'Khách hoàn thành kỳ nghỉ Sunrise Beachfront Suite tại Nha Trang. Chưa đánh giá.',NULL,'COMPLETED','2026-10-26 07:00:00'),(110,'BK-TEST-110',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',17,'2026-10-22','2026-10-25',2,1,3,4500000.00,'Khách hoàn thành kỳ nghỉ Sunset Paradise Suite tại Phú Quốc. Chưa đánh giá.',NULL,'COMPLETED','2026-10-26 08:00:00'),(111,'BK-TEST-111',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',10,'2026-10-25','2026-10-27',2,0,2,1300000.00,'Khách công tác lưu trú Modern Urban Studio tại TP.HCM. Chưa đánh giá.',NULL,'COMPLETED','2026-10-27 03:00:00'),(112,'BK-TEST-112',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',6,'2026-10-19','2026-10-23',4,2,6,8400000.00,'Gia đình lưu trú tại Phố Cổ Grand Family Loft Hà Nội. Chưa đánh giá.',NULL,'COMPLETED','2026-10-26 09:00:00'),(113,'BK-TEST-113',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',9,'2026-10-24','2026-10-27',2,0,2,5550000.00,'Cặp đôi lưu trú Villa Cloud Hunter Attic tại Đà Lạt. Chưa đánh giá.',NULL,'COMPLETED','2026-10-27 04:00:00'),(114,'BK-TEST-114',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',15,'2026-10-10','2026-10-14',4,1,5,11200000.00,'Khách đánh giá 5 sao VIP Coral Sea View Villa Nha Trang. Chờ Host phản hồi.',NULL,'COMPLETED','2026-10-26 10:00:00'),(115,'BK-TEST-115',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',18,'2026-10-12','2026-10-15',4,0,4,9600000.00,'Khách đánh giá 3 sao Royal Oceanfront Pavilion Phú Quốc. Chờ Host phản hồi (Low rating).',NULL,'COMPLETED','2026-10-26 11:00:00'),(116,'BK-TEST-116',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',11,'2026-10-15','2026-10-17',2,0,2,2900000.00,'Khách đánh giá 5 sao Riverfront Executive Suite Sài Gòn. Chờ Host phản hồi.',NULL,'COMPLETED','2026-10-26 12:00:00'),(117,'BK-TEST-117',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',4,'2026-10-16','2026-10-18',2,0,2,1100000.00,'Khách đánh giá 1 sao Classic Old Quarter Deluxe Hà Nội. Chờ Host phản hồi (Low rating).',NULL,'COMPLETED','2026-10-26 13:00:00'),(118,'BK-TEST-118',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',16,'2026-10-21','2026-10-23',2,0,2,1040000.00,'Khách đánh giá 4 sao Tropical Garden Bungalow Phú Quốc. Chờ Host phản hồi.',NULL,'COMPLETED','2026-10-26 14:00:00'),(119,'BK-TEST-119',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',13,'2026-10-25','2026-10-28',2,0,1,1440000.00,'Kỳ nghỉ hoàn thành tại Ocean Breeze Standard 101 Nha Trang. Sẵn sàng viết review mới!',NULL,'COMPLETED','2026-10-29 03:00:00'),(120,'BK-TEST-120',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',1,'2026-10-26','2026-10-29',2,0,1,1350000.00,'Kỳ nghỉ hoàn thành tại Cozy Studio View Sông Hàn 101. Sẵn sàng viết review mới!',NULL,'COMPLETED','2026-10-30 04:00:00'),(121,'BK-TEST-121',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',8,'2026-10-27','2026-10-30',2,1,2,4050000.00,'Kỳ nghỉ hoàn thành tại Pine Valley View Suite 201 Đà Lạt. Sẵn sàng viết review mới!',NULL,'COMPLETED','2026-10-30 07:00:00'),(122,'BK-TEST-122',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',3,'2026-10-27','2026-10-30',4,0,2,7200000.00,'Kỳ nghỉ hoàn thành tại Penthouse Rooftop Panorama 301. Sẵn sàng viết review mới!',NULL,'COMPLETED','2026-10-30 09:00:00'),(123,'BK-TEST-123',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',18,'2026-10-28','2026-10-31',4,2,3,9600000.00,'Kỳ nghỉ hoàn thành tại Royal Oceanfront Pavilion 301 Phú Quốc. Sẵn sàng viết review mới!',NULL,'COMPLETED','2026-10-31 03:00:00'),(124,'BK-TEST-124',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',13,'2026-10-20','2026-10-23',2,0,1,1440000.00,'Khách đánh giá 5 sao Ocean Breeze Standard. Chờ Host phản hồi.',NULL,'COMPLETED','2026-10-24 03:00:00'),(125,'BK-TEST-125',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',2,'2026-10-21','2026-10-24',3,0,1,3450000.00,'Khách đánh giá 2 sao Family Sweet Suite Cầu Rồng. Chờ Host phản hồi (Low rating).',NULL,'COMPLETED','2026-10-25 04:00:00'),(126,'BK-TEST-126',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',5,'2026-10-22','2026-10-25',2,0,1,3750000.00,'Khách đánh giá 4 sao Heritage Balcony Suite Phố Cổ. Chờ Host phản hồi.',NULL,'COMPLETED','2026-10-26 05:00:00'),(127,'BK-TEST-127',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',7,'2026-10-23','2026-10-26',2,0,1,1800000.00,'Khách đánh giá 1 sao Rustic Wooden Bungalow Đà Lạt. Chờ Host phản hồi (Low rating).',NULL,'COMPLETED','2026-10-27 08:00:00'),(128,'BK-TEST-128',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',12,'2026-10-24','2026-10-27',4,0,2,7950000.00,'Khách đánh giá 5 sao Landmark View Grand Suite. Chờ Host phản hồi.',NULL,'COMPLETED','2026-10-28 10:00:00');
/*!40000 ALTER TABLE `bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contactmessages`
--

DROP TABLE IF EXISTS `contactmessages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contactmessages` (
  `message_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `ticket_code` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'GENERAL_FEEDBACK',
  `booking_id` int DEFAULT NULL,
  `full_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subject` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UNREAD',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  UNIQUE KEY `uk_contact_ticket_code` (`ticket_code`),
  KEY `idx_contact_user` (`user_id`),
  KEY `idx_contact_status` (`status`),
  KEY `fk_contact_booking` (`booking_id`),
  CONSTRAINT `fk_contact_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_contact_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contactmessages`
--

LOCK TABLES `contactmessages` WRITE;
/*!40000 ALTER TABLE `contactmessages` DISABLE KEYS */;
INSERT INTO `contactmessages` VALUES (1,3,'TK-20261031-KP38','HOST_ASSISTANCE',2,'Nguyễn Văn Host Demo','hostdemo@gmail.com','0912345678','111111111111','qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq','NEW','2026-10-31 18:15:50','2026-10-31 18:15:50'),(2,2,'TK-20261031-63S3','BOOKING_INQUIRY',111,'Khanh MG','khanhmg2k3@gmail.com','0987654321','Yêu cầu hỗ trợ nhận phòng sớm tại Homestay Đà Lạt','Chào Ban quản trị Sogo Homestay, tôi có chuyến bay hạ cánh sớm lúc 10:00 sáng. Đơn đặt phòng của tôi dự kiến nhận lúc 14:00. Tôi muốn nhờ Ban quản trị hỗ trợ liên hệ với chủ nhà xem tôi có thể gửi hành lý trước và nhận phòng sớm nếu phòng trống được không? Xin cảm ơn!','PROCESSING','2026-10-31 19:57:22','2026-10-31 21:23:57'),(3,4,'TK-20261031-RDDF','BOOKING_INQUIRY',113,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233','Yêu cầu hỗ trợ nhận phòng sớm tại Homestay Đà Lạt','Chào Ban quản trị Sogo Homestay, chuyến bay của tôi hạ cánh sớm lúc 10:00 sáng mai. Đơn đặt phòng của tôi dự kiến nhận lúc 14:00. Tôi muốn nhờ Ban quản trị liên hệ với chủ nhà xem tôi có thể gửi hành lý trước và nhận phòng sớm nếu phòng đang trống được không? Xin cảm ơn!','RESOLVED','2026-10-31 20:57:57','2026-10-31 21:22:20'),(4,8,'TK-20261031-X4TY','PAYMENT_PRICING',NULL,'Đặng Thùy Linh','thuylinh@gmail.com','0909777888','Hỏi về thời gian hoàn tiền và phương thức thanh toán qua thẻ','Tôi đã thực hiện thanh toán qua cổng trực tuyến nhưng hệ thống trừ tiền tài khoản ngân hàng 2 lần cho cùng một giao dịch. Tôi đã kiểm tra lịch sử biến động số dư. Nhờ bộ phận tài chính Sogo kiểm tra và hướng dẫn thủ tục tra soát đối soát hoàn tiền giúp tôi.','NEW','2026-10-31 22:11:15','2026-10-31 22:11:15'),(5,9,'TK-20261101-KE7W','HOST_ASSISTANCE',NULL,'Vũ Hoàng Nam','hoangnam@gmail.com','0988999000','Chào mày','Mày có biết bố mày là ai không','RESOLVED','2026-11-01 21:59:07','2026-11-01 22:01:32'),(6,4,'TK-20261101-H9T6','BOOKING_INQUIRY',127,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233','Tao muốn đấm mày','Tao muốn đấm mày','PROCESSING','2026-11-01 22:38:09','2026-11-01 22:38:46');
/*!40000 ALTER TABLE `contactmessages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('BOOKING','PROMOTION','REVIEW','SYSTEM') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SYSTEM',
  `target_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notifications_user` (`user_id`,`created_at` DESC),
  KEY `idx_notifications_unread` (`user_id`,`is_read`),
  CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,2,'Mời bạn đánh giá kỳ nghỉ tại Homestay Đà Lạt','Kỳ nghỉ của bạn tại Rustic Wooden Bungalow 101 đã hoàn thành! Hãy chia sẻ cảm nhận và hình ảnh trải nghiệm để nhận xu tích lũy nhé.','REVIEW','/write-review?bookingId=108',1,'2026-10-27 02:57:20'),(2,2,'Chủ nhà đã phản hồi đánh giá của bạn','Host Văn Demo đã phản hồi đánh giá của bạn: \"Cảm ơn bạn đã lựa chọn Sogo Homestay! Rất vui vì bạn hài lòng với kỳ nghỉ.\"','REVIEW','/write-review?bookingId=104',1,'2026-10-27 02:07:20'),(3,2,'Đặt phòng thành công! (Mã #BK-TEST-107)','Bạn đã đặt thành công phòng Family Sweet Suite Cầu Rồng 201. Chúc bạn có kỳ nghỉ thật tuyệt vời!','BOOKING','/my-bookings',1,'2026-10-27 00:07:20'),(4,2,'Ưu đãi đặc biệt: Giảm 15% cho phòng yêu thích','Phòng Penthouse Rooftop Panorama 301 trong danh sách yêu thích của bạn vừa có Voucher giảm 15%. Đặt ngay kẻo lỡ!','PROMOTION','/wishlist',1,'2026-10-26 03:07:20'),(5,2,'Nhắc nhở: Sắp đến giờ nhận phòng','Chỉ còn 24 giờ nữa là đến giờ nhận phòng tại Sogo Homestay Đà Nẵng. Chúc bạn có chuyến đi thật vui vẻ!','BOOKING','/my-bookings',1,'2026-10-25 03:07:20'),(6,3,'Khách hàng gửi đánh giá 2 sao cần phản hồi','Khách hàng Khanh MG vừa gửi đánh giá 2 sao cho phòng Pine Valley View Suite 201: \"Phòng hơi ẩm và nước nóng yếu...\". Hãy phản hồi để hỗ trợ khách hàng!','REVIEW','/host/reviews?filter=low',1,'2026-10-27 02:42:20'),(7,3,'Có đánh giá mới từ khách hàng','Khách hàng Khanh MG đã đánh giá 4 sao cho phòng Penthouse Rooftop Panorama 301. Hãy gửi lời cảm ơn đến khách hàng!','REVIEW','/host/reviews?filter=unreplied',1,'2026-10-27 01:07:20'),(8,3,'Có đơn đặt phòng mới cần chuẩn bị','Khách hàng Khanh MG vừa hoàn tất đặt phòng Cozy Studio 101. Kiểm tra chi tiết và chuẩn bị phòng đón tiếp khách!','BOOKING','/host/dashboard',1,'2026-10-26 22:07:20'),(9,3,'Báo cáo doanh thu tuần của các homestay','Doanh thu tuần qua của các homestay thuộc sở hữu của bạn đạt 12.500.000 VNĐ, tăng 15% so với tuần trước.','SYSTEM','/host/dashboard',1,'2026-10-26 03:07:20'),(10,3,'Khách hàng Khanh MG gửi đánh giá 1 sao cần xử lý khẩn cấp','Khách hàng Khanh MG vừa gửi đánh giá 1 sao cho phòng Classic Old Quarter Deluxe: \"Máy lạnh nhỏ nước...\". Hãy phản hồi để hỗ trợ khách!','REVIEW','/host/reviews?filter=low',1,'2026-10-29 06:18:24'),(11,3,'Khách hàng gửi đánh giá 3 sao cần phản hồi','Khách hàng Khanh MG gửi đánh giá 3 sao cho phòng Royal Oceanfront Pavilion: \"View biển đẹp nhưng wifi tầng trệt yếu...\".','REVIEW','/host/reviews?filter=low',1,'2026-10-29 06:06:24'),(12,3,'Có đánh giá 5 sao mới từ Khanh MG','Khách hàng Khanh MG vừa đánh giá 5 sao cho phòng VIP Coral Sea View Villa: \"Hồ bơi vô cực ngắm bình minh cực đỉnh...\".','REVIEW','/host/reviews?filter=unreplied',0,'2026-10-29 05:36:24'),(13,2,'Mời bạn đánh giá kỳ nghỉ tại Nha Trang','Kỳ nghỉ của bạn tại Sunrise Beachfront Suite 201 đã hoàn thành! Hãy chia sẻ cảm nhận để nhận xu ưu đãi nhé.','REVIEW','/write-review?bookingId=109',0,'2026-10-29 06:11:24'),(14,2,'Mời bạn đánh giá kỳ nghỉ tại Phú Quốc','Kỳ nghỉ của bạn tại Sunset Paradise Suite 201 đã hoàn thành! Hãy chia sẻ trải nghiệm hoàng hôn Phú Quốc cùng cộng đồng nhé.','REVIEW','/write-review?bookingId=110',0,'2026-10-29 04:26:24'),(15,2,'Mời bạn đánh giá kỳ nghỉ tại Ocean Breeze Nha Trang','Kỳ nghỉ của bạn tại Ocean Breeze Standard 101 (#BK-TEST-119) đã hoàn tất! Hãy viết đánh giá để nhận quà nhé.','REVIEW','/write-review?bookingId=119',0,'2026-10-31 16:22:47'),(16,2,'Mời bạn đánh giá kỳ nghỉ Cozy Studio Đà Nẵng','Kỳ nghỉ của bạn tại Cozy Studio (#BK-TEST-120) đã hoàn thành! Hãy chia sẻ trải nghiệm kỳ nghỉ của bạn.','REVIEW','/write-review?bookingId=120',0,'2026-10-31 15:57:47'),(17,3,'Khách hàng gửi đánh giá 1 sao lò sưởi Đà Lạt cần phản hồi','Khách hàng An Nguyễn vừa gửi đánh giá 1 sao phòng Rustic Wooden Bungalow (#BK-TEST-127): \"Lò sưởi bị khói...\". Hãy xử lý hỗ trợ khách!','REVIEW','/host/reviews?filter=low',0,'2026-10-31 16:15:47'),(18,3,'Khách hàng phản ánh ồn 2 sao tại Cầu Rồng','Khách hàng An Nguyễn vừa gửi đánh giá 2 sao phòng Family Sweet Suite (#BK-TEST-125): \"Ban đêm hơi ồn...\". Hãy gửi phản hồi giải thích và hỗ trợ khách.','REVIEW','/host/reviews?filter=low',0,'2026-10-31 15:42:47'),(19,3,'Có đánh giá 5 sao tuyệt vời tại Landmark 81','Khách hàng Khanh MG vừa gửi đánh giá 5 sao phòng Landmark View Grand Suite (#BK-TEST-128): \"View ngắm Landmark 81 cực sang chảnh...\". Hãy gửi lời cảm ơn khách!','REVIEW','/host/reviews?filter=unreplied',0,'2026-10-31 15:27:47'),(20,3,'Có đánh giá 4 sao mới cho phòng Phố Cổ Hà Nội','Khách hàng Khanh MG đánh giá 4 sao phòng Heritage Balcony Suite (#BK-TEST-126): \"Không gian đậm chất Hà Nội xưa...\". Hãy phản hồi lời cảm ơn khách!','REVIEW','/host/reviews?filter=unreplied',0,'2026-10-31 14:27:47'),(21,1,'Yêu cầu hỗ trợ mới [TK-20261101-H9T6]','Nguyễn Văn An vừa gửi yêu cầu hỗ trợ thuộc mục Hỗ trợ đặt phòng.','SYSTEM','/admin/support/detail?id=6',1,'2026-11-01 15:38:09'),(22,4,'Phản hồi mới cho yêu cầu [TK-20261101-H9T6]','Ban quản trị đã phản hồi yêu cầu hỗ trợ TK-20261101-H9T6 của bạn. Nhấn để xem chi tiết.','SYSTEM','/support/ticket?code=TK-20261101-H9T6#reply-9',1,'2026-11-01 15:38:46');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `review_replies`
--

DROP TABLE IF EXISTS `review_replies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `review_replies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `review_id` int NOT NULL,
  `host_id` int NOT NULL,
  `reply_content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `review_id` (`review_id`),
  KEY `idx_replies_host` (`host_id`),
  CONSTRAINT `fk_replies_host` FOREIGN KEY (`host_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_replies_review` FOREIGN KEY (`review_id`) REFERENCES `reviews` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review_replies`
--

LOCK TABLES `review_replies` WRITE;
/*!40000 ALTER TABLE `review_replies` DISABLE KEYS */;
INSERT INTO `review_replies` VALUES (1,3,3,'Cảm ơn bạn đã lựa chọn Sogo Homestay! Rất vui vì bạn hài lòng với kỳ nghỉ. Hẹn gặp lại bạn trong chuyến đi tới nhé.','2026-10-26 03:09:16','2026-10-26 03:09:16');
/*!40000 ALTER TABLE `review_replies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `user_id` int NOT NULL,
  `room_id` int NOT NULL,
  `property_id` int NOT NULL,
  `rating` tinyint NOT NULL,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('APPROVED','PENDING','HIDDEN') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'APPROVED',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_id` (`booking_id`),
  KEY `idx_reviews_room` (`room_id`,`status`),
  KEY `idx_reviews_user` (`user_id`),
  CONSTRAINT `fk_reviews_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reviews_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reviews_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_chk_1` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
INSERT INTO `reviews` VALUES (1,1,2,2,1,5,'Kỳ nghỉ tuyệt vời ngoài mong đợi!','Phòng rất sạch sẽ, view ban công ngắm cầu Rồng tuyệt đẹp. Chủ nhà nhiệt tình và chu đáo.','APPROVED','2026-10-21 23:37:27','2026-10-21 23:37:27'),(2,102,2,3,1,4,'Không gian thoáng mát, view đẹp','Phòng Penthouse tầng thượng rất rộng rãi, ngắm toàn cảnh sông Hàn lung linh về đêm. Sẽ quay lại!','APPROVED','2026-10-26 02:45:02','2026-10-26 03:13:40'),(3,104,4,5,2,5,'Phòng đẹp, chủ nhà rất nhiệt tình','Ban công nhìn xuống phố cổ rất thích. Chủ nhà hướng dẫn đường đi và gợi ý quán ăn ngon.','APPROVED','2026-10-26 03:09:16','2026-10-26 03:09:16'),(4,105,2,8,3,2,'Phòng hơi ẩm và nước nóng yếu','View đẹp nhưng phòng có mùi ẩm, vòi sen nước nóng chảy yếu vào buổi tối. Mong chủ nhà cải thiện chất lượng dịch vụ.','APPROVED','2026-10-26 03:09:16','2026-10-26 03:09:16'),(5,106,4,12,4,4,'Căn hộ hiện đại, view sông tuyệt vời','Căn hộ sạch sẽ, ban công ngắm sông Sài Gòn rất đẹp. Chỉ tiếc thang máy hơi đông vào giờ cao điểm.','APPROVED','2026-10-26 03:09:16','2026-10-26 03:09:16'),(6,114,4,15,5,5,'Biệt thự view biển tuyệt đẹp ngoài mong đợi!','Hồ bơi vô cực riêng tư hướng thẳng biển ngắm bình minh cực đỉnh. Phòng ngủ rộng rãi, gia đình mình ai cũng thích mê!','APPROVED','2026-10-27 01:30:00','2026-10-27 01:30:00'),(7,115,2,18,6,3,'View biển đẹp nhưng wifi tầng trệt hơi chập chờn','Không gian resort sang trọng, bồn tắm sục Jacuzzi ngoài trời rất xịn. Điểm trừ nhỏ là wifi ở phòng khách hơi yếu lúc buổi tối.','APPROVED','2026-10-27 02:15:00','2026-10-27 02:15:00'),(8,116,2,11,4,5,'Ngắm Landmark 81 cực chill bên sông Sài Gòn','Ban công tầng cao đón gió sông mát rượi, tối ngắm Landmark 81 lung linh tuyệt đẹp. Chủ nhà nhiệt tình hỗ trợ nhận phòng sớm.','APPROVED','2026-10-27 03:45:00','2026-10-27 03:45:00'),(9,117,4,4,2,1,'Máy lạnh nhỏ nước và cách âm chưa được tốt','Đêm đầu máy lạnh nhỏ nước ngay góc giường, cách âm chưa tốt nên nghe tiếng xe cộ ngoài phố. Mong chủ nhà sớm bảo trì khắc phục.','APPROVED','2026-10-27 04:20:00','2026-10-27 04:20:00'),(10,118,2,16,6,4,'Khu vườn nhiệt đới xanh mát và yên bình','Bungalow ẩn mình giữa vườn dừa mát mẻ, không khí trong lành yên tĩnh tuyệt đối. Rất phù hợp để nghỉ ngơi chữa lành sau chuỗi ngày bận rộn.','APPROVED','2026-10-27 07:00:00','2026-10-27 07:00:00'),(11,124,2,13,5,5,'Phòng thoáng mát, gần biển Nha Trang đi dạo rất thích!','Vị trí rất gần biển, sáng sớm mở cửa gió lùa mát rượi. Phòng ốc gọn gàng ngăn nắp, giá cả rất hợp lý cho kỳ nghỉ ngắn ngày.','APPROVED','2026-10-28 02:00:00','2026-10-28 02:00:00'),(12,125,4,2,1,2,'Ban đêm hơi ồn do tiếng còi xe bên cầu Rồng','Phòng rộng và nội thất đẹp nhưng ban đêm cách âm cửa kính ban công chưa tốt, nghe tiếng xe cộ qua cầu khá rõ. Mong chủ nhà lắp thêm rèm chống ồn.','APPROVED','2026-10-29 01:30:00','2026-10-29 01:30:00'),(13,126,2,5,2,4,'Không gian đậm chất Hà Nội xưa, ban công ngắm phố rất chill','Ban công nhìn xuống con phố cổ tấp nập, trà chiều ngồi ngắm mưa Hà Nội cực kỳ thích. Chủ nhà chu đáo gợi ý nhiều quán bún chả ngon.','APPROVED','2026-10-29 07:15:00','2026-10-29 07:15:00'),(14,127,4,7,3,1,'Lò sưởi bị khói và bình nước nóng chậm','Thời tiết Đà Lạt lạnh mà bình nóng lạnh chờ rất lâu mới có nước ấm, lò sưởi đốt lên bị khói ngộp phòng. Gia đình mình có trải nghiệm chưa được trọn vẹn.','APPROVED','2026-10-30 03:20:00','2026-10-30 03:20:00'),(15,128,2,12,4,5,'View ngắm Landmark 81 cực kỳ sang chảnh bên sông','Căn suite thượng lưu view ôm trọn sông Sài Gòn và Landmark 81 lung linh về đêm. Dịch vụ check-in nhanh gọn, chủ nhà hướng dẫn rất tận tình!','APPROVED','2026-10-30 09:45:00','2026-10-30 09:45:00');
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `room_amenities`
--

DROP TABLE IF EXISTS `room_amenities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `room_amenities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `room_id` int NOT NULL,
  `amenity_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_room_amenity` (`room_id`,`amenity_name`),
  KEY `idx_room_amenities_room` (`room_id`),
  CONSTRAINT `fk_room_amenities_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `room_amenities`
--

LOCK TABLES `room_amenities` WRITE;
/*!40000 ALTER TABLE `room_amenities` DISABLE KEYS */;
INSERT INTO `room_amenities` VALUES (4,1,'Ban Công Ngắm Cảnh'),(2,1,'Điều Hòa Nhiệt Độ'),(3,1,'Máy Nước Nóng Lạnh'),(1,1,'Wi-Fi Tốc Độ Cao'),(9,2,'Ban Công Ngắm Cảnh'),(6,2,'Điều Hòa Nhiệt Độ'),(7,2,'Máy Nước Nóng Lạnh'),(8,2,'Smart TV & Netflix'),(5,2,'Wi-Fi Tốc Độ Cao'),(15,3,'Ban Công Ngắm Cảnh'),(14,3,'Bếp & Dụng Cụ Nấu Ăn'),(11,3,'Điều Hòa Nhiệt Độ'),(16,3,'Hồ Bơi Vô Cực'),(12,3,'Máy Nước Nóng Lạnh'),(13,3,'Smart TV & Netflix'),(10,3,'Wi-Fi Tốc Độ Cao'),(18,4,'Điều Hòa Nhiệt Độ'),(19,4,'Máy Nước Nóng Lạnh'),(17,4,'Wi-Fi Tốc Độ Cao'),(24,5,'Ban Công Ngắm Cảnh'),(21,5,'Điều Hòa Nhiệt Độ'),(22,5,'Máy Nước Nóng Lạnh'),(23,5,'Smart TV & Netflix'),(20,5,'Wi-Fi Tốc Độ Cao'),(29,6,'Bếp & Dụng Cụ Nấu Ăn'),(26,6,'Điều Hòa Nhiệt Độ'),(27,6,'Máy Nước Nóng Lạnh'),(28,6,'Smart TV & Netflix'),(25,6,'Wi-Fi Tốc Độ Cao'),(33,7,'Ban Công Ngắm Cảnh'),(31,7,'Điều Hòa Nhiệt Độ'),(32,7,'Máy Nước Nóng Lạnh'),(30,7,'Wi-Fi Tốc Độ Cao'),(38,8,'Ban Công Ngắm Cảnh'),(35,8,'Điều Hòa Nhiệt Độ'),(36,8,'Máy Nước Nóng Lạnh'),(37,8,'Smart TV & Netflix'),(34,8,'Wi-Fi Tốc Độ Cao'),(43,9,'Bếp & Dụng Cụ Nấu Ăn'),(40,9,'Điều Hòa Nhiệt Độ'),(41,9,'Máy Nước Nóng Lạnh'),(42,9,'Smart TV & Netflix'),(39,9,'Wi-Fi Tốc Độ Cao'),(47,10,'Bếp & Dụng Cụ Nấu Ăn'),(45,10,'Điều Hòa Nhiệt Độ'),(46,10,'Máy Nước Nóng Lạnh'),(44,10,'Wi-Fi Tốc Độ Cao'),(52,11,'Ban Công Ngắm Cảnh'),(49,11,'Điều Hòa Nhiệt Độ'),(50,11,'Máy Nước Nóng Lạnh'),(51,11,'Smart TV & Netflix'),(48,11,'Wi-Fi Tốc Độ Cao'),(57,12,'Bếp & Dụng Cụ Nấu Ăn'),(54,12,'Điều Hòa Nhiệt Độ'),(58,12,'Hồ Bơi Vô Cực'),(55,12,'Máy Nước Nóng Lạnh'),(56,12,'Smart TV & Netflix'),(53,12,'Wi-Fi Tốc Độ Cao'),(60,13,'Điều Hòa Nhiệt Độ'),(61,13,'Máy Nước Nóng Lạnh'),(59,13,'Wi-Fi Tốc Độ Cao'),(66,14,'Ban Công Ngắm Cảnh'),(63,14,'Điều Hòa Nhiệt Độ'),(64,14,'Máy Nước Nóng Lạnh'),(65,14,'Smart TV & Netflix'),(62,14,'Wi-Fi Tốc Độ Cao'),(71,15,'Bếp & Dụng Cụ Nấu Ăn'),(68,15,'Điều Hòa Nhiệt Độ'),(72,15,'Hồ Bơi Vô Cực'),(69,15,'Máy Nước Nóng Lạnh'),(70,15,'Smart TV & Netflix'),(67,15,'Wi-Fi Tốc Độ Cao'),(74,16,'Điều Hòa Nhiệt Độ'),(75,16,'Máy Nước Nóng Lạnh'),(73,16,'Wi-Fi Tốc Độ Cao'),(80,17,'Ban Công Ngắm Cảnh'),(77,17,'Điều Hòa Nhiệt Độ'),(78,17,'Máy Nước Nóng Lạnh'),(79,17,'Smart TV & Netflix'),(76,17,'Wi-Fi Tốc Độ Cao'),(85,18,'Bếp & Dụng Cụ Nấu Ăn'),(82,18,'Điều Hòa Nhiệt Độ'),(86,18,'Hồ Bơi Vô Cực'),(83,18,'Máy Nước Nóng Lạnh'),(84,18,'Smart TV & Netflix'),(81,18,'Wi-Fi Tốc Độ Cao');
/*!40000 ALTER TABLE `room_amenities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `room_images`
--

DROP TABLE IF EXISTS `room_images`;
/*!50001 DROP VIEW IF EXISTS `room_images`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `room_images` AS SELECT 
 1 AS `id`,
 1 AS `room_id`,
 1 AS `stored_name`,
 1 AS `media_type`,
 1 AS `content_type`,
 1 AS `sort_order`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `support_replies`
--

DROP TABLE IF EXISTS `support_replies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `support_replies` (
  `reply_id` int NOT NULL AUTO_INCREMENT,
  `ticket_id` int NOT NULL,
  `sender_id` int NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reply_id`),
  KEY `idx_replies_ticket` (`ticket_id`),
  KEY `idx_replies_sender` (`sender_id`),
  CONSTRAINT `fk_replies_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_replies_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `contactmessages` (`message_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `support_replies`
--

LOCK TABLES `support_replies` WRITE;
/*!40000 ALTER TABLE `support_replies` DISABLE KEYS */;
INSERT INTO `support_replies` VALUES (1,2,1,'Chào bạn, Ban quản trị Sogo Homestay đã tiếp nhận yêu cầu của bạn. Chúng tôi đã liên hệ trực tiếp với chủ nhà homestay. Chủ nhà đồng ý hỗ trợ bạn gửi hành lý từ 10:30 sáng và sẽ ưu tiên dọn phòng sớm nếu khách trước trả phòng đúng giờ nhé.','2026-10-31 20:54:54'),(2,3,1,'Chào bạn, Ban quản trị Sogo Homestay đã tiếp nhận yêu cầu của bạn. Chúng tôi đã liên hệ trực tiếp với chủ nhà homestay. Chủ nhà đồng ý hỗ trợ bạn gửi hành lý từ 10:30 sáng và sẽ ưu tiên dọn phòng sớm nếu khách trước trả phòng đúng giờ nhé.','2026-10-31 20:59:31'),(3,3,4,'Em cám ơn ạ','2026-10-31 21:12:53'),(4,3,1,'Ok bạn','2026-10-31 21:13:58'),(5,2,1,'1111','2026-10-31 21:23:31'),(6,2,1,'Ai mà biết được bạn','2026-10-31 21:23:57'),(7,5,1,'Bố mày đây','2026-11-01 22:00:00'),(8,5,1,'Mày ăn cơm chưa','2026-11-01 22:00:36'),(9,6,1,'Chan bố mày đê','2026-11-01 22:38:46');
/*!40000 ALTER TABLE `support_replies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `term_sections`
--

DROP TABLE IF EXISTS `term_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `term_sections` (
  `id` int NOT NULL AUTO_INCREMENT,
  `section_order` int NOT NULL,
  `sidebar_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `content_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `content_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_text` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_json` mediumtext COLLATE utf8mb4_unicode_ci,
  `callout_text` mediumtext COLLATE utf8mb4_unicode_ci,
  `callout_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'info',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `term_sections`
--

LOCK TABLES `term_sections` WRITE;
/*!40000 ALTER TABLE `term_sections` DISABLE KEYS */;
INSERT INTO `term_sections` VALUES (34,1,'Quy Định Nhận Phòng & Trả Phòng','Quy Định Nhận Phòng & Trả Phòng','multi-block','[{\"type\":\"text\",\"text\":\"• Giờ nhận phòng (Check-in): từ 14:00 của ngày bắt đầu lưu trú.\\n• Giờ trả phòng (Check-out): trước 12:00 trưa của ngày kết thúc lưu trú.\\n• Nhận phòng sớm / Trả phòng trễ: Tùy thuộc vào tình trạng phòng trống tại thời điểm đó và có thể áp dụng phụ phí theo quy định:\\n    - Trả phòng trễ từ 12:00 đến 18:00: Phụ thu 50% tiền phòng 1 đêm.\\n    - Trả phòng sau 18:00: Tính 100% tiền phòng 1 đêm.\\n• Khách vui lòng xuất trình CCCD/Hộ chiếu hợp lệ của tất cả các khách lưu trú để hoàn tất thủ tục đăng ký tạm trú với cơ quan quản lý.\\n-Khách vui lòng cấm đi ỉa\"},{\"type\":\"table\",\"title\":\"Bảng Chính Sách Hoàn Tiền\",\"headers\":[\"11111111111\",\"1111111\"],\"rows\":[[\"111111111\",\"ưefwefwf\"],[\"ffwewefwef\",\"fwfwefwe\"]]},{\"type\":\"callout\",\"text\":\"Đậu xanh rau má\",\"calloutType\":\"note\"}]',NULL,NULL,NULL),(35,2,'Quy Định Thanh Toán & Đặt Cọc111','Quy Định Thanh Toán & Đặt Cọc111','multi-block','[{\"type\":\"text\",\"text\":\"Nhằm đảm bảo việc giữ phòng, khách hàng cần thực hiện đặt cọc theo tỷ lệ sau:\\n\\n• Đặt cọc giữ chỗ: Tối thiểu 50% tổng giá trị đơn đặt phòng trong vòng 24 giờ kể từ khi gửi yêu cầu.\\n• Thanh toán số tiền còn lại: 50% còn lại được thanh toán trực tiếp tại quầy lễ tân khi làm thủ tục Check-in.\\n• Phương thức chấp nhận: Chuyển khoản ngân hàng trực tuyến (QR Pay), thẻ tín dụng/ghi nợ nội địa và tiền mặt.\"}]',NULL,NULL,NULL),(36,3,'Nội Quy Lưu Trú & An Ninh Homestay','Nội Quy Lưu Trú & An Ninh Homestay','multi-block','[{\"type\":\"text\",\"text\":\"• Không hút thuốc lá: Tuyệt đối không hút thuốc trong phòng ngủ. Khách có thể hút thuốc tại khu vực sân vườn hoặc ban công mở.\\n• Giờ yên tĩnh: Từ 22:30 đến 06:00 sáng hôm sau nhằm đảm bảo sự riêng tư và giấc ngủ của các phòng xung quanh.\\n• Chất cấm & Vũ khí: Nghiêm cấm mang theo các chất gây cháy nổ, vũ khí, chất kích thích hoặc thực hiện các hành vi vi phạm pháp luật Việt Nam trong khuôn viên homestay.\\n• Vật nuôi (Thú cưng): Vui lòng thông báo trước với quản lý homestay. Phí dọn dẹp vệ sinh phòng thú cưng có thể được áp dụng.\\n• Bảo quản tài sản: Quý khách có trách nhiệm giữ gìn trang thiết bị và đồ dùng trong phòng. Nếu xảy ra hư hỏng, mất mát sẽ bồi thường theo bảng giá niêm yết của homestay.\"}]',NULL,NULL,NULL),(37,4,'alo abc','alo abc','multi-block','[{\"type\":\"text\",\"text\":\"anh là ai\"},{\"type\":\"table\",\"title\":\"Bảng Chính Sách Hoàn Tiền\",\"headers\":[\"aa\",\"bb\",\"cc\"],\"rows\":[[\"12\",\"14\",\"42\"],[\"à\",\"fwefe\",\"fwe\"],[\"ưefwe\",\"fweef\",\"ưefwe\"]]},{\"type\":\"callout\",\"text\":\"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\",\"calloutType\":\"note\"}]',NULL,NULL,NULL),(38,5,'QUy định giờ giấc','QUy định giờ giấc','multi-block','[{\"type\":\"table\",\"title\":\"Bảng Chính Sách Hoàn Tiền\",\"headers\":[\"Thời Gian Thông Báo Hủy\",\"Chính Sách Hoàn Cọc\"],\"rows\":[[\"Trước 07 ngày so với ngày nhận phòng\",\"Hoàn 100% tiền đặt cọc (trừ phí chuyển khoản nếu có)\"],[\"Từ 03 đến 06 ngày trước ngày nhận phòng\",\"Hoàn 50% tiền đặt cọc\"],[\"Dưới 03 ngày hoặc Không đến (No-show)\",\"Không hoàn lại tiền cọc\"]]}]',NULL,NULL,NULL);
/*!40000 ALTER TABLE `term_sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `terms`
--

DROP TABLE IF EXISTS `terms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `terms` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Điều Khoản Dịch Vụ & Quy Định Lưu Trú',
  `meta_description` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `terms`
--

LOCK TABLES `terms` WRITE;
/*!40000 ALTER TABLE `terms` DISABLE KEYS */;
/*!40000 ALTER TABLE `terms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `terms_setting`
--

DROP TABLE IF EXISTS `terms_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `terms_setting` (
  `id` int NOT NULL AUTO_INCREMENT,
  `main_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `last_updated` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `terms_setting`
--

LOCK TABLES `terms_setting` WRITE;
/*!40000 ALTER TABLE `terms_setting` DISABLE KEYS */;
INSERT INTO `terms_setting` VALUES (1,'Điều Khoản Dịch Vụ & Quy Định Lưu Trú - FPT Homestay','31/10/2026 23:12');
/*!40000 ALTER TABLE `terms_setting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `room_images`
--

/*!50001 DROP VIEW IF EXISTS `room_images`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `room_images` AS select `roomimages`.`image_id` AS `id`,coalesce(`roomimages`.`room_id`,`roomimages`.`room_type_id`) AS `room_id`,`roomimages`.`image_url` AS `stored_name`,`roomimages`.`media_type` AS `media_type`,`roomimages`.`content_type` AS `content_type`,`roomimages`.`display_order` AS `sort_order` from `roomimages` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-02  1:13:03
