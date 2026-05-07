package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.printquote.backend.entity.CartItem;
import com.printquote.backend.mapper.CartItemMapper;
import com.printquote.backend.utils.JwtUtils;
import com.printquote.backend.vo.Result;
import io.jsonwebtoken.Claims;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.util.StringUtils;
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

    /**
     * 从请求头解析出用户ID（已登录）或 null（未登录）
     */
    private Long resolveUserId(String authHeader) {
        if (!StringUtils.hasText(authHeader) || !authHeader.startsWith("Bearer ")) return null;
        try {
            Claims claims = JwtUtils.parseToken(authHeader.substring(7));
            Object uid = claims.get("userId");
            return uid != null ? Long.valueOf(uid.toString()) : null;
        } catch (Exception e) {
            return null; // token 无效时当作未登录处理
        }
    }

    /**
     * 根据认证状态构建查询条件：
     * - 已登录：按 userId 查 
     * - 未登录：按 sessionId 查
     */
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

    // ===================== API ===================== //

    @GetMapping("")
    public Result<List<CartItem>> getCart(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Session-Id", required = false) String sessionId
    ) {
        cartItemMapper.deleteExpired();
        Long userId = resolveUserId(authHeader);
        return Result.success(cartItemMapper.selectList(buildQuery(userId, sessionId)));
    }

    @PostMapping("")
    public Result<CartItem> addToCart(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Session-Id", required = false) String sessionId,
            @RequestBody Map<String, Object> body
    ) {
        Long userId = resolveUserId(authHeader);

        CartItem item = new CartItem();
        item.setUserId(userId);
        item.setSessionId(sessionId);
        // 原本产品 ID 改为了分类叶子节点 ID
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
        Long userId = resolveUserId(authHeader);
        LambdaQueryWrapper<CartItem> q = new LambdaQueryWrapper<CartItem>().eq(CartItem::getId, id);
        if (userId != null) {
            q.eq(CartItem::getUserId, userId);     // 防止越权删除
        } else {
            q.eq(CartItem::getSessionId, sessionId);
        }
        cartItemMapper.delete(q);
        return Result.success(null);
    }

    @DeleteMapping("")
    public Result<Void> clearCart(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Session-Id", required = false) String sessionId
    ) {
        Long userId = resolveUserId(authHeader);
        cartItemMapper.delete(buildQuery(userId, sessionId));
        return Result.success(null);
    }

    @Scheduled(fixedDelay = 5 * 60 * 1000)
    public void cleanupExpired() {
        cartItemMapper.deleteExpired();
    }
}
