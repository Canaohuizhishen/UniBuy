// 商品管理界面
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Item {
    id: root
    anchors.fill: parent
    property alias backButton: backButton

    // 网络管理器
    NetworkManager {
        id: networkManager

        onRequestStarted: function(operation) {
            console.log("Request started:", operation);
            loadingIndicator.visible = true;
        }

        onRequestFinished: function(operation, success, result) {
            console.log("Request finished:", operation, success, "Result:", JSON.stringify(result));
            loadingIndicator.visible = false;

            if (!success) {
                var errorMsg = result.message || "操作失败";
                console.error("Operation failed:", errorMsg);

                // 显示详细错误信息
                errorDialog.title = "操作失败";
                errorDialog.message = errorMsg;
                errorDialog.open();
            }
        }

        onRequestError: function(operation, error) {
            console.error("Request error:", operation, error);
            loadingIndicator.visible = false;
            errorDialog.message = "网络错误: " + error;
            errorDialog.open();
        }
    }

    // 商品数据
    property var productsModel: ListModel {}
    property string currentStatus: "出售中"
    property bool isSearching: false
    property string lastSearchKeyword: ""

    Component.onCompleted: {
        loadProducts(currentStatus);
    }

    // 加载商品
    function loadProducts(status) {
        isSearching = false;
        networkManager.getProducts(status, function(success, result) {
            if (success && result.data) {
                updateProductsModel(result.data);
            }
        });
    }

    // 更新模型
    function updateProductsModel(productsArray) {
        productsModel.clear();
        for (var i = 0; i < productsArray.length; i++) {
            var product = productsArray[i];
            productsModel.append({
                productId: product.productId || "",
                name: product.name || "",
                category: product.category || "",
                price: product.price || 0,
                originalPrice: product.originalPrice || 0,
                stock: product.stock || 0,
                sales: product.sales || 0,
                status: product.status || "待审核",
                images: product.images || [],
                description: product.description || "",
                updateTime: product.updateTime || ""
            });
        }
    }

    // 添加商品
    function addNewProduct(productData) {
        console.log("Adding new product, data:", JSON.stringify(productData));

        networkManager.addProduct(productData, function(success, result) {
            console.log("Add product response:", success, result);
            if (success) {
                console.log("Product added successfully");
                loadProducts(currentStatus);
                publishDialog.resetForm();
            } else {
                console.error("Failed to add product:", result.message);
                errorDialog.title = "添加商品失败";
                errorDialog.message = result.message || "未知错误";
                errorDialog.open();
            }
        });
    }

    // 编辑商品
    function editProduct(productId, productData) {
        console.log("Editing product:", productId, "Data:", JSON.stringify(productData));

        if (!productData.productId) {
            productData.productId = productId;
        }

        networkManager.updateProduct(productId, productData, function(success, result) {
            console.log("Edit product response:", success, result);
            if (success) {
                console.log("Product updated successfully");
                loadProducts(currentStatus);
                editProductDialog.close();
            } else {
                console.error("Failed to update product:", result.message);
                errorDialog.title = "更新商品失败";
                errorDialog.message = result.message || "未知错误";
                errorDialog.open();
            }
        });
    }

    Timer {
        id: reloadTimer
        interval: 100
        onTriggered: {
            if (isSearching && lastSearchKeyword) {
                searchProducts(lastSearchKeyword);
            } else {
                loadProducts(currentStatus);
            }
        }
    }

    // 删除商品
    function deleteProduct(productId) {
        console.log("Deleting product:", productId);

        for (var i = 0; i < productsModel.count; i++) {
            if (productsModel.get(i).productId === productId) {
                productsModel.remove(i);
                break;
            }
        }

        networkManager.deleteProduct(productId, function(success, result) {
            if (!success) {
                console.error("Failed to delete product:", result.message);
                errorDialog.title = "删除商品失败";
                errorDialog.message = result.message || "未知错误";
                errorDialog.open();

                if (isSearching && lastSearchKeyword) {
                    searchProducts(lastSearchKeyword);
                } else {
                    loadProducts(currentStatus);
                }
            }
        });
    }

    // 切换商品状态
    function toggleProductStatus(productId, currentStatus) {
        console.log("Toggling product status:", productId, currentStatus);
        networkManager.toggleProductStatus(productId, currentStatus, function(success, result) {
            if (success) {
                console.log("Product status toggled");
                reloadTimer.start();
            } else {
                console.error("Failed to toggle product status:", result.message);
                errorDialog.title = "操作失败";
                errorDialog.message = result.message || "未知错误";
                errorDialog.open();
            }
        });
    }

    // 搜索商品
    function searchProducts(keyword) {
        if (!keyword.trim()) {
            isSearching = false;
            lastSearchKeyword = "";
            loadProducts(currentStatus);
            return;
        }

        isSearching = true;
        lastSearchKeyword = keyword;

        networkManager.searchProducts(keyword, function(success, result) {
            if (success && result.data) {
                updateProductsModel(result.data);
            }
        });
    }

    // 更新商品库存
    function updateProductStock(productId, newStock) {
        console.log("Updating product stock:", productId, "to", newStock);

        // 获取当前商品数据
        var currentProduct = null;
        for (var i = 0; i < productsModel.count; i++) {
            if (productsModel.get(i).productId === productId) {
                currentProduct = productsModel.get(i);
                break;
            }
        }

        if (!currentProduct) {
            console.error("Product not found:", productId);
            return;
        }

        // 准备更新数据
        var productData = {
            "stock": newStock,
            "status": newStock > 0 ? "出售中" : "已售罄",
            "name": currentProduct.name,
            "category": currentProduct.category,
            "price": currentProduct.price,
            "originalPrice": currentProduct.originalPrice || 0,
            "description": currentProduct.description || ""
        };

        networkManager.updateProduct(productId, productData, function(success, result) {
            if (success) {
                console.log("Product stock updated successfully");

                // 更新本地模型，避免重新加载所有数据
                for (var i = 0; i < productsModel.count; i++) {
                    if (productsModel.get(i).productId === productId) {
                        productsModel.setProperty(i, "stock", newStock);
                        productsModel.setProperty(i, "status", newStock > 0 ? "出售中" : "已售罄");

                        // 如果有数据返回，更新其他字段
                        if (result.data) {
                            productsModel.setProperty(i, "updateTime", result.data.updateTime || "");
                        }

                        console.log("Local model updated for product:", productId);
                        break;
                    }
                }
                loadProducts(currentStatus);
            } else {
                console.error("Failed to update product stock:", result.message);
                errorDialog.title = "更新库存失败";
                errorDialog.message = result.message || "未知错误";
                errorDialog.open();
            }
        });
    }

    // 主布局
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 标题栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "white"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                // 返回按钮
                StyledButton {
                    id: backButton
                    text: ""
                    buttonType: "ghost"
                    icon: "←"
                    buttonHeight: 30
                    buttonWidth: 40
                    radius: 8
                }

                // 页面标题
                Text {
                    text: "商品管理"
                    font.pixelSize: 20
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                // 搜索框
                SearchInput {
                    id: searchInput
                    placeholderText: "搜索商品名称或ID..."
                    Layout.preferredWidth: 300

                    onSearchTriggered: function(text) {
                        searchProducts(text);
                    }

                    onTextChanged: {
                        if (searchInput.text === "") {
                            searchProducts("");
                        }
                    }
                }

                Item { Layout.preferredWidth: 10 }

                // 发布商品按钮
                StyledButton {
                    text: "发布商品"
                    buttonType: "primary"
                    icon: "➕"
                    buttonHeight: 40
                    radius: 8

                    onClicked: {
                        publishDialog.resetForm();
                        publishDialog.open();
                    }
                }
            }
        }

        // 商品状态标签
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "white"

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 15
                spacing: 10

                Repeater {
                    model: ["出售中", "已下架", "待审核", "已售罄"]
                    delegate: TabButton {
                        text: modelData
                        checked: !isSearching && currentStatus === modelData
                        onClicked: {
                            isSearching = false;
                            lastSearchKeyword = "";
                            searchInput.text = "";
                            currentStatus = modelData;
                            loadProducts(currentStatus);
                        }
                    }
                }
            }
        }

        // 商品列表
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollView {
                anchors.fill: parent
                anchors.margins: 15
                clip: true

                ListView {
                    id: productListView
                    width: parent.width
                    spacing: 10
                    model: productsModel
                    delegate: ProductItem {
                        width: productListView.width
                        height: 140
                        productData: model
                        onEditClicked: {
                            console.log("Edit clicked for product:", model.productId);
                            editProductDialog.fillForm(model);
                            editProductDialog.open();
                        }
                        onStatusClicked: {
                            console.log("Status clicked for product:", model.productId, "Status:", model.status);
                            toggleProductStatus(model.productId, model.status);
                        }
                        onRestockClicked: {
                            console.log("Restock clicked for product:", model.productId);
                            // 打开库存修改对话框
                            stockModificationDialog.openWithProduct(model);
                        }
                        onDeleteClicked: {
                            console.log("Delete clicked for product:", model.productId);
                            deleteConfirmDialog._productIdToDelete = model.productId;
                            deleteConfirmDialog.message = "确认要删除商品 \"" + model.name + "\" 吗？";
                            deleteConfirmDialog.open();
                        }
                    }

                    // 空状态
                    EmptyState {
                        visible: productsModel.count === 0
                        icon: "📦"
                        title: isSearching ? "未找到相关商品" : "暂无商品"
                        description: isSearching ? "尝试使用其他关键词搜索" : "点击右上角按钮发布商品"
                        width: parent.width
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }

    // 发布商品对话框
    PublishProductDialog {
        id: publishDialog
        onProductSubmitted: function(productData) {
            addNewProduct(productData);
            publishDialog.close();
        }
    }

    // 编辑商品对话框
    PublishProductDialog {
        id: editProductDialog
        title: "编辑商品"
        onProductSubmitted: function(productData) {
            editProduct(productData.productId, productData);
            editProductDialog.close();
        }
    }

    ConfirmDialog {
        id: deleteConfirmDialog
        title: "确认删除"
        destructive: true
        okText: "删除"
        property string _productIdToDelete: ""
        onAccepted: {
            console.log("Deleting product from dialog:", _productIdToDelete);
            if (_productIdToDelete !== "") {
                deleteProduct(_productIdToDelete);
                _productIdToDelete = "";
            }
        }
    }

    ConfirmDialog {
        id: errorDialog
        title: "操作失败"
        okText: "确定"
        cancelText: ""
        destructive: true
    }

    // 库存修改对话框
    StockModificationDialog {
        id: stockModificationDialog
        onStockModified: function(productId, newStock) {
            console.log("Stock modification requested for:", productId, "new stock:", newStock);
            updateProductStock(productId, newStock);
        }
    }

    // 加载指示器
    Rectangle {
        id: loadingIndicator
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.3)
        visible: false
        focus: visible
        Keys.forwardTo: []

        //防止键盘事件穿透
        onVisibleChanged: {
            if (visible) {
                forceActiveFocus()
            }
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: parent.visible
        }

        //防止点击穿透
        MouseArea {
            anchors.fill: parent
            enabled: loadingIndicator.visible
            hoverEnabled: false
            onPressed: function(mouse){ mouse.accepted = true }
            onReleased: function(mouse){ mouse.accepted = true }
            onClicked: function(mouse){ mouse.accepted = true }
            onDoubleClicked: function(mouse){ mouse.accepted = true }
            onWheel: function(wheel){ wheel.accepted = true }
        }
    }
}
