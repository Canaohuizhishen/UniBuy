//订单项
import QtQuick 2.15
import QtQuick.Controls 2.15
import "./"

Rectangle {
    property var orderData: null
    signal process(var order)

    radius: 12  // 增加圆角
    color: "white"
    border.color: "#eee"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        // 订单头部信息
        RowLayout {
            Text {
                text: orderData ? "订单号：" + orderData.orderId : ""
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Text {
                text: orderData ? orderData.time : ""
                color: "#666"
                font.pixelSize: 12
            }

            // 使用状态标签组件
            StatusBadge {
                status: orderData ? orderData.status : ""
            }
        }

        // 商品信息
        Rectangle {
            Layout.fillWidth: true
            height: 80
            color: "#f9f9f9"
            radius: 8  // 增加圆角

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10

                // 商品图片区域
                Rectangle {
                    width: 60
                    height: 60
                    color: "#f0f0f0"
                    radius: 6  // 增加圆角

                    Text {
                        text: "📦"
                        font.pixelSize: 20
                        anchors.centerIn: parent
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Text {
                        text: orderData && orderData.items && orderData.items.length > 0 ?
                              orderData.items[0].name : ""
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: {
                            if (!orderData || !orderData.items || orderData.items.length === 0) return ""
                            var item = orderData.items[0]
                            return "数量：" + item.quantity + "  单价：" + item.price
                        }
                        font.pixelSize: 12
                        color: "#666"
                    }

                    Text {
                        text: orderData ? "买家：" + orderData.customer : ""
                        font.pixelSize: 12
                        color: "#666"
                    }
                }

                Text {
                    text: orderData ? orderData.total : ""
                    font.pixelSize: 18
                    color: "#e74c3c"
                    font.bold: true
                }
            }
        }

        // 操作按钮
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 8

            StyledButton {
                text: "查看详情"
                buttonType: "ghost"
                buttonWidth: 90
                buttonHeight: 32
                radius: 6
                onClicked: process(orderData)
            }

            StyledButton {
                text: {
                    if (!orderData) return ""
                    switch(orderData.status) {
                        case "待发货": return "发货"
                        case "待收货": return "确认收货"
                        case "退款售后": return "处理售后"
                        default: return "处理"
                    }
                }
                buttonType: "primary"
                buttonWidth: 90
                buttonHeight: 32
                radius: 6
                visible: orderData &&
                        orderData.status !== "已完成" &&
                        orderData.status !== "已取消"
                onClicked: process(orderData)
            }
        }
    }
}
