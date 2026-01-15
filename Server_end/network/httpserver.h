#pragma once
#include <iostream>
#include <string>
#include <vector>
#include <chrono>
#include <ctime>
#include "../network/httplib.h"
#include "../controllers/manageproductscontroller.h"

using namespace httplib;

class HTTPServer {
private:
    Server svr;
    int port;

    // 路由处理函数
    void setupRoutes();  // 设置所有路由规则
    void handleOptionsRequest(const Request& req, Response& res);  // 处理跨域OPTIONS请求
    void handleSearchProducts(const Request& req, Response& res);  // 处理商品搜索请求
    void handleGetProduct(const Request& req, Response& res);  // 处理获取单个商品请求
    void handleGetProducts(const Request& req, Response& res);  // 处理获取商品列表请求
    void handleAddProduct(const Request& req, Response& res);  // 处理添加商品请求
    void handleUpdateProduct(const Request& req, Response& res);  // 处理更新商品请求
    void handleDeleteProduct(const Request& req, Response& res);  // 处理删除商品请求
    void handleToggleProductStatus(const Request& req, Response& res);  // 处理切换商品状态请求
    void handleGetProductCounts(const Request& req, Response& res);  // 处理获取商品统计请求
    void handleGetCategories(const Request& req, Response& res);  // 处理获取商品分类请求
    void handleHealthCheck(const Request& req, Response& res);  // 处理健康检查请求

    // 订单管理路由处理函数
    void handleGetOrders(const Request& req, Response& res);
    void handleGetOrder(const Request& req, Response& res);
    void handleCreateOrder(const Request& req, Response& res);
    void handleUpdateOrder(const Request& req, Response& res);
    void handleDeleteOrder(const Request& req, Response& res);
    void handleShipOrder(const Request& req, Response& res);
    void handleCancelOrder(const Request& req, Response& res);
    void handleCompleteOrder(const Request& req, Response& res);
    void handleRefundOrder(const Request& req, Response& res);
    void handleSearchOrders(const Request& req, Response& res);
    void handleGetOrderCounts(const Request& req, Response& res);
    void handleGetOrdersByDateRange(const Request& req, Response& res);
    void handleGetOrdersByUser(const Request& req, Response& res);

public:
    HTTPServer(int port = 8080);
    void start();
    void stop();
};
