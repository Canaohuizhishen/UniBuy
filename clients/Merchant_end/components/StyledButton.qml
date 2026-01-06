// 通用按钮组件
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: buttonWidth
    height: buttonHeight

    // 属性
    property string text: ""
    property int buttonWidth: 80
    property int buttonHeight: 36
    property string buttonType: "default"  // "default", "primary", "success", "warning", "danger", "ghost"
    property string icon: ""
    property bool disabled: false
    property bool loading: false
    radius: 8

    // 信号
    signal clicked

    // 计算属性：根据按钮类型获取颜色
    property color backgroundColor: {
        if (disabled) return "#e0e0e0"
        switch(buttonType) {
            case "primary": return "#3498db"
            case "success": return "#2ecc71"
            case "warning": return "#f39c12"
            case "danger": return "#e74c3c"
            case "ghost": return "transparent"
            default: return "#f5f6fa"
        }
    }

    property color hoverColor: {
        if (disabled) return "#e0e0e0"
        switch(buttonType) {
            case "primary": return "#2980b9"
            case "success": return "#27ae60"
            case "warning": return "#e67e22"
            case "danger": return "#c0392b"
            case "ghost": return "#f8f9fa"
            default: return "#e9ecef"
        }
    }

    property color textColor: {
        if (disabled) return "#95a5a6"
        switch(buttonType) {
            case "ghost": return "#3498db"
            default: return buttonType === "default" ? "#2c3e50" : "white"
        }
    }

    property color borderColor: {
        if (disabled) return "#d5d5d5"
        switch(buttonType) {
            case "ghost": return "#3498db"
            case "default": return "#d1d5db"
            default: return backgroundColor
        }
    }

    property color hoverBorderColor: {
        if (disabled) return "#d5d5d5"
        switch(buttonType) {
            case "ghost": return "#2980b9"
            case "default": return "#3498db"
            default: return hoverColor
        }
    }

    // 按钮主体
    color: root.disabled ? root.backgroundColor :
           mouseArea.containsPress ? root.hoverColor :
           mouseArea.containsMouse ? root.hoverColor : root.backgroundColor

    border.color: root.disabled ? root.borderColor :
                mouseArea.containsMouse ? root.hoverBorderColor : root.borderColor
    border.width: 1

    // 加载动画
    Rectangle {
        id: loadingOverlay
        anchors.fill: parent
        color: Qt.rgba(1, 1, 1, 0.7)
        radius: root.radius
        visible: root.loading

        RotationAnimator {
            target: loadingIcon
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
            running: root.loading
        }

        Text {
            id: loadingIcon
            text: "⟳"
            font.pixelSize: 16
            color: root.textColor
            anchors.centerIn: parent
        }
    }

    // 按钮内容 - 直接显示图标和文字
    Row {
        anchors.centerIn: parent
        spacing: iconText.text ? 6 : 0

        // 图标
        Text {
            id: iconText
            text: root.icon
            font.pixelSize: 14
            color: root.textColor
            visible: text !== ""
        }

        // 文字
        Text {
            id: buttonText
            text: root.text
            font.pixelSize: 14
            font.weight: Font.Medium
            color: root.textColor
        }
    }

    // 鼠标区域
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
        enabled: !root.disabled && !root.loading

        onClicked: {
            if (!root.loading && !root.disabled) {
                root.clicked()
            }
        }
    }
}
