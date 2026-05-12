package com.printquote.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

@Data
@TableName(value = "quote_history", autoResultMap = true)
public class QuoteHistory {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private String sessionId;

    private Long categoryId;

    private String productName;

    @TableField(typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> formData;

    @TableField(typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> rawFormData;

    private BigDecimal price;

    private LocalDateTime createTime;
}
