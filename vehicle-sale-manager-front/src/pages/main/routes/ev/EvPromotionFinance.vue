<template>
  <div class="ev-promotion-finance">
    <div class="mb12">
      <el-form :model="promotionForm" inline size="small" label-width="80px">
        <el-form-item label="车型ID">
          <el-input-number v-model="promotionForm.vehicleId" :min="1" />
        </el-form-item>
        <el-form-item label="标题">
          <el-input v-model="promotionForm.title" placeholder="活动名称" />
        </el-form-item>
        <el-form-item label="类型">
          <el-input v-model="promotionForm.type" placeholder="折扣/赠品" />
        </el-form-item>
        <el-form-item label="折扣(0.9)">
          <el-input-number v-model="promotionForm.discountRate" :min="0" :max="1" :step="0.01" />
        </el-form-item>
        <el-form-item label="赠品">
          <el-input v-model="promotionForm.gift" />
        </el-form-item>
        <el-form-item label="开始日期">
          <el-date-picker v-model="promotionForm.startDate" type="date" placeholder="选择日期" value-format="yyyy-MM-dd" style="width: 150px" />
        </el-form-item>
        <el-form-item label="结束日期">
          <el-date-picker v-model="promotionForm.endDate" type="date" placeholder="选择日期" value-format="yyyy-MM-dd" style="width: 150px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="savePromotionForm">保存活动</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="mb12">
      <el-form :inline="true" size="small">
        <el-form-item label="活动ID">
          <el-input v-model="promotionStatus.id" style="width: 120px" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="promotionStatus.status" style="width: 140px">
            <el-option label="上线" value="ONLINE" />
            <el-option label="下架" value="OFFLINE" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button @click="changePromotionStatus">更新状态</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-divider>金融方案</el-divider>
    <el-form :model="planForm" inline size="small" label-width="90px">
      <el-form-item label="车型ID">
        <el-input-number v-model="planForm.vehicleId" :min="1" />
      </el-form-item>
      <el-form-item label="方案名">
        <el-input v-model="planForm.name" />
      </el-form-item>
      <el-form-item label="首付比例">
        <el-input-number v-model="planForm.downPaymentRate" :min="0" :max="1" :step="0.01" />
      </el-form-item>
      <el-form-item label="期数(月)">
        <el-input-number v-model="planForm.months" :min="6" />
      </el-form-item>
      <el-form-item label="年化利率">
        <el-input-number v-model="planForm.annualRate" :min="0" :step="0.001" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="savePlan">保存方案</el-button>
        <el-button @click="loadPlans">刷新列表</el-button>
      </el-form-item>
    </el-form>
    <el-table :data="plans" size="small" border class="mt8">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="vehicleId" label="车型ID" width="90" />
      <el-table-column prop="name" label="方案" />
      <el-table-column prop="downPaymentRate" label="首付比例" width="110" />
      <el-table-column prop="months" label="期数" width="80" />
      <el-table-column prop="annualRate" label="年化利率" width="100" />
    </el-table>
  </div>
</template>

<script>
import {
  savePromotion,
  changePromotionStatus,
  saveFinancialPlan,
  listFinancialPlans
} from '@/api/ev'

export default {
  name: 'EvPromotionFinance',
  data () {
    return {
      promotionForm: {
        vehicleId: null,
        title: '',
        type: '',
        discountRate: null,
        gift: '',
        startDate: null,
        endDate: null
      },
      promotionStatus: {
        id: '',
        status: 'ONLINE'
      },
      planForm: {
        vehicleId: null,
        name: '',
        downPaymentRate: null,
        months: null,
        annualRate: null
      },
      plans: []
    }
  },
  created () {
    this.loadPlans()
  },
  methods: {
    async savePromotionForm () {
      const res = await savePromotion(this.promotionForm)
      if (res.status) this.$message.success('已保存活动')
    },
    async changePromotionStatus () {
      if (!this.promotionStatus.id) return
      const res = await changePromotionStatus(this.promotionStatus.id, this.promotionStatus.status)
      if (res.status) this.$message.success('已更新')
    },
    async savePlan () {
      const res = await saveFinancialPlan(this.planForm)
      if (res.status) {
        this.$message.success('已保存方案')
        this.loadPlans()
      }
    },
    async loadPlans () {
      const res = await listFinancialPlans()
      if (res.status) this.plans = res.data || []
    }
  }
}
</script>

<style lang="less" scoped>
.ev-promotion-finance {
  .mb12 { margin-bottom: 12px; }
  .mt8 { margin-top: 8px; }
}
</style>

