import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: dialog
    title: "确认操作"
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property string message: ""
    property string okText: "确定"
    property string cancelText: "取消"
    property bool destructive: false

    width: 350
    height: 180
    x: parent ? (parent.width - width) / 2 : 0
    y: parent ? (parent.height - height) / 2 : 0

    background: Rectangle {
        radius: 12
        color: "white"
        border.color: "#e0e0e0"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // 标题区域
        Text {
            text: dialog.title
            font.pixelSize: 18
            font.bold: true
            color: destructive ? "#e74c3c" : "#2c3e50"
            Layout.alignment: Qt.AlignHCenter
        }

        // 消息内容
        Text {
            text: message
            font.pixelSize: 14
            color: "#555"
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        // 按钮区域
        RowLayout {
            spacing: 12
            Layout.alignment: Qt.AlignHCenter

            // 取消按钮
            Button {
                visible: cancelText !== ""
                text: cancelText
                onClicked: dialog.reject()

                background: Rectangle {
                    radius: 6
                    color: parent.down ? "#e0e0e0" : "#f5f6fa"
                }

                contentItem: Text {
                    text: parent.text
                    color: "#666"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // 确定按钮
            Button {
                text: okText
                onClicked: dialog.accept()

                background: Rectangle {
                    radius: 6
                    color: destructive ? (parent.down ? "#c0392b" : "#e74c3c") :
                           (parent.down ? "#2980b9" : "#3498db")
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
