cmake_minimum_required(VERSION 4.1.1)

#https://github.com/Kitware/CMake/blob/v4.1.1/Help/dev/experimental.rst

# set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
# set(CMAKE_CXX_MODULE_STD ON)

project(Server_end LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(Server_end
    main.cpp
    entities/product.h entities/product.cpp
    network/httplib.h
    nlohmann/json.hpp
    broker/productbroker.h broker/productbroker.cpp
    controllers/manageproductscontroller.h controllers/manageproductscontroller.cpp
    network/httpserver.h network/httpserver.cpp
    entities/order.h entities/order.cpp
    broker/orderbroker.h broker/orderbroker.cpp
    controllers/manageordercontroller.h controllers/manageordercontroller.cpp




    controllers/ordercontroller.h controllers/ordercontroller.cpp
    controllers/shoppingcontroller.h controllers/shoppingcontroller.cpp



)

target_sources(Server_end
    PRIVATE
        #math.cpp                   # 实现单元
    PRIVATE FILE_SET cxx_modules TYPE CXX_MODULES  FILES
        #math.cppm                  # 接口单元
)

target_compile_features(Server_end PRIVATE cxx_std_23)

