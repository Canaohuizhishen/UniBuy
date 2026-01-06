// 搜索输入框
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    id: root
    property string placeholderText: "搜索..."
    property alias text: textField.text
    signal searchTriggered(string text)

    width: 300
    height: 40
    radius: 20  // 圆形输入框
    border.color: "#ddd"
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        Text {
            text: "🔍"
            font.pixelSize: 14
            color: "#999"
        }

        TextField {
            id: textField
            Layout.fillWidth: true
            placeholderText: root.placeholderText
            font.pixelSize: 14
            background: null
            color: "#000000"

            onAccepted: root.searchTriggered(text)
        }
    }
}
