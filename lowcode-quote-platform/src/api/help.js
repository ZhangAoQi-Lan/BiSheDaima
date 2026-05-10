import request from '@/utils/request'

export function getCategories() {
  return request({
    url: '/help/categories',
    method: 'get'
  })
}

export function getArticleDetail(id) {
  return request({
    url: `/help/articles/${id}`,
    method: 'get'
  })
}

export function searchArticles(keyword) {
  return request({
    url: '/help/search',
    method: 'get',
    params: { keyword }
  })
}

export function submitFeedback(data) {
  return request({
    url: '/help/feedback',
    method: 'post',
    data
  })
}
