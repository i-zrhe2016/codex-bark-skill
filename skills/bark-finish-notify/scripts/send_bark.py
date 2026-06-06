#!/usr/bin/env python3
"""Send a Bark notification for a completed Codex task."""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request

DEFAULT_ENDPOINT = "https://api.day.app/j32eBocVfwx6kvf8xr452K/"


def normalize_endpoint(endpoint: str) -> str:
    endpoint = endpoint.strip()
    if not endpoint:
        raise ValueError("Bark endpoint is empty")
    if not endpoint.endswith("/"):
        endpoint = f"{endpoint}/"
    return endpoint


def build_payload(summary: str, project: str, body: str | None) -> dict[str, str]:
    return {
        "title": "Codex task complete",
        "body": body or f"Project: {project}\nSummary: {summary}",
        "group": "Codex",
        "sound": "telegraph",
    }


def send_notification(endpoint: str, payload: dict[str, str]) -> dict[str, object]:
    data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        endpoint,
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=10) as response:
        raw_body = response.read().decode("utf-8")
    if not raw_body:
        return {}
    return json.loads(raw_body)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Send a Bark notification for a completed Codex task."
    )
    parser.add_argument(
        "--summary",
        required=True,
        help="Short completion summary shown in the notification body.",
    )
    parser.add_argument(
        "--project",
        default="bark",
        help="Project name included in the notification body.",
    )
    parser.add_argument(
        "--body",
        help="Optional full notification body. Overrides the generated project/summary body.",
    )
    parser.add_argument(
        "--endpoint",
        default=os.environ.get("BARK_ENDPOINT", DEFAULT_ENDPOINT),
        help="Full Bark endpoint, for example https://api.day.app/your-device-key/.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    try:
        endpoint = normalize_endpoint(args.endpoint)
        payload = build_payload(args.summary.strip(), args.project.strip(), args.body)
        result = send_notification(endpoint, payload)
    except ValueError as exc:
        print(f"Invalid Bark configuration: {exc}", file=sys.stderr)
        return 2
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        print(f"Bark request failed: HTTP {exc.code}: {detail}", file=sys.stderr)
        return 1
    except urllib.error.URLError as exc:
        print(f"Bark request failed: {exc.reason}", file=sys.stderr)
        return 1
    except TimeoutError:
        print("Bark request failed: timed out", file=sys.stderr)
        return 1

    code = result.get("code")
    if code not in (None, 200):
        print(f"Bark returned an unexpected response: {json.dumps(result)}", file=sys.stderr)
        return 1

    print(
        json.dumps(
            {
                "ok": True,
                "endpoint": endpoint,
                "summary": args.summary.strip(),
                "result": result,
            },
            ensure_ascii=True,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
