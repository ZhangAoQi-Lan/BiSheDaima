package com.printquote.backend.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.printquote.backend.entity.User;

public interface UserService extends IService<User> {
    User findByUsername(String username);
    User findByEmail(String email);
    User findByUsernameOrEmail(String account);
}
