//主窗口
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import"../components"

Item {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    anchors.fill: parent

    property var currentPage: homePage

    HomePage{
        id: homePage
        visible: true
        productManagementButton.onClicked: {
            homePage.visible = false
            productManagementPage.visible = true
            currentPage = productManagementPage
        }
        orderManagementButton.onClicked: {}
    }

    ProductManagementPage{
        id: productManagementPage
        visible: false

        backButton.onClicked: {
            productManagementPage.visible = false
            homePage.visible = true
            currentPage = homePage
        }
    }
}
