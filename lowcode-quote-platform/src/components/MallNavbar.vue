<template>
  <header class="mall-navbar">
    <div class="nav-inner">
      <div class="logo" @click="router.push('/mall')">
        <div class="logo-icon">
          <el-icon :size="22" color="#fff"><Printer /></el-icon>
        </div>
        <span class="logo-text">印刷包装在线报价</span>
      </div>

      <nav class="nav-links">
        <router-link to="/mall" class="nav-link" exact-active-class="active">
          <span>产品大厅</span>
          <div class="nav-underline" />
        </router-link>
        <router-link to="/mall/orders" class="nav-link" active-class="active">
          <span>我的订单</span>
          <div class="nav-underline" />
        </router-link>
        <router-link to="/mall/help" class="nav-link" active-class="active">
          <span>帮助中心</span>
          <div class="nav-underline" />
        </router-link>
      </nav>

      <div class="nav-actions">
        <div class="cart-btn-wrap">
          <el-badge :value="cartItems.length" :hidden="cartItems.length === 0" :max="99">
            <button class="cart-btn" @click="drawerVisible = true">
              <el-icon :size="20"><ShoppingCart /></el-icon>
              <span v-if="cartItems.length" class="cart-count-bubble">{{ cartItems.length }}</span>
            </button>
          </el-badge>
        </div>

        <template v-if="userStore.token">
          <el-dropdown trigger="click">
            <button class="user-btn">
              <el-avatar :size="30" :src="userStore.userInfo?.avatar" icon="UserFilled" />
              <span class="user-name">{{ userStore.userInfo?.nickname || userStore.userInfo?.username }}</span>
              <el-icon :size="12" class="user-chevron"><ArrowDown /></el-icon>
            </button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="router.push('/mall/profile')">
                  <el-icon><User /></el-icon>
                  个人设置
                </el-dropdown-item>
                <el-dropdown-item divided @click="handleLogout">
                  <el-icon><SwitchButton /></el-icon>
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </template>
        <template v-else>
          <button class="login-btn" @click="router.push('/login')">登录 / 注册</button>
        </template>
      </div>
    </div>
  </header>

  <el-drawer v-model="drawerVisible" direction="rtl" size="460px" :with-header="false">
    <div class="cart-drawer-wrap">
      <!-- 自定义头部 -->
      <div class="cart-drawer-head">
        <div class="drawer-head-left">
          <div class="head-icon">
            <el-icon :size="18" color="#fff"><ShoppingCart /></el-icon>
          </div>
          <span class="head-title">暂存箱</span>
          <span class="head-count" v-if="cartItems.length">{{ cartItems.length }} 项</span>
        </div>
        <el-button link @click="drawerVisible = false">
          <el-icon :size="18"><Close /></el-icon>
        </el-button>
      </div>

      <!-- 空状态 -->
      <div v-if="cartItems.length === 0" class="cart-empty-premium">
        <div class="empty-gradient-bg">
          <div class="empty-icon-circle">
            <el-icon :size="44" color="#c0c4cc"><ShoppingCart /></el-icon>
          </div>
          <h3>暂存箱空空如也</h3>
          <p>快去定制您的专属印刷品吧</p>
          <el-button type="danger" round @click="drawerVisible = false; router.push('/mall')">
            去产品大厅选购
          </el-button>
        </div>
      </div>

      <!-- 列表 -->
      <div v-else class="cart-drawer-list">
        <div v-for="item in cartItems" :key="item.id" class="cart-premium-card">
          <div class="card-top">
            <div class="card-product-name">{{ item.productName }}</div>
            <el-button link type="danger" :icon="Delete" size="small" @click="handleRemove(item.id)" />
          </div>

          <div class="card-countdown" :class="{ urgent: getRemaining(item) < 60 }">
            <el-icon :size="13"><Timer /></el-icon>
            <span>{{ formatRemaining(item) }} 后失效</span>
          </div>

          <!-- 核心规格（始终展示） -->
          <div class="card-core-specs">
            <span v-for="(spec, idx) in getCoreSpecs(item)" :key="idx" class="spec-chip">
              {{ spec }}
            </span>
          </div>

          <!-- 展开/收起完整配置 -->
          <transition name="expand-fade">
            <div v-if="expandedItemId === item.id" class="card-full-config">
              <template v-for="(val, key) in item.formData" :key="key">
                <template v-if="isPlainObject(val)">
                  <div class="cfg-section">{{ key }}</div>
                  <div v-for="(sv, sk) in val" :key="sk" class="cfg-row">
                    <span>{{ sk }}</span>
                    <span>{{ Array.isArray(sv) ? sv.join('、') : sv }}</span>
                  </div>
                </template>
                <div v-else class="cfg-row">
                  <span>{{ key }}</span>
                  <span>{{ Array.isArray(val) ? val.join('、') : val }}</span>
                </div>
              </template>
            </div>
          </transition>

          <div class="card-bottom">
            <el-button link type="primary" size="small" @click="toggleItemExpand(item.id)">
              {{ expandedItemId === item.id ? '收起详情' : '配置详情' }}
              <el-icon :class="{ rotated: expandedItemId === item.id }"><ArrowDown /></el-icon>
            </el-button>
            <span class="card-price">¥ <strong>{{ item.price }}</strong></span>
          </div>
        </div>
      </div>

      <!-- 底部结算（毛玻璃） -->
      <div class="cart-drawer-foot" v-if="cartItems.length > 0">
        <div class="foot-summary">
          <span>共 {{ cartItems.length }} 项</span>
          <span class="foot-total">合计 <strong>¥ {{ totalPrice }}</strong></span>
        </div>
        <div class="foot-actions">
          <el-button class="clear-all-btn" @click="handleClearAll">清空</el-button>
          <button class="submit-order-btn" :disabled="submitting" @click="handleSubmitOrders">
            <span v-if="submitting" class="btn-loading" />
            <span v-else>提交全部订单</span>
          </button>
        </div>
      </div>
    </div>
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
  SwitchButton,
  User,
  UserFilled,
  Close,
} from "@element-plus/icons-vue";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  getCartItems,
  deleteCartItem,
  clearCart as clearCartApi,
} from "@/api/cart";
import { createOrder } from "@/api/order";
import { useUserStore } from "@/stores/user";

const router = useRouter();
const userStore = useUserStore();
const drawerVisible = ref(false);
const cartItems = ref([]);
const now = ref(Date.now());
const submitting = ref(false);
const expandedItemId = ref(null);

const totalPrice = computed(() =>
  cartItems.value
    .reduce((sum, i) => sum + parseFloat(i.price || 0), 0)
    .toFixed(2),
);
const isPlainObject = (value) =>
  value !== null && typeof value === "object" && !Array.isArray(value);

const toggleItemExpand = (id) => {
  expandedItemId.value = expandedItemId.value === id ? null : id;
};

const getCoreSpecs = (item) => {
  if (!item.formData) return [];
  const specs = [];
  const extract = (obj) => {
    for (const [k, v] of Object.entries(obj)) {
      if (isPlainObject(v)) {
        extract(v);
      } else if (!Array.isArray(v) && typeof v !== 'object') {
        const label = String(k).length > 8 ? String(k).slice(0, 6) + '..' : String(k);
        specs.push(`${label}: ${v}`);
      }
    }
  };
  extract(item.formData);
  return specs.slice(0, 4);
};

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

const handleSubmitOrders = async () => {
  if (cartItems.value.length === 0) {
    ElMessage.warning("暂存箱为空，请先配置报价并加入暂存箱");
    return;
  }
  try {
    submitting.value = true;
    await createOrder();
    cartItems.value = [];
    drawerVisible.value = false;
    ElMessage.success("订单提交成功");
    router.push("/mall/orders");
  } catch {
    ElMessage.error("订单提交失败，请重试");
  } finally {
    submitting.value = false;
  }
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
/* ===== 玻璃拟态导航栏 ===== */
.mall-navbar {
  position: sticky;
  top: 0;
  z-index: 1000;
  height: 60px;
  background: rgba(255,255,255,.78);
  backdrop-filter: blur(18px) saturate(140%);
  -webkit-backdrop-filter: blur(18px) saturate(140%);
  border-bottom: 1px solid rgba(0,0,0,.06);
  box-shadow: 0 1px 8px rgba(0,0,0,.04);
}
.nav-inner {
  max-width: 1400px;
  margin: 0 auto;
  height: 100%;
  display: flex;
  align-items: center;
  padding: 0 28px;
  gap: 8px;
}

/* Logo */
.logo {
  display: flex;
  align-items: center;
  gap: 9px;
  cursor: pointer;
  flex-shrink: 0;
  margin-right: 24px;
}
.logo-icon {
  width: 34px;
  height: 34px;
  border-radius: 10px;
  background: linear-gradient(135deg, #f72a44, #d32035);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 8px rgba(247,42,68,.3);
}
.logo-text {
  font-size: 16px;
  font-weight: 700;
  color: #1a1a2e;
  letter-spacing: -.2px;
}

/* 导航链接 + 动态下划线 */
.nav-links {
  display: flex;
  gap: 4px;
  flex: 1;
}
.nav-link {
  position: relative;
  padding: 8px 16px;
  font-size: 14px;
  font-weight: 500;
  color: var(--gray-500);
  text-decoration: none;
  border-radius: 8px;
  transition: color .2s, background .2s;
  cursor: pointer;
}
.nav-link:hover { color: var(--color-primary); background: var(--color-primary-light); }
.nav-link.active { color: var(--color-primary); font-weight: 600; }
.nav-link.active .nav-underline {
  position: absolute;
  bottom: -2px;
  left: 50%;
  transform: translateX(-50%);
  width: 20px;
  height: 3px;
  background: var(--color-primary);
  border-radius: 2px;
  transition: width .3s var(--ease-out);
}
.nav-link:hover .nav-underline { width: 28px; }

/* 右侧操作 */
.nav-actions {
  display: flex;
  align-items: center;
  gap: 14px;
  flex-shrink: 0;
}

/* 购物车按钮 */
.cart-btn {
  position: relative;
  width: 38px;
  height: 38px;
  border-radius: 50%;
  border: none;
  background: var(--gray-100);
  color: var(--gray-600);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all .25s var(--ease-out);
}
.cart-btn:hover {
  background: var(--color-primary-light);
  color: var(--color-primary);
  transform: scale(1.08);
}
.cart-count-bubble {
  position: absolute;
  top: -4px;
  right: -6px;
  min-width: 18px;
  height: 18px;
  border-radius: 9px;
  background: var(--color-primary);
  color: #fff;
  font-size: 10px;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 4px;
  animation: badge-pop .3s var(--ease-out);
}
@keyframes badge-pop {
  0%   { transform: scale(.5); opacity: 0; }
  60%  { transform: scale(1.15); }
  100% { transform: scale(1); opacity: 1; }
}

/* 用户按钮 */
.user-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 4px 14px 4px 4px;
  border-radius: 24px;
  border: 1px solid var(--gray-200);
  background: rgba(255, 255, 255, 0.9);
  cursor: pointer;
  transition: all 0.3s var(--ease-out);
  font-family: inherit;
  font-size: 13px;
  color: var(--gray-600);
  box-shadow: var(--shadow-sm);
}
.user-btn:hover {
  border-color: var(--color-primary);
  box-shadow: var(--shadow-md);
  transform: translateY(-1px);
}
.user-name { font-weight: 600; max-width: 80px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.user-chevron { color: var(--gray-400); transition: transform .2s; }

/* 登录按钮 */
.login-btn {
  padding: 8px 20px;
  border-radius: 20px;
  border: none;
  background: var(--color-primary);
  color: #fff;
  font-size: 13px;
  font-weight: 600;
  font-family: inherit;
  cursor: pointer;
  transition: all .25s;
  box-shadow: 0 2px 8px rgba(247,42,68,.25);
}
.login-btn:hover {
  background: var(--color-primary-dark);
  box-shadow: 0 4px 14px rgba(247,42,68,.35);
  transform: translateY(-1px);
}

/* ===== 购物车抽屉 Premium 设计 ===== */
.cart-drawer-wrap {
  display: flex; flex-direction: column; height: 100%;
}

/* 自定义头部 */
.cart-drawer-head {
  display: flex; justify-content: space-between; align-items: center;
  padding: 16px 20px; border-bottom: 1px solid var(--gray-100);
}
.drawer-head-left { display: flex; align-items: center; gap: 10px; }
.head-icon {
  width: 30px; height: 30px; border-radius: 8px;
  background: linear-gradient(135deg, #f72a44, #d32035);
  display: flex; align-items: center; justify-content: center;
}
.head-title { font-size: 16px; font-weight: 700; color: var(--gray-700); }
.head-count { font-size: 12px; color: var(--gray-400); background: var(--gray-100); padding: 2px 8px; border-radius: 10px; }

/* 空状态 Premium */
.cart-empty-premium {
  flex: 1; display: flex; align-items: center; justify-content: center;
}
.empty-gradient-bg {
  text-align: center; padding: 48px 32px;
  background: linear-gradient(160deg, #fdf2f4, #f8f9fc 60%);
  border-radius: var(--radius-lg); margin: 20px;
}
.empty-icon-circle {
  width: 88px; height: 88px; border-radius: 50%;
  background: linear-gradient(135deg, #fef0f0, #fce4e4);
  display: inline-flex; align-items: center; justify-content: center;
  margin-bottom: 20px; box-shadow: inset 0 2px 4px rgba(255,255,255,.8);
}
.empty-gradient-bg h3 { font-size: 18px; color: var(--gray-600); margin: 0 0 6px; font-weight: 700; }
.empty-gradient-bg p { font-size: 13px; color: var(--gray-400); margin: 0 0 20px; }

/* 列表 */
.cart-drawer-list {
  flex: 1; overflow-y: auto; padding: 12px 16px;
  display: flex; flex-direction: column; gap: 10px;
}

/* 卡片 */
.cart-premium-card {
  background: #fff; border-radius: var(--radius-md);
  box-shadow: 0 1px 4px rgba(0,0,0,.04), 0 2px 12px rgba(0,0,0,.03);
  padding: 14px 16px;
  transition: box-shadow .25s;
}
.cart-premium-card:hover { box-shadow: var(--shadow-md); }
.card-top { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px; }
.card-product-name { font-size: 14px; font-weight: 700; color: var(--gray-700); }
.card-countdown {
  display: flex; align-items: center; gap: 5px; font-size: 12px;
  color: var(--green-500); margin-bottom: 10px; font-weight: 500;
}
.card-countdown.urgent { color: var(--color-primary); animation: pulse 1s infinite; }
@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: .5; } }

/* 核心规格 Chips */
.card-core-specs {
  display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 8px;
}
.spec-chip {
  font-size: 11px; color: var(--gray-500);
  background: var(--gray-50); padding: 3px 10px;
  border-radius: 6px; border: 1px solid var(--gray-200);
  max-width: 180px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}

/* 完整配置展开 */
.card-full-config { margin-top: 10px; padding-top: 10px; border-top: 1px dashed var(--gray-200); }
.cfg-section { font-size: 12px; font-weight: 700; color: var(--gray-600); margin: 8px 0 4px; }
.cfg-row {
  display: flex; justify-content: space-between; padding: 4px 0;
  font-size: 12px; color: var(--gray-500);
}
.cfg-row span:last-child { color: var(--gray-600); font-weight: 500; text-align: right; max-width: 60%; }

.expand-fade-enter-active, .expand-fade-leave-active { transition: all .3s var(--ease-out); }
.expand-fade-enter-from, .expand-fade-leave-to { opacity: 0; max-height: 0; overflow: hidden; }

/* 卡片底部 */
.card-bottom {
  display: flex; justify-content: space-between; align-items: center;
  margin-top: 10px; padding-top: 10px; border-top: 1px solid var(--gray-100);
}
.card-price { font-size: 13px; color: var(--gray-500); }
.card-price strong { font-size: 18px; color: var(--color-primary); font-weight: 800; }
.card-bottom .el-icon { transition: transform .25s; font-size: 12px; }
.card-bottom .el-icon.rotated { transform: rotate(180deg); }

/* 底部毛玻璃 */
.cart-drawer-foot {
  padding: 16px 20px;
  background: rgba(255,255,255,.88);
  backdrop-filter: blur(16px);
  border-top: 1px solid rgba(0,0,0,.05);
  box-shadow: 0 -4px 16px rgba(0,0,0,.04);
}
.foot-summary {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 14px; font-size: 13px; color: var(--gray-500);
}
.foot-total strong {
  font-size: 22px; color: var(--color-primary); font-weight: 800; margin-left: 6px;
}
.foot-actions { display: flex; gap: 10px; }
.clear-all-btn { flex-shrink: 0; border-radius: 12px !important; }

/* 提交按钮 — 品牌渐变 + 波纹 */
.submit-order-btn {
  flex: 1; height: 46px; border: none; border-radius: 14px;
  background: linear-gradient(135deg, #f72a44, #d32035);
  color: #fff; font-size: 15px; font-weight: 700;
  cursor: pointer; position: relative; overflow: hidden;
  font-family: inherit;
  box-shadow: 0 4px 16px rgba(247,42,68,.3);
  transition: all .25s;
}
.submit-order-btn:hover { box-shadow: 0 6px 22px rgba(247,42,68,.4); transform: translateY(-1px); }
.submit-order-btn:active { transform: scale(.98); }
.submit-order-btn::after {
  content: ''; position: absolute; inset: 0;
  background: radial-gradient(circle at center, rgba(255,255,255,.3) 0%, transparent 70%);
  opacity: 0; transition: opacity .3s;
}
.submit-order-btn:hover::after { opacity: 1; }
.submit-order-btn:disabled { opacity: .6; cursor: wait; }

.btn-loading {
  display: inline-block; width: 18px; height: 18px;
  border: 2px solid rgba(255,255,255,.3);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin .8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }
</style>
