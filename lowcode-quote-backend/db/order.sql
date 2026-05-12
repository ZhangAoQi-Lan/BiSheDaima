-- 订单主表
CREATE TABLE IF NOT EXISTS `order_info` (
  `id`           BIGINT        NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `user_id`      BIGINT        NULL     COMMENT '登录用户ID，未登录时为NULL',
  `session_id`   VARCHAR(64)   NULL     COMMENT '匿名会话ID',
  `total_price`  DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '订单总价',
  `status`       VARCHAR(20)   NOT NULL DEFAULT 'PENDING' COMMENT '状态: PENDING-待处理, PROCESSED-已处理, SHIPPED-已发货, COMPLETED-已完成, CANCELLED-已取消',
  `receiver_name` VARCHAR(50)  DEFAULT NULL COMMENT '收货人',
  `receiver_phone` VARCHAR(20) DEFAULT NULL COMMENT '联系电话',
  `receiver_address` VARCHAR(255) DEFAULT NULL COMMENT '收货地址',
  `order_remark` VARCHAR(255) DEFAULT NULL COMMENT '订单备注',
  `artwork_name` VARCHAR(255) DEFAULT NULL COMMENT '设计稿文件名',
  `artwork_url` VARCHAR(500) DEFAULT NULL COMMENT '设计稿地址',
  `production_note` VARCHAR(500) DEFAULT NULL COMMENT '生产备注',
  `tracking_no` VARCHAR(100) DEFAULT NULL COMMENT '物流单号',
  `create_time`  DATETIME      NOT NULL DEFAULT NOW() COMMENT '创建时间',
  `update_time`  DATETIME      NOT NULL DEFAULT NOW() ON UPDATE NOW() COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_session_id` (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单主表';

-- 订单明细表
CREATE TABLE IF NOT EXISTS `order_item` (
  `id`           BIGINT        NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `order_id`     BIGINT        NOT NULL COMMENT '订单ID',
  `product_name` VARCHAR(128)  NOT NULL COMMENT '产品名称快照',
  `form_data`    JSON          NOT NULL COMMENT '表单配置快照（JSON）',
  `price`        DECIMAL(10,2) NOT NULL COMMENT '单价',
  `create_time`  DATETIME      NOT NULL DEFAULT NOW() COMMENT '创建时间',
  PRIMARY KEY (`id`),
  INDEX `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细表';

-- 订单履约时间线
CREATE TABLE IF NOT EXISTS `order_timeline` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_id` BIGINT NOT NULL COMMENT '订单ID',
  `status` VARCHAR(30) NOT NULL COMMENT '订单状态',
  `title` VARCHAR(100) NOT NULL COMMENT '节点标题',
  `description` VARCHAR(500) DEFAULT NULL COMMENT '节点说明',
  `operator_type` VARCHAR(20) NOT NULL DEFAULT 'SYSTEM' COMMENT '操作来源',
  `create_time` DATETIME NOT NULL DEFAULT NOW() COMMENT '创建时间',
  PRIMARY KEY (`id`),
  INDEX `idx_order_timeline_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单履约时间线';
