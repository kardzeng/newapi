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
