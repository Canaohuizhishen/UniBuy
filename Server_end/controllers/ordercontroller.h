#pragma once
#include <string>
#include <vector>
#include <unordered_map>
#include "../nlohmann/json.hpp"

class OrderController {
public:
    // 消费者订单API
    static std::string getConsumerOrders();
    static std::string getConsumerOrdersByStatus(const std::string& status);
    static std::string getConsumerOrder(const std::string& orderId);
    static std::string cancelConsumerOrder(const std::string& orderId);
    static std::string confirmReceipt(const std::string& orderId);
    static std::string getLogisticsInfo(const std::string& orderId);
    static std::string createServiceRequest(const std::string& orderId, const nlohmann::json& requestData);
    static std::string getServiceRequests(const std::string& orderId);
    static std::string addReview(const std::string& orderId, const nlohmann::json& reviewData);
    static std::string searchConsumerOrders(const std::string& keyword);
    static std::string getConsumerOrderCounts();

private:
    static nlohmann::json createResponse(bool success, const std::string& message = "", const nlohmann::json& data = nullptr);
    static std::vector<nlohmann::json> generateMockOrders();  // 生成模拟订单数据
    static std::unordered_map<std::string, nlohmann::json> mockOrders;  // 模拟订单存储
};
