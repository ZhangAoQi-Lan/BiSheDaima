package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.printquote.backend.entity.MaterialComponent;
import com.printquote.backend.mapper.MaterialComponentMapper;
import com.printquote.backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;

@RestController
@RequestMapping("/api/admin/material")
public class AdminMaterialController {

    @Autowired
    private MaterialComponentMapper materialComponentMapper;

    /**
     * 获取物料组件列表
     */
    @GetMapping("/list")
    public Result<List<MaterialComponent>> getMaterialList() {
        QueryWrapper<MaterialComponent> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("status", 1);
        List<MaterialComponent> list = materialComponentMapper.selectList(queryWrapper);
        return Result.success(list);
    }

    /**
     * 新增/修改物料组件
     */
    @PostMapping
    public Result<MaterialComponent> saveMaterial(@RequestBody MaterialComponent component) {
        if (component.getId() == null) {
            component.setCreateTime(new Date());
            component.setUpdateTime(new Date());
            component.setStatus(1); // 默认正常
            materialComponentMapper.insert(component);
        } else {
            component.setUpdateTime(new Date());
            materialComponentMapper.updateById(component);
        }
        return Result.success(component);
    }

    /**
     * 删除弃用物料
     */
    @DeleteMapping("/{id}")
    public Result<String> deleteMaterial(@PathVariable("id") Long id) {
        MaterialComponent component = materialComponentMapper.selectById(id);
        if (component != null) {
            component.setStatus(0); // 逻辑删除
            materialComponentMapper.updateById(component);
        }
        return Result.success("删除成功");
    }
}
