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
    test_orders.js


)

target_sources(Server_end
    PRIVATE
        #math.cpp                   # 实现单元
    PRIVATE FILE_SET cxx_modules TYPE CXX_MODULES  FILES
        #math.cppm                  # 接口单元
)

target_compile_features(Server_end PRIVATE cxx_std_23)






































# include(GNUInstallDirs)
# install(TARGETS Server_end
#     LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
#     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
# )



# set(CMAKE_CXX_STANDARD_REQUIRED ON) #强制使用指定的C++标准（如 CMAKE_CXX_STANDARD 设置的版本），而不允许回退到较旧的标准。
# set(CMAKE_CXX_STANDARD 23)           # 希望使用 C++23
# set(CMAKE_CXX_EXTENSIONS OFF) #避免编译器启用如g++的GNU扩展（如 -std=gnu++23），确保使用的是标准C++23（-std=c++23）。

# target_sources( Server_end
#     PRIVATE
#         main.cpp
#
#     PUBLIC
#
# )

#target_compile_options( Server_end PRIVATE -fmodules-ts )

#target_include_directories( Server_end PRIVATE /usr/include )

#target_link_directories( Server_end PRIVATE /usr/lib )

#target_link_libraries( Server_end PRIVATE m )

#set_target_properties( Server_end PROPERTIES
            #CXX_STANDARD 20
            #CXX_EXTENSIONS OFF
            #etc..
            #)
# 设置指定的C++编译器版本是必须的，如果不设置，或者为OFF，则指定版本不可用时，会使用上一版本。
#set_target_properties(Server_end PROPERTIES  CXX_STANDARD_REQUIRED on)

## --------------------------------------------------------------------------
## Adding build-requirements
## 源文件列表
#target_sources( <target> PRIVATE <source-file>... )
#
#target_precompile_headers( <target> PRIVATE <header-file>... )
#
## 预处理头文件搜索路径列表，等价参数：-I
#target_include_directories( <target> PRIVATE <include-search-dir>... )
#
## 预编译宏 自动在指定的宏前添加，等价参数：-D
#target_compile_definitions( <target> PRIVATE <macro-definitions>... )
#
## 编译选项和特性
#target_compile_options( <target> PRIVATE <compiler-option>... )
#target_compile_features( <target> PRIVATE <feature>... )
#
## 链接库
#target_link_libraries( <target> PRIVATE <dependency>... )
#
## 链接选项
#target_link_options( <target> PRIVATE <linker-option>... )
#
## 链接库搜索路径，等价参数：-L
#target_link_directories( <target> PRIVATE <linker-search-dir>... )

#execute_process(COMMAND ln -s /opt/gcc/gcm.cache  ./)

## Modern Cmake建议围绕Target和Property进行项目配置，竭力避免出现下面变量variable的set定义。
## Variable横行是典型CMake2.8时期的风格, Modern CMake则遵循了OO方法。其中，target表示待构建的对象，
## target相关的语句用于定义来约束link、compile等相关属性的scope。
#set(CMAKE_CXX_STANDARD 20)
#set(CMAKE_CXX_STANDARD_REQUIRED ON)


###完整的project命令
#project( Server_end LANGUAGES CXX )
         # DESCRIPTION "Description of project" HOMEPAGE_URL "http://www.abc.com" VERSION 0.1.0 )
#execute_process(COMMAND g++ -std=c++20 -xc++-system-header -fmodules-ts # 如何要使用modules,该命令应该放在project命令之后
#                iostream
#                string )
