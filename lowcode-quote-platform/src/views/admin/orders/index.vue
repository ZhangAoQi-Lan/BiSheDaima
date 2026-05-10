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
              style="width: 130px"
              @change="fetchOrders"
            >
              <el-option label="待处理" value="PENDING" />
              <el-option label="已处理" value="PROCESSED" />
              <el-option label="已发货" value="SHIPPED" />
              <el-option label="已完成" value="COMPLETED" />
              <el-option label="已取消" value="CANCELLED" />
            </el-select>
            <el-input
              v-model="keyword"
              placeholder="搜索用户名"
              clearable
              :prefix-icon="Search"
              style="width: 200px"
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
          <el-table-column prop="username" label="下单用户" min-width="120">
            <template #default="{ row }">
              <div class="user-cell">
                <el-avatar :size="24" icon="UserFilled" />
                <span>{{ row.username }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="110" align="center">
            <template #default="{ row }">
              <el-tag
                :type="statusType(row.status)"
                effect="dark"
                size="small"
                round
              >
                {{ statusLabel(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="itemCount" label="产品数" width="80" align="center" />
          <el-table-column prop="totalPrice" label="总价" width="130" align="right">
            <template #default="{ row }">
              <span class="price-text">¥ {{ row.totalPrice }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="提交时间" width="170" align="center">
            <template #default="{ row }">
              <span class="time-text">{{ formatTime(row.createTime) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="160" align="center" fixed="right">
            <template #default="{ row }">
              <el-button link type="primary" size="small" @click="showDetail(row.id)">
                <el-icon :size="14"><View /></el-icon>详情
              </el-button>
              <el-button link type="warning" size="small" @click="openStatusEdit(row)">
                <el-icon :size="14"><Edit /></el-icon>状态
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </div>

    <!-- 订单详情弹窗 -->
    <el-dialog v-model="dialogVisible" title="订单详情" width="640px" :close-on-click-modal="false">
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
            <span class="s-value price">¥ {{ detailOrder.totalPrice }}</span>
          </div>
          <div class="summary-row">
            <span class="s-label">提交时间</span>
            <span class="s-value">{{ formatTime(detailOrder.createTime) }}</span>
          </div>
        </div>

        <el-divider>订单明细 ({{ detailItems.length }} 项)</el-divider>

        <div class="detail-items">
          <div v-for="(item, idx) in detailItems" :key="item.id" class="detail-order-item">
            <div class="item-index-badge">{{ idx + 1 }}</div>
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
          v-if="detailOrder"
          type="warning"
          :icon="Edit"
          @click="dialogVisible = false; openStatusEdit(detailOrder)"
        >
          修改状态
        </el-button>
      </template>
    </el-dialog>

    <!-- 修改状态弹窗 -->
    <el-dialog v-model="statusDialogVisible" title="修改订单状态" width="440px" :close-on-click-modal="false">
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
        <el-divider />
        <div class="status-select-row">
          <span class="edit-label">新状态</span>
          <el-select v-model="newStatus" placeholder="请选择新状态" style="width: 200px">
            <el-option
              v-for="s in statusOptions"
              :key="s.value"
              :label="s.label"
              :value="s.value"
              :disabled="s.value === editingOrder.status"
            >
              <el-tag :type="statusType(s.value)" effect="dark" size="small" round>
                {{ s.label }}
              </el-tag>
            </el-option>
          </el-select>
        </div>
      </div>
      <template #footer>
        <el-button @click="statusDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="statusSaving" @click="confirmStatusChange">
          确认修改
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { Document, Search, View, Edit } from '@element-plus/icons-vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { getAdminOrders, getAdminOrderDetail, updateOrderStatus } from '@/api/admin';
import AdminNavbar from '@/components/AdminNavbar.vue';

const orders = ref([]);
const loading = ref(false);
const keyword = ref('');
const filterStatus = ref('');
const total = ref(0);

const dialogVisible = ref(false);
const detailOrder = ref(null);
const detailItems = ref([]);
const detailUsername = ref('');

// 状态编辑
const statusDialogVisible = ref(false);
const editingOrder = ref(null);
const newStatus = ref('');
const statusSaving = ref(false);

const statusOptions = [
  { label: '待处理', value: 'PENDING' },
  { label: '已处理', value: 'PROCESSED' },
  { label: '已发货', value: 'SHIPPED' },
  { label: '已完成', value: 'COMPLETED' },
  { label: '已取消', value: 'CANCELLED' },
];

const statusLabel = (s) => {
  const map = { PENDING: '待处理', PROCESSED: '已处理', SHIPPED: '已发货', COMPLETED: '已完成', CANCELLED: '已取消' };
  return map[s] || s;
};
const statusType = (s) => {
  const map = { PENDING: 'warning', PROCESSED: '', SHIPPED: '', COMPLETED: 'success', CANCELLED: 'info' };
  return map[s] || 'info';
};
const formatTime = (t) => {
  if (!t) return '-';
  const d = new Date(t);
  const pad = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
};
const isPlainObject = (v) =>
  v !== null && typeof v === 'object' && !Array.isArray(v);

const fetchOrders = async () => {
  loading.value = true;
  try {
    const params = {};
    if (filterStatus.value) params.status = filterStatus.value;
    if (keyword.value) params.keyword = keyword.value;
    orders.value = (await getAdminOrders(params)) || [];
    total.value = orders.value.length;
  } catch {
    orders.value = [];
  } finally {
    loading.value = false;
  }
};

const showDetail = async (orderId) => {
  try {
    const res = await getAdminOrderDetail(orderId);
    detailOrder.value = res.order;
    detailItems.value = res.items || [];
    detailUsername.value = res.username || '匿名用户';
    dialogVisible.value = true;
  } catch {}
};

const openStatusEdit = (order) => {
  editingOrder.value = order;
  newStatus.value = '';
  statusDialogVisible.value = true;
};

const confirmStatusChange = async () => {
  if (!newStatus.value) {
    ElMessage.warning('请选择新状态');
    return;
  }
  try {
    await ElMessageBox.confirm(
      `确认将订单 #${editingOrder.value.id} 状态从「${statusLabel(editingOrder.value.status)}」改为「${statusLabel(newStatus.value)}」？`,
      '修改确认',
      { type: 'warning' }
    );
    statusSaving.value = true;
    await updateOrderStatus(editingOrder.value.id, newStatus.value);
    ElMessage.success('状态修改成功');
    statusDialogVisible.value = false;
    // 刷新列表和详情
    await fetchOrders();
    if (detailOrder.value && detailOrder.value.id === editingOrder.value.id) {
      const res = await getAdminOrderDetail(editingOrder.value.id);
      detailOrder.value = res.order;
    }
  } catch (e) {
    if (e !== 'cancel' && e !== 'close') {
      ElMessage.error('状态修改失败');
    }
  } finally {
    statusSaving.value = false;
  }
};

onMounted(fetchOrders);
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
.subtitle { font-size: 13px; color: #909399; }
.header-right { display: flex; gap: 8px; align-items: center; }
.order-id-text { font-weight: 700; color: #303133; }
.user-cell { display: flex; align-items: center; gap: 8px; }
.price-text { font-weight: 700; color: #f72a44; font-size: 14px; }
.time-text { color: #909399; font-size: 13px; }

.detail-summary {
  background: #f8f9fc;
  border-radius: 8px;
  padding: 16px 20px;
}
.summary-row {
  display: flex;
  justify-content: space-between;
  padding: 6px 0;
}
.summary-row .s-label { color: #909399; font-size: 13px; }
.summary-row .s-value { color: #303133; font-weight: 600; font-size: 14px; }
.summary-row .s-value.price { color: #f72a44; font-size: 18px; font-weight: 800; }
.detail-items { display: flex; flex-direction: column; gap: 10px; }
.detail-order-item {
  background: #f8f9fc;
  border: 1px solid #ebeef5;
  border-radius: 10px;
  padding: 14px 16px;
  display: flex;
  gap: 14px;
}
.item-index-badge {
  width: 26px; height: 26px;
  border-radius: 8px;
  background: linear-gradient(135deg, #409eff, #337ecc);
  color: #fff;
  font-size: 12px; font-weight: 700;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0; margin-top: 2px;
}
.item-body { flex: 1; min-width: 0; }
.item-head {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 10px;
}
.item-name { font-size: 15px; font-weight: 700; color: #303133; }
.item-price { font-size: 17px; font-weight: 800; color: #f72a44; flex-shrink: 0; margin-left: 16px; }
.item-config { font-size: 13px; color: #606266; }
.config-group-label {
  font-size: 12px; font-weight: 700; color: #606266;
  margin: 8px 0 6px; text-transform: uppercase; letter-spacing: 0.3px;
}
.config-chips { display: flex; flex-wrap: wrap; gap: 6px; }
.config-chip {
  display: inline-flex; align-items: center;
  background: #e8edf3; border-radius: 6px; padding: 4px 10px;
  font-size: 12px; white-space: nowrap;
}
.chip-key { color: #909399; font-weight: 500; }
.chip-sep { color: #c0c4cc; margin: 0 4px; }
.chip-val { color: #303133; font-weight: 600; }
.direct-field {
  display: flex; align-items: baseline;
  padding: 5px 0; border-bottom: 1px dashed #ebeef5; gap: 10px;
}
.direct-field:last-child { border-bottom: none; }
.field-key { color: #909399; flex-shrink: 0; font-weight: 500; }
.field-val { color: #303133; font-weight: 600; }

/* 状态编辑 */
.status-edit-body {
  padding: 4px 0;
}
.status-current {
  display: flex; align-items: center; gap: 14px; padding: 8px 0;
}
.status-select-row {
  display: flex; align-items: center; gap: 14px; padding: 8px 0;
}
.edit-label { color: #909399; font-size: 13px; flex-shrink: 0; min-width: 70px; }
.edit-value { color: #303133; font-weight: 600; font-size: 14px; }
</style>
