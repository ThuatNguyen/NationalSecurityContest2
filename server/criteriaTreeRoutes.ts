import type { Express } from "express";
import type { Request, Response, NextFunction } from "express";
import { criteriaTreeStorage } from "./criteriaTreeStorage";
import type { InsertCriteria, InsertCriteriaResult } from "@shared/schema";
import { db } from "./db";
import * as schema from "@shared/schema";
import { eq, and } from "drizzle-orm";

/**
 * Middleware kiểm tra quyền truy cập
 */
function requireRole(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.isAuthenticated()) {
      return res.status(401).json({ message: "Vui lòng đăng nhập" });
    }
    
    const user = req.user as any;
    if (!roles.includes(user.role)) {
      return res.status(403).json({ message: "Không có quyền truy cập" });
    }
    
    next();
  };
}

/**
 * Setup API routes cho hệ thống Tiêu chí Tree
 */
export function setupCriteriaTreeRoutes(app: Express) {
  
  // ============================================
  // CRITERIA CRUD
  // ============================================
  
  /**
   * GET /api/criteria/tree
   * Lấy cây tiêu chí đầy đủ theo periodId và clusterId
   */
  app.get("/api/criteria/tree", async (req: Request, res: Response, next: NextFunction) => {
    try {
      const periodId = req.query.periodId as string;
      const clusterId = req.query.clusterId as string | undefined;
      
      if (!periodId) {
        return res.status(400).json({ message: "Thiếu periodId" });
      }
      
      const tree = await criteriaTreeStorage.getCriteriaTree(periodId, clusterId);
      res.json(tree);
    } catch (error) {
      next(error);
    }
  });
  
  /**
   * GET /api/criteria/:id
   * Lấy chi tiết một tiêu chí
   */
  app.get("/api/criteria/:id", async (req: Request, res: Response, next: NextFunction) => {
    try {
      const criteria = await criteriaTreeStorage.getCriteriaById(req.params.id);
      if (!criteria) {
        return res.status(404).json({ message: "Không tìm thấy tiêu chí" });
      }
      res.json(criteria);
    } catch (error) {
      next(error);
    }
  });
  
  /**
   * POST /api/criteria
   * Tạo tiêu chí mới (admin only)
   */
  app.post("/api/criteria", requireRole("admin"), async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { criteria, details } = req.body;
      
      // Validate criteria_type
      // 0 = parent node (not scorable), 1-4 = leaf nodes (scorable)
      if (![0, 1, 2, 3, 4].includes(criteria.criteriaType)) {
        return res.status(400).json({ 
          message: "criteria_type phải là 0 (tiêu chí cha), 1 (định lượng), 2 (định tính), 3 (chấm thẳng), hoặc 4 (+/-)" 
        });
      }
      
      // Simplified validation: details are now optional for all types
      // Type 1: Auto-calculation uses criteriaTargets table
      // Type 2: No config needed (binary đạt/không đạt)
      // Type 3 & 4: User enters score directly, no formula needed
      // Details parameter is optional and can be undefined
      
      const newCriteria = await criteriaTreeStorage.createCriteria(criteria, details);
      res.status(201).json(newCriteria);
    } catch (error: any) {
      if (error.message.includes("duplicate") || error.message.includes("unique")) {
        return res.status(400).json({ message: "Tiêu chí đã tồn tại" });
      }
      next(error);
    }
  });
  
  /**
   * PUT /api/criteria/:id
   * Cập nhật tiêu chí (admin only)
   */
  app.put("/api/criteria/:id", requireRole("admin"), async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { criteria, details } = req.body;
      
      const updated = await criteriaTreeStorage.updateCriteria(req.params.id, criteria, details);
      if (!updated) {
        return res.status(404).json({ message: "Không tìm thấy tiêu chí" });
      }
      
      res.json(updated);
    } catch (error: any) {
      next(error);
    }
  });
  
  /**
   * DELETE /api/criteria/:id
   * Xóa tiêu chí (admin only, chỉ nếu không có con)
   */
  app.delete("/api/criteria/:id", requireRole("admin"), async (req: Request, res: Response, next: NextFunction) => {
    try {
      await criteriaTreeStorage.deleteCriteria(req.params.id);
      res.json({ message: "Đã xóa tiêu chí thành công" });
    } catch (error: any) {
      if (error.message.includes("tiêu chí con") || error.message.includes("kết quả")) {
        return res.status(400).json({ message: error.message });
      }
      next(error);
    }
  });
  
  // ============================================
  // CRITERIA TARGETS (Giao chỉ tiêu)
  // ============================================
  
  /**
   * POST /api/criteria-targets
   * Giao chỉ tiêu cho đơn vị (admin, cluster_leader)
   */
  app.post("/api/criteria-targets", requireRole("admin", "cluster_leader"), async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as any;
      const target = req.body;
      
      // Cluster leaders can only set targets for their cluster's units
      if (user.role === "cluster_leader") {
        // TODO: Validate that unit belongs to user's cluster
      }
      
      const result = await criteriaTreeStorage.setCriteriaTarget(target);
      res.json(result);
    } catch (error: any) {
      next(error);
    }
  });
  
  /**
   * GET /api/criteria-targets
   * Lấy danh sách chỉ tiêu của đơn vị theo periodId
   */
  app.get("/api/criteria-targets", async (req: Request, res: Response, next: NextFunction) => {
    try {
      const unitId = req.query.unitId as string;
      const periodId = req.query.periodId as string;
      
      if (!unitId) {
        return res.status(400).json({ message: "Thiếu unitId" });
      }
      if (!periodId) {
        return res.status(400).json({ message: "Thiếu periodId" });
      }
      
      const targets = await criteriaTreeStorage.getCriteriaTargets(unitId, periodId);
      res.json(targets);
    } catch (error) {
      next(error);
    }
  });
  
  // ============================================
  // CRITERIA RESULTS (Kết quả chấm điểm)
  // ============================================
  
  /**
   * POST /api/criteria-results/input
   * Nhập kết quả chấm điểm (unit users)
   */
  app.post("/api/criteria-results/input", requireRole("user", "cluster_leader", "admin"), async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as any;
      const result: InsertCriteriaResult = req.body;
      
      // Users can only input for their own unit
      if (user.role === "user" && result.unitId !== user.unitId) {
        return res.status(403).json({ message: "Không có quyền nhập điểm cho đơn vị khác" });
      }
      
      const saved = await criteriaTreeStorage.saveCriteriaResult(result);
      
      // Tự động tính điểm cho tiêu chí định lượng (Type 1)
      const criteria = await criteriaTreeStorage.getCriteriaById(result.criteriaId);
      if (criteria && criteria.criteriaType === 1 && result.actualValue) {
        try {
          await criteriaTreeStorage.calculateCriteriaScore(
            result.criteriaId,
            result.unitId,
            result.periodId
          );
          
          // Lấy lại kết quả sau khi tính điểm
          const [updatedResult] = await db
            .select()
            .from(schema.criteriaResults)
            .where(and(
              eq(schema.criteriaResults.criteriaId, result.criteriaId),
              eq(schema.criteriaResults.unitId, result.unitId),
              eq(schema.criteriaResults.periodId, result.periodId)
            ))
            .limit(1);
          
          return res.json(updatedResult || saved);
        } catch (calcError) {
          // Nếu có lỗi khi tính điểm, vẫn trả về kết quả đã lưu
          console.error("Lỗi khi tính điểm tự động:", calcError);
        }
      }
      
      res.json(saved);
    } catch (error: any) {
      next(error);
    }
  });
  
  /**
   * POST /api/criteria-results/calc
   * Tính điểm tự động cho một tiêu chí theo periodId
   */
  app.post("/api/criteria-results/calc", requireRole("user", "cluster_leader", "admin"), async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { criteriaId, unitId, periodId } = req.body;
      
      if (!criteriaId || !unitId || !periodId) {
        return res.status(400).json({ message: "Thiếu criteriaId, unitId hoặc periodId" });
      }
      
      const score = await criteriaTreeStorage.calculateCriteriaScore(criteriaId, unitId, periodId);
      res.json({ score });
    } catch (error: any) {
      if (error.message.includes("không tồn tại") || error.message.includes("Chưa có")) {
        return res.status(400).json({ message: error.message });
      }
      next(error);
    }
  });
  
  /**
   * GET /api/criteria-results/summary
   * Lấy tổng hợp điểm của đơn vị theo periodId
   */
  app.get("/api/criteria-results/summary", async (req: Request, res: Response, next: NextFunction) => {
    try {
      const unitId = req.query.unitId as string;
      const periodId = req.query.periodId as string;
      
      if (!unitId) {
        return res.status(400).json({ message: "Thiếu unitId" });
      }
      if (!periodId) {
        return res.status(400).json({ message: "Thiếu periodId" });
      }
      
      const summary = await criteriaTreeStorage.calculateUnitTotalScore(unitId, periodId);
      res.json(summary);
    } catch (error) {
      next(error);
    }
  });
  
  /**
   * GET /api/criteria-results
   * Lấy kết quả chấm điểm của đơn vị theo periodId
   */
  app.get("/api/criteria-results", async (req: Request, res: Response, next: NextFunction) => {
    try {
      const unitId = req.query.unitId as string;
      const periodId = req.query.periodId as string;
      
      if (!unitId) {
        return res.status(400).json({ message: "Thiếu unitId" });
      }
      if (!periodId) {
        return res.status(400).json({ message: "Thiếu periodId" });
      }
      
      const results = await criteriaTreeStorage.getCriteriaResults(unitId, periodId);
      res.json(results);
    } catch (error) {
      next(error);
    }
  });
  
  /**
   * PUT /api/criteria-results/review
   * Cập nhật điểm thẩm định (cluster_score hoặc final_score) cho tiêu chí
   */
  app.put("/api/criteria-results/review", requireRole("cluster_leader", "admin"), async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as any;
      const { criteriaId, unitId, periodId, reviewType, score, comment } = req.body;
      
      if (!criteriaId || !unitId || !periodId || !reviewType) {
        return res.status(400).json({ message: "Thiếu thông tin bắt buộc" });
      }
      
      if (reviewType !== "review1" && reviewType !== "review2") {
        return res.status(400).json({ message: "reviewType phải là 'review1' hoặc 'review2'" });
      }
      
      // Cluster leaders can only review their own cluster's units
      if (user.role === "cluster_leader") {
        const unit = await db
          .select()
          .from(schema.units)
          .where(eq(schema.units.id, unitId))
          .limit(1);
        
        if (!unit[0] || unit[0].clusterId !== user.clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể thẩm định đơn vị trong cụm của mình" });
        }
      }
      
      // Tìm hoặc tạo criteria_result
      const [existing] = await db
        .select()
        .from(schema.criteriaResults)
        .where(and(
          eq(schema.criteriaResults.criteriaId, criteriaId),
          eq(schema.criteriaResults.unitId, unitId),
          eq(schema.criteriaResults.periodId, periodId)
        ))
        .limit(1);
      
      const updateData: any = {
        updatedAt: new Date(),
      };
      
      // Cập nhật cột tương ứng với loại thẩm định
      if (reviewType === "review1") {
        updateData.clusterScore = score !== undefined && score !== null ? score.toString() : null;
      } else {
        updateData.finalScore = score !== undefined && score !== null ? score.toString() : null;
      }
      
      // Update note: allow empty string to clear comment, null/undefined to skip update
      if (comment !== undefined && comment !== null) {
        updateData.note = comment.trim() === "" ? null : comment;
      }
      
      let result;
      if (existing) {
        // Update existing record
        const [updated] = await db
          .update(schema.criteriaResults)
          .set(updateData)
          .where(eq(schema.criteriaResults.id, existing.id))
          .returning();
        result = updated;
      } else {
        // Create new record
        const insertData: InsertCriteriaResult = {
          criteriaId,
          unitId,
          periodId,
          clusterScore: reviewType === "review1" ? (score !== undefined && score !== null ? score.toString() : null) : null,
          finalScore: reviewType === "review2" ? (score !== undefined && score !== null ? score.toString() : null) : null,
          // Normalize comment: empty string becomes null, undefined/null skipped
          note: (comment !== undefined && comment !== null) 
            ? (comment.trim() === "" ? null : comment)
            : undefined,
        };
        
        const [created] = await db
          .insert(schema.criteriaResults)
          .values(insertData)
          .returning();
        result = created;
      }
      
      res.json(result);
    } catch (error: any) {
      console.error("Error updating review score:", error);
      next(error);
    }
  });
}
