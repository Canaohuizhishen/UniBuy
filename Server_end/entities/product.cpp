#include "product.h"
#include <iostream>
#include <sstream>
#include <iomanip>
#include <ctime>
#include <algorithm>
#include "../nlohmann/json.hpp"

using json = nlohmann::json;

// Product 类实现
Product::Product() : price(0.0), originalPrice(0.0), stock(0), sales(0) {
    createTime = generateTimestamp();
    updateTime = createTime;
    status = "待审核";
}

Product::Product(const std::string& name, const std::string& category,
                 double price, int stock)
    : name(name), category(category), price(price), stock(stock),
    originalPrice(0.0), sales(0) {
    createTime = generateTimestamp();
    updateTime = createTime;
    status = "待审核";
}

// Getter 实现
std::string Product::getProductId() const { return productId; }
std::string Product::getName() const { return name; }
std::string Product::getCategory() const { return category; }
double Product::getPrice() const { return price; }
double Product::getOriginalPrice() const { return originalPrice; }
int Product::getStock() const { return stock; }
std::string Product::getDescription() const { return description; }
std::vector<std::string> Product::getImages() const { return images; }
std::vector<std::string> Product::getTags() const { return tags; }
std::string Product::getStatus() const { return status; }
int Product::getSales() const { return sales; }
std::string Product::getCreateTime() const { return createTime; }
std::string Product::getUpdateTime() const { return updateTime; }
std::vector<ProductSKU> Product::getSkuList() const { return skuList; }

// Setter 实现
void Product::setProductId(const std::string& id) { productId = id; }
void Product::setName(const std::string& name) { this->name = name; updateTime = generateTimestamp(); }
void Product::setCategory(const std::string& category) { this->category = category; updateTime = generateTimestamp(); }
void Product::setPrice(double price) { this->price = price; updateTime = generateTimestamp(); }
void Product::setOriginalPrice(double originalPrice) { this->originalPrice = originalPrice; updateTime = generateTimestamp(); }
void Product::setStock(int stock) { this->stock = stock; updateTime = generateTimestamp(); }
void Product::setDescription(const std::string& description) { this->description = description; updateTime = generateTimestamp(); }
void Product::setImages(const std::vector<std::string>& images) { this->images = images; updateTime = generateTimestamp(); }
void Product::setTags(const std::vector<std::string>& tags) { this->tags = tags; updateTime = generateTimestamp(); }
void Product::setStatus(const std::string& status) { this->status = status; updateTime = generateTimestamp(); }
void Product::setSales(int sales) { this->sales = sales; updateTime = generateTimestamp(); }
void Product::setUpdateTime(const std::string& time) { updateTime = time; }
void Product::setSkuList(const std::vector<ProductSKU>& skuList) { this->skuList = skuList; updateTime = generateTimestamp(); }
void Product::setCreateTime(const std::string& time) {createTime = time;}

// 业务方法
void Product::updateStock(int quantity) {
    if (stock + quantity >= 0) {
        stock += quantity;
        updateTime = generateTimestamp();
    }
}

void Product::increaseSales(int quantity) {
    sales += quantity;
    updateTime = generateTimestamp();
}

bool Product::isAvailable() const {
    return status == "出售中" && stock > 0;
}

std::string Product::toJson() const {
    json j;
    j["productId"] = productId;
    j["name"] = name;
    j["category"] = category;
    j["price"] = price;
    j["originalPrice"] = originalPrice;
    j["stock"] = stock;
    j["description"] = description;
    j["images"] = images;
    j["tags"] = tags;
    j["status"] = status;
    j["sales"] = sales;
    j["createTime"] = createTime;
    j["updateTime"] = updateTime;

    // 转换SKU列表
    json skuArray = json::array();
    for (const auto& sku : skuList) {
        json skuJson;
        skuJson["skuId"] = sku.getSkuId();
        skuJson["spec"] = sku.getSpec();
        skuJson["price"] = sku.getPrice();
        skuJson["stock"] = sku.getStock();
        skuArray.push_back(skuJson);
    }
    j["skuList"] = skuArray;

    return j.dump();
}

Product Product::fromJson(const std::string& jsonStr, bool keepOriginalStatus) {
    Product product;
    try {
        json j = json::parse(jsonStr);

        product.setProductId(j.value("productId", ""));
        product.setName(j.value("name", ""));
        product.setCategory(j.value("category", ""));
        product.setPrice(j.value("price", 0.0));
        product.setOriginalPrice(j.value("originalPrice", 0.0));
        product.setStock(j.value("stock", 0));
        product.setDescription(j.value("description", ""));

        if (j.contains("images")) {
            std::vector<std::string> images;
            for (const auto& img : j["images"]) {
                images.push_back(img.get<std::string>());
            }
            product.setImages(images);
        }

        if (j.contains("tags")) {
            std::vector<std::string> tags;
            for (const auto& tag : j["tags"]) {
                tags.push_back(tag.get<std::string>());
            }
            product.setTags(tags);
        }

        // 处理状态字段
        if (j.contains("status")) {
            product.setStatus(j["status"].get<std::string>());
        } else if (!keepOriginalStatus) {
            // 如果不是保留原始状态，且没有提供状态，则设置为默认状态
            product.setStatus("出售中");
        }
        // 如果 keepOriginalStatus 为 true 且没有提供状态，则什么都不做

        product.setSales(j.value("sales", 0));
        product.setCreateTime(j.value("createTime", ""));
        product.setUpdateTime(j.value("updateTime", ""));

        // 解析SKU列表
        if (j.contains("skuList")) {
            std::vector<ProductSKU> skuList;
            for (const auto& skuJson : j["skuList"]) {
                ProductSKU sku;
                sku.setSkuId(skuJson.value("skuId", ""));
                sku.setSpec(skuJson.value("spec", ""));
                sku.setPrice(skuJson.value("price", 0.0));
                sku.setStock(skuJson.value("stock", 0));
                skuList.push_back(sku);
            }
            product.setSkuList(skuList);
        }
    } catch (const std::exception& e) {
        std::cerr << "Error parsing product JSON: " << e.what() << std::endl;
    }
    return product;
}

std::string Product::getCurrentTimestamp() {
    auto now = std::chrono::system_clock::now();
    auto now_time_t = std::chrono::system_clock::to_time_t(now);
    auto now_tm = *std::localtime(&now_time_t);

    std::ostringstream oss;
    oss << std::put_time(&now_tm, "%Y-%m-%d %H:%M:%S");
    return oss.str();
}

std::string Product::generateTimestamp() {
    auto now = std::time(nullptr);
    auto tm = *std::localtime(&now);
    std::ostringstream oss;
    oss << std::put_time(&tm, "%Y-%m-%d %H:%M:%S");
    return oss.str();
}

// ProductSKU 类实现
ProductSKU::ProductSKU() : price(0.0), stock(0) {}
ProductSKU::ProductSKU(const std::string& spec, double price, int stock)
    : spec(spec), price(price), stock(stock) {}

std::string ProductSKU::getSkuId() const { return skuId; }
std::string ProductSKU::getSpec() const { return spec; }
double ProductSKU::getPrice() const { return price; }
int ProductSKU::getStock() const { return stock; }

void ProductSKU::setSkuId(const std::string& id) { skuId = id; }
void ProductSKU::setSpec(const std::string& spec) { this->spec = spec; }
void ProductSKU::setPrice(double price) { this->price = price; }
void ProductSKU::setStock(int stock) { this->stock = stock; }

