import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var cartItem: null
    signal quantityChanged(string productId, int newQuantity)
    signal removed(string productId)

    width: parent ? parent.width : 400
    height: 100
    radius: 8
    color: "white"
    border.color: "#eee"
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // 选择框
        Rectangle {
            width: 20
            height: 20
            radius: 4
            border.color: "#bdc3c7"
            border.width: 1

            Text {
                visible: cartItem && cartItem.selected
                text: "✓"
                color: "#3498db"
                font.bold: true
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (cartItem) {
                        cartItem.selected = !cartItem.selected
                    }
                }
            }
        }

        // 商品图片
        Rectangle {
            width: 70
            height: 70
            radius: 6
            color: "#f8f9fa"

            Text {
                text: "📦"
                font.pixelSize: 20
                anchors.centerIn: parent
            }
        }

        // 商品信息
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            // 商品名称
            Text {
                text: cartItem && cartItem.name !== undefined ? cartItem.name : "商品"
                font.pixelSize: 14
                font.bold: true
                color: "#2c3e50"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            // 规格信息
            Text {
                text: cartItem && cartItem.spec ? "规格：" + cartItem.spec : "默认规格"
                font.pixelSize: 12
                color: "#7f8c8d"
            }

            // 价格和数量控制
            RowLayout {
                spacing: 20

                // 单价
                Text {
                    text: cartItem ? "¥" + cartItem.price.toFixed(2) : ""
                    font.pixelSize: 16
                    color: "#e74c3c"
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                // 数量控制
                Row {
                    spacing: 8

                    // 减少按钮
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 4
                        color: cartItem && cartItem.quantity <= 1 ? "#ecf0f1" : "#3498db"

                        Text {
                            text: "−"
                            color: cartItem && cartItem.quantity <= 1 ? "#95a5a6" : "white"
                            font.pixelSize: 16
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: cartItem && cartItem.quantity > 1
                            onClicked: {
                                if (cartItem) {
                                    var newQty = cartItem.quantity - 1
                                    root.quantityChanged(cartItem.productId, newQty)
                                }
                            }
                        }
                    }

                    // 数量显示
                    Rectangle {
                        width: 40
                        height: 24
                        color: "#f8f9fa"
                        radius: 4

                        Text {
                            text: cartItem ? cartItem.quantity : "0"
                            font.pixelSize: 14
                            color: "#2c3e50"
                            anchors.centerIn: parent
                        }
                    }

                    // 增加按钮
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 4
                        color: cartItem && cartItem.quantity >= cartItem.maxStock ? "#ecf0f1" : "#3498db"

                        Text {
                            text: "+"
                            color: cartItem && cartItem.quantity >= cartItem.maxStock ? "#95a5a6" : "white"
                            font.pixelSize: 16
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: cartItem && cartItem.quantity < cartItem.maxStock
                            onClicked: {
                                if (cartItem) {
                                    var newQty = cartItem.quantity + 1
                                    root.quantityChanged(cartItem.productId, newQty)
                                }
                            }
                        }
                    }
                }

                // 小计
                Text {
                    text: cartItem ? "¥" + (cartItem.price * cartItem.quantity).toFixed(2) : ""
                    font.pixelSize: 16
                    color: "#e74c3c"
                    font.bold: true
                    Layout.preferredWidth: 80
                }
            }
        }

        // 删除按钮
        Button {
            text: "删除"
            font.pixelSize: 12
            background: Rectangle {
                radius: 4
                color: parent.down ? "#c0392b" : "#e74c3c"
            }
            contentItem: Text {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                if (cartItem) {
                    root.removed(cartItem.productId)
                }
            }
        }
    }
}
