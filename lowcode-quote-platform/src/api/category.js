import request from '@/utils/request'

export function getMallCategoryList() {
  return request({
    url: '/mall/category/list',
    method: 'get'
  })
}

export function getMallCategoryTree() {
  return request({
    url: '/mall/category/tree',
    method: 'get'
  })
}

// ---------------- 以下为管理端接口 ---------------- //

export function getAdminCategoryTree() {
  return request({
    url: '/admin/category/tree',
    method: 'get'
  })
}

export function getAdminCategoryList() {
  return request({
    url: '/admin/category/list',
    method: 'get'
  })
}

export function addCategory(data) {
  return request({
    url: '/admin/category',
    method: 'post',
    data
  })
}

export function updateCategory(data) {
  return request({
    url: '/admin/category',
    method: 'put',
    data
  })
}

export function deleteCategory(id) {
  return request({
    url: `/admin/category/${id}`,
    method: 'delete'
  })
}
