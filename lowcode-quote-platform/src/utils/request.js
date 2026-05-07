import axios from 'axios'
import { ElMessage } from 'element-plus'

const service = axios.create({
  baseURL: 'http://localhost:8080/api', // 指向刚刚开放的 Spring Boot 端口
  timeout: 10000 
})

import router from '@/router'
import { useUserStore } from '@/stores/user'

// 请求拦截器
service.interceptors.request.use(
  config => {
    const userStore = useUserStore()
    if (userStore.token) {
      config.headers['Authorization'] = 'Bearer ' + userStore.token
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  response => {
    const res = response.data
    // 对应我们后端的 Result.java
    if (res.code === 401) {
      ElMessage.error(res.msg || res.message || '未授权，请登录')
      const userStore = useUserStore()
      userStore.clearAuth()
      router.push('/login')
      return Promise.reject(new Error(res.msg || 'Error'))
    }
    
    // 我们原有的全局错误处理（忽略不需要特别拦的成功或其他结果）
    if (res.code !== undefined && res.code !== 200) {
      ElMessage.error(res.msg || res.message || 'Error')
      return Promise.reject(new Error(res.msg || res.message || 'Error'))
    } else {
      return res.data || res
    }
  },
  error => {
    ElMessage.error(error.message)
    if (error.response && error.response.status === 401) {
      const userStore = useUserStore()
      userStore.clearAuth()
      router.push('/login')
    }
    return Promise.reject(error)
  }
)

export default service
