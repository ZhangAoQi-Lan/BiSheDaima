import request from '@/utils/request'
import { getOrCreateSessionId } from '@/utils/session'

const sessionHeader = () => ({ 'X-Session-Id': getOrCreateSessionId() })

export function createOrder(data = {}) {
  return request.post('/mall/order', data, { headers: sessionHeader() })
}

export function getOrders() {
  return request.get('/mall/order', { headers: sessionHeader() })
}

export function getOrderDetail(id) {
  return request.get(`/mall/order/${id}`, { headers: sessionHeader() })
}

export function cancelOrder(id) {
  return request.put(`/mall/order/${id}/cancel`, {}, { headers: sessionHeader() })
}
