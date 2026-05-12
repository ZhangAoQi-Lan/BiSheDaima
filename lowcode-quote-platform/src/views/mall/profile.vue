<template>
  <div class="profile-page">
    <MallNavbar />

    <div class="page-body">
      <section class="profile-hero">
        <div class="hero-copy">
          <span class="hero-kicker">Profile Studio</span>
          <h1>个人中心</h1>
          <p>统一管理账号资料、收货地址、历史报价和购物车记录。</p>
        </div>
        <div class="hero-user">
          <el-avatar :size="84" :src="avatarUrl" icon="UserFilled" />
          <div>
            <div class="hero-user-name">{{ form.nickname || form.username || '未设置昵称' }}</div>
            <div class="hero-user-sub">{{ form.email || '尚未绑定邮箱' }}</div>
          </div>
        </div>
      </section>

      <el-tabs v-model="activeTab" class="profile-tabs">
        <el-tab-pane label="个人资料" name="profile">
          <div class="panel-grid">
            <el-card class="soft-card">
              <template #header>基础资料</template>
              <el-form ref="formRef" :model="form" :rules="rules" label-position="top">
                <el-form-item label="登录账号">
                  <el-input v-model="form.username" disabled />
                </el-form-item>
                <el-form-item label="昵称" prop="nickname">
                  <el-input v-model="form.nickname" />
                </el-form-item>
                <el-form-item label="邮箱" prop="email">
                  <el-input v-model="form.email" />
                </el-form-item>
                <el-button type="primary" :loading="saving" @click="saveProfile">保存资料</el-button>
              </el-form>
            </el-card>

            <el-card class="soft-card">
              <template #header>安全设置</template>
              <el-form ref="pwdFormRef" :model="pwdForm" :rules="pwdRules" label-position="top">
                <el-form-item label="当前密码" prop="oldPwd">
                  <el-input v-model="pwdForm.oldPwd" type="password" show-password />
                </el-form-item>
                <el-form-item label="新密码" prop="newPwd">
                  <el-input v-model="pwdForm.newPwd" type="password" show-password />
                </el-form-item>
                <el-form-item label="确认密码" prop="confirmPwd">
                  <el-input v-model="pwdForm.confirmPwd" type="password" show-password />
                </el-form-item>
                <el-button type="warning" :loading="pwdSaving" @click="changePassword">修改密码</el-button>
              </el-form>
            </el-card>
          </div>
        </el-tab-pane>

        <el-tab-pane label="地址管理" name="address">
          <el-card class="soft-card">
            <template #header>
              <div class="card-header">
                <span>收货地址</span>
                <el-button type="primary" @click="openAddressDialog()">新增地址</el-button>
              </div>
            </template>

            <div v-if="addresses.length === 0" class="empty-address">
              <el-empty description="还没有收货地址，新增一个就可以用于下单" />
            </div>

            <div v-else class="address-grid">
              <div v-for="item in addresses" :key="item.id" class="address-item" :class="{ active: item.isDefault }">
                <div class="address-top">
                  <div class="address-owner">
                    <strong>{{ item.receiverName }}</strong>
                    <span>{{ item.phone }}</span>
                  </div>
                  <el-tag v-if="item.isDefault" type="success" round>默认地址</el-tag>
                </div>

                <p>{{ formatAddress(item) }}</p>

                <div class="address-actions">
                  <el-button link type="primary" @click="openAddressDialog(item)">编辑</el-button>
                  <el-button v-if="!item.isDefault" link @click="makeDefault(item.id)">设为默认</el-button>
                  <el-button link type="danger" @click="removeAddress(item.id)">删除</el-button>
                </div>
              </div>
            </div>
          </el-card>
        </el-tab-pane>

        <el-tab-pane label="历史报价" name="history">
          <el-card class="soft-card">
            <el-table :data="quoteHistory" border>
              <el-table-column prop="productName" label="产品" min-width="160" />
              <el-table-column prop="price" label="报价" width="120" />
              <el-table-column prop="createTime" label="时间" width="180" />
              <el-table-column label="操作" width="220">
                <template #default="{ row }">
                  <el-button link type="primary" @click="reuseQuote(row)">再次报价</el-button>
                  <el-button link @click="reAddToCart(row)">加入购物车</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </el-tab-pane>

        <el-tab-pane label="购物车记录" name="cart">
          <el-card class="soft-card">
            <el-table :data="cartItems" border>
              <el-table-column prop="productName" label="产品" min-width="180" />
              <el-table-column prop="price" label="价格" width="120" />
              <el-table-column prop="expiresAt" label="失效时间" width="180" />
              <el-table-column label="操作" width="120">
                <template #default="{ row }">
                  <el-button link type="danger" @click="removeCart(row.id)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </el-tab-pane>
      </el-tabs>
    </div>

    <el-dialog v-model="addressDialogVisible" :title="editingAddress.id ? '编辑地址' : '新增地址'" width="680px" destroy-on-close>
      <el-form :model="addressForm" label-position="top" class="address-form">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="收货人">
              <el-input v-model="addressForm.receiverName" maxlength="30" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="联系电话">
              <el-input v-model="addressForm.phone" maxlength="20" />
            </el-form-item>
          </el-col>
        </el-row>

        <div class="geo-row">
          <div class="geo-tip">可直接手填地址，也可以用当前位置自动回填省、市、区。</div>
          <el-button text type="primary" :loading="locating" @click="fillCurrentLocation">定位当前位置</el-button>
        </div>

        <el-row :gutter="16">
          <el-col :span="8">
            <el-form-item label="省">
              <el-input v-model="addressForm.province" maxlength="30" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="市">
              <el-input v-model="addressForm.city" maxlength="30" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="区">
              <el-input v-model="addressForm.district" maxlength="30" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="详细地址">
          <el-input
            v-model="addressForm.detailAddress"
            type="textarea"
            :rows="3"
            placeholder="街道、门牌号、楼栋房间号等"
          />
        </el-form-item>

        <el-checkbox v-model="addressForm.isDefault">设为默认地址</el-checkbox>
      </el-form>

      <template #footer>
        <el-button @click="addressDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="addressSaving" @click="saveAddress">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import MallNavbar from '@/components/MallNavbar.vue'
import { useUserStore } from '@/stores/user'
import { getCurrentUser, updateProfile, updatePassword } from '@/api/user'
import { getAddresses, createAddress, updateAddress, deleteAddress, setDefaultAddress } from '@/api/address'
import { getQuoteHistory } from '@/api/quoteHistory'
import { getCartItems, addCartItem, deleteCartItem } from '@/api/cart'
import { reverseGeocode } from '@/api/location'

const router = useRouter()
const userStore = useUserStore()

const formRef = ref(null)
const pwdFormRef = ref(null)
const saving = ref(false)
const pwdSaving = ref(false)
const addressSaving = ref(false)
const locating = ref(false)
const activeTab = ref('profile')
const avatarUrl = ref('')
const addresses = ref([])
const quoteHistory = ref([])
const cartItems = ref([])
const addressDialogVisible = ref(false)
const editingAddress = ref({})

const form = reactive({
  username: '',
  nickname: '',
  email: ''
})

const rules = {
  email: [{ type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }]
}

const pwdForm = reactive({
  oldPwd: '',
  newPwd: '',
  confirmPwd: ''
})

const pwdRules = {
  oldPwd: [{ required: true, message: '请输入当前密码', trigger: 'blur' }],
  newPwd: [{ required: true, message: '请输入新密码', trigger: 'blur' }],
  confirmPwd: [{
    validator: (_rule, value, callback) => {
      if (value !== pwdForm.newPwd) callback(new Error('两次密码输入不一致'))
      else callback()
    },
    trigger: 'blur'
  }]
}

const addressForm = reactive({
  receiverName: '',
  phone: '',
  province: '',
  city: '',
  district: '',
  detailAddress: '',
  isDefault: false
})

const formatAddress = (address) =>
  [address.province, address.city, address.district, address.detailAddress].filter(Boolean).join(' ')

const resetAddressForm = () => {
  Object.assign(addressForm, {
    receiverName: '',
    phone: '',
    province: '',
    city: '',
    district: '',
    detailAddress: '',
    isDefault: addresses.value.length === 0
  })
}

const loadProfile = async () => {
  const user = await getCurrentUser()
  form.username = user.username || ''
  form.nickname = user.nickname || ''
  form.email = user.email || ''
  avatarUrl.value = user.avatar || ''
  userStore.setUserInfo({ ...userStore.userInfo, ...user })
}

const loadExtraData = async () => {
  addresses.value = await getAddresses()
  quoteHistory.value = await getQuoteHistory()
  cartItems.value = await getCartItems()
}

const saveProfile = async () => {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  saving.value = true
  try {
    const user = await updateProfile({ nickname: form.nickname, email: form.email })
    userStore.setUserInfo({ ...userStore.userInfo, ...user })
    ElMessage.success('资料已保存')
  } finally {
    saving.value = false
  }
}

const changePassword = async () => {
  const valid = await pwdFormRef.value.validate().catch(() => false)
  if (!valid) return
  pwdSaving.value = true
  try {
    await updatePassword({ oldPassword: pwdForm.oldPwd, newPassword: pwdForm.newPwd })
    ElMessage.success('密码已修改，请重新登录')
    userStore.clearAuth()
    router.push('/login')
  } finally {
    pwdSaving.value = false
  }
}

const openAddressDialog = (address = null) => {
  editingAddress.value = address || {}
  if (!address) {
    resetAddressForm()
  } else {
    Object.assign(addressForm, {
      receiverName: address.receiverName || '',
      phone: address.phone || '',
      province: address.province || '',
      city: address.city || '',
      district: address.district || '',
      detailAddress: address.detailAddress || '',
      isDefault: Boolean(address.isDefault)
    })
  }
  addressDialogVisible.value = true
}

const fillCurrentLocation = () => {
  if (!navigator.geolocation) {
    ElMessage.warning('当前浏览器不支持定位，请手动填写地址')
    return
  }

  locating.value = true
  navigator.geolocation.getCurrentPosition(
    async (position) => {
      const { latitude, longitude } = position.coords
      try {
        const data = await reverseGeocode({ latitude, longitude })
        addressForm.province = data.province || ''
        addressForm.city = data.city || ''
        addressForm.district = data.district || ''

        if (!addressForm.detailAddress.trim()) {
          addressForm.detailAddress = data.recommendedDetailAddress || data.formattedAddress || ''
        } else if (data.recommendedDetailAddress && !addressForm.detailAddress.includes(data.recommendedDetailAddress)) {
          addressForm.detailAddress = `${data.recommendedDetailAddress} ${addressForm.detailAddress}`.trim()
        }

        ElMessage.success('已根据当前位置自动回填省、市、区')
      } catch (_error) {
        const locationText = `当前位置坐标：${latitude.toFixed(6)}, ${longitude.toFixed(6)}`
        addressForm.detailAddress = addressForm.detailAddress
          ? `${addressForm.detailAddress}\n${locationText}`
          : locationText
        ElMessage.warning('定位成功，但地址解析失败，已写入坐标供你补充')
      } finally {
        locating.value = false
      }
    },
    () => {
      locating.value = false
      ElMessage.warning('定位失败，请检查浏览器定位权限后重试')
    },
    { enableHighAccuracy: true, timeout: 8000 }
  )
}

const saveAddress = async () => {
  if (!addressForm.receiverName.trim()) {
    ElMessage.warning('请填写收货人')
    return
  }
  if (!addressForm.phone.trim()) {
    ElMessage.warning('请填写联系电话')
    return
  }
  if (!addressForm.detailAddress.trim()) {
    ElMessage.warning('请填写详细地址')
    return
  }

  addressSaving.value = true
  try {
    const payload = {
      receiverName: addressForm.receiverName.trim(),
      phone: addressForm.phone.trim(),
      province: addressForm.province.trim(),
      city: addressForm.city.trim(),
      district: addressForm.district.trim(),
      detailAddress: addressForm.detailAddress.trim(),
      isDefault: Boolean(addressForm.isDefault)
    }

    if (editingAddress.value.id) {
      await updateAddress(editingAddress.value.id, payload)
    } else {
      await createAddress(payload)
    }

    addressDialogVisible.value = false
    addresses.value = await getAddresses()
    ElMessage.success('地址已保存')
  } finally {
    addressSaving.value = false
  }
}

const makeDefault = async (id) => {
  await setDefaultAddress(id)
  addresses.value = await getAddresses()
}

const removeAddress = async (id) => {
  await deleteAddress(id)
  addresses.value = await getAddresses()
}

const reuseQuote = (row) => {
  localStorage.setItem('quote_reuse_payload', JSON.stringify({
    categoryId: row.categoryId,
    rawFormData: row.rawFormData
  }))
  router.push({ path: '/mall', query: { categoryId: row.categoryId } })
}

const reAddToCart = async (row) => {
  await addCartItem({
    categoryId: row.categoryId,
    productName: row.productName,
    formData: row.formData,
    price: row.price
  })
  ElMessage.success('已重新加入购物车')
  cartItems.value = await getCartItems()
  window.dispatchEvent(new CustomEvent('cart-updated'))
}

const removeCart = async (id) => {
  await deleteCartItem(id)
  cartItems.value = await getCartItems()
}

onMounted(async () => {
  await loadProfile()
  await loadExtraData()
})
</script>

<style scoped>
.profile-page {
  min-height: 100vh;
  background: radial-gradient(circle at top, #fff7ed 0%, #f8fafc 22%, #f1f5f9 100%);
}

.page-body {
  max-width: 1180px;
  margin: 0 auto;
  padding: 28px 24px 64px;
}

.profile-hero {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
  padding: 30px 32px;
  border-radius: 26px;
  background: linear-gradient(135deg, #0f172a, #1e293b);
  color: #fff;
  box-shadow: 0 20px 40px rgba(15, 23, 42, 0.14);
  margin-bottom: 22px;
}

.hero-kicker {
  display: inline-block;
  font-size: 11px;
  letter-spacing: 1.6px;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.62);
  margin-bottom: 10px;
}

.hero-copy h1 {
  margin: 0;
  font-size: 34px;
  font-weight: 800;
}

.hero-copy p {
  margin: 8px 0 0;
  color: rgba(255, 255, 255, 0.7);
}

.hero-user {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 14px 18px;
  border-radius: 22px;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.12);
}

.hero-user-name {
  font-size: 18px;
  font-weight: 700;
}

.hero-user-sub {
  margin-top: 4px;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.64);
}

.profile-tabs :deep(.el-tabs__nav-wrap::after) {
  display: none;
}

.profile-tabs :deep(.el-tabs__item) {
  height: 42px;
  padding: 0 20px;
  font-weight: 700;
}

.profile-tabs :deep(.el-tabs__active-bar) {
  height: 3px;
  border-radius: 999px;
}

.panel-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 18px;
}

.soft-card {
  border-radius: 22px;
  border: 1px solid rgba(226, 232, 240, 0.9);
}

.card-header,
.address-top,
.address-actions,
.geo-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.empty-address {
  padding: 12px 0;
}

.address-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.address-item {
  border: 1px solid #e2e8f0;
  border-radius: 18px;
  padding: 16px;
  background: linear-gradient(180deg, #fff, #fbfdff);
}

.address-item.active {
  border-color: #86efac;
  background: linear-gradient(180deg, #f0fdf4, #f7fee7);
}

.address-owner {
  display: flex;
  align-items: center;
  gap: 10px;
}

.address-owner span {
  color: #64748b;
  font-size: 13px;
}

.address-item p {
  margin: 14px 0;
  line-height: 1.7;
  color: #475569;
  min-height: 44px;
}

.address-form {
  padding-top: 4px;
}

.geo-row {
  margin-bottom: 12px;
  gap: 12px;
}

.geo-tip {
  font-size: 12px;
  line-height: 1.5;
  color: #64748b;
}

@media (max-width: 900px) {
  .profile-hero,
  .panel-grid,
  .address-grid {
    grid-template-columns: 1fr;
    flex-direction: column;
    align-items: flex-start;
  }

  .hero-user {
    width: 100%;
  }
}
</style>
