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

export function updateOrderStatus(orderId, status, note = '') {
  return request.put(`/admin/order/${orderId}/status`, { status, note })
}

export function updateOrderProduction(orderId, data) {
  return request.put(`/admin/order/${orderId}/production`, data)
}

// ===== 用户管理（写操作） =====
export function updateUserPassword(userId, password) {
  return request.put(`/admin/user/${userId}/password`, { password })
}

export function updateUserRole(userId, role) {
  return request.put(`/admin/user/${userId}/role`, { role })
}

// ===== 售后管理 =====
export function getAdminAfterSales(status) {
  return request.get('/admin/after-sale/list', { params: { status } })
}

export function updateAfterSaleStatus(id, status) {
  return request.put(`/admin/after-sale/${id}/status`, { status })
}

// ===== 统计面板 =====
export function getAdminStatsOverview() {
  return request.get('/admin/stats/overview')
}

export function getAdminStatsStatus() {
  return request.get('/admin/stats/status')
}

export function getAdminStatsProducts() {
  return request.get('/admin/stats/products')
}

export function getAdminStatsCategories() {
  return request.get('/admin/stats/categories')
}

export function getAdminStatsTrend() {
  return request.get('/admin/stats/trend')
}
