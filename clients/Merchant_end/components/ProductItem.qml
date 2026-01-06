//商品列表项
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "./"

Rectangle {
    property var productData: null
    signal editClicked(var product)
    signal statusClicked(var product)
    signal deleteClicked(var product)
    signal restockClicked(var product)  //补货按钮点击信号

    radius: 12
    color: "white"
    border.color: "#eee"
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // 商品图片
        Rectangle {
            width: 100
            height: 100
            color: "#f8f9fa"
            radius: 8  // 增加圆角

            // 商品图片预览
            Rectangle {
                anchors.fill: parent
                anchors.margins: 8
                color: "#e9ecef"
                radius: 6  // 增加圆角

                // 商品图片占位符
                Text {
                    text: "📦"
                    font.pixelSize: 24
                    anchors.centerIn: parent
                }

                // 图片数量指示器
                Text {
                    visible: productData && productData.images && productData.images.length > 0
                    text: productData && productData.images ? productData.images.length + "张" : ""
                    color: "#6c757d"
                    font.pixelSize: 10
                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        margins: 2
                    }
                }
            }
        }

        // 商品信息
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            // 商品名称和ID
            RowLayout {
                Text {
                    text: productData ? productData.name : ""
                    font.pixelSize: 16
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // 使用状态标签组件
                StatusBadge {
                    status: productData ? productData.status : ""
                    Layout.alignment: Qt.AlignRight
                }
            }

            // 分类和标签
            RowLayout {
                Text {
                    text: productData ? "分类：" + productData.category : ""
                    font.pixelSize: 12
                    color: "#666"
                }

                // 标签
                Flow {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: productData && productData.tags ? productData.tags : []

                        delegate: Rectangle {
                            height: 18
                            radius: 9  // 增加圆角
                            color: "#e9ecef"

                            Text {
                                text: modelData
                                color: "#495057"
                                font.pixelSize: 10
                                anchors.centerIn: parent
                                anchors.horizontalCenterOffset: 1
                                anchors.verticalCenterOffset: 1
                            }
                        }
                    }
                }
            }

            // 价格信息
            RowLayout {
                // 当前价格
                Text {
                    text: productData ? "¥" + productData.price : ""
                    font.pixelSize: 18
                    color: "#e74c3c"
                    font.bold: true
                }

                // 原价
                Text {
                    visible: productData && productData.originalPrice
                    text: productData && productData.originalPrice ? "¥" + productData.originalPrice : ""
                    font.pixelSize: 12
                    color: "#6c757d"
                    font.strikeout: true
                }

                Item { Layout.fillWidth: true }

                // SKU数量
                Text {
                    text: productData && productData.skuList ? productData.skuList.length + "个规格" : "1个规格"
                    color: "#6c757d"
                    font.pixelSize: 11
                }
            }

            // 库存和销量信息
            RowLayout {
                spacing: 20

                Text {
                    text: productData ? "库存：" + productData.stock : ""
                    font.pixelSize: 12
                    color: productData && productData.stock <= 10 ? "#e74c3c" : "#666"
                }

                Text {
                    text: productData ? "销量：" + productData.sales : ""
                    font.pixelSize: 12
                    color: "#666"
                }

                Text {
                    text: productData ? "更新时间：" + productData.updateTime : ""
                    font.pixelSize: 11
                    color: "#adb5bd"
                }

                Item { Layout.fillWidth: true }
            }
        }

        // 操作按钮
        Column {
            spacing: 6

            SmallButton {
                text: "编辑"
                buttonType: "primary"
                radius: 6
                onClicked: editClicked(productData)
            }

            SmallButton {
                text: getStatusButtonText(productData ? productData.status : "")
                buttonType: {
                    if (!productData) return "default"
                    switch(productData.status) {
                        case "出售中": return "warning"
                        case "已下架": return "success"
                        case "已售罄": return "primary"
                        case "待审核": return "default"
                        default: return "default"
                    }
                }
                radius: 6
                enabled: productData && productData.status !== "待审核"
                onClicked: {
                    console.log("Status button clicked for product:", productData.productId,
                               "Current status:", productData.status);

                    if (productData.status === "已售罄") {
                        // 发出补货信号，由父组件处理
                        restockClicked(productData);
                    } else {
                        // 原来的状态切换逻辑
                        statusClicked(productData);
                    }
                }
            }

            SmallButton {
                text: "删除"
                buttonType: "danger"
                radius: 6
                onClicked: deleteClicked(productData)
            }
        }
    }

    // 获取状态按钮文本
    function getStatusButtonText(status) {
        switch(status) {
        case "出售中": return "下架"
        case "已下架": return "上架"
        case "已售罄": return "补货"
        case "待审核": return "审核中"
        default: return "操作"
        }
    }
}
