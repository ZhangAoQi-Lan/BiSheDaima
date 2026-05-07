import request from '@/utils/request'

// 获取所有状态正常的物料组件字典列表
export function getMaterialList() {
  return request.get('/admin/material/list')
}

// 新增或更新某物料组件字典
export function saveMaterial(data) {
  return request.post('/admin/material', data)
}

// 逻辑删除某物料组件字典
export function deleteMaterial(id) {
  return request.delete(`/admin/material/${id}`)
}
