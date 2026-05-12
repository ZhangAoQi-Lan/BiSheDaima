package com.printquote.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("order_timeline")
public class OrderTimeline {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long orderId;

    private String status;

    private String title;

    private String description;

    private String operatorType;

    private LocalDateTime createTime;
}
