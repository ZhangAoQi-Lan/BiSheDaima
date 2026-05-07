import request from '@/utils/request'
import { getOrCreateSessionId } from '@/utils/session'

const headers = () => ({ 'X-Session-Id': getOrCreateSessionId() })

/** 获取暂存箱列表 */
export function getCartItems() {
  return request.get('/mall/cart', { headers: headers() })
}

/** 加入暂存箱 */
export function addCartItem(payload) {
  return request.post('/mall/cart', payload, { headers: headers() })
}

/** 删除单条暂存记录 */
export function deleteCartItem(id) {
  return request.delete(`/mall/cart/${id}`, { headers: headers() })
}

/** 清空暂存箱 */
export function clearCart() {
  return request.delete('/mall/cart', { headers: headers() })
}
