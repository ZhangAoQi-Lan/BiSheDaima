package com.printquote.backend.controller;

import cn.hutool.http.HttpUtil;
import cn.hutool.json.JSONArray;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.printquote.backend.vo.Result;
import com.printquote.backend.vo.ReverseGeocodeVO;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/common/location")
public class LocationController {

    @Value("${amap.web-key:}")
    private String amapWebKey;

    @GetMapping("/reverse-geocode")
    public Result<ReverseGeocodeVO> reverseGeocode(@RequestParam Double latitude, @RequestParam Double longitude) {
        if (latitude == null || longitude == null) {
            return Result.error("经纬度参数不能为空");
        }
        if (amapWebKey == null || amapWebKey.isBlank()) {
            return Result.error("未配置高德地图 Web 服务 Key，请在 application.yml 中设置 amap.web-key");
        }

        Map<String, Object> params = new LinkedHashMap<>();
        params.put("key", amapWebKey);
        params.put("location", longitude + "," + latitude);
        params.put("extensions", "base");
        params.put("radius", 1000);
        params.put("output", "JSON");

        String responseText = HttpUtil.get("https://restapi.amap.com/v3/geocode/regeo", params);
        JSONObject root = JSONUtil.parseObj(responseText);
        if (!"1".equals(root.getStr("status"))) {
            return Result.error(root.getStr("info", "逆地理编码失败"));
        }

        JSONObject regeocode = root.getJSONObject("regeocode");
        if (regeocode == null) {
            return Result.error("未获取到地址信息");
        }

        JSONObject addressComponent = regeocode.getJSONObject("addressComponent");
        if (addressComponent == null) {
            return Result.error("地址解析结果不完整");
        }

        ReverseGeocodeVO result = new ReverseGeocodeVO();
        result.setProvince(addressComponent.getStr("province", ""));
        result.setCity(normalizeCity(addressComponent.get("city"), result.getProvince()));
        result.setDistrict(addressComponent.getStr("district", ""));
        result.setTownship(addressComponent.getStr("township", ""));
        result.setFormattedAddress(regeocode.getStr("formatted_address", ""));

        JSONObject streetNumber = addressComponent.getJSONObject("streetNumber");
        if (streetNumber != null) {
            result.setStreet(streetNumber.getStr("street", ""));
            result.setStreetNumber(streetNumber.getStr("number", ""));
        } else {
            result.setStreet("");
            result.setStreetNumber("");
        }

        result.setRecommendedDetailAddress(buildRecommendedDetailAddress(result));
        return Result.success(result);
    }

    private String normalizeCity(Object cityValue, String fallbackProvince) {
        if (cityValue == null) {
            return fallbackProvince;
        }
        if (cityValue instanceof JSONArray cityArray) {
            if (cityArray.isEmpty()) {
                return fallbackProvince;
            }
            Object firstValue = cityArray.get(0);
            return firstValue == null || String.valueOf(firstValue).isBlank() ? fallbackProvince : String.valueOf(firstValue).trim();
        }
        String city = String.valueOf(cityValue).trim();
        return city.isEmpty() ? fallbackProvince : city;
    }

    private String buildRecommendedDetailAddress(ReverseGeocodeVO result) {
        StringBuilder builder = new StringBuilder();
        appendIfPresent(builder, result.getTownship());
        appendIfPresent(builder, result.getStreet());
        appendIfPresent(builder, result.getStreetNumber());
        return builder.toString();
    }

    private void appendIfPresent(StringBuilder builder, String value) {
        if (value == null || value.isBlank()) {
            return;
        }
        builder.append(value.trim());
    }
}
