package com.printquote.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("help_category")
public class HelpCategory {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;

    private String description;

    private String icon;

    private String gradient;

    private Integer sortOrder;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
