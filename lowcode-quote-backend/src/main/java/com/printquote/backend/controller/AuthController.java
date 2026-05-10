package com.printquote.backend.controller;

import com.printquote.backend.entity.User;
import com.printquote.backend.service.UserService;
import com.printquote.backend.service.MailService;
import com.printquote.backend.utils.JwtUtils;
import com.printquote.backend.vo.LoginRequest;
import com.printquote.backend.vo.Result;
import cn.hutool.captcha.CaptchaUtil;
import cn.hutool.captcha.LineCaptcha;
import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.RandomUtil;
import cn.hutool.core.util.StrUtil;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserService userService;

    @Autowired
    private MailService mailService;

    // 简易内存缓存用于存储验证码 (生产推荐 Redis)
    private static final Map<String, String> captchaCache = new ConcurrentHashMap<>();
    private static final Map<String, String> emailCodeCache = new ConcurrentHashMap<>();

    /**
     * 获取图形验证码
     */
    @GetMapping("/captcha")
    public Result<Map<String, String>> getCaptcha() {
        LineCaptcha lineCaptcha = CaptchaUtil.createLineCaptcha(116, 36, 4, 10);
        String code = lineCaptcha.getCode();
        String uuid = IdUtil.simpleUUID();
        
        captchaCache.put(uuid, code);
        // 简单模拟过期，这里不使用定时器清理，实际应用需要 Redis 设置 TTL
        
        Map<String, String> res = new HashMap<>();
        res.put("captchaId", uuid);
        res.put("imgBase64", lineCaptcha.getImageBase64Data());
        return Result.success(res);
    }

    /**
     * 发送邮箱验证码
     */
    @PostMapping("/sendEmailCode")
    public Result<String> sendEmailCode(@RequestBody Map<String, String> params) {
        String email = params.get("email");
        if (StrUtil.isBlank(email)) {
            return Result.error("邮箱不能为空");
        }
        String code = RandomUtil.randomNumbers(6);
        emailCodeCache.put(email, code);
        
        try {
            mailService.sendSimpleMail(email, "注册验证码", "您的注册验证码为：" + code + "，有效期5分钟。");
            return Result.success("发送成功");
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("发送失败，请检查邮件配置");
        }
    }

    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody LoginRequest loginRequest) {
        // 校验图形验证码
        if (StrUtil.isBlank(loginRequest.getCaptchaId()) || StrUtil.isBlank(loginRequest.getCaptchaCode())) {
            return Result.error("请输入验证码");
        }
        String cacheCode = captchaCache.get(loginRequest.getCaptchaId());
        if (!loginRequest.getCaptchaCode().equalsIgnoreCase(cacheCode)) {
            return Result.error("验证码不正确或已过期");
        }
        captchaCache.remove(loginRequest.getCaptchaId());

        User user = userService.findByUsernameOrEmail(loginRequest.getUsername());
        if (user == null || !BCrypt.checkpw(loginRequest.getPassword(), user.getPassword())) {
            return Result.error("账号或密码错误");
        }

        // 签发 JWT
        String token = JwtUtils.generateToken(user.getId(), user.getUsername(), user.getRole());

        Map<String, Object> response = new HashMap<>();
        response.put("token", token);
        response.put("username", user.getUsername());
        response.put("nickname", user.getNickname());
        response.put("avatar", user.getAvatar());
        response.put("role", user.getRole());

        return Result.success(response);
    }

    @PostMapping("/register")
    public Result<String> register(@RequestBody LoginRequest loginRequest) {
        // 验证邮箱验证码
        if (StrUtil.isBlank(loginRequest.getEmail()) || StrUtil.isBlank(loginRequest.getEmailCode())) {
            return Result.error("邮箱和验证码不能为空");
        }
        String cacheEmailCode = emailCodeCache.get(loginRequest.getEmail());
        if (!loginRequest.getEmailCode().equals(cacheEmailCode)) {
             return Result.error("邮箱验证码错误或已失效");
        }

        User existUser = userService.findByUsername(loginRequest.getUsername());
        if (existUser != null) {
            return Result.error("用户名已被注册");
        }

        User existEmail = userService.findByEmail(loginRequest.getEmail());
        if (existEmail != null) {
            return Result.error("邮箱已被注册");
        }

        User newUser = new User();
        newUser.setUsername(loginRequest.getUsername());
        // BCrypt 哈希加密
        newUser.setPassword(BCrypt.hashpw(loginRequest.getPassword(), BCrypt.gensalt()));
        newUser.setEmail(loginRequest.getEmail());
        newUser.setRole("USER"); // 默认注册的角色是普通用户
        userService.save(newUser);
        
        // 清理缓存
        emailCodeCache.remove(loginRequest.getEmail());

        return Result.success("注册成功");
    }
}
