import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root
    property var orderData: null
    property var cartData: null
    property string orderType: "direct" // direct: 直接购买, cart: 购物车结算
    property alias payButton: payButton

    signal paymentCompleted(string orderId)
    signal paymentFailed(string error)
    signal backClicked

    // 支付方式
    property var paymentMethods: [
        { id: "wechat", name: "微信支付", icon: "💳", description: "推荐微信用户使用" },
        { id: "alipay", name: "支付宝", icon: "📱", description: "推荐支付宝用户使用" },
        { id: "bankcard", name: "银行卡支付", icon: "💳", description: "支持储蓄卡/信用卡" },
        { id: "balance", name: "余额支付", icon: "💰", description: "使用账户余额" }
    ]

    property string selectedPaymentMethod: "wechat"

    ScrollView {
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 0

            // 顶部标题栏
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "white"
                border.color: "#eee"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    Button {
                        text: "← 返回"
                        onClicked: root.backClicked()
                        font.pixelSize: 14

                        background: Rectangle {
                            radius: 4
                            color: parent.down ? "#f0f0f0" : "transparent"
                        }
                    }

                    Text {
                        text: "确认订单并支付"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#2c3e50"
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item {
                        width: 60
                    }
                }
            }

            // 收货地址
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                color: "white"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    RowLayout {
                        Text {
                            text: "收货地址"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#2c3e50"
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            text: "修改"
                            font.pixelSize: 12

                            background: Rectangle {
                                radius: 4
                                color: parent.down ? "#f0f0f0" : "transparent"
                                border.color: "#ddd"
                                border.width: 1
                            }
                        }
                    }

                    // 默认地址
                    Column {
                        spacing: 4

                        Row {
                            spacing: 8

                            Text {
                                text: "张三"
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Text {
                                text: "138****8888"
                                font.pixelSize: 14
                                color: "#666"
                            }
                        }

                        Text {
                            text: "北京市朝阳区建国门外大街1号"
                            font.pixelSize: 13
                            color: "#666"
                            width: parent.width
                            wrapMode: Text.Wrap
                        }
                    }
                }

                // 分隔线
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#f0f0f0"
                    anchors.bottom: parent.bottom
                }
            }

            // 商品列表
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: orderType === "direct" ? 120 : Math.min(200, cartData ? (cartData.items.length * 80) : 120)
                color: "white"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    Text {
                        text: orderType === "direct" ? "商品信息" : "购物车商品"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#2c3e50"
                    }

                    // 商品项
                    Column {
                        spacing: 12
                        width: parent.width

                        // 直接购买模式
                        Loader {
                            active: orderType === "direct" && orderData
                            width: parent.width
                            height: active ? 60 : 0

                            sourceComponent: Component {
                                Row {
                                    width: parent.width
                                    spacing: 12

                                    // 商品图片
                                    Rectangle {
                                        width: 50
                                        height: 50
                                        radius: 6
                                        color: "#f8f9fa"

                                        Text {
                                            text: "📦"
                                            font.pixelSize: 20
                                            anchors.centerIn: parent
                                        }
                                    }

                                    // 商品信息
                                    Column {
                                        width: parent.width - 74
                                        spacing: 4

                                        Text {
                                            text: orderData ? orderData.productName : "商品"
                                            font.pixelSize: 14
                                            font.bold: true
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }

                                        Row {
                                            spacing: 15

                                            Text {
                                                text: orderData ? "¥" + orderData.price.toFixed(2) : ""
                                                font.pixelSize: 14
                                                color: "#e74c3c"
                                            }

                                            Text {
                                                text: "×" + (orderData ? orderData.quantity : 1)
                                                font.pixelSize: 14
                                                color: "#666"
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // 购物车模式
                        Repeater {
                            model: orderType === "cart" && cartData ? cartData.items : []

                            delegate: Row {
                                width: parent.width
                                spacing: 12

                                Rectangle {
                                    width: 50
                                    height: 50
                                    radius: 6
                                    color: "#f8f9fa"

                                    Text {
                                        text: "📦"
                                        font.pixelSize: 20
                                        anchors.centerIn: parent
                                    }
                                }

                                Column {
                                    width: parent.width - 74
                                    spacing: 4

                                    Text {
                                        text: modelData.productName || "商品"
                                        font.pixelSize: 14
                                        font.bold: true
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }

                                    Row {
                                        spacing: 15

                                        Text {
                                            text: "¥" + (modelData.price ? modelData.price.toFixed(2) : "0.00")
                                            font.pixelSize: 14
                                            color: "#e74c3c"
                                        }

                                        Text {
                                            text: "×" + (modelData.quantity || 1)
                                            font.pixelSize: 14
                                            color: "#666"
                                        }

                                        Item { width: parent.width - childrenRect.width - 15 }

                                        Text {
                                            text: "小计：¥" + (modelData.subtotal ? modelData.subtotal.toFixed(2) : "0.00")
                                            font.pixelSize: 14
                                            color: "#e74c3c"
                                            font.bold: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#f0f0f0"
                    anchors.bottom: parent.bottom
                }
            }

            // 支付方式
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: paymentMethods.length * 70 + 50
                color: "white"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 0

                    Text {
                        text: "选择支付方式"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#2c3e50"
                        Layout.bottomMargin: 12
                    }

                    Repeater {
                        model: paymentMethods

                        delegate: Rectangle {
                            width: parent.width
                            height: 70
                            color: selectedPaymentMethod === modelData.id ? "#f0f7ff" : "transparent"
                            radius: 8

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: selectedPaymentMethod = modelData.id
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 12

                                // 支付方式图标
                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: 20
                                    color: selectedPaymentMethod === modelData.id ? "#3498db" : "#f0f0f0"

                                    Text {
                                        text: modelData.icon
                                        font.pixelSize: 20
                                        anchors.centerIn: parent
                                    }
                                }

                                // 支付方式信息
                                ColumnLayout {
                                    spacing: 4

                                    Text {
                                        text: modelData.name
                                        font.pixelSize: 15
                                        font.bold: true
                                        color: "#2c3e50"
                                    }

                                    Text {
                                        text: modelData.description
                                        font.pixelSize: 12
                                        color: "#7f8c8d"
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                // 选中标记
                                Rectangle {
                                    visible: selectedPaymentMethod === modelData.id
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: "#3498db"

                                    Text {
                                        text: "✓"
                                        color: "white"
                                        font.pixelSize: 12
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            // 分隔线
                            Rectangle {
                                visible: index < paymentMethods.length - 1
                                width: parent.width
                                height: 1
                                color: "#f0f0f0"
                                anchors.bottom: parent.bottom
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#f0f0f0"
                    anchors.bottom: parent.bottom
                }
            }

            // 订单金额汇总
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                color: "white"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        text: "订单金额"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#2c3e50"
                    }

                    Column {
                        width: parent.width
                        spacing: 8

                        Row {
                            width: parent.width
                            spacing: 10

                            Text {
                                text: "商品金额"
                                font.pixelSize: 14
                                color: "#666"
                            }

                            Item { width: parent.width - childrenRect.width - 10 }

                            Text {
                                text: "¥" + calculateTotal()
                                font.pixelSize: 14
                                color: "#333"
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: 10

                            Text {
                                text: "运费"
                                font.pixelSize: 14
                                color: "#666"
                            }

                            Item { width: parent.width - childrenRect.width - 10 }

                            Text {
                                text: calculateTotal() > 99 ? "¥0.00" : "¥10.00"
                                font.pixelSize: 14
                                color: calculateTotal() > 99 ? "#2ecc71" : "#333"
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#f0f0f0"
                        }

                        Row {
                            width: parent.width
                            spacing: 10

                            Text {
                                text: "应付总额"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#2c3e50"
                            }

                            Item { width: parent.width - childrenRect.width - 10 }

                            Text {
                                text: "¥" + calculateFinalTotal()
                                font.pixelSize: 20
                                color: "#e74c3c"
                                font.bold: true
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // 支付按钮
                    Button {
                        id: payButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        text: "确认支付 ¥" + calculateFinalTotal()

                        background: Rectangle {
                            radius: 8
                            color: parent.down ? "#2980b9" : "#3498db"
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 16
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }

    // 支付成功弹窗
    Popup {
        id: successPopup
        width: 350
        height: 250
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: true
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: 12
            color: "white"
            border.color: "#e0e0e0"
            border.width: 1
        }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "✅"
                font.pixelSize: 50
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "支付成功！"
                font.pixelSize: 20
                font.bold: true
                color: "#2ecc71"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "订单已创建，请等待发货"
                font.pixelSize: 14
                color: "#666"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Button {
                text: "查看订单"
                anchors.horizontalCenter: parent.horizontalCenter

                background: Rectangle {
                    radius: 6
                    color: parent.down ? "#2980b9" : "#3498db"
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    successPopup.close()
                    root.paymentCompleted("ORDER_" + Date.now())
                }
            }
        }
    }

    // 加载指示器
    Popup {
        id: loadingPopup
        width: 150
        height: 150
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: true

        background: Rectangle {
            radius: 12
            color: "white"
            border.color: "#e0e0e0"
            border.width: 1
        }

        Column {
            anchors.centerIn: parent
            spacing: 15

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: true
                width: 40
                height: 40
            }

            Text {
                text: "支付处理中..."
                font.pixelSize: 14
                color: "#666"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    function calculateTotal() {
        if (orderType === "direct" && orderData) {
            return (orderData.price * (orderData.quantity || 1)).toFixed(2)
        } else if (orderType === "cart" && cartData) {
            return cartData.total ? cartData.total.toFixed(2) : "0.00"
        }
        return "0.00"
    }

    function calculateFinalTotal() {
        var total = parseFloat(calculateTotal())
        var shipping = total > 99 ? 0 : 10
        return (total + shipping).toFixed(2)
    }

    Component.onCompleted: {
        console.log("PaymentPage loaded, orderType:", orderType)
        console.log("Order data:", orderData)
        console.log("Cart data:", cartData)
    }
}
