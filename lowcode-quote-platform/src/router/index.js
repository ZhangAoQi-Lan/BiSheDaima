import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: () => import('../views/login/index.vue'),
      meta: { requiresAuth: false }
    },
    {
      path: '/',
      redirect: '/mall'
    },
    {
      path: '/mall',
      name: 'mall-home',
      component: () => import('../views/mall/index.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/mall/orders',
      name: 'mall-orders',
      component: () => import('../views/mall/orders.vue'),
      meta: { requiresAuth: true }
    },

    {
      path: '/admin',
      redirect: '/admin/category'
    },
    {
      path: '/admin/category',
      name: 'admin-category',
      component: () => import('../views/admin/category.vue'),
      meta: { requiresAuth: true, role: 'ADMIN' }
    },
    {
      path: '/admin/material',
      name: 'admin-material',
      component: () => import('../views/admin/material/index.vue'),
      meta: { requiresAuth: true, role: 'ADMIN' }
    }
  ]
})

// 全局路由守卫
router.beforeEach((to, from, next) => {
  const userStore = useUserStore()
  
  // 检查该路由是否需要登录
  if (to.meta.requiresAuth) {
    if (!userStore.token) {
      next({ name: 'login', query: { redirect: to.fullPath } })
    } else {
      // 检查是否需要特定角色
      if (to.meta.role && userStore.userInfo.role !== to.meta.role) {
        // 如果需要 ADMIN 但当前用户不是 ADMIN
        import('element-plus').then(({ ElMessage }) => {
          ElMessage.error('权限不足，无法访问该页面')
        })
        next('/mall')
      } else {
        next()
      }
    }
  } else {
    // 不需要登录，直接放行
    next()
  }
})

export default router
