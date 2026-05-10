-- 用户资料扩展迁移
-- 添加昵称和头像字段

ALTER TABLE `user`
  ADD COLUMN `nickname` varchar(50) DEFAULT NULL COMMENT '显示昵称' AFTER `email`,
  ADD COLUMN `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL' AFTER `nickname`;
