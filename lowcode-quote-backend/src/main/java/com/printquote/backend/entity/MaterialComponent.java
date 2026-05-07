package com.printquote.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("material_component")
public class MaterialComponent {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String type;
    
    private String label;
    
    private String icon;
    
    // 归属分类：materials物料, sizeGroup尺寸, crafts工艺, elements通用
    private String category;
    
    // 预设的具体业务选项数据 (预设下拉项、价格体系等)
    private String optionsJson;
    
    private Integer status;
    
    private Date createTime;
    
    private Date updateTime;
}
