package com.example.mybatisplus.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.example.mybatisplus.mapper.ev.*;
import com.example.mybatisplus.model.domain.ev.*;
import com.example.mybatisplus.model.domain.ev.enums.OrderStatus;
import com.example.mybatisplus.model.domain.ev.enums.PromotionStatus;
import com.example.mybatisplus.model.domain.ev.enums.TestDriveStatus;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 新能源汽车销售系统：数据库实现（MyBatis-Plus）
 */
@Service
public class EvSaleService {

    private final VehicleMapper vehicleMapper;
    private final PromotionMapper promotionMapper;
    private final OrderRecordMapper orderRecordMapper;
    private final ReviewRecordMapper reviewRecordMapper;
    private final TestDriveRecordMapper testDriveRecordMapper;
    private final UserProfileMapper userProfileMapper;
    private final FinancialPlanMapper financialPlanMapper;
    private final BrowseHistoryMapper browseHistoryMapper;
    private final InventorySubscriptionMapper inventorySubscriptionMapper;

    public EvSaleService(VehicleMapper vehicleMapper,
            PromotionMapper promotionMapper,
            OrderRecordMapper orderRecordMapper,
            ReviewRecordMapper reviewRecordMapper,
            TestDriveRecordMapper testDriveRecordMapper,
            UserProfileMapper userProfileMapper,
            FinancialPlanMapper financialPlanMapper,
            BrowseHistoryMapper browseHistoryMapper,
            InventorySubscriptionMapper inventorySubscriptionMapper) {
        this.vehicleMapper = vehicleMapper;
        this.promotionMapper = promotionMapper;
        this.orderRecordMapper = orderRecordMapper;
        this.reviewRecordMapper = reviewRecordMapper;
        this.testDriveRecordMapper = testDriveRecordMapper;
        this.userProfileMapper = userProfileMapper;
        this.financialPlanMapper = financialPlanMapper;
        this.browseHistoryMapper = browseHistoryMapper;
        this.inventorySubscriptionMapper = inventorySubscriptionMapper;
    }

    // -------------------- 车型 --------------------

    @Transactional
    public Vehicle saveVehicle(Vehicle vehicle) {
        if (vehicle.getId() == null) {
            vehicleMapper.insert(vehicle);
            return vehicle;
        }
        vehicleMapper.updateById(vehicle);
        return vehicleMapper.selectById(vehicle.getId());
    }

    @Transactional
    public Vehicle updateVehicle(Long id, Vehicle payload) {
        Vehicle exist = vehicleMapper.selectById(id);
        if (exist == null) {
            throw new IllegalArgumentException("车辆不存在");
        }
        payload.setId(id);
        vehicleMapper.updateById(payload);
        return vehicleMapper.selectById(id);
    }

    @Transactional
    public void deleteVehicle(Long id) {
        vehicleMapper.deleteById(id);
        promotionMapper.delete(new LambdaQueryWrapper<Promotion>().eq(Promotion::getVehicleId, id));
    }

    public List<Vehicle> listVehicles(String brand, BigDecimal minPrice, BigDecimal maxPrice,
            Integer minRange, Integer maxRange, String batteryType,
            String sortBy, String order) {
        QueryWrapper<Vehicle> qw = new QueryWrapper<>();
        if (StringUtils.hasText(brand))
            if (minPrice != null)
                qw.ge("guide_price", minPrice);
        if (maxPrice != null)
            qw.le("guide_price", maxPrice);
        if (minRange != null && minRange > 0)
            qw.ge("range_km", minRange);
        if (maxRange != null && maxRange > 0)
            qw.le("range_km", maxRange);
        if (StringUtils.hasText(batteryType))
            qw.eq("battery_type", batteryType);

        boolean desc = "desc".equalsIgnoreCase(order);
        if ("price".equalsIgnoreCase(sortBy)) {
            qw.orderBy(true, !desc, "guide_price");
        } else if ("range".equalsIgnoreCase(sortBy)) {
            qw.orderBy(true, !desc, "range_km");
        } else {
            qw.orderBy(true, !desc, "id");
        }
        return vehicleMapper.selectList(qw);
    }

    public VehicleDetail getVehicleDetail(Long vehicleId) {
        Vehicle vehicle = vehicleMapper.selectById(vehicleId);
        if (vehicle == null) {
            throw new IllegalArgumentException("车辆不存在");
        }
        VehicleDetail detail = new VehicleDetail();
        detail.setVehicle(vehicle);
        detail.setPromotions(getActivePromotions(vehicleId));
        detail.setReviews(listReviews(vehicleId));
        detail.setLowStock(vehicle.getStock() != null && vehicle.getStock() <= 5);
        return detail;
    }

    public List<Vehicle> lowStockVehicles() {
        return vehicleMapper.selectList(new LambdaQueryWrapper<Vehicle>().le(Vehicle::getStock, 5));
    }

    @Transactional
    public Vehicle restockVehicle(Long vehicleId, int delta) {
        Vehicle vehicle = vehicleMapper.selectById(vehicleId);
        if (vehicle == null) {
            throw new IllegalArgumentException("车辆不存在");
        }
        Integer before = vehicle.getStock() == null ? 0 : vehicle.getStock();
        vehicle.setStock(before + delta);
        vehicleMapper.updateById(vehicle);
        if (before <= 0 && vehicle.getStock() > 0) {
            inventorySubscriptionMapper.delete(
                    new LambdaQueryWrapper<InventorySubscription>().eq(InventorySubscription::getVehicleId, vehicleId));
        }
        return vehicleMapper.selectById(vehicleId);
    }

    // -------------------- 促销 --------------------

    @Transactional
    public Promotion savePromotion(Promotion promotion) {
        if (promotion.getVehicleId() == null || vehicleMapper.selectById(promotion.getVehicleId()) == null) {
            throw new IllegalArgumentException("需要先选择车型再关联活动");
        }
        if (promotion.getId() == null) {
            promotionMapper.insert(promotion);
            return promotion;
        }
        promotionMapper.updateById(promotion);
        return promotionMapper.selectById(promotion.getId());
    }

    @Transactional
    public Promotion updatePromotionStatus(Long id, PromotionStatus status) {
        Promotion promotion = promotionMapper.selectById(id);
        if (promotion == null) {
            throw new IllegalArgumentException("活动不存在");
        }
        promotion.setStatus(status);
        promotionMapper.updateById(promotion);
        return promotionMapper.selectById(id);
    }

    public List<Promotion> getActivePromotions(Long vehicleId) {
        LocalDate today = LocalDate.now();
        return promotionMapper.selectList(new LambdaQueryWrapper<Promotion>()
                .eq(Promotion::getVehicleId, vehicleId)
                .eq(Promotion::getStatus, PromotionStatus.ONLINE)
                .le(Promotion::getStartDate, today)
                .ge(Promotion::getEndDate, today));
    }

    // -------------------- 订单 --------------------

    @Transactional
    public OrderRecord createOrder(OrderRecord request) {
        Vehicle vehicle = vehicleMapper.selectById(request.getVehicleId());
        if (vehicle == null)
            throw new IllegalArgumentException("车型不存在");
        UserProfile user = userProfileMapper.selectById(request.getUserId());
        if (user == null) {
            // 如果用户个人信息不存在，自动创建一个基本记录
            user = new UserProfile();
            user.setId(request.getUserId());
            user.setRegisterTime(LocalDateTime.now());
            user.setCreateDate(LocalDateTime.now());
            user.setUpdateDate(LocalDateTime.now());
            userProfileMapper.insert(user);
        }

        int qty = request.getQuantity() == null ? 1 : request.getQuantity();
        Integer stock = vehicle.getStock() == null ? 0 : vehicle.getStock();
        if (stock < qty)
            throw new IllegalStateException("库存不足");

        Promotion promotion = choosePromotion(request);
        BigDecimal unitPrice = vehicle.getGuidePrice();
        if (promotion != null && promotion.getDiscountRate() != null) {
            unitPrice = unitPrice.multiply(promotion.getDiscountRate()).setScale(2, RoundingMode.HALF_UP);
        }
        BigDecimal total = unitPrice.multiply(BigDecimal.valueOf(qty));
        if (promotion != null && promotion.getSubsidy() != null) {
            total = total.subtract(promotion.getSubsidy()).max(BigDecimal.ZERO);
        }

        OrderRecord order = new OrderRecord();
        order.setOrderNo(genOrderNo());
        LocalDateTime now = LocalDateTime.now();
        order.setUserId(request.getUserId());
        order.setVehicleId(request.getVehicleId());
        order.setQuantity(qty);
        order.setStore(request.getStore());
        order.setContactName(request.getContactName());
        order.setContactPhone(request.getContactPhone());
        order.setStatus(OrderStatus.WAIT_PAY);
        order.setCreatedAt(now);
        order.setCreateDate(now);
        order.setUpdateDate(now);
        order.setFinancialPlanId(request.getFinancialPlanId());
        order.setRemark(request.getRemark());
        order.setPricePerUnit(unitPrice);
        order.setTotalAmount(total);
        if (promotion != null) {
            order.setPromotionId(promotion.getId());
            order.setPromotionTitle(promotion.getTitle());
        }
        orderRecordMapper.insert(order);

        vehicleMapper.update(null, new LambdaUpdateWrapper<Vehicle>()
                .eq(Vehicle::getId, vehicle.getId())
                .set(Vehicle::getStock, stock - qty));
        return order;
    }

    private String genOrderNo() {
        return "EV" + System.currentTimeMillis() + (int) (Math.random() * 900 + 100);
    }

    private Promotion choosePromotion(OrderRecord request) {
        if (request.getPromotionId() != null) {
            return promotionMapper.selectById(request.getPromotionId());
        }
        List<Promotion> active = getActivePromotions(request.getVehicleId());
        return active.isEmpty() ? null : active.get(0);
    }

    @Transactional
    public OrderRecord cancelOrder(Long orderId, Long userId) {
        OrderRecord order = orderRecordMapper.selectById(orderId);
        if (order == null)
            throw new IllegalArgumentException("订单不存在");
        if (order.getStatus() != OrderStatus.WAIT_PAY)
            throw new IllegalStateException("仅未支付订单可取消");
        if (userId != null && !Objects.equals(userId, order.getUserId()))
            throw new IllegalStateException("只能取消自己的订单");

        order.setStatus(OrderStatus.CANCELLED);
        order.setUpdateDate(LocalDateTime.now());
        orderRecordMapper.updateById(order);
        vehicleMapper.update(null, new LambdaUpdateWrapper<Vehicle>()
                .eq(Vehicle::getId, order.getVehicleId())
                .setSql("stock = stock + " + order.getQuantity()));
        return orderRecordMapper.selectById(orderId);
    }

    @Transactional
    public OrderRecord markPaid(Long orderId) {
        OrderRecord order = orderRecordMapper.selectById(orderId);
        if (order == null)
            throw new IllegalArgumentException("订单不存在");
        if (order.getStatus() == OrderStatus.CANCELLED)
            throw new IllegalStateException("订单已取消");

        order.setStatus(OrderStatus.WAIT_PICKUP);
        LocalDateTime now = LocalDateTime.now();
        order.setPaidAt(now);
        order.setUpdateDate(now);
        orderRecordMapper.updateById(order);
        return orderRecordMapper.selectById(orderId);
    }

    @Transactional
    public OrderRecord markPicked(Long orderId) {
        OrderRecord order = orderRecordMapper.selectById(orderId);
        if (order == null)
            throw new IllegalArgumentException("订单不存在");
        if (order.getStatus() != OrderStatus.WAIT_PICKUP && order.getStatus() != OrderStatus.PAID) {
            throw new IllegalStateException("仅待提车状态可操作");
        }
        order.setStatus(OrderStatus.COMPLETED);
        LocalDateTime now = LocalDateTime.now();
        order.setPickupAt(now);
        order.setUpdateDate(now);
        orderRecordMapper.updateById(order);
        return orderRecordMapper.selectById(orderId);
    }

    public List<OrderRecord> listOrders() {
        return orderRecordMapper
                .selectList(new LambdaQueryWrapper<OrderRecord>().orderByDesc(OrderRecord::getCreatedAt));
    }

    public List<OrderRecord> listOrders(Long userId) {
        return orderRecordMapper.selectList(new LambdaQueryWrapper<OrderRecord>()
                .eq(OrderRecord::getUserId, userId)
                .orderByDesc(OrderRecord::getCreatedAt));
    }

    // -------------------- 评价 --------------------

    @Transactional
    public ReviewRecord addReview(ReviewRecord request) {
        // 检查用户是否有已提车的订单
        int completedOrderCount = orderRecordMapper.selectCount(new LambdaQueryWrapper<OrderRecord>()
                .eq(OrderRecord::getUserId, request.getUserId())
                .eq(OrderRecord::getStatus, OrderStatus.COMPLETED));
        if (completedOrderCount == 0) {
            throw new IllegalStateException("仅已提车用户可评价");
        }

        // 如果提供了orderId，验证订单是否已提车且属于该用户
        if (request.getOrderId() != null) {
            OrderRecord order = orderRecordMapper.selectById(request.getOrderId());
            if (order == null || order.getStatus() != OrderStatus.COMPLETED) {
                throw new IllegalStateException("仅已提车订单可评价");
            }
            if (!Objects.equals(order.getUserId(), request.getUserId())) {
                throw new IllegalStateException("只能评价自己的订单");
            }
            request.setVehicleId(order.getVehicleId());
        }
        // 如果没有提供orderId，直接使用request中的vehicleId
        // 验证vehicleId是否存在
        if (request.getVehicleId() == null || vehicleMapper.selectById(request.getVehicleId()) == null) {
            throw new IllegalArgumentException("车型不存在");
        }
        LocalDateTime now = LocalDateTime.now();
        request.setCreatedAt(now);
        request.setCreateDate(now);
        request.setUpdateDate(now);
        reviewRecordMapper.insert(request);
        return request;
    }

    public List<ReviewRecord> listReviews(Long vehicleId) {
        return reviewRecordMapper.selectList(new LambdaQueryWrapper<ReviewRecord>()
                .eq(ReviewRecord::getVehicleId, vehicleId)
                .orderByDesc(ReviewRecord::getCreatedAt));
    }

    // -------------------- 试驾 --------------------

    @Transactional
    public TestDriveRecord createTestDrive(TestDriveRecord request) {
        if (vehicleMapper.selectById(request.getVehicleId()) == null)
            throw new IllegalArgumentException("车型不存在");
        UserProfile user = userProfileMapper.selectById(request.getUserId());
        if (user == null) {
            // 如果用户个人信息不存在，自动创建一个基本记录
            user = new UserProfile();
            user.setId(request.getUserId());
            user.setRegisterTime(LocalDateTime.now());
            user.setCreateDate(LocalDateTime.now());
            user.setUpdateDate(LocalDateTime.now());
            userProfileMapper.insert(user);
        }
        request.setStatus(TestDriveStatus.PENDING);
        LocalDateTime now = LocalDateTime.now();
        request.setCreatedAt(now);
        request.setCreateDate(now);
        request.setUpdateDate(now);
        testDriveRecordMapper.insert(request);
        return request;
    }

    @Transactional
    public TestDriveRecord reviewTestDrive(Long id, TestDriveStatus status, String note) {
        TestDriveRecord record = testDriveRecordMapper.selectById(id);
        if (record == null)
            throw new IllegalArgumentException("预约不存在");
        record.setStatus(status);
        record.setAdminNote(note);
        record.setUpdateDate(LocalDateTime.now());
        testDriveRecordMapper.updateById(record);
        return testDriveRecordMapper.selectById(id);
    }

    public List<TestDriveRecord> listTestDrives(Long userId) {
        LambdaQueryWrapper<TestDriveRecord> qw = new LambdaQueryWrapper<TestDriveRecord>();
        if (userId != null)
            qw.eq(TestDriveRecord::getUserId, userId);
        return testDriveRecordMapper.selectList(qw);
    }

    // -------------------- 浏览记录 --------------------

    @Transactional
    public void recordBrowse(Long userId, Long vehicleId) {
        BrowseHistory h = new BrowseHistory();
        h.setUserId(userId);
        h.setVehicleId(vehicleId);
        h.setBrowseTime(LocalDateTime.now());
        browseHistoryMapper.insert(h);
    }

    // -------------------- 智能推荐 --------------------

    public List<Vehicle> recommendVehicles(Long userId) {
        List<BrowseHistory> history = browseHistoryMapper.selectList(
                new LambdaQueryWrapper<BrowseHistory>()
                        .eq(BrowseHistory::getUserId, userId)
                        .orderByDesc(BrowseHistory::getBrowseTime)
                        .last("limit 5"));

        Set<Long> excludeIds = new HashSet<>();
        String preferredBrand = null;
        BigDecimal avgPrice = null;
        Integer avgRange = null;

        if (!history.isEmpty()) {
            List<BigDecimal> prices = new ArrayList<>();
            List<Integer> ranges = new ArrayList<>();
            Map<String, Integer> brandCounts = new HashMap<>();

            for (BrowseHistory h : history) {
                Vehicle v = vehicleMapper.selectById(h.getVehicleId());
                if (v != null) {
                    excludeIds.add(v.getId());
                    prices.add(v.getGuidePrice());
                    ranges.add(v.getRangeKm());
                    brandCounts.put(v.getBrand(), brandCounts.getOrDefault(v.getBrand(), 0) + 1);
                }
            }

            if (!brandCounts.isEmpty()) {
                preferredBrand = brandCounts.entrySet().stream()
                        .max(Map.Entry.comparingByValue())
                        .get().getKey();
            }

            if (!prices.isEmpty()) {
                avgPrice = prices.stream().reduce(BigDecimal.ZERO, BigDecimal::add)
                        .divide(BigDecimal.valueOf(prices.size()), 2, RoundingMode.HALF_UP);
            }

            if (!ranges.isEmpty()) {
                avgRange = ranges.stream().reduce(0, Integer::sum) / ranges.size();
            }
        }

        List<Vehicle> recommendations = new ArrayList<>();

        // 1. 推荐相似车型
        if (!excludeIds.isEmpty()) {
            for (Long id : excludeIds) {
                Vehicle vehicle = vehicleMapper.selectById(id);
                if (vehicle != null) {
                    recommendations.addAll(getSimilarVehicles(vehicle, excludeIds));
                }
            }
        }

        // 2. 推荐同品牌车型
        if (StringUtils.hasText(preferredBrand)) {
            recommendations.addAll(getSameBrandVehicles(preferredBrand, excludeIds));
        }

        // 3. 推荐高性价比车型
        recommendations.addAll(getHighValueVehicles());

        // 去重并限制数量
        Set<Long> seen = new HashSet<>();
        List<Vehicle> result = new ArrayList<>();
        for (Vehicle v : recommendations) {
            if (!seen.contains(v.getId())) {
                seen.add(v.getId());
                result.add(v);
                if (result.size() >= 6)
                    break;
            }
        }

        return result;
    }

    /**
     * 获取相似车型
     */
    private List<Vehicle> getSimilarVehicles(Vehicle vehicle, Set<Long> excludeIds) {
        return vehicleMapper.selectList(new LambdaQueryWrapper<Vehicle>()
                .notIn(Vehicle::getId, excludeIds)
                .eq(Vehicle::getBatteryType, vehicle.getBatteryType())
                .orderByDesc(Vehicle::getStock)
                .last("limit 3"));
    }

    /**
     * 获取同品牌的车型
     */
    private List<Vehicle> getSameBrandVehicles(String brand, Set<Long> excludeIds) {
        return vehicleMapper.selectList(new LambdaQueryWrapper<Vehicle>()
                .eq(Vehicle::getBrand, brand)
                .notIn(Vehicle::getId, excludeIds)
                .orderByDesc(Vehicle::getStock)
                .last("limit 3"));
    }

    /**
     * 获取高性价比车型
     */
    private List<Vehicle> getHighValueVehicles() {
        return vehicleMapper.selectList(new LambdaQueryWrapper<Vehicle>()
                .orderByDesc(Vehicle::getRangeKm)
                .orderByAsc(Vehicle::getGuidePrice)
                .last("limit 6"));
    }

    /**
     * 比较车型
     */
    public List<Vehicle> compareVehicles(List<Long> vehicleIds) {
        return vehicleMapper.selectBatchIds(vehicleIds);
    }

    public void subscribeInventory(Long userId, Long vehicleId) {
        UserProfile user = userProfileMapper.selectById(userId);
        if (user == null) {
            // 如果用户个人信息不存在，自动创建一个基本记录
            user = new UserProfile();
            user.setId(userId);
            user.setRegisterTime(LocalDateTime.now());
            user.setCreateDate(LocalDateTime.now());
            user.setUpdateDate(LocalDateTime.now());
            userProfileMapper.insert(user);
        }
        InventorySubscription sub = new InventorySubscription();
        sub.setUserId(userId);
        sub.setVehicleId(vehicleId);
        sub.setNotified(false);
        try {
            inventorySubscriptionMapper.insert(sub);
        } catch (DuplicateKeyException ignore) {
            // already subscribed
        }
    }

    // -------------------- 用户/金融 --------------------

    @Transactional
    public UserProfile saveUser(UserProfile userProfile) {
        if (userProfile.getId() == null) {
            userProfile.setRegisterTime(LocalDateTime.now());
            userProfileMapper.insert(userProfile);
            return userProfile;
        }
        userProfileMapper.updateById(userProfile);
        return userProfileMapper.selectById(userProfile.getId());
    }

    public List<UserProfile> listUsers() {
        return userProfileMapper
                .selectList(new LambdaQueryWrapper<UserProfile>().orderByDesc(UserProfile::getRegisterTime));
    }

    public UserProfile getUserProfile(Long userId) {
        return userProfileMapper.selectById(userId);
    }

    @Transactional
    public void deleteUser(Long userId) {
        userProfileMapper.deleteById(userId);
    }

    public List<BrowseHistory> getUserBrowseHistory(Long userId) {
        return browseHistoryMapper.selectList(
                new LambdaQueryWrapper<BrowseHistory>()
                        .eq(BrowseHistory::getUserId, userId)
                        .orderByDesc(BrowseHistory::getBrowseTime));
    }

    @Transactional
    public FinancialPlan saveFinancialPlan(FinancialPlan plan) {
        if (plan.getVehicleId() == null || vehicleMapper.selectById(plan.getVehicleId()) == null) {
            throw new IllegalArgumentException("车型不存在");
        }
        if (plan.getId() == null) {
            financialPlanMapper.insert(plan);
            return plan;
        }
        financialPlanMapper.updateById(plan);
        return financialPlanMapper.selectById(plan.getId());
    }

    public List<FinancialPlan> listFinancialPlans(Long vehicleId) {
        LambdaQueryWrapper<FinancialPlan> qw = new LambdaQueryWrapper<>();
        if (vehicleId != null)
            qw.eq(FinancialPlan::getVehicleId, vehicleId);
        return financialPlanMapper.selectList(qw);
    }

    // -------------------- 统计 --------------------

    public Map<String, Object> stats(LocalDate start, LocalDate end) {
        // MySQL DATETIME 支持的范围是 1000-01-01 到 9999-12-31
        // 使用 LocalDateTime.MIN 会超出范围，改为使用 MySQL 支持的最小日期
        LocalDateTime from = start == null ? LocalDate.of(1000, 1, 1).atStartOfDay() : start.atStartOfDay();
        LocalDateTime to = end == null ? LocalDateTime.now() : end.plusDays(1).atStartOfDay();

        List<OrderRecord> scoped = orderRecordMapper.selectList(new LambdaQueryWrapper<OrderRecord>()
                .ge(OrderRecord::getCreatedAt, from)
                .lt(OrderRecord::getCreatedAt, to)
                .ne(OrderRecord::getStatus, OrderStatus.CANCELLED));

        Map<Long, Integer> qtyByVehicle = new HashMap<>();
        Map<Long, BigDecimal> amountByVehicle = new HashMap<>();
        for (OrderRecord order : scoped) {
            qtyByVehicle.merge(order.getVehicleId(), order.getQuantity(), Integer::sum);
            if (order.getTotalAmount() != null) {
                amountByVehicle.merge(order.getVehicleId(), order.getTotalAmount(), BigDecimal::add);
            }
        }

        List<Map<String, Object>> topVehicles = qtyByVehicle.entrySet().stream()
                .sorted(Map.Entry.<Long, Integer>comparingByValue().reversed())
                .limit(5)
                .map(e -> {
                    Map<String, Object> map = new HashMap<>();
                    Vehicle vehicle = vehicleMapper.selectById(e.getKey());
                    map.put("vehicle", vehicle);
                    map.put("qty", e.getValue());
                    map.put("amount", amountByVehicle.getOrDefault(e.getKey(), BigDecimal.ZERO));
                    return map;
                }).collect(Collectors.toList());

        Map<String, Long> brandShare = scoped.stream()
                .map(o -> vehicleMapper.selectById(o.getVehicleId()))
                .filter(Objects::nonNull)
                .collect(Collectors.groupingBy(Vehicle::getBrand, Collectors.counting()));

        Map<String, Long> rangeShare = scoped.stream()
                .map(o -> vehicleMapper.selectById(o.getVehicleId()))
                .filter(Objects::nonNull)
                .collect(Collectors.groupingBy(this::rangeBucket, Collectors.counting()));

        long newUsers = userProfileMapper.selectList(new LambdaQueryWrapper<UserProfile>()
                .ge(UserProfile::getRegisterTime, from)
                .lt(UserProfile::getRegisterTime, to))
                .size();

        BigDecimal totalAmount = scoped.stream()
                .map(OrderRecord::getTotalAmount)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Map<String, Object> result = new HashMap<>();
        result.put("top5Vehicles", topVehicles);
        result.put("brandShare", brandShare);
        result.put("rangeShare", rangeShare);
        result.put("newUsers", newUsers);
        result.put("totalAmount", totalAmount);
        result.put("totalOrders", scoped.size());
        return result;
    }

    private String rangeBucket(Vehicle vehicle) {
        if (vehicle == null || vehicle.getRangeKm() == null)
            return "未知";
        int r = vehicle.getRangeKm();
        if (r < 400)
            return "＜400km";
        if (r < 600)
            return "400-600km";
        return "≥600km";
    }
}