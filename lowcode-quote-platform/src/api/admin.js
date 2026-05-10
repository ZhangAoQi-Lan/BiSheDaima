import request from '@/utils/request'

// ===== 用户管理 =====
export function getAdminUsers(keyword) {
  return request.get('/admin/user/list', { params: { keyword } })
}

export function getAdminUserDetail(id) {
  return request.get(`/admin/user/${id}`)
}

// ===== 订单管理 =====
export function getAdminOrders(params) {
  return request.get('/admin/order/list', { params })
}

export function getAdminOrderDetail(id) {
  return request.get(`/admin/order/${id}`)
}

export function updateOrderStatus(orderId, status) {
  return request.put(`/admin/order/${orderId}/status`, { status })
}

// ===== 用户管理（写操作） =====
export function updateUserPassword(userId, password) {
  return request.put(`/admin/user/${userId}/password`, { password })
}

export function updateUserRole(userId, role) {
  return request.put(`/admin/user/${userId}/role`, { role })
}
