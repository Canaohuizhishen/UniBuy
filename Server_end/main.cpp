#include <iostream>
#include <string>
#include "./controllers/manageproductscontroller.h"
#include "./broker/productbroker.h"
#include "./entities/product.h"
#include "./network/httpserver.h"

void initializeTestData() {
    std::cout << "📦 正在添加初始测试商品..." << std::endl;

    try {
        // 测试商品1：夏季男士短袖T恤
        Product product1("夏季男士短袖T恤", "服饰", 79.00, 125);
        product1.setDescription("纯棉材质，舒适透气，夏季必备");
        product1.setStatus("出售中");
        product1.setSales(342);
        product1.setOriginalPrice(99.00);
        ProductBroker::addProduct(product1);
        std::cout << "  ✅ 已添加: " << product1.getName() << std::endl;

        // 测试商品2：无线蓝牙耳机
        Product product2("无线蓝牙耳机", "数码", 199.00, 56);
        product2.setOriginalPrice(299.00);
        product2.setDescription("高清音质，蓝牙5.0，续航24小时");
        product2.setStatus("已下架");
        product2.setSales(89);
        ProductBroker::addProduct(product2);
        std::cout << "  ✅ 已添加: " << product2.getName() << std::endl;

        // 测试商品3：笔记本电脑
        Product product3("笔记本电脑", "数码", 5999.00, 8);
        product3.setDescription("高性能游戏本，RTX 4060显卡");
        product3.setStatus("出售中");
        product3.setSales(15);
        product3.setOriginalPrice(6999.00);
        ProductBroker::addProduct(product3);
        std::cout << "  ✅ 已添加: " << product3.getName() << std::endl;

        // 测试商品4：运动鞋
        Product product4("运动鞋", "服饰", 299.00, 0);
        product4.setDescription("专业跑步鞋，缓震设计");
        product4.setStatus("已售罄");
        product4.setSales(210);
        ProductBroker::addProduct(product4);
        std::cout << "  ✅ 已添加: " << product4.getName() << std::endl;

        // 测试商品5：待审核商品
        Product product5("新品测试", "测试", 99.00, 50);
        product5.setDescription("新品上市，待审核");
        product5.setStatus("待审核");
        ProductBroker::addProduct(product5);
        std::cout << "  ✅ 已添加: " << product5.getName() << std::endl;

        std::cout << "🎉 测试商品添加成功。总计: "
                  << ProductBroker::getAllProducts().size() << " 个商品" << std::endl;

    } catch (const std::exception& e) {
        std::cerr << "❌ 添加测试商品时出错: " << e.what() << std::endl;
    }
}

int main() {
    std::cout << "=========================================" << std::endl;
    std::cout << "        UniBuy 服务器 v1.0.0           " << std::endl;
    std::cout << "=========================================" << std::endl;

    // 初始化测试数据
    initializeTestData();

    // 创建并启动服务器
    HTTPServer server(8080);

    try {
        server.start();
    } catch (const std::exception& e) {
        std::cerr << "❌ 服务器启动失败: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
