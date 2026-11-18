# External test deploy (temporary test setup)

本目录是面向外网临时测试的最小部署配置（2 核 2G、MySQL、访问量小）。

- **访问地址（强制用 IP，不用未备案域名）**：`http://159.75.3.202`
- 对外端口：仅 HTTP `80`（Caddy 反代到 new-api:3000）
- 无 Redis：`MEMORY_CACHE_ENABLED=true`（省内存）
- 合规：勿改仓库根目录的 `LICENSE` / `NOTICE` / `THIRD-PARTY-LICENSES.md`；界面署名保持原样

## 1. 网络放行

安全组 / 防火墙放行入站 **80**（以及你自己用的 SSH，例如 61122）。  
不要依赖未备案域名访问（会被运营商拦截）。

## 2. 准备环境变量

在本目录执行：

```bash
cd deploy/test-external
cp .env.example .env
```

准备两份密钥文件（**拆分存放**）：

```bash
cp .env.example .env
cp secrets/mysql_root.env.example secrets/mysql_root.env
chmod 600 .env secrets/mysql_root.env
```

1. `.env`：只放应用侧 MySQL 普通用户  
   - `MYSQL_USER=newapi`  
   - `MYSQL_PASSWORD=` 应用库强密码  
2. `secrets/mysql_root.env`：只放 root  
   - `MYSQL_ROOT_PASSWORD=`（`openssl rand -base64 32`）  
   - **不要**把 root 密码写进 `.env`，**不要**把该文件挂给 `new-api` 容器  
3. 会话密钥与 Cookie：已在 `docker-compose.yml` 固定  
   - `SESSION_COOKIE_SECURE=false`（HTTP `80`；若为 true，refresh cookie 不发送，约 15 分钟掉登录）  
   - `SESSION_SECRET` / `CRYPTO_SECRET` 为两个独立固定长串（勿跨环境复用）  
   - 未设置 `SESSION_COOKIE_TRUSTED_URL`（Secure=false 时不应配置）

### Root 密码安全方案（temporary test setup）

| 措施 | 说明 |
| --- | --- |
| 文件分离 | 应用密钥在 `.env`，root 在 `secrets/mysql_root.env` |
| 权限 | 两文件均 `chmod 600`，仅部署用户可读 |
| 不进 Git | `.env` 与 `secrets/*.env` 已忽略；只提交 `*.example` |
| 网络隔离 | `MYSQL_ROOT_HOST=localhost`：root 不能从 `new-api` 容器或外网连，只能 `docker compose exec` 进 mysql 容器再用 |
| 应用权限 | `newapi` 经 `mysql-init` 限制为仅对库 `new-api` 有 ALL，无其它库权限 |

### MySQL 怎么登录

```bash
# 日常：应用用户（只能进 new-api 库）
docker compose exec -it mysql mysql -u newapi -p new-api

# 紧急：root（仅容器内 localhost）
docker compose exec -it mysql mysql -u root -p
```

**注意：** 用户/密码与 init SQL 只在 **首次** 初始化 `./mysql_data` 时生效。旧数据卷需删卷重建，或手动改权限后再对齐 `.env`。

## 3. 启动

```bash
docker compose up -d
docker compose ps
docker compose logs -f --tail=100
```

数据目录（相对本目录）：

| 路径 | 用途 |
| --- | --- |
| `./data` | new-api 应用数据 |
| `./mysql_data` | MySQL 数据 |
| `./logs` | new-api 日志 |
| `./caddy_data` / `./caddy_config` | Caddy 证书与配置状态 |

## 4. 访问

```text
http://159.75.3.202
```

不要用未备案域名。默认管理员账号以镜像 / 首次启动提示为准。

## 5. 常用运维

```bash
# 停止
docker compose down

# 查看 MySQL 内存是否顶满 512m
docker stats new-api-mysql new-api new-api-caddy

# 仅重建应用
docker compose up -d --force-recreate new-api
```

## 6. 注意

- 这是 **temporary test setup**，密码、`SESSION_SECRET`、证书策略都按测试机处理；上正式环境请重做加固。  
- `SQL_DSN` 在 `docker-compose.yml` 中按  
  `newapi:<MYSQL_PASSWORD>@tcp(mysql:3306)/new-api?parseTime=true` 组装（用户名可用 `MYSQL_USER` 覆盖）。  
- 密码尽量避免 `@` `:` `/` `#` 等特殊字符，否则 DSN 需 URL 编码。  
- 根目录原有 `docker-compose.yml` / `.env.example` **未改动**；请只在本目录启动，避免混用两套编排。
