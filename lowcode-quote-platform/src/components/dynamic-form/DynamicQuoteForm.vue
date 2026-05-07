<template>
  <div class="dynamic-quote-form">
    <el-skeleton :rows="10" animated v-if="loading" />

    <div v-else class="form-content">
      <el-row :gutter="24" justify="center">
        <el-col :span="18">
          <div class="config-panel">
            <div class="panel-header">
              <h2 class="product-title">{{ schemaData.productName }} <span class="sub-title">定制选项</span></h2>
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
                          <el-option v-for="preset in element.presets" :key="preset" :label="String(preset)" :value="preset" />
                        </el-select>
                        <el-input-number v-else v-model="formData[element.id]" :min="element.min" :max="element.max" :step="element.step" @change="handleFormChange" />
                        <span class="unit" v-if="element.unit">{{ element.unit }}</span>
                      </div>
                    </template>

                    <template v-else-if="element.type === 'size-mix'">
                      <div class="size-mix-container">
                        <el-select
                          v-if="!sizeMixCustom[element.id]"
                          v-model="sizeMixPresetKey[element.id]"
                          placeholder="选择标准尺寸"
                          @change="(val) => onSizePresetSelect(element, val)"
                          style="width: 180px"
                        >
                          <el-option v-for="p in element.presets" :key="p.label" :label="p.label" :value="p.label" />
                        </el-select>
                        <div v-else class="custom-size-row">
                          <span>宽</span>
                          <el-input-number v-model="formData[element.id + '_w']" :min="0" :controls="false" style="width: 70px" @change="handleFormChange" />
                          <span>mm</span>
                          <span>高</span>
                          <el-input-number v-model="formData[element.id + '_h']" :min="0" :controls="false" style="width: 70px" @change="handleFormChange" />
                          <span>mm</span>
                        </div>
                        <el-checkbox v-model="sizeMixCustom[element.id]" @change="(val) => onSizeCustomToggle(element, val)">自定义</el-checkbox>
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
                      <el-option v-for="opt in element.options" :key="opt.id" :label="opt.label" :value="opt.id" />
                    </el-select>

                    <el-radio-group v-else-if="element.type === 'radio'" v-model="formData[element.id]" :disabled="isDisabled(element.id)" @change="handleFormChange">
                      <el-radio-button v-for="opt in element.options" :key="opt.id" :label="opt.id">{{ opt.label }}</el-radio-button>
                    </el-radio-group>

                    <template v-else-if="element.type === 'checkbox'">
                      <div class="craft-options-row">
                        <div v-for="opt in element.options" :key="opt.id" class="craft-option-wrap">
                          <el-checkbox-group v-model="formData[element.id]" :disabled="isDisabled(element.id)" @change="(val) => onCraftChange(element, val)">
                            <el-checkbox-button :label="opt.id">{{ opt.label }}</el-checkbox-button>
                          </el-checkbox-group>
                          <el-button
                            v-if="opt.subElements && (formData[element.id] || []).includes(opt.id)"
                            type="primary"
                            circle
                            size="small"
                            class="craft-config-btn"
                            @click.stop="openCraftDialog(opt)"
                          >
                            <el-icon><Setting /></el-icon>
                          </el-button>
                          <el-tag
                            v-if="(formData[element.id] || []).includes(opt.id) && opt.subElements && isCraftConfigured(opt)"
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
                          <el-option v-for="preset in element.presets" :key="preset" :label="String(preset)" :value="preset" />
                        </el-select>
                        <el-input-number v-else v-model="formData[element.id]" :min="element.min" :max="element.max" :step="element.step" @change="handleFormChange" />
                        <span class="unit" v-if="element.unit">{{ element.unit }}</span>
                      </div>
                    </template>

                    <template v-else-if="element.type === 'size-mix'">
                      <div class="size-mix-container">
                        <el-select
                          v-if="!sizeMixCustom[element.id]"
                          v-model="sizeMixPresetKey[element.id]"
                          placeholder="选择标准尺寸"
                          @change="(val) => onSizePresetSelect(element, val)"
                          style="width: 180px"
                        >
                          <el-option v-for="p in element.presets" :key="p.label" :label="p.label" :value="p.label" />
                        </el-select>
                        <div v-else class="custom-size-row">
                          <span>宽</span>
                          <el-input-number v-model="formData[element.id + '_w']" :min="0" :controls="false" style="width: 70px" @change="handleFormChange" />
                          <span>mm</span>
                          <span>高</span>
                          <el-input-number v-model="formData[element.id + '_h']" :min="0" :controls="false" style="width: 70px" @change="handleFormChange" />
                          <span>mm</span>
                        </div>
                        <el-checkbox v-model="sizeMixCustom[element.id]" @change="(val) => onSizeCustomToggle(element, val)">自定义</el-checkbox>
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
                      <el-option v-for="opt in element.options" :key="opt.id" :label="opt.label" :value="opt.id" />
                    </el-select>

                    <el-radio-group v-else-if="element.type === 'radio'" v-model="formData[element.id]" :disabled="isDisabled(element.id)" @change="handleFormChange">
                      <el-radio-button v-for="opt in element.options" :key="opt.id" :label="opt.id">{{ opt.label }}</el-radio-button>
                    </el-radio-group>

                    <template v-else-if="element.type === 'checkbox'">
                      <div class="craft-options-row">
                        <div v-for="opt in element.options" :key="opt.id" class="craft-option-wrap">
                          <el-checkbox-group v-model="formData[element.id]" :disabled="isDisabled(element.id)" @change="(val) => onCraftChange(element, val)">
                            <el-checkbox-button :label="opt.id">{{ opt.label }}</el-checkbox-button>
                          </el-checkbox-group>
                          <el-button
                            v-if="opt.subElements && (formData[element.id] || []).includes(opt.id)"
                            type="primary"
                            circle
                            size="small"
                            class="craft-config-btn"
                            @click.stop="openCraftDialog(opt)"
                          >
                            <el-icon><Setting /></el-icon>
                          </el-button>
                          <el-tag
                            v-if="(formData[element.id] || []).includes(opt.id) && opt.subElements && isCraftConfigured(opt)"
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
              <div class="pricing-header"><h3>订单报价结算</h3></div>
              <div class="pricing-body">
                <div class="summary-item">
                  <span class="label">产品名称：</span>
                  <span class="value">{{ schemaData.productName }}</span>
                </div>
                <el-divider border-style="dashed" />
                <div class="total-price-wrap">
                  <div class="total-label">预计总价 (不含运费)</div>
                  <div class="price-val">¥ <span>{{ currentTotalPrice }}</span></div>
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
      <el-form :model="craftFormData" label-width="100px" style="padding: 10px 20px" v-if="craftCurrentOpt">
        <el-form-item v-for="sub in craftCurrentOpt.subElements" :key="sub.id" :label="sub.name" :required="sub.required">
          <el-select v-if="sub.type === 'select'" v-model="craftFormData[sub.id]" placeholder="请选择" style="width: 220px">
            <el-option v-for="sopt in sub.options" :key="sopt.id" :label="sopt.label" :value="sopt.id" />
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
import { getAllSchemaElements, getSectionElements, normalizeSchema } from '@/utils/schema'

const props = defineProps({
  categoryId: { type: [String, Number], required: true }
})

const loading = ref(true)
const schemaData = ref(normalizeSchema(null))
const formData = ref({})
const currentTotalPrice = ref('0.00')
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

const orderedSections = computed(() => {
  return [...(schemaData.value.sections || [])].sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0))
})
const commonElements = computed(() => {
  const all = getSectionElements(schemaData.value.common)
  return [...all].sort((a, b) => (a.weight || 0) - (b.weight || 0))
})

const getSortedSectionElements = (section) => {
  const all = getSectionElements(section)
  return [...all].sort((a, b) => (a.weight || 0) - (b.weight || 0))
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
    return { label, width, height }
  }
  const parsed = parseSizeFromLabel(preset)
  if (!parsed || parsed.width <= 0 || parsed.height <= 0) return null
  return {
    label: String(preset || '').trim() || `${parsed.width}x${parsed.height}mm`,
    width: parsed.width,
    height: parsed.height
  }
}

const normalizeSizeMixElement = (el) => {
  if (!el || el.type !== 'size-mix') return
  const presets = (Array.isArray(el.presets) ? el.presets : [])
    .map(normalizeSizePreset)
    .filter(Boolean)
  el.presets = presets.length ? presets : [{ label: '90x54mm', width: 90, height: 54 }]
}

onMounted(() => loadSchema())
watch(() => props.categoryId, () => loadSchema())

const loadSchema = async () => {
  if (!props.categoryId) return
  loading.value = true
  try {
    let res = await getCategorySchema(props.categoryId)
    if (typeof res === 'string') res = JSON.parse(res)
    schemaData.value = normalizeSchema(res, '')
    initFormModel()
    handleFormChange()
  } catch (err) {
    console.error(err)
    ElMessage.warning('加载配置失败')
  } finally {
    loading.value = false
  }
}

const initFormModel = () => {
  const model = {}
  getAllElementsFlat().forEach((el) => {
    if (el.type === 'checkbox') {
      model[el.id] = []
      el.options?.forEach((opt) => {
        opt.subElements?.forEach((sub) => {
          model[sub.id] = sub.type === 'number' ? 1 : ''
        })
      })
    } else if (el.type === 'number') {
      model[el.id] = el.presets?.[0] || 1
    } else if (el.type === 'size-mix') {
      normalizeSizeMixElement(el)
      const p = el.presets?.[0]
      sizeMixPresetKey.value[el.id] = p?.label || ''
      sizeMixCustom.value[el.id] = false
      model[el.id + '_w'] = p?.width || 0
      model[el.id + '_h'] = p?.height || 0
      model[el.id] = p?.label || ''
    } else {
      model[el.id] = ''
    }
  })
  formData.value = model
  lastCheckedValues.value = JSON.parse(JSON.stringify(model))
}

const handleFormChange = () => {
  checkConstraints()
  if (calcTimer) clearTimeout(calcTimer)
  calcTimer = setTimeout(async () => {
    try {
      const res = await adminPreviewCalculatePrice(props.categoryId, { formData: formData.value })
      if (res) currentTotalPrice.value = res
    } catch (_) {}
  }, 300)
}

const checkConstraints = () => {
  const hidden = new Set()
  const disabled = new Set()
  ;(schemaData.value.common?.constraints || []).forEach((r) => {
    const val = formData.value[r.condition.targetId]
    let hit = false
    if (r.condition.operator === '==') hit = val == r.condition.value
    else if (r.condition.operator === '!=') hit = val != r.condition.value
    else if (r.condition.operator === 'in') hit = Array.isArray(val) && val.includes(r.condition.value)
    if (!hit) return
    if (r.action.effect === 'hide') hidden.add(r.action.targetId)
    else if (r.action.effect === 'disable') disabled.add(r.action.targetId)
  })
  orderedSections.value.forEach((section) => {
    ;(section.constraints || []).forEach((r) => {
      const val = formData.value[r.condition.targetId]
      let hit = false
      if (r.condition.operator === '==') hit = val == r.condition.value
      else if (r.condition.operator === '!=') hit = val != r.condition.value
      else if (r.condition.operator === 'in') hit = Array.isArray(val) && val.includes(r.condition.value)
      if (!hit) return
      if (r.action.effect === 'hide') hidden.add(r.action.targetId)
      else if (r.action.effect === 'disable') disabled.add(r.action.targetId)
    })
  })
  ;(schemaData.value.constraints || []).forEach((r) => {
    const val = formData.value[r.condition.targetId]
    let hit = false
    if (r.condition.operator === '==') hit = val == r.condition.value
    else if (r.condition.operator === '!=') hit = val != r.condition.value
    else if (r.condition.operator === 'in') hit = Array.isArray(val) && val.includes(r.condition.value)
    if (!hit) return
    if (r.action.effect === 'hide') hidden.add(r.action.targetId)
    else if (r.action.effect === 'disable') disabled.add(r.action.targetId)
  })
  hiddenElements.value = hidden
  disabledElements.value = disabled
}

const onSizePresetSelect = (el, label) => {
  normalizeSizeMixElement(el)
  const p = el.presets.find(x => x.label === label)
  if (!p) return
  formData.value[el.id + '_w'] = p.width
  formData.value[el.id + '_h'] = p.height
  formData.value[el.id] = label
  sizeMixCustom.value[el.id] = false
  handleFormChange()
}

const onSizeCustomToggle = (el, custom) => {
  if (custom) {
    sizeMixPresetKey.value[el.id] = ''
    formData.value[el.id] = 'custom'
  } else {
    onSizePresetSelect(el, el.presets?.[0]?.label)
  }
  handleFormChange()
}

const onCraftChange = (el, val) => {
  const old = lastCheckedValues.value[el.id] || []
  const added = val.filter(v => !old.includes(v))
  if (added.length > 0) {
    const opt = el.options.find(o => o.id === added[0])
    if (opt?.subElements?.length) openCraftDialog(opt)
  }
  lastCheckedValues.value[el.id] = [...val]
  handleFormChange()
}

const openCraftDialog = (opt) => {
  craftCurrentOpt.value = opt
  craftDialogTitle.value = `${opt.label} 参数配置`
  const saved = craftStoredData.value[opt.id] || {}
  const init = {}
  ;(opt.subElements || []).forEach((s) => {
    init[s.id] = saved[s.id] || (s.type === 'number' ? 1 : '')
  })
  craftFormData.value = init
  craftDialogVisible.value = true
}

const confirmCraftDialog = () => {
  craftStoredData.value[craftCurrentOpt.value.id] = { ...craftFormData.value }
  Object.assign(formData.value, craftFormData.value)
  craftDialogVisible.value = false
  handleFormChange()
}

const isCraftConfigured = (opt) => !!craftStoredData.value[opt.id]
const isHidden = (id) => hiddenElements.value.has(id)
const isDisabled = (id) => disabledElements.value.has(id)

const submitQuote = () => ElMessage.success(`订单已提交，总计：${currentTotalPrice.value}`)

const buildReadableFormData = () => {
  const grouped = {}
  const commonResult = {}
  commonElements.value.forEach((el) => {
    if (isHidden(el.id)) return
    const val = formData.value[el.id]
    let readableValue = ''
    if (el.type === 'number') {
      readableValue = `${val}${el.unit || ''}`
    } else if (el.type === 'select' || el.type === 'radio') {
      const opt = el.options?.find((o) => o.id === val)
      readableValue = opt ? opt.label : val
    } else if (el.type === 'size-mix') {
      readableValue = sizeMixCustom.value[el.id]
        ? `自定义: ${formData.value[el.id + '_w']} x ${formData.value[el.id + '_h']} mm`
        : val
    } else if (el.type === 'checkbox') {
      const labels = (val || []).map((id) => {
        const opt = el.options?.find((o) => o.id === id)
        return opt ? opt.label : id
      })
      readableValue = labels.join('、')
    }
    if (readableValue) commonResult[el.name] = readableValue
  })
  Object.assign(grouped, commonResult)

  orderedSections.value.forEach((section) => {
    const sectionResult = {}
    getSortedSectionElements(section).forEach((el) => {
      if (isHidden(el.id)) return
      const val = formData.value[el.id]
      let readableValue = ''

      if (el.type === 'number') {
        readableValue = `${val}${el.unit || ''}`
      } else if (el.type === 'select' || el.type === 'radio') {
        const opt = el.options?.find((o) => o.id === val)
        readableValue = opt ? opt.label : val
      } else if (el.type === 'size-mix') {
        readableValue = sizeMixCustom.value[el.id]
          ? `自定义: ${formData.value[el.id + '_w']} x ${formData.value[el.id + '_h']} mm`
          : val
      } else if (el.type === 'checkbox') {
        const labels = (val || []).map((id) => {
          const opt = el.options?.find((o) => o.id === id)
          let label = opt ? opt.label : id
          const stored = craftStoredData.value[id]
          if (stored && opt?.subElements) {
            const subLabels = opt.subElements.map((sub) => {
              const subVal = stored[sub.id]
              if (sub.type === 'select') {
                const sopt = sub.options?.find(so => so.id === subVal)
                return `${sub.name}: ${sopt ? sopt.label : subVal}`
              }
              return `${sub.name}: ${subVal}`
            })
            label += ` (${subLabels.join(', ')})`
          }
          return label
        })
        readableValue = labels.join('、')
      }

      if (readableValue) sectionResult[el.name] = readableValue
    })
    if (Object.keys(sectionResult).length) {
      if (section.name && section.name.trim()) {
        grouped[section.name] = sectionResult
      } else {
        Object.assign(grouped, sectionResult)
      }
    }
  })
  return grouped
}

const addToCart = async () => {
  if (!schemaData.value) return ElMessage.warning('商品数据尚未加载完成')
  try {
    await addCartItem({
      categoryId: props.categoryId,
      productName: schemaData.value.productName,
      formData: buildReadableFormData(),
      price: currentTotalPrice.value
    })
    ElMessage.success('已加入暂存箱！10分钟内有效，请及时处理。')
    window.dispatchEvent(new CustomEvent('cart-updated'))
  } catch (err) {
    ElMessage.error('加入暂存箱失败，请重试')
  }
}
</script>

<style scoped>
.dynamic-quote-form { margin-top: 10px; }
.config-panel { background: #fff; border-radius: 8px; box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05); padding: 20px 30px; }
.panel-header { border-bottom: 1px solid #eee; margin-bottom: 20px; padding-bottom: 15px; }
.product-title { font-size: 18px; color: #333; }
.sub-title { font-size: 13px; color: #999; margin-left: 10px; font-weight: normal; }
.section-block { margin-bottom: 16px; }
.section-title { font-size: 16px; font-weight: 700; color: #303133; margin: 8px 0 14px; }
.element-item { margin-bottom: 18px !important; }
.tip-icon { margin-left: 5px; color: #ccc; cursor: pointer; }
.number-input-wrap, .size-mix-container { display: flex; align-items: center; gap: 10px; }
.custom-size-row { display: flex; align-items: center; background: #f9f9f9; padding: 4px 10px; border-radius: 4px; border: 1px solid #eee; gap: 6px; }
.craft-options-row { display: flex; flex-wrap: wrap; gap: 10px; }
.craft-option-wrap { display: flex; align-items: center; gap: 5px; }
.craft-config-btn { width: 26px !important; height: 26px !important; padding: 0 !important; }
.pricing-affix { position: sticky; top: 20px; }
.pricing-card { border: none; }
.pricing-header { background: #f72a44; color: #fff; padding: 15px 20px; border-radius: 8px 8px 0 0; }
.pricing-body { padding: 20px; }
.summary-item { display: flex; justify-content: space-between; font-size: 14px; margin-bottom: 10px; }
.total-price-wrap { text-align: right; margin-top: 20px; }
.price-val { color: #f72a44; font-size: 20px; font-weight: bold; }
.price-val span { font-size: 32px; }
.action-wrap { margin-top: 25px; display: flex; flex-direction: column; gap: 10px; }
.submit-btn { height: 45px; background: #f72a44 !important; border-color: #f72a44 !important; }
.cart-btn { height: 40px; }
</style>
