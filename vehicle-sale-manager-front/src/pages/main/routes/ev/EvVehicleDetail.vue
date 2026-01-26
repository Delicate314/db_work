<template>
  <div class="ev-detail">
    <el-page-header @back="$router.back()" content="车型详情" class="mb16" />

    <el-card shadow="never" class="mb16" v-if="detail">
      <!-- 图片展示区域 -->
      <div class="image-gallery mb16">
        <el-carousel :interval="5000" type="card" height="300px">
          <el-carousel-item v-for="(image, index) in vehicleImages" :key="index">
            <img :src="image" alt="车辆图片" class="carousel-image">
          </el-carousel-item>
          <el-carousel-item v-if="vehicleImages.length === 0">
            <div class="no-image">
              <el-empty description="暂无车辆图片" />
            </div>
          </el-carousel-item>
        </el-carousel>
      </div>

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
          
          <!-- 金融方案 -->
          <el-card shadow="never" class="mt12" body-style="{padding:'10px'}">
            <div slot="header" class="card-header">金融方案</div>
            <el-empty v-if="!financialPlans || financialPlans.length === 0" description="暂无金融方案" />
            <div v-else class="financial-plans">
              <div 
                v-for="plan in financialPlans" 
                :key="plan.id" 
                class="plan-card"
                :class="{ 'plan-selected': selectedPlanId === plan.id }"
                @click="selectPlan(plan.id)">
                <div class="plan-content">
                  <div class="plan-header">
                    <el-radio v-model="selectedPlanId" :label="plan.id" @change="handlePlanChange">
                      <span class="plan-name">{{ plan.name }}</span>
                    </el-radio>
                  </div>
                  <div class="plan-details">
                    <div>首付：{{ formatDownPayment(plan) }}</div>
                    <div>期数：{{ plan.months }}期</div>
                    <div>年化利率：{{ (plan.annualRate * 100).toFixed(2) }}%</div>
                  </div>
                  <div v-if="selectedPlanId === plan.id && detail && detail.vehicle" class="plan-calc">
                    <div class="calc-result">
                      <span class="calc-label">月供（1台）：</span>
                      <span class="calc-value">¥{{ formatPrice(calculateMonthlyPayment(plan, 1)) }}</span>
                    </div>
                    <div class="calc-details">
                      <div>首付金额：¥{{ formatPrice(calculateDownPayment(plan, 1)) }}</div>
                      <div>贷款金额：¥{{ formatPrice(calculateLoanAmount(plan, 1)) }}</div>
                      <div>总利息：¥{{ formatPrice(calculateTotalInterest(plan, 1)) }}</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
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

    <el-dialog :visible.sync="showOrder" title="下单" width="600px">
      <el-form :model="orderForm" label-width="100px" size="small">
        <el-form-item label="提车门店">
          <el-select v-model="orderForm.store" placeholder="请选择提车门店" filterable style="width: 100%">
            <el-option
              v-for="store in storeList"
              :key="store"
              :label="store"
              :value="store">
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="数量">
          <el-input-number v-model="orderForm.quantity" :min="1" />
        </el-form-item>
        <el-form-item label="金融方案">
          <el-select v-model="orderForm.financialPlanId" placeholder="请选择金融方案" clearable style="width: 100%">
            <el-option
              v-for="plan in financialPlans"
              :key="plan.id"
              :label="plan.name"
              :value="plan.id">
              <span style="float: left">{{ plan.name }}</span>
              <span style="float: right; color: #8492a6; font-size: 13px">
                首付{{ (plan.downPaymentRate * 100).toFixed(0) }}% / {{ plan.months }}期 / {{ (plan.annualRate * 100).toFixed(2) }}%
              </span>
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item v-if="orderForm.financialPlanId && detail && detail.vehicle" label="月供金额">
          <span class="monthly-payment-display">
            ¥{{ formatPrice(calculateMonthlyPayment(getSelectedPlan())) }}
          </span>
          <div class="payment-details">
            <div>首付：¥{{ formatPrice(calculateDownPayment(getSelectedPlan())) }}</div>
            <div>贷款：¥{{ formatPrice(calculateLoanAmount(getSelectedPlan())) }}</div>
          </div>
        </el-form-item>
        <el-form-item label="联系人">
          <el-input v-model="orderForm.contactName" />
        </el-form-item>
        <el-form-item label="电话">
          <el-input v-model="orderForm.contactPhone" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="orderForm.remark" type="textarea" :rows="2" />
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
          <el-select v-model="testDriveForm.store" placeholder="请选择门店" filterable style="width: 100%">
            <el-option
              v-for="store in storeList"
              :key="store"
              :label="store"
              :value="store">
            </el-option>
          </el-select>
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
  subscribeInventory,
  getFinancialPlans
} from '@/api/ev'

export default {
  name: 'EvVehicleDetail',
  data() {
    return {
      detail: null,
      reviews: [],
      financialPlans: [],
      selectedPlanId: null,
      showOrder: false,
      showTestDrive: false,
      // 门店列表
      storeList: [
        '北京朝阳店',
        '北京海淀店',
        '北京丰台店',
        '上海浦东店',
        '上海徐汇店',
        '上海静安店',
        '广州天河店',
        '广州番禺店',
        '深圳南山店',
        '深圳福田店',
        '杭州西湖店',
        '杭州余杭店',
        '成都锦江店',
        '成都高新店',
        '武汉江汉店',
        '西安雁塔店',
        '南京建邺店',
        '苏州工业园区店',
        '天津和平店',
        '重庆渝北店'
      ],
      orderForm: {
        store: '',
        quantity: 1,
        contactName: '',
        contactPhone: '',
        remark: '',
        financialPlanId: null
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
    },
    vehicleImages() {
      if (!this.detail || !this.detail.vehicle) return []
      const { brand, name } = this.detail.vehicle
      // 为常见车型使用指定的图片URL
      const vehicleImages = {
        '蔚来 蔚来 ET5': 'https://x0.ifengimg.com/res/2022/1FF981821F97612F3D1CD9084DF3B51BF3F83AC4_size1553_w3000_h2000.jpeg',
        '比亚迪 比亚迪 海豹': 'https://x0.ifengimg.com/res/2022/40FBEE12809C29F8926A83DC65FEECC3509F8788_size198_w800_h492.jpeg',
        '特斯拉 特斯拉 Model Y': 'https://n.sinaimg.cn/sinakd20111/177/w1024h753/20241025/28aa-c33e284dac8617e15aa37a54cc326505.jpg',
        '小鹏 小鹏 P7': 'https://img.pcauto.com.cn/images/upload/upc/tx/auto5/2411/13/c17/463268471_1731480381011.jpg',
        '理想 理想 L7': 'https://img1.xcarimg.com/news/3/39814/40425/40481/846_635_20221230144614023506988395445.jpg',
        '极氪 极氪 001': 'https://img.pcauto.com.cn/images/upload/upc/tx/auto5/2301/03/c43/346866820_1672730570970.jpg',
        '极氪 极氪 007': 'https://th.bing.com/th/id/R.810ab0d5062f410fe4f438192e8610b3?rik=f0YjhuD2KWzCPA&riu=http%3a%2f%2fimg.pcauto.com.cn%2fimages%2fupload%2fupc%2ftx%2fauto5%2f2408%2f14%2fc19%2f438941014_1723612363706.jpg&ehk=C05JItbpSCsUDJgwnmyBWsNiSapCv%2bViuXxjGl2Vf4o%3d&risl=&pid=ImgRaw&r=0',
        '广汽埃安 广汽埃安 AION S Plus': 'https://tse2.mm.bing.net/th/id/OIP.WXaHP3I0Bda9MEs0pNCknwHaFj?rs=1&pid=ImgDetMain&o=7&rm=3',
        '长安深蓝 长安深蓝 SL03': 'https://tse2.mm.bing.net/th/id/OIF.Toei0lYAipKPj6aE24xD7g?rs=1&pid=ImgDetMain&o=7&rm=3',
        '华为 华为问界 M5': 'https://x0.ifengimg.com/res/2023/8390AC2FC36A9217CE67F37B09F9A8AA1C0BD30C_size43_w660_h440.jpg',
        '华为 华为 问界 M5': 'https://x0.ifengimg.com/res/2023/8390AC2FC36A9217CE67F37B09F9A8AA1C0BD30C_size43_w660_h440.jpg',
        '哪吒 哪吒 U Pro': 'https://th.bing.com/th/id/R.b2bac3be201bbf299db478d521a87c4a?rik=WcQH95ErdcyU4A&riu=http%3a%2f%2fs3.xchuxing.com%2fxchuxing%2farticle%2f2021%2f03%2f21%2f0544d202103211046143169.png&ehk=m0qlhr4hnK6Wjx6KlZAfwZCyjkkYA5tlSN2Hy0ek6DM%3d&risl=&pid=ImgRaw&r=0',
        '大众 大众 ID.4 CROZZ': 'https://tse4.mm.bing.net/th/id/OIP.XzFxUk0-0dFl85Po5vwdSwHaE8?rs=1&pid=ImgDetMain&o=7&rm=3',
        '比亚迪 比亚迪 汉 EV': 'https://tse2.mm.bing.net/th/id/OIP.fclJ-4yk6kMLfIZNSyZLzAHaEW?rs=1&pid=ImgDetMain&o=7&rm=3'
      }

      const key = `${brand} ${name}`
      if (key === '蔚来 蔚来 ET5') {
        // 为蔚来ET5使用用户提供的具体图片URL
        return [
          'https://x0.ifengimg.com/res/2022/1FF981821F97612F3D1CD9084DF3B51BF3F83AC4_size1553_w3000_h2000.jpeg',
          'https://img.pcauto.com.cn/images/upload/upc/tx/auto5/2501/06/c56/472777230_1736157728764.jpg',
          'https://img.pcauto.com.cn/images/upload/upc/tx/auto5/2205/06/c77/311293827_1651848779609_1024.jpg',
          'https://tse3.mm.bing.net/th/id/OIP.uTh7MideXhDzP4WIk_Dw-gHaE8?rs=1&pid=ImgDetMain&o=7&rm=3',
          'https://img2.bitauto.com/appimage-630-w1/mapi/media/2021/12/19/20555ab7e45949029230811f893e0b1c.jpeg'
        ]
      } else if (vehicleImages[key]) {
        // 为其他指定车型返回多张图片：第一张为具体图片，后面为生成的不同角度图片
        const baseImage = vehicleImages[key]
        const additionalImages = [
          `${brand} ${name} 侧面外观`,
          `${brand} ${name} 内饰驾驶舱`,
          `${brand} ${name} 尾部外观`,
          `${brand} ${name} 侧面45度角`
        ].map(prompt => {
          const encodedPrompt = encodeURIComponent(prompt)
          return `https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=${encodedPrompt}&image_size=landscape_16_9`
        })
        return [baseImage, ...additionalImages]
      }

      // 其他车型使用生成的图片
      const imagePrompts = [
        `${brand} ${name} 正前方外观`,
        `${brand} ${name} 侧面外观`,
        `${brand} ${name} 内饰驾驶舱`,
        `${brand} ${name} 尾部外观`,
        `${brand} ${name} 侧面45度角`
      ]
      return imagePrompts.map(prompt => {
        const encodedPrompt = encodeURIComponent(prompt)
        return `https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=${encodedPrompt}&image_size=landscape_16_9`
      })
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
    formatPrice(val) {
      if (val === null || val === undefined) return '0.00'
      return Number(val).toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
    },
    async fetchDetail() {
      const res = await vehicleDetail(this.vehicleId)
      if (res.status) {
        this.detail = res.data
        this.loadReviews()
        this.loadFinancialPlans()
      }
    },
    async loadFinancialPlans() {
      const res = await getFinancialPlans(this.vehicleId)
      if (res.status) {
        this.financialPlans = res.data || []
        if (this.financialPlans.length > 0) {
          this.selectedPlanId = this.financialPlans[0].id
        }
      }
    },
    selectPlan(planId) {
      this.selectedPlanId = planId
      this.handlePlanChange()
    },
    handlePlanChange() {
      // 当选择金融方案时，同步更新下单表单
      this.orderForm.financialPlanId = this.selectedPlanId
    },
    getSelectedPlan() {
      return this.financialPlans.find(p => p.id === this.orderForm.financialPlanId) || null
    },
    formatDownPayment(plan) {
      return (plan.downPaymentRate * 100).toFixed(0) + '%'
    },
    // 计算首付金额
    calculateDownPayment(plan, quantity = null) {
      if (!plan || !this.detail || !this.detail.vehicle) return 0
      const vehiclePrice = Number(this.detail.vehicle.guidePrice) || 0
      const qty = quantity !== null ? quantity : (this.orderForm.quantity || 1)
      return vehiclePrice * qty * plan.downPaymentRate
    },
    // 计算贷款金额
    calculateLoanAmount(plan, quantity = null) {
      if (!plan || !this.detail || !this.detail.vehicle) return 0
      const vehiclePrice = Number(this.detail.vehicle.guidePrice) || 0
      const qty = quantity !== null ? quantity : (this.orderForm.quantity || 1)
      const totalPrice = vehiclePrice * qty
      return totalPrice - this.calculateDownPayment(plan, qty)
    },
    // 计算月供（等额本息）
    calculateMonthlyPayment(plan, quantity = null) {
      if (!plan || !this.detail || !this.detail.vehicle) return 0
      const loanAmount = this.calculateLoanAmount(plan, quantity)
      if (loanAmount <= 0) return 0
      
      // 月利率 = 年利率 / 12
      const monthlyRate = plan.annualRate / 12
      const months = plan.months
      
      // 等额本息计算公式：月供 = 贷款本金 × [月利率 × (1+月利率)^还款月数] / [(1+月利率)^还款月数 - 1]
      if (monthlyRate === 0) {
        // 无利息情况
        return loanAmount / months
      }
      
      const pow = Math.pow(1 + monthlyRate, months)
      return loanAmount * (monthlyRate * pow) / (pow - 1)
    },
    // 计算总利息
    calculateTotalInterest(plan, quantity = null) {
      if (!plan) return 0
      const monthlyPayment = this.calculateMonthlyPayment(plan, quantity)
      const loanAmount = this.calculateLoanAmount(plan, quantity)
      return monthlyPayment * plan.months - loanAmount
    },
    async loadReviews() {
      const res = await listReviews(this.vehicleId)
      if (res.status) this.reviews = res.data || []
    },
    async submitOrder() {
      const payload = { 
        ...this.orderForm, 
        userId: this.userId, 
        vehicleId: this.vehicleId,
        financialPlanId: this.orderForm.financialPlanId || null
      }
      const res = await createOrder(payload)
      if (res.status) {
        this.$message.success('下单成功')
        this.showOrder = false
        // 重置表单
        this.orderForm = {
          store: '',
          quantity: 1,
          contactName: '',
          contactPhone: '',
          remark: '',
          financialPlanId: null
        }
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

  .image-gallery {
    width: 100%;

    .carousel-image {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .no-image {
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100%;
    }
  }

  .financial-plans {
    width: 100%;
    display: flex;
    flex-direction: column;
    gap: 12px;

    .plan-card {
      cursor: pointer;
      transition: all 0.3s;
      border: 2px solid #e4e7ed;
      border-radius: 4px;
      padding: 12px;
      background-color: #fff;

      &:hover {
        border-color: #409eff;
        box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
      }

      &.plan-selected {
        border-color: #409eff;
        background-color: #ecf5ff;
      }

      .plan-content {
        .plan-header {
          margin-bottom: 8px;

          .plan-name {
            font-size: 16px;
            font-weight: 600;
            color: #303133;
            margin-left: 8px;
          }
        }

        .plan-details {
          display: flex;
          gap: 16px;
          font-size: 14px;
          color: #606266;
          margin-bottom: 8px;
          margin-left: 28px;
        }

        .plan-calc {
          margin-top: 12px;
          padding-top: 12px;
          border-top: 1px solid #e4e7ed;
          margin-left: 28px;

          .calc-result {
            margin-bottom: 8px;

            .calc-label {
              font-size: 14px;
              color: #606266;
            }

            .calc-value {
              font-size: 24px;
              font-weight: 700;
              color: #e67e22;
              margin-left: 8px;
            }
          }

          .calc-details {
            display: flex;
            gap: 16px;
            font-size: 12px;
            color: #909399;
          }
        }
      }
    }
  }

  .monthly-payment-display {
    font-size: 20px;
    font-weight: 700;
    color: #e67e22;
  }

  .payment-details {
    margin-top: 8px;
    font-size: 12px;
    color: #909399;
    display: flex;
    gap: 16px;
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