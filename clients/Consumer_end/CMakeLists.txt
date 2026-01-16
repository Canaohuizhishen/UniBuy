cmake_minimum_required(VERSION 4.1.1)

#https://github.com/Kitware/CMake/blob/v4.1.1/Help/dev/experimental.rst

# set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
# set(CMAKE_CXX_MODULE_STD ON)

project(Consumer_end VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

set(QT_FORCE_CMP0156_TO_VALUE NEW)

qt_add_executable(appConsumer_end)

qt_add_qml_module(appConsumer_end
    URI Consumer_end
    VERSION 1.0
    SOURCES     main.cpp
    QML_FILES   Main.qml
    QML_FILES components/NetworkManager.qml
    QML_FILES components/OrderItem.qml
    QML_FILES page/OrderTrackPage.qml
    QML_FILES components/OrderDetailDialog.qml
    QML_FILES components/LogisticsDialog.qml
    QML_FILES components/ConfirmDialog.qml components/EmptyState.qml components/ProductCard.qml components/ShoppingCartItem.qml
    QML_FILES page/BrowseProductsPage.qml page/CheckoutPage.qml page/ProductDetailPage.qml page/ShoppingCartPage.qml
    QML_FILES page/OrderTrackPage.qml
    QML_FILES components/LogisticsDialog.qml components/NetworkManager.qml components/OrderDetailDialog.qml components/OrderItem.qml
    QML_FILES page/PaymentPage.qml
)

target_sources(appConsumer_end
    PRIVATE
        #math.cpp                   # 实现单元
    PRIVATE FILE_SET cxx_modules TYPE CXX_MODULES  FILES
        #math.cppm                  # 接口单元
)

source_group("QML Files" FILES
    Main.qml
)

target_compile_features(appConsumer_end PRIVATE cxx_std_23)

target_link_libraries(appConsumer_end
    PRIVATE
        Qt6::Quick
)

set_target_properties(appConsumer_end PROPERTIES
    AUTORCC TRUE                              #  set(CMAKE_AUTORCC ON)
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appConsumer_end
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)
install(TARGETS appConsumer_end
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
