import request from '@/utils/request'

export function getCurrentUser() {
  return request.get('/user/current')
}

export function updateProfile(data) {
  return request.put('/user/profile', data)
}

export function updatePassword(data) {
  return request.put('/user/password', data)
}
