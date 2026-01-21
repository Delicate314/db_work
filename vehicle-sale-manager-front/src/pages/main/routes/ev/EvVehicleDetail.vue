<template>
  <div class="ev-detail">
    <el-page-header @back="$router.back()" content="车型详情" class="mb16" />

    <el-card shadow="never" class="mb16" v-if="detail">
      <div slot="header" class="card-header">
        <div>
          <span class="title">{{ detail.vehicle.brand }} {{ detail.vehicle.name }}</span>
          <el-tag v-if="detail.lowStock" type="danger" size="mini" class="ml8">库存紧张</el-tag>
        </div>
        <div class="price">指导价：{{ fmtPrice(detail.vehicle.guidePrice) }}</div>
      </div>
      <el-row :gutter="16">
        <el-col :span="12">
          <el-descriptions title="基础参数" :column="2" size="small" border>
            <el-descriptions-item label="续航">{{ detail.vehicle.rangeKm }} km</el-descriptions-item>
            <el-descriptions-item label="电池">{{ detail.vehicle.batteryType }}</el-descriptions-item>
            <el-descriptions-item label="智驾">{{ detail.vehicle.smartDriveLevel || '—' }}</el-descriptions-item>
            <el-descriptions-item label="快充">{{ detail.vehicle.fastChargeMinutes }} 分钟</el-descriptions-item>
            <el-descriptions-item label="库存">{{ detail.vehicle.stock }}</el-descriptions-item>
            <el-descriptions-item label="上市时间">{{ detail.vehicle.launchDate }}</el-descriptions-item>
          </el-descriptions>
          <el-descriptions title="配置参数" :column="2" size="small" border class="mt12" v-if="detail.vehicle.configs">
            <el-descriptions-item v-for="(v, k) in detail.vehicle.configs" :key="k" :label="k">
              {{ v }}
            </el-descriptions-item>
          </el-descriptions>
        </el-col>
        <el-col :span="12">
          <div class="actions">
            <el-button type="primary" @click="showOrder = true">立即下单</el-button>
            <el-button @click="showTestDrive = true">预约试驾</el-button>
            <el-button @click="subscribeInventory">订阅库存提醒</el-button>
          </div>
          <el-card shadow="never" class="mt12" body-style="{padding:'10px'}">
            <div slot="header" class="card-header">促销活动</div>
            <el-empty v-if="!detail.promotions || detail.promotions.length === 0" description="暂无活动" />
            <el-timeline v-else>
              <el-timeline-item v-for="p in detail.promotions" :key="p.id" :timestamp="p.title">
                {{ p.description }}
              </el-timeline-item>
            </el-timeline>
          </el-card>
        </el-col>
      </el-row>
    </el-card>

    <el-card shadow="never" class="mb16">
      <div slot="header" class="card-header">评价</div>
      <el-form :model="reviewForm" inline size="small">
        <el-form-item label="评分">
          <el-rate v-model="reviewForm.rating" />
        </el-form-item>
        <el-form-item label="评论">
          <el-input v-model="reviewForm.comment" type="textarea" placeholder="写下你的用车体验" style="width:320px" />
        </el-form-item>
        <el-form-item>
          <el-button size="small" @click="submitReview">提交评价</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="reviews" size="small" border>
        <el-table-column prop="userId" label="用户" width="90" />
        <el-table-column prop="rating" label="评分" width="80" />
        <el-table-column prop="comment" label="内容" />
        <el-table-column prop="createdAt" label="时间" width="160" />
      </el-table>
    </el-card>

    <el-dialog :visible.sync="showOrder" title="下单" width="500px">
      <el-form :model="orderForm" label-width="90px" size="small">
        <el-form-item label="提车门店">
          <el-input v-model="orderForm.store" placeholder="请输入门店" />
        </el-form-item>
        <el-form-item label="数量">
          <el-input-number v-model="orderForm.quantity" :min="1" />
        </el-form-item>
        <el-form-item label="联系人">
          <el-input v-model="orderForm.contactName" />
        </el-form-item>
        <el-form-item label="电话">
          <el-input v-model="orderForm.contactPhone" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="orderForm.remark" />
        </el-form-item>
      </el-form>
      <div slot="footer">
        <el-button @click="showOrder = false">取消</el-button>
        <el-button type="primary" @click="submitOrder">提交</el-button>
      </div>
    </el-dialog>

    <el-dialog :visible.sync="showTestDrive" title="预约试驾" width="500px">
      <el-form :model="testDriveForm" label-width="90px" size="small">
        <el-form-item label="门店">
          <el-input v-model="testDriveForm.store" placeholder="如 上海浦东店" />
        </el-form-item>
        <el-form-item label="时间">
          <el-date-picker v-model="testDriveForm.scheduleTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" />
        </el-form-item>
      </el-form>
      <div slot="footer">
        <el-button @click="showTestDrive = false">取消</el-button>
        <el-button type="primary" @click="submitTestDrive">提交</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import {
  vehicleDetail,
  listReviews,
  addReview,
  createOrder,
  createTestDrive,
  subscribeInventory
} from '@/api/ev'

export default {
  name: 'EvVehicleDetail',
  data() {
    return {
      detail: null,
      reviews: [],
      showOrder: false,
      showTestDrive: false,
      orderForm: {
        store: '',
        quantity: 1,
        contactName: '',
        contactPhone: '',
        remark: ''
      },
      testDriveForm: {
        store: '',
        scheduleTime: ''
      },
      reviewForm: {
        rating: 5,
        comment: ''
      }
    }
  },
  computed: {
    ...mapGetters({
      userId: 'user/getUserId'
    }),
    vehicleId() {
      return Number(this.$route.params.id)
    }
  },
  created() {
    this.fetchDetail()
  },
  methods: {
    fmtPrice(val) {
      if (val === null || val === undefined) return '--'
      const num = Number(val) / 10000
      return num.toFixed(2) + ' 万'
    },
    async fetchDetail() {
      const res = await vehicleDetail(this.vehicleId)
      if (res.status) {
        this.detail = res.data
        this.loadReviews()
      }
    },
    async loadReviews() {
      const res = await listReviews(this.vehicleId)
      if (res.status) this.reviews = res.data || []
    },
    async submitOrder() {
      const payload = { ...this.orderForm, userId: this.userId, vehicleId: this.vehicleId }
      const res = await createOrder(payload)
      if (res.status) {
        this.$message.success('下单成功')
        this.showOrder = false
        this.fetchDetail()
      }
    },
    async submitTestDrive() {
      const payload = { ...this.testDriveForm, userId: this.userId, vehicleId: this.vehicleId }
      const res = await createTestDrive(payload)
      if (res.status) {
        this.$message.success('预约成功')
        this.showTestDrive = false
      }
    },
    async subscribeInventory() {
      const res = await subscribeInventory(this.userId, this.vehicleId)
      if (res.status) this.$message.success('已订阅库存提醒')
    },
    async submitReview() {
      const payload = {
        ...this.reviewForm,
        userId: this.userId,
        vehicleId: this.vehicleId,
        orderId: null
      }
      const res = await addReview(payload)
      if (res.status) {
        this.$message.success('评价成功')
        this.loadReviews()
      }
    }
  }
}
</script>

<style lang="less" scoped>
.ev-detail {
  .card-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  .title {
    font-size: 20px;
    font-weight: 700;
  }

  .price {
    color: #e67e22;
  }

  .actions {
    display: flex;
    gap: 8px;
    margin-bottom: 8px;
  }

  .ml8 {
    margin-left: 8px;
  }

  .mb16 {
    margin-bottom: 16px;
  }

  .mt12 {
    margin-top: 12px;
  }
}
</style>
{
"cells": [],
"metadata": {
"language_info": {
"name": "python"
}
},
"nbformat": 4,
"nbformat_minor": 2
}