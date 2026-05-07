-- 创建库
CREATE DATABASE IF NOT EXISTS print_quote_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE print_quote_db;

-- -------------
-- 1. 产品基础表 (用于商品上架和管理列表)
-- -------------
CREATE TABLE IF NOT EXISTS `product` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` VARCHAR(128) NOT NULL COMMENT '产品名称，如：高级商务名片、宣传画册',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0下架，1上架',
  `base_price` DECIMAL(10,2) DEFAULT '0.00' COMMENT '产品基础计价(起步价)',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='印刷产品基础表';

-- 插入一条测试数据
INSERT INTO `product` (`name`, `status`, `base_price`) VALUES ('首版测试名片', 1, 0.00);

-- -------------
-- 2. 产品配置图纸表 (用于通过 JSON 保存管理端设计的动态表单及约束规则 Schema)
-- -------------
CREATE TABLE IF NOT EXISTS `product_schema` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '图纸ID',
  `product_id` BIGINT NOT NULL COMMENT '关联的具体产品ID',
  `schema_json` LONGTEXT NOT NULL COMMENT '由低代码配置器生成的 Schema JSON 原文，驱动前端的一切',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_product_id` (`product_id`) -- 一个产品目前只对应一份图纸
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品 Schema 动态配置表（低代码图纸池）';

-- 插入一条空图纸作为测试产品的绑定
INSERT INTO `product_schema` (`product_id`, `schema_json`) VALUES (1, '{"productId":"1","productName":"首版测试名片","elements":[],"constraints":[],"pricing":{"basePrice":0.0}}');
