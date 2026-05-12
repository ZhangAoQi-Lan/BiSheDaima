<template>
  <div class="admin-page">
    <AdminNavbar />
    <div class="page-body">
      <div class="page-card">
        <div class="toolbar">
          <el-select v-model="filterStatus" clearable placeholder="筛选状态" style="width: 160px" @change="fetchList">
            <el-option label="待处理" value="PENDING" />
            <el-option label="处理中" value="PROCESSING" />
            <el-option label="已完成" value="COMPLETED" />
            <el-option label="已驳回" value="REJECTED" />
          </el-select>
          <el-button type="primary" @click="fetchList">刷新</el-button>
        </div>

        <el-table :data="records" v-loading="loading" border>
          <el-table-column prop="id" label="申请ID" width="90" />
          <el-table-column prop="orderId" label="订单号" width="100" />
          <el-table-column prop="username" label="用户" width="120" />
          <el-table-column prop="reason" label="原因" width="140" />
          <el-table-column prop="description" label="说明" min-width="220" show-overflow-tooltip />
          <el-table-column prop="orderAmount" label="订单金额" width="120" />
          <el-table-column label="状态" width="120">
            <template #default="{ row }">
              <el-tag :type="tagType(row.status)">{{ text(row.status) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="220">
            <template #default="{ row }">
              <el-select v-model="row._nextStatus" placeholder="更新状态" style="width: 120px">
                <el-option label="待处理" value="PENDING" />
                <el-option label="处理中" value="PROCESSING" />
                <el-option label="已完成" value="COMPLETED" />
                <el-option label="已驳回" value="REJECTED" />
              </el-select>
              <el-button type="primary" link @click="updateStatus(row)">保存</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { ElMessage } from 'element-plus'
import AdminNavbar from '@/components/AdminNavbar.vue'
import { getAdminAfterSales, updateAfterSaleStatus } from '@/api/admin'

const loading = ref(false)
const filterStatus = ref('')
const records = ref([])

const text = (status) => ({
  PENDING: '待处理',
  PROCESSING: '处理中',
  COMPLETED: '已完成',
  REJECTED: '已驳回'
}[status] || status)

const tagType = (status) => ({
  PENDING: 'warning',
  PROCESSING: 'primary',
  COMPLETED: 'success',
  REJECTED: 'info'
}[status] || 'info')

const fetchList = async () => {
  loading.value = true
  try {
    records.value = (await getAdminAfterSales(filterStatus.value)).map(item => ({
      ...item,
      _nextStatus: item.status
    }))
  } finally {
    loading.value = false
  }
}

const updateStatus = async (row) => {
  if (!row._nextStatus || row._nextStatus === row.status) return
  await updateAfterSaleStatus(row.id, row._nextStatus)
  ElMessage.success('售后状态已更新')
  fetchList()
}

onMounted(fetchList)
</script>

<style scoped>
.admin-page {
  min-height: 100vh;
  background: #f3f5f7;
}
.page-body {
  padding: 22px 28px;
}
.page-card {
  background: #fff;
  border-radius: 12px;
  padding: 18px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.04);
}
.toolbar {
  display: flex;
  justify-content: space-between;
  margin-bottom: 18px;
}
</style>
