import request from '@/utils/request'

export function getAfterSales() {
  return request.get('/mall/after-sale')
}

export function createAfterSale(data) {
  return request.post('/mall/after-sale', data)
}
