import { getAllSchemaElements } from '@/utils/schema'

export function evaluateCondition(condition, formData) {
  if (!condition?.targetId) return false

  const currentValue = formData?.[condition.targetId]
  const expectedValue = condition.value

  if (condition.operator === '==') return currentValue == expectedValue
  if (condition.operator === '!=') return currentValue != expectedValue
  if (condition.operator === 'in') return Array.isArray(currentValue) && currentValue.includes(expectedValue)

  return false
}

export function evaluateRule(rule, formData) {
  if (Array.isArray(rule?.conditions) && rule.conditions.length) {
    if (rule.logic === 'OR') return rule.conditions.some((condition) => evaluateCondition(condition, formData))
    return rule.conditions.every((condition) => evaluateCondition(condition, formData))
  }

  if (rule?.condition) return evaluateCondition(rule.condition, formData)
  return false
}

function processConstraints(constraints, formData, hiddenIds, disabledIds) {
  ;(constraints || []).forEach((rule) => {
    if (!evaluateRule(rule, formData)) return

    if (rule?.action?.effect === 'hide') hiddenIds.add(rule.action.targetId)
    if (rule?.action?.effect === 'disable') disabledIds.add(rule.action.targetId)
  })
}

export function collectConstraintEffects(schema, formData) {
  const hiddenIds = new Set()
  const disabledIds = new Set()

  processConstraints(schema?.common?.constraints, formData, hiddenIds, disabledIds)
  ;(schema?.sections || []).forEach((section) => {
    processConstraints(section?.constraints, formData, hiddenIds, disabledIds)
  })
  processConstraints(schema?.constraints, formData, hiddenIds, disabledIds)

  return { hiddenIds, disabledIds }
}

export function getElementResetState(element) {
  if (!element) return { value: '' }

  if (element.type === 'checkbox') {
    return {
      value: Array.isArray(element.defaultValue) ? [...element.defaultValue] : []
    }
  }

  if (element.type === 'number') {
    return {
      value: element.defaultValue ?? element.presets?.[0] ?? 1
    }
  }

  if (element.type === 'size-mix') {
    const firstPreset = element.presets?.[0]
    return {
      value: firstPreset?.label || '',
      width: firstPreset?.width || 0,
      height: firstPreset?.height || 0,
      presetLabel: firstPreset?.label || ''
    }
  }

  return {
    value: element.defaultValue ?? ''
  }
}

export function syncConstrainedFormState({
  schema,
  formData,
  hiddenIds,
  disabledIds,
  sizeMixPresetKey = {},
  sizeMixCustom = {}
}) {
  const allElements = getAllSchemaElements(schema)
  const targetIds = new Set([...hiddenIds, ...disabledIds])
  let changed = false

  targetIds.forEach((elementId) => {
    const element = allElements.find((item) => item.id === elementId)
    if (!element) return

    const resetState = getElementResetState(element)

    if (element.type === 'size-mix') {
      if (formData[elementId] !== resetState.value) {
        formData[elementId] = resetState.value
        changed = true
      }
      if (formData[`${elementId}_w`] !== resetState.width) {
        formData[`${elementId}_w`] = resetState.width
        changed = true
      }
      if (formData[`${elementId}_h`] !== resetState.height) {
        formData[`${elementId}_h`] = resetState.height
        changed = true
      }
      if (sizeMixPresetKey[elementId] !== resetState.presetLabel) {
        sizeMixPresetKey[elementId] = resetState.presetLabel
        changed = true
      }
      if (sizeMixCustom[elementId] !== false) {
        sizeMixCustom[elementId] = false
        changed = true
      }
      return
    }

    if (JSON.stringify(formData[elementId]) !== JSON.stringify(resetState.value)) {
      formData[elementId] = resetState.value
      changed = true
    }
  })

  return changed
}
