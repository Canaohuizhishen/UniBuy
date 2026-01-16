import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root
    property string title: "购物车"

    NetworkManager {
            id: networkManager
        }

    signal backClicked
    signal checkout(var items)

    property var selectedItems: []
    property double selectedTotal: 0
    property int selectedCount: 0

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Button {
            text: "刷新"
            onClicked: networkManager.getCart()
        }
        // 购物车头部
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "white"
            border.color: "#eee"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15

                // 全选
                Row {
                    spacing: 8

                    Rectangle {
                        width: 20
                        height: 20
                        radius: 4
                        border.color: "#bdc3c7"
                        border.width: 1

                        Text {
                            visible: isAllSelected
                            text: "✓"
                            color: "#3498db"
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: toggleAllSelection()
                        }
                    }

                    Text {
                        text: "全选"
                        font.pixelSize: 14
                        color: "#2c3e50"
                    }
                }

                Item { Layout.fillWidth: true }

                // 编辑/完成按钮
                Button {
                    text: isEditing ? "完成" : "编辑"
                    font.pixelSize: 14
                    background: Rectangle {
                        radius: 4
                        color: parent.down ? "#7f8c8d" : "#95a5a6"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: isEditing = !isEditing
                }
            }
        }

        // 购物车内容
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f8f9fa"

            ScrollView {
                anchors.fill: parent
                anchors.margins: 1

                Column {
                    width: parent.width
                    spacing: 1

                    // 购物车项目列表
                    Repeater {
                        model: cartItemsModel

                        delegate: ShoppingCartItem {
                            width: parent.width
                            cartItem: model

                            onQuantityChanged: function(productId, newQuantity) {
                                updateCartItemQuantity(productId, newQuantity)
                            }
                            onRemoved: function(productId) {
                                removeCartItem(productId)
                            }
                        }
                    }

                    // 空状态
                    EmptyState {
                        visible: cartItemsModel.count === 0
                        icon: "🛒"
                        title: "购物车是空的"
                        description: "快去挑选心仪的商品吧"
                        width: parent.width
                        height: 300
                    }
                }
            }
        }

        // 底部结算栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "white"
            border.color: "#eee"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15

                // 合计信息
                Column {
                    spacing: 4

                    Text {
                        text: "合计："
                        font.pixelSize: 14
                        color: "#7f8c8d"
                    }

                    Text {
                        text: "¥" + selectedTotal.toFixed(2)
                        font.pixelSize: 24
                        color: "#e74c3c"
                        font.bold: true
                    }

                    Text {
                        visible: selectedCount > 0
                        text: "已选 " + selectedCount + " 件商品"
                        font.pixelSize: 12
                        color: "#95a5a6"
                    }
                }

                Item { Layout.fillWidth: true }

                // 结算按钮
                // 结算按钮
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    text: "去结算 (" + selectedCount + "件)"
                    enabled: selectedCount > 0

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
                        if (selectedCount > 0) {
                            // 获取选中的商品
                            var selectedItems = []
                            for (var i = 0; i < cartModel.count; i++) {
                                var item = cartModel.get(i)
                                if (item.selected) {
                                    selectedItems.push(item)
                                }
                            }

                            // 显示支付页面
                            showPaymentPage("cart", null, {
                                items: selectedItems,
                                total: calculateSelectedTotal(),
                                itemCount: selectedCount
                            })
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: cartItemsModel
    }

    property bool isEditing: false
    property bool isAllSelected: false

    Component.onCompleted: loadCart()

    function loadCart() {
        var userId = "user1"
        networkManager.getCart(userId, function(success, result) {
            if (success && result.success) {
                // 处理购物车数据
                updateCartModel(result.data.items)
            } else {
                console.log("获取购物车失败:", result.message)
            }
        })
    }

    function updateCartItemsModel(items) {
        cartItemsModel.clear()
        for (var i = 0; i < items.length; i++) {
            var item = items[i]
            item.selected = true // 默认选中
            cartItemsModel.append(item)
        }
        updateSelection()
    }

    function updateCartItemQuantity(productId, quantity) {
        networkManager.updateCartItem(productId, quantity, function(success) {
            if (success) {
                updateSelection()
            }
        })
    }

    function removeCartItem(productId) {
        networkManager.removeFromCart(productId, function(success) {
            if (success) {
                updateSelection()
            }
        })
    }

    function toggleAllSelection() {
        isAllSelected = !isAllSelected
        for (var i = 0; i < cartItemsModel.count; i++) {
            cartItemsModel.setProperty(i, "selected", isAllSelected)
        }
        updateSelection()
    }

    function updateSelection() {
        selectedItems = []
        selectedTotal = 0
        selectedCount = 0

        for (var i = 0; i < cartItemsModel.count; i++) {
            var item = cartItemsModel.get(i)
            if (item.selected) {
                selectedItems.push(item)
                selectedTotal += item.price * item.quantity
                selectedCount += item.quantity
            }
        }

        // 更新全选状态
        isAllSelected = cartItemsModel.count > 0 && selectedItems.length === cartItemsModel.count
    }

    function getSelectedItems() {
        return selectedItems
    }
}
