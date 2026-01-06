//导航按钮
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    property string text: ""
    property string iconText: ""
    property bool isActive: false
    signal clicked

    width: parent.width
    height: 50
    radius: 8
    color: isActive ? "#3498db" : "transparent"

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 20
        spacing: 10

        Text {
            text: iconText
            font.pixelSize: 16
            color: isActive ? "white" : "#bdc3c7"
        }

        Text {
            text: parent.text
            color: isActive ? "white" : "#ecf0f1"
            font.pixelSize: 14
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.clicked()
    }
}
