package com.printquote.backend.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.printquote.backend.entity.HelpArticle;

import java.util.List;
import java.util.Map;

public interface HelpService extends IService<HelpArticle> {

    List<Map<String, Object>> getCategoriesWithArticles();

    Map<String, Object> getArticleDetail(Long articleId);

    List<Map<String, Object>> searchArticles(String keyword);

    Integer submitFeedback(Long articleId, Long userId, String feedbackType);
}
