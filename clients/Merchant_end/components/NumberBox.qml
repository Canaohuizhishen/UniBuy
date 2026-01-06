//数字输入框
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

GroupBox {
    id: box
    property string titleText: ""
    property alias tipText: input.placeholderText
    property alias text: input.text
    property alias inputBoxColor: inputBox.color
    property alias inputTextColor: input.color
    property alias unitText: unitText.text
    property bool isFloat: false // 是否浮点数模式
    property real minValue: -Infinity // 最小值限制
    property real maxValue: Infinity // 最大值限制
    property int decimals: 2 // 小数位数（仅浮点数模式有效）
    property bool isNecessary: false
    property bool showError: false
    property string errorMessage: ""
    property bool isReadOnly: false // 只读属性

    Layout.fillWidth: true

    topPadding: 10

    // 当文本变化时验证数值范围
    onTextChanged: {
        if (text !== "") {
            validateNumber()
        } else {
            clearError()
        }
    }

    // 验证数值范围函数
    function validateNumber() {
        var num = parseFloat(text)

        // 检查是否为有效数字
        if (isNaN(num)) {
            showError = true
            errorMessage = "请输入有效的数字"
            return false
        }

        // 如果是整数模式但不是整数
        if (!isFloat && !Number.isInteger(num)) {
            showError = true
            errorMessage = "请输入整数"
            return false
        }

        // 检查最小值
        if (num < minValue) {
            showError = true
            errorMessage = "数值不能小于" + minValue
            return false
        }

        // 检查最大值
        if (num > maxValue) {
            showError = true
            errorMessage = "数值不能大于" + maxValue
            return false
        }

        // 如果是浮点数，格式化小数位数
        if (isFloat) {
            input.text = num.toFixed(decimals)
        }

        showError = false
        errorMessage = ""
        return true
    }

    // 返回错误状态的函数
    function isError() {
        if (isNecessary && input.text.trim() === "") {
            showError = true
            errorMessage = "此字段为必填项"
        } else {
            validateNumber()
        }
        return showError
    }

    // 清除错误状态
    function clearError() {
        showError = false
        errorMessage = ""
    }

    background: Rectangle {
        color: "transparent"
        border.color: showError ? "red" : "#dfe6e9" // 错误时显示红色边框
        border.width: showError ? 2 : 1
        radius: 12
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        RowLayout {
            // 标题部分
            Row{
                spacing: 2

                Text {
                    text: box.titleText
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2c3e50"
                }

                Text {
                    visible: box.isNecessary
                    text: "*"
                    font.pixelSize: 16
                    font.bold: true
                    color: "red"
                }
            }

            // 输入框区域
            TextField {
                id: input
                Layout.fillWidth: true
                placeholderText: tipText || (isFloat ? "请输入小数..." : "请输入整数...")
                placeholderTextColor: "#95a5a6"
                selectByMouse: true
                font.pixelSize: 14
                color: "#000000"
                readOnly: box.isReadOnly
                height: 36

                leftPadding: 12
                rightPadding: 12
                verticalAlignment: Text.AlignVCenter

                onTextChanged: {
                    box.text = text
                }

                // 按键处理，限制输入
                Keys.onPressed: function(event){
                    // 只允许数字、小数点（浮点数模式）、负号、删除和方向键
                    var allowedKeys = [
                        Qt.Key_0, Qt.Key_1, Qt.Key_2, Qt.Key_3, Qt.Key_4,
                        Qt.Key_5, Qt.Key_6, Qt.Key_7, Qt.Key_8, Qt.Key_9,
                        Qt.Key_Backspace, Qt.Key_Delete, Qt.Key_Left,
                        Qt.Key_Right, Qt.Key_Up, Qt.Key_Down,
                        Qt.Key_PageUp, Qt.Key_PageDown, Qt.Key_Home,
                        Qt.Key_End, Qt.Key_Tab, Qt.Key_Enter,
                        Qt.Key_Return, Qt.Key_Escape
                    ]

                    // 如果是浮点数模式，允许小数点
                    if (isFloat) {
                        allowedKeys.push(Qt.Key_Period)
                    }

                    // 允许负号（如果最小值小于0）
                    if (minValue < 0) {
                        allowedKeys.push(Qt.Key_Minus)
                    }

                    // 检查是否是控制键组合
                    var isControlKey = (event.modifiers & Qt.ControlModifier) ||
                                      (event.modifiers & Qt.AltModifier)

                    // 如果按下的键不在允许列表中，且不是控制键组合，则阻止输入
                    if (!isControlKey && allowedKeys.indexOf(event.key) === -1) {
                        event.accepted = true
                    }
                }

                background: Rectangle {
                    id: inputBox
                    color: "white"
                    radius: 8
                    border.color: showError ? "red" : (input.activeFocus ? "#3498db" : "#dfe6e9")
                    border.width: 1
                }
            }

            Label {
                id: unitText
                visible: text !== ""
                text: ""
                font.pixelSize: 14
                color: "#7f8c8d"
                Layout.alignment: Qt.AlignRight
            }
        }

        // 错误提示
        Text {
            id: errorText
            visible: showError && errorMessage !== ""
            text: errorMessage
            color: "red"
            font.pixelSize: 12
            Layout.fillWidth: true
            Layout.leftMargin: 5
            Layout.bottomMargin: 5
        }
    }
}
