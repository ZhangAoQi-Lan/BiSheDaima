package com.printquote.backend.vo;

import lombok.Data;

@Data
public class ReverseGeocodeVO {
    private String province;
    private String city;
    private String district;
    private String township;
    private String street;
    private String streetNumber;
    private String formattedAddress;
    private String recommendedDetailAddress;
}
