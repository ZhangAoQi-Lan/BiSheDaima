package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.printquote.backend.entity.QuoteHistory;
import com.printquote.backend.mapper.QuoteHistoryMapper;
import com.printquote.backend.utils.AuthContextUtils;
import com.printquote.backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/mall/quote-history")
public class QuoteHistoryController {

    @Autowired
    private QuoteHistoryMapper quoteHistoryMapper;

    @GetMapping("")
    public Result<List<QuoteHistory>> list(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Session-Id", required = false) String sessionId
    ) {
        Long userId = AuthContextUtils.resolveUserId(authHeader);
        LambdaQueryWrapper<QuoteHistory> query = new LambdaQueryWrapper<QuoteHistory>()
                .orderByDesc(QuoteHistory::getCreateTime);
        if (userId != null) {
            query.eq(QuoteHistory::getUserId, userId);
        } else {
            query.eq(QuoteHistory::getSessionId, StringUtils.hasText(sessionId) ? sessionId : "");
        }
        return Result.success(quoteHistoryMapper.selectList(query));
    }

    @PostMapping("")
    public Result<QuoteHistory> create(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Session-Id", required = false) String sessionId,
            @RequestBody Map<String, Object> body
    ) {
        QuoteHistory history = new QuoteHistory();
        history.setUserId(AuthContextUtils.resolveUserId(authHeader));
        history.setSessionId(sessionId);
        history.setCategoryId(Long.valueOf(body.get("categoryId").toString()));
        history.setProductName(String.valueOf(body.get("productName")));
        history.setPrice(new BigDecimal(body.get("price").toString()));
        history.setCreateTime(LocalDateTime.now());
        @SuppressWarnings("unchecked")
        Map<String, Object> formData = (Map<String, Object>) body.get("formData");
        @SuppressWarnings("unchecked")
        Map<String, Object> rawFormData = (Map<String, Object>) body.get("rawFormData");
        history.setFormData(formData);
        history.setRawFormData(rawFormData);
        quoteHistoryMapper.insert(history);
        return Result.success(history);
    }
}
