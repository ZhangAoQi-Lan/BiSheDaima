package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.printquote.backend.entity.CategorySchema;
import com.printquote.backend.mapper.CategorySchemaMapper;
import com.printquote.backend.vo.CalculatePriceRequest;
import com.printquote.backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/mall/category")
public class MallCalculateController {

    @Autowired
    private CategorySchemaMapper schemaMapper;

    @PostMapping("/{id}/calculate")
    public Result<String> calculatePrice(@PathVariable("id") Long categoryId, @RequestBody CalculatePriceRequest request) {
        try {
            LambdaQueryWrapper<CategorySchema> queryWrapper = new LambdaQueryWrapper<>();
            queryWrapper.eq(CategorySchema::getCategoryId, categoryId);
            CategorySchema schemaEntity = schemaMapper.selectOne(queryWrapper);

            if (schemaEntity == null || schemaEntity.getSchemaJson() == null) {
                return Result.error("未能找到分类配置好的定价图纸");
            }

            ObjectMapper mapper = new ObjectMapper();
            JsonNode schemaNode = mapper.readTree(schemaEntity.getSchemaJson());

            double basePrice = 0.0;
            String quantityElId = null;
            if (schemaNode.has("pricing")) {
                JsonNode pricingNode = schemaNode.get("pricing");
                if (pricingNode.has("basePrice")) {
                    basePrice = pricingNode.get("basePrice").asDouble(0.0);
                }
                if (pricingNode.has("quantityElId") && !pricingNode.get("quantityElId").isNull()) {
                    quantityElId = pricingNode.get("quantityElId").asText();
                }
            }

            double totalAddonsPrice = 0.0;
            Map<String, Object> formData = request.getFormData();
            List<JsonNode> allElements = flattenElements(schemaNode);

            if (formData != null && !allElements.isEmpty()) {
                for (JsonNode elNode : allElements) {
                    String elId = elNode.path("id").asText("");
                    String type = elNode.path("type").asText("");
                    if (elId.isBlank() || !formData.containsKey(elId)) {
                        continue;
                    }

                    Object userVal = formData.get(elId);
                    if (userVal == null) {
                        continue;
                    }

                    if (("select".equals(type) || "radio".equals(type) || "checkbox".equals(type)) && elNode.has("options")) {
                        for (JsonNode optNode : elNode.get("options")) {
                            String optId = optNode.path("id").asText("");
                            double priceAdd = optNode.has("priceAdd") ? optNode.get("priceAdd").asDouble(0.0) : 0.0;
                            if (optId.isBlank()) {
                                continue;
                            }

                            if (userVal instanceof List<?>) {
                                if (((List<?>) userVal).contains(optId)) {
                                    totalAddonsPrice += priceAdd;
                                }
                            } else if (optId.equals(userVal.toString())) {
                                totalAddonsPrice += priceAdd;
                            }
                        }
                    }
                }
            }

            double quantity = 1;
            if (quantityElId != null && formData != null && formData.containsKey(quantityElId)) {
                try {
                    quantity = Double.parseDouble(formData.get(quantityElId).toString());
                } catch (NumberFormatException ignored) {
                }
            }

            double finalPrice = (basePrice + totalAddonsPrice) * quantity;
            return Result.success(new DecimalFormat("#.00").format(finalPrice));

        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("系统计价异常: " + e.getMessage());
        }
    }

    /**
     * v1: root.{materials,sizeGroup,crafts,elements}
     * v2: root.common + root.sections[].{materials,sizeGroup,crafts,elements}
     */
    private List<JsonNode> flattenElements(JsonNode schemaNode) {
        List<JsonNode> result = new ArrayList<>();
        String[] groups = new String[]{"materials", "sizeGroup", "crafts", "elements"};

        if (schemaNode.has("sections") && schemaNode.get("sections").isArray()) {
            JsonNode commonNode = schemaNode.get("common");
            if (commonNode != null && commonNode.isObject()) {
                for (String group : groups) {
                    JsonNode groupNode = commonNode.get(group);
                    if (groupNode != null && groupNode.isArray()) {
                        groupNode.forEach(result::add);
                    }
                }
            }
            for (JsonNode sectionNode : schemaNode.get("sections")) {
                for (String group : groups) {
                    JsonNode groupNode = sectionNode.get(group);
                    if (groupNode != null && groupNode.isArray()) {
                        groupNode.forEach(result::add);
                    }
                }
            }
            return result;
        }

        for (String group : groups) {
            JsonNode groupNode = schemaNode.get(group);
            if (groupNode != null && groupNode.isArray()) {
                groupNode.forEach(result::add);
            }
        }
        return result;
    }
}
