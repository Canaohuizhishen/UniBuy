// NetworkManager.qml - 在现有基础上添加购物车函数
import QtQuick

Item {
    id: networkManager

    // 通用请求方法
    function get(url, callback) {
        console.log("GET请求:", url)
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        callback(true, response)
                    } catch (e) {
                        callback(false, { message: "JSON解析错误: " + e.message })
                    }
                } else {
                    callback(false, { message: "HTTP错误: " + xhr.status })
                }
            }
        }
        xhr.open("GET", url)
        xhr.send()
    }

    function post(url, data, callback) {
        console.log("POST请求:", url, data)
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 201) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        callback(true, response)
                    } catch (e) {
                        callback(false, { message: "JSON解析错误: " + e.message })
                    }
                } else {
                    callback(false, { message: "HTTP错误: " + xhr.status })
                }
            }
        }
        xhr.open("POST", url)
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.send(JSON.stringify(data))
    }

    // 商品相关
    function getShoppingProducts(callback) {
        get("http://localhost:8080/api/products", callback)
    }

    function searchShoppingProducts(keyword, callback) {
        get("http://localhost:8080/api/products/search?keyword=" + encodeURIComponent(keyword), callback)
    }

    // 订单相关
    function getOrders(callback) {
        console.log("调用获取订单API...")
        get("http://localhost:8080/api/consumer/orders", callback)
    }


    function getOrdersByStatus(status, callback) {
        console.log("按状态获取订单:", status)
        get("http://localhost:8080/api/consumer/orders/status/" + status, callback)
    }

    // ==== 新增的购物车函数 ====

    // 获取购物车
    function getCart(userId, callback) {
        get("http://localhost:8080/api/cart/" + userId, callback)
    }

    // 添加到购物车
    function addToCart(userId, cartItemData, callback) {
        post("http://localhost:8080/api/cart/" + userId + "/add", cartItemData, callback)
    }

    // 更新购物车项
    function updateCartItem(userId, itemId, updateData, callback) {
        var url = "http://localhost:8080/api/cart/" + userId + "/item/" + itemId
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 201) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        callback(true, response)
                    } catch (e) {
                        callback(false, { message: "JSON解析错误: " + e.message })
                    }
                } else {
                    callback(false, { message: "HTTP错误: " + xhr.status })
                }
            }
        }
        xhr.open("PUT", url)
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.send(JSON.stringify(updateData))
    }

    // 从购物车移除项
    function removeFromCart(userId, itemId, callback) {
        var url = "http://localhost:8080/api/cart/" + userId + "/item/" + itemId
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 204) {
                    callback(true, { success: true })
                } else {
                    callback(false, { message: "HTTP错误: " + xhr.status })
                }
            }
        }
        xhr.open("DELETE", url)
        xhr.send()
    }

    // 清空购物车
    function clearCart(userId, callback) {
        var url = "http://localhost:8080/api/cart/" + userId + "/clear"
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 204) {
                    callback(true, { success: true })
                } else {
                    callback(false, { message: "HTTP错误: " + xhr.status })
                }
            }
        }
        xhr.open("DELETE", url)
        xhr.send()
    }

    // 获取购物车摘要
    function getCartSummary(userId, callback) {
        get("http://localhost:8080/api/cart/" + userId + "/summary", callback)
    }

    // 结算购物车
    function checkoutCart(userId, orderInfo, callback) {
        post("http://localhost:8080/api/cart/" + userId + "/checkout", orderInfo, callback)
    }

    // 获取商品详情
    function getProductDetail(productId, callback) {
        get("http://localhost:8080/api/products/" + productId, callback)
    }

    // 信号
    signal requestStarted()
    signal requestCompleted()
    signal requestError(string errorMessage)
}
