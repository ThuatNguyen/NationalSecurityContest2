import { db } from "./db";
import * as schema from "@shared/schema";
import bcrypt from "bcryptjs";

async function seedQuangTri() {
  console.log("🌱 Bắt đầu seed dữ liệu Công an tỉnh Quảng Trị...");

  try {
    // Xóa dữ liệu cũ (nếu cần)
    console.log("Xóa dữ liệu cũ...");
    await db.delete(schema.users);
    await db.delete(schema.units);
    await db.delete(schema.clusters);

    // 1. Tạo Cụm thi đua cấp PHÒNG
    console.log("Tạo Cụm thi đua cấp Phòng...");
    const clusters = await db.insert(schema.clusters).values([
      {
        name: "Cụm thi đua số 223 các phòng thuộc khối ANND",
        shortName: "Cụm 223",
        clusterType: "phong",
        description: "08 đơn vị: PA01, PA02, PA03, PA04, PA05, PA06, PA08, PA09",
      },
      {
        name: "Cụm thi đua số 224 các phòng thuộc khối Cảnh sát điều tra",
        shortName: "Cụm 224",
        clusterType: "phong",
        description: "05 đơn vị: PC01, PC02, PC03, PC04, PC09",
      },
      {
        name: "Cụm thi đua số 225 các phòng thuộc Khối Cảnh sát quản lý hành chính",
        shortName: "Cụm 225",
        clusterType: "phong",
        description: "07 đơn vị: PC06, PC07, PC08, PC10, PC11A, PC11B, PK02",
      },
      {
        name: "Cụm thi đua số 226 các phòng thuộc Khối XDLL-TT-HC",
        shortName: "Cụm 226",
        clusterType: "phong",
        description: "07 đơn vị: PV01, PV06, PX01, PX03, PX05, PX06, PH10",
      },
      // 2. Cụm thi đua cấp XÃ/PHƯỜNG
      {
        name: "Cụm thi đua số 342",
        shortName: "Cụm 342",
        clusterType: "xa_phuong",
        description: "07 đơn vị: Tuyên Sơn, Tuyên Lâm, Tân Thành, Dân Hóa, Minh Hóa, Kim Điền, Kim Phú",
      },
      {
        name: "Cụm thi đua số 343",
        shortName: "Cụm 343",
        clusterType: "xa_phuong",
        description: "07 đơn vị: Đồng Lê, Tuyên Phú, Tuyên Bình, Phú Trạch, Hòa Trạch, Trung Thuần, Tuyên Hóa",
      },
      {
        name: "Cụm thi đua số 344",
        shortName: "Cụm 344",
        clusterType: "xa_phuong",
        description: "07 đơn vị: Quảng Trạch, Nam Ba Đồn, Nam Gianh, Tân Gianh, Bắc Trạch, Ba Đồn, Bắc Gianh",
      },
      {
        name: "Cụm thi đua số 345",
        shortName: "Cụm 345",
        clusterType: "xa_phuong",
        description: "07 đơn vị: Phong Nha, Thượng Trạch, Bố Trạch, Đông Trạch, Hoàn Lão, Nam Trạch, Đồng Thuận",
      },
      {
        name: "Cụm thi đua số 346",
        shortName: "Cụm 346",
        clusterType: "xa_phuong",
        description: "07 đơn vị: Đồng Sơn, Đồng Hởi, Quảng Ninh, Ninh Châu, Trường Sơn, Trường Ninh, Lệ Ninh",
      },
      {
        name: "Cụm thi đua số 347",
        shortName: "Cụm 347",
        clusterType: "xa_phuong",
        description: "07 đơn vị: Cam Hồng, Lệ Thủy, Tân Mỹ, Trường Phú, Sen Ngư, Kim Ngân, Vĩnh Linh",
      },
      {
        name: "Cụm thi đua số 348",
        shortName: "Cụm 348",
        clusterType: "xa_phuong",
        description: "07 đơn vị: Vĩnh Hoàng, Cửa Tùng, Vĩnh Thủy, Bến Quan, Cồn Tiên, Gio Linh, Bến Hải",
      },
      {
        name: "Cụm thi đua số 349",
        shortName: "Cụm 349",
        clusterType: "xa_phuong",
        description: "07 đơn vị: Hướng Lập, Hướng Phùng, Khe Sanh, Lao Bảo, Tân Lập, Lìa, A Dơi",
      },
      {
        name: "Cụm thi đua số 350",
        shortName: "Cụm 350",
        clusterType: "xa_phuong",
        description: "07 đơn vị: Hiếu Giang, Cam Lộ, Hướng Hiệp, Ba Lòng, Đakrông, Tà Rụt, La Lay",
      },
      {
        name: "Cụm thi đua số 351",
        shortName: "Cụm 351",
        clusterType: "xa_phuong",
        description: "08 đơn vị: Đông Hà, Nam Đông Hà, Cửa Việt, Nam Cửa Việt, Triệu Bình, Ái Tử, Triệu Phong, Cồn Cỏ",
      },
      {
        name: "Cụm thi đua số 352",
        shortName: "Cụm 352",
        clusterType: "xa_phuong",
        description: "07 đơn vị: Quảng Trị, Triệu Cơ, Mỹ Thủy, Vĩnh Định, Hải Lăng, Diên Sanh, Nam Hải Lăng",
      },
    ]).returning();

    console.log(`✓ Đã tạo ${clusters.length} cụm thi đua`);

    // 3. Tạo đơn vị cho từng cụm
    console.log("Tạo Đơn vị...");
    
    const unitsData = [
      // Cụm 223 - ANND
      { name: "Phòng PA01", shortName: "PA01", clusterId: clusters[0].id },
      { name: "Phòng PA02", shortName: "PA02", clusterId: clusters[0].id },
      { name: "Phòng PA03", shortName: "PA03", clusterId: clusters[0].id },
      { name: "Phòng PA04", shortName: "PA04", clusterId: clusters[0].id }, // Cụm trưởng
      { name: "Phòng PA05", shortName: "PA05", clusterId: clusters[0].id }, // Cụm phó
      { name: "Phòng PA06", shortName: "PA06", clusterId: clusters[0].id },
      { name: "Phòng PA08", shortName: "PA08", clusterId: clusters[0].id },
      { name: "Phòng PA09", shortName: "PA09", clusterId: clusters[0].id },

      // Cụm 224 - CSĐT
      { name: "Phòng PC01", shortName: "PC01", clusterId: clusters[1].id },
      { name: "Phòng PC02", shortName: "PC02", clusterId: clusters[1].id },
      { name: "Phòng PC03", shortName: "PC03", clusterId: clusters[1].id }, // Cụm trưởng
      { name: "Phòng PC04", shortName: "PC04", clusterId: clusters[1].id }, // Cụm phó
      { name: "Phòng PC09", shortName: "PC09", clusterId: clusters[1].id },

      // Cụm 225 - CSQLHC
      { name: "Phòng PC06", shortName: "PC06", clusterId: clusters[2].id },
      { name: "Phòng PC07", shortName: "PC07", clusterId: clusters[2].id }, // Cụm trưởng
      { name: "Phòng PC08", shortName: "PC08", clusterId: clusters[2].id }, // Cụm phó
      { name: "Phòng PC10", shortName: "PC10", clusterId: clusters[2].id },
      { name: "Phòng PC11A", shortName: "PC11A", clusterId: clusters[2].id },
      { name: "Phòng PC11B", shortName: "PC11B", clusterId: clusters[2].id },
      { name: "Phòng PK02", shortName: "PK02", clusterId: clusters[2].id },

      // Cụm 226 - XDLL-TT-HC
      { name: "Phòng PV01", shortName: "PV01", clusterId: clusters[3].id },
      { name: "Phòng PV06", shortName: "PV06", clusterId: clusters[3].id },
      { name: "Phòng PX01", shortName: "PX01", clusterId: clusters[3].id }, // Cụm trưởng
      { name: "Phòng PX03", shortName: "PX03", clusterId: clusters[3].id },
      { name: "Phòng PX05", shortName: "PX05", clusterId: clusters[3].id },
      { name: "Phòng PX06", shortName: "PX06", clusterId: clusters[3].id },
      { name: "Phòng PH10", shortName: "PH10", clusterId: clusters[3].id }, // Cụm phó

      // Cụm 342
      { name: "Công an xã Tuyên Sơn", shortName: "Tuyên Sơn", clusterId: clusters[4].id },
      { name: "Công an xã Tuyên Lâm", shortName: "Tuyên Lâm", clusterId: clusters[4].id },
      { name: "Công an xã Tân Thành", shortName: "Tân Thành", clusterId: clusters[4].id },
      { name: "Công an xã Dân Hóa", shortName: "Dân Hóa", clusterId: clusters[4].id },
      { name: "Công an xã Minh Hóa", shortName: "Minh Hóa", clusterId: clusters[4].id }, // Cụm trưởng
      { name: "Công an xã Kim Điền", shortName: "Kim Điền", clusterId: clusters[4].id },
      { name: "Công an xã Kim Phú", shortName: "Kim Phú", clusterId: clusters[4].id }, // Cụm phó

      // Cụm 343
      { name: "Công an xã Đồng Lê", shortName: "Đồng Lê", clusterId: clusters[5].id },
      { name: "Công an xã Tuyên Phú", shortName: "Tuyên Phú", clusterId: clusters[5].id },
      { name: "Công an xã Tuyên Bình", shortName: "Tuyên Bình", clusterId: clusters[5].id },
      { name: "Công an xã Phú Trạch", shortName: "Phú Trạch", clusterId: clusters[5].id },
      { name: "Công an xã Hòa Trạch", shortName: "Hòa Trạch", clusterId: clusters[5].id },
      { name: "Công an xã Trung Thuần", shortName: "Trung Thuần", clusterId: clusters[5].id }, // Cụm phó
      { name: "Công an xã Tuyên Hóa", shortName: "Tuyên Hóa", clusterId: clusters[5].id }, // Cụm trưởng

      // Cụm 344
      { name: "Công an xã Quảng Trạch", shortName: "Quảng Trạch", clusterId: clusters[6].id }, // Cụm phó
      { name: "Công an xã Nam Ba Đồn", shortName: "Nam Ba Đồn", clusterId: clusters[6].id },
      { name: "Công an xã Nam Gianh", shortName: "Nam Gianh", clusterId: clusters[6].id },
      { name: "Công an xã Tân Gianh", shortName: "Tân Gianh", clusterId: clusters[6].id },
      { name: "Công an xã Bắc Trạch", shortName: "Bắc Trạch", clusterId: clusters[6].id },
      { name: "Công an phường Ba Đồn", shortName: "Ba Đồn", clusterId: clusters[6].id }, // Cụm trưởng
      { name: "Công an phường Bắc Gianh", shortName: "Bắc Gianh", clusterId: clusters[6].id },

      // Cụm 345
      { name: "Công an xã Phong Nha", shortName: "Phong Nha", clusterId: clusters[7].id },
      { name: "Công an xã Thượng Trạch", shortName: "Thượng Trạch", clusterId: clusters[7].id },
      { name: "Công an xã Bố Trạch", shortName: "Bố Trạch", clusterId: clusters[7].id },
      { name: "Công an xã Đông Trạch", shortName: "Đông Trạch", clusterId: clusters[7].id },
      { name: "Công an xã Hoàn Lão", shortName: "Hoàn Lão", clusterId: clusters[7].id },
      { name: "Công an xã Nam Trạch", shortName: "Nam Trạch", clusterId: clusters[7].id }, // Cụm phó
      { name: "Công an phường Đồng Thuận", shortName: "Đồng Thuận", clusterId: clusters[7].id }, // Cụm trưởng

      // Cụm 346
      { name: "Công an phường Đồng Sơn", shortName: "Đồng Sơn", clusterId: clusters[8].id },
      { name: "Công an phường Đồng Hởi", shortName: "Đồng Hởi", clusterId: clusters[8].id }, // Cụm trưởng
      { name: "Công an xã Quảng Ninh", shortName: "Quảng Ninh", clusterId: clusters[8].id }, // Cụm phó
      { name: "Công an xã Ninh Châu", shortName: "Ninh Châu", clusterId: clusters[8].id },
      { name: "Công an xã Trường Sơn", shortName: "Trường Sơn", clusterId: clusters[8].id },
      { name: "Công an xã Trường Ninh", shortName: "Trường Ninh", clusterId: clusters[8].id },
      { name: "Công an xã Lệ Ninh", shortName: "Lệ Ninh", clusterId: clusters[8].id },

      // Cụm 347
      { name: "Công an xã Cam Hồng", shortName: "Cam Hồng", clusterId: clusters[9].id }, // Cụm phó
      { name: "Công an xã Lệ Thủy", shortName: "Lệ Thủy", clusterId: clusters[9].id }, // Cụm trưởng
      { name: "Công an xã Tân Mỹ", shortName: "Tân Mỹ", clusterId: clusters[9].id },
      { name: "Công an xã Trường Phú", shortName: "Trường Phú", clusterId: clusters[9].id },
      { name: "Công an xã Sen Ngư", shortName: "Sen Ngư", clusterId: clusters[9].id },
      { name: "Công an xã Kim Ngân", shortName: "Kim Ngân", clusterId: clusters[9].id },
      { name: "Công an xã Vĩnh Linh", shortName: "Vĩnh Linh", clusterId: clusters[9].id },

      // Cụm 348
      { name: "Công an xã Vĩnh Hoàng", shortName: "Vĩnh Hoàng", clusterId: clusters[10].id },
      { name: "Công an xã Cửa Tùng", shortName: "Cửa Tùng", clusterId: clusters[10].id },
      { name: "Công an xã Vĩnh Thủy", shortName: "Vĩnh Thủy", clusterId: clusters[10].id }, // Cụm phó
      { name: "Công an xã Bến Quan", shortName: "Bến Quan", clusterId: clusters[10].id }, // Cụm trưởng
      { name: "Công an xã Cồn Tiên", shortName: "Cồn Tiên", clusterId: clusters[10].id },
      { name: "Công an xã Gio Linh", shortName: "Gio Linh", clusterId: clusters[10].id },
      { name: "Công an xã Bến Hải", shortName: "Bến Hải", clusterId: clusters[10].id },

      // Cụm 349
      { name: "Công an xã Hướng Lập", shortName: "Hướng Lập", clusterId: clusters[11].id },
      { name: "Công an xã Hướng Phùng", shortName: "Hướng Phùng", clusterId: clusters[11].id },
      { name: "Công an xã Khe Sanh", shortName: "Khe Sanh", clusterId: clusters[11].id }, // Cụm trưởng
      { name: "Công an xã Lao Bảo", shortName: "Lao Bảo", clusterId: clusters[11].id }, // Cụm phó
      { name: "Công an xã Tân Lập", shortName: "Tân Lập", clusterId: clusters[11].id },
      { name: "Công an xã Lìa", shortName: "Lìa", clusterId: clusters[11].id },
      { name: "Công an xã A Dơi", shortName: "A Dơi", clusterId: clusters[11].id },

      // Cụm 350
      { name: "Công an xã Hiếu Giang", shortName: "Hiếu Giang", clusterId: clusters[12].id }, // Cụm trưởng
      { name: "Công an xã Cam Lộ", shortName: "Cam Lộ", clusterId: clusters[12].id }, // Cụm phó
      { name: "Công an xã Hướng Hiệp", shortName: "Hướng Hiệp", clusterId: clusters[12].id },
      { name: "Công an xã Ba Lòng", shortName: "Ba Lòng", clusterId: clusters[12].id },
      { name: "Công an xã Đakrông", shortName: "Đakrông", clusterId: clusters[12].id },
      { name: "Công an xã Tà Rụt", shortName: "Tà Rụt", clusterId: clusters[12].id },
      { name: "Công an xã La Lay", shortName: "La Lay", clusterId: clusters[12].id },

      // Cụm 351
      { name: "Công an phường Đông Hà", shortName: "Đông Hà", clusterId: clusters[13].id }, // Cụm trưởng
      { name: "Công an phường Nam Đông Hà", shortName: "Nam Đông Hà", clusterId: clusters[13].id },
      { name: "Công an xã Cửa Việt", shortName: "Cửa Việt", clusterId: clusters[13].id },
      { name: "Công an xã Nam Cửa Việt", shortName: "Nam Cửa Việt", clusterId: clusters[13].id },
      { name: "Công an xã Triệu Bình", shortName: "Triệu Bình", clusterId: clusters[13].id },
      { name: "Công an xã Ái Tử", shortName: "Ái Tử", clusterId: clusters[13].id }, // Cụm phó
      { name: "Công an xã Triệu Phong", shortName: "Triệu Phong", clusterId: clusters[13].id },
      { name: "Công an đặc khu Cồn Cỏ", shortName: "Cồn Cỏ", clusterId: clusters[13].id },

      // Cụm 352
      { name: "Công an phường Quảng Trị", shortName: "Quảng Trị", clusterId: clusters[14].id }, // Cụm trưởng
      { name: "Công an xã Triệu Cơ", shortName: "Triệu Cơ", clusterId: clusters[14].id },
      { name: "Công an xã Mỹ Thủy", shortName: "Mỹ Thủy", clusterId: clusters[14].id },
      { name: "Công an xã Vĩnh Định", shortName: "Vĩnh Định", clusterId: clusters[14].id },
      { name: "Công an xã Hải Lăng", shortName: "Hải Lăng", clusterId: clusters[14].id }, // Cụm phó
      { name: "Công an xã Diên Sanh", shortName: "Diên Sanh", clusterId: clusters[14].id },
      { name: "Công an xã Nam Hải Lăng", shortName: "Nam Hải Lăng", clusterId: clusters[14].id },
    ];

    const units = await db.insert(schema.units).values(unitsData).returning();
    console.log(`✓ Đã tạo ${units.length} đơn vị`);

    // 4. Tạo tài khoản admin
    console.log("Tạo tài khoản Admin...");
    const hashedPassword = await bcrypt.hash("admin123", 10);
    
    await db.insert(schema.users).values({
      username: "admin",
      password: hashedPassword,
      fullName: "Quản trị viên hệ thống",
      role: "admin",
    });
    console.log("✓ Đã tạo tài khoản admin (username: admin, password: admin123)");

    // 5. Tạo tài khoản Cụm trưởng cho từng cụm
    console.log("Tạo tài khoản Cụm trưởng...");
    
    const clusterLeaderAccounts = [
      { username: "cum223", clusterId: clusters[0].id, clusterName: clusters[0].name, unitId: units.find(u => u.shortName === "PA04")?.id },
      { username: "cum224", clusterId: clusters[1].id, clusterName: clusters[1].name, unitId: units.find(u => u.shortName === "PC03")?.id },
      { username: "cum225", clusterId: clusters[2].id, clusterName: clusters[2].name, unitId: units.find(u => u.shortName === "PC07")?.id },
      { username: "cum226", clusterId: clusters[3].id, clusterName: clusters[3].name, unitId: units.find(u => u.shortName === "PX01")?.id },
      { username: "cum342", clusterId: clusters[4].id, clusterName: clusters[4].name, unitId: units.find(u => u.shortName === "Minh Hóa")?.id },
      { username: "cum343", clusterId: clusters[5].id, clusterName: clusters[5].name, unitId: units.find(u => u.shortName === "Tuyên Hóa")?.id },
      { username: "cum344", clusterId: clusters[6].id, clusterName: clusters[6].name, unitId: units.find(u => u.shortName === "Ba Đồn")?.id },
      { username: "cum345", clusterId: clusters[7].id, clusterName: clusters[7].name, unitId: units.find(u => u.shortName === "Đồng Thuận")?.id },
      { username: "cum346", clusterId: clusters[8].id, clusterName: clusters[8].name, unitId: units.find(u => u.shortName === "Đồng Hởi")?.id },
      { username: "cum347", clusterId: clusters[9].id, clusterName: clusters[9].name, unitId: units.find(u => u.shortName === "Lệ Thủy")?.id },
      { username: "cum348", clusterId: clusters[10].id, clusterName: clusters[10].name, unitId: units.find(u => u.shortName === "Bến Quan")?.id },
      { username: "cum349", clusterId: clusters[11].id, clusterName: clusters[11].name, unitId: units.find(u => u.shortName === "Khe Sanh")?.id },
      { username: "cum350", clusterId: clusters[12].id, clusterName: clusters[12].name, unitId: units.find(u => u.shortName === "Hiếu Giang")?.id },
      { username: "cum351", clusterId: clusters[13].id, clusterName: clusters[13].name, unitId: units.find(u => u.shortName === "Đông Hà")?.id },
      { username: "cum352", clusterId: clusters[14].id, clusterName: clusters[14].name, unitId: units.find(u => u.shortName === "Quảng Trị")?.id },
    ];

    for (const account of clusterLeaderAccounts) {
      await db.insert(schema.users).values({
        username: account.username,
        password: hashedPassword,
        fullName: account.clusterName,
        role: "cluster_leader",
        clusterId: account.clusterId,
        unitId: account.unitId,
      });
    }
    console.log(`✓ Đã tạo ${clusterLeaderAccounts.length} tài khoản cụm trưởng`);

    // 6. Tạo tài khoản user cho tất cả các đơn vị
    console.log("Tạo tài khoản cho các đơn vị...");
    
    // Helper function để chuyển tên có dấu sang không dấu
    const removeVietnameseTones = (str: string) => {
      return str
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .replace(/đ/g, 'd')
        .replace(/Đ/g, 'D');
    };
    
    for (const unit of units) {
      // Lấy tên từ shortName, bỏ dấu, viết thường, viết liền
      const namePart = removeVietnameseTones(unit.shortName)
        .toLowerCase()
        .replace(/\s+/g, '');
      
      // Tạo username với prefix dựa vào loại đơn vị
      let username: string;
      if (unit.shortName.startsWith('P')) {
        // Phòng: giữ nguyên mã như PA01, PC03...
        username = unit.shortName.toLowerCase();
      } else {
        // Xã/Phường: thêm prefix cax_
        username = `cax_${namePart}`;
      }
      
      await db.insert(schema.users).values({
        username: username,
        password: hashedPassword,
        fullName: unit.name,
        role: "user",
        clusterId: unit.clusterId,
        unitId: unit.id,
      });
    }
    console.log(`✓ Đã tạo ${units.length} tài khoản user cho các đơn vị`);

    console.log("\n✅ Hoàn thành seed dữ liệu Quảng Trị!");
    console.log("\n📋 Tổng kết:");
    console.log(`   - ${clusters.length} cụm thi đua`);
    console.log(`   - ${units.length} đơn vị`);
    console.log(`   - 1 tài khoản admin`);
    console.log(`   - ${clusterLeaderAccounts.length} tài khoản cụm trưởng`);
    console.log(`   - ${units.length} tài khoản user`);
    console.log("\n🔑 Thông tin đăng nhập:");
    console.log("   Admin: username=admin, password=admin123");
    console.log("   Cụm trưởng: username=cum223-cum352, password=admin123");
    console.log("   User: username=[mã đơn vị], password=admin123");

  } catch (error) {
    console.error("❌ Lỗi khi seed dữ liệu:", error);
    throw error;
  }
}

// Run seed
seedQuangTri()
  .then(() => {
    console.log("✅ Seed script completed successfully");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Seed script failed:", error);
    process.exit(1);
  });
