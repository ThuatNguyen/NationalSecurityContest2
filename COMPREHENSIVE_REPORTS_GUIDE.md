# Hướng dẫn sử dụng Báo cáo tổng hợp

## Tổng quan

Hệ thống báo cáo tổng hợp mới được thiết kế để giải quyết vấn đề **bảng báo cáo có quá nhiều tiêu chí khiến không thể in vừa khổ giấy**.

### Các tính năng chính:

1. **Báo cáo tổng quan** - Hiển thị điểm tổng hợp theo nhóm tiêu chí
2. **Báo cáo chi tiết theo nhóm** - Hiển thị tiêu chí theo cột dọc với cấu trúc cây cha-con
3. **Xuất Excel đa sheet** - Mỗi nhóm tiêu chí là một sheet riêng
4. **Tùy chọn lọc và in** - Cho phép tùy chỉnh nội dung hiển thị

---

## Cách sử dụng

### 1. Truy cập trang báo cáo

Từ trang **Báo cáo** hiện tại, nhấn nút **"Báo cáo tổng hợp mới"** ở góc trên bên phải.

Hoặc truy cập trực tiếp: `/reports/comprehensive`

### 2. Chọn kỳ thi đua và cụm

- Chọn **Kỳ thi đua** từ dropdown
- Chọn **Cụm** (tự động lọc theo quyền của người dùng)

### 3. Tùy chọn hiển thị

Bạn có thể bật/tắt các tùy chọn sau:

- ✅ **Hiển thị điểm tự chấm** (ĐTC)
- ✅ **Hiển thị thẩm định L1** (TĐ1)
- ✅ **Hiển thị thẩm định L2** (TĐ2)
- ✅ **Ẩn tiêu chí không phân công** (KP)
- ✅ **Ẩn cột trống** (không có điểm)

### 4. Xem báo cáo

#### Tab "Tổng quan"

Hiển thị bảng tổng hợp điểm theo nhóm tiêu chí:

```
┌──────────────┬─────────┬─────────┬─────────┬─────────┐
│ Đơn vị       │ Nhóm I  │ Nhóm II │ Nhóm III│ Tổng    │
├──────────────┼─────────┼─────────┼─────────┼─────────┤
│ Đơn vị A     │         │         │         │         │
│   ĐTC        │ 25.0    │ 18.0    │ 5.0     │ 48.0    │
│   TĐ1        │ 25.0    │ 18.0    │ 5.0     │ 48.0    │
│   TĐ2        │ -       │ -       │ -       │ -       │
└──────────────┴─────────┴─────────┴─────────┴─────────┘
```

**Ưu điểm:**
- Vừa khổ giấy A4 dọc
- Dễ so sánh giữa các đơn vị
- Thích hợp cho báo cáo nhanh

#### Tab "Chi tiết theo nhóm"

Hiển thị tiêu chí theo **cột dọc** với cấu trúc cây:

```
┌────────────────────────────────┬───────────┬───────────┐
│ Tiêu chí                       │ Đơn vị A  │ Đơn vị B  │
├────────────────────────────────┼───────────┼───────────┤
│ ● I. CÔNG TÁC ĐẢNG (50đ)      │ 25.0      │ -         │
│   ● 1. Phát triển ĐV (25đ)    │ 15.0      │ -         │
│     • TC7: Số lượng ĐV (10đ)   │           │           │
│       ĐTC: 10.0 | TĐ1: 10.0   │           │           │
│     • TC8: Giáo dục CT (5đ)    │           │           │
│       ĐTC: 5.0 | TĐ1: 5.0     │           │           │
└────────────────────────────────┴───────────┴───────────┘
```

**Ưu điểm:**
- Thể hiện rõ cấu trúc cây cha-con
- Tiêu chí theo hàng → Vừa khổ giấy A4 ngang
- Dễ đọc từng tiêu chí chi tiết

**Chọn nhóm:**
- Mặc định hiển thị **"Tất cả nhóm"**
- Có thể chọn **từng nhóm** để in riêng

### 5. In báo cáo

Nhấn nút **"In báo cáo"** → Chọn:
- **Khổ giấy:** A4 Landscape (ngang)
- **Margins:** Normal (1cm)

Hệ thống sẽ tự động:
- Ẩn các nút điều khiển
- Ẩn sidebar, header
- Tối ưu bố cục cho in

### 6. Xuất Excel

Nhấn nút **"Xuất Excel"** → Tải file Excel với cấu trúc:

#### Sheet 1: "Tổng quan"
- Bảng tổng hợp theo nhóm tiêu chí
- Dễ xem overview nhanh

#### Sheet 2+: "Nhóm 1", "Nhóm 2", ...
- Mỗi nhóm là một sheet riêng
- Chi tiết đầy đủ các tiêu chí
- Format với indent và ký hiệu cây (●, •)

**Ưu điểm Excel:**
- Có thể sao chép/phân tích dữ liệu
- Tự động điều chỉnh cột
- Lọc, sort theo ý muốn

---

## API Endpoints

### 1. Báo cáo tổng quan

```
GET /api/reports/summary?periodId={id}&clusterId={id}
```

**Response:**
```json
{
  "period": {...},
  "cluster": {...},
  "units": [
    {
      "unitId": "...",
      "unitName": "...",
      "groups": [
        {
          "groupId": "...",
          "groupName": "...",
          "groupMaxScore": 50,
          "selfScore": 25.0,
          "clusterScore": 25.0,
          "finalScore": null
        }
      ],
      "totals": {
        "selfScore": 48.0,
        "clusterScore": 48.0,
        "finalScore": 0
      }
    }
  ],
  "criteriaGroups": [...]
}
```

### 2. Báo cáo chi tiết theo nhóm

```
GET /api/reports/group-detail?periodId={id}&clusterId={id}&groupId={id}
```

**Query params:**
- `periodId` (required)
- `clusterId` (required)
- `groupId` (optional) - Nếu không truyền sẽ trả về tất cả nhóm

**Response:**
```json
{
  "period": {...},
  "cluster": {...},
  "units": [...],
  "groups": [
    {
      "groupId": "...",
      "groupName": "...",
      "groupMaxScore": 50,
      "criteriaRows": [
        {
          "criteriaId": "...",
          "criteriaNumber": "1",
          "criteriaName": "...",
          "level": 1,
          "maxScore": 50,
          "isParent": true,
          "units": {
            "unit-id-1": {
              "isAssigned": true,
              "selfScore": 25.0,
              "clusterScore": 25.0,
              "finalScore": null
            }
          }
        }
      ]
    }
  ]
}
```

### 3. Xuất Excel

```
GET /api/reports/export-excel?periodId={id}&clusterId={id}
```

**Response:** File Excel binary

**Filename format:** 
`BaoCaoChiTiet_{ClusterName}_{PeriodName}_YYYY-MM-DD.xlsx`

---

## Phân quyền

- **Admin:** Xem tất cả cụm
- **Cluster Leader:** Chỉ xem cụm của mình
- **User:** Chỉ xem cụm của đơn vị mình

---

## Kỹ thuật Implementation

### Backend (server/reportRoutes.ts)

- **Recursion:** Duyệt cây tiêu chí để tính tổng điểm
- **Map-based lookup:** Tối ưu performance với Map
- **ExcelJS:** Tạo file Excel với format đẹp

### Frontend (ComprehensiveReports.tsx)

- **React Query:** Cache và refetch thông minh
- **Tabs:** Tách riêng Summary và Detail
- **Checkbox filters:** Tùy chỉnh hiển thị
- **Print CSS:** Tự động tối ưu khi in

### Print Styles (index.css)

```css
@media print {
  @page { size: A4 landscape; margin: 1cm; }
  .no-print { display: none !important; }
  /* ... auto optimize layout ... */
}
```

---

## Troubleshooting

### Vấn đề: Bảng vẫn không vừa khi in

**Giải pháp:**
1. Kiểm tra đã chọn **A4 Landscape** chưa
2. Bật tùy chọn **"Ẩn cột trống"**
3. Chọn in **từng nhóm** thay vì tất cả
4. Xuất Excel để xem chi tiết

### Vấn đề: Không tải được dữ liệu

**Kiểm tra:**
1. Đã chọn đúng kỳ thi đua và cụm chưa
2. Có quyền xem cụm đó không (Cluster Leader/User chỉ xem cụm mình)
3. Kiểm tra console log lỗi API

### Vấn đề: Excel không xuất được

**Giải pháp:**
1. Đợi tải hoàn tất (file có thể lớn)
2. Kiểm tra popup blocker
3. Thử lại với ít nhóm hơn

---

## Best Practices

### Khi nào dùng Tổng quan?
- Họp nhanh, báo cáo sơ bộ
- So sánh tổng điểm giữa các đơn vị
- In nhanh 1 trang

### Khi nào dùng Chi tiết theo nhóm?
- Kiểm tra chi tiết từng tiêu chí
- Lưu hồ sơ chính thức
- Đối chiếu điểm

### Khi nào xuất Excel?
- Cần phân tích thêm (pivot, chart)
- Chia sẻ file cho nhiều người
- Lưu trữ lâu dài

---

## Changelog

### Version 1.0.0 (2025-11-26)

✨ **Features:**
- Báo cáo tổng quan theo nhóm
- Báo cáo chi tiết với cấu trúc cây
- Xuất Excel đa sheet
- Tùy chọn lọc hiển thị
- Responsive print layout

🎨 **Design:**
- Bố cục dọc cho tiêu chí
- Indent và ký hiệu cây (●, •)
- Tối ưu in A4 ngang

🔒 **Security:**
- Phân quyền theo role
- Validate periodId, clusterId

---

## Liên hệ hỗ trợ

Nếu gặp vấn đề hoặc cần hỗ trợ, vui lòng liên hệ team phát triển.
