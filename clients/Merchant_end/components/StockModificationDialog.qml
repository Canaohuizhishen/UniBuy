// 库存修改对话框
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: dialog
    title: "修改库存"
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property var productData: null
    signal stockModified(string productId, int newStock)

    width: 400
    height: 320
    x: parent ? (parent.width - width) / 2 : 0
    y: parent ? (parent.height - height) / 2 : 0

    // 圆角背景
    background: Rectangle {
        radius: 12
        color: "white"
        border.color: "#e0e0e0"
        border.width: 1
    }

    // 初始化对话框
    function openWithProduct(product) {
        productData = product;
        resetForm();
        open();
    }

    // 重置表单
    function resetForm() {
        if (!productData) return;

        currentStockText.text = productData.stock;
        increaseRadio.checked = true;
        quantityInput.text = "";
        targetStockInput.text = "";

        updatePreview();
    }

    // 计算预览库存
    function updatePreview() {
        if (!productData) return;

        var currentStock = productData.stock || 0;
        var newStock = currentStock;

        if (increaseRadio.checked) {
            var addQty = parseInt(quantityInput.text) || 0;
            newStock = currentStock + addQty;
        } else if (decreaseRadio.checked) {
            var subQty = parseInt(quantityInput.text) || 0;
            newStock = currentStock - subQty;
        } else if (setStockRadio.checked) {
            newStock = parseInt(targetStockInput.text) || currentStock;
        }

        // 确保非负
        newStock = Math.max(0, newStock);

        previewText.text = "修改后库存: " + newStock;

        // 更新按钮状态
        var isValid = false;
        if (increaseRadio.checked || decreaseRadio.checked) {
            isValid = quantityInput.text !== "" && parseInt(quantityInput.text) > 0;
        } else if (setStockRadio.checked) {
            isValid = targetStockInput.text !== "" && !isNaN(parseInt(targetStockInput.text));
        }

        confirmButton.disabled = !isValid;
    }

    // 应用库存修改
    function applyStockModification() {
        if (!productData) return;

        var currentStock = productData.stock || 0;
        var newStock = currentStock;

        if (increaseRadio.checked) {
            var addQty = parseInt(quantityInput.text) || 0;
            newStock = currentStock + addQty;
        } else if (decreaseRadio.checked) {
            var subQty = parseInt(quantityInput.text) || 0;
            newStock = currentStock - subQty;
        } else if (setStockRadio.checked) {
            newStock = parseInt(targetStockInput.text) || currentStock;
        }

        // 确保非负
        newStock = Math.max(0, newStock);

        console.log("Stock modification: " + productData.productId +
                   " from " + currentStock + " to " + newStock);

        stockModified(productData.productId, newStock);
        dialog.close();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // 商品信息
        GroupBox {
            Layout.fillWidth: true
            background: Rectangle {
                radius: 8
                color: "#f8f9fa"
                border.color: "#e9ecef"
            }

            ColumnLayout {
                spacing: 5
                anchors.margins: 10

                Text {
                    text: "商品: " + (productData ? productData.name : "")
                    font.pixelSize: 14
                    font.bold: true
                    elide: Text.ElideRight
                }

                RowLayout {
                    Text {
                        text: "当前库存:"
                        color: "#666"
                    }

                    Text {
                        id: currentStockText
                        text: ""
                        font.bold: true
                        color: "#e74c3c"
                    }
                }
            }
        }

        // 修改方式
        GroupBox {
            title: "修改方式"
            Layout.fillWidth: true
            background: Rectangle {
                radius: 8
                color: "#f8f9fa"
                border.color: "#e9ecef"
            }

            ColumnLayout {
                spacing: 10
                anchors.margins: 10

                RadioButton {
                    id: increaseRadio
                    text: "增加库存"
                    checked: true
                    onClicked: updatePreview()

                    contentItem: RowLayout {
                        spacing: 8

                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            border.color: increaseRadio.checked ? "#3498db" : "#95a5a6"
                            border.width: 2
                            color: increaseRadio.checked ? "#3498db" : "transparent"

                            Rectangle {
                                anchors.centerIn: parent
                                width: 8
                                height: 8
                                radius: 4
                                color: "white"
                                visible: increaseRadio.checked
                            }
                        }

                        Text {
                            text: increaseRadio.text
                            font.pixelSize: 14
                            color: "#2c3e50"
                        }
                    }
                }

                RowLayout {
                    visible: increaseRadio.checked

                    Text {
                        text: "增加数量:"
                        color: "#666"
                    }

                    TextField {
                        id: quantityInput
                        Layout.fillWidth: true
                        placeholderText: "请输入要增加的数量"
                        color: "black"
                        validator: IntValidator { bottom: 1; top: 999999 }
                        onTextChanged: updatePreview()

                        background: Rectangle {
                            radius: 6
                            border.color: parent.activeFocus ? "#3498db" : "#bdc3c7"
                            border.width: 1
                        }
                    }
                }

                RadioButton {
                    id: decreaseRadio
                    text: "减少库存"
                    onClicked: updatePreview()

                    contentItem: RowLayout {
                        spacing: 8

                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            border.color: decreaseRadio.checked ? "#3498db" : "#95a5a6"
                            border.width: 2
                            color: decreaseRadio.checked ? "#3498db" : "transparent"

                            Rectangle {
                                anchors.centerIn: parent
                                width: 8
                                height: 8
                                radius: 4
                                color: "white"
                                visible: decreaseRadio.checked
                            }
                        }

                        Text {
                            text: decreaseRadio.text
                            font.pixelSize: 14
                            color: "#2c3e50"
                        }
                    }
                }

                RowLayout {
                    visible: decreaseRadio.checked

                    Text {
                        text: "减少数量:"
                        color: "#666"
                    }

                    TextField {
                        id: quantityInput2
                        Layout.fillWidth: true
                        placeholderText: "请输入要减少的数量"
                        color: "black"
                        validator: IntValidator { bottom: 1; top: 999999 }
                        onTextChanged: updatePreview()

                        background: Rectangle {
                            radius: 6
                            border.color: parent.activeFocus ? "#3498db" : "#bdc3c7"
                            border.width: 1
                        }
                    }
                }

                RadioButton {
                    id: setStockRadio
                    text: "设置库存为"
                    onClicked: updatePreview()

                    contentItem: RowLayout {
                        spacing: 8

                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            border.color: setStockRadio.checked ? "#3498db" : "#95a5a6"
                            border.width: 2
                            color: setStockRadio.checked ? "#3498db" : "transparent"

                            Rectangle {
                                anchors.centerIn: parent
                                width: 8
                                height: 8
                                radius: 4
                                color: "white"
                                visible: setStockRadio.checked
                            }
                        }

                        Text {
                            text: setStockRadio.text
                            font.pixelSize: 14
                            color: "#2c3e50"
                        }
                    }
                }

                RowLayout {
                    visible: setStockRadio.checked

                    Text {
                        text: "目标库存:"
                        color: "#666"
                    }

                    TextField {
                        id: targetStockInput
                        Layout.fillWidth: true
                        placeholderText: "请输入目标库存"
                        color: "black"
                        validator: IntValidator { bottom: 0; top: 999999 }
                        onTextChanged: updatePreview()

                        background: Rectangle {
                            radius: 6
                            border.color: parent.activeFocus ? "#3498db" : "#bdc3c7"
                            border.width: 1
                        }
                    }
                }
            }
        }

        // 预览
        Text {
            id: previewText
            text: "修改后库存: 0"
            font.pixelSize: 14
            font.bold: true
            color: "#2ecc71"
            Layout.alignment: Qt.AlignHCenter
        }

        // 操作按钮
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            StyledButton {
                text: "取消"
                buttonType: "ghost"
                buttonWidth: 80
                buttonHeight: 40
                radius: 8
                onClicked: dialog.reject()
            }

            StyledButton {
                id: confirmButton
                text: "确认修改"
                buttonType: "primary"
                buttonWidth: 120
                buttonHeight: 40
                radius: 8
                disabled: true
                onClicked: applyStockModification()
            }
        }
    }
}
