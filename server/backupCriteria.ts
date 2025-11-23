import { db } from "./db";
import * as schema from "@shared/schema";
import { eq, and } from "drizzle-orm";
import * as fs from "fs";
import * as path from "path";

async function backupCriteria() {
  console.log("🔍 Bắt đầu backup criteria cho cụm 347...");

  try {
    // 1. Tìm cụm 347
    const cluster = await db
      .select()
      .from(schema.clusters)
      .where(eq(schema.clusters.shortName, "Cụm 347"))
      .limit(1);

    if (cluster.length === 0) {
      console.error("❌ Không tìm thấy cụm 347");
      return;
    }

    const clusterId = cluster[0].id;
    console.log(`✓ Tìm thấy cụm: ${cluster[0].name} (ID: ${clusterId})`);

    // 2. Lấy tất cả criteria của cụm 347
    const criteriaList = await db
      .select()
      .from(schema.criteria)
      .where(eq(schema.criteria.clusterId, clusterId))
      .orderBy(schema.criteria.orderIndex);

    console.log(`✓ Tìm thấy ${criteriaList.length} criteria`);

    // 3. Lấy formula cho các criteria định lượng
    const criteriaIds = criteriaList.map(c => c.id);
    const formulas = criteriaIds.length > 0 
      ? await db
          .select()
          .from(schema.criteriaFormula)
          .where(
            eq(schema.criteriaFormula.criteriaId, criteriaIds[0])
          )
      : [];

    // Get all formulas
    const allFormulas = [];
    for (const criteriaId of criteriaIds) {
      const formula = await db
        .select()
        .from(schema.criteriaFormula)
        .where(eq(schema.criteriaFormula.criteriaId, criteriaId));
      if (formula.length > 0) {
        allFormulas.push(...formula);
      }
    }

    console.log(`✓ Tìm thấy ${allFormulas.length} formula`);

    // 4. Tạo backup data
    const backupData = {
      cluster: cluster[0],
      criteria: criteriaList,
      formulas: allFormulas,
      backupDate: new Date().toISOString(),
      totalCriteria: criteriaList.length,
      totalFormulas: allFormulas.length,
    };

    // 5. Lưu vào file JSON
    const backupDir = path.join(process.cwd(), "backups");
    if (!fs.existsSync(backupDir)) {
      fs.mkdirSync(backupDir, { recursive: true });
    }

    const timestamp = new Date().toISOString().replace(/[:.]/g, "-").slice(0, 19);
    const filename = `criteria_cum347_${timestamp}.json`;
    const filepath = path.join(backupDir, filename);

    fs.writeFileSync(filepath, JSON.stringify(backupData, null, 2), "utf-8");

    console.log("\n✅ Backup thành công!");
    console.log(`📁 File: ${filepath}`);
    console.log(`📊 Tổng kết:`);
    console.log(`   - Cụm: ${cluster[0].name}`);
    console.log(`   - Số criteria: ${criteriaList.length}`);
    console.log(`   - Số formula: ${allFormulas.length}`);

    // 6. Tạo script restore tương ứng
    const restoreScript = `import { db } from "./db";
import * as schema from "@shared/schema";
import * as fs from "fs";
import * as path from "path";

async function restoreCriteria() {
  console.log("🔄 Bắt đầu restore criteria cho cụm 347...");

  try {
    // Đọc file backup
    const backupFile = "${filename}";
    const filepath = path.join(process.cwd(), "backups", backupFile);
    const data = JSON.parse(fs.readFileSync(filepath, "utf-8"));

    console.log(\`📁 Đọc file: \${backupFile}\`);
    console.log(\`✓ Tìm thấy \${data.totalCriteria} criteria\`);

    // Tìm cụm 347 mới (sau khi seed lại)
    const cluster = await db
      .select()
      .from(schema.clusters)
      .where(eq(schema.clusters.shortName, "Cụm 347"))
      .limit(1);

    if (cluster.length === 0) {
      console.error("❌ Không tìm thấy cụm 347 trong database mới");
      return;
    }

    const newClusterId = cluster[0].id;
    console.log(\`✓ Cụm mới: \${cluster[0].name} (ID: \${newClusterId})\`);

    // Map old ID -> new ID cho criteria
    const criteriaIdMap = new Map<string, string>();

    // Insert criteria theo thứ tự level (để đảm bảo parent tồn tại trước child)
    const sortedCriteria = data.criteria.sort((a: any, b: any) => a.level - b.level);

    for (const oldCriteria of sortedCriteria) {
      const newParentId = oldCriteria.parentId ? criteriaIdMap.get(oldCriteria.parentId) : null;

      const [newCriteria] = await db.insert(schema.criteria).values({
        parentId: newParentId,
        level: oldCriteria.level,
        name: oldCriteria.name,
        code: oldCriteria.code,
        description: oldCriteria.description,
        maxScore: oldCriteria.maxScore,
        criteriaType: oldCriteria.criteriaType,
        formulaType: oldCriteria.formulaType,
        orderIndex: oldCriteria.orderIndex,
        periodId: oldCriteria.periodId, // Giữ nguyên periodId
        clusterId: newClusterId, // Dùng clusterId mới
        isActive: oldCriteria.isActive,
      }).returning();

      criteriaIdMap.set(oldCriteria.id, newCriteria.id);
    }

    console.log(\`✓ Đã restore \${criteriaIdMap.size} criteria\`);

    // Insert formulas
    for (const oldFormula of data.formulas) {
      const newCriteriaId = criteriaIdMap.get(oldFormula.criteriaId);
      if (newCriteriaId) {
        await db.insert(schema.criteriaFormula).values({
          criteriaId: newCriteriaId,
          targetRequired: oldFormula.targetRequired,
          defaultTarget: oldFormula.defaultTarget,
          unit: oldFormula.unit,
        });
      }
    }

    console.log(\`✓ Đã restore \${data.formulas.length} formula\`);

    console.log("\\n✅ Restore thành công!");

  } catch (error) {
    console.error("❌ Lỗi khi restore:", error);
    throw error;
  }
}

// Run restore
restoreCriteria()
  .then(() => {
    console.log("✅ Restore completed");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Restore failed:", error);
    process.exit(1);
  });
`;

    const restoreFilename = `restoreCriteria_cum347_${timestamp}.ts`;
    const restoreFilepath = path.join(backupDir, restoreFilename);
    fs.writeFileSync(restoreFilepath, restoreScript, "utf-8");

    console.log(`\n📝 Script restore: ${restoreFilepath}`);
    console.log(`\n💡 Để restore lại sau khi seed mới, chạy:`);
    console.log(`   tsx ${restoreFilepath}`);

  } catch (error) {
    console.error("❌ Lỗi khi backup:", error);
    throw error;
  }
}

// Run backup
backupCriteria()
  .then(() => {
    console.log("✅ Backup completed");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Backup failed:", error);
    process.exit(1);
  });
