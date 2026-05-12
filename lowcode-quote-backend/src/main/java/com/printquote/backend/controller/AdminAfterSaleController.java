package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.printquote.backend.entity.AfterSale;
import com.printquote.backend.entity.OrderInfo;
import com.printquote.backend.entity.User;
import com.printquote.backend.mapper.AfterSaleMapper;
import com.printquote.backend.mapper.OrderInfoMapper;
import com.printquote.backend.mapper.UserMapper;
import com.printquote.backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api/admin/after-sale")
public class AdminAfterSaleController {

    @Autowired
    private AfterSaleMapper afterSaleMapper;

    @Autowired
    private OrderInfoMapper orderInfoMapper;

    @Autowired
    private UserMapper userMapper;

    @GetMapping("/list")
    public Result<List<Map<String, Object>>> list(@RequestParam(required = false) String status) {
        LambdaQueryWrapper<AfterSale> query = new LambdaQueryWrapper<AfterSale>()
                .orderByDesc(AfterSale::getCreateTime);
        if (status != null && !status.isBlank()) {
            query.eq(AfterSale::getStatus, status);
        }

        List<AfterSale> records = afterSaleMapper.selectList(query);
        Set<Long> userIds = new HashSet<>();
        Set<Long> orderIds = new HashSet<>();
        for (AfterSale record : records) {
            if (record.getUserId() != null) {
                userIds.add(record.getUserId());
            }
            if (record.getOrderId() != null) {
                orderIds.add(record.getOrderId());
            }
        }

        Map<Long, String> usernameMap = new HashMap<>();
        for (User user : userIds.isEmpty() ? Collections.<User>emptyList() : userMapper.selectBatchIds(userIds)) {
            usernameMap.put(user.getId(), user.getUsername());
        }

        Map<Long, OrderInfo> orderMap = new HashMap<>();
        for (OrderInfo order : orderIds.isEmpty() ? Collections.<OrderInfo>emptyList() : orderInfoMapper.selectBatchIds(orderIds)) {
            orderMap.put(order.getId(), order);
        }

        List<Map<String, Object>> result = new ArrayList<>();
        for (AfterSale record : records) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", record.getId());
            item.put("orderId", record.getOrderId());
            item.put("username", usernameMap.getOrDefault(record.getUserId(), "未知用户"));
            item.put("reason", record.getReason());
            item.put("description", record.getDescription());
            item.put("status", record.getStatus());
            item.put("createTime", record.getCreateTime());
            item.put("updateTime", record.getUpdateTime());
            OrderInfo order = orderMap.get(record.getOrderId());
            item.put("orderStatus", order != null ? order.getStatus() : null);
            item.put("orderAmount", order != null ? order.getTotalPrice() : null);
            result.add(item);
        }
        return Result.success(result);
    }

    @PutMapping("/{id}/status")
    public Result<Void> updateStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        AfterSale afterSale = afterSaleMapper.selectById(id);
        if (afterSale == null) {
            return Result.error("售后申请不存在");
        }
        afterSale.setStatus(body.get("status"));
        afterSale.setUpdateTime(LocalDateTime.now());
        afterSaleMapper.updateById(afterSale);
        return Result.success(null);
    }
}
