import request from '@/utils/request'

export function getAddresses() {
  return request.get('/user/address')
}

export function createAddress(data) {
  return request.post('/user/address', data)
}

export function updateAddress(id, data) {
  return request.put(`/user/address/${id}`, data)
}

export function deleteAddress(id) {
  return request.delete(`/user/address/${id}`)
}

export function setDefaultAddress(id) {
  return request.put(`/user/address/${id}/default`)
}
