package com.printquote.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.printquote.backend.entity.OrderItem;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface OrderItemMapper extends BaseMapper<OrderItem> {
}
