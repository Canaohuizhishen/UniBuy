#include "orderbroker.h"
#include "../entities/product.h"
#include <iostream>
#include <sstream>
#include <iomanip>
#include <ctime>

std::unordered_map<std::string, Order> OrderBroker::orderStore;
std::mutex OrderBroker::storeMutex;
int OrderBroker::nextOrderId = 1;
int OrderBroker::nextOrderNumber = 100000;

std::string OrderBroker::createOrder(const Order& order) {
    std::lock_guard<std::mutex> lock(storeMutex);

    std::string orderId = generateOrderId();
    Order newOrder = order;
    newOrder.setOrderId(orderId);
    newOrder.setOrderNumber(generateOrderNumber());
    newOrder.setCreateTime(Order::generateTimestamp());
    newOrder.setUpdateTime(newOrder.getCreateTime());

    orderStore[orderId] = newOrder;
    nextOrderId++;

    std::cout << "订单已创建: " << orderId << " - " << newOrder.getOrderNumber()
              << " (" << newOrder.getStatus() << ")" << std::endl;
    return orderId;
}

bool OrderBroker::updateOrder(const std::string& orderId, const Order& order) {
    std::lock_guard<std::mutex> lock(storeMutex);

    if (orderStore.find(orderId) == orderStore.end()) {
        return false;
    }

    Order updatedOrder = order;
    updatedOrder.setOrderId(orderId);
    updatedOrder.setUpdateTime(Order::generateTimestamp());

    orderStore[orderId] = updatedOrder;
    std::cout << "订单已更新: " << orderId << std::endl;
    return true;
}

bool OrderBroker::deleteOrder(const std::string& orderId) {
    std::lock_guard<std::mutex> lock(storeMutex);

    auto it = orderStore.find(orderId);
    if (it == orderStore.end()) {
        return false;
    }

    orderStore.erase(it);
    std::cout << "订单已删除: " << orderId << std::endl;
    return true;
}

Order OrderBroker::getOrder(const std::string& orderId) {
    std::lock_guard<std::mutex> lock(storeMutex);

    auto it = orderStore.find(orderId);
    if (it != orderStore.end()) {
        return it->second;
    }

    return Order();
}

std::vector<Order> OrderBroker::getAllOrders() {
    std::lock_guard<std::mutex> lock(storeMutex);

    std::vector<Order> orders;
    for (const auto& pair : orderStore) {
        orders.push_back(pair.second);
    }

    // 按创建时间倒序排序
    std::sort(orders.begin(), orders.end(),
              [](const Order& a, const Order& b) {
                  return a.getCreateTime() > b.getCreateTime();
              });

    return orders;
}

std::vector<Order> OrderBroker::getOrdersByStatus(const std::string& status) {
    std::lock_guard<std::mutex> lock(storeMutex);

    std::vector<Order> filteredOrders;
    for (const auto& pair : orderStore) {
        if (pair.second.getStatus() == status) {
            filteredOrders.push_back(pair.second);
        }
    }

    // 按创建时间倒序排序
    std::sort(filteredOrders.begin(), filteredOrders.end(),
              [](const Order& a, const Order& b) {
                  return a.getCreateTime() > b.getCreateTime();
              });

    return filteredOrders;
}

std::vector<Order> OrderBroker::getOrdersByUser(const std::string& userId) {
    std::lock_guard<std::mutex> lock(storeMutex);

    std::vector<Order> userOrders;
    for (const auto& pair : orderStore) {
        if (pair.second.getUserId() == userId) {
            userOrders.push_back(pair.second);
        }
    }

    // 按创建时间倒序排序
    std::sort(userOrders.begin(), userOrders.end(),
              [](const Order& a, const Order& b) {
                  return a.getCreateTime() > b.getCreateTime();
              });

    return userOrders;
}

bool OrderBroker::shipOrder(const std::string& orderId, const std::string& logisticsCompany,
                            const std::string& trackingNumber) {
    std::lock_guard<std::mutex> lock(storeMutex);

    auto it = orderStore.find(orderId);
    if (it == orderStore.end()) {
        return false;
    }

    Order& order = it->second;
    order.setStatus("已发货");
    order.setLogisticsCompany(logisticsCompany);
    order.setTrackingNumber(trackingNumber);
    order.setUpdateTime(Order::generateTimestamp());

    std::cout << "订单已发货: " << orderId << " - 物流公司: " << logisticsCompany
              << ", 运单号: " << trackingNumber << std::endl;
    return true;
}

bool OrderBroker::cancelOrder(const std::string& orderId, const std::string& reason) {
    std::lock_guard<std::mutex> lock(storeMutex);

    auto it = orderStore.find(orderId);
    if (it == orderStore.end()) {
        return false;
    }

    Order& order = it->second;

    // 只有待付款和待发货的订单可以取消
    if (order.getStatus() != "待付款" && order.getStatus() != "待发货") {
        return false;
    }

    order.setStatus("已取消");
    if (!reason.empty()) {
        order.setRefundReason(reason);
    }
    order.setUpdateTime(Order::generateTimestamp());

    std::cout << "订单已取消: " << orderId << " - 原因: " << reason << std::endl;
    return true;
}

bool OrderBroker::completeOrder(const std::string& orderId) {
    std::lock_guard<std::mutex> lock(storeMutex);

    auto it = orderStore.find(orderId);
    if (it == orderStore.end()) {
        return false;
    }

    Order& order = it->second;

    // 只有已发货的订单可以完成
    if (order.getStatus() != "已发货") {
        return false;
    }

    order.setStatus("已完成");
    order.setUpdateTime(Order::generateTimestamp());

    std::cout << "订单已完成: " << orderId << std::endl;
    return true;
}

bool OrderBroker::refundOrder(const std::string& orderId, const std::string& reason) {
    std::lock_guard<std::mutex> lock(storeMutex);

    auto it = orderStore.find(orderId);
    if (it == orderStore.end()) {
        return false;
    }

    Order& order = it->second;

    // 只有已发货和已完成的订单可以申请退款
    if (order.getStatus() != "已发货" && order.getStatus() != "已完成") {
        return false;
    }

    order.setStatus("售后中");
    order.setRefundReason(reason);
    order.setRefundStatus("待处理");
    order.setRefundTime(Order::generateTimestamp());
    order.setUpdateTime(order.getRefundTime());

    std::cout << "订单申请退款: " << orderId << " - 原因: " << reason << std::endl;
    return true;
}

std::vector<Order> OrderBroker::searchOrders(const std::string& keyword) {
    std::lock_guard<std::mutex> lock(storeMutex);

    std::vector<Order> results;
    if (keyword.empty()) {
        return results;
    }

    std::string lowerKeyword;
    std::transform(keyword.begin(), keyword.end(),
                   std::back_inserter(lowerKeyword), ::tolower);

    for (const auto& pair : orderStore) {
        const Order& order = pair.second;

        // 在订单号、用户名、收货人、地址、商品名中搜索
        std::string lowerOrderNumber = order.getOrderNumber();
        std::transform(lowerOrderNumber.begin(), lowerOrderNumber.end(),
                       lowerOrderNumber.begin(), ::tolower);

        std::string lowerUserName = order.getUserName();
        std::transform(lowerUserName.begin(), lowerUserName.end(),
                       lowerUserName.begin(), ::tolower);

        std::string lowerReceiverName = order.getReceiverName();
        std::transform(lowerReceiverName.begin(), lowerReceiverName.end(),
                       lowerReceiverName.begin(), ::tolower);

        std::string lowerShippingAddress = order.getShippingAddress();
        std::transform(lowerShippingAddress.begin(), lowerShippingAddress.end(),
                       lowerShippingAddress.begin(), ::tolower);

        if (lowerOrderNumber.find(lowerKeyword) != std::string::npos ||
            lowerUserName.find(lowerKeyword) != std::string::npos ||
            lowerReceiverName.find(lowerKeyword) != std::string::npos ||
            lowerShippingAddress.find(lowerKeyword) != std::string::npos) {
            results.push_back(order);
        } else {
            // 搜索商品名称
            for (const auto& item : order.getItems()) {
                std::string lowerProductName = item.getProductName();
                std::transform(lowerProductName.begin(), lowerProductName.end(),
                               lowerProductName.begin(), ::tolower);

                if (lowerProductName.find(lowerKeyword) != std::string::npos) {
                    results.push_back(order);
                    break;
                }
            }
        }
    }

    // 按创建时间倒序排序
    std::sort(results.begin(), results.end(),
              [](const Order& a, const Order& b) {
                  return a.getCreateTime() > b.getCreateTime();
              });

    return results;
}

std::unordered_map<std::string, int> OrderBroker::getOrderCounts() {
    std::lock_guard<std::mutex> lock(storeMutex);

    std::unordered_map<std::string, int> counts;
    counts["待付款"] = 0;
    counts["待发货"] = 0;
    counts["已发货"] = 0;
    counts["已完成"] = 0;
    counts["已取消"] = 0;
    counts["售后中"] = 0;
    counts["全部"] = 0;

    for (const auto& pair : orderStore) {
        const Order& order = pair.second;
        std::string status = order.getStatus();

        if (counts.find(status) != counts.end()) {
            counts[status]++;
        }
        counts["全部"]++;

        // 检查是否是今日订单
        std::string today = Order::generateTimestamp().substr(0, 10); // YYYY-MM-DD
        if (order.getCreateTime().substr(0, 10) == today) {
            if (counts.find("今日订单") == counts.end()) {
                counts["今日订单"] = 0;
            }
            counts["今日订单"]++;
        }
    }

    return counts;
}

std::vector<Order> OrderBroker::getOrdersByDateRange(const std::string& startDate, const std::string& endDate) {
    std::lock_guard<std::mutex> lock(storeMutex);

    std::vector<Order> dateFilteredOrders;

    for (const auto& pair : orderStore) {
        const Order& order = pair.second;
        std::string createDate = order.getCreateTime().substr(0, 10); // YYYY-MM-DD

        if (createDate >= startDate && createDate <= endDate) {
            dateFilteredOrders.push_back(order);
        }
    }

    // 按创建时间倒序排序
    std::sort(dateFilteredOrders.begin(), dateFilteredOrders.end(),
              [](const Order& a, const Order& b) {
                  return a.getCreateTime() > b.getCreateTime();
              });

    return dateFilteredOrders;
}

void OrderBroker::initializeTestData() {
    std::lock_guard<std::mutex> lock(storeMutex);

    if (!orderStore.empty()) {
        return; // 已有数据，不再初始化
    }

    std::cout << "📦 正在初始化订单测试数据..." << std::endl;

    try {
        // 订单1：待发货
        Order order1("USER001", "张三");
        order1.setShippingAddress("北京市朝阳区建国门外大街1号");
        order1.setReceiverName("张三");
        order1.setReceiverPhone("13800138000");
        order1.setPaymentMethod("微信支付");
        order1.setStatus("待发货");
        order1.setBuyerMessage("请尽快发货，谢谢！");

        OrderItem item1("P1", "夏季男士短袖T恤", 79.00, 2);
        item1.setItemId("ITEM001");
        order1.addItem(item1);

        OrderItem item2("P5", "运动袜", 15.00, 3);
        item2.setItemId("ITEM002");
        order1.addItem(item2);

        order1.setShippingFee(0.00);
        order1.calculateTotal();

        // 直接创建订单，不调用 createOrder()
        std::string orderId1 = generateOrderId();
        order1.setOrderId(orderId1);
        order1.setOrderNumber(generateOrderNumber());
        order1.setCreateTime(Order::generateTimestamp());
        order1.setUpdateTime(order1.getCreateTime());
        orderStore[orderId1] = order1;
        nextOrderId++;

        std::cout << "订单已创建: " << orderId1 << " - " << order1.getOrderNumber()
                  << " (" << order1.getStatus() << ")" << std::endl;

        // 订单2：已发货
        Order order2("USER002", "李四");
        order2.setShippingAddress("上海市浦东新区陆家嘴环路100号");
        order2.setReceiverName("李四");
        order2.setReceiverPhone("13900139000");
        order2.setPaymentMethod("支付宝");
        order2.setStatus("已发货");
        order2.setLogisticsCompany("顺丰速运");
        order2.setTrackingNumber("SF123456789");

        OrderItem item3("P3", "笔记本电脑", 5999.00, 1);
        item3.setItemId("ITEM003");
        order2.addItem(item3);

        order2.setShippingFee(0.00);
        order2.calculateTotal();

        std::string orderId2 = generateOrderId();
        order2.setOrderId(orderId2);
        order2.setOrderNumber(generateOrderNumber());
        order2.setCreateTime(Order::generateTimestamp());
        order2.setUpdateTime(order2.getCreateTime());
        orderStore[orderId2] = order2;
        nextOrderId++;

        std::cout << "订单已创建: " << orderId2 << " - " << order2.getOrderNumber()
                  << " (" << order2.getStatus() << ")" << std::endl;

        // 订单3：已完成
        Order order3("USER003", "王五");
        order3.setShippingAddress("广州市天河区体育西路189号");
        order3.setReceiverName("王五");
        order3.setReceiverPhone("13700137000");
        order3.setPaymentMethod("银行卡");
        order3.setStatus("已完成");
        order3.setLogisticsCompany("中通快递");
        order3.setTrackingNumber("ZT987654321");

        OrderItem item4("P2", "无线蓝牙耳机", 199.00, 1);
        item4.setItemId("ITEM004");
        order3.addItem(item4);

        OrderItem item5("P4", "运动鞋", 299.00, 1);
        item5.setItemId("ITEM005");
        order3.addItem(item5);

        order3.setShippingFee(0.00);
        order3.calculateTotal();

        std::string orderId3 = generateOrderId();
        order3.setOrderId(orderId3);
        order3.setOrderNumber(generateOrderNumber());
        order3.setCreateTime(Order::generateTimestamp());
        order3.setUpdateTime(order3.getCreateTime());
        orderStore[orderId3] = order3;
        nextOrderId++;

        std::cout << "订单已创建: " << orderId3 << " - " << order3.getOrderNumber()
                  << " (" << order3.getStatus() << ")" << std::endl;

        // 订单4：已取消
        Order order4("USER001", "张三");
        order4.setShippingAddress("北京市海淀区中关村大街1号");
        order4.setReceiverName("张三");
        order4.setReceiverPhone("13800138001");
        order4.setPaymentMethod("微信支付");
        order4.setStatus("已取消");
        order4.setRefundReason("买错了");

        OrderItem item6("P5", "新品测试", 99.00, 2);
        item6.setItemId("ITEM006");
        order4.addItem(item6);

        order4.setShippingFee(0.00);
        order4.calculateTotal();

        std::string orderId4 = generateOrderId();
        order4.setOrderId(orderId4);
        order4.setOrderNumber(generateOrderNumber());
        order4.setCreateTime(Order::generateTimestamp());
        order4.setUpdateTime(order4.getCreateTime());
        orderStore[orderId4] = order4;
        nextOrderId++;

        std::cout << "订单已创建: " << orderId4 << " - " << order4.getOrderNumber()
                  << " (" << order4.getStatus() << ")" << std::endl;

        // 订单5：售后中
        Order order5("USER004", "赵六");
        order5.setShippingAddress("深圳市南山区科技园路100号");
        order5.setReceiverName("赵六");
        order5.setReceiverPhone("13600136000");
        order5.setPaymentMethod("支付宝");
        order5.setStatus("售后中");
        order5.setLogisticsCompany("圆通速递");
        order5.setTrackingNumber("YT555666777");
        order5.setRefundReason("商品有瑕疵");
        order5.setRefundStatus("待处理");

        OrderItem item7("P1", "夏季男士短袖T恤", 79.00, 1);
        item7.setItemId("ITEM007");
        order5.addItem(item7);

        order5.setShippingFee(0.00);
        order5.calculateTotal();

        std::string orderId5 = generateOrderId();
        order5.setOrderId(orderId5);
        order5.setOrderNumber(generateOrderNumber());
        order5.setCreateTime(Order::generateTimestamp());
        order5.setUpdateTime(order5.getCreateTime());
        orderStore[orderId5] = order5;
        nextOrderId++;

        std::cout << "订单已创建: " << orderId5 << " - " << order5.getOrderNumber()
                  << " (" << order5.getStatus() << ")" << std::endl;

        // 订单6:待发货
        Order order6("USER005", "钱七");
        order6.setShippingAddress("杭州市西湖区文三路90号");
        order6.setReceiverName("钱七");
        order6.setReceiverPhone("13500135000");
        order6.setPaymentMethod("微信支付");
        order6.setStatus("待发货");  // 设置状态为待发货
        order6.setBuyerMessage("周末收货，请安排工作日发货");

        // 添加商品项1
        OrderItem item8("P2", "无线蓝牙耳机", 199.00, 2);
        item8.setItemId("ITEM008");
        order6.addItem(item8);

        // 添加商品项2
        OrderItem item9("P4", "运动鞋", 299.00, 1);
        item9.setItemId("ITEM009");
        order6.addItem(item9);

        // 添加商品项3
        OrderItem item10("P5", "运动袜", 15.00, 5);
        item10.setItemId("ITEM010");
        order6.addItem(item10);

        order6.setShippingFee(10.00);  // 设置运费
        order6.calculateTotal();  // 计算总金额

        std::string orderId6 = generateOrderId();
        order6.setOrderId(orderId6);
        order6.setOrderNumber(generateOrderNumber());
        order6.setCreateTime(Order::generateTimestamp());
        order6.setUpdateTime(order6.getCreateTime());
        orderStore[orderId6] = order6;
        nextOrderId++;

        std::cout << "订单已创建: " << orderId6 << " - " << order6.getOrderNumber()
                  << " (" << order6.getStatus() << ")" << std::endl;

        std::cout << "🎉 订单测试数据初始化完成。总计: "
                  << orderStore.size() << " 个订单" << std::endl;

    } catch (const std::exception& e) {
        std::cerr << "❌ 初始化订单测试数据时出错: " << e.what() << std::endl;
    }
}

std::string OrderBroker::generateOrderId() {
    return "O" + std::to_string(nextOrderId);
}

std::string OrderBroker::generateOrderNumber() {
    std::time_t now = std::time(nullptr);
    std::tm* tm = std::localtime(&now);

    std::ostringstream oss;
    oss << std::put_time(tm, "%Y%m%d") << std::setw(6) << std::setfill('0') << nextOrderNumber;

    nextOrderNumber++;
    return oss.str();
}
