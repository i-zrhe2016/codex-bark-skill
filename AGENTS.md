# Project Instructions

For every completed task in this project, send exactly one Bark completion notification immediately before the final response.

Use the repository Bark skill at [skills/bark-finish-notify/SKILL.md](/root/bark/skills/bark-finish-notify/SKILL.md:1) for workflow details.

Run:

`python3 /root/bark/skills/bark-finish-notify/scripts/send_bark.py --summary "<short outcome summary>" --project "bark"`

Rules:

- Send the notification only after implementation and verification are finished.
- Send one notification per task, not per intermediate update.
- Keep the summary short and concrete.
- If the task is blocked or only partially complete, make the summary reflect that state.
- If the Bark request fails, still return the final response and mention the delivery failure.
