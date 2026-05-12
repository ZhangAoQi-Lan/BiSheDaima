<template>
  <div class="mall-container">
    <MallNavbar />

    <div class="mall-body">
      <aside class="category-sidebar">
        <div class="sidebar-shell" @mouseleave="handleSidebarLeave">
          <div class="sidebar-header">
            <span class="sidebar-kicker">Category</span>
            <h3>产品分类</h3>
          </div>

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
              <div v-for="sub2 in currentHoveredCategory.children" :key="sub2.id" class="sub-group-row">
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
                    进入报价
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </aside>

      <main class="product-area" v-loading="loading">
        <div v-if="selectedCategoryId" class="direct-quote-container">
          <div class="container-header">
            <div class="breadcrumb">
              <span class="breadcrumb-item" @click="selectCategory(null, null)">商城首页</span>
              <template v-if="categoryPath.length">
                <el-icon class="breadcrumb-arrow"><ArrowRight /></el-icon>
                <span class="breadcrumb-item active">{{ categoryPath[categoryPath.length - 1].name }}</span>
              </template>
            </div>
          </div>
          <DynamicQuoteForm :categoryId="selectedCategoryId" :key="selectedCategoryId" />
        </div>

        <div v-else-if="!loading" class="portal-homepage">
          <section class="hero-card reveal">
            <div class="hero-copy">
              <span class="section-badge">Platform Intro</span>
              <h1>{{ siteContent.shopName }}</h1>
              <p>{{ siteContent.shopIntro }}</p>
              <div class="hero-actions">
                <el-button type="primary" size="large" @click="scrollToCategory">立即开始报价</el-button>
                <el-button size="large" @click="selectCategory(null, null)">浏览产品分类</el-button>
              </div>
            </div>

            <div class="hero-side">
              <div class="info-card">
                <div class="info-title">平台公告</div>
                <div class="announce-list">
                  <div v-for="(item, index) in siteContent.announcements" :key="index" class="announce-item">
                    {{ item }}
                  </div>
                </div>
              </div>

              <div class="info-card compact">
                <div class="info-title">联系方式</div>
                <p>电话：{{ siteContent.contactPhone }}</p>
                <p>微信：{{ siteContent.contactWechat }}</p>
                <p>服务时间：{{ siteContent.serviceHours }}</p>
                <p>地址：{{ siteContent.shopAddress }}</p>
              </div>
            </div>
          </section>

          <section class="showcase-band reveal">
            <div class="band-header">
              <span class="section-badge light">Quote Flow</span>
              <h2>从选品到生产，一条线完成在线下单</h2>
              <p>后台配置字段，前台自动生成报价表单，用户提交后直接进入购物车和订单流程。</p>
            </div>

            <div class="process-grid">
              <div v-for="(step, index) in processSteps" :key="step.title" class="process-card">
                <div class="process-index">{{ String(index + 1).padStart(2, '0') }}</div>
                <div class="process-icon">
                  <el-icon :size="24"><component :is="step.icon" /></el-icon>
                </div>
                <h3>{{ step.title }}</h3>
                <p>{{ step.desc }}</p>
              </div>
            </div>
          </section>

          <section class="showcase-section reveal">
            <div class="band-header left">
              <span class="section-badge light">Popular Cases</span>
              <h2>热门定制案例</h2>
              <p>这些是最常被企业选择的印刷品类，也是最适合用来演示平台报价能力的产品。</p>
            </div>

            <div class="showcase-grid">
              <div v-for="item in showcaseItems" :key="item.id" class="showcase-card">
                <div class="showcase-visual" :style="{ background: item.gradient }">
                  <span class="showcase-emoji">{{ item.emoji }}</span>
                </div>
                <div class="showcase-info">
                  <h4>{{ item.name }}</h4>
                  <p>{{ item.specs }}</p>
                </div>
              </div>
            </div>
          </section>

          <section class="trust-section reveal">
            <div class="stats-card">
              <div v-for="stat in trustStats" :key="stat.label" class="trust-stat">
                <div class="trust-value">
                  <span>{{ animatedStats[stat.label] ?? 0 }}</span>
                  <small>{{ stat.unit }}</small>
                </div>
                <div class="trust-label">{{ stat.label }}</div>
              </div>
            </div>
          </section>

          <section class="partners-section reveal">
            <div class="band-header left">
              <span class="section-badge light">Partners</span>
              <h2>合作品牌</h2>
            </div>
            <div class="partner-grid">
              <div v-for="p in partners" :key="p" class="partner-logo">{{ p }}</div>
            </div>
          </section>
        </div>
      </main>
    </div>

    <footer class="footer">
      <p>© 2026 印刷包装在线报价平台 · 基于 Vue 3 与 Element Plus 构建</p>
    </footer>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ArrowRight, Edit, Coin, Box, Van } from '@element-plus/icons-vue'
import { getMallCategoryTree } from '@/api/category'
import { getMallSiteContent } from '@/api/site'
import MallNavbar from '@/components/MallNavbar.vue'
import DynamicQuoteForm from '@/components/dynamic-form/DynamicQuoteForm.vue'

const route = useRoute()
const selectedCategoryId = ref(null)
const categoryTree = ref([])
const loading = ref(false)
const siteContent = ref({
  shopName: '印刷包装在线报价平台',
  shopIntro: '',
  contactPhone: '',
  contactWechat: '',
  serviceHours: '',
  shopAddress: '',
  announcements: []
})

const activeCategoryId = ref(null)
const activeSubCategoryId = ref(null)
const hoveredCategoryId = ref(null)
const flyoutHovered = ref(false)
const hoveredItemTop = ref(0)
let hideTimer = null
let observer = null
let statsAnimated = false

const currentHoveredCategory = computed(() => categoryTree.value.find(c => c.id === hoveredCategoryId.value))
const flyoutStyle = computed(() => ({ top: `${hoveredItemTop.value}px`, left: '216px' }))

const handleItemEnter = (id, event) => {
  clearTimeout(hideTimer)
  hoveredCategoryId.value = id
  if (event?.currentTarget) hoveredItemTop.value = event.currentTarget.offsetTop
}

const handleSidebarLeave = () => {
  hideTimer = setTimeout(() => {
    if (!flyoutHovered.value) hoveredCategoryId.value = null
  }, 180)
}

const handleFlyoutEnter = () => {
  clearTimeout(hideTimer)
  flyoutHovered.value = true
}

const handleFlyoutLeave = () => {
  flyoutHovered.value = false
  hideTimer = setTimeout(() => {
    hoveredCategoryId.value = null
  }, 180)
}

const selectCategory = (firstId, subId) => {
  if (!subId) {
    activeCategoryId.value = firstId
    selectedCategoryId.value = null
    activeSubCategoryId.value = null
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

const processSteps = [
  { icon: Edit, title: '选择产品', desc: '从左侧分类快速找到对应印刷品类和模板。' },
  { icon: Coin, title: '实时报价', desc: '填写规格参数后，系统立即计算当前配置价格。' },
  { icon: Box, title: '加入暂存', desc: '确认方案后加入购物车，统一完成下单。' },
  { icon: Van, title: '生产交付', desc: '订单流转到生产与发货，状态可持续追踪。' }
]

const showcaseItems = [
  { id: 1, name: '精装画册', specs: '300g 铜版纸 · 局部 UV · 锁线精装', gradient: 'linear-gradient(135deg, #667eea, #764ba2)', emoji: '📖' },
  { id: 2, name: '磨砂名片', specs: '400g 哑粉纸 · 双面磨砂 · 圆角工艺', gradient: 'linear-gradient(135deg, #f093fb, #f5576c)', emoji: '💳' },
  { id: 3, name: '高端礼盒', specs: '裱灰板结构 · 烫金 Logo · EVA 内衬', gradient: 'linear-gradient(135deg, #43e97b, #38f9d7)', emoji: '🎁' },
  { id: 4, name: '企业宣传册', specs: '200g 特种纸 · 骑马钉 · 专色印刷', gradient: 'linear-gradient(135deg, #f6d365, #fda085)', emoji: '📰' },
  { id: 5, name: '手提纸袋', specs: '250g 白卡纸 · 覆哑膜 · 棉绳提手', gradient: 'linear-gradient(135deg, #a18cd1, #fbc2eb)', emoji: '🛍️' },
  { id: 6, name: '不干胶标签', specs: '铜版不干胶 · 异形模切 · 卷装出货', gradient: 'linear-gradient(135deg, #ffecd2, #fcb69f)', emoji: '🏷️' }
]

const trustStats = [
  { label: '累计成交额', value: 58960, unit: '万元' },
  { label: '服务企业数', value: 12680, unit: '家' },
  { label: '配置模板数', value: 3540, unit: '套' },
  { label: '日均订单', value: 856, unit: '单' }
]

const partners = ['晨光文具', '三只松鼠', '良品铺子', '百草味', '恒安集团', '网易严选', '海澜之家', '太平鸟']
const animatedStats = ref({})

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

function setupScrollReveal() {
  if (observer) {
    observer.disconnect()
  }
  observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible')
        if (entry.target.classList.contains('trust-section')) animateStats()
      }
    })
  }, { threshold: 0.15 })

  nextTick(() => {
    document.querySelectorAll('.reveal').forEach(el => observer.observe(el))
  })
}

function scrollToCategory() {
  window.scrollTo({ top: 120, behavior: 'smooth' })
}

onMounted(async () => {
  loading.value = true
  const [treeRes, siteRes] = await Promise.all([
    getMallCategoryTree().catch(() => null),
    getMallSiteContent().catch(() => null)
  ])
  if (treeRes) categoryTree.value = treeRes || []
  if (siteRes) siteContent.value = siteRes
  if (route.query.categoryId) selectedCategoryId.value = route.query.categoryId
  loading.value = false
  setupScrollReveal()
})

onUnmounted(() => {
  clearTimeout(hideTimer)
  if (observer) observer.disconnect()
})

watch(
  () => route.query.categoryId,
  (value) => {
    if (value) selectedCategoryId.value = value
  }
)

watch(selectedCategoryId, async (value) => {
  if (!value) {
    await nextTick()
    setupScrollReveal()
  }
})
</script>

<style scoped>
.mall-container {
  min-height: 100vh;
  background: linear-gradient(180deg, #fff7ed 0%, #f8fafc 20%, #f1f5f9 100%);
  display: flex;
  flex-direction: column;
}

.mall-body {
  flex: 1;
  display: flex;
  max-width: 1400px;
  width: 100%;
  margin: 28px auto 0;
  padding: 0 24px 36px;
  gap: 24px;
  align-items: flex-start;
  position: relative;
}

.category-sidebar {
  width: 218px;
  flex-shrink: 0;
  position: sticky;
  top: 92px;
  z-index: 10;
}

.sidebar-shell {
  background: rgba(255, 255, 255, 0.92);
  border: 1px solid rgba(226, 232, 240, 0.9);
  border-radius: 24px;
  box-shadow: 0 18px 30px rgba(15, 23, 42, 0.06);
  overflow: hidden;
}

.sidebar-header {
  padding: 18px 18px 12px;
  border-bottom: 1px solid #eef2f7;
}

.sidebar-kicker {
  display: inline-block;
  font-size: 11px;
  letter-spacing: 1.4px;
  text-transform: uppercase;
  color: #94a3b8;
  margin-bottom: 6px;
}

.sidebar-header h3 {
  margin: 0;
  font-size: 18px;
  color: #0f172a;
}

.category-list {
  list-style: none;
  margin: 0;
  padding: 10px;
}

.category-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 14px;
  margin-bottom: 4px;
  cursor: pointer;
  font-size: 14px;
  color: #475569;
  transition: all 0.2s ease;
  border-radius: 16px;
  user-select: none;
}

.category-item:hover {
  background: #fff7ed;
  color: #ea580c;
}

.category-item.active {
  background: linear-gradient(135deg, #fff7ed, #ffedd5);
  color: #ea580c;
  font-weight: 700;
}

.arrow-icon {
  margin-left: auto;
  font-size: 12px;
  color: #cbd5e1;
}

.subcategory-flyout {
  position: absolute;
  width: 620px;
  background: transparent;
  z-index: 100;
}

.flyout-inner {
  background: rgba(255, 255, 255, 0.96);
  backdrop-filter: blur(16px);
  border-radius: 24px;
  box-shadow: 0 24px 42px rgba(15, 23, 42, 0.12);
  padding: 24px;
  border: 1px solid rgba(226, 232, 240, 0.9);
}

.flyout-title {
  font-size: 16px;
  font-weight: 800;
  color: #0f172a;
  margin-bottom: 18px;
  padding-bottom: 12px;
  border-bottom: 1px solid #eef2f7;
}

.flyout-rows {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.sub-group-row {
  display: flex;
  align-items: flex-start;
}

.sub-group-label {
  width: 120px;
  font-size: 13px;
  font-weight: 700;
  color: #334155;
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
  color: #ea580c;
}

.leaf-items {
  flex: 1;
  display: flex;
  flex-wrap: wrap;
  gap: 10px 16px;
  padding-left: 14px;
  border-left: 1px solid #eef2f7;
}

.leaf-item {
  font-size: 13px;
  color: #64748b;
  cursor: pointer;
  transition: all 0.2s ease;
  padding: 5px 10px;
  border-radius: 999px;
}

.leaf-item:hover,
.leaf-item.active {
  color: #ea580c;
  background: #fff7ed;
}

.placeholder-item {
  color: #94a3b8;
}

.product-area {
  flex: 1;
  min-width: 0;
}

.container-header {
  padding: 16px 22px;
  border-bottom: 1px solid #eef2f7;
}

.breadcrumb {
  display: flex;
  align-items: center;
  font-size: 13px;
}

.breadcrumb-item {
  color: #94a3b8;
  cursor: pointer;
}

.breadcrumb-item:hover {
  color: #ea580c;
}

.breadcrumb-item.active {
  color: #0f172a;
  font-weight: 700;
  cursor: default;
}

.breadcrumb-arrow {
  font-size: 12px;
  color: #cbd5e1;
  margin: 0 5px;
}

.direct-quote-container {
  background: rgba(255, 255, 255, 0.95);
  border: 1px solid rgba(226, 232, 240, 0.9);
  border-radius: 28px;
  box-shadow: 0 20px 36px rgba(15, 23, 42, 0.06);
  overflow: hidden;
}

.portal-homepage {
  padding-bottom: 36px;
}

.hero-card,
.showcase-band,
.showcase-section,
.partners-section {
  margin-bottom: 22px;
}

.hero-card {
  display: grid;
  grid-template-columns: 1.15fr 0.85fr;
  gap: 20px;
  padding: 28px;
  border-radius: 30px;
  background: linear-gradient(135deg, #0f172a, #1e293b 56%, #334155);
  color: #fff;
  box-shadow: 0 26px 46px rgba(15, 23, 42, 0.16);
}

.hero-copy h1 {
  margin: 8px 0 12px;
  font-size: 38px;
  font-weight: 800;
}

.hero-copy p {
  max-width: 620px;
  margin: 0;
  font-size: 15px;
  line-height: 1.8;
  color: rgba(255, 255, 255, 0.76);
}

.hero-actions {
  display: flex;
  gap: 12px;
  margin-top: 22px;
}

.hero-side {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.info-card {
  padding: 18px;
  border-radius: 22px;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.12);
}

.info-card.compact p {
  margin: 0 0 8px;
  color: rgba(255, 255, 255, 0.75);
  font-size: 13px;
}

.info-title {
  font-size: 15px;
  font-weight: 800;
  margin-bottom: 12px;
}

.announce-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.announce-item {
  padding: 12px 14px;
  border-radius: 14px;
  background: rgba(255, 255, 255, 0.08);
  color: rgba(255, 255, 255, 0.82);
  font-size: 13px;
  line-height: 1.6;
}

.showcase-band,
.showcase-section,
.partners-section {
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid rgba(226, 232, 240, 0.9);
  border-radius: 28px;
  box-shadow: 0 16px 30px rgba(15, 23, 42, 0.05);
  padding: 28px;
}

.band-header {
  text-align: center;
  margin-bottom: 22px;
}

.band-header.left {
  text-align: left;
}

.section-badge {
  display: inline-flex;
  align-items: center;
  padding: 5px 12px;
  border-radius: 999px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 1.2px;
  text-transform: uppercase;
  background: rgba(255, 255, 255, 0.12);
  color: rgba(255, 255, 255, 0.72);
}

.section-badge.light {
  background: #fff7ed;
  color: #ea580c;
}

.band-header h2 {
  margin: 12px 0 8px;
  font-size: 30px;
  color: #0f172a;
}

.band-header p {
  margin: 0;
  color: #64748b;
  line-height: 1.7;
}

.process-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}

.process-card {
  padding: 22px;
  border-radius: 22px;
  background: linear-gradient(180deg, #fff, #f8fafc);
  border: 1px solid #e2e8f0;
}

.process-index {
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 1.4px;
  color: #94a3b8;
}

.process-icon {
  width: 52px;
  height: 52px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff7ed;
  color: #ea580c;
  margin: 14px 0;
}

.process-card h3 {
  margin: 0 0 8px;
  color: #0f172a;
}

.process-card p {
  margin: 0;
  font-size: 13px;
  color: #64748b;
  line-height: 1.7;
}

.showcase-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 18px;
}

.showcase-card {
  overflow: hidden;
  border-radius: 22px;
  background: #fff;
  border: 1px solid #e2e8f0;
  transition: all 0.25s ease;
}

.showcase-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 20px 36px rgba(15, 23, 42, 0.1);
}

.showcase-visual {
  height: 168px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.showcase-emoji {
  font-size: 50px;
}

.showcase-info {
  padding: 16px;
}

.showcase-info h4 {
  margin: 0 0 8px;
  color: #0f172a;
  font-size: 16px;
}

.showcase-info p {
  margin: 0;
  color: #64748b;
  line-height: 1.7;
  font-size: 13px;
}

.stats-card {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  padding: 26px 28px;
  border-radius: 26px;
  background: linear-gradient(135deg, #0f172a, #1e293b);
  box-shadow: 0 22px 42px rgba(15, 23, 42, 0.14);
}

.trust-stat {
  text-align: center;
  color: #fff;
}

.trust-value {
  display: flex;
  align-items: baseline;
  justify-content: center;
  gap: 4px;
  font-size: 34px;
  font-weight: 800;
}

.trust-value small {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.68);
}

.trust-label {
  margin-top: 6px;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.68);
}

.partner-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
}

.partner-logo {
  padding: 16px;
  border-radius: 16px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  color: #475569;
  font-size: 13px;
  font-weight: 700;
  text-align: center;
}

.footer {
  color: #94a3b8;
  font-size: 13px;
  text-align: center;
  padding: 10px 0 34px;
}

.reveal {
  opacity: 0;
  transform: translateY(28px);
  transition: opacity 0.7s ease, transform 0.7s ease;
}

.reveal.visible {
  opacity: 1;
  transform: translateY(0);
}

@media (max-width: 1180px) {
  .hero-card,
  .process-grid,
  .showcase-grid,
  .stats-card,
  .partner-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 900px) {
  .mall-body {
    flex-direction: column;
  }

  .category-sidebar {
    position: static;
    width: 100%;
  }

  .hero-card,
  .process-grid,
  .showcase-grid,
  .stats-card,
  .partner-grid {
    grid-template-columns: 1fr;
  }

  .hero-actions {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
