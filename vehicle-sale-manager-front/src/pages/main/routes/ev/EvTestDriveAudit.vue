<template>
  <div class="ev-testdrive-audit">
    <el-button size="small" class="mb8" @click="loadTestDrives">刷新</el-button>
    <el-table :data="testDriveList" size="small" border>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="userId" label="用户" width="80" />
      <el-table-column prop="vehicleId" label="车型ID" width="90" />
      <el-table-column prop="store" label="门店" />
      <el-table-column prop="scheduleTime" label="预约时间" width="160" />
      <el-table-column prop="status" label="状态" width="110" />
      <el-table-column label="操作" width="180">
        <template slot-scope="scope">
          <el-button size="mini" type="text" @click="audit(scope.row, 'APPROVED')">通过</el-button>
          <el-button size="mini" type="text" @click="audit(scope.row, 'REJECTED')">拒绝</el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script>
import {
  auditTestDrive,
  adminListTestDrives
} from '@/api/ev'

export default {
  name: 'EvTestDriveAudit',
  data () {
    return {
      testDriveList: []
    }
  },
  created () {
    this.loadTestDrives()
  },
  methods: {
    async loadTestDrives () {
      const res = await adminListTestDrives()
      if (res.status) this.testDriveList = res.data || []
    },
    async audit (row, status) {
      const res = await auditTestDrive(row.id, status, '')
      if (res.status) {
        this.$message.success('操作成功')
        this.loadTestDrives()
      }
    }
  }
}
</script>

<style lang="less" scoped>
.ev-testdrive-audit {
  .mb8 { margin-bottom: 8px; }
}
</style>

