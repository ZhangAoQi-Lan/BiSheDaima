<template>
  <div class="admin-page">
    <AdminNavbar />
    <div class="page-body">
      <div class="card-grid">
        <div class="stat-card" v-for="card in cards" :key="card.label">
          <div class="stat-label">{{ card.label }}</div>
          <div class="stat-value">{{ card.value }}</div>
        </div>
      </div>

      <div class="panel-grid">
        <el-card class="panel-card trend-card">
          <template #header>近 7 日订单趋势</template>
          <div class="trend-list">
            <div v-for="item in trendList" :key="item.date" class="trend-row">
              <div class="trend-date">{{ shortDate(item.date) }}</div>
              <div class="trend-main">
                <div class="trend-track">
                  <div class="trend-fill" :style="{ width: `${trendPercent(item.orderCount)}%` }" />
                </div>
                <div class="trend-meta">
                  <span>{{ item.orderCount }} 单</span>
                  <strong>￥{{ item.amount }}</strong>
                </div>
              </div>
            </div>
          </div>
        </el-card>

        <el-card class="panel-card">
          <template #header>订单状态分布</template>
          <div class="bar-list">
            <div v-for="item in statusList" :key="item.status" class="bar-row">
              <span class="bar-label">{{ statusText(item.status) }}</span>
              <div class="bar-track">
                <div class="bar-fill" :style="{ width: `${statusPercent(item.total)}%` }" />
              </div>
              <span class="bar-value">{{ item.total }}</span>
            </div>
          </div>
        </el-card>

        <el-card class="panel-card">
          <template #header>热销商品</template>
          <el-table :data="productList" size="small" border>
            <el-table-column prop="name" label="商品" />
            <el-table-column prop="total" label="订单项数" width="120" />
          </el-table>
        </el-card>

        <el-card class="panel-card">
          <template #header>热门分类</template>
          <el-table :data="categoryList" size="small" border>
            <el-table-column prop="name" label="分类" />
            <el-table-column prop="total" label="报价次数" width="120" />
          </el-table>
        </el-card>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import AdminNavbar from '@/components/AdminNavbar.vue'
import {
  getAdminStatsOverview,
  getAdminStatsStatus,
  getAdminStatsProducts,
  getAdminStatsCategories,
  getAdminStatsTrend
} from '@/api/admin'

const overview = ref({
  quoteCount: 0,
  orderCount: 0,
  orderAmount: 0,
  userCount: 0,
  afterSaleCount: 0
})
const statusList = ref([])
const productList = ref([])
const categoryList = ref([])
const trendList = ref([])

const cards = computed(() => [
  { label: '报价次数', value: overview.value.quoteCount },
  { label: '订单数量', value: overview.value.orderCount },
  { label: '订单总金额', value: `￥${overview.value.orderAmount}` },
  { label: '用户数量', value: overview.value.userCount },
  { label: '售后申请', value: overview.value.afterSaleCount }
])

const maxStatus = computed(() => Math.max(...statusList.value.map(item => Number(item.total) || 0), 1))
const statusPercent = (total) => (Number(total) / maxStatus.value) * 100
const maxTrend = computed(() => Math.max(...trendList.value.map(item => Number(item.orderCount) || 0), 1))
const trendPercent = (total) => (Number(total) / maxTrend.value) * 100
const shortDate = (date) => String(date || '').slice(5)

const statusText = (status) => ({
  PENDING: '待处理',
  PROCESSED: '已处理',
  SHIPPED: '已发货',
  COMPLETED: '已完成',
  CANCELLED: '已取消'
}[status] || status)

const fetchAll = async () => {
  overview.value = await getAdminStatsOverview()
  statusList.value = await getAdminStatsStatus()
  productList.value = await getAdminStatsProducts()
  categoryList.value = await getAdminStatsCategories()
  trendList.value = await getAdminStatsTrend()
}

onMounted(fetchAll)
</script>

<style scoped>
.admin-page {
  min-height: 100vh;
  background: #f3f5f7;
}
.page-body {
  padding: 22px 28px;
}
.card-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 16px;
  margin-bottom: 20px;
}
.stat-card {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.04);
}
.stat-label {
  font-size: 13px;
  color: #909399;
}
.stat-value {
  margin-top: 10px;
  font-size: 28px;
  font-weight: 800;
  color: #303133;
}
.panel-grid {
  display: grid;
  grid-template-columns: 1.2fr 1fr 1fr;
  gap: 16px;
}
.panel-card {
  border-radius: 12px;
}
.trend-card {
  grid-column: 1 / -1;
}
.trend-list {
  display: grid;
  grid-template-columns: repeat(7, minmax(0, 1fr));
  gap: 12px;
}
.trend-row {
  min-width: 0;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
  background: #fbfdff;
  padding: 12px;
}
.trend-date {
  font-size: 12px;
  color: #909399;
  margin-bottom: 10px;
}
.trend-main {
  display: flex;
  flex-direction: column;
  gap: 9px;
}
.trend-track {
  height: 10px;
  border-radius: 999px;
  background: #eef2f6;
  overflow: hidden;
}
.trend-fill {
  height: 100%;
  min-width: 8px;
  border-radius: 999px;
  background: linear-gradient(90deg, #f97316, #409eff);
}
.trend-meta {
  display: flex;
  justify-content: space-between;
  gap: 8px;
  font-size: 12px;
  color: #606266;
}
.trend-meta strong {
  color: #303133;
}
.bar-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}
.bar-row {
  display: grid;
  grid-template-columns: 90px 1fr 60px;
  gap: 10px;
  align-items: center;
}
.bar-label,
.bar-value {
  font-size: 13px;
  color: #606266;
}
.bar-track {
  height: 12px;
  border-radius: 999px;
  background: #eef2f6;
  overflow: hidden;
}
.bar-fill {
  height: 100%;
  border-radius: 999px;
  background: linear-gradient(90deg, #409eff, #67c23a);
}
@media (max-width: 1200px) {
  .card-grid,
  .panel-grid,
  .trend-list {
    grid-template-columns: 1fr 1fr;
  }
}
</style>
