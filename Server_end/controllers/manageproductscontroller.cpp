#include "manageproductscontroller.h"
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>

using json = nlohmann::json;

json ManageProductsController::productToJson(const Product& product) {
    return json::parse(product.toJson());
}

json ManageProductsController::createResponse(bool success, const std::string& message, const json& data) {
    json response;
    response["success"] = success;
    response["message"] = message;
    if (data != nullptr) {
        response["data"] = data;
    }
    return response;
}

std::string ManageProductsController::getAllProducts() {
    try {
        std::vector<Product> products = ProductBroker::getAllProducts();
        json productsArray = json::array();

        for (const auto& product : products) {
            productsArray.push_back(productToJson(product));
        }

        return createResponse(true, "成功", productsArray).dump();
    } catch (const std::exception& e) {
        std::cerr << "获取所有商品时出错: " << e.what() << std::endl;
        return createResponse(false, "获取商品时出错").dump();
    }
}

std::string ManageProductsController::getProductsByStatus(const std::string& status) {
    try {
        std::vector<Product> products = ProductBroker::getProductsByStatus(status);
        json productsArray = json::array();

        for (const auto& product : products) {
            productsArray.push_back(productToJson(product));
        }

        return createResponse(true, "成功", productsArray).dump();
    } catch (const std::exception& e) {
        std::cerr << "按状态获取商品时出错: " << e.what() << std::endl;
        return createResponse(false, "获取商品时出错").dump();
    }
}

std::string ManageProductsController::getProduct(const std::string& productId) {
    try {
        Product product = ProductBroker::getProduct(productId);
        if (product.getProductId().empty()) {
            return createResponse(false, "商品未找到").dump();
        }

        return createResponse(true, "成功", productToJson(product)).dump();
    } catch (const std::exception& e) {
        std::cerr << "获取商品时出错: " << e.what() << std::endl;
        return createResponse(false, "获取商品时出错").dump();
    }
}

std::string ManageProductsController::addProduct(const std::string& productJson) {
    try {
        Product product = Product::fromJson(productJson, false);

        // 根据库存自动设置状态（如果未提供状态）
        if (product.getStatus().empty()) {
            if (product.getStock() <= 0) {
                product.setStatus("已售罄");
            } else {
                product.setStatus("出售中");
            }
        }

        std::string productId = ProductBroker::addProduct(product);

        if (!productId.empty()) {
            Product createdProduct = ProductBroker::getProduct(productId);
            return createResponse(true, "商品添加成功", productToJson(createdProduct)).dump();
        } else {
            return createResponse(false, "添加商品失败").dump();
        }
    } catch (const std::exception& e) {
        std::cerr << "添加商品时出错: " << e.what() << std::endl;
        return createResponse(false, "添加商品时出错: " + std::string(e.what())).dump();
    }
}

std::string ManageProductsController::updateProduct(const std::string& productId, const std::string& productJson) {
    try {
        std::cout << "调用UpdateProduct - 商品ID: " << productId << std::endl;
        std::cout << "商品JSON数据: " << productJson << std::endl;

        // 获取现有商品以保留状态
        Product existingProduct = ProductBroker::getProduct(productId);
        if (existingProduct.getProductId().empty()) {
            return createResponse(false, "商品未找到").dump();
        }

        // 使用新的fromJson方法，保留原始状态
        Product updatedProduct = Product::fromJson(productJson, true);  // 传递 true
        updatedProduct.setProductId(productId);

        // 如果没有提供新状态，使用原始状态
        if (updatedProduct.getStatus().empty()) {
            updatedProduct.setStatus(existingProduct.getStatus());
        }

        // 如果是出售中状态，检查库存并可能更新状态
        if (updatedProduct.getStatus() == "出售中" && updatedProduct.getStock() <= 0) {
            updatedProduct.setStatus("已售罄");
        }
        // 如果已售罄但库存恢复了，可以自动改为出售中
        else if (updatedProduct.getStatus() == "已售罄" && updatedProduct.getStock() > 0) {
            updatedProduct.setStatus("出售中");
        }

        bool success = ProductBroker::updateProduct(productId, updatedProduct);
        if (success) {
            Product resultProduct = ProductBroker::getProduct(productId);
            return createResponse(true, "商品更新成功", productToJson(resultProduct)).dump();
        } else {
            return createResponse(false, "商品未找到").dump();
        }
    } catch (const std::exception& e) {
        std::cerr << "更新商品时出错: " << e.what() << std::endl;
        return createResponse(false, "更新商品时出错: " + std::string(e.what())).dump();
    }
}

std::string ManageProductsController::deleteProduct(const std::string& productId) {
    try {
        bool success = ProductBroker::deleteProduct(productId);
        if (success) {
            return createResponse(true, "商品删除成功").dump();
        } else {
            return createResponse(false, "商品未找到").dump();
        }
    } catch (const std::exception& e) {
        std::cerr << "删除商品时出错: " << e.what() << std::endl;
        return createResponse(false, "删除商品时出错").dump();
    }
}

std::string ManageProductsController::searchProducts(const std::string& keyword) {
    try {
        std::vector<Product> products = ProductBroker::searchProducts(keyword);
        json productsArray = json::array();

        for (const auto& product : products) {
            productsArray.push_back(productToJson(product));
        }

        return createResponse(true, "成功", productsArray).dump();
    } catch (const std::exception& e) {
        std::cerr << "搜索商品时出错: " << e.what() << std::endl;
        return createResponse(false, "搜索商品时出错").dump();
    }
}

std::string ManageProductsController::getProductCounts() {
    try {
        json counts;
        counts["出售中"] = ProductBroker::getProductCountByStatus("出售中");
        counts["已下架"] = ProductBroker::getProductCountByStatus("已下架");
        counts["已售罄"] = ProductBroker::getProductCountByStatus("已售罄");
        counts["待审核"] = ProductBroker::getProductCountByStatus("待审核");
        counts["全部"] = ProductBroker::getAllProducts().size();

        return createResponse(true, "成功", counts).dump();
    } catch (const std::exception& e) {
        std::cerr << "获取商品数量统计时出错: " << e.what() << std::endl;
        return createResponse(false, "获取商品数量统计时出错").dump();
    }
}

std::string ManageProductsController::toggleProductStatus(const std::string& productId, const std::string& currentStatus) {
    try {
        std::cout << "调用ToggleProductStatus - 商品ID: " << productId
                  << ", 当前状态: " << currentStatus << std::endl;

        Product product = ProductBroker::getProduct(productId);
        if (product.getProductId().empty()) {
            std::cout << "商品未找到: " << productId << std::endl;
            return createResponse(false, "商品未找到").dump();
        }

        std::string newStatus;
        if (currentStatus == "出售中") {
            newStatus = "已下架";
        } else if (currentStatus == "已下架" || currentStatus == "已售罄") {
            newStatus = "出售中";
        } else if (currentStatus == "待审核") {
            return createResponse(false, "商品正在审核中，请等待审核结果").dump();
        } else {
            newStatus = "出售中";
        }

        std::cout << "将状态从 " << currentStatus << " 更改为 " << newStatus << std::endl;

        product.setStatus(newStatus);
        ProductBroker::updateProduct(productId, product);

        return createResponse(true, "状态已更新", productToJson(product)).dump();
    } catch (const std::exception& e) {
        std::cerr << "切换商品状态时出错: " << e.what() << std::endl;
        return createResponse(false, "切换商品状态时出错").dump();
    }
}

std::string ManageProductsController::getCategories() {
    try {
        std::vector<std::string> categories = ProductBroker::getCategories();
        json categoriesArray = json::array();

        for (const auto& category : categories) {
            categoriesArray.push_back(category);
        }

        return createResponse(true, "成功", categoriesArray).dump();
    } catch (const std::exception& e) {
        std::cerr << "获取商品分类时出错: " << e.what() << std::endl;
        return createResponse(false, "获取商品分类时出错").dump();
    }
}
