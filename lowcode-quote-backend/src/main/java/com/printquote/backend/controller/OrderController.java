package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.printquote.backend.entity.CartItem;
import com.printquote.backend.entity.OrderInfo;
import com.printquote.backend.entity.OrderItem;
import com.printquote.backend.mapper.CartItemMapper;
import com.printquote.backend.mapper.OrderInfoMapper;
import com.printquote.backend.mapper.OrderItemMapper;
import com.printquote.backend.utils.JwtUtils;
import com.printquote.backend.vo.Result;
import io.jsonwebtoken.Claims;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/mall/order")
public class OrderController {

    @Autowired
    private OrderInfoMapper orderInfoMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private CartItemMapper cartItemMapper;

    private Long resolveUserId(String authHeader) {
        if (!StringUtils.hasText(authHeader) || !authHeader.startsWith("Bearer ")) return null;
        try {
            Claims claims = JwtUtils.parseToken(authHeader.substring(7));
            Object uid = claims.get("userId");
            return uid != null ? Long.valueOf(uid.toString()) : null;
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * 提交订单：将暂存箱中所有商品转为正式订单
     */
    @PostMapping("")
    public Result<OrderInfo> createOrder(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Session-Id", required = false) String sessionId
    ) {
        Long userId = resolveUserId(authHeader);

        // 查询当前用户的暂存箱中所有有效商品
        LambdaQueryWrapper<CartItem> query = new LambdaQueryWrapper<CartItem>()
                .gt(CartItem::getExpiresAt, LocalDateTime.now())
                .orderByDesc(CartItem::getCreateTime);
        if (userId != null) {
            query.eq(CartItem::getUserId, userId);
        } else {
            query.eq(CartItem::getSessionId, sessionId != null ? sessionId : "");
        }
        List<CartItem> cartItems = cartItemMapper.selectList(query);

        if (cartItems.isEmpty()) {
            return Result.error("暂存箱为空，请先配置报价并加入暂存箱");
        }

        // 计算总价
        BigDecimal totalPrice = cartItems.stream()
                .map(CartItem::getPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // 创建订单
        OrderInfo order = new OrderInfo();
        order.setUserId(userId);
        order.setSessionId(sessionId);
        order.setTotalPrice(totalPrice);
        order.setStatus("PENDING");
        order.setCreateTime(LocalDateTime.now());
        order.setUpdateTime(LocalDateTime.now());
        orderInfoMapper.insert(order);

        // 创建订单明细
        for (CartItem cartItem : cartItems) {
            OrderItem item = new OrderItem();
            item.setOrderId(order.getId());
            item.setProductName(cartItem.getProductName());
            item.setFormData(cartItem.getFormData());
            item.setPrice(cartItem.getPrice());
            item.setCreateTime(LocalDateTime.now());
            orderItemMapper.insert(item);
        }

        // 清空暂存箱
        cartItemMapper.delete(query);

        return Result.success(order);
    }

    /**
     * 获取当前用户的订单列表（包含明细）
     */
    @GetMapping("")
    public Result<List<OrderInfo>> listOrders(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Session-Id", required = false) String sessionId
    ) {
        Long userId = resolveUserId(authHeader);

        LambdaQueryWrapper<OrderInfo> query = new LambdaQueryWrapper<OrderInfo>()
                .orderByDesc(OrderInfo::getCreateTime);
        if (userId != null) {
            query.eq(OrderInfo::getUserId, userId);
        } else {
            query.eq(OrderInfo::getSessionId, sessionId != null ? sessionId : "");
        }
        return Result.success(orderInfoMapper.selectList(query));
    }

    /**
     * 获取单个订单详情（含明细列表）
     */
    @GetMapping("/{id}")
    public Result<Map<String, Object>> getOrderDetail(
            @PathVariable Long id,
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Session-Id", required = false) String sessionId
    ) {
        Long userId = resolveUserId(authHeader);

        OrderInfo order = orderInfoMapper.selectById(id);
        if (order == null) {
            return Result.error("订单不存在");
        }

        // 防止越权访问
        boolean isOwner;
        if (userId != null) {
            isOwner = userId.equals(order.getUserId());
        } else {
            String sid = sessionId != null ? sessionId : "";
            isOwner = sid.equals(order.getSessionId());
        }
        if (!isOwner) {
            return Result.error("无权查看该订单");
        }

        List<OrderItem> items = orderItemMapper.selectList(
                new LambdaQueryWrapper<OrderItem>()
                        .eq(OrderItem::getOrderId, id)
                        .orderByAsc(OrderItem::getCreateTime)
        );

        Map<String, Object> result = new java.util.HashMap<>();
        result.put("order", order);
        result.put("items", items);
        return Result.success(result);
    }
}
