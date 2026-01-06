#include "productbroker.h"
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

std::unordered_map<std::string, Product> ProductBroker::productStore;
std::mutex ProductBroker::storeMutex;
int ProductBroker::nextProductId = 1;

std::string ProductBroker::addProduct(const Product& product) {
    std::lock_guard<std::mutex> lock(storeMutex);

    std::string productId = generateProductId();
    Product newProduct = product;
    newProduct.setProductId(productId);

    productStore[productId] = newProduct;
    nextProductId++;

    std::cout << "商品已添加: " << productId << " - " << newProduct.getName() << std::endl;
    return productId;
}

bool ProductBroker::updateProduct(const std::string& productId, const Product& product) {
    std::lock_guard<std::mutex> lock(storeMutex);

    if (productStore.find(productId) == productStore.end()) {
        return false;
    }

    productStore[productId] = product;
    productStore[productId].setProductId(productId); // 确保ID不变
    productStore[productId].setUpdateTime(Product().generateTimestamp());

    std::cout << "商品已更新: " << productId << std::endl;
    return true;
}

bool ProductBroker::deleteProduct(const std::string& productId) {
    std::lock_guard<std::mutex> lock(storeMutex);

    auto it = productStore.find(productId);
    if (it == productStore.end()) {
        return false;
    }

    productStore.erase(it);
    std::cout << "商品已删除: " << productId << std::endl;
    return true;
}

Product ProductBroker::getProduct(const std::string& productId) {
    std::lock_guard<std::mutex> lock(storeMutex);

    auto it = productStore.find(productId);
    if (it != productStore.end()) {
        return it->second;
    }

    return Product(); // 返回空产品
}

std::vector<Product> ProductBroker::getAllProducts() {
    std::lock_guard<std::mutex> lock(storeMutex);

    std::vector<Product> products;
    for (const auto& pair : productStore) {
        products.push_back(pair.second);
    }

    // 按更新时间倒序排序
    std::sort(products.begin(), products.end(),
              [](const Product& a, const Product& b) {
                  return a.getUpdateTime() > b.getUpdateTime();
              });

    return products;
}

std::vector<Product> ProductBroker::getProductsByStatus(const std::string& status) {
    std::lock_guard<std::mutex> lock(storeMutex);

    std::vector<Product> filteredProducts;
    for (const auto& pair : productStore) {
        if (pair.second.getStatus() == status) {
            filteredProducts.push_back(pair.second);
        }
    }

    // 按更新时间倒序排序
    std::sort(filteredProducts.begin(), filteredProducts.end(),
              [](const Product& a, const Product& b) {
                  return a.getUpdateTime() > b.getUpdateTime();
              });

    return filteredProducts;
}

std::vector<Product> ProductBroker::searchProducts(const std::string& keyword) {
    std::lock_guard<std::mutex> lock(storeMutex);

    std::vector<Product> results;
    std::string lowerKeyword;
    std::transform(keyword.begin(), keyword.end(),
                   std::back_inserter(lowerKeyword), ::tolower);

    for (const auto& pair : productStore) {
        const Product& product = pair.second;

        // 在名称、ID、分类中搜索
        std::string lowerName = product.getName();
        std::transform(lowerName.begin(), lowerName.end(),
                       lowerName.begin(), ::tolower);

        std::string lowerCategory = product.getCategory();
        std::transform(lowerCategory.begin(), lowerCategory.end(),
                       lowerCategory.begin(), ::tolower);

        std::string lowerId = product.getProductId();
        std::transform(lowerId.begin(), lowerId.end(),
                       lowerId.begin(), ::tolower);

        if (lowerName.find(lowerKeyword) != std::string::npos ||
            lowerCategory.find(lowerKeyword) != std::string::npos ||
            lowerId.find(lowerKeyword) != std::string::npos) {
            results.push_back(product);
        }
    }

    return results;
}

int ProductBroker::getProductCountByStatus(const std::string& status) {
    std::lock_guard<std::mutex> lock(storeMutex);

    int count = 0;
    for (const auto& pair : productStore) {
        if (pair.second.getStatus() == status) {
            count++;
        }
    }

    return count;
}

std::vector<std::string> ProductBroker::getCategories() {
    std::lock_guard<std::mutex> lock(storeMutex);

    std::vector<std::string> categories;
    for (const auto& pair : productStore) {
        const std::string& category = pair.second.getCategory();
        if (std::find(categories.begin(), categories.end(), category) == categories.end()) {
            categories.push_back(category);
        }
    }

    return categories;
}

std::string ProductBroker::generateProductId() {
    return "P" + std::to_string(nextProductId);
}

