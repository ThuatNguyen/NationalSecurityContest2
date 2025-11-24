# Feature: Hiển thị nhãn "Không giao CT" và tính tổng điểm được giao

## Mục đích
Sau khi lưu tiêu chí với checkbox "Không được giao chỉ tiêu":
1. Tên tiêu chí hiển thị nhãn **"Không giao CT"** (badge màu xanh)
2. Dòng **TỔNG CỘNG** hiển thị **X/Y** (ví dụ: 684.0/700.0)
   - X = tổng điểm được giao (chỉ tính tiêu chí có `isAssigned = true`)
   - Y = tổng điểm tối đa của tất cả tiêu chí

## Thay đổi

### Backend (server/storage.ts)
**Thêm field `isAssigned` vào response:**
```typescript
const flatNode = {
  ...
  isAssigned: result?.isAssigned ?? true, // Default true for backwards compatibility
  ...
};
```

### Frontend (client/src/pages/EvaluationPeriods.tsx)

#### 1. Hàm `calculateAssignedMaxScore()`
**Trước:**
```typescript
// Chỉ check targetValue === 0 cho Type 1
const isNoTargetButHasResult = hasTarget && criteria.targetValue === 0 && ...
```

**Sau:**
```typescript
// Check isAssigned cho TẤT CẢ types (1,2,3,4)
const isAssigned = (criteria as any).isAssigned !== false;

if (!isAssigned) {
  const criteriaMaxScore = criteria.maxScore as number || 0;
  notAssignedTotal += criteriaMaxScore;
}
```

**Return:**
```typescript
{
  totalMax: number,        // Tổng điểm tối đa
  assignedMax: number,     // Tổng điểm được giao = totalMax - notAssignedTotal
}
```

#### 2. Hàm `renderCriteriaName()`
**Thêm hiển thị nhãn cho Type 2, 3, 4:**

**Type 2 (Định tính):**
```tsx
<span>
  {baseName}
  {/* Status: Đạt/Chưa đạt */}
  {item.selfScore && (
    <span className="text-xs ml-2 text-green-600">
      (Đạt)
    </span>
  )}
  {/* Badge: Không giao CT */}
  {!isAssigned && (
    <span className="ml-1 inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800 border border-blue-200">
      Không giao CT
    </span>
  )}
</span>
```

**Type 3, 4 (Chấm thẳng, Cộng/Trừ):**
```tsx
<span>
  {baseName}
  {!isAssigned && (
    <span className="ml-1 inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800 border border-blue-200">
      Không giao CT
    </span>
  )}
</span>
```

#### 3. Dòng TỔNG CỘNG
**Logic hiển thị:**
```tsx
<td>
  {(() => {
    const { totalMax, assignedMax } = calculateAssignedMaxScore();
    if (assignedMax < totalMax) {
      return `${assignedMax.toFixed(1)}/${totalMax.toFixed(1)}`;
    }
    return totalMax.toFixed(1);
  })()}
</td>
```

**Ví dụ output:**
- Nếu có tiêu chí không được giao: `684.0/700.0`
- Nếu tất cả được giao: `700.0`

## Luồng hoạt động

### Case 1: Chấm điểm bình thường (isAssigned = true)
1. User nhập điểm → Lưu
2. Backend lưu `isAssigned = true` vào DB
3. Tên tiêu chí hiển thị bình thường (không có badge)
4. Điểm tính vào tổng: TỔNG CỘNG = 700.0

### Case 2: Không được giao (isAssigned = false)
1. User tích checkbox "Tiêu chí không được giao chỉ tiêu" → Lưu
2. Backend lưu `isAssigned = false` vào DB
3. **Tên tiêu chí** hiển thị badge **"Không giao CT"** (màu xanh)
4. Điểm KHÔNG tính vào tổng: TỔNG CỘNG = **684.0/700.0**
   - 684.0 = điểm được giao (không tính tiêu chí này)
   - 700.0 = điểm tối đa

## Ví dụ

### Tiêu chí Type 2 (Định tính)
**Được giao:**
```
Không để xảy ra... (Đạt)
```

**Không được giao:**
```
Không để xảy ra... (Đạt) [Không giao CT]
```

### Tiêu chí Type 3 (Chấm thẳng)
**Được giao:**
```
Thu hồi tiền, tài sản...
```

**Không được giao:**
```
Thu hồi tiền, tài sản... [Không giao CT]
```

### Dòng TỔNG CỘNG
**Tất cả được giao:**
```
| TỔNG CỘNG | 700.0 | 684.0 | ... |
```

**Có tiêu chí không được giao:**
```
| TỔNG CỘNG | 684.0/700.0 | 684.0 | ... |
```
- Cột "Điểm tối đa": **684.0/700.0** (chỉ tính tiêu chí được giao)
- Cột "Điểm đạt được": Vẫn tính bình thường

## Lưu ý
- Badge "Không giao CT" chỉ hiển thị khi `isAssigned = false`
- Điểm của tiêu chí không được giao KHÔNG tính vào tổng điểm đạt được
- Tổng điểm được giao (assignedMax) dùng để tính % hoàn thành
- Áp dụng cho **TẤT CẢ** loại tiêu chí (Type 1, 2, 3, 4)

## Files đã sửa
1. `server/storage.ts`: Thêm `isAssigned` vào response của `getEvaluationSummaryTree`
2. `client/src/pages/EvaluationPeriods.tsx`:
   - Update `calculateAssignedMaxScore()` dùng `isAssigned` field
   - Update `renderCriteriaName()` hiển thị badge cho Type 2, 3, 4
   - Dòng TỔNG CỘNG đã có logic sẵn (không cần sửa)
