// 通用状态标签
import QtQuick 2.15

Rectangle {
    id: root
    property string status: ""
    property string statusText: status

    width: Math.max(60, statusText.length * 10 + 20)
    height: 24
    radius: height / 2  // 圆形标签

    color: {
        switch(status) {
        case "待付款": case "已下架": case "待审核": return "#95a5a6"
        case "待发货": return "#e74c3c"
        case "待收货": return "#f39c12"
        case "已完成": case "出售中": return "#2ecc71"
        case "已取消": return "#7f8c8d"
        case "已售罄": return "#e74c3c"
        default: return "#3498db"
        }
    }

    Text {
        text: statusText
        color: "white"
        font.pixelSize: 10
        font.bold: true
        anchors.centerIn: parent
    }
}
