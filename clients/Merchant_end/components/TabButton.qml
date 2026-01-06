//标签页按钮
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    property string text: ""
    property bool checked: false
    signal clicked

    width: text.length * 15 + 30
    height: 36
    color: checked ? "#3498db" : "transparent"
    radius: 18  // 圆形按钮

    Text {
        text: parent.text
        color: checked ? "white" : "#666"
        font.pixelSize: 14
        anchors.centerIn: parent
    }

    Rectangle {
        visible: checked
        width: 20
        height: 3
        color: "white"
        radius: 1.5
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 5
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.clicked()
    }
}
