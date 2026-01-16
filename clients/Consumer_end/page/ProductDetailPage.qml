import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root
    property string productId: ""
    property string title: "商品详情"

    NetworkManager {
        id: networkManager
    }

    signal backClicked
    signal addToCart(string productId, int quantity)

    ScrollView {
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 0

            // 商品图片轮播
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                color: "#f8f9fa"

                SwipeView {
                    id: imageSwipeView
                    anchors.fill: parent

                    Repeater {
                        model: productData && productData.images ? productData.images : 1

                        Rectangle {
                            color: "#e9ecef"

                            Column {
                                anchors.centerIn: parent
                                spacing: 10

                                Text {
                                    text: "📦"
                                    font.pixelSize: 80
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: productData && productData.images && productData.images.length > 1 ?
                                          (index + 1) + "/" + productData.images.length : ""
                                    color: "#6c757d"
                                    font.pixelSize: 14
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                }

                // 页码指示器
                PageIndicator {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 10
                    count: imageSwipeView.count
                    currentIndex: imageSwipeView.currentIndex
                }
            }

            // 商品基本信息
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: contentColumn.height + 24
                color: "white"

                ColumnLayout {
                    id: contentColumn
                    width: parent.width
                    anchors.margins: 16
                    spacing: 12

                    // 商品名称
                    Text {
                        text: productData ? productData.name : ""
                        font.pixelSize: 18
                        font.bold: true
                        color: "#2c3e50"
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }

                    // 价格区域
                    RowLayout {
                        spacing: 10

                        // 当前价格
                        Text {
                            text: productData ? "¥" + productData.price.toFixed(2) : ""
                            font.pixelSize: 24
                            color: "#e74c3c"
                            font.bold: true
                        }

                        // 原价（如果有）
                        Text {
                            visible: productData && productData.originalPrice && productData.originalPrice > productData.price
                            text: productData && productData.originalPrice ? "¥" + productData.originalPrice.toFixed(2) : ""
                            font.pixelSize: 16
                            color: "#95a5a6"
                            font.strikeout: true
                        }

                        Item { Layout.fillWidth: true }

                        // 状态标签
                        Rectangle {
                            visible: productData && productData.status && productData.status !== "出售中"
                            width: 50
                            height: 24
                            radius: 4
                            color: {
                                if (!productData) return "#95a5a6"
                                switch(productData.status) {
                                case "已售罄": return "#e74c3c"
                                case "已下架": return "#95a5a6"
                                default: return "#95a5a6"
                                }
                            }

                            Text {
                                text: productData ? (productData.status === "已售罄" ? "售罄" : "下架") : ""
                                color: "white"
                                font.pixelSize: 12
                                font.bold: true
                                anchors.centerIn: parent
                            }
                        }
                    }

                    // 销售信息
                    RowLayout {
                        spacing: 20

                        Text {
                            text: "销量：" + (productData ? productData.sales : 0)
                            font.pixelSize: 14
                            color: "#7f8c8d"
                        }

                        Text {
                            text: "库存：" + (productData ? productData.stock : 0)
                            font.pixelSize: 14
                            color: productData && productData.stock < 10 ? "#e74c3c" : "#7f8c8d"
                        }

                        Text {
                            text: "分类：" + (productData ? productData.category : "")
                            font.pixelSize: 14
                            color: "#7f8c8d"
                        }
                    }

                    // 分隔线
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#f0f0f0"
                    }

                    // 商品描述
                    ColumnLayout {
                        spacing: 8

                        Text {
                            text: "商品描述"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#2c3e50"
                        }

                        Text {
                            text: productData ? productData.description : "暂无描述"
                            font.pixelSize: 14
                            color: "#555"
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // 规格选择（如果有规格）
            Rectangle {
                visible: productData && productData.skuList && productData.skuList.length > 0
                Layout.fillWidth: true
                Layout.preferredHeight: specColumn.height + 24
                color: "white"

                ColumnLayout {
                    id: specColumn
                    width: parent.width
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        text: "规格选择"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#2c3e50"
                    }

                    Flow {
                        spacing: 10
                        Layout.fillWidth: true

                        Repeater {
                            model: productData ? productData.skuList : []

                            Rectangle {
                                width: specText.width + 20
                                height: 36
                                radius: 6
                                border.color: selected ? "#3498db" : "#ddd"
                                border.width: selected ? 2 : 1
                                color: selected ? "#e3f2fd" : "white"

                                property bool selected: false

                                Text {
                                    id: specText
                                    text: modelData.spec
                                    font.pixelSize: 14
                                    color: selected ? "#3498db" : "#666"
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        // 选择规格逻辑
                                        for (var i = 0; i < parent.parent.children.length; i++) {
                                            parent.parent.children[i].selected = false
                                        }
                                        parent.selected = true
                                        selectedSku = modelData
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 数量选择
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "white"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 20

                    Text {
                        text: "数量"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#2c3e50"
                    }

                    Item { Layout.fillWidth: true }

                    // 数量控制
                    Row {
                        spacing: 8

                        // 减少按钮
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 4
                            color: quantity <= 1 ? "#ecf0f1" : "#3498db"

                            Text {
                                text: "−"
                                color: quantity <= 1 ? "#95a5a6" : "white"
                                font.pixelSize: 20
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: quantity > 1
                                onClicked: quantity = Math.max(1, quantity - 1)
                            }
                        }

                        // 数量显示
                        Rectangle {
                            width: 50
                            height: 32
                            color: "#f8f9fa"
                            radius: 4

                            Text {
                                text: quantity
                                font.pixelSize: 16
                                color: "#2c3e50"
                                anchors.centerIn: parent
                            }
                        }

                        // 增加按钮
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 4
                            color: quantity >= (productData ? productData.stock : 99) ? "#ecf0f1" : "#3498db"

                            Text {
                                text: "+"
                                color: quantity >= (productData ? productData.stock : 99) ? "#95a5a6" : "white"
                                font.pixelSize: 20
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: quantity < (productData ? productData.stock : 99)
                                onClicked: quantity = Math.min((productData ? productData.stock : 99), quantity + 1)
                            }
                        }
                    }
                }
            }

            // 底部操作栏
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "white"
                border.color: "#eee"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    // 加入购物车按钮
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        text: productData && productData.status === "已售罄" ? "已售罄" : "加入购物车"
                        enabled: productData && productData.status === "出售中" && productData.stock > 0

                        background: Rectangle {
                            radius: 8
                            color: parent.enabled ? (parent.down ? "#2980b9" : "#3498db") : "#bdc3c7"
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 16
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            if (productData) {
                                root.addToCart(productData.productId, quantity)
                            }
                        }
                    }

                    // 立即购买按钮
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        text: "立即购买"
                        enabled: productData && productData.status === "出售中" && productData.stock > 0

                        background: Rectangle {
                            radius: 8
                            color: parent.enabled ? (parent.down ? "#c0392b" : "#e74c3c") : "#bdc3c7"
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 16
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            if (productData) {
                                // 创建订单数据
                                var orderData = {
                                    productId: productData.productId,
                                    productName: productData.name,
                                    price: productData.price,
                                    quantity: quantity,
                                    spec: "默认规格",
                                    subtotal: productData.price * quantity
                                }

                                // 显示支付页面
                                showPaymentPage("direct", orderData)
                            }
                        }
                    }
                }
            }
        }
    }

    // 加载中指示器
    Rectangle {
        id: loadingIndicator
        anchors.fill: parent
        color: "white"
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

    // 错误提示
    Rectangle {
        anchors.fill: parent
        color: "white"
        visible: loadError

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "😔"
                font.pixelSize: 40
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "商品加载失败"
                font.pixelSize: 18
                color: "#2c3e50"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: errorMessage
                font.pixelSize: 14
                color: "#7f8c8d"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Button {
                text: "重试"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: loadProductDetail()
            }

            Button {
                text: "返回"
                anchors.horizontalCenter: parent.horizontalCenter
                background: Rectangle {
                    radius: 6
                    color: parent.down ? "#f5f6fa" : "transparent"
                    border.color: "#3498db"
                    border.width: 1
                }
                contentItem: Text {
                    text: parent.text
                    color: "#3498db"
                }
                onClicked: root.backClicked()
            }
        }
    }

    // 属性
    property var productData: null
    property var selectedSku: null
    property int quantity: 1
    property bool loading: false
    property bool loadError: false
    property string errorMessage: ""

    Component.onCompleted: {
        if (productId) {
            loadProductDetail()
        }
    }

    function loadProductDetail() {
        loading = true
        loadError = false

        networkManager.getProductDetail(productId, function(success, result) {
            loading = false

            if (success && result.data) {
                productData = result.data
                // 默认选择第一个SKU
                if (productData.skuList && productData.skuList.length > 0) {
                    selectedSku = productData.skuList[0]
                }
            } else {
                loadError = true
                errorMessage = result.message || "加载失败"
            }
        })
    }

    function getStatusColor(status) {
        switch(status) {
        case "出售中": return "#2ecc71"
        case "已售罄": return "#e74c3c"
        case "已下架": return "#95a5a6"
        default: return "#95a5a6"
        }
    }
}
