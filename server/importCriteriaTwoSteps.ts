import { db } from "./db";
import { sql, eq } from "drizzle-orm";
import { evaluationPeriods, clusters } from "../shared/schema";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

interface CriteriaRow {
  id: string;
  parent_id: string | null;
  level: number;
  name: string;
  code: string | null;
  description: string | null;
  max_score: number;
  criteria_type: number;
  formula_type: number | null;
  order_index: number;
  period_id: string;
  cluster_id: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

function parseCriteriaLine(line: string): CriteriaRow | null {
  if (!line.trim() || line.includes("COPY public")) return null;
  
  const fields = line.split("\t");
  if (fields.length < 15) return null;

  return {
    id: fields[0],
    parent_id: fields[1] === "\\N" ? null : fields[1],
    level: parseInt(fields[2]),
    name: fields[3],
    code: fields[4] === "\\N" ? null : fields[4],
    description: fields[5] === "\\N" ? null : fields[5],
    max_score: parseFloat(fields[6]),
    criteria_type: parseInt(fields[7]),
    formula_type: fields[8] === "\\N" ? null : parseInt(fields[8]),
    order_index: parseInt(fields[9]),
    period_id: fields[10],
    cluster_id: fields[11],
    is_active: fields[12] === "t" || fields[12] === "1" || fields[12] === "true",
    created_at: fields[13],
    updated_at: fields[14]
  };
}

async function importCriteriaTwoSteps() {
  console.log("📥 Import criteria theo 2 bước (parent_id = null trước)");

  try {
    // Lấy Period ID và Cluster ID từ database
    console.log("\n🔍 Tìm Period và Cluster...");
    
    const periods = await db.select().from(evaluationPeriods).orderBy(evaluationPeriods.createdAt);
    if (periods.length === 0) {
      throw new Error("Không tìm thấy kỳ thi đua nào. Vui lòng tạo kỳ thi đua trước.");
    }
    const NEW_PERIOD_ID = periods[0].id;
    console.log(`   ✓ Period: ${periods[0].name} (${NEW_PERIOD_ID})`);

    const clusterList = await db.select().from(clusters).where(eq(clusters.shortName, "Cụm 347"));
    if (clusterList.length === 0) {
      throw new Error("Không tìm thấy Cụm 347. Vui lòng tạo cluster trước.");
    }
    const NEW_CLUSTER_ID = clusterList[0].id;
    console.log(`   ✓ Cluster: ${clusterList[0].name} (${NEW_CLUSTER_ID})`);

    // Đọc file SQL - sử dụng đường dẫn tương đối từ thư mục project
    const sqlFilePath = path.join(__dirname, "..", "attached_assets", "contestdb.sql");
    console.log(`\n📂 Đọc file: ${sqlFilePath}`);
    
    if (!fs.existsSync(sqlFilePath)) {
      throw new Error(`Không tìm thấy file SQL tại: ${sqlFilePath}`);
    }
    
    const sqlContent = fs.readFileSync(sqlFilePath, "utf-8");

    // Extract COPY criteria section
    const criteriaStart = sqlContent.indexOf("COPY public.criteria");
    const criteriaEnd = sqlContent.indexOf("\\.", criteriaStart);
    const criteriaSection = sqlContent.substring(criteriaStart, criteriaEnd);
    const criteriaLines = criteriaSection.split("\n").slice(1); // Skip header

    console.log(`\n📊 Tìm thấy ${criteriaLines.length} dòng trong file`);

    // Parse tất cả dữ liệu trước
    const allCriteria: CriteriaRow[] = [];
    for (const line of criteriaLines) {
      const row = parseCriteriaLine(line);
      if (row) {
        allCriteria.push(row);
      }
    }

    console.log(`📊 Parse được ${allCriteria.length} tiêu chí hợp lệ`);

    // Xóa dữ liệu cũ cho period và cluster này
    console.log("\n🗑️  Xóa dữ liệu cũ...");
    await db.execute(sql`DELETE FROM criteria WHERE period_id = ${NEW_PERIOD_ID} AND cluster_id = ${NEW_CLUSTER_ID}`);
    console.log("   ✓ Đã xóa");

    // BƯỚC 1: Import với parent_id = NULL
    console.log("\n📥 BƯỚC 1: Import toàn bộ criteria với parent_id = NULL...");
    
    let imported = 0;
    for (const row of allCriteria) {
      try {
        const name = row.name.replace(/'/g, "''");
        const code = row.code ? `'${row.code}'` : "NULL";
        const description = row.description ? `'${row.description.replace(/'/g, "''")}'` : "NULL";
        const formula_type = row.formula_type !== null ? row.formula_type : "NULL";

        await db.execute(sql.raw(`
          INSERT INTO criteria 
          (id, parent_id, level, name, code, description, max_score, criteria_type, 
           formula_type, order_index, period_id, cluster_id, is_active, created_at, updated_at)
          VALUES (
            '${row.id}',
            NULL,
            ${row.level},
            '${name}',
            ${code},
            ${description},
            ${row.max_score},
            ${row.criteria_type},
            ${formula_type},
            ${row.order_index},
            '${NEW_PERIOD_ID}',
            '${NEW_CLUSTER_ID}',
            ${row.is_active ? 1 : 0},
            NOW(),
            NOW()
          )
        `));
        
        imported++;
        if (imported % 50 === 0) {
          console.log(`   ✓ Đã import ${imported}/${allCriteria.length}...`);
        }
      } catch (error: any) {
        console.log(`   ⚠️ Lỗi import ${row.id}: ${error.message.split('\n')[0]}`);
      }
    }

    console.log(`\n✅ BƯỚC 1 hoàn tất: Import ${imported}/${allCriteria.length} tiêu chí`);

    // BƯỚC 2: Update parent_id từ dữ liệu gốc
    console.log("\n🔄 BƯỚC 2: Update parent_id từ dữ liệu gốc...");
    
    let updated = 0;
    for (const row of allCriteria) {
      if (row.parent_id) {
        try {
          await db.execute(sql.raw(`
            UPDATE criteria 
            SET parent_id = '${row.parent_id}'
            WHERE id = '${row.id}' AND period_id = '${NEW_PERIOD_ID}' AND cluster_id = '${NEW_CLUSTER_ID}'
          `));
          updated++;
        } catch (error: any) {
          console.log(`   ⚠️ Lỗi update ${row.id}: ${error.message.split('\n')[0]}`);
        }
      }
    }

    console.log(`   ✓ Updated ${updated} parent_id`);

    // Kiểm tra kết quả
    console.log("\n📊 Kiểm tra kết quả:");
    
    const countResult = await db.execute(sql`SELECT COUNT(*) as count FROM criteria WHERE period_id = ${NEW_PERIOD_ID} AND cluster_id = ${NEW_CLUSTER_ID}`);
    const withParent = await db.execute(sql`SELECT COUNT(*) as count FROM criteria WHERE period_id = ${NEW_PERIOD_ID} AND cluster_id = ${NEW_CLUSTER_ID} AND parent_id IS NOT NULL`);
    const withoutParent = await db.execute(sql`SELECT COUNT(*) as count FROM criteria WHERE period_id = ${NEW_PERIOD_ID} AND cluster_id = ${NEW_CLUSTER_ID} AND parent_id IS NULL`);

    console.log(`   ✓ Tổng số tiêu chí: ${countResult.rows[0].count}`);
    console.log(`   ✓ Có parent_id: ${withParent.rows[0].count}`);
    console.log(`   ✓ Không có parent_id (root): ${withoutParent.rows[0].count}`);
    console.log(`   ✓ Period ID: ${NEW_PERIOD_ID}`);
    console.log(`   ✓ Cluster ID: ${NEW_CLUSTER_ID}`);

    // Hiển thị một vài mẫu
    console.log("\n📋 Mẫu tiêu chí root:");
    const samples = await db.execute(sql`
      SELECT id, name, level, max_score 
      FROM criteria 
      WHERE period_id = ${NEW_PERIOD_ID} AND cluster_id = ${NEW_CLUSTER_ID} AND parent_id IS NULL 
      LIMIT 5
    `);
    samples.rows.forEach((row: any) => {
      console.log(`   - [${row.level}] ${row.name} (${row.max_score} điểm)`);
    });

    console.log("\n✅ HOÀN TẤT!");
    console.log(`   Import: ${imported}/${allCriteria.length} tiêu chí`);
    console.log(`   Missing: ${allCriteria.length - imported} tiêu chí`);
    
    if (allCriteria.length - imported > 0) {
      console.log("\n⚠️  CẦN KIỂM TRA: Có tiêu chí không import được!");
    }

    process.exit(0);
  } catch (error: any) {
    console.error("❌ Lỗi:", error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

importCriteriaTwoSteps().catch((error) => {
  console.error("❌ Lỗi:", error);
  process.exit(1);
});
