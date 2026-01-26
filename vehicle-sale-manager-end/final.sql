CREATE DATABASE IF NOT EXISTS `ev_sales` /*!40100 DEFAULT CHARACTER SET utf8mb4 */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `ev_sales`;

-- MySQL dump 10.13  Distrib 8.0.33, for Win64 (x86_64)
-- Server version	8.0.33

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */
;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */
;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */
;
/*!50503 SET NAMES utf8mb4 */
;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */
;
/*!40103 SET TIME_ZONE='+00:00' */
;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */
;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */
;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */
;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */
;

--
-- Table structure for table `vehicle`
-- 车辆信息表
--

DROP TABLE IF EXISTS `vehicle`;

CREATE TABLE `vehicle` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `name` varchar(100) DEFAULT NULL COMMENT '车型名称',
    `brand` varchar(50) DEFAULT NULL COMMENT '品牌',
    `range_km` int DEFAULT NULL COMMENT '续航里程（km）',
    `battery_type` varchar(50) DEFAULT NULL COMMENT '电池类型（磷酸铁锂、三元锂等）',
    `guide_price` decimal(10, 2) DEFAULT NULL COMMENT '官方指导价',
    `stock` int DEFAULT '0' COMMENT '库存数量',
    `launch_date` date DEFAULT NULL COMMENT '上市时间',
    `fast_charge_minutes` int DEFAULT NULL COMMENT '快充时间（分钟）',
    `smart_drive_level` varchar(20) DEFAULT NULL COMMENT '智驾等级（L2/L2+/L3等）',
    `description` text COMMENT '车型描述',
    `configs` json DEFAULT NULL COMMENT '配置参数（JSON格式）',
    `images` json DEFAULT NULL COMMENT '车型图集（JSON数组）',
    `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
    `update_date` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted` tinyint(1) DEFAULT '0',
    PRIMARY KEY (`id`),
    KEY `idx_brand` (`brand`),
    KEY `idx_range` (`range_km`),
    KEY `idx_battery_type` (`battery_type`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '车辆信息表';

--
-- Dumping data for table `vehicle`
--

LOCK TABLES `vehicle` WRITE;

INSERT INTO
    `vehicle`
VALUES (
        1,
        '蔚来 ET5',
        '蔚来',
        560,
        '三元锂',
        328000.00,
        8,
        '2023-06-01',
        35,
        'L2+',
        '蔚来ET5是一款中型纯电轿车',
        JSON_OBJECT(
            '驱动形式',
            '双电机四驱',
            '零百加速',
            '4.0s'
        ),
        JSON_ARRAY(
            'https://example.com/et5-1.jpg'
        ),
        NOW(),
        NOW(),
        0
    ),
    (
        2,
        '比亚迪 海豹',
        '比亚迪',
        650,
        '磷酸铁锂',
        228000.00,
        3,
        '2023-03-01',
        28,
        'L2',
        '比亚迪海豹是一款运动型纯电轿车',
        JSON_OBJECT('驱动形式', '后驱', '零百加速', '5.9s'),
        JSON_ARRAY(
            'https://example.com/seal-1.jpg'
        ),
        NOW(),
        NOW(),
        0
    ),
    (
        3,
        '特斯拉 Model Y',
        '特斯拉',
        545,
        '三元锂',
        261900.00,
        12,
        '2022-01-01',
        25,
        'L2',
        '特斯拉Model Y是一款中型SUV',
        JSON_OBJECT(
            '驱动形式',
            '双电机四驱',
            '零百加速',
            '5.0s'
        ),
        JSON_ARRAY(
            'https://example.com/modely-1.jpg'
        ),
        NOW(),
        NOW(),
        0
    ),
    (
        4,
        '小鹏 P7',
        '小鹏',
        610,
        '三元锂',
        209900.00,
        6,
        '2021-03-01',
        30,
        'L2+',
        '小鹏P7是一款中型纯电轿车',
        JSON_OBJECT('驱动形式', '后驱', '零百加速', '6.4s'),
        JSON_ARRAY(
            'https://example.com/p7-1.jpg'
        ),
        NOW(),
        NOW(),
        0
    ),
    (
        5,
        '理想 L7',
        '理想',
        1315,
        '三元锂',
        319800.00,
        9,
        '2023-02-01',
        40,
        'L2',
        '理想L7是一款中大型SUV',
        JSON_OBJECT('驱动形式', '增程式', '零百加速', '5.8s'),
        JSON_ARRAY(
            'https://example.com/l7-1.jpg'
        ),
        NOW(),
        NOW(),
        0
    ),
    (
        6,
        '极氪 001',
        '极氪',
        712,
        '三元锂',
        299000.00,
        5,
        '2021-10-01',
        36,
        'L2+',
        '极氪001是一款中大型纯电轿车',
        JSON_OBJECT(
            '驱动形式',
            '双电机四驱',
            '零百加速',
            '3.8s'
        ),
        JSON_ARRAY(
            'https://example.com/001-1.jpg'
        ),
        NOW(),
        NOW(),
        0
    ),
    (
        7,
        '广汽埃安 AION S Plus',
        '广汽埃安',
        602,
        '磷酸铁锂',
        149800.00,
        15,
        '2022-06-01',
        35,
        'L2',
        '广汽埃安AION S Plus是一款紧凑型纯电轿车',
        JSON_OBJECT('驱动形式', '前驱', '零百加速', '7.6s'),
        JSON_ARRAY(
            'https://example.com/aions-1.jpg'
        ),
        NOW(),
        NOW(),
        0
    ),
    (
        8,
        '长安深蓝 SL03',
        '长安深蓝',
        705,
        '磷酸铁锂',
        171900.00,
        7,
        '2022-07-01',
        38,
        'L2',
        '长安深蓝SL03是一款中型纯电轿车',
        JSON_OBJECT('驱动形式', '后驱', '零百加速', '5.9s'),
        JSON_ARRAY(
            'https://example.com/sl03-1.jpg'
        ),
        NOW(),
        NOW(),
        0
    ),
    (
        9,
        '华为问界 M5',
        '华为',
        1100,
        '三元锂',
        249800.00,
        8,
        '2022-12-01',
        45,
        'L2+',
        '华为问界M5是一款中型SUV',
        JSON_OBJECT('驱动形式', '增程式', '零百加速', '4.4s'),
        JSON_ARRAY(
            'https://example.com/m5-1.jpg'
        ),
        NOW(),
        NOW(),
        0
    ),
    (
        10,
        '哪吒 U Pro',
        '哪吒',
        610,
        '三元锂',
        129800.00,
        12,
        '2021-04-01',
        35,
        'L2',
        '哪吒U Pro是一款紧凑型SUV',
        JSON_OBJECT('驱动形式', '前驱', '零百加速', '7.9s'),
        JSON_ARRAY(
            'https://example.com/u-pro-1.jpg'
        ),
        NOW(),
        NOW(),
        0
    ),
    (
        11,
        '大众 ID.4 CROZZ',
        '大众',
        550,
        '三元锂',
        199900.00,
        5,
        '2021-03-01',
        40,
        'L2',
        '大众ID.4 CROZZ是一款紧凑型SUV',
        JSON_OBJECT('驱动形式', '后驱', '零百加速', '8.2s'),
        JSON_ARRAY(
            'https://example.com/id4-1.jpg'
        ),
        NOW(),
        NOW(),
        0
    ),
    (
        12,
        '比亚迪 汉 EV',
        '比亚迪',
        715,
        '磷酸铁锂',
        219800.00,
        6,
        '2020-07-01',
        30,
        'L2',
        '比亚迪汉EV是一款中大型纯电轿车',
        JSON_OBJECT('驱动形式', '四驱', '零百加速', '3.9s'),
        JSON_ARRAY(
            'https://example.com/han-1.jpg'
        ),
        NOW(),
        NOW(),
        0
    );

UNLOCK TABLES;

--
-- Table structure for table `user_profile`
-- 用户档案表（购车客户）
--

DROP TABLE IF EXISTS `user_profile`;

CREATE TABLE `user_profile` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `name` varchar(50) DEFAULT NULL COMMENT '姓名',
    `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
    `id_number` varchar(18) DEFAULT NULL COMMENT '身份证号',
    `address` varchar(200) DEFAULT NULL COMMENT '地址',
    `register_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
    `prefer_brands` json DEFAULT NULL COMMENT '偏好品牌（JSON数组）',
    `prefer_battery_types` json DEFAULT NULL COMMENT '偏好电池类型（JSON数组）',
    `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
    `update_date` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted` tinyint(1) DEFAULT '0',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_phone` (`phone`),
    KEY `idx_register_time` (`register_time`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '用户档案表';

--
-- Dumping data for table `user_profile`
--

LOCK TABLES `user_profile` WRITE;

INSERT INTO
    `user_profile`
VALUES (
        1,
        '管理员',
        '13800000000',
        NULL,
        '总部门店',
        DATE_SUB(NOW(), INTERVAL 30 DAY),
        NULL,
        NULL,
        NOW(),
        NOW(),
        0
    ),
    (
        2,
        'Alice',
        '13900000001',
        NULL,
        '上海虹桥提车中心',
        DATE_SUB(NOW(), INTERVAL 12 DAY),
        JSON_ARRAY('蔚来', '比亚迪'),
        JSON_ARRAY('三元锂'),
        NOW(),
        NOW(),
        0
    );

UNLOCK TABLES;

--
-- Table structure for table `promotion`
-- 促销活动表
--

DROP TABLE IF EXISTS `promotion`;

CREATE TABLE `promotion` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `vehicle_id` bigint DEFAULT NULL COMMENT '关联车型ID',
    `title` varchar(100) DEFAULT NULL COMMENT '活动标题',
    `type` varchar(50) DEFAULT NULL COMMENT '活动类型（车型折扣、购车送充电桩、置换补贴等）',
    `description` text COMMENT '活动描述',
    `discount_rate` decimal(3, 2) DEFAULT NULL COMMENT '折扣比例（0.9表示9折）',
    `gift` varchar(200) DEFAULT NULL COMMENT '赠品',
    `subsidy` decimal(10, 2) DEFAULT NULL COMMENT '补贴金额',
    `start_date` date DEFAULT NULL COMMENT '开始日期',
    `end_date` date DEFAULT NULL COMMENT '结束日期',
    `status` varchar(20) DEFAULT 'ONLINE' COMMENT '状态（ONLINE/OFFLINE）',
    `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
    `update_date` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted` tinyint(1) DEFAULT '0',
    PRIMARY KEY (`id`),
    KEY `idx_vehicle_id` (`vehicle_id`),
    KEY `idx_status` (`status`),
    KEY `idx_date_range` (`start_date`, `end_date`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '促销活动表';

--
-- Dumping data for table `promotion`
--

LOCK TABLES `promotion` WRITE;

INSERT INTO
    `promotion`
VALUES (
        1,
        2,
        '海豹春季折扣',
        '车型折扣',
        '限时9折并赠送家用充电桩',
        0.90,
        '家用充电桩',
        NULL,
        DATE_SUB(NOW(), INTERVAL 10 DAY),
        DATE_ADD(NOW(), INTERVAL 20 DAY),
        'ONLINE',
        NOW(),
        NOW(),
        0
    );

UNLOCK TABLES;

--
-- Table structure for table `financial_plan`
-- 金融方案表
--

DROP TABLE IF EXISTS `financial_plan`;

CREATE TABLE `financial_plan` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `vehicle_id` bigint DEFAULT NULL COMMENT '关联车型ID',
    `name` varchar(100) DEFAULT NULL COMMENT '方案名称',
    `down_payment_rate` decimal(3, 2) DEFAULT NULL COMMENT '首付比例（0.2表示20%）',
    `months` int DEFAULT NULL COMMENT '分期期数（月）',
    `annual_rate` decimal(5, 4) DEFAULT NULL COMMENT '年化利率',
    `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
    `update_date` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted` tinyint(1) DEFAULT '0',
    PRIMARY KEY (`id`),
    KEY `idx_vehicle_id` (`vehicle_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '金融方案表';

--
-- Dumping data for table `financial_plan`
--

LOCK TABLES `financial_plan` WRITE;

INSERT INTO
    `financial_plan`
VALUES (
        1,
        3,
        '轻享金融 20% 首付',
        0.20,
        36,
        0.0380,
        NOW(),
        NOW(),
        0
    ),
    -- 蔚来 ET5 金融方案
    (
        2,
        1,
        '低首付方案 20%首付',
        0.20,
        36,
        0.0380,
        NOW(),
        NOW(),
        0
    ),
    (
        3,
        1,
        '标准方案 30%首付',
        0.30,
        24,
        0.0350,
        NOW(),
        NOW(),
        0
    ),
    (
        4,
        1,
        '灵活方案 50%首付',
        0.50,
        12,
        0.0280,
        NOW(),
        NOW(),
        0
    ),
    (
        5,
        1,
        '超长分期 20%首付',
        0.20,
        60,
        0.0420,
        NOW(),
        NOW(),
        0
    ),
    (
        6,
        1,
        '零息优惠 30%首付',
        0.30,
        12,
        0.0000,
        NOW(),
        NOW(),
        0
    ),
    (
        7,
        1,
        '高首付低息 60%首付',
        0.60,
        24,
        0.0250,
        NOW(),
        NOW(),
        0
    ),
    (
        8,
        1,
        '全款购车',
        1.00,
        1,
        0.0000,
        NOW(),
        NOW(),
        0
    );

UNLOCK TABLES;

--
-- Table structure for table `order_record`
-- 订单记录表
--

DROP TABLE IF EXISTS `order_record`;

CREATE TABLE `order_record` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `order_no` varchar(50) NOT NULL COMMENT '订单编号',
    `user_id` bigint DEFAULT NULL COMMENT '购车用户ID',
    `vehicle_id` bigint DEFAULT NULL COMMENT '车型ID',
    `quantity` int DEFAULT '1' COMMENT '购车数量',
    `store` varchar(100) DEFAULT NULL COMMENT '提车门店',
    `contact_name` varchar(50) DEFAULT NULL COMMENT '联系人姓名',
    `contact_phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
    `status` varchar(20) DEFAULT 'WAIT_PAY' COMMENT '订单状态（WAIT_PAY/PAID/WAIT_PICKUP/COMPLETED/CANCELLED）',
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '下单时间',
    `paid_at` datetime DEFAULT NULL COMMENT '支付时间',
    `pickup_at` datetime DEFAULT NULL COMMENT '提车时间',
    `price_per_unit` decimal(10, 2) DEFAULT NULL COMMENT '单价',
    `total_amount` decimal(10, 2) DEFAULT NULL COMMENT '订单总金额',
    `promotion_title` varchar(100) DEFAULT NULL COMMENT '使用的促销活动标题',
    `promotion_id` bigint DEFAULT NULL COMMENT '使用的促销活动ID',
    `financial_plan_id` bigint DEFAULT NULL COMMENT '使用的金融方案ID',
    `remark` varchar(500) DEFAULT NULL COMMENT '备注',
    `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
    `update_date` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted` tinyint(1) DEFAULT '0',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_vehicle_id` (`vehicle_id`),
    KEY `idx_status` (`status`),
    KEY `idx_created_at` (`created_at`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '订单记录表';

--
-- Dumping data for table `order_record`
--

LOCK TABLES `order_record` WRITE;

INSERT INTO
    `order_record`
VALUES (
        1,
        'ORD20240001',
        2,
        2,
        1,
        '上海浦东店',
        'Alice',
        '13900000001',
        'PAID',
        DATE_SUB(NOW(), INTERVAL 5 DAY),
        DATE_SUB(NOW(), INTERVAL 4 DAY),
        NULL,
        228000.00,
        205200.00,
        '海豹春季折扣',
        1,
        NULL,
        NULL,
        NOW(),
        NOW(),
        0
    );

UNLOCK TABLES;

--
-- Table structure for table `review_record`
-- 评价记录表
--

DROP TABLE IF EXISTS `review_record`;

CREATE TABLE `review_record` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `order_id` bigint DEFAULT NULL COMMENT '关联订单ID',
    `user_id` bigint DEFAULT NULL COMMENT '评价用户ID',
    `vehicle_id` bigint DEFAULT NULL COMMENT '车型ID',
    `rating` int DEFAULT NULL COMMENT '评分（1-5星）',
    `comment` text COMMENT '文字评价',
    `photos` json DEFAULT NULL COMMENT '晒单照片（JSON数组）',
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
    `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
    `update_date` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted` tinyint(1) DEFAULT '0',
    PRIMARY KEY (`id`),
    KEY `idx_order_id` (`order_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_vehicle_id` (`vehicle_id`),
    KEY `idx_rating` (`rating`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '评价记录表';

--
-- Dumping data for table `review_record`
--

LOCK TABLES `review_record` WRITE;

UNLOCK TABLES;

--
-- Table structure for table `test_drive_record`
-- 试驾记录表
--

DROP TABLE IF EXISTS `test_drive_record`;

CREATE TABLE `test_drive_record` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `user_id` bigint DEFAULT NULL COMMENT '预约用户ID',
    `vehicle_id` bigint DEFAULT NULL COMMENT '车型ID',
    `store` varchar(100) DEFAULT NULL COMMENT '试驾门店',
    `schedule_time` datetime DEFAULT NULL COMMENT '预约试驾时间',
    `status` varchar(20) DEFAULT 'PENDING' COMMENT '审核状态（PENDING/APPROVED/REJECTED/COMPLETED）',
    `admin_note` varchar(500) DEFAULT NULL COMMENT '管理员备注',
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
    `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
    `update_date` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted` tinyint(1) DEFAULT '0',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_vehicle_id` (`vehicle_id`),
    KEY `idx_status` (`status`),
    KEY `idx_schedule_time` (`schedule_time`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '试驾记录表';

--
-- Dumping data for table `test_drive_record`
--

LOCK TABLES `test_drive_record` WRITE;

UNLOCK TABLES;

--
-- Table structure for table `browse_history`
-- 浏览记录表（用于推荐功能）
--

DROP TABLE IF EXISTS `browse_history`;

CREATE TABLE `browse_history` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `user_id` bigint DEFAULT NULL COMMENT '用户ID',
    `vehicle_id` bigint DEFAULT NULL COMMENT '车型ID',
    `browse_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '浏览时间',
    `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
    `update_date` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted` tinyint(1) DEFAULT '0',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_vehicle_id` (`vehicle_id`),
    KEY `idx_browse_time` (`browse_time`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '浏览记录表';

--
-- Table structure for table `inventory_subscription`
-- 库存订阅表（用于库存提醒功能）
--

DROP TABLE IF EXISTS `inventory_subscription`;

CREATE TABLE `inventory_subscription` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `user_id` bigint DEFAULT NULL COMMENT '订阅用户ID',
    `vehicle_id` bigint DEFAULT NULL COMMENT '车型ID',
    `notified` tinyint(1) DEFAULT '0' COMMENT '是否已通知',
    `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
    `update_date` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted` tinyint(1) DEFAULT '0',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_vehicle` (`user_id`, `vehicle_id`),
    KEY `idx_notified` (`notified`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '库存订阅表';

-- -------------------------------------------------------
-- 登录与角色基础表（沿用原系统结构，供登录使用）
-- -------------------------------------------------------

DROP TABLE IF EXISTS `role`;

CREATE TABLE `role` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `name` varchar(20) DEFAULT NULL,
    `detail` varchar(250) DEFAULT NULL,
    `is_deleted` tinyint(1) DEFAULT '0',
    `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
    `update_date` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb3 COMMENT = '角色表';

LOCK TABLES `role` WRITE;

INSERT INTO
    `role`
VALUES (
        1,
        '学生',
        '学生用户',
        0,
        NOW(),
        NOW()
    ),
    (
        2,
        '中心管理员',
        '中心管理员',
        0,
        NOW(),
        NOW()
    ),
    (
        3,
        '初访员',
        '初访员',
        0,
        NOW(),
        NOW()
    ),
    (
        4,
        '心理助理',
        '心理助理',
        0,
        NOW(),
        NOW()
    ),
    (
        5,
        '咨询员',
        '咨询员',
        0,
        NOW(),
        NOW()
    );

UNLOCK TABLES;

DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `loginName` varchar(50) DEFAULT NULL,
    `password` varchar(50) DEFAULT NULL,
    `name` varchar(30) DEFAULT NULL,
    `sex` varchar(10) DEFAULT NULL,
    `birth` date DEFAULT NULL,
    `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
    `update_date` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted` tinyint(1) DEFAULT '0',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb3 COMMENT = '登录用户表';

LOCK TABLES `user` WRITE;

INSERT INTO
    `user`
VALUES (
        1,
        '20240111',
        '123456',
        '黄俊凯',
        '男',
        '2003-04-11',
        NOW(),
        NOW(),
        0
    ),
    (
        2,
        '20240112',
        '123456',
        '牟展宏',
        '男',
        '2002-11-06',
        NOW(),
        NOW(),
        0
    ),
    (
        3,
        '20240113',
        '123456',
        '宋天鹏',
        '男',
        '2000-01-01',
        NOW(),
        NOW(),
        0
    ),
    (
        4,
        '20240114',
        '123456',
        '谢志成',
        '男',
        '2000-01-01',
        NOW(),
        NOW(),
        0
    ),
    (
        5,
        '20230101',
        '123456',
        '金莉',
        '女',
        '2000-01-01',
        NOW(),
        NOW(),
        0
    ),
    (
        6,
        '20230102',
        '123456',
        '路璐',
        '女',
        '2000-01-01',
        NOW(),
        NOW(),
        0
    ),
    (
        7,
        '20230103',
        '123456',
        '祝继华',
        '男',
        '2000-01-01',
        NOW(),
        NOW(),
        0
    ),
    (
        8,
        '20230104',
        '123456',
        '杜小智',
        '男',
        '2000-01-01',
        NOW(),
        NOW(),
        0
    ),
    (
        9,
        '20230105',
        '123456',
        '宋永红',
        '女',
        '2000-01-01',
        NOW(),
        NOW(),
        0
    ),
    (
        10,
        '20230106',
        '123456',
        '白秀秀',
        '女',
        '2000-01-01',
        NOW(),
        NOW(),
        0
    ),
    (
        11,
        '20230107',
        '123456',
        '原盛',
        '男',
        '2000-01-01',
        NOW(),
        NOW(),
        0
    ),
    (
        12,
        '20230108',
        '123456',
        '饶元',
        '男',
        '2000-01-01',
        NOW(),
        NOW(),
        0
    ),
    (
        13,
        '20230109',
        '123456',
        '张斌',
        '男',
        '2000-01-01',
        NOW(),
        NOW(),
        0
    ),
    (
        14,
        'admin',
        '123456',
        '管理员',
        '男',
        '2000-01-01',
        NOW(),
        NOW(),
        0
    );

UNLOCK TABLES;

DROP TABLE IF EXISTS `user_role`;

CREATE TABLE `user_role` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `uid` bigint NOT NULL,
    `rid` bigint NOT NULL,
    `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
    `update_date` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_deleted` tinyint(1) DEFAULT '0',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb3 COMMENT = '用户-角色关联表';

LOCK TABLES `user_role` WRITE;

INSERT INTO
    `user_role`
VALUES (1, 1, 1, NOW(), NOW(), 0),
    (2, 2, 1, NOW(), NOW(), 0),
    (3, 3, 1, NOW(), NOW(), 0),
    (4, 4, 1, NOW(), NOW(), 0),
    (5, 5, 2, NOW(), NOW(), 0),
    (6, 6, 2, NOW(), NOW(), 0),
    (7, 7, 3, NOW(), NOW(), 0),
    (8, 8, 3, NOW(), NOW(), 0),
    (9, 9, 3, NOW(), NOW(), 0),
    (10, 10, 4, NOW(), NOW(), 0),
    (11, 11, 5, NOW(), NOW(), 0),
    (12, 12, 5, NOW(), NOW(), 0),
    (13, 13, 5, NOW(), NOW(), 0),
    (14, 14, 2, NOW(), NOW(), 0);

UNLOCK TABLES;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */
;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */
;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */
;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */
;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */
;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */
;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */
;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */
;

-- Dump completed