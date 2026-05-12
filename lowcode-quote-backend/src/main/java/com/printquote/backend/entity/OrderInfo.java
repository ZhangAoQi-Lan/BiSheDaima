package com.printquote.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("order_info")
public class OrderInfo {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private String sessionId;

    private BigDecimal totalPrice;

    private String status;

    private String receiverName;

    private String receiverPhone;

    private String receiverAddress;

    private String orderRemark;

    private String artworkName;

    private String artworkUrl;

    private String productionNote;

    private String trackingNo;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
