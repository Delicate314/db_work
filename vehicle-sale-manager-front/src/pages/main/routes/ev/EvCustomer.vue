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
                        <el-col v-for="item in vehicleList" :key="item.id" :span="12" class="mb12">
                            <el-card :body-style="{ padding: '12px' }" class="vehicle-card"
                                @click="openDetail(item.id)">
                                <div class="card-content">
                                    <div class="text-content">
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
                                    </div>
                                    <!-- 车型预览图 -->
                                    <div class="vehicle-image">
                                        <img :src="getVehicleImage(item)" :alt="item.brand + item.name"
                                            class="preview-image">
                                    </div>
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
                        <el-table-column prop="store" label="门店" />
                        <el-table-column prop="scheduleTime" label="预约时间" />
                        <el-table-column prop="status" label="状态" width="100" />
                    </el-table>
                </el-col>
            </el-row>
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
                        <el-select v-model="testDriveForm.store" placeholder="请选择门店" filterable style="width: 200px">
                            <el-option
                                v-for="store in storeList"
                                :key="store"
                                :label="store"
                                :value="store">
                            </el-option>
                        </el-select>
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
    subscribeInventory
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
            vehicleList: [],
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
        this.loadVehicles()
        this.loadRecommend()
        this.loadOrders()
        this.loadTestDrives()
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
        async loadVehicles() {
            this.loading.vehicles = true
            try {
                const res = await searchVehicles({
                    brand: this.filters.brand,
                    minPrice: this.filters.minPrice ? this.filters.minPrice * 10000 : null,
                    maxPrice: this.filters.maxPrice ? this.filters.maxPrice * 10000 : null,
                    minRange: this.filters.minRange > 0 ? this.filters.minRange : null,
                    maxRange: this.filters.maxRange > 0 ? this.filters.maxRange : null,
                    batteryType: this.filters.batteryType,
                    sort: this.filters.sort,
                    order: this.filters.order
                })
                if (res.status) {
                    this.vehicleList = res.data || []
                }
            } finally {
                this.loading.vehicles = false
            }
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
            const payload = {
                ...this.reviewForm,
                userId: this.userId,
                orderId: completed ? completed.id : null
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
        getVehicleImage(item) {
            if (!item) return ''
            const { brand, name } = item
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
            // 调试：如果图片加载失败，可以在控制台查看实际的key值
            if (!vehicleImages[key] && (brand === '华为' || name && name.includes('问界'))) {
                console.log('车辆图片映射调试 - brand:', brand, 'name:', name, 'key:', key)
            }
            if (vehicleImages[key]) {
                return vehicleImages[key]
            }

            // 其他车型使用生成的图片
            const prompt = encodeURIComponent(`${brand} ${name} 外观`)
            return `https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=${prompt}&image_size=square`
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
        height: 180px;
        display: flex;
        flex-direction: column;
        justify-content: space-between;

        .card-content {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            height: 100%;
        }

        .text-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-width: 0;
        }

        .vehicle-image {
            width: 120px;
            height: 120px;
            overflow: hidden;
            border-radius: 4px;
            flex-shrink: 0;
            margin-top: 4px;

            .preview-image {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }
        }

        .title {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-weight: 600;
            margin-bottom: 6px;
            flex-wrap: wrap;
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
            margin-top: 8px;
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
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