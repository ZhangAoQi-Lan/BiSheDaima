package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.printquote.backend.entity.SiteConfig;
import com.printquote.backend.mapper.SiteConfigMapper;
import com.printquote.backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/mall/site")
public class MallSiteController {

    @Autowired
    private SiteConfigMapper siteConfigMapper;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @GetMapping("/content")
    public Result<Map<String, Object>> content() {
        List<SiteConfig> configs = siteConfigMapper.selectList(new LambdaQueryWrapper<SiteConfig>().orderByAsc(SiteConfig::getId));
        Map<String, String> source = new HashMap<>();
        for (SiteConfig config : configs) {
            source.put(config.getConfigKey(), config.getConfigValue());
        }

        Map<String, Object> result = new HashMap<>();
        result.put("shopName", source.getOrDefault("shopName", "印刷包装在线报价平台"));
        result.put("shopIntro", source.getOrDefault("shopIntro", "专注印刷行业低代码报价与在线下单服务。"));
        result.put("contactPhone", source.getOrDefault("contactPhone", "400-800-2026"));
        result.put("contactWechat", source.getOrDefault("contactWechat", "print-quote"));
        result.put("serviceHours", source.getOrDefault("serviceHours", "周一至周日 09:00-18:00"));
        result.put("shopAddress", source.getOrDefault("shopAddress", "上海市印刷产业园 A1 栋"));
        result.put("announcements", parseAnnouncements(source.get("announcements")));
        return Result.success(result);
    }

    private List<String> parseAnnouncements(String value) {
        if (value == null || value.isBlank()) {
            return List.of("欢迎使用印刷行业低代码报价平台", "支持在线报价、购物车下单与订单跟踪");
        }
        try {
            return objectMapper.readValue(value, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            return List.of(value);
        }
    }
}
