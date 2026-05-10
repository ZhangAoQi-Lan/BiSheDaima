package com.printquote.backend.config;

import com.printquote.backend.interceptor.AdminInterceptor;
import com.printquote.backend.interceptor.MallInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Autowired
    private AdminInterceptor adminInterceptor;

    @Autowired
    private MallInterceptor mallInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // 后台管理端接口拦截
        registry.addInterceptor(adminInterceptor)
                .addPathPatterns("/api/admin/**")
                .excludePathPatterns("/api/auth/**");

        // 商城端接口拦截（普通用户/管理员均可访问）
        registry.addInterceptor(mallInterceptor)
                .addPathPatterns("/api/mall/**", "/api/user/**", "/api/help/feedback")
                .excludePathPatterns("/api/auth/**");
    }
}
