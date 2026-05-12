import request from '@/utils/request'

export function reverseGeocode(params) {
  return request.get('/common/location/reverse-geocode', { params })
}
