# 排查顺序

1. QQ本身是否可打开？确认实际QQ.exe路径、版本及来源。
2. NapCat窗口是登录提示、子进程错误还是已在线？扫码由本人完成。
3. OneBot是否启用正向WebSocket，DSH地址和访问令牌是否匹配？不要把WebUI端口当成OneBot。
4. DSH是否收到来信？收到后检查预设、模型额度、工具错误及QQ投递结果。
5. 最终用另一账号真实收发确认；端口在线只是部分检查。

## 本机修复经验的适用边界

直接更改QQ的resources/app/package.json曾触发损坏提示，恢复原字节后可恢复。这个实验不等于官方NapCat必然不能用：官方Windows Boot在进程内重定向文件读取，不需要覆盖QQ安装目录清单。不要把外部qqnt.json复制到QQ目录，也不要为了让版本号看起来一致而改它。

独立QQ副本曾出现GPU process launch failed error_code=18，和清单损坏或QQNT.dll断点退出是不同阶段。错误码本身不能证明显卡硬件坏了。最终原QQ安装路径启动成功，但没有完成权限、父进程、路径等全部变量的因果隔离。

本仓库按使用者要求提供管理员入口。保留当前已经工作的实例；不要为测试新入口反复启动多个QQ。管理员完整启动需要在下一次正常启动时由本人确认UAC及登录，仓库只读检查不会替你完成这些操作。

没有通过关闭防护、放宽安全规则或降级QQ来完成本轮恢复。参考上游：[Windows Boot源码](https://github.com/NapNeko/NapCat-Windows-Boot)、[NapCat发布页](https://github.com/NapNeko/NapCatQQ/releases)。
