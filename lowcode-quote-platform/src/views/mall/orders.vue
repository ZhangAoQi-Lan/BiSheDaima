<template>
  <div class="orders-page">
    <MallNavbar />

    <div class="page-body">
      <section class="hero-panel">
        <div>
          <div class="hero-kicker">Order Center</div>
          <h1>我的订单</h1>
          <p>按订单状态筛选，先看买了什么，收货信息放在详情里查看。</p>
        </div>
        <el-button type="primary" @click="fetchOrders">刷新订单</el-button>
      </section>

      <section class="filter-bar">
        <button
          v-for="option in statusOptions"
          :key="option.value"
          type="button"
          class="filter-chip"
          :class="{ active: activeStatus === option.value }"
          @click="activeStatus = option.value"
        >
          <span>{{ option.label }}</span>
          <strong>{{ getStatusCount(option.value) }}</strong>
        </button>
      </section>

      <el-empty
        v-if="!loading && filteredOrders.length === 0"
        :description="activeStatus === 'ALL' ? '还没有订单记录' : '当前状态下暂无订单'"
        class="empty-state"
      />

      <div v-else class="order-list">
        <el-card v-for="entry in filteredOrders" :key="entry.order.id" class="order-card" shadow="hover">
          <div class="order-header">
            <div>
              <div class="order-id">订单 #{{ entry.order.id }}</div>
              <div class="order-meta">{{ formatTime(entry.order.createTime) }}</div>
            </div>
            <div class="order-header-right">
              <el-tag :type="statusType(entry.order.status)" effect="dark" round>{{ statusText(entry.order.status) }}</el-tag>
              <strong class="order-price">¥{{ entry.order.totalPrice }}</strong>
            </div>
          </div>

          <div class="goods-box">
            <div class="goods-box-header">
              <span>商品明细</span>
              <em>{{ entry.itemCount }} 件商品</em>
            </div>

            <div v-if="entry.items.length" class="goods-list">
              <div v-for="item in entry.items" :key="item.id" class="goods-item">
                <div class="goods-main">
                  <strong>{{ item.productName }}</strong>
                  <span>¥{{ item.price }}</span>
                </div>
                <div class="goods-specs">
                  <span v-for="spec in formatItemSpecs(item.formData)" :key="spec">{{ spec }}</span>
                </div>
              </div>
            </div>

            <el-empty v-else description="暂无商品明细" :image-size="72" />
          </div>

          <div class="order-actions">
            <div class="action-left">
              <el-button link type="primary" @click="openDetail(entry.order.id)">查看详情</el-button>
              <el-button v-if="canCancel(entry.order)" link type="danger" @click="handleCancel(entry.order)">取消订单</el-button>
            </div>

            <div class="action-right">
              <el-button
                v-if="canApplyAfterSale(entry.order)"
                link
                type="warning"
                @click="openAfterSale(entry.order)"
              >
                申请售后
              </el-button>
              <el-tag v-else-if="hasAfterSale(entry.order.id)" type="warning" round>已发起售后</el-tag>
            </div>
          </div>
        </el-card>
      </div>
    </div>

    <el-dialog v-model="detailVisible" title="订单详情" width="920px">
      <div v-if="detailData.order" class="detail-wrap">
        <div class="detail-summary">
          <div class="summary-item">
            <span>订单号</span>
            <strong>#{{ detailData.order.id }}</strong>
          </div>
          <div class="summary-item">
            <span>订单状态</span>
            <strong>{{ statusText(detailData.order.status) }}</strong>
          </div>
          <div class="summary-item">
            <span>订单金额</span>
            <strong>¥{{ detailData.order.totalPrice }}</strong>
          </div>
          <div class="summary-item">
            <span>下单时间</span>
            <strong>{{ formatTime(detailData.order.createTime) }}</strong>
          </div>
          <div class="summary-item">
            <span>收货人</span>
            <strong>{{ detailData.order.receiverName || '未填写' }}</strong>
          </div>
          <div class="summary-item">
            <span>联系电话</span>
            <strong>{{ detailData.order.receiverPhone || '-' }}</strong>
          </div>
          <div class="summary-item full">
            <span>收货地址</span>
            <strong>{{ detailData.order.receiverAddress || '-' }}</strong>
          </div>
          <div class="summary-item full">
            <span>订单备注</span>
            <strong>{{ detailData.order.orderRemark || '无' }}</strong>
          </div>
          <div class="summary-item">
            <span>设计稿</span>
            <strong>{{ detailData.order.artworkName || '暂未上传' }}</strong>
          </div>
          <div class="summary-item">
            <span>物流单号</span>
            <strong>{{ detailData.order.trackingNo || '待发货后更新' }}</strong>
          </div>
          <div class="summary-item full">
            <span>生产备注</span>
            <strong>{{ detailData.order.productionNote || '暂无生产备注' }}</strong>
          </div>
          <div v-if="detailData.order.artworkUrl" class="summary-item full">
            <span>稿件链接</span>
            <a :href="detailData.order.artworkUrl" target="_blank" rel="noopener">{{ detailData.order.artworkUrl }}</a>
          </div>
        </div>

        <div class="timeline-box">
          <h3>履约进度</h3>
          <el-timeline>
            <el-timeline-item
              v-for="node in detailData.timeline || []"
              :key="node.id"
              :timestamp="formatTime(node.createTime)"
              :type="timelineType(node.status)"
            >
              <div class="timeline-title">{{ node.title }}</div>
              <div class="timeline-desc">{{ node.description }}</div>
            </el-timeline-item>
          </el-timeline>
        </div>

        <el-table :data="detailData.items || []" border>
          <el-table-column prop="productName" label="商品名称" min-width="180" />
          <el-table-column prop="price" label="价格" width="120" />
          <el-table-column label="配置详情" min-width="300">
            <template #default="{ row }">
              <div class="form-data">
                <div v-for="spec in formatItemSpecs(row.formData)" :key="spec">{{ spec }}</div>
              </div>
            </template>
          </el-table-column>
        </el-table>

        <div v-if="(detailData.afterSales || []).length" class="after-sale-box">
          <h3>售后记录</h3>
          <div v-for="item in detailData.afterSales" :key="item.id" class="after-sale-item">
            <span>{{ item.reason }}</span>
            <el-tag size="small" round>{{ afterSaleText(item.status) }}</el-tag>
          </div>
        </div>
      </div>
    </el-dialog>

    <el-dialog v-model="afterSaleVisible" title="申请售后" width="540px">
      <el-form label-position="top">
        <el-form-item label="售后原因">
          <el-select v-model="afterSaleForm.reason" placeholder="请选择">
            <el-option label="印刷问题" value="印刷问题" />
            <el-option label="发货问题" value="发货问题" />
            <el-option label="数量问题" value="数量问题" />
            <el-option label="其他问题" value="其他问题" />
          </el-select>
        </el-form-item>
        <el-form-item label="问题说明">
          <el-input
            v-model="afterSaleForm.description"
            type="textarea"
            :rows="4"
            placeholder="请补充具体情况，方便我们更快处理"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="afterSaleVisible = false">取消</el-button>
        <el-button type="primary" @click="submitAfterSale">提交申请</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import MallNavbar from '@/components/MallNavbar.vue'
import { cancelOrder, getOrders, getOrderDetail } from '@/api/order'
import { createAfterSale, getAfterSales } from '@/api/afterSale'

const loading = ref(false)
const orders = ref([])
const afterSales = ref([])
const detailVisible = ref(false)
const afterSaleVisible = ref(false)
const currentOrder = ref(null)
const activeStatus = ref('ALL')
const detailData = ref({ order: null, items: [], afterSales: [], timeline: [] })
const afterSaleForm = reactive({
  reason: '',
  description: ''
})

const statusOptions = [
  { label: '全部', value: 'ALL' },
  { label: '待处理', value: 'PENDING' },
  { label: '已处理', value: 'PROCESSED' },
  { label: '已发货', value: 'SHIPPED' },
  { label: '已完成', value: 'COMPLETED' },
  { label: '已取消', value: 'CANCELLED' }
]

const filteredOrders = computed(() => {
  if (activeStatus.value === 'ALL') {
    return orders.value
  }
  return orders.value.filter(entry => entry.order.status === activeStatus.value)
})

const normalizeOrderEntries = (payload = []) => payload.map((entry) => {
  if (entry?.order) {
    return {
      order: entry.order,
      items: Array.isArray(entry.items) ? entry.items : [],
      itemCount: Number(entry.itemCount ?? entry.items?.length ?? 0)
    }
  }

  return {
    order: entry,
    items: [],
    itemCount: 0
  }
})

const fetchOrders = async () => {
  loading.value = true
  try {
    const [orderResult, afterSaleResult] = await Promise.all([
      getOrders(),
      getAfterSales()
    ])
    orders.value = normalizeOrderEntries(orderResult)
    afterSales.value = afterSaleResult
  } finally {
    loading.value = false
  }
}

const getStatusCount = (status) => {
  if (status === 'ALL') {
    return orders.value.length
  }
  return orders.value.filter(entry => entry.order.status === status).length
}

const openDetail = async (id) => {
  detailData.value = await getOrderDetail(id)
  detailVisible.value = true
}

const canCancel = (order) => order.status === 'PENDING'

const canApplyAfterSale = (order) => {
  if (hasAfterSale(order.id)) return false
  return ['PENDING', 'PROCESSED', 'SHIPPED', 'COMPLETED'].includes(order.status)
}

const handleCancel = async (order) => {
  await ElMessageBox.confirm(
    `确认取消订单 #${order.id} 吗？取消后将无法继续处理该订单。`,
    '取消订单',
    { type: 'warning' }
  )
  await cancelOrder(order.id)
  ElMessage.success('订单已取消')
  await fetchOrders()
  if (detailVisible.value && detailData.value.order?.id === order.id) {
    detailData.value = await getOrderDetail(order.id)
  }
}

const openAfterSale = (order) => {
  currentOrder.value = order
  afterSaleForm.reason = ''
  afterSaleForm.description = ''
  afterSaleVisible.value = true
}

const submitAfterSale = async () => {
  if (!afterSaleForm.reason) {
    ElMessage.warning('请选择售后原因')
    return
  }

  await createAfterSale({
    orderId: currentOrder.value.id,
    reason: afterSaleForm.reason,
    description: afterSaleForm.description
  })
  ElMessage.success('售后申请已提交')
  afterSaleVisible.value = false
  await fetchOrders()
}

const hasAfterSale = (orderId) => afterSales.value.some(item => item.orderId === orderId)

const formatTime = (value) => {
  if (!value) return '-'
  const date = new Date(value)
  const pad = (num) => String(num).padStart(2, '0')
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}`
}

const formatItemSpecs = (formData = {}) => Object.entries(formData)
  .filter(([, value]) => value !== null && value !== undefined && value !== '')
  .filter(([, value]) => typeof value !== 'object' || Array.isArray(value))
  .map(([key, value]) => `${key}：${Array.isArray(value) ? value.join('、') : value}`)
  .slice(0, 6)

const statusText = (status) => ({
  PENDING: '待处理',
  PROCESSED: '已处理',
  SHIPPED: '已发货',
  COMPLETED: '已完成',
  CANCELLED: '已取消'
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

const afterSaleText = (status) => ({
  PENDING: '待处理',
  PROCESSING: '处理中',
  COMPLETED: '已完成',
  REJECTED: '已驳回'
}[status] || status)

onMounted(fetchOrders)
</script>

<style scoped>
.orders-page {
  min-height: 100vh;
  background: radial-gradient(circle at top, #fff7ed 0%, #f8fafc 22%, #f1f5f9 100%);
}

.page-body {
  max-width: 1180px;
  margin: 0 auto;
  padding: 28px 24px 64px;
}

.hero-panel {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 18px;
  padding: 28px 30px;
  border-radius: 24px;
  background: linear-gradient(135deg, #0f172a, #1e293b);
  color: #fff;
  box-shadow: 0 20px 40px rgba(15, 23, 42, 0.14);
  margin-bottom: 18px;
}

.hero-kicker {
  font-size: 11px;
  letter-spacing: 1.6px;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.65);
  margin-bottom: 10px;
}

.hero-panel h1 {
  margin: 0;
  font-size: 34px;
  font-weight: 800;
}

.hero-panel p {
  margin: 8px 0 0;
  font-size: 14px;
  color: rgba(255, 255, 255, 0.72);
}

.filter-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 22px;
}

.filter-chip {
  min-width: 108px;
  border: 1px solid #e2e8f0;
  background: rgba(255, 255, 255, 0.84);
  border-radius: 16px;
  padding: 12px 14px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  color: #475569;
  cursor: pointer;
  transition: all 0.2s ease;
}

.filter-chip strong {
  color: #0f172a;
}

.filter-chip:hover,
.filter-chip.active {
  border-color: rgba(234, 88, 12, 0.32);
  box-shadow: 0 14px 28px rgba(234, 88, 12, 0.08);
  color: #ea580c;
}

.filter-chip.active strong {
  color: #ea580c;
}

.empty-state {
  padding-top: 48px;
}

.order-list {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.order-card {
  border-radius: 22px;
  border: 1px solid rgba(226, 232, 240, 0.8);
  overflow: hidden;
}

.order-header,
.order-header-right,
.order-actions,
.after-sale-item,
.goods-main,
.goods-box-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.action-left,
.action-right {
  display: flex;
  align-items: center;
  gap: 14px;
}

.order-id {
  font-size: 20px;
  font-weight: 800;
  color: #0f172a;
}

.order-meta {
  margin-top: 6px;
  color: #64748b;
  font-size: 13px;
}

.order-price {
  font-size: 24px;
  color: #ea580c;
}

.goods-box {
  margin: 18px 0;
  padding: 16px 18px;
  border-radius: 18px;
  background: linear-gradient(180deg, #fbfdff, #f8fafc);
  border: 1px solid #e2e8f0;
}

.goods-box-header {
  margin-bottom: 12px;
  color: #0f172a;
  font-weight: 700;
}

.goods-box-header em {
  font-style: normal;
  color: #64748b;
  font-size: 13px;
  font-weight: 500;
}

.goods-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.goods-item {
  padding: 14px 16px;
  border-radius: 16px;
  background: #fff;
  border: 1px solid #e9eef5;
}

.goods-main strong {
  color: #0f172a;
  font-size: 15px;
}

.goods-main span {
  color: #ea580c;
  font-weight: 700;
}

.goods-specs {
  margin-top: 10px;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.goods-specs span {
  padding: 6px 10px;
  border-radius: 999px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  color: #475569;
  font-size: 12px;
}

.order-actions {
  border-top: 1px solid #edf2f7;
  padding-top: 14px;
}

.detail-wrap {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.detail-summary {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
}

.summary-item {
  padding: 14px 16px;
  border-radius: 16px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.summary-item.full {
  grid-column: 1 / -1;
}

.summary-item span {
  font-size: 12px;
  color: #64748b;
}

.summary-item strong {
  font-size: 15px;
  color: #0f172a;
}

.summary-item a {
  color: #2563eb;
  font-size: 13px;
  word-break: break-all;
}

.timeline-box {
  border-radius: 16px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  padding: 16px 18px 4px;
}

.timeline-box h3 {
  margin: 0 0 14px;
  color: #0f172a;
  font-size: 16px;
}

.timeline-title {
  font-weight: 800;
  color: #0f172a;
}

.timeline-desc {
  margin-top: 4px;
  font-size: 13px;
  color: #64748b;
}

.form-data {
  font-size: 12px;
  line-height: 1.8;
  color: #475569;
}

.after-sale-box {
  border-radius: 16px;
  background: #fffaf0;
  border: 1px solid #fde68a;
  padding: 16px 18px;
}

.after-sale-box h3 {
  margin: 0 0 10px;
  color: #92400e;
}

.after-sale-item {
  padding: 8px 0;
  border-bottom: 1px dashed rgba(146, 64, 14, 0.18);
}

.after-sale-item:last-child {
  border-bottom: none;
}

@media (max-width: 900px) {
  .hero-panel,
  .order-header,
  .order-actions,
  .goods-main {
    flex-direction: column;
    align-items: flex-start;
  }

  .detail-summary {
    grid-template-columns: 1fr;
  }

  .filter-chip {
    min-width: calc(50% - 6px);
  }
}

@media (max-width: 640px) {
  .page-body {
    padding: 20px 16px 56px;
  }

  .hero-panel {
    padding: 22px 20px;
  }

  .hero-panel h1 {
    font-size: 28px;
  }

  .filter-chip {
    width: 100%;
    min-width: 100%;
  }
}
</style>
