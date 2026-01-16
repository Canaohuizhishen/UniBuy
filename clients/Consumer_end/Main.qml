import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./page"

ApplicationWindow {
    width: 1000
    height: 700
    visible: true
    title: qsTr("UniBuy - 消费者端")
    color: "#f5f6fa"

    // 使用 TabBar 切换不同页面
    TabBar {
        id: tabBar
        width: parent.width
        currentIndex: 0

        TabButton {
            text: "浏览商品"
        }
        TabButton {
            text: "购物车"
        }
        TabButton {
            text: "我的订单"
        }
    }

    // 使用 StackLayout 切换页面内容
    StackLayout {
        width: parent.width
        height: parent.height - tabBar.height
        anchors.top: tabBar.bottom
        currentIndex: tabBar.currentIndex

        // 商品浏览页面
        BrowseProductsPage {
            id: browsePage
            onProductClicked: function(productId) {
                // 处理商品点击
                console.log("商品点击:", productId)
            }
            onCartClicked: {
                // 跳转到购物车页
                tabBar.currentIndex = 1
            }
        }

        // 购物车页面
        ShoppingCartPage {
            id: cartPage
            onBackClicked: {
                tabBar.currentIndex = 0
            }
            onCheckout: function(items) {
                console.log("结算商品:", items)
                // 这里可以跳转到结算页面
            }
        }

        // 订单跟踪页面（原有功能）
        OrderTrackPage {
            id: orderPage
            onVisibleChanged: {
                if(visible)orderPage.loadOrders()
            }
        }
    }

}
