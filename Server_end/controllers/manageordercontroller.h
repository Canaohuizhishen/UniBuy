#pragma once
#include "../broker/orderbroker.h"
#include "../entities/product.h"
#include <iostream>
#include <string>
#include <vector>
#include "../nlohmann/json.hpp"

class OrderManagementController {
public:
    // RESTful API接口对应的方法
    static std::string getAllOrders();
    static std::string getOrdersByStatus(const std::string& status);
    static std::string getOrder(const std::string& orderId);
    static std::string getOrdersByUser(const std::string& userId);
    static std::string createOrder(const std::string& orderJson);
    static std::string updateOrder(const std::string& orderId, const std::string& orderJson);
    static std::string deleteOrder(const std::string& orderId);

    // 订单操作
    static std::string shipOrder(const std::string& orderId, const std::string& logisticsCompany,
                                 const std::string& trackingNumber);
    static std::string cancelOrder(const std::string& orderId, const std::string& reason = "");
    static std::string completeOrder(const std::string& orderId);
    static std::string refundOrder(const std::string& orderId, const std::string& reason);

    // 搜索和统计
    static std::string searchOrders(const std::string& keyword);
    static std::string getOrderCounts();
    static std::string getOrdersByDateRange(const std::string& startDate, const std::string& endDate);

private:
    static nlohmann::json orderToJson(const Order& order);
    static nlohmann::json createResponse(bool success, const std::string& message = "",
                                         const nlohmann::json& data = nullptr);
};
