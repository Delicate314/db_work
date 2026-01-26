<template>
  <div class="ev-order-manage">
    <el-table :data="orderList" size="small" border>
      <el-table-column prop="orderNo" label="订单号" width="140" />
      <el-table-column prop="userId" label="用户" width="80" />
      <el-table-column prop="vehicleId" label="车型ID" width="90" />
      <el-table-column prop="quantity" label="数量" width="70" />
      <el-table-column prop="status" label="状态" width="110" />
      <el-table-column prop="createdAt" label="下单时间" width="160">
        <template slot-scope="scope">{{ formatDate(scope.row.createdAt) }}</template>
      </el-table-column>
      <el-table-column label="金额">
        <template slot-scope="scope">{{ fmtPrice(scope.row.totalAmount) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="180">
        <template slot-scope="scope">
          <el-button v-if="scope.row.status === 'WAIT_PAY'" type="text" size="mini" @click="markPaid(scope.row)">确认支付</el-button>
          <el-button v-if="scope.row.status === 'WAIT_PICKUP' || scope.row.status === 'PAID'" type="text" size="mini" @click="markPickup(scope.row)">标记提车</el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script>
import {
  adminOrders,
  markOrderPaid,
  markOrderPickup
} from '@/api/ev'

export default {
  name: 'EvOrderManage',
  data () {
    return {
      orderList: []
    }
  },
  created () {
    this.loadOrders()
  },
  methods: {
    fmtPrice (val) {
      if (val === null || val === undefined) return '--'
      const num = Number(val) / 10000
      return num.toFixed(2) + ' 万'
    },
    formatDate (val) {
      if (!val) return '--'
      return new Date(val).toLocaleString('zh-CN')
    },
    async loadOrders () {
      const res = await adminOrders()
      if (res.status) this.orderList = res.data || []
    },
    async markPaid (row) {
      const res = await markOrderPaid(row.id)
      if (res.status) {
        this.$message.success('已确认支付')
        this.loadOrders()
      }
    },
    async markPickup (row) {
      const res = await markOrderPickup(row.id)
      if (res.status) {
        this.$message.success('已标记提车')
        this.loadOrders()
      }
    }
  }
}
</script>

<style lang="less" scoped>
.ev-order-manage {
}
</style>

