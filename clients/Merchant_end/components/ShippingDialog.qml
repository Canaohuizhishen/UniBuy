//发货对话框
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: dialog
    title: "订单发货"
    width: 400

    // 圆角背景
    background: Rectangle {
        radius: 12
        color: "white"
        border.color: "#e0e0e0"
        border.width: 1
    }

    property var currentOrder: null
    property string selectedLogistics: "顺丰"
    signal acceptedWithData(string orderId, string logisticsCompany, string trackingNo)

    function openWithOrder(order) {
        currentOrder = order
        waybillField.text = ""  // 清空运单号输入框
        selectedLogistics = "顺丰"
        open()
    }

    ColumnLayout {
        spacing: 15
        anchors.margins: 15

        Text {
            text: "订单号：" + (currentOrder ? currentOrder.orderId : "")
            font.bold: true
            color: "black"
        }

        // 快递公司选择
        GroupBox {
            title: "快递公司"
            Layout.fillWidth: true
            background: Rectangle {
                radius: 8
                color: "#f8f9fa"
                border.color: "#e9ecef"
            }

            label: Label {
                text: parent.title
                color: "black"
                font.pixelSize: 16
                font.bold: true
                leftPadding: 5
            }

            Grid {
                columns: 3
                spacing: 10
                anchors.margins: 10

                Repeater {
                    model: ["顺丰", "中通", "圆通", "申通", "韵达", "京东"]
                    delegate: RadioButton {
                        text: modelData
                        checked: modelData === dialog.selectedLogistics
                        onClicked: dialog.selectedLogistics = modelData

                        indicator: Rectangle {
                            implicitWidth: 20
                            implicitHeight: 20
                            radius: 10
                            border.color: parent.checked ? "#3498db" : "#bdc3c7"
                            border.width: 2
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                anchors.centerIn: parent
                                width: 10
                                height: 10
                                radius: 5
                                color: parent.parent.checked ? "#3498db" : "transparent"
                                visible: parent.parent.checked
                            }
                        }
                        contentItem: Text {
                            text: modelData
                            color: "black"
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: indicator.width + spacing
                        }
                    }
                }
            }
        }

        // 运单号输入
        GroupBox {
            title: "运单信息"
            Layout.fillWidth: true
            background: Rectangle {
                radius: 8
                color: "#f8f9fa"
                border.color: "#e9ecef"
            }

            label: Label {
                text: parent.title
                color: "black"
                font.pixelSize: 16
                font.bold: true
                leftPadding: 5
            }


            ColumnLayout {
                spacing: 5
                anchors.margins: 10

                TextField {
                    id: waybillField
                    placeholderText: "请输入运单号"
                    placeholderTextColor: "#666"
                    Layout.fillWidth: true
                    color: "black"
                    background: Rectangle {
                        radius: 6
                        border.color: parent.activeFocus ? "#3498db" : "#bdc3c7"
                        border.width: 1
                    }
                }

                Text {
                    text: "温馨提示：请核对运单号无误后发货"
                    color: "#666"
                    font.pixelSize: 12
                }
            }
        }
    }

    footer: DialogButtons {
        onAccepted: {
                    if (currentOrder && waybillField.text !== "") {
                        console.log("发货订单：", currentOrder.orderId,
                                  "快递公司：", dialog.selectedLogistics,
                                  "运单号：", waybillField.text)
                        // 发出包含数据的信号
                        dialog.acceptedWithData(currentOrder.orderId, dialog.selectedLogistics, waybillField.text)
                        dialog.accept()
                    }
                }
        onRejected: dialog.reject()
    }
}
