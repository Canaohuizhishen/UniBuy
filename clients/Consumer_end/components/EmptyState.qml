import QtQuick

Column {
    property string icon: "📦"
    property string title: "暂无数据"
    property string description: ""
    property color textColor: "#999"
    property real iconSize: 48
    property real titleSize: 16
    property real descriptionSize: 14

    spacing: 10

    Text {
        text: icon
        font.pixelSize: iconSize
        color: textColor
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        text: title
        font.pixelSize: titleSize
        color: textColor
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        visible: description !== ""
        text: description
        font.pixelSize: descriptionSize
        color: textColor
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
