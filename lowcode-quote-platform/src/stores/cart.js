import { defineStore } from 'pinia'
import { ref } from 'vue'

/**
 * 暂存箱 Store（类购物车功能）
 * 存储用户添加的定制商品配置 + 计算价格，以便后续统一结算。
 */
export const useCartStore = defineStore('cart', () => {
  // 暂存箱列表，每一项是一个独立的商品配置快照
  const items = ref([])

  // 暂存箱抽屉是否显示
  const drawerVisible = ref(false)

  /**
   * 添加一条配置到暂存箱
   * @param {Object} payload - { productId, productName, formData, price }
   */
  const addToCart = (payload) => {
    items.value.push({
      id: Date.now(), // 唯一标识
      productId: payload.productId,
      productName: payload.productName,
      formData: JSON.parse(JSON.stringify(payload.formData)), // 深拷贝防止外部修改
      price: payload.price,
      createTime: new Date().toLocaleString()
    })
    drawerVisible.value = true // 添加后自动打开抽屉
  }

  /**
   * 从暂存箱删除某一项
   */
  const removeFromCart = (id) => {
    const idx = items.value.findIndex(i => i.id === id)
    if (idx !== -1) items.value.splice(idx, 1)
  }

  /**
   * 清空暂存箱
   */
  const clearCart = () => {
    items.value = []
  }

  /**
   * 计算暂存箱总价
   */
  const totalPrice = () => {
    return items.value.reduce((sum, item) => sum + parseFloat(item.price || 0), 0).toFixed(2)
  }

  return {
    items,
    drawerVisible,
    addToCart,
    removeFromCart,
    clearCart,
    totalPrice
  }
})
