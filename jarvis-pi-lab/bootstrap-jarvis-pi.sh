#!/usr/bin/env bash
# Herdr: four pi agents for jarvis-pi orchestration. Project cwd = arg / JARVIS_PI_PROJECT / pwd.
# Prereqs: herdr session running, pi + jq on PATH, new panes at shell prompts.
set -euo pipefail

log() { printf '==> %s\n' "$*"; }

KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
FORCE=0
POSITIONAL=()

usage() {
  cat <<EOF
Usage: $(basename "$0") [--force] [PROJECT_PATH]

PROJECT_PATH defaults to JARVIS_PI_PROJECT, else pwd (see also: jarvis command).

Options:
  --force   Create a new workspace even if one exists for this project label
  -h        Help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force|-f) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

if [[ ${#POSITIONAL[@]} -gt 0 ]]; then
  PROJECT_CWD="$(cd "${POSITIONAL[0]}" && pwd)"
elif [[ -n "${JARVIS_PI_PROJECT:-}" ]]; then
  PROJECT_CWD="$(cd "$JARVIS_PI_PROJECT" && pwd)"
else
  PROJECT_CWD="$(pwd)"
fi

if [[ ! -d "$PROJECT_CWD" ]]; then
  echo "Not a directory: $PROJECT_CWD" >&2
  exit 1
fi

if [[ "$(cd "$PROJECT_CWD" && pwd -P)" == "$(cd "$KIT_DIR" && pwd -P)" ]]; then
  echo "Refusing to bootstrap: PROJECT_CWD is the kit ($KIT_DIR), not your repo." >&2
  echo "Run: cd /path/to/monopd && jarvis" >&2
  exit 1
fi

if ! command -v herdr >/dev/null || ! command -v jq >/dev/null || ! command -v pi >/dev/null; then
  echo "Need herdr, jq, and pi on PATH." >&2
  exit 1
fi

SLUG="$(printf '%s' "$PROJECT_CWD" | shasum -a 256 | cut -c1-8)"
BASE="$(basename "$PROJECT_CWD")"
WORKSPACE_LABEL="${JARVIS_PI_LABEL:-jarvis:${BASE}-${SLUG}}"
ROOM="${JARVIS_PI_ROOM:-jarvis-pi-${SLUG}}"
export JARVIS_PI_ROOM="$ROOM"

find_workspace() {
  herdr workspace list 2>/dev/null \
    | jq -r --arg lbl "$WORKSPACE_LABEL" \
      '.result.workspaces[]? | select(.label == $lbl) | .workspace_id' \
    | head -1
}

EXISTING="$(find_workspace || true)"

if [[ -n "$EXISTING" && "$FORCE" -eq 0 ]]; then
  log "Workspace already exists for $PROJECT_CWD ($WORKSPACE_LABEL → $EXISTING)"
  herdr workspace focus "$EXISTING" 2>/dev/null || true
  cat <<EOF

Existing workspace focused (no new agents started).

Project:  $PROJECT_CWD
Room:     $ROOM
Kit:      $KIT_DIR/AGENTS.md

In EACH pi session (if not already connected):
  /room connect $ROOM
  /room whoami

In jarvis ONLY:
  /room control on

To spawn another workspace for the same repo: jarvis --force

EOF
  exit 0
fi

if [[ -n "$EXISTING" && "$FORCE" -eq 1 ]]; then
  WORKSPACE_LABEL="${WORKSPACE_LABEL}-$(date +%s)"
fi

echo "Creating Herdr workspace cwd=$PROJECT_CWD label=$WORKSPACE_LABEL room=$ROOM"
created=$(herdr workspace create \
  --cwd "$PROJECT_CWD" \
  --label "$WORKSPACE_LABEL" \
  --env "JARVIS_PI_PROJECT=${PROJECT_CWD}" \
  --env "JARVIS_PI_KIT=${KIT_DIR}" \
  --no-focus)
MASTER=$(echo "$created" | jq -r '.result.root_pane.pane_id')
WS_ID=$(echo "$created" | jq -r '.result.workspace.workspace_id')

DEV=$(herdr pane split "$MASTER" --direction right --no-focus | jq -r '.result.pane.pane_id')
REV=$(herdr pane split "$DEV" --direction down --no-focus | jq -r '.result.pane.pane_id')
ANA=$(herdr pane split "$MASTER" --direction down --no-focus | jq -r '.result.pane.pane_id')

PANES=("$MASTER" "$DEV" "$REV" "$ANA")

pi_common=(--provider mlplatform)
PROJECT_PROMPT="PROJECT_ROOT=${PROJECT_CWD}. You work in PROJECT_ROOT (the user's repo). The orchestration kit at ${KIT_DIR} is not the code repository."

prepare_all_panes() {
  local p
  log "All panes → cd $PROJECT_CWD"
  for p in "${PANES[@]}"; do
    herdr pane run "$p" cd "$PROJECT_CWD"
  done
  # New splits need a moment before shell accepts agent start
  sleep 1
  for p in "${PANES[@]}"; do
    herdr pane wait-output "$p" --timeout 8000 --regex '[%#>$] ' 2>/dev/null || sleep 0.5
  done
}

start_pi() {
  local name=$1 pane=$2 model=$3 thinking=$4
  herdr agent start "$name" --kind pi --pane "$pane" -- \
    --name "$name" \
    "${pi_common[@]}" \
    --model "$model" \
    --thinking "$thinking" \
    --append-system-prompt "$PROJECT_PROMPT" \
    "@${KIT_DIR}/AGENTS.md"
}

prepare_all_panes

echo "Starting pi agents..."
start_pi jarvis    "$MASTER" 'openai/gpt-5.6-sol'            low
start_pi developer "$DEV"    'deepseek/deepseek-v4.1-flash'  high
start_pi reviewer  "$REV"    'qwen3.8-125b'                  low
start_pi analyst   "$ANA"    'openai/gpt-5.6-luna'           medium

herdr workspace focus "$WS_ID" 2>/dev/null || true

mkdir -p "${HOME}/.config/jarvis-pi"
# shellcheck disable=SC2016
jq -n \
  --arg path "$PROJECT_CWD" \
  --arg ws "$WS_ID" \
  --arg lbl "$WORKSPACE_LABEL" \
  --arg room "$ROOM" \
  --arg at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{project_path:$path, workspace_id:$ws, label:$lbl, room:$room, updated_at:$at}' \
  >"${HOME}/.config/jarvis-pi/last.json"

cat <<EOF

Bootstrap done.

Project:  $PROJECT_CWD
Workspace: $WS_ID ($WORKSPACE_LABEL)
Room:     $ROOM
Panes:
  jarvis    $MASTER
  developer $DEV
  reviewer  $REV
  analyst   $ANA

In EACH pi session run:
  /room connect $ROOM
  /room whoami

In jarvis ONLY:
  /room control on

Orchestration rules: $KIT_DIR/AGENTS.md

EOF
