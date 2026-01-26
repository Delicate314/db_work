import http from '@http/http'

// 客户端
export const searchVehicles = (params) => http.GET('/api/ev/vehicles', params)
export const vehicleDetail = (id) => http.GET(`/api/ev/vehicles/${id}`)
export const compareVehicles = (ids) => http.POST('/api/ev/compare', ids)
export const getPromotions = (vehicleId) => http.GET('/api/ev/promotions', { vehicleId })
export const createOrder = (data) => http.POST('/api/ev/orders', data)
export const listOrders = (userId) => http.GET('/api/ev/orders', { userId })
export const cancelOrder = (orderId, userId) => http.POST(`/api/ev/orders/${orderId}/cancel`, { userId })
export const addReview = (data) => http.POST('/api/ev/reviews', data)
export const listReviews = (vehicleId) => http.GET('/api/ev/reviews', { vehicleId })
export const createTestDrive = (data) => http.POST('/api/ev/test-drives', data)
export const listTestDrives = (userId) => http.GET('/api/ev/test-drives', { userId })
export const adminListTestDrives = () => http.GET('/api/ev/admin/test-drives')
export const recommendVehicles = (userId) => http.GET('/api/ev/recommendations', { userId })
export const subscribeInventory = (userId, vehicleId) => http.POST('/api/ev/inventory/subscribe', { userId, vehicleId })
export const saveProfile = (profile) => http.POST('/api/ev/profile', profile)
export const getProfile = (userId) => http.GET('/api/ev/profile', { userId })

// 管理端
export const createVehicle = (data) => http.POST('/api/ev/admin/vehicles', data)
export const updateVehicle = (id, data) => http.PUT(`/api/ev/admin/vehicles/${id}`, data)
export const deleteVehicle = (id) => http.DELETE(`/api/ev/admin/vehicles/${id}`)
export const restockVehicle = (id, delta) => http.POST(`/api/ev/admin/vehicles/${id}/restock`, { delta })
export const lowStockVehicles = () => http.GET('/api/ev/admin/vehicles/low-stock')

export const adminOrders = () => http.GET('/api/ev/admin/orders')
export const markOrderPaid = (id) => http.POST(`/api/ev/admin/orders/${id}/pay`)
export const markOrderPickup = (id) => http.POST(`/api/ev/admin/orders/${id}/pickup`)

export const savePromotion = (data) => http.POST('/api/ev/admin/promotions', data)
export const changePromotionStatus = (id, status) => http.POST(`/api/ev/admin/promotions/${id}/status`, { status })

export const listUsers = () => http.GET('/api/ev/admin/users')
export const saveUser = (data) => http.POST('/api/ev/admin/users', data)
export const deleteUser = (id) => http.DELETE(`/api/ev/admin/users/${id}`)
export const getUserOrders = (id) => http.GET(`/api/ev/admin/users/${id}/orders`)
export const getUserBrowseHistory = (id) => http.GET(`/api/ev/admin/users/${id}/browse-history`)

export const stats = (start, end) => http.GET('/api/ev/admin/stats', { start, end })

export const auditTestDrive = (id, status, note) => http.POST(`/api/ev/admin/test-drives/${id}/audit`, { status, note })

export const saveFinancialPlan = (plan) => http.POST('/api/ev/admin/financial-plans', plan)
export const listFinancialPlans = (vehicleId) => http.GET('/api/ev/admin/financial-plans', { vehicleId })
