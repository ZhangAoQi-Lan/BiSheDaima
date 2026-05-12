export const SECTION_KEYS = ['materials', 'sizeGroup', 'crafts', 'elements']

export const RULE_OPERATOR_OPTIONS = [
  { label: '等于', value: '==', description: '字段值与目标值完全一致时触发' },
  { label: '不等于', value: '!=', description: '字段值与目标值不一致时触发' },
  { label: '包含', value: 'in', description: '多选字段包含指定选项时触发' }
]

export const RULE_EFFECT_OPTIONS = [
  { label: '隐藏字段', value: 'hide', description: '满足条件后不展示目标字段' },
  { label: '禁用字段', value: 'disable', description: '满足条件后字段可见但不可编辑' }
]

export const DEFAULT_PRICING_OPERATIONS = [
  {
    id: 'op_base',
    type: 'base',
    label: '基础底价',
    enabled: true,
    description: '作为报价起始金额，通常对应开机费、基础工费或起印成本。'
  },
  {
    id: 'op_options',
    type: 'option_add_sum',
    label: '选配加价汇总',
    enabled: true,
    description: '汇总纸张、工艺、尺寸预设等选项中配置的附加金额。'
  },
  {
    id: 'op_option_ratio',
    type: 'option_ratio_multiply',
    label: '选项系数乘算',
    enabled: true,
    description: '将已选项中的系数连乘，用于体现材质、印色或工艺对单价的倍率影响。'
  },
  {
    id: 'op_quantity',
    type: 'multiply_number',
    label: '按数量乘算',
    enabled: false,
    fieldId: null,
    description: '绑定数量类字段后，将当前金额按数量倍数放大。'
  },
  {
    id: 'op_models',
    type: 'multiply_number',
    label: '按款数乘算',
    enabled: false,
    fieldId: null,
    description: '绑定款数类字段后，适用于多款内容分别生产的场景。'
  }
]

function sanitizePricingKey(rawValue = '') {
  const normalized = String(rawValue)
    .trim()
    .replace(/[^A-Za-z0-9_]/g, '_')
    .replace(/_+/g, '_')
    .replace(/^_+|_+$/g, '')

  if (!normalized) return null
  return /^[A-Za-z_]/.test(normalized) ? normalized : `field_${normalized}`
}

function buildDefaultPricingKey(element = {}) {
  const nameSlug = String(element.name || '')
    .trim()
    .replace(/[^A-Za-z0-9\u4e00-\u9fa5]+/g, '_')
    .replace(/^_+|_+$/g, '')

  const idSlug = String(element.id || '')
    .trim()
    .replace(/[^A-Za-z0-9_]/g, '_')

  const candidate = sanitizePricingKey(nameSlug)
  if (candidate) return candidate
  return sanitizePricingKey(idSlug) || `field_${Date.now()}`
}

export function normalizePricingKey(rawValue, element = {}) {
  return sanitizePricingKey(rawValue) || buildDefaultPricingKey(element)
}

export function ensureElementPricingMeta(element = {}) {
  if (!element.pricingMeta || typeof element.pricingMeta !== 'object') {
    element.pricingMeta = {}
  }

  element.pricingMeta.key = normalizePricingKey(element.pricingMeta.key, element)
  return element
}

function ensurePricingOperationDefaults(pricing) {
  if (!Array.isArray(pricing.operations)) {
    pricing.operations = []
  }

  if (!pricing.operations.some(operation => operation.id === 'op_option_ratio' || operation.type === 'option_ratio_multiply')) {
    pricing.operations.splice(2, 0, {
      id: 'op_option_ratio',
      type: 'option_ratio_multiply',
      label: '选项系数乘算',
      enabled: true,
      fieldId: null,
      description: '将已选项中的系数连乘，用于体现材质、印色或工艺对单价的倍率影响。'
    })
  }

  return pricing
}

export function createDefaultPricing(rawPricing = {}) {
  const pricing = {
    quantityElId: rawPricing?.quantityElId ?? null,
    modelsElId: rawPricing?.modelsElId ?? null,
    formula: rawPricing?.formula || '(basePrice + optionTotal) * optionRatio * quantity * models',
    note: rawPricing?.note || '推荐直接使用公式计价；若未填写公式，则回退为下方结构化步骤。priceAdd 用于固定加价，priceRatio 用于倍率乘算，optionRatio 表示当前所有已选项系数的连乘结果。',
    operations: []
  }

  const rawOperations = Array.isArray(rawPricing?.operations) ? rawPricing.operations : []

  if (rawOperations.length) {
    pricing.operations = rawOperations.map((operation, index) => ({
      id: operation?.id || `op_${index + 1}`,
      type: operation?.type || 'option_add_sum',
      label: operation?.label || `步骤 ${index + 1}`,
      enabled: operation?.enabled !== false,
      fieldId: operation?.fieldId ?? null,
      description: operation?.description || ''
    }))
    ensurePricingOperationDefaults(pricing)
  } else {
    pricing.operations = DEFAULT_PRICING_OPERATIONS.map((operation) => {
      if (operation.id === 'op_quantity') {
        return { ...operation, enabled: !!pricing.quantityElId, fieldId: pricing.quantityElId }
      }
      if (operation.id === 'op_models') {
        return { ...operation, enabled: !!pricing.modelsElId, fieldId: pricing.modelsElId }
      }
      return { ...operation }
    })
  }

  return pricing
}

export function syncPricingOperations(pricing) {
  if (!pricing || !Array.isArray(pricing.operations)) return pricing
  ensurePricingOperationDefaults(pricing)
  pricing.operations.forEach((op) => {
    if (op.id === 'op_quantity') {
      op.enabled = !!pricing.quantityElId
      op.fieldId = pricing.quantityElId ?? null
    }
    if (op.id === 'op_models') {
      op.enabled = !!pricing.modelsElId
      op.fieldId = pricing.modelsElId ?? null
    }
  })
  return pricing
}

export function createEmptyBucket(name = '', sortOrder = 1, id = null) {
  return {
    id: id || `sec_${Date.now()}_${Math.floor(Math.random() * 1000)}`,
    name,
    sortOrder,
    basePrice: 0,
    materials: [],
    sizeGroup: [],
    crafts: [],
    elements: [],
    constraints: []
  }
}

export function createEmptySection(name = '', sortOrder = 1, id = null) {
  return createEmptyBucket(name, sortOrder, id)
}

function normalizeBucket(rawBucket, index, fallbackName = '') {
  const rawName = (rawBucket?.name ?? '').trim()
  const isLegacyBaseName = /^基础配置(\s*\(#\d+\))?$/.test(rawName)
  const normalizedName = isLegacyBaseName ? '' : (rawName || fallbackName)

  const bucket = {
    id: rawBucket?.id || `sec_${Date.now()}_${index}`,
    name: normalizedName,
    sortOrder: Number(rawBucket?.sortOrder || index + 1),
    basePrice: Number(rawBucket?.basePrice) || 0,
    constraints: Array.isArray(rawBucket?.constraints) ? rawBucket.constraints : []
  }

  SECTION_KEYS.forEach((key) => {
    bucket[key] = Array.isArray(rawBucket?.[key]) ? rawBucket[key] : []
    bucket[key].forEach((element) => {
      ensureElementPricingMeta(element)
      if (element.options) {
        element.options.forEach((opt) => {
          if (opt.priceRatio === undefined) opt.priceRatio = 1
        })
      }
    })
  })

  return bucket
}

export function normalizeSchema(raw, productNameFallback = '') {
  const source = raw && typeof raw === 'object' ? raw : {}
  const pricing = createDefaultPricing(source.pricing)

  if (Array.isArray(source.sections)) {
    const sections = source.sections.map((section, index) => normalizeBucket(section, index, ''))
    const common = normalizeBucket(source.common || {}, -1, '')
    common.id = 'common'
    common.sortOrder = 0

    if (!common.basePrice && Number(source.pricing?.basePrice)) {
      common.basePrice = Number(source.pricing.basePrice)
    }

    return {
      ...source,
      schemaVersion: 2,
      productName: source.productName || productNameFallback || '未命名产品',
      common,
      sections,
      constraints: Array.isArray(source.constraints) ? source.constraints : [],
      pricing
    }
  }

  const wrapped = createEmptyBucket('', 1, 'sec_base')
  SECTION_KEYS.forEach((key) => {
    wrapped[key] = Array.isArray(source[key]) ? source[key] : []
    wrapped[key].forEach((element) => {
      ensureElementPricingMeta(element)
      if (element.options) {
        element.options.forEach((opt) => {
          if (opt.priceRatio === undefined) opt.priceRatio = 1
        })
      }
    })
  })
  wrapped.constraints = Array.isArray(source.constraints) ? source.constraints : []

  if (Number(source.pricing?.basePrice)) {
    wrapped.basePrice = Number(source.pricing.basePrice)
  }

  return {
    categoryId: source.categoryId ?? null,
    productName: source.productName || productNameFallback || '未命名产品',
    schemaVersion: 2,
    common: createEmptyBucket('', 0, 'common'),
    sections: [wrapped],
    constraints: [],
    pricing
  }
}

export function getSectionElements(section) {
  if (!section) return []
  return SECTION_KEYS.flatMap((key) => section[key] || [])
}

export function getAllSchemaElements(schema) {
  if (!schema) return []
  const commonElements = getSectionElements(schema.common)
  const sectionElements = (schema.sections || []).flatMap((section) => getSectionElements(section))
  return [...commonElements, ...sectionElements]
}
