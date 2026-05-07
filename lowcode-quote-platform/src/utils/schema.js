export const SECTION_KEYS = ['materials', 'sizeGroup', 'crafts', 'elements']

export function createEmptyBucket(name = '', sortOrder = 1, id = null) {
  return {
    id: id || `sec_${Date.now()}_${Math.floor(Math.random() * 1000)}`,
    name,
    sortOrder,
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
    constraints: Array.isArray(rawBucket?.constraints) ? rawBucket.constraints : []
  }
  SECTION_KEYS.forEach((key) => {
    bucket[key] = Array.isArray(rawBucket?.[key]) ? rawBucket[key] : []
  })
  return bucket
}

export function normalizeSchema(raw, productNameFallback = '') {
  const source = raw && typeof raw === 'object' ? raw : {}
  const pricing = source.pricing || { basePrice: 0, quantityElId: null }

  if (Array.isArray(source.sections)) {
    const sections = source.sections.map((section, index) => normalizeBucket(section, index, ''))

    const common = normalizeBucket(source.common || {}, -1, '')
    common.id = 'common'
    common.sortOrder = 0

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
  })
  wrapped.constraints = Array.isArray(source.constraints) ? source.constraints : []

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
