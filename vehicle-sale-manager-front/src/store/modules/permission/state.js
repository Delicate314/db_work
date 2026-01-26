export default {
  whiteList: ['/', 'notFound', 'login', 'forbidden', 'badGateway'],
  permissionMap: {
    1: {
      // 普通用户：只使用新能源汽车选购相关页面
      main: ['evCustomer', 'evDetail']
    },
    2: {
      // 管理员：只使用新能源汽车管理后台
      main: ['evVehicleManage', 'evPromotionFinance', 'evOrderManage', 'evTestDriveAudit', 'evUserManage', 'evStats', 'evDetail']
    },
    3: {
      main: []
    },
    4: {
      main: []
    },
    5: {
      main: []
    },
    6: {
      main: []
    }
  }
}
