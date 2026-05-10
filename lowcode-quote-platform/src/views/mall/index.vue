<template>
  <div class="mall-container">
    <MallNavbar />

    <div class="mall-body">
      <!-- 左侧一级分类侧边栏 -->
      <aside class="category-sidebar">
        <div class="sidebar-inner" @mouseleave="handleSidebarLeave">
          <ul class="category-list">
            <li
              v-for="cat in categoryTree"
              :key="cat.id"
              class="category-item"
              :class="{ active: activeCategoryId === cat.id }"
              @mouseenter="handleItemEnter(cat.id, $event)"
            >
              <span class="category-name">{{ cat.name }}</span>
              <el-icon v-if="cat.children?.length" class="arrow-icon"><ArrowRight /></el-icon>
            </li>
          </ul>
        </div>

        <!-- 三级分类飞出面板 -->
        <div
          v-show="hoveredCategoryId && currentHoveredCategory"
          class="subcategory-flyout"
          :style="flyoutStyle"
          @mouseenter="handleFlyoutEnter"
          @mouseleave="handleFlyoutLeave"
        >
          <div class="flyout-inner" v-if="currentHoveredCategory">
            <div class="flyout-title">{{ currentHoveredCategory.name }}</div>
            <div class="flyout-rows">
              <div
                v-for="sub2 in currentHoveredCategory.children"
                :key="sub2.id"
                class="sub-group-row"
              >
                <div
                  class="sub-group-label"
                  :class="{ 'is-leaf': !sub2.children || sub2.children.length === 0 }"
                  @click.stop="(!sub2.children || sub2.children.length === 0) && selectCategory(currentHoveredCategory.id, sub2.id)"
                >
                  {{ sub2.name }}
                  <el-icon v-if="sub2.children && sub2.children.length"><ArrowRight /></el-icon>
                </div>
                <div class="leaf-items">
                  <span
                    v-for="sub3 in sub2.children"
                    :key="sub3.id"
                    class="leaf-item"
                    :class="{ active: activeSubCategoryId === sub3.id || selectedCategoryId === sub3.id }"
                    @click.stop="selectCategory(currentHoveredCategory.id, sub3.id)"
                  >
                    {{ sub3.name }}
                  </span>
                  <span
                    v-if="!sub2.children || sub2.children.length === 0"
                    class="leaf-item placeholder-item"
                    @click.stop="selectCategory(currentHoveredCategory.id, sub2.id)"
                  >
                    (查看详情)
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </aside>

      <!-- 右侧商品区域 -->
      <div class="product-area" v-loading="loading">
        <div class="direct-quote-container" v-if="selectedCategoryId">
          <div class="container-header">
            <div class="breadcrumb">
              <span class="breadcrumb-item" @click="selectCategory(null, null)">商城首页</span>
              <template v-if="categoryPath.length">
                <el-icon style="font-size:12px;color:#c0c4cc;margin:0 4px"><ArrowRight /></el-icon>
                <span class="breadcrumb-item active">{{ categoryPath[categoryPath.length - 1].name }}</span>
              </template>
            </div>
          </div>
          <DynamicQuoteForm :categoryId="selectedCategoryId" :key="selectedCategoryId" />
        </div>
        <div v-else-if="!loading" class="portal-homepage">
          <!-- ====== 1. 服务流程 ====== -->
          <section class="process-section reveal">
            <div class="section-label">定制流程</div>
            <h2 class="section-heading">四步开启您的专属印刷</h2>
            <p class="section-sub">低代码引擎驱动，从选品到生产，精准高效</p>
            <div class="process-steps">
              <div class="process-step" v-for="(step, i) in processSteps" :key="i">
                <div class="step-icon-wrap">
                  <el-icon :size="28"><component :is="step.icon" /></el-icon>
                </div>
                <div class="step-connector" v-if="i < processSteps.length - 1">
                  <span class="connector-line" />
                  <el-icon :size="14" class="connector-arrow"><ArrowRight /></el-icon>
                </div>
                <div class="step-info">
                  <span class="step-num">{{ String(i + 1).padStart(2, '0') }}</span>
                  <h4>{{ step.title }}</h4>
                  <p>{{ step.desc }}</p>
                </div>
              </div>
            </div>
          </section>

          <!-- ====== 2. 精品案例橱窗 ====== -->
          <section class="showcase-section reveal">
            <div class="section-label">精品案例</div>
            <h2 class="section-heading">热门定制案例</h2>
            <p class="section-sub">数千家企业信赖的品质之选</p>
            <div class="showcase-grid">
              <div class="showcase-card" v-for="item in showcaseItems" :key="item.id">
                <div class="showcase-img" :style="{ background: item.gradient }">
                  <span class="showcase-emoji">{{ item.emoji }}</span>
                  <div class="showcase-overlay">
                    <span class="showcase-view">查看案例</span>
                  </div>
                </div>
                <div class="showcase-info">
                  <h5>{{ item.name }}</h5>
                  <span class="showcase-specs">{{ item.specs }}</span>
                </div>
              </div>
            </div>
          </section>

          <!-- ====== 3. 核心优势 ====== -->
          <section class="strengths-section reveal">
            <div class="section-label">为什么选择我们</div>
            <h2 class="section-heading">核心优势</h2>
            <div class="strengths-grid">
              <div class="strength-card" v-for="s in strengths" :key="s.title">
                <div class="strength-icon" :style="{ background: s.gradient }">
                  <el-icon :size="28" color="#fff"><component :is="s.icon" /></el-icon>
                </div>
                <h4>{{ s.title }}</h4>
                <p>{{ s.desc }}</p>
              </div>
            </div>
          </section>

          <!-- ====== 4. 平台动态统计 ====== -->
          <section class="trust-section reveal">
            <div class="trust-inner">
              <div class="trust-stat" v-for="stat in trustStats" :key="stat.label">
                <span class="trust-value">
                  <span class="trust-counter">{{ animatedStats[stat.label] ?? 0 }}</span>
                  <span class="trust-unit">{{ stat.unit }}</span>
                </span>
                <span class="trust-label">{{ stat.label }}</span>
              </div>
            </div>
          </section>

          <!-- ====== 5. 合作伙伴 Logo 墙 ====== -->
          <section class="partners-section reveal">
            <div class="section-label">合作伙伴</div>
            <h2 class="section-heading">信赖我们的企业</h2>
            <div class="partner-grid">
              <div class="partner-logo" v-for="p in partners" :key="p">{{ p }}</div>
            </div>
          </section>
        </div>
      </div>
    </div>

    <div class="footer">
      <p>&copy; 2026 印刷包装生态有限公司 版权所有 | 基于 Vue 3 &amp; Element Plus 构建</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import {
  ArrowRight,
  Edit, Coin, Box, Van, Medal, Connection, Cpu
} from '@element-plus/icons-vue'
import { getMallCategoryTree } from '@/api/category'
import MallNavbar from '@/components/MallNavbar.vue'
import DynamicQuoteForm from '@/components/dynamic-form/DynamicQuoteForm.vue'

const selectedCategoryId = ref(null)
const categoryTree = ref([])
const loading = ref(false)

const activeCategoryId = ref(null)
const activeSubCategoryId = ref(null)

const hoveredCategoryId = ref(null)
const flyoutHovered = ref(false)
let hideTimer = null

const currentHoveredCategory = computed(() =>
  categoryTree.value.find(c => c.id === hoveredCategoryId.value)
)

const hoveredItemTop = ref(0)

const flyoutStyle = computed(() => ({
  top: `${hoveredItemTop.value}px`,
  left: '198px'
}))

const handleItemEnter = (id, event) => {
  clearTimeout(hideTimer)
  hoveredCategoryId.value = id
  if (event && event.currentTarget) {
    hoveredItemTop.value = event.currentTarget.offsetTop
  }
}

const handleSidebarLeave = () => {
  hideTimer = setTimeout(() => {
    if (!flyoutHovered.value) hoveredCategoryId.value = null
  }, 200)
}

const handleFlyoutEnter = () => {
  clearTimeout(hideTimer)
  flyoutHovered.value = true
}

const handleFlyoutLeave = () => {
  flyoutHovered.value = false
  hideTimer = setTimeout(() => {
    hoveredCategoryId.value = null
  }, 200)
}

const selectCategory = (firstId, subId) => {
  // 仅允许选中叶子节点：subId 不存在则表示选中一级分类（不允许），subId 存在才是叶子
  if (!subId) {
    activeCategoryId.value = firstId
    return
  }
  activeCategoryId.value = firstId
  activeSubCategoryId.value = subId
  hoveredCategoryId.value = null
  flyoutHovered.value = false
  selectedCategoryId.value = subId
}

const categoryPath = computed(() => {
  if (!selectedCategoryId.value) return []
  const path = []
  const findPath = (tree, targetId, currentPath) => {
    for (const node of tree) {
      if (node.id === targetId) {
        path.push(...currentPath, { id: node.id, name: node.name })
        return true
      }
      if (node.children?.length) {
        if (findPath(node.children, targetId, [...currentPath, { id: node.id, name: node.name }])) return true
      }
    }
    return false
  }
  findPath(categoryTree.value, selectedCategoryId.value, [])
  return path
})

// ===== 服务流程 =====
const processSteps = [
  { icon: 'Edit', title: '选择产品', desc: '浏览左侧分类目录，定位您需要的印刷品类' },
  { icon: 'Coin', title: '实时报价', desc: '填写规格参数，引擎动态计算最优价格' },
  { icon: 'Box', title: '提交暂存', desc: '确认配置并暂存订单，10 分钟内有效锁定' },
  { icon: 'Van', title: '厂家生产', desc: '订单直连生产线，品质把控后极速发货' }
]

// ===== 精品案例 =====
const showcaseItems = [
  { id: 1, name: '精装画册', specs: '300g 铜版纸 · 局部UV · 锁线精装', gradient: 'linear-gradient(135deg, #667eea, #764ba2)', emoji: '\u{1F4D6}' },
  { id: 2, name: '磨砂名片', specs: '400g 哑粉纸 · 双面磨砂 · 圆角工艺', gradient: 'linear-gradient(135deg, #f093fb, #f5576c)', emoji: '\u{1F4B3}' },
  { id: 3, name: '高端礼盒', specs: '157g 铜版裱灰板 · 烫金Logo · 内衬EVA', gradient: 'linear-gradient(135deg, #43e97b, #38f9d7)', emoji: '\u{1F381}' },
  { id: 4, name: '企业宣传册', specs: '200g 特种纸 · 骑马钉 · 专色印刷', gradient: 'linear-gradient(135deg, #f6d365, #fda085)', emoji: '\u{1F4F0}' },
  { id: 5, name: '手提纸袋', specs: '250g 白卡纸 · 覆哑膜 · 棉绳拎手', gradient: 'linear-gradient(135deg, #a18cd1, #fbc2eb)', emoji: '\u{1F6CD}\u{FE0F}' },
  { id: 6, name: '不干胶标签', specs: '铜版不干胶 · 异形模切 · 卷装出货', gradient: 'linear-gradient(135deg, #ffecd2, #fcb69f)', emoji: '\u{1F3F7}\u{FE0F}' }
]

// ===== 核心优势 =====
const strengths = [
  { icon: 'Cpu', title: '智能引擎', desc: 'JSON 驱动动态表单，联动约束规则，秒级出价，零误差计算。', gradient: 'linear-gradient(135deg, #667eea, #764ba2)' },
  { icon: 'Medal', title: '品质工艺', desc: '精选特种纸与进口环保油墨，匠心印后工艺，品质可追溯。', gradient: 'linear-gradient(135deg, #f093fb, #f5576c)' },
  { icon: 'Connection', title: '极速物流', desc: '全国多仓协同，24 小时内极速发货，顺丰/德邦直达。', gradient: 'linear-gradient(135deg, #43e97b, #38f9d7)' }
]

// ===== 平台统计 =====
const trustStats = [
  { label: '累计成交额', value: 58960, unit: '万元' },
  { label: '服务企业数', value: 12680, unit: '家' },
  { label: '配置模板数', value: 3540, unit: '套' },
  { label: '日均订单', value: 856, unit: '单' }
]
const animatedStats = ref({})
let statsAnimated = false

function animateStats() {
  if (statsAnimated) return
  statsAnimated = true
  trustStats.forEach(stat => {
    const target = stat.value
    const step = Math.max(1, Math.floor(target / 66))
    let current = 0
    const timer = setInterval(() => {
      current = Math.min(current + step, target)
      animatedStats.value[stat.label] = current.toLocaleString()
      if (current >= target) clearInterval(timer)
    }, 30)
  })
}

// ===== 合作伙伴 =====
const partners = ['恒安集团', '得力文具', '三只松鼠', '良品铺子', '百草味', '太平鸟', '海澜之家', '晨光文具', '来伊份', '周黑鸭', '西西弗书店', '网易严选']

// ===== 滚动动画 =====
let observer = null

function setupScrollReveal() {
  observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible')
        if (entry.target.classList.contains('trust-section')) {
          animateStats()
        }
      }
    })
  }, { threshold: 0.15 })

  nextTick(() => {
    document.querySelectorAll('.reveal').forEach(el => observer.observe(el))
  })
}

onMounted(async () => {
  loading.value = true
  const treeRes = await getMallCategoryTree().catch(() => null)
  if (treeRes) {
    categoryTree.value = treeRes || []
  }
  loading.value = false
  setupScrollReveal()
})

onUnmounted(() => {
  clearTimeout(hideTimer)
  if (observer) observer.disconnect()
})
</script>

<style scoped>
.mall-container {
  min-height: 100vh;
  background-color: #f2f5f8;
  display: flex;
  flex-direction: column;
}

/* ===== 主体 ===== */
.mall-body {
  flex: 1;
  display: flex;
  max-width: 1400px;
  width: 100%;
  margin: 28px auto;
  padding: 0 24px;
  box-sizing: border-box;
  align-items: flex-start;
  position: relative;
}

/* ===== 左侧侧边栏 ===== */
.category-sidebar {
  width: 200px;
  flex-shrink: 0;
  position: sticky;
  top: 20px;
  z-index: 10;
}

.sidebar-inner {
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.06);
  overflow: hidden;
  padding-bottom: 8px;
}

.sidebar-title {
  padding: 16px 20px;
  font-size: 13px;
  font-weight: 700;
  color: #303133;
  background: linear-gradient(135deg, #f0f4ff 0%, #e8f0fe 100%);
  border-bottom: 1px solid #ebeef5;
  letter-spacing: 0.5px;
}

.category-list {
  list-style: none;
  margin: 0;
  padding: 8px 0;
}

.category-item {
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 10px 16px;
  cursor: pointer;
  font-size: 14px;
  color: #606266;
  transition: all 0.15s;
  border-left: 3px solid transparent;
  user-select: none;
}

.category-item:hover {
  background-color: #f5f7fa;
  color: #409eff;
}

.category-item.active {
  background-color: #ecf5ff;
  color: #409eff;
  font-weight: 600;
  border-left-color: #409eff;
}

.cat-icon {
  font-size: 15px;
  flex-shrink: 0;
}

.arrow-icon {
  margin-left: auto;
  font-size: 12px;
  color: #c0c4cc;
}

/* ===== 飞出面板 ===== */
.subcategory-flyout {
  position: absolute;
  width: 600px;
  background: transparent;
  z-index: 100;
  padding-left: 2px;
}

.flyout-inner {
  display: flex;
  flex-direction: column;
  background: rgba(255,255,255,.96);
  backdrop-filter: blur(12px);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-xl);
  padding: 24px;
  border: 1px solid rgba(0,0,0,.06);
  min-height: 200px;
}

.flyout-title {
  font-size: 15px;
  font-weight: bold;
  color: #1a1a1a;
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 2px solid #f2f2f2;
}

.flyout-rows {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.sub-group-row {
  display: flex;
  align-items: flex-start;
}

.sub-group-label {
  width: 110px;
  font-size: 13px;
  font-weight: bold;
  color: #333;
  cursor: default;
  display: flex;
  align-items: center;
  gap: 4px;
  flex-shrink: 0;
  margin-top: 4px;
}

.sub-group-label.is-leaf {
  cursor: pointer;
}

.sub-group-label.is-leaf:hover {
  color: #409eff;
}

.leaf-items {
  flex: 1;
  display: flex;
  flex-wrap: wrap;
  gap: 12px 20px;
  padding-left: 10px;
  border-left: 1px solid #f0f0f0;
}

.leaf-item {
  font-size: 13px;
  color: #666;
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
}

.leaf-item:hover {
  color: #409eff;
}

.leaf-item.active {
  color: #409eff;
  font-weight: bold;
}

.placeholder-item {
  color: #999;
  font-style: italic;
}

/* ===== 右侧区域 ===== */
.product-area {
  flex: 1;
  margin-left: 20px;
  min-width: 0;
}

.container-header {
  padding: 12px 20px;
  border-bottom: 1px solid #f0f0f0;
  margin-bottom: 10px;
}

.breadcrumb {
  display: flex;
  align-items: center;
  font-size: 13px;
}

.breadcrumb-item {
  color: #909399;
  cursor: pointer;
}

.breadcrumb-item:hover { color: #409eff; }
.breadcrumb-item.active { color: #303133; font-weight: 600; cursor: default; }

.direct-quote-container {
  background: #fff;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  padding: 0;
  overflow: hidden;
  animation: fadeInScale .5s var(--ease-out);
}

/* ===== 门户首页各模块 ===== */
.portal-homepage {
  flex: 1;
  min-width: 0;
  padding-bottom: 40px;
}

.section-label {
  display: inline-block;
  font-size: 12px;
  font-weight: 700;
  color: var(--color-primary);
  background: var(--color-primary-light);
  padding: 4px 14px;
  border-radius: 20px;
  letter-spacing: 1px;
  text-transform: uppercase;
  margin-bottom: 12px;
}
.section-heading {
  font-size: 28px;
  font-weight: 800;
  color: var(--gray-700);
  margin: 0 0 8px;
}
.section-sub {
  font-size: 14px;
  color: var(--gray-400);
  margin: 0 0 36px;
}

/* 滚动渐现动画 */
.reveal {
  opacity: 0;
  transform: translateY(36px);
  transition: opacity .7s ease, transform .7s ease;
}
.reveal.visible {
  opacity: 1;
  transform: translateY(0);
}
.process-section { transition-delay: .1s; }
.showcase-section { transition-delay: .15s; }
.strengths-section { transition-delay: .2s; }
.trust-section { transition-delay: .25s; }
.partners-section { transition-delay: .3s; }

/* ===== 1. 服务流程 ===== */
.process-section {
  text-align: center;
  padding: 20px 0 40px;
}
.process-steps {
  display: flex;
  justify-content: center;
  align-items: flex-start;
  max-width: 900px;
  margin: 0 auto;
}
.process-step {
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  flex: 1;
}
.step-icon-wrap {
  width: 68px;
  height: 68px;
  border-radius: 50%;
  background: #fff;
  border: 2px solid var(--gray-200);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-primary);
  transition: all .4s var(--ease-out);
  position: relative;
  z-index: 1;
  box-shadow: var(--shadow-sm);
}
.process-step:hover .step-icon-wrap {
  border-color: var(--color-primary);
  box-shadow: var(--shadow-glow-red);
  transform: translateY(-4px);
}
.step-connector {
  position: absolute;
  top: 34px;
  left: calc(50% + 34px);
  width: calc(100% - 68px);
  display: flex;
  align-items: center;
  z-index: 0;
}
.connector-line {
  flex: 1;
  height: 2px;
  background: var(--gray-200);
  border-radius: 1px;
}
.connector-arrow {
  color: var(--gray-300);
  flex-shrink: 0;
  margin-left: 2px;
}
.step-info {
  margin-top: 20px;
  text-align: center;
  padding: 0 8px;
}
.step-num {
  font-size: 11px;
  font-weight: 800;
  color: var(--gray-300);
  letter-spacing: 2px;
}
.step-info h4 {
  margin: 6px 0 4px;
  font-size: 15px;
  font-weight: 700;
  color: var(--gray-600);
}
.step-info p {
  margin: 0;
  font-size: 12.5px;
  color: var(--gray-400);
  line-height: 1.5;
}

/* ===== 2. 精品案例橱窗 ===== */
.showcase-section {
  padding: 20px 0 30px;
  text-align: center;
}
.showcase-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  max-width: 860px;
  margin: 0 auto;
}
.showcase-card {
  background: #fff;
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
  transition: transform .35s var(--ease-out), box-shadow .35s var(--ease-out);
  cursor: pointer;
}
.showcase-card:hover {
  transform: translateY(-8px) scale(1.03);
  box-shadow: var(--shadow-xl);
}
.showcase-img {
  height: 140px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}
.showcase-emoji {
  font-size: 48px;
  transition: transform .35s var(--ease-out);
}
.showcase-card:hover .showcase-emoji {
  transform: scale(1.2);
}
.showcase-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0,0,0,.45);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity .3s;
}
.showcase-card:hover .showcase-overlay {
  opacity: 1;
}
.showcase-view {
  color: #fff;
  font-size: 14px;
  font-weight: 600;
  padding: 8px 20px;
  border: 2px solid rgba(255,255,255,.7);
  border-radius: 24px;
}
.showcase-info {
  padding: 16px;
  text-align: left;
}
.showcase-info h5 {
  margin: 0 0 4px;
  font-size: 15px;
  font-weight: 700;
  color: var(--gray-600);
}
.showcase-specs {
  font-size: 12px;
  color: var(--gray-400);
}

/* ===== 3. 核心优势 ===== */
.strengths-section {
  padding: 20px 0 30px;
  text-align: center;
}
.strengths-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  max-width: 860px;
  margin: 0 auto;
}
.strength-card {
  background: #fff;
  border-radius: var(--radius-lg);
  padding: 36px 24px 28px;
  box-shadow: var(--shadow-sm);
  transition: transform .3s var(--ease-out), box-shadow .3s var(--ease-out);
}
.strength-card:hover {
  transform: translateY(-6px);
  box-shadow: var(--shadow-lg);
}
.strength-icon {
  width: 60px;
  height: 60px;
  border-radius: 16px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 18px;
}
.strength-card h4 {
  margin: 0 0 10px;
  font-size: 17px;
  font-weight: 700;
  color: var(--gray-600);
}
.strength-card p {
  margin: 0;
  font-size: 13px;
  color: var(--gray-400);
  line-height: 1.7;
}

/* ===== 4. 平台动态统计 ===== */
.trust-section {
  padding: 20px 0;
}
.trust-inner {
  background: linear-gradient(135deg, #1a1a2e 0%, #0f3460 100%);
  border-radius: 20px;
  padding: 44px 48px;
  display: flex;
  justify-content: space-around;
  align-items: center;
  backdrop-filter: blur(10px);
  box-shadow: var(--shadow-xl);
}
.trust-stat {
  text-align: center;
}
.trust-value {
  display: block;
  font-size: 38px;
  font-weight: 800;
  color: #fff;
  line-height: 1.2;
  margin-bottom: 6px;
}
.trust-unit {
  font-size: 18px;
  font-weight: 400;
  opacity: .7;
}
.trust-label {
  font-size: 14px;
  color: rgba(255,255,255,.6);
  font-weight: 400;
}

/* ===== 5. 合作伙伴 ===== */
.partners-section {
  padding: 30px 0 40px;
  text-align: center;
}
.partner-grid {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 16px;
  max-width: 860px;
  margin: 0 auto;
}
.partner-logo {
  background: #fff;
  border: 1px solid var(--gray-200);
  border-radius: 12px;
  padding: 14px 24px;
  font-size: 13px;
  font-weight: 600;
  color: var(--gray-400);
  transition: all .25s;
  cursor: default;
}
.partner-logo:hover {
  color: var(--gray-600);
  border-color: var(--gray-300);
  box-shadow: var(--shadow-sm);
  transform: translateY(-2px);
}

/* ===== 底部 ===== */
.footer {
  color: #909399;
  font-size: 13px;
  text-align: center;
  flex-shrink: 0;
  padding: 18px 0 30px;
}

/* 入场动画关键帧 */
@keyframes fadeInScale {
  from { opacity: 0; transform: scale(.95); }
  to   { opacity: 1; transform: scale(1); }
}
@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(24px); }
  to   { opacity: 1; transform: translateY(0); }
}
@keyframes slideInRight {
  from { opacity: 0; transform: translateX(-20px); }
  to   { opacity: 1; transform: translateX(0); }
}

</style>
