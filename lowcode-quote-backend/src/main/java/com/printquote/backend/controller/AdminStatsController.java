package com.printquote.backend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.printquote.backend.entity.Category;
import com.printquote.backend.entity.OrderInfo;
import com.printquote.backend.entity.User;
import com.printquote.backend.mapper.*;
import com.printquote.backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin/stats")
public class AdminStatsController {

    @Autowired
    private QuoteHistoryMapper quoteHistoryMapper;

    @Autowired
    private OrderInfoMapper orderInfoMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private CategoryMapper categoryMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private AfterSaleMapper afterSaleMapper;

    @GetMapping("/overview")
    public Result<Map<String, Object>> overview() {
        long quoteCount = quoteHistoryMapper.selectCount(null);
        List<OrderInfo> orders = orderInfoMapper.selectList(new LambdaQueryWrapper<OrderInfo>());
        BigDecimal orderAmount = orders.stream()
                .map(OrderInfo::getTotalPrice)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Map<String, Object> result = new HashMap<>();
        result.put("quoteCount", quoteCount);
        result.put("orderCount", (long) orders.size());
        result.put("orderAmount", orderAmount);
        result.put("userCount", userMapper.selectCount(new LambdaQueryWrapper<User>()));
        result.put("afterSaleCount", afterSaleMapper.selectCount(null));
        return Result.success(result);
    }

    @GetMapping("/status")
    public Result<List<Map<String, Object>>> orderStatus() {
        List<OrderInfo> orders = orderInfoMapper.selectList(new LambdaQueryWrapper<OrderInfo>());
        Map<String, Long> grouped = orders.stream()
                .collect(Collectors.groupingBy(OrderInfo::getStatus, LinkedHashMap::new, Collectors.counting()));

        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<String, Long> entry : grouped.entrySet()) {
            Map<String, Object> item = new HashMap<>();
            item.put("status", entry.getKey());
            item.put("total", entry.getValue());
            result.add(item);
        }
        return Result.success(result);
    }

    @GetMapping("/trend")
    public Result<List<Map<String, Object>>> orderTrend() {
        LocalDate today = LocalDate.now();
        LocalDate start = today.minusDays(6);
        List<OrderInfo> orders = orderInfoMapper.selectList(
                new LambdaQueryWrapper<OrderInfo>()
                        .ge(OrderInfo::getCreateTime, start.atStartOfDay())
        );
        Map<LocalDate, List<OrderInfo>> grouped = orders.stream()
                .filter(order -> order.getCreateTime() != null)
                .collect(Collectors.groupingBy(order -> order.getCreateTime().toLocalDate()));

        List<Map<String, Object>> result = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            LocalDate day = start.plusDays(i);
            List<OrderInfo> dayOrders = grouped.getOrDefault(day, Collections.emptyList());
            BigDecimal amount = dayOrders.stream()
                    .map(OrderInfo::getTotalPrice)
                    .filter(Objects::nonNull)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            Map<String, Object> item = new HashMap<>();
            item.put("date", day.toString());
            item.put("orderCount", dayOrders.size());
            item.put("amount", amount);
            result.add(item);
        }
        return Result.success(result);
    }

    @GetMapping("/products")
    public Result<List<Map<String, Object>>> topProducts() {
        return Result.success(orderItemMapper.selectTopProducts(6));
    }

    @GetMapping("/categories")
    public Result<List<Map<String, Object>>> topCategories() {
        Map<Long, String> categoryNameMap = categoryMapper.selectList(new LambdaQueryWrapper<Category>())
                .stream()
                .collect(Collectors.toMap(Category::getId, Category::getName, (a, b) -> a));

        List<Map<String, Object>> result = new ArrayList<>();
        for (Map<String, Object> row : quoteHistoryMapper.selectTopCategories(6)) {
            Long categoryId = row.get("categoryId") == null ? null : Long.valueOf(row.get("categoryId").toString());
            Map<String, Object> item = new HashMap<>();
            item.put("categoryId", categoryId);
            item.put("name", categoryNameMap.getOrDefault(categoryId, "未命名分类"));
            item.put("total", Long.valueOf(row.get("total").toString()));
            result.add(item);
        }
        return Result.success(result);
    }
}
