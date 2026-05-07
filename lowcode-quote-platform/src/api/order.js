import request from '@/utils/request'
import { getOrCreateSessionId } from '@/utils/session'

const sessionHeader = () => ({ 'X-Session-Id': getOrCreateSessionId() })

export function createOrder() {
  return request.post('/mall/order', {}, { headers: sessionHeader() })
}

export function getOrders() {
  return request.get('/mall/order', { headers: sessionHeader() })
}

export function getOrderDetail(id) {
  return request.get(`/mall/order/${id}`, { headers: sessionHeader() })
}
