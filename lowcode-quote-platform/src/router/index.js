import { createRouter, createWebHistory } from 'vue-router'
import { ElMessage } from 'element-plus'
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
      meta: { requiresAuth: true, forbidAdmin: true }
    },
    {
      path: '/mall/orders',
      name: 'mall-orders',
      component: () => import('../views/mall/orders.vue'),
      meta: { requiresAuth: true, forbidAdmin: true }
    },
    {
      path: '/mall/help',
      name: 'mall-help',
      component: () => import('../views/mall/help/index.vue'),
      meta: { requiresAuth: true, forbidAdmin: true }
    },
    {
      path: '/mall/profile',
      name: 'mall-profile',
      component: () => import('../views/mall/profile.vue'),
      meta: { requiresAuth: true, forbidAdmin: true }
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
    },
    {
      path: '/admin/orders',
      name: 'admin-orders',
      component: () => import('../views/admin/orders/index.vue'),
      meta: { requiresAuth: true, role: 'ADMIN' }
    },
    {
      path: '/admin/after-sale',
      name: 'admin-after-sale',
      component: () => import('../views/admin/after-sale/index.vue'),
      meta: { requiresAuth: true, role: 'ADMIN' }
    },
    {
      path: '/admin/stats',
      name: 'admin-stats',
      component: () => import('../views/admin/stats/index.vue'),
      meta: { requiresAuth: true, role: 'ADMIN' }
    },
    {
      path: '/admin/site',
      name: 'admin-site',
      component: () => import('../views/admin/site/index.vue'),
      meta: { requiresAuth: true, role: 'ADMIN' }
    },
    {
      path: '/admin/users',
      name: 'admin-users',
      component: () => import('../views/admin/users/index.vue'),
      meta: { requiresAuth: true, role: 'ADMIN' }
    }
  ]
})

router.beforeEach((to) => {
  const userStore = useUserStore()
  const isAdmin = userStore.userInfo?.role === 'ADMIN'

  if (to.meta.forbidAdmin && isAdmin) {
    return '/admin/category'
  }

  if (!to.meta.requiresAuth) {
    return true
  }

  if (!userStore.token) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }

  if (to.meta.role && userStore.userInfo?.role !== to.meta.role) {
    ElMessage.error('权限不足，无法访问该页面')
    return isAdmin ? '/admin/category' : '/mall'
  }

  return true
})

export default router
