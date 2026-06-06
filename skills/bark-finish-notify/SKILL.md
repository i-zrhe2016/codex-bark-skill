---
name: bark-finish-notify
description: Use when the user wants a Bark push notification after Codex finishes a task, or wants completion alerts sent through api.day.app/Bark. When this repository skill is in use, send exactly one Bark notification at the end of the task, after validation and immediately before the final response.
---

# Bark Finish Notify

## Overview

This repository skill sends a single Bark notification when Codex finishes a task. Use it for completion alerts, not for progress updates.

## Workflow

1. Complete the task normally: gather context, make changes, and run verification.
2. Right before the final response, run:
   `python3 /root/bark/skills/bark-finish-notify/scripts/send_bark.py --summary "<short summary>" --project "bark"`
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

## Install To Global Codex Skills (optional)

If you want this repository copy to also appear as a globally installed Codex skill, run:

`bash /root/bark/skills/bark-finish-notify/scripts/install_to_codex.sh`
