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
        path: 'ev-admin',
        name: 'evAdmin',
        component: () =>
          import(
            /* webpackChunkName: "EvAdmin" */ '../pages/main/routes/ev/EvAdmin'
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
