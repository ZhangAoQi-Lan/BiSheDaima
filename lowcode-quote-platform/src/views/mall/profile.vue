<template>
  <div class="profile-page">
    <MallNavbar />

    <div class="profile-body">
      <!-- 左侧：基本信息 -->
      <div class="profile-main">
        <div class="section-card">
          <div class="card-label">基础信息</div>

          <!-- 头像上传 -->
          <div class="avatar-upload-area">
            <div class="avatar-wrap" @mouseenter="avatarHover = true" @mouseleave="avatarHover = false">
              <el-avatar :size="88" :src="avatarUrl" class="profile-avatar">
                <el-icon :size="36"><UserFilled /></el-icon>
              </el-avatar>
              <transition name="overlay-fade">
                <div v-if="avatarHover" class="avatar-overlay" @click="triggerUpload">
                  <el-icon :size="20"><Camera /></el-icon>
                  <span>修改头像</span>
                </div>
              </transition>
            </div>
            <div class="avatar-actions">
              <el-upload
                ref="uploadRef"
                class="avatar-uploader"
                :action="uploadUrl"
                :headers="uploadHeaders"
                name="file"
                :show-file-list="false"
                accept="image/*"
                :on-success="handleUploadSuccess"
                :on-error="handleUploadError"
                :before-upload="beforeUpload"
              >
                <el-button size="small" round>上传照片</el-button>
              </el-upload>
              <el-button size="small" round plain @click="handleRemoveAvatar" v-if="avatarUrl">移除</el-button>
            </div>
          </div>

          <el-divider />

          <!-- 表单 -->
          <el-form :model="form" :rules="rules" ref="formRef" label-position="top" class="info-form">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="登录账号">
                  <el-input v-model="form.username" disabled class="glow-input" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="显示昵称" prop="nickname">
                  <el-input
                    v-model="form.nickname"
                    placeholder="请输入昵称"
                    maxlength="20"
                    show-word-limit
                    class="glow-input"
                  />
                </el-form-item>
              </el-col>
            </el-row>
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="绑定邮箱" prop="email">
                  <el-input v-model="form.email" placeholder="请输入邮箱" class="glow-input" />
                </el-form-item>
              </el-col>
            </el-row>
            <el-form-item>
              <el-button type="primary" size="large" round :loading="saving" @click="handleSave" class="save-btn">
                保存修改
              </el-button>
            </el-form-item>
          </el-form>
        </div>
      </div>

      <!-- 右侧：安全设置 -->
      <div class="profile-side">
        <div class="section-card">
          <div class="card-label">安全设置</div>
          <div class="security-list">
            <div class="security-row">
              <div class="sec-info">
                <span class="sec-title">登录密码</span>
                <span class="sec-hint">定期更换密码更安全</span>
              </div>
              <el-button link type="primary" @click="pwdDialogVisible = true">修改</el-button>
            </div>
            <el-divider style="margin: 14px 0" />
            <div class="security-row">
              <div class="sec-info">
                <span class="sec-title">账号角色</span>
                <span class="sec-hint">
                  <el-tag :type="userStore.userInfo?.role === 'ADMIN' ? 'danger' : 'info'" size="small" round effect="plain">
                    {{ userStore.userInfo?.role === 'ADMIN' ? '管理员' : '普通用户' }}
                  </el-tag>
                </span>
              </div>
            </div>
            <el-divider style="margin: 14px 0" />
            <div class="security-row">
              <div class="sec-info">
                <span class="sec-title">注册时间</span>
                <span class="sec-hint">{{ formatTime(userStore.userInfo?.createTime) }}</span>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>

    <!-- 修改密码弹窗 -->
    <el-dialog v-model="pwdDialogVisible" title="修改登录密码" width="420px" :close-on-click-modal="false">
      <el-form :model="pwdForm" :rules="pwdRules" ref="pwdFormRef" label-width="80px">
        <el-form-item label="当前密码" prop="oldPwd">
          <el-input v-model="pwdForm.oldPwd" type="password" show-password placeholder="请输入当前密码" />
        </el-form-item>
        <el-form-item label="新密码" prop="newPwd">
          <el-input v-model="pwdForm.newPwd" type="password" show-password placeholder="至少6位" />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPwd">
          <el-input v-model="pwdForm.confirmPwd" type="password" show-password placeholder="再次输入" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="pwdDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="pwdSaving" @click="handleChangePwd">确认修改</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { UserFilled, Camera } from '@element-plus/icons-vue';
import { ElMessage } from 'element-plus';
import MallNavbar from '@/components/MallNavbar.vue';
import { useUserStore } from '@/stores/user';
import { getCurrentUser, updateProfile, updatePassword } from '@/api/user';

const router = useRouter();
const userStore = useUserStore();
const saving = ref(false);
const avatarHover = ref(false);
const avatarUrl = ref('');
const uploadRef = ref(null);
const formRef = ref(null);
const pwdFormRef = ref(null);
const pageLoading = ref(true);

const uploadUrl = 'http://localhost:8080/api/upload';
const uploadHeaders = computed(() => ({
  Authorization: 'Bearer ' + userStore.token,
}));

const form = reactive({
  username: '',
  nickname: '',
  email: '',
});

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const rules = {
  email: [
    { validator: (_rule, value, cb) => {
      if (value && !emailRegex.test(value)) cb(new Error('请输入正确的邮箱格式'));
      else cb();
    }, trigger: 'blur' }
  ],
};

const pwdForm = reactive({ oldPwd: '', newPwd: '', confirmPwd: '' });

const validateConfirmPwd = (_rule, value, cb) => {
  if (value !== pwdForm.newPwd) cb(new Error('两次密码不一致'));
  else cb();
};

const pwdRules = {
  oldPwd: [{ required: true, message: '请输入当前密码', trigger: 'blur' }],
  newPwd: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '新密码至少6位', trigger: 'blur' },
  ],
  confirmPwd: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    { validator: validateConfirmPwd, trigger: 'blur' },
  ],
};

const pwdDialogVisible = ref(false);
const pwdSaving = ref(false);

const formatTime = (t) => {
  if (!t) return '-';
  const d = new Date(t);
  const pad = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
};

const populateForm = (user) => {
  form.username = user.username || '';
  form.nickname = user.nickname || '';
  form.email = user.email || '';
  avatarUrl.value = user.avatar || '';
};

const syncUserStore = (user) => {
  userStore.setUserInfo({
    ...userStore.userInfo,
    username: user.username,
    nickname: user.nickname,
    email: user.email,
    avatar: user.avatar,
    role: user.role,
    createTime: user.createTime,
  });
};

const triggerUpload = () => {
  uploadRef.value?.$el?.querySelector('input[type="file"]')?.click();
};

const beforeUpload = (file) => {
  const isImage = file.type.startsWith('image/');
  if (!isImage) {
    ElMessage.error('只能上传图片文件');
    return false;
  }
  const isLt2M = file.size / 1024 / 1024 < 2;
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB');
    return false;
  }
  return true;
};

const handleUploadSuccess = async (response) => {
  // response is the data returned by the interceptor: the URL string
  const url = typeof response === 'string' ? response : response.data;
  if (!url) {
    ElMessage.error('上传返回异常');
    return;
  }
  avatarUrl.value = url;
  try {
    const user = await updateProfile({ avatar: url });
    syncUserStore(user);
    ElMessage.success('头像已更新');
  } catch {
    ElMessage.error('头像同步失败，请刷新重试');
  }
};

const handleUploadError = () => {
  ElMessage.error('头像上传失败');
};

const handleRemoveAvatar = async () => {
  avatarUrl.value = '';
  try {
    const user = await updateProfile({ avatar: '' });
    syncUserStore(user);
    ElMessage.success('头像已移除');
  } catch {
    ElMessage.error('操作失败');
  }
};

const handleSave = async () => {
  const valid = await formRef.value.validate().catch(() => false);
  if (!valid) return;

  saving.value = true;
  try {
    const user = await updateProfile({
      nickname: form.nickname,
      email: form.email,
    });
    syncUserStore(user);
    ElMessage.success('个人资料已更新');
  } catch {
    ElMessage.error('保存失败，请重试');
  } finally {
    saving.value = false;
  }
};

const handleChangePwd = async () => {
  const valid = await pwdFormRef.value.validate().catch(() => false);
  if (!valid) return;

  pwdSaving.value = true;
  try {
    await updatePassword({
      oldPassword: pwdForm.oldPwd,
      newPassword: pwdForm.newPwd,
    });
    ElMessage.success('密码修改成功，请重新登录');
    pwdDialogVisible.value = false;
    userStore.clearAuth();
    router.push('/login');
  } catch {
    // error handled by interceptor
  } finally {
    pwdSaving.value = false;
  }
};

onMounted(async () => {
  try {
    const user = await getCurrentUser();
    populateForm(user);
    syncUserStore(user);
  } catch {
    // fallback to local store data
    const info = userStore.userInfo;
    if (info && info.username) {
      populateForm(info);
    }
  } finally {
    pageLoading.value = false;
  }
});
</script>

<style scoped>
.profile-page {
  min-height: 100vh;
  background: var(--gray-100);
}
.profile-body {
  max-width: 940px;
  margin: 36px auto 80px;
  padding: 0 24px;
  display: grid;
  grid-template-columns: 1fr 300px;
  gap: 24px;
  align-items: start;
  animation: fadeInScale .5s var(--ease-out);
}

.section-card {
  background: #fff;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  padding: 28px;
  margin-bottom: 20px;
  border: 1px solid var(--gray-200);
}
.card-label {
  font-size: 15px;
  font-weight: 700;
  color: var(--gray-700);
  margin-bottom: 22px;
  padding-bottom: 12px;
  border-bottom: 2px solid var(--gray-100);
  letter-spacing: -.2px;
}

/* 头像上传 */
.avatar-upload-area {
  display: flex;
  align-items: center;
  gap: 24px;
  margin-bottom: 8px;
}
.avatar-wrap {
  position: relative;
  cursor: pointer;
  border-radius: 50%;
}
.avatar-uploader {
  display: inline-block;
}
.profile-avatar {
  background: linear-gradient(135deg, #667eea, #764ba2);
  box-shadow: 0 4px 16px rgba(102,126,234,.3);
}
.avatar-overlay {
  position: absolute;
  inset: 0;
  border-radius: 50%;
  background: rgba(0,0,0,.45);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  color: #fff;
  font-size: 11px;
  font-weight: 600;
  z-index: 1;
}
.overlay-fade-enter-active,
.overlay-fade-leave-active { transition: opacity .2s; }
.overlay-fade-enter-from,
.overlay-fade-leave-to { opacity: 0; }
.avatar-actions {
  display: flex;
  gap: 8px;
  align-items: center;
}

/* 输入框 Glow */
:deep(.glow-input .el-input__wrapper) {
  border-radius: 10px;
  transition: all .3s var(--ease-out);
}
:deep(.glow-input .el-input__wrapper:hover) {
  box-shadow: 0 0 0 2px rgba(247,42,68,.08);
}
:deep(.glow-input .el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 3px rgba(247,42,68,.15), 0 0 16px rgba(247,42,68,.06);
  border-color: var(--color-primary);
}

.save-btn {
  margin-top: 10px;
  padding: 10px 32px !important;
  box-shadow: 0 4px 14px rgba(247,42,68,.25);
}

/* 安全设置 */
.security-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.sec-info { display: flex; flex-direction: column; gap: 3px; }
.sec-title { font-size: 14px; font-weight: 600; color: var(--gray-600); }
.sec-hint { font-size: 12px; color: var(--gray-400); }

@media (max-width: 768px) {
  .profile-body { grid-template-columns: 1fr; }
}
</style>
