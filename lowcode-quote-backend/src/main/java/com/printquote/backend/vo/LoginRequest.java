package com.printquote.backend.vo;

import lombok.Data;

@Data
public class LoginRequest {
    private String username;
    private String password;
    
    // 图形验证码相关
    private String captchaId;
    private String captchaCode;
    
    // 注册独有相关
    private String phone;
    private String email;
    private String emailCode;
}
