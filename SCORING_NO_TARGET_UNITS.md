# Hệ thống chấm điểm cho đơn vị không được giao chỉ tiêu

## 📋 Tổng quan

Hệ thống hỗ trợ chấm điểm cho **đơn vị không được giao chỉ tiêu** (Target = 0 hoặc null) nhưng **có kết quả thực tế** (Actual > 0) đối với tiêu chí định lượng (criteriaType = 1).

## 🎯 Nguyên tắc chấm điểm

### **2 Nhóm đơn vị riêng biệt**

Hệ thống tách riêng các đơn vị thành 2 nhóm để tính điểm:

#### **Nhóm 1: Có chỉ tiêu (Target > 0)**
- Tính điểm theo **Exceed Percentage** (% vượt chỉ tiêu)
- Công thức chuẩn 4 loại:
  - **Loại 1**: A < T → `0.5 × MS × (A/T)`
  - **Loại 2**: A = T → `0.5 × MS`
  - **Loại 3**: Leader (exceed % cao nhất) → `MS` (điểm tối đa)
  - **Loại 4**: Vượt nhưng không phải leader → `0.5 × MS + (unit_exceed% / leader_exceed%) × (0.5 × MS)`

#### **Nhóm 2: Không có chỉ tiêu (Target = 0 hoặc null) nhưng có kết quả (Actual > 0)**
- Tính điểm theo **tỷ lệ Actual value** so với đơn vị cao nhất **cùng nhóm**
- Công thức: `Score = (Actual / Max_Actual_In_No_Target_Group) × MaxScore`
- **Giới hạn tối đa: 100% MaxScore** (khuyến khích cố gắng)

### ⚠️ **Lưu ý quan trọng**

1. **Không so sánh giữa 2 nhóm**: 
   - Nhóm 1 so sánh theo Exceed %
   - Nhóm 2 so sánh theo Actual value tuyệt đối
   - 2 thang đo khác nhau, không thể mix!

2. **Leader chỉ có trong Nhóm 1**:
   - Chỉ đơn vị có Target mới có thể trở thành Leader của cụm
   - Đơn vị không có Target không thể trở thành Leader

3. **100% MaxScore cho Nhóm 2**:
   - Khuyến khích đơn vị không được giao vẫn cố gắng
   - Thường không giao chỉ tiêu là do đó là thế mạnh/sở trường

---

## 📊 Ví dụ cụ thể

### Tình huống: Tiêu chí "Số vụ án được giải quyết" (MaxScore = 10 điểm)

| Đơn vị | Target (T) | Actual (A) | Exceed % | Nhóm | Cách tính | Điểm |
|--------|-----------|-----------|----------|------|-----------|------|
| **A** | 100 | 120 | 20% | 1 (Có target) | Leader Nhóm 1 → Loại 3 | **10.0** ✅ |
| **B** | 0 | 150 | N/A | 2 (Không target) | (150/150) × 10 = 10.0 | **10.0** ✅ |
| **C** | 50 | 60 | 20% | 1 (Có target) | Loại 4: 5 + (0.2/0.2)×5 = 10.0 | **10.0** ✅ |
| **D** | 80 | 80 | 0% | 1 (Có target) | Loại 2: 0.5 × 10 = 5.0 | **5.0** |
| **E** | 0 | 100 | N/A | 2 (Không target) | (100/150) × 10 = 6.67 | **6.67** |
| **F** | 0 | 75 | N/A | 2 (Không target) | (75/150) × 10 = 5.0 | **5.0** |

### Giải thích:

#### **Nhóm 1 (A, C, D)**:
- **A**: Actual=120, Target=100 → Exceed 20% → **Leader Nhóm 1** → 10 điểm
- **C**: Actual=60, Target=50 → Exceed 20% → Cũng exceed 20% như A → Công thức 4 → 10 điểm
- **D**: Actual=80, Target=80 → Đạt đúng 100% → 5 điểm

#### **Nhóm 2 (B, E, F)**:
- **B**: Actual=150 → **Cao nhất trong Nhóm 2** → (150/150) × 10 = **10 điểm** ✅
- **E**: Actual=100 → (100/150) × 10 = 6.67 điểm
- **F**: Actual=75 → (75/150) × 10 = 5.0 điểm

---

## 🎨 Hiển thị trên giao diện

### **Badge đánh dấu**

Đơn vị không được giao chỉ tiêu sẽ có badge màu xanh:

```
Tấn công tội phạm (T: ?, A: 150) [Không giao CT]
```

### **Chú thích**

Ở cuối bảng điểm có giải thích đầy đủ:

```
🔵 Không giao CT: Đơn vị không được giao chỉ tiêu nhưng có kết quả. 
   Điểm tính theo tỷ lệ so với đơn vị có kết quả cao nhất cùng nhóm (tối đa 100% điểm).
```

---

## 💻 Chi tiết kỹ thuật

### Backend: `criteriaScoreService.ts`

```typescript
static batchCalculateQuantitativeScores(
  results: CriteriaResult[],
  targets: Map<string, number>,
  maxScore: number
): Map<string, number> {
  const scores = new Map<string, number>();
  
  // Chia thành 2 nhóm
  const unitsWithTarget = results.filter(r => (targets.get(r.unitId) || 0) > 0);
  const unitsWithoutTarget = results.filter(r => (targets.get(r.unitId) || 0) === 0);
  
  // GROUP 1: Tính theo exceed %
  if (unitsWithTarget.length > 0) {
    const leader = this.findClusterLeader(unitsWithTarget, targets);
    // ... logic chuẩn 4 công thức
  }
  
  // GROUP 2: Tính theo actual value ratio
  if (unitsWithoutTarget.length > 0) {
    let maxActualInGroup = Math.max(...unitsWithoutTarget.map(r => Number(r.actualValue || 0)));
    
    for (const result of unitsWithoutTarget) {
      const actual = Number(result.actualValue || 0);
      if (actual > 0 && maxActualInGroup > 0) {
        const ratio = actual / maxActualInGroup;
        const score = ratio * maxScore; // 100% max
        scores.set(result.unitId, Number(score.toFixed(2)));
      }
    }
  }
  
  return scores;
}
```

### Frontend: `EvaluationPeriods.tsx`

```typescript
const formatCriteriaNameWithResult = (item: Criteria): JSX.Element => {
  if (item.criteriaType === 1) {
    const hasTarget = item.targetValue > 0;
    const hasActual = item.actualValue > 0;
    const isNoTargetButHasResult = !hasTarget && hasActual;
    
    return (
      <span>
        {item.name} (T: {item.targetValue ?? '?'}, A: {item.actualValue ?? '?'})
        {isNoTargetButHasResult && (
          <span className="badge-no-target">Không giao CT</span>
        )}
      </span>
    );
  }
  // ...
};
```

---

## ✅ Ưu điểm của giải pháp

1. **Công bằng**: Mỗi nhóm có thang đo riêng, không so sánh táo với cam
2. **Khuyến khích**: Đơn vị không được giao vẫn có động lực làm tốt
3. **Rõ ràng**: Badge và chú thích giúp dễ hiểu
4. **Linh hoạt**: Hỗ trợ cả trường hợp chỉ có 1 hoặc nhiều đơn vị không có target
5. **Tối đa 100%**: Không bị giới hạn thấp, công nhận thành tích cao

---

## 🧪 Test Cases

### Test Case 1: Chỉ có 1 đơn vị không có target

**Input**:
- A: T=100, A=120
- B: T=0, A=150
- C: T=50, A=60

**Expected Output**:
- A: 10.0 (Leader Nhóm 1)
- B: 10.0 (Cao nhất Nhóm 2)
- C: 10.0 (Công thức 4)

### Test Case 2: Nhiều đơn vị không có target

**Input**:
- A: T=100, A=120
- B1: T=0, A=150
- B2: T=0, A=100
- B3: T=0, A=50

**Expected Output**:
- A: 10.0 (Leader Nhóm 1)
- B1: 10.0 (150/150 × 10)
- B2: 6.67 (100/150 × 10)
- B3: 3.33 (50/150 × 10)

### Test Case 3: Không có đơn vị có target (tất cả không được giao)

**Input**:
- A: T=0, A=100
- B: T=0, A=80
- C: T=0, A=60

**Expected Output**:
- A: 10.0 (100/100 × 10)
- B: 8.0 (80/100 × 10)
- C: 6.0 (60/100 × 10)

### Test Case 4: Đơn vị không có target và không có kết quả

**Input**:
- A: T=100, A=120
- B: T=0, A=0

**Expected Output**:
- A: 10.0 (Leader)
- B: 0.0 (Không có kết quả)

---

## 📝 Lưu ý khi sử dụng

1. **Badge chỉ hiển thị khi**: 
   - Target = 0 hoặc null
   - Actual > 0
   - CriteriaType = 1 (định lượng)

2. **Điểm = 0 khi**:
   - Không có target VÀ không có kết quả
   - Hoặc actual = 0

3. **So sánh giữa các đơn vị**:
   - Xem badge để biết đơn vị nào không được giao chỉ tiêu
   - Đơn vị không có target được chấm theo logic riêng
   - Không nên so sánh trực tiếp điểm giữa 2 nhóm

---

## 🔄 Migration

**Không cần migration database** vì:
- Sử dụng dữ liệu có sẵn (targetValue, actualValue)
- Chỉ thay đổi logic tính toán
- Backward compatible với dữ liệu cũ

**Cập nhật tự động**:
- Khi recalculate điểm, logic mới sẽ tự động áp dụng
- Điểm cũ sẽ được tính lại theo công thức mới

---

## 📞 Support

Nếu có thắc mắc về cách chấm điểm:
1. Xem badge "Không giao CT" để xác định đơn vị
2. Đọc chú thích ở cuối bảng
3. Tham khảo tài liệu này để hiểu logic chi tiết
