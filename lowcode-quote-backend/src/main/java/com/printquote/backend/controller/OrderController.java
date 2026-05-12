package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.printquote.backend.entity.AfterSale;
import com.printquote.backend.entity.CartItem;
import com.printquote.backend.entity.OrderInfo;
import com.printquote.backend.entity.OrderItem;
import com.printquote.backend.entity.OrderTimeline;
import com.printquote.backend.entity.UserAddress;
import com.printquote.backend.mapper.AfterSaleMapper;
import com.printquote.backend.mapper.CartItemMapper;
import com.printquote.backend.mapper.OrderInfoMapper;
import com.printquote.backend.mapper.OrderItemMapper;
import com.printquote.backend.mapper.OrderTimelineMapper;
import com.printquote.backend.mapper.UserAddressMapper;
import com.printquote.backend.utils.AuthContextUtils;
import com.printquote.backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.time.LocalDateTime;
import java.util.HashMap;
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

    @Autowired
    private UserAddressMapper userAddressMapper;

    @Autowired
    private AfterSaleMapper afterSaleMapper;

    @Autowired
    private OrderTimelineMapper orderTimelineMapper;

    @PostMapping("")
    public Result<OrderInfo> createOrder(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Session-Id", required = false) String sessionId,
            @RequestBody(required = false) Map<String, Object> body
    ) {
        Long userId = AuthContextUtils.resolveUserId(authHeader);

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
            return Result.error("暂存箱为空，请先加入报价商品");
        }

        BigDecimal totalPrice = cartItems.stream()
                .map(CartItem::getPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        OrderInfo order = new OrderInfo();
        order.setUserId(userId);
        order.setSessionId(sessionId);
        order.setTotalPrice(totalPrice);
        order.setStatus("PENDING");

        if (userId != null) {
            if (body == null || body.get("addressId") == null) {
                return Result.error("请选择收货地址");
            }
            Long addressId = Long.valueOf(body.get("addressId").toString());
            UserAddress address = userAddressMapper.selectOne(
                    new LambdaQueryWrapper<UserAddress>()
                            .eq(UserAddress::getId, addressId)
                            .eq(UserAddress::getUserId, userId)
            );
            if (address == null) {
                return Result.error("收货地址不存在");
            }
            order.setReceiverName(address.getReceiverName());
            order.setReceiverPhone(address.getPhone());
            order.setReceiverAddress(joinAddress(address));
            order.setOrderRemark(body.get("remark") == null ? "" : body.get("remark").toString());
        } else if (body != null && body.get("remark") != null) {
            order.setOrderRemark(body.get("remark").toString());
        }
        if (body != null) {
            order.setArtworkName(textValue(body, "artworkName"));
            order.setArtworkUrl(textValue(body, "artworkUrl"));
        }

        order.setCreateTime(LocalDateTime.now());
        order.setUpdateTime(LocalDateTime.now());
        orderInfoMapper.insert(order);
        addTimeline(order.getId(), "PENDING", "订单已提交", "用户提交订单，等待后台确认生产信息", "USER");

        for (CartItem cartItem : cartItems) {
            OrderItem item = new OrderItem();
            item.setOrderId(order.getId());
            item.setProductName(cartItem.getProductName());
            item.setFormData(cartItem.getFormData());
            item.setPrice(cartItem.getPrice());
            item.setCreateTime(LocalDateTime.now());
            orderItemMapper.insert(item);
        }

        cartItemMapper.delete(query);
        return Result.success(order);
    }

    @GetMapping("")
    public Result<List<Map<String, Object>>> listOrders(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Session-Id", required = false) String sessionId
    ) {
        Long userId = AuthContextUtils.resolveUserId(authHeader);
        LambdaQueryWrapper<OrderInfo> query = new LambdaQueryWrapper<OrderInfo>()
                .orderByDesc(OrderInfo::getCreateTime);
        if (userId != null) {
            query.eq(OrderInfo::getUserId, userId);
        } else {
            query.eq(OrderInfo::getSessionId, sessionId != null ? sessionId : "");
        }
        List<OrderInfo> orderList = orderInfoMapper.selectList(query);
        List<Map<String, Object>> result = new ArrayList<>();
        for (OrderInfo order : orderList) {
            List<OrderItem> items = orderItemMapper.selectList(
                    new LambdaQueryWrapper<OrderItem>()
                            .eq(OrderItem::getOrderId, order.getId())
                            .orderByAsc(OrderItem::getCreateTime)
            );
            Map<String, Object> item = new HashMap<>();
            item.put("order", order);
            item.put("items", items);
            item.put("itemCount", items.size());
            result.add(item);
        }
        return Result.success(result);
    }

    @GetMapping("/{id}")
    public Result<Map<String, Object>> getOrderDetail(
            @PathVariable Long id,
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Session-Id", required = false) String sessionId
    ) {
        Long userId = AuthContextUtils.resolveUserId(authHeader);
        OrderInfo order = orderInfoMapper.selectById(id);
        if (order == null) {
            return Result.error("订单不存在");
        }

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

        List<AfterSale> afterSales = afterSaleMapper.selectList(
                new LambdaQueryWrapper<AfterSale>()
                        .eq(AfterSale::getOrderId, id)
                        .orderByDesc(AfterSale::getCreateTime)
        );
        List<OrderTimeline> timeline = orderTimelineMapper.selectList(
                new LambdaQueryWrapper<OrderTimeline>()
                        .eq(OrderTimeline::getOrderId, id)
                        .orderByAsc(OrderTimeline::getCreateTime)
        );

        Map<String, Object> result = new HashMap<>();
        result.put("order", order);
        result.put("items", items);
        result.put("afterSales", afterSales);
        result.put("timeline", timeline);
        return Result.success(result);
    }

    @PutMapping("/{id}/cancel")
    public Result<OrderInfo> cancelOrder(
            @PathVariable Long id,
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Session-Id", required = false) String sessionId
    ) {
        Long userId = AuthContextUtils.resolveUserId(authHeader);
        OrderInfo order = orderInfoMapper.selectById(id);
        if (order == null) {
            return Result.error("订单不存在");
        }

        boolean isOwner;
        if (userId != null) {
            isOwner = userId.equals(order.getUserId());
        } else {
            String sid = sessionId != null ? sessionId : "";
            isOwner = sid.equals(order.getSessionId());
        }
        if (!isOwner) {
            return Result.error("无权操作该订单");
        }
        if (!"PENDING".equals(order.getStatus())) {
            return Result.error("当前订单状态不可取消");
        }

        order.setStatus("CANCELLED");
        order.setUpdateTime(LocalDateTime.now());
        orderInfoMapper.updateById(order);
        addTimeline(order.getId(), "CANCELLED", "订单已取消", "用户取消订单，订单流程结束", "USER");
        return Result.success(order);
    }

    private void addTimeline(Long orderId, String status, String title, String description, String operatorType) {
        OrderTimeline timeline = new OrderTimeline();
        timeline.setOrderId(orderId);
        timeline.setStatus(status);
        timeline.setTitle(title);
        timeline.setDescription(description);
        timeline.setOperatorType(operatorType);
        timeline.setCreateTime(LocalDateTime.now());
        orderTimelineMapper.insert(timeline);
    }

    private String textValue(Map<String, Object> body, String key) {
        Object value = body.get(key);
        if (value == null) {
            return null;
        }
        String text = value.toString().trim();
        return text.isEmpty() ? null : text;
    }

    private String joinAddress(UserAddress address) {
        StringBuilder builder = new StringBuilder();
        append(builder, address.getProvince());
        append(builder, address.getCity());
        append(builder, address.getDistrict());
        append(builder, address.getDetailAddress());
        return builder.toString().trim();
    }

    private void append(StringBuilder builder, String value) {
        if (value == null || value.isBlank()) {
            return;
        }
        if (!builder.isEmpty()) {
            builder.append(' ');
        }
        builder.append(value);
    }
}
