# codex-bark-skill

一个给 Codex 使用的 Bark 完成通知技能仓库。

这个仓库的核心能力是在任务完成后发送一条 Bark 推送，适合在本地挂机执行、长时间代码修改、批量验证或异步等待结果时使用。

## 功能

- 提供 `bark-finish-notify` 技能定义
- 提供一键安装到 `~/.codex/skills/` 的脚本
- 安装时自动写入 `~/.codex/AGENTS.md` 全局指令，让 Codex 项目默认带 Bark 完成通知
- 提供独立的 Bark 发送脚本
- 支持通过环境变量或命令行覆盖 Bark endpoint
- 默认在通知中带上项目名和任务摘要

## 目录结构

```text
skills/
  bark-finish-notify/
    SKILL.md                    技能说明
    agents/openai.yaml          Codex agent 元数据
    scripts/send_bark.py        Bark 推送脚本
    scripts/install_to_codex.sh 安装脚本
```

## 安装

将技能安装到当前用户的 Codex 技能目录，并自动配置全局 Codex 指令：

```bash
bash skills/bark-finish-notify/scripts/install_to_codex.sh
```

安装完成后：

```bash
~/.codex/skills/bark-finish-notify
```

```bash
~/.codex/AGENTS.md
```

默认行为：

- skill 会被安装到 `${CODEX_HOME:-~/.codex}/skills/bark-finish-notify`
- 安装脚本会幂等写入一个受控的 Bark 指令块到 `${CODEX_GLOBAL_AGENTS_FILE:-${CODEX_HOME}/AGENTS.md}`
- 这样位于用户家目录下的所有 Codex 项目都会继承“任务结束前发送一次 Bark 通知”的规则

如果你需要更强的全局范围，例如不止 `~/` 下的项目，可以把指令块写到更高层的 `AGENTS.md`：

```bash
CODEX_GLOBAL_AGENTS_FILE=/AGENTS.md \
bash skills/bark-finish-notify/scripts/install_to_codex.sh
```

如果你自定义了 Codex 数据目录，也可以一起指定：

```bash
CODEX_HOME=/custom/codex \
bash skills/bark-finish-notify/scripts/install_to_codex.sh
```

安装后重启 Codex，确保新 skill 和全局指令被加载。

## 使用方式

### 1. 在 Codex 任务完成后发送通知

```bash
python3 ~/.codex/skills/bark-finish-notify/scripts/send_bark.py \
  --summary "Implemented Bark completion skill"
```

脚本会默认使用当前工作目录名作为项目名。
如果你设置了 `CODEX_HOME`，把示例中的 `~/.codex` 替换成对应目录即可。

### 2. 指定项目名

```bash
python3 ~/.codex/skills/bark-finish-notify/scripts/send_bark.py \
  --summary "Updated deploy script" \
  --project "ops"
```

### 3. 自定义 Bark endpoint

使用环境变量：

```bash
BARK_ENDPOINT="https://api.day.app/your-device-key/" \
python3 ~/.codex/skills/bark-finish-notify/scripts/send_bark.py \
  --summary "Task complete"
```

或显式传参：

```bash
python3 ~/.codex/skills/bark-finish-notify/scripts/send_bark.py \
  --summary "Task complete" \
  --endpoint "https://api.day.app/your-device-key/"
```

### 4. 自定义完整通知正文

```bash
python3 ~/.codex/skills/bark-finish-notify/scripts/send_bark.py \
  --summary "Task complete" \
  --body "Deployment finished and smoke tests passed."
```

## 通知内容

默认通知内容包含：

- 标题：`Codex task complete`
- 分组：`Codex`
- 声音：`telegraph`
- 正文：`Project: <项目名>` 和 `Summary: <摘要>`

## 在 Codex 中的使用约定

建议把这个技能作为“任务完成钩子”使用；安装脚本已经把这条约定写入全局 `~/.codex/AGENTS.md`：

1. 先完成实际工作
2. 运行测试或必要验证
3. 在最终回复前只发送一次 Bark 通知

如果任务失败、阻塞或只部分完成，通知摘要也应该反映真实状态。

## 适用场景

- 让 Codex 在长任务结束时主动提醒
- 远程开发或后台运行时减少手动轮询
- 需要区分不同项目的完成状态
- 把 Bark 作为轻量级完成信号接入个人工作流

## 注意事项

- `install_to_codex.sh` 会覆盖目标 skill 目录中的 `bark-finish-notify`
- `install_to_codex.sh` 会更新 `AGENTS.md` 中由它管理的 Bark 指令块，但不会动其他内容
- `send_bark.py` 默认 endpoint 已内置，可按需覆盖
- 如果 Bark 请求失败，调用方仍应继续输出最终结果，并单独说明通知发送失败

## License

仓库内未提供单独的许可证文件；如需开源分发，建议补充 `LICENSE`。
