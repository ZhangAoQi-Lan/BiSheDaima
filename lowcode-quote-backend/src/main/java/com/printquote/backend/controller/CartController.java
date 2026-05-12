package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.printquote.backend.entity.CartItem;
import com.printquote.backend.mapper.CartItemMapper;
import com.printquote.backend.utils.AuthContextUtils;
import com.printquote.backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/mall/cart")
public class CartController {

    @Autowired
    private CartItemMapper cartItemMapper;

    private LambdaQueryWrapper<CartItem> buildQuery(Long userId, String sessionId) {
        LambdaQueryWrapper<CartItem> query = new LambdaQueryWrapper<CartItem>()
                .gt(CartItem::getExpiresAt, LocalDateTime.now())
                .orderByDesc(CartItem::getCreateTime);
        if (userId != null) {
            query.eq(CartItem::getUserId, userId);
        } else {
            query.eq(CartItem::getSessionId, sessionId != null ? sessionId : "");
        }
        return query;
    }

    @GetMapping("")
    public Result<List<CartItem>> getCart(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Session-Id", required = false) String sessionId
    ) {
        cartItemMapper.deleteExpired();
        Long userId = AuthContextUtils.resolveUserId(authHeader);
        return Result.success(cartItemMapper.selectList(buildQuery(userId, sessionId)));
    }

    @PostMapping("")
    public Result<CartItem> addToCart(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Session-Id", required = false) String sessionId,
            @RequestBody Map<String, Object> body
    ) {
        Long userId = AuthContextUtils.resolveUserId(authHeader);

        CartItem item = new CartItem();
        item.setUserId(userId);
        item.setSessionId(sessionId);
        item.setCategoryId(Long.valueOf(body.get("categoryId").toString()));
        item.setProductName(body.get("productName").toString());
        @SuppressWarnings("unchecked")
        Map<String, Object> formData = (Map<String, Object>) body.get("formData");
        item.setFormData(formData);
        item.setPrice(new BigDecimal(body.get("price").toString()));
        item.setCreateTime(LocalDateTime.now());
        item.setExpiresAt(LocalDateTime.now().plusMinutes(10));

        cartItemMapper.insert(item);
        return Result.success(item);
    }

    @DeleteMapping("/{id}")
    public Result<Void> removeItem(
            @PathVariable Long id,
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Session-Id", required = false) String sessionId
    ) {
        Long userId = AuthContextUtils.resolveUserId(authHeader);
        LambdaQueryWrapper<CartItem> query = new LambdaQueryWrapper<CartItem>().eq(CartItem::getId, id);
        if (userId != null) {
            query.eq(CartItem::getUserId, userId);
        } else {
            query.eq(CartItem::getSessionId, sessionId);
        }
        cartItemMapper.delete(query);
        return Result.success(null);
    }

    @DeleteMapping("")
    public Result<Void> clearCart(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Session-Id", required = false) String sessionId
    ) {
        Long userId = AuthContextUtils.resolveUserId(authHeader);
        cartItemMapper.delete(buildQuery(userId, sessionId));
        return Result.success(null);
    }

    @Scheduled(fixedDelay = 5 * 60 * 1000)
    public void cleanupExpired() {
        cartItemMapper.deleteExpired();
    }
}
