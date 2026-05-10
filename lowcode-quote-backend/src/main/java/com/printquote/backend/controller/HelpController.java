package com.printquote.backend.controller;

import com.printquote.backend.service.HelpService;
import com.printquote.backend.vo.Result;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/help")
public class HelpController {

    @Autowired
    private HelpService helpService;

    @GetMapping("/categories")
    public Result<Map<String, Object>> getCategories() {
        List<Map<String, Object>> categories = helpService.getCategoriesWithArticles();

        int totalArticles = categories.stream()
            .mapToInt(c -> (int) c.get("articleCount"))
            .sum();

        Map<String, Object> result = new HashMap<>();
        result.put("categories", categories);
        result.put("totalArticles", totalArticles);
        return Result.success(result);
    }

    @GetMapping("/articles/{id}")
    public Result<Map<String, Object>> getArticle(@PathVariable Long id) {
        Map<String, Object> detail = helpService.getArticleDetail(id);
        if (detail == null) {
            return Result.error("文章不存在");
        }
        return Result.success(detail);
    }

    @GetMapping("/search")
    public Result<List<Map<String, Object>>> search(@RequestParam String keyword) {
        List<Map<String, Object>> results = helpService.searchArticles(keyword);
        return Result.success(results);
    }

    @PostMapping("/feedback")
    public Result<Map<String, Object>> feedback(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        Object articleIdObj = body.get("articleId");
        Object feedbackTypeObj = body.get("feedbackType");

        if (articleIdObj == null || feedbackTypeObj == null) {
            return Result.error("参数不完整");
        }

        Long articleId = Long.valueOf(articleIdObj.toString());
        String feedbackType = feedbackTypeObj.toString();

        Long userId = (Long) request.getAttribute("userId");
        if (userId == null) {
            return Result.error("请先登录");
        }

        Integer newCount = helpService.submitFeedback(articleId, userId, feedbackType);
        if (newCount == null) {
            return Result.error("您已经反馈过该文章");
        }

        Map<String, Object> result = new HashMap<>();
        result.put("helpfulCount", newCount);
        return Result.success(result);
    }
}
