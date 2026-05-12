<template>
  <div class="admin-page">
    <AdminNavbar />
    <div class="page-body">
      <el-card class="page-card">
        <template #header>首页与店铺信息维护</template>
        <el-form label-position="top">
          <el-row :gutter="18">
            <el-col :span="12">
              <el-form-item label="店铺名称">
                <el-input v-model="form.shopName" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="联系电话">
                <el-input v-model="form.contactPhone" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="18">
            <el-col :span="12">
              <el-form-item label="客服微信">
                <el-input v-model="form.contactWechat" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="服务时间">
                <el-input v-model="form.serviceHours" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-form-item label="店铺地址">
            <el-input v-model="form.shopAddress" />
          </el-form-item>
          <el-form-item label="店铺介绍">
            <el-input v-model="form.shopIntro" type="textarea" :rows="4" />
          </el-form-item>
          <el-form-item label="公告列表">
            <el-input
              v-model="announcementsText"
              type="textarea"
              :rows="6"
              placeholder="每行一条公告"
            />
          </el-form-item>
          <el-button type="primary" :loading="saving" @click="save">保存内容</el-button>
        </el-form>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import AdminNavbar from '@/components/AdminNavbar.vue'
import { getAdminSiteContent, saveAdminSiteContent } from '@/api/site'

const saving = ref(false)
const announcementsText = ref('')
const form = reactive({
  shopName: '',
  shopIntro: '',
  contactPhone: '',
  contactWechat: '',
  serviceHours: '',
  shopAddress: ''
})

const fetchContent = async () => {
  const data = await getAdminSiteContent()
  Object.assign(form, data)
  try {
    announcementsText.value = JSON.parse(data.announcements || '[]').join('\n')
  } catch {
    announcementsText.value = data.announcements || ''
  }
}

const save = async () => {
  saving.value = true
  try {
    await saveAdminSiteContent({
      ...form,
      announcements: JSON.stringify(
        announcementsText.value
          .split('\n')
          .map(item => item.trim())
          .filter(Boolean)
      )
    })
    ElMessage.success('站点内容已保存')
  } finally {
    saving.value = false
  }
}

onMounted(fetchContent)
</script>

<style scoped>
.admin-page {
  min-height: 100vh;
  background: #f3f5f7;
}
.page-body {
  padding: 22px 28px;
}
.page-card {
  border-radius: 12px;
}
</style>
