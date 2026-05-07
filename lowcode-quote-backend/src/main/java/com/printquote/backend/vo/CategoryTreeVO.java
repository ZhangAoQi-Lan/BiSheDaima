package com.printquote.backend.vo;

import com.printquote.backend.entity.Category;
import lombok.Data;
import java.util.List;

/**
 * 分类树形 VO：一级分类 + 其下二级子分类列表
 */
@Data
public class CategoryTreeVO {
    private Long id;
    private String name;
    private String icon;
    private Integer sortOrder;
    private Long parentId;
    private List<CategoryTreeVO> children;

    public CategoryTreeVO() {}

    public CategoryTreeVO(Category parent, List<CategoryTreeVO> children) {
        this.id = parent.getId();
        this.name = parent.getName();
        this.icon = parent.getIcon();
        this.sortOrder = parent.getSortOrder();
        this.parentId = parent.getParentId();
        this.children = children;
    }
}
