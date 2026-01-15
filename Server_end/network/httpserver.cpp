#include "httpserver.h"
#include "../controllers/manageordercontroller.h"

using json = nlohmann::json;

HTTPServer::HTTPServer(int port) : port(port) {
    setupRoutes();
}

void HTTPServer::setupRoutes() {
    // 启用CORS
    svr.set_default_headers({
        {"Access-Control-Allow-Origin", "*"},
        {"Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS"},
        {"Access-Control-Allow-Headers", "Content-Type"}
    });

    // 处理OPTIONS请求
    svr.Options(R"(/api/.*)", [this](const Request& req, Response& res) {
        handleOptionsRequest(req, res);
    });

    // 商品管理API

    // 搜索商品
    svr.Get("/api/products/search", [this](const Request& req, Response& res) {
        handleSearchProducts(req, res);
    });

    // 获取单个商品
    svr.Get(R"(/api/products/([A-Za-z0-9]+))", [this](const Request& req, Response& res) {
        handleGetProduct(req, res);
    });

    // 获取所有商品
    svr.Get("/api/products", [this](const Request& req, Response& res) {
        handleGetProducts(req, res);
    });

    // 添加商品
    svr.Post("/api/products", [this](const Request& req, Response& res) {
        handleAddProduct(req, res);
    });

    // 更新商品
    svr.Put(R"(/api/products/([A-Za-z0-9]+))", [this](const Request& req, Response& res) {
        handleUpdateProduct(req, res);
    });

    // 删除商品
    svr.Delete(R"(/api/products/([A-Za-z0-9]+))", [this](const Request& req, Response& res) {
        handleDeleteProduct(req, res);
    });

    // 切换商品状态
    svr.Post(R"(/api/products/([A-Za-z0-9]+)/toggle-status)", [this](const Request& req, Response& res) {
        handleToggleProductStatus(req, res);
    });

    // 获取商品统计
    svr.Get("/api/products/stats/counts", [this](const Request& req, Response& res) {
        handleGetProductCounts(req, res);
    });

    // 获取商品分类
    svr.Get("/api/products/categories", [this](const Request& req, Response& res) {
        handleGetCategories(req, res);
    });

    // 健康检查
    svr.Get("/health", [this](const Request& req, Response& res) {
        handleHealthCheck(req, res);
    });

    // 订单管理API

    // 获取所有订单
    svr.Get("/api/orders", [this](const Request& req, Response& res) {
        handleGetOrders(req, res);
    });

    // 获取单个订单
    svr.Get(R"(/api/orders/([A-Za-z0-9]+))", [this](const Request& req, Response& res) {
        handleGetOrder(req, res);
    });

    // 创建订单
    svr.Post("/api/orders", [this](const Request& req, Response& res) {
        handleCreateOrder(req, res);
    });

    // 更新订单
    svr.Put(R"(/api/orders/([A-Za-z0-9]+))", [this](const Request& req, Response& res) {
        handleUpdateOrder(req, res);
    });

    // 删除订单
    svr.Delete(R"(/api/orders/([A-Za-z0-9]+))", [this](const Request& req, Response& res) {
        handleDeleteOrder(req, res);
    });

    // 发货订单
    svr.Post(R"(/api/orders/([A-Za-z0-9]+)/ship)", [this](const Request& req, Response& res) {
        handleShipOrder(req, res);
    });

    // 取消订单
    svr.Post(R"(/api/orders/([A-Za-z0-9]+)/cancel)", [this](const Request& req, Response& res) {
        handleCancelOrder(req, res);
    });

    // 完成订单
    svr.Post(R"(/api/orders/([A-Za-z0-9]+)/complete)", [this](const Request& req, Response& res) {
        handleCompleteOrder(req, res);
    });

    // 申请退款
    svr.Post(R"(/api/orders/([A-Za-z0-9]+)/refund)", [this](const Request& req, Response& res) {
        handleRefundOrder(req, res);
    });

    // 搜索订单
    svr.Get("/api/orders/search", [this](const Request& req, Response& res) {
        handleSearchOrders(req, res);
    });

    // 获取订单统计
    svr.Get("/api/orders/stats/counts", [this](const Request& req, Response& res) {
        handleGetOrderCounts(req, res);
    });

    // 按日期范围获取订单
    svr.Get("/api/orders/by-date", [this](const Request& req, Response& res) {
        handleGetOrdersByDateRange(req, res);
    });

    // 获取用户订单
    svr.Get(R"(/api/orders/user/([A-Za-z0-9]+))", [this](const Request& req, Response& res) {
        handleGetOrdersByUser(req, res);
    });
}

void HTTPServer::handleOptionsRequest(const Request& req, Response& res) {
    res.set_header("Access-Control-Allow-Origin", "*");
    res.set_header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    res.set_header("Access-Control-Allow-Headers", "Content-Type");
    res.status = 204;
}

void HTTPServer::handleSearchProducts(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    std::string keyword = req.get_param_value("keyword");
    if (!keyword.empty()) {
        res.set_content(ManageProductsController::searchProducts(keyword), "application/json");
    } else {
        nlohmann::json response;
        response["success"] = false;
        response["message"] = "必须提供关键字参数";
        res.set_content(response.dump(), "application/json");
    }
}

void HTTPServer::handleGetProduct(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    std::string productId = req.matches[1];
    res.set_content(ManageProductsController::getProduct(productId), "application/json");
}

void HTTPServer::handleGetProducts(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    std::string status = req.get_param_value("status");

    if (!status.empty()) {
        res.set_content(ManageProductsController::getProductsByStatus(status), "application/json");
    } else {
        res.set_content(ManageProductsController::getAllProducts(), "application/json");
    }
}

void HTTPServer::handleAddProduct(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    if (req.has_header("Content-Type") &&
        req.get_header_value("Content-Type").find("application/json") != std::string::npos) {
        res.set_content(ManageProductsController::addProduct(req.body), "application/json");
    } else {
        nlohmann::json response;
        response["success"] = false;
        response["message"] = "Content-Type 必须为 application/json";
        res.set_content(response.dump(), "application/json");
    }
}

void HTTPServer::handleUpdateProduct(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    if (req.has_header("Content-Type") &&
        req.get_header_value("Content-Type").find("application/json") != std::string::npos) {
        std::string productId = req.matches[1];
        res.set_content(ManageProductsController::updateProduct(productId, req.body), "application/json");
    } else {
        nlohmann::json response;
        response["success"] = false;
        response["message"] = "Content-Type 必须为 application/json";
        res.set_content(response.dump(), "application/json");
    }
}

void HTTPServer::handleDeleteProduct(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    std::string productId = req.matches[1];
    res.set_content(ManageProductsController::deleteProduct(productId), "application/json");
}

void HTTPServer::handleToggleProductStatus(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    std::string productId = req.matches[1];

    if (req.has_header("Content-Type") &&
        req.get_header_value("Content-Type").find("application/json") != std::string::npos) {
        try {
            nlohmann::json body = nlohmann::json::parse(req.body);
            std::string currentStatus = body.value("currentStatus", "");

            if (!currentStatus.empty()) {
                res.set_content(ManageProductsController::toggleProductStatus(productId, currentStatus),
                                "application/json");
            } else {
                nlohmann::json response;
                response["success"] = false;
                response["message"] = "必须提供currentStatus";
                res.set_content(response.dump(), "application/json");
            }
        } catch (const std::exception& e) {
            nlohmann::json response;
            response["success"] = false;
            response["message"] = "无效的JSON: " + std::string(e.what());
            res.set_content(response.dump(), "application/json");
        }
    } else {
        nlohmann::json response;
        response["success"] = false;
        response["message"] = "Content-Type必须为application/json";
        res.set_content(response.dump(), "application/json");
    }
}

void HTTPServer::handleGetProductCounts(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    res.set_content(ManageProductsController::getProductCounts(), "application/json");
}

void HTTPServer::handleGetCategories(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    res.set_content(ManageProductsController::getCategories(), "application/json");
}

void HTTPServer::start() {
    std::cout << "正在启动 UniBuy 服务器，端口 " << port << "..." << std::endl;
    svr.listen("0.0.0.0", port);
}

void HTTPServer::stop() {
    svr.stop();
    std::cout << "UniBuy 服务器已停止" << std::endl;
}

void HTTPServer::handleHealthCheck(const Request& req, Response& res) {
    res.set_content("UniBuy 服务器正在运行", "text/plain");
}

void HTTPServer::handleGetOrders(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    std::string status = req.get_param_value("status");

    if (!status.empty()) {
        res.set_content(OrderManagementController::getOrdersByStatus(status), "application/json");
    } else {
        res.set_content(OrderManagementController::getAllOrders(), "application/json");
    }
}

void HTTPServer::handleGetOrder(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    std::string orderId = req.matches[1];
    res.set_content(OrderManagementController::getOrder(orderId), "application/json");
}

void HTTPServer::handleCreateOrder(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    if (req.has_header("Content-Type") &&
        req.get_header_value("Content-Type").find("application/json") != std::string::npos) {
        res.set_content(OrderManagementController::createOrder(req.body), "application/json");
    } else {
        json response;
        response["success"] = false;
        response["message"] = "Content-Type 必须为 application/json";
        res.set_content(response.dump(), "application/json");
    }
}

void HTTPServer::handleUpdateOrder(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    if (req.has_header("Content-Type") &&
        req.get_header_value("Content-Type").find("application/json") != std::string::npos) {
        std::string orderId = req.matches[1];
        res.set_content(OrderManagementController::updateOrder(orderId, req.body), "application/json");
    } else {
        json response;
        response["success"] = false;
        response["message"] = "Content-Type 必须为 application/json";
        res.set_content(response.dump(), "application/json");
    }
}

void HTTPServer::handleDeleteOrder(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    std::string orderId = req.matches[1];
    res.set_content(OrderManagementController::deleteOrder(orderId), "application/json");
}

void HTTPServer::handleShipOrder(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    std::string orderId = req.matches[1];

    if (req.has_header("Content-Type") &&
        req.get_header_value("Content-Type").find("application/json") != std::string::npos) {
        try {
            json body = json::parse(req.body);
            std::string logisticsCompany = body.value("logisticsCompany", "");
            std::string trackingNumber = body.value("trackingNumber", "");

            if (!logisticsCompany.empty() && !trackingNumber.empty()) {
                res.set_content(OrderManagementController::shipOrder(orderId, logisticsCompany, trackingNumber),
                                "application/json");
            } else {
                json response;
                response["success"] = false;
                response["message"] = "必须提供物流公司和运单号";
                res.set_content(response.dump(), "application/json");
            }
        } catch (const std::exception& e) {
            json response;
            response["success"] = false;
            response["message"] = "无效的JSON: " + std::string(e.what());
            res.set_content(response.dump(), "application/json");
        }
    } else {
        json response;
        response["success"] = false;
        response["message"] = "Content-Type必须为application/json";
        res.set_content(response.dump(), "application/json");
    }
}

void HTTPServer::handleCancelOrder(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    std::string orderId = req.matches[1];

    std::string reason = "";
    if (req.has_header("Content-Type") &&
        req.get_header_value("Content-Type").find("application/json") != std::string::npos) {
        try {
            json body = json::parse(req.body);
            reason = body.value("reason", "");
        } catch (...) {
            // 如果JSON解析失败，忽略reason
        }
    }

    res.set_content(OrderManagementController::cancelOrder(orderId, reason), "application/json");
}

void HTTPServer::handleCompleteOrder(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    std::string orderId = req.matches[1];
    res.set_content(OrderManagementController::completeOrder(orderId), "application/json");
}

void HTTPServer::handleRefundOrder(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    std::string orderId = req.matches[1];

    if (req.has_header("Content-Type") &&
        req.get_header_value("Content-Type").find("application/json") != std::string::npos) {
        try {
            json body = json::parse(req.body);
            std::string reason = body.value("reason", "");

            if (!reason.empty()) {
                res.set_content(OrderManagementController::refundOrder(orderId, reason),
                                "application/json");
            } else {
                json response;
                response["success"] = false;
                response["message"] = "必须提供退款原因";
                res.set_content(response.dump(), "application/json");
            }
        } catch (const std::exception& e) {
            json response;
            response["success"] = false;
            response["message"] = "无效的JSON: " + std::string(e.what());
            res.set_content(response.dump(), "application/json");
        }
    } else {
        json response;
        response["success"] = false;
        response["message"] = "Content-Type必须为application/json";
        res.set_content(response.dump(), "application/json");
    }
}

void HTTPServer::handleSearchOrders(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    std::string keyword = req.get_param_value("keyword");
    if (!keyword.empty()) {
        res.set_content(OrderManagementController::searchOrders(keyword), "application/json");
    } else {
        json response;
        response["success"] = false;
        response["message"] = "必须提供关键字参数";
        res.set_content(response.dump(), "application/json");
    }
}

void HTTPServer::handleGetOrderCounts(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    res.set_content(OrderManagementController::getOrderCounts(), "application/json");
}

void HTTPServer::handleGetOrdersByDateRange(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    std::string startDate = req.get_param_value("startDate");
    std::string endDate = req.get_param_value("endDate");

    if (!startDate.empty() && !endDate.empty()) {
        res.set_content(OrderManagementController::getOrdersByDateRange(startDate, endDate), "application/json");
    } else {
        json response;
        response["success"] = false;
        response["message"] = "必须提供开始日期(startDate)和结束日期(endDate)参数";
        res.set_content(response.dump(), "application/json");
    }
}

void HTTPServer::handleGetOrdersByUser(const Request& req, Response& res) {
    res.set_header("Content-Type", "application/json");
    std::string userId = req.matches[1];
    res.set_content(OrderManagementController::getOrdersByUser(userId), "application/json");
}
