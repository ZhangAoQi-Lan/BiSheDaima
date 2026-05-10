package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.printquote.backend.entity.Category;
import com.printquote.backend.entity.CategorySchema;
import com.printquote.backend.mapper.CategoryMapper;
import com.printquote.backend.mapper.CategorySchemaMapper;
import com.printquote.backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.Map;

@RestController
@RequestMapping("/api/schema")
public class SchemaController {

    @Autowired
    private CategorySchemaMapper schemaMapper;

    @Autowired
    private CategoryMapper categoryMapper;

    @GetMapping("/category/{categoryId}")
    public Result<String> getSchemaByCategoryId(@PathVariable("categoryId") Long categoryId) {
        LambdaQueryWrapper<CategorySchema> query = new LambdaQueryWrapper<>();
        query.eq(CategorySchema::getCategoryId, categoryId);
        CategorySchema schema = schemaMapper.selectOne(query);

        if (schema != null && schema.getSchemaJson() != null) {
            return Result.success(schema.getSchemaJson());
        }

        Category category = categoryMapper.selectById(categoryId);
        String productName = category != null ? category.getName() : "未命名产品";

        String initJson = String.format(
                "{\"schemaVersion\":2,\"categoryId\":\"%d\",\"productName\":\"%s\",\"common\":{\"id\":\"common\",\"name\":\"\",\"sortOrder\":0,\"materials\":[],\"sizeGroup\":[],\"crafts\":[],\"elements\":[],\"constraints\":[]},\"sections\":[{\"id\":\"sec_base\",\"name\":\"\",\"sortOrder\":1,\"materials\":[],\"sizeGroup\":[],\"crafts\":[],\"elements\":[],\"constraints\":[]}],\"constraints\":[],\"pricing\":{\"basePrice\":0,\"quantityElId\":null,\"modelsElId\":null,\"note\":\"建议按底价、选配加价、数量/款数乘算的顺序配置报价步骤。\",\"operations\":[{\"id\":\"op_base\",\"type\":\"base\",\"label\":\"基础底价\",\"enabled\":true,\"description\":\"作为报价起始金额，通常对应开机费、基础工费或起印成本。\"},{\"id\":\"op_options\",\"type\":\"option_add_sum\",\"label\":\"选配加价汇总\",\"enabled\":true,\"description\":\"汇总纸张、工艺、尺寸预设等选项中配置的附加金额。\"},{\"id\":\"op_quantity\",\"type\":\"multiply_number\",\"label\":\"按数量乘算\",\"enabled\":false,\"fieldId\":null,\"description\":\"绑定数量类字段后，将当前金额按数量倍数放大。\"},{\"id\":\"op_models\",\"type\":\"multiply_number\",\"label\":\"按款数乘算\",\"enabled\":false,\"fieldId\":null,\"description\":\"绑定款数类字段后，适用于多款内容分别生产的场景。\"}]}}",
                categoryId, productName
        );
        return Result.success(initJson);
    }

    @PutMapping("/category/{categoryId}")
    public Result<String> saveSchema(@PathVariable("categoryId") Long categoryId, @RequestBody Map<String, Object> schemaMap) {
        try {
            String jsonStr = new ObjectMapper().writeValueAsString(schemaMap);

            LambdaQueryWrapper<CategorySchema> queryWrapper = new LambdaQueryWrapper<>();
            queryWrapper.eq(CategorySchema::getCategoryId, categoryId);
            CategorySchema existSchema = schemaMapper.selectOne(queryWrapper);

            if (existSchema != null) {
                LambdaUpdateWrapper<CategorySchema> updateWrapper = new LambdaUpdateWrapper<>();
                updateWrapper.eq(CategorySchema::getCategoryId, categoryId);

                CategorySchema updateEntity = new CategorySchema();
                updateEntity.setSchemaJson(jsonStr);
                updateEntity.setUpdateTime(new Date());
                schemaMapper.update(updateEntity, updateWrapper);
            } else {
                CategorySchema newSchema = new CategorySchema();
                newSchema.setCategoryId(categoryId);
                newSchema.setSchemaJson(jsonStr);
                newSchema.setUpdateTime(new Date());
                schemaMapper.insert(newSchema);
            }

            return Result.success("该分类下的产品图纸保存成功");
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("图纸保存失败: " + e.getMessage());
        }
    }
}
