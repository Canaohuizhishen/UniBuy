// OrderItem.qml - 精确匹配图片布局
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    property var orderData: null
    signal viewDetails(var order)
    signal trackLogistics(var order)
    signal cancelOrder(var order)
    signal confirmReceipt(var order)
    signal requestService(var order)
    signal addReview(var order)

    width: parent.width
    height: contentColumn.height + 24
    color: "white"

    // 顶部灰色分隔线
    Rectangle {
        width: parent.width
        height: 8
        color: "#f5f5f5"
    }

    Column {
        id: contentColumn
        width: parent.width
        spacing: 0
        padding: 16

        // 第一行：订单号和下单时间
        Row {
            width: parent.width-500
            spacing: 20

            Text {
                text: "订单号：" + (orderData && orderData.orderNumber ? orderData.orderNumber : "UNIBUY0000000010")
                font.pixelSize: 14
                color: "#333333"
            }

            Text {
                text: orderData && orderData.createTime ? orderData.createTime : "2028-01-12 15:56:16"
                font.pixelSize: 14
                color: "#666666"
            }

            Item { width: parent.width - childrenRect.width - 20; height: 1 }

            // 状态标签
            Rectangle {
                width: statusText.width + 20
                height: 24
                radius: 12
                color: getStatusColor(orderData ? orderData.status : "待收货")

                Text {
                    id: statusText
                    text: orderData && orderData.status ? orderData.status : "待收货"
                    color: "white"
                    font.pixelSize: 12
                    font.bold: true
                    anchors.centerIn: parent
                }
            }
        }

        // 间距
        Item { width: 1; height: 12 }

        // 商品信息 - 单行显示
        Row {
            width: parent.width
            spacing: 8

            Text {
                text: orderData && orderData.items && orderData.items[0] ? orderData.items[0].productName : "商品1"
                font.pixelSize: 14
                color: "#333333"
            }

            Text {
                text: "¥" + (orderData && orderData.items && orderData.items[0] ? orderData.items[0].price : "")
                font.pixelSize: 14
                color: "#e74c3c"
            }

            Text {
                text: "×" + (orderData && orderData.items && orderData.items[0] ? orderData.items[0].quantity : "1")
                font.pixelSize: 14
                color: "#666666"
            }

            Item { width: parent.width - childrenRect.width - 8; height: 1 }
        }

        // 分隔线
        Rectangle {
            width: parent.width
            height: 1
            color: "#f0f0f0"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 12
            anchors.bottomMargin: 12
        }

        // 底部信息行
        Row {
            width: parent.width -500
            spacing: 20

            Text {
                text: "共" + (orderData && orderData.items ? orderData.items.length : 1) + "件商品"
                font.pixelSize: 14
                color: "#666666"
            }

            Item { width: parent.width - childrenRect.width - 100; height: 1 }

            Text {
                text: "合计："
                font.pixelSize: 14
                color: "#333333"
            }

            Text {
                text: "¥" + (orderData && orderData.totalAmount ? orderData.totalAmount : "99")
                font.pixelSize: 16
                color: "#e74c3c"
                font.bold: true
            }
        }

        // 间距
        Item { width: 1; height: 16 }

        // 操作按钮行
        Row {
            width: parent.width
            spacing: 8

            // 查看详情按钮
            Rectangle {
                width: 80
                height: 32
                radius: 4
                color: viewDetailsMouseArea.pressed ? "#e0e0e0" : "transparent"
                border.color: "#cccccc"
                border.width: 1

                Text {
                    text: "查看详情"
                    font.pixelSize: 12
                    color: "#666666"
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: viewDetailsMouseArea
                    anchors.fill: parent
                    onClicked: viewDetails(orderData)
                }
            }

            // 根据状态显示不同的按钮
            // 如果是待收货状态
            Rectangle {
                visible: (orderData && orderData.status === "待收货") || (!orderData && true)  // 默认显示
                width: 80
                height: 32
                radius: 4
                color: confirmReceiptMouseArea.pressed ? "#27ae60" : "#2ecc71"

                Text {
                    text: "确认收货"
                    font.pixelSize: 12
                    color: "white"
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: confirmReceiptMouseArea
                    anchors.fill: parent
                    onClicked: confirmReceipt(orderData)
                }
            }

            // 跟踪物流按钮
            Rectangle {
                visible: (orderData && (orderData.status === "待收货" || orderData.status === "已完成")) || (!orderData && true)
                width: 80
                height: 32
                radius: 4
                color: trackLogisticsMouseArea.pressed ? "#2980b9" : "#3498db"

                Text {
                    text: "跟踪物流"
                    font.pixelSize: 12
                    color: "white"
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: trackLogisticsMouseArea
                    anchors.fill: parent
                    onClicked: trackLogistics(orderData)
                }
            }

            // 如果是待付款状态，显示取消订单
            Rectangle {
                visible: orderData && orderData.status === "待付款"
                width: 80
                height: 32
                radius: 4
                color: cancelOrderMouseArea.pressed ? "#c0392b" : "#e74c3c"

                Text {
                    text: "取消订单"
                    font.pixelSize: 12
                    color: "white"
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: cancelOrderMouseArea
                    anchors.fill: parent
                    onClicked: cancelOrder(orderData)
                }
            }

            // 如果是已完成状态，显示评价按钮
            Rectangle {
                visible: orderData && orderData.status === "已完成"
                width: 60
                height: 32
                radius: 4
                color: addReviewMouseArea.pressed ? "#d68910" : "#f39c12"

                Text {
                    text: "评价"
                    font.pixelSize: 12
                    color: "white"
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: addReviewMouseArea
                    anchors.fill: parent
                    onClicked: addReview(orderData)
                }
            }

            // 如果是已完成状态，显示申请售后
            Rectangle {
                visible: orderData && orderData.status === "已完成"
                width: 80
                height: 32
                radius: 4
                color: requestServiceMouseArea.pressed ? "#8e44ad" : "#9b59b6"

                Text {
                    text: "申请售后"
                    font.pixelSize: 12
                    color: "white"
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: requestServiceMouseArea
                    anchors.fill: parent
                    onClicked: requestService(orderData)
                }
            }
        }

        // 底部灰色分隔线
        Rectangle {
            width: parent.width
            height: 8
            color: "#f5f5f5"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 16
        }
    }

    // 获取状态颜色
    function getStatusColor(status) {
        switch(status) {
        case "待付款": return "#e74c3c"
        case "待发货": return "#f39c12"
        case "待收货": return "#3498db"
        case "已完成": return "#2ecc71"
        case "已取消": return "#95a5a6"
        default: return "#3498db"
        }
    }
}
