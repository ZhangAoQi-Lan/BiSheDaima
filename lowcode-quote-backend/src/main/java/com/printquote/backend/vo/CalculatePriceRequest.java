package com.printquote.backend.vo;

import lombok.Data;
import java.util.Map;

@Data
public class CalculatePriceRequest {
    private Map<String, Object> formData;
}
