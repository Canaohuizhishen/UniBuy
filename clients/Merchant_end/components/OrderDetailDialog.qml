// OrderDetailDialog.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
Dialog {
    id: dialog
    title: "订单详情"
    width: 600
    height: 550

    // 圆角背景
    background: Rectangle {
        radius: 12
        color: "white"
        border.color: "#e0e0e0"
        border.width: 1
    }

    property var currentOrder: null

    function openWithOrder(order) {
        currentOrder = order
        open()
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: contentLayout.height

        ColumnLayout {
            id: contentLayout
            width: parent.width
            spacing: 15
            anchors.margins: 15

            // 订单基本信息
            GroupBox {
                title: "订单信息"
                Layout.fillWidth: true
                background: Rectangle {
                    radius: 8
                    color: "#f8f9fa"
                    border.color: "#e9ecef"
                }

                GridLayout {
                    columns: 2
                    rowSpacing: 8
                    columnSpacing: 20
                    anchors.margins: 10

                    Text { text: "订单号：" }
                    Text { text: currentOrder ? currentOrder.orderId : ""; font.bold: true }

                    Text { text: "下单时间：" }
                    Text { text: currentOrder ? currentOrder.time : "" }

                    Text { text: "订单状态：" }
                    Text {
                        text: currentOrder ? currentOrder.status : ""
                        color: {
                            if (!currentOrder) return "#666"
                            switch(currentOrder.status) {
                            case "待发货": return "#e74c3c"
                            case "待收货": return "#f39c12"
                            case "已完成": return "#2ecc71"
                            default: return "#666"
                            }
                        }
                        font.bold: true
                    }

                    Text { text: "订单金额：" }
                    Text {
                        text: currentOrder ? currentOrder.total : ""
                        color: "#e74c3c"
                        font.bold: true
                        font.pixelSize: 16
                    }
                }
            }

            // 收货信息
            GroupBox {
                title: "收货信息"
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
                        text: "收货人：张三"
                        font.pixelSize: 14
                    }

                    Text {
                        text: "联系电话：138****8888"
                        font.pixelSize: 14
                    }

                    Text {
                        text: "收货地址：北京市朝阳区xxx街道xxx号"
                        font.pixelSize: 14
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }
            }

            // 商品信息
            GroupBox {
                title: "商品信息"
                Layout.fillWidth: true
                background: Rectangle {
                    radius: 8
                    color: "#f8f9fa"
                    border.color: "#e9ecef"
                }


                ScrollView {  // 添加滚动视图
                    anchors.fill: parent
                    anchors.margins: 5  // 添加一些边距

                    ListView {
                        width: parent.width
                        model: currentOrder ? currentOrder.items : null
                        delegate: RowLayout {
                            width: parent.width
                            spacing: 10
                            anchors.margins: 10

                            Text {
                                text: model.name
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "×" + model.quantity
                                color: "#666"
                            }

                            Text {
                                text: model.price
                                color: "#e74c3c"
                            }
                        }
                    }
                }
            }

            // 物流信息
            GroupBox {
                title: "物流信息"
                visible: currentOrder &&
                       (currentOrder.status === "待收货" ||
                        currentOrder.status === "已完成" ||
                        currentOrder.status === "已发货")
                Layout.fillWidth: true
                background: Rectangle {
                    radius: 8
                    color: "#f8f9fa"
                    border.color: "#e9ecef"
                }

                ColumnLayout {
                    spacing: 5
                    anchors.margins: 10

                    RowLayout {
                        Text { text: "快递公司：" }
                        Text { text: "顺丰速运"; font.bold: true }

                        Item { Layout.fillWidth: true }

                        Button {
                            text: "复制单号"
                            background: Rectangle {
                                radius: 6
                                color: parent.down ? "#e0e0e0" : "#f5f6fa"
                            }
                            onClicked: copyToClipboard("SF123456789")
                        }
                    }

                    Text { text: "运单号：SF123456789" }

                    ColumnLayout {
                        spacing: 10

                        Text { text: "物流轨迹：" }

                        Repeater {
                            model: [
                                {time: "2023-12-16 15:30", status: "已签收"},
                                {time: "2023-12-16 10:20", status: "正在派送"},
                                {time: "2023-12-15 18:45", status: "到达北京转运中心"},
                                {time: "2023-12-15 14:10", status: "已发货"}
                            ]
                            delegate: RowLayout {
                                width: parent.width

                                Rectangle {
                                    width: 10
                                    height: 10
                                    radius: 5
                                    color: index === 0 ? "#2ecc71" : "#ddd"
                                    border.color: index === 0 ? "#27ae60" : "#ccc"
                                }

                                ColumnLayout {
                                    spacing: 2

                                    Text {
                                        text: modelData.status
                                        font.pixelSize: 12
                                    }

                                    Text {
                                        text: modelData.time
                                        font.pixelSize: 10
                                        color: "#666"
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 操作按钮区域
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Layout.topMargin: 50
                spacing: 8

                Button {
                    text: "联系买家"
                    background: Rectangle {
                        radius: 6
                        color: parent.down ? "#e0e0e0" : "#f5f6fa"
                    }
                    onClicked: contactBuyer()
                }

                Button {
                    text: "打印发货单"
                    visible: currentOrder && currentOrder.status === "待发货"
                    background: Rectangle {
                        radius: 6
                        color: parent.down ? "#e0e0e0" : "#f5f6fa"
                    }
                }

                Button {
                    text: currentOrder && currentOrder.status === "待发货" ? "立即发货" : "处理售后"
                    background: Rectangle {
                        radius: 6
                        color: "#3498db"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                    }
                    onClicked: {
                        if (currentOrder && currentOrder.status === "待发货") {
                            shippingDialog.openWithOrder(currentOrder)
                        } else {
                            // 处理售后
                        }
                    }
                }
            }
        }
    }

    footer: DialogButtons {
        okText: "关闭"
        onAccepted: dialog.accept()
        onRejected: dialog.reject()
    }

    function contactBuyer() {
        console.log("联系买家")
    }

    function copyToClipboard(text) {
        console.log("复制到剪贴板:", text)
    }
}
