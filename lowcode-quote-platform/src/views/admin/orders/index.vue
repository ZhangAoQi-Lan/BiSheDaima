<template>
  <div class="admin-page">
    <AdminNavbar />

    <div class="page-body">
      <div class="page-card">
        <div class="card-header">
          <div class="header-left">
            <h3><el-icon :size="18"><Document /></el-icon> 订单管理</h3>
            <span class="subtitle">共 {{ total }} 笔订单</span>
          </div>

          <div class="header-right">
            <el-select
              v-model="filterStatus"
              placeholder="订单状态"
              clearable
              style="width: 140px"
              @change="fetchOrders"
            >
              <el-option label="待处理" value="PENDING" />
              <el-option label="已处理" value="PROCESSED" />
              <el-option label="已发货" value="SHIPPED" />
              <el-option label="已完成" value="COMPLETED" />
              <el-option label="用户已取消" value="CANCELLED" />
            </el-select>

            <el-input
              v-model="keyword"
              placeholder="搜索用户名"
              clearable
              :prefix-icon="Search"
              style="width: 220px"
              @keyup.enter="fetchOrders"
              @clear="fetchOrders"
            />

            <el-button type="primary" :icon="Search" @click="fetchOrders">搜索</el-button>
          </div>
        </div>

        <el-table
          :data="orders"
          v-loading="loading"
          stripe
          style="width: 100%"
          empty-text="暂无订单数据"
        >
          <el-table-column prop="id" label="订单号" width="90" align="center">
            <template #default="{ row }">
              <span class="order-id-text">#{{ row.id }}</span>
            </template>
          </el-table-column>

          <el-table-column prop="username" label="下单用户" min-width="140">
            <template #default="{ row }">
              <div class="user-cell">
                <el-avatar :size="24" icon="UserFilled" />
                <span>{{ row.username }}</span>
              </div>
            </template>
          </el-table-column>

          <el-table-column prop="status" label="状态" width="120" align="center">
            <template #default="{ row }">
              <el-tag :type="statusType(row.status)" effect="dark" size="small" round>
                {{ statusLabel(row.status) }}
              </el-tag>
            </template>
          </el-table-column>

          <el-table-column prop="itemCount" label="产品数" width="90" align="center" />

          <el-table-column prop="totalPrice" label="总价" width="130" align="right">
            <template #default="{ row }">
              <span class="price-text">¥{{ row.totalPrice }}</span>
            </template>
          </el-table-column>

          <el-table-column prop="createTime" label="提交时间" width="170" align="center">
            <template #default="{ row }">
              <span class="time-text">{{ formatTime(row.createTime) }}</span>
            </template>
          </el-table-column>

          <el-table-column label="操作" width="200" align="center" fixed="right">
            <template #default="{ row }">
              <div class="table-actions">
                <el-button link type="primary" size="small" @click="showDetail(row.id)">
                  <el-icon :size="14"><View /></el-icon>详情
                </el-button>

                <el-button
                  v-if="hasNextStatuses(row.status)"
                  link
                  type="warning"
                  size="small"
                  @click="openStatusEdit(row)"
                >
                  <el-icon :size="14"><Edit /></el-icon>修改状态
                </el-button>

                <el-tag v-else-if="row.status === 'CANCELLED'" type="info" size="small">用户已取消</el-tag>
                <el-tag v-else type="success" size="small">状态已结束</el-tag>
              </div>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </div>

    <el-dialog v-model="dialogVisible" title="订单详情" width="700px" :close-on-click-modal="false">
      <template v-if="detailOrder">
        <div class="detail-summary">
          <div class="summary-row">
            <span class="s-label">订单号</span>
            <span class="s-value">#{{ detailOrder.id }}</span>
          </div>
          <div class="summary-row">
            <span class="s-label">下单用户</span>
            <span class="s-value">{{ detailUsername }}</span>
          </div>
          <div class="summary-row">
            <span class="s-label">订单状态</span>
            <span class="s-value">
              <el-tag :type="statusType(detailOrder.status)" effect="dark" size="small" round>
                {{ statusLabel(detailOrder.status) }}
              </el-tag>
            </span>
          </div>
          <div class="summary-row">
            <span class="s-label">订单总价</span>
            <span class="s-value price">¥{{ detailOrder.totalPrice }}</span>
          </div>
          <div class="summary-row">
            <span class="s-label">提交时间</span>
            <span class="s-value">{{ formatTime(detailOrder.createTime) }}</span>
          </div>
          <div v-if="detailOrder.status === 'CANCELLED'" class="summary-row">
            <span class="s-label">取消来源</span>
            <span class="s-value cancel-source">用户主动取消</span>
          </div>
          <div class="summary-row">
            <span class="s-label">设计稿</span>
            <span class="s-value">{{ detailOrder.artworkName || '未登记' }}</span>
          </div>
          <div class="summary-row">
            <span class="s-label">物流单号</span>
            <span class="s-value">{{ detailOrder.trackingNo || '待填写' }}</span>
          </div>
          <div class="summary-row full-row">
            <span class="s-label">生产备注</span>
            <span class="s-value">{{ detailOrder.productionNote || '暂无' }}</span>
          </div>
          <div v-if="detailOrder.artworkUrl" class="summary-row full-row">
            <span class="s-label">稿件链接</span>
            <a :href="detailOrder.artworkUrl" target="_blank" rel="noopener" class="detail-link">{{ detailOrder.artworkUrl }}</a>
          </div>
        </div>

        <el-divider>履约时间线</el-divider>

        <el-timeline class="order-timeline">
          <el-timeline-item
            v-for="node in detailTimeline"
            :key="node.id"
            :timestamp="formatTime(node.createTime)"
            :type="timelineType(node.status)"
          >
            <div class="timeline-title">{{ node.title }}</div>
            <div class="timeline-desc">{{ node.description }}</div>
          </el-timeline-item>
        </el-timeline>

        <el-divider>生产与稿件信息</el-divider>

        <el-form label-position="top" class="production-form">
          <el-row :gutter="12">
            <el-col :span="12">
              <el-form-item label="设计稿名称">
                <el-input v-model="productionForm.artworkName" placeholder="例如：名片设计稿.pdf" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="物流单号">
                <el-input v-model="productionForm.trackingNo" placeholder="发货后填写" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-form-item label="设计稿链接">
            <el-input v-model="productionForm.artworkUrl" placeholder="文件地址、网盘链接或 MinIO URL" />
          </el-form-item>
          <el-form-item label="生产备注">
            <el-input
              v-model="productionForm.productionNote"
              type="textarea"
              :rows="3"
              placeholder="例如：客户要求色彩偏暖，覆膜后再发货"
            />
          </el-form-item>
          <div class="production-actions">
            <el-button type="primary" :loading="productionSaving" @click="saveProductionInfo">保存生产信息</el-button>
          </div>
        </el-form>

        <el-divider>订单明细 ({{ detailItems.length }} 项)</el-divider>

        <div class="detail-items">
          <div v-for="(item, idx) in detailItems" :key="item.id" class="detail-order-item">
            <div class="item-index-badge">{{ idx + 1 }}</div>
            <div class="item-body">
              <div class="item-head">
                <span class="item-name">{{ item.productName }}</span>
                <span class="item-price">¥{{ item.price }}</span>
              </div>
              <div class="item-config">
                <template v-for="(val, key) in item.formData" :key="key">
                  <template v-if="isPlainObject(val)">
                    <div class="config-group-label">{{ key }}</div>
                    <div class="config-chips">
                      <span v-for="(subVal, subKey) in val" :key="`${key}_${subKey}`" class="config-chip">
                        <span class="chip-key">{{ subKey }}</span>
                        <span class="chip-sep">:</span>
                        <span class="chip-val">{{ Array.isArray(subVal) ? subVal.join('、') : subVal }}</span>
                      </span>
                    </div>
                  </template>
                  <div v-else class="direct-field">
                    <span class="field-key">{{ key }}</span>
                    <span class="field-val">{{ Array.isArray(val) ? val.join('、') : val }}</span>
                  </div>
                </template>
              </div>
            </div>
          </div>
        </div>
      </template>

      <template #footer>
        <el-button @click="dialogVisible = false">关闭</el-button>
        <el-button
          v-if="detailOrder && hasNextStatuses(detailOrder.status)"
          type="warning"
          :icon="Edit"
          @click="dialogVisible = false; openStatusEdit(detailOrder)"
        >
          修改状态
        </el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="statusDialogVisible" title="修改订单状态" width="460px" :close-on-click-modal="false">
      <div class="status-edit-body" v-if="editingOrder">
        <div class="status-current">
          <span class="edit-label">订单号</span>
          <span class="edit-value">#{{ editingOrder.id }}</span>
        </div>

        <div class="status-current">
          <span class="edit-label">当前状态</span>
          <span class="edit-value">
            <el-tag :type="statusType(editingOrder.status)" effect="dark" size="small" round>
              {{ statusLabel(editingOrder.status) }}
            </el-tag>
          </span>
        </div>

        <div v-if="editingOrder.status === 'CANCELLED'" class="status-tip danger">
          该订单已由用户取消，不能再执行发货或完成等后续操作。
        </div>

        <div v-else-if="!availableStatusOptions.length" class="status-tip">
          当前订单已经处于流程终态，无需再修改。
        </div>

        <template v-else>
          <el-divider />
          <div class="status-select-row">
            <span class="edit-label">新状态</span>
            <el-select v-model="newStatus" placeholder="请选择新状态" style="width: 220px">
              <el-option
                v-for="s in availableStatusOptions"
                :key="s.value"
                :label="s.label"
                :value="s.value"
              />
            </el-select>
          </div>
          <el-form label-position="top" class="status-note-form">
            <el-form-item label="流转备注">
              <el-input
                v-model="statusNote"
                type="textarea"
                :rows="3"
                placeholder="例如：已核对设计稿，进入生产排期"
              />
            </el-form-item>
          </el-form>
        </template>
      </div>

      <template #footer>
        <el-button @click="statusDialogVisible = false">取消</el-button>
        <el-button
          type="primary"
          :loading="statusSaving"
          :disabled="!availableStatusOptions.length"
          @click="confirmStatusChange"
        >
          确认修改
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { Document, Edit, Search, View } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getAdminOrderDetail, getAdminOrders, updateOrderProduction, updateOrderStatus } from '@/api/admin'
import AdminNavbar from '@/components/AdminNavbar.vue'

const orders = ref([])
const loading = ref(false)
const keyword = ref('')
const filterStatus = ref('')
const total = ref(0)

const dialogVisible = ref(false)
const detailOrder = ref(null)
const detailItems = ref([])
const detailUsername = ref('')
const detailTimeline = ref([])

const statusDialogVisible = ref(false)
const editingOrder = ref(null)
const newStatus = ref('')
const statusNote = ref('')
const statusSaving = ref(false)
const productionSaving = ref(false)
const productionForm = ref({
  artworkName: '',
  artworkUrl: '',
  productionNote: '',
  trackingNo: ''
})

const transitionMap = {
  PENDING: [
    { label: '已处理', value: 'PROCESSED' },
    { label: '用户已取消', value: 'CANCELLED' }
  ],
  PROCESSED: [
    { label: '已发货', value: 'SHIPPED' },
    { label: '已完成', value: 'COMPLETED' }
  ],
  SHIPPED: [
    { label: '已完成', value: 'COMPLETED' }
  ],
  COMPLETED: [],
  CANCELLED: []
}

const availableStatusOptions = computed(() => {
  if (!editingOrder.value) return []
  return transitionMap[editingOrder.value.status] || []
})

const statusLabel = (status) => ({
  PENDING: '待处理',
  PROCESSED: '已处理',
  SHIPPED: '已发货',
  COMPLETED: '已完成',
  CANCELLED: '用户已取消'
}[status] || status)

const statusType = (status) => ({
  PENDING: 'warning',
  PROCESSED: 'primary',
  SHIPPED: 'success',
  COMPLETED: 'success',
  CANCELLED: 'info'
}[status] || 'info')

const timelineType = (status) => ({
  PENDING: 'warning',
  PROCESSED: 'primary',
  SHIPPED: 'success',
  COMPLETED: 'success',
  CANCELLED: 'info'
}[status] || 'primary')

const formatTime = (value) => {
  if (!value) return '-'
  const date = new Date(value)
  const pad = (num) => String(num).padStart(2, '0')
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}`
}

const isPlainObject = (value) => value !== null && typeof value === 'object' && !Array.isArray(value)
const hasNextStatuses = (status) => (transitionMap[status] || []).length > 0

const fetchOrders = async () => {
  loading.value = true
  try {
    const params = {}
    if (filterStatus.value) params.status = filterStatus.value
    if (keyword.value) params.keyword = keyword.value
    orders.value = (await getAdminOrders(params)) || []
    total.value = orders.value.length
  } catch {
    orders.value = []
  } finally {
    loading.value = false
  }
}

const showDetail = async (orderId) => {
  const res = await getAdminOrderDetail(orderId)
  detailOrder.value = res.order
  detailItems.value = res.items || []
  detailUsername.value = res.username || '匿名用户'
  detailTimeline.value = res.timeline || []
  productionForm.value = {
    artworkName: res.order?.artworkName || '',
    artworkUrl: res.order?.artworkUrl || '',
    productionNote: res.order?.productionNote || '',
    trackingNo: res.order?.trackingNo || ''
  }
  dialogVisible.value = true
}

const openStatusEdit = (order) => {
  editingOrder.value = order
  newStatus.value = ''
  statusNote.value = ''
  statusDialogVisible.value = true
}

const confirmStatusChange = async () => {
  if (!newStatus.value) {
    ElMessage.warning('请选择新状态')
    return
  }

  await ElMessageBox.confirm(
    `确认将订单 #${editingOrder.value.id} 从“${statusLabel(editingOrder.value.status)}”修改为“${statusLabel(newStatus.value)}”吗？`,
    '修改确认',
    { type: 'warning' }
  )

  statusSaving.value = true
  try {
    await updateOrderStatus(editingOrder.value.id, newStatus.value, statusNote.value)
    ElMessage.success('订单状态已更新')
    statusDialogVisible.value = false
    await fetchOrders()

    if (detailOrder.value && detailOrder.value.id === editingOrder.value.id) {
      const res = await getAdminOrderDetail(editingOrder.value.id)
      detailOrder.value = res.order
      detailTimeline.value = res.timeline || []
    }
  } finally {
    statusSaving.value = false
  }
}

const saveProductionInfo = async () => {
  if (!detailOrder.value) return
  productionSaving.value = true
  try {
    await updateOrderProduction(detailOrder.value.id, productionForm.value)
    ElMessage.success('生产信息已保存')
    await showDetail(detailOrder.value.id)
  } finally {
    productionSaving.value = false
  }
}

onMounted(fetchOrders)
</script>

<style scoped>
.admin-page {
  min-height: 100vh;
  background: #f0f2f5;
}

.page-body {
  padding: 22px 28px;
}

.page-card {
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
  overflow: hidden;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 18px 22px;
  border-bottom: 1px solid #ebeef5;
  flex-wrap: wrap;
  gap: 12px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-left h3 {
  margin: 0;
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 17px;
  color: #303133;
}

.subtitle {
  font-size: 13px;
  color: #909399;
}

.header-right {
  display: flex;
  gap: 8px;
  align-items: center;
}

.order-id-text {
  font-weight: 700;
  color: #303133;
}

.user-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}

.price-text {
  font-weight: 700;
  color: #f72a44;
  font-size: 14px;
}

.time-text {
  color: #909399;
  font-size: 13px;
}

.table-actions {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.detail-summary {
  background: #f8f9fc;
  border-radius: 8px;
  padding: 16px 20px;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  padding: 6px 0;
  gap: 16px;
}

.summary-row .s-label {
  color: #909399;
  font-size: 13px;
}

.summary-row .s-value {
  color: #303133;
  font-weight: 600;
  font-size: 14px;
}

.summary-row .s-value.price {
  color: #f72a44;
  font-size: 18px;
  font-weight: 800;
}

.summary-row .s-value.cancel-source {
  color: #909399;
}

.summary-row.full-row {
  align-items: flex-start;
}

.detail-link {
  color: #2563eb;
  font-size: 13px;
  word-break: break-all;
  text-align: right;
}

.order-timeline {
  padding: 4px 0 0;
}

.timeline-title {
  font-weight: 800;
  color: #303133;
}

.timeline-desc {
  margin-top: 4px;
  color: #606266;
  font-size: 13px;
}

.production-form {
  background: #f8f9fc;
  border: 1px solid #ebeef5;
  border-radius: 10px;
  padding: 14px 16px 10px;
}

.production-actions {
  display: flex;
  justify-content: flex-end;
}

.detail-items {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.detail-order-item {
  background: #f8f9fc;
  border: 1px solid #ebeef5;
  border-radius: 10px;
  padding: 14px 16px;
  display: flex;
  gap: 14px;
}

.item-index-badge {
  width: 26px;
  height: 26px;
  border-radius: 8px;
  background: linear-gradient(135deg, #409eff, #337ecc);
  color: #fff;
  font-size: 12px;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  margin-top: 2px;
}

.item-body {
  flex: 1;
  min-width: 0;
}

.item-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.item-name {
  font-size: 15px;
  font-weight: 700;
  color: #303133;
}

.item-price {
  font-size: 17px;
  font-weight: 800;
  color: #f72a44;
  flex-shrink: 0;
  margin-left: 16px;
}

.item-config {
  font-size: 13px;
  color: #606266;
}

.config-group-label {
  font-size: 12px;
  font-weight: 700;
  color: #606266;
  margin: 8px 0 6px;
}

.config-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.config-chip {
  display: inline-flex;
  align-items: center;
  background: #e8edf3;
  border-radius: 6px;
  padding: 4px 10px;
  font-size: 12px;
  white-space: nowrap;
}

.chip-key {
  color: #909399;
  font-weight: 500;
}

.chip-sep {
  color: #c0c4cc;
  margin: 0 4px;
}

.chip-val {
  color: #303133;
  font-weight: 600;
}

.direct-field {
  display: flex;
  align-items: baseline;
  padding: 5px 0;
  border-bottom: 1px dashed #ebeef5;
  gap: 10px;
}

.direct-field:last-child {
  border-bottom: none;
}

.field-key {
  color: #909399;
  flex-shrink: 0;
  font-weight: 500;
}

.field-val {
  color: #303133;
  font-weight: 600;
}

.status-edit-body {
  padding: 4px 0;
}

.status-current,
.status-select-row {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 8px 0;
}

.edit-label {
  color: #909399;
  font-size: 13px;
  flex-shrink: 0;
  min-width: 70px;
}

.edit-value {
  color: #303133;
  font-weight: 600;
  font-size: 14px;
}

.status-tip {
  margin-top: 12px;
  padding: 10px 12px;
  border-radius: 8px;
  background: #f4f6f8;
  color: #606266;
  font-size: 13px;
  line-height: 1.6;
}

.status-tip.danger {
  background: #fff1f0;
  color: #cf1322;
}

.status-note-form {
  margin-top: 12px;
}
</style>
