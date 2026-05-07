<template>
  <div class="login-container">
    <el-card class="login-card">
      <template #header>
        <div class="login-header">
          <span>{{ isLogin ? '系统登录' : '用户注册' }}</span>
        </div>
      </template>

      <el-form :model="form" :rules="rules" ref="formRef" label-width="80px">
        <el-form-item label="账号" prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名或邮箱" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="form.password" type="password" placeholder="请输入密码" show-password />
        </el-form-item>
        
        <!-- 登录独有的图形验证码 -->
        <el-form-item v-if="isLogin" label="验证码" prop="captchaCode">
          <div style="display: flex; gap: 10px; width: 100%;">
            <el-input v-model="form.captchaCode" placeholder="图形验证码" style="flex: 1;" @keyup.enter="handleSubmit" />
            <img 
              v-if="captchaImg" 
              :src="captchaImg" 
              @click="loadCaptcha" 
              style="width: 100px; height: 32px; cursor: pointer; border: 1px solid #dcdfe6; border-radius: 4px;" 
              title="点击刷新" 
            />
          </div>
        </el-form-item>

        <!-- 注册独有项 -->
        <template v-if="!isLogin">
          <el-form-item label="邮箱地址" prop="email">
            <el-input v-model="form.email" placeholder="请输入有效邮箱" />
          </el-form-item>
          <el-form-item label="验证码" prop="emailCode">
            <div style="display: flex; gap: 10px; width: 100%;">
              <el-input v-model="form.emailCode" placeholder="邮箱验证码" style="flex: 1;" />
              <el-button type="primary" plain :disabled="emailSending || emailCountdown > 0" @click="handleSendEmailCode">
                {{ emailCountdown > 0 ? `${emailCountdown}s后重发` : '获取验证码' }}
              </el-button>
            </div>
          </el-form-item>
        </template>

        <el-form-item>
          <el-button type="primary" style="width: 100%; margin-top: 10px; margin-bottom: 10px;" :loading="loading" @click="handleSubmit">
            {{ isLogin ? '登 录' : '注 册' }}
          </el-button>
          <div class="switch-mode">
            <el-link type="primary" :underline="false" @click="toggleMode">
              {{ isLogin ? '没有账号？去注册' : '已有账号？去登录' }}
            </el-link>
          </div>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { login, register, getCaptcha, sendEmailCode } from '@/api/auth'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const isLogin = ref(true)
const loading = ref(false)
const formRef = ref(null)

// 验证码部分状态
const captchaImg = ref('')
const captchaId = ref('')
const emailSending = ref(false)
const emailCountdown = ref(0)

const form = reactive({
  username: '',
  password: '',
  captchaCode: '',
  email: '',
  emailCode: ''
})

const rules = reactive({
  username: [{ required: true, message: '请输入账号（用户名或邮箱）', trigger: 'blur' }],
  password: [{ required: true, message: '请输入强密码', trigger: 'blur' }],
  captchaCode: [{ required: true, message: '请输入图形验证码', trigger: 'blur' }],
  email: [
    { required: true, message: '请输入邮箱地址', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: ['blur', 'change'] }
  ],
  emailCode: [{ required: true, message: '请输入收到的验证码', trigger: 'blur' }]
})

onMounted(() => {
  loadCaptcha()
})

const loadCaptcha = async () => {
  try {
    const res = await getCaptcha()
    captchaImg.value = res.imgBase64
    captchaId.value = res.captchaId
    form.captchaCode = '' // 切换/刷新验证码应清空当前的输入
  } catch (error) {
    ElMessage.error('加载验证码失败')
  }
}

const handleSendEmailCode = async () => {
  if (!form.email || !/^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$/.test(form.email)) {
    return ElMessage.warning('请先输入有效的邮箱地址')
  }
  emailSending.value = true
  try {
    await sendEmailCode({ email: form.email })
    ElMessage.success('验证码已发送至邮箱，请查收')
    emailCountdown.value = 60
    const timer = setInterval(() => {
      emailCountdown.value--
      if (emailCountdown.value <= 0) {
        clearInterval(timer)
      }
    }, 1000)
  } catch (error) {
    ElMessage.error('获取验证码失败，请重试')
  } finally {
    emailSending.value = false
  }
}

const toggleMode = () => {
  isLogin.value = !isLogin.value
  formRef.value?.resetFields()
  if (isLogin.value) {
    loadCaptcha() // 切回登录需刷新验证码
  }
}

const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid, fields) => {
    if (valid) {
      // 在注册模式不验证图形验证码字段 (通过 rules 排除或忽略处理也可以，这里简化由于不渲染因此不走该 rule；如果走我们需要手动拦截)
      loading.value = true
      try {
        if (isLogin.value) {
          const res = await login({
            username: form.username,
            password: form.password,
            captchaId: captchaId.value,
            captchaCode: form.captchaCode
          })
          userStore.setToken(res.token)
          userStore.setUserInfo({ username: res.username, role: res.role })
          ElMessage.success('登录成功')
          const redirect = route.query.redirect || (res.role === 'ADMIN' ? '/admin/category' : '/mall')
          router.push(redirect)
        } else {
          await register({
            username: form.username,
            password: form.password,
            email: form.email,
            emailCode: form.emailCode
          })
          ElMessage.success('注册成功，请使用新账号登录')
          toggleMode()
        }
      } catch (error) {
        // 请求抛出异常（如密码错误/验证码不对），通常由于响应拦截器已处理 Toast，在此只需刷新验证码
        if (isLogin.value) {
          loadCaptcha()
        }
      } finally {
        loading.value = false
      }
    } else {
      console.log('error submit!', fields)
    }
  })
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #f3f4f6;
}

.login-card {
  width: 400px;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.login-header {
  font-size: 20px;
  font-weight: bold;
  text-align: center;
}

.switch-mode {
  text-align: center;
  width: 100%;
}
</style>
