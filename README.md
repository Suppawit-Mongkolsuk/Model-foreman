# model-foreman

skill สำหรับ Claude Code ที่ทำหน้าที่เป็น "ผู้จัดการงาน"
คุยเคลียร์ requirement กับคุณจนได้ spec แล้วแตกงานส่งให้ Haiku, Sonnet หรือ Opus ตามความยากของแต่ละ task
มีตัวรีวิวแยก และยกระดับโมเดลเองเมื่องานไม่ผ่าน เพื่อลดค่าใช้จ่ายโดยไม่เสียคุณภาพ

## ทำงานอย่างไร

```
คุณให้โจทย์
   ↓
Opus เคลียร์โจทย์ ถามกลับจนได้ spec  ← หยุดรอคุณยืนยัน
   ↓
แตก task → ให้คะแนนความยาก → เลือกโมเดล → ผูก skill ที่เกี่ยวข้อง
   ↓
worker ทำงาน (Haiku / Sonnet / Opus) และรัน test
   ↓
QA (Sonnet) ลองใช้งานจริง กรณีขอบ และโจมตีแบบง่าย  ← เฉพาะงานที่ผู้ใช้ใช้โดยตรงหรือแตะความปลอดภัย
   ↓
reviewer (context ใหม่) ตรวจกับ spec, skill และรายงาน QA
   ระดับตามความเสี่ยง: Haiku เช็กเร็ว / Sonnet / Opus ไม่มั่นใจ → ESCALATE_REVIEW ส่งต่อระดับถัดไป
   ↓
PASS → สรุปให้คุณ
FIX → แก้ที่โมเดลเดิม 1 ครั้ง
ESCALATE → ส่งให้โมเดลที่เก่งขึ้น
BLOCKED → หยุดถามคุณ
```

- เลือกโมเดลจากความยากของ task ไม่ใช่จากบทบาท Opus ก็เขียนโค้ดเองได้ถ้างานยาก
- คนเขียนกับคนรีวิวไม่ใช่ context เดียวกัน
- reviewer อ่านโค้ดว่าถูกตาม spec ไหม ส่วน QA ลองใช้จริงว่าพังไหม สองอย่างนี้จับบั๊กคนละแบบ
- งานที่แตะ auth, crypto, สิทธิ์ หรือ input จากผู้ใช้ จะไปที่ Opus เสมอ ทั้งตอนทำและตอนรีวิว
- brief ถูกเขียนให้โมเดลเล็กทำได้ทันที และเรียงส่วนที่เหมือนกันไว้ก่อนเพื่อใช้ cache

## สิ่งที่ต้องมี

- Claude Code
- สิทธิ์ใช้ Opus, Sonnet และ Haiku ในแพลนหรือ API key ของคุณ
- แนะนำให้มี test ในโปรเจกต์ ยิ่งครอบคลุม ยิ่งส่งงานให้โมเดลเล็กได้มากและปลอดภัย

## ติดตั้ง

พิมพ์สองคำสั่งนี้ใน Claude Code

```
/plugin marketplace add Suppawit-Mongkolsuk/Model-foreman
/plugin install model-foreman@model-foreman
```

จากนั้นรัน `/reload-plugins` หรือเปิด Claude Code ใหม่

### อัปเดตเป็นเวอร์ชันล่าสุด

```
/plugin marketplace update model-foreman
```

### ถอนการติดตั้ง

```
/plugin uninstall model-foreman@model-foreman
```

## ตั้งค่าก่อนใช้

1. **รัน session หลักด้วย Opus** — skill เปลี่ยนโมเดลของ session หลักเองไม่ได้ ใช้ `/model opus` ก่อนเริ่ม และแนะนำ `/effort high` (หรือ `xhigh` ถ้างานซับซ้อน) ไม่ต้องกลัวว่า agent จะได้ effort สูงตาม เพราะ skill ส่ง effort ให้แต่ละ agent เองตามความยากของ task (ข้อยกเว้น: ถ้าตั้ง environment variable `CLAUDE_CODE_EFFORT_LEVEL` ไว้ ค่านั้นจะทับทุกตัว รวมถึง agent ด้วย)
2. **ให้สิทธิ์แก้ไฟล์และรัน test โดยไม่ต้องถาม** — ไม่อย่างนั้นระบบจะหยุดรอคุณทุกขั้น ตั้งได้ใน settings ของโปรเจกต์ จำกัดเฉพาะคำสั่งที่จำเป็น เช่นคำสั่ง test ของคุณ

## วิธีใช้

### แบบโหมด (แนะนำ)

เปิดโหมด Foreman ครั้งเดียว แล้วสั่งงานเป็นประโยคธรรมดาได้เลย ไม่ต้องพิมพ์คำสั่งนำหน้า

```
/model-foreman:on
```

ครั้งแรก Claude Code จะขออนุญาตแก้ไฟล์ `.claude/settings.local.json` ให้กดอนุญาต
โหมดนี้ค้างไว้ในโปรเจกต์นั้นจนกว่าจะปิด เปิด Claude Code ใหม่ก็ยังอยู่

```
เพิ่มหน้า login ที่รองรับ 2FA และแก้ปุ่มในหน้า settings ให้ตรงดีไซน์ใหม่
```

คำถามทั่วไป การอ่านโค้ด หรืองานแก้เล็กมาก ๆ จะตอบหรือทำทันทีโดยไม่ผ่าน flow

ปิดโหมด

```
/model-foreman:off
```

ถ้าอยากเปิดโหมดนี้ทุกโปรเจกต์ ใส่ `"outputStyle": "model-foreman:Foreman"` ใน `~/.claude/settings.json`

### แบบสั่งทีละครั้ง

ถ้าไม่ได้เปิดโหมด ใช้คำสั่งนี้นำหน้างาน

```
/model-foreman:start เพิ่มหน้า login ที่รองรับ 2FA
```

ทั้งสองแบบ ระบบจะถามกลับจนได้ spec แล้วรอให้คุณยืนยันก่อนเริ่มทำงาน

## ระบบจะหยุดถามคุณเมื่อ

- ต้องยืนยัน spec
- จะทำสิ่งที่ย้อนกลับไม่ได้: ลบไฟล์, migration, เปลี่ยน schema, push, deploy
- reviewer ตัดสินว่า BLOCKED (spec กำกวม)
- รีวิวครบ 5 ครั้งแล้วยังไม่ผ่าน หรือ Opus ก็ยังไม่ผ่าน
- task มากกว่าครึ่งถูกยกระดับ (มักแปลว่า spec หรือ rubric มีปัญหา)

## ความปลอดภัย: คำสั่งที่ต้องขออนุญาตเสมอ

plugin มี guard hook ที่บังคับให้ Claude Code ถามคุณก่อนทุกครั้ง **แม้คำสั่งนั้นจะอยู่ใน allow list** และมีผลกับ worker ทุกตัวด้วย

| ประเภท | ตัวอย่าง |
|---|---|
| ลบไฟล์ | `rm -rf`, `git clean -f`, `git checkout -- .` |
| ทิ้งงาน / แก้ประวัติ | `git reset --hard`, `git branch -D`, `git stash` |
| สร้าง commit | `git commit` (งานเก็บเป็น patch ให้คุณ commit เอง) |
| ส่งออกนอกเครื่อง | `git push`, `npm publish`, deploy, `terraform apply`, `kubectl apply/delete` |
| ฐานข้อมูล | `DROP TABLE`, `TRUNCATE`, `DELETE FROM`, migration |
| สิทธิ์ระบบ | `sudo`, `chmod -R`, `chown -R` |
| สคริปต์จากเน็ต | `curl ... \| bash` |
| ไฟล์ลับ | แก้ `.env`, ไฟล์ใน `.git/`, ไฟล์ `.pem` `.key` |

คำสั่งทั่วไป เช่น `npm test` หรือ `rm` ไฟล์เดียว ยังรันตาม allow list ได้ปกติ

### เพิ่มคำสั่งที่ต้องถามเอง

ใส่กฎ `ask` ใน `.claude/settings.json` ของโปรเจกต์ กฎ `ask` ชนะ `allow` เสมอ

```json
{
  "permissions": {
    "allow": ["Edit", "Write", "Bash(npm test)"],
    "ask": ["Bash(docker compose down *)", "Bash(./scripts/reset-db.sh)"]
  }
}
```

ถ้าอยากห้ามเด็ดขาด ไม่ให้แม้แต่ถาม ให้ใส่ใน `"deny"` แทน

### ปิด guard

guard ทำงานทุกเซสชันที่เปิด plugin ไว้ ไม่ว่าจะเปิดโหมด Foreman หรือไม่ ถ้าอยากปิด ให้ตั้ง environment variable `MODEL_FOREMAN_GUARD=off` ก่อนเปิด Claude Code

### ข้อจำกัดของ guard

guard ดูจากข้อความของคำสั่ง จึงจับรูปแบบที่ใช้กันทั่วไปได้ แต่ไม่ใช่กำแพงกันได้ทุกทาง เช่น ถ้าคำสั่งอันตรายถูกซ่อนไว้ในสคริปต์อื่นแล้วเรียกสคริปต์นั้น guard จะมองไม่เห็น ถ้างานสำคัญมาก ให้รันใน container หรือ VM ด้วย

## ปรับแต่ง

- **เกณฑ์ความยาก** — fork repo นี้แล้วแก้ `skills/start/rubric.md` ช่วงคะแนนที่ให้มาเป็นจุดเริ่มต้น ไม่ใช่ค่าที่พิสูจน์แล้ว
- **ดูผลการตัดสินใจ** — ทุก task ถูกบันทึกลง `.claude/router-log.md` ในโปรเจกต์ ถ้าคะแนนช่วงไหนโดนตีกลับบ่อย ให้ขยับเส้นแบ่งใน rubric
- **skill ของคุณเอง** — ระบบจะผูก skill ที่เกี่ยวข้อง (เช่น skill ด้าน UI) ไว้ใน brief ให้ worker และ reviewer โหลดใช้ ตั้ง description ของ skill ให้ชัดเพื่อให้ถูกเลือก

## ข้อจำกัด

- การประเมินความยากเป็นการตัดสินของโมเดลตามเกณฑ์ ไม่ใช่การวัด อาจพลาดได้
- ค่าใช้จ่ายในสรุปเป็นค่าประมาณ ดูยอดจริงด้วย `/cost`
- รายละเอียดของ Claude Code (การส่ง model ให้ agent, การโหลด skill ใน subagent) อาจต่างกันตามเวอร์ชัน ตรวจกับเอกสารของ Claude Code อีกครั้งถ้าทำงานไม่ตรงที่คาด

## โครงสร้าง

```
.claude-plugin/
├─ plugin.json        ข้อมูล plugin
└─ marketplace.json   ทำให้ repo นี้ติดตั้งผ่าน /plugin ได้
skills/
├─ start/
│  ├─ SKILL.md        ขั้นตอนทั้งหมด
│  └─ rubric.md       เกณฑ์ให้คะแนนและกฎบังคับ
├─ on/SKILL.md        เปิดโหมด Foreman
└─ off/SKILL.md       ปิดโหมด Foreman
scripts/
└─ foreman-patch.sh   เก็บสิ่งที่แต่ละ task เปลี่ยนเป็น .patch โดยไม่แตะ git
agents/
├─ worker.md          ตัวทำงาน
├─ investigator.md    ตัวหาต้นเหตุบั๊ก อ่านอย่างเดียว (Sonnet / Opus)
├─ qa.md              ตัวทดสอบการใช้งานจริง (Sonnet)
└─ reviewer.md        ตัวรีวิว (Haiku / Sonnet / Opus ตามความเสี่ยง)
output-styles/
└─ foreman.md         โหมด Foreman
hooks/
├─ hooks.json         ลงทะเบียน guard
└─ guard.sh           ตรวจคำสั่งอันตราย
```

## ประวัติการแก้

**0.7.0**
- งานแก้บั๊กที่ยังไม่รู้ต้นเหตุ แตกเป็น D-task (หาสาเหตุ) ก่อน task แก้ ด้วย agent ใหม่ `investigator` ที่อ่านอย่างเดียว
- ผลของ D-task กลายเป็น brief ของ task แก้: ไฟล์ที่ต้องแก้, จุดต้นเหตุ, test ที่ต้องเขียน (TDD)
- ต้นเหตุอยู่นอกขอบเขตที่ตกลงไว้ → หยุดถามผู้ใช้ก่อนเขียน task แก้
- ใช้คู่กับ foreman-hud 0.7.0 ขึ้นไป

**0.6.0**
- ไม่มี agent ตัวไหน commit: แต่ละ task เก็บสิ่งที่เปลี่ยนเป็น `.claude/foreman/patches/<run>-<task>.patch` ด้วย `scripts/foreman-patch.sh` และ guard ถามก่อน `git commit` / `git stash` ทุกครั้ง
- reviewer อ่านจาก patch แทนการอ่านทั้งไฟล์
- รีวิวรวมทั้งงานด้วย Opus ครั้งเดียวตอนจบ (`TASK: FINAL`) จับปัญหาข้าม task
- task ที่แก้ไฟล์ซ้อนกันนับว่าขึ้นต่อกัน ทำทีละตัว (foreman-hud 0.6.0 ปฏิเสธถ้าซ้อนกับ worker ที่ยังทำอยู่)
- บันทึกแผนลง `.claude/foreman/plan-<run>.md` ทำ run เดิมต่อข้าม session ได้
- จบงานด้วยรายการไฟล์ ร่างข้อความ commit และคำสั่งย้อนทั้งงาน
- ใช้คู่กับ foreman-hud 0.6.0 ขึ้นไป

**0.5.0**
- รายงานของ worker ใช้สถานะ `DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED / DISPUTE` และผล test แบบมีค่าตายตัวพร้อม output จริง
- worker ถามก่อนเริ่มได้ (`NEEDS_CONTEXT`), self-review ก่อนส่ง, แย้ง feedback ที่ผิดได้ (`DISPUTE`), ทำ TDD เมื่อ brief สั่ง, รัน test เฉพาะส่วนของตัวเอง
- QA ให้ระดับปัญหา `สูง / กลาง / ต่ำ`, ใช้ `visual-check` กับงาน UI และตอบ `ทดสอบไม่ได้` แทนการอ่านโค้ด
- QA เจอปัญหาระดับกลางขึ้นไป → แก้ → QA ซ้ำ → แล้วค่อยรีวิว
- ช่อง `ระดับรีวิว` ใน brief เป็นทั้งขั้นต่ำและเพดาน, Opus รีวิวเพราะ QA เฉพาะปัญหาระดับกลางขึ้นไป
- กฎ Opus เสมอ แคบลงเหลือ auth, crypto, สิทธิ์ และจุดที่ข้อมูลข้ามเข้าระบบฝั่ง server (ฟอร์มฝั่ง frontend ใช้คะแนนปกติ)
- brief มี run id, `TDD`, `อ่านเพิ่มได้ไม่เกิน` และ `QA เข้าระบบ` (อ่านจาก `.claude/foreman/qa-env.md`)
- ตารางผูก skill ตามประเภทงาน และส่วน Red flags สำหรับผู้จัดการ
- ใช้คู่กับ foreman-hud 0.5.0 ขึ้นไป
