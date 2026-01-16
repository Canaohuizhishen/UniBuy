// 物流跟踪对话框 - 优化间距
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: dialog
    width: 500
    height: 500
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property var orderData: null

    background: Rectangle {
        radius: 12
        color: "white"
        border.color: "#e0e0e0"
        border.width: 1
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // 标题
        Text {
            text: "物流信息"
            font.pixelSize: 18
            font.bold: true
            color: "#2c3e50"
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }

        // 物流公司信息
        Column {
            width: parent.width
            spacing: 12

            Text {
                text: "物流信息"
                font.pixelSize: 16
                font.bold: true
                color: "#2c3e50"
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#e0e0e0"
            }

            Grid {
                width: parent.width
                columns: 2
                columnSpacing: 20
                rowSpacing: 12

                Text {
                    text: "快递公司："
                    font.pixelSize: 14
                    color: "#666"
                }
                Text {
                    text: orderData && orderData.logisticsInfo ?
                          orderData.logisticsInfo.company : "暂无信息"
                    font.pixelSize: 14
                    font.bold: true
                }

                Text {
                    text: "运单号："
                    font.pixelSize: 14
                    color: "#666"
                }
                Text {
                    text: orderData && orderData.logisticsInfo ?
                          orderData.logisticsInfo.trackingNumber : "暂无信息"
                    font.pixelSize: 14
                }

                Text {
                    text: "当前状态："
                    font.pixelSize: 14
                    color: "#666"
                }
                Text {
                    text: orderData && orderData.logisticsInfo ?
                          orderData.logisticsInfo.currentStatus : "暂无信息"
                    color: "#3498db"
                    font.pixelSize: 14
                    font.bold: true
                }

                Text {
                    text: "当前位置："
                    font.pixelSize: 14
                    color: "#666"
                }
                Text {
                    text: orderData && orderData.logisticsInfo ?
                          orderData.logisticsInfo.currentLocation : "暂无信息"
                    font.pixelSize: 14
                }
            }
        }

        // 物流轨迹
        Column {
            width: parent.width
            height: parent.height - children[0].height - children[1].height - 32
            spacing: 12

            Text {
                text: "物流轨迹"
                font.pixelSize: 16
                font.bold: true
                color: "#2c3e50"
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#e0e0e0"
            }

            // 物流轨迹列表
            ScrollView {
                width: parent.width
                height: parent.height - 30
                clip: true

                Column {
                    id: trackingColumn
                    width: parent.width
                    spacing: 20  // 轨迹项之间的间距

                    Repeater {
                        model: orderData && orderData.logisticsInfo &&
                               orderData.logisticsInfo.trackingHistory ?
                               orderData.logisticsInfo.trackingHistory : []

                        delegate: Row {
                            width: parent.width
                            spacing: 16

                            // 时间轴竖线
                            Column {
                                width: 30
                                spacing: 0

                                // 时间轴点
                                Rectangle {
                                    width: 14
                                    height: 14
                                    radius: 7
                                    color: index === 0 ? "#3498db" : "#ddd"
                                    border.color: index === 0 ? "#2980b9" : "#ccc"
                                    border.width: 2
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                // 时间轴线
                                Rectangle {
                                    visible: index < trackingColumn.children.length - 1
                                    width: 2
                                    height: 20
                                    color: "#ddd"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            // 轨迹信息
                            Column {
                                width: parent.width - 46
                                spacing: 4

                                Text {
                                    text: modelData.time || ""
                                    font.pixelSize: 13
                                    color: "#666"
                                    width: parent.width
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: modelData.description || ""
                                    font.pixelSize: 15
                                    font.bold: true
                                    width: parent.width
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }

                    // 空状态
                    Rectangle {
                        visible: trackingColumn.children.length === 0
                        width: parent.width
                        height: 100
                        color: "transparent"

                        Text {
                            text: "暂无物流轨迹"
                            font.pixelSize: 14
                            color: "#999"
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }
    }
}
