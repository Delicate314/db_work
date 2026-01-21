<template>
    <div class="ev-customer">
        <el-card shadow="never" class="mb16">
            <div slot="header" class="card-header">车型检索与筛选</div>
            <el-form :inline="true" :model="filters" size="small">
                <el-form-item label="品牌">
                    <el-input v-model="filters.brand" placeholder="如 比亚迪/特斯拉" clearable />
                </el-form-item>
                <el-form-item label="价格区间(万)">
                    <el-input-number v-model="filters.minPrice" :min="0" :step="1" controls-position="right" />
                    <span class="dash">-</span>
                    <el-input-number v-model="filters.maxPrice" :min="0" :step="1" controls-position="right" />
                </el-form-item>
                <el-form-item label="续航(km)">
                    <el-input-number v-model="filters.minRange" :min="0" :step="50" controls-position="right" />
                    <span class="dash">-</span>
                    <el-input-number v-model="filters.maxRange" :min="0" :step="50" controls-position="right" />
                </el-form-item>
                <el-form-item label="电池类型">
                    <el-select v-model="filters.batteryType" placeholder="请选择" clearable style="width: 140px">
                        <el-option v-for="b in batteryOptions" :key="b" :label="b" :value="b" />
                    </el-select>
                </el-form-item>
                <el-form-item label="排序">
                    <el-select v-model="filters.sort" style="width: 120px">
                        <el-option label="默认" value="id" />
                        <el-option label="价格" value="price" />
                        <el-option label="续航" value="range" />
                    </el-select>
                    <el-select v-model="filters.order" style="width: 100px">
                        <el-option label="升序" value="asc" />
                        <el-option label="降序" value="desc" />
                    </el-select>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="loadVehicles">搜索</el-button>
                    <el-button @click="reset">重置</el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <el-row :gutter="16" class="mb16">
            <el-col :span="18">
                <el-card shadow="never">
                    <div slot="header" class="card-header">
                        车型列表
                        <span class="tip">点击卡片查看详情，下单或评价</span>
                    </div>
                    <el-skeleton v-if="loading.vehicles" animated rows="4" />
                    <el-empty v-else-if="vehicleList.length === 0" description="暂无车型" />
                    <el-row v-else :gutter="12">
                        <el-col v-for="item in vehicleList" :key="item.id" :span="8" class="mb12">
                            <el-card :body-style="{ padding: '12px' }" class="vehicle-card"
                                @click="openDetail(item.id)">
                                <div class="title">
                                    <span>{{ item.brand }} {{ item.name }}</span>
                                    <el-tag v-if="item.stock !== null && item.stock <= 5" type="danger"
                                        size="mini">库存紧张</el-tag>
                                </div>
                                <div class="price">指导价：{{ fmtPrice(item.guidePrice) }}</div>
                                <div class="desc">续航 {{ item.rangeKm }}km · {{ item.batteryType }}</div>
                                <div class="desc">智驾：{{ item.smartDriveLevel || '—' }}</div>
                                <div class="actions">
                                    <el-button size="mini" type="primary"
                                        @click.stop="addCompare(item)">加入对比</el-button>
                                    <el-button size="mini" @click.stop="subscribe(item)">库存提醒</el-button>
                                    <el-button size="mini" type="text"
                                        @click.stop="openDetail(item.id)">查看详情</el-button>
                                </div>
                            </el-card>
                        </el-col>
                    </el-row>
                </el-card>
            </el-col>
            <el-col :span="6">
                <el-card shadow="never" class="mb16">
                    <div slot="header" class="card-header">对比栏</div>
                    <el-tag v-for="v in compareList" :key="v.id" closable @close="removeCompare(v)" class="mr8 mb8">
                        {{ v.brand }} {{ v.name }}
                    </el-tag>
                    <div class="mt8">
                        <el-button type="primary" size="mini" :disabled="compareList.length < 2"
                            @click="doCompare">开始对比</el-button>
                    </div>
                    <el-table v-if="compareResult.length" :data="compareResult" size="mini" border class="mt8">
                        <el-table-column prop="name" label="车型" />
                        <el-table-column prop="rangeKm" label="续航" />
                        <el-table-column prop="batteryType" label="电池" />
                        <el-table-column label="价格">
                            <template slot-scope="scope">{{ fmtPrice(scope.row.guidePrice) }}</template>
                        </el-table-column>
                    </el-table>
                </el-card>
                <el-card shadow="never">
                    <div slot="header" class="card-header">为你推荐</div>
                    <el-empty v-if="recommendList.length === 0" description="暂无推荐" />
                    <el-timeline v-else>
                        <el-timeline-item v-for="rec in recommendList" :key="rec.id" :timestamp="rec.brand">
                            <div class="rec-item" @click="openDetail(rec.id)">
                                <div class="name">{{ rec.name }}</div>
                                <div class="meta">{{ rec.rangeKm }}km · {{ fmtPrice(rec.guidePrice) }}</div>
                            </div>
                        </el-timeline-item>
                    </el-timeline>
                </el-card>
            </el-col>
        </el-row>

        <el-card shadow="never" class="mb16">
            <div slot="header" class="card-header">我的订单与试驾</div>
            <el-row :gutter="16">
                <el-col :span="12">
                    <el-table :data="orderList" size="small" border>
                        <el-table-column prop="orderNo" label="订单编号" width="140" />
                        <el-table-column prop="vehicleId" label="车型ID" width="80" />
                        <el-table-column label="车型名称" width="150">
                            <template slot-scope="scope">{{ getVehicleName(scope.row.vehicleId) }}</template>
                        </el-table-column>
                        <el-table-column prop="quantity" label="数量" width="60" />
                        <el-table-column prop="status" label="状态" width="90" />
                        <el-table-column label="金额">
                            <template slot-scope="scope">{{ fmtPrice(scope.row.totalAmount) }}</template>
                        </el-table-column>
                        <el-table-column label="操作" width="140">
                            <template slot-scope="scope">
                                <el-button v-if="scope.row.status === 'WAIT_PAY'" type="text" size="mini"
                                    @click="cancel(scope.row)">取消</el-button>
                            </template>
                        </el-table-column>
                    </el-table>
                </el-col>
                <el-col :span="12">
                    <el-table :data="testDriveList" size="small" border>
                        <el-table-column prop="vehicleId" label="车型ID" width="80" />
                        <el-table-column label="车型名称" width="150">
                            <template slot-scope="scope">{{ getVehicleName(scope.row.vehicleId) }}</template>
                        </el-table-column>
                        <el-table-column prop="store" label="门店" />
                        <el-table-column prop="scheduleTime" label="预约时间" />
                        <el-table-column prop="status" label="状态" width="100" />
                    </el-table>
                </el-col>
            </el-row>
        </el-card>

        <el-card shadow="never">
            <div slot="header" class="card-header">个人信息</div>
            <el-form :model="profile" label-width="80px" size="small" :inline="true">
                <el-form-item label="姓名">
                    <el-input v-model="profile.name" />
                </el-form-item>
                <el-form-item label="手机号">
                    <el-input v-model="profile.phone" />
                </el-form-item>
                <el-form-item label="地址">
                    <el-input v-model="profile.address" />
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="saveProfileInfo">保存</el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <el-drawer :visible.sync="detailVisible" title="车型详情" size="50%" :destroy-on-close="true">
            <div v-if="detail">
                <div class="detail-title">{{ detail.vehicle.brand }} {{ detail.vehicle.name }}</div>
                <p>价格：{{ fmtPrice(detail.vehicle.guidePrice) }} | 续航：{{ detail.vehicle.rangeKm }}km | 电池：{{
                    detail.vehicle.batteryType }}</p>
                <p>智驾：{{ detail.vehicle.smartDriveLevel || '—' }} | 快充：{{ detail.vehicle.fastChargeMinutes }} 分钟</p>
                <p>库存：{{ detail.vehicle.stock }}</p>
                <el-tag v-if="detail.lowStock" type="danger">库存紧张</el-tag>
                <h4>促销活动</h4>
                <el-empty v-if="!detail.promotions || detail.promotions.length === 0" description="暂无活动" />
                <el-timeline v-else>
                    <el-timeline-item v-for="p in detail.promotions" :key="p.id" :timestamp="p.title">
                        {{ p.description }}
                    </el-timeline-item>
                </el-timeline>
                <h4>配置参数</h4>
                <el-descriptions :column="2" size="small">
                    <el-descriptions-item v-for="(v, k) in detail.vehicle.configs" :key="k" :label="k">
                        {{ v }}
                    </el-descriptions-item>
                </el-descriptions>
                <h4 class="mt12">下单</h4>
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
                    <el-form-item>
                        <el-button type="primary" @click="submitOrder">立即下单</el-button>
                    </el-form-item>
                </el-form>

                <h4 class="mt12">评价</h4>
                <el-form :model="reviewForm" label-width="90px" size="small">
                    <el-form-item label="评分">
                        <el-rate v-model="reviewForm.rating" />
                    </el-form-item>
                    <el-form-item label="评价内容">
                        <el-input type="textarea" v-model="reviewForm.comment" />
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

                <h4 class="mt12">预约试驾</h4>
                <el-form :model="testDriveForm" label-width="90px" size="small" inline>
                    <el-form-item label="门店">
                        <el-input v-model="testDriveForm.store" placeholder="如 上海浦东店" />
                    </el-form-item>
                    <el-form-item label="时间">
                        <el-date-picker v-model="testDriveForm.scheduleTime" type="datetime" placeholder="选择时间"
                            value-format="yyyy-MM-dd HH:mm:ss" />
                    </el-form-item>
                    <el-form-item>
                        <el-button size="small" type="primary" @click="submitTestDrive">提交预约</el-button>
                    </el-form-item>
                </el-form>
            </div>
        </el-drawer>
    </div>
</template>

<script>
import { mapGetters } from 'vuex'
import {
    searchVehicles,
    vehicleDetail,
    compareVehicles,
    recommendVehicles,
    createOrder,
    listOrders,
    cancelOrder,
    listReviews,
    addReview,
    createTestDrive,
    listTestDrives,
    subscribeInventory,
    saveProfile,
    getProfile
} from '@/api/ev'

export default {
    name: 'EvCustomer',
    data() {
        return {
            filters: {
                brand: '',
                minPrice: null,
                maxPrice: null,
                minRange: null,
                maxRange: null,
                batteryType: '',
                sort: 'id',
                order: 'asc'
            },
            batteryOptions: ['三元锂', '磷酸铁锂', '其他'],
            vehicleList: [],
            vehicleMap: {}, // 车型ID到车型名称的映射
            compareList: [],
            compareResult: [],
            recommendList: [],
            detailVisible: false,
            detail: null,
            reviews: [],
            orderForm: {
                store: '',
                quantity: 1,
                contactName: '',
                contactPhone: ''
            },
            reviewForm: {
                rating: 5,
                comment: ''
            },
            testDriveForm: {
                store: '',
                scheduleTime: ''
            },
            orderList: [],
            testDriveList: [],
            profile: {
                name: '',
                phone: '',
                address: ''
            },
            loading: {
                vehicles: false
            }
        }
    },
    computed: {
        ...mapGetters({
            userId: 'user/getUserId'
        })
    },
    created() {
        this.loadAllVehicles()
        this.loadRecommend()
        this.loadOrders()
        this.loadTestDrives()
        this.loadProfile()
    },
    methods: {
        fmtPrice(val) {
            if (val === null || val === undefined) return '--'
            const num = Number(val) / 10000
            return num.toFixed(2) + ' 万'
        },
        reset() {
            this.filters = { brand: '', minPrice: null, maxPrice: null, minRange: null, maxRange: null, batteryType: '', sort: 'id', order: 'asc' }
            this.loadVehicles()
        },
        async loadAllVehicles() {
            try {
                const res = await searchVehicles({})
                if (res.status) {
                    const allVehicles = res.data || []
                    // 更新车型映射
                    allVehicles.forEach(vehicle => {
                        this.vehicleMap[vehicle.id] = `${vehicle.brand} ${vehicle.name}`
                    })
                }
            } catch (error) {
                console.error('获取车型列表失败:', error)
            }
        },
        async loadVehicles() {
            this.loading.vehicles = true
            try {
                const res = await searchVehicles({
                    ...this.filters,
                    minPrice: this.filters.minPrice ? this.filters.minPrice * 10000 : null,
                    maxPrice: this.filters.maxPrice ? this.filters.maxPrice * 10000 : null,
                    minRange: this.filters.minRange > 0 ? this.filters.minRange : null,
                    maxRange: this.filters.maxRange > 0 ? this.filters.maxRange : null
                })
                if (res.status) {
                    this.vehicleList = res.data || []
                }
            } finally {
                this.loading.vehicles = false
            }
        },
        getVehicleName(vehicleId) {
            return this.vehicleMap[vehicleId] || '未知车型'
        },
        async loadRecommend() {
            if (!this.userId) return
            const res = await recommendVehicles(this.userId)
            if (res.status) this.recommendList = res.data || []
        },
        addCompare(item) {
            if (this.compareList.find(v => v.id === item.id)) return
            if (this.compareList.length >= 3) {
                this.$message.warning('最多对比 3 款车型')
                return
            }
            this.compareList.push(item)
        },
        removeCompare(item) {
            this.compareList = this.compareList.filter(v => v.id !== item.id)
        },
        async doCompare() {
            const ids = this.compareList.map(v => v.id)
            const res = await compareVehicles(ids)
            if (res.status) {
                this.compareResult = res.data || []
            }
        },
        async openDetail(id) {
            this.$router.push({ name: 'evDetail', params: { id } })
        },
        async loadReviews(vehicleId) {
            const res = await listReviews(vehicleId)
            if (res.status) this.reviews = res.data || []
        },
        async submitOrder() {
            const payload = { ...this.orderForm, userId: this.userId, vehicleId: this.detail.vehicle.id }
            const res = await createOrder(payload)
            if (res.status) {
                this.$message.success('下单成功')
                this.loadOrders()
                this.loadVehicles()
            }
        },
        async loadOrders() {
            if (!this.userId) return
            const res = await listOrders(this.userId)
            if (res.status) this.orderList = res.data || []
        },
        async cancel(order) {
            const res = await cancelOrder(order.id, this.userId)
            if (res.status) {
                this.$message.success('已取消')
                this.loadOrders()
                this.loadVehicles()
            }
        },
        async submitReview() {
            const completed = this.orderList.find(o => o.vehicleId === this.detail.vehicle.id && o.status === 'COMPLETED')
            if (!completed) {
                this.$message.error('只有已提车的订单才能评价')
                return
            }
            const payload = {
                ...this.reviewForm,
                userId: this.userId,
                orderId: completed.id
            }
            const res = await addReview(payload)
            if (res.status) {
                this.$message.success('评价成功')
                this.loadReviews(this.detail.vehicle.id)
            }
        },
        async submitTestDrive() {
            const payload = { ...this.testDriveForm, userId: this.userId, vehicleId: this.detail.vehicle.id }
            const res = await createTestDrive(payload)
            if (res.status) {
                this.$message.success('已提交预约')
                this.loadTestDrives()
            }
        },
        async loadTestDrives() {
            if (!this.userId) return
            const res = await listTestDrives(this.userId)
            if (res.status) this.testDriveList = res.data || []
        },
        async subscribe(item) {
            const res = await subscribeInventory(this.userId, item.id)
            if (res.status) this.$message.success('已订阅库存提醒')
        },
        async saveProfileInfo() {
            const res = await saveProfile({ ...this.profile, id: this.userId })
            if (res.status) this.$message.success('已保存')
        },
        async loadProfile() {
            if (!this.userId) return
            const res = await getProfile(this.userId)
            if (res.status && res.data) {
                this.profile = { ...this.profile, ...res.data }
            }
        }
    }
}
</script>

<style lang="less" scoped>
.ev-customer {
    .card-header {
        font-weight: 600;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .tip {
        color: #909399;
        font-weight: 400;
        font-size: 12px;
    }

    .vehicle-card {
        cursor: pointer;

        .title {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-weight: 600;
            margin-bottom: 6px;
        }

        .price {
            color: #e67e22;
            margin-bottom: 4px;
        }

        .desc {
            color: #606266;
            font-size: 12px;
            margin-bottom: 2px;
        }

        .actions {
            margin-top: 6px;
            display: flex;
            gap: 8px;
        }
    }

    .dash {
        margin: 0 6px;
        color: #909399;
    }

    .rec-item {
        cursor: pointer;

        .name {
            font-weight: 600;
        }

        .meta {
            color: #606266;
            font-size: 12px;
        }
    }

    .mb12 {
        margin-bottom: 12px;
    }

    .mb16 {
        margin-bottom: 16px;
    }

    .mr8 {
        margin-right: 8px;
    }

    .mt8 {
        margin-top: 8px;
    }

    .mt12 {
        margin-top: 12px;
    }
}
</style>
