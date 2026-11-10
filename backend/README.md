# 宇坤商城后端（mall-backend）

Flutter 客户端（`../app-flutter`）配套的 Kotlin + Spring Boot 服务，当前提供商品列表、详情、搜索、上架四个接口。数据存 PostgreSQL，表结构由 Flyway 迁移脚本管理。

## 技术栈

| 项 | 版本 / 说明 |
| --- | --- |
| Kotlin | 2.3.21 |
| Spring Boot | 4.1.2（Spring Framework 7、Jackson 3） |
| JDK | 25（Gradle toolchain） |
| Gradle | 9.3.1（自带 wrapper） |
| 数据库 | PostgreSQL 18（库名 `yukunyuan_mall`） |
| 迁移 | Flyway 12.4.0 + `flyway-database-postgresql` |
| ORM | Spring Data JPA / Hibernate 7（`ddl-auto: validate`） |

## 前置条件

本机（或 Docker）已启动 PostgreSQL，并已创建数据库：

```sql
create database yukunyuan_mall;
```

默认连接信息在 `src/main/resources/application.yml`：

```yaml
url:      jdbc:postgresql://localhost:5432/yukunyuan_mall
username: postgres
password: s554517318
```

部署或其他环境用环境变量覆盖即可，不用改代码：

```powershell
$env:DB_URL = 'jdbc:postgresql://192.168.1.10:5432/yukunyuan_mall'
$env:DB_USERNAME = 'postgres'
$env:DB_PASSWORD = '你的密码'
```

## 快速开始

```powershell
cd backend
.\gradlew.bat bootRun          # 启动，默认 http://localhost:8080
.\gradlew.bat test             # 跑接口测试（H2 内存库，不需要 PostgreSQL）
.\gradlew.bat build            # 打包 build/libs/mall-backend-0.1.0-SNAPSHOT.jar
```

首次启动时 Flyway 会自动建表，随后写入 12 条演示商品（与 Flutter 端 `kMockProducts` 一致）；已有数据不会重复写。不想写演示数据就设置 `app.seed.enabled=false`。

- 健康检查：<http://localhost:8080/api/health>
- 数据库检查（本机有 psql 时）：

```powershell
psql -h localhost -U postgres -d yukunyuan_mall -c "\dt"
psql -h localhost -U postgres -d yukunyuan_mall -c "select id, title, price_cents, category from products order by id;"
psql -h localhost -U postgres -d yukunyuan_mall -c "select version, description, success from flyway_schema_history;"
```

如果 PostgreSQL 跑在 Docker 里、宿主机没装 psql，用容器内的 psql：

```powershell
docker exec -it <postgres容器名> psql -U postgres -d yukunyuan_mall -c "\dt"
```

## 数据库与 Flyway

- 迁移脚本目录：`src/main/resources/db/migration`
- 命名规范：`V{版本}__{说明}.sql`，例如 `V2__add_product_image_url.sql`
- 已执行记录表：`flyway_schema_history`（Flyway 自动创建，不要手工改）
- JPA 配置为 `ddl-auto: validate`：实体与表不一致时启动直接报错，避免线上被 Hibernate 悄悄改表

当前 `V1__create_products_table.sql` 建的商品表：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `id` | `varchar(36)` PK | 种子数据 `p1..p12`，上架商品 UUID |
| `title` | `varchar(30)` not null | 商品名称 |
| `description` | `varchar(200)` not null | 商品描述 |
| `price_cents` | `bigint` not null | 价格，单位「分」，0 表示面议；`>= 0` |
| `category` | `varchar(16)` not null | 枚举名 `FOOD/HOME/DIGITAL/CLOTHING/HANDMADE/OTHER` |
| `seller_name` | `varchar(30)` not null | 店铺名称 |
| `stock` | `integer` not null default 0 | 库存，0 表示售罄；`>= 0` |
| `created_at` | `timestamptz` not null | 创建时间（UTC） |
| `updated_at` | `timestamptz` not null | 更新时间（UTC） |

索引：`idx_products_category`、`idx_products_created_at`。

新增字段的流程：写 `V2__xxx.sql` → 同步修改实体 → 重启应用（Flyway 自动执行，Hibernate `validate` 校验）。**已经执行过的迁移文件不要改**，否则 Flyway 校验会失败；本地想重来就 `drop database yukunyuan_mall; create database yukunyuan_mall;` 后重启。

测试使用 `src/test/resources/application.yml` 里的 H2 内存库，并关闭 Flyway，所以 `gradlew test` 不需要本机 PostgreSQL，也不会碰开发库。

## 接口

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/api/health` | 连通性探测 |
| GET | `/api/products` | 商品列表，支持 `category`、`q` 两个查询参数 |
| GET | `/api/products/{id}` | 商品详情，不存在返回 404 |
| POST | `/api/products` | 上架商品，成功返回 201 |

### 查询参数

- `category`：中文分类名，取值 `食品 / 家居 / 数码 / 服饰 / 手作 / 其他`；传 `全部` 或留空表示不筛选。
- `q`：关键词，在标题、描述、店铺名里模糊匹配。

```powershell
curl.exe "http://localhost:8080/api/products?category=食品"
curl.exe "http://localhost:8080/api/products?q=相机"
```

### 返回字段

与 Flutter `lib/models/product.dart` 的 `Product.fromJson` 完全对齐：

```json
{
  "id": "p1",
  "title": "手工皂礼盒（三块装）",
  "description": "冷制皂，橄榄油打底……",
  "priceCents": 6800,
  "category": "手作",
  "sellerName": "阿梅的小铺",
  "stock": 12
}
```

金额一律用 `priceCents`（单位：分）传 `Long`，0 表示「面议」，不要在前后端之间传浮点元。

### 上架请求

```json
{
  "title": "手工皂礼盒（三块装）",
  "priceCents": 6800,
  "category": "手作",
  "description": "冷制皂，橄榄油打底……",
  "sellerName": "阿梅的小铺",
  "stock": 12
}
```

校验规则：标题 2–30 字；价格 ≥ 0 且不超过 1,000,000 元；分类必须是上面 6 个之一；描述 ≤ 200 字；库存 ≥ 0，不传默认 1。校验失败返回 400，结构如下：

```json
{
  "code": "VALIDATION_FAILED",
  "message": "商品名称不能为空",
  "fieldErrors": { "title": "商品名称不能为空" }
}
```

## 目录结构

```
src/main/kotlin/com/yukunyuan/mall/
  MallBackendApplication.kt        启动类
  common/                          统一错误结构 + 全局异常处理
  config/WebConfig.kt              CORS（开发期放开所有来源）
  health/HealthController.kt       GET /api/health
  product/
    Product.kt                     JPA 实体
    ProductCategory.kt             分类枚举（中文 label 与前端一致）
    ProductRepository.kt           查询（分类 + 关键词）
    ProductDtos.kt                 请求/响应 DTO
    ProductService.kt              业务逻辑
    ProductController.kt           REST 接口
    ProductSeeder.kt               演示数据
src/main/resources/
  application.yml                  端口、PostgreSQL、JPA、Flyway、种子开关
  db/migration/V1__create_products_table.sql   建表迁移
src/test/kotlin/.../ProductApiTest.kt          接口测试
```

## 接 Flutter

把 `app-flutter/lib/data/` 下的假数据换成 HTTP 调用即可：

- Web / Windows 调试：`http://localhost:8080/api`
- Android 模拟器：`http://10.0.2.2:8080/api`
- 真机：`http://<电脑局域网 IP>:8080/api`（防火墙需放行 8080）

Flutter 的 `Product.fromJson` 用 `json['id'] as String`，所以后端主键是 UUID 字符串；价格按「分」解析成 `int`。

## 下一步

1. 账号体系：注册、登录、JWT，「是否开过店」决定能否购买（会员制核心规则）。
2. 上架接口接当前登录用户，不再由前端传 `sellerName`。
3. 订单与支付：地址、下单、库存扣减，先做线下转账/余额。
4. 图片上传：对象存储 + 压缩，商品增加 `imageUrl` 字段（记得配 `V2` 迁移）。
5. 分页：商品变多后把列表改成 `page/size` 并封装分页响应（当前 12 条一次性返回）。

## 说明

- 演示环境用本机 PostgreSQL + 默认密码；上线请改用环境变量注入密码，并只给应用最小权限（不要用 `postgres` 超级用户）。
- 当前搜索是 `lower(...) like '%关键词%'`，数据量大后可加 `pg_trgm` 扩展和 GIN 索引。
- CORS `allowedOriginPatterns("*")` 只适合开发期，上线改成固定域名。
- 已移除 H2 控制台；看数据用 psql / DataGrip / pgAdmin 即可。
