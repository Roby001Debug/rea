# 在另一台 Windows 电脑使用

安装分为“REA 运行时/MCP”和“MN-Tech 指令技能”两层。这里的脚本只处理第二层。已有 REA 正常工作的电脑只需确认版本、备份原技能并安装指令，不需要重装 REA。

## 1. 取得适配

从自己的 Fork 获取适配分支，或下载这个分支的 ZIP：

```powershell
git clone --branch mn-tech/rea-6.5.0 --single-branch https://github.com/Roby001Debug/rea.git rea-mn-tech
Set-Location -LiteralPath '.\rea-mn-tech\mn-tech\versions\6.5.0'
git rev-parse HEAD
```

记录提交号，再阅读 [PROVENANCE.md](PROVENANCE.md) 和 [VALIDATION.md](VALIDATION.md)。ZIP 下载时也应选择上述分支；下列命令从解压后的 `mn-tech/versions/6.5.0` 目录运行。只搬运本版本技能时，复制整个 `6.5.0` 目录并保留内部结构即可，不必携带上游源码或 `node_modules`。原 6.3.0 适配位置见 [版本索引](../../VERSIONS.md)。

安装器适用于 Windows PowerShell 5.1 / PowerShell 7，使用系统文件 API，不要求管理员权限或额外模块。文档是 UTF-8；脚本使用 ASCII 字符，兼容 5.1 的读取方式。请保留本目录的 `.gitattributes`，它关闭本目录的 Git 自动换行转换，确保 Windows 签出后文件哈希与清单一致。

## 2. 确认或准备 REA 运行时

技能基线是 **rea-agents 6.5.0**。该发布的 Node 要求是 `^22.19.0 || ^24.11.0 || >=26.0.0`。运行时、Node 和可选分析引擎由目标电脑单独管理。

已有安装时先查看实际包的 `package.json` 核对版本，再使用该安装的 `rea` 命令或 Node 入口诊断：

```powershell
rea doctor --client codex --json
```

**定制技能的已知提示：** 6.5.0 的 `doctor --skill` 除了版本，还逐字节比较上游规范文件。此适配有意修改了 SKILL.md，因此会显示版本 42、207 tools、`state: stale`，退出码 1；隔离原版对照为 `aligned`、退出码 0。先核对本包 manifest 和已说明的差异，不把这个提示当成必须覆盖技能的故障。需要保留适配而只修复 MCP 注册时，使用 `setup --client codex --skill=false --dry-run --json`；核对计划并获得对应操作授权后，应用同一范围的 `--skill=false --yes`。本安装器不会自动调用 setup。

只有全新电脑需要准备运行时、且操作者同意下载固定版本时，才使用上游入口：

```powershell
npx -y rea-agents@6.5.0 doctor --client codex --json
npx -y rea-agents@6.5.0 setup --client codex --dry-run --json
```

`npx` 可能联网下载。检查 dry-run 给出的配置、备份路径和技能替换计划，再决定是否执行：

```powershell
npx -y rea-agents@6.5.0 setup --client codex --yes
```

上游 setup 会写 MCP 配置，并可能安装同名技能，因此先完成运行时 setup，再处理技能。这里不自动安装可选引擎。本目录已完成 6.5.0 核心静态流程的隔离验证；其他版本需另做验证，不自动升级或降级现有运行时。当前桌面客户端重连和可选原生引擎不在本轮验证范围。

## 3. 选择技能目录并预览

Codex 默认目录的示例：

```powershell
$reaSkillsDirectory = Join-Path $HOME '.codex\skills'
.\scripts\Install-MnTechRea.ps1 -SkillsDirectory $reaSkillsDirectory
```

自定义 Codex home 应选择它实际使用的 `skills` 目录。只安装到一个当前客户端会读取的位置，不默认同时安装到 `.codex` 和 `.agents`，以免同名技能产生歧义。

预期输出 JSON：`mode = preview`、文件数、目标目录及版本。预览只读，不创建目录、不联网，并核对文件清单与每个文件 SHA-256，拒绝额外文件、损坏文件以及符号链接/目录联接。

`Destination already exists` 表示原件保护生效。脚本没有覆盖选项。先确认原技能来源；联接到技能主库的目录应走该主库自己的维护流程，不直接移动或覆盖联接。

## 4. 已有普通目录时人工备份

仅在核对目录、同意替换该电脑的技能、且相关会话适合切换时操作。备份必须位于客户端所有技能搜索目录以外，避免仍被当成技能加载。

```powershell
$reaActive = Join-Path $reaSkillsDirectory 'reverse-engineer-anything'
$reaArchiveRoot = Join-Path $HOME 'rea-skill-backups'
$reaArchive = Join-Path $reaArchiveRoot ('reverse-engineer-anything-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$reaExisting = Get-Item -LiteralPath $reaActive -Force
if (($reaExisting.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
    throw 'Managed link detected; use its owning library workflow.'
}
if (Test-Path -LiteralPath $reaArchive) { throw 'Backup path already exists.' }
New-Item -ItemType Directory -Path $reaArchiveRoot -Force | Out-Null
Move-Item -LiteralPath $reaActive -Destination $reaArchive -ErrorAction Stop
```

记录并保留 `$reaArchive`。这是人工变更，不属于默认预览。不要对使用不同路径的客户端照搬默认位置。

## 5. 应用并核对

再次预览，再明确应用到已空出的目标：

```powershell
.\scripts\Install-MnTechRea.ps1 -SkillsDirectory $reaSkillsDirectory
.\scripts\Install-MnTechRea.ps1 -SkillsDirectory $reaSkillsDirectory -Apply
```

成功输出 `mode = installed`，所有文件已回读 SHA-256。安装器只创建 `reverse-engineer-anything`，不运行 REA、不改客户端配置、不重启应用。重复安装会报告目标已存在，原有内容保持不变。不要向同一目录并发安装。

在合适时点打开新 Codex 会话，确认技能被发现且实际 REA MCP 工具可用。用自制小型测试程序集验证静态身份和已知函数路径；“技能可见”不代表 MCP 已连接或引擎可用。隔离 stdio 客户端已验证握手、实际工具调用和正常退出；目标电脑的 Codex 会话发现与重连仍需各自确认。

## 6. 回退

在客户端停止使用该技能的时点，把新技能移到全新归档位置，再把原备份移回。不要删除整个技能根目录。

```powershell
# Keep the verified values of $reaActive, $reaArchive and $reaArchiveRoot from step 4.
$reaRetired = Join-Path $reaArchiveRoot ('mn-tech-retired-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
if (Test-Path -LiteralPath $reaRetired) { throw 'Retired path already exists.' }
if (-not (Test-Path -LiteralPath $reaArchive -PathType Container)) { throw 'Original backup is missing.' }
$reaCurrent = Get-Item -LiteralPath $reaActive -Force
if (($reaCurrent.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw 'Unexpected link; stop.' }
Move-Item -LiteralPath $reaActive -Destination $reaRetired -ErrorAction Stop
if (Test-Path -LiteralPath $reaActive) { throw 'Active path still exists; stop.' }
Move-Item -LiteralPath $reaArchive -Destination $reaActive -ErrorAction Stop
```

失败时保留归档与错误，确认实际路径后继续。新装且没有旧备份时，只需把新技能移出所有活动技能目录，再开新会话。MCP 和运行时未由本安装器修改，技能回退不需要卸载运行时。

## 7. 故障与升级

- `Payload integrity mismatch`：与清单不一致，重新核对固定提交的下载内容，不通过修改哈希绕过错误。
- `Unlisted payload file`：载荷混入额外文件，保留检查结果并使用干净发布目录。
- `Refusing a symbolic link or junction`：源或目标经过联接，选择普通目录或走现有主库维护流程。
- 权限或磁盘错误：可能留下部分新目录；脚本保留它供检查，不自动删除。归档部分目录并确认原备份仍在，再重新预览。
- 执行策略阻止：遵守目标电脑策略，核查来源或进行企业签名，不全局关闭执行策略。
- 升级：先归档现有适配，审查新版技能、参数和差异，更新清单并验证。旧 `tool_count` 不代表新服务的实际工具列表。

## 可选：临时目录离线检查

```powershell
$reaTestRoot = Join-Path ([IO.Path]::GetTempPath()) ('rea-mn-tech-check-' + [guid]::NewGuid().ToString('N'))
.\tests\Test-Install.ps1 -TestRoot $reaTestRoot -Apply
```

测试只使用包内文本和合成文件，结果留在指定目录，不读取或更改真实技能、运行时或 MCP 配置。测试文件及人为创建的联接由操作者核对后清理。

## Windows 兼容边界

参见 [兼容性说明](skill/reverse-engineer-anything/references/mn-tech-compatibility.md)。遇到私有临时目录 EPERM 时先定位客户端权限边界，不修改 REA 私有目录 ACL、不关闭系统防护，也不自动提升权限。本轮在保持同一副本与样本的条件下，经授权切换执行权限后 JavaScript 分析成功。SQLite 另需 Node 24.15+（24.x）或兼容 26+；本轮复用的 Node 24.14.1 不支持该可选能力。
