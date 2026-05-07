-- cart_item 表建表语句
-- 暂存箱功能：每条记录代表用户在报价配置页面加入的一份定制配置快照
-- 10分钟不操作自动过期（由后端定时清理或前端倒计时触发删除）

CREATE TABLE IF NOT EXISTS `cart_item` (
  `id`           BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id`      BIGINT      NULL     COMMENT '登录用户ID，未登录时为NULL',
  `session_id`   VARCHAR(64) NOT NULL COMMENT '前端本地生成的匿名会话ID（localStorage存储）',
  `product_id`   BIGINT      NOT NULL COMMENT '关联商品ID',
  `product_name` VARCHAR(128) NOT NULL COMMENT '商品名称快照',
  `form_data`    JSON        NOT NULL COMMENT '表单配置快照（JSON）',
  `price`        DECIMAL(10, 2) NOT NULL COMMENT '当时计算的预估价格',
  `create_time`  DATETIME    NOT NULL DEFAULT NOW() COMMENT '创建时间',
  `expires_at`   DATETIME    NOT NULL COMMENT '过期时间（创建时间 + 10分钟）',
  PRIMARY KEY (`id`),
  INDEX `idx_session_id` (`session_id`),
  INDEX `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报价暂存箱';
