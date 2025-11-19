import { db } from "./db";
import * as schema from "@shared/schema";
import bcrypt from "bcryptjs";

async function seedBasic() {
  console.log("🌱 Bắt đầu seed dữ liệu cơ bản...");

  try {
    console.log("Tạo Cụm thi đua...");
    const [cluster1, cluster2, cluster3] = await db.insert(schema.clusters).values([
      {
        name: "Cụm Công an cấp Phòng Thành phố",
        shortName: "CACPTP",
        clusterType: "phong",
        description: "Cụm thi đua các đơn vị Công an cấp phòng thuộc Thành phố",
      },
      {
        name: "Cụm Công an xã/phường Quận 1",
        shortName: "CAXPQ1",
        clusterType: "xa_phuong",
        description: "Cụm thi đua Công an các xã, phường thuộc Quận 1",
      },
      {
        name: "Cụm Công an xã/phường Quận 3",
        shortName: "CAXPQ3",
        clusterType: "xa_phuong",
        description: "Cụm thi đua Công an các xã, phường thuộc Quận 3",
      },
    ]).returning();

    console.log(`✓ Đã tạo 3 cụm thi đua`);

    console.log("Tạo Đơn vị...");
    const units = await db.insert(schema.units).values([
      {
        name: "Phòng Cảnh sát Hình sự",
        shortName: "PC02",
        clusterId: cluster1.id,
        description: "Phòng Cảnh sát Hình sự Công an TP.HCM",
      },
      {
        name: "Phòng Cảnh sát Giao thông",
        shortName: "PC08",
        clusterId: cluster1.id,
        description: "Phòng Cảnh sát Giao thông Công an TP.HCM",
      },
      {
        name: "Phòng An ninh Chính trị nội bộ",
        shortName: "PA03",
        clusterId: cluster1.id,
        description: "Phòng An ninh Chính trị nội bộ Công an TP.HCM",
      },
      {
        name: "Công an Phường Bến Nghé",
        shortName: "CAPBN",
        clusterId: cluster2.id,
        description: "Công an Phường Bến Nghé, Quận 1",
      },
      {
        name: "Công an Phường Bến Thành",
        shortName: "CAPBT",
        clusterId: cluster2.id,
        description: "Công an Phường Bến Thành, Quận 1",
      },
      {
        name: "Công an Phường Cô Giang",
        shortName: "CAPCG",
        clusterId: cluster2.id,
        description: "Công an Phường Cô Giang, Quận 1",
      },
      {
        name: "Công an Phường Võ Thị Sáu",
        shortName: "CAPVTS",
        clusterId: cluster3.id,
        description: "Công an Phường Võ Thị Sáu, Quận 3",
      },
      {
        name: "Công an Phường 09",
        shortName: "CAP09Q3",
        clusterId: cluster3.id,
        description: "Công an Phường 09, Quận 3",
      },
    ]).returning();

    console.log(`✓ Đã tạo ${units.length} đơn vị`);

    console.log("Tạo người dùng...");
    const hashedPassword = await bcrypt.hash("admin123", 10);
    
    await db.insert(schema.users).values([
      {
        username: "admin",
        password: hashedPassword,
        fullName: "Quản trị viên hệ thống",
        role: "admin",
      },
      {
        username: "cumtruong1",
        password: await bcrypt.hash("123456", 10),
        fullName: "Cụm trưởng Cụm TP",
        role: "cluster_leader",
        clusterId: cluster1.id,
      },
      {
        username: "cumtruong2",
        password: await bcrypt.hash("123456", 10),
        fullName: "Cụm trưởng Cụm Xã phường Q1",
        role: "cluster_leader",
        clusterId: cluster2.id,
      },
      {
        username: "cumtruong3",
        password: await bcrypt.hash("123456", 10),
        fullName: "Cụm trưởng Cụm Xã phường Q3",
        role: "cluster_leader",
        clusterId: cluster3.id,
      },
      {
        username: "donvi1",
        password: await bcrypt.hash("123456", 10),
        fullName: "Cán bộ PC02",
        role: "user",
        clusterId: cluster1.id,
        unitId: units[0].id,
      },
      {
        username: "donvi2",
        password: await bcrypt.hash("123456", 10),
        fullName: "Cán bộ PC08",
        role: "user",
        clusterId: cluster1.id,
        unitId: units[1].id,
      },
      {
        username: "donvi3",
        password: await bcrypt.hash("123456", 10),
        fullName: "Cán bộ Phường Bến Nghé",
        role: "user",
        clusterId: cluster2.id,
        unitId: units[3].id,
      },
    ]);

    console.log(`✓ Đã tạo 7 người dùng`);

    console.log("Tạo Kỳ thi đua...");
    await db.insert(schema.evaluationPeriods).values([
      {
        name: "Kỳ thi đua 6 tháng đầu năm 2025",
        year: 2025,
        startDate: new Date("2025-01-01"),
        endDate: new Date("2025-06-30"),
        status: "active",
      },
    ]);

    console.log(`✓ Đã tạo kỳ thi đua`);

    console.log("\n✅ Hoàn thành seed dữ liệu cơ bản!");
    console.log("\n📋 Thông tin đăng nhập:");
    console.log("  Admin: admin / admin123");
    console.log("  Cụm trưởng 1 (Phòng): cumtruong1 / 123456");
    console.log("  Cụm trưởng 2 (XP Q1): cumtruong2 / 123456");
    console.log("  Cụm trưởng 3 (XP Q3): cumtruong3 / 123456");
    console.log("  Đơn vị 1 (PC02): donvi1 / 123456");
    console.log("  Đơn vị 2 (PC08): donvi2 / 123456");
    console.log("  Đơn vị 3 (Bến Nghé): donvi3 / 123456");
    
  } catch (error) {
    console.error("❌ Lỗi khi seed dữ liệu:", error);
    throw error;
  }
}

seedBasic()
  .then(() => {
    console.log("\n🎉 Seed thành công!");
    process.exit(0);
  })
  .catch((error) => {
    console.error("\n💥 Seed thất bại:", error);
    process.exit(1);
  });
