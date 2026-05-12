<template>
  <div class="dynamic-quote-form">
    <el-skeleton :rows="10" animated v-if="loading" />

    <div v-else class="form-content">
      <el-row :gutter="24" justify="center">
        <el-col :span="18">
          <div class="config-panel">
            <div class="panel-header">
              <h2 class="product-title">
                {{ schemaData.productName }}
                <span class="sub-title">定制选项</span>
              </h2>
            </div>

            <el-form :model="formData" label-width="140px" class="quote-form">
              <div class="section-block" v-if="commonElements.length">
                <template v-for="element in commonElements" :key="element.id">
                  <el-form-item v-if="!isHidden(element.id)" :required="element.isRequired" class="element-item">
                    <template #label>
                      <span class="label-text">{{ element.name }}</span>
                      <el-tooltip v-if="element.tip" :content="element.tip" placement="top">
                        <el-icon class="tip-icon"><QuestionFilled /></el-icon>
                      </el-tooltip>
                    </template>

                    <template v-if="element.type === 'number'">
                      <div class="number-input-wrap">
                        <el-select
                          v-if="element.presets && element.presets.length > 0"
                          v-model="formData[element.id]"
                          filterable
                          allow-create
                          default-first-option
                          placeholder="选择或输入"
                          @change="handleFormChange"
                          style="width: 180px"
                        >
                          <el-option
                            v-for="preset in element.presets"
                            :key="typeof preset === 'object' ? preset.label : preset"
                            :label="typeof preset === 'object' ? preset.label : String(preset)"
                            :value="typeof preset === 'object' ? preset.label : preset"
                          />
                        </el-select>
                        <el-input-number
                          v-else
                          v-model="formData[element.id]"
                          :min="element.min"
                          :max="element.max"
                          :step="element.step"
                          @change="handleFormChange"
                        />
                        <span class="unit" v-if="element.unit">{{ element.unit }}</span>
                      </div>
                    </template>

                    <template v-else-if="element.type === 'size-mix'">
                      <div class="size-mix-container">
                        <el-select
                          v-if="!sizeMixCustom[element.id]"
                          v-model="sizeMixPresetKey[element.id]"
                          placeholder="选择标准尺寸"
                          @change="(value) => onSizePresetSelect(element, value)"
                          style="width: 180px"
                        >
                          <el-option v-for="preset in element.presets" :key="preset.label" :label="preset.label" :value="preset.label" />
                        </el-select>
                        <div v-else class="custom-size-row">
                          <span>宽</span>
                          <el-input-number
                            v-model="formData[`${element.id}_w`]"
                            :min="0"
                            :controls="false"
                            style="width: 70px"
                            @change="handleFormChange"
                          />
                          <span>mm</span>
                          <span>高</span>
                          <el-input-number
                            v-model="formData[`${element.id}_h`]"
                            :min="0"
                            :controls="false"
                            style="width: 70px"
                            @change="handleFormChange"
                          />
                          <span>mm</span>
                        </div>
                        <el-checkbox v-model="sizeMixCustom[element.id]" @change="(value) => onSizeCustomToggle(element, value)">
                          自定义
                        </el-checkbox>
                      </div>
                    </template>

                    <el-select
                      v-else-if="element.type === 'select'"
                      v-model="formData[element.id]"
                      placeholder="请选择"
                      style="width: 280px"
                      :disabled="isDisabled(element.id)"
                      @change="handleFormChange"
                    >
                      <el-option v-for="option in element.options" :key="option.id" :label="option.label" :value="option.id" />
                    </el-select>

                    <el-radio-group
                      v-else-if="element.type === 'radio'"
                      v-model="formData[element.id]"
                      :disabled="isDisabled(element.id)"
                      @change="handleFormChange"
                    >
                      <el-radio-button v-for="option in element.options" :key="option.id" :label="option.id">
                        {{ option.label }}
                      </el-radio-button>
                    </el-radio-group>

                    <template v-else-if="element.type === 'checkbox'">
                      <div class="craft-options-row">
                        <div v-for="option in element.options" :key="option.id" class="craft-option-wrap">
                          <el-checkbox-group
                            v-model="formData[element.id]"
                            :disabled="isDisabled(element.id)"
                            @change="(value) => onCraftChange(element, value)"
                          >
                            <el-checkbox-button :label="option.id">{{ option.label }}</el-checkbox-button>
                          </el-checkbox-group>
                          <el-button
                            v-if="option.subElements && (formData[element.id] || []).includes(option.id)"
                            type="primary"
                            circle
                            size="small"
                            class="craft-config-btn"
                            @click.stop="openCraftDialog(option)"
                          >
                            <el-icon><Setting /></el-icon>
                          </el-button>
                          <el-tag
                            v-if="(formData[element.id] || []).includes(option.id) && option.subElements && isCraftConfigured(option)"
                            type="success"
                            size="small"
                          >
                            已配置
                          </el-tag>
                        </div>
                      </div>
                    </template>
                  </el-form-item>
                </template>
              </div>

              <div class="section-block" v-for="section in orderedSections" :key="section.id">
                <div class="section-title" v-if="section.name && section.name.trim()">// {{ section.name }}</div>
                <template v-for="element in getSortedSectionElements(section)" :key="element.id">
                  <el-form-item v-if="!isHidden(element.id)" :required="element.isRequired" class="element-item">
                    <template #label>
                      <span class="label-text">{{ element.name }}</span>
                      <el-tooltip v-if="element.tip" :content="element.tip" placement="top">
                        <el-icon class="tip-icon"><QuestionFilled /></el-icon>
                      </el-tooltip>
                    </template>

                    <template v-if="element.type === 'number'">
                      <div class="number-input-wrap">
                        <el-select
                          v-if="element.presets && element.presets.length > 0"
                          v-model="formData[element.id]"
                          filterable
                          allow-create
                          default-first-option
                          placeholder="选择或输入"
                          @change="handleFormChange"
                          style="width: 180px"
                        >
                          <el-option
                            v-for="preset in element.presets"
                            :key="typeof preset === 'object' ? preset.label : preset"
                            :label="typeof preset === 'object' ? preset.label : String(preset)"
                            :value="typeof preset === 'object' ? preset.label : preset"
                          />
                        </el-select>
                        <el-input-number
                          v-else
                          v-model="formData[element.id]"
                          :min="element.min"
                          :max="element.max"
                          :step="element.step"
                          @change="handleFormChange"
                        />
                        <span class="unit" v-if="element.unit">{{ element.unit }}</span>
                      </div>
                    </template>

                    <template v-else-if="element.type === 'size-mix'">
                      <div class="size-mix-container">
                        <el-select
                          v-if="!sizeMixCustom[element.id]"
                          v-model="sizeMixPresetKey[element.id]"
                          placeholder="选择标准尺寸"
                          @change="(value) => onSizePresetSelect(element, value)"
                          style="width: 180px"
                        >
                          <el-option v-for="preset in element.presets" :key="preset.label" :label="preset.label" :value="preset.label" />
                        </el-select>
                        <div v-else class="custom-size-row">
                          <span>宽</span>
                          <el-input-number
                            v-model="formData[`${element.id}_w`]"
                            :min="0"
                            :controls="false"
                            style="width: 70px"
                            @change="handleFormChange"
                          />
                          <span>mm</span>
                          <span>高</span>
                          <el-input-number
                            v-model="formData[`${element.id}_h`]"
                            :min="0"
                            :controls="false"
                            style="width: 70px"
                            @change="handleFormChange"
                          />
                          <span>mm</span>
                        </div>
                        <el-checkbox v-model="sizeMixCustom[element.id]" @change="(value) => onSizeCustomToggle(element, value)">
                          自定义
                        </el-checkbox>
                      </div>
                    </template>

                    <el-select
                      v-else-if="element.type === 'select'"
                      v-model="formData[element.id]"
                      placeholder="请选择"
                      style="width: 280px"
                      :disabled="isDisabled(element.id)"
                      @change="handleFormChange"
                    >
                      <el-option v-for="option in element.options" :key="option.id" :label="option.label" :value="option.id" />
                    </el-select>

                    <el-radio-group
                      v-else-if="element.type === 'radio'"
                      v-model="formData[element.id]"
                      :disabled="isDisabled(element.id)"
                      @change="handleFormChange"
                    >
                      <el-radio-button v-for="option in element.options" :key="option.id" :label="option.id">
                        {{ option.label }}
                      </el-radio-button>
                    </el-radio-group>

                    <template v-else-if="element.type === 'checkbox'">
                      <div class="craft-options-row">
                        <div v-for="option in element.options" :key="option.id" class="craft-option-wrap">
                          <el-checkbox-group
                            v-model="formData[element.id]"
                            :disabled="isDisabled(element.id)"
                            @change="(value) => onCraftChange(element, value)"
                          >
                            <el-checkbox-button :label="option.id">{{ option.label }}</el-checkbox-button>
                          </el-checkbox-group>
                          <el-button
                            v-if="option.subElements && (formData[element.id] || []).includes(option.id)"
                            type="primary"
                            circle
                            size="small"
                            class="craft-config-btn"
                            @click.stop="openCraftDialog(option)"
                          >
                            <el-icon><Setting /></el-icon>
                          </el-button>
                          <el-tag
                            v-if="(formData[element.id] || []).includes(option.id) && option.subElements && isCraftConfigured(option)"
                            type="success"
                            size="small"
                          >
                            已配置
                          </el-tag>
                        </div>
                      </div>
                    </template>
                  </el-form-item>
                </template>
              </div>
            </el-form>
          </div>
        </el-col>

        <el-col :span="6">
          <div class="pricing-affix">
            <el-card shadow="always" class="pricing-card" :body-style="{ padding: '0px' }">
              <div class="pricing-header">
                <h3>订单报价结算</h3>
              </div>
              <div class="pricing-body">
                <div class="summary-item">
                  <span class="label">产品名称</span>
                  <span class="value">{{ schemaData.productName }}</span>
                </div>
                <div v-if="pricingSummary.length" class="price-breakdown">
                  <div v-for="item in pricingSummary" :key="item.key" class="summary-item">
                    <span class="label">{{ item.label }}</span>
                    <span class="value">{{ formatBreakdownValue(item) }}</span>
                  </div>
                </div>
                <div v-if="pricingWarnings.length" class="price-warnings">
                  <div v-for="warning in pricingWarnings" :key="warning" class="warning-line">{{ warning }}</div>
                </div>
                <el-divider border-style="dashed" />
                <div class="total-price-wrap">
                  <div class="total-label">预计总价（不含运费）</div>
                  <div class="price-val">
                    ¥ <span :class="{ 'price-flash': priceChanged }" :key="currentTotalPrice">{{ currentTotalPrice }}</span>
                  </div>
                </div>
                <div class="action-wrap">
                  <el-button type="danger" size="large" class="submit-btn" @click="submitQuote">立即结算报价</el-button>
                  <el-button size="large" class="cart-btn" @click="addToCart">加入暂存箱</el-button>
                </div>
              </div>
            </el-card>
          </div>
        </el-col>
      </el-row>
    </div>

    <el-dialog v-model="craftDialogVisible" :title="craftDialogTitle" width="580px" class="craft-dialog">
      <el-form v-if="craftCurrentOpt" :model="craftFormData" label-width="100px" style="padding: 10px 20px">
        <el-form-item v-for="sub in craftCurrentOpt.subElements" :key="sub.id" :label="sub.name" :required="sub.required">
          <el-select v-if="sub.type === 'select'" v-model="craftFormData[sub.id]" placeholder="请选择" style="width: 220px">
            <el-option v-for="option in sub.options" :key="option.id" :label="option.label" :value="option.id" />
          </el-select>
          <el-input-number v-else-if="sub.type === 'number'" v-model="craftFormData[sub.id]" :min="sub.min || 1" style="width: 160px" />
          <el-input v-else v-model="craftFormData[sub.id]" :placeholder="sub.placeholder || '请输入'" style="width: 220px" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="craftDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmCraftDialog">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, defineProps, onMounted, ref, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { QuestionFilled, Setting } from '@element-plus/icons-vue'
import { getCategorySchema, adminPreviewCalculatePrice } from '@/api/schema'
import { addCartItem } from '@/api/cart'
import { saveQuoteHistory } from '@/api/quoteHistory'
import { collectConstraintEffects, syncConstrainedFormState } from '@/utils/constraint-engine'
import { getAllSchemaElements, getSectionElements, normalizeSchema } from '@/utils/schema'

const props = defineProps({
  categoryId: { type: [String, Number], required: true }
})

const loading = ref(true)
const schemaData = ref(normalizeSchema(null))
const formData = ref({})
const currentTotalPrice = ref('0.00')
const priceDetails = ref(null)
const priceChanged = ref(false)
const hiddenElements = ref(new Set())
const disabledElements = ref(new Set())
const sizeMixPresetKey = ref({})
const sizeMixCustom = ref({})
const lastCheckedValues = ref({})
let calcTimer = null

const craftDialogVisible = ref(false)
const craftDialogTitle = ref('')
const craftCurrentOpt = ref(null)
const craftFormData = ref({})
const craftStoredData = ref({})

const pricingSummary = computed(() => {
  const breakdown = priceDetails.value?.breakdown || []
  const keys = ['basePrice', 'optionTotal', 'optionRatio', 'quantity', 'models']
  return breakdown.filter(item => keys.includes(item.key))
})

const pricingWarnings = computed(() => priceDetails.value?.warnings || [])

const orderedSections = computed(() => {
  return [...(schemaData.value.sections || [])].sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0))
})

const commonElements = computed(() => {
  const elements = getSectionElements(schemaData.value.common)
  return [...elements].sort((a, b) => (a.weight || 0) - (b.weight || 0))
})

const getSortedSectionElements = (section) => {
  const elements = getSectionElements(section)
  return [...elements].sort((a, b) => (a.weight || 0) - (b.weight || 0))
}

const getAllElementsFlat = () => getAllSchemaElements(schemaData.value)

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
    if (width <= 0 || height <= 0) return null
    const label = (preset.label || '').trim() || `${width}x${height}mm`
    return { label, width, height, priceAdd: Number(preset.priceAdd) || 0 }
  }

  const parsed = parseSizeFromLabel(preset)
  if (!parsed || parsed.width <= 0 || parsed.height <= 0) return null

  return {
    label: String(preset || '').trim() || `${parsed.width}x${parsed.height}mm`,
    width: parsed.width,
    height: parsed.height,
    priceAdd: 0
  }
}

const normalizeSizeMixElement = (element) => {
  if (!element || element.type !== 'size-mix') return
  const presets = (Array.isArray(element.presets) ? element.presets : [])
    .map(normalizeSizePreset)
    .filter(Boolean)
  element.presets = presets.length ? presets : [{ label: '90x54mm', width: 90, height: 54, priceAdd: 0 }]
}

const applySchemaData = (rawSchema) => {
  schemaData.value = normalizeSchema(rawSchema, '')
  initFormModel()
  restoreReusableQuote()
  handleFormChange()
}

const loadSchema = async () => {
  if (!props.categoryId) {
    loading.value = false
    return
  }

  loading.value = true
  try {
    let response = await getCategorySchema(props.categoryId)
    if (typeof response === 'string') response = JSON.parse(response)
    applySchemaData(response)
  } catch (error) {
    console.error(error)
    ElMessage.warning('加载配置失败')
  } finally {
    loading.value = false
  }
}

const initFormModel = () => {
  const model = {}
  const presetState = {}
  const customState = {}

  getAllElementsFlat().forEach((element) => {
    if (element.type === 'checkbox') {
      model[element.id] = Array.isArray(element.defaultValue) ? [...element.defaultValue] : []
      element.options?.forEach((option) => {
        option.subElements?.forEach((subElement) => {
          model[subElement.id] = subElement.type === 'number' ? 1 : ''
        })
      })
      return
    }

    if (element.type === 'number') {
      model[element.id] = element.defaultValue ?? element.presets?.[0] ?? 1
      return
    }

    if (element.type === 'size-mix') {
      normalizeSizeMixElement(element)
      const firstPreset = element.presets?.[0]
      presetState[element.id] = firstPreset?.label || ''
      customState[element.id] = false
      model[`${element.id}_w`] = firstPreset?.width || 0
      model[`${element.id}_h`] = firstPreset?.height || 0
      model[element.id] = firstPreset?.label || ''
      return
    }

    model[element.id] = element.defaultValue ?? ''
  })

  formData.value = model
  sizeMixPresetKey.value = presetState
  sizeMixCustom.value = customState
  lastCheckedValues.value = JSON.parse(JSON.stringify(model))
}

const updatePrice = async () => {
  if (!props.categoryId) return

  try {
    const response = await adminPreviewCalculatePrice(props.categoryId, { formData: formData.value })
    const normalized = normalizePricingResponse(response)
    if (normalized.totalPriceText !== currentTotalPrice.value) {
      priceChanged.value = true
      currentTotalPrice.value = normalized.totalPriceText
      priceDetails.value = normalized
      setTimeout(() => {
        priceChanged.value = false
      }, 400)
    } else {
      priceDetails.value = normalized
    }
  } catch (_) {}
}

const normalizePricingResponse = (response) => {
  if (response && typeof response === 'object') {
    return {
      totalPrice: Number(response.totalPrice ?? 0),
      totalPriceText: response.totalPriceText || Number(response.totalPrice ?? 0).toFixed(2),
      breakdown: Array.isArray(response.breakdown) ? response.breakdown : [],
      warnings: Array.isArray(response.warnings) ? response.warnings : []
    }
  }

  const value = Number(response || 0)
  return {
    totalPrice: value,
    totalPriceText: value.toFixed(2),
    breakdown: [],
    warnings: []
  }
}

const formatBreakdownValue = (item) => {
  if (['optionRatio', 'quantity', 'models'].includes(item.key)) {
    return `×${Number(item.value || 0).toFixed(2)}`
  }
  return `¥${Number(item.value || 0).toFixed(2)}`
}

const checkConstraints = () => {
  const { hiddenIds, disabledIds } = collectConstraintEffects(schemaData.value, formData.value)

  syncConstrainedFormState({
    schema: schemaData.value,
    formData: formData.value,
    hiddenIds,
    disabledIds,
    sizeMixPresetKey: sizeMixPresetKey.value,
    sizeMixCustom: sizeMixCustom.value
  })

  hiddenElements.value = hiddenIds
  disabledElements.value = disabledIds
}

const handleFormChange = () => {
  checkConstraints()
  if (calcTimer) clearTimeout(calcTimer)
  calcTimer = setTimeout(() => {
    updatePrice()
  }, 200)
}

const onSizePresetSelect = (element, label) => {
  normalizeSizeMixElement(element)
  const preset = element.presets.find((item) => item.label === label)
  if (!preset) return

  formData.value[`${element.id}_w`] = preset.width
  formData.value[`${element.id}_h`] = preset.height
  formData.value[element.id] = label
  sizeMixCustom.value[element.id] = false
  handleFormChange()
}

const onSizeCustomToggle = (element, custom) => {
  if (custom) {
    sizeMixPresetKey.value[element.id] = ''
    formData.value[element.id] = 'custom'
  } else {
    onSizePresetSelect(element, element.presets?.[0]?.label)
    return
  }

  handleFormChange()
}

const onCraftChange = (element, value) => {
  const previous = lastCheckedValues.value[element.id] || []
  const added = value.filter((item) => !previous.includes(item))
  if (added.length > 0) {
    const option = element.options.find((item) => item.id === added[0])
    if (option?.subElements?.length) openCraftDialog(option)
  }
  lastCheckedValues.value[element.id] = [...value]
  handleFormChange()
}

const openCraftDialog = (option) => {
  craftCurrentOpt.value = option
  craftDialogTitle.value = `${option.label} 参数配置`
  const saved = craftStoredData.value[option.id] || {}
  const initValue = {}

  ;(option.subElements || []).forEach((subElement) => {
    initValue[subElement.id] = saved[subElement.id] || (subElement.type === 'number' ? 1 : '')
  })

  craftFormData.value = initValue
  craftDialogVisible.value = true
}

const confirmCraftDialog = () => {
  craftStoredData.value[craftCurrentOpt.value.id] = { ...craftFormData.value }
  Object.assign(formData.value, craftFormData.value)
  craftDialogVisible.value = false
  handleFormChange()
}

const isCraftConfigured = (option) => !!craftStoredData.value[option.id]
const isHidden = (id) => hiddenElements.value.has(id)
const isDisabled = (id) => disabledElements.value.has(id)

const restoreReusableQuote = () => {
  const cached = localStorage.getItem('quote_reuse_payload')
  if (!cached) return
  try {
    const payload = JSON.parse(cached)
    if (String(payload.categoryId) !== String(props.categoryId)) return
    if (payload.rawFormData && typeof payload.rawFormData === 'object') {
      formData.value = { ...formData.value, ...payload.rawFormData }
    }
    localStorage.removeItem('quote_reuse_payload')
  } catch (_) {
    localStorage.removeItem('quote_reuse_payload')
  }
}

const persistQuoteHistory = async () => {
  await saveQuoteHistory({
    categoryId: props.categoryId,
    productName: schemaData.value.productName,
    formData: buildReadableFormData(),
    rawFormData: JSON.parse(JSON.stringify(formData.value)),
    price: currentTotalPrice.value
  })
}

const submitQuote = async () => {
  try {
    await persistQuoteHistory()
    await addCartItem({
      categoryId: props.categoryId,
      productName: schemaData.value.productName,
      formData: buildReadableFormData(),
      price: currentTotalPrice.value
    })
    window.dispatchEvent(new CustomEvent('cart-updated'))
    window.dispatchEvent(new CustomEvent('checkout-now'))
    ElMessage.success('已加入购物车，请确认收货地址后提交订单')
  } catch (_) {
    ElMessage.error('立即结算失败，请稍后重试')
  }
}

const buildReadableFormData = () => {
  const grouped = {}
  const commonResult = {}

  commonElements.value.forEach((element) => {
    if (isHidden(element.id)) return

    const value = formData.value[element.id]
    let readableValue = ''

    if (element.type === 'number') {
      readableValue = `${value}${element.unit || ''}`
    } else if (element.type === 'select' || element.type === 'radio') {
      const option = element.options?.find((item) => item.id === value)
      readableValue = option ? option.label : value
    } else if (element.type === 'size-mix') {
      readableValue = sizeMixCustom.value[element.id]
        ? `自定义 ${formData.value[`${element.id}_w`]} x ${formData.value[`${element.id}_h`]} mm`
        : value
    } else if (element.type === 'checkbox') {
      const labels = (value || []).map((id) => {
        const option = element.options?.find((item) => item.id === id)
        return option ? option.label : id
      })
      readableValue = labels.join('、')
    }

    if (readableValue) commonResult[element.name] = readableValue
  })

  Object.assign(grouped, commonResult)

  orderedSections.value.forEach((section) => {
    const sectionResult = {}

    getSortedSectionElements(section).forEach((element) => {
      if (isHidden(element.id)) return

      const value = formData.value[element.id]
      let readableValue = ''

      if (element.type === 'number') {
        readableValue = `${value}${element.unit || ''}`
      } else if (element.type === 'select' || element.type === 'radio') {
        const option = element.options?.find((item) => item.id === value)
        readableValue = option ? option.label : value
      } else if (element.type === 'size-mix') {
        readableValue = sizeMixCustom.value[element.id]
          ? `自定义 ${formData.value[`${element.id}_w`]} x ${formData.value[`${element.id}_h`]} mm`
          : value
      } else if (element.type === 'checkbox') {
        const labels = (value || []).map((id) => {
          const option = element.options?.find((item) => item.id === id)
          let label = option ? option.label : id
          const stored = craftStoredData.value[id]
          if (stored && option?.subElements) {
            const subLabels = option.subElements.map((subElement) => {
              const subValue = stored[subElement.id]
              if (subElement.type === 'select') {
                const subOption = subElement.options?.find((item) => item.id === subValue)
                return `${subElement.name}: ${subOption ? subOption.label : subValue}`
              }
              return `${subElement.name}: ${subValue}`
            })
            label += ` (${subLabels.join(', ')})`
          }
          return label
        })
        readableValue = labels.join('、')
      }

      if (readableValue) sectionResult[element.name] = readableValue
    })

    if (!Object.keys(sectionResult).length) return

    if (section.name && section.name.trim()) {
      grouped[section.name] = sectionResult
    } else {
      Object.assign(grouped, sectionResult)
    }
  })

  return grouped
}

const addToCart = async () => {
  if (!schemaData.value) return

  try {
    await persistQuoteHistory()
    await addCartItem({
      categoryId: props.categoryId,
      productName: schemaData.value.productName,
      formData: buildReadableFormData(),
      price: currentTotalPrice.value
    })
    ElMessage.success('已加入购物车，10 分钟内有效')
    window.dispatchEvent(new CustomEvent('cart-updated'))
  } catch (_) {
    ElMessage.error('加入购物车失败，请重试')
  }
}

onMounted(() => loadSchema())

watch(
  () => props.categoryId,
  () => {
    loadSchema()
  }
)
</script>

<style scoped>
.dynamic-quote-form { margin-top: 10px; }
.config-panel { background: transparent; padding: 20px 24px; }
.panel-header { margin-bottom: 20px; padding-bottom: 15px; }
.product-title { font-size: 22px; font-weight: 800; color: var(--gray-700); letter-spacing: -.3px; }
.sub-title { font-size: 13px; color: var(--gray-400); font-weight: 400; }
.section-block {
  background: #fff;
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-xs);
  padding: 22px 24px;
  margin-bottom: 16px;
  border: 1px solid var(--gray-200);
  transition: box-shadow .25s;
}
.section-block:hover { box-shadow: var(--shadow-sm); }
.section-title { font-size: 15px; font-weight: 700; color: var(--gray-700); margin: 0 0 16px; padding-bottom: 10px; border-bottom: 2px solid var(--gray-100); }
.element-item { margin-bottom: 20px !important; }
.tip-icon { margin-left: 5px; color: var(--gray-300); cursor: pointer; transition: color .2s; }
.tip-icon:hover { color: var(--color-primary); }
.number-input-wrap, .size-mix-container { display: flex; align-items: center; gap: 10px; }
.custom-size-row {
  display: flex; align-items: center; gap: 6px;
  background: var(--gray-50); padding: 6px 12px;
  border-radius: var(--radius-sm); border: 1px solid var(--gray-200);
}
.craft-options-row { display: flex; flex-wrap: wrap; gap: 10px; }
.craft-option-wrap { display: flex; align-items: center; gap: 5px; }
.craft-config-btn { width: 26px !important; height: 26px !important; padding: 0 !important; }
.pricing-affix { position: sticky; top: 20px; }
.pricing-card {
  border: none;
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: var(--shadow-lg);
  transition: box-shadow .3s;
}
.pricing-card:hover { box-shadow: var(--shadow-xl); }
.pricing-header {
  background: linear-gradient(135deg, #1a1a2e, #f72a44);
  color: #fff;
  padding: 18px 20px;
}
.pricing-header h3 { font-size: 16px; font-weight: 700; margin: 0; letter-spacing: .3px; }
.pricing-body { padding: 22px 20px; background: #fff; }
.summary-item { display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 10px; color: var(--gray-500); }
.summary-item .value { font-weight: 600; color: var(--gray-600); }
.price-breakdown {
  padding: 12px 14px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 14px;
}
.price-breakdown .summary-item:last-child { margin-bottom: 0; }
.price-warnings {
  margin-top: 12px;
  padding: 10px 12px;
  border-radius: 12px;
  background: #fff7ed;
  border: 1px solid #fed7aa;
}
.warning-line {
  font-size: 12px;
  line-height: 1.6;
  color: #9a3412;
}
.total-price-wrap { text-align: right; margin-top: 16px; padding-top: 14px; border-top: 2px dashed var(--gray-200); }
.total-label { font-size: 12px; color: var(--gray-400); text-transform: uppercase; letter-spacing: .6px; }
.price-val { color: var(--color-primary); font-size: 22px; font-weight: 800; margin-top: 4px; }
.price-val span { font-size: 36px; letter-spacing: -1px; }
.action-wrap { margin-top: 22px; display: flex; flex-direction: column; gap: 10px; }
.submit-btn {
  height: 48px !important; font-size: 15px !important; font-weight: 700 !important;
  background: var(--color-primary) !important; border-color: var(--color-primary) !important;
  border-radius: var(--radius-md) !important;
  box-shadow: 0 4px 14px rgba(247,42,68,.3);
  transition: all .25s !important;
}
.submit-btn:hover { box-shadow: 0 6px 20px rgba(247,42,68,.4); transform: translateY(-1px); }
.cart-btn { height: 42px !important; border-radius: var(--radius-md) !important; font-weight: 600 !important; }
</style>
