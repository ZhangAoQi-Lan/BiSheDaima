package com.printquote.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.printquote.backend.entity.HelpArticle;
import com.printquote.backend.entity.HelpCategory;
import com.printquote.backend.entity.HelpFeedback;
import com.printquote.backend.mapper.HelpArticleMapper;
import com.printquote.backend.mapper.HelpCategoryMapper;
import com.printquote.backend.mapper.HelpFeedbackMapper;
import com.printquote.backend.service.HelpService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
public class HelpServiceImpl extends ServiceImpl<HelpArticleMapper, HelpArticle> implements HelpService {

    @Autowired
    private HelpCategoryMapper helpCategoryMapper;

    @Autowired
    private HelpFeedbackMapper helpFeedbackMapper;

    @Override
    public List<Map<String, Object>> getCategoriesWithArticles() {
        List<HelpCategory> categories = helpCategoryMapper.selectList(
            new LambdaQueryWrapper<HelpCategory>().orderByAsc(HelpCategory::getSortOrder)
        );

        List<HelpArticle> allArticles = this.list(
            new LambdaQueryWrapper<HelpArticle>().orderByAsc(HelpArticle::getId)
        );

        Map<Long, List<HelpArticle>> articleMap = allArticles.stream()
            .collect(Collectors.groupingBy(HelpArticle::getCategoryId));

        List<Map<String, Object>> result = new ArrayList<>();
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        for (HelpCategory cat : categories) {
            Map<String, Object> catMap = new LinkedHashMap<>();
            catMap.put("id", cat.getId());
            catMap.put("name", cat.getName());
            catMap.put("description", cat.getDescription());
            catMap.put("icon", cat.getIcon());
            catMap.put("gradient", cat.getGradient());

            List<HelpArticle> catArticles = articleMap.getOrDefault(cat.getId(), Collections.emptyList());
            catMap.put("articleCount", catArticles.size());

            List<Map<String, Object>> articleList = new ArrayList<>();
            for (HelpArticle art : catArticles) {
                Map<String, Object> artMap = new LinkedHashMap<>();
                artMap.put("id", art.getId());
                artMap.put("title", art.getTitle());
                artMap.put("date", art.getUpdateTime() != null ? art.getUpdateTime().format(dtf) : "");
                artMap.put("views", art.getViews());
                artMap.put("readTime", art.getReadTime());
                artMap.put("tags", art.getTags());
                artMap.put("categoryId", art.getCategoryId());
                artMap.put("helpfulCount", art.getHelpfulCount());
                articleList.add(artMap);
            }
            catMap.put("articles", articleList);
            result.add(catMap);
        }
        return result;
    }

    @Override
    public Map<String, Object> getArticleDetail(Long articleId) {
        HelpArticle art = this.getById(articleId);
        if (art == null) return null;

        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        Map<String, Object> detail = new LinkedHashMap<>();
        detail.put("id", art.getId());
        detail.put("categoryId", art.getCategoryId());
        detail.put("title", art.getTitle());
        detail.put("content", art.getContent());
        detail.put("tags", art.getTags());
        detail.put("views", art.getViews());
        detail.put("readTime", art.getReadTime());
        detail.put("helpfulCount", art.getHelpfulCount());
        detail.put("date", art.getUpdateTime() != null ? art.getUpdateTime().format(dtf) : "");
        return detail;
    }

    @Override
    public List<Map<String, Object>> searchArticles(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return Collections.emptyList();
        }

        String trimmed = keyword.trim();
        LambdaQueryWrapper<HelpArticle> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(HelpArticle::getTitle, trimmed)
               .or()
               .like(HelpArticle::getContent, trimmed)
               .orderByDesc(HelpArticle::getViews)
               .last("LIMIT 8");

        List<HelpArticle> articles = this.list(wrapper);

        // Load all categories for name lookup
        List<HelpCategory> categories = helpCategoryMapper.selectList(null);
        Map<Long, String> catNameMap = categories.stream()
            .collect(Collectors.toMap(HelpCategory::getId, HelpCategory::getName));

        List<Map<String, Object>> result = new ArrayList<>();
        for (HelpArticle art : articles) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", art.getId());
            item.put("title", highlightText(art.getTitle(), trimmed));
            item.put("catTitle", catNameMap.getOrDefault(art.getCategoryId(), ""));
            item.put("originalTitle", art.getTitle());
            result.add(item);
        }
        return result;
    }

    @Override
    public Integer submitFeedback(Long articleId, Long userId, String feedbackType) {
        // 检查是否已反馈（一人一票）
        LambdaQueryWrapper<HelpFeedback> checkWrapper = new LambdaQueryWrapper<>();
        checkWrapper.eq(HelpFeedback::getArticleId, articleId)
                    .eq(HelpFeedback::getUserId, userId);
        if (helpFeedbackMapper.selectCount(checkWrapper) > 0) {
            return null; // 已反馈过
        }

        // 插入反馈记录
        HelpFeedback feedback = new HelpFeedback();
        feedback.setArticleId(articleId);
        feedback.setUserId(userId);
        feedback.setFeedbackType(feedbackType);
        helpFeedbackMapper.insert(feedback);

        // 如果是有帮助，原子性增加计数
        if ("up".equals(feedbackType)) {
            LambdaUpdateWrapper<HelpArticle> updateWrapper = new LambdaUpdateWrapper<>();
            updateWrapper.eq(HelpArticle::getId, articleId)
                         .setSql("helpful_count = helpful_count + 1");
            this.update(updateWrapper);
        }

        // 返回最新数值
        HelpArticle article = this.getById(articleId);
        return article != null ? article.getHelpfulCount() : 0;
    }

    private String highlightText(String text, String keyword) {
        String escaped = Pattern.quote(keyword);
        return text.replaceAll("(?i)(" + escaped + ")", "<mark class=\"search-hl\">$1</mark>");
    }
}
