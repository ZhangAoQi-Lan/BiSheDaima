<template>
  <div class="orders-page">
    <MallNavbar />

    <!-- ====== Hero 区域 ====== -->
    <section class="hero-section">
      <div class="hero-grid" />
      <div class="hero-overlay" />
      <div class="hero-content">
        <h1 class="hero-title">我的订单中心</h1>
        <p class="hero-subtitle">管理您的印刷预约与订单进度</p>
        <div class="search-container">
          <div class="search-wrap" :class="{ focused: searchFocused }">
            <el-icon :size="20" class="search-icon"><Search /></el-icon>
            <input
              ref="searchInput"
              v-model="searchQuery"
              class="search-field"
              placeholder="输入订单号快速检索..."
              @focus="searchFocused = true"
              @blur="searchFocused = false"
            />
            <el-button
              v-if="searchQuery"
              link
              class="search-clear"
              @click="searchQuery = ''"
            >
              <el-icon :size="16"><Close /></el-icon>
            </el-button>
          </div>
        </div>
      </div>
    </section>

    <!-- ====== 主体内容 ====== -->
    <div class="orders-body">
      <!-- 统计卡片 — 浮窗悬浮 -->
      <div class="stats-row" v-if="!loading && orders.length > 0">
        <div class="stat-card">
          <div class="stat-icon total">
            <el-icon :size="22"><Document /></el-icon>
          </div>
          <div class="stat-body">
            <span class="stat-num">{{ orders.length }}</span>
            <span class="stat-label">全部订单</span>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon pending">
            <el-icon :size="22"><Clock /></el-icon>
          </div>
          <div class="stat-body">
            <span class="stat-num">{{ pendingCount }}</span>
            <span class="stat-label">待处理</span>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon amount">
            <el-icon :size="22"><Money /></el-icon>
          </div>
          <div class="stat-body">
            <span class="stat-num">¥ {{ totalSpent }}</span>
            <span class="stat-label">累计金额</span>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon refresh-card">
            <el-icon :size="22" class="refresh-icon" :class="{ spinning: loading }" @click="fetchOrders"><Refresh /></el-icon>
          </div>
          <div class="stat-body">
            <span class="stat-num refresh-label">刷新</span>
            <span class="stat-label">获取最新状态</span>
          </div>
        </div>
      </div>

      <!-- 状态切换 Tabs -->
      <div class="status-tabs" v-if="orders.length > 0">
        <button
          v-for="tab in statusTabs"
          :key="tab.value"
          class="status-tab"
          :class="{ active: filterTab === tab.value }"
          @click="filterTab = tab.value"
        >
          {{ tab.label }}
          <span class="tab-count" v-if="tab.value && statusCount(tab.value)">{{ statusCount(tab.value) }}</span>
        </button>
      </div>

      <!-- 加载态 -->
      <div v-if="loading" class="loading-wrap">
        <el-skeleton animated>
          <template #template>
            <div class="skeleton-card" v-for="i in 3" :key="i">
              <el-skeleton-item variant="text" style="width: 30%; height: 20px" />
              <el-skeleton-item variant="text" style="width: 50%; height: 14px; margin-top: 10px" />
              <el-skeleton-item variant="text" style="width: 40%; height: 14px; margin-top: 6px" />
            </div>
          </template>
        </el-skeleton>
      </div>

      <!-- 空状态 -->
      <div v-else-if="orders.length === 0" class="empty-wrap">
        <div class="empty-illustration">
          <el-icon :size="80"><DocumentChecked /></el-icon>
        </div>
        <p class="empty-title">还没有订单</p>
        <p class="empty-desc">配置印刷报价并提交后，订单会出现在这里</p>
        <el-button type="danger" round @click="router.push('/mall')">去产品大厅选购</el-button>
      </div>

      <!-- 订单列表 -->
      <div v-else class="order-list">
        <transition-group name="list-slide" tag="div" class="list-inner">
        <div
          v-for="order in filteredOrders"
          :key="order.id"
          class="order-card"
          :class="[`status-${order.status?.toLowerCase()}`, { expanded: expandedOrderId === order.id }]"
        >
          <!-- 订单头部 -->
          <div class="order-summary" @click="toggleExpand(order.id)">
            <div class="summary-left">
              <div class="status-indicator" :class="order.status?.toLowerCase()"></div>
              <div class="order-meta">
                <div class="order-id-row">
                  <el-icon :size="16"><Tickets /></el-icon>
                  <span class="order-id">订单 #{{ order.id }}</span>
                  <el-tag
                    :type="statusType(order.status)"
                    size="small"
                    effect="dark"
                    round
                    class="status-tag"
                  >
                    {{ statusLabel(order.status) }}
                  </el-tag>
                </div>
                <div class="order-sub-info">
                  <span class="order-time">
                    <el-icon :size="13"><Calendar /></el-icon>
                    {{ formatTime(order.createTime) }}
                  </span>
                  <el-divider direction="vertical" />
                  <span class="order-item-count">{{ order.itemCount || 0 }} 项产品</span>
                </div>
              </div>
            </div>
            <div class="summary-right">
              <span class="total-label">合计</span>
              <span class="total-price">¥ {{ order.totalPrice }}</span>
              <el-icon :class="['expand-icon', { rotated: expandedOrderId === order.id }]">
                <ArrowDownBold />
              </el-icon>
            </div>
          </div>

          <!-- 订单详情 -->
          <transition name="slide-fade">
            <div v-if="expandedOrderId === order.id" class="order-detail">
              <div class="detail-header">
                <span class="detail-title">订单明细</span>
                <span class="detail-count">共 {{ order.items?.length || 0 }} 项</span>
              </div>
              <div
                v-for="(item, idx) in order.items"
                :key="item.id"
                class="order-item"
              >
                <div class="item-index">{{ idx + 1 }}</div>
                <div class="item-body">
                  <div class="item-head">
                    <span class="item-name">{{ item.productName }}</span>
                    <span class="item-price">¥ {{ item.price }}</span>
                  </div>
                  <div class="item-config">
                    <template v-for="(val, key) in item.formData" :key="key">
                      <template v-if="isPlainObject(val)">
                        <div class="config-group-label">{{ key }}</div>
                        <div class="config-chips">
                          <span
                            v-for="(subVal, subKey) in val"
                            :key="`${key}_${subKey}`"
                            class="config-chip"
                          >
                            <span class="chip-key">{{ subKey }}</span>
                            <span class="chip-sep">:</span>
                            <span class="chip-val">{{
                              Array.isArray(subVal) ? subVal.join("、") : subVal
                            }}</span>
                          </span>
                        </div>
                      </template>
                      <div v-else class="direct-field">
                        <span class="field-key">{{ key }}</span>
                        <span class="field-val">{{
                          Array.isArray(val) ? val.join("、") : val
                        }}</span>
                      </div>
                    </template>
                  </div>
                </div>
              </div>
            </div>
          </transition>
        </div>
        </transition-group>
      </div>
    </div>

    <!-- ====== 底部 ====== -->
    <footer class="global-footer">
      <span>印刷包装在线报价系统 · 订单管理</span>
      <span class="footer-divider">|</span>
      <span>专业印刷，匠心品质</span>
    </footer>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import {
  ArrowDownBold,
  Refresh,
  Search,
  Close,
  Document,
  Clock,
  Money,
  DocumentChecked,
  Tickets,
  Calendar,
} from "@element-plus/icons-vue";
import { getOrders, getOrderDetail } from "@/api/order";
import MallNavbar from "@/components/MallNavbar.vue";

const router = useRouter();
const orders = ref([]);
const loading = ref(true);
const expandedOrderId = ref(null);
const filterTab = ref('');
const searchQuery = ref('');
const searchFocused = ref(false);
const searchInput = ref(null);

const statusTabs = [
  { label: '全部', value: '' },
  { label: '待处理', value: 'PENDING' },
  { label: '已处理', value: 'PROCESSED' },
  { label: '已发货', value: 'SHIPPED' },
  { label: '已完成', value: 'COMPLETED' },
  { label: '已取消', value: 'CANCELLED' },
];

const filteredOrders = computed(() => {
  let list = orders.value;
  if (filterTab.value) {
    list = list.filter(o => o.status === filterTab.value);
  }
  if (searchQuery.value.trim()) {
    const q = searchQuery.value.trim().toLowerCase();
    list = list.filter(o => String(o.id).toLowerCase().includes(q));
  }
  return list;
});

const statusCount = (s) => orders.value.filter(o => o.status === s).length;

const pendingCount = computed(() =>
  orders.value.filter((o) => o.status === "PENDING").length
);
const totalSpent = computed(() =>
  orders.value
    .reduce((sum, o) => sum + parseFloat(o.totalPrice || 0), 0)
    .toFixed(2)
);

const statusLabel = (s) =>
  ({ PENDING: "待处理", PROCESSED: "已处理", SHIPPED: "已发货", COMPLETED: "已完成", CANCELLED: "已取消" }[s] || s);
const statusType = (s) =>
  ({ PENDING: "warning", PROCESSED: "", SHIPPED: "", COMPLETED: "success", CANCELLED: "info" }[s] || "info");
const formatTime = (t) => {
  if (!t) return "";
  const d = new Date(t);
  const pad = (n) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
};
const isPlainObject = (v) =>
  v !== null && typeof v === "object" && !Array.isArray(v);

const toggleExpand = async (orderId) => {
  if (expandedOrderId.value === orderId) {
    expandedOrderId.value = null;
    return;
  }
  expandedOrderId.value = orderId;
  const order = orders.value.find((o) => o.id === orderId);
  if (order && !order.items) {
    try {
      const res = await getOrderDetail(orderId);
      order.items = res.items || [];
      order.itemCount = order.items.length;
    } catch {
      order.items = [];
    }
  }
};

const fetchOrders = async () => {
  loading.value = true;
  try {
    orders.value = (await getOrders()) || [];
    orders.value.forEach((o) => {
      if (!o.itemCount) o.itemCount = "...";
    });
  } catch {
    orders.value = [];
  } finally {
    loading.value = false;
  }
};

onMounted(fetchOrders);
</script>

<style scoped>
/* ===== 页面容器 ===== */
.orders-page {
  min-height: 100vh;
  background: #f5f6f8;
}

/* ========================================
   Hero 区域 — 网格纹理 + 光晕
   ======================================== */
.hero-section {
  position: relative;
  height: 380px;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  background: linear-gradient(160deg, #1a1a2e 0%, #16213e 40%, #0f3460 100%);
}
.hero-grid {
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(rgba(255,255,255,.03) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,.03) 1px, transparent 1px);
  background-size: 40px 40px;
  mask-image: radial-gradient(ellipse 80% 60% at 50% 40%, black 40%, transparent 70%);
  -webkit-mask-image: radial-gradient(ellipse 80% 60% at 50% 40%, black 40%, transparent 70%);
}
.hero-overlay {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(circle at 20% 70%, rgba(247,42,68,.12) 0%, transparent 50%),
    radial-gradient(circle at 80% 30%, rgba(102,126,234,.1) 0%, transparent 50%);
}
.hero-content {
  position: relative;
  z-index: 1;
  text-align: center;
  animation: fadeInUp .7s var(--ease-out);
}
.hero-title {
  font-size: 42px;
  font-weight: 800;
  color: #fff;
  margin: 0 0 12px;
  letter-spacing: 1.5px;
}
.hero-subtitle {
  font-size: 16px;
  color: rgba(255,255,255,.65);
  margin: 0 0 32px;
  font-weight: 300;
}

/* 搜索框 */
.search-container {
  position: relative;
  width: 480px;
  max-width: 90vw;
  margin: 0 auto;
}
.search-wrap {
  display: flex;
  align-items: center;
  background: rgba(255,255,255,.12);
  backdrop-filter: blur(12px);
  border: 1.5px solid rgba(255,255,255,.18);
  border-radius: 36px;
  padding: 6px 18px;
  transition: all .35s cubic-bezier(.4,0,.2,1);
}
.search-wrap.focused {
  background: rgba(255,255,255,.2);
  border-color: rgba(255,255,255,.5);
  box-shadow: 0 0 0 4px rgba(247,42,68,.25), 0 0 30px rgba(247,42,68,.12);
}
.search-icon {
  color: rgba(255,255,255,.7);
  flex-shrink: 0;
  margin-right: 8px;
}
.search-field {
  flex: 1;
  border: none;
  outline: none;
  background: transparent;
  font-size: 15px;
  color: #fff;
  padding: 10px 0;
  font-family: inherit;
}
.search-field::placeholder { color: rgba(255,255,255,.45); }
.search-clear { color: rgba(255,255,255,.6); flex-shrink: 0; }

/* ========================================
   主体区域 — 负边距悬浮覆盖 Hero
   ======================================== */
.orders-body {
  max-width: 1200px;
  margin: -50px auto 0;
  padding: 0 24px 80px;
  position: relative;
  z-index: 2;
}

/* ========================================
   统计卡片 — 半透明浮窗
   ======================================== */
.stats-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 22px;
  animation: fadeInUp .6s var(--ease-out) .15s both;
}
.stat-card {
  background: rgba(255,255,255,.88);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255,255,255,.9);
  border-radius: 14px;
  padding: 18px 16px;
  display: flex;
  align-items: center;
  gap: 14px;
  box-shadow: 0 2px 16px rgba(0,0,0,.06);
  transition: box-shadow 0.3s, transform 0.3s;
}
.stat-card:hover {
  box-shadow: 0 4px 24px rgba(0,0,0,.1);
  transform: translateY(-2px);
}
.stat-icon {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.stat-icon.total {
  background: linear-gradient(135deg, #e8f0fe, #d4e4fc);
  color: #3b82f6;
}
.stat-icon.pending {
  background: linear-gradient(135deg, #fef3c7, #fde68a);
  color: #f59e0b;
}
.stat-icon.amount {
  background: linear-gradient(135deg, #fce4ec, #f8bbd0);
  color: #e53935;
}
.stat-icon.refresh-card {
  background: linear-gradient(135deg, #e8f5e9, #c8e6c9);
  color: #43a047;
  cursor: pointer;
  transition: background .25s;
}
.stat-icon.refresh-card:hover {
  background: linear-gradient(135deg, #c8e6c9, #a5d6a7);
}
.refresh-icon { transition: transform .25s; }
.refresh-icon.spinning { animation: spin .8s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

.stat-body {
  display: flex;
  flex-direction: column;
}
.stat-num {
  font-size: 22px;
  font-weight: 700;
  color: #303133;
  line-height: 1.2;
}
.stat-label {
  font-size: 13px;
  color: #909399;
  margin-top: 2px;
}
.refresh-label {
  font-size: 16px;
  font-weight: 700;
  color: #43a047;
}

/* ===== 状态切换 Tabs ===== */
.status-tabs {
  display: flex;
  gap: 6px;
  margin-bottom: 20px;
  flex-wrap: wrap;
  animation: fadeInUp .6s var(--ease-out) .2s both;
}
.status-tab {
  padding: 8px 18px;
  border: 1.5px solid var(--gray-200);
  border-radius: 24px;
  background: #fff;
  font-size: 13px;
  font-weight: 500;
  color: var(--gray-500);
  cursor: pointer;
  font-family: inherit;
  transition: all .25s var(--ease-out);
}
.status-tab:hover { border-color: var(--color-primary); color: var(--color-primary); }
.status-tab.active {
  background: var(--color-primary);
  color: #fff;
  border-color: var(--color-primary);
  font-weight: 700;
  box-shadow: 0 2px 10px rgba(247,42,68,.25);
}
.tab-count {
  display: inline-block;
  background: rgba(255,255,255,.25);
  color: inherit;
  padding: 0 6px;
  border-radius: 10px;
  font-size: 11px;
  margin-left: 6px;
  min-width: 16px;
  text-align: center;
}
.status-tab.active .tab-count { background: rgba(255,255,255,.3); }

/* ===== 列表滑动过渡 ===== */
.list-slide-enter-active,
.list-slide-leave-active {
  transition: all .4s var(--ease-out);
}
.list-slide-enter-from {
  opacity: 0;
  transform: translateX(40px);
}
.list-slide-leave-to {
  opacity: 0;
  transform: translateX(-40px);
}
.list-slide-move {
  transition: transform .35s var(--ease-out);
}
.list-inner { display: flex; flex-direction: column; gap: 14px; }

/* ===== 加载态 ===== */
.loading-wrap {
  padding: 20px 0;
  animation: fadeInUp .6s var(--ease-out) .2s both;
}
.skeleton-card {
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 12px;
}

/* ===== 空状态 ===== */
.empty-wrap {
  text-align: center;
  padding: 80px 20px;
  background: #fff;
  border-radius: 16px;
  border: 1px solid #ebeef5;
  animation: fadeInUp .6s var(--ease-out) .2s both;
}
.empty-illustration {
  color: #dcdfe6;
  margin-bottom: 20px;
}
.empty-title {
  font-size: 18px;
  font-weight: 600;
  color: #606266;
  margin: 0 0 8px;
}
.empty-desc {
  font-size: 14px;
  color: #909399;
  margin: 0 0 24px;
}

/* ===== 订单列表 ===== */
.order-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  animation: fadeInUp .6s var(--ease-out) .25s both;
}

/* ===== 订单卡片 ===== */
.order-card {
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 14px;
  overflow: hidden;
  transition: all 0.3s var(--ease-out);
  position: relative;
}
.order-card::before {
  content: "";
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 4px;
  border-radius: 14px 0 0 14px;
  transition: background 0.3s;
}
.order-card.status-pending::before {
  background: #f59e0b;
}
.order-card.status-processed::before {
  background: #409eff;
}
.order-card.status-shipped::before {
  background: #7c3aed;
}
.order-card.status-completed::before {
  background: #67c23a;
}
.order-card.status-cancelled::before {
  background: #c0c4cc;
}
.order-card:hover {
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border-color: #d4d7de;
}
.order-card.expanded {
  border-color: #c6d0e0;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.1);
}

/* ===== 订单摘要 ===== */
.order-summary {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 18px 18px 18px 22px;
  cursor: pointer;
  user-select: none;
  transition: background 0.2s;
}
.order-summary:hover {
  background: #fafbfc;
}
.summary-left {
  display: flex;
  align-items: center;
  gap: 14px;
}
.status-indicator {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  flex-shrink: 0;
}
.status-indicator.pending {
  background: #f59e0b;
  box-shadow: 0 0 0 4px rgba(245, 158, 11, 0.18);
}
.status-indicator.confirmed {
  background: #67c23a;
  box-shadow: 0 0 0 4px rgba(103, 194, 58, 0.18);
}
.status-indicator.cancelled {
  background: #c0c4cc;
  box-shadow: 0 0 0 4px rgba(192, 196, 204, 0.18);
}
.order-meta {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.order-id-row {
  display: flex;
  align-items: center;
  gap: 7px;
}
.order-id {
  font-weight: 700;
  color: #303133;
  font-size: 15px;
  letter-spacing: 0.3px;
}
.status-tag {
  font-weight: 600;
  margin-left: 2px;
}
.order-sub-info {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12.5px;
  color: #909399;
}
.order-sub-info .el-icon {
  margin-right: 2px;
}
.summary-right {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-shrink: 0;
}
.total-label {
  font-size: 13px;
  color: #909399;
}
.total-price {
  font-size: 20px;
  font-weight: 800;
  color: #f72a44;
  letter-spacing: -0.3px;
}
.expand-icon {
  color: #909399;
  font-size: 14px;
  transition: transform 0.3s ease;
  margin-left: 4px;
}
.expand-icon.rotated {
  transform: rotate(180deg);
}

/* ===== 订单详情（展开区域） ===== */
.order-detail {
  background: #f8f9fc;
  border-top: 1px solid #ebeef5;
  padding: 18px 22px 20px;
}
.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 14px;
}
.detail-title {
  font-size: 14px;
  font-weight: 700;
  color: #303133;
}
.detail-count {
  font-size: 12px;
  color: #909399;
  background: #ebeef5;
  padding: 2px 10px;
  border-radius: 10px;
}

/* ===== 明细项 ===== */
.order-item {
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 10px;
  padding: 14px 16px;
  margin-bottom: 10px;
  display: flex;
  gap: 14px;
  transition: border-color 0.2s;
}
.order-item:hover {
  border-color: #c6d0e0;
}
.order-item:last-child {
  margin-bottom: 0;
}
.item-index {
  width: 26px;
  height: 26px;
  border-radius: 8px;
  background: linear-gradient(135deg, #f72a44, #e53935);
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
  padding-left: 2px;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}
.config-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}
.config-chip {
  display: inline-flex;
  align-items: center;
  background: #f0f2f5;
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

/* ===== 过渡动画 ===== */
.slide-fade-enter-active {
  transition: all 0.35s ease-out;
}
.slide-fade-leave-active {
  transition: all 0.25s ease-in;
}
.slide-fade-enter-from {
  opacity: 0;
  transform: translateY(-12px);
}
.slide-fade-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}

/* ========================================
   全局底部
   ======================================== */
.global-footer {
  text-align: center;
  padding: 30px 0 40px;
  color: #c0c4cc;
  font-size: 13px;
}
.footer-divider { margin: 0 12px; }

/* ========================================
   响应式
   ======================================== */
@media (max-width: 900px) {
  .hero-section { height: 300px; }
  .hero-title { font-size: 28px; }
  .hero-subtitle { font-size: 14px; }
  .stats-row { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 600px) {
  .hero-section { height: 260px; }
  .hero-title { font-size: 22px; }
  .stats-row { grid-template-columns: 1fr; }
  .orders-body { padding: 0 12px 60px; }
}
</style>
