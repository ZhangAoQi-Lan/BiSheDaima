package com.printquote.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;
import java.util.Date;

@Data
@TableName("product_schema")
public class CategorySchema {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField("product_id")
    private Long categoryId;
    
    private String schemaJson;
    
    private Date updateTime;
}
