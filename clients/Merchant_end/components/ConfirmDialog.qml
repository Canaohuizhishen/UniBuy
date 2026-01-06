// 通用确认对话框
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

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

    // 圆角背景
    background: Rectangle {
        radius: 12
        color: "white"
        border.color: "#e0e0e0"
        border.width: 1
    }

    // 简化的对话框内容
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

        DialogButtons {
            cancelText: dialog.cancelText
            okText: dialog.okText
            destructive: dialog.destructive
            Layout.alignment: Qt.AlignHCenter
            onAccepted: dialog.accept()
            onRejected: dialog.reject()
        }
    }
}
