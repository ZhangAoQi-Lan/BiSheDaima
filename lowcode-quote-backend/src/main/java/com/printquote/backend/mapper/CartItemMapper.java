package com.printquote.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.printquote.backend.entity.CartItem;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface CartItemMapper extends BaseMapper<CartItem> {

    /** 批量删除所有已过期的记录（由定时任务调用） */
    @Delete("DELETE FROM cart_item WHERE expires_at < NOW()")
    void deleteExpired();
}
