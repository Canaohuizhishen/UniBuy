//多行文本输入框
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

GroupBox {
    id: box
    title: ""
    property alias tipText: input.placeholderText
    property alias text: input.text
    property alias inputBoxColor: inputBox.color
    property alias inputTextColor: input.color
    property alias unitText: unitText.text
    property int maxWordNum: 100
    property bool isNecessary: false
    property bool showError: false
    property string errorMessage: ""
    property bool isReadOnly: false

    Layout.fillWidth: true

    // 当文本变化时更新字数统计
    onTextChanged: updateWordCount()

    // 更新字数统计函数
    function updateWordCount() {
        wordCountText.text = input.text.length
        if (input.text.length === maxWordNum) {
            showError = true
            errorMessage = "字数超过限制，最多" + maxWordNum + "字"
            // 如果超过了最大字数，截断文本
            input.text = input.text.substring(0, maxWordNum)
        }else {
            showError = false
            errorMessage = ""
        }
    }

    // 返回错误状态的函数
    function isError() {
        if (isNecessary && input.text.trim() === "") {
            showError = true
            errorMessage = "此字段为必填项"
        }else {
            showError = false
            errorMessage = ""
        }
        return showError
    }

    // 清除错误状态
    function clearError() {
        showError = false
        errorMessage = ""
    }

    // 标题行（包含标题和字数统计）
    label: Row{
        spacing: 10
        leftPadding: 10
        topPadding: 10

        // 标题部分
        Row{
            spacing: 2

            Text {
                text: box.title
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

        Item { Layout.fillWidth: true } // 占位空间

        // 字数统计
        Row{
            Text {
                id: wordCountText
                text: "0"
                font.pixelSize: 12
                color: input.text.length > maxWordNum ? "red" : "#2c3e50"
            }
            Text {
                id: wordMaxText
                text: "/" + maxWordNum
                font.pixelSize: 12
                color: input.text.length > maxWordNum ? "red" : "#95a5a6"
            }
        }
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

        RowLayout{
            // 输入框区域
            TextArea {
                id: input
                width: parent.width
                height: contentHeight + 16 // 自适应高度
                placeholderText: tipText || "请输入。。。"
                placeholderTextColor: "#95a5a6"
                wrapMode: Text.Wrap
                selectByMouse: true
                font.pixelSize: 14
                color: "#000000"
                readOnly: box.isReadOnly // 支持外部控制只读

                // 显式设置 padding
                leftPadding: 12
                rightPadding: 12
                topPadding: 8
                bottomPadding: 8

                onTextChanged: {
                    box.text = text
                    box.updateWordCount()
                }

                // 按键处理，防止超过最大字数
                Keys.onPressed: function(event){
                    // 如果当前字数已经达到或超过最大字数，并且按下的键不是删除、退格、方向键等控制键
                    // 则阻止输入
                    if (text.length >= maxWordNum &&
                            !(event.key === Qt.Key_Backspace ||
                              event.key === Qt.Key_Delete ||
                              event.key === Qt.Key_Left ||
                              event.key === Qt.Key_Right ||
                              event.key === Qt.Key_Up ||
                              event.key === Qt.Key_Down ||
                              event.key === Qt.Key_PageUp ||
                              event.key === Qt.Key_PageDown ||
                              event.key === Qt.Key_Home ||
                              event.key === Qt.Key_End ||
                              event.key === Qt.Key_Tab ||
                              event.key === Qt.Key_Enter ||
                              event.key === Qt.Key_Return ||
                              event.key === Qt.Key_Escape ||
                              event.modifiers & Qt.ControlModifier)) {
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
                visible: text!==""
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
