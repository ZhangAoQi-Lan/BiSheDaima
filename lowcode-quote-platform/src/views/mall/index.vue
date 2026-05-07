<template>
  <div class="mall-container">
    <MallNavbar />

    <div class="mall-body">
      <!-- 左侧一级分类侧边栏 -->
      <aside class="category-sidebar">
        <div class="sidebar-inner" @mouseleave="handleSidebarLeave">
          <ul class="category-list">
            <!-- 一级分类列表（鼠标进入时展示飞出面板） -->
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

        <!-- 三级分类飞出面板 (Megamenu Style) -->
        <div
          v-show="hoveredCategoryId && currentHoveredCategory"
          class="subcategory-flyout"
          :style="flyoutStyle"
          @mouseenter="handleFlyoutEnter"
          @mouseleave="handleFlyoutLeave"
        >
          <div class="flyout-inner" v-if="currentHoveredCategory">
            <!-- 头部：一级分类名称自用标题 -->
            <div class="flyout-title">{{ currentHoveredCategory.name }}</div>
            
            <div class="flyout-rows">
              <!-- 二级分类行 -->
              <div 
                v-for="sub2 in currentHoveredCategory.children" 
                :key="sub2.id"
                class="sub-group-row"
              >
                <!-- 二级标题 -->
                <div class="sub-group-label" @click.stop="selectCategory(currentHoveredCategory.id, sub2.id)">
                  {{ sub2.name }}
                  <el-icon><ArrowRight /></el-icon>
                </div>
                
                <!-- 三级明细 (叶子节点) -->
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
                  <!-- 如果二级没有子节点，则二级本身也是可点击的叶子 -->
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
          <!-- 面包屑导航移入容器 -->
          <div class="container-header">
            <div class="breadcrumb">
              <span class="breadcrumb-item" @click="selectCategory(null, null)">商城首页</span>
              <template v-for="(pathItem, index) in categoryPath" :key="pathItem.id">
                <el-icon style="font-size:12px;color:#c0c4cc;margin:0 4px"><ArrowRight /></el-icon>
                <span 
                  class="breadcrumb-item" 
                  :class="{ active: index === categoryPath.length - 1 }"
                  @click="index < categoryPath.length - 1 ? jumpToPath(pathItem, index) : null"
                >
                  {{ pathItem.name }}
                </span>
              </template>
            </div>
          </div>
          <DynamicQuoteForm :categoryId="selectedCategoryId" :key="selectedCategoryId" />
        </div>
        <div v-else-if="!loading" class="empty-state-wrapper">
          <div class="empty-content">
            <img src="@/assets/illustrations/empty-mall.png" alt="Select Product" class="empty-img" />
            <div class="empty-text">
              当前尚未选择产品，请通过左侧产品分类选择产品吧...
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="footer">
      <p>© 2026 印刷包装生态有限公司 版权所有 | 基于 Vue 3 &amp; Element Plus 构建</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { Picture, Folder, Grid, ArrowRight } from '@element-plus/icons-vue'
import { getMallCategoryTree } from '@/api/category'
import { useRouter } from 'vue-router'
import MallNavbar from '@/components/MallNavbar.vue'
import DynamicQuoteForm from '@/components/dynamic-form/DynamicQuoteForm.vue'

const router = useRouter()
const selectedCategoryId = ref(null) // 当前选中的用于渲染表单的最底层节点 ID
const categoryTree = ref([])   // 树形结构：[{ id, name, children: [...] }]
const loading = ref(false)

// 当前选中项的路径信息
const activeCategoryId = ref(null)       // 选中的一级分类 id
const activeSubCategoryId = ref(null)    // 选中的子级分类 id (可能是二级也可能是三级)

// 飞出面板控制
const hoveredCategoryId = ref(null)      // 鼠标悬停的一级分类 id
const flyoutHovered = ref(false)         // 飞出面板是否被鼠标悬停
let hideTimer = null

// 飞出面板对应的分类数据
const currentHoveredCategory = computed(() =>
  categoryTree.value.find(c => c.id === hoveredCategoryId.value)
)

const hoveredItemTop = ref(0) // 记录当前悬停元素的 top 偏移量

// 飞出面板位置（动态 top 对齐悬停菜单项）
const flyoutStyle = computed(() => ({
  top: `${hoveredItemTop.value}px`,
  left: '198px' // 比 200px 小一点，制造重叠区避免 hover 丢失
}))

// 当鼠标进入左侧具体的某一项分类时
const handleItemEnter = (id, event) => {
  clearTimeout(hideTimer) // 只要是在左侧菜单内部切换，就立刻清理消失定时器
  hoveredCategoryId.value = id
  if (event && event.currentTarget) {
    // 获取当前 li 相对于包含块（即 aside）的 offsetTop
    hoveredItemTop.value = event.currentTarget.offsetTop
  }
}

// 侧边栏整体鼠标离开
const handleSidebarLeave = () => {
  hideTimer = setTimeout(() => {
    if (!flyoutHovered.value) hoveredCategoryId.value = null
  }, 200) // 容错时间
}

// 鼠标进入飞出面板（证明用户划过去了）
const handleFlyoutEnter = () => {
  clearTimeout(hideTimer)
  flyoutHovered.value = true
}

// 鼠标彻底离开飞出面板
const handleFlyoutLeave = () => {
  flyoutHovered.value = false
  // 这里也需要有延时，防止用户只是不小心划出去又立刻回来
  hideTimer = setTimeout(() => {
    hoveredCategoryId.value = null
  }, 200)
}

// 选择分类，现在它就是“选中产品”的动作
const selectCategory = async (firstId, subId) => {
  activeCategoryId.value = firstId
  activeSubCategoryId.value = subId
  hoveredCategoryId.value = null
  flyoutHovered.value = false
  
  // 以二级分类ID优先，如果它是叶子节点则直接显示右侧配图单
  selectedCategoryId.value = subId ?? firstId
}

// 计算当前选中节点的完整路径 [Level1, Level2, Level3...]
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

const jumpToPath = (item, index) => {
  // 面包屑点击跳转：如果点的是第一级，仅保留第一级选中
  if (index === 0) {
    selectCategory(item.id, null)
  } else {
    // 否则选中该节点
    selectCategory(activeCategoryId.value, item.id)
  }
}

// 便捷查名 (由于有了路径计算，这两个可以精简或移除)
const getFirstLevelName = (id) => categoryTree.value.find(c => c.id === id)?.name ?? ''

// 移除老的跳转详情逻辑（现已改为原地直接渲染直配表单）
// const goToDetail = (id) => router.push(`/mall/product/${id}`)

onMounted(async () => {
  loading.value = true
  const treeRes = await getMallCategoryTree().catch(() => null)
  if (treeRes) {
     categoryTree.value = treeRes || []
  }
  loading.value = false
})

onUnmounted(() => clearTimeout(hideTimer))
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
  position: relative;   /* 飞出面板的定位参考 */
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
  padding-bottom: 8px; /* 补足底部圆角处可能被遮挡的白边 */
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

/* ===== 飞出面板 (Megamenu) ===== */
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
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  padding: 20px;
  border: 1px solid #ebeef5;
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
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 4px;
  flex-shrink: 0;
  margin-top: 4px;
}

.sub-group-label:hover {
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

/* ===== 右侧区域及直配容器 ===== */
.product-area {
  flex: 1;
  margin-left: 20px;
  min-width: 0;
}

.area-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
  padding: 0 4px;
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

.product-count {
  margin: 0;
  color: #909399;
  font-size: 13px;
}

/* 直配表单的外层容器 */
.direct-quote-container {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.04);
  padding: 0;
  overflow: hidden;
}

.empty-state-wrapper {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 500px;
  background: transparent;
}

.empty-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
  animation: fadeIn 0.6s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.empty-img {
  width: 320px;
  height: auto;
  opacity: 0.85;
}

.empty-text {
  color: #a8abb2;
  font-size: 16px;
  letter-spacing: 0.5px;
  user-select: none;
}

.category-name {
  flex: 1;
  font-weight: 500;
}

.category-item.active {
  background-color: #f0f7ff;
  color: #409eff;
  border-left: 4px solid #409eff;
}

.category-item:hover:not(.active) {
  background-color: #f9fafb;
  color: #409eff;
}


/* ===== 页脚 ===== */
.footer {
  text-align: center;
  padding: 28px 0;
  color: #909399;
  font-size: 13px;
  background-color: #fff;
  border-top: 1px solid #ebeef5;
}
</style>
