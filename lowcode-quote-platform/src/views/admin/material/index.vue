<template>
  <div class="admin-page">
    <AdminNavbar />
    <div class="page-body">
      <el-card class="main-card">
        <div class="card-header-row">
          <h3>配置全局业务属性组合（此处增减将在图纸台左侧列表同步）</h3>
          <el-button type="primary" size="large" @click="openMaterialEditor(null)">+ 新增当前分类的预设物料</el-button>
        </div>

        <el-tabs v-model="activeTab" class="material-tabs">
          <el-tab-pane label="物料纸张库 (materials)" name="materials" />
          <el-tab-pane label="特种尺寸规则 (sizeGroup)" name="sizeGroup" />
          <el-tab-pane label="印后工艺组 (crafts)" name="crafts" />
          <el-tab-pane label="通用元素层 (elements)" name="elements" />
        </el-tabs>

        <el-table :data="activeComponentList" style="width: 100%" height="calc(100vh - 260px)" border>
          <el-table-column prop="id" label="预设库ID" width="100" />
          <el-table-column prop="label" label="展示名称" />
          <el-table-column prop="type" label="底层交互控件" width="200" />
          <el-table-column label="操作" width="200" align="center">
            <template #default="{ row }">
              <el-button size="small" type="primary" plain @click="openMaterialEditor(row)">预设参数配置</el-button>
              <el-button size="small" type="danger" plain @click="handleDeleteMaterial(row.id)">删除弃用</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-card>
    </div>

    <!-- 单个全局物料预设编辑器 -->
    <el-dialog v-model="materialEditorVisible" :title="materialForm.id ? '编辑全局物料预设' : '新增全局物料'" width="550px">
      <el-form label-width="120px">
        <el-form-item label="归属架构层级">
          <el-select v-model="materialForm.category">
            <el-option label="物料纸张库 (materials)" value="materials" />
            <el-option label="特种尺寸规则 (sizeGroup)" value="sizeGroup" />
            <el-option label="印后工艺组 (crafts)" value="crafts" />
            <el-option label="通用元素层 (elements)" value="elements" />
          </el-select>
        </el-form-item>
        <el-form-item label="业务材料名称">
          <el-input v-model="materialForm.label" placeholder="如：名片常用铜版纸 / 极光烫金板..." />
        </el-form-item>
        <el-form-item label="使用的基础组件">
          <el-select v-model="materialForm.type" :disabled="!!materialForm.id" placeholder="选定后无法修改">
            <el-option label="下拉单选控件 (select)" value="select" />
            <el-option label="平铺单选控件 (radio)" value="radio" />
            <el-option label="高级多选控件 (checkbox)" value="checkbox" />
            <el-option label="独立数字输入 (number)" value="number" />
            <el-option label="复合尺寸选择器 (size-mix)" value="size-mix" />
          </el-select>
        </el-form-item>

        <el-divider v-if="['select', 'radio', 'checkbox'].includes(materialForm.type)">预设选项体系与全局价格定义</el-divider>

        <div v-if="['select', 'radio', 'checkbox'].includes(materialForm.type)">
          <div class="option-list" style="max-height: 250px; overflow-y: auto; padding-right: 10px;">
            <div class="opt-row" v-for="(opt, oIdx) in materialForm.options" :key="oIdx" style="margin-bottom:8px; display:flex; gap:8px;">
              <el-input v-model="opt.label" placeholder="选项名称" size="small" style="width: 140px"/>
              <el-input-number v-model="opt.priceAdd" :step="1" size="small" controls-position="right" placeholder="固定加价" style="width: 110px"/>
              <el-input-number v-model="opt.priceRatio" :min="0" :step="0.1" size="small" controls-position="right" placeholder="乘积系数" style="width: 100px"/>
              <el-button type="danger" link icon="Delete" @click="materialForm.options.splice(oIdx, 1)"/>
            </div>
          </div>
          <el-button type="primary" plain size="small" style="width: 100%; margin-top:10px" @click="materialForm.options.push({id: 'opt_' + Date.now(), label: '', priceAdd: 0, priceRatio: 1})">
            + 在该物料库中预设一行业务选项
          </el-button>
        </div>
      </el-form>
      <template #footer>
        <el-button @click="materialEditorVisible = false">取消</el-button>
        <el-button type="success" @click="saveMaterialData">保存到核心业务库并落盘</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Delete } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getMaterialList, saveMaterial, deleteMaterial } from '@/api/material'
import AdminNavbar from '@/components/AdminNavbar.vue'

const componentTypes = ref([])
const activeTab = ref('materials')
const materialEditorVisible = ref(false)
const materialForm = ref({ id: null, category: 'materials', label: '', type: 'select', options: [] })

const activeComponentList = computed(() => {
   if (activeTab.value === 'elements') {
      return componentTypes.value.filter(c => !['materials', 'sizeGroup', 'crafts'].includes(c.category))
   }
   return componentTypes.value.filter(c => c.category === activeTab.value)
})

const fetchMaterials = async () => {
   try { componentTypes.value = await getMaterialList() || [] } catch(err){}
}

const openMaterialEditor = (row) => {
   if (row) {
      let parsedOptions = []
      if (row.optionsJson) {
         try { parsedOptions = JSON.parse(row.optionsJson) } catch(e){}
      }
      materialForm.value = {
         id: row.id,
         category: row.category || 'elements',
         label: row.label,
         type: row.type,
         options: parsedOptions
      }
   } else {
      materialForm.value = {
         id: null,
         category: activeTab.value, // 贴心地默认为当前正在查看的分类
         label: '新建' + (activeTab.value === 'materials' ? '物料' : (activeTab.value === 'sizeGroup' ? '尺寸' : (activeTab.value === 'crafts' ? '工艺' : '元素'))),
         type: 'select',
         options: [{id: 'opt_' + Date.now(), label: '默认选项', priceAdd: 0, priceRatio: 1}]
      }
   }
   materialEditorVisible.value = true
}

const saveMaterialData = async () => {
   if (!materialForm.value.label) return ElMessage.warning('业务材料名称不能为空')
   const payload = {
      id: materialForm.value.id,
      category: materialForm.value.category,
      label: materialForm.value.label,
      type: materialForm.value.type,
      icon: materialForm.value.type === 'number' ? 'Setting' : (materialForm.value.type === 'checkbox' ? 'List' : 'Pointer'),
      optionsJson: JSON.stringify(materialForm.value.options)
   }
   try {
      await saveMaterial(payload)
      ElMessage.success('已成功存入核心业务库！回到品类图纸台即可查看到。')
      materialEditorVisible.value = false
      fetchMaterials()
   } catch(e) {}
}

const handleDeleteMaterial = async (id) => {
   ElMessageBox.confirm('这只会将此预设从全量业务物料中心除名（不再供后来的图纸选用），已经使用了该预设的历史商品图纸及其售价不受影响！是否确认移除？', '移除警告', { type: 'warning' }).then(async () => {
      try {
         await deleteMaterial(id)
         ElMessage.success('移除成功')
         fetchMaterials()
      } catch(e) {}
   })
}

onMounted(() => {
  fetchMaterials()
})
</script>

<style scoped>
.admin-page {
  height: 100vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f0f2f5;
}
.page-body {
  flex: 1;
  min-height: 0;
  padding: 22px 28px;
  overflow: auto;
}
.main-card {
  border-radius: 10px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
}
.card-header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 5px;
}
.card-header-row h3 {
  margin: 0;
  padding: 0;
  font-size: 16px;
  color: #303133;
}
.material-tabs {
  margin-top: 10px;
  margin-bottom: 20px;
}
</style>
