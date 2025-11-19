# Hướng dẫn sử dụng Form chấm điểm cho đơn vị không được giao chỉ tiêu

## 📋 Tổng quan

Form chấm điểm định lượng đã được cập nhật để hỗ trợ **đơn vị không được giao chỉ tiêu**. Người dùng có thể đánh dấu bằng checkbox và chỉ cần nhập kết quả thực hiện.

---

## 🎯 Cách sử dụng

### **Trường hợp 1: Đơn vị ĐƯỢC GIAO chỉ tiêu (bình thường)**

1. **Mở form chấm điểm** cho tiêu chí định lượng
2. **Nhập chỉ tiêu được giao** (ví dụ: 100)
3. **Nhập kết quả thực hiện** (ví dụ: 120)
4. **Xem điểm dự kiến** hiển thị tự động
5. **Click "Lưu điểm"**

```
┌─────────────────────────────────────────────┐
│ Tiêu chí định lượng                         │
├─────────────────────────────────────────────┤
│ ☐ Đơn vị không được giao chỉ tiêu          │
├─────────────────────────────────────────────┤
│ Chỉ tiêu được giao *  │ Kết quả thực hiện * │
│ [    100    ]         │ [     120      ]    │
├─────────────────────────────────────────────┤
│ ℹ Điểm dự kiến: 10.0 / 10 (Tỷ lệ: 120.0%)  │
└─────────────────────────────────────────────┘
```

---

### **Trường hợp 2: Đơn vị KHÔNG ĐƯỢC GIAO chỉ tiêu**

1. **Mở form chấm điểm** cho tiêu chí định lượng
2. **✅ Check vào checkbox** "Đơn vị không được giao chỉ tiêu"
3. **Input chỉ tiêu sẽ tự động ẩn đi**
4. **Nhập kết quả thực hiện** (ví dụ: 150)
5. **Badge "Không giao CT" sẽ hiển thị** với hướng dẫn
6. **Click "Lưu điểm"**

```
┌─────────────────────────────────────────────┐
│ Tiêu chí định lượng                         │
├─────────────────────────────────────────────┤
│ ☑ Đơn vị không được giao chỉ tiêu          │
│   Chỉ nhập kết quả thực hiện. Điểm sẽ tính │
│   theo tỷ lệ so với đơn vị có kết quả cao  │
│   nhất cùng nhóm.                           │
├─────────────────────────────────────────────┤
│         Kết quả thực hiện *                 │
│         [     150      ]                    │
├─────────────────────────────────────────────┤
│ 🔵 Không giao CT                            │
│ Điểm sẽ được tính tự động theo tỷ lệ so với│
│ đơn vị có kết quả cao nhất trong nhóm không│
│ được giao chỉ tiêu (tối đa 100% điểm).     │
└─────────────────────────────────────────────┘
```

---

## 🎨 Giao diện mới

### **Before (không check checkbox)**

<img src="form-with-target.png" alt="Form có chỉ tiêu" />

- Hiển thị 2 input: **Chỉ tiêu được giao** và **Kết quả thực hiện**
- Grid layout 2 cột
- Hiển thị điểm dự kiến và công thức tính

### **After (check checkbox)**

<img src="form-no-target.png" alt="Form không có chỉ tiêu" />

- **Checkbox** được check ✅
- Input chỉ tiêu **tự động ẩn**
- Input kết quả **full width** (chiếm cả 2 cột)
- **Badge "Không giao CT"** hiển thị màu xanh
- **Hướng dẫn** rõ ràng về cách tính điểm

---

## 🔧 Chi tiết kỹ thuật

### **State Management**

```typescript
const [noTarget, setNoTarget] = useState(false); // Checkbox state
const [targetValue, setTargetValue] = useState(""); // Target input
const [actualValue, setActualValue] = useState(""); // Actual input
```

### **Auto-detect existing no-target units**

Khi mở form cho đơn vị đã có dữ liệu (edit mode):

```typescript
useEffect(() => {
  if (open && criteriaType === 1) {
    // Auto-check checkbox if currentTargetValue is 0 or null
    setNoTarget(!currentTargetValue || currentTargetValue === 0);
  }
}, [open, currentTargetValue]);
```

### **Validation Logic**

```typescript
if (noTarget) {
  // Only validate actual value
  if (!actualValue || parseFloat(actualValue) < 0) {
    errors.actualValue = "Vui lòng nhập kết quả thực hiện (≥ 0)";
  }
  
  // Save with targetValue = 0
  onSave({
    targetValue: 0,
    actualValue: parseFloat(actualValue),
    file: file || undefined,
  });
} else {
  // Normal validation: both target and actual
  // ...
}
```

### **UI Behavior**

| Action | Result |
|--------|--------|
| Check "Không giao CT" | - Target input **ẩn**<br>- Actual input **full width**<br>- Badge **hiển thị**<br>- Công thức **ẩn** |
| Uncheck "Không giao CT" | - Target input **hiện**<br>- Grid **2 cột**<br>- Badge **ẩn**<br>- Công thức **hiển thị** |

---

## 📊 Luồng dữ liệu

```mermaid
graph TD
    A[Mở form] --> B{Check "Không giao CT"?}
    B -->|Yes| C[targetValue = 0]
    B -->|No| D[Nhập target > 0]
    C --> E[Nhập actual]
    D --> E
    E --> F[Click Lưu]
    F --> G{noTarget?}
    G -->|Yes| H[Backend: Nhóm 2 - Tính theo ratio]
    G -->|No| I[Backend: Nhóm 1 - Tính theo exceed%]
    H --> J[Hiển thị badge trên bảng]
    I --> J
```

---

## ✅ Validation Rules

### **Khi KHÔNG check "Không giao CT"**
- ✅ **Chỉ tiêu**: Bắt buộc, > 0
- ✅ **Kết quả**: Bắt buộc, ≥ 0

### **Khi CHECK "Không giao CT"**
- ⏭️ **Chỉ tiêu**: Skip validation (auto = 0)
- ✅ **Kết quả**: Bắt buộc, ≥ 0

---

## 🎯 Test Cases

### Test Case 1: Check/Uncheck checkbox

**Steps:**
1. Mở form chấm điểm định lượng
2. Check "Không giao CT"
3. **Expected**: Input chỉ tiêu ẩn, badge hiển thị
4. Uncheck "Không giao CT"
5. **Expected**: Input chỉ tiêu hiện lại

### Test Case 2: Lưu đơn vị không có target

**Steps:**
1. Check "Không giao CT"
2. Nhập actual = 150
3. Click "Lưu điểm"
4. **Expected**: Lưu thành công với targetValue = 0
5. Xem bảng điểm
6. **Expected**: Hiển thị badge "Không giao CT"

### Test Case 3: Edit đơn vị không có target

**Steps:**
1. Mở form cho đơn vị đã có target = 0
2. **Expected**: Checkbox tự động được check
3. Input chỉ tiêu tự động ẩn
4. Actual value hiển thị giá trị cũ

### Test Case 4: Validation khi không có target

**Steps:**
1. Check "Không giao CT"
2. Để trống actual
3. Click "Lưu điểm"
4. **Expected**: Hiển thị lỗi "Vui lòng nhập kết quả thực hiện"

---

## 🔄 Tương thích

- ✅ Tương thích với dữ liệu cũ (target > 0)
- ✅ Auto-detect đơn vị không có target (target = 0)
- ✅ Không ảnh hưởng các tiêu chí khác (type 2, 3, 4)
- ✅ Responsive trên mobile

---

## 📝 Lưu ý quan trọng

1. **Checkbox chỉ có cho tiêu chí định lượng (type=1)**
   - Tiêu chí định tính, chấm thẳng, cộng/trừ không có checkbox này

2. **Không thể preview điểm khi không có target**
   - Vì cần so sánh với các đơn vị khác trong nhóm
   - Điểm sẽ được tính tự động sau khi lưu

3. **Badge "Không giao CT" hiển thị trên bảng điểm**
   - Giúp phân biệt đơn vị không có target với các đơn vị khác
   - Xem tài liệu `SCORING_NO_TARGET_UNITS.md` để hiểu cách tính điểm

4. **Có thể chuyển đổi giữa có/không target**
   - Check/uncheck checkbox bất cứ lúc nào trước khi lưu
   - Dữ liệu cũ sẽ được giữ lại khi uncheck

---

## 🎓 Best Practices

### **Cho người dùng:**
1. **Đọc kỹ mô tả** bên dưới checkbox trước khi check
2. **Đảm bảo đơn vị thực sự không được giao** chỉ tiêu
3. **Nhập kết quả chính xác** vì điểm phụ thuộc vào so sánh với đơn vị khác

### **Cho admin:**
1. **Thông báo rõ** cho các đơn vị về cách chấm điểm khi không có target
2. **Kiểm tra badge** trên bảng điểm để xác nhận dữ liệu đúng
3. **Tham khảo chú thích** ở cuối bảng để giải thích cho đơn vị

---

## 📁 Files liên quan

- `client/src/components/ScoringModal.tsx` - Form chấm điểm
- `client/src/pages/EvaluationPeriods.tsx` - Hiển thị badge trên bảng
- `server/criteriaScoreService.ts` - Logic tính điểm backend
- `SCORING_NO_TARGET_UNITS.md` - Tài liệu chi tiết về cách tính điểm
