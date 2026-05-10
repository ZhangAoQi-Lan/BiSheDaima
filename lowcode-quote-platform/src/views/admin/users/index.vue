<template>
  <div class="admin-page">
    <AdminNavbar />
    <div class="page-body">
      <div class="page-card">
        <div class="card-header">
          <div class="header-left">
            <h3><el-icon :size="18"><User /></el-icon> 用户管理</h3>
            <span class="subtitle">共 {{ total }} 个注册用户</span>
          </div>
          <div class="header-right">
            <el-input
              v-model="keyword"
              placeholder="搜索用户名或邮箱"
              clearable
              :prefix-icon="Search"
              style="width: 260px"
              @keyup.enter="fetchUsers"
              @clear="fetchUsers"
            />
            <el-button type="primary" :icon="Search" @click="fetchUsers">搜索</el-button>
          </div>
        </div>

        <el-table
          :data="users"
          v-loading="loading"
          stripe
          style="width: 100%"
          empty-text="暂无用户数据"
        >
          <el-table-column prop="id" label="ID" width="70" align="center" />
          <el-table-column prop="username" label="用户名" min-width="120">
            <template #default="{ row }">
              <div class="user-cell">
                <el-avatar :size="28" icon="UserFilled" />
                <span>{{ row.username }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="email" label="邮箱" min-width="180">
            <template #default="{ row }">
              <span class="email-text">{{ row.email || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="role" label="角色" width="100" align="center">
            <template #default="{ row }">
              <el-tag
                :type="row.role === 'ADMIN' ? 'danger' : 'info'"
                effect="light"
                size="small"
                round
              >
                {{ row.role === 'ADMIN' ? '管理员' : '普通用户' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="注册时间" width="180" align="center">
            <template #default="{ row }">
              <span class="time-text">{{ formatTime(row.createTime) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="140" align="center" fixed="right">
            <template #default="{ row }">
              <el-button link type="primary" size="small" @click="showDetail(row)">
                <el-icon :size="14"><View /></el-icon>查看
              </el-button>
              <el-button link type="warning" size="small" @click="openEdit(row)">
                <el-icon :size="14"><Edit /></el-icon>编辑
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <div class="no-more" v-if="!loading && users.length > 0 && !keyword">
          <span>已加载全部用户</span>
        </div>
      </div>
    </div>

    <!-- 用户详情弹窗 -->
    <el-dialog v-model="dialogVisible" title="用户详情" width="480px" :close-on-click-modal="false">
      <template v-if="detailUser">
        <div class="detail-grid">
          <div class="detail-item">
            <span class="detail-label">用户ID</span>
            <span class="detail-value">{{ detailUser.id }}</span>
          </div>
          <div class="detail-item">
            <span class="detail-label">用户名</span>
            <span class="detail-value">{{ detailUser.username }}</span>
          </div>
          <div class="detail-item">
            <span class="detail-label">邮箱</span>
            <span class="detail-value">{{ detailUser.email || '未绑定' }}</span>
          </div>
          <div class="detail-item">
            <span class="detail-label">角色</span>
            <span class="detail-value">
              <el-tag :type="detailUser.role === 'ADMIN' ? 'danger' : 'info'" effect="light" size="small" round>
                {{ detailUser.role === 'ADMIN' ? '管理员' : '普通用户' }}
              </el-tag>
            </span>
          </div>
          <div class="detail-item">
            <span class="detail-label">注册时间</span>
            <span class="detail-value">{{ formatTime(detailUser.createTime) }}</span>
          </div>
          <div class="detail-item">
            <span class="detail-label">更新时间</span>
            <span class="detail-value">{{ formatTime(detailUser.updateTime) }}</span>
          </div>
        </div>
      </template>
    </el-dialog>

    <!-- 用户编辑弹窗 -->
    <el-dialog v-model="editDialogVisible" title="编辑用户" width="500px" :close-on-click-modal="false">
      <template v-if="editUser">
        <div class="edit-section">
          <div class="edit-user-info">
            <el-avatar :size="40" icon="UserFilled" />
            <div>
              <div class="edit-username">{{ editUser.username }}</div>
              <div class="edit-uid">ID: {{ editUser.id }}</div>
            </div>
          </div>
        </div>

        <el-divider>角色权限</el-divider>
        <div class="edit-row">
          <span class="edit-label">当前角色</span>
          <el-tag :type="editUser.role === 'ADMIN' ? 'danger' : 'info'" effect="light" size="small" round>
            {{ editUser.role === 'ADMIN' ? '管理员' : '普通用户' }}
          </el-tag>
        </div>
        <div class="edit-row" style="margin-top: 14px">
          <span class="edit-label">修改为</span>
          <el-select v-model="editRole" placeholder="选择新角色" style="width: 180px">
            <el-option label="普通用户 (USER)" value="USER" />
            <el-option label="管理员 (ADMIN)" value="ADMIN" />
          </el-select>
          <el-button
            type="warning"
            size="small"
            :loading="roleSaving"
            :disabled="!editRole || editRole === editUser.role"
            @click="handleUpdateRole"
          >
            确认切换
          </el-button>
        </div>

        <el-divider>密码重置</el-divider>
        <div class="edit-row">
          <span class="edit-label">新密码</span>
          <el-input
            v-model="newPassword"
            type="password"
            show-password
            placeholder="至少6位"
            style="width: 200px"
          />
        </div>
        <div class="edit-row" style="margin-top: 14px">
          <span class="edit-label">确认密码</span>
          <el-input
            v-model="confirmPassword"
            type="password"
            show-password
            placeholder="再次输入"
            style="width: 200px"
          />
          <el-button
            type="danger"
            size="small"
            :loading="pwdSaving"
            :disabled="!newPassword || newPassword !== confirmPassword"
            @click="handleResetPassword"
          >
            重置密码
          </el-button>
        </div>
      </template>
      <template #footer>
        <el-button @click="editDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { User, Search, View, Edit } from '@element-plus/icons-vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { getAdminUsers, updateUserPassword, updateUserRole } from '@/api/admin';
import AdminNavbar from '@/components/AdminNavbar.vue';

const users = ref([]);
const loading = ref(false);
const keyword = ref('');
const total = ref(0);

const dialogVisible = ref(false);
const detailUser = ref(null);

// 编辑
const editDialogVisible = ref(false);
const editUser = ref(null);
const editRole = ref('');
const newPassword = ref('');
const confirmPassword = ref('');
const roleSaving = ref(false);
const pwdSaving = ref(false);

const formatTime = (t) => {
  if (!t) return '-';
  const d = new Date(t);
  const pad = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
};

const fetchUsers = async () => {
  loading.value = true;
  try {
    users.value = (await getAdminUsers(keyword.value || undefined)) || [];
    total.value = users.value.length;
  } catch {
    users.value = [];
  } finally {
    loading.value = false;
  }
};

const showDetail = (user) => {
  detailUser.value = user;
  dialogVisible.value = true;
};

const openEdit = (user) => {
  editUser.value = user;
  editRole.value = '';
  newPassword.value = '';
  confirmPassword.value = '';
  editDialogVisible.value = true;
};

const handleUpdateRole = async () => {
  if (!editRole.value || editRole.value === editUser.value.role) return;
  try {
    const label = editRole.value === 'ADMIN' ? '管理员' : '普通用户';
    await ElMessageBox.confirm(
      `确认将用户「${editUser.value.username}」的角色从「${editUser.value.role === 'ADMIN' ? '管理员' : '普通用户'}」切换为「${label}」？`,
      '角色变更确认',
      { type: 'warning' }
    );
    roleSaving.value = true;
    await updateUserRole(editUser.value.id, editRole.value);
    ElMessage.success(`用户「${editUser.value.username}」角色已切换为「${label}」`);
    editDialogVisible.value = false;
    await fetchUsers();
  } catch (e) {
    if (e !== 'cancel' && e !== 'close') {
      ElMessage.error('角色修改失败');
    }
  } finally {
    roleSaving.value = false;
  }
};

const handleResetPassword = async () => {
  if (!newPassword.value) {
    ElMessage.warning('请输入新密码');
    return;
  }
  if (newPassword.value.length < 6) {
    ElMessage.warning('密码至少6位');
    return;
  }
  if (newPassword.value !== confirmPassword.value) {
    ElMessage.warning('两次输入的密码不一致');
    return;
  }
  try {
    await ElMessageBox.confirm(
      `确认重置用户「${editUser.value.username}」的密码？此操作不可逆。`,
      '密码重置确认',
      { type: 'warning' }
    );
    pwdSaving.value = true;
    await updateUserPassword(editUser.value.id, newPassword.value);
    ElMessage.success(`用户「${editUser.value.username}」密码已重置`);
    newPassword.value = '';
    confirmPassword.value = '';
  } catch (e) {
    if (e !== 'cancel' && e !== 'close') {
      ElMessage.error('密码重置失败');
    }
  } finally {
    pwdSaving.value = false;
  }
};

onMounted(fetchUsers);
</script>

<style scoped>
.admin-page {
  min-height: 100vh;
  background: #f0f2f5;
}
.page-body { padding: 22px 28px; }
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
.header-left { display: flex; align-items: center; gap: 12px; }
.header-left h3 {
  margin: 0;
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 17px;
  color: #303133;
}
.subtitle { font-size: 13px; color: #909399; }
.header-right { display: flex; gap: 8px; }
.user-cell { display: flex; align-items: center; gap: 8px; }
.email-text { color: #606266; }
.time-text { color: #909399; font-size: 13px; }
.no-more { text-align: center; padding: 20px; color: #c0c4cc; font-size: 13px; }

/* 详情 */
.detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
.detail-item { display: flex; flex-direction: column; gap: 4px; }
.detail-label { font-size: 12px; color: #909399; font-weight: 500; }
.detail-value { font-size: 14px; color: #303133; font-weight: 600; }

/* 编辑弹窗 */
.edit-section { margin-bottom: 4px; }
.edit-user-info { display: flex; align-items: center; gap: 14px; }
.edit-username { font-size: 16px; font-weight: 700; color: #303133; }
.edit-uid { font-size: 12px; color: #909399; margin-top: 2px; }
.edit-row {
  display: flex;
  align-items: center;
  gap: 12px;
}
.edit-label { color: #909399; font-size: 13px; flex-shrink: 0; min-width: 70px; }
</style>
