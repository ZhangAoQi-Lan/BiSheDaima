package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.printquote.backend.entity.OrderInfo;
import com.printquote.backend.entity.OrderItem;
import com.printquote.backend.entity.User;
import com.printquote.backend.mapper.OrderInfoMapper;
import com.printquote.backend.mapper.OrderItemMapper;
import com.printquote.backend.mapper.UserMapper;
import com.printquote.backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin/order")
public class AdminOrderController {

    @Autowired
    private OrderInfoMapper orderInfoMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private UserMapper userMapper;

    @GetMapping("/list")
    public Result<List<Map<String, Object>>> listOrders(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String keyword
    ) {
        LambdaQueryWrapper<OrderInfo> query = new LambdaQueryWrapper<OrderInfo>()
                .orderByDesc(OrderInfo::getCreateTime);

        if (StringUtils.hasText(status)) {
            query.eq(OrderInfo::getStatus, status);
        }

        // 如果有关键字，先查用户ID
        if (StringUtils.hasText(keyword)) {
            List<Long> userIds = userMapper.selectList(
                    new LambdaQueryWrapper<User>()
                            .like(User::getUsername, keyword)
            ).stream().map(User::getId).collect(Collectors.toList());
            if (!userIds.isEmpty()) {
                query.in(OrderInfo::getUserId, userIds);
            } else {
                // 没有匹配的用户，返回空列表
                return Result.success(Collections.emptyList());
            }
        }

        List<OrderInfo> orders = orderInfoMapper.selectList(query);

        // 构建用户ID到用户名的映射
        Set<Long> userIdSet = orders.stream()
                .map(OrderInfo::getUserId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        Map<Long, String> usernameMap = new HashMap<>();
        if (!userIdSet.isEmpty()) {
            userMapper.selectBatchIds(userIdSet)
                    .forEach(u -> usernameMap.put(u.getId(), u.getUsername()));
        }

        // 组装返回数据
        List<Map<String, Object>> result = new ArrayList<>();
        for (OrderInfo order : orders) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", order.getId());
            map.put("userId", order.getUserId());
            map.put("username", order.getUserId() != null
                    ? usernameMap.getOrDefault(order.getUserId(), "未知用户")
                    : "匿名用户");
            map.put("totalPrice", order.getTotalPrice());
            map.put("status", order.getStatus());
            map.put("createTime", order.getCreateTime());
            map.put("updateTime", order.getUpdateTime());

            // 查询明细数量
            Long itemCount = orderItemMapper.selectCount(
                    new LambdaQueryWrapper<OrderItem>()
                            .eq(OrderItem::getOrderId, order.getId())
            );
            map.put("itemCount", itemCount);
            result.add(map);
        }
        return Result.success(result);
    }

    @GetMapping("/{id}")
    public Result<Map<String, Object>> getOrderDetail(@PathVariable Long id) {
        OrderInfo order = orderInfoMapper.selectById(id);
        if (order == null) {
            return Result.error("订单不存在");
        }

        List<OrderItem> items = orderItemMapper.selectList(
                new LambdaQueryWrapper<OrderItem>()
                        .eq(OrderItem::getOrderId, id)
                        .orderByAsc(OrderItem::getCreateTime)
        );

        // 获取用户名
        String username = "匿名用户";
        if (order.getUserId() != null) {
            User user = userMapper.selectById(order.getUserId());
            if (user != null) username = user.getUsername();
        }

        Map<String, Object> result = new HashMap<>();
        result.put("order", order);
        result.put("items", items);
        result.put("username", username);
        return Result.success(result);
    }

    @PutMapping("/{id}/status")
    public Result<?> updateOrderStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String newStatus = body.get("status");
        if (!StringUtils.hasText(newStatus)) {
            return Result.error("状态不能为空");
        }
        Set<String> validStatuses = Set.of("PENDING", "PROCESSED", "SHIPPED", "COMPLETED", "CANCELLED");
        if (!validStatuses.contains(newStatus)) {
            return Result.error("无效的状态值");
        }
        OrderInfo order = orderInfoMapper.selectById(id);
        if (order == null) {
            return Result.error("订单不存在");
        }
        order.setStatus(newStatus);
        order.setUpdateTime(LocalDateTime.now());
        orderInfoMapper.updateById(order);
        return Result.success(null);
    }
}
