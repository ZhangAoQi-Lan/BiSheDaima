package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.printquote.backend.entity.Category;
import com.printquote.backend.mapper.CategoryMapper;
import com.printquote.backend.vo.CategoryTreeVO;
import com.printquote.backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin/category")
public class AdminCategoryController {

    @Autowired
    private CategoryMapper categoryMapper;

    /**
     * 获取管理端分类树（包含所有层级）
     */
    @GetMapping("/tree")
    public Result<List<CategoryTreeVO>> getCategoryTree() {
        QueryWrapper<Category> query = new QueryWrapper<>();
        query.orderByAsc("sort_order");
        List<Category> allCategories = categoryMapper.selectList(query);
        List<CategoryTreeVO> tree = buildTree(allCategories);
        return Result.success(tree);
    }

    /**
     * 获取管理端全部分类（平铺列表）
     */
    @GetMapping("/list")
    public Result<List<Category>> getCategoryList() {
        QueryWrapper<Category> qw = new QueryWrapper<>();
        qw.orderByAsc("sort_order");
        return Result.success(categoryMapper.selectList(qw));
    }

    /**
     * 内部构建树结构的辅助方法
     */
    private List<CategoryTreeVO> buildTree(List<Category> allCategories) {
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
        vo.setChildren(new ArrayList<>());
        return vo;
    }

    /**
     * 新增分类节点
     */
    @PostMapping
    public Result<Category> addCategory(@RequestBody Category category) {
        categoryMapper.insert(category);
        return Result.success(category);
    }

    /**
     * 修改分类节点
     */
    @PutMapping
    public Result<Category> updateCategory(@RequestBody Category category) {
        if (category.getId() == null) {
            return Result.error("分类ID不能为空");
        }
        categoryMapper.updateById(category);
        return Result.success(category);
    }

    /**
     * 删除节点（如果有子节点，则视业务情况限制删除或级联删除，此处暂不演示完整约束）
     */
    @DeleteMapping("/{id}")
    public Result<String> deleteCategory(@PathVariable("id") Long id) {
        // 安全起见，如存在子节点应拦截
        QueryWrapper<Category> childQuery = new QueryWrapper<>();
        childQuery.eq("parent_id", id);
        if (categoryMapper.selectCount(childQuery) > 0) {
            return Result.error("存在子分类，无法直接删除！");
        }
        categoryMapper.deleteById(id);
        return Result.success("删除成功");
    }
}
