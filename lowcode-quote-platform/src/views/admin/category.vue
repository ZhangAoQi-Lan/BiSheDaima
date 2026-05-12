<template>
  <div class="admin-page">
    <AdminNavbar />
    <div class="page-body">
      <el-container class="layout">
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
            <div class="panel-actions">
              <el-button v-if="isLeafNodeSelected" link type="danger" @click="clearCanvas">清空当前区域</el-button>
              <el-button type="success" size="small" :disabled="!isLeafNodeSelected" @click="saveToServer">保存图纸</el-button>
              <el-button plain size="small" @click="previewJson">预览 JSON</el-button>
            </div>
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
                  <el-input v-model="option.label" size="small" placeholder="名称" />
                  <el-input-number v-model="option.priceAdd" size="small" :step="1" placeholder="加价" />
                  <el-input-number v-model="option.priceRatio" size="small" :min="0" :step="0.1" :precision="2" placeholder="系数" style="width: 90px" />
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
                  <el-input-number v-model="preset.width" size="small" :min="0" :step="1" placeholder="宽" />
                  <el-input-number v-model="preset.height" size="small" :min="0" :step="1" placeholder="高" />
                  <el-input-number v-model="preset.priceAdd" size="small" :min="0" :step="0.01" :precision="2" placeholder="加价" />
                  <el-button link type="danger" @click="removeSizePreset(currentActiveElement, presetIndex)">删</el-button>
                </div>
                <el-button plain type="primary" @click="addSizePreset(currentActiveElement)">新增尺寸</el-button>
              </template>

              <template v-if="showConstraintEditor">
                <el-divider>字段控制（当前配置区域）</el-divider>
                <el-card v-for="(rule, ruleIndex) in currentConstraints" :key="ruleIndex" class="rule-card" shadow="never">
                  <div class="rule-header">
                    <el-select v-model="rule.logic" size="small" style="width: 80px">
                      <el-option label="且 (AND)" value="AND" />
                      <el-option label="或 (OR)" value="OR" />
                    </el-select>
                    <span class="rule-tip">满足以下条件时：</span>
                    <el-button link type="danger" @click="removeConstraint(rule)">删除配置</el-button>
                  </div>

                  <div v-for="(cond, condIndex) in rule.conditions" :key="condIndex" class="condition-row">
                    <div class="cond-main">
                      <el-select v-model="cond.targetId" placeholder="条件字段" size="small" @change="cond.value = ''">
                        <el-option v-for="candidate in allElements" :key="candidate.id" :label="candidate.name" :value="candidate.id" />
                      </el-select>
                      <el-select v-model="cond.operator" size="small" style="width: 100px">
                        <el-option label="等于" value="==" />
                        <el-option label="不等于" value="!=" />
                        <el-option label="包含" value="in" />
                      </el-select>
                      <template v-if="cond.targetId">
                        <el-select
                          v-if="getFieldOptions(cond.targetId).length"
                          v-model="cond.value"
                          placeholder="请选择值"
                          size="small"
                          filterable
                        >
                          <el-option
                            v-for="opt in getFieldOptions(cond.targetId)"
                            :key="opt.value"
                            :label="opt.label"
                            :value="opt.value"
                          />
                        </el-select>
                        <el-input v-else v-model="cond.value" placeholder="条件值" size="small" />
                      </template>
                      <el-input v-else v-model="cond.value" placeholder="条件值" size="small" disabled />
                    </div>
                    <el-button link type="danger" :icon="Delete" @click="removeCondition(rule, condIndex)" v-if="rule.conditions.length > 1" />
                  </div>

                  <div class="rule-footer">
                    <el-button link type="primary" :icon="Plus" @click="addCondition(rule)">添加条件</el-button>
                    <div class="action-wrap">
                      <span class="action-label">执行：</span>
                      <el-select v-model="rule.action.effect" size="small" style="width: 100px">
                        <el-option label="隐藏" value="hide" />
                        <el-option label="禁用" value="disable" />
                      </el-select>
                    </div>
                  </div>
                </el-card>
                <el-button plain type="warning" @click="addConstraint">+ 添加控制项</el-button>
              </template>
              <template v-else>
                <el-divider>基础校验说明</el-divider>
                <div class="constraint-lite-tip">
                  当前方案不将复杂逻辑配置作为核心能力，配置重点放在字段、选项、默认值、必填和价格参数上。
                </div>
                <div class="constraint-lite-list">
                  <div>1. 数量类字段可通过最小值、最大值和步长控制输入范围。</div>
                  <div>2. 选项类字段可通过候选项、默认值和是否必填控制可选内容。</div>
                  <div>3. 特殊业务限制建议在产品模板说明或后端固定校验中处理，避免配置过度复杂。</div>
                </div>
              </template>
            </el-form>
          </div>
          <el-empty v-else :description="propertyEmptyDescription" />

          <!-- 定价配置（始终可见） -->
          <div v-if="isLeafNodeSelected" class="pricing-config">
            <div class="panel-title">定价配置</div>
            <div class="pricing-config-body">
              <!-- 字段选项定价列表 -->
              <div class="pricing-options-section">
                <div class="pricing-label" style="margin-bottom: 6px">选项定价</div>
                <el-empty v-if="!pricedElements.length" description="暂无选项可配置价格，请先在画布中添加字段和选项" :image-size="40" />
                <div v-for="el in pricedElements" :key="el.id" class="po-element">
                  <div class="po-el-header">
                    <span class="po-el-name">{{ el.name }}</span>
                    <span class="po-el-type">{{ el.type }}</span>
                  </div>
                  <!-- select/radio 选项 -->
                  <div v-if="['select','radio'].includes(el.type)" class="po-options">
                    <div v-for="(opt, oi) in el.options" :key="opt.id || oi" class="po-opt-row">
                      <el-input v-model="opt.label" size="small" style="flex:1" placeholder="选项名" />
                      <span class="po-opt-label">加价</span>
                      <el-input-number v-model="opt.priceAdd" size="small" :step="0.01" :precision="2" style="width:80px" />
                      <span class="po-opt-label">系数</span>
                      <el-input-number v-model="opt.priceRatio" size="small" :min="0" :max="10" :step="0.1" :precision="2" style="width:70px" />
                      <el-button link type="danger" size="small" @click="el.options.splice(oi, 1)">删</el-button>
                    </div>
                    <el-button link type="primary" size="small" @click="addPricingOption(el)">+ 选项</el-button>
                  </div>
                  <!-- checkbox 选项 -->
                  <div v-if="el.type === 'checkbox'" class="po-options">
                    <div v-for="(opt, oi) in el.options" :key="opt.id || oi" class="po-opt-row">
                      <el-input v-model="opt.label" size="small" style="flex:1" placeholder="选项名" />
                      <span class="po-opt-label">加价</span>
                      <el-input-number v-model="opt.priceAdd" size="small" :step="0.01" :precision="2" style="width:80px" />
                      <span class="po-opt-label">系数</span>
                      <el-input-number v-model="opt.priceRatio" size="small" :min="0" :max="10" :step="0.1" :precision="2" style="width:70px" />
                      <el-button link type="danger" size="small" @click="el.options.splice(oi, 1)">删</el-button>
                    </div>
                    <el-button link type="primary" size="small" @click="addPricingOption(el)">+ 选项</el-button>
                  </div>
                  <!-- size-mix 预设 -->
                  <div v-if="el.type === 'size-mix'" class="po-options">
                    <div v-for="(pre, pi) in el.presets" :key="pi" class="po-opt-row">
                      <el-input v-model="pre.label" size="small" style="flex:1" placeholder="如90x54mm" />
                      <span class="po-opt-label">加价</span>
                      <el-input-number v-model="pre.priceAdd" size="small" :step="0.01" :precision="2" style="width:80px" />
                      <el-button link type="danger" size="small" @click="el.presets.splice(pi, 1)">删</el-button>
                    </div>
                    <el-button link type="primary" size="small" @click="addPricingPreset(el)">+ 预设</el-button>
                  </div>
                </div>
              </div>

              <el-divider style="margin: 8px 0" />

              <!-- 底价 -->
              <div class="pricing-row">
                <span class="pricing-label">基础底价 (¥)</span>
                <el-input-number v-model="pricingBasePrice" :min="0" :step="0.01" :precision="2" controls-position="right" style="width:140px" />
              </div>

              <!-- 数量/款数 -->
              <div class="pricing-row">
                <span class="pricing-label">数量字段</span>
                <el-select v-model="schemaData.pricing.quantityElId" placeholder="选择" clearable style="width:140px" @change="onQuantityFieldChange">
                  <el-option v-for="el in numberElements" :key="el.id" :label="el.name || el.id" :value="el.id" />
                </el-select>
              </div>
              <div class="pricing-row">
                <span class="pricing-label">款数字段</span>
                <el-select v-model="schemaData.pricing.modelsElId" placeholder="选择" clearable style="width:140px" @change="onModelsFieldChange">
                  <el-option v-for="el in numberElements" :key="el.id" :label="el.name || el.id" :value="el.id" />
                </el-select>
              </div>

              <el-divider style="margin: 8px 0" />

              <!-- 计价公式 -->
              <div class="formula-section">
                <div class="formula-header">
                  <span class="pricing-label">计价公式</span>
                  <el-button link type="primary" size="small" @click="showVariableHelper = !showVariableHelper">
                    {{ showVariableHelper ? '收起变量' : '变量帮助' }}
                  </el-button>
                </div>

                <div v-if="showVariableHelper" class="variable-helper">
                  <div class="var-group-title">内置变量</div>
                  <el-tag
                    v-for="v in builtinVars" :key="v"
                    size="small" class="var-tag"
                    @click="insertToFormula(v)"
                  >{{ v }}</el-tag>
                  <div class="var-group-title">字段变量（可加 .priceAdd / .priceRatio）</div>
                  <el-tag
                    v-for="v in elementVars" :key="v.id"
                    size="small" class="var-tag"
                    @click="insertToFormula(v.id)"
                  >{{ v.label }}</el-tag>
                  <div class="var-group-title">属性后缀</div>
                  <el-tag
                    v-for="suffix in varSuffixes" :key="suffix"
                    size="small" class="var-tag var-suffix"
                    @click="appendToFormula(suffix)"
                  >{{ suffix }}</el-tag>
                </div>

                <el-input
                  v-model="schemaData.pricing.formula"
                  type="textarea"
                  :rows="3"
                  placeholder="如: (basePrice + optionTotal) * quantity * models"
                  style="margin-top: 8px"
                />
                <div class="formula-summary">
                  当前公式: <code>{{ formulaDisplay }}</code>
                </div>
              </div>

              <el-divider style="margin: 10px 0" />

              <!-- 定价步骤（回退逻辑） -->
              <div class="operations-section">
                <div class="formula-header">
                  <span class="pricing-label">定价步骤（公式为空时使用）</span>
                  <el-button link type="primary" size="small" @click="addPricingStep">+ 步骤</el-button>
                </div>
                <el-empty v-if="!pricingOps.length" description="无定价步骤" :image-size="40" />
                <div
                  v-for="(op, idx) in pricingOps"
                  :key="op.id"
                  class="operation-card"
                >
                  <div class="op-row">
                    <el-switch v-model="op.enabled" size="small" />
                    <el-input v-model="op.label" size="small" style="width: 110px" />
                    <el-select v-model="op.type" size="small" style="width: 130px">
                      <el-option label="基础底价" value="base" />
                      <el-option label="选配加价汇总" value="option_add_sum" />
                      <el-option label="乘算字段" value="multiply_number" />
                    </el-select>
                    <el-select
                      v-if="op.type === 'multiply_number'"
                      v-model="op.fieldId"
                      placeholder="绑定字段"
                      size="small"
                      clearable
                      style="width: 140px"
                    >
                      <el-option
                        v-for="el in numberElements"
                        :key="el.id"
                        :label="el.name || el.id"
                        :value="el.id"
                      />
                    </el-select>
                    <el-button link :disabled="idx === 0" @click="movePricingOp(idx, -1)">上移</el-button>
                    <el-button link :disabled="idx === pricingOps.length - 1" @click="movePricingOp(idx, 1)">下移</el-button>
                    <el-button link type="danger" @click="removePricingOp(idx)">删除</el-button>
                  </div>
                </div>
              </div>

              <el-divider style="margin: 10px 0" />

              <!-- 模拟验证 -->
              <div class="sim-section">
                <div class="formula-header">
                  <span class="pricing-label">模拟验证</span>
                  <el-button link type="primary" size="small" @click="simulatePricing">执行模拟</el-button>
                </div>
                <div v-if="simulationResult !== null" class="sim-result">
                  <div class="sim-price">预计: <strong>¥{{ simulationResult }}</strong></div>
                </div>
              </div>
            </div>
          </div>
        </el-aside>
      </el-container>
    </el-container>
    </div>

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
import { Plus, Delete } from '@element-plus/icons-vue'
import { getAdminCategoryTree, addCategory, updateCategory, deleteCategory } from '@/api/category'
import { getCategorySchema, saveCategorySchema, adminPreviewCalculatePrice } from '@/api/schema'
import { getMaterialList } from '@/api/material'
import { SECTION_KEYS, createEmptyBucket, createEmptySection, getAllSchemaElements, getSectionElements, normalizeSchema, syncPricingOperations } from '@/utils/schema'
import AdminNavbar from '@/components/AdminNavbar.vue'

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

const showVariableHelper = ref(false)
const simulationResult = ref(null)
const simulationDetails = ref(null)
const showConstraintEditor = false

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
const numberElements = computed(() => allElements.value.filter(el => el.type === 'number'))
const currentActiveElement = computed(() => allElements.value.find(element => element.id === currentActiveElementId.value))

const pricingOps = computed({
  get() { return schemaData.value.pricing?.operations || [] },
  set(val) { if (schemaData.value.pricing) schemaData.value.pricing.operations = val }
})

const pricedElements = computed(() => {
  return allElements.value.filter(el =>
    ['select', 'radio', 'checkbox', 'size-mix'].includes(el.type)
  )
})

// Single basePrice stored on common for simplicity
const pricingBasePrice = computed({
  get() { return schemaData.value.common?.basePrice ?? 0 },
  set(v) {
    if (!schemaData.value.common) schemaData.value.common = createEmptyBucket('', 0, 'common')
    schemaData.value.common.basePrice = v
  }
})

const builtinVars = ['basePrice', 'optionTotal', 'optionRatio', 'quantity', 'models']

const elementVars = computed(() => allElements.value.map(el => {
  const key = el.pricingMeta?.key || el.id
  return { id: key, label: `${el.name || el.id} (${key})` }
}))

const varSuffixes = ['.priceAdd', '.priceRatio', '.width', '.height', '.area']

const formulaDisplay = computed(() => {
  return schemaData.value.pricing?.formula || '(无公式，将使用定价步骤)'
})

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

const onQuantityFieldChange = (val) => {
  syncPricingOperations(schemaData.value.pricing)
}

const onModelsFieldChange = (val) => {
  syncPricingOperations(schemaData.value.pricing)
}

const insertToFormula = (varName) => {
  if (!schemaData.value.pricing) schemaData.value.pricing = {}
  const cur = schemaData.value.pricing.formula || ''
  schemaData.value.pricing.formula = cur + (cur && !cur.endsWith(' ') ? ' ' : '') + varName
}

const appendToFormula = (suffix) => {
  if (!schemaData.value.pricing) schemaData.value.pricing = {}
  schemaData.value.pricing.formula = (schemaData.value.pricing.formula || '').trimEnd() + suffix
}

const addPricingStep = () => {
  if (!schemaData.value.pricing) schemaData.value.pricing = {}
  if (!schemaData.value.pricing.operations) schemaData.value.pricing.operations = []
  schemaData.value.pricing.operations.push({
    id: 'op_' + Date.now(),
    type: 'option_add_sum',
    label: '新步骤',
    enabled: true,
    fieldId: null,
    description: ''
  })
}

const removePricingOp = (idx) => {
  pricingOps.value.splice(idx, 1)
}

const movePricingOp = (idx, delta) => {
  const list = pricingOps.value
  const to = idx + delta
  if (to < 0 || to >= list.length) return
  const tmp = list[idx]
  list[idx] = list[to]
  list[to] = tmp
}

const addPricingOption = (el) => {
  if (!el.options) el.options = []
  el.options.push({ id: `${el.id}_opt_${Date.now()}`, label: '新选项', priceAdd: 0, priceRatio: 1 })
}

const addPricingPreset = (el) => {
  if (!el.presets) el.presets = []
  el.presets.push({ label: '', width: 0, height: 0, priceAdd: 0 })
}

const collectPricingValidationIssues = () => {
  const issues = []
  allElements.value.forEach((element) => {
    ;(element.options || []).forEach((option) => {
      const ratio = Number(option.priceRatio)
      if (!Number.isNaN(ratio) && ratio > 10) {
        issues.push(`${element.name || element.id} / ${option.label || option.id} 的系数为 ${ratio}，已明显超出常用倍率范围。`)
      }
    })
  })
  return issues
}

const simulatePricing = async () => {
  if (!activeCategory.value?.id) return
  const testFormData = {}
  simulationDetails.value = null
  allElements.value.forEach(el => {
    if (el.type === 'checkbox') {
      testFormData[el.id] = el.options?.[0]?.id ? [el.options[0].id] : []
    } else if (el.type === 'number') {
      testFormData[el.id] = el.defaultValue || 1
    } else if (el.type === 'size-mix') {
      const preset = el.presets?.[0]
      testFormData[el.id] = preset?.label || ''
      testFormData[el.id + '_w'] = preset?.width || 90
      testFormData[el.id + '_h'] = preset?.height || 54
    } else if (['select', 'radio'].includes(el.type)) {
      testFormData[el.id] = el.options?.[0]?.id || ''
    }
  })
  try {
    const result = await adminPreviewCalculatePrice(activeCategory.value.id, { formData: testFormData })
    const normalized = normalizePricingResponse(result)
    simulationResult.value = normalized.totalPriceText
    simulationDetails.value = normalized
    if (normalized.warnings.length) {
      ElMessage.warning(normalized.warnings[0])
    }
  } catch {
    simulationResult.value = '模拟失败'
  }
}

const normalizePricingResponse = (response) => {
  if (response && typeof response === 'object') {
    return {
      totalPriceText: response.totalPriceText || Number(response.totalPrice || 0).toFixed(2),
      breakdown: Array.isArray(response.breakdown) ? response.breakdown : [],
      warnings: Array.isArray(response.warnings) ? response.warnings : [],
      mode: response.mode || 'formula',
      formula: response.formula || ''
    }
  }

  return {
    totalPriceText: Number(response || 0).toFixed(2),
    breakdown: [],
    warnings: [],
    mode: 'formula',
    formula: ''
  }
}

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
    pricing: { quantityElId: null, modelsElId: null }
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
    const priceAdd = Number(preset.priceAdd) || 0
    return { label, width, height, priceAdd }
  }
  const parsed = parseSizeFromLabel(preset)
  if (!parsed) return null
  return {
    label: String(preset || '').trim() || `${parsed.width}x${parsed.height}mm`,
    width: parsed.width,
    height: parsed.height,
    priceAdd: 0
  }
}

const normalizeElementForEditor = (element) => {
  if (!element) return
  if (element.type === 'size-mix') {
    const normalized = (Array.isArray(element.presets) ? element.presets : [])
      .map(normalizeSizePreset)
      .filter(Boolean)
    element.presets = normalized.length ? normalized : [{ label: '90x54mm', width: 90, height: 54, priceAdd: 0 }]
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
  if (componentDef.type === 'size-mix') Object.assign(element, { presets: [{ label: '90x54mm', width: 90, height: 54, priceAdd: 0 }] })

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
  element.presets.push({ label: '', width: 0, height: 0, priceAdd: 0 })
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

const getFieldOptions = (targetId) => {
  const el = allElements.value.find(e => e.id === targetId)
  if (!el) return []
  if (el.type === 'size-mix') {
    return (el.presets || []).map(p => ({ label: p.label, value: p.label }))
  }
  if (['select', 'radio', 'checkbox'].includes(el.type)) {
    return (el.options || []).map(o => ({ label: o.label, value: o.id }))
  }
  return []
}

const addConstraint = () => {
  if (!canEditCurrentScope.value && !guardSectionWrite()) return
  if (!currentBucket.value || !currentActiveElementId.value) return ElMessage.warning('请先选中字段')
  if (!currentBucket.value.constraints) currentBucket.value.constraints = []
  currentBucket.value.constraints.push({
    scope: isSectionMode.value ? 'section' : 'global',
    sectionId: isSectionMode.value ? effectiveSectionId.value : 'common',
    logic: 'AND',
    conditions: [{ targetId: '', operator: '==', value: '' }],
    action: { targetId: currentActiveElementId.value, effect: 'hide' }
  })
}

const addCondition = (rule) => {
  if (!rule.conditions) rule.conditions = []
  rule.conditions.push({ targetId: '', operator: '==', value: '' })
}

const removeCondition = (rule, index) => {
  rule.conditions.splice(index, 1)
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
          height: preset.height,
          priceAdd: Number(preset.priceAdd) || 0
        }))
      if (!cleaned.presets.length) {
        cleaned.presets = [{ label: '90x54mm', width: 90, height: 54, priceAdd: 0 }]
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
  const pricingIssues = collectPricingValidationIssues()
  if (pricingIssues.length) {
    ElMessage.warning(pricingIssues[0])
    return
  }
  if (!schemaData.value.categoryId) return ElMessage.error('请先选择末级分类')

  schemaData.value.productName = activeCategory.value?.name || schemaData.value.productName || '未命名产品'

  const validIds = new Set(allElements.value.map(element => element.id))
  const common = cleanBucket(schemaData.value.common || createEmptyBucket('', 0, 'common'))
  common.id = 'common'
  common.sortOrder = 0
  common.constraints = (common.constraints || []).filter((constraint) => {
    // 兼容旧数据并清洗
    if (constraint.condition && !constraint.conditions) {
      constraint.conditions = [constraint.condition]
      delete constraint.condition
    }
    if (!constraint.logic) constraint.logic = 'AND'
    
    return constraint.conditions?.length && 
           constraint.conditions.every(c => c.targetId && validIds.has(c.targetId)) &&
           constraint?.action?.targetId &&
           validIds.has(constraint.action.targetId)
  })

  const sections = orderedSections.value.map((section, index) => {
    const cleaned = cleanBucket(section)
    cleaned.sortOrder = index + 1
    cleaned.constraints = (cleaned.constraints || []).filter((constraint) => {
      if (constraint.condition && !constraint.conditions) {
        constraint.conditions = [constraint.condition]
        delete constraint.condition
      }
      if (!constraint.logic) constraint.logic = 'AND'

      return constraint.conditions?.length && 
             constraint.conditions.every(c => c.targetId && validIds.has(c.targetId)) &&
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
    pricing: schemaData.value.pricing || { quantityElId: null, modelsElId: null }
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
.admin-page { height: 100vh; display: flex; flex-direction: column; overflow: hidden; background: #f0f2f5; }
.page-body { flex: 1; min-height: 0; overflow: hidden; }
.layout { height: 100%; overflow: hidden; }
.body { height: 100%; min-height: 0; padding: 12px; gap: 12px; box-sizing: border-box; overflow: hidden; }
.panel { height: 100%; min-height: 0; background: #fff; border-radius: 8px; overflow: auto; }
.panel-title { display: flex; justify-content: space-between; align-items: center; padding: 10px 12px; border-bottom: 1px solid #f0f0f0; font-weight: 600; }
.row { align-items: center; }
.panel-actions { display: flex; align-items: center; gap: 8px; }
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

/* 定价配置面板 */
.pricing-config {
  border-top: 2px solid #f0f0f0;
  flex-shrink: 0;
}
.pricing-config-body {
  padding: 12px;
}
.pricing-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
}
.pricing-label {
  font-size: 13px;
  color: #606266;
  font-weight: 500;
  flex-shrink: 0;
}
.scope-badge {
  font-size: 11px; font-weight: 400; color: #409eff;
  background: #ecf5ff; border-radius: 3px; padding: 1px 6px; margin-left: 6px;
}

/* 选项定价列表 */
.pricing-options-section {
  background: #f5f7fa; border: 1px solid #e4e7ed; border-radius: 6px;
  padding: 8px 10px; margin-bottom: 4px; max-height: 320px; overflow-y: auto;
}
.po-element {
  border-bottom: 1px dashed #e4e7ed; padding: 6px 0;
}
.po-element:last-child { border-bottom: none; }
.po-el-header {
  display: flex; align-items: center; gap: 8px; margin-bottom: 4px;
}
.po-el-name { font-size: 13px; font-weight: 600; color: #303133; }
.po-el-type { font-size: 10px; color: #909399; background: #f0f0f0; padding: 0 5px; border-radius: 3px; }
.po-options { padding-left: 4px; }
.po-opt-row {
  display: flex; align-items: center; gap: 4px; margin-bottom: 4px;
}
.po-opt-label { font-size: 10px; color: #909399; flex-shrink: 0; }
.constraint-lite-tip {
  padding: 10px 12px;
  background: #f8fafc;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  color: #475569;
  line-height: 1.7;
}
.constraint-lite-list {
  margin-top: 10px;
  padding: 10px 12px;
  background: #fff;
  border: 1px dashed #dbe2ea;
  border-radius: 8px;
  color: #64748b;
  line-height: 1.8;
}

/* 公式编辑器 */
.formula-section { margin-bottom: 4px; }
.formula-header {
  display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;
}
.formula-summary {
  margin-top: 6px; font-size: 12px; color: #909399;
}
.formula-summary code {
  color: #409eff; background: #ecf5ff; padding: 1px 6px; border-radius: 3px;
}

/* 变量帮助面板 */
.variable-helper {
  background: #f0f7ff; border: 1px solid #c6e2ff; border-radius: 6px;
  padding: 8px 10px; margin-bottom: 8px; max-height: 180px; overflow-y: auto;
}
.var-group-title {
  font-size: 11px; color: #409eff; font-weight: 600; margin: 6px 0 4px;
}
.var-group-title:first-child { margin-top: 0; }
.var-tag { margin: 2px 4px 2px 0; cursor: pointer; }
.var-tag:hover { opacity: 0.8; }
.var-suffix { background: #fdf6ec; border-color: #e6a23c; color: #e6a23c; }

/* 定价步骤 */
.operations-section { margin-bottom: 4px; }
.operation-card {
  border: 1px solid #ebeef5; border-radius: 6px; padding: 8px 10px;
  margin-bottom: 6px; background: #fafafa;
}
.op-row { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }

/* 模拟验证 */
.sim-section { margin-top: 4px; }
.sim-result {
  background: #f0f9eb; border: 1px solid #c2e7b0; border-radius: 6px;
  padding: 10px 12px; margin-top: 8px;
}
.sim-price { font-size: 16px; color: #67c23a; }
.sim-price strong { font-size: 20px; }
.rule-card { 
  margin-bottom: 16px; 
  border: 1px solid #e4e7ed; 
  border-radius: 8px;
  background-color: #fafafa;
  transition: all 0.3s;
}
.rule-card:hover {
  border-color: #409eff;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}
.rule-header { 
  display: flex; 
  align-items: center; 
  justify-content: space-between; 
  margin-bottom: 12px; 
  padding-bottom: 10px; 
  border-bottom: 1px solid #eee; 
}
.rule-tip { 
  font-size: 13px; 
  font-weight: 500;
  color: #606266; 
  flex: 1; 
  margin-left: 10px; 
}
.condition-row { 
  display: flex; 
  align-items: flex-start; 
  gap: 10px; 
  margin-bottom: 12px; 
  padding: 8px;
  background: #fff;
  border-radius: 6px;
  border: 1px solid #f0f0f0;
}
.cond-main { 
  flex: 1; 
  display: flex; 
  flex-direction: column; 
  gap: 6px; 
}
.rule-footer { 
  margin-top: 12px; 
  display: flex; 
  align-items: center; 
  justify-content: space-between; 
  border-top: 1px solid #eee; 
  padding-top: 10px; 
}
.action-wrap { 
  display: flex; 
  align-items: center; 
  background: #ecf5ff;
  padding: 4px 10px;
  border-radius: 4px;
  border: 1px solid #d9ecff;
  font-size: 13px; 
}
.action-label { 
  color: #409eff; 
  font-weight: bold;
}
</style>
