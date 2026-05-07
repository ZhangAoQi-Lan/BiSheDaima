-- ===================================================
-- 商城分类导航功能 —— 数据库迁移脚本（两级分类版）
-- 执行前请确保 Spring Boot 已停止
-- 如果之前已经执行过旧版脚本，请先执行：
--   DROP TABLE IF EXISTS `category`;
--   ALTER TABLE `product` DROP COLUMN IF EXISTS `category_id`;
-- ===================================================

-- 1. 新建两级分类表
CREATE TABLE IF NOT EXISTS `category` (
  `id`         BIGINT       NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name`       VARCHAR(50)  NOT NULL                COMMENT '分类名称',
  `parent_id`  BIGINT           NULL DEFAULT NULL   COMMENT '父分类ID，NULL=一级分类',
  `icon`       VARCHAR(100)     NULL                COMMENT '图标（预留）',
  `sort_order` INT          NOT NULL DEFAULT 0      COMMENT '排序权重，数值越小排越前',
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品两级分类表';

-- 2. 商品表新增分类关联字段（关联到二级分类ID）
ALTER TABLE `product`
  ADD COLUMN `category_id` BIGINT NULL DEFAULT NULL COMMENT '所属二级分类ID' AFTER `base_price`;

-- ===================================================
-- 3. 插入一级分类
-- ===================================================
INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES
  ('名片卡片',   NULL,  1),
  ('画册装订',   NULL,  2),
  ('不干胶标签', NULL,  3),
  ('单页折页',   NULL,  4),
  ('PVC制卡',    NULL,  5),
  ('包装盒',     NULL,  6),
  ('喷画条幅',   NULL,  7),
  ('制袋纸杯',   NULL,  8),
  ('办公用品',   NULL,  9),
  ('数码快印',   NULL, 10);

-- ===================================================
-- 4. 插入二级分类（parent_id 对应上面插入的一级分类 id）
-- 注意：id 自增，以下用变量方式写清楚对应关系
--
-- 一级分类 id 分配（自增从1开始）：
--   1=名片卡片  2=画册装订  3=不干胶标签  4=单页折页
--   5=PVC制卡   6=包装盒    7=喷画条幅    8=制袋纸杯
--   9=办公用品  10=数码快印
-- ===================================================

-- 名片卡片（parent_id = 1）
INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES
  ('铜版名片',   1,  1),
  ('精品名片',   1,  2),
  ('高档名片',   1,  3),
  ('纸质刮奖卡', 1,  4);

-- 画册装订（parent_id = 2）
INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES
  ('爆款画册',   2,  1),
  ('商务画册',   2,  2),
  ('精装画册',   2,  3),
  ('皮革笔记本', 2,  4),
  ('图书出版服务', 2, 5);

-- 不干胶标签（parent_id = 3）
INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES
  ('铜版纸不干胶', 3, 1),
  ('平张特材标签', 3, 2),
  ('卷筒标签',     3, 3),
  ('水晶标签',     3, 4);

-- 单页折页（parent_id = 4）
INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES
  ('特款单页',   4,  1),
  ('优质单页',   4,  2),
  ('折页',       4,  3),
  ('门票卡券',   4,  4),
  ('菜单',       4,  5);

-- PVC制卡（parent_id = 5）
INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES
  ('PVC标准卡',  5,  1),
  ('PVC异形卡',  5,  2),
  ('PVC数码卡',  5,  3);

-- 包装盒（parent_id = 6）
INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES
  ('卡盒',         6,  1),
  ('吊耳卡盒',     6,  2),
  ('精品天地盖盒', 6,  3),
  ('精品书型盒',   6,  4),
  ('包装盒打样',   6,  5);

-- 喷画条幅（parent_id = 7）
INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES
  ('喷绘',     7,  1),
  ('写真',     7,  2),
  ('展板',     7,  3),
  ('展架',     7,  4),
  ('锦旗绶带', 7,  5),
  ('彩旗条幅', 7,  6),
  ('标识标牌', 7,  7);

-- 制袋纸杯（parent_id = 8）
INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES
  ('纸袋',     8,  1),
  ('无纺布袋', 8,  2),
  ('帆布袋',   8,  3),
  ('纸杯',     8,  4);

-- 办公用品（parent_id = 9）
INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES
  ('联单',     9,  1),
  ('票本',     9,  2),
  ('档案袋信封', 9, 3),
  ('封套卡套', 9,  4),
  ('纸抽',     9,  5);

-- 数码快印（parent_id = 10）
INSERT INTO `category` (`name`, `parent_id`, `sort_order`) VALUES
  ('数码单页',     10, 1),
  ('数码不干胶',   10, 2),
  ('数码小卡',     10, 3),
  ('数码画册',     10, 4),
  ('数码精装画册', 10, 5),
  ('数码特价产品', 10, 6);
