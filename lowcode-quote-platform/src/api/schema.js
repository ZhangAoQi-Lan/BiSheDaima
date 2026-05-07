import request from '@/utils/request'

export function getCategorySchema(categoryId) {
  return request({
    url: `/schema/category/${categoryId}`,
    method: 'get'
  })
}

export function saveCategorySchema(categoryId, data) {
  return request({
    url: `/schema/category/${categoryId}`,
    method: 'put',
    data
  })
}

export function adminPreviewCalculatePrice(categoryId, data) {
  return request({
    url: `/mall/category/${categoryId}/calculate`,
    method: 'post',
    data
  })
}
