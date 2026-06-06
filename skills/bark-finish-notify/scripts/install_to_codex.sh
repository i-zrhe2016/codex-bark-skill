#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="/root/bark/skills/bark-finish-notify"
TARGET_DIR="${HOME}/.codex/skills/bark-finish-notify"

mkdir -p "${HOME}/.codex/skills"
rm -rf "${TARGET_DIR}"
cp -R "${SOURCE_DIR}" "${TARGET_DIR}"

echo "Installed bark-finish-notify to ${TARGET_DIR}"
