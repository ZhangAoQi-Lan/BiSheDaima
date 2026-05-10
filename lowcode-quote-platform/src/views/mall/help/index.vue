<template>
  <div class="help-center" :class="{ 'is-detail': activeArticleId }">
    <MallNavbar />

    <!-- ====== Hero 区域 ====== -->
    <section class="hero-section">
      <div class="hero-grid" />
      <div class="hero-overlay" />
      <div class="hero-content">
        <h1 class="hero-title">印刷行业知识库</h1>
        <p class="hero-subtitle">从纸张选择到工艺落地，一站式解答您的所有印刷疑问</p>
      </div>
    </section>

    <!-- ====== 主体 ====== -->
    <div class="help-body">
      <transition name="page-switch" mode="out-in">
        <!-- ========== 首页：分类 + FAQ ========== -->
        <div v-if="!activeArticleId" key="home" class="home-layout">
          <!-- 统计条 -->
          <div class="stats-bar">
            <div class="stat-item">
              <span class="stat-num">{{ totalArticles }}</span>
              <span class="stat-label">篇文档</span>
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
              <span class="stat-label">客服响应</span>
            </div>
          </div>

          <!-- 分类卡片矩阵 - 骨架屏 -->
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

          <!-- 分类卡片矩阵 - 真实数据 -->
          <div v-else class="category-grid">
            <div
              v-for="cat in categories"
              :key="cat.id"
              class="category-card"
              @click="selectCategory(cat)"
            >
              <div class="card-glass" />
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

          <!-- FAQ 区域 -->
          <div class="faq-section">
            <div class="faq-header">
              <div class="faq-title-row">
                <span class="faq-badge">FAQ</span>
                <h2>常见问题</h2>
              </div>
              <p class="faq-sub">以下是最常被问到的印刷相关问题，也许能立刻解答您的疑惑</p>
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

        <!-- ========== 详情页：文章阅读 ========== -->
        <div v-else key="detail" class="detail-layout">
          <el-container class="article-shell">
            <!-- 左侧目录 -->
            <el-aside width="260px" class="article-aside">
              <div class="aside-back">
                <el-button link :icon="ArrowLeft" @click="activeArticleId = null">
                  返回知识库首页
                </el-button>
              </div>

              <!-- 文章目录 -->
              <div class="aside-menu">
                <div class="aside-menu-title">知识分类</div>
                <div
                  v-for="cat in categories"
                  :key="cat.id"
                  class="aside-cat"
                >
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

              <!-- TOC 锚点导航 -->
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

              <!-- 相关文章 -->
              <div v-if="relatedArticles.length" class="aside-toc">
                <div class="aside-menu-title">相关推荐</div>
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

            <!-- 文章正文 -->
            <el-main class="article-main">
              <!-- 骨架屏 -->
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

              <!-- 真实内容 -->
              <div v-else-if="currentArticle">
                <el-breadcrumb separator="›" class="article-breadcrumb">
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

                <!-- 内容 -->
                <div
                  ref="articleBody"
                  class="article-body"
                  v-html="currentArticle.content"
                />

                <!-- 标签 -->
                <div class="article-tags" v-if="currentArticle.tags?.length">
                  <el-tag
                    v-for="tag in currentArticle.tags"
                    :key="tag"
                    size="small"
                    effect="plain"
                    round
                  >{{ tag }}</el-tag>
                </div>

                <!-- 反馈区 -->
                <div class="article-feedback">
                  <div v-if="!feedbackGiven" class="feedback-ask">
                    <p>这篇文章对您有帮助吗？</p>
                    <div class="feedback-btns">
                      <el-button
                        round
                        plain
                        :loading="feedbackLoading"
                        @click="giveFeedback('up')"
                      >
                        <el-icon :size="15"><CircleCheckFilled /></el-icon>
                        有帮助 ({{ articleHelpful }})
                      </el-button>
                      <el-button
                        round
                        plain
                        :loading="feedbackLoading"
                        @click="giveFeedback('down')"
                      >
                        <el-icon :size="15"><WarningFilled /></el-icon>
                        没帮助
                      </el-button>
                    </div>
                  </div>
                  <transition name="feedback-pop">
                    <div v-if="feedbackGiven" class="feedback-thanks">
                      <el-icon :size="28" :color="feedbackType === 'up' ? '#67c23a' : '#e6a23c'">
                        <component :is="feedbackType === 'up' ? 'CircleCheckFilled' : 'WarningFilled'" />
                      </el-icon>
                      <span>{{ feedbackType === 'up' ? '感谢您的反馈，我们将持续优化内容质量！' : '感谢您的反馈，我们会尽快改进这篇文章。如需帮助，请联系在线客服。' }}</span>
                    </div>
                  </transition>
                </div>
              </div>
            </el-main>
          </el-container>
        </div>
      </transition>
    </div>

    <!-- ====== 底部 ====== -->
    <footer class="global-footer">
      <span>印刷包装在线报价系统 · 知识库</span>
      <span class="footer-divider">|</span>
      <span>专业印刷，匠心品质</span>
    </footer>
  </div>
</template>

<script setup>
import { ref, computed, nextTick, onMounted } from 'vue'
import {
  ArrowRight, ArrowDown, ArrowLeft,
  Guide, Reading, Wallet, Printer, InfoFilled, Files,
  Calendar, View, Clock, CircleCheckFilled, WarningFilled
} from '@element-plus/icons-vue'
import MallNavbar from '@/components/MallNavbar.vue'
import { getCategories, getArticleDetail, submitFeedback } from '@/api/help'
import { ElMessage } from 'element-plus'

// ===== 状态 =====
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

// ===== localStorage 一人一票 =====
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

// ===== TOC =====
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

// ===== 相关文章 =====
const relatedArticles = computed(() => {
  if (!currentArticle.value || !currentCategory.value) return []
  return currentCategory.value.articles
    .filter(a => a.id !== activeArticleId.value)
    .slice(0, 3)
})

// ===== 当前分类 =====
const currentCategory = computed(() => {
  if (!activeArticleId.value || !currentArticle.value) return null
  return categories.value.find(cat =>
    cat.articles.some(art => art.id === activeArticleId.value)
  )
})

// ===== 反馈 =====
const giveFeedback = async (type) => {
  if (!activeArticleId.value) return

  // 检查一人一票
  if (hasVotedArticle(activeArticleId.value)) {
    ElMessage.warning('您已经反馈过该文章')
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
  } catch {
    // 错误已在拦截器中处理
  } finally {
    feedbackLoading.value = false
  }
}

// ===== 文章导航 =====
const openArticle = async (id) => {
  activeArticleId.value = id
  feedbackGiven.value = false
  articleLoading.value = true
  currentArticle.value = null

  try {
    const detail = await getArticleDetail(id)
    currentArticle.value = detail
    articleHelpful.value = detail.helpfulCount || 0

    // 检查是否已投票
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

// ===== FAQ 静态数据 =====
const faqs = ref([
  { id: 1, q: '我上传的文件颜色不准怎么办？', a: '印刷采用CMYK四色模式。如果您的设计文件是RGB模式（如屏幕截图、手机照片），颜色会有一定偏差。建议在设计阶段就将文件转为CMYK模式，并以印刷色谱（非屏幕显示）作为颜色参考。我们的印前部门也会在制版时对明显偏色的文件进行色彩校正。' },
  { id: 2, q: '可以先打样再大批量印刷吗？', a: '支持！您可以在报价选项中选择"数码打样"或"上机打样"服务。数码打样费用较低（约¥30-80/份），适合颜色校对；上机打样费用较高但能100%还原大批量效果。建议对颜色要求严格的高端产品选择打样服务。' },
  { id: 3, q: '加急订单需要多少额外费用？', a: '加急费用根据产品类型和加急程度而定：标准加急（缩短50%交期）加收20%；特急加急（6-12小时出货）加收50%。加急费用会在报价面板的"加急"选项中实时显示。请注意，含特殊工艺的产品可能不支持特急加急。' },
  { id: 4, q: '异地发货一般多久能到？', a: '省内1-2天，华东/华南2-3天，华中/华北3-4天，西南/西北4-6天，偏远地区5-8天。大件货物在以上基础上增加1-2天。默认使用顺丰/中通快递，量大走德邦/安能物流。' },
  { id: 5, q: '纸张克重和厚度有什么关系？', a: '克重（g/m²）是每平方米纸张的重量，一般来说克重越大纸张越厚，但不同纸种的松厚度不同。例如200g铜版纸约0.19mm厚，而200g轻型纸可达0.28mm。国标允许克重误差±5%属于正常范围。' },
  { id: 6, q: '漏印或数量不足怎么赔付？', a: '发现数量不足请拍照留存（含外包装标签和实物），24小时内联系客服。核实后我们会按缺失数量比例退款或免费补印。如因我司原因导致的印刷错误（如制版错误、用错纸张），我们将全额退款并免费重印。' },
  { id: 7, q: '发票什么时候可以开？', a: '订单完成后即可在"我的订单"中申请开票。电子发票1-3个工作日发至您邮箱，纸质发票5个工作日内寄出。请在订单完成后30天内完成申请，逾期将无法补开。支持增值税普通发票和专用发票。' },
  { id: 8, q: '我的文件需要转曲吗？怎么转？', a: '强烈建议将文字转曲后再上传！未转曲的文字可能在印刷时出现字体缺失导致的乱码或错位。Illustrator中按Shift+Ctrl+O全选文字转轮廓；InDesign导出PDF时选择PDF/X-1a标准会自动嵌入字体。上传前在Acrobat中检查字体列表确认转曲成功。' },
  { id: 9, q: '什么是出血位？需要留多少？', a: '出血是印刷设计中将画面延伸出裁切线的额外区域，防止裁切误差导致白边。标准出血位为3mm（四周各3mm）。满版底色或图片必须留出血位，否则裁切偏移会导致成品边缘出现难看的白线。' },
  { id: 10, q: '铜版纸和特种纸有什么区别？', a: '铜版纸表面光滑、白度高、色彩还原精准，适合大多数商业印刷品；特种纸自带纹理和底色（如大地纸、珠光纸），印刷色彩会受纸张底色影响，呈现更复古或高级的视觉效果。选择时应根据设计风格和预算综合考虑。' },
  { id: 11, q: 'UV工艺会不会容易脱落？', a: '正常使用条件下（非频繁弯折、刮擦）UV工艺不会脱落。UV油墨通过紫外线瞬时固化，与纸张附着力强。但极端的弯折（如对折卡片）可能导致UV层开裂，避免在UV区域进行折叠即可。' }
])

// ===== 初始化 =====
onMounted(async () => {
  try {
    const data = await getCategories()
    categories.value = data.categories || []
    totalArticles.value = data.totalArticles || 0
  } catch {
    // 加载失败
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
/* ========================================
   CSS 变量 & 全局
   ======================================== */
.help-center {
  min-height: 100vh;
  background: #f5f6f8;
}

/* ========================================
   Hero 区域 — 网格纹理 + 光晕搜索
   ======================================== */
.hero-section {
  position: relative;
  height: 240px;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  background: linear-gradient(160deg, #1a1a2e 0%, #16213e 40%, #0f3460 100%);
}
.hero-grid {
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(rgba(255,255,255,.03) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,.03) 1px, transparent 1px);
  background-size: 40px 40px;
  mask-image: radial-gradient(ellipse 80% 60% at 50% 40%, black 40%, transparent 70%);
  -webkit-mask-image: radial-gradient(ellipse 80% 60% at 50% 40%, black 40%, transparent 70%);
}
.hero-overlay {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(circle at 20% 70%, rgba(247,42,68,.12) 0%, transparent 50%),
    radial-gradient(circle at 80% 30%, rgba(102,126,234,.1) 0%, transparent 50%);
}
.hero-content {
  position: relative;
  z-index: 1;
  text-align: center;
}
.hero-title {
  font-size: 42px;
  font-weight: 800;
  color: #fff;
  margin: 0 0 12px;
  letter-spacing: 1.5px;
}
.hero-subtitle {
  font-size: 16px;
  color: rgba(255,255,255,.65);
  margin: 0;
  font-weight: 300;
}

/* ========================================
   主体区域
   ======================================== */
.help-body {
  max-width: 1200px;
  margin: -50px auto 0;
  padding: 0 24px;
  position: relative;
  z-index: 2;
}

/* 页面切换动效 */
.page-switch-enter-active, .page-switch-leave-active { transition: all .35s ease; }
.page-switch-enter-from { opacity: 0; transform: translateX(30px); }
.page-switch-leave-to { opacity: 0; transform: translateX(-30px); }

/* ========================================
   统计条
   ======================================== */
.stats-bar {
  display: flex;
  justify-content: center;
  gap: 48px;
  background: #fff;
  border-radius: 14px;
  padding: 22px 40px;
  box-shadow: 0 2px 16px rgba(0,0,0,.04);
  margin-bottom: 28px;
}
.stat-item { text-align: center; }
.stat-num { font-size: 28px; font-weight: 800; color: #303133; display: block; line-height: 1.2; }
.stat-label { font-size: 13px; color: #909399; margin-top: 2px; display: block; }

/* ========================================
   分类卡片 — 玻璃拟态
   ======================================== */
.category-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 18px;
  margin-bottom: 40px;
}
.category-card {
  position: relative;
  background: rgba(255,255,255,.65);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255,255,255,.8);
  border-radius: 18px;
  padding: 28px 20px 22px;
  text-align: center;
  cursor: pointer;
  overflow: hidden;
  transition: all .35s cubic-bezier(.4,0,.2,1);
  box-shadow: 0 2px 12px rgba(0,0,0,.04);
}
.category-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 16px 36px rgba(0,0,0,.1);
  border-color: rgba(255,255,255,.95);
}
.category-card:hover .cat-icon-wrap {
  transform: scale(1.08);
}
.category-card:hover .cat-meta .el-icon {
  transform: translateX(4px);
}
/* 骨架屏卡片 */
.skeleton-card {
  cursor: default;
}
.skeleton-card:hover {
  transform: none;
  box-shadow: 0 2px 12px rgba(0,0,0,.04);
}
.sk-flex-center {
  display: flex;
  justify-content: center;
  margin-bottom: 16px;
}
.sk-title {
  display: flex;
  justify-content: center;
  margin-bottom: 8px;
}
.sk-desc {
  display: flex;
  justify-content: center;
  margin-bottom: 4px;
}

.cat-icon-wrap {
  width: 54px;
  height: 54px;
  border-radius: 16px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
  transition: transform .35s cubic-bezier(.4,0,.2,1);
  box-shadow: 0 4px 14px rgba(0,0,0,.1);
}
.cat-title {
  margin: 0 0 8px;
  font-size: 16px;
  font-weight: 700;
  color: #1a1a2e;
}
.cat-desc {
  font-size: 13px;
  color: #909399;
  line-height: 1.5;
  margin: 0 0 14px;
  min-height: 36px;
}
.cat-meta {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  font-size: 12px;
  color: #c0c4cc;
}
.cat-meta .el-icon {
  transition: transform .3s;
  color: #606266;
}

/* ========================================
   FAQ — 卡片折叠
   ======================================== */
.faq-section {
  margin-bottom: 40px;
}
.faq-header {
  text-align: center;
  margin-bottom: 28px;
}
.faq-title-row {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  margin-bottom: 6px;
}
.faq-badge {
  background: #f72a44;
  color: #fff;
  font-size: 12px;
  font-weight: 700;
  padding: 3px 10px;
  border-radius: 6px;
  letter-spacing: 1px;
}
.faq-title-row h2 { margin: 0; font-size: 24px; color: #1a1a2e; }
.faq-sub { font-size: 14px; color: #909399; margin: 0; }
.faq-grid {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.faq-card {
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 14px;
  overflow: hidden;
  cursor: pointer;
  transition: box-shadow .25s, border-color .25s;
}
.faq-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,.06); border-color: #d4d7de; }
.faq-card.open { border-color: #f72a44; box-shadow: 0 4px 20px rgba(247,42,68,.08); }
.faq-q {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 16px 20px;
}
.faq-q-num {
  width: 28px;
  height: 28px;
  border-radius: 8px;
  background: #f5f6f8;
  color: #909399;
  font-size: 12px;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.faq-q-text { flex: 1; font-size: 15px; font-weight: 600; color: #303133; }
.faq-chevron { color: #c0c4cc; flex-shrink: 0; transition: transform .3s; }
.faq-chevron.rotated { transform: rotate(180deg); }
.faq-a {
  padding: 0 20px 18px 62px;
  color: #606266;
  line-height: 1.8;
  font-size: 14px;
}
.faq-a p { margin: 0; }
.faq-slide-enter-active, .faq-slide-leave-active { transition: all .3s ease; }
.faq-slide-enter-from, .faq-slide-leave-to { opacity: 0; max-height: 0; padding-bottom: 0; }

/* ========================================
   详情页布局
   ======================================== */
.detail-layout { margin-top: -50px; }
.article-shell {
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 4px 24px rgba(0,0,0,.06);
  overflow: hidden;
  min-height: 70vh;
}
.article-aside {
  background: #fafbfc;
  border-right: 1px solid #ebeef5;
  padding: 0;
  overflow-y: auto;
}
.aside-back {
  padding: 16px;
  border-bottom: 1px solid #ebeef5;
}
.aside-menu-title {
  font-size: 12px;
  font-weight: 700;
  color: #909399;
  text-transform: uppercase;
  letter-spacing: .8px;
  padding: 14px 16px 8px;
}
.aside-cat { padding: 0 0 6px; }
.aside-cat-name {
  font-size: 13px;
  font-weight: 700;
  color: #303133;
  padding: 6px 16px;
  display: flex;
  align-items: center;
  gap: 6px;
}
.aside-art {
  font-size: 13px;
  color: #606266;
  padding: 7px 16px 7px 36px;
  cursor: pointer;
  border-left: 2px solid transparent;
  transition: all .2s;
  line-height: 1.5;
}
.aside-art:hover { color: #f72a44; background: #fef0f0; }
.aside-art.active { color: #f72a44; font-weight: 600; border-left-color: #f72a44; background: #fef0f0; }
.aside-toc { padding-bottom: 8px; }
.toc-item {
  font-size: 12.5px;
  color: #606266;
  padding: 6px 16px 6px 36px;
  cursor: pointer;
  transition: color .15s;
  line-height: 1.5;
}
.toc-item:hover { color: #f72a44; }
.toc-item.toc-h3 { padding-left: 50px; font-size: 12px; color: #909399; }

/* 正文区 */
.article-main {
  padding: 40px 56px;
  max-width: 780px;
}
.article-breadcrumb { margin-bottom: 24px; }
.article-title {
  font-size: 32px;
  font-weight: 800;
  color: #1a1a2e;
  margin: 0 0 14px;
  line-height: 1.3;
  letter-spacing: -.3px;
}
.article-meta {
  display: flex;
  gap: 22px;
  font-size: 13px;
  color: #909399;
  margin-bottom: 32px;
  padding-bottom: 20px;
  border-bottom: 1px solid #ebeef5;
}
.article-meta span { display: flex; align-items: center; gap: 4px; }

/* 正文排版 */
.article-body {
  line-height: 1.85;
  color: #303133;
  font-size: 15px;
}
.article-body :deep(h2) {
  font-size: 22px;
  font-weight: 700;
  color: #1a1a2e;
  margin: 40px 0 14px;
  padding-top: 24px;
  border-top: 1px solid #f0f0f0;
}
.article-body :deep(h2:first-of-type) { border-top: none; padding-top: 0; }
.article-body :deep(h3) { font-size: 18px; color: #303133; margin: 28px 0 10px; }
.article-body :deep(p) { margin: 0 0 16px; }
.article-body :deep(strong) { color: #1a1a2e; }
.article-body :deep(.highlight) {
  background: linear-gradient(180deg, transparent 60%, #fef08a 60%);
  padding: 0 2px;
}

/* 图示占位 */
.article-body :deep(.article-illustration) {
  margin: 24px 0;
  border-radius: 12px;
  border: 2px dashed #d4d7de;
  background: #fafbfc;
  padding: 40px 20px;
  text-align: center;
  position: relative;
}
.article-body :deep(.article-illustration::before) {
  font-size: 36px;
  position: absolute;
  left: 50%;
  top: 16px;
  transform: translateX(-50%);
}
.article-body :deep(.article-illustration.compare) { background: linear-gradient(90deg, #fef0f0 50%, #f0faf0 50%); }
.article-body :deep(.article-illustration.compare::before) { content: '🔍'; }
.article-body :deep(.article-illustration.process) { background: #f5f7fa; }
.article-body :deep(.article-illustration.process::before) { content: '⚙️'; }
.article-body :deep(.illu-label) {
  display: block;
  font-size: 13px;
  color: #909399;
  margin-top: 28px;
}

/* 标签 & 反馈 */
.article-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin: 32px 0 28px;
  padding-top: 24px;
  border-top: 1px solid #ebeef5;
}
.article-feedback {
  background: #f8f9fc;
  border-radius: 14px;
  padding: 24px;
  text-align: center;
  margin-top: 16px;
}
.feedback-ask p { margin: 0 0 14px; font-size: 15px; color: #606266; font-weight: 600; }
.feedback-btns { display: flex; justify-content: center; gap: 12px; }
.feedback-thanks {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  color: #303133;
  font-size: 14px;
  font-weight: 500;
}
.feedback-pop-enter-active { transition: all .4s cubic-bezier(.4,0,.2,1); }
.feedback-pop-leave-active { transition: all .25s ease-in; }
.feedback-pop-enter-from { opacity: 0; transform: scale(.9); }
.feedback-pop-leave-to { opacity: 0; transform: scale(.95); }

/* ========================================
   全局底部
   ======================================== */
.global-footer {
  text-align: center;
  padding: 30px 0 40px;
  color: #c0c4cc;
  font-size: 13px;
}
.footer-divider { margin: 0 12px; }

/* ========================================
   响应式
   ======================================== */
@media (max-width: 1100px) {
  .category-grid { grid-template-columns: repeat(3, 1fr); }
  .article-main { padding: 30px 32px; }
}
@media (max-width: 768px) {
  .hero-section { height: 200px; }
  .hero-title { font-size: 28px; }
  .category-grid { grid-template-columns: repeat(2, 1fr); }
  .stats-bar { gap: 24px; flex-wrap: wrap; }
  .article-aside { display: none; }
  .article-main { padding: 24px 20px; }
}
</style>
