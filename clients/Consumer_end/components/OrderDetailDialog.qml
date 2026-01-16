// 订单详情对话框 - 优化商品间距
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: dialog
    width: 600
    height: Math.min(700, parent.height * 0.9)
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property var orderData: null

    background: Rectangle {
        radius: 12
        color: "white"
        border.color: "#e0e0e0"
        border.width: 1
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        clip: true

        Column {
            width: parent.width
            spacing: 20

            // 订单基本信息
            Column {
                width: parent.width
                spacing: 12

                Text {
                    text: "订单信息"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2c3e50"
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#e0e0e0"
                }

                Grid {
                    width: parent.width
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 12

                    Text {
                        text: "订单号："
                        font.pixelSize: 14
                        color: "#666"
                    }
                    Text {
                        text: orderData ? orderData.orderNumber : ""
                        font.pixelSize: 14
                        font.bold: true
                        width: parent.width/2 - 20
                        elide: Text.ElideRight
                    }

                    Text {
                        text: "下单时间："
                        font.pixelSize: 14
                        color: "#666"
                    }
                    Text {
                        text: orderData ? orderData.createTime : ""
                        font.pixelSize: 14
                    }

                    Text {
                        text: "订单状态："
                        font.pixelSize: 14
                        color: "#666"
                    }
                    Text {
                        text: orderData ? orderData.status : ""
                        color: getStatusColor(orderData ? orderData.status : "")
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Text {
                        text: "订单金额："
                        font.pixelSize: 14
                        color: "#666"
                    }
                    Text {
                        text: orderData ? "¥" + orderData.totalAmount : ""
                        color: "#e74c3c"
                        font.pixelSize: 16
                        font.bold: true
                    }
                }
            }

            // 收货信息
            Column {
                width: parent.width
                spacing: 12

                Text {
                    text: "收货信息"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2c3e50"
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#e0e0e0"
                }

                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "收货人：张先生"
                        font.pixelSize: 14
                    }

                    Text {
                        text: "联系电话：138****8888"
                        font.pixelSize: 14
                    }

                    Text {
                        text: "收货地址：北京市朝阳区xxx街道xxx号"
                        font.pixelSize: 14
                        width: parent.width
                        wrapMode: Text.Wrap
                    }
                }
            }

            // 商品信息
            Column {
                width: parent.width
                spacing: 12

                Text {
                    text: "商品信息"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2c3e50"
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#e0e0e0"
                }

                // 商品列表容器
                Rectangle {
                    width: parent.width
                    height: childrenRect.height
                    radius: 8
                    color: "#f8f9fa"

                    Column {
                        width: parent.width
                        spacing: 12  // 商品之间的间距
                        padding: 12

                        Repeater {
                            model: orderData && orderData.items ? orderData.items : []

                            delegate: Row {
                                width: parent.width
                                spacing: 12

                                // 商品图片
                                Rectangle {
                                    width: 60
                                    height: 60
                                    radius: 8
                                    color: "#f0f0f0"

                                    Text {
                                        text: "📦"
                                        font.pixelSize: 20
                                        anchors.centerIn: parent
                                    }
                                }

                                // 商品信息
                                Column {
                                    width: parent.width - 84
                                    spacing: 4

                                    Text {
                                        text: modelData.productName
                                        font.pixelSize: 14
                                        font.bold: true
                                        width: parent.width
                                        elide: Text.ElideRight
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: 16

                                        Text {
                                            text: "规格：" + (modelData.spec || "默认")
                                            color: "#666"
                                            font.pixelSize: 12
                                        }

                                        Text {
                                            text: "¥" + modelData.price + " × " + modelData.quantity
                                            color: "#666"
                                            font.pixelSize: 12
                                        }
                                    }

                                    Text {
                                        text: "小计：¥" + modelData.subtotal
                                        color: "#e74c3c"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function getStatusColor(status) {
        switch(status) {
        case "待付款": return "#e74c3c"
        case "待发货": return "#f39c12"
        case "待收货": return "#3498db"
        case "已完成": return "#2ecc71"
        case "已取消": return "#95a5a6"
        default: return "#95a5a6"
        }
    }
}
