<template>
  <div class="admin-navbar">
    <div class="nav-left">
      <div class="logo" @click="router.push('/admin/category')">
        <el-icon :size="22"><Setting /></el-icon>
        <span class="logo-text">印刷报价管理后台</span>
      </div>
      <el-menu
        mode="horizontal"
        :default-active="activeMenu"
        :ellipsis="false"
        class="nav-menu"
        @select="handleMenuSelect"
      >
        <el-menu-item index="/admin/category">
          <el-icon><Grid /></el-icon>
          <span>产品管理</span>
        </el-menu-item>
        <el-menu-item index="/admin/material">
          <el-icon><Box /></el-icon>
          <span>材料中心</span>
        </el-menu-item>
        <el-menu-item index="/admin/orders">
          <el-icon><Document /></el-icon>
          <span>订单管理</span>
        </el-menu-item>
        <el-menu-item index="/admin/after-sale">
          <el-icon><Service /></el-icon>
          <span>售后管理</span>
        </el-menu-item>
        <el-menu-item index="/admin/stats">
          <el-icon><DataAnalysis /></el-icon>
          <span>数据统计</span>
        </el-menu-item>
        <el-menu-item index="/admin/site">
          <el-icon><EditPen /></el-icon>
          <span>站点内容</span>
        </el-menu-item>
        <el-menu-item index="/admin/users">
          <el-icon><User /></el-icon>
          <span>用户管理</span>
        </el-menu-item>
      </el-menu>
    </div>
    <div class="nav-right">
      <el-button :icon="Link" @click="router.push('/mall')" text>
        返回商城
      </el-button>
      <el-dropdown>
        <span class="user-area">
          <el-avatar :size="28" icon="UserFilled" />
          <span class="username">{{ userStore.userInfo?.username || '管理员' }}</span>
          <el-icon :size="12"><ArrowDown /></el-icon>
        </span>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item @click="handleLogout">
              <el-icon><SwitchButton /></el-icon>
              退出登录
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  Setting, Grid, Box, Document, User, Link,
  ArrowDown, SwitchButton, Service, DataAnalysis, EditPen
} from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const activeMenu = computed(() => {
  const path = route.path
  if (path.startsWith('/admin/material')) return '/admin/material'
  if (path.startsWith('/admin/orders')) return '/admin/orders'
  if (path.startsWith('/admin/after-sale')) return '/admin/after-sale'
  if (path.startsWith('/admin/stats')) return '/admin/stats'
  if (path.startsWith('/admin/site')) return '/admin/site'
  if (path.startsWith('/admin/users')) return '/admin/users'
  return '/admin/category'
})

const handleMenuSelect = (index) => {
  router.push(index)
}

const handleLogout = () => {
  userStore.clearAuth()
  router.push('/login')
}
</script>

<style scoped>
.admin-navbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 52px;
  padding: 0 24px;
  background: #2b333e;
  color: #e0e4e8;
  user-select: none;
  position: sticky;
  top: 0;
  z-index: 1000;
  box-shadow: 0 1px 6px rgba(0, 0, 0, 0.15);
}
.nav-left {
  display: flex;
  align-items: center;
  gap: 8px;
}
.logo {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding-right: 16px;
  margin-right: 4px;
  border-right: 1px solid rgba(255, 255, 255, 0.12);
  flex-shrink: 0;
}
.logo-text {
  font-size: 15px;
  font-weight: 700;
  color: #fff;
  letter-spacing: 0.5px;
}
.nav-menu {
  background: transparent !important;
  border-bottom: none !important;
  height: 52px;
}
.nav-menu :deep(.el-menu-item) {
  height: 52px;
  line-height: 52px;
  color: #b0b8c1;
  border-bottom: 2px solid transparent;
  font-size: 13px;
  padding: 0 14px;
  transition: color 0.2s, border-color 0.2s;
}
.nav-menu :deep(.el-menu-item:hover) {
  color: #fff;
  background: rgba(255, 255, 255, 0.06);
}
.nav-menu :deep(.el-menu-item.is-active) {
  color: #fff;
  border-bottom-color: #409eff;
  font-weight: 600;
}
.nav-right {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-shrink: 0;
}
.nav-right .el-button--text {
  color: #b0b8c1;
}
.nav-right .el-button--text:hover {
  color: #fff;
}
.user-area {
  display: flex;
  align-items: center;
  gap: 7px;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 6px;
  color: #c8cdd3;
  transition: background 0.2s;
}
.user-area:hover {
  background: rgba(255, 255, 255, 0.08);
}
.username {
  font-size: 13px;
  font-weight: 500;
}
</style>
