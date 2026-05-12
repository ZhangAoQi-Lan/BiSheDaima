package com.printquote.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.printquote.backend.entity.OrderItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface OrderItemMapper extends BaseMapper<OrderItem> {

    @Select("SELECT product_name AS name, COUNT(*) AS total FROM order_item GROUP BY product_name ORDER BY total DESC LIMIT #{limit}")
    List<Map<String, Object>> selectTopProducts(@Param("limit") int limit);
}
