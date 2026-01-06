//订单统计卡片
import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    property var statData: null

    radius: 12
    color: statData ? statData.color : "#3498db"
    opacity: 0.9

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: statData ? statData.title : ""
            color: "white"
            font.pixelSize: 12
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: statData ? statData.value : ""
            color: "white"
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
