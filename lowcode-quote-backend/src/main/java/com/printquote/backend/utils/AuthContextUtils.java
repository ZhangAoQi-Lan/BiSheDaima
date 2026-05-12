package com.printquote.backend.utils;

import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.util.StringUtils;

public final class AuthContextUtils {

    private AuthContextUtils() {
    }

    public static Long resolveUserId(String authHeader) {
        if (!StringUtils.hasText(authHeader) || !authHeader.startsWith("Bearer ")) {
            return null;
        }
        try {
            Claims claims = JwtUtils.parseToken(authHeader.substring(7));
            Object uid = claims.get("userId");
            return uid != null ? Long.valueOf(uid.toString()) : null;
        } catch (Exception e) {
            return null;
        }
    }

    public static Long resolveUserId(HttpServletRequest request) {
        Object value = request.getAttribute("userId");
        if (value == null) {
            return null;
        }
        return Long.valueOf(value.toString());
    }
}
