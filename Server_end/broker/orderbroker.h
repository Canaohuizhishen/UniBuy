#pragma once
#include "../entities/order.h"
#include <iostream>
#include <string>
#include <vector>
#include <unordered_map>
#include <mutex>
#include <algorithm>
#include <ctime>

class OrderBroker {
private:
    static std::unordered_map<std::string, Order> orderStore;
    static std::mutex storeMutex;
    static int nextOrderId;
    static int nextOrderNumber;

public:
    // 订单管理方法
    static std::string createOrder(const Order& order);
    static bool updateOrder(const std::string& orderId, const Order& order);
    static bool deleteOrder(const std::string& orderId);
    static Order getOrder(const std::string& orderId);
    static std::vector<Order> getAllOrders();
    static std::vector<Order> getOrdersByStatus(const std::string& status);
    static std::vector<Order> getOrdersByUser(const std::string& userId);

    // 订单操作
    static bool shipOrder(const std::string& orderId, const std::string& logisticsCompany,
                          const std::string& trackingNumber);
    static bool cancelOrder(const std::string& orderId, const std::string& reason = "");
    static bool completeOrder(const std::string& orderId);
    static bool refundOrder(const std::string& orderId, const std::string& reason);

    // 搜索和统计
    static std::vector<Order> searchOrders(const std::string& keyword);
    static std::unordered_map<std::string, int> getOrderCounts();
    static std::vector<Order> getOrdersByDateRange(const std::string& startDate, const std::string& endDate);

    // 测试数据初始化
    static void initializeTestData();

private:
    static std::string generateOrderId();
    static std::string generateOrderNumber();
};
