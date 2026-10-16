# 来源、差异和使用边界

## 固定来源

| 对象 | 来源 |
|---|---|
| 原项目 | [morluto/rea](https://github.com/morluto/rea) |
| 自有 Fork | [Roby001Debug/rea](https://github.com/Roby001Debug/rea) |
| 适配分支基线 | 上游主线提交 `9a82046b07244e62df22076b64ded05ff9abc5db`，包版本 6.5.0 |
| 技能原始发布 | [rea-agents 6.3.0](https://www.npmjs.com/package/rea-agents/v/6.3.0) |
| 原始发布对应源码 | [rea-agents-6.3.0](https://github.com/morluto/rea/tree/rea-agents-6.3.0)，提交 `74cf9e1401fcd89482fe39c27cc898f5858e9b72` |
| 本机适配来源 | MN-Tech engineering R01，2026-10-10；只提取通用技能文件 |
| 可迁移适配 | MN-Tech engineering R02 portable，2026-10-17 |

整理时从 npm 取得 6.3.0 发布包，验证 registry 提供的 SHA-512 integrity 与 SHA-1，再比较技能文件。本机两个技能副本的文件清单和 SHA-256 一致；发布包中的五份指南以及许可证与本机对应文件逐字节一致。原始发布包只用于本地核验，未放进本目录。

## 文件层面的改动

| 文件 | 处理 |
|---|---|
| `SKILL.md` | 保留上游方法，加入工程路由、规则入口、MCP 能力边界与协作规则；R02 明确基线，移除“目标电脑已经安装好”的假设 |
| `references/local-engineering-rules.md` | 通用工程规则，来源于 R01；没有客户路径、设备身份或专有代码 |
| `agents/openai.yaml` | Codex 自动调用和 `rea` MCP 依赖声明；不包含本机启动路径，不负责注册服务 |
| `NOTICE.md` | 来源、版本、MIT 声明和升级提醒 |
| `LICENSE` | 保留上游 MIT 原文及 morluto 署名 |
| 其余五份 `references/*.md` | 与 npm 6.3.0 发布包逐字节相同 |
| 安装器、中文说明、合成测试 | 此次独立增加，只用于技能文件的可迁移安装 |

所有可安装文件的 SHA-256 见 [manifest.json](manifest.json)。校验只能证明内容一致性，来源真实性还应结合保存的 Git 提交和下载位置核对。

## 分支和版本策略

本分支相对基线只新增 `mn-tech/`；没有修改上游 `.agents/skills/`、`src/`、构建文件、MCP 实现或原厂程序。`main` 作为上游镜像保留。适配目录不加入上游 npm 的自动打包清单，使用时按独立说明安装。

6.3.0 是本次核验的指令来源；6.5.0 是 Fork 主线的版本。两者并列保存便于保留上游演进，但不宣称旧技能已经在新版运行时完成验收。静态来源核对、文件安装测试、真实 MCP 功能测试是不同证据层级。

## 脱敏范围

只发布明确列出的文本、脚本和合成测试。排除客户名、站名、工程目录、地址、主机/点标识、凭据、工程原件、供应商二进制、反编译代码、License 数据、截图、抓包和环境配置。项目对应表和扫描原始记录保留在本地。

本适配不包含试用延期、许可算法修改或任何项目专用补丁。工程规则仍由目标项目的 AGENTS 和操作者的实际授权决定。

## 许可证

REA 原文保留 [MIT 许可证](skill/reverse-engineer-anything/LICENSE) 与署名；MN-Tech 新增内容按同一 MIT 条款提供。它是独立下游适配，不代表上游对本目录或任何特定工程应用的认可。
