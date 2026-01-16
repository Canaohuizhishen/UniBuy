#pragma once
#include "../broker/productbroker.h"
#include "../broker/orderbroker.h"
#include "../entities/order.h"
#include <iostream>
#include <string>
#include <vector>
#include <unordered_map>
#include <mutex>
#include "../nlohmann/json.hpp"

class ShoppingController {
private:
    // 购物车模拟数据（实际项目中应该用数据库）
    static std::unordered_map<std::string, std::vector<nlohmann::json>> shoppingCarts;
    static std::mutex cartMutex;
    static int nextCartItemId;

public:
    // 商品浏览相关
    static std::string getAllProductsForShopping();
    static std::string getProductDetailForShopping(const std::string& productId);
    static std::string searchProductsForShopping(const std::string& keyword);
    static std::string getProductCountsForShopping();

    // 购物车相关
    static std::string getCart(const std::string& userId);
    static std::string addToCart(const std::string& userId, const nlohmann::json& itemData);
    static std::string updateCartItem(const std::string& userId, const std::string& itemId,
                                      const nlohmann::json& updateData);
    static std::string removeFromCart(const std::string& userId, const std::string& itemId);
    static std::string removeProductFromCart(const std::string& userId, const std::string& productId);
    static std::string clearCart(const std::string& userId);
    static std::string getCartSummary(const std::string& userId);

    // 直接购买（不经过购物车）
    static std::string directPurchase(const std::string& userId, const nlohmann::json& orderData);

    // 结算购物车
    static std::string checkoutCart(const std::string& userId, const nlohmann::json& orderInfo);

private:
    static nlohmann::json createResponse(bool success, const std::string& message = "",
                                         const nlohmann::json& data = nullptr);
    static std::string generateCartItemId();
    static nlohmann::json productToJsonForShopping(const Product& product);
    static bool validateCartItem(const nlohmann::json& item);
    static bool checkProductAvailability(const std::string& productId, int requestedQuantity);
};
