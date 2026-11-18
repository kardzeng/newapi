# External test deploy (temporary test setup)

本目录是面向外网临时测试的最小部署配置（2 核 2G、MySQL、访问量小）。

- 域名：`newapi.aigava.ai`
- 对外端口：HTTP `8080`、HTTPS `8443`
- 未发布常用特权 Web 端口；公网入口只有 Caddy
- 无 Redis：`MEMORY_CACHE_ENABLED=true`（省内存）
- 合规：勿改仓库根目录的 `LICENSE` / `NOTICE` / `THIRD-PARTY-LICENSES.md`；界面署名保持原样

## 1. DNS

先把 `newapi.aigava.ai` **A 记录**解析到这台服务器的公网 IP，并确认已生效：

```bash
dig +short newapi.aigava.ai
```

安全组 / 防火墙只放行入站 **8080** 与 **8443**（以及你自己用的 SSH）。

## 2. 准备环境变量

在本目录执行：

```bash
cd deploy/test-external
cp .env.example .env
```

编辑 `.env`：

1. `MYSQL_USER=newapi`（默认即可）  
2. 把 `MYSQL_PASSWORD=CHANGE_ME` 改成应用库强密码（**new-api 用这个账号连库，不用 root**）  
3. 把 `MYSQL_ROOT_PASSWORD=CHANGE_ME_ROOT_ONLY` 改成另一套强密码（仅容器初始化 / 紧急运维）  
4. 用 `openssl rand -hex 32` 生成并填入 `SESSION_SECRET`  
5. 确认 `SESSION_COOKIE_TRUSTED_URL=https://newapi.aigava.ai:8443`

### MySQL 怎么登录

| 用途 | 用户 | 密码变量 | 说明 |
| --- | --- | --- | --- |
| 应用 / 日常 | `newapi` | `MYSQL_PASSWORD` | 官方镜像初始化时自动创建，权限仅库 `new-api` |
| 紧急管理 | `root` | `MYSQL_ROOT_PASSWORD` | 不要写进 `SQL_DSN`；平时别用 |

在容器内登录应用用户：

```bash
docker compose exec mysql \
  mysql -u newapi -p"$MYSQL_PASSWORD" new-api
# 或交互输入密码：
docker compose exec -it mysql mysql -u newapi -p new-api
```

紧急用 root：

```bash
docker compose exec -it mysql mysql -u root -p
```

**注意：** `MYSQL_USER` / `MYSQL_PASSWORD` 只在 **首次** 初始化 `./mysql_data` 时生效。若以前已经用 root 起过库，需要删卷重建，或手动建用户：

```sql
CREATE USER 'newapi'@'%' IDENTIFIED BY '你的密码';
GRANT ALL PRIVILEGES ON `new-api`.* TO 'newapi'@'%';
FLUSH PRIVILEGES;
```

然后改 `.env` 的 `MYSQL_PASSWORD`，并 `docker compose up -d --force-recreate new-api`。

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

优先使用：

```text
https://newapi.aigava.ai:8443
```

HTTP 调试入口：

```text
http://newapi.aigava.ai:8080
```

默认管理员账号以镜像 / 首次启动提示为准（上游 new-api 惯例多为首次打开控制台设置）。

## 5. TLS 说明（temporary test setup）

### 默认：自签 / 内部 CA（已启用）

当前 `Caddyfile` 使用 `tls internal` + `local_certs`。浏览器会提示证书不受信任，测试环境可先「继续访问」。

这是推荐的临时方案：本布局**不**对外发布 ACME 常用校验端口，Let's Encrypt 的 HTTP-01 / TLS-ALPN-01 **通常无法**仅靠开放 `8443` 自动签发成功。

### 若仍想尝试 Caddy 自动证书

仅开放 `8443` **不足以**保证 ACME 签发成功。若日志里出现证书申请失败，请继续用自签，或改用下方 DNS 挑战。

### 备选：DNS 挑战签发正式证书

1. 在 DNS 服务商创建 API Token（需能改该域名的 TXT 记录）  
2. 按 [Caddy DNS providers](https://caddyserver.com/docs/modules/) 选用对应插件镜像或构建含 DNS 模块的 Caddy  
3. 将站点块改为类似：

```caddy
newapi.aigava.ai {
	tls {
		dns <provider> ...
	}
	reverse_proxy new-api:3000 {
		flush_interval -1
		header_up Host {host}
		header_up X-Real-IP {remote_host}
		header_up X-Forwarded-For {remote_host}
		header_up X-Forwarded-Proto {scheme}
		header_up Upgrade {http.request.header.Upgrade}
		header_up Connection {http.request.header.Connection}
	}
}
```

4. `docker compose up -d --force-recreate caddy`

### 备选：自备证书文件

把证书放到本目录（例如 `./certs/fullchain.pem`、`./certs/privkey.pem`），挂载进 Caddy，并将站点 TLS 改为：

```caddy
tls /etc/caddy/certs/fullchain.pem /etc/caddy/certs/privkey.pem
```

## 6. 常用运维

```bash
# 停止
docker compose down

# 查看 MySQL 内存是否顶满 512m
docker stats new-api-mysql new-api new-api-caddy

# 仅重建应用
docker compose up -d --force-recreate new-api
```

## 7. 注意

- 这是 **temporary test setup**，密码、`SESSION_SECRET`、证书策略都按测试机处理；上正式环境请重做加固。  
- `SQL_DSN` 在 `docker-compose.yml` 中按  
  `newapi:<MYSQL_PASSWORD>@tcp(mysql:3306)/new-api?parseTime=true` 组装（用户名可用 `MYSQL_USER` 覆盖）。  
- 密码尽量避免 `@` `:` `/` `#` 等特殊字符，否则 DSN 需 URL 编码。  
- 根目录原有 `docker-compose.yml` / `.env.example` **未改动**；请只在本目录启动，避免混用两套编排。
