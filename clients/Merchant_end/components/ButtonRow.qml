// 按钮组容器
import QtQuick 2.15
import QtQuick.Layouts 1.15

RowLayout {
    id: root
    spacing: 10

    property var buttons: []
    property bool alignRight: false

    Layout.alignment: alignRight ? Qt.AlignRight : Qt.AlignLeft

    // 动态创建按钮
    Repeater {
        model: root.buttons
        delegate: StyledButton {
            text: modelData.text
            buttonType: modelData.type || "default"
            icon: modelData.icon || ""
            buttonWidth: modelData.width || 80
            buttonHeight: modelData.height || 36
            radius: modelData.radius || 6
            disabled: modelData.disabled || false

            onClicked: if (modelData.onClick) modelData.onClick()
        }
    }
}
