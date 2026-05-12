package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.printquote.backend.entity.UserAddress;
import com.printquote.backend.mapper.UserAddressMapper;
import com.printquote.backend.utils.AuthContextUtils;
import com.printquote.backend.vo.Result;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/user/address")
public class UserAddressController {

    @Autowired
    private UserAddressMapper userAddressMapper;

    @GetMapping("")
    public Result<List<UserAddress>> list(HttpServletRequest request) {
        Long userId = AuthContextUtils.resolveUserId(request);
        return Result.success(userAddressMapper.selectList(
                new LambdaQueryWrapper<UserAddress>()
                        .eq(UserAddress::getUserId, userId)
                        .orderByDesc(UserAddress::getIsDefault)
                        .orderByDesc(UserAddress::getUpdateTime)
        ));
    }

    @PostMapping("")
    public Result<UserAddress> create(@RequestBody UserAddress address, HttpServletRequest request) {
        Long userId = AuthContextUtils.resolveUserId(request);
        address.setId(null);
        address.setUserId(userId);
        address.setCreateTime(LocalDateTime.now());
        address.setUpdateTime(LocalDateTime.now());

        boolean hasDefault = userAddressMapper.selectCount(
                new LambdaQueryWrapper<UserAddress>()
                        .eq(UserAddress::getUserId, userId)
                        .eq(UserAddress::getIsDefault, true)
        ) > 0;

        if (Boolean.TRUE.equals(address.getIsDefault()) || !hasDefault) {
            clearDefault(userId);
            address.setIsDefault(true);
        } else {
            address.setIsDefault(false);
        }

        userAddressMapper.insert(address);
        return Result.success(address);
    }

    @PutMapping("/{id}")
    public Result<UserAddress> update(@PathVariable Long id, @RequestBody UserAddress payload, HttpServletRequest request) {
        Long userId = AuthContextUtils.resolveUserId(request);
        UserAddress exist = getOwnedAddress(id, userId);
        if (exist == null) {
            return Result.error("地址不存在");
        }

        exist.setReceiverName(payload.getReceiverName());
        exist.setPhone(payload.getPhone());
        exist.setProvince(payload.getProvince());
        exist.setCity(payload.getCity());
        exist.setDistrict(payload.getDistrict());
        exist.setDetailAddress(payload.getDetailAddress());
        exist.setUpdateTime(LocalDateTime.now());

        if (Boolean.TRUE.equals(payload.getIsDefault())) {
            clearDefault(userId);
            exist.setIsDefault(true);
        }

        userAddressMapper.updateById(exist);
        return Result.success(exist);
    }

    @PutMapping("/{id}/default")
    public Result<Void> setDefault(@PathVariable Long id, HttpServletRequest request) {
        Long userId = AuthContextUtils.resolveUserId(request);
        UserAddress exist = getOwnedAddress(id, userId);
        if (exist == null) {
            return Result.error("地址不存在");
        }
        clearDefault(userId);
        exist.setIsDefault(true);
        exist.setUpdateTime(LocalDateTime.now());
        userAddressMapper.updateById(exist);
        return Result.success(null);
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id, HttpServletRequest request) {
        Long userId = AuthContextUtils.resolveUserId(request);
        UserAddress exist = getOwnedAddress(id, userId);
        if (exist == null) {
            return Result.error("地址不存在");
        }
        userAddressMapper.deleteById(id);

        if (Boolean.TRUE.equals(exist.getIsDefault())) {
            UserAddress nextDefault = userAddressMapper.selectOne(
                    new LambdaQueryWrapper<UserAddress>()
                            .eq(UserAddress::getUserId, userId)
                            .orderByDesc(UserAddress::getUpdateTime)
                            .last("LIMIT 1")
            );
            if (nextDefault != null) {
                nextDefault.setIsDefault(true);
                nextDefault.setUpdateTime(LocalDateTime.now());
                userAddressMapper.updateById(nextDefault);
            }
        }

        return Result.success(null);
    }

    private void clearDefault(Long userId) {
        userAddressMapper.update(
                null,
                new LambdaUpdateWrapper<UserAddress>()
                        .eq(UserAddress::getUserId, userId)
                        .set(UserAddress::getIsDefault, false)
                        .set(UserAddress::getUpdateTime, LocalDateTime.now())
        );
    }

    private UserAddress getOwnedAddress(Long id, Long userId) {
        return userAddressMapper.selectOne(
                new LambdaQueryWrapper<UserAddress>()
                        .eq(UserAddress::getId, id)
                        .eq(UserAddress::getUserId, userId)
        );
    }
}
