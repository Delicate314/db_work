<template>
  <div class="ev-user-manage">
    <div class="mb12">
      <el-button type="primary" size="small" @click="openUserDialog()">新增用户</el-button>
      <el-button size="small" @click="loadUsers">刷新</el-button>
    </div>
    <el-table :data="userList" size="small" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="name" label="姓名" />
      <el-table-column prop="phone" label="手机号" />
      <el-table-column prop="idNumber" label="身份证号" />
      <el-table-column prop="address" label="地址" />
      <el-table-column prop="registerTime" label="注册时间" width="170">
        <template slot-scope="scope">{{ formatDate(scope.row.registerTime) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="280">
        <template slot-scope="scope">
          <el-button type="text" size="mini" @click="openUserDialog(scope.row)">编辑</el-button>
          <el-button type="text" size="mini" @click="viewOrders(scope.row)">购车记录</el-button>
          <el-button type="text" size="mini" @click="viewBrowseHistory(scope.row)">浏览偏好</el-button>
          <el-popconfirm title="确认删除？" @confirm="removeUser(scope.row)">
            <el-button slot="reference" type="text" size="mini">删除</el-button>
          </el-popconfirm>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog :visible.sync="userDialog.visible" :title="userDialog.form.id ? '编辑用户' : '新增用户'" width="600px">
      <el-form :model="userDialog.form" label-width="100px" size="small">
        <el-form-item label="姓名">
          <el-input v-model="userDialog.form.name" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="userDialog.form.phone" />
        </el-form-item>
        <el-form-item label="身份证号">
          <el-input v-model="userDialog.form.idNumber" />
        </el-form-item>
        <el-form-item label="地址">
          <el-input v-model="userDialog.form.address" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <span slot="footer">
        <el-button @click="userDialog.visible = false">取消</el-button>
        <el-button type="primary" @click="saveUser">保存</el-button>
      </span>
    </el-dialog>

    <el-dialog :visible.sync="ordersDialog.visible" title="购车记录" width="900px">
      <el-table :data="ordersDialog.orders" size="small" border>
        <el-table-column prop="orderNo" label="订单号" width="140" />
        <el-table-column prop="vehicleId" label="车型ID" width="90" />
        <el-table-column prop="quantity" label="数量" width="70" />
        <el-table-column prop="status" label="状态" width="110" />
        <el-table-column prop="createdAt" label="下单时间" width="160">
          <template slot-scope="scope">{{ formatDate(scope.row.createdAt) }}</template>
        </el-table-column>
        <el-table-column label="金额">
          <template slot-scope="scope">{{ fmtPrice(scope.row.totalAmount) }}</template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <el-dialog :visible.sync="browseDialog.visible" title="浏览偏好" width="700px">
      <div class="mb12">
        <strong>偏好品牌：</strong>
        <el-tag v-for="brand in browseDialog.preferBrands" :key="brand" class="mr8">{{ brand }}</el-tag>
      </div>
      <div class="mb12">
        <strong>偏好电池类型：</strong>
        <el-tag v-for="type in browseDialog.preferBatteryTypes" :key="type" class="mr8">{{ type }}</el-tag>
      </div>
      <el-divider>浏览历史</el-divider>
      <el-table :data="browseDialog.history" size="small" border>
        <el-table-column prop="vehicleId" label="车型ID" width="90" />
        <el-table-column prop="browseTime" label="浏览时间" width="160">
          <template slot-scope="scope">{{ formatDate(scope.row.browseTime) }}</template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script>
import {
  listUsers,
  saveUser,
  deleteUser,
  getUserOrders,
  getUserBrowseHistory
} from '@/api/ev'

export default {
  name: 'EvUserManage',
  data () {
    return {
      userList: [],
      userDialog: {
        visible: false,
        form: {}
      },
      ordersDialog: {
        visible: false,
        orders: []
      },
      browseDialog: {
        visible: false,
        preferBrands: [],
        preferBatteryTypes: [],
        history: []
      }
    }
  },
  created () {
    this.loadUsers()
  },
  methods: {
    formatDate (val) {
      if (!val) return '--'
      return new Date(val).toLocaleString('zh-CN')
    },
    fmtPrice (val) {
      if (val === null || val === undefined) return '--'
      const num = Number(val) / 10000
      return num.toFixed(2) + ' 万'
    },
    async loadUsers () {
      const res = await listUsers()
      if (res.status) this.userList = res.data || []
    },
    openUserDialog (row) {
      this.userDialog.form = row ? { ...row } : { name: '', phone: '', idNumber: '', address: '' }
      this.userDialog.visible = true
    },
    async saveUser () {
      const data = { ...this.userDialog.form }
      const res = await saveUser(data)
      if (res.status) {
        this.$message.success('保存成功')
        this.userDialog.visible = false
        this.loadUsers()
      }
    },
    async removeUser (row) {
      const res = await deleteUser(row.id)
      if (res.status) {
        this.$message.success('删除成功')
        this.loadUsers()
      }
    },
    async viewOrders (row) {
      const res = await getUserOrders(row.id)
      if (res.status) {
        this.ordersDialog.orders = res.data || []
        this.ordersDialog.visible = true
      }
    },
    async viewBrowseHistory (row) {
      const res = await getUserBrowseHistory(row.id)
      if (res.status) {
        this.browseDialog.history = res.data || []
        // 从用户信息中获取偏好
        this.browseDialog.preferBrands = row.preferBrands || []
        this.browseDialog.preferBatteryTypes = row.preferBatteryTypes || []
        this.browseDialog.visible = true
      }
    }
  }
}
</script>

<style lang="less" scoped>
.ev-user-manage {
  .mb12 { margin-bottom: 12px; }
  .mr8 { margin-right: 8px; }
}
</style>

