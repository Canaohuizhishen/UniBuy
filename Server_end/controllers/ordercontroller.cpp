#include "ordercontroller.h"
#include "../broker/orderbroker.h"
#include "../entities/order.h"
#include <iostream>
#include <ctime>
#include <iomanip>
#include <sstream>
#include <algorithm>

using json = nlohmann::json;

// 初始化模拟订单数据
std::unordered_map<std::string, json> OrderController::mockOrders;

json OrderController::createResponse(bool success, const std::string& message, const json& data) {
    json response;
    response["success"] = success;
    response["message"] = message;
    if (!data.is_null()) {
        response["data"] = data;
    }
    return response;
}

std::vector<json> OrderController::generateMockOrders() {
    // 模拟订单数据
    std::vector<json> orders;

    // 订单1
    json order1;
    order1["orderId"] = "ORDER001";
    order1["orderNumber"] = "UNIBUY202412150001";
    order1["status"] = "待收货";
    order1["totalAmount"] = 299.00;
    order1["createTime"] = "2023-12-15 14:30:25";
    order1["items"] = json::array({
        {
            {"productId", "P1"},
            {"productName", "夏季男士短袖T恤"},
            {"spec", "L码 白色"},
            {"price", 79.00},
            {"quantity", 2},
            {"subtotal", 158.00}
        },
        {
            {"productId", "P2"},
            {"productName", "运动袜"},
            {"spec", "均码 黑色"},
            {"price", 15.00},
            {"quantity", 3},
            {"subtotal", 45.00}
        }
    });
    order1["logisticsInfo"] = {
        {"company", "顺丰速运"},
        {"trackingNumber", "SF1234567890123"},
        {"currentStatus", "运输中"},
        {"currentLocation", "北京转运中心"},
        {"trackingHistory", json::array({
                                {
                                    {"time", "2023-12-16 14:20"},
                                    {"description", "已发货，等待揽收"}
                                },
                                {
                                    {"time", "2023-12-16 18:45"},
                                    {"description", "快件已到达北京转运中心"}
                                },
                                {
                                    {"time", "2023-12-17 09:30"},
                                    {"description", "正在派送中"}
                                }
                            })}
    };
    orders.push_back(order1);
    mockOrders["ORDER001"] = order1;

    // 订单2
    json order2;
    order2["orderId"] = "ORDER002";
    order2["orderNumber"] = "UNIBUY202412140002";
    order2["status"] = "待付款";
    order2["totalAmount"] = 5999.00;
    order2["createTime"] = "2023-12-14 10:15:42";
    order2["items"] = json::array({
        {
            {"productId", "P3"},
            {"productName", "笔记本电脑"},
            {"spec", "16GB+512GB 灰色"},
            {"price", 5999.00},
            {"quantity", 1},
            {"subtotal", 5999.00}
        }
    });
    orders.push_back(order2);
    mockOrders["ORDER002"] = order2;

    // 订单3
    json order3;
    order3["orderId"] = "ORDER003";
    order3["orderNumber"] = "UNIBUY202412130003";
    order3["status"] = "已完成";
    order3["totalAmount"] = 158.00;
    order3["createTime"] = "2023-12-13 16:20:18";
    order3["items"] = json::array({
        {
            {"productId", "P1"},
            {"productName", "夏季男士短袖T恤"},
            {"spec", "M码 黑色"},
            {"price", 79.00},
            {"quantity", 2},
            {"subtotal", 158.00}
        }
    });
    order3["logisticsInfo"] = {
        {"company", "圆通快递"},
        {"trackingNumber", "YT9876543210123"},
        {"currentStatus", "已签收"},
        {"currentLocation", "北京市朝阳区"},
        {"trackingHistory", json::array({
                                {
                                    {"time", "2023-12-13 18:30"},
                                    {"description", "商家已发货"}
                                },
                                {
                                    {"time", "2023-12-14 10:20"},
                                    {"description", "快件已到达北京转运中心"}
                                },
                                {
                                    {"time", "2023-12-15 14:15"},
                                    {"description", "正在派送中"}
                                },
                                {
                                    {"time", "2023-12-15 16:30"},
                                    {"description", "已签收，签收人：张先生"}
                                }
                            })}
    };
    orders.push_back(order3);
    mockOrders["ORDER003"] = order3;

    return orders;
}

std::string OrderController::getConsumerOrders() {
    try {
        // 假设当前用户ID为"user123"（实际应从登录信息获取）
        std::string userId = "user123";

        // 从 OrderBroker 获取用户订单
        std::vector<Order> orders = OrderBroker::getOrdersByUser(userId);

        // 如果没有订单，返回空数组
        if (orders.empty()) {
            json ordersArray = json::array();
            return createResponse(true, "暂无订单", ordersArray).dump();
        }

        json ordersArray = json::array();
        for (const auto& order : orders) {
            // 将 Order 对象转换为 JSON
            json orderJson;
            orderJson["orderId"] = order.getOrderId();
            orderJson["orderNumber"] = order.getOrderNumber();
            orderJson["status"] = order.getStatus();
            orderJson["totalAmount"] = order.getTotalAmount();
            orderJson["createTime"] = order.getCreateTime();

            // 添加订单项
            json itemsArray = json::array();
            for (const auto& item : order.getItems()) {
                json itemJson;
                itemJson["productId"] = item.getProductId();
                itemJson["productName"] = item.getProductName();
                itemJson["price"] = item.getPrice();
                itemJson["quantity"] = item.getQuantity();
                itemJson["subtotal"] = item.getTotal();
                itemsArray.push_back(itemJson);
            }
            orderJson["items"] = itemsArray;

            // 如果有物流信息，添加物流信息
            if (!order.getLogisticsCompany().empty()) {
                json logisticsJson;
                logisticsJson["company"] = order.getLogisticsCompany();
                logisticsJson["trackingNumber"] = order.getTrackingNumber();
                logisticsJson["currentStatus"] = "运输中";
                logisticsJson["currentLocation"] = "北京转运中心";

                // 模拟物流轨迹
                json trackingHistory = json::array();
                json step1;
                step1["time"] = "2023-12-16 14:20";
                step1["description"] = "已发货，等待揽收";
                trackingHistory.push_back(step1);

                json step2;
                step2["time"] = "2023-12-16 18:45";
                step2["description"] = "快件已到达北京转运中心";
                trackingHistory.push_back(step2);

                logisticsJson["trackingHistory"] = trackingHistory;
                orderJson["logisticsInfo"] = logisticsJson;
            }

            ordersArray.push_back(orderJson);
        }

        return createResponse(true, "获取订单成功", ordersArray).dump();
    } catch (const std::exception& e) {
        std::cerr << "获取真实订单时出错: " << e.what() << std::endl;
        return createResponse(false, "获取订单时出错").dump();
    }
}

std::string OrderController::getConsumerOrdersByStatus(const std::string& status) {
    try {
        if (mockOrders.empty()) {
            generateMockOrders();
        }

        json ordersArray = json::array();
        for (const auto& pair : mockOrders) {
            if (pair.second["status"] == status) {
                ordersArray.push_back(pair.second);
            }
        }

        return createResponse(true, "获取订单成功", ordersArray).dump();
    } catch (const std::exception& e) {
        std::cerr << "按状态获取订单时出错: " << e.what() << std::endl;
        return createResponse(false, "获取订单时出错").dump();
    }
}

std::string OrderController::getConsumerOrder(const std::string& orderId) {
    try {
        if (mockOrders.empty()) {
            generateMockOrders();
        }

        auto it = mockOrders.find(orderId);
        if (it != mockOrders.end()) {
            return createResponse(true, "获取订单详情成功", it->second).dump();
        } else {
            return createResponse(false, "订单未找到").dump();
        }
    } catch (const std::exception& e) {
        std::cerr << "获取订单详情时出错: " << e.what() << std::endl;
        return createResponse(false, "获取订单详情时出错").dump();
    }
}

std::string OrderController::cancelConsumerOrder(const std::string& orderId) {
    try {
        if (mockOrders.empty()) {
            generateMockOrders();
        }

        auto it = mockOrders.find(orderId);
        if (it != mockOrders.end()) {
            if (it->second["status"] == "待付款") {
                it->second["status"] = "已取消";
                return createResponse(true, "订单取消成功", it->second).dump();
            } else {
                return createResponse(false, "该订单状态不可取消").dump();
            }
        } else {
            return createResponse(false, "订单未找到").dump();
        }
    } catch (const std::exception& e) {
        std::cerr << "取消订单时出错: " << e.what() << std::endl;
        return createResponse(false, "取消订单时出错").dump();
    }
}

std::string OrderController::confirmReceipt(const std::string& orderId) {
    try {
        if (mockOrders.empty()) {
            generateMockOrders();
        }

        auto it = mockOrders.find(orderId);
        if (it != mockOrders.end()) {
            if (it->second["status"] == "待收货") {
                it->second["status"] = "已完成";
                return createResponse(true, "确认收货成功", it->second).dump();
            } else {
                return createResponse(false, "该订单状态不可确认收货").dump();
            }
        } else {
            return createResponse(false, "订单未找到").dump();
        }
    } catch (const std::exception& e) {
        std::cerr << "确认收货时出错: " << e.what() << std::endl;
        return createResponse(false, "确认收货时出错").dump();
    }
}

std::string OrderController::getLogisticsInfo(const std::string& orderId) {
    try {
        if (mockOrders.empty()) {
            generateMockOrders();
        }

        auto it = mockOrders.find(orderId);
        if (it != mockOrders.end()) {
            if (it->second.contains("logisticsInfo")) {
                return createResponse(true, "获取物流信息成功", it->second["logisticsInfo"]).dump();
            } else {
                return createResponse(false, "暂无物流信息").dump();
            }
        } else {
            return createResponse(false, "订单未找到").dump();
        }
    } catch (const std::exception& e) {
        std::cerr << "获取物流信息时出错: " << e.what() << std::endl;
        return createResponse(false, "获取物流信息时出错").dump();
    }
}

std::string OrderController::searchConsumerOrders(const std::string& keyword) {
    try {
        if (mockOrders.empty()) {
            generateMockOrders();
        }

        json ordersArray = json::array();
        std::string lowerKeyword = keyword;
        std::transform(lowerKeyword.begin(), lowerKeyword.end(), lowerKeyword.begin(), ::tolower);

        for (const auto& pair : mockOrders) {
            const auto& order = pair.second;

            // 在订单号、商品名称中搜索
            std::string orderNumber = order["orderNumber"];
            std::transform(orderNumber.begin(), orderNumber.end(), orderNumber.begin(), ::tolower);

            bool found = false;
            if (orderNumber.find(lowerKeyword) != std::string::npos) {
                found = true;
            } else {
                // 检查商品名称
                for (const auto& item : order["items"]) {
                    std::string productName = item["productName"];
                    std::transform(productName.begin(), productName.end(), productName.begin(), ::tolower);
                    if (productName.find(lowerKeyword) != std::string::npos) {
                        found = true;
                        break;
                    }
                }
            }

            if (found) {
                ordersArray.push_back(order);
            }
        }

        return createResponse(true, "搜索成功", ordersArray).dump();
    } catch (const std::exception& e) {
        std::cerr << "搜索订单时出错: " << e.what() << std::endl;
        return createResponse(false, "搜索订单时出错").dump();
    }
}

std::string OrderController::getConsumerOrderCounts() {
    try {
        if (mockOrders.empty()) {
            generateMockOrders();
        }

        json counts = {
            {"待付款", 0},
            {"待发货", 0},
            {"待收货", 0},
            {"已完成", 0},
            {"已取消", 0},
            {"全部", 0}
        };

        for (const auto& pair : mockOrders) {
            std::string status = pair.second["status"];
            if (counts.contains(status)) {
                counts[status] = counts[status].get<int>() + 1;
            }
            counts["全部"] = counts["全部"].get<int>() + 1;
        }

        return createResponse(true, "获取订单统计成功", counts).dump();
    } catch (const std::exception& e) {
        std::cerr << "获取订单统计时出错: " << e.what() << std::endl;
        return createResponse(false, "获取订单统计时出错").dump();
    }
}

// 其他方法暂时返回模拟数据
std::string OrderController::createServiceRequest(const std::string& orderId, const json& requestData) {
    return createResponse(true, "售后申请已提交", {{"requestId", "SR001"}, {"status", "审核中"}}).dump();
}

std::string OrderController::getServiceRequests(const std::string& orderId) {
    json requests = json::array({
        {
            {"requestId", "SR001"},
            {"type", "退货"},
            {"reason", "商品质量问题"},
            {"status", "审核中"},
            {"createTime", "2023-12-16 10:30:00"}
        }
    });
    return createResponse(true, "获取售后请求成功", requests).dump();
}

std::string OrderController::addReview(const std::string& orderId, const json& reviewData) {
    return createResponse(true, "评价提交成功", reviewData).dump();
}
