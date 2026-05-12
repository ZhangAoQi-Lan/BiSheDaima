import request from '@/utils/request'

export function getMallSiteContent() {
  return request.get('/mall/site/content')
}

export function getAdminSiteContent() {
  return request.get('/admin/site/content')
}

export function saveAdminSiteContent(data) {
  return request.put('/admin/site/content', data)
}
