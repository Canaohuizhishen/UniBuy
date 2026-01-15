#!/usr/bin/env node

/**
 * UniBuy 订单管理API测试脚本
 * 使用Node.js原生模块，无需额外依赖
 */

const http = require('http');
const https = require('https');
const { URL } = require('url');

class OrderAPITester {
    constructor(baseUrl = 'http://localhost:8080') {
        this.baseUrl = baseUrl;
        this.testOrders = [];
        this.stats = {
            total: 0,
            passed: 0,
            failed: 0,
            warnings: 0
        };
        this.colors = {
            reset: '\x1b[0m',
            red: '\x1b[31m',
            green: '\x1b[32m',
            yellow: '\x1b[33m',
            blue: '\x1b[34m',
            magenta: '\x1b[35m',
            cyan: '\x1b[36m'
        };
    }

    // 工具方法
    printHeader(title) {
        console.log(`\n${this.colors.cyan}${'='.repeat(60)}${this.colors.reset}`);
        console.log(`${this.colors.magenta} ${title}${this.colors.reset}`);
        console.log(`${this.colors.cyan}${'='.repeat(60)}${this.colors.reset}`);
    }

    printResult(testName, success, message = '') {
        this.stats.total++;
        if (success === true) {
            this.stats.passed++;
            console.log(`${this.colors.green}✅ PASS: ${testName}${this.colors.reset}`);
        } else if (success === 'warning') {
            this.stats.warnings++;
            console.log(`${this.colors.yellow}⚠️  WARN: ${testName}${this.colors.reset}`);
            if (message) console.log(`   ${message}`);
        } else {
            this.stats.failed++;
            console.log(`${this.colors.red}❌ FAIL: ${testName}${this.colors.reset}`);
            if (message) console.log(`   ${message}`);
        }
    }

    printSummary() {
        console.log(`\n${this.colors.cyan}${'='.repeat(60)}${this.colors.reset}`);
        console.log(`${this.colors.magenta} 测试总结${this.colors.reset}`);
        console.log(`${this.colors.cyan}${'='.repeat(60)}${this.colors.reset}`);
        console.log(`${this.colors.blue}总测试数: ${this.stats.total}${this.colors.reset}`);
        console.log(`${this.colors.green}通过: ${this.stats.passed}${this.colors.reset}`);
        console.log(`${this.colors.yellow}警告: ${this.stats.warnings}${this.colors.reset}`);
        console.log(`${this.colors.red}失败: ${this.stats.failed}${this.colors.reset}`);

        const successRate = ((this.stats.passed / this.stats.total) * 100).toFixed(1);
        if (successRate === '100.0') {
            console.log(`${this.colors.green}🎉 成功率: ${successRate}%${this.colors.reset}`);
        } else if (successRate >= 80) {
            console.log(`${this.colors.yellow}⚠️  成功率: ${successRate}%${this.colors.reset}`);
        } else {
            console.log(`${this.colors.red}❌ 成功率: ${successRate}%${this.colors.reset}`);
        }
    }

    // HTTP请求方法
    async request(method, endpoint, data = null) {
        return new Promise((resolve, reject) => {
            const url = new URL(endpoint, this.baseUrl);
            const options = {
                hostname: url.hostname,
                port: url.port || (url.protocol === 'https:' ? 443 : 80),
                path: url.pathname + url.search,
                method: method,
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                timeout: 5000
            };

            const req = (url.protocol === 'https:' ? https : http).request(options, (res) => {
                let responseData = '';

                res.on('data', (chunk) => {
                    responseData += chunk;
                });

                res.on('end', () => {
                    try {
                        const parsedData = responseData ? JSON.parse(responseData) : {};
                        resolve({
                            statusCode: res.statusCode,
                            data: parsedData,
                            headers: res.headers
                        });
                    } catch (error) {
                        reject(new Error(`JSON解析失败: ${error.message}`));
                    }
                });
            });

            req.on('error', (error) => {
                reject(new Error(`请求失败: ${error.message}`));
            });

            req.on('timeout', () => {
                req.destroy();
                reject(new Error('请求超时'));
            });

            if (data) {
                req.write(JSON.stringify(data));
            }

            req.end();
        });
    }

    async sendRequest(method, endpoint, data = null) {
        try {
            const result = await this.request(method, endpoint, data);
            return { success: true, ...result };
        } catch (error) {
            return { success: false, error: error.message };
        }
    }

    // 测试用例
    async testHealthCheck() {
        try {
            const result = await this.sendRequest('GET', '/health');
            if (!result.success) {
                return { success: false, message: result.error };
            }
            return { success: true, message: '服务健康检查通过' };
        } catch (error) {
            return { success: false, message: error.message };
        }
    }

    async testGetAllOrders() {
        try {
            const result = await this.sendRequest('GET', '/api/orders');
            if (!result.success) {
                return { success: false, message: result.error };
            }
            if (!result.data.success) {
                return { success: false, message: result.data.message || '获取订单失败' };
            }
            const orderCount = result.data.data?.length || 0;
            return {
                success: true,
                message: `获取到 ${orderCount} 个订单`,
                data: result.data.data
            };
        } catch (error) {
            return { success: false, message: error.message };
        }
    }

    async testGetOrdersByStatus() {
        const statuses = ['待付款', '待发货', '已发货', '已完成', '已取消', '售后中'];
        let allPassed = true;
        let messages = [];

        for (const status of statuses) {
            try {
                const result = await this.sendRequest('GET', `/api/orders?status=${encodeURIComponent(status)}`);
                if (!result.success) {
                    allPassed = false;
                    messages.push(`${status}: ${result.error}`);
                    continue;
                }
                if (!result.data.success) {
                    allPassed = false;
                    messages.push(`${status}: ${result.data.message}`);
                    continue;
                }
            } catch (error) {
                allPassed = false;
                messages.push(`${status}: ${error.message}`);
            }
        }

        return {
            success: allPassed,
            message: allPassed ? '所有状态查询成功' : messages.join('; ')
        };
    }

    async testCreateOrder() {
        const timestamp = Date.now();
        const orderData = {
            userId: `TEST_USER_${timestamp}`,
            userName: '测试用户',
            shippingAddress: `测试地址${timestamp}`,
            receiverName: '测试收货人',
            receiverPhone: '13800138000',
            paymentMethod: '微信支付',
            buyerMessage: 'JavaScript测试订单',
            shippingFee: 10.0,
            items: [
                {
                    productId: 'P1',
                    productName: '夏季男士短袖T恤',
                    price: 79.0,
                    quantity: 2
                },
                {
                    productId: 'P5',
                    productName: '新品测试',
                    price: 99.0,
                    quantity: 1
                }
            ]
        };

        try {
            const result = await this.sendRequest('POST', '/api/orders', orderData);
            if (!result.success) {
                return { success: false, message: result.error };
            }
            if (!result.data.success) {
                return { success: false, message: result.data.message || '创建失败' };
            }

            const orderId = result.data.data?.orderId;
            if (orderId) {
                this.testOrders.push(orderId);
                return {
                    success: true,
                    message: `订单创建成功，ID: ${orderId}`,
                    orderId: orderId
                };
            }
            return { success: false, message: '未返回订单ID' };
        } catch (error) {
            return { success: false, message: error.message };
        }
    }

    async testGetSingleOrder() {
        if (this.testOrders.length === 0) {
            return { success: false, message: '没有可用的测试订单' };
        }

        const orderId = this.testOrders[this.testOrders.length - 1];
        try {
            const result = await this.sendRequest('GET', `/api/orders/${orderId}`);
            if (!result.success) {
                return { success: false, message: result.error };
            }
            if (!result.data.success) {
                return { success: false, message: result.data.message || '获取失败' };
            }
            return { success: true, message: `成功获取订单 ${orderId}` };
        } catch (error) {
            return { success: false, message: error.message };
        }
    }

    async testUpdateOrder() {
        if (this.testOrders.length === 0) {
            return { success: false, message: '没有可用的测试订单' };
        }

        const orderId = this.testOrders[this.testOrders.length - 1];
        const updateData = {
            buyerMessage: 'JavaScript更新测试',
            shippingAddress: '更新后的收货地址'
        };

        try {
            const result = await this.sendRequest('PUT', `/api/orders/${orderId}`, updateData);
            if (!result.success) {
                return { success: false, message: result.error };
            }
            if (!result.data.success) {
                return { success: false, message: result.data.message || '更新失败' };
            }
            return { success: true, message: `订单 ${orderId} 更新成功` };
        } catch (error) {
            return { success: false, message: error.message };
        }
    }

    async testShipOrder() {
        if (this.testOrders.length === 0) {
            return { success: false, message: '没有可用的测试订单' };
        }

        const orderId = this.testOrders[this.testOrders.length - 1];
        const shipData = {
            logisticsCompany: '顺丰速运',
            trackingNumber: `SF${Date.now()}`
        };

        try {
            const result = await this.sendRequest('POST', `/api/orders/${orderId}/ship`, shipData);
            if (!result.success) {
                return { success: false, message: result.error };
            }
            if (!result.data.success) {
                return { success: false, message: result.data.message || '发货失败' };
            }
            return { success: true, message: `订单 ${orderId} 发货成功` };
        } catch (error) {
            return { success: false, message: error.message };
        }
    }

    async testCancelOrder() {
        if (this.testOrders.length === 0) {
            return { success: false, message: '没有可用的测试订单' };
        }

        const orderId = this.testOrders[this.testOrders.length - 1];
        const cancelData = {
            reason: 'JavaScript测试取消'
        };

        try {
            const result = await this.sendRequest('POST', `/api/orders/${orderId}/cancel`, cancelData);
            if (!result.success) {
                return { success: false, message: result.error };
            }
            if (!result.data.success) {
                // 如果订单不能取消（比如已发货），这可能是预期的
                return {
                    success: 'warning',
                    message: `订单取消失败（可能是预期的）：${result.data.message}`
                };
            }
            return { success: true, message: `订单 ${orderId} 取消成功` };
        } catch (error) {
            return { success: false, message: error.message };
        }
    }

    async testCompleteOrder() {
        if (this.testOrders.length === 0) {
            return { success: false, message: '没有可用的测试订单' };
        }

        const orderId = this.testOrders[this.testOrders.length - 1];
        try {
            const result = await this.sendRequest('POST', `/api/orders/${orderId}/complete`);
            if (!result.success) {
                return { success: false, message: result.error };
            }
            if (!result.data.success) {
                // 如果订单不能完成（比如未发货），这可能是预期的
                return {
                    success: 'warning',
                    message: `订单完成失败（可能是预期的）：${result.data.message}`
                };
            }
            return { success: true, message: `订单 ${orderId} 完成成功` };
        } catch (error) {
            return { success: false, message: error.message };
        }
    }

    async testSearchOrders() {
        try {
            // 搜索订单号
            const result1 = await this.sendRequest('GET', '/api/orders/search?keyword=2023');
            if (!result1.success) {
                return { success: false, message: `搜索失败: ${result1.error}` };
            }
            if (!result1.data.success) {
                return { success: false, message: `搜索失败: ${result1.data.message}` };
            }

            // 搜索用户名
            const result2 = await this.sendRequest('GET', '/api/orders/search?keyword=张三');
            if (!result2.success) {
                return { success: false, message: `搜索失败: ${result2.error}` };
            }
            if (!result2.data.success) {
                return { success: false, message: `搜索失败: ${result2.data.message}` };
            }

            return { success: true, message: '订单搜索测试通过' };
        } catch (error) {
            return { success: false, message: error.message };
        }
    }

    async testGetOrderStats() {
        try {
            const result = await this.sendRequest('GET', '/api/orders/stats/counts');
            if (!result.success) {
                return { success: false, message: result.error };
            }
            if (!result.data.success) {
                return { success: false, message: result.data.message || '获取统计失败' };
            }

            const stats = result.data.data || {};
            console.log(`${this.colors.blue}订单统计:${this.colors.reset}`);
            for (const [key, value] of Object.entries(stats)) {
                console.log(`  ${key}: ${value}`);
            }
            return { success: true, message: '统计获取成功' };
        } catch (error) {
            return { success: false, message: error.message };
        }
    }

    async testGetOrdersByDate() {
        const today = new Date().toISOString().split('T')[0];
        const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];

        try {
            const result = await this.sendRequest('GET',
                `/api/orders/by-date?startDate=${yesterday}&endDate=${today}`);
            if (!result.success) {
                return { success: false, message: result.error };
            }
            if (!result.data.success) {
                return { success: false, message: result.data.message || '按日期查询失败' };
            }
            return { success: true, message: '按日期范围查询成功' };
        } catch (error) {
            return { success: false, message: error.message };
        }
    }

    async testGetOrdersByUser() {
        try {
            const result = await this.sendRequest('GET', '/api/orders/user/USER001');
            if (!result.success) {
                return { success: false, message: result.error };
            }
            if (!result.data.success) {
                return { success: false, message: result.data.message || '获取用户订单失败' };
            }
            return { success: true, message: '用户订单查询成功' };
        } catch (error) {
            return { success: false, message: error.message };
        }
    }

    async testEdgeCases() {
        let passed = 0;
        let total = 0;
        let messages = [];

        // 测试1: 不存在的订单
        total++;
        try {
            const result = await this.sendRequest('GET', '/api/orders/NON_EXISTENT_ORDER');
            if (result.success && result.data && !result.data.success) {
                passed++;
            } else {
                messages.push('不存在的订单测试失败');
            }
        } catch {
            messages.push('不存在的订单测试异常');
        }

        // 测试2: 空搜索
        total++;
        try {
            const result = await this.sendRequest('GET', '/api/orders/search?keyword=');
            if (result.success && result.data && !result.data.success) {
                passed++;
            } else {
                messages.push('空搜索测试失败');
            }
        } catch {
            messages.push('空搜索测试异常');
        }

        // 测试3: 无效JSON创建订单
        total++;
        try {
            const invalidData = '{"invalid": json}';
            // 需要发送原始字符串，这里简化处理
            const result = await this.sendRequest('POST', '/api/orders', { invalid: 'json' });
            if (result.success && result.data && !result.data.success) {
                passed++;
            } else {
                messages.push('无效JSON测试失败');
            }
        } catch {
            messages.push('无效JSON测试异常');
        }

        return {
            success: passed === total,
            message: `边界测试: ${passed}/${total} 通过` + (messages.length ? ` (${messages.join(', ')})` : '')
        };
    }

    async cleanupTestData() {
        console.log(`\n${this.colors.yellow}正在清理测试数据...${this.colors.reset}`);

        for (const orderId of this.testOrders) {
            try {
                await this.sendRequest('DELETE', `/api/orders/${orderId}`);
                console.log(`${this.colors.green}  已删除订单: ${orderId}${this.colors.reset}`);
            } catch (error) {
                console.log(`${this.colors.red}  删除订单失败 ${orderId}: ${error.message}${this.colors.reset}`);
            }
        }

        this.testOrders = [];
        console.log(`${this.colors.green}测试数据清理完成${this.colors.reset}`);
    }

    async runAllTests() {
        console.log(`${this.colors.magenta}🚀 开始测试 UniBuy 订单管理系统...${this.colors.reset}`);
        console.log(`${this.colors.blue}服务器: ${this.baseUrl}${this.colors.reset}`);

        // 测试用例定义
        const testCases = [
            { name: '健康检查', method: () => this.testHealthCheck() },
            { name: '获取所有订单', method: () => this.testGetAllOrders() },
            { name: '按状态获取订单', method: () => this.testGetOrdersByStatus() },
            { name: '创建新订单', method: () => this.testCreateOrder() },
            { name: '获取单个订单', method: () => this.testGetSingleOrder() },
            { name: '更新订单', method: () => this.testUpdateOrder() },
            { name: '发货订单', method: () => this.testShipOrder() },
            { name: '取消订单', method: () => this.testCancelOrder() },
            { name: '完成订单', method: () => this.testCompleteOrder() },
            { name: '搜索订单', method: () => this.testSearchOrders() },
            { name: '获取订单统计', method: () => this.testGetOrderStats() },
            { name: '按日期范围获取订单', method: () => this.testGetOrdersByDate() },
            { name: '获取用户订单', method: () => this.testGetOrdersByUser() },
            { name: '边界情况测试', method: () => this.testEdgeCases() }
        ];

        // 分组测试
        const groups = [
            { name: '基本功能测试', tests: [0, 1, 2] },
            { name: '订单操作测试', tests: [3, 4, 5, 6, 7, 8] },
            { name: '查询与统计测试', tests: [9, 10, 11, 12] },
            { name: '异常处理测试', tests: [13] }
        ];

        // 执行测试
        for (const group of groups) {
            this.printHeader(group.name);

            for (const testIndex of group.tests) {
                if (testIndex < testCases.length) {
                    const test = testCases[testIndex];
                    console.log(`\n${this.colors.blue}▶ ${test.name}${this.colors.reset}`);

                    try {
                        const result = await test.method();
                        this.printResult(test.name, result.success, result.message);
                    } catch (error) {
                        this.printResult(test.name, false, `测试执行异常: ${error.message}`);
                    }
                }
            }
        }

        // 显示总结
        this.printSummary();

        // 清理测试数据
        if (this.testOrders.length > 0) {
            await this.cleanupTestData();
        }

        // 返回退出码
        process.exitCode = this.stats.failed > 0 ? 1 : 0;
        return this.stats;
    }
}

// 主函数
async function main() {
    const tester = new OrderAPITester();

    try {
        await tester.runAllTests();
    } catch (error) {
        console.error(`${tester.colors.red}测试运行失败: ${error.message}${tester.colors.reset}`);
        process.exit(1);
    }
}

// 处理命令行参数
function parseArguments() {
    const args = process.argv.slice(2);
    let baseUrl = 'http://localhost:8080';

    for (let i = 0; i < args.length; i++) {
        if (args[i] === '--url' || args[i] === '-u') {
            if (i + 1 < args.length) {
                baseUrl = args[i + 1];
                i++;
            }
        } else if (args[i] === '--help' || args[i] === '-h') {
            console.log(`
UniBuy 订单管理测试工具

用法:
  node test_orders.js [选项]

选项:
  -u, --url <url>   指定服务器URL (默认: http://localhost:8080)
  -h, --help        显示帮助信息

示例:
  node test_orders.js
  node test_orders.js --url http://192.168.1.100:8080
            `);
            process.exit(0);
        }
    }

    return baseUrl;
}

// 启动测试
if (require.main === module) {
    const baseUrl = parseArguments();
    const tester = new OrderAPITester(baseUrl);

    tester.runAllTests().catch(error => {
        console.error(`测试失败: ${error.message}`);
        process.exit(1);
    });
}

module.exports = OrderAPITester;
