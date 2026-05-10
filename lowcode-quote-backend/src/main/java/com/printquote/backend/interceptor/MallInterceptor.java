package com.printquote.backend.interceptor;

import com.printquote.backend.utils.JwtUtils;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class MallInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 放行 OPTIONS 请求
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
            try {
                // 只要能够成功解析 Token，即说明已经登录（普通用户或者管理员均可）
                Claims claims = JwtUtils.parseToken(token);
                request.setAttribute("userId", ((Number) claims.get("userId")).longValue());
                request.setAttribute("username", claims.get("username"));
                request.setAttribute("role", claims.get("role"));
                return true;
            } catch (Exception e) {
                // Token 无效或过期
            }
        }

        response.setStatus(401);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"code\":401,\"message\":\"未登录，请先登录\"}");
        return false;
    }
}
