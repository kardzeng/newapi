# Modifications

本仓库相对上游 [QuantumNous/new-api](https://github.com/QuantumNous/new-api) 的修改记录（AGPLv3 Section 7(c)）。

| 日期 | 文件 | 改动说明 |
| --- | --- | --- |
| 2026-11-18 | `web/src/features/about/index.tsx` | 关于页空状态补充 NOTICE 要求的署名文案（i18n） |
| 2026-11-18 | `web/src/components/layout/components/footer.tsx` | 页脚署名改为 NOTICE 规定原文（i18n），保留指向原项目的可见链接 |
| 2026-11-18 | `web/src/i18n/locales/{en,zh,zh-TW,fr,ja,ru,vi}.json` | 新增署名文案的七语种翻译键 |
| 2026-11-18 | `web/scripts/sync-i18n.mjs` | 移除已不再使用的页脚署名混淆键配置 |
| 2026-11-18 | `README.md` | 顶部补充 fork / AGPL-3.0 / 源码仓库声明 |
| 2026-11-18 | `README.zh_CN.md` | 顶部补充 fork / AGPL-3.0 / 源码仓库声明 |
| 2026-11-18 | `MODIFICATIONS.md` | 新建本修改记录文件 |
| 2026-11-18 | `deploy/test-external/docker-compose.yml` | 新增外网临时测试编排：new-api + MySQL 8.0 + Caddy；宿主仅 8080/8443；无 Redis，内存缓存；MySQL mem_limit 512m 与低内存参数 |
| 2026-11-18 | `deploy/test-external/Caddyfile` | 新增 Caddy：8080/8443、自签 TLS、反代 new-api:3000（WebSocket/SSE flush） |
| 2026-11-18 | `deploy/test-external/.env.example` | 新增测试环境敏感项占位（MySQL 密码、SESSION_SECRET、Cookie Origin） |
| 2026-11-18 | `deploy/test-external/DEPLOY_TEST.md` | 新增临时测试部署步骤、DNS、TLS/自签与 DNS 挑战说明 |
| 2026-11-18 | `deploy/test-external/docker-compose.yml` | 应用用 `newapi`；root 改由 `secrets/mysql_root.env` 注入，且 `MYSQL_ROOT_HOST=localhost` |
| 2026-11-18 | `deploy/test-external/.env.example` | 仅保留应用侧 `MYSQL_USER`/`MYSQL_PASSWORD` 与会话密钥 |
| 2026-11-18 | `deploy/test-external/secrets/mysql_root.env.example` | 新增 root 密码单独示例文件（真实 `mysql_root.env` 不提交） |
| 2026-11-18 | `deploy/test-external/mysql-init/01-restrict-newapi.sql` | 限制 `newapi` 仅对 `new-api` 库有 ALL 权限 |
| 2026-11-18 | `deploy/test-external/DEPLOY_TEST.md` | 补充 root 分文件 + localhost 隔离安全方案与登录说明 |
| 2026-11-18 | `.gitignore` | 忽略 `deploy/test-external/secrets/*.env`（保留 `*.example`） |
| 2026-11-18 | `deploy/test-external/docker-compose.yml` | HTTP 测试：`SESSION_COOKIE_SECURE=false`；固定独立的 `SESSION_SECRET` 与 `CRYPTO_SECRET` |
| 2026-11-18 | `deploy/test-external/.env.example` | 会话密钥改由 compose 固定；示例中移除 Secure/TRUSTED_URL |
| 2026-11-18 | `deploy/test-external/DEPLOY_TEST.md` | 同步 HTTP Cookie / 双密钥说明 |
| 2026-11-18 | `web/src/features/system-update/use-system-update.ts` | 关闭管理端自动检查更新（`enabled: false`），避免直连 api.github.com |
| 2026-11-18 | `web/src/features/system-update/__tests__/update-checking.test.tsx` | 测试中临时打开自动检查路径以覆盖原有用例 |
| 2026-11-18 | `deploy/test-external/{docker-compose.yml,Caddyfile,DEPLOY_TEST.md,.env.example}` | 对外 HTTP 端口由 8080 改为 7000（HTTPS 仍为 8443） |
