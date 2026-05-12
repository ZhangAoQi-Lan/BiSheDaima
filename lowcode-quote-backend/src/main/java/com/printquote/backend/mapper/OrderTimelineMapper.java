package com.printquote.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.printquote.backend.entity.OrderTimeline;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface OrderTimelineMapper extends BaseMapper<OrderTimeline> {
}
