#pragma once

#include <iostream>
#include <string>
#include <vector>
#include <ctime>
#include <iomanip>
#include <sstream>

// 订单项实体
class OrderItem {
private:
    std::string itemId;
    std::string productId;
    std::string productName;
    double price;
    int quantity;
    std::string sku;

public:
    OrderItem();
    OrderItem(const std::string& productId, const std::string& productName, double price, int quantity);

    // Getters
    std::string getItemId() const;
    std::string getProductId() const;
    std::string getProductName() const;
    double getPrice() const;
    int getQuantity() const;
    std::string getSku() const;
    double getTotal() const;

    // Setters
    void setItemId(const std::string& id);
    void setProductId(const std::string& id);
    void setProductName(const std::string& name);
    void setPrice(double price);
    void setQuantity(int quantity);
    void setSku(const std::string& sku);

    // 序列化
    std::string toJson() const;
    static OrderItem fromJson(const std::string& jsonStr);
};

// 订单实体
class Order {
private:
    std::string orderId;
    std::string orderNumber;
    std::string userId;
    std::string userName;
    std::string status; // 待付款, 待发货, 已发货, 已完成, 已取消, 售后中
    std::vector<OrderItem> items;
    double totalAmount;
    double shippingFee;
    std::string shippingAddress;
    std::string receiverName;
    std::string receiverPhone;
    std::string paymentMethod;
    std::string logisticsCompany;
    std::string trackingNumber;
    std::string createTime;
    std::string updateTime;
    std::string buyerMessage;
    std::string refundReason;
    std::string refundStatus;
    std::string refundTime;

public:
    Order();
    Order(const std::string& userId, const std::string& userName);

    // Getters
    std::string getOrderId() const;
    std::string getOrderNumber() const;
    std::string getUserId() const;
    std::string getUserName() const;
    std::string getStatus() const;
    std::vector<OrderItem> getItems() const;
    double getTotalAmount() const;
    double getShippingFee() const;
    std::string getShippingAddress() const;
    std::string getReceiverName() const;
    std::string getReceiverPhone() const;
    std::string getPaymentMethod() const;
    std::string getLogisticsCompany() const;
    std::string getTrackingNumber() const;
    std::string getCreateTime() const;
    std::string getUpdateTime() const;
    std::string getBuyerMessage() const;
    std::string getRefundReason() const;
    std::string getRefundStatus() const;
    std::string getRefundTime() const;

    // Setters
    void setOrderId(const std::string& id);
    void setOrderNumber(const std::string& number);
    void setUserId(const std::string& id);
    void setUserName(const std::string& name);
    void setStatus(const std::string& status);
    void setItems(const std::vector<OrderItem>& items);
    void setTotalAmount(double amount);
    void setShippingFee(double fee);
    void setShippingAddress(const std::string& address);
    void setReceiverName(const std::string& name);
    void setReceiverPhone(const std::string& phone);
    void setPaymentMethod(const std::string& method);
    void setLogisticsCompany(const std::string& company);
    void setTrackingNumber(const std::string& number);
    void setUpdateTime(const std::string& time);
    void setBuyerMessage(const std::string& message);
    void setRefundReason(const std::string& reason);
    void setRefundStatus(const std::string& status);
    void setRefundTime(const std::string& time);
    void setCreateTime(const std::string& time);

    // 业务方法
    void calculateTotal();
    bool isValid() const;
    void addItem(const OrderItem& item);
    void removeItem(const std::string& itemId);
    void updateItemQuantity(const std::string& itemId, int quantity);

    // 时间戳生成
    static std::string generateTimestamp();

    // 序列化
    std::string toJson() const;
    static Order fromJson(const std::string& jsonStr);
};
