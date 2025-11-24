# Feature: Đánh dấu tiêu chí không được giao

## Mục đích
Cho phép đơn vị đánh dấu một số tiêu chí **KHÔNG được giao** để:
- Không tính vào "tổng điểm được giao" 
- Tính % hoàn thành chính xác = điểm đạt được / điểm được giao × 100%

## Cách sử dụng

### Đối với Tiêu chí Định lượng (Type 1) và Định tính (Type 2):

1. Mở modal chấm điểm
2. Ở đầu modal, thấy checkbox: **"Tiêu chí KHÔNG được giao cho đơn vị"**
3. **Nếu tiêu chí được giao** (mặc định):
   - Bỏ checkbox đó
   - Điền form chấm điểm bình thường
   
4. **Nếu tiêu chí KHÔNG được giao**:
   - ✅ Tích vào checkbox
   - Form nhập điểm và file đính kèm sẽ **ẨN đi**
   - Bấm "Lưu" → Tiêu chí được đánh dấu `isAssigned = false`

### Đối với Tiêu chí Chấm thẳng (Type 3) và Cộng/Trừ (Type 4):

- Không có checkbox "không được giao"
- **Luôn mặc định** là tiêu chí được giao (`isAssigned = true`)
- Chấm điểm bình thường

## Kỹ thuật

### Database
- Thêm cột `is_assigned BOOLEAN NOT NULL DEFAULT true` vào `criteria_results`
- Migration: `0004_add_is_assigned_to_criteria_results.sql`

### Backend Logic
```typescript
// server/criteriaTreeStorage.ts - calculateUnitTotalScore()
{
  total: number,              // Tổng điểm đạt được (chỉ tính isAssigned=true)
  totalAssigned: number,      // Tổng maxScore của tiêu chí được giao
  achievementRate: number,    // % = total / totalAssigned × 100
  ...
}
```

### Frontend UI
- `ScoringModal.tsx`: 
  - Checkbox "Tiêu chí KHÔNG được giao" (chỉ hiện cho type 1,2)
  - Ẩn form khi checkbox được tích
  - Gửi `isAssigned: false` khi lưu

### Business Rules
- `isAssigned = false`: Không tính vào tổng điểm, không ảnh hưởng % hoàn thành
- `isAssigned = true` (mặc định): Tính bình thường
- Áp dụng cho **TẤT CẢ** criteria types (1,2,3,4)
- Backwards compatible: default = true

## Ví dụ

**Kịch bản:**
- Tiêu chí A (type 2, maxScore=10): Đơn vị X **được giao** → chấm 10 điểm
- Tiêu chí B (type 3, maxScore=5): Đơn vị X **được giao** → chấm 3 điểm  
- Tiêu chí C (type 2, maxScore=8): Đơn vị X **KHÔNG được giao** → tích checkbox, không nhập điểm

**Kết quả:**
- Tổng điểm được giao = 10 + 5 = **15** (không tính C)
- Điểm đạt được = 10 + 3 = **13**
- % hoàn thành = 13 / 15 × 100% = **86.67%**
