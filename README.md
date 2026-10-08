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
reviewer (Opus, context ใหม่) ตรวจกับ spec และ skill
   ↓
PASS → สรุปให้คุณ
FIX → แก้ที่โมเดลเดิม 1 ครั้ง
ESCALATE → ส่งให้โมเดลที่เก่งขึ้น
BLOCKED → หยุดถามคุณ
```

- เลือกโมเดลจากความยากของ task ไม่ใช่จากบทบาท Opus ก็เขียนโค้ดเองได้ถ้างานยาก
- คนเขียนกับคนรีวิวไม่ใช่ context เดียวกัน
- งานที่แตะ auth, crypto, สิทธิ์ หรือ input จากผู้ใช้ จะไปที่ Opus เสมอ

## สิ่งที่ต้องมี

- Claude Code
- สิทธิ์ใช้ Opus, Sonnet และ Haiku ในแพลนหรือ API key ของคุณ
- แนะนำให้มี test ในโปรเจกต์ ยิ่งครอบคลุม ยิ่งส่งงานให้โมเดลเล็กได้มากและปลอดภัย

## ติดตั้ง

### แบบใช้เฉพาะโปรเจกต์

```bash
git clone https://github.com/Suppawit-Mongkolsuk/Model-foreman.git model-foreman
cp -r model-foreman/.claude/skills/model-foreman  <your-project>/.claude/skills/
cp model-foreman/.claude/agents/worker.md model-foreman/.claude/agents/reviewer.md  <your-project>/.claude/agents/
```

### แบบใช้ทุกโปรเจกต์ในเครื่อง

```bash
git clone https://github.com/Suppawit-Mongkolsuk/Model-foreman.git model-foreman
mkdir -p ~/.claude/skills ~/.claude/agents
cp -r model-foreman/.claude/skills/model-foreman  ~/.claude/skills/
cp model-foreman/.claude/agents/worker.md model-foreman/.claude/agents/reviewer.md  ~/.claude/agents/
```

เปิด Claude Code ใหม่หลังติดตั้ง แล้วตรวจว่า skill และ agent ขึ้นในรายชื่อ

## ตั้งค่าก่อนใช้

1. **รัน session หลักด้วย Opus** — skill เปลี่ยนโมเดลของ session หลักเองไม่ได้ ใช้ `/model opus` ก่อนเริ่ม
2. **ให้สิทธิ์แก้ไฟล์และรัน test โดยไม่ต้องถาม** — ไม่อย่างนั้นระบบจะหยุดรอคุณทุกขั้น ตั้งได้ใน settings ของโปรเจกต์ จำกัดเฉพาะคำสั่งที่จำเป็น เช่นคำสั่ง test ของคุณ
3. **ถ้า Claude Code ของคุณส่ง model ตอนเรียก agent ไม่ได้** — คัดลอก `worker.md` เป็น `worker-haiku.md`, `worker-sonnet.md`, `worker-opus.md` แล้วเพิ่ม `model: haiku` / `sonnet` / `opus` ในส่วนหัวของแต่ละไฟล์ (เปลี่ยน `name:` ให้ตรงชื่อไฟล์ด้วย)

## วิธีใช้

พิมพ์ในเซสชันว่าให้ใช้ model-foreman แล้วตามด้วยโจทย์ เช่น

```
ใช้ model-foreman: เพิ่มหน้า login ที่รองรับ 2FA และแก้ปุ่มในหน้า settings ให้ตรงดีไซน์ใหม่
```

ระบบจะถามกลับจนได้ spec แล้วรอให้คุณยืนยันก่อนเริ่มทำงาน

## ระบบจะหยุดถามคุณเมื่อ

- ต้องยืนยัน spec
- จะทำสิ่งที่ย้อนกลับไม่ได้: ลบไฟล์, migration, เปลี่ยน schema, push, deploy
- reviewer ตัดสินว่า BLOCKED (spec กำกวม)
- รีวิวครบ 4 ครั้งแล้วยังไม่ผ่าน หรือ Opus ก็ยังไม่ผ่าน
- task มากกว่าครึ่งถูกยกระดับ (มักแปลว่า spec หรือ rubric มีปัญหา)

## ปรับแต่ง

- **เกณฑ์ความยาก** — แก้ใน `.claude/skills/model-foreman/rubric.md` ช่วงคะแนนที่ให้มาเป็นจุดเริ่มต้น ไม่ใช่ค่าที่พิสูจน์แล้ว
- **ดูผลการตัดสินใจ** — ทุก task ถูกบันทึกลง `.claude/router-log.md` ในโปรเจกต์ ถ้าคะแนนช่วงไหนโดนตีกลับบ่อย ให้ขยับเส้นแบ่งใน rubric
- **skill ของคุณเอง** — ระบบจะผูก skill ที่เกี่ยวข้อง (เช่น skill ด้าน UI) ไว้ใน brief ให้ worker และ reviewer โหลดใช้ ตั้ง description ของ skill ให้ชัดเพื่อให้ถูกเลือก

## ข้อจำกัด

- การประเมินความยากเป็นการตัดสินของโมเดลตามเกณฑ์ ไม่ใช่การวัด อาจพลาดได้
- ค่าใช้จ่ายในสรุปเป็นค่าประมาณ ดูยอดจริงด้วย `/cost`
- รายละเอียดของ Claude Code (การส่ง model ให้ agent, การโหลด skill ใน subagent) อาจต่างกันตามเวอร์ชัน ตรวจกับเอกสารของ Claude Code อีกครั้งถ้าทำงานไม่ตรงที่คาด

## โครงสร้าง

```
.claude/
├─ skills/model-foreman/
│  ├─ SKILL.md     ขั้นตอนทั้งหมด
│  └─ rubric.md    เกณฑ์ให้คะแนนและกฎบังคับ
└─ agents/
   ├─ worker.md    ตัวทำงาน
   └─ reviewer.md  ตัวรีวิว (Opus)
```
