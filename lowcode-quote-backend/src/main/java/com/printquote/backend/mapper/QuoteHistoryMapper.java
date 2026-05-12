package com.printquote.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.printquote.backend.entity.QuoteHistory;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface QuoteHistoryMapper extends BaseMapper<QuoteHistory> {

    @Select("SELECT category_id AS categoryId, COUNT(*) AS total FROM quote_history GROUP BY category_id ORDER BY total DESC LIMIT #{limit}")
    List<Map<String, Object>> selectTopCategories(@Param("limit") int limit);
}
