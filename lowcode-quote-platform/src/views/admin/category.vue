<template>
  <div class="page">
    <el-container class="layout">
      <el-header class="top">
        <div class="title">分类图纸编排</div>
        <div>
          <el-button type="primary" plain @click="$router.push('/admin/material')">物料中心</el-button>
          <el-button type="success" :disabled="!isLeafNodeSelected" @click="saveToServer">保存图纸</el-button>
          <el-button plain @click="previewJson">预览 JSON</el-button>
        </div>
      </el-header>

      <el-container class="body">
        <el-aside width="280px" class="panel">
          <div class="panel-title">
            <span>分类树</span>
            <el-button link type="primary" @click="openCategoryDialog(null)">新增一级</el-button>
          </div>
          <el-tree
            :data="categoryTree"
            :props="defaultProps"
            node-key="id"
            default-expand-all
            :expand-on-click-node="false"
            @node-click="handleCategoryClick"
          >
            <template #default="{ node, data }">
              <span class="tree-node">
                <span>{{ node.label }}</span>
                <span v-if="node.isCurrent">
                  <el-button link type="primary" @click.stop="openCategoryDialog(data.id)">+子级</el-button>
                  <el-button link type="warning" @click.stop="editCategoryDialog(data)">改名</el-button>
                  <el-button link type="danger" @click.stop="handleDeleteCategory(data)">删</el-button>
                </span>
              </span>
            </template>
          </el-tree>
        </el-aside>

        <el-aside width="220px" class="panel" v-show="isLeafNodeSelected">
          <div class="panel-title">组件库</div>
          <div class="group" v-for="group in groupedComponentTypes" :key="group.category">
            <div class="group-title" v-show="group.list.length">{{ group.title }}</div>
            <div
              class="item"
              :class="{ disabled: isSectionMode && !effectiveSectionId }"
              v-for="component in group.list"
              :key="component.id"
              @click="addComponent(component)"
            >
              {{ component.label }}
            </div>
          </div>
        </el-aside>

        <el-main class="panel">
          <div class="panel-title row">
            <span>{{ isLeafNodeSelected ? `当前分类：${activeCategory?.name || ''}` : '请选择末级分类' }}</span>
            <el-button v-if="isLeafNodeSelected" link type="danger" @click="clearCanvas">清空当前区域</el-button>
          </div>

          <div class="section-bar" v-if="isLeafNodeSelected">
            <el-segmented
              v-model="editingScope"
              :options="[
                { label: '公共配置', value: 'common' },
                { label: '分组配置', value: 'section' }
              ]"
            />

            <el-select
              v-if="isSectionMode && namedSections.length"
              v-model="selectedNamedSectionId"
              style="width: 220px"
              placeholder="请选择分组"
              clearable
            >
              <el-option v-for="section in namedSections" :key="section.id" :label="section.name" :value="section.id" />
            </el-select>

            <div v-if="isSectionMode && !namedSections.length" class="section-empty-tip">暂无分组，请先新增分组</div>
            <div v-if="isSectionMode && namedSections.length && !effectiveSectionId" class="section-empty-tip">请先选择分组</div>
            <div v-if="!isSectionMode" class="section-empty-tip">当前正在编辑“公共配置”</div>

            <el-button plain type="primary" @click="addSection">新增分组</el-button>
            <el-button plain :disabled="!isSectionMode || !effectiveSectionId" @click="renameSection">重命名</el-button>
            <el-button plain :disabled="!isSectionMode || !effectiveSectionId" @click="moveSection(-1)">上移</el-button>
            <el-button plain :disabled="!isSectionMode || !effectiveSectionId" @click="moveSection(1)">下移</el-button>
            <el-button plain type="danger" :disabled="!isSectionMode || !effectiveSectionId" @click="removeSection">删除</el-button>
          </div>

          <div class="canvas" v-if="isLeafNodeSelected">
            <template v-if="canEditCurrentScope">
              <template v-for="tabKey in sectionKeys" :key="tabKey">
                <el-divider v-if="currentBucket && currentBucket[tabKey]?.length" content-position="left">{{ tabTitle(tabKey) }}</el-divider>
                <div
                  class="field"
                  v-for="element in (currentBucket?.[tabKey] || [])"
                  :key="element.id"
                  :class="{ active: currentActiveElementId === element.id }"
                  @click="selectElement(element)"
                >
                  <div class="field-head">
                    <span>{{ element.name }}</span>
                    <el-button link type="danger" @click.stop="removeElement(element.id)">删除</el-button>
                  </div>
                  <div class="field-body">类型：{{ element.type }} | ID：{{ element.id }}</div>
                </div>
              </template>
            </template>

            <el-empty v-if="!currentBucketElements.length" :description="canvasEmptyDescription" />
          </div>
        </el-main>

        <el-aside width="360px" class="panel" v-show="isLeafNodeSelected">
          <div class="panel-title">属性编辑</div>
          <div class="editor" v-if="currentActiveElement && canEditCurrentScope">
            <el-form label-position="top">
              <el-form-item label="组件 ID"><el-input v-model="currentActiveElement.id" disabled /></el-form-item>
              <el-form-item label="显示标题"><el-input v-model="currentActiveElement.name" /></el-form-item>
              <el-form-item label="提示文案"><el-input v-model="currentActiveElement.tip" /></el-form-item>
              <el-form-item label="必填"><el-switch v-model="currentActiveElement.isRequired" /></el-form-item>
              <el-form-item label="权重"><el-input-number v-model="currentActiveElement.weight" :step="1" /></el-form-item>

              <template v-if="['select', 'radio', 'checkbox'].includes(currentActiveElement.type)">
                <el-divider>选项</el-divider>
                <div class="opt-row" v-for="(option, optionIndex) in currentActiveElement.options" :key="optionIndex">
                  <el-input v-model="option.label" size="small" />
                  <el-input-number v-model="option.priceAdd" size="small" :step="1" />
                  <el-button
                    v-if="currentActiveElement.type === 'checkbox'"
                    link
                    type="warning"
                    @click="openSubElementEditor(option)"
                  >
                    子字段({{ (option.subElements || []).length }})
                  </el-button>
                  <el-button link type="danger" @click="removeOption(currentActiveElement, optionIndex)">删</el-button>
                </div>
                <el-button plain type="primary" @click="addOption(currentActiveElement)">新增选项</el-button>
              </template>

              <template v-if="currentActiveElement.type === 'number'">
                <el-divider>数值</el-divider>
                <el-form-item label="单位"><el-input v-model="currentActiveElement.unit" /></el-form-item>
                <el-form-item label="最小值"><el-input-number v-model="currentActiveElement.min" :step="1" /></el-form-item>
                <el-form-item label="最大值"><el-input-number v-model="currentActiveElement.max" :step="1" /></el-form-item>
                <el-form-item label="步长"><el-input-number v-model="currentActiveElement.step" :step="1" /></el-form-item>
              </template>

              <template v-if="currentActiveElement.type === 'size-mix'">
                <el-divider>尺寸预设</el-divider>
                <div class="opt-row size-preset-row" v-for="(preset, presetIndex) in currentActiveElement.presets" :key="presetIndex">
                  <el-input v-model="preset.label" size="small" placeholder="如：90x54mm" />
                  <el-input-number v-model="preset.width" size="small" :min="0" :step="1" />
                  <el-input-number v-model="preset.height" size="small" :min="0" :step="1" />
                  <el-button link type="danger" @click="removeSizePreset(currentActiveElement, presetIndex)">删</el-button>
                </div>
                <el-button plain type="primary" @click="addSizePreset(currentActiveElement)">新增尺寸</el-button>
              </template>

              <el-divider>联动约束（当前配置区域）</el-divider>
              <el-card v-for="(rule, ruleIndex) in currentConstraints" :key="ruleIndex" class="rule-card" shadow="never">
                <el-select v-model="rule.condition.targetId" placeholder="条件字段">
                  <el-option v-for="candidate in currentBucketElements" :key="candidate.id" :label="candidate.name" :value="candidate.id" />
                </el-select>
                <el-select v-model="rule.condition.operator" style="margin-top: 6px">
                  <el-option label="等于" value="==" />
                  <el-option label="不等于" value="!=" />
                  <el-option label="包含" value="in" />
                </el-select>
                <el-input v-model="rule.condition.value" placeholder="条件值" style="margin-top: 6px" />
                <el-select v-model="rule.action.effect" style="margin-top: 6px">
                  <el-option label="隐藏" value="hide" />
                  <el-option label="禁用" value="disable" />
                </el-select>
                <el-button link type="danger" @click="removeConstraint(rule)">删除规则</el-button>
              </el-card>
              <el-button plain type="warning" @click="addConstraint">+ 添加约束</el-button>
            </el-form>
          </div>
          <el-empty v-else :description="propertyEmptyDescription" />
        </el-aside>
      </el-container>
    </el-container>

    <el-drawer v-model="jsonDrawerVisible" title="Schema JSON" size="40%">
      <el-input type="textarea" :rows="30" :value="JSON.stringify(schemaData, null, 2)" readonly />
    </el-drawer>

    <el-dialog v-model="categoryDialogVisible" :title="categoryForm.id ? '编辑分类' : '新增分类'" width="460px">
      <el-form label-width="90px">
        <el-form-item label="名称"><el-input v-model="categoryForm.name" /></el-form-item>
        <el-form-item label="排序"><el-input-number v-model="categoryForm.sortOrder" :min="1" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="categoryDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveCategory">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="subElementEditorVisible" :title="`子字段配置 - ${subElementEditingOpt?.label || ''}`" width="640px">
      <el-card v-for="(sub, index) in subElementEditList" :key="index" shadow="never" style="margin-bottom: 10px">
        <div class="sub-row">
          <el-input v-model="sub.name" placeholder="字段名" />
          <el-select v-model="sub.type" style="width: 120px">
            <el-option label="select" value="select" />
            <el-option label="number" value="number" />
            <el-option label="text" value="text" />
          </el-select>
          <el-checkbox v-model="sub.required">必填</el-checkbox>
          <el-button link type="danger" @click="subElementEditList.splice(index, 1)">删</el-button>
        </div>
        <div v-if="sub.type === 'select'" style="margin-top: 8px">
          <div class="sub-row" v-for="(option, optionIndex) in (sub.options || [])" :key="optionIndex">
            <el-input v-model="option.label" placeholder="选项名" />
            <el-button link type="danger" @click="sub.options.splice(optionIndex, 1)">删</el-button>
          </div>
          <el-button plain size="small" @click="addSubOption(sub)">+ 选项</el-button>
        </div>
      </el-card>
      <el-button plain type="primary" style="width: 100%" @click="addSubElement">+ 添加子字段</el-button>
      <template #footer>
        <el-button @click="subElementEditorVisible = false">取消</el-button>
        <el-button type="primary" @click="saveSubElements">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getAdminCategoryTree, addCategory, updateCategory, deleteCategory } from '@/api/category'
import { getCategorySchema, saveCategorySchema } from '@/api/schema'
import { getMaterialList } from '@/api/material'
import { SECTION_KEYS, createEmptyBucket, createEmptySection, getAllSchemaElements, getSectionElements, normalizeSchema } from '@/utils/schema'

const sectionKeys = SECTION_KEYS
const defaultProps = { children: 'children', label: 'name' }

const categoryTree = ref([])
const activeCategory = ref(null)
const componentTypes = ref([])
const activeSectionId = ref('')
const currentActiveElementId = ref(null)
const jsonDrawerVisible = ref(false)
const editingScope = ref('section')

const categoryDialogVisible = ref(false)
const categoryForm = ref({ id: null, name: '', parentId: null, sortOrder: 1 })

const subElementEditorVisible = ref(false)
const subElementEditingOpt = ref(null)
const subElementEditList = ref([])

const schemaData = ref(normalizeSchema(null))

const isLeafNodeSelected = computed(() => activeCategory.value && (!activeCategory.value.children || activeCategory.value.children.length === 0))
const isSectionMode = computed(() => editingScope.value === 'section')

const groupedComponentTypes = computed(() => ([
  { title: '物料', category: 'materials', list: componentTypes.value.filter(c => c.category === 'materials') },
  { title: '尺寸', category: 'sizeGroup', list: componentTypes.value.filter(c => c.category === 'sizeGroup') },
  { title: '工艺', category: 'crafts', list: componentTypes.value.filter(c => c.category === 'crafts') },
  { title: '通用', category: 'elements', list: componentTypes.value.filter(c => !['materials', 'sizeGroup', 'crafts'].includes(c.category)) }
]))

const orderedSections = computed(() => {
  return [...(schemaData.value.sections || [])].sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0))
})

const namedSections = computed(() => {
  return orderedSections.value.filter((section) => (section.name || '').trim())
})

const selectedNamedSectionId = computed({
  get() {
    return namedSections.value.some(section => section.id === activeSectionId.value) ? activeSectionId.value : ''
  },
  set(value) {
    activeSectionId.value = value || ''
  }
})

const effectiveSectionId = computed(() => {
  if (!isSectionMode.value) return ''
  return namedSections.value.some(section => section.id === activeSectionId.value) ? activeSectionId.value : ''
})

const currentSection = computed(() => {
  if (!effectiveSectionId.value) return null
  return (schemaData.value.sections || []).find(section => section.id === effectiveSectionId.value) || null
})

const currentBucket = computed(() => {
  return isSectionMode.value ? currentSection.value : schemaData.value.common
})

const currentBucketElements = computed(() => getSectionElements(currentBucket.value))
const allElements = computed(() => getAllSchemaElements(schemaData.value))
const currentActiveElement = computed(() => allElements.value.find(element => element.id === currentActiveElementId.value))

const currentConstraints = computed(() => {
  return (currentBucket.value?.constraints || []).filter(constraint => constraint?.action?.targetId === currentActiveElementId.value)
})

const canEditCurrentScope = computed(() => !isSectionMode.value || !!effectiveSectionId.value)

const canvasEmptyDescription = computed(() => {
  if (isSectionMode.value && !namedSections.value.length) return '暂无分组，请先新增分组'
  if (isSectionMode.value && !effectiveSectionId.value) return '请先选择分组'
  return '请从左侧添加字段到当前配置区域'
})

const propertyEmptyDescription = computed(() => {
  if (isSectionMode.value && !namedSections.value.length) return '暂无分组，请先新增分组'
  if (isSectionMode.value && !effectiveSectionId.value) return '请先选择分组'
  return '请先在中间选中字段'
})

const tabTitle = (key) => ({ materials: '物料', sizeGroup: '尺寸', crafts: '工艺', elements: '通用' }[key] || key)

const ensureSchemaShape = () => {
  if (!schemaData.value || typeof schemaData.value !== 'object') schemaData.value = normalizeSchema(null)
  if (!schemaData.value.common) schemaData.value.common = createEmptyBucket('', 0, 'common')
  if (!Array.isArray(schemaData.value.sections)) schemaData.value.sections = []
}

const guardSectionWrite = () => {
  if (isSectionMode.value && !effectiveSectionId.value) {
    ElMessage.warning('请先选择分组')
    return false
  }
  return true
}

watch([editingScope, effectiveSectionId], () => {
  if (isSectionMode.value && !effectiveSectionId.value) currentActiveElementId.value = null
})

watch(allElements, () => {
  if (!allElements.value.some(element => element.id === currentActiveElementId.value)) {
    currentActiveElementId.value = null
  }
})

const fetchCategoryTree = async () => {
  categoryTree.value = (await getAdminCategoryTree().catch(() => [])) || []
}

const fetchMaterials = async () => {
  componentTypes.value = (await getMaterialList().catch(() => [])) || []
}

const initEmptySchema = (categoryId) => {
  schemaData.value = normalizeSchema({
    categoryId,
    productName: activeCategory.value?.name || '未命名产品',
    schemaVersion: 2,
    common: createEmptyBucket('', 0, 'common'),
    sections: [],
    pricing: { basePrice: 0, quantityElId: null }
  })
  activeSectionId.value = ''
  currentActiveElementId.value = null
}

const fetchSchemaData = async (categoryId) => {
  try {
    let response = await getCategorySchema(categoryId)
    if (typeof response === 'string') response = JSON.parse(response)
    schemaData.value = normalizeSchema({ ...(response || {}), categoryId }, activeCategory.value?.name || '')
  } catch {
    initEmptySchema(categoryId)
    return
  }
  ensureSchemaShape()
  activeSectionId.value = namedSections.value.some(section => section.id === activeSectionId.value) ? activeSectionId.value : ''
  currentActiveElementId.value = null
}

const handleCategoryClick = async (data) => {
  activeCategory.value = data
  if (isLeafNodeSelected.value) await fetchSchemaData(data.id)
}

const openCategoryDialog = (parentId) => {
  categoryForm.value = { id: null, name: '', parentId, sortOrder: 1 }
  categoryDialogVisible.value = true
}

const editCategoryDialog = (data) => {
  categoryForm.value = { id: data.id, name: data.name, parentId: data.parentId, sortOrder: data.sortOrder }
  categoryDialogVisible.value = true
}

const saveCategory = async () => {
  if (!categoryForm.value.name) return ElMessage.warning('名称必填')
  if (categoryForm.value.id) await updateCategory(categoryForm.value)
  else await addCategory(categoryForm.value)
  categoryDialogVisible.value = false
  ElMessage.success('保存成功')
  await fetchCategoryTree()
}

const handleDeleteCategory = async (data) => {
  if (data.children?.length) return ElMessage.error('请先删除子节点')
  try {
    await ElMessageBox.confirm('确认删除该分类？', '提示', { type: 'warning' })
    await deleteCategory(data.id)
    ElMessage.success('已删除')
    await fetchCategoryTree()
  } catch (_) {}
}

const addSection = async () => {
  try {
    const { value } = await ElMessageBox.prompt('请输入分组名称', '新增分组', {
      inputPattern: /.+/,
      inputErrorMessage: '不能为空'
    })
    const section = createEmptySection(value.trim(), (schemaData.value.sections?.length || 0) + 1)
    schemaData.value.sections.push(section)
    activeSectionId.value = section.id
    editingScope.value = 'section'
  } catch (_) {}
}

const renameSection = async () => {
  if (!effectiveSectionId.value || !currentSection.value) return
  try {
    const { value } = await ElMessageBox.prompt('请输入分组名称', '重命名', {
      inputValue: currentSection.value.name,
      inputPattern: /.+/,
      inputErrorMessage: '不能为空'
    })
    currentSection.value.name = value.trim()
  } catch (_) {}
}

const removeSection = async () => {
  if (!effectiveSectionId.value || !currentSection.value) return
  if ((schemaData.value.sections || []).length <= 1) return ElMessage.warning('至少保留一个分组')
  try {
    await ElMessageBox.confirm(`确认删除分组 ${currentSection.value.name}？`, '提示', { type: 'warning' })
    schemaData.value.sections = schemaData.value.sections.filter(section => section.id !== currentSection.value.id)
    schemaData.value.sections.forEach((section, index) => {
      section.sortOrder = index + 1
    })
    activeSectionId.value = ''
    currentActiveElementId.value = null
  } catch (_) {}
}

const moveSection = (delta) => {
  if (!effectiveSectionId.value) return
  const list = [...orderedSections.value]
  const from = list.findIndex(section => section.id === effectiveSectionId.value)
  const to = from + delta
  if (from < 0 || to < 0 || to >= list.length) return
  const temp = list[from]
  list[from] = list[to]
  list[to] = temp
  list.forEach((section, index) => {
    section.sortOrder = index + 1
  })
  schemaData.value.sections = list
}

const parseSizeFromLabel = (label) => {
  const text = String(label || '').trim()
  const match = text.match(/(\d+(?:\.\d+)?)\D+(\d+(?:\.\d+)?)/)
  if (!match) return null
  return { width: Number(match[1]), height: Number(match[2]) }
}

const normalizeSizePreset = (preset) => {
  if (preset && typeof preset === 'object' && !Array.isArray(preset)) {
    const width = Number(preset.width) || 0
    const height = Number(preset.height) || 0
    const label = (preset.label || '').trim() || (width > 0 && height > 0 ? `${width}x${height}mm` : '')
    return { label, width, height }
  }
  const parsed = parseSizeFromLabel(preset)
  if (!parsed) return null
  return {
    label: String(preset || '').trim() || `${parsed.width}x${parsed.height}mm`,
    width: parsed.width,
    height: parsed.height
  }
}

const normalizeElementForEditor = (element) => {
  if (!element) return
  if (element.type === 'size-mix') {
    const normalized = (Array.isArray(element.presets) ? element.presets : [])
      .map(normalizeSizePreset)
      .filter(Boolean)
    element.presets = normalized.length ? normalized : [{ label: '90x54mm', width: 90, height: 54 }]
  }
}

const selectElement = (element) => {
  if (!canEditCurrentScope.value) return
  normalizeElementForEditor(element)
  currentActiveElementId.value = element.id
}

const addComponent = (componentDef) => {
  if (!canEditCurrentScope.value && !guardSectionWrite()) return
  if (!currentBucket.value) return

  const targetTab = sectionKeys.includes(componentDef.category) ? componentDef.category : 'elements'
  let options = null
  if (componentDef.optionsJson) {
    try {
      options = JSON.parse(componentDef.optionsJson)
    } catch (_) {}
  }

  const prefix = isSectionMode.value ? effectiveSectionId.value : 'common'
  const baseId = `${prefix}_${componentDef.type}_${Date.now()}`
  const element = {
    id: baseId,
    type: componentDef.type,
    name: componentDef.label,
    tip: '',
    isRequired: false,
    weight: 0,
    options: options || (['select', 'radio', 'checkbox'].includes(componentDef.type)
      ? [{ id: `${baseId}_opt_1`, label: '默认选项', priceAdd: 0, priceRatio: 1 }]
      : null)
  }

  if (componentDef.type === 'number') Object.assign(element, { min: 1, max: 1000, step: 1, presets: [] })
  if (componentDef.type === 'size-mix') Object.assign(element, { presets: [{ label: '90x54mm', width: 90, height: 54 }] })

  if (!currentBucket.value[targetTab]) currentBucket.value[targetTab] = []
  currentBucket.value[targetTab].push(element)
  currentActiveElementId.value = element.id
}

const removeElement = (elementId) => {
  if (!canEditCurrentScope.value && !guardSectionWrite()) return
  if (!currentBucket.value) return
  if (currentActiveElementId.value === elementId) currentActiveElementId.value = null

  sectionKeys.forEach((key) => {
    const list = currentBucket.value[key] || []
    const index = list.findIndex(element => element.id === elementId)
    if (index !== -1) list.splice(index, 1)
  })

  currentBucket.value.constraints = (currentBucket.value.constraints || []).filter((rule) => {
    return rule?.condition?.targetId !== elementId && rule?.action?.targetId !== elementId
  })
}

const clearCanvas = () => {
  if (!canEditCurrentScope.value && !guardSectionWrite()) return
  if (!currentBucket.value) return
  sectionKeys.forEach((key) => {
    currentBucket.value[key] = []
  })
  currentBucket.value.constraints = []
  currentActiveElementId.value = null
}

const addOption = (element) => {
  if (!canEditCurrentScope.value && !guardSectionWrite()) return
  if (!element.options) element.options = []
  element.options.push({ id: `${element.id}_opt_${Date.now()}`, label: '新选项', priceAdd: 0, priceRatio: 1 })
}

const removeOption = (element, index) => {
  if (!canEditCurrentScope.value && !guardSectionWrite()) return
  element.options.splice(index, 1)
}

const addSizePreset = (element) => {
  if (!canEditCurrentScope.value && !guardSectionWrite()) return
  normalizeElementForEditor(element)
  element.presets.push({ label: '', width: 0, height: 0 })
}

const removeSizePreset = (element, index) => {
  if (!canEditCurrentScope.value && !guardSectionWrite()) return
  normalizeElementForEditor(element)
  if (element.presets.length <= 1) {
    ElMessage.warning('至少保留一个尺寸预设')
    return
  }
  element.presets.splice(index, 1)
}

const openSubElementEditor = (option) => {
  if (!canEditCurrentScope.value && !guardSectionWrite()) return
  subElementEditingOpt.value = option
  subElementEditList.value = JSON.parse(JSON.stringify(option.subElements || []))
  subElementEditorVisible.value = true
}

const addSubElement = () => {
  subElementEditList.value.push({
    id: `sub_${Date.now()}`,
    name: '新字段',
    type: 'select',
    required: false,
    options: [{ id: `sopt_${Date.now()}`, label: '默认选项' }]
  })
}

const addSubOption = (sub) => {
  if (!sub.options) sub.options = []
  sub.options.push({ id: `sopt_${Date.now()}`, label: '新选项' })
}

const saveSubElements = () => {
  if (!canEditCurrentScope.value && !guardSectionWrite()) return
  if (!subElementEditingOpt.value) return
  subElementEditingOpt.value.subElements = subElementEditList.value
  subElementEditorVisible.value = false
  ElMessage.success('子字段已保存')
}

const addConstraint = () => {
  if (!canEditCurrentScope.value && !guardSectionWrite()) return
  if (!currentBucket.value || !currentActiveElementId.value) return ElMessage.warning('请先选中字段')
  if (!currentBucket.value.constraints) currentBucket.value.constraints = []
  currentBucket.value.constraints.push({
    scope: isSectionMode.value ? 'section' : 'global',
    sectionId: isSectionMode.value ? effectiveSectionId.value : 'common',
    condition: { targetId: '', operator: '==', value: '' },
    action: { targetId: currentActiveElementId.value, effect: 'hide' }
  })
}

const removeConstraint = (rule) => {
  if (!canEditCurrentScope.value && !guardSectionWrite()) return
  const list = currentBucket.value?.constraints || []
  const index = list.indexOf(rule)
  if (index !== -1) list.splice(index, 1)
}

const cleanArray = (array) => {
  return (array || []).map(element => {
    const cleaned = { ...element }
    if (cleaned.options) {
      cleaned.options = cleaned.options.map(option => ({ priceRatio: 1, ...option }))
    }
    if (cleaned.type === 'size-mix') {
      cleaned.presets = (Array.isArray(cleaned.presets) ? cleaned.presets : [])
        .map(normalizeSizePreset)
        .filter(preset => preset && preset.width > 0 && preset.height > 0)
        .map((preset) => ({
          label: (preset.label || '').trim() || `${preset.width}x${preset.height}mm`,
          width: preset.width,
          height: preset.height
        }))
      if (!cleaned.presets.length) {
        cleaned.presets = [{ label: '90x54mm', width: 90, height: 54 }]
      }
    }
    return cleaned
  })
}

const cleanBucket = (bucket) => ({
  ...bucket,
  materials: cleanArray(bucket.materials),
  sizeGroup: cleanArray(bucket.sizeGroup),
  crafts: cleanArray(bucket.crafts),
  elements: cleanArray(bucket.elements)
})

const saveToServer = async () => {
  if (!schemaData.value.categoryId && activeCategory.value?.id) schemaData.value.categoryId = activeCategory.value.id
  if (!schemaData.value.categoryId) return ElMessage.error('请先选择末级分类')

  schemaData.value.productName = activeCategory.value?.name || schemaData.value.productName || '未命名产品'

  const validIds = new Set(allElements.value.map(element => element.id))
  const common = cleanBucket(schemaData.value.common || createEmptyBucket('', 0, 'common'))
  common.id = 'common'
  common.sortOrder = 0
  common.constraints = (common.constraints || []).filter((constraint) => {
    return constraint?.condition?.targetId &&
      validIds.has(constraint.condition.targetId) &&
      constraint?.action?.targetId &&
      validIds.has(constraint.action.targetId)
  })

  const sections = orderedSections.value.map((section, index) => {
    const cleaned = cleanBucket(section)
    cleaned.sortOrder = index + 1
    cleaned.constraints = (cleaned.constraints || []).filter((constraint) => {
      return constraint?.condition?.targetId &&
        validIds.has(constraint.condition.targetId) &&
        constraint?.action?.targetId &&
        validIds.has(constraint.action.targetId)
    })
    return cleaned
  })

  const payload = {
    categoryId: schemaData.value.categoryId,
    productName: schemaData.value.productName,
    schemaVersion: 2,
    common,
    sections,
    constraints: Array.isArray(schemaData.value.constraints) ? schemaData.value.constraints : [],
    pricing: schemaData.value.pricing || { basePrice: 0, quantityElId: null }
  }

  await saveCategorySchema(payload.categoryId, payload)
  ElMessage.success('图纸保存成功')
}

const previewJson = () => {
  jsonDrawerVisible.value = true
}

onMounted(async () => {
  await fetchCategoryTree()
  await fetchMaterials()
  ensureSchemaShape()
})
</script>

<style scoped>
.page { height: 100vh; overflow: hidden; }
.layout { height: 100%; background: #eef0f3; overflow: hidden; }
.top { height: 60px; display: flex; align-items: center; justify-content: space-between; background: #2b333e; color: #fff; padding: 0 16px; flex-shrink: 0; }
.title { font-size: 18px; font-weight: 600; }
.body { height: calc(100vh - 60px); min-height: 0; padding: 12px; gap: 12px; box-sizing: border-box; overflow: hidden; }
.panel { height: 100%; min-height: 0; background: #fff; border-radius: 8px; overflow: auto; }
.panel-title { display: flex; justify-content: space-between; align-items: center; padding: 10px 12px; border-bottom: 1px solid #f0f0f0; font-weight: 600; }
.row { align-items: center; }
.tree-node { width: 100%; display: flex; justify-content: space-between; align-items: center; }
.group { padding: 8px; }
.group-title { font-size: 12px; color: #909399; margin: 8px 0; }
.item { padding: 8px 10px; border: 1px dashed #dcdfe6; border-radius: 4px; margin-bottom: 8px; cursor: pointer; }
.item:hover { border-color: #409eff; background: #ecf5ff; }
.item.disabled { cursor: not-allowed; opacity: 0.45; background: #f5f7fa; border-color: #ebeef5; }
.section-bar { display: flex; flex-wrap: wrap; gap: 8px; padding: 12px; border-bottom: 1px solid #f4f4f4; align-items: center; }
.section-empty-tip { height: 32px; line-height: 32px; padding: 0 10px; color: #909399; background: #f5f7fa; border-radius: 4px; border: 1px solid #ebeef5; }
.canvas { padding: 12px; }
.field { border: 1px dashed #e4e7ed; border-radius: 6px; padding: 10px; margin-bottom: 10px; cursor: pointer; }
.field.active { border-color: #409eff; background: #ecf5ff; }
.field-head { display: flex; justify-content: space-between; align-items: center; }
.field-body { color: #909399; font-size: 12px; margin-top: 6px; }
.editor { padding: 12px; }
.opt-row, .sub-row { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
.size-preset-row { margin-bottom: 12px; }
.size-preset-row :deep(.el-input) { flex: 1; min-width: 160px; }
.size-preset-row :deep(.el-input-number) { width: 96px; flex-shrink: 0; }
.size-preset-row :deep(.el-input__wrapper) { min-height: 34px; }
.size-preset-row :deep(.el-input__inner) { line-height: 22px; }
.rule-card { margin-bottom: 8px; }
</style>
