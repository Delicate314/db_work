-- 创建数据库
CREATE DATABASE IF NOT EXISTS ev_sales DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE ev_sales;

-- 车型表
CREATE TABLE IF NOT EXISTS vehicle (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) DEFAULT NULL,
    brand VARCHAR(50) DEFAULT NULL,
    range_km INT DEFAULT NULL,
    battery_type VARCHAR(50) DEFAULT NULL,
    guide_price DECIMAL(10, 2) DEFAULT NULL,
    stock INT DEFAULT NULL,
    launch_date DATE DEFAULT NULL,
    fast_charge_minutes INT DEFAULT NULL,
    smart_drive_level VARCHAR(20) DEFAULT NULL,
    description TEXT DEFAULT NULL,
    configs JSON DEFAULT NULL,
    images JSON DEFAULT NULL,
    create_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted TINYINT(1) DEFAULT '0',
    PRIMARY KEY (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 促销活动表
CREATE TABLE IF NOT EXISTS promotion (
    id BIGINT NOT NULL AUTO_INCREMENT,
    vehicle_id BIGINT DEFAULT NULL,
    title VARCHAR(100) DEFAULT NULL,
    description TEXT DEFAULT NULL,
    type VARCHAR(50) DEFAULT NULL,
    discount_rate DECIMAL(3, 2) DEFAULT NULL,
    subsidy DECIMAL(10, 2) DEFAULT NULL,
    gift VARCHAR(200) DEFAULT NULL,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    status VARCHAR(20) DEFAULT 'ONLINE',
    create_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted TINYINT(1) DEFAULT '0',
    PRIMARY KEY (id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicle (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 用户信息表
CREATE TABLE IF NOT EXISTS user_profile (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) DEFAULT NULL,
    phone VARCHAR(20) DEFAULT NULL,
    email VARCHAR(100) DEFAULT NULL,
    address VARCHAR(200) DEFAULT NULL,
    register_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login_time DATETIME DEFAULT NULL,
    create_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted TINYINT(1) DEFAULT '0',
    PRIMARY KEY (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 订单记录表
CREATE TABLE IF NOT EXISTS order_record (
    id BIGINT NOT NULL AUTO_INCREMENT,
    order_no VARCHAR(50) DEFAULT NULL,
    user_id BIGINT DEFAULT NULL,
    vehicle_id BIGINT DEFAULT NULL,
    quantity INT DEFAULT '1',
    store VARCHAR(100) DEFAULT NULL,
    contact_name VARCHAR(50) DEFAULT NULL,
    contact_phone VARCHAR(20) DEFAULT NULL,
    status VARCHAR(20) DEFAULT 'WAIT_PAY',
    created_at DATETIME DEFAULT NULL,
    paid_at DATETIME DEFAULT NULL,
    pickup_at DATETIME DEFAULT NULL,
    price_per_unit DECIMAL(10, 2) DEFAULT NULL,
    total_amount DECIMAL(10, 2) DEFAULT NULL,
    promotion_title VARCHAR(100) DEFAULT NULL,
    promotion_id BIGINT DEFAULT NULL,
    financial_plan_id BIGINT DEFAULT NULL,
    remark TEXT DEFAULT NULL,
    create_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted TINYINT(1) DEFAULT '0',
    PRIMARY KEY (id),
    FOREIGN KEY (user_id) REFERENCES user_profile (id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicle (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 评价记录表
CREATE TABLE IF NOT EXISTS review_record (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT DEFAULT NULL,
    vehicle_id BIGINT DEFAULT NULL,
    order_id BIGINT DEFAULT NULL,
    rating INT DEFAULT NULL,
    comment TEXT DEFAULT NULL,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    create_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted TINYINT(1) DEFAULT '0',
    PRIMARY KEY (id),
    FOREIGN KEY (user_id) REFERENCES user_profile (id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicle (id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES order_record (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 试驾记录表
CREATE TABLE IF NOT EXISTS test_drive_record (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT DEFAULT NULL,
    vehicle_id BIGINT DEFAULT NULL,
    store VARCHAR(100) DEFAULT NULL,
    contact_name VARCHAR(50) DEFAULT NULL,
    contact_phone VARCHAR(20) DEFAULT NULL,
    apply_date DATE DEFAULT NULL,
    apply_time TIME DEFAULT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    admin_note TEXT DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    create_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted TINYINT(1) DEFAULT '0',
    PRIMARY KEY (id),
    FOREIGN KEY (user_id) REFERENCES user_profile (id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicle (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 金融方案表
CREATE TABLE IF NOT EXISTS financial_plan (
    id BIGINT NOT NULL AUTO_INCREMENT,
    vehicle_id BIGINT DEFAULT NULL,
    name VARCHAR(100) DEFAULT NULL,
    down_payment_rate DECIMAL(3, 2) DEFAULT NULL,
    months INT DEFAULT NULL,
    annual_rate DECIMAL(4, 2) DEFAULT NULL,
    description TEXT DEFAULT NULL,
    create_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted TINYINT(1) DEFAULT '0',
    PRIMARY KEY (id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicle (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 浏览历史表
CREATE TABLE IF NOT EXISTS browse_history (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT DEFAULT NULL,
    vehicle_id BIGINT DEFAULT NULL,
    browse_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    create_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted TINYINT(1) DEFAULT '0',
    PRIMARY KEY (id),
    FOREIGN KEY (user_id) REFERENCES user_profile (id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicle (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 库存订阅表
CREATE TABLE IF NOT EXISTS inventory_subscription (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT DEFAULT NULL,
    vehicle_id BIGINT DEFAULT NULL,
    notified TINYINT(1) DEFAULT '0',
    create_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted TINYINT(1) DEFAULT '0',
    PRIMARY KEY (id),
    UNIQUE KEY uk_user_vehicle (user_id, vehicle_id),
    FOREIGN KEY (user_id) REFERENCES user_profile (id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicle (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- 插入示例数据
INSERT INTO
    vehicle (
        name,
        brand,
        range_km,
        battery_type,
        guide_price,
        stock,
        launch_date,
        fast_charge_minutes,
        smart_drive_level,
        description,
        configs,
        images
    )
VALUES (
        'Model Y',
        '特斯拉',
        545,
        '三元锂',
        263900.00,
        50,
        '2020-01-07',
        30,
        'L2+',
        '特斯拉Model Y是一款中型SUV，具有出色的续航能力和智能驾驶功能',
        '{"最大功率": "258kW", "最大扭矩": "440N·m", "百公里加速": "5.9秒", "车身尺寸": "4750*1921*1624mm"}',
        '["https://example.com/model-y-1.jpg", "https://example.com/model-y-2.jpg"]'
    ),
    (
        '汉EV',
        '比亚迪',
        605,
        '磷酸铁锂',
        219800.00,
        100,
        '2020-07-12',
        33,
        'L2',
        '比亚迪汉EV是一款中大型轿车，搭载刀片电池，具有超长续航',
        '{"最大功率": "163kW", "最大扭矩": "330N·m", "百公里加速": "7.9秒", "车身尺寸": "4980*1910*1495mm"}',
        '["https://example.com/han-ev-1.jpg", "https://example.com/han-ev-2.jpg"]'
    ),
    (
        '小鹏P7',
        '小鹏',
        675,
        '三元锂',
        209900.00,
        30,
        '2020-04-27',
        29,
        'L2+',
        '小鹏P7是一款中型轿车，拥有智能座舱和丰富的智能驾驶功能',
        '{"最大功率": "196kW", "最大扭矩": "390N·m", "百公里加速": "6.7秒", "车身尺寸": "4880*1896*1458mm"}',
        '["https://example.com/xpeng-p7-1.jpg", "https://example.com/xpeng-p7-2.jpg"]'
    );

INSERT INTO
    promotion (
        vehicle_id,
        title,
        description,
        type,
        discount_rate,
        subsidy,
        gift,
        start_date,
        end_date,
        status
    )
VALUES (
        1,
        '特斯拉限时优惠',
        'Model Y限时享受8.5折优惠',
        '折扣',
        0.85,
        NULL,
        '充电桩',
        '2024-01-01',
        '2024-12-31',
        'ONLINE'
    ),
    (
        2,
        '比亚迪新春礼包',
        '汉EV购车送新春大礼包',
        '礼品',
        NULL,
        10000.00,
        '行车记录仪+脚垫',
        '2024-01-01',
        '2024-12-31',
        'ONLINE'
    ),
    (
        3,
        '小鹏金融方案',
        '小鹏P7首付低至20%',
        '金融',
        NULL,
        NULL,
        '免费保养2次',
        '2024-01-01',
        '2024-12-31',
        'ONLINE'
    );

INSERT INTO
    user_profile (
        name,
        phone,
        email,
        address,
        register_time
    )
VALUES (
        '张三',
        '13800138001',
        'zhangsan@example.com',
        '北京市朝阳区',
        '2024-01-01 10:00:00'
    ),
    (
        '李四',
        '13900139001',
        'lisi@example.com',
        '上海市浦东新区',
        '2024-01-02 11:00:00'
    ),
    (
        '王五',
        '13700137001',
        'wangwu@example.com',
        '广州市天河区',
        '2024-01-03 12:00:00'
    );

INSERT INTO
    financial_plan (
        vehicle_id,
        name,
        down_payment_rate,
        months,
        annual_rate,
        description
    )
VALUES (
        1,
        '特斯拉标准金融方案',
        0.3,
        36,
        4.99,
        '首付30%，36期免息'
    ),
    (
        1,
        '特斯拉低首付方案',
        0.2,
        48,
        5.99,
        '首付20%，48期低息'
    ),
    (
        2,
        '比亚迪轻松购',
        0.2,
        36,
        4.5,
        '首付20%，36期低息'
    ),
    (
        3,
        '小鹏金融方案',
        0.25,
        24,
        0,
        '首付25%，24期免息'
    );