#pragma once
#include "../broker/productbroker.h"
#include <iostream>
#include <string>
#include <vector>
#include "../nlohmann/json.hpp"

class ManageProductsController {
public:
    // RESTful API接口对应的方法
    static std::string getAllProducts();
    static std::string getProductsByStatus(const std::string& status);
    static std::string getProduct(const std::string& productId);
    static std::string addProduct(const std::string& productJson);
    static std::string updateProduct(const std::string& productId, const std::string& productJson);
    static std::string deleteProduct(const std::string& productId);
    static std::string searchProducts(const std::string& keyword);
    static std::string getProductCounts();
    static std::string toggleProductStatus(const std::string& productId, const std::string& currentStatus);
    static std::string getCategories();

private:
    static nlohmann::json productToJson(const Product& product);
    static nlohmann::json createResponse(bool success, const std::string& message = "", const nlohmann::json& data = nullptr);
};
