// OrderItem.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "./"

Rectangle {
    id: orderItem
    property var orderData: null
    signal process(var order)
    signal shipClicked(var order)     // 新增：发货信号
    signal cancelClicked(var order)   // 新增：取消信号

    radius: 12
    color: "white"
    border.color: "#eee"
    border.width: 1

    // 注意：这里使用ColumnLayout而不是Column
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        // 订单头部信息
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: orderData ? "订单号：" + orderData.orderNumber : ""
                font.bold: true
                font.pixelSize: 14
            }

            Item { Layout.fillWidth: true }

            Text {
                text: orderData ? orderData.createTime : ""
                color: "#666"
                font.pixelSize: 12
            }

            // 状态标签
            Rectangle {
                width: Math.max(60, (orderData ? orderData.status : "").length * 10 + 20)
                height: 24
                radius: 12
                color: {
                    if (!orderData) return "#95a5a6"
                    switch(orderData.status) {
                    case "待付款": case "已取消": return "#95a5a6"
                    case "待发货": return "#e74c3c"
                    case "已发货": return "#f39c12"
                    case "已完成": return "#2ecc71"
                    case "售后中": return "#9b59b6"
                    default: return "#3498db"
                    }
                }

                Text {
                    text: orderData ? orderData.status : ""
                    color: "white"
                    font.pixelSize: 10
                    font.bold: true
                    anchors.centerIn: parent
                }
            }
        }

        // 商品信息
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "#f9f9f9"
            radius: 8

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10

                // 商品图片区域
                Rectangle {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 60
                    color: "#f0f0f0"
                    radius: 6

                    Text {
                        text: "📦"
                        font.pixelSize: 20
                        anchors.centerIn: parent
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 5

                    Text {
                        text: "买家：" + (orderData ? orderData.userName : "")
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: {
                            if (!orderData || !orderData.items || orderData.items.length === 0)
                                return "商品：暂无商品"
                            var item = orderData.items[0]
                            return "商品：" + item.productName + (orderData.items.length > 1 ? " 等" + orderData.items.length + "件商品" : "")
                        }
                        font.pixelSize: 12
                        color: "#666"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "地址：" + (orderData ? orderData.shippingAddress : "")
                        font.pixelSize: 12
                        color: "#666"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                Text {
                    text: "¥" + (orderData ? orderData.totalAmount : 0)
                    font.pixelSize: 18
                    color: "#e74c3c"
                    font.bold: true
                }
            }
        }

        // 操作按钮
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            spacing: 8

            // 查看详情按钮
            Rectangle {
                width: 90
                height: 32
                radius: 6
                color: "#f5f6fa"
                border.color: "#d1d5db"
                border.width: 1

                Text {
                    text: "查看详情"
                    color: "#3498db"
                    font.pixelSize: 12
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (orderData) {
                            process(orderData)
                        }
                    }
                }
            }

            // 发货按钮
            Rectangle {
                width: 90
                height: 32
                radius: 6
                color: "#3498db"
                visible: orderData && orderData.status === "待发货"

                Text {
                    text: "发货"
                    color: "white"
                    font.pixelSize: 12
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (orderData) {
                            shipClicked(orderData)
                        }
                    }
                }
            }

            // 取消按钮
            Rectangle {
                width: 90
                height: 32
                radius: 6
                color: "#f5f6fa"
                border.color: "#d1d5db"
                border.width: 1
                visible: orderData && (orderData.status === "待付款" || orderData.status === "待发货")

                Text {
                    text: "取消"
                    color: "#e74c3c"
                    font.pixelSize: 12
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (orderData) {
                            cancelClicked(orderData)
                        }
                    }
                }
            }
        }
    }
}
