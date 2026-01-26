package com.example.mybatisplus.web.controller;

import com.example.mybatisplus.common.JsonResponse;
import com.example.mybatisplus.model.domain.ev.*;
import com.example.mybatisplus.model.domain.ev.enums.PromotionStatus;
import com.example.mybatisplus.model.domain.ev.enums.TestDriveStatus;
import com.example.mybatisplus.service.EvSaleService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/ev/admin")
public class EvAdminController {

    private final EvSaleService evSaleService;

    public EvAdminController(EvSaleService evSaleService) {
        this.evSaleService = evSaleService;
    }

    @PostMapping("/vehicles")
    public JsonResponse<Vehicle> createVehicle(@RequestBody Vehicle vehicle) {
        return JsonResponse.success(evSaleService.saveVehicle(vehicle), "新增车型成功");
    }

    @PutMapping("/vehicles/{id}")
    public JsonResponse<Vehicle> updateVehicle(@PathVariable Long id, @RequestBody Vehicle vehicle) {
        return JsonResponse.success(evSaleService.updateVehicle(id, vehicle), "更新车型成功");
    }

    @DeleteMapping("/vehicles/{id}")
    public JsonResponse<Void> deleteVehicle(@PathVariable Long id) {
        evSaleService.deleteVehicle(id);
        return JsonResponse.successMessage("删除成功");
    }

    @GetMapping("/vehicles/low-stock")
    public JsonResponse<List<Vehicle>> lowStockVehicles() {
        return JsonResponse.success(evSaleService.lowStockVehicles());
    }

    @PostMapping("/vehicles/{id}/restock")
    public JsonResponse<Vehicle> restock(@PathVariable Long id, @RequestBody Map<String, Integer> body) {
        Integer delta = body == null ? null : body.get("delta");
        if (delta == null) {
            return JsonResponse.failure("缺少参数 delta");
        }
        return JsonResponse.success(evSaleService.restockVehicle(id, delta), "补货完成");
    }

    @GetMapping("/orders")
    public JsonResponse<List<OrderRecord>> listOrders() {
        return JsonResponse.success(evSaleService.listOrders());
    }

    @PostMapping("/orders/{id}/pay")
    public JsonResponse<OrderRecord> markPaid(@PathVariable Long id) {
        return JsonResponse.success(evSaleService.markPaid(id), "已确认支付");
    }

    @PostMapping("/orders/{id}/pickup")
    public JsonResponse<OrderRecord> markPickup(@PathVariable Long id) {
        return JsonResponse.success(evSaleService.markPicked(id), "已标记提车");
    }

    @PostMapping("/promotions")
    public JsonResponse<Promotion> createPromotion(@RequestBody Promotion promotion) {
        return JsonResponse.success(evSaleService.savePromotion(promotion), "活动已保存");
    }

    @PostMapping("/promotions/{id}/status")
    public JsonResponse<Promotion> changePromotionStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String statusStr = body == null ? null : body.get("status");
        PromotionStatus status = statusStr == null ? null : PromotionStatus.valueOf(statusStr);
        if (status == null) {
            return JsonResponse.failure("缺少参数 status");
        }
        return JsonResponse.success(evSaleService.updatePromotionStatus(id, status));
    }

    @GetMapping("/users")
    public JsonResponse<Object> listUsers() {
        return JsonResponse.success(evSaleService.listUsers());
    }

    @PostMapping("/users")
    public JsonResponse<UserProfile> saveUser(@RequestBody UserProfile userProfile) {
        return JsonResponse.success(evSaleService.saveUser(userProfile), "用户信息已保存");
    }

    @DeleteMapping("/users/{id}")
    public JsonResponse<Void> deleteUser(@PathVariable Long id) {
        evSaleService.deleteUser(id);
        return JsonResponse.successMessage("用户已删除");
    }

    @GetMapping("/users/{id}/orders")
    public JsonResponse<List<OrderRecord>> getUserOrders(@PathVariable Long id) {
        return JsonResponse.success(evSaleService.listOrders(id));
    }

    @GetMapping("/users/{id}/browse-history")
    public JsonResponse<List<BrowseHistory>> getUserBrowseHistory(@PathVariable Long id) {
        return JsonResponse.success(evSaleService.getUserBrowseHistory(id));
    }

    @GetMapping("/stats")
    public JsonResponse<Map<String, Object>> stats(@RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate start,
                                                   @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate end) {
        return JsonResponse.success(evSaleService.stats(start, end));
    }

    @GetMapping("/test-drives")
    public JsonResponse<List<TestDriveRecord>> listTestDrives() {
        return JsonResponse.success(evSaleService.listTestDrives(null));
    }

    @PostMapping("/test-drives/{id}/audit")
    public JsonResponse<TestDriveRecord> auditTestDrive(@PathVariable Long id,
                                                        @RequestBody Map<String, String> body) {
        String statusStr = body == null ? null : body.get("status");
        String note = body == null ? null : body.get("note");
        TestDriveStatus status = statusStr == null ? null : TestDriveStatus.valueOf(statusStr);
        if (status == null) {
            return JsonResponse.failure("缺少参数 status");
        }
        return JsonResponse.success(evSaleService.reviewTestDrive(id, status, note), "审核完成");
    }

    @PostMapping("/financial-plans")
    public JsonResponse<FinancialPlan> savePlan(@RequestBody FinancialPlan plan) {
        return JsonResponse.success(evSaleService.saveFinancialPlan(plan), "金融方案已保存");
    }

    @GetMapping("/financial-plans")
    public JsonResponse<List<FinancialPlan>> listPlans(@RequestParam(required = false) Long vehicleId) {
        return JsonResponse.success(evSaleService.listFinancialPlans(vehicleId));
    }
}
