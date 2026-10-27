# NapCat 部署助手（DSH 插件）

提供DSH可安装插件、NapCat部署指南与本机端口只读检查，并附Windows管理员启动脚本。QQ登录、DSH安装、模型与人设配置仍需要自行完成。插件不代替OneBot消息适配器。

## 安装到DSH

```powershell
dsh plugin --profile desktop add github:zhuziddl/my
```

重载对应profile后，插件在有tools服务的作用域提供 `napcat_deploy_check` 工具：`mode=guide`返回指南，`mode=status`只检查本机默认3001/6099端口。若所选Agent预设隔离根作用域工具，需要在该预设的plugins中挂载 `dsh-napcat-deploy` 才能看到工具。本插件没有自动启动、提权或发消息行为。

也可按[DSH插件市场文档](https://deepseek-harness.github.io/deepseek-harness/en/guide/plugin-market)启用Custom plugin markets，在“插件 → Discover → 添加索引源”填写：

```text
https://raw.githubusercontent.com/zhuziddl/my/main/index.json
```

这是本仓库提供的独立索引，版本固定到Git提交；不是社区市场已审核收录的声明。包名尚未发布到npm；无需npm发布即可从GitHub安装。若需要社区市场收录，可使用仓库链接及catalog-entry.yml提交。

## 已验证范围

兼容基线为Windows x64、QQ 9.9.33-52230、官方NapCat4.18.41；其他版本应重新验证。当前入口申请管理员权限。自动化检查覆盖插件行为与启动前校验，不等于每台机器都已完成管理员启动、登录和真实消息验收。提权并不保证修复所有启动故障。

## 下次部署

1. 下载本仓库并解压到固定目录。安装腾讯官方Windows QQ，记录QQ.exe实际路径，先确认普通QQ可打开。
2. 在 [NapCat官方4.18.41发布页](https://github.com/NapNeko/NapCatQQ/releases/tag/v4.18.41) 下载 `NapCat.Shell.zip`。此版本为复现基线，升级时要重新核对上游包和哈希。
3. 在本目录打开PowerShell，执行：

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1 -ArchivePath "$env:USERPROFILE\Downloads\NapCat.Shell.zip"
   ```

   脚本校验ZIP的SHA256并解压到本目录runtime/shell，不覆盖已有目录，不修改QQ文件。上述命令和启动入口的ExecutionPolicy Bypass仅作用于本次PowerShell子进程，不更改系统或用户的永久执行策略；运行前应检查下载来源和脚本内容。
4. 编辑生成的 `config.local.json`，填自己的 `qqExe` 和 `qqNumber`。不要提交此文件。默认shellDirectory使用本目录的runtime/shell；如果已经有官方NapCat，可改成本机现有shell目录的绝对路径，从而跳过第2、3步。
5. 双击 `Start.cmd`，同意Windows管理员权限提示。若要求登录，由本人扫码登录目标账号，保持启动窗口运行。
6. 使用NapCat本机WebUI配置OneBot **正向WebSocket服务端**，本机示例为 `127.0.0.1:3001`；在DSH的OneBot适配器配置对应WebSocket地址、相同访问令牌和目标预设。此处的令牌在各自本机界面设置，本仓库不存储它。不同DSH版本界面或配置字段可能不同。
7. 保持DSH运行，用另一个QQ账号发消息并确认回复。WebUI的6099和OneBot的3001用途不同；3001返回HTTP426通常表示需要WebSocket。

只检查路径、文件和端口，不启动QQ、不申请提权：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Start.ps1 -CheckOnly
```

有服务占用配置的OneBot端口时入口会停止，避免重复启动；端口监听本身不能证明登录身份或聊天正常。

## 文件说明

- `Install.ps1`：从自行下载的固定版本官方ZIP安装。
- `Start.cmd` / `Start.ps1`：读取本地配置、申请管理员权限、调用官方BootMain。
- `config.example.json`：不含账号和令牌的模板。
- [故障排查](docs/troubleshooting.md)：区分启动、登录、连接与模型故障。
- [交接规则](docs/handoff.md)：双向目录与同步轮次。

仓库不分发QQ或NapCat二进制，不包含聊天、登录态、模型密钥、真实账号或完整DSH profile。DSH主题、记忆、主动聊天、游戏插件不在本脚本的自动安装范围内；恢复它们需要各自的版本与配置，不能仅靠复制本仓库完成。
