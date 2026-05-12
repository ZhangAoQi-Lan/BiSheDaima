<template>
  <header class="mall-navbar">
    <div class="nav-inner">
      <div class="brand" @click="router.push('/mall')">
        <div class="brand-mark">
          <el-icon :size="18"><Printer /></el-icon>
        </div>
        <div class="brand-copy">
          <span class="brand-title">印刷包装在线报价</span>
          <span class="brand-sub">Printing Quote Platform</span>
        </div>
      </div>

      <nav class="nav-links">
        <router-link to="/mall" class="nav-link">产品大厅</router-link>
        <router-link to="/mall/orders" class="nav-link">我的订单</router-link>
        <router-link to="/mall/help" class="nav-link">帮助中心</router-link>
        <router-link to="/mall/profile" class="nav-link">个人中心</router-link>
      </nav>

      <div class="nav-actions">
        <el-badge :value="cartItems.length" :hidden="cartItems.length === 0">
          <button class="icon-btn cart-btn" @click="openDrawer">
            <el-icon :size="18"><ShoppingCart /></el-icon>
          </button>
        </el-badge>

        <el-dropdown>
          <button class="user-pill">
            <el-avatar :size="34" :src="userStore.userInfo?.avatar" icon="UserFilled" />
            <div class="user-copy">
              <span class="user-label">{{ userStore.userInfo?.nickname || userStore.userInfo?.username }}</span>
              <span class="user-role">已登录</span>
            </div>
            <el-icon :size="12"><ArrowDown /></el-icon>
          </button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item @click="router.push('/mall/profile')">个人中心</el-dropdown-item>
              <el-dropdown-item divided @click="logout">退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>
  </header>

  <el-drawer v-model="drawerVisible" direction="rtl" size="460px" :with-header="false">
    <div class="drawer-wrap">
      <div class="drawer-header">
        <div>
          <div class="drawer-title">购物车 / 暂存箱</div>
          <div class="drawer-subtitle">当前共 {{ cartItems.length }} 项报价内容</div>
        </div>
        <el-button link @click="drawerVisible = false">关闭</el-button>
      </div>

      <div v-if="cartItems.length === 0" class="empty-box">
        <el-empty description="还没有加入购物车的报价商品" />
      </div>

      <div v-else class="cart-list">
        <div v-for="item in cartItems" :key="item.id" class="cart-card">
          <div class="card-top">
            <div>
              <div class="product-name">{{ item.productName }}</div>
              <div class="expire-text">剩余保留时间 {{ formatRemaining(item) }}</div>
            </div>
            <el-button link type="danger" @click="removeItem(item.id)">删除</el-button>
          </div>

          <div class="spec-list">
            <span v-for="(spec, index) in getSpecs(item)" :key="index" class="spec-chip">{{ spec }}</span>
          </div>

          <div class="card-bottom">
            <span class="price-text">¥{{ item.price }}</span>
          </div>
        </div>
      </div>

      <div v-if="cartItems.length > 0" class="drawer-footer">
        <div class="footer-total">
          <span>合计</span>
          <strong>¥{{ totalPrice }}</strong>
        </div>
        <div class="footer-actions">
          <el-button @click="clearAll">清空</el-button>
          <el-button type="primary" :loading="submitting" @click="openCheckout">去结算</el-button>
        </div>
      </div>
    </div>
  </el-drawer>

  <el-dialog v-model="checkoutVisible" title="确认订单" width="700px">
    <div class="checkout-section">
      <div class="section-header">
        <div class="section-title">选择收货地址</div>
        <el-button type="primary" plain @click="openAddressDialog()">新增地址</el-button>
      </div>

      <div v-if="addresses.length === 0" class="address-empty">
        <el-empty description="还没有收货地址，先在这里新增即可" :image-size="72" />
        <div class="empty-actions">
          <el-button type="primary" @click="openAddressDialog()">新增地址</el-button>
          <el-button @click="router.push('/mall/profile')">去个人中心管理</el-button>
        </div>
      </div>

      <div v-else class="address-list">
        <label
          v-for="address in addresses"
          :key="address.id"
          class="address-card"
          :class="{ active: selectedAddressId === address.id }"
        >
          <input v-model="selectedAddressId" type="radio" :value="address.id" />
          <div class="address-content">
            <div class="address-head">
              <span>{{ address.receiverName }}</span>
              <span>{{ address.phone }}</span>
              <el-tag v-if="address.isDefault" size="small" type="success">默认</el-tag>
            </div>
            <div class="address-body">{{ formatAddress(address) }}</div>
          </div>
        </label>
      </div>
    </div>

    <el-form label-position="top">
      <el-form-item label="设计稿名称">
        <el-input
          v-model="artworkName"
          maxlength="120"
          placeholder="例如：名片正反面设计稿.pdf"
        />
      </el-form-item>
      <el-form-item label="设计稿链接">
        <el-input
          v-model="artworkUrl"
          maxlength="500"
          placeholder="可填写网盘链接、MinIO 文件地址或留空后续补充"
        />
      </el-form-item>
      <el-form-item label="订单备注">
        <el-input
          v-model="remark"
          type="textarea"
          :rows="3"
          placeholder="如有特殊工艺、交付要求可在此补充"
        />
      </el-form-item>
    </el-form>

    <template #footer>
      <el-button @click="checkoutVisible = false">取消</el-button>
      <el-button type="primary" :loading="submitting" @click="submitOrder">提交订单</el-button>
    </template>
  </el-dialog>

  <el-dialog v-model="addressDialogVisible" title="新增地址" width="680px" destroy-on-close>
    <el-form label-position="top" class="address-form">
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
      <el-button type="primary" :loading="savingAddress" @click="saveAddress">保存</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowDown, Printer, ShoppingCart } from '@element-plus/icons-vue'
import { getCartItems, deleteCartItem, clearCart as clearCartApi } from '@/api/cart'
import { createOrder } from '@/api/order'
import { createAddress, getAddresses } from '@/api/address'
import { reverseGeocode } from '@/api/location'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

const drawerVisible = ref(false)
const checkoutVisible = ref(false)
const addressDialogVisible = ref(false)
const cartItems = ref([])
const addresses = ref([])
const selectedAddressId = ref(null)
const remark = ref('')
const artworkName = ref('')
const artworkUrl = ref('')
const submitting = ref(false)
const savingAddress = ref(false)
const locating = ref(false)
const now = ref(Date.now())

const addressForm = reactive({
  receiverName: '',
  phone: '',
  province: '',
  city: '',
  district: '',
  detailAddress: '',
  isDefault: false
})

const totalPrice = computed(() => cartItems.value.reduce((sum, item) => sum + Number(item.price || 0), 0).toFixed(2))

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

const openDrawer = async () => {
  await fetchCart()
  drawerVisible.value = true
}

const fetchCart = async () => {
  cartItems.value = await getCartItems()
}

const fetchAddresses = async () => {
  addresses.value = await getAddresses()
  const defaultAddress = addresses.value.find(item => item.isDefault) || addresses.value[0]
  selectedAddressId.value = defaultAddress?.id || null
}

const removeItem = async (id) => {
  await deleteCartItem(id)
  cartItems.value = cartItems.value.filter(item => item.id !== id)
  window.dispatchEvent(new CustomEvent('cart-updated'))
}

const clearAll = async () => {
  await ElMessageBox.confirm('确认清空购物车中的所有报价商品吗？', '提示', { type: 'warning' })
  await clearCartApi()
  cartItems.value = []
  window.dispatchEvent(new CustomEvent('cart-updated'))
}

const openCheckout = async () => {
  await fetchAddresses()
  checkoutVisible.value = true
}

const openAddressDialog = () => {
  resetAddressForm()
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

  savingAddress.value = true
  try {
    const created = await createAddress({
      receiverName: addressForm.receiverName.trim(),
      phone: addressForm.phone.trim(),
      province: addressForm.province.trim(),
      city: addressForm.city.trim(),
      district: addressForm.district.trim(),
      detailAddress: addressForm.detailAddress.trim(),
      isDefault: Boolean(addressForm.isDefault)
    })
    await fetchAddresses()
    selectedAddressId.value = created?.id || selectedAddressId.value
    addressDialogVisible.value = false
    ElMessage.success('地址已保存')
  } finally {
    savingAddress.value = false
  }
}

const submitOrder = async () => {
  if (!selectedAddressId.value) {
    ElMessage.warning('请先选择收货地址')
    return
  }
  submitting.value = true
  try {
    await createOrder({
      addressId: selectedAddressId.value,
      remark: remark.value,
      artworkName: artworkName.value,
      artworkUrl: artworkUrl.value
    })
    ElMessage.success('订单提交成功')
    remark.value = ''
    artworkName.value = ''
    artworkUrl.value = ''
    checkoutVisible.value = false
    drawerVisible.value = false
    cartItems.value = []
    window.dispatchEvent(new CustomEvent('cart-updated'))
    router.push('/mall/orders')
  } finally {
    submitting.value = false
  }
}

const formatAddress = (address) => [address.province, address.city, address.district, address.detailAddress].filter(Boolean).join(' ')

const getRemainingSeconds = (item) => Math.max(0, Math.floor((new Date(item.expiresAt).getTime() - now.value) / 1000))

const formatRemaining = (item) => {
  const seconds = getRemainingSeconds(item)
  const minutes = String(Math.floor(seconds / 60)).padStart(2, '0')
  const remain = String(seconds % 60).padStart(2, '0')
  return `${minutes}:${remain}`
}

const getSpecs = (item) => {
  const result = []
  const walk = (obj) => {
    Object.entries(obj || {}).forEach(([key, value]) => {
      if (value && typeof value === 'object' && !Array.isArray(value)) {
        walk(value)
      } else if (result.length < 4) {
        result.push(`${key}: ${Array.isArray(value) ? value.join('、') : value}`)
      }
    })
  }
  walk(item.formData)
  return result
}

const logout = () => {
  userStore.clearAuth()
  router.push('/login')
}

let timer = null

const handleCheckoutNow = async () => {
  await openDrawer()
  await openCheckout()
}

onMounted(() => {
  fetchCart()
  timer = setInterval(() => {
    now.value = Date.now()
    cartItems.value = cartItems.value.filter(item => getRemainingSeconds(item) > 0)
  }, 1000)
  window.addEventListener('cart-updated', fetchCart)
  window.addEventListener('checkout-now', handleCheckoutNow)
})

onUnmounted(() => {
  clearInterval(timer)
  window.removeEventListener('cart-updated', fetchCart)
  window.removeEventListener('checkout-now', handleCheckoutNow)
})
</script>

<style scoped>
.mall-navbar {
  position: sticky;
  top: 0;
  z-index: 1000;
  border-bottom: 1px solid rgba(15, 23, 42, 0.06);
  background:
    linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(255, 255, 255, 0.9));
  backdrop-filter: blur(18px);
}

.nav-inner {
  max-width: 1380px;
  margin: 0 auto;
  min-height: 72px;
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 0 24px;
}

.brand {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  flex-shrink: 0;
}

.brand-mark {
  width: 42px;
  height: 42px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  background: linear-gradient(135deg, #ef4444, #f97316);
  box-shadow: 0 10px 20px rgba(249, 115, 22, 0.2);
}

.brand-copy {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.brand-title {
  font-size: 17px;
  font-weight: 800;
  color: #0f172a;
}

.brand-sub {
  font-size: 11px;
  color: #94a3b8;
}

.nav-links {
  flex: 1;
  display: flex;
  justify-content: center;
  gap: 10px;
}

.nav-link {
  padding: 10px 14px;
  border-radius: 999px;
  color: #475569;
  text-decoration: none;
  font-size: 14px;
  font-weight: 700;
  transition: all 0.2s ease;
}

.nav-link:hover {
  color: #0f172a;
  background: rgba(248, 250, 252, 0.9);
}

.nav-link.router-link-active {
  color: #ea580c;
  background: rgba(255, 237, 213, 0.9);
}

.nav-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.icon-btn,
.user-pill {
  border: none;
  cursor: pointer;
}

.icon-btn {
  width: 44px;
  height: 44px;
  border-radius: 14px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: #fff;
  color: #334155;
  box-shadow: 0 8px 20px rgba(15, 23, 42, 0.06);
}

.user-pill {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 5px 12px 5px 5px;
  border-radius: 999px;
  background: #fff;
  box-shadow: 0 8px 20px rgba(15, 23, 42, 0.06);
}

.user-copy {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  line-height: 1.2;
}

.user-label {
  font-size: 13px;
  font-weight: 700;
  color: #1e293b;
}

.user-role {
  font-size: 11px;
  color: #94a3b8;
}

.drawer-wrap {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.drawer-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 16px;
  border-bottom: 1px solid #e2e8f0;
}

.drawer-title {
  font-size: 20px;
  font-weight: 800;
  color: #0f172a;
}

.drawer-subtitle {
  margin-top: 4px;
  font-size: 12px;
  color: #64748b;
}

.cart-list {
  flex: 1;
  overflow: auto;
  padding: 18px 0;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.cart-card {
  border: 1px solid #e2e8f0;
  border-radius: 18px;
  padding: 16px;
  background: linear-gradient(180deg, #fff, #fcfdff);
}

.card-top,
.card-bottom,
.drawer-footer,
.footer-actions,
.address-head,
.section-header,
.empty-actions,
.geo-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.product-name {
  font-size: 15px;
  font-weight: 800;
  color: #0f172a;
}

.expire-text {
  margin-top: 6px;
  font-size: 12px;
  color: #ef4444;
}

.spec-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin: 14px 0;
}

.spec-chip {
  font-size: 12px;
  color: #475569;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 999px;
  padding: 5px 10px;
}

.price-text {
  font-size: 20px;
  font-weight: 800;
  color: #ea580c;
}

.drawer-footer {
  border-top: 1px solid #e2e8f0;
  padding-top: 16px;
}

.footer-total {
  color: #64748b;
}

.footer-total strong {
  margin-left: 8px;
  font-size: 24px;
  color: #ea580c;
}

.footer-actions {
  gap: 10px;
}

.checkout-section {
  margin-bottom: 18px;
}

.section-title {
  font-size: 15px;
  font-weight: 800;
  color: #0f172a;
}

.address-empty {
  padding: 10px 0 4px;
}

.empty-actions {
  justify-content: center;
  gap: 12px;
}

.address-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.address-card {
  display: flex;
  gap: 12px;
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  padding: 14px;
  cursor: pointer;
  background: #fff;
  transition: all 0.2s ease;
}

.address-card:hover {
  border-color: #fdba74;
  box-shadow: 0 10px 20px rgba(249, 115, 22, 0.08);
}

.address-card.active {
  border-color: #f97316;
  background: #fff7ed;
}

.address-card input {
  margin-top: 4px;
}

.address-content {
  flex: 1;
}

.address-body {
  margin-top: 8px;
  font-size: 13px;
  line-height: 1.7;
  color: #475569;
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

@media (max-width: 980px) {
  .nav-inner {
    flex-wrap: wrap;
    padding: 14px 20px;
  }

  .nav-links {
    order: 3;
    width: 100%;
    justify-content: flex-start;
    overflow: auto;
    padding-bottom: 4px;
  }
}
</style>
