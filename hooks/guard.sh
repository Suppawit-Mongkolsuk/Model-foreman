#!/usr/bin/env bash
# model-foreman guard
# ถ้าคำสั่งเข้าข่ายอันตราย ให้ Claude Code ถามผู้ใช้ก่อนเสมอ แม้จะมี allow rule
# ปิดได้ด้วย env MODEL_FOREMAN_GUARD=off

[ "${MODEL_FOREMAN_GUARD:-on}" = "off" ] && exit 0

input=$(cat)

field() {
  printf '%s' "$input" | grep -oE "\"$1\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" | head -1 \
    | sed -E "s/^\"$1\"[[:space:]]*:[[:space:]]*\"//; s/\"$//"
}

tool=$(field tool_name)
reason=""

check() {
  # $1 = ข้อความที่จะตรวจ, $2 = regex, $3 = เหตุผล
  if [ -z "$reason" ] && printf '%s' "$1" | grep -qiE "$2"; then
    reason="$3"
  fi
}

if [ "$tool" = "Bash" ]; then
  cmd=$(field command)
  check "$cmd" '(^|[;&|[:space:]])rm[[:space:]]+(-[a-zA-Z]*[rRf]|--recursive|--force)' 'ลบไฟล์แบบ recursive หรือ force'
  check "$cmd" '(^|[;&|[:space:]])sudo[[:space:]]' 'รันด้วยสิทธิ์ root (sudo)'
  check "$cmd" 'git[[:space:]]+push' 'push โค้ดขึ้น remote'
  check "$cmd" 'git[[:space:]]+reset[[:space:]]+[^;&|]*--hard' 'git reset --hard ทิ้งงานที่ยังไม่ commit'
  check "$cmd" 'git[[:space:]]+clean[[:space:]]+[^;&|]*-[a-zA-Z]*f' 'git clean ลบไฟล์ที่ไม่ได้ track'
  check "$cmd" 'git[[:space:]]+branch[[:space:]]+[^;&|]*-D' 'ลบ branch แบบ force'
  check "$cmd" 'git[[:space:]]+(checkout|restore)[[:space:]]+[^;&|]*(--[[:space:]]+)?\.([[:space:]]|$)' 'ทิ้งการแก้ไขทั้งโฟลเดอร์'
  check "$cmd" '(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba|z)?sh' 'ดาวน์โหลดสคริปต์แล้วรันทันที'
  check "$cmd" '(drop[[:space:]]+(table|database|schema)|truncate[[:space:]]+table|delete[[:space:]]+from)' 'คำสั่ง SQL ที่ลบข้อมูล'
  check "$cmd" '(migrate|db[[:space:]]+push|alembic[[:space:]]+(upgrade|downgrade))' 'migration ฐานข้อมูล'
  check "$cmd" '(terraform[[:space:]]+(apply|destroy)|kubectl[[:space:]]+(apply|delete)|vercel[[:space:]]+[^;&|]*--prod|(^|[[:space:]])deploy([[:space:]]|$))' 'deploy หรือแก้ infrastructure'
  check "$cmd" '(npm|pnpm|yarn)[[:space:]]+publish' 'publish package'
  check "$cmd" '(chmod|chown)[[:space:]]+[^;&|]*-R' 'เปลี่ยนสิทธิ์ไฟล์แบบ recursive'
  check "$cmd" '(^|[;&|[:space:]])(mkfs|dd[[:space:]]+if=)' 'เขียนทับดิสก์'
  check "$cmd" 'docker[[:space:]]+(system|volume|image)[[:space:]]+prune' 'ลบ docker resources'
elif [ "$tool" = "Edit" ] || [ "$tool" = "Write" ]; then
  path=$(field file_path)
  check "$path" '(^|/)\.env(\.|$)' 'แก้ไฟล์ .env ที่อาจมี secret'
  check "$path" '(^|/)\.git/' 'แก้ไฟล์ภายใน .git'
  check "$path" '\.(pem|key)$|(^|/)id_(rsa|ed25519)' 'แก้ไฟล์ key หรือ certificate'
fi

[ -z "$reason" ] && exit 0

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"model-foreman guard: %s — ต้องยืนยันก่อนทำ"}}\n' "$reason"
exit 0
