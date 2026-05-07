package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.printquote.backend.entity.Category;
import com.printquote.backend.mapper.CategoryMapper;
import com.printquote.backend.vo.CategoryTreeVO;
import com.printquote.backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 分类接口（商城端 + 管理端共用）
 */
@RestController
public class CategoryController {

    @Autowired
    private CategoryMapper categoryMapper;

    /**
     * 商城端：获取分类树（一级分类 + 二级子分类），供侧边栏使用
     * GET /api/mall/category/tree
     */
    @GetMapping("/api/mall/category/tree")
    public Result<List<CategoryTreeVO>> getMallCategoryTree() {
        return Result.success(buildTree());
    }

    /**
     * 商城端：获取一级分类列表（兼容旧逻辑）
     * GET /api/mall/category/list
     */
    @GetMapping("/api/mall/category/list")
    public Result<List<Category>> getMallCategoryList() {
        QueryWrapper<Category> qw = new QueryWrapper<>();
        qw.isNull("parent_id").orderByAsc("sort_order");
        return Result.success(categoryMapper.selectList(qw));
    }



    // ---- 私有方法：构建树形结构 ----

    private List<CategoryTreeVO> buildTree() {
        // 一次查询全部分类（数量不多，无需分批）
        List<Category> allCategories = categoryMapper.selectList(
                new QueryWrapper<Category>().orderByAsc("sort_order")
        );

        // 先找出所有顶级节点 (parentId 为 null )
        List<CategoryTreeVO> rootNodes = allCategories.stream()
                .filter(c -> c.getParentId() == null)
                .map(this::convertToVO)
                .collect(Collectors.toList());

        // 递归设置子节点
        for (CategoryTreeVO root : rootNodes) {
            findAndSetChildren(root, allCategories);
        }
        return rootNodes;
    }

    private void findAndSetChildren(CategoryTreeVO parent, List<Category> allCategories) {
        List<CategoryTreeVO> children = allCategories.stream()
                .filter(c -> parent.getId().equals(c.getParentId()))
                .map(this::convertToVO)
                .collect(Collectors.toList());

        if (!children.isEmpty()) {
            parent.setChildren(children);
            for (CategoryTreeVO child : children) {
                findAndSetChildren(child, allCategories);
            }
        }
    }

    private CategoryTreeVO convertToVO(Category category) {
        CategoryTreeVO vo = new CategoryTreeVO();
        vo.setId(category.getId());
        vo.setName(category.getName());
        vo.setParentId(category.getParentId());
        vo.setIcon(category.getIcon());
        vo.setSortOrder(category.getSortOrder());
        vo.setChildren(new java.util.ArrayList<>());
        return vo;
    }
}
