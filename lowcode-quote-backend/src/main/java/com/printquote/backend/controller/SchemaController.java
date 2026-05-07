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

    /**
     * 获取指定分类节点关联的图纸数据 (前后台通用)
     */
    @GetMapping("/category/{categoryId}")
    public Result<String> getSchemaByCategoryId(@PathVariable("categoryId") Long categoryId) {
        LambdaQueryWrapper<CategorySchema> query = new LambdaQueryWrapper<>();
        query.eq(CategorySchema::getCategoryId, categoryId);
        CategorySchema schema = schemaMapper.selectOne(query);
        
        if (schema != null && schema.getSchemaJson() != null) {
            // 直接将 JSON String 以原始格式包装到 Result 中进行返回，这样前端不需要再次解析 string 而是直接使用 JSON 结构
            // 如果要在 Result 中包裹纯 JSON 格式可能需要调整包装逻辑，当前以返回字串处理，前端需要 JSON.parse(res.data)
            return Result.success(schema.getSchemaJson());
        }
        
        // 若没有存过，就返回一个默认空底板
        Category cat = categoryMapper.selectById(categoryId);
        String name = cat != null ? cat.getName() : "未命名产品";
        
        String initJson = String.format(
                "{\"schemaVersion\":2,\"categoryId\":\"%d\",\"productName\":\"%s\",\"common\":{\"id\":\"common\",\"name\":\"\",\"sortOrder\":0,\"materials\":[],\"sizeGroup\":[],\"crafts\":[],\"elements\":[],\"constraints\":[]},\"sections\":[{\"id\":\"sec_base\",\"name\":\"\",\"sortOrder\":1,\"materials\":[],\"sizeGroup\":[],\"crafts\":[],\"elements\":[],\"constraints\":[]}],\"constraints\":[],\"pricing\":{\"basePrice\":0,\"quantityElId\":null}}",
                categoryId, name
        );
        return Result.success(initJson);
    }
    
    /**
     * 管理端保存图纸 (Lowcode 拼装界面调用该接口存放最终产物)
     */
    @PutMapping("/category/{categoryId}")
    public Result<String> saveSchema(@PathVariable("categoryId") Long categoryId, @RequestBody Map<String, Object> schemaMap) {
        try {
            String jsonStr = new ObjectMapper().writeValueAsString(schemaMap);

            LambdaQueryWrapper<CategorySchema> queryWrapper = new LambdaQueryWrapper<>();
            queryWrapper.eq(CategorySchema::getCategoryId, categoryId);
            CategorySchema existSchema = schemaMapper.selectOne(queryWrapper);

            if (existSchema != null) {
                // 更新现有图纸
                LambdaUpdateWrapper<CategorySchema> updateWrapper = new LambdaUpdateWrapper<>();
                updateWrapper.eq(CategorySchema::getCategoryId, categoryId);
                
                CategorySchema updateEntity = new CategorySchema();
                updateEntity.setSchemaJson(jsonStr);
                updateEntity.setUpdateTime(new Date());
                schemaMapper.update(updateEntity, updateWrapper);
            } else {
                // 新增保存图纸
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
