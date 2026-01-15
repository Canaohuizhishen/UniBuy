// 网络通信管理器
import QtQuick 2.15

QtObject {
    id: networkManager

    property string serverUrl: "http://localhost:8080"// 服务器地址配置
    property var pendingRequests: []
    property bool isProcessing: false

    // 信号
    signal requestStarted(string operation)
    signal requestFinished(string operation, bool success, var result)
    signal requestError(string operation, string error)

    // 请求方法
    function sendRequest(method, endpoint, data, callback) {
        var operation = method + " " + endpoint;
        // console.log("Queueing request:", operation);

        // 将请求加入队列
        pendingRequests.push({
                                 method: method,
                                 endpoint: endpoint,
                                 data: data,
                                 callback: callback,
                                 operation: operation
                             });

        // 如果没有正在处理的请求，开始处理队列
        if (!isProcessing) {
            processNextRequest();
        }
    }

    function processNextRequest() {
        if (pendingRequests.length === 0) {
            isProcessing = false;
            return;
        }

        isProcessing = true;
        var request = pendingRequests.shift();

        // console.log("Processing request:", request.operation);
        requestStarted(request.operation);

        var xhr = new XMLHttpRequest();
        var url = serverUrl + request.endpoint;

        // 设置超时（3秒）
        xhr.timeout = 3000;

        xhr.ontimeout = function() {
            console.error("Request timeout:", request.operation);
            requestError(request.operation, "请求超时");
            if (request.callback) request.callback(false, {message: "请求超时"});
            processNextRequest();
        };

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                // console.log("Response received for:", request.operation, "Status:", xhr.status);

                try {
                    var response = JSON.parse(xhr.responseText);
                    // console.log("Response success:", response.success);

                    if (xhr.status >= 200 && xhr.status < 300) {
                        requestFinished(request.operation, response.success, response);
                        if (request.callback) request.callback(response.success, response);
                    } else {
                        requestError(request.operation, response.message || "请求失败");
                        if (request.callback) request.callback(false, response);
                    }
                } catch (e) {
                    console.error("Parse error:", e);
                    requestError(request.operation, "服务器响应格式错误");
                    if (request.callback) request.callback(false, {message: "服务器响应格式错误"});
                }

                // 处理下一个请求
                processNextRequest();
            }
        };

        xhr.open(request.method, url, true);

        if (request.method === "POST" || request.method === "PUT") {
            xhr.setRequestHeader("Content-Type", "application/json");
        }

        if (request.data) {
            var jsonData = JSON.stringify(request.data);
            // console.log("Request body length:", jsonData.length);
            xhr.send(jsonData);
        } else {
            xhr.send();
        }
    }

    // 商品管理API
    function getProducts(status, callback) {
        var endpoint = "/api/products";
        if (status && status !== "全部") {
            endpoint += "?status=" + encodeURIComponent(status);
        }
        sendRequest("GET", endpoint, null, callback);
    }

    function getProduct(productId, callback) {
        sendRequest("GET", "/api/products/" + productId, null, callback);
    }

    function addProduct(productData, callback) {
        sendRequest("POST", "/api/products", productData, callback);
    }

    function updateProduct(productId, productData, callback) {
        sendRequest("PUT", "/api/products/" + productId, productData, callback);
    }

    function deleteProduct(productId, callback) {
        sendRequest("DELETE", "/api/products/" + productId, null, callback);
    }

    function searchProducts(keyword, callback) {
        sendRequest("GET", "/api/products/search?keyword=" + encodeURIComponent(keyword), null, callback);
    }

    function toggleProductStatus(productId, currentStatus, callback) {
        // console.log("Toggle status:", productId, currentStatus);
        // 确保发送正确的 JSON 数据
        var data = {currentStatus: currentStatus};
        sendRequest("POST", "/api/products/" + productId + "/toggle-status",
                    data, callback);
    }

    function getProductCounts(callback) {
        sendRequest("GET", "/api/products/stats/counts", null, callback);
    }

    // 订单管理API
    function getOrders(status, callback) {
        var endpoint = "/api/orders";
        if (status && status !== "全部") {
            endpoint += "?status=" + encodeURIComponent(status);
        }
        sendRequest("GET", endpoint, null, callback);
    }

    function getOrder(orderId, callback) {
        sendRequest("GET", "/api/orders/" + orderId, null, callback);
    }

    function createOrder(orderData, callback) {
        sendRequest("POST", "/api/orders", orderData, callback);
    }

    function shipOrder(orderId, logisticsCompany, trackingNumber, callback) {
        sendRequest("POST", "/api/orders/" + orderId + "/ship",
                    {
                        logisticsCompany: logisticsCompany,
                        trackingNumber: trackingNumber
                    }, callback);
    }

    function cancelOrder(orderId, callback) {
        sendRequest("POST", "/api/orders/" + orderId + "/cancel", null, callback);
    }

    function getOrderCounts(callback) {
        sendRequest("GET", "/api/orders/stats/counts", null, callback);
    }

    function searchOrders(keyword, callback) {
        sendRequest("GET", "/api/orders/search?keyword=" + encodeURIComponent(keyword),
                    null, callback);
    }
}
