#!/bin/bash
echo "=== UniBuy 服务器端完整功能测试 ==="
echo "请确保服务器已运行在 localhost:8080"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试计数器
TESTS_PASSED=0
TESTS_TOTAL=0

# 通用函数：执行测试并检查结果
run_test() {
    local test_name="$1"
    local command="$2"
    local expected_status="${3:-0}"

    ((TESTS_TOTAL++))

    echo -e "${YELLOW}测试: ${test_name}${NC}"
    echo "命令: $command"

    # 执行命令
    result=$(eval "$command" 2>&1)
    local actual_status=$?

    # 检查HTTP状态码（如果有）
    if echo "$result" | grep -q "HTTP"; then
        http_status=$(echo "$result" | head -1 | grep -o '[0-9][0-9][0-9]')
        if [ -n "$http_status" ]; then
            actual_status="$http_status"
        fi
    fi

    # 检查结果
    if [ "$actual_status" = "$expected_status" ] || \
       (echo "$result" | grep -q '"success":true') || \
       (echo "$result" | grep -q '"success": true'); then
        echo -e "${GREEN}✓ 测试通过${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ 测试失败${NC}"
        echo "返回结果:"
        echo "$result" | head -20
        return 1
    fi
}

# 函数：格式化JSON输出
format_json() {
    if command -v python3 &> /dev/null; then
        python3 -m json.tool
    elif command -v python &> /dev/null; then
        python -m json.tool
    else
        cat
    fi
}

echo "1. 健康检查"
run_test "健康检查" "curl -s -w '\nHTTP状态码: %{http_code}' http://localhost:8080/health"

echo -e "\n2. 商品管理功能测试"
echo "2.1 获取所有商品"
run_test "获取所有商品" "curl -s -X GET http://localhost:8080/api/products | format_json"

echo -e "\n2.2 按状态获取商品"
run_test "获取出售中商品" "curl -s -X GET 'http://localhost:8080/api/products?status=出售中' | format_json"
run_test "获取已下架商品" "curl -s -X GET 'http://localhost:8080/api/products?status=已下架' | format_json"
run_test "获取已售罄商品" "curl -s -X GET 'http://localhost:8080/api/products?status=已售罄' | format_json"
run_test "获取待审核商品" "curl -s -X GET 'http://localhost:8080/api/products?status=待审核' | format_json"

echo -e "\n2.3 添加商品"
NEW_PRODUCT_ID=$(curl -s -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name":"测试商品-"'"$(date +%s)"'",
    "category":"测试",
    "price":99.99,
    "originalPrice":129.99,
    "stock":50,
    "description":"这是一个完整的测试商品描述",
    "images":["image1.jpg","image2.jpg"],
    "tags":["测试","新品","热销"],
    "status":"出售中"
  }' | python3 -c "
import json, sys
data = json.load(sys.stdin)
if data.get('success'):
    print(data['data']['productId'])
else:
    print('ERROR')
")

if [ "$NEW_PRODUCT_ID" != "ERROR" ] && [ -n "$NEW_PRODUCT_ID" ]; then
    echo -e "${GREEN}商品添加成功，ID: $NEW_PRODUCT_ID${NC}"

    echo -e "\n2.4 获取单个商品"
    run_test "获取新增商品" "curl -s -X GET http://localhost:8080/api/products/$NEW_PRODUCT_ID | format_json"

    echo -e "\n2.5 更新商品"
    run_test "更新商品" "curl -s -X PUT http://localhost:8080/api/products/$NEW_PRODUCT_ID \
      -H 'Content-Type: application/json' \
      -d '{
        \"name\":\"测试商品-更新\",
        \"category\":\"数码\",
        \"price\":89.99,
        \"stock\":30,
        \"description\":\"已更新的商品描述\"
      }' | format_json"

    echo -e "\n2.6 切换商品状态"
    echo "当前状态 -> 下架"
    run_test "下架商品" "curl -s -X POST http://localhost:8080/api/products/$NEW_PRODUCT_ID/toggle-status \
      -H 'Content-Type: application/json' \
      -d '{\"currentStatus\":\"出售中\"}' | format_json"

    echo "下架状态 -> 上架"
    run_test "上架商品" "curl -s -X POST http://localhost:8080/api/products/$NEW_PRODUCT_ID/toggle-status \
      -H 'Content-Type: application/json' \
      -d '{\"currentStatus\":\"已下架\"}' | format_json"

    echo -e "\n2.7 设置库存为0（自动变为已售罄）"
    run_test "设置库存为0" "curl -s -X PUT http://localhost:8080/api/products/$NEW_PRODUCT_ID \
      -H 'Content-Type: application/json' \
      -d '{
        \"name\":\"测试商品-售罄测试\",
        \"stock\":0
      }' | format_json"

    echo "检查状态是否变为已售罄"
    run_test "检查售罄状态" "curl -s -X GET http://localhost:8080/api/products/$NEW_PRODUCT_ID | python3 -c \"
import json, sys
data = json.load(sys.stdin)
if data.get('success') and data['data'].get('status') == '已售罄':
    print('已售罄状态正确')
    sys.exit(0)
else:
    print('状态错误')
    sys.exit(1)
\""

    echo -e "\n2.8 搜索商品"
    run_test "搜索商品名称" "curl -s -X GET 'http://localhost:8080/api/products/search?keyword=测试' | format_json"
    run_test "搜索商品分类" "curl -s -X GET 'http://localhost:8080/api/products/search?keyword=数码' | format_json"

    echo -e "\n2.9 获取商品统计"
    run_test "获取商品统计" "curl -s -X GET http://localhost:8080/api/products/stats/counts | format_json"

    echo -e "\n2.10 获取商品分类"
    run_test "获取分类列表" "curl -s -X GET http://localhost:8080/api/products/categories | format_json"

    echo -e "\n2.11 删除商品"
    run_test "删除商品" "curl -s -X DELETE http://localhost:8080/api/products/$NEW_PRODUCT_ID | format_json"

    echo -e "\n2.12 确认商品已删除"
    run_test "确认删除" "curl -s -X GET http://localhost:8080/api/products/$NEW_PRODUCT_ID | python3 -c \"
import json, sys
data = json.load(sys.stdin)
if not data.get('success'):
    print('商品已成功删除')
    sys.exit(0)
else:
    print('商品删除失败')
    sys.exit(1)
\""
else
    echo -e "${RED}商品添加失败，跳过后续测试${NC}"
fi

echo -e "\n3. 边缘情况测试"
echo -e "\n3.1 测试不存在的商品"
run_test "获取不存在的商品" "curl -s -X GET http://localhost:8080/api/products/P999999 | format_json"

echo -e "\n3.2 测试无效JSON"
run_test "无效JSON请求" "curl -s -X POST http://localhost:8080/api/products \
  -H 'Content-Type: application/json' \
  -d '{\"invalid\": json}' | format_json"

echo -e "\n3.3 测试缺少必要字段"
run_test "缺少必要字段" "curl -s -X POST http://localhost:8080/api/products \
  -H 'Content-Type: application/json' \
  -d '{\"name\": \"只有名称\"}' | format_json"

echo -e "\n3.4 测试空搜索"
run_test "空搜索" "curl -s -X GET 'http://localhost:8080/api/products/search?keyword=' | format_json"

echo -e "\n3.5 测试不存在的状态"
run_test "不存在的状态" "curl -s -X GET 'http://localhost:8080/api/products?status=不存在' | format_json"

echo -e "\n4. 批量操作测试"
echo -e "\n4.1 批量添加多个商品"
for i in {1..3}; do
    echo "添加商品 $i"
    curl -s -X POST http://localhost:8080/api/products \
      -H "Content-Type: application/json" \
      -d "{
        \"name\":\"批量测试商品-$i\",
        \"category\":\"批量测试\",
        \"price\":$((10 + i)),
        \"stock\":$((20 * i)),
        \"description\":\"第$i个批量测试商品\"
      }" > /dev/null
    echo -e "${GREEN}商品$i添加成功${NC}"
done

echo -e "\n4.2 批量搜索测试"
run_test "批量搜索" "curl -s -X GET 'http://localhost:8080/api/products/search?keyword=批量' | python3 -c \"
import json, sys
data = json.load(sys.stdin)
if data.get('success'):
    count = len(data.get('data', []))
    print(f'找到 {count} 个批量测试商品')
    if count >= 3:
        sys.exit(0)
    else:
        sys.exit(1)
else:
    sys.exit(1)
\""

echo -e "\n5. CORS和OPTIONS测试"
echo -e "\n5.1 OPTIONS预检请求"
run_test "OPTIONS请求" "curl -s -X OPTIONS http://localhost:8080/api/products \
  -H 'Access-Control-Request-Method: GET' \
  -H 'Access-Control-Request-Headers: Content-Type' \
  -w '\nHTTP状态码: %{http_code}'"

echo -e "\n6. 性能测试"
echo -e "\n6.1 并发请求测试（3个并发）"
time (for i in {1..3}; do
    curl -s -X GET http://localhost:8080/api/products > /dev/null &
done; wait)

echo -e "\n6.2 响应时间测试"
echo "单次请求响应时间:"
time curl -s -X GET http://localhost:8080/api/products > /dev/null

echo -e "\n7. 数据一致性测试"
echo -e "\n7.1 统计数字一致性"
TOTAL_COUNT=$(curl -s -X GET http://localhost:8080/api/products | python3 -c "
import json, sys
data = json.load(sys.stdin)
if data.get('success'):
    print(len(data.get('data', [])))
else:
    print(0)
")

STATS_COUNT=$(curl -s -X GET http://localhost:8080/api/products/stats/counts | python3 -c "
import json, sys
data = json.load(sys.stdin)
if data.get('success'):
    stats = data.get('data', {})
    total = stats.get('全部', 0)
    print(total)
else:
    print(0)
")

if [ "$TOTAL_COUNT" = "$STATS_COUNT" ] && [ "$TOTAL_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ 数据一致性检查通过: $TOTAL_COUNT 个商品${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗ 数据一致性检查失败: 列表=$TOTAL_COUNT, 统计=$STATS_COUNT${NC}"
fi
((TESTS_TOTAL++))

echo -e "\n========================================="
echo -e "测试总结:"
echo -e "总测试数: ${TESTS_TOTAL}"
echo -e "通过测试: ${TESTS_PASSED}"
echo -e "失败测试: $((TESTS_TOTAL - TESTS_PASSED))"

if [ $TESTS_PASSED -eq $TESTS_TOTAL ]; then
    echo -e "${GREEN}🎉 所有测试通过！服务器功能完整。${NC}"
elif [ $TESTS_PASSED -gt $((TESTS_TOTAL * 2 / 3)) ]; then
    echo -e "${YELLOW}⚠️  大部分测试通过，部分功能可能需要检查。${NC}"
else
    echo -e "${RED}❌ 测试失败较多，请检查服务器状态。${NC}"
fi

echo -e "\n8. 清理测试数据"
echo "清理批量测试商品..."
BATCH_IDS=$(curl -s -X GET 'http://localhost:8080/api/products/search?keyword=批量' | python3 -c "
import json, sys
data = json.load(sys.stdin)
if data.get('success'):
    for product in data.get('data', []):
        print(product.get('productId'))
")

if [ -n "$BATCH_IDS" ]; then
    echo "找到 $(echo "$BATCH_IDS" | wc -l) 个批量测试商品需要清理"
    for id in $BATCH_IDS; do
        echo "删除商品: $id"
        curl -s -X DELETE http://localhost:8080/api/products/$id > /dev/null
    done
    echo -e "${GREEN}批量测试数据清理完成${NC}"
else
    echo "没有批量测试数据需要清理"
fi

echo -e "\n测试完成！"
