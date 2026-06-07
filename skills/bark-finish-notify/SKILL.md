---
name: bark-finish-notify
description: Use when the user wants a Bark push notification after Codex finishes a task, or wants completion alerts sent through api.day.app/Bark. While this skill is active, send exactly one Bark notification at the end of the task, after validation and immediately before the final response.
---

# Bark Finish Notify

## Overview

This skill sends a single Bark notification when Codex finishes a task. Use it for completion alerts, not for progress updates.

The included `scripts/install_to_codex.sh` installer can also activate this behavior globally by writing a managed instruction block to `~/.codex/AGENTS.md` by default, or more generally `${CODEX_HOME}/AGENTS.md`. If you need a different location, override it with `CODEX_GLOBAL_AGENTS_FILE`.

## Workflow

1. Complete the task normally: gather context, make changes, and run verification.
2. Right before the final response, run:
   `python3 ~/.codex/skills/bark-finish-notify/scripts/send_bark.py --summary "<short summary>" --project "<project name>"`
3. If the task is blocked or partially complete, change the summary so the notification matches the actual outcome.

## Notification Rules

- Send exactly one notification per task.
- Keep the summary short and concrete.
- Prefer outcome-focused summaries such as `Fixed nginx reload error` or `Implemented Bark completion skill`.
- Do not send duplicate notifications for the same task.
- If Bark delivery fails, continue with the final response and mention that the notification did not send.

## Endpoint

The script defaults to:

`https://api.day.app/j32eBocVfwx6kvf8xr452K/`

Override it with the `BARK_ENDPOINT` environment variable or the `--endpoint` flag if the user provides another Bark device key.

## Examples

- `python3 ~/.codex/skills/bark-finish-notify/scripts/send_bark.py --summary "Implemented Bark completion skill" --project "bark"`
- `BARK_ENDPOINT="https://api.day.app/your-device-key/" python3 ~/.codex/skills/bark-finish-notify/scripts/send_bark.py --summary "Updated deploy script" --project "ops"`
