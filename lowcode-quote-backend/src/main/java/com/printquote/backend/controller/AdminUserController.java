package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.printquote.backend.entity.User;
import com.printquote.backend.mapper.UserMapper;
import com.printquote.backend.vo.Result;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@RestController
@RequestMapping("/api/admin/user")
public class AdminUserController {

    @Autowired
    private UserMapper userMapper;

    @GetMapping("/list")
    public Result<List<User>> listUsers(@RequestParam(required = false) String keyword) {
        LambdaQueryWrapper<User> query = new LambdaQueryWrapper<User>()
                .orderByDesc(User::getCreateTime);
        if (StringUtils.hasText(keyword)) {
            query.and(w -> w
                    .like(User::getUsername, keyword)
                    .or()
                    .like(User::getEmail, keyword)
            );
        }
        // 脱敏：不返回密码
        List<User> users = userMapper.selectList(query);
        users.forEach(u -> u.setPassword(null));
        return Result.success(users);
    }

    @GetMapping("/{id}")
    public Result<Map<String, Object>> getUserDetail(@PathVariable Long id) {
        User user = userMapper.selectById(id);
        if (user == null) {
            return Result.error("用户不存在");
        }
        user.setPassword(null);
        Map<String, Object> result = new HashMap<>();
        result.put("user", user);
        return Result.success(result);
    }

    @PutMapping("/{id}/password")
    public Result<?> resetPassword(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String newPassword = body.get("password");
        if (!StringUtils.hasText(newPassword) || newPassword.length() < 6) {
            return Result.error("密码至少6位");
        }
        User user = userMapper.selectById(id);
        if (user == null) {
            return Result.error("用户不存在");
        }
        user.setPassword(BCrypt.hashpw(newPassword, BCrypt.gensalt()));
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);
        return Result.success(null);
    }

    @PutMapping("/{id}/role")
    public Result<?> updateRole(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String newRole = body.get("role");
        if (!StringUtils.hasText(newRole)) {
            return Result.error("角色不能为空");
        }
        if (!Set.of("USER", "ADMIN").contains(newRole)) {
            return Result.error("无效的角色值");
        }
        User user = userMapper.selectById(id);
        if (user == null) {
            return Result.error("用户不存在");
        }
        user.setRole(newRole);
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);
        return Result.success(null);
    }
}
