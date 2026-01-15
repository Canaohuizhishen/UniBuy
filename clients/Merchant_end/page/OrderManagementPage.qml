import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"


Item {
    id: root
    anchors.fill: parent
    property alias backButton: backButton

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
    // 在 OrderManagementPage.qml 的 Item 元素开头添加：
    property var mockOrdersData: [
        {
            orderId: "ORDER001",
            orderNumber: "202412160001",
            status: "待发货",
            userName: "张三",
            totalAmount: 299.00,
            createTime: "2023-12-16 10:30:00",
            updateTime: "2023-12-16 10:30:00",
            shippingAddress: "北京市朝阳区建国门外大街1号",
            phoneNumber: "13800138000",
            buyerMessage: "请尽快发货，谢谢！",
            trackingNo: "",
            items: [
                { name: "夏季男士短袖T恤", quantity: 2, price: 79.00 },
                { name: "运动袜", quantity: 3, price: 15.00 }
            ],
            refundReason: "",
            refundStatus: ""
        },
    ]

    Component.onCompleted: {
        console.log("🚀 订单管理页面初始化...");
        loadOrders(currentStatus);
        updateOrderStats();
    }

    function loadOrders(status) {
        console.log("📦 加载订单，状态:", status);

            // 使用模拟数据
            var filteredOrders = [];
            for (var i = 0; i < mockOrdersData.length; i++) {
                var order = mockOrdersData[i];
                if (status === "全部" || order.status === status) {
                    filteredOrders.push(order);
                }
            }

            updateOrdersModel(filteredOrders);
    }

    function updateOrderStats() {
        console.log("📊 开始更新订单统计...");

        // 初始化统计对象
        var stats = {
            "待发货": 0,
            "已发货": 0,
            "已完成": 0,
            "售后中": 0,
            "今日订单": 0
        };

        // 统计所有模拟订单
        for (var i = 0; i < mockOrdersData.length; i++) {
            var order = mockOrdersData[i];
            var status = order.status;

            // 统计各状态订单
            if (stats.hasOwnProperty(status)) {
                stats[status]++;
            }

            // 统计今日订单（假设创建时间包含"2023-12-16"的就是今日订单）
            if (order.createTime && order.createTime.includes("2023-12-16")) {
                stats["今日订单"]++;
            }
        }

        console.log("📊 统计结果:",
            "待发货=" + stats["待发货"],
            "已发货=" + stats["已发货"],
            "已完成=" + stats["已完成"],
            "售后中=" + stats["售后中"],
            "今日订单=" + stats["今日订单"]
        );

        // 清空并更新统计模型
        orderStatsModel.clear();

        // 添加统计卡片数据
        orderStatsModel.append({
            title: "待发货",
            value: stats["待发货"].toString(),
            color: "#e74c3c"
        });
        orderStatsModel.append({
            title: "已发货",
            value: stats["已发货"].toString(),
            color: "#f39c12"
        });
        orderStatsModel.append({
            title: "已完成",
            value: stats["已完成"].toString(),
            color: "#2ecc71"
        });
        orderStatsModel.append({
            title: "售后中",
            value: stats["售后中"].toString(),
            color: "#9b59b6"
        });
        orderStatsModel.append({
            title: "今日订单",
            value: stats["今日订单"].toString(),
            color: "#3498db"
        });

        console.log("📊 统计模型已更新，卡片数:", orderStatsModel.count);

        // 验证每个卡片的值
        for (var j = 0; j < orderStatsModel.count; j++) {
            var item = orderStatsModel.get(j);
            console.log("  卡片", j, ":", item.title, "=", item.value);
        }
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

    function shipOrder(orderId, trackingNo) {
        networkManager.shipOrder(orderId, trackingNo, function(success, result) {
            if (success) {
                console.log("Order shipped successfully");
                loadOrders(currentStatus);
                shippingDialog.close();
            } else {
                console.error("Failed to ship order:", result.message);
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
        onAcceptedWithData: function(orderId, trackingNo) {
            shipOrder(orderId, trackingNo);
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
