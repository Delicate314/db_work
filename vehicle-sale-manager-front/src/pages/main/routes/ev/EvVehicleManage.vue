<template>
  <div class="ev-vehicle-manage">
    <div class="mb12">
      <el-button type="primary" size="small" @click="openVehicleDialog()">新增车型</el-button>
      <el-button size="small" @click="loadVehicles">刷新</el-button>
      <el-button size="small" @click="loadLowStock">低库存</el-button>
    </div>
    <el-table :data="vehicleList" size="small" border>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="brand" label="品牌" width="100" />
      <el-table-column prop="name" label="名称" />
      <el-table-column prop="rangeKm" label="续航" width="90" />
      <el-table-column prop="batteryType" label="电池" width="110" />
      <el-table-column label="指导价">
        <template slot-scope="scope">{{ fmtPrice(scope.row.guidePrice) }}</template>
      </el-table-column>
      <el-table-column prop="stock" label="库存" width="80" />
      <el-table-column label="操作" width="200">
        <template slot-scope="scope">
          <el-button type="text" size="mini" @click="openVehicleDialog(scope.row)">编辑</el-button>
          <el-button type="text" size="mini" @click="restock(scope.row)">补货</el-button>
          <el-popconfirm title="确认删除？" @confirm="removeVehicle(scope.row)">
            <el-button slot="reference" type="text" size="mini">删除</el-button>
          </el-popconfirm>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog :visible.sync="vehicleDialog.visible" :title="vehicleDialog.form.id ? '编辑车型' : '新增车型'" width="640px">
      <el-form :model="vehicleDialog.form" label-width="100px" size="small">
        <el-form-item label="品牌">
          <el-input v-model="vehicleDialog.form.brand" />
        </el-form-item>
        <el-form-item label="名称">
          <el-input v-model="vehicleDialog.form.name" />
        </el-form-item>
        <el-form-item label="指导价(元)">
          <el-input-number v-model="vehicleDialog.form.guidePrice" :min="0" :step="1000" style="width: 200px" />
        </el-form-item>
        <el-form-item label="续航(km)">
          <el-input-number v-model="vehicleDialog.form.rangeKm" :min="0" :step="10" />
        </el-form-item>
        <el-form-item label="电池类型">
          <el-input v-model="vehicleDialog.form.batteryType" />
        </el-form-item>
        <el-form-item label="库存">
          <el-input-number v-model="vehicleDialog.form.stock" :min="0" />
        </el-form-item>
        <el-form-item label="智驾等级">
          <el-input v-model="vehicleDialog.form.smartDriveLevel" />
        </el-form-item>
        <el-form-item label="快充(分钟)">
          <el-input-number v-model="vehicleDialog.form.fastChargeMinutes" :min="0" />
        </el-form-item>
        <el-form-item label="上市时间">
          <el-date-picker v-model="vehicleDialog.form.launchDate" type="date" placeholder="选择日期" value-format="yyyy-MM-dd" style="width: 200px" />
        </el-form-item>
      </el-form>
      <span slot="footer">
        <el-button @click="vehicleDialog.visible = false">取消</el-button>
        <el-button type="primary" @click="saveVehicle">保存</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import {
  searchVehicles,
  createVehicle,
  updateVehicle,
  deleteVehicle,
  restockVehicle,
  lowStockVehicles
} from '@/api/ev'

export default {
  name: 'EvVehicleManage',
  data () {
    return {
      vehicleList: [],
      vehicleDialog: {
        visible: false,
        form: {}
      }
    }
  },
  created () {
    this.loadVehicles()
  },
  methods: {
    fmtPrice (val) {
      if (val === null || val === undefined) return '--'
      const num = Number(val) / 10000
      return num.toFixed(2) + ' 万'
    },
    async loadVehicles () {
      const res = await searchVehicles({})
      if (res.status) this.vehicleList = res.data || []
    },
    async loadLowStock () {
      const res = await lowStockVehicles()
      if (res.status) this.vehicleList = res.data || []
    },
    openVehicleDialog (row) {
      this.vehicleDialog.form = row ? { ...row } : { brand: '', name: '', guidePrice: 0, rangeKm: 0, batteryType: '', stock: 0, launchDate: null }
      this.vehicleDialog.visible = true
    },
    async saveVehicle () {
      const data = { ...this.vehicleDialog.form }
      const res = data.id ? await updateVehicle(data.id, data) : await createVehicle(data)
      if (res.status) {
        this.$message.success('保存成功')
        this.vehicleDialog.visible = false
        this.loadVehicles()
      }
    },
    async restock (row) {
      this.$prompt('请输入补货数量', '补货', {
        confirmButtonText: '确定',
        cancelButtonText: '取消'
      }).then(async ({ value }) => {
        const delta = Number(value)
        if (!delta) return
        const res = await restockVehicle(row.id, delta)
        if (res.status) {
          this.$message.success('补货完成')
          this.loadVehicles()
        }
      }).catch(() => {})
    },
    async removeVehicle (row) {
      const res = await deleteVehicle(row.id)
      if (res.status) {
        this.$message.success('删除成功')
        this.loadVehicles()
      }
    }
  }
}
</script>

<style lang="less" scoped>
.ev-vehicle-manage {
  .mb12 { margin-bottom: 12px; }
}
</style>

