package com.printquote.backend.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PriceBreakdownItemVO {

    private String key;

    private String label;

    private Double value;

    private String description;
}
