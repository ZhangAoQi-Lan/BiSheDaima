import request from '@/utils/request'
import { getOrCreateSessionId } from '@/utils/session'

const headers = () => ({ 'X-Session-Id': getOrCreateSessionId() })

export function getQuoteHistory() {
  return request.get('/mall/quote-history', { headers: headers() })
}

export function saveQuoteHistory(data) {
  return request.post('/mall/quote-history', data, { headers: headers() })
}
