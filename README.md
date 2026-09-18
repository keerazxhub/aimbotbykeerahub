# 🎯 KeeraHub — Mobile Aim Assist

> สคริปต์ **Aim Assist สำหรับมือถือ** ใน Roblox — เบา, ลื่น, ปรับได้จากในเกม
> ปุ่มใหญ่กดง่าย + เมนูตั้งค่าเล็ก ๆ ไม่บังจอ

![Platform](https://img.shields.io/badge/platform-Mobile-informational)
![Language](https://img.shields.io/badge/language-Lua-blue)
![Status](https://img.shields.io/badge/status-active-success)

---

## ✨ จุดเด่น

- 🔴 **FOV Circle** วงกลมกลางจอ ปรับขนาดได้แบบเรียลไทม์
- 🎯 **เลือกจุดล็อก** สลับ `Head` ↔ `Body` ได้ในคลิกเดียว
- 🌀 **Smoothness 2 ระดับ** `0.30` (เนียน) / `0.75` (ไว)
- 👆 **Smart Swipe** ตอนนิ้วแตะจออยู่ ความเนียนจะลดลงอัตโนมัติ (×0.4) → ลากนิ้วลื่นขึ้น
- 👥 **Team Filter** กันล็อกพวกเดียวกัน (เช็คทั้ง `Team` และ `TeamColor`)
- 🧱 **Wall Check** ยิง Raycast ดูว่าศัตรูโผล่ให้เห็นจริง ไม่ล็อกทะลุกำแพง
- 📱 **UI แบบ Touch-first** ปุ่ม Aim Assist ใหญ่ ๆ + ปุ่มเฟือง ⚙️ ซ่อน/โชว์เมนู

---

## 🧭 หน้าตา UI

```
[ Aim Assist: OFF ]  [ ⚙️ ]
                          └─ เมนูตั้งค่า
                             ├─ FOV: 35%      (- / +)
                             ├─ Smoothness    (0.30)
                             ├─ Part: Head    (Head / Body)
                             └─ Team Filter   (Check Team: ON)
```

| ปุ่ม | หน้าที่ |
|---|---|
| `Aim Assist: OFF/ON` | เปิด–ปิดระบบล็อกเป้า (ตอนเปิดขอบวง FOV เปลี่ยนเป็น **สีเขียว**) |
| `⚙️` | ซ่อน/โชว์เมนูตั้งค่า |
| `-` / `+` | ปรับ FOV ทีละ **5%** (ช่วง **10% – 100%**) |
| `Smooth: 0.30` | สลับค่า Smoothness วนไปมาระหว่าง 2 ระดับ |
| `Part: Head` | สลับเป้าหมายระหว่าง **หัว** (เทา) และ **ตัว** (ส้ม) |
| `Check Team: ON` | สลับเป็น `Lock Everyone` (แดง) ถ้าอยากล็อกทุกคน |

---

## ⚙️ ค่าตั้งต้นในสคริปต์

| Setting | ค่าเริ่มต้น | ความหมาย |
|---|---|---|
| `AimbotEnabled` | `false` | เริ่มต้นปิด ต้องกดเอง |
| `TeamCheck` | `true` | ไม่ล็อกเพื่อนร่วมทีม |
| `FOV_Scale` | `0.35` | รัศมี FOV = `min(กว้าง, สูง) × 0.35` |
| `Smoothness` | `0.30` | ยิ่งน้อยยิ่งค่อย ๆ หมุน (0.30 / 0.75) |
| `TargetPart` | `"Head"` | จุดที่กล้องหันไปหา |

---

## 🚀 วิธีใช้

รันคำสั่งเดียวใน Executor (มือถือ):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/keerazxhub/aimbotbykeerahub/refs/heads/main/codeaim.lua"))()
```

จากนั้น **กดปุ่ม `Aim Assist`** แล้วปรับค่าผ่านปุ่ม ⚙️ ได้เลย
GUI ใช้ `ResetOnSpawn = false` → **ไม่หายตอนเกิดใหม่**

---

## 🔍 เบื้องหลังสั้น ๆ

- หาเป้าที่ **ใกล้กลางจอที่สุด** โดยเทียบระยะบนหน้าจอกับ `currentFOV_Radius`
- เป้าต้อง **on screen + มีชีวิต (`Health > 0`) + ไม่มีกำแพงกั้น**
- หมุนกล้องด้วย `Camera.CFrame:Lerp(targetCFrame, smoothness)` ใน `RenderStepped`
- Raycast กรอง `LocalPlayer.Character` และ `Camera` ออกก่อนเช็คกำแพง

---

## ⚠️ ข้อควรระวัง

- ใช้เพื่อ **ศึกษาเท่านั้น** การใช้สคริปต์ช่วยเล่นอาจผิดกติกา/ToS ของเกม
- ค่า Smoothness สูงมาก ๆ จะดู **กระตุก** แนะนำเริ่มที่ `0.30`
- ตั้ง FOV กว้างเกินไปอาจ **ล็อกเป้าที่ไม่ต้องการ** — ปรับให้พอดีกับนิ้วตัวเอง
- ใช้แล้วความเสี่ยงเป็นของผู้ใช้เอง ผู้พัฒนาไม่รับผิดชอบใด ๆ

---

<p align="center">Made with ❤️ by <b>KeeraHub</b></p>

