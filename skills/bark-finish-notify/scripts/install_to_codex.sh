#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CODEX_HOME="${CODEX_HOME:-${HOME}/.codex}"
TARGET_DIR="${CODEX_HOME}/skills/bark-finish-notify"
GLOBAL_AGENTS_FILE="${CODEX_GLOBAL_AGENTS_FILE:-${CODEX_HOME}/AGENTS.md}"
BEGIN_MARKER="<!-- BEGIN bark-finish-notify managed block -->"
END_MARKER="<!-- END bark-finish-notify managed block -->"
MANAGED_BLOCK_FILE=""
AGENTS_TMP_FILE=""

cleanup() {
  if [ -n "${MANAGED_BLOCK_FILE}" ]; then
    rm -f "${MANAGED_BLOCK_FILE}"
  fi
  if [ -n "${AGENTS_TMP_FILE}" ]; then
    rm -f "${AGENTS_TMP_FILE}"
  fi
}

trap cleanup EXIT

mkdir -p "${CODEX_HOME}/skills"
rm -rf "${TARGET_DIR}"
cp -R "${SOURCE_DIR}" "${TARGET_DIR}"

MANAGED_BLOCK_FILE="$(mktemp)"

cat > "${MANAGED_BLOCK_FILE}" <<EOF
${BEGIN_MARKER}
# Bark Finish Notify

For every completed task in this project, send exactly one Bark completion notification immediately before the final response.

Use the installed Bark skill at \`${TARGET_DIR}/SKILL.md\` for workflow details.

Run:

\`python3 ${TARGET_DIR}/scripts/send_bark.py --summary "<short outcome summary>"\`

Rules:

- Send the notification only after implementation and verification are finished.
- Send one notification per task, not per intermediate update.
- Keep the summary short and concrete.
- Let the script infer the project name from the current working directory unless the user asks for a specific project label.
- If the task is blocked or only partially complete, make the summary reflect that state.
- If the Bark request fails, still return the final response and mention the delivery failure.
${END_MARKER}
EOF

mkdir -p "$(dirname "${GLOBAL_AGENTS_FILE}")"

if [ -f "${GLOBAL_AGENTS_FILE}" ]; then
  AGENTS_TMP_FILE="$(mktemp)"
  awk -v begin="${BEGIN_MARKER}" -v end="${END_MARKER}" '
    $0 == begin { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "${GLOBAL_AGENTS_FILE}" > "${AGENTS_TMP_FILE}"
  mv "${AGENTS_TMP_FILE}" "${GLOBAL_AGENTS_FILE}"
  AGENTS_TMP_FILE=""
fi

if [ -s "${GLOBAL_AGENTS_FILE}" ]; then
  printf '\n' >> "${GLOBAL_AGENTS_FILE}"
fi

cat "${MANAGED_BLOCK_FILE}" >> "${GLOBAL_AGENTS_FILE}"

echo "Installed bark-finish-notify to ${TARGET_DIR}"
echo "Configured Bark completion instructions in ${GLOBAL_AGENTS_FILE}"
