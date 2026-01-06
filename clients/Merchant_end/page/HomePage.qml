// 首页
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    anchors.fill: parent
    property alias productManagementButton: productManagementButton
    property alias orderManagementButton: orderManagementButton

    // 背景
    Rectangle {
        anchors.fill: parent
        color: "#f5f6fa"

        // 标题
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 40
            text: "商家中心"
            font.pixelSize: 32
            font.bold: true
            color: "#2c3e50"
        }

        // 网格视图容器
        Rectangle {
            anchors.centerIn: parent
            width: gridLayout.width + 80
            height: gridLayout.height + 80
            radius: 20
            color: "white"

            // 网格布局
            GridLayout {
                id: gridLayout
                anchors.centerIn: parent
                columns: 5
                rows: 2
                columnSpacing: 20
                rowSpacing: 20

                // 商品管理按钮
                Button {
                    id: productManagementButton
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 120
                    text: "商品管理"

                    background: Rectangle {
                        radius: 10
                        color: parent.down ? "#2980b9" : "#3498db"
                    }

                    contentItem: Column {
                        spacing: 10

                        Text {
                            text: "📦"
                            font.pixelSize: 32
                            color: "white"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: parent.parent.text
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    onClicked: {
                        console.log("点击了商品管理按钮")
                    }
                }

                // 订单管理按钮
                Button {
                    id: orderManagementButton
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 120
                    text: "订单管理"

                    background: Rectangle {
                        radius: 10
                        color: parent.down ? "#c0392b" : "#e74c3c"
                    }

                    contentItem: Column {
                        spacing: 10

                        Text {
                            text: "📋"
                            font.pixelSize: 32
                            color: "white"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: parent.parent.text
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    onClicked: {
                        console.log("点击了订单管理按钮")
                    }
                }

                // 其他按钮，为了美观
                Repeater {
                    model: [
                        {text: "数据中心", icon: "📊", color: "#2ecc71"},
                        {text: "店铺管理", icon: "🏪", color: "#f39c12"},
                        {text: "资金账户", icon: "💰", color: "#9b59b6"},
                        {text: "客服咨询", icon: "💬", color: "#1abc9c"},
                        {text: "系统通知", icon: "🔔", color: "#34495e"},
                        {text: "营销活动", icon: "🎯", color: "#e67e22"},
                        {text: "数据分析", icon: "📈", color: "#16a085"},
                        {text: "帮助中心", icon: "❓", color: "#7f8c8d"}
                    ]

                    delegate: Button {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 120
                        text: modelData.text

                        background: Rectangle {
                            radius: 10
                            color: parent.down ? Qt.darker(modelData.color, 1.2) : modelData.color
                        }

                        contentItem: Column {
                            spacing: 10

                            Text {
                                text: modelData.icon
                                font.pixelSize: 32
                                color: "white"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: parent.parent.text
                                color: "white"
                                font.pixelSize: 14
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        onClicked: {
                            console.log("点击了" + modelData.text + "按钮")
                        }
                    }
                }
            }
        }

        // 底部信息
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            text: "UniBuy商家端 vip"
            font.pixelSize: 12
            color: "#95a5a6"
        }
    }
}
