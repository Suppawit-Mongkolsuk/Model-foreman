#!/usr/bin/env bash
# model-foreman: เก็บสิ่งที่แต่ละ task เปลี่ยนเป็นไฟล์ .patch โดยไม่แตะ git (ไม่ commit, ไม่ stash, ไม่ add)
# รันจาก root ของโปรเจกต์ ใช้ได้กับ bash 3.2 (macOS)
#
#   foreman-patch.sh snap <run> <task> <file>...   ก่อนแก้: จำสภาพไฟล์ไว้ (รอบ FIX ใช้ของเดิม ไม่ถ่ายใหม่)
#   foreman-patch.sh diff <run> <task> <file>...   หลังแก้: เขียน .claude/foreman/patches/<run>-<task>.patch
#   foreman-patch.sh all  <run>                    ตอนจบ: diff ทั้งงานเทียบกับสภาพก่อนเริ่ม run
set -u

ROOT=".claude/foreman"
cmd="${1:-}"; run="${2:-}"
[ -n "$cmd" ] && [ -n "$run" ] || { echo "usage: $0 snap|diff <run> <task> <file>... | all <run>" >&2; exit 2; }
case "$run" in */*|*..*) echo "run id ห้ามมี / หรือ .." >&2; exit 2;; esac

BASE="$ROOT/snap/$run/_base"
mkdir -p "$ROOT/patches" "$BASE"

safe_path() {
  case "$1" in /*|*..*) echo "ข้าม $1: ต้องเป็น path ในโปรเจกต์ (relative, ไม่มี ..)" >&2; return 1;; esac
  return 0
}

# จำไฟล์ลง dir: มีไฟล์ = copy, ยังไม่มี = จดว่าเป็นไฟล์ใหม่
remember() {
  local dir="$1" f="$2"
  if [ -e "$dir/$f" ] || grep -qxF -- "$f" "$dir/.new-files" 2>/dev/null; then return 0; fi
  if [ -f "$f" ]; then
    mkdir -p "$dir/$(dirname "$f")" && cp -p "$f" "$dir/$f"
  else
    echo "$f" >> "$dir/.new-files"
  fi
}

# diff หนึ่งไฟล์เทียบกับที่จำไว้ใน dir
diff_one() {
  local dir="$1" f="$2"
  if [ -f "$dir/$f" ]; then
    if [ -f "$f" ]; then diff -u --label "a/$f" --label "b/$f" "$dir/$f" "$f"
    else diff -u --label "a/$f" --label /dev/null "$dir/$f" /dev/null; fi
  elif [ -f "$f" ]; then
    diff -u --label /dev/null --label "b/$f" /dev/null "$f"
  fi
  return 0
}

summary() {
  local out="$1" files add del
  files=$(grep -c '^+++ ' "$out" 2>/dev/null || true)
  add=$(grep -c '^+[^+]' "$out" 2>/dev/null || true)
  del=$(grep -c '^-[^-]' "$out" 2>/dev/null || true)
  echo "patch: $out ($files ไฟล์, +$add -$del)"
}

case "$cmd" in
  snap)
    task="${3:-}"; [ -n "$task" ] || { echo "ต้องระบุ task" >&2; exit 2; }
    shift 3
    dir="$ROOT/snap/$run/$task"
    if [ -d "$dir" ]; then echo "มี snapshot ของ $task อยู่แล้ว ใช้ของเดิม"; exit 0; fi
    mkdir -p "$dir"
    for f in "$@"; do
      safe_path "$f" || continue
      remember "$dir" "$f"
      remember "$BASE" "$f"
      printf '%s\n' "$f" >> "$dir/.files"
    done
    echo "snapshot: $dir ($# ไฟล์)"
    ;;
  diff)
    task="${3:-}"; [ -n "$task" ] || { echo "ต้องระบุ task" >&2; exit 2; }
    shift 3
    dir="$ROOT/snap/$run/$task"
    [ -d "$dir" ] || { echo "ยังไม่มี snapshot ของ $task ให้รัน snap ก่อนแก้ไฟล์" >&2; exit 1; }
    out="$ROOT/patches/$run-$task.patch"
    : > "$out"
    for f in "$@"; do
      safe_path "$f" || continue
      if [ ! -e "$dir/$f" ] && ! grep -qxF -- "$f" "$dir/.new-files" 2>/dev/null; then
        echo "คำเตือน: $f ไม่ได้อยู่ใน snapshot (ไม่ได้อยู่ใน brief?) diff เทียบกับไฟล์ว่าง" >&2
      fi
      diff_one "$dir" "$f" >> "$out"
    done
    summary "$out"
    ;;
  all)
    out="$ROOT/patches/$run-ALL.patch"
    : > "$out"
    list=$( { find "$BASE" -type f ! -name '.*' | sed "s#^$BASE/##"; cat "$BASE/.new-files" 2>/dev/null; } | sort -u )
    if [ -n "$list" ]; then
      echo "$list" | while IFS= read -r f; do diff_one "$BASE" "$f" >> "$out"; done
    fi
    summary "$out"
    ;;
  *) echo "คำสั่งไม่รู้จัก: $cmd" >&2; exit 2;;
esac
