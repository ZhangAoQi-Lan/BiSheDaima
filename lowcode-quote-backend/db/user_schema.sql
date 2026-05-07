-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(100) NOT NULL COMMENT '密码 (建议哈希存储)',
  `phone` varchar(20) DEFAULT NULL COMMENT '绑定的手机号',
  `email` varchar(50) DEFAULT NULL COMMENT '绑定的邮箱',
  `role` varchar(20) NOT NULL DEFAULT 'USER' COMMENT '角色：ADMIN-管理员，USER-普通用户',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_phone` (`phone`),
  UNIQUE KEY `uk_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 插入默认的管理员和普通用户进行测试 (密码需按实际 Bcrypt 处理，为了使原测试账号能登入建议按后续新接口逻辑先注册或者我们使用 BCrypt 默认 123456 的结果，这里演示更新为加密密文 $2a$10$wKqR4qTz8y2e2.49h/O3lO62T6g90e3T7Qx.Zq/Z02WnIf6xT/4Tq)
INSERT IGNORE INTO `user` (`username`, `password`, `phone`, `email`, `role`) VALUES 
('admin', '$2a$10$wKqR4qTz8y2e2.49h/O3lO62T6g90e3T7Qx.Zq/Z02WnIf6xT/4Tq', '13800000000', 'admin@example.com', 'ADMIN'),
('user', '$2a$10$wKqR4qTz8y2e2.49h/O3lO62T6g90e3T7Qx.Zq/Z02WnIf6xT/4Tq', '13811111111', 'user@example.com', 'USER');
