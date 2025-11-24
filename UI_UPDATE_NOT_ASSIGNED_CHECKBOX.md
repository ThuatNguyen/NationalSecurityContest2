# UI Update: Checkbox "Không được giao chỉ tiêu" cho từng loại tiêu chí

## Thay đổi

### Trước đây:
- Checkbox "Tiêu chí KHÔNG được giao" ở **đầu modal** (áp dụng cho type 1,2)
- Type 3,4 không có checkbox

### Bây giờ:
- **Type 1 (Định lượng)**: 
  - ❌ XÓA checkbox ở đầu modal
  - ✅ GIỮ checkbox "Tiêu chí không được giao chỉ tiêu" bên trong form (noTarget)
  - Dùng để đánh dấu không có chỉ tiêu cụ thể nhưng vẫn chấm điểm

- **Type 2 (Định tính)**:
  - ✅ Checkbox "Tiêu chí không được giao chỉ tiêu" bên trong form (dưới tiêu đề)
  - Khi tích → Ẩn radio button Đạt/Không đạt + file upload
  - Lưu → `isAssigned = false`

- **Type 3 (Chấm thẳng)**:
  - ✅ Checkbox "Tiêu chí không được giao chỉ tiêu" bên trong form (dưới tiêu đề)
  - Khi tích → Ẩn input điểm + file upload
  - Lưu → `isAssigned = false`

- **Type 4 (Cộng/Trừ)**:
  - ✅ Checkbox "Tiêu chí không được giao chỉ tiêu" bên trong form (dưới tiêu đề)
  - Khi tích → Ẩn input điểm + file upload
  - Lưu → `isAssigned = false`

## Luồng hoạt động

### Case 1: Tiêu chí được giao (mặc định)
1. Mở modal chấm điểm
2. Checkbox "Tiêu chí không được giao chỉ tiêu" **KHÔNG tích**
3. Form nhập điểm hiển thị bình thường
4. Nhập điểm → Upload file (optional) → Lưu
5. Lưu vào DB với `isAssigned = true`

### Case 2: Tiêu chí KHÔNG được giao
1. Mở modal chấm điểm
2. ✅ **Tích** checkbox "Tiêu chí không được giao chỉ tiêu"
3. Form nhập điểm + file upload **ẨN đi**
4. Bấm Lưu
5. Lưu vào DB với `isAssigned = false` (không có điểm, không có file)

### Case 3: Hiển thị trong bảng
- Nếu `isAssigned = false` và đã có record trong `criteria_results`:
  - Hiển thị **⊘** (ký tự prohibited)
  - Nền màu cam
  - Tooltip: "Đơn vị không được giao tiêu chí này"
  - Điểm không tính vào tổng

## Kỹ thuật

### Modal Component
```typescript
// State
const [notAssigned, setNotAssigned] = useState(false);

// Render checkbox (for type 2,3,4)
<Checkbox
  id="not-assigned-type2"
  checked={notAssigned}
  onCheckedChange={(checked) => setNotAssigned(checked as boolean)}
/>

// Conditional render form
{!notAssigned && (
  <div>
    {/* Form nhập điểm */}
  </div>
)}

// On save
if (notAssigned) {
  onSave({ isAssigned: false });
} else {
  onSave({ 
    score: ...,
    file: ...,
    isAssigned: true 
  });
}
```

### Display Logic (CriteriaMatrixTable.tsx)
```typescript
const hasResult = scores?.hasResult === true;
const isAssigned = scores?.isAssigned !== false;
const shouldMarkNotAssigned = hasResult && !isAssigned;

// Style
className={shouldMarkNotAssigned 
  ? "bg-orange-50 text-orange-700" 
  : ""}

// Icon
{shouldMarkNotAssigned && (
  <span className="text-orange-600">⊘</span>
)}
```

## Files đã sửa
- `client/src/components/ScoringModal.tsx`
  - Xóa checkbox chung ở đầu modal
  - Thêm checkbox riêng cho từng type (2,3,4) bên trong form
  - Conditional render form khi notAssigned
  - Update validation logic
  - Update file upload visibility

## Lưu ý
- Type 1 có 2 checkbox khác nhau:
  - `noTarget`: Không có chỉ tiêu cụ thể (vẫn chấm điểm so sánh với units khác)
  - `notAssigned`: Không được giao tiêu chí (không chấm điểm)
  
- Types 2,3,4 chỉ có 1 checkbox:
  - `notAssigned`: Không được giao chỉ tiêu (không chấm điểm)

- Hiển thị ⊘ CHỈ KHI: `hasResult = true` VÀ `isAssigned = false`
  - Tức là: Đã tạo record trong DB để đánh dấu "không được giao"
