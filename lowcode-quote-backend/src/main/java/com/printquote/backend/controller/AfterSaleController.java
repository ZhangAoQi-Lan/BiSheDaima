package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.printquote.backend.entity.AfterSale;
import com.printquote.backend.entity.OrderInfo;
import com.printquote.backend.mapper.AfterSaleMapper;
import com.printquote.backend.mapper.OrderInfoMapper;
import com.printquote.backend.utils.AuthContextUtils;
import com.printquote.backend.vo.Result;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/mall/after-sale")
public class AfterSaleController {

    @Autowired
    private AfterSaleMapper afterSaleMapper;

    @Autowired
    private OrderInfoMapper orderInfoMapper;

    @GetMapping("")
    public Result<List<AfterSale>> list(HttpServletRequest request) {
        Long userId = AuthContextUtils.resolveUserId(request);
        return Result.success(afterSaleMapper.selectList(
                new LambdaQueryWrapper<AfterSale>()
                        .eq(AfterSale::getUserId, userId)
                        .orderByDesc(AfterSale::getCreateTime)
        ));
    }

    @PostMapping("")
    public Result<AfterSale> create(@RequestBody Map<String, String> body, HttpServletRequest request) {
        Long userId = AuthContextUtils.resolveUserId(request);
        Long orderId = Long.valueOf(body.get("orderId"));
        OrderInfo order = orderInfoMapper.selectById(orderId);
        if (order == null || !userId.equals(order.getUserId())) {
            return Result.error("订单不存在或无权申请售后");
        }

        Long existCount = afterSaleMapper.selectCount(
                new LambdaQueryWrapper<AfterSale>()
                        .eq(AfterSale::getOrderId, orderId)
                        .eq(AfterSale::getUserId, userId)
        );
        if (existCount > 0) {
            return Result.error("该订单已提交售后申请");
        }

        AfterSale afterSale = new AfterSale();
        afterSale.setOrderId(orderId);
        afterSale.setUserId(userId);
        afterSale.setReason(body.get("reason"));
        afterSale.setDescription(body.get("description"));
        afterSale.setStatus("PENDING");
        afterSale.setCreateTime(LocalDateTime.now());
        afterSale.setUpdateTime(LocalDateTime.now());
        afterSaleMapper.insert(afterSale);
        return Result.success(afterSale);
    }
}
