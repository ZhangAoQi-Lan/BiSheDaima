package com.printquote.backend.controller;

import com.printquote.backend.entity.User;
import com.printquote.backend.service.UserService;
import com.printquote.backend.vo.Result;
import jakarta.servlet.http.HttpServletRequest;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    private UserService userService;

    /**
     * 获取当前登录用户完整资料
     */
    @GetMapping("/current")
    public Result<User> getCurrentUser(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        User user = userService.getById(userId);
        if (user == null) {
            return Result.error("用户不存在");
        }
        user.setPassword(null);
        return Result.success(user);
    }

    /**
     * 修改用户资料（昵称、邮箱、头像）
     */
    @PutMapping("/profile")
    public Result<User> updateProfile(@RequestBody Map<String, String> params, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        User user = userService.getById(userId);
        if (user == null) {
            return Result.error("用户不存在");
        }

        if (params.containsKey("nickname")) {
            user.setNickname(params.get("nickname"));
        }
        if (params.containsKey("email")) {
            String email = params.get("email");
            User existEmail = userService.findByEmail(email);
            if (existEmail != null && !existEmail.getId().equals(userId)) {
                return Result.error("邮箱已被其他用户使用");
            }
            user.setEmail(email);
        }
        if (params.containsKey("avatar")) {
            user.setAvatar(params.get("avatar"));
        }

        userService.updateById(user);
        user.setPassword(null);
        return Result.success(user);
    }

    /**
     * 修改密码
     */
    @PutMapping("/password")
    public Result<String> updatePassword(@RequestBody Map<String, String> params, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        String oldPassword = params.get("oldPassword");
        String newPassword = params.get("newPassword");

        if (oldPassword == null || oldPassword.isEmpty()) {
            return Result.error("旧密码不能为空");
        }
        if (newPassword == null || newPassword.length() < 6) {
            return Result.error("新密码至少6位");
        }

        User user = userService.getById(userId);
        if (user == null) {
            return Result.error("用户不存在");
        }

        if (!BCrypt.checkpw(oldPassword, user.getPassword())) {
            return Result.error("旧密码不正确");
        }

        user.setPassword(BCrypt.hashpw(newPassword, BCrypt.gensalt()));
        userService.updateById(user);

        return Result.success("密码修改成功");
    }
}
