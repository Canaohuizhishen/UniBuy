// 对话框按钮组
import QtQuick 2.15
import QtQuick.Layouts 1.15

Row {
    spacing: 12
    layoutDirection: Qt.RightToLeft

    property string cancelText: "取消"
    property string okText: "确定"
    property bool destructive: false
    signal accepted
    signal rejected

    StyledButton {
        text: parent.cancelText
        buttonType: "ghost"
        buttonWidth: 80
        buttonHeight: 40
        radius: 8
        onClicked: parent.rejected()
    }

    StyledButton {
        text: parent.okText
        buttonType: parent.destructive ? "danger" : "primary"
        buttonWidth: 80
        buttonHeight: 40
        radius: 8
        onClicked: parent.accepted()
    }
}
