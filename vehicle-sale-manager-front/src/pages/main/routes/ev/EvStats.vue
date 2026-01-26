<template>
  <div class="ev-stats">
    <el-form :inline="true" size="small" class="mb12">
      <el-form-item label="开始日期">
        <el-date-picker v-model="statRange.start" type="date" placeholder="开始" value-format="yyyy-MM-dd" />
      </el-form-item>
      <el-form-item label="结束日期">
        <el-date-picker v-model="statRange.end" type="date" placeholder="结束" value-format="yyyy-MM-dd" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="loadStats">统计</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="16" class="mb16">
      <el-col :span="6">
        <el-card>
          <div class="stat-item">
            <div class="stat-label">总订单</div>
            <div class="stat-value">{{ statsData.totalOrders || 0 }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card>
          <div class="stat-item">
            <div class="stat-label">销售额</div>
            <div class="stat-value">{{ fmtPrice(statsData.totalAmount) }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card>
          <div class="stat-item">
            <div class="stat-label">新增用户</div>
            <div class="stat-value">{{ statsData.newUsers || 0 }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card>
          <div class="stat-item">
            <div class="stat-label">TOP5车型</div>
            <div class="stat-value">{{ statsData.top5Vehicles ? statsData.top5Vehicles.length : 0 }}</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="16">
      <el-col :span="12">
        <el-card>
          <div slot="header">销量TOP5车型</div>
          <el-table v-if="statsData.top5Vehicles" :data="statsData.top5Vehicles" size="small" border>
            <el-table-column label="车型" width="200">
              <template slot-scope="scope">{{ scope.row.vehicle ? scope.row.vehicle.brand + ' ' + scope.row.vehicle.name : '' }}</template>
            </el-table-column>
            <el-table-column prop="qty" label="销量" width="80" />
            <el-table-column prop="amount" label="销售额">
              <template slot-scope="scope">{{ fmtPrice(scope.row.amount) }}</template>
            </el-table-column>
          </el-table>
          <div v-else class="empty-tip">暂无数据</div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card>
          <div slot="header">品牌销售占比</div>
          <el-table v-if="statsData.brandShare" :data="formatShareData(statsData.brandShare)" size="small" border>
            <el-table-column prop="brand" label="品牌" />
            <el-table-column prop="count" label="订单数" width="100" />
            <el-table-column prop="percentage" label="占比" width="100">
              <template slot-scope="scope">{{ scope.row.percentage }}%</template>
            </el-table-column>
          </el-table>
          <div v-else class="empty-tip">暂无数据</div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="16" class="mt16">
      <el-col :span="12">
        <el-card>
          <div slot="header">续航里程销售占比</div>
          <el-table v-if="statsData.rangeShare" :data="formatShareData(statsData.rangeShare)" size="small" border>
            <el-table-column prop="brand" label="续航范围" />
            <el-table-column prop="count" label="订单数" width="100" />
            <el-table-column prop="percentage" label="占比" width="100">
              <template slot-scope="scope">{{ scope.row.percentage }}%</template>
            </el-table-column>
          </el-table>
          <div v-else class="empty-tip">暂无数据</div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import { stats } from '@/api/ev'

export default {
  name: 'EvStats',
  data () {
    return {
      statsData: {},
      statRange: { start: '', end: '' }
    }
  },
  created () {
    this.loadStats()
  },
  methods: {
    fmtPrice (val) {
      if (val === null || val === undefined) return '--'
      const num = Number(val) / 10000
      return num.toFixed(2) + ' 万'
    },
    formatShareData (shareMap) {
      if (!shareMap) return []
      const total = Object.values(shareMap).reduce((sum, val) => sum + Number(val), 0)
      return Object.entries(shareMap).map(([key, value]) => ({
        brand: key,
        count: value,
        percentage: total > 0 ? ((Number(value) / total) * 100).toFixed(2) : '0.00'
      })).sort((a, b) => b.count - a.count)
    },
    async loadStats () {
      const res = await stats(this.statRange.start, this.statRange.end)
      if (res.status) this.statsData = res.data || {}
    }
  }
}
</script>

<style lang="less" scoped>
.ev-stats {
  .mb12 { margin-bottom: 12px; }
  .mb16 { margin-bottom: 16px; }
  .mt16 { margin-top: 16px; }
  .stat-item {
    text-align: center;
    .stat-label {
      font-size: 14px;
      color: #666;
      margin-bottom: 8px;
    }
    .stat-value {
      font-size: 24px;
      font-weight: bold;
      color: #1890ff;
    }
  }
  .empty-tip {
    text-align: center;
    padding: 40px;
    color: #999;
  }
}
</style>

