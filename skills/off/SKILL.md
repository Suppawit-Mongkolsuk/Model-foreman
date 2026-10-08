---
name: off
description: ปิดโหมด Foreman ในโปรเจกต์นี้ — ใช้เมื่อผู้ใช้พิมพ์ /model-foreman:off เท่านั้น
disable-model-invocation: true
allowed-tools: Read, Edit
---

ปิดโหมด Foreman ของโปรเจกต์ปัจจุบัน

1. เปิดไฟล์ `.claude/settings.local.json` ที่ root ของโปรเจกต์
2. ถ้า `outputStyle` เป็น `model-foreman:Foreman` ให้ลบ key นั้นออก โดยเก็บ key อื่นไว้ครบ
3. ถ้าไม่มีไฟล์ ไม่มี key นี้ หรือเป็น style อื่น ไม่ต้องแก้อะไร แล้วบอกผู้ใช้ตามจริง
   ถ้าเจอ `"outputStyle": "model-foreman:Foreman"` ใน `~/.claude/settings.json` ให้บอกผู้ใช้ว่าโหมดถูกเปิดไว้ทุกโปรเจกต์จากไฟล์นั้น และถามก่อนแก้
4. ตอบผู้ใช้สั้น ๆ ว่าปิดโหมดแล้ว มีผลตั้งแต่ข้อความถัดไป และยังสั่งงานแบบครั้งเดียวได้ด้วย `/model-foreman:start <งาน>`
