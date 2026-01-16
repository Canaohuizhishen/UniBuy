#include "shoppingcontroller.h"
#include <iostream>
#include <sstream>
#include <algorithm>
#include <ctime>

using json = nlohmann::json;

// 静态成员初始化
std::unordered_map<std::string, std::vector<nlohmann::json>> ShoppingController::shoppingCarts;
std::mutex ShoppingController::cartMutex;
int ShoppingController::nextCartItemId = 1;

json ShoppingController::createResponse(bool success, const std::string& message, const json& data) {
    json response;
    response["success"] = success;
    response["message"] = message;
    if (!data.is_null()) {
        response["data"] = data;
    }
    return response;
}

json ShoppingController::productToJsonForShopping(const Product& product) {
    json productJson;

    productJson["productId"] = product.getProductId();
    productJson["name"] = product.getName();
    productJson["category"] = product.getCategory();
    productJson["price"] = product.getPrice();
    productJson["originalPrice"] = product.getOriginalPrice();
    productJson["stock"] = product.getStock();
    productJson["description"] = product.getDescription();
    productJson["images"] = product.getImages();
    productJson["tags"] = product.getTags();
    productJson["status"] = product.getStatus();
    productJson["sales"] = product.getSales();
    productJson["available"] = product.isAvailable();

    return productJson;
}

std::string ShoppingController::generateCartItemId() {
    return "CI" + std::to_string(nextCartItemId++);
}

bool ShoppingController::validateCartItem(const json& item) {
    if (!item.contains("productId") || !item.contains("quantity") ||
        !item.contains("productName") || !item.contains("price")) {
        return false;
    }

    if (item["quantity"].get<int>() <= 0) {
        return false;
    }

    if (item["price"].get<double>() < 0) {
        return false;
    }

    return true;
}

bool ShoppingController::checkProductAvailability(const std::string& productId, int requestedQuantity) {
    try {
        Product product = ProductBroker::getProduct(productId);
        if (product.getProductId().empty()) {
            return false;
        }

        if (!product.isAvailable()) {
            return false;
        }

        if (product.getStock() < requestedQuantity) {
            return false;
        }

        return true;
    } catch (const std::exception& e) {
        std::cerr << "检查商品可用性时出错: " << e.what() << std::endl;
        return false;
    }
}

std::string ShoppingController::getAllProductsForShopping() {
    try {
        std::vector<Product> products = ProductBroker::getAllProducts();
        json productsArray = json::array();

        for (const auto& product : products) {
            // 只返回出售中的商品给消费者端
            if (product.getStatus() == "出售中" && product.getStock() > 0) {
                productsArray.push_back(productToJsonForShopping(product));
            }
        }

        return createResponse(true, "成功", productsArray).dump();
    } catch (const std::exception& e) {
        std::cerr << "获取商品列表时出错: " << e.what() << std::endl;
        return createResponse(false, "获取商品时出错").dump();
    }
}

std::string ShoppingController::getProductDetailForShopping(const std::string& productId) {
    try {
        Product product = ProductBroker::getProduct(productId);
        if (product.getProductId().empty()) {
            return createResponse(false, "商品未找到").dump();
        }

        // 检查商品是否可用
        if (!product.isAvailable()) {
            return createResponse(false, "商品已下架或已售罄").dump();
        }

        return createResponse(true, "成功", productToJsonForShopping(product)).dump();
    } catch (const std::exception& e) {
        std::cerr << "获取商品详情时出错: " << e.what() << std::endl;
        return createResponse(false, "获取商品详情时出错").dump();
    }
}

std::string ShoppingController::searchProductsForShopping(const std::string& keyword) {
    try {
        if (keyword.empty()) {
            return getAllProductsForShopping();
        }

        std::vector<Product> products = ProductBroker::searchProducts(keyword);
        json productsArray = json::array();

        for (const auto& product : products) {
            // 只返回出售中的商品给消费者端
            if (product.getStatus() == "出售中" && product.getStock() > 0) {
                productsArray.push_back(productToJsonForShopping(product));
            }
        }

        return createResponse(true, "成功", productsArray).dump();
    } catch (const std::exception& e) {
        std::cerr << "搜索商品时出错: " << e.what() << std::endl;
        return createResponse(false, "搜索商品时出错").dump();
    }
}

std::string ShoppingController::getProductCountsForShopping() {
    try {
        json counts;

        int availableCount = 0;
        int lowStockCount = 0; // 库存少于10的商品
        int outOfStockCount = 0;

        std::vector<Product> products = ProductBroker::getAllProducts();

        for (const auto& product : products) {
            if (product.getStatus() == "出售中") {
                if (product.getStock() > 0) {
                    availableCount++;
                    if (product.getStock() < 10) {
                        lowStockCount++;
                    }
                } else {
                    outOfStockCount++;
                }
            }
        }

        counts["available"] = availableCount;
        counts["lowStock"] = lowStockCount;
        counts["outOfStock"] = outOfStockCount;
        counts["total"] = products.size();

        return createResponse(true, "成功", counts).dump();
    } catch (const std::exception& e) {
        std::cerr << "获取商品统计时出错: " << e.what() << std::endl;
        return createResponse(false, "获取商品统计时出错").dump();
    }
}

std::string ShoppingController::getCart(const std::string& userId) {
    std::lock_guard<std::mutex> lock(cartMutex);

    try {
        if (shoppingCarts.find(userId) == shoppingCarts.end()) {
            shoppingCarts[userId] = std::vector<json>();
        }

        json cartArray = json::array();
        double totalAmount = 0.0;
        int totalItems = 0;
        int totalQuantity = 0;

        for (const auto& item : shoppingCarts[userId]) {
            cartArray.push_back(item);
            totalAmount += item["price"].get<double>() * item["quantity"].get<int>();
            totalQuantity += item["quantity"].get<int>();
            totalItems++;
        }

        json result;
        result["items"] = cartArray;
        result["summary"] = {
            {"totalAmount", totalAmount},
            {"totalItems", totalItems},
            {"totalQuantity", totalQuantity}
        };

        return createResponse(true, "成功", result).dump();
    } catch (const std::exception& e) {
        std::cerr << "获取购物车时出错: " << e.what() << std::endl;
        return createResponse(false, "获取购物车时出错").dump();
    }
}

std::string ShoppingController::addToCart(const std::string& userId, const json& itemData) {
    std::lock_guard<std::mutex> lock(cartMutex);

    try {
        if (!validateCartItem(itemData)) {
            return createResponse(false, "无效的购物车项数据").dump();
        }

        // 检查商品可用性
        std::string productId = itemData["productId"];
        int quantity = itemData["quantity"];

        if (!checkProductAvailability(productId, quantity)) {
            return createResponse(false, "商品不可用或库存不足").dump();
        }

        // 初始化用户购物车（如果不存在）
        if (shoppingCarts.find(userId) == shoppingCarts.end()) {
            shoppingCarts[userId] = std::vector<json>();
        }

        // 检查商品是否已在购物车中
        bool itemExists = false;
        for (auto& item : shoppingCarts[userId]) {
            if (item["productId"] == productId && item["spec"] == itemData.value("spec", "")) {
                // 更新数量
                int newQuantity = item["quantity"].get<int>() + quantity;

                // 再次检查库存
                if (!checkProductAvailability(productId, newQuantity)) {
                    return createResponse(false, "库存不足，无法添加到购物车").dump();
                }

                item["quantity"] = newQuantity;
                item["subtotal"] = item["price"].get<double>() * newQuantity;
                item["updateTime"] = Order::generateTimestamp();
                itemExists = true;
                break;
            }
        }

        // 如果不存在，添加新项
        if (!itemExists) {
            json newItem = itemData;
            newItem["itemId"] = generateCartItemId();
            newItem["addTime"] = Order::generateTimestamp();
            newItem["updateTime"] = newItem["addTime"];

            // 计算小计
            if (!newItem.contains("subtotal")) {
                newItem["subtotal"] = newItem["price"].get<double>() * newItem["quantity"].get<int>();
            }

            // 确保有规格信息
            if (!newItem.contains("spec")) {
                newItem["spec"] = "默认规格";
            }

            shoppingCarts[userId].push_back(newItem);
        }

        // 获取更新后的购物车
        std::string cartResponse = getCart(userId);
        json cartResult = json::parse(cartResponse);

        if (cartResult["success"].get<bool>()) {
            json responseData;
            responseData["cart"] = cartResult["data"];
            responseData["message"] = itemExists ? "购物车商品数量已更新" : "商品已添加到购物车";

            return createResponse(true, responseData["message"], responseData).dump();
        } else {
            return cartResponse;
        }

    } catch (const std::exception& e) {
        std::cerr << "添加到购物车时出错: " << e.what() << std::endl;
        return createResponse(false, "添加到购物车时出错: " + std::string(e.what())).dump();
    }
}

std::string ShoppingController::updateCartItem(const std::string& userId, const std::string& itemId,
                                               const json& updateData) {
    std::lock_guard<std::mutex> lock(cartMutex);

    try {
        if (shoppingCarts.find(userId) == shoppingCarts.end()) {
            return createResponse(false, "购物车为空").dump();
        }

        bool itemFound = false;
        for (auto& item : shoppingCarts[userId]) {
            if (item["itemId"] == itemId) {
                // 更新数量
                if (updateData.contains("quantity")) {
                    int newQuantity = updateData["quantity"];
                    std::string productId = item["productId"];

                    // 检查库存
                    if (!checkProductAvailability(productId, newQuantity)) {
                        return createResponse(false, "库存不足").dump();
                    }

                    item["quantity"] = newQuantity;
                    item["subtotal"] = item["price"].get<double>() * newQuantity;
                    item["updateTime"] = Order::generateTimestamp();
                }

                // 更新规格（如果需要）
                if (updateData.contains("spec")) {
                    item["spec"] = updateData["spec"];
                    item["updateTime"] = Order::generateTimestamp();
                }

                itemFound = true;
                break;
            }
        }

        if (!itemFound) {
            return createResponse(false, "购物车项未找到").dump();
        }

        return createResponse(true, "购物车项已更新").dump();
    } catch (const std::exception& e) {
        std::cerr << "更新购物车项时出错: " << e.what() << std::endl;
        return createResponse(false, "更新购物车项时出错").dump();
    }
}

std::string ShoppingController::removeFromCart(const std::string& userId, const std::string& itemId) {
    std::lock_guard<std::mutex> lock(cartMutex);

    try {
        if (shoppingCarts.find(userId) == shoppingCarts.end()) {
            return createResponse(false, "购物车为空").dump();
        }

        auto& cart = shoppingCarts[userId];
        auto it = std::remove_if(cart.begin(), cart.end(),
                                 [itemId](const json& item) { return item["itemId"] == itemId; });

        if (it != cart.end()) {
            cart.erase(it, cart.end());
            return createResponse(true, "商品已从购物车移除").dump();
        } else {
            return createResponse(false, "购物车项未找到").dump();
        }
    } catch (const std::exception& e) {
        std::cerr << "从购物车移除商品时出错: " << e.what() << std::endl;
        return createResponse(false, "从购物车移除商品时出错").dump();
    }
}

std::string ShoppingController::removeProductFromCart(const std::string& userId, const std::string& productId) {
    std::lock_guard<std::mutex> lock(cartMutex);

    try {
        if (shoppingCarts.find(userId) == shoppingCarts.end()) {
            return createResponse(false, "购物车为空").dump();
        }

        auto& cart = shoppingCarts[userId];
        auto originalSize = cart.size();

        cart.erase(std::remove_if(cart.begin(), cart.end(),
                                  [productId](const json& item) { return item["productId"] == productId; }), cart.end());

        if (cart.size() < originalSize) {
            return createResponse(true, "商品已从购物车移除").dump();
        } else {
            return createResponse(false, "商品未在购物车中").dump();
        }
    } catch (const std::exception& e) {
        std::cerr << "从购物车移除商品时出错: " << e.what() << std::endl;
        return createResponse(false, "从购物车移除商品时出错").dump();
    }
}

std::string ShoppingController::clearCart(const std::string& userId) {
    std::lock_guard<std::mutex> lock(cartMutex);

    try {
        if (shoppingCarts.find(userId) == shoppingCarts.end()) {
            return createResponse(false, "购物车已为空").dump();
        }

        shoppingCarts.erase(userId);
        return createResponse(true, "购物车已清空").dump();
    } catch (const std::exception& e) {
        std::cerr << "清空购物车时出错: " << e.what() << std::endl;
        return createResponse(false, "清空购物车时出错").dump();
    }
}

std::string ShoppingController::getCartSummary(const std::string& userId) {
    std::lock_guard<std::mutex> lock(cartMutex);

    try {
        if (shoppingCarts.find(userId) == shoppingCarts.end()) {
            json summary = {
                {"totalAmount", 0.0},
                {"totalItems", 0},
                {"totalQuantity", 0},
                {"isEmpty", true}
            };
            return createResponse(true, "购物车为空", summary).dump();
        }

        double totalAmount = 0.0;
        int totalItems = 0;
        int totalQuantity = 0;

        for (const auto& item : shoppingCarts[userId]) {
            totalAmount += item["price"].get<double>() * item["quantity"].get<int>();
            totalQuantity += item["quantity"].get<int>();
            totalItems++;
        }

        json summary = {
            {"totalAmount", totalAmount},
            {"totalItems", totalItems},
            {"totalQuantity", totalQuantity},
            {"isEmpty", totalItems == 0}
        };

        return createResponse(true, "成功", summary).dump();
    } catch (const std::exception& e) {
        std::cerr << "获取购物车摘要时出错: " << e.what() << std::endl;
        return createResponse(false, "获取购物车摘要时出错").dump();
    }
}

std::string ShoppingController::directPurchase(const std::string& userId, const json& orderData) {
    try {
        // 验证订单数据
        if (!orderData.contains("items") || !orderData["items"].is_array() || orderData["items"].empty()) {
            return createResponse(false, "订单必须包含商品项").dump();
        }

        // 验证每个商品项的可用性
        for (const auto& item : orderData["items"]) {
            std::string productId = item["productId"];
            int quantity = item["quantity"];

            if (!checkProductAvailability(productId, quantity)) {
                return createResponse(false, "商品 " + productId + " 不可用或库存不足").dump();
            }
        }

        // 构建完整的订单数据
        json completeOrderData = orderData;
        completeOrderData["userId"] = userId;

        // 如果没有提供用户名，使用默认值
        if (!completeOrderData.contains("userName")) {
            completeOrderData["userName"] = "用户" + userId.substr(std::max(0, (int)userId.length() - 4));
        }

        // 设置订单状态为待付款
        completeOrderData["status"] = "待付款";

        // 如果没有提供时间，设置当前时间
        if (!completeOrderData.contains("createTime")) {
            completeOrderData["createTime"] = Order::generateTimestamp();
        }

        if (!completeOrderData.contains("updateTime")) {
            completeOrderData["updateTime"] = completeOrderData["createTime"];
        }

        // 计算总金额（如果未提供）
        if (!completeOrderData.contains("totalAmount")) {
            double total = 0.0;
            for (const auto& item : completeOrderData["items"]) {
                total += item["price"].get<double>() * item["quantity"].get<int>();
            }
            completeOrderData["totalAmount"] = total;
        }

        // 调用OrderBroker创建订单
        Order order = Order::fromJson(completeOrderData.dump());

        if (!order.isValid()) {
            return createResponse(false, "订单数据无效").dump();
        }

        std::string orderId = OrderBroker::createOrder(order);

        if (!orderId.empty()) {
            Order createdOrder = OrderBroker::getOrder(orderId);

            json responseData;
            responseData["orderId"] = orderId;
            responseData["orderNumber"] = createdOrder.getOrderNumber();
            responseData["totalAmount"] = createdOrder.getTotalAmount();
            responseData["status"] = createdOrder.getStatus();
            responseData["createTime"] = createdOrder.getCreateTime();

            return createResponse(true, "订单创建成功", responseData).dump();
        } else {
            return createResponse(false, "创建订单失败").dump();
        }

    } catch (const std::exception& e) {
        std::cerr << "直接购买时出错: " << e.what() << std::endl;
        return createResponse(false, "购买失败: " + std::string(e.what())).dump();
    }
}

std::string ShoppingController::checkoutCart(const std::string& userId, const json& orderInfo) {
    try {
        std::lock_guard<std::mutex> lock(cartMutex);

        // 获取用户购物车
        if (shoppingCarts.find(userId) == shoppingCarts.end() || shoppingCarts[userId].empty()) {
            return createResponse(false, "购物车为空").dump();
        }

        const auto& cartItems = shoppingCarts[userId];

        // 验证购物车中所有商品的可用性
        for (const auto& item : cartItems) {
            std::string productId = item["productId"];
            int quantity = item["quantity"];

            if (!checkProductAvailability(productId, quantity)) {
                return createResponse(false, "商品 " + productId + " 不可用或库存不足").dump();
            }
        }

        // 构建订单数据
        json orderData;
        orderData["userId"] = userId;
        orderData["userName"] = orderInfo.value("userName", "用户" + userId.substr(std::max(0, (int)userId.length() - 4)));
        orderData["shippingAddress"] = orderInfo.value("shippingAddress", "");
        orderData["receiverName"] = orderInfo.value("receiverName", "");
        orderData["receiverPhone"] = orderInfo.value("receiverPhone", "");
        orderData["paymentMethod"] = orderInfo.value("paymentMethod", "wechat");
        orderData["buyerMessage"] = orderInfo.value("buyerMessage", "");
        orderData["status"] = "待付款";
        orderData["createTime"] = Order::generateTimestamp();
        orderData["updateTime"] = orderData["createTime"];

        // 转换购物车项为订单项
        json itemsArray = json::array();
        double totalAmount = 0.0;

        for (const auto& cartItem : cartItems) {
            json orderItem;
            orderItem["productId"] = cartItem["productId"];
            orderItem["productName"] = cartItem["productName"];
            orderItem["price"] = cartItem["price"];
            orderItem["quantity"] = cartItem["quantity"];
            orderItem["spec"] = cartItem.value("spec", "默认规格");
            orderItem["subtotal"] = cartItem["price"].get<double>() * cartItem["quantity"].get<int>();

            itemsArray.push_back(orderItem);
            totalAmount += orderItem["subtotal"].get<double>();
        }

        orderData["items"] = itemsArray;
        orderData["totalAmount"] = totalAmount;
        orderData["shippingFee"] = orderInfo.value("shippingFee", totalAmount > 99 ? 0.0 : 10.0);
        orderData["totalAmount"] = totalAmount + orderData["shippingFee"].get<double>();

        // 创建订单
        Order order = Order::fromJson(orderData.dump());

        if (!order.isValid()) {
            return createResponse(false, "订单数据无效").dump();
        }

        std::string orderId = OrderBroker::createOrder(order);

        if (!orderId.empty()) {
            // 清空购物车
            shoppingCarts.erase(userId);

            Order createdOrder = OrderBroker::getOrder(orderId);

            json responseData;
            responseData["orderId"] = orderId;
            responseData["orderNumber"] = createdOrder.getOrderNumber();
            responseData["totalAmount"] = createdOrder.getTotalAmount();
            responseData["status"] = createdOrder.getStatus();
            responseData["createTime"] = createdOrder.getCreateTime();
            responseData["message"] = "订单创建成功，购物车已清空";

            return createResponse(true, "结算成功", responseData).dump();
        } else {
            return createResponse(false, "创建订单失败").dump();
        }

    } catch (const std::exception& e) {
        std::cerr << "结算购物车时出错: " << e.what() << std::endl;
        return createResponse(false, "结算失败: " + std::string(e.what())).dump();
    }
}
