import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root
    property string title: "结算"
    property var checkoutItems: []

    signal backClicked
    signal orderPlaced(string orderId)

    // 表单数据
    property var formData: ({
        shippingAddress: "",
        receiverName: "",
        receiverPhone: "",
        paymentMethod: "alipay",
        orderNote: ""
    })

    ScrollView {
        anchors.fill: parent

        ColumnLayout {
            width: parent.width
            spacing: 0

            // 收货地址
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: "white"
                border.color: "#eee"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10

                    RowLayout {
                        Text {
                            text: "收货地址"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#2c3e50"
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            text: "选择地址"
                            font.pixelSize: 14
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

                    // 地址信息
                    Column {
                        spacing: 5

                        Row {
                            spacing: 15

                            Text {
                                text: formData.receiverName || "请选择收货地址"
                                font.pixelSize: 16
                                color: formData.receiverName ? "#2c3e50" : "#95a5a6"
                            }

                            Text {
                                text: formData.receiverPhone || ""
                                font.pixelSize: 16
                                color: "#7f8c8d"
                            }
                        }

                        Text {
                            text: formData.shippingAddress || ""
                            font.pixelSize: 14
                            color: "#7f8c8d"
                            wrapMode: Text.Wrap
                            width: parent.width
                        }
                    }
                }
            }

            // 订单商品
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: checkoutItems.length * 80 + 60
                color: "white"
                border.color: "#eee"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // 标题
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: "#f8f9fa"

                        Text {
                            text: "订单商品"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#2c3e50"
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // 商品列表
                    Column {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Repeater {
                            model: checkoutItems

                            delegate: Rectangle {
                                width: parent.width
                                height: 80
                                color: index % 2 === 0 ? "white" : "#fcfcfc"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 12

                                    // 商品图片
                                    Rectangle {
                                        width: 50
                                        height: 50
                                        radius: 6
                                        color: "#f8f9fa"

                                        Text {
                                            text: "📦"
                                            font.pixelSize: 16
                                            anchors.centerIn: parent
                                        }
                                    }

                                    // 商品信息
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 4

                                        Text {
                                            text: model.name || ""
                                            font.pixelSize: 14
                                            color: "#2c3e50"
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: model.spec ? "规格：" + model.spec : ""
                                            font.pixelSize: 12
                                            color: "#7f8c8d"
                                        }
                                    }

                                    // 价格和数量
                                    Column {
                                        spacing: 4

                                        Text {
                                            text: "¥" + (model.price || 0).toFixed(2)
                                            font.pixelSize: 16
                                            color: "#e74c3c"
                                            font.bold: true
                                        }

                                        Text {
                                            text: "×" + (model.quantity || 1)
                                            font.pixelSize: 14
                                            color: "#7f8c8d"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 支付方式
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: "white"
                border.color: "#eee"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Text {
                        text: "支付方式"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#2c3e50"
                    }

                    // 支付方式选项
                    Column {
                        spacing: 10

                        RadioButton {
                            id: alipayRadio
                            text: "支付宝"
                            checked: true
                            onClicked: formData.paymentMethod = "alipay"

                            contentItem: Row {
                                spacing: 12

                                Rectangle {
                                    width: 18
                                    height: 18
                                    radius: 9
                                    border.color: alipayRadio.checked ? "#3498db" : "#95a5a6"
                                    border.width: 2
                                    color: alipayRadio.checked ? "#3498db" : "transparent"

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: "white"
                                        visible: alipayRadio.checked
                                    }
                                }

                                Text {
                                    text: "支付宝"
                                    font.pixelSize: 16
                                    color: "#2c3e50"
                                }
                            }
                        }

                        RadioButton {
                            id: wechatRadio
                            text: "微信支付"
                            onClicked: formData.paymentMethod = "wechat"

                            contentItem: Row {
                                spacing: 12

                                Rectangle {
                                    width: 18
                                    height: 18
                                    radius: 9
                                    border.color: wechatRadio.checked ? "#3498db" : "#95a5a6"
                                    border.width: 2
                                    color: wechatRadio.checked ? "#3498db" : "transparent"

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: "white"
                                        visible: wechatRadio.checked
                                    }
                                }

                                Text {
                                    text: "微信支付"
                                    font.pixelSize: 16
                                    color: "#2c3e50"
                                }
                            }
                        }

                        RadioButton {
                            id: cardRadio
                            text: "银行卡支付"
                            onClicked: formData.paymentMethod = "card"

                            contentItem: Row {
                                spacing: 12

                                Rectangle {
                                    width: 18
                                    height: 18
                                    radius: 9
                                    border.color: cardRadio.checked ? "#3498db" : "#95a5a6"
                                    border.width: 2
                                    color: cardRadio.checked ? "#3498db" : "transparent"

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: "white"
                                        visible: cardRadio.checked
                                    }
                                }

                                Text {
                                    text: "银行卡支付"
                                    font.pixelSize: 16
                                    color: "#2c3e50"
                                }
                            }
                        }
                    }

                    // 订单备注
                    TextField {
                        Layout.fillWidth: true
                        placeholderText: "订单备注（选填）"
                        font.pixelSize: 14

                        onTextChanged: formData.orderNote = text

                        background: Rectangle {
                            radius: 6
                            border.color: parent.activeFocus ? "#3498db" : "#bdc3c7"
                            border.width: 1
                        }
                    }
                }
            }

            // 订单合计
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: "white"
                border.color: "#eee"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    Text {
                        text: "订单合计"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#2c3e50"
                    }

                    // 费用明细
                    Column {
                        spacing: 10
                        Layout.fillWidth: true

                        RowLayout {
                            width: parent.width

                            Text {
                                text: "商品金额"
                                font.pixelSize: 14
                                color: "#7f8c8d"
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: "¥" + calculateSubtotal().toFixed(2)
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }
                        }

                        RowLayout {
                            width: parent.width

                            Text {
                                text: "运费"
                                font.pixelSize: 14
                                color: "#7f8c8d"
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: "¥" + shippingFee.toFixed(2)
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }
                        }

                        // 分隔线
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#eee"
                        }

                        RowLayout {
                            width: parent.width

                            Text {
                                text: "合计"
                                font.pixelSize: 16
                                color: "#2c3e50"
                                font.bold: true
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: "¥" + calculateTotal().toFixed(2)
                                font.pixelSize: 20
                                color: "#e74c3c"
                                font.bold: true
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // 提交订单按钮
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        text: "提交订单"

                        background: Rectangle {
                            radius: 8
                            color: parent.down ? "#c0392b" : "#e74c3c"
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 18
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: submitOrder()
                    }
                }
            }
        }
    }

    property double shippingFee: 10.00 // 默认运费

    function calculateSubtotal() {
        var subtotal = 0
        for (var i = 0; i < checkoutItems.length; i++) {
            var item = checkoutItems[i]
            subtotal += (item.price || 0) * (item.quantity || 1)
        }
        return subtotal
    }

    function calculateTotal() {
        return calculateSubtotal() + shippingFee
    }

    function validateForm() {
        if (!formData.receiverName || !formData.receiverPhone || !formData.shippingAddress) {
            errorDialog.title = "信息不完整"
            errorDialog.message = "请填写完整的收货信息"
            errorDialog.open()
            return false
        }
        return true
    }

    function submitOrder() {
        if (!validateForm()) return

        // 构造订单数据
        var orderData = {
            items: [],
            shippingAddress: formData.shippingAddress,
            receiverName: formData.receiverName,
            receiverPhone: formData.receiverPhone,
            paymentMethod: formData.paymentMethod,
            orderNote: formData.orderNote,
            shippingFee: shippingFee,
            totalAmount: calculateTotal()
        }

        // 转换商品项
        for (var i = 0; i < checkoutItems.length; i++) {
            var item = checkoutItems[i]
            orderData.items.push({
                productId: item.productId,
                productName: item.name,
                price: item.price,
                quantity: item.quantity,
                spec: item.spec || ""
            })
        }

        // 显示加载中
        loadingIndicator.visible = true

        // 提交订单
        networkManager.createOrder(orderData, function(success, result) {
            loadingIndicator.visible = false

            if (success) {
                successDialog.message = "订单创建成功！订单号：" + result.data.orderId
                successDialog.open()

                // 处理支付
                processPayment(result.data.orderId)
            } else {
                errorDialog.title = "下单失败"
                errorDialog.message = result.message || "创建订单失败"
                errorDialog.open()
            }
        })
    }

    function processPayment(orderId) {
        networkManager.processPayment(orderId, formData.paymentMethod, function(success, result) {
            if (success) {
                orderPlaced(orderId)
                root.backClicked()
            } else {
                errorDialog.title = "支付失败"
                errorDialog.message = result.message || "支付处理失败"
                errorDialog.open()
            }
        })
    }

    // 对话框
    ConfirmDialog {
        id: successDialog
        title: "订单创建成功"
        okText: "查看订单"
        cancelText: "继续购物"
        onAccepted: root.backClicked()
        onRejected: root.backClicked()
    }

    ConfirmDialog {
        id: errorDialog
        title: "操作失败"
        okText: "确定"
        cancelText: ""
    }

    // 加载指示器
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
