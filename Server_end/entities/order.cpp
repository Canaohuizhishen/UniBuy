#include "order.h"
#include "../nlohmann/json.hpp"
#include <iostream>
#include <sstream>
#include <algorithm>
#include <ctime>

using json = nlohmann::json;

// OrderItem 实现
OrderItem::OrderItem() : price(0.0), quantity(0) {}

OrderItem::OrderItem(const std::string& productId, const std::string& productName, double price, int quantity)
    : productId(productId), productName(productName), price(price), quantity(quantity) {}

std::string OrderItem::getItemId() const { return itemId; }
std::string OrderItem::getProductId() const { return productId; }
std::string OrderItem::getProductName() const { return productName; }
double OrderItem::getPrice() const { return price; }
int OrderItem::getQuantity() const { return quantity; }
std::string OrderItem::getSku() const { return sku; }
double OrderItem::getTotal() const { return price * quantity; }

void OrderItem::setItemId(const std::string& id) { itemId = id; }
void OrderItem::setProductId(const std::string& id) { productId = id; }
void OrderItem::setProductName(const std::string& name) { productName = name; }
void OrderItem::setPrice(double price) { this->price = price; }
void OrderItem::setQuantity(int quantity) { this->quantity = quantity; }
void OrderItem::setSku(const std::string& sku) { this->sku = sku; }

std::string OrderItem::toJson() const {
    json j;
    j["itemId"] = itemId;
    j["productId"] = productId;
    j["productName"] = productName;
    j["price"] = price;
    j["quantity"] = quantity;
    j["sku"] = sku;
    j["total"] = getTotal();
    return j.dump();
}

OrderItem OrderItem::fromJson(const std::string& jsonStr) {
    OrderItem item;
    try {
        json j = json::parse(jsonStr);
        item.setItemId(j.value("itemId", ""));
        item.setProductId(j.value("productId", ""));
        item.setProductName(j.value("productName", ""));
        item.setPrice(j.value("price", 0.0));
        item.setQuantity(j.value("quantity", 0));
        item.setSku(j.value("sku", ""));
    } catch (const std::exception& e) {
        std::cerr << "Error parsing OrderItem JSON: " << e.what() << std::endl;
    }
    return item;
}

// Order 实现
Order::Order() : totalAmount(0.0), shippingFee(0.0) {
    status = "待付款";
    createTime = generateTimestamp();
    updateTime = createTime;
}

Order::Order(const std::string& userId, const std::string& userName)
    : userId(userId), userName(userName), totalAmount(0.0), shippingFee(0.0) {
    status = "待付款";
    createTime = generateTimestamp();
    updateTime = createTime;
}

// Getters
std::string Order::getOrderId() const { return orderId; }
std::string Order::getOrderNumber() const { return orderNumber; }
std::string Order::getUserId() const { return userId; }
std::string Order::getUserName() const { return userName; }
std::string Order::getStatus() const { return status; }
std::vector<OrderItem> Order::getItems() const { return items; }
double Order::getTotalAmount() const { return totalAmount; }
double Order::getShippingFee() const { return shippingFee; }
std::string Order::getShippingAddress() const { return shippingAddress; }
std::string Order::getReceiverName() const { return receiverName; }
std::string Order::getReceiverPhone() const { return receiverPhone; }
std::string Order::getPaymentMethod() const { return paymentMethod; }
std::string Order::getLogisticsCompany() const { return logisticsCompany; }
std::string Order::getTrackingNumber() const { return trackingNumber; }
std::string Order::getCreateTime() const { return createTime; }
std::string Order::getUpdateTime() const { return updateTime; }
std::string Order::getBuyerMessage() const { return buyerMessage; }
std::string Order::getRefundReason() const { return refundReason; }
std::string Order::getRefundStatus() const { return refundStatus; }
std::string Order::getRefundTime() const { return refundTime; }

// Setters
void Order::setOrderId(const std::string& id) { orderId = id; }
void Order::setOrderNumber(const std::string& number) { orderNumber = number; }
void Order::setUserId(const std::string& id) { userId = id; updateTime = generateTimestamp(); }
void Order::setUserName(const std::string& name) { userName = name; updateTime = generateTimestamp(); }
void Order::setStatus(const std::string& status) { this->status = status; updateTime = generateTimestamp(); }
void Order::setItems(const std::vector<OrderItem>& items) { this->items = items; calculateTotal(); }
void Order::setTotalAmount(double amount) { totalAmount = amount; updateTime = generateTimestamp(); }
void Order::setShippingFee(double fee) { shippingFee = fee; calculateTotal(); updateTime = generateTimestamp(); }
void Order::setShippingAddress(const std::string& address) { shippingAddress = address; updateTime = generateTimestamp(); }
void Order::setReceiverName(const std::string& name) { receiverName = name; updateTime = generateTimestamp(); }
void Order::setReceiverPhone(const std::string& phone) { receiverPhone = phone; updateTime = generateTimestamp(); }
void Order::setPaymentMethod(const std::string& method) { paymentMethod = method; updateTime = generateTimestamp(); }
void Order::setLogisticsCompany(const std::string& company) { logisticsCompany = company; updateTime = generateTimestamp(); }
void Order::setTrackingNumber(const std::string& number) { trackingNumber = number; updateTime = generateTimestamp(); }
void Order::setUpdateTime(const std::string& time) { updateTime = time; }
void Order::setBuyerMessage(const std::string& message) { buyerMessage = message; updateTime = generateTimestamp(); }
void Order::setRefundReason(const std::string& reason) { refundReason = reason; updateTime = generateTimestamp(); }
void Order::setRefundStatus(const std::string& status) { refundStatus = status; updateTime = generateTimestamp(); }
void Order::setRefundTime(const std::string& time) { refundTime = time; updateTime = generateTimestamp(); }
void Order::setCreateTime(const std::string& time) {
    this->createTime = time;
}

// 业务方法
void Order::calculateTotal() {
    double itemsTotal = 0.0;
    for (const auto& item : items) {
        itemsTotal += item.getTotal();
    }
    totalAmount = itemsTotal + shippingFee;
    updateTime = generateTimestamp();

    // std::cout << "计算订单总额: 商品总额=" << itemsTotal
    //           << ", 运费=" << shippingFee
    //           << ", 总计=" << totalAmount << std::endl;
}


bool Order::isValid() const {
    if (userId.empty() || items.empty()) {
        return false;
    }

    if (status == "已发货" || status == "已完成") {
        if (trackingNumber.empty() || logisticsCompany.empty()) {
            return false;
        }
    }

    return true;
}

void Order::addItem(const OrderItem& item) {
    items.push_back(item);
    calculateTotal();
}

void Order::removeItem(const std::string& itemId) {
    items.erase(std::remove_if(items.begin(), items.end(),
                               [itemId](const OrderItem& item) { return item.getItemId() == itemId; }),
                items.end());
    calculateTotal();
}

void Order::updateItemQuantity(const std::string& itemId, int quantity) {
    for (auto& item : items) {
        if (item.getItemId() == itemId) {
            item.setQuantity(quantity);
            break;
        }
    }
    calculateTotal();
}

std::string Order::generateTimestamp() {
    auto now = std::time(nullptr);
    auto tm = *std::localtime(&now);
    std::ostringstream oss;
    oss << std::put_time(&tm, "%Y-%m-%d %H:%M:%S");
    return oss.str();
}

std::string Order::toJson() const {
    json j;
    j["orderId"] = orderId;
    j["orderNumber"] = orderNumber;
    j["userId"] = userId;
    j["userName"] = userName;
    j["status"] = status;

    json itemsArray = json::array();
    for (const auto& item : items) {
        itemsArray.push_back(json::parse(item.toJson()));
    }
    j["items"] = itemsArray;

    j["totalAmount"] = totalAmount;
    j["shippingFee"] = shippingFee;
    j["shippingAddress"] = shippingAddress;
    j["receiverName"] = receiverName;
    j["receiverPhone"] = receiverPhone;
    j["paymentMethod"] = paymentMethod;
    j["logisticsCompany"] = logisticsCompany;
    j["trackingNumber"] = trackingNumber;
    j["createTime"] = createTime;
    j["updateTime"] = updateTime;
    j["buyerMessage"] = buyerMessage;
    j["refundReason"] = refundReason;
    j["refundStatus"] = refundStatus;
    j["refundTime"] = refundTime;

    return j.dump();
}

Order Order::fromJson(const std::string& jsonStr) {
    Order order;
    try {
        json j = json::parse(jsonStr);

        order.setOrderId(j.value("orderId", ""));
        order.setOrderNumber(j.value("orderNumber", ""));
        order.setUserId(j.value("userId", ""));
        order.setUserName(j.value("userName", ""));
        order.setStatus(j.value("status", "待付款"));

        if (j.contains("items")) {
            std::vector<OrderItem> items;
            for (const auto& itemJson : j["items"]) {
                OrderItem item = OrderItem::fromJson(itemJson.dump());
                if (item.getItemId().empty()) {
                    item.setItemId("ITEM_" + std::to_string(std::rand()));
                }
                items.push_back(item);
            }
            order.setItems(items);  // 这会触发 calculateTotal()
        }

        order.setShippingFee(j.value("shippingFee", 0.0));
        order.setShippingAddress(j.value("shippingAddress", ""));
        order.setReceiverName(j.value("receiverName", ""));
        order.setReceiverPhone(j.value("receiverPhone", ""));
        order.setPaymentMethod(j.value("paymentMethod", ""));
        order.setLogisticsCompany(j.value("logisticsCompany", ""));
        order.setTrackingNumber(j.value("trackingNumber", ""));

        // 处理时间字段
        std::string createTime = j.value("createTime", "");
        if (!createTime.empty()) {
            order.setCreateTime(createTime);
        } else {
            order.setCreateTime(order.generateTimestamp());
        }

        order.setUpdateTime(j.value("updateTime", order.getCreateTime()));
        order.setBuyerMessage(j.value("buyerMessage", ""));
        order.setRefundReason(j.value("refundReason", ""));
        order.setRefundStatus(j.value("refundStatus", ""));
        order.setRefundTime(j.value("refundTime", ""));

        double providedTotal = j.value("totalAmount", 0.0);
        double calculatedTotal = order.getTotalAmount();

        if (providedTotal > 0 && std::abs(providedTotal - calculatedTotal) > 0.01) {
            std::cout << "警告: 提供的订单总额 " << providedTotal
                      << " 与计算总额 " << calculatedTotal << " 不一致" << std::endl;
            // 使用计算的总金额
            order.setTotalAmount(calculatedTotal);
        }

    } catch (const std::exception& e) {
        std::cerr << "Error parsing Order JSON: " << e.what() << std::endl;
    }
    return order;
}
