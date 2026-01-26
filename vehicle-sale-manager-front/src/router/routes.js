const loginPage = [
  {
    path: '/login',
    name: 'login',
    component: () =>
      import(/* webpackChunkName: "Login" */ '../pages/login/Login')
  }
]

const mainPage = [
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/main',
    name: 'main',
    component: () =>
      import(/* webpackChunkName: "Main" */ '../pages/main/Main'),
    // 统一改为新能源汽车相关子路由
    children: [
      {
        path: 'ev-customer',
        name: 'evCustomer',
        component: () =>
          import(
            /* webpackChunkName: "EvCustomer" */ '../pages/main/routes/ev/EvCustomer'
          )
      },
      {
        path: 'ev-vehicle-manage',
        name: 'evVehicleManage',
        component: () =>
          import(
            /* webpackChunkName: "EvVehicleManage" */ '../pages/main/routes/ev/EvVehicleManage'
          )
      },
      {
        path: 'ev-promotion-finance',
        name: 'evPromotionFinance',
        component: () =>
          import(
            /* webpackChunkName: "EvPromotionFinance" */ '../pages/main/routes/ev/EvPromotionFinance'
          )
      },
      {
        path: 'ev-order-manage',
        name: 'evOrderManage',
        component: () =>
          import(
            /* webpackChunkName: "EvOrderManage" */ '../pages/main/routes/ev/EvOrderManage'
          )
      },
      {
        path: 'ev-testdrive-audit',
        name: 'evTestDriveAudit',
        component: () =>
          import(
            /* webpackChunkName: "EvTestDriveAudit" */ '../pages/main/routes/ev/EvTestDriveAudit'
          )
      },
      {
        path: 'ev-user-manage',
        name: 'evUserManage',
        component: () =>
          import(
            /* webpackChunkName: "EvUserManage" */ '../pages/main/routes/ev/EvUserManage'
          )
      },
      {
        path: 'ev-stats',
        name: 'evStats',
        component: () =>
          import(
            /* webpackChunkName: "EvStats" */ '../pages/main/routes/ev/EvStats'
          )
      },
      {
        path: 'ev-detail/:id',
        name: 'evDetail',
        component: () =>
          import(
            /* webpackChunkName: "EvVehicleDetail" */ '../pages/main/routes/ev/EvVehicleDetail'
          )
      }
    ]
  }
]

const errorPage = [
  {
    path: '/notFound',
    name: 'notFound',
    component: () =>
      import(/* webpackChunkName: "NotFound" */ '../pages/error/NotFound')
  },
  {
    path: '/forbidden',
    name: 'forbidden',
    component: () =>
      import(/* webpackChunkName: "Forbidden" */ '../pages/error/Forbidden')
  },
  {
    path: '/badGateway',
    name: 'badGateway',
    component: () =>
      import(/* webpackChunkName: "BadGateway" */ '../pages/error/BadGateway')
  },
  {
    path: '*',
    redirect: '/notFound'
  }
]
export default [...loginPage, ...mainPage, ...errorPage]
