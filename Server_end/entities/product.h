#pragma once

#include <iostream>
#include <sstream>
#include <iomanip>
#include <ctime>
#include <algorithm>
#include <vector>
#include <string>
#include <chrono>

class ProductSKU;

class Product {
private:
    std::string productId;
    std::string name;
    std::string category;
    double price;
    double originalPrice;
    int stock;
    std::string description;
    std::vector<std::string> images;
    std::vector<std::string> tags;
    std::string status; // 出售中、已下架、已售罄、待审核
    int sales;
    std::string createTime;
    std::string updateTime;
    std::vector<ProductSKU> skuList;

public:
    // 构造与析构
    Product();
    Product(const std::string& name, const std::string& category, double price, int stock);

    // Getter 方法
    std::string getProductId() const;
    std::string getName() const;
    std::string getCategory() const;
    double getPrice() const;
    double getOriginalPrice() const;
    int getStock() const;
    std::string getDescription() const;
    std::vector<std::string> getImages() const;
    std::vector<std::string> getTags() const;
    std::string getStatus() const;
    int getSales() const;
    std::string getCreateTime() const;
    std::string getUpdateTime() const;
    std::vector<ProductSKU> getSkuList() const;

    // Setter 方法
    void setProductId(const std::string& id);
    void setName(const std::string& name);
    void setCategory(const std::string& category);
    void setPrice(double price);
    void setOriginalPrice(double originalPrice);
    void setStock(int stock);
    void setDescription(const std::string& description);
    void setImages(const std::vector<std::string>& images);
    void setTags(const std::vector<std::string>& tags);
    void setStatus(const std::string& status);
    void setSales(int sales);
    void setUpdateTime(const std::string& time);
    void setSkuList(const std::vector<ProductSKU>& skuList);
    void setCreateTime(const std::string& time);

    // 业务方法
    void updateStock(int quantity);
    void increaseSales(int quantity);
    bool isAvailable() const;
    std::string toJson() const;
    static Product fromJson(const std::string& jsonStr, bool keepOriginalStatus = false);
    static std::string getCurrentTimestamp();// 获取时间戳
    std::string generateTimestamp();
};

// SKU子类
class ProductSKU {
private:
    std::string skuId;
    std::string spec;
    double price;
    int stock;

public:
    ProductSKU();
    ProductSKU(const std::string& spec, double price, int stock);

    std::string getSkuId() const;
    std::string getSpec() const;
    double getPrice() const;
    int getStock() const;

    void setSkuId(const std::string& id);
    void setSpec(const std::string& spec);
    void setPrice(double price);
    void setStock(int stock);
};
