import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root
    property string title: "浏览商品"

    property bool showPaymentPage: false
    property var paymentData: null
    property string paymentType: "direct"
    property string selectedPaymentMethod: "wechat" // 默认支付方式

    NetworkManager {
        id: networkManager
    }

    // 商品数据
    ListModel {
        id: productsModel
    }

    // 状态控制
    property var currentProductDetail: null
    property bool showProductDetail: false
    property bool loading: false

    // 信号定义
    signal productClicked(string productId)
    signal cartClicked

    // 页面1：商品浏览页面（默认显示）
    Item {
        id: browsePage
        anchors.fill: parent
        visible: !showProductDetail && !showPaymentPage

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 搜索栏
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "white"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "搜索商品..."
                        font.pixelSize: 14

                        background: Rectangle {
                            radius: 20
                            border.color: "#3498db"
                            border.width: 1
                        }

                        onTextChanged: {
                            console.log("搜索文本变化:", text)
                            searchTimer.restart()
                        }

                        onAccepted: searchProducts()
                    }

                    Button {
                        text: "搜索"
                        onClicked: searchProducts()
                    }

                    // 购物车图标按钮
                    Button {
                        text: "🛒"
                        font.pixelSize: 20
                        onClicked: cartClicked()

                        background: Rectangle {
                            radius: 20
                            color: parent.down ? "#e0e0e0" : "transparent"
                        }
                    }
                }
            }

            // 商品网格
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#f8f9fa"

                // 加载指示器
                Rectangle {
                    id: loadingIndicator
                    anchors.fill: parent
                    color: "#f8f9fa"
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

                ScrollView {
                    anchors.fill: parent
                    clip: true
                    visible: !loading

                    GridView {
                        id: productGrid
                        width: parent.width
                        cellWidth: 250
                        cellHeight: 320
                        clip: true

                        model: productsModel

                        delegate: ProductCard {
                            width: productGrid.cellWidth - 20
                            height: productGrid.cellHeight - 10
                            productData: model

                            onProductClicked: function(productId) {
                                console.log("商品点击，ID:", productId)
                                currentProductDetail = productId
                                showProductDetail = true
                                // 发射信号给父组件
                                root.productClicked(productId)
                            }

                            onAddToCart: function(productId, quantity) {
                                console.log("加入购物车，商品ID:", productId, "数量:", quantity)
                                handleAddToCart(productId, quantity || 1)
                            }
                        }

                        EmptyState {
                            visible: productsModel.count === 0 && !loading
                            icon: "📦"
                            title: "暂无商品"
                            description: "没有找到相关商品"
                            width: productGrid.width
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }
    }

    // 页面2：商品详情页
    Loader {
        id: detailLoader
        anchors.fill: parent
        active: showProductDetail && !showPaymentPage
        visible: active

        sourceComponent: Component {
            Item {
                anchors.fill: parent
                property string productId: currentProductDetail
                property var productData: null
                property bool loadingDetail: false
                property int quantity: 1

                // 顶部返回栏
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "white"
                    z: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        Button {
                            text: "← 返回"
                            onClicked: {
                                showProductDetail = false
                            }

                            background: Rectangle {
                                radius: 4
                                color: parent.down ? "#f0f0f0" : "transparent"
                            }
                        }

                        Text {
                            text: "商品详情"
                            font.pixelSize: 16
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

                // 加载指示器
                Rectangle {
                    visible: loadingDetail
                    anchors.fill: parent
                    anchors.topMargin: 50
                    color: "#f8f9fa"
                    z: 2

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
                            text: "加载商品详情中..."
                            color: "#7f8c8d"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                ScrollView {
                    anchors.fill: parent
                    anchors.topMargin: 50
                    clip: true
                    visible: !loadingDetail && productData

                    ColumnLayout {
                        width: parent.width
                        spacing: 0

                        // 商品图片
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 300
                            color: "#f8f9fa"

                            Column {
                                anchors.centerIn: parent
                                spacing: 10

                                Text {
                                    text: "📦"
                                    font.pixelSize: 80
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: productData && productData.images && productData.images.length > 0 ?
                                          productData.images.length + "张图片" : "商品图片"
                                    color: "#6c757d"
                                    font.pixelSize: 14
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }

                        // 商品信息
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

                                    // 原价
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
                                        width: statusText.width + 12
                                        height: 24
                                        radius: 12
                                        color: {
                                            if (!productData) return "#95a5a6"
                                            switch(productData.status) {
                                            case "出售中": return "#2ecc71"
                                            case "已售罄": return "#e74c3c"
                                            case "已下架": return "#95a5a6"
                                            default: return "#95a5a6"
                                            }
                                        }

                                        Text {
                                            id: statusText
                                            text: productData ? productData.status : ""
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
                                        text: "销量：" + (productData ? productData.sales : "0")
                                        font.pixelSize: 14
                                        color: "#7f8c8d"
                                    }

                                    Text {
                                        text: "库存：" + (productData ? productData.stock : "0")
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
                                        text: productData ? (productData.description || "暂无描述") : ""
                                        font.pixelSize: 14
                                        color: "#555"
                                        wrapMode: Text.Wrap
                                        Layout.fillWidth: true
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
                                        color: quantity >= maxStock() ? "#ecf0f1" : "#3498db"

                                        Text {
                                            text: "+"
                                            color: quantity >= maxStock() ? "#95a5a6" : "white"
                                            font.pixelSize: 20
                                            font.bold: true
                                            anchors.centerIn: parent
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            enabled: quantity < maxStock()
                                            onClicked: quantity += 1
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
                                    text: productData && productData.status === "出售中" && productData.stock > 0 ? "加入购物车" : "已售罄"
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
                                            handleAddToCart(productData.productId, quantity)
                                            showToast("商品已添加到购物车")
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
                                            var orderData = {
                                                productId: productData.productId,
                                                productName: productData.name,
                                                price: productData.price,
                                                quantity: quantity,
                                                spec: "默认规格",
                                                subtotal: productData.price * quantity,
                                                totalAmount: productData.price * quantity,
                                                shippingFee: productData.price * quantity > 99 ? 0 : 10,
                                                finalTotal: productData.price * quantity + (productData.price * quantity > 99 ? 0 : 10),
                                                items: [{
                                                    productId: productData.productId,
                                                    productName: productData.name,
                                                    price: productData.price,
                                                    quantity: quantity,
                                                    spec: "默认规格",
                                                    subtotal: productData.price * quantity
                                                }]
                                            }

                                            paymentType = "direct"
                                            paymentData = orderData
                                            showProductDetail = false
                                            showPaymentPage = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // 计算最大库存
                function maxStock() {
                    return productData ? productData.stock : 999
                }

                // 加载商品详情
                function loadProductDetail() {
                    console.log("加载商品详情:", productId)
                    if (!productId) {
                        console.error("商品ID为空")
                        showToast("商品信息加载失败: 商品ID为空")
                        return
                    }

                    loadingDetail = true

                    // 使用networkManager的通用get方法
                    var url = "http://localhost:8080/api/products/" + productId
                    console.log("请求URL:", url)

                    networkManager.get(url, function(success, result) {
                        loadingDetail = false
                        console.log("商品详情加载结果:", success)
                        console.log("返回数据:", JSON.stringify(result).substring(0, 200) + "...")

                        if (success) {
                            if (result.success) {
                                productData = result.data
                                console.log("商品数据加载成功:", productData.productId, productData.name)
                            } else {
                                showToast("加载商品详情失败: " + (result.message || "未知错误"))
                            }
                        } else {
                            showToast("网络请求失败: " + (result.message || "请检查服务器连接"))
                        }
                    })
                }

                Component.onCompleted: {
                    console.log("商品详情页面组件加载完成，ID:", productId)
                    if (productId) {
                        loadProductDetail()
                    } else {
                        console.error("商品ID为空，无法加载详情")
                        showToast("商品信息加载失败")
                    }
                }
            }
        }
    }

    // 页面3：支付页面
    Loader {
        id: paymentLoader
        anchors.fill: parent
        active: showPaymentPage
        visible: active

        sourceComponent: Component {
            PaymentPage {
                anchors.fill: parent
                orderType: paymentType
                orderData: paymentType === "direct" ? paymentData : null
                cartData: paymentType === "cart" ? paymentData : null

                payButton.onClicked: {
                    if (orderType === "direct") {
                        // 直接购买 - 创建订单
                        createDirectOrder();
                    } else if (orderType === "cart") {
                        // 购物车结算
                        checkoutCart();
                    }
                }

                onPaymentCompleted: function(orderId) {
                    console.log("支付完成，订单ID:", orderId)
                    showPaymentPage = false
                    showProductDetail = false
                    showToast("支付成功！订单号: " + orderId)
                }

                onPaymentFailed: function(error) {
                    console.log("支付失败:", error)
                    showToast("支付失败: " + error)
                }

                onBackClicked: {
                    showPaymentPage = false
                    if (paymentType === "direct") {
                        showProductDetail = true
                    }
                }
            }
        }
    }

    Timer {
        id: searchTimer
        interval: 500
        onTriggered: searchProducts()
    }

    // Toast提示组件
    Popup {
        id: toast
        width: 200
        height: 50
        x: (parent.width - width) / 2
        y: parent.height - 100
        modal: false
        closePolicy: Popup.NoAutoClose

        background: Rectangle {
            radius: 8
            color: "#333"
            opacity: 0.9
        }

        Text {
            anchors.centerIn: parent
            text: toast.message
            color: "white"
            font.pixelSize: 14
        }

        property string message: ""

        onOpened: {
            timer.start()
        }

        Timer {
            id: timer
            interval: 2000
            onTriggered: toast.close()
        }
    }

    Component.onCompleted: {
        console.log("BrowseProductsPage 加载完成")
        console.log("networkManager 存在:", networkManager !== null)
        console.log("当前服务器地址: http://localhost:8080")
        loadProducts()
    }

    Popup {
        id: successPopup
        width: 350
        height: 280
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle {
            radius: 16
            color: "white"
            border.color: "#e0e0e0"
            border.width: 1
        }

        property string orderId: ""
        property string orderNumber: ""
        property double orderAmount: 0

        // 关闭弹窗的函数
        function closePopup() {
            successPopup.close()
        }

        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            // 成功图标
            Rectangle {
                width: 60
                height: 60
                radius: 30
                color: "#e8f5e8"
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "✓"
                    font.pixelSize: 32
                    color: "#2ecc71"
                    font.bold: true
                    anchors.centerIn: parent
                }
            }

            // 成功标题
            Text {
                text: "支付成功！"
                font.pixelSize: 20
                font.bold: true
                color: "#2c3e50"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // 订单信息
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: "感谢您的购买"
                    font.pixelSize: 14
                    color: "#7f8c8d"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // 订单号
                Row {
                    spacing: 6
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: "订单号："
                        font.pixelSize: 14
                        color: "#666"
                    }

                    Text {
                        text: successPopup.orderNumber || "自动生成"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#3498db"
                    }
                }

                // 支付金额
                Row {
                    spacing: 6
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: "支付金额："
                        font.pixelSize: 14
                        color: "#666"
                    }

                    Text {
                        text: "¥" + successPopup.orderAmount.toFixed(2)
                        font.pixelSize: 16
                        font.bold: true
                        color: "#e74c3c"
                    }
                }
            }

            // 提示信息
            Text {
                text: "您可以在\"我的订单\"中查看订单详情"
                font.pixelSize: 12
                color: "#95a5a6"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // 按钮区域
            Row {
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                // 查看订单按钮
                Button {
                    width: 120
                    height: 40
                    text: "查看订单"

                    background: Rectangle {
                        radius: 8
                        color: parent.down ? "#2980b9" : "#3498db"
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        // 切换到订单页面
                        if (typeof tabBar !== 'undefined') {
                            tabBar.currentIndex = 2  // 假设订单页是第3个tab
                        }
                        successPopup.close()
                    }
                }

                // 继续购物按钮
                Button {
                    width: 120
                    height: 40
                    text: "继续购物"

                    background: Rectangle {
                        radius: 8
                        color: parent.down ? "#e0e0e0" : "#f5f6fa"
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#2c3e50"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        // 回到商品浏览页面
                        showPaymentPage = false
                        showProductDetail = false
                        successPopup.close()

                        // 清空搜索框
                        if (searchField) {
                            searchField.text = ""
                        }

                        // 重新加载商品
                        loadProducts()
                    }
                }
            }
        }
    }

    function paymentFailed(errorMessage) {
        console.log("支付失败:", errorMessage)
        showToast("支付失败: " + errorMessage)
        showPaymentPage = false
        // 重新显示商品详情页
        showProductDetail = true
    }

    function paymentCompleted(orderId, orderNumber, orderAmount) {
        console.log("支付完成，订单ID:", orderId, "订单号:", orderNumber)

        // 显示成功弹窗
        successPopup.orderId = orderId
        successPopup.orderNumber = orderNumber || ("ORD" + Date.now().toString().slice(-8))
        successPopup.orderAmount = orderAmount || 0

        // 关闭其他页面
        showPaymentPage = false
        showProductDetail = false

        // 打开成功弹窗
        successPopup.open()
    }

    function createDirectOrder() {
        // 这里应该使用 paymentData 而不是 orderData
        var orderDataToUse = paymentData;

        if (!orderDataToUse) {
            paymentFailed("订单数据为空");
            loadingPopup.visible = false;
            return;
        }

        // 构建订单数据
        var orderInfo = {
            userId: "user123", // 实际应用中应该从用户登录信息获取
            userName: "用户",
            shippingAddress: "北京市朝阳区建国门外大街1号", // 实际应用中应该从地址管理获取
            receiverName: "张三",
            receiverPhone: "13800000000",
            paymentMethod: selectedPaymentMethod,
            buyerMessage: "",
            items: orderDataToUse.items || [{
                productId: orderDataToUse.productId,
                productName: orderDataToUse.productName,
                price: orderDataToUse.price,
                quantity: orderDataToUse.quantity,
                spec: orderDataToUse.spec || "默认规格",
                subtotal: orderDataToUse.subtotal || orderDataToUse.price * orderDataToUse.quantity
            }],
            totalAmount: orderDataToUse.totalAmount || orderDataToUse.price * orderDataToUse.quantity,
            shippingFee: orderDataToUse.shippingFee || 0,
            status: "待付款"
        };

        console.log("创建直接购买订单:", JSON.stringify(orderInfo));

        // 使用 XMLHttpRequest 创建订单
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://localhost:8080/api/orders");
        xhr.setRequestHeader("Content-Type", "application/json");

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 201) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        if (response.success) {
                            console.log("订单创建成功:", response.data.orderId)
                            paymentCompleted(
                                response.data.orderId,
                                response.data.orderNumber,
                                response.data.totalAmount
                            )
                            // successPopup.open() // 不再需要这一行
                        } else {
                            paymentFailed("创建订单失败: " + response.message)
                        }
                    } catch (e) {
                        // 修改这里：调用定义的paymentFailed函数
                        paymentFailed("解析响应失败: " + e.message);
                    }
                } else {
                    // 修改这里：调用定义的paymentFailed函数
                    paymentFailed("HTTP错误: " + xhr.status);
                }
            }
        };

        xhr.onerror = function() {
            loadingPopup.visible = false;
            // 修改这里：调用定义的paymentFailed函数
            paymentFailed("网络请求失败");
        };

        xhr.send(JSON.stringify(orderInfo));
    }

    function checkoutCart() {
        // 原有的购物车结算逻辑
        var orderInfo = {
            userName: "用户",
            shippingAddress: "北京市朝阳区建国门外大街1号",
            receiverName: "张三",
            receiverPhone: "13800000000",
            paymentMethod: selectedPaymentMethod,
            buyerMessage: ""
        };

        if (root.networkManager) {
            root.networkManager.checkoutCart("user123", JSON.stringify(orderInfo), function(success, result) {
                loadingPopup.visible = false;
                if (success && result.success) {
                    successPopup.open();
                    paymentCompleted(result.data.orderId);
                } else {
                    paymentFailed(result.message || "结算失败");
                }
            });
        } else {
            paymentFailed("网络管理器未初始化");
            loadingPopup.visible = false;
        }
    }

    function loadProducts() {
        console.log("开始加载商品...")
        loading = true

        networkManager.getShoppingProducts(function(success, result) {
            loading = false
            console.log("商品加载结果:", success)
            if (success && result.data) {
                updateProductsModel(result.data)
            } else {
                showToast("加载失败: " + (result.message || "网络错误"))
            }
        })
    }

    function searchProducts() {
        console.log("搜索商品，关键词:", searchField ? searchField.text : "")
        if (searchField && searchField.text.trim()) {
            loading = true
            networkManager.searchShoppingProducts(searchField.text, function(success, result) {
                loading = false
                if (success && result.data) {
                    updateProductsModel(result.data)
                } else {
                    showToast("搜索失败: " + (result.message || "网络错误"))
                }
            })
        } else {
            loadProducts()
        }
    }

    function updateProductsModel(products) {
        console.log("更新商品模型，数量:", products.length)
        productsModel.clear()
        for (var i = 0; i < products.length; i++) {
            var product = products[i]
            var productData = {
                productId: product.productId || "",
                name: product.name || "",
                category: product.category || "",
                price: product.price || 0,
                originalPrice: product.originalPrice || 0,
                stock: product.stock || 0,
                sales: product.sales || 0,
                status: product.status || "",
                images: product.images || [],
                description: product.description || "",
                updateTime: product.updateTime || ""
            }
            productsModel.append(productData)
        }
    }

    function handleAddToCart(productId, quantity, callback) {
        console.log("调用handleAddToCart函数，商品ID:", productId, "数量:", quantity)

        // 先获取商品信息，确保商品存在且库存足够
        var url = "http://localhost:8080/api/products/" + productId
        networkManager.get(url, function(success, productResult) {
            if (!success || !productResult.success) {
                showToast("添加失败: 商品信息获取失败")
                if (callback) callback(false)
                return
            }

            var product = productResult.data
            if (product.status !== "出售中") {
                showToast("添加失败: 商品" + (product.status === "已售罄" ? "已售罄" : "已下架"))
                if (callback) callback(false)
                return
            }

            if (product.stock < quantity) {
                showToast("添加失败: 库存不足，当前库存" + product.stock)
                if (callback) callback(false)
                return
            }

            // 创建购物车项数据
            var cartItemData = {
                productId: productId,
                productName: product.name,
                price: product.price,
                quantity: quantity,
                spec: "默认规格"
            }

            // 添加购物车API调用（这里使用模拟数据，实际需要调用后端API）
            // TODO: 替换为实际的购物车API
            console.log("模拟添加到购物车:", cartItemData)

            // 暂时模拟成功
            showToast("商品已添加到购物车")
            if (callback) callback(true)
        })
    }

    function showToast(message) {
        toast.message = message
        toast.open()
    }

    function showPayment(type, orderData, cartData) {
        paymentType = type
        if (type === "direct") {
            paymentData = orderData
        } else {
            paymentData = cartData
        }
        showProductDetail = false
        showPaymentPage = true
    }
}
