// 图标按钮
import QtQuick 2.15
import QtQuick.Controls 2.15

StyledButton {
    id: root
    property string icon: "⚙️"
    property int iconSize: 20

    buttonWidth: 40
    buttonHeight: 40
    radius: 20  // 圆形按钮
    buttonType: "ghost"

    contentItem: Item {
        anchors.fill: parent

        Text {
            text: root.icon
            font.pixelSize: root.iconSize
            color: root.textColor
            anchors.centerIn: parent
        }
    }
}
