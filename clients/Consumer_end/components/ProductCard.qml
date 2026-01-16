import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var productData: null
    signal productClicked(string productId)
    signal addToCart(string productId, int quantity)

    width: 230
    height: 300
    radius: 12
    color: "white"
    border.color: "#eee"
    border.width: 1

    // 鼠标悬停效果
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            parent.border.color = "#3498db"
            parent.scale = 1.02
        }
        onExited: {
            parent.border.color = "#eee"
            parent.scale = 1.0
        }
        onClicked: root.productClicked(productData.productId)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // 商品图片区域
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            radius: 8
            color: "#f8f9fa"

            // 商品图片占位符
            Rectangle {
                anchors.fill: parent
                anchors.margins: 10
                radius: 6
                color: "#e9ecef"

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "📦"
                        font.pixelSize: 32
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // 图片数量
                    Text {
                        visible: productData && productData.images && productData.images.length > 0
                        text: productData && productData.images ? productData.images.length + "张" : ""
                        color: "#6c757d"
                        font.pixelSize: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // 状态标签
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 8
                width: 40
                height: 20
                radius: 4
                color: {
                    if (!productData) return "#95a5a6"
                    switch(productData.status) {
                    case "出售中": return "#2ecc71"
                    case "已售罄": return "#e74c3c"
                    case "已下架": return "#95a5a6"
                    default: return "#95a5a6"
                    }
                }
                visible: productData && productData.status && productData.status !== "出售中"

                Text {
                    text: productData ? (productData.status === "已售罄" ? "售罄" : "下架") : ""
                    color: "white"
                    font.pixelSize: 10
                    font.bold: true
                    anchors.centerIn: parent
                }
            }
        }

        // 商品信息
        ColumnLayout {
            spacing: 4
            Layout.fillWidth: true

            // 商品名称
            Text {
                text: productData ? productData.name : ""
                font.pixelSize: 14
                font.bold: true
                color: "#2c3e50"
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            // 分类标签
            Text {
                text: productData ? productData.category : ""
                font.pixelSize: 11
                color: "#7f8c8d"
                Layout.fillWidth: true
            }

            // 价格区域
            RowLayout {
                spacing: 6

                // 当前价格
                Text {
                    text: productData ? "¥" + productData.price.toFixed(2) : ""
                    font.pixelSize: 18
                    color: "#e74c3c"
                    font.bold: true
                }

                // 原价（如果有）
                Text {
                    visible: productData && productData.originalPrice && productData.originalPrice > productData.price
                    text: productData && productData.originalPrice ? "¥" + productData.originalPrice.toFixed(2) : ""
                    font.pixelSize: 12
                    color: "#95a5a6"
                    font.strikeout: true
                }

                Item { Layout.fillWidth: true }
            }

            // 销售信息
            RowLayout {
                spacing: 8

                Text {
                    text: productData ? "销量：" + productData.sales : ""
                    font.pixelSize: 11
                    color: "#7f8c8d"
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: productData ? "库存：" + productData.stock : ""
                    font.pixelSize: 11
                    color: productData && productData.stock < 10 ? "#e74c3c" : "#7f8c8d"
                }
            }
        }

        // 操作按钮
        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            text: productData && productData.status === "已售罄" ? "已售罄" : "加入购物车"
            enabled: productData && productData.status === "出售中" && productData.stock > 0

            background: Rectangle {
                radius: 6
                color: parent.enabled ? (parent.down ? "#2980b9" : "#3498db") : "#bdc3c7"
            }

            contentItem: Text {
                text: parent.text
                color: "white"
                font.pixelSize: 13
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                if (productData) {
                    root.addToCart(productData.productId, 1)
                }
            }
        }
    }
}
