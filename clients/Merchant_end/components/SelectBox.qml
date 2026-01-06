//选择框组件
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

GroupBox {
    id: root
    Layout.fillWidth: true

    // 属性
    property string titleText: ""
    property var model: []
    property int currentIndex: -1
    property string currentText: currentIndex >= 0 && currentIndex < model.length ? model[currentIndex] : ""
    property string tipText: "请选择..."
    property bool isNecessary: false
    property bool showError: false
    property string errorMessage: ""
    property bool isReadOnly: false
    property color borderColor: "#dfe6e9"
    property color focusBorderColor: "#3498db"
    property color errorBorderColor: "#e74c3c"
    property color textColor: "#000000"
    property color placeholderColor: "#95a5a6"
    property bool autoSelectFirst: false

    signal selectionChanged(string selectedValue)
    signal validationFailed()

    // 初始化时确保 currentIndex 为 -1
    Component.onCompleted: {
        console.log("SelectBox completed, currentIndex:", currentIndex, "model length:", model.length)
        // 如果设置了自动选择第一个，则选择第一个
        if (autoSelectFirst && model.length > 0) {
            currentIndex = 0
        } else {
            // 否则确保为 -1，表示未选择
            currentIndex = -1
        }
    }

    // 当模型变化时，重置选择（除非设置了自动选择）
    onModelChanged: {
        console.log("SelectBox model changed, length:", model.length, "autoSelectFirst:", autoSelectFirst)
        if (autoSelectFirst && model.length > 0) {
            currentIndex = 0
        } else {
            currentIndex = -1
        }
    }

    // 验证函数
    function validate() {
        if (isNecessary && currentIndex < 0) {
            showError = true
            errorMessage = "此字段为必选项"
            validationFailed()
            return false
        }
        showError = false
        errorMessage = ""
        return true
    }

    // 清除错误状态
    function clearError() {
        showError = false
        errorMessage = ""
    }

    // 清空选择
    function clear() {
        currentIndex = -1
    }

    // 设置值
    function setValue(value) {
        for (var i = 0; i < model.length; i++) {
            if (model[i] === value) {
                currentIndex = i
                return true
            }
        }
        return false
    }

    // 背景样式
    background: Rectangle {
        color: "transparent"
        border.color: showError ? errorBorderColor : (dropdownPopup.visible ? focusBorderColor : borderColor)
        border.width: showError ? 2 : 1
        radius: 12
    }

    // 主内容区域
    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            // 标题部分
            Row {
                spacing: 2

                Text {
                    text: root.titleText
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2c3e50"
                }

                // 必选标记
                Text {
                    visible: root.isNecessary
                    text: "*"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#e74c3c"
                }
            }

            // 选择框主体
            Rectangle {
                id: selectBoxContainer
                Layout.preferredWidth: 250
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignRight
                radius: 8
                border.color: showError ? errorBorderColor :
                                          (dropdownPopup.visible ? focusBorderColor : "#dfe6e9")
                border.width: 1
                color: isReadOnly ? "#f8f9fa" : "white"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    // 当前选择显示
                    Text {
                        id: displayText
                        Layout.fillWidth: true
                        text: currentIndex >= 0 ? currentText : tipText
                        color: currentIndex >= 0 ? textColor : placeholderColor
                        font.pixelSize: 14
                        elide: Text.ElideRight
                    }

                    // 下拉箭头
                    Text {
                        text: dropdownPopup.visible ? "▲" : "▼"
                        color: "#95a5a6"
                        font.pixelSize: 12
                        visible: !isReadOnly
                    }
                }

                // 鼠标区域
                MouseArea {
                    anchors.fill: parent
                    enabled: !isReadOnly
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onEntered: {
                        if (!isReadOnly && !showError) {
                            selectBoxContainer.border.color = focusBorderColor
                        }
                    }

                    onExited: {
                        if (!isReadOnly && !showError) {
                            selectBoxContainer.border.color = "#dfe6e9"
                        }
                    }

                    onClicked: {
                        if (!isReadOnly) {
                            if (dropdownPopup.visible) {
                                dropdownPopup.close()
                            } else {
                                dropdownPopup.open()
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            // 错误提示
            Text {
                id: errorText
                visible: showError && errorMessage !== ""
                text: errorMessage
                color: "#e74c3c"
                font.pixelSize: 12
                Layout.fillWidth: true
                Layout.leftMargin: 5
            }

            // 帮助文本
            Text {
                id: helpText
                visible: tipText !== "" && !showError
                text: tipText
                color: "#95a5a6"
                font.pixelSize: 12
                Layout.fillWidth: true
                Layout.leftMargin: 5
            }
        }
    }

    // 下拉菜单弹出框
    Popup {
        id: dropdownPopup
        x: selectBoxContainer.x
        y: selectBoxContainer.height + 2
        width: selectBoxContainer.width
        height: Math.min(300, dropdownList.contentHeight + 20)
        padding: 0
        modal: true
        focus: true

        background: Rectangle {
            radius: 8
            color: "white"
            border.color: "#dfe6e9"
            border.width: 1
        }

        contentItem: ListView {
            id: dropdownList
            clip: true
            model: root.model
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                width: dropdownPopup.width
                height: 36
                color: index === currentIndex ? "#f0f7ff" :
                                                mouseArea.containsMouse ? "#f8f9fa" : "white"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    // 选项文本
                    Text {
                        text: modelData
                        color: "#000000"
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    // 选中标记
                    Text {
                        visible: index === currentIndex
                        text: "✓"
                        color: "#3498db"
                        font.pixelSize: 14
                    }
                }

                // 鼠标区域
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        var oldIndex = currentIndex
                        currentIndex = index
                        clearError()
                        dropdownPopup.close()

                        // 发出自定义选择改变信号
                        if (oldIndex !== index) {
                            selectionChanged(modelData)
                        }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 8
            }
        }

        onOpened: {
            // 滚动到当前选中项
            if (currentIndex >= 0) {
                dropdownList.positionViewAtIndex(currentIndex, ListView.Contain)
            }
        }

        onClosed: {
            // 触发验证
            if (isNecessary) {
                validate()
            }
        }
    }

    onCurrentIndexChanged: {
        if (currentIndex >= 0 && currentIndex < model.length) {
            selectionChanged(model[currentIndex])
        }
    }
}
