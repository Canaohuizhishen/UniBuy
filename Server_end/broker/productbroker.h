#pragma once
#include "../entities/product.h"
#include <iostream>
#include <algorithm>
#include <cctype>
#include <string>
#include <vector>
#include <unordered_map>
#include <mutex>
#include <chrono>
#include <ctime>
#include <iomanip>
#include <sstream>

class ProductBroker {
private:
    static std::unordered_map<std::string, Product> productStore;
    static std::mutex storeMutex;
    static int nextProductId;

public:
    // 商品管理方法
    static std::string addProduct(const Product& product);
    static bool updateProduct(const std::string& productId, const Product& product);
    static bool deleteProduct(const std::string& productId);
    static Product getProduct(const std::string& productId);
    static std::vector<Product> getAllProducts();
    static std::vector<Product> getProductsByStatus(const std::string& status);
    static std::vector<Product> searchProducts(const std::string& keyword);

    // 统计方法
    static int getProductCountByStatus(const std::string& status);
    static std::vector<std::string> getCategories();

private:
    static std::string generateProductId();
};
