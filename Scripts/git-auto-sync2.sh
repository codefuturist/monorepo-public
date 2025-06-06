#!/usr/bin/env zsh
# Force-sync a local Git repo to a remote branch, discarding ALL local edits.
# ──────────────────────────────────────────────────────────────────────────────
# Usage examples
#   git-auto-sync.sh -d /srv/my-app                    # use defaults
#   git-auto-sync.sh -d /srv/my-app -b production      # pick a branch
#   git-auto-sync.sh -d /opt/site -r upstream -l /tmp/sync.log
#   git-auto-sync.sh --help                            # show help
#
# Exit codes: 0=OK, 1=arg error, 2=repo problem, 3=git failure

# set -euo pipefail

# ── Colours (fallback to plain if no TTY) ─────────────────────────────────────
tty -s && { BLD=$'\e[1m'; GRN=$'\e[32m'; RED=$'\e[31m'; YEL=$'\e[33m'; CLR=$'\e[0m'; } || { BLD= GRN= RED= YEL= CLR=; }

# ── Defaults ──────────────────────────────────────────────────────────────────
#REPO_DIR=""
#REMOTE="origin"
#BRANCH="main"
#LOG_FILE="/var/log/git-auto-sync.log"
LOG_DIR="${5:-${GIT_AUTO_SYNC_LOG_DIR:-"/var/log"}}"
REPO_DIR="${1:-${GIT_AUTO_SYNC_REPO_DIR:-"/home/colin/scripts"}}"
REMOTE="${2:-${GIT_AUTO_SYNC_REMOTE:-origin}}"
BRANCH="${3:-${GIT_AUTO_SYNC_BRANCH:-main}}"
LOG_FILE="${4:-${GIT_AUTO_SYNC_LOG_FILE:-"$LOG_DIR/git-auto-sync.log"}}"

usage() {
  cat <<EOF
${BLD}git-auto-sync.sh${CLR} – force-pull a repository, nuking local changes.

Options:
  -d DIR   Repository directory (required)
  -r NAME  Remote name       [default: origin]
  -b NAME  Branch to track   [default: main]
  -l FILE  Log file path     [default: /var/log/git-auto-sync.log]
  -q       Quiet; no stdout (errors still print)
  -h       Show this help

Every run performs:
  git fetch           (remote updates)
  git reset --hard    (set local branch to remote/branch)
  git clean -fd       (delete untracked files & dirs)
EOF
}

# ── Parse arguments ───────────────────────────────────────────────────────────
QUIET=false
while getopts ":d:r:b:l:qh-:" opt; do
  case "$opt" in
    d) REPO_DIR=$OPTARG ;;
    r) REMOTE=$OPTARG   ;;
    b) BRANCH=$OPTARG   ;;
    l) LOG_FILE=$OPTARG ;;
    q) QUIET=true       ;;
    h|-|-) usage; exit 0;;
    \?) echo "${RED}Error:${CLR} Unknown option -$OPTARG" >&2; usage; exit 1;;
    :)  echo "${RED}Error:${CLR} Option -$OPTARG requires an argument" >&2; usage; exit 1;;
  esac
done

[[ -z $REPO_DIR ]] && { echo "${RED}Error:${CLR} -d DIR is required." >&2; usage; exit 1; }

# ── Sanity checks ─────────────────────────────────────────────────────────────
if [[ ! -d $REPO_DIR/.git ]]; then
  echo "${RED}Error:${CLR} '$REPO_DIR' is not a Git repository." >&2
  exit 2
fi

# ── Sync operation ────────────────────────────────────────────────────────────
run() {
  cd "$REPO_DIR"
  git checkout -qf "$BRANCH"
  git fetch --quiet "$REMOTE"
  git reset --hard "$REMOTE/$BRANCH"
  git clean -fdq
}

# TIMESTAMP=$(date --iso-seconds)
TIMESTAMP=$(date +"%d.%m.%y %H:%M:%S")
if $QUIET; then
  run || { echo "[$TIMESTAMP] FAILED sync $REPO_DIR" >>"$LOG_FILE"; exit 3; }
else
  echo "${GRN}[$TIMESTAMP] syncing '$REPO_DIR' from $REMOTE/$BRANCH…${CLR}"
  run && echo "${GRN}done.${CLR}" || { echo "${RED}FAILED.${CLR}"; exit 3; }
fi

echo "[$TIMESTAMP] synced $REPO_DIR to $REMOTE/$BRANCH" >>"$LOG_FILE"
