#include "manageordercontroller.h"
#include <iostream>
#include <sstream>

using json = nlohmann::json;

json OrderManagementController::orderToJson(const Order& order) {
    return json::parse(order.toJson());
}

json OrderManagementController::createResponse(bool success, const std::string& message, const json& data) {
    json response;
    response["success"] = success;
    response["message"] = message;
    if (data != nullptr) {
        response["data"] = data;
    }
    return response;
}

std::string OrderManagementController::getAllOrders() {
    try {
        std::vector<Order> orders = OrderBroker::getAllOrders();
        json ordersArray = json::array();

        for (const auto& order : orders) {
            ordersArray.push_back(orderToJson(order));
        }

        return createResponse(true, "成功", ordersArray).dump();
    } catch (const std::exception& e) {
        std::cerr << "获取所有订单时出错: " << e.what() << std::endl;
        return createResponse(false, "获取订单时出错").dump();
    }
}

std::string OrderManagementController::getOrdersByStatus(const std::string& status) {
    try {
        std::vector<Order> orders = OrderBroker::getOrdersByStatus(status);
        json ordersArray = json::array();

        for (const auto& order : orders) {
            ordersArray.push_back(orderToJson(order));
        }

        return createResponse(true, "成功", ordersArray).dump();
    } catch (const std::exception& e) {
        std::cerr << "按状态获取订单时出错: " << e.what() << std::endl;
        return createResponse(false, "获取订单时出错").dump();
    }
}

std::string OrderManagementController::getOrder(const std::string& orderId) {
    try {
        Order order = OrderBroker::getOrder(orderId);
        if (order.getOrderId().empty()) {
            return createResponse(false, "订单未找到").dump();
        }

        return createResponse(true, "成功", orderToJson(order)).dump();
    } catch (const std::exception& e) {
        std::cerr << "获取订单时出错: " << e.what() << std::endl;
        return createResponse(false, "获取订单时出错").dump();
    }
}

std::string OrderManagementController::getOrdersByUser(const std::string& userId) {
    try {
        std::vector<Order> orders = OrderBroker::getOrdersByUser(userId);
        json ordersArray = json::array();

        for (const auto& order : orders) {
            ordersArray.push_back(orderToJson(order));
        }

        return createResponse(true, "成功", ordersArray).dump();
    } catch (const std::exception& e) {
        std::cerr << "获取用户订单时出错: " << e.what() << std::endl;
        return createResponse(false, "获取用户订单时出错").dump();
    }
}

std::string OrderManagementController::createOrder(const std::string& orderJson) {
    try {
        std::cout << "创建订单，JSON数据: " << orderJson << std::endl;

        Order order = Order::fromJson(orderJson);

        // 验证订单有效性
        if (!order.isValid()) {
            return createResponse(false, "订单数据不完整").dump();
        }

        std::string orderId = OrderBroker::createOrder(order);

        if (!orderId.empty()) {
            Order createdOrder = OrderBroker::getOrder(orderId);
            return createResponse(true, "订单创建成功", orderToJson(createdOrder)).dump();
        } else {
            return createResponse(false, "创建订单失败").dump();
        }
    } catch (const std::exception& e) {
        std::cerr << "创建订单时出错: " << e.what() << std::endl;
        return createResponse(false, "创建订单时出错: " + std::string(e.what())).dump();
    }
}

std::string OrderManagementController::updateOrder(const std::string& orderId, const std::string& orderJson) {
    try {
        std::cout << "更新订单 - 订单ID: " << orderId << std::endl;
        std::cout << "订单JSON数据: " << orderJson << std::endl;

        // 获取现有订单
        Order existingOrder = OrderBroker::getOrder(orderId);
        if (existingOrder.getOrderId().empty()) {
            return createResponse(false, "订单未找到").dump();
        }

        Order updatedOrder = Order::fromJson(orderJson);
        updatedOrder.setOrderId(orderId);

        // 保留原有的一些字段（如果新数据中没有）
        if (updatedOrder.getCreateTime().empty()) {
            updatedOrder.setUpdateTime(existingOrder.getCreateTime());
        }

        bool success = OrderBroker::updateOrder(orderId, updatedOrder);
        if (success) {
            Order resultOrder = OrderBroker::getOrder(orderId);
            return createResponse(true, "订单更新成功", orderToJson(resultOrder)).dump();
        } else {
            return createResponse(false, "订单未找到").dump();
        }
    } catch (const std::exception& e) {
        std::cerr << "更新订单时出错: " << e.what() << std::endl;
        return createResponse(false, "更新订单时出错: " + std::string(e.what())).dump();
    }
}

std::string OrderManagementController::deleteOrder(const std::string& orderId) {
    try {
        bool success = OrderBroker::deleteOrder(orderId);
        if (success) {
            return createResponse(true, "订单删除成功").dump();
        } else {
            return createResponse(false, "订单未找到").dump();
        }
    } catch (const std::exception& e) {
        std::cerr << "删除订单时出错: " << e.what() << std::endl;
        return createResponse(false, "删除订单时出错").dump();
    }
}

std::string OrderManagementController::shipOrder(const std::string& orderId, const std::string& logisticsCompany,
                                                 const std::string& trackingNumber) {
    try {
        std::cout << "发货订单 - 订单ID: " << orderId
                  << ", 物流公司: " << logisticsCompany
                  << ", 运单号: " << trackingNumber << std::endl;

        bool success = OrderBroker::shipOrder(orderId, logisticsCompany, trackingNumber);
        if (success) {
            Order resultOrder = OrderBroker::getOrder(orderId);
            return createResponse(true, "订单发货成功", orderToJson(resultOrder)).dump();
        } else {
            return createResponse(false, "订单发货失败或订单未找到").dump();
        }
    } catch (const std::exception& e) {
        std::cerr << "发货订单时出错: " << e.what() << std::endl;
        return createResponse(false, "发货订单时出错: " + std::string(e.what())).dump();
    }
}

std::string OrderManagementController::cancelOrder(const std::string& orderId, const std::string& reason) {
    try {
        std::cout << "取消订单 - 订单ID: " << orderId
                  << ", 原因: " << (reason.empty() ? "未提供" : reason) << std::endl;

        bool success = OrderBroker::cancelOrder(orderId, reason);
        if (success) {
            Order resultOrder = OrderBroker::getOrder(orderId);
            return createResponse(true, "订单取消成功", orderToJson(resultOrder)).dump();
        } else {
            return createResponse(false, "订单取消失败（可能订单状态不允许取消）").dump();
        }
    } catch (const std::exception& e) {
        std::cerr << "取消订单时出错: " << e.what() << std::endl;
        return createResponse(false, "取消订单时出错: " + std::string(e.what())).dump();
    }
}

std::string OrderManagementController::completeOrder(const std::string& orderId) {
    try {
        std::cout << "完成订单 - 订单ID: " << orderId << std::endl;

        bool success = OrderBroker::completeOrder(orderId);
        if (success) {
            Order resultOrder = OrderBroker::getOrder(orderId);
            return createResponse(true, "订单完成成功", orderToJson(resultOrder)).dump();
        } else {
            return createResponse(false, "订单完成失败（可能订单状态不允许完成）").dump();
        }
    } catch (const std::exception& e) {
        std::cerr << "完成订单时出错: " << e.what() << std::endl;
        return createResponse(false, "完成订单时出错: " + std::string(e.what())).dump();
    }
}

std::string OrderManagementController::refundOrder(const std::string& orderId, const std::string& reason) {
    try {
        std::cout << "申请退款 - 订单ID: " << orderId
                  << ", 原因: " << reason << std::endl;

        bool success = OrderBroker::refundOrder(orderId, reason);
        if (success) {
            Order resultOrder = OrderBroker::getOrder(orderId);
            return createResponse(true, "退款申请成功", orderToJson(resultOrder)).dump();
        } else {
            return createResponse(false, "退款申请失败（可能订单状态不允许退款）").dump();
        }
    } catch (const std::exception& e) {
        std::cerr << "申请退款时出错: " << e.what() << std::endl;
        return createResponse(false, "申请退款时出错: " + std::string(e.what())).dump();
    }
}

std::string OrderManagementController::searchOrders(const std::string& keyword) {
    try {
        std::vector<Order> orders = OrderBroker::searchOrders(keyword);
        json ordersArray = json::array();

        for (const auto& order : orders) {
            ordersArray.push_back(orderToJson(order));
        }

        return createResponse(true, "成功", ordersArray).dump();
    } catch (const std::exception& e) {
        std::cerr << "搜索订单时出错: " << e.what() << std::endl;
        return createResponse(false, "搜索订单时出错").dump();
    }
}

std::string OrderManagementController::getOrderCounts() {
    try {
        auto counts = OrderBroker::getOrderCounts();
        json countsJson;

        for (const auto& pair : counts) {
            countsJson[pair.first] = pair.second;
        }

        return createResponse(true, "成功", countsJson).dump();
    } catch (const std::exception& e) {
        std::cerr << "获取订单数量统计时出错: " << e.what() << std::endl;
        return createResponse(false, "获取订单数量统计时出错").dump();
    }
}

std::string OrderManagementController::getOrdersByDateRange(const std::string& startDate, const std::string& endDate) {
    try {
        if (startDate.empty() || endDate.empty()) {
            return createResponse(false, "必须提供开始日期和结束日期").dump();
        }

        std::vector<Order> orders = OrderBroker::getOrdersByDateRange(startDate, endDate);
        json ordersArray = json::array();

        for (const auto& order : orders) {
            ordersArray.push_back(orderToJson(order));
        }

        return createResponse(true, "成功", ordersArray).dump();
    } catch (const std::exception& e) {
        std::cerr << "按日期范围获取订单时出错: " << e.what() << std::endl;
        return createResponse(false, "按日期范围获取订单时出错").dump();
    }
}
