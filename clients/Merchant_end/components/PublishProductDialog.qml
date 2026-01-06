//发布商品对话框
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

Dialog {
    id: dialog
    title: "发布商品"
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // 对话框尺寸
    width: 500
    height: Math.min(650, parent ? parent.height * 0.8 : 650)

    // 使用布局实现居中
    x: parent ? (parent.width - width) / 2 : 0
    y: parent ? (parent.height - height) / 2 : 0

    // 圆角背景
    background: Rectangle {
        radius: 12
        color: "white"
        border.color: "#e0e0e0"
        border.width: 1
    }

    signal productSubmitted(var productData)

    // 定义分类列表
    property var categories: ["服饰", "数码", "箱包", "家居", "美妆", "食品", "图书"]

    // 初始化表单数据
    property var formData: ({
                                productId: "",
                                name: "",
                                category: "",
                                price: "",
                                originalPrice: "",
                                stock: "",
                                description: "",
                                images: [],
                                skuList: []
                            })

    // 重置表单
    function resetForm() {
        formData = {
            productId: "",
            name: "",
            category: "",
            price: "",
            originalPrice: "",
            stock: "",
            description: "",
            images: [],
            skuList: []
        }

        // 重置所有输入控件
        nameInput.text = ""
        categorySelect.clear()
        priceInput.text = ""
        originalPriceInput.text = ""
        stockInput.text = ""
        descriptionInput.text = ""
    }

    // 填充表单（用于编辑）
    function fillForm(data) {
        console.log("Filling form with data: productId=" + (data.productId || "") +
                    ", name=" + (data.name || "") +
                    ", status=" + (data.status || ""));

        // 确保所有属性都有默认值
        var formDataCopy = {
            productId: data.productId || "",
            name: data.name || "",
            category: data.category || "",
            price: data.price || "",
            originalPrice: data.originalPrice || "",
            stock: data.stock || "",
            description: data.description || "",
            images: data.images || [],
            skuList: data.skuList || [],
            status: data.status || "出售中"  // 确保状态字段有值
        };

        // 更新formData（避免直接赋值导致循环引用）
        for (var key in formDataCopy) {
            formData[key] = formDataCopy[key];
        }

        // 更新UI控件
        nameInput.text = formData.name || "";
        var categoryIndex = categories.indexOf(formData.category || "");
        categorySelect.currentIndex = Math.max(0, categoryIndex);
        priceInput.text = formData.price ? formData.price.toString() : "";
        originalPriceInput.text = formData.originalPrice ? formData.originalPrice.toString() : "";
        stockInput.text = formData.stock ? formData.stock.toString() : "";
        descriptionInput.text = formData.description || "";
    }

    // 验证表单
    function validateForm() {
        // 验证所有必需字段
        var valid = true;

        // 商品名称验证
        if (!nameInput.text.trim()) {
            nameInput.showError = true;
            nameInput.errorMessage = "请输入商品名称";
            valid = false;
        } else {
            nameInput.clearError();
        }

        // 分类验证
        if (!categorySelect.currentText || categorySelect.currentText === "") {
            categorySelect.showError = true;
            categorySelect.errorMessage = "请选择商品分类";
            valid = false;
        } else {
            categorySelect.clearError();
        }

        // 价格验证
        if (!priceInput.text.trim() || isNaN(priceInput.text)) {
            priceInput.showError = true;
            priceInput.errorMessage = "请输入有效的价格";
            valid = false;
        } else {
            priceInput.clearError();
        }

        // 原价验证
        if (originalPriceInput.isNecessary) {
            if (!originalPriceInput.text.trim()) {
                originalPriceInput.showError = true;
                originalPriceInput.errorMessage = "请输入原价";
                valid = false;
            } else if (isNaN(originalPriceInput.text)) {
                originalPriceInput.showError = true;
                originalPriceInput.errorMessage = "请输入有效的原价";
                valid = false;
            } else {
                originalPriceInput.clearError();
            }
        }

        // 库存验证
        if (!stockInput.text.trim() || isNaN(stockInput.text)) {
            stockInput.showError = true;
            stockInput.errorMessage = "请输入有效的库存数量";
            valid = false;
        } else {
            stockInput.clearError();
        }

        return valid;
    }

    // 收集表单数据
    function collectFormData() {
        var data = {
            name: nameInput.text.trim(),
            category: categorySelect.currentText,
            price: parseFloat(priceInput.text),
            stock: parseInt(stockInput.text),
            description: descriptionInput.text.trim(),
            images: formData.images || [],
            skuList: formData.skuList || []
        };

        // 如果有productId（编辑时），添加到数据中
        if (formData.productId && formData.productId !== "") {
            data.productId = formData.productId;
            data.status = formData.status || "出售中";
        } else {
            // 根据库存设置状态
            if (data.stock <= 0) {
                data.status = "已售罄";
            } else {
                data.status = "出售中";
            }
        }

        // 添加可选字段
        if (originalPriceInput.text && originalPriceInput.text.trim() !== "") {
            data.originalPrice = parseFloat(originalPriceInput.text);
        }

        console.log("Collecting form data with productId:", formData.productId, "status:", data.status);
        return data;
    }

    // 文件选择对话框
    FileDialog {
        id: imageFileDialog
        title: "选择商品图片"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.gif)"]
        fileMode: FileDialog.OpenFiles

        onAccepted: {
            // 将选中的文件添加到图片列表中
            var selectedImages = []
            for (var i = 0; i < selectedFiles.length; i++) {
                var fileUrl = selectedFiles[i].toString()
                selectedImages.push(fileUrl)
            }
            formData.images = selectedImages
            console.log("选择了图片:", selectedImages)
        }
    }

    contentItem: Rectangle {
        implicitWidth: 800
        implicitHeight: 550

        ScrollView {
            anchors.fill: parent
            clip: true
            padding: 15

            ColumnLayout {
                width: parent.width
                spacing: 20

                // 验证错误提示
                Rectangle {
                    id: validationErrorContainer
                    Layout.fillWidth: true
                    height: validationError.visible ? 40 : 0
                    color: "#ffeaea"
                    radius: 8
                    border.color: "#ffcccc"
                    visible: validationError.text !== ""

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10

                        Text {
                            text: "⚠️"
                            font.pixelSize: 16
                        }

                        Text {
                            id: validationError
                            Layout.fillWidth: true
                            color: "#d63031"
                            font.pixelSize: 13
                            wrapMode: Text.Wrap
                        }
                    }
                }

                // 商品名称
                TextBox {
                    id: nameInput
                    title: "商品标题"
                    tipText: "请输入商品标题（商品标题组成：商品描述+规格）"
                    isNecessary: true
                    maxWordNum: 60
                }


                SelectBox {
                    id: categorySelect
                    Layout.fillWidth: true
                    titleText: "商品分类"
                    model: categories
                    tipText: "请选择商品分类"
                    isNecessary: true
                }

                NumberBox {
                    id: priceInput
                    Layout.fillWidth: true
                    isFloat: true
                    titleText: "售价"
                    tipText: "请输入售价"
                    unitText: "元"
                    isNecessary: true
                    minValue: 0
                    maxValue: 100000
                }

                // 原价
                NumberBox {
                    id: originalPriceInput
                    Layout.fillWidth: true
                    isFloat: true
                    titleText: "原价"
                    tipText: "请输入原价"
                    unitText: "元"
                    isNecessary: true
                    minValue: 0
                    maxValue: 100000
                }

                // 商品库存
                NumberBox {
                    id: stockInput
                    Layout.fillWidth: true
                    titleText: "库存数量"
                    tipText: "请输入库存数量"
                    unitText: "件"
                    isNecessary: true
                    minValue: 0
                    maxValue: 100000
                }

                // 商品图片
                GroupBox {
                    title: "商品图片"
                    Layout.fillWidth: true

                    label: Label {
                        text: parent.title
                        font.pixelSize: 16
                        font.bold: true
                        color: "#2c3e50"
                        leftPadding: 5
                    }

                    background: Rectangle {
                        color: "transparent"
                        border.color: "#dfe6e9"
                        radius: 12
                    }

                    ColumnLayout {
                        spacing: 15

                        // 图片上传区域
                        Rectangle {
                            Layout.fillWidth: true
                            height: 140
                            color: "#f8f9fa"
                            radius: 12
                            border.width: 2
                            border.color: "#3498db"

                            Column {
                                anchors.centerIn: parent
                                spacing: 12

                                Text {
                                    text: "📷"
                                    font.pixelSize: 32
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: "点击上传图片"
                                    color: "#3498db"
                                    font.pixelSize: 16
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: "支持 JPG、PNG、GIF 格式"
                                    color: "#95a5a6"
                                    font.pixelSize: 13
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onEntered: parent.opacity = 0.9
                                onExited: parent.opacity = 1

                                onClicked: imageFileDialog.open()
                            }
                        }

                        // 图片预览区域标题
                        RowLayout {
                            Text {
                                text: "已选择 " + (formData.images ? formData.images.length : 0) + " 张图片"
                                color: "#666"
                                font.pixelSize: 14
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: "最多可上传10张图片"
                                color: "#95a5a6"
                                font.pixelSize: 12
                            }
                        }

                        // 图片预览
                        Flow {
                            Layout.fillWidth: true
                            spacing: 12

                            Repeater {
                                model: formData.images ? formData.images : []

                                delegate: Rectangle {
                                    width: 90
                                    height: 90
                                    radius: 8
                                    color: "#f1f2f6"
                                    border.color: "#dfe4ea"
                                    border.width: 1

                                    // 图片预览
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        radius: 6
                                        color: "#2c3e50"

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 5

                                            Text {
                                                text: "📸"
                                                font.pixelSize: 18
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: {
                                                    if (!modelData) return "图片"
                                                    var parts = modelData.split('/')
                                                    var filename = parts[parts.length - 1]
                                                    return filename.substring(0, Math.min(8, filename.length)) + (filename.length > 8 ? "..." : "")
                                                }
                                                color: "white"
                                                font.pixelSize: 10
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }

                                    // 删除按钮
                                    Rectangle {
                                        width: 22
                                        height: 22
                                        radius: 11
                                        color: "#e74c3c"
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.margins: -6
                                        border.color: "white"
                                        border.width: 2

                                        Text {
                                            text: "×"
                                            color: "white"
                                            font.bold: true
                                            font.pixelSize: 14
                                            anchors.centerIn: parent
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (formData.images && index < formData.images.length) {
                                                    var newImages = formData.images.slice()
                                                    newImages.splice(index, 1)
                                                    formData.images = newImages
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // 商品详情
                TextBox {
                    id: descriptionInput
                    title: "商品详情"
                    tipText: "请输入商品描述（若未编辑，商品发布后
轮播图将自动填充至图文详情）"
                    maxWordNum: 500
                }
            }
        }
    }

    footer: DialogButtons {
        spacing: 10
        padding: 10

        onAccepted: {
            if (validateForm()) {
                var productData = collectFormData()
                dialog.productSubmitted(productData)
                dialog.accept()
            } else {
                // 验证失败，保持对话框打开
                dialog.open()
            }
        }

        onRejected: {
            resetForm()
            dialog.reject()
        }
    }
}
