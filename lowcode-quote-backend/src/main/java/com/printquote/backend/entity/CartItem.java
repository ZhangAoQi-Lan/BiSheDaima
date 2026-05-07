package com.printquote.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

@Data
@TableName(value = "cart_item", autoResultMap = true)
public class CartItem {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 用户ID（需要登录场景使用），未登录时为 null */
    private Long userId;

    /** 匿名用户标识（存在 localStorage，用于未登录时识别用户） */
    private String sessionId;

    @TableField("product_id")
    private Long categoryId;

    private String productName;

    /** 表单配置快照，以 JSON 形式存储 */
    @TableField(typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> formData;

    private BigDecimal price;

    /** 加入时间 */
    private LocalDateTime createTime;

    /** 过期时间 = createTime + 10 分钟，到期后自动删除 */
    private LocalDateTime expiresAt;
}
