<template>
  <div class="help-center" :class="{ 'is-detail': activeArticleId }">
    <MallNavbar />

    <section class="hero-section">
      <div class="hero-content">
        <span class="hero-kicker">Help Center</span>
        <h1 class="hero-title">印刷知识与使用帮助</h1>
        <p class="hero-subtitle">从纸张选择到交付说明，帮你更快完成下单和报价。</p>
      </div>
    </section>

    <div class="help-body">
      <transition name="page-switch" mode="out-in">
        <div v-if="!activeArticleId" key="home" class="home-layout">
          <div class="stats-bar">
            <div class="stat-item">
              <span class="stat-num">{{ totalArticles }}</span>
              <span class="stat-label">篇文章</span>
            </div>
            <div class="stat-item">
              <span class="stat-num">{{ categories.length }}</span>
              <span class="stat-label">知识分类</span>
            </div>
            <div class="stat-item">
              <span class="stat-num">10+</span>
              <span class="stat-label">常见问题</span>
            </div>
            <div class="stat-item">
              <span class="stat-num">24h</span>
              <span class="stat-label">响应支持</span>
            </div>
          </div>

          <div v-if="loading" class="category-grid">
            <div v-for="i in 5" :key="i" class="category-card skeleton-card">
              <el-skeleton animated>
                <template #template>
                  <div class="sk-flex-center">
                    <el-skeleton-item variant="circle" style="width:54px;height:54px" />
                  </div>
                  <div class="sk-title"><el-skeleton-item variant="text" style="width:60%" /></div>
                  <div class="sk-desc"><el-skeleton-item variant="text" style="width:80%" /></div>
                  <div class="sk-desc"><el-skeleton-item variant="text" style="width:40%" /></div>
                </template>
              </el-skeleton>
            </div>
          </div>

          <div v-else class="category-grid">
            <div
              v-for="cat in categories"
              :key="cat.id"
              class="category-card"
              @click="selectCategory(cat)"
            >
              <div class="cat-icon-wrap" :style="{ background: cat.gradient }">
                <el-icon :size="26" color="#fff"><component :is="cat.icon" /></el-icon>
              </div>
              <h3 class="cat-title">{{ cat.name }}</h3>
              <p class="cat-desc">{{ cat.description }}</p>
              <div class="cat-meta">
                <span>{{ cat.articleCount }} 篇文章</span>
                <el-icon :size="14"><ArrowRight /></el-icon>
              </div>
            </div>
          </div>

          <div class="faq-section">
            <div class="faq-header">
              <span class="faq-badge">FAQ</span>
              <h2>常见问题</h2>
              <p>这些是下单和印刷过程中最常遇到的问题，先看一眼通常就能省掉不少沟通成本。</p>
            </div>

            <div class="faq-grid">
              <div
                v-for="faq in faqs"
                :key="faq.id"
                class="faq-card"
                :class="{ open: activeFaq === faq.id }"
                @click="activeFaq = activeFaq === faq.id ? null : faq.id"
              >
                <div class="faq-q">
                  <span class="faq-q-num">{{ String(faq.id).padStart(2, '0') }}</span>
                  <span class="faq-q-text">{{ faq.q }}</span>
                  <el-icon :class="['faq-chevron', { rotated: activeFaq === faq.id }]"><ArrowDown /></el-icon>
                </div>
                <transition name="faq-slide">
                  <div v-if="activeFaq === faq.id" class="faq-a">
                    <p>{{ faq.a }}</p>
                  </div>
                </transition>
              </div>
            </div>
          </div>
        </div>

        <div v-else key="detail" class="detail-layout">
          <el-container class="article-shell">
            <el-aside width="260px" class="article-aside">
              <div class="aside-back">
                <el-button link :icon="ArrowLeft" @click="activeArticleId = null">返回知识首页</el-button>
              </div>

              <div class="aside-menu">
                <div class="aside-menu-title">知识分类</div>
                <div v-for="cat in categories" :key="cat.id" class="aside-cat">
                  <div class="aside-cat-name">
                    <el-icon :size="14"><component :is="cat.icon" /></el-icon>
                    {{ cat.name }}
                  </div>
                  <div
                    v-for="art in cat.articles"
                    :key="art.id"
                    class="aside-art"
                    :class="{ active: art.id === activeArticleId }"
                    @click="openArticle(art.id)"
                  >
                    {{ art.title }}
                  </div>
                </div>
              </div>

              <div v-if="tocItems.length" class="aside-toc">
                <div class="aside-menu-title">本页目录</div>
                <div
                  v-for="(toc, idx) in tocItems"
                  :key="idx"
                  class="toc-item"
                  :class="{ 'toc-h2': toc.level === 2, 'toc-h3': toc.level === 3 }"
                  @click="scrollToAnchor(toc.id)"
                >
                  {{ toc.text }}
                </div>
              </div>

              <div v-if="relatedArticles.length" class="aside-toc">
                <div class="aside-menu-title">相关文章</div>
                <div
                  v-for="ra in relatedArticles"
                  :key="ra.id"
                  class="toc-item"
                  @click="openArticle(ra.id)"
                >
                  {{ ra.title }}
                </div>
              </div>
            </el-aside>

            <el-main class="article-main">
              <div v-if="articleLoading">
                <el-skeleton animated>
                  <template #template>
                    <el-skeleton-item variant="text" style="width:40%;height:20px" />
                    <div style="margin-top:16px">
                      <el-skeleton-item variant="text" style="width:70%;height:32px" />
                    </div>
                    <div style="margin:16px 0 32px;display:flex;gap:22px">
                      <el-skeleton-item variant="text" style="width:120px" />
                      <el-skeleton-item variant="text" style="width:100px" />
                      <el-skeleton-item variant="text" style="width:100px" />
                    </div>
                    <div v-for="i in 6" :key="i" style="margin-bottom:12px">
                      <el-skeleton-item variant="text" style="width:100%" />
                    </div>
                  </template>
                </el-skeleton>
              </div>

              <div v-else-if="currentArticle">
                <el-breadcrumb separator="/" class="article-breadcrumb">
                  <el-breadcrumb-item>知识库</el-breadcrumb-item>
                  <el-breadcrumb-item>{{ currentCategory?.name }}</el-breadcrumb-item>
                  <el-breadcrumb-item>{{ currentArticle.title }}</el-breadcrumb-item>
                </el-breadcrumb>

                <h1 class="article-title">{{ currentArticle.title }}</h1>
                <div class="article-meta">
                  <span><el-icon :size="14"><Calendar /></el-icon> 更新于 {{ currentArticle.date || '' }}</span>
                  <span><el-icon :size="14"><View /></el-icon> {{ currentArticle.views || 0 }} 次阅读</span>
                  <span><el-icon :size="14"><Clock /></el-icon> 约 {{ currentArticle.readTime || 3 }} 分钟</span>
                </div>

                <div ref="articleBody" class="article-body" v-html="currentArticle.content" />

                <div class="article-tags" v-if="currentArticle.tags?.length">
                  <el-tag
                    v-for="tag in currentArticle.tags"
                    :key="tag"
                    size="small"
                    effect="plain"
                    round
                  >{{ tag }}</el-tag>
                </div>

                <div class="article-feedback">
                  <div v-if="!feedbackGiven" class="feedback-ask">
                    <p>这篇文章对你有帮助吗？</p>
                    <div class="feedback-btns">
                      <el-button round plain :loading="feedbackLoading" @click="giveFeedback('up')">
                        <el-icon :size="15"><CircleCheckFilled /></el-icon>
                        有帮助 ({{ articleHelpful }})
                      </el-button>
                      <el-button round plain :loading="feedbackLoading" @click="giveFeedback('down')">
                        <el-icon :size="15"><WarningFilled /></el-icon>
                        需要改进
                      </el-button>
                    </div>
                  </div>
                  <transition name="feedback-pop">
                    <div v-if="feedbackGiven" class="feedback-thanks">
                      <el-icon :size="28" :color="feedbackType === 'up' ? '#16a34a' : '#d97706'">
                        <component :is="feedbackType === 'up' ? 'CircleCheckFilled' : 'WarningFilled'" />
                      </el-icon>
                      <span>{{ feedbackType === 'up' ? '感谢反馈，我们会继续打磨内容质量。' : '收到你的建议，我们会尽快优化这篇内容。' }}</span>
                    </div>
                  </transition>
                </div>
              </div>
            </el-main>
          </el-container>
        </div>
      </transition>
    </div>

    <footer class="global-footer">
      <span>印刷包装在线报价系统 · 帮助中心</span>
      <span class="footer-divider">|</span>
      <span>专业印刷，稳定交付</span>
    </footer>
  </div>
</template>

<script setup>
import { ref, computed, nextTick, onMounted } from 'vue'
import {
  ArrowRight, ArrowDown, ArrowLeft,
  Guide, Reading, Wallet, Printer, InfoFilled,
  Calendar, View, Clock, CircleCheckFilled, WarningFilled
} from '@element-plus/icons-vue'
import MallNavbar from '@/components/MallNavbar.vue'
import { getCategories, getArticleDetail, submitFeedback } from '@/api/help'
import { ElMessage } from 'element-plus'

const activeFaq = ref(null)
const activeArticleId = ref(null)
const feedbackGiven = ref(false)
const feedbackType = ref('up')
const feedbackLoading = ref(false)
const articleHelpful = ref(0)
const articleBody = ref(null)
const loading = ref(true)
const articleLoading = ref(false)
const categories = ref([])
const totalArticles = ref(0)
const currentArticle = ref(null)

const VOTED_KEY = 'help_feedback_articles'

function getVotedArticles() {
  try {
    return JSON.parse(localStorage.getItem(VOTED_KEY) || '[]')
  } catch {
    return []
  }
}

function markArticleVoted(articleId) {
  const voted = getVotedArticles()
  if (!voted.includes(articleId)) {
    voted.push(articleId)
    localStorage.setItem(VOTED_KEY, JSON.stringify(voted))
  }
}

function hasVotedArticle(articleId) {
  return getVotedArticles().includes(articleId)
}

const tocItems = computed(() => {
  if (!currentArticle.value?.content) return []
  const items = []
  const re = /<h([23])\s+id="([^"]*)"[^>]*>(.*?)<\/h[23]>/gi
  let m
  while ((m = re.exec(currentArticle.value.content)) !== null) {
    items.push({ level: Number(m[1]), id: m[2], text: m[3].replace(/<[^>]*>/g, '') })
  }
  return items
})

const scrollToAnchor = (id) => {
  nextTick(() => {
    const el = document.getElementById(id)
    if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' })
  })
}

const relatedArticles = computed(() => {
  if (!currentArticle.value || !currentCategory.value) return []
  return currentCategory.value.articles
    .filter(a => a.id !== activeArticleId.value)
    .slice(0, 3)
})

const currentCategory = computed(() => {
  if (!activeArticleId.value || !currentArticle.value) return null
  return categories.value.find(cat =>
    cat.articles.some(art => art.id === activeArticleId.value)
  )
})

const giveFeedback = async (type) => {
  if (!activeArticleId.value) return
  if (hasVotedArticle(activeArticleId.value)) {
    ElMessage.warning('你已经反馈过这篇文章了')
    return
  }

  feedbackLoading.value = true
  try {
    const data = await submitFeedback({
      articleId: activeArticleId.value,
      feedbackType: type
    })
    feedbackType.value = type
    feedbackGiven.value = true
    articleHelpful.value = data.helpfulCount
    markArticleVoted(activeArticleId.value)
    setTimeout(() => { feedbackGiven.value = false }, 5000)
  } finally {
    feedbackLoading.value = false
  }
}

const openArticle = async (id) => {
  activeArticleId.value = id
  feedbackGiven.value = false
  articleLoading.value = true
  currentArticle.value = null

  try {
    const detail = await getArticleDetail(id)
    currentArticle.value = detail
    articleHelpful.value = detail.helpfulCount || 0
    if (hasVotedArticle(id)) {
      feedbackGiven.value = true
      feedbackType.value = 'up'
    }
  } catch {
    activeArticleId.value = null
  } finally {
    articleLoading.value = false
  }
}

const selectCategory = (cat) => {
  if (cat.articles?.length) {
    openArticle(cat.articles[0].id)
  }
}

const faqs = ref([
  { id: 1, q: '上传文件后颜色会和屏幕看到的一样吗？', a: '不一定。印刷通常采用 CMYK 色彩模式，屏幕显示多为 RGB。建议在设计阶段就使用 CMYK，并为重要颜色先打样确认。' },
  { id: 2, q: '可以先打样再批量印刷吗？', a: '可以。对颜色、纸张和工艺有较高要求的订单，建议先做数码打样或上机打样，再确认大货生产。' },
  { id: 3, q: '加急订单一般多久可以出货？', a: '会根据产品类型、工艺复杂度和排产情况决定。普通加急通常可明显缩短交期，具体时效以下单页提示和客服确认结果为准。' },
  { id: 4, q: '出血位要留多少？', a: '常规建议四边各留 3mm 出血位，避免裁切误差导致白边。成品尺寸、裁切线和安全边距也建议在设计时一起预留。' },
  { id: 5, q: '纸张克重越高就一定越厚吗？', a: '不完全一样。不同纸种松厚度不同，所以相同克重的纸张，实际手感和厚度也可能不同。选择时要结合纸种一起判断。' },
  { id: 6, q: '如果收到的数量不足或成品有问题怎么办？', a: '请尽快拍照留存并通过订单页发起售后申请，我们会根据问题类型协助补印、重做或处理退款说明。' }
])

onMounted(async () => {
  try {
    const data = await getCategories()
    categories.value = data.categories || []
    totalArticles.value = data.totalArticles || 0
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.help-center {
  min-height: 100vh;
  background: linear-gradient(180deg, #fff7ed 0%, #f8fafc 22%, #f1f5f9 100%);
}

.hero-section {
  padding: 54px 24px 92px;
  background: linear-gradient(135deg, #0f172a, #1e293b 58%, #334155);
}

.hero-content {
  max-width: 1180px;
  margin: 0 auto;
  color: #fff;
}

.hero-kicker {
  display: inline-block;
  font-size: 11px;
  letter-spacing: 1.6px;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.62);
  margin-bottom: 10px;
}

.hero-title {
  margin: 0;
  font-size: 40px;
  font-weight: 800;
}

.hero-subtitle {
  margin: 10px 0 0;
  font-size: 15px;
  color: rgba(255, 255, 255, 0.72);
}

.help-body {
  max-width: 1200px;
  margin: -42px auto 0;
  padding: 0 24px 48px;
  position: relative;
  z-index: 2;
}

.page-switch-enter-active,
.page-switch-leave-active {
  transition: all 0.35s ease;
}

.page-switch-enter-from {
  opacity: 0;
  transform: translateX(24px);
}

.page-switch-leave-to {
  opacity: 0;
  transform: translateX(-24px);
}

.stats-bar {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
  margin-bottom: 24px;
}

.stat-item {
  padding: 20px;
  border-radius: 18px;
  background: rgba(255, 255, 255, 0.88);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(226, 232, 240, 0.9);
  box-shadow: 0 14px 28px rgba(15, 23, 42, 0.04);
  text-align: center;
}

.stat-num {
  display: block;
  font-size: 28px;
  font-weight: 800;
  color: #0f172a;
}

.stat-label {
  display: block;
  margin-top: 4px;
  font-size: 13px;
  color: #64748b;
}

.category-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 18px;
  margin-bottom: 38px;
}

.category-card {
  background: rgba(255, 255, 255, 0.92);
  border: 1px solid rgba(226, 232, 240, 0.9);
  border-radius: 22px;
  padding: 26px 20px 22px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 14px 28px rgba(15, 23, 42, 0.04);
}

.category-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 24px 42px rgba(15, 23, 42, 0.1);
}

.skeleton-card:hover {
  transform: none;
}

.sk-flex-center,
.sk-title,
.sk-desc {
  display: flex;
  justify-content: center;
}

.sk-flex-center {
  margin-bottom: 16px;
}

.sk-title {
  margin-bottom: 8px;
}

.sk-desc {
  margin-bottom: 4px;
}

.cat-icon-wrap {
  width: 56px;
  height: 56px;
  border-radius: 18px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
  box-shadow: 0 12px 24px rgba(15, 23, 42, 0.12);
}

.cat-title {
  margin: 0 0 8px;
  font-size: 16px;
  font-weight: 700;
  color: #0f172a;
}

.cat-desc {
  margin: 0 0 14px;
  min-height: 38px;
  font-size: 13px;
  color: #64748b;
  line-height: 1.6;
}

.cat-meta {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  font-size: 12px;
  color: #94a3b8;
}

.faq-section {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 24px;
  border: 1px solid rgba(226, 232, 240, 0.9);
  box-shadow: 0 16px 32px rgba(15, 23, 42, 0.05);
  padding: 28px;
}

.faq-header {
  text-align: center;
  margin-bottom: 24px;
}

.faq-badge {
  display: inline-block;
  margin-bottom: 10px;
  padding: 4px 12px;
  border-radius: 999px;
  background: #fff7ed;
  color: #ea580c;
  font-size: 12px;
  font-weight: 700;
}

.faq-header h2 {
  margin: 0;
  font-size: 28px;
  color: #0f172a;
}

.faq-header p {
  margin: 10px auto 0;
  max-width: 720px;
  color: #64748b;
}

.faq-grid {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.faq-card {
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.25s ease;
}

.faq-card:hover,
.faq-card.open {
  border-color: #fdba74;
  box-shadow: 0 14px 28px rgba(249, 115, 22, 0.08);
}

.faq-q {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 16px 18px;
  background: #fff;
}

.faq-q-num {
  width: 30px;
  height: 30px;
  border-radius: 10px;
  background: #fff7ed;
  color: #ea580c;
  font-size: 12px;
  font-weight: 800;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.faq-q-text {
  flex: 1;
  font-size: 15px;
  font-weight: 700;
  color: #1e293b;
}

.faq-chevron {
  color: #94a3b8;
  transition: transform 0.25s ease;
}

.faq-chevron.rotated {
  transform: rotate(180deg);
}

.faq-a {
  padding: 0 18px 18px 62px;
  color: #475569;
  line-height: 1.8;
  font-size: 14px;
  background: #fff;
}

.faq-a p {
  margin: 0;
}

.faq-slide-enter-active,
.faq-slide-leave-active {
  transition: all 0.25s ease;
}

.faq-slide-enter-from,
.faq-slide-leave-to {
  opacity: 0;
  max-height: 0;
}

.detail-layout {
  margin-top: -46px;
}

.article-shell {
  background: rgba(255, 255, 255, 0.94);
  border-radius: 24px;
  border: 1px solid rgba(226, 232, 240, 0.9);
  box-shadow: 0 18px 40px rgba(15, 23, 42, 0.06);
  overflow: hidden;
  min-height: 70vh;
}

.article-aside {
  background: #fafcff;
  border-right: 1px solid #e2e8f0;
}

.aside-back {
  padding: 16px;
  border-bottom: 1px solid #e2e8f0;
}

.aside-menu-title {
  font-size: 12px;
  font-weight: 700;
  color: #94a3b8;
  letter-spacing: 0.8px;
  padding: 14px 16px 8px;
}

.aside-cat-name {
  font-size: 13px;
  font-weight: 700;
  color: #1e293b;
  padding: 6px 16px;
  display: flex;
  align-items: center;
  gap: 6px;
}

.aside-art,
.toc-item {
  font-size: 13px;
  color: #475569;
  padding: 8px 16px 8px 36px;
  cursor: pointer;
  transition: all 0.2s ease;
  line-height: 1.5;
}

.aside-art:hover,
.aside-art.active,
.toc-item:hover {
  color: #ea580c;
  background: #fff7ed;
}

.aside-art.active {
  font-weight: 700;
  border-left: 2px solid #ea580c;
}

.toc-item.toc-h3 {
  padding-left: 52px;
  font-size: 12px;
  color: #64748b;
}

.article-main {
  padding: 40px 54px;
  max-width: 820px;
}

.article-breadcrumb {
  margin-bottom: 24px;
}

.article-title {
  margin: 0 0 14px;
  font-size: 34px;
  font-weight: 800;
  color: #0f172a;
}

.article-meta {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
  font-size: 13px;
  color: #64748b;
  margin-bottom: 28px;
  padding-bottom: 18px;
  border-bottom: 1px solid #e2e8f0;
}

.article-meta span {
  display: flex;
  align-items: center;
  gap: 4px;
}

.article-body {
  font-size: 15px;
  line-height: 1.9;
  color: #334155;
}

.article-body :deep(h2) {
  font-size: 22px;
  font-weight: 800;
  color: #0f172a;
  margin: 36px 0 12px;
}

.article-body :deep(h3) {
  font-size: 18px;
  color: #1e293b;
  margin: 24px 0 10px;
}

.article-body :deep(p) {
  margin: 0 0 16px;
}

.article-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin: 30px 0 24px;
  padding-top: 22px;
  border-top: 1px solid #e2e8f0;
}

.article-feedback {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 18px;
  padding: 24px;
  text-align: center;
}

.feedback-ask p {
  margin: 0 0 14px;
  font-size: 15px;
  color: #475569;
  font-weight: 700;
}

.feedback-btns {
  display: flex;
  justify-content: center;
  gap: 12px;
  flex-wrap: wrap;
}

.feedback-thanks {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  color: #1e293b;
  font-size: 14px;
  font-weight: 500;
}

.feedback-pop-enter-active {
  transition: all 0.35s ease;
}

.feedback-pop-leave-active {
  transition: all 0.2s ease;
}

.feedback-pop-enter-from,
.feedback-pop-leave-to {
  opacity: 0;
  transform: scale(0.95);
}

.global-footer {
  text-align: center;
  padding: 30px 0 42px;
  color: #94a3b8;
  font-size: 13px;
}

.footer-divider {
  margin: 0 12px;
}

@media (max-width: 1100px) {
  .category-grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .stats-bar {
    grid-template-columns: repeat(2, 1fr);
  }

  .article-main {
    padding: 30px 28px;
  }
}

@media (max-width: 768px) {
  .hero-section {
    padding-bottom: 80px;
  }

  .hero-title {
    font-size: 30px;
  }

  .category-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .article-aside {
    display: none;
  }

  .article-main {
    padding: 24px 18px;
  }
}
</style>
