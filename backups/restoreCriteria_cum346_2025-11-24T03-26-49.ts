import { db } from "../server/db.js";
import * as schema from "../shared/schema.js";
import { eq } from "drizzle-orm";
import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function restoreCriteria() {
  console.log("🔄 Bắt đầu restore criteria cho cụm 346...");

  try {
    // Đọc file backup
    const backupFile = "criteria_cum346_2025-11-24T03-26-49.json";
    const filepath = path.join(__dirname, backupFile);
    const data = JSON.parse(fs.readFileSync(filepath, "utf-8"));

    console.log(`📁 Đọc file: ${backupFile}`);
    console.log(`✓ Tìm thấy ${data.totalCriteria} criteria`);

    // Tìm cụm 346 mới (sau khi seed lại)
    const cluster = await db
      .select()
      .from(schema.clusters)
      .where(eq(schema.clusters.shortName, "Cụm 346"))
      .limit(1);

    if (cluster.length === 0) {
      console.error("❌ Không tìm thấy cụm 346 trong database mới");
      return;
    }

    const newClusterId = cluster[0].id;
    console.log(`✓ Cụm mới: ${cluster[0].name} (ID: ${newClusterId})`);

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

    console.log(`✓ Đã restore ${criteriaIdMap.size} criteria`);

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

    console.log(`✓ Đã restore ${data.formulas.length} formula`);

    console.log("\n✅ Restore thành công!");

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
