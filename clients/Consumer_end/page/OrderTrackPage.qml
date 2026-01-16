import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Page {
    id: root
    title: "我的订单"

    property var networkManager: NetworkManager {}
    property bool loading: false
    property string currentFilter: "全部"

    // 订单数据
    ListModel {
        id: ordersModel
    }

    // 对话框组件
    OrderDetailDialog {
        id: orderDetailDialog
    }

    LogisticsDialog {
        id: logisticsDialog
    }

    ConfirmDialog {
        id: confirmDialog
        onAccepted: handleConfirmAction()
        onRejected: confirmDialog.close()
    }

    // 顶部筛选栏
    Rectangle {
        width: parent.width
        height: 50
        color: "white"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Text {
                text: "筛选："
                font.pixelSize: 14
                color: "#666"
            }

            // 筛选按钮组
            RowLayout {
                spacing: 8

                Repeater {
                    model: ["全部", "待付款", "待发货", "待收货", "已完成", "已取消"]

                    Button {
                        text: modelData
                        font.pixelSize: 12
                        checked: currentFilter === modelData

                        background: Rectangle {
                            radius: 15
                            color: parent.checked ? "#3498db" : "transparent"
                            border.color: parent.checked ? "#3498db" : "#ddd"
                            border.width: 1
                        }

                        contentItem: Text {
                            text: parent.text
                            color: parent.checked ? "white" : "#666"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            currentFilter = modelData
                            loadOrders()
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // 搜索框
            TextField {
                id: searchField
                placeholderText: "搜索订单号或商品..."
                font.pixelSize: 12
                Layout.preferredWidth: 200

                background: Rectangle {
                    radius: 15
                    border.color: "#ddd"
                    border.width: 1
                }

                onTextChanged: searchTimer.restart()
            }

            Button {
                text: "刷新"
                onClicked: loadOrders()

                background: Rectangle {
                    radius: 4
                    color: parent.down ? "#2980b9" : "#3498db"
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    // 加载指示器
    Rectangle {
        anchors.fill: parent
        color: "#f5f6fa"
        visible: loading

        Column {
            anchors.centerIn: parent
            spacing: 20

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: true
                width: 40
                height: 40
            }

            Text {
                text: "加载中..."
                color: "#7f8c8d"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // 订单列表
    ScrollView {
        anchors.fill: parent
        anchors.topMargin: 50
        clip: true
        visible: !loading

        Column {
            width: parent.width
            spacing: 0

            Repeater {
                model: ordersModel

                delegate: OrderItem {
                    orderData: model
                    width: parent.width

                    onViewDetails: function(order) {
                        orderDetailDialog.orderData = order
                        orderDetailDialog.open()
                    }

                    onTrackLogistics: function(order) {
                        logisticsDialog.orderData = order
                        logisticsDialog.open()
                    }

                    onCancelOrder: function(order) {
                        confirmDialog.title = "确认取消订单"
                        confirmDialog.message = "确定要取消订单 " + order.orderNumber + " 吗？"
                        confirmDialog.destructive = true
                        confirmDialog.okText = "确认取消"
                        confirmDialog.userData = { orderId: order.orderId, action: "cancel" }
                        confirmDialog.open()
                    }

                    onConfirmReceipt: function(order) {
                        confirmDialog.title = "确认收货"
                        confirmDialog.message = "请确认您已收到订单 " + order.orderNumber + " 的商品"
                        confirmDialog.destructive = false
                        confirmDialog.okText = "确认收货"
                        confirmDialog.userData = { orderId: order.orderId, action: "confirm" }
                        confirmDialog.open()
                    }

                    onRequestService: function(order) {
                        console.log("申请售后:", order.orderNumber)
                        // 这里可以打开售后申请页面
                    }

                    onAddReview: function(order) {
                        console.log("添加评价:", order.orderNumber)
                        // 这里可以打开评价页面
                    }
                }
            }

            // 空状态
            EmptyState {
                visible: ordersModel.count === 0 && !loading
                icon: "📦"
                title: "暂无订单"
                description: currentFilter === "全部" ? "还没有订单记录" : "没有" + currentFilter + "的订单"
                width: parent.width
                height: 300
            }
        }
    }

    Timer {
        id: searchTimer
        interval: 500
        onTriggered: searchOrders()
    }

    Component.onCompleted: {
        console.log("OrderTrackPage 加载完成")
        loadOrders()
    }

    function loadOrders() {
        console.log("开始加载真实订单数据...")
        loading = true

        // 使用NetworkManager的getOrders函数获取真实数据
        networkManager.getOrders(function(success, result) {
            loading = false
            console.log("订单加载结果:", success, result)

            if (success) {
                if (result.success) {
                    // 清空旧数据
                    ordersModel.clear()

                    // 添加真实订单数据
                    var orders = result.data
                    console.log("收到订单数据数量:", orders.length)

                    for (var i = 0; i < orders.length; i++) {
                        var order = orders[i]

                        // 格式化订单数据
                        var orderData = {
                            orderId: order.orderId || "",
                            orderNumber: order.orderNumber || ("UNIBUY" + Date.now().toString().slice(-8)),
                            status: order.status || "待付款",
                            totalAmount: order.totalAmount || 0,
                            createTime: order.createTime || new Date().toLocaleString(),
                            items: order.items || [],
                            logisticsInfo: order.logisticsInfo || null
                        }

                        ordersModel.append(orderData)
                    }

                    // 更新订单统计
                    updateOrderCounts()
                } else {
                    console.error("API返回错误:", result.message)
                    showToast("加载订单失败: " + (result.message || "未知错误"))
                }
            } else {
                console.error("网络请求失败:", result.message)
                showToast("网络请求失败: " + (result.message || "请检查服务器连接"))

            }
        })
    }


    function updateOrdersModel(orders) {
        ordersModel.clear()
        for (var i = 0; i < orders.length; i++) {
            var order = orders[i]
            ordersModel.append(order)
        }
    }

    function searchOrders() {
        var keyword = searchField.text.trim()
        if (keyword) {
            loading = true
            // 这里应该调用搜索API，暂时使用本地过滤
            // 实际开发中应该调用 networkManager.searchOrders(keyword, callback)
            // 为了简化，这里模拟搜索
            console.log("搜索订单:", keyword)
            loading = false
        } else {
            loadOrders()
        }
    }

    function handleConfirmAction() {
        var userData = confirmDialog.userData
        if (!userData) return

        if (userData.action === "cancel") {
            cancelOrder(userData.orderId)
        } else if (userData.action === "confirm") {
            confirmReceipt(userData.orderId)
        }
        confirmDialog.close()
    }

    function cancelOrder(orderId) {
        networkManager.cancelOrder(orderId, function(success, result) {
            if (success && result.success) {
                console.log("订单取消成功:", orderId)
                loadOrders()
                showToast("订单已取消")
            } else {
                console.error("取消订单失败:", result.message)
                showToast("取消订单失败: " + result.message)
            }
        })
    }

    function confirmReceipt(orderId) {
        networkManager.confirmReceipt(orderId, function(success, result) {
            if (success && result.success) {
                console.log("确认收货成功:", orderId)
                loadOrders()
                showToast("已确认收货")
            } else {
                console.error("确认收货失败:", result.message)
                showToast("确认收货失败: " + result.message)
            }
        })
    }

    function showToast(message) {
        // 这里可以添加Toast显示逻辑
        console.log("Toast:", message)
    }
}
