<template>
  <el-menu mode="horizontal" :ellipsis="false" class="top-navbar">
    <div class="logo" @click="router.push('/mall')" style="cursor: pointer">
      <el-icon :size="24" color="#f72a44"><Printer /></el-icon>
      <span>印刷包装在线报价系统</span>
    </div>
    <div class="flex-grow" />
    <el-menu-item index="1" @click="router.push('/mall')"
      >产品大厅</el-menu-item
    >
    <el-menu-item index="2">我的订单</el-menu-item>
    <el-menu-item index="3">帮助中心</el-menu-item>

    <div class="nav-actions">
      <el-badge
        :value="cartItems.length"
        :hidden="cartItems.length === 0"
        type="danger"
      >
        <el-button
          plain
          round
          :icon="ShoppingCart"
          @click="drawerVisible = true"
          >购物车</el-button
        >
      </el-badge>

      <template v-if="userStore.token">
        <el-dropdown>
          <el-button type="primary" plain round>
            {{ userStore.userInfo?.username }}
            <el-icon class="el-icon--right"><ArrowDown /></el-icon>
          </el-button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item
                v-if="userStore.userInfo?.role === 'ADMIN'"
                @click="router.push('/admin')"
                >进入管理后台</el-dropdown-item
              >
              <el-dropdown-item @click="handleLogout"
                >退出登录</el-dropdown-item
              >
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </template>
      <template v-else>
        <el-button type="danger" round @click="router.push('/login')"
          >登录 / 注册</el-button
        >
      </template>
    </div>
  </el-menu>

  <el-drawer v-model="drawerVisible" direction="rtl" size="440px">
    <template #header>
      <div class="drawer-header">
        <el-icon :size="20"><ShoppingCart /></el-icon>
        <span>购物车（{{ cartItems.length }} 件）</span>
      </div>
    </template>

    <el-empty
      v-if="cartItems.length === 0"
      description="购物车是空的，快去选购吧~"
    />

    <div v-else class="cart-list">
      <div v-for="item in cartItems" :key="item.id" class="cart-item">
        <div class="cart-item-head">
          <span class="item-name">{{ item.productName }}</span>
          <el-button
            type="danger"
            link
            :icon="Delete"
            @click="handleRemove(item.id)"
          />
        </div>

        <div class="countdown" :class="{ urgent: getRemaining(item) < 60 }">
          <el-icon><Timer /></el-icon>
          <span>{{ formatRemaining(item) }} 后失效</span>
        </div>

        <div class="item-config">
          <template v-for="(val, key) in item.formData" :key="key">
            <div v-if="isPlainObject(val)" class="config-section-title">
              {{ key }}
            </div>
            <template v-if="isPlainObject(val)">
              <div
                v-for="(subVal, subKey) in val"
                :key="`${key}_${subKey}`"
                class="config-row"
              >
                <span class="config-key">{{ subKey }}</span>
                <span class="config-val">{{
                  Array.isArray(subVal) ? subVal.join("、") : subVal
                }}</span>
              </div>
            </template>
            <div v-else class="config-row">
              <span class="config-key">{{ key }}</span>
              <span class="config-val">{{
                Array.isArray(val) ? val.join("、") : val
              }}</span>
            </div>
          </template>
        </div>

        <div class="item-price">
          预计单价：<strong>¥ {{ item.price }}</strong>
        </div>
      </div>
    </div>

    <template #footer>
      <div class="cart-footer" v-if="cartItems.length > 0">
        <div class="total-info">
          <span>共 {{ cartItems.length }} 项</span>
          <span class="total-price"
            >合计：<strong>¥ {{ totalPrice }}</strong></span
          >
        </div>
        <div class="footer-btns">
          <el-button @click="handleClearAll">清空购物车</el-button>
          <el-button type="danger">提交全部订单</el-button>
        </div>
      </div>
    </template>
  </el-drawer>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref } from "vue";
import { useRouter } from "vue-router";
import {
  Printer,
  ShoppingCart,
  Delete,
  Timer,
  ArrowDown,
} from "@element-plus/icons-vue";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  getCartItems,
  deleteCartItem,
  clearCart as clearCartApi,
} from "@/api/cart";
import { useUserStore } from "@/stores/user";

const router = useRouter();
const userStore = useUserStore();
const drawerVisible = ref(false);
const cartItems = ref([]);
const now = ref(Date.now());

const totalPrice = computed(() =>
  cartItems.value
    .reduce((sum, i) => sum + parseFloat(i.price || 0), 0)
    .toFixed(2),
);
const isPlainObject = (value) =>
  value !== null && typeof value === "object" && !Array.isArray(value);

const getRemaining = (item) =>
  Math.max(
    0,
    Math.floor((new Date(item.expiresAt).getTime() - now.value) / 1000),
  );
const formatRemaining = (item) => {
  const s = getRemaining(item);
  return `${Math.floor(s / 60)
    .toString()
    .padStart(2, "0")}:${(s % 60).toString().padStart(2, "0")}`;
};

const fetchCart = async () => {
  try {
    cartItems.value = (await getCartItems()) || [];
  } catch {}
};

const handleRemove = async (id) => {
  await deleteCartItem(id);
  cartItems.value = cartItems.value.filter((i) => i.id !== id);
};

const handleClearAll = () => {
  ElMessageBox.confirm("确认清空所有暂存记录？", "提示", {
    type: "warning",
  }).then(async () => {
    await clearCartApi();
    cartItems.value = [];
    ElMessage.success("已清空暂存箱");
  });
};

const handleLogout = () => {
  userStore.clearAuth();
  router.push("/login");
};

let ticker = null;
onMounted(() => {
  fetchCart();
  ticker = setInterval(() => {
    now.value = Date.now();
    const before = cartItems.value.length;
    cartItems.value = cartItems.value.filter((i) => getRemaining(i) > 0);
    if (cartItems.value.length < before)
      ElMessage.warning("部分暂存报价已超时失效");
  }, 1000);
  window.addEventListener("cart-updated", fetchCart);
});

onUnmounted(() => {
  clearInterval(ticker);
  window.removeEventListener("cart-updated", fetchCart);
});

defineExpose({
  openDrawer: () => {
    drawerVisible.value = true;
  },
});
</script>

<style scoped>
.top-navbar {
  padding: 0 40px;
  border-bottom: 2px solid #f72a44;
  height: 64px;
  align-items: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  background-color: #ffffff;
}
.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 20px;
  font-weight: bold;
  color: #303133;
}
.flex-grow {
  flex-grow: 1;
}
.nav-actions {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-left: 30px;
}

.drawer-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 17px;
  font-weight: bold;
}
.cart-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.cart-item {
  background: #f8f9fc;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  padding: 14px 16px;
}
.cart-item-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}
.item-name {
  font-size: 15px;
  font-weight: bold;
  color: #303133;
}
.countdown {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 13px;
  color: #67c23a;
  margin-bottom: 10px;
  font-weight: 500;
}
.countdown.urgent {
  color: #f72a44;
  animation: pulse 1s infinite;
}
@keyframes pulse {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}
.item-config {
  font-size: 13px;
  color: #606266;
  margin-bottom: 10px;
}
.config-section-title {
  margin-top: 6px;
  font-weight: 700;
  color: #303133;
}
.config-row {
  display: flex;
  justify-content: space-between;
  padding: 3px 0;
  border-bottom: 1px dashed #ebeef5;
}
.config-key {
  color: #909399;
}
.config-val {
  color: #303133;
  font-weight: 500;
}
.item-price {
  font-size: 14px;
  color: #f72a44;
}
.item-price strong {
  font-size: 18px;
}
.cart-footer {
  padding: 16px 0 0;
  border-top: 1px solid #ebeef5;
}
.total-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  font-size: 14px;
  color: #606266;
}
.total-price {
  font-size: 16px;
}
.total-price strong {
  font-size: 22px;
  color: #f72a44;
}
.footer-btns {
  display: flex;
  gap: 10px;
}
.footer-btns .el-button {
  flex: 1;
}
</style>
