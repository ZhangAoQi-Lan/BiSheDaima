package com.printquote.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@TableName(value = "help_article", autoResultMap = true)
public class HelpArticle {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long categoryId;

    private String title;

    private String content;

    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<String> tags;

    private Integer views;

    private Integer readTime;

    private Integer helpfulCount;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
