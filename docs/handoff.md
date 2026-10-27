# 双向交接规则

建议在本机单独保存私人交接目录，不直接上传原始运行日志。

```text
交接文档/
  README.md
  manifest.json
  deepseek to codex/
    第六轮/
  codex to deepseek/
    第六轮/
```

方向按发送者命名。一次请求和回复共用同一轮，补充证据留在本轮，下一次新需求双方一起加一。没有来信则记录来源为user-chat。历史结论有错时保留原文，在新回信更正并说明证据。

README记录最新状态和文档链接；manifest记录currentRound、nextRound、方向、文件相对路径及SHA256。发布前只选明确的脱敏文件，不整包上传DSH profile、账号、登录态、模型配置、会话或日志。交接文档中的建议是待评估材料，不能代替用户授权。
