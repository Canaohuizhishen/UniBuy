import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"


Item {
    id: root
    anchors.fill: parent
    property alias backButton: backButton

    // Network manager
        NetworkManager {
            id: networkManager

            onRequestStarted: function(operation) {
                // console.log("Request started:", operation);
                loadingIndicator.visible = true;
            }

            onRequestFinished: function(operation, success, result) {
                // console.log("Request finished:", operation, success, "Result:", JSON.stringify(result));
                loadingIndicator.visible = false;

                if (!success) {
                    var errorMsg = result.message || "操作失败";
                    console.error("Operation failed:", errorMsg);

                    // 显示详细错误信息
                    errorDialog.title = "操作失败";
                    errorDialog.message = errorMsg;
                    errorDialog.open();
                }
            }

            onRequestError: function(operation, error) {
                console.error("Request error:", operation, error);
                loadingIndicator.visible = false;
                errorDialog.message = "网络错误: " + error;
                errorDialog.open();
            }
        }


    // Network manager
    property var ordersModel: ListModel {}
    property string currentStatus: "待发货"
    property bool isSearching: false
    property string lastSearchKeyword: ""
    property ListModel orderStatsModel: ListModel {
        // 添加默认数据
        ListElement { title: "待发货"; value: "0"; color: "#e74c3c" }
        ListElement { title: "已发货"; value: "0"; color: "#f39c12" }
        ListElement { title: "已完成"; value: "0"; color: "#2ecc71" }
        ListElement { title: "售后中"; value: "0"; color: "#9b59b6" }
        ListElement { title: "今日订单"; value: "0"; color: "#3498db" }
    }

    Component.onCompleted: {
        console.log("🚀 订单管理页面初始化...");
        loadOrders(currentStatus);
        updateOrderStats();
    }

    function loadOrders(status) {
        console.log("📦 从服务器加载订单，状态:", status);

        isSearching = false;

        // 使用网络请求获取订单
        networkManager.getOrders(status, function(success, result) {
            console.log("📡 服务器响应 - 成功:", success);
            console.log("📡 服务器响应 - 结果:", JSON.stringify(result));

            if (success && result.data) {
                console.log("✅ 获取订单成功，数量:", result.data.length);
                console.log("📋 第一个订单示例:", JSON.stringify(result.data[0]));
                updateOrdersModel(result.data);
            } else {
                console.error("❌ 获取订单失败:", result ? result.message : "未知错误");
            }
        });
    }

    function updateOrderStats() {
        console.log("📊 从服务器获取订单统计数据...");

        // 使用网络请求获取真实统计数据
        networkManager.getOrderCounts(function(success, result) {
            if (success && result.data) {
                console.log("📊 服务器返回统计:", JSON.stringify(result.data));

                // 清空并更新统计模型
                orderStatsModel.clear();

                // 更新统计卡片数据
                var stats = result.data;

                // 确保所有需要的统计项都有值
                orderStatsModel.append({
                    title: "待发货",
                    value: (stats["待发货"] || 0).toString(),
                    color: "#e74c3c"
                });
                orderStatsModel.append({
                    title: "已发货",
                    value: (stats["已发货"] || 0).toString(),
                    color: "#f39c12"
                });
                orderStatsModel.append({
                    title: "已完成",
                    value: (stats["已完成"] || 0).toString(),
                    color: "#2ecc71"
                });
                orderStatsModel.append({
                    title: "售后中",
                    value: (stats["售后中"] || 0).toString(),
                    color: "#9b59b6"
                });
                orderStatsModel.append({
                    title: "今日订单",
                    value: (stats["今日订单"] || 0).toString(),
                    color: "#3498db"
                });

                console.log("📊 统计卡片已更新");
            } else {
                console.error("❌ 获取订单统计失败:", result ? result.message : "未知错误");
            }
        });
    }

    function updateOrdersModel(ordersArray) {
        ordersModel.clear();
        for (var i = 0; i < ordersArray.length; i++) {
            var order = ordersArray[i];
            ordersModel.append({
                orderId: order.orderId || "",
                orderNumber: order.orderNumber || "",
                status: order.status || "待付款",
                userName: order.userName || "",
                totalAmount: order.totalAmount || 0,
                createTime: order.createTime || "",
                updateTime: order.updateTime || "",
                shippingAddress: order.shippingAddress || "",
                phoneNumber: order.phoneNumber || "",
                buyerMessage: order.buyerMessage || "",
                trackingNo: order.trackingNo || "",
                items: order.items || [],
                refundReason: order.refundReason || "",
                refundStatus: order.refundStatus || ""
            });
        }
    }

    function shipOrder(orderId, logisticsCompany, trackingNo) {
        networkManager.shipOrder(orderId, logisticsCompany, trackingNo, function(success, result) {
            if (success) {
                console.log("订单发货成功:", orderId);
                loadOrders(currentStatus);  // 刷新订单列表
                updateOrderStats();  // 更新统计
                shippingDialog.close();  // 关闭对话框
            } else {
                console.error("发货失败:", result.message);
                errorDialog.message = result.message || "发货失败";
                errorDialog.open();
            }
        });
    }

    function cancelOrder(orderId) {
        networkManager.cancelOrder(orderId, function(success, result) {
            if (success) {
                console.log("Order cancelled successfully");
                loadOrders(currentStatus);

                updateOrderStats();
            } else {
                console.error("Failed to cancel order:", result.message);
                errorDialog.message = result.message || "取消订单失败";
                errorDialog.open();
            }
        });
    }

    function searchOrders(keyword) {
        console.log("🔍 搜索订单，关键词:", keyword);

            if (!keyword.trim()) {
                isSearching = false;
                lastSearchKeyword = "";
                loadOrders(currentStatus);
                return;
            }

            isSearching = true;
            lastSearchKeyword = keyword;

            var searchResults = [];
            var lowerKeyword = keyword.toLowerCase();

            for (var i = 0; i < mockOrdersData.length; i++) {
                var order = mockOrdersData[i];

                // 在订单号、用户名、地址、商品名中搜索
                if (order.orderNumber.toLowerCase().includes(lowerKeyword) ||
                    order.userName.toLowerCase().includes(lowerKeyword) ||
                    order.shippingAddress.toLowerCase().includes(lowerKeyword) ||
                    (order.items && order.items.some(function(item) {
                        return item.name.toLowerCase().includes(lowerKeyword);
                    }))) {
                    searchResults.push(order);
                }
            }

            updateOrdersModel(searchResults);
    }

    // Main layout
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "white"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                StyledButton {
                    id: backButton
                    text: ""
                    buttonType: "ghost"
                    icon: "←"
                    buttonHeight: 30
                    buttonWidth: 40
                    radius: 8
                }

                Text {
                    text: "订单管理"
                    font.pixelSize: 20
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                // Search
                SearchInput {
                    id: searchInput
                    placeholderText: "搜索订单号、买家..."
                    Layout.preferredWidth: 300

                    onSearchTriggered: function(text) {
                        searchOrders(text);
                    }
                }
            }
        }

        // Statistics cards
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            color: "#f8f9fa"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Repeater {
                    model: orderStatsModel
                    delegate: OrderStatCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        statData: model
                    }
                }
            }
        }

        // Order status tabs
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "white"

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 15
                spacing: 10

                Repeater {
                    model: ["待发货", "已发货", "已完成", "已取消", "售后中", "全部"]
                    delegate: TabButton {
                        text: modelData
                        checked: !isSearching && currentStatus === modelData
                        onClicked: {
                            isSearching = false;
                            lastSearchKeyword = "";
                            searchInput.text = "";
                            currentStatus = modelData;
                            loadOrders(currentStatus);
                        }
                    }
                }
            }
        }

        // Order list
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollView {
                anchors.fill: parent
                anchors.margins: 15
                clip: true

                ListView {
                    id: orderListView
                    width: parent.width
                    spacing: 10
                    model: ordersModel

                    delegate: OrderItem {
                        width: orderListView.width
                        height: 180
                        orderData: model
                        // 查看详情
                        onProcess: function(order) {
                           orderDetailDialog.openWithOrder(order);
                        }
                        // 发货操作
                        onShipClicked: function(order) {
                            shippingDialog.openWithOrder(order);
                        }
                        // 取消操作
                        onCancelClicked: function(order) {
                            cancelConfirmDialog._orderIdToCancel = order.orderId;
                            cancelConfirmDialog.message = "确认要取消订单 " + order.orderNumber + " 吗？";
                            cancelConfirmDialog.open();
                        }
                    }

                    EmptyState {
                        visible: ordersModel.count === 0
                        icon: "📋"
                        title: isSearching ? "未找到相关订单" : "暂无订单"
                        description: isSearching ? "尝试使用其他关键词搜索" : ""
                        width: parent.width
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }

    // Dialogs
    ShippingDialog {
        id: shippingDialog
        onAcceptedWithData: function(orderId, logisticsCompany, trackingNo) {
            shipOrder(orderId, logisticsCompany, trackingNo);
        }
    }

    OrderDetailDialog {
        id: orderDetailDialog
    }

    ConfirmDialog {
        id: errorDialog
        title: "操作失败"
        okText: "确定"
        cancelText: ""
        destructive: true
    }

    ConfirmDialog {
        id: cancelConfirmDialog
        title: "确认取消"
        message: "确认要取消这个订单吗？"
        destructive: true
        property string _orderIdToCancel: ""
        onAccepted: {
            if (_orderIdToCancel !== "") {
                cancelOrder(_orderIdToCancel);
                _orderIdToCancel = "";
            }
        }
    }

    // Loading indicator
    Rectangle {
        id: loadingIndicator
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.3)
        visible: false

        BusyIndicator {
            anchors.centerIn: parent
            running: parent.visible
        }
    }
}
