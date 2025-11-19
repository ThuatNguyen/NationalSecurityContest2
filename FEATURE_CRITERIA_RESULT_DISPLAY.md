# Tính năng: Hiển thị kết quả thực hiện trong tên tiêu chí

## Mô tả
Khi chấm điểm kỳ thi đua, hệ thống sẽ hiển thị kết quả thực hiện của đơn vị ngay trong tên tiêu chí, giúp người dùng dễ dàng theo dõi và đánh giá.

## Ví dụ hiển thị

### Tiêu chí định lượng (Type 1):
```
Tấn công tội phạm (T: 5, A: 2)
```
- **T (Target)**: Chỉ tiêu được giao = 5
- **A (Actual)**: Kết quả thực tế = 2

### Tiêu chí định tính (Type 2):
```
Hoàn thành nhiệm vụ (Đạt)
Đào tạo cán bộ (Chưa đạt)
```

### Tiêu chí khác (Type 3, 4):
Hiển thị tên bình thường, không có thông tin thêm

## Chú thích
Ở cuối mỗi bảng điểm có phần chú thích giải thích ý nghĩa các ký tự viết tắt:

- **T:** Chỉ tiêu (Target) - Chỉ tiêu được giao cho đơn vị (áp dụng cho tiêu chí định lượng)
- **A:** Thực hiện (Actual) - Kết quả thực tế đơn vị đạt được (áp dụng cho tiêu chí định lượng)
- **Đạt/Chưa đạt:** Trạng thái hoàn thành tiêu chí định tính

## Chi tiết kỹ thuật

### 1. Frontend Changes (`client/src/pages/EvaluationPeriods.tsx`)

#### a. Cập nhật Interface
```typescript
interface Criteria {
  // ... existing fields
  targetValue?: number; // NEW: Chỉ tiêu được giao
  actualValue?: number; // Kết quả thực tế
  criteriaType: number; // 0=cha, 1=định lượng, 2=định tính, 3=chấm thẳng, 4=cộng/trừ
}
```

#### b. Helper Function mới
```typescript
const formatCriteriaNameWithResult = (item: Criteria): JSX.Element => {
  const baseName = item.name;
  
  // Chỉ thêm thông tin cho tiêu chí lá (criteriaType 1-4)
  if (item.criteriaType === 0) {
    return <span>{baseName}</span>;
  }
  
  // Type 1: Định lượng
  if (item.criteriaType === 1 && (item.targetValue !== undefined || item.actualValue !== undefined)) {
    const T = item.targetValue ?? '?';
    const A = item.actualValue ?? '?';
    
    return (
      <span>
        {baseName}
        {(T !== '?' || A !== '?') && (
          <span className="text-xs text-muted-foreground ml-2">
            (T: {T}, A: {A})
          </span>
        )}
      </span>
    );
  }
  
  // Type 2: Định tính
  if (item.criteriaType === 2 && item.selfScore !== undefined && item.selfScore !== null) {
    const achieved = Number(item.selfScore) > 0;
    return (
      <span>
        {baseName}
        <span className={`text-xs ml-2 ${achieved ? 'text-green-600' : 'text-gray-500'}`}>
          ({achieved ? 'Đạt' : 'Chưa đạt'})
        </span>
      </span>
    );
  }
  
  return <span>{baseName}</span>;
};
```

#### c. Cập nhật hiển thị trong bảng
Thay thế:
```typescript
{item.name}
```

Bằng:
```typescript
{formatCriteriaNameWithResult(item)}
```

#### d. Thêm phần chú thích
Sau bảng điểm, thêm:
```typescript
<div className="mt-4 p-3 bg-muted/50 border rounded-md text-sm">
  <div className="font-semibold mb-2 text-foreground">Chú thích:</div>
  <div className="space-y-1 text-xs text-muted-foreground">
    <div><span className="font-medium text-foreground">T:</span> Chỉ tiêu (Target) - Chỉ tiêu được giao cho đơn vị (áp dụng cho tiêu chí định lượng)</div>
    <div><span className="font-medium text-foreground">A:</span> Thực hiện (Actual) - Kết quả thực tế đơn vị đạt được (áp dụng cho tiêu chí định lượng)</div>
    <div><span className="font-medium text-foreground">Đạt/Chưa đạt:</span> Trạng thái hoàn thành tiêu chí định tính</div>
  </div>
</div>
```

### 2. Backend Changes (`server/storage.ts`)

#### Cập nhật `getEvaluationSummaryTree()`

Thêm query để lấy `targetValue` từ bảng `criteriaTargets`:

```typescript
// Get all criteria targets for this period+unit
const criteriaTargets = await db
  .select()
  .from(schema.criteriaTargets)
  .where(
    and(
      eq(schema.criteriaTargets.periodId, periodId),
      eq(schema.criteriaTargets.unitId, unitId)
    )
  );
const targetsMap = new Map(criteriaTargets.map(t => [t.criteriaId, t]));
```

Thêm `targetValue` vào flatNode:
```typescript
const flatNode = {
  // ... existing fields
  actualValue: result?.actualValue ? parseFloat(result.actualValue) : undefined,
  targetValue: target?.targetValue ? parseFloat(target.targetValue) : undefined, // NEW
  // ... remaining fields
};
```

## Lợi ích

1. **Dễ theo dõi**: Người chấm điểm có thể nhìn thấy ngay chỉ tiêu và kết quả mà không cần mở modal
2. **Tiết kiệm thời gian**: Không cần click vào từng tiêu chí để xem thông tin chi tiết
3. **Rõ ràng**: Với chú thích ở cuối bảng, người dùng mới cũng hiểu ngay ý nghĩa
4. **Chuyên nghiệp**: Format chuẩn, nhất quán trên toàn hệ thống

## Testing

### Test Cases

1. **Tiêu chí định lượng có đầy đủ T và A**
   - Hiển thị: "Tên tiêu chí (T: 10, A: 8)"
   
2. **Tiêu chí định lượng chỉ có T, chưa có A**
   - Hiển thị: "Tên tiêu chí (T: 10, A: ?)"
   
3. **Tiêu chí định lượng chỉ có A, chưa có T**
   - Hiển thị: "Tên tiêu chí (T: ?, A: 5)"
   
4. **Tiêu chí định tính - Đạt**
   - Hiển thị: "Tên tiêu chí (Đạt)" với màu xanh
   
5. **Tiêu chí định tính - Chưa đạt**
   - Hiển thị: "Tên tiêu chí (Chưa đạt)" với màu xám
   
6. **Tiêu chí cha (Type 0)**
   - Hiển thị: "Tên tiêu chí" (không có thông tin thêm)
   
7. **Tiêu chí Type 3, 4**
   - Hiển thị: "Tên tiêu chí" (không có thông tin thêm)

8. **Phần chú thích**
   - Kiểm tra hiển thị ở cả bảng chính và phần in ấn
   - Kiểm tra responsive trên mobile

## Tương thích

- ✅ Tương thích với hệ thống cũ (legacy fields)
- ✅ Không ảnh hưởng đến logic tính điểm
- ✅ Hoạt động trên tất cả trình duyệt modern
- ✅ Responsive trên mobile

## Files Changed

1. `/client/src/pages/EvaluationPeriods.tsx` - Frontend UI
2. `/server/storage.ts` - Backend API

## Migration

Không cần migration vì:
- Sử dụng fields có sẵn trong database
- Chỉ thêm logic hiển thị, không thay đổi cấu trúc dữ liệu
