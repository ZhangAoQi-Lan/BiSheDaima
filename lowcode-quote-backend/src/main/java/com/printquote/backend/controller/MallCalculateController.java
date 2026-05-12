package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.printquote.backend.entity.CategorySchema;
import com.printquote.backend.mapper.CategorySchemaMapper;
import com.printquote.backend.vo.CalculatePriceRequest;
import com.printquote.backend.vo.PriceBreakdownItemVO;
import com.printquote.backend.vo.PriceCalculationVO;
import com.printquote.backend.vo.Result;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.text.DecimalFormat;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@RestController
@RequestMapping("/api/mall/category")
public class MallCalculateController {

    private static final Logger log = LoggerFactory.getLogger(MallCalculateController.class);
    private static final Pattern TOKEN_PATTERN = Pattern.compile("[A-Za-z_][A-Za-z0-9_]*(\\.[A-Za-z_][A-Za-z0-9_]*)*");

    @Autowired
    private CategorySchemaMapper schemaMapper;

    @PostMapping("/{id}/calculate")
    public Result<PriceCalculationVO> calculatePrice(@PathVariable("id") Long categoryId,
                                                     @RequestBody CalculatePriceRequest request) {
        try {
            LambdaQueryWrapper<CategorySchema> queryWrapper = new LambdaQueryWrapper<>();
            queryWrapper.eq(CategorySchema::getCategoryId, categoryId);
            CategorySchema schemaEntity = schemaMapper.selectOne(queryWrapper);

            if (schemaEntity == null || schemaEntity.getSchemaJson() == null) {
                return Result.error("未找到该分类对应的报价配置");
            }

            ObjectMapper mapper = new ObjectMapper();
            JsonNode schemaNode = mapper.readTree(schemaEntity.getSchemaJson());
            Map<String, Object> formData = request.getFormData();
            List<JsonNode> allElements = flattenElements(schemaNode);
            JsonNode pricingNode = schemaNode.path("pricing");

            double optionAddTotal = resolveOptionAddTotal(allElements, formData);
            double optionRatio = resolveOptionRatioTotal(allElements, formData);
            Map<String, Double> pricingContext = buildPricingContext(schemaNode, pricingNode, allElements, formData, optionAddTotal, optionRatio);

            String formula = pricingNode.path("formula").asText("").trim();
            List<String> warnings = new ArrayList<>();
            if (!formula.isEmpty()) {
                warnings.addAll(collectFormulaWarnings(formula, pricingContext));
            }

            double finalPrice = calculatePriceValue(pricingNode, pricingContext);
            finalPrice = Math.max(0.0, finalPrice);
            warnings.addAll(collectRiskWarnings(pricingContext, finalPrice));

            PriceCalculationVO result = new PriceCalculationVO();
            result.setTotalPrice(round(finalPrice));
            result.setTotalPriceText(formatPrice(finalPrice));
            result.setMode(formula.isEmpty() ? "operations" : "formula");
            result.setFormula(formula.isEmpty() ? null : formula);
            result.setContext(pricingContext);
            result.setBreakdown(buildBreakdown(pricingNode, allElements, formData, pricingContext));
            result.setWarnings(warnings);

            log.info("[计价] categoryId={} mode={} context={} finalPrice={}",
                    categoryId, result.getMode(), pricingContext, result.getTotalPriceText());

            return Result.success(result);
        } catch (Exception e) {
            log.error("系统计价异常", e);
            return Result.error("系统计价异常: " + e.getMessage());
        }
    }

    private double calculatePriceValue(JsonNode pricingNode, Map<String, Double> pricingContext) {
        String formula = pricingNode.path("formula").asText("").trim();
        if (!formula.isEmpty()) {
            return evaluateFormula(formula, pricingContext);
        }
        return calculateByOperations(pricingNode, pricingContext);
    }

    private double calculateByOperations(JsonNode pricingNode, Map<String, Double> pricingContext) {
        if (pricingNode.has("operations") && pricingNode.get("operations").isArray()) {
            double runningTotal = 0.0;
            for (JsonNode operation : pricingNode.get("operations")) {
                if (operation.has("enabled") && !operation.path("enabled").asBoolean(true)) {
                    continue;
                }

                String type = operation.path("type").asText("");
                if ("base".equals(type)) {
                    runningTotal += pricingContext.getOrDefault("basePrice", 0.0);
                } else if ("option_add_sum".equals(type)) {
                    runningTotal += pricingContext.getOrDefault("optionTotal", 0.0);
                } else if ("option_ratio_multiply".equals(type)) {
                    runningTotal *= pricingContext.getOrDefault("optionRatio", 1.0);
                } else if ("multiply_number".equals(type)) {
                    String fieldId = operation.path("fieldId").asText("");
                    runningTotal *= pricingContext.getOrDefault(fieldId, 1.0);
                }
            }
            return runningTotal;
        }

        double basePrice = pricingContext.getOrDefault("basePrice", 0.0);
        double optionTotal = pricingContext.getOrDefault("optionTotal", 0.0);
        double optionRatio = pricingContext.getOrDefault("optionRatio", 1.0);
        double quantity = pricingContext.getOrDefault("quantity", 1.0);
        double models = pricingContext.getOrDefault("models", 1.0);
        return (basePrice + optionTotal) * optionRatio * quantity * models;
    }

    private Map<String, Double> buildPricingContext(JsonNode schemaNode,
                                                    JsonNode pricingNode,
                                                    List<JsonNode> allElements,
                                                    Map<String, Object> formData,
                                                    double optionAddTotal,
                                                    double optionRatio) {
        Map<String, Double> context = new LinkedHashMap<>();

        double basePrice = safeDouble(schemaNode.path("common").path("basePrice"), 0.0);
        if (schemaNode.has("sections") && schemaNode.get("sections").isArray()) {
            for (JsonNode section : schemaNode.get("sections")) {
                basePrice += safeDouble(section.path("basePrice"), 0.0);
            }
        }
        if (basePrice == 0.0) {
            basePrice = safeDouble(pricingNode.get("basePrice"), 0.0);
        }
        context.put("basePrice", basePrice);
        context.put("optionTotal", optionAddTotal);
        context.put("optionRatio", optionRatio);

        String quantityElId = pricingNode.path("quantityElId").isMissingNode() || pricingNode.path("quantityElId").isNull()
                ? null : pricingNode.path("quantityElId").asText();
        String modelsElId = pricingNode.path("modelsElId").isMissingNode() || pricingNode.path("modelsElId").isNull()
                ? null : pricingNode.path("modelsElId").asText();

        double quantity = resolveFieldNumber(formData, quantityElId);
        double models = resolveFieldNumber(formData, modelsElId);
        context.put("quantity", quantity);
        context.put("models", models);
        if (quantityElId != null && !quantityElId.isBlank()) {
            context.put(quantityElId, quantity);
        }
        if (modelsElId != null && !modelsElId.isBlank()) {
            context.put(modelsElId, models);
        }

        for (JsonNode element : allElements) {
            String elementId = element.path("id").asText("");
            if (elementId.isBlank()) continue;

            String type = element.path("type").asText("");
            String pricingKey = resolvePricingKey(element);

            if ("number".equals(type)) {
                double value = resolveFieldNumber(formData, elementId);
                putFieldContext(context, elementId, pricingKey, value);
            } else if ("size-mix".equals(type)) {
                double sizePrice = resolveSizeMixPrice(element, formData, elementId);
                putFieldContext(context, elementId, pricingKey, sizePrice);
                if (formData != null) {
                    double width = extractSizeDimension(formData, elementId, "w");
                    double height = extractSizeDimension(formData, elementId, "h");
                    if (width > 0 && height > 0) {
                        context.put(elementId + ".width", width);
                        context.put(elementId + ".height", height);
                        context.put(elementId + ".area", width * height);
                        if (pricingKey != null && !pricingKey.equals(elementId)) {
                            context.put(pricingKey + ".width", width);
                            context.put(pricingKey + ".height", height);
                            context.put(pricingKey + ".area", width * height);
                        }
                    }
                }
            } else if ("select".equals(type) || "radio".equals(type) || "checkbox".equals(type)) {
                double value = resolveElementOptionTotal(element, formData);
                putFieldContext(context, elementId, pricingKey, value);

                double[] optionAgg = aggregateMatchedOptions(element, formData, elementId);
                context.put(elementId + ".priceAdd", optionAgg[0]);
                context.put(elementId + ".priceRatio", optionAgg[1]);
                if (pricingKey != null && !pricingKey.equals(elementId)) {
                    context.put(pricingKey + ".priceAdd", optionAgg[0]);
                    context.put(pricingKey + ".priceRatio", optionAgg[1]);
                }
            } else {
                double value = resolveElementOptionTotal(element, formData);
                putFieldContext(context, elementId, pricingKey, value);
            }
        }

        return context;
    }

    private void putFieldContext(Map<String, Double> context, String elementId, String pricingKey, double value) {
        context.put(elementId, value);
        if (pricingKey != null && !pricingKey.equals(elementId)) {
            context.put(pricingKey, value);
        }
    }

    private double[] aggregateMatchedOptions(JsonNode element, Map<String, Object> formData, String elementId) {
        double aggAdd = 0.0;
        double aggRatio = 1.0;
        if (formData == null || !element.has("options") || !formData.containsKey(elementId)) {
            return new double[]{aggAdd, aggRatio};
        }
        Object userValue = formData.get(elementId);
        if (userValue == null) return new double[]{aggAdd, aggRatio};

        for (JsonNode option : element.get("options")) {
            String optionId = option.path("id").asText("");
            if (optionId.isBlank()) continue;

            boolean matched;
            if (userValue instanceof List<?>) {
                matched = ((List<?>) userValue).contains(optionId);
            } else {
                matched = optionId.equals(userValue.toString());
            }

            if (matched) {
                aggAdd += safeDouble(option.get("priceAdd"), 0.0);
                aggRatio *= safeDouble(option.get("priceRatio"), 1.0);
            }
        }
        return new double[]{aggAdd, aggRatio};
    }

    private double resolveOptionRatioTotal(List<JsonNode> allElements, Map<String, Object> formData) {
        double totalRatio = 1.0;
        if (formData == null || allElements.isEmpty()) {
            return totalRatio;
        }

        for (JsonNode element : allElements) {
            String type = element.path("type").asText("");
            if (!"select".equals(type) && !"radio".equals(type) && !"checkbox".equals(type)) {
                continue;
            }

            String elementId = element.path("id").asText("");
            if (elementId.isBlank()) continue;
            double[] aggregate = aggregateMatchedOptions(element, formData, elementId);
            totalRatio *= aggregate[1];
        }

        return totalRatio <= 0 ? 1.0 : totalRatio;
    }

    private double extractSizeDimension(Map<String, Object> formData, String elementId, String keySuffix) {
        if (formData == null) return 0.0;
        String key = elementId + "_" + keySuffix;
        return resolveFieldNumber(formData, key);
    }

    private String resolvePricingKey(JsonNode element) {
        if (element == null || !element.has("pricingMeta")) return null;
        String rawKey = element.path("pricingMeta").path("key").asText("").trim();
        if (rawKey.isEmpty()) return null;
        String normalized = rawKey
                .replaceAll("[^A-Za-z0-9_]", "_")
                .replaceAll("_+", "_")
                .replaceAll("^_+|_+$", "");
        if (normalized.isEmpty()) return null;
        if (!Character.isLetter(normalized.charAt(0)) && normalized.charAt(0) != '_') {
            normalized = "field_" + normalized;
        }
        return normalized;
    }

    private double resolveOptionAddTotal(List<JsonNode> allElements, Map<String, Object> formData) {
        double totalAddons = 0.0;
        if (formData == null || allElements.isEmpty()) {
            return totalAddons;
        }

        for (JsonNode element : allElements) {
            totalAddons += resolveElementOptionTotal(element, formData);
        }

        return totalAddons;
    }

    private double resolveElementOptionTotal(JsonNode element, Map<String, Object> formData) {
        if (formData == null) return 0.0;

        String elementId = element.path("id").asText("");
        String type = element.path("type").asText("");
        if (elementId.isBlank()) return 0.0;

        if ("size-mix".equals(type)) {
            return resolveSizeMixPrice(element, formData, elementId);
        }

        if (!"select".equals(type) && !"radio".equals(type) && !"checkbox".equals(type)) {
            return 0.0;
        }

        if (!element.has("options") || !formData.containsKey(elementId)) return 0.0;
        Object userValue = formData.get(elementId);
        if (userValue == null) return 0.0;

        double total = 0.0;
        for (JsonNode option : element.get("options")) {
            String optionId = option.path("id").asText("");
            if (optionId.isBlank()) continue;

            boolean matched;
            if (userValue instanceof List<?>) {
                matched = ((List<?>) userValue).contains(optionId);
            } else {
                matched = optionId.equals(userValue.toString());
            }

            if (matched) {
                double add = safeDouble(option.get("priceAdd"), 0.0);
                total += add;
            }
        }
        return total;
    }

    private double resolveFieldNumber(Map<String, Object> formData, String fieldId) {
        if (fieldId == null || fieldId.isBlank() || formData == null || !formData.containsKey(fieldId)) {
            return 1.0;
        }
        double value = safeDoubleFromObject(formData.get(fieldId), 1.0);
        return value <= 0 ? 1.0 : value;
    }

    private double resolveSizeMixPrice(JsonNode element, Map<String, Object> formData, String elementId) {
        if (formData == null || !formData.containsKey(elementId)) return 0.0;
        Object value = formData.get(elementId);
        if (value == null) return 0.0;
        String label = value.toString().trim();
        if (label.isEmpty() || "custom".equals(label)) return 0.0;

        if (!element.has("presets") || !element.get("presets").isArray()) return 0.0;
        for (JsonNode preset : element.get("presets")) {
            if (label.equals(preset.path("label").asText("").trim())) {
                return safeDouble(preset.get("priceAdd"), 0.0);
            }
        }
        return 0.0;
    }

    private List<String> collectFormulaWarnings(String formula, Map<String, Double> context) {
        List<String> warnings = new ArrayList<>();
        Set<String> missingTokens = new LinkedHashSet<>();
        Matcher matcher = TOKEN_PATTERN.matcher(formula);
        while (matcher.find()) {
            String token = matcher.group();
            if (!context.containsKey(token)) {
                missingTokens.add(token);
            }
        }
        for (String token : missingTokens) {
            warnings.add("公式中引用了未赋值变量：" + token + "，系统按 0 处理。");
        }
        return warnings;
    }

    private List<String> collectRiskWarnings(Map<String, Double> context, double finalPrice) {
        List<String> warnings = new ArrayList<>();
        double optionRatio = context.getOrDefault("optionRatio", 1.0);
        double optionTotal = context.getOrDefault("optionTotal", 0.0);
        double quantity = context.getOrDefault("quantity", 1.0);
        double models = context.getOrDefault("models", 1.0);

        if (optionRatio > 10) {
            warnings.add("当前选项系数较大（" + formatRatio(optionRatio) + "），请检查是否把金额或百分比误填到了系数字段。");
        }
        if (optionRatio > 100) {
            warnings.add("当前选项系数已超过 100 倍，建议优先核对印色、工艺、印面等字段的系数配置。");
        }
        if (optionTotal < 0) {
            warnings.add("当前选配加价合计为负值，请确认是否存在用于减价的特殊工艺配置。");
        }
        if (quantity > 100000 || models > 1000) {
            warnings.add("数量倍数或款数倍数较大，请确认数量字段和款数字段绑定是否正确。");
        }
        if (finalPrice > 100000) {
            warnings.add("当前总价较高，请结合系数、数量和款数配置再次确认。");
        }
        return warnings;
    }

    private double evaluateFormula(String formula, Map<String, Double> context) {
        try {
            Matcher matcher = TOKEN_PATTERN.matcher(formula);
            StringBuffer replaced = new StringBuffer();
            while (matcher.find()) {
                String token = matcher.group();
                double value = context.getOrDefault(token, 0.0);
                matcher.appendReplacement(replaced, Matcher.quoteReplacement(Double.toString(value)));
            }
            matcher.appendTail(replaced);
            return evaluateExpression(replaced.toString());
        } catch (Exception e) {
            log.error("Formula evaluation failed: formula='{}' context={}", formula, context, e);
            return 0.0;
        }
    }

    private double evaluateExpression(String expression) {
        List<String> tokens = tokenize(expression);
        List<String> postfix = toPostfix(tokens);
        return evalPostfix(postfix);
    }

    private List<String> tokenize(String expression) {
        List<String> tokens = new ArrayList<>();
        StringBuilder number = new StringBuilder();
        for (int i = 0; i < expression.length(); i++) {
            char ch = expression.charAt(i);
            if (Character.isWhitespace(ch)) continue;

            if (Character.isDigit(ch) || ch == '.') {
                number.append(ch);
                continue;
            }

            if (number.length() > 0) {
                tokens.add(number.toString());
                number.setLength(0);
            }

            if (ch == '-' && (tokens.isEmpty() || isOperator(tokens.get(tokens.size() - 1)) || "(".equals(tokens.get(tokens.size() - 1)))) {
                number.append(ch);
                continue;
            }

            tokens.add(String.valueOf(ch));
        }
        if (number.length() > 0) {
            tokens.add(number.toString());
        }
        return tokens;
    }

    private List<String> toPostfix(List<String> tokens) {
        List<String> output = new ArrayList<>();
        Deque<String> operators = new ArrayDeque<>();

        for (String token : tokens) {
            if (isNumber(token)) {
                output.add(token);
            } else if ("(".equals(token)) {
                operators.push(token);
            } else if (")".equals(token)) {
                while (!operators.isEmpty() && !"(".equals(operators.peek())) {
                    output.add(operators.pop());
                }
                if (!operators.isEmpty()) operators.pop();
            } else if (isOperator(token)) {
                while (!operators.isEmpty() && isOperator(operators.peek())
                        && precedence(operators.peek()) >= precedence(token)) {
                    output.add(operators.pop());
                }
                operators.push(token);
            }
        }

        while (!operators.isEmpty()) {
            output.add(operators.pop());
        }
        return output;
    }

    private double evalPostfix(List<String> postfix) {
        Deque<Double> stack = new ArrayDeque<>();
        for (String token : postfix) {
            if (isNumber(token)) {
                stack.push(Double.parseDouble(token));
                continue;
            }

            double right = stack.pop();
            double left = stack.pop();
            switch (token) {
                case "+" -> stack.push(left + right);
                case "-" -> stack.push(left - right);
                case "*" -> stack.push(left * right);
                case "/" -> stack.push(right == 0 ? 0.0 : left / right);
                default -> throw new IllegalArgumentException("Unsupported operator: " + token);
            }
        }
        return stack.isEmpty() ? 0.0 : stack.pop();
    }

    private List<PriceBreakdownItemVO> buildBreakdown(JsonNode pricingNode,
                                                      List<JsonNode> allElements,
                                                      Map<String, Object> formData,
                                                      Map<String, Double> context) {
        List<PriceBreakdownItemVO> items = new ArrayList<>();
        items.add(new PriceBreakdownItemVO("basePrice", "基础底价", round(context.getOrDefault("basePrice", 0.0)), "报价起始金额"));
        items.add(new PriceBreakdownItemVO("optionTotal", "选配加价", round(context.getOrDefault("optionTotal", 0.0)), "所有已选纸张、工艺和尺寸预设的附加金额汇总"));
        items.add(new PriceBreakdownItemVO("optionRatio", "选项系数", round(context.getOrDefault("optionRatio", 1.0)), "所有已选项倍率系数的连乘结果"));
        items.add(new PriceBreakdownItemVO("quantity", "数量倍数", round(context.getOrDefault("quantity", 1.0)), "数量字段对应的乘算倍数"));
        items.add(new PriceBreakdownItemVO("models", "款数倍数", round(context.getOrDefault("models", 1.0)), "款数字段对应的乘算倍数"));

        items.addAll(buildSelectionBreakdown(allElements, formData));

        if (!pricingNode.path("formula").asText("").trim().isEmpty()) {
            items.add(new PriceBreakdownItemVO("mode", "计价方式", null, "当前使用公式计价"));
        } else {
            items.add(new PriceBreakdownItemVO("mode", "计价方式", null, "当前使用定价步骤计价"));
        }
        return items;
    }

    private List<PriceBreakdownItemVO> buildSelectionBreakdown(List<JsonNode> allElements, Map<String, Object> formData) {
        List<PriceBreakdownItemVO> items = new ArrayList<>();
        if (formData == null) return items;

        for (JsonNode element : allElements) {
            String elementId = element.path("id").asText("");
            String elementName = element.path("name").asText(elementId);
            String type = element.path("type").asText("");

            if ("size-mix".equals(type)) {
                Object selected = formData.get(elementId);
                if (selected == null) continue;
                String label = selected.toString();
                double price = resolveSizeMixPrice(element, formData, elementId);
                if (label != null && !label.isBlank()) {
                    items.add(new PriceBreakdownItemVO(
                            "selection:" + elementId,
                            elementName + "：" + label,
                            round(price),
                            "尺寸预设加价"
                    ));
                }
                continue;
            }

            if (!"select".equals(type) && !"radio".equals(type) && !"checkbox".equals(type)) {
                continue;
            }

            if (!element.has("options") || !formData.containsKey(elementId)) {
                continue;
            }
            Object userValue = formData.get(elementId);
            if (userValue == null) continue;

            for (JsonNode option : element.get("options")) {
                String optionId = option.path("id").asText("");
                if (optionId.isBlank()) continue;

                boolean matched;
                if (userValue instanceof List<?>) {
                    matched = ((List<?>) userValue).contains(optionId);
                } else {
                    matched = optionId.equals(userValue.toString());
                }

                if (matched) {
                    double add = safeDouble(option.get("priceAdd"), 0.0);
                    double ratio = safeDouble(option.get("priceRatio"), 1.0);
                    items.add(new PriceBreakdownItemVO(
                            "selection:" + elementId + ":" + optionId,
                            elementName + "：" + option.path("label").asText(optionId),
                            round(add),
                            "固定加价 ¥" + formatPrice(add) + "，系数 ×" + formatRatio(ratio)
                    ));
                }
            }
        }

        return items;
    }

    private boolean isOperator(String token) {
        return "+".equals(token) || "-".equals(token) || "*".equals(token) || "/".equals(token);
    }

    private boolean isNumber(String token) {
        if (token == null || token.isBlank()) return false;
        try {
            Double.parseDouble(token);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    private int precedence(String operator) {
        return ("+".equals(operator) || "-".equals(operator)) ? 1 : 2;
    }

    private double safeDouble(JsonNode node, double defaultValue) {
        if (node == null || node.isNull()) return defaultValue;
        try {
            return node.asDouble(defaultValue);
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private double safeDoubleFromObject(Object obj, double defaultValue) {
        if (obj == null) return defaultValue;
        try {
            if (obj instanceof Number) return ((Number) obj).doubleValue();
            return Double.parseDouble(obj.toString().trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private Double round(double value) {
        return Math.round(value * 100.0) / 100.0;
    }

    private String formatPrice(double value) {
        return new DecimalFormat("#0.00").format(value);
    }

    private String formatRatio(double value) {
        return new DecimalFormat("#0.##").format(value);
    }

    private List<JsonNode> flattenElements(JsonNode schemaNode) {
        List<JsonNode> result = new ArrayList<>();
        String[] groups = {"materials", "sizeGroup", "crafts", "elements"};

        if (schemaNode.has("sections") && schemaNode.get("sections").isArray()) {
            JsonNode commonNode = schemaNode.get("common");
            if (commonNode != null && commonNode.isObject()) {
                for (String group : groups) {
                    JsonNode arr = commonNode.get(group);
                    if (arr != null && arr.isArray()) arr.forEach(result::add);
                }
            }
            for (JsonNode section : schemaNode.get("sections")) {
                for (String group : groups) {
                    JsonNode arr = section.get(group);
                    if (arr != null && arr.isArray()) arr.forEach(result::add);
                }
            }
            return result;
        }

        for (String group : groups) {
            JsonNode arr = schemaNode.get(group);
            if (arr != null && arr.isArray()) arr.forEach(result::add);
        }
        return result;
    }
}
