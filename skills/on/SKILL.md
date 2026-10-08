---
name: on
description: เปิดโหมด Foreman ในโปรเจกต์นี้ — ใช้เมื่อผู้ใช้พิมพ์ /model-foreman:on เท่านั้น
disable-model-invocation: true
allowed-tools: Read, Write, Edit
---

เปิดโหมด Foreman ให้โปรเจกต์ปัจจุบัน

1. เปิดไฟล์ `.claude/settings.local.json` ที่ root ของโปรเจกต์ ถ้ายังไม่มีให้สร้างใหม่พร้อมเนื้อหา `{}`
2. ตั้งค่า `"outputStyle": "model-foreman:Foreman"` โดยเก็บ key อื่นในไฟล์ไว้ครบ ห้ามเขียนทับทั้งไฟล์
3. ถ้าค่า `outputStyle` เดิมเป็น style อื่นที่ไม่ใช่ `default` ให้บอกผู้ใช้ว่าแทนที่ style ไหนไป
4. ตอบผู้ใช้สั้น ๆ ว่า
   - เปิดโหมด Foreman แล้ว มีผลตั้งแต่ข้อความถัดไป และค้างไว้ในโปรเจกต์นี้จนกว่าจะพิมพ์ `/model-foreman:off`
   - ถ้ายังไม่ได้ใช้ Opus ให้พิมพ์ `/model opus`
   - ต่อจากนี้สั่งงานเป็นประโยคธรรมดาได้เลย
