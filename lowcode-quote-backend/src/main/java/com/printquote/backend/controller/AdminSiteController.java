package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.printquote.backend.entity.SiteConfig;
import com.printquote.backend.mapper.SiteConfigMapper;
import com.printquote.backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/site")
public class AdminSiteController {

    @Autowired
    private SiteConfigMapper siteConfigMapper;

    @GetMapping("/content")
    public Result<Map<String, String>> getContent() {
        List<SiteConfig> configs = siteConfigMapper.selectList(new LambdaQueryWrapper<SiteConfig>().orderByAsc(SiteConfig::getId));
        Map<String, String> result = new HashMap<>();
        for (SiteConfig config : configs) {
            result.put(config.getConfigKey(), config.getConfigValue());
        }
        return Result.success(result);
    }

    @PutMapping("/content")
    public Result<Void> saveContent(@RequestBody Map<String, String> payload) {
        for (Map.Entry<String, String> entry : payload.entrySet()) {
            SiteConfig config = siteConfigMapper.selectOne(
                    new LambdaQueryWrapper<SiteConfig>().eq(SiteConfig::getConfigKey, entry.getKey())
            );
            if (config == null) {
                config = new SiteConfig();
                config.setConfigKey(entry.getKey());
                config.setConfigValue(entry.getValue());
                config.setCreateTime(LocalDateTime.now());
                config.setUpdateTime(LocalDateTime.now());
                siteConfigMapper.insert(config);
            } else {
                config.setConfigValue(entry.getValue());
                config.setUpdateTime(LocalDateTime.now());
                siteConfigMapper.updateById(config);
            }
        }
        return Result.success(null);
    }
}
