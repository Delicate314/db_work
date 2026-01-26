package com.example.mybatisplus.web.controller;

import com.example.mybatisplus.common.JsonResponse;
import com.example.mybatisplus.model.domain.ev.*;
import com.example.mybatisplus.service.EvSaleService;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/ev")
public class EvCustomerController {

    private final EvSaleService evSaleService;

    public EvCustomerController(EvSaleService evSaleService) {
        this.evSaleService = evSaleService;
    }

    @GetMapping("/vehicles")
    public JsonResponse<List<Vehicle>> searchVehicles(@RequestParam(required = false) String brand,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) Integer minRange,
            @RequestParam(required = false) Integer maxRange,
            @RequestParam(required = false) String batteryType,
            @RequestParam(required = false, defaultValue = "id") String sort,
            @RequestParam(required = false, defaultValue = "asc") String order) {
        return JsonResponse.success(
                evSaleService.listVehicles(brand, minPrice, maxPrice, minRange, maxRange, batteryType, sort, order));
    }

    @GetMapping("/vehicles/{id}")
    public JsonResponse<VehicleDetail> vehicleDetail(@PathVariable Long id,
            @RequestHeader(value = "X-User-Id", required = false) Long userId) {
        if (userId != null) {
            evSaleService.recordBrowse(userId, id);
        }
        return JsonResponse.success(evSaleService.getVehicleDetail(id));
    }

    @PostMapping("/compare")
    public JsonResponse<List<Vehicle>> compare(@RequestBody List<Long> vehicleIds) {
        return JsonResponse.success(evSaleService.compareVehicles(vehicleIds));
    }

    @PostMapping("/orders")
    public JsonResponse<OrderRecord> createOrder(@RequestBody OrderRecord request,
            @RequestHeader(value = "X-User-Id", required = false) Long userId) {
        if (request.getUserId() == null) {
            request.setUserId(userId);
        }
        return JsonResponse.success(evSaleService.createOrder(request), "下单成功");
    }

    @GetMapping("/orders")
    public JsonResponse<List<OrderRecord>> myOrders(@RequestParam Long userId) {
        return JsonResponse.success(evSaleService.listOrders(userId));
    }

    @PostMapping("/orders/{id}/cancel")
    public JsonResponse<OrderRecord> cancelOrder(@PathVariable Long id, @RequestBody Map<String, Long> body) {
        Long userId = body == null ? null : body.get("userId");
        if (userId == null) {
            return JsonResponse.failure("缺少参数 userId");
        }
        return JsonResponse.success(evSaleService.cancelOrder(id, userId), "订单已取消");
    }

    @PostMapping("/reviews")
    public JsonResponse<ReviewRecord> addReview(@RequestBody ReviewRecord review) {
        return JsonResponse.success(evSaleService.addReview(review), "评价成功");
    }

    @GetMapping("/reviews")
    public JsonResponse<List<ReviewRecord>> listReviews(@RequestParam Long vehicleId) {
        return JsonResponse.success(evSaleService.listReviews(vehicleId));
    }

    @PostMapping("/test-drives")
    public JsonResponse<TestDriveRecord> createTestDrive(@RequestBody TestDriveRecord request,
            @RequestHeader(value = "X-User-Id", required = false) Long userId) {
        if (request.getUserId() == null) {
            request.setUserId(userId);
        }
        return JsonResponse.success(evSaleService.createTestDrive(request), "预约提交成功");
    }

    @GetMapping("/test-drives")
    public JsonResponse<List<TestDriveRecord>> myTestDrives(@RequestParam Long userId) {
        return JsonResponse.success(evSaleService.listTestDrives(userId));
    }

    @GetMapping("/recommendations")
    public JsonResponse<List<Vehicle>> recommend(@RequestParam Long userId) {
        return JsonResponse.success(evSaleService.recommendVehicles(userId));
    }

    @PostMapping("/inventory/subscribe")
    public JsonResponse<String> subscribe(@RequestBody Map<String, Long> body) {
        Long userId = body == null ? null : body.get("userId");
        Long vehicleId = body == null ? null : body.get("vehicleId");
        if (userId == null || vehicleId == null) {
            return JsonResponse.failure("缺少参数 userId / vehicleId");
        }
        evSaleService.subscribeInventory(userId, vehicleId);
        return JsonResponse.success("已订阅库存提醒");
    }

    @GetMapping("/promotions")
    public JsonResponse<List<Promotion>> promotions(@RequestParam Long vehicleId) {
        return JsonResponse.success(evSaleService.getActivePromotions(vehicleId));
    }

    @PostMapping("/profile")
    public JsonResponse<UserProfile> saveProfile(@RequestBody UserProfile profile) {
        return JsonResponse.success(evSaleService.saveUser(profile), "个人信息已更新");
    }

    @GetMapping("/profile")
    public JsonResponse<UserProfile> profile(@RequestParam Long userId) {
        return JsonResponse.success(evSaleService.getUserProfile(userId));
    }

    @GetMapping("/financial-plans")
    public JsonResponse<List<FinancialPlan>> financialPlans(@RequestParam Long vehicleId) {
        return JsonResponse.success(evSaleService.listFinancialPlans(vehicleId));
    }
}
