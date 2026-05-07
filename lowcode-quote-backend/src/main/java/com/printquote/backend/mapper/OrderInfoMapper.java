package com.printquote.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.printquote.backend.entity.OrderInfo;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface OrderInfoMapper extends BaseMapper<OrderInfo> {
}
