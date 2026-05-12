package com.printquote.backend.vo;

import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class PriceCalculationVO {

    private Double totalPrice;

    private String totalPriceText;

    private String mode;

    private String formula;

    private Map<String, Double> context;

    private List<PriceBreakdownItemVO> breakdown;

    private List<String> warnings;
}
