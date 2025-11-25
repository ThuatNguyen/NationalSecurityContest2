import { db } from "./db";
import { eq, and, sql as sqlExpr, inArray } from "drizzle-orm";
import * as schema from "@shared/schema";
import type { 
  User, InsertUser,
  Cluster, InsertCluster,
  Unit, InsertUnit,
  // CriteriaGroup, InsertCriteriaGroup, // OLD - removed with tree refactor
  // Criteria, InsertCriteria, // OLD - removed with tree refactor
  EvaluationPeriod, InsertEvaluationPeriod,
  Evaluation, InsertEvaluation,
  CriteriaResult, InsertCriteriaResult
} from "@shared/schema";

export interface IStorage {
  // Usersnpm install -g npm@11.6.2
  getUsers(): Promise<User[]>;
  getUser(id: string): Promise<User | undefined>;
  getUserByUsername(username: string): Promise<User | undefined>;
  createUser(user: InsertUser): Promise<User>;
  updateUser(id: string, user: Partial<InsertUser>): Promise<User | undefined>;
  deleteUser(id: string): Promise<void>;
  
  // Clusters
  getClusters(): Promise<Cluster[]>;
  getCluster(id: string): Promise<Cluster | undefined>;
  createCluster(cluster: InsertCluster): Promise<Cluster>;
  updateCluster(id: string, cluster: Partial<InsertCluster>): Promise<Cluster | undefined>;
  deleteCluster(id: string): Promise<void>;
  
  // Units
  getUnits(clusterId?: string): Promise<Unit[]>;
  getUnit(id: string): Promise<Unit | undefined>;
  createUnit(unit: InsertUnit): Promise<Unit>;
  updateUnit(id: string, unit: Partial<InsertUnit>): Promise<Unit | undefined>;
  deleteUnit(id: string): Promise<void>;
  
  // OLD CRITERIA GROUPS & CRITERIA METHODS - DISABLED
  // These methods use the old flat criteria_groups table structure
  // See server/criteriaTreeStorage.ts for new tree-based methods
  /*
  getCriteriaGroups(clusterId: string, year: number): Promise<CriteriaGroup[]>;
  getCriteriaGroup(id: string): Promise<CriteriaGroup | undefined>;
  createCriteriaGroup(group: InsertCriteriaGroup): Promise<CriteriaGroup>;
  updateCriteriaGroup(id: string, group: Partial<InsertCriteriaGroup>): Promise<CriteriaGroup | undefined>;
  deleteCriteriaGroup(id: string): Promise<void>;
  
  getCriteria(groupId: string): Promise<Criteria[]>;
  getCriteriaById(id: string): Promise<Criteria | undefined>;
  createCriteria(criteria: InsertCriteria): Promise<Criteria>;
  updateCriteria(id: string, criteria: Partial<InsertCriteria>): Promise<Criteria | undefined>;
  deleteCriteria(id: string): Promise<void>;
  */
  
  // Evaluation Periods
  getEvaluationPeriods(clusterId?: string): Promise<EvaluationPeriod[]>;
  getEvaluationPeriod(id: string): Promise<EvaluationPeriod | undefined>;
  createEvaluationPeriod(period: InsertEvaluationPeriod): Promise<EvaluationPeriod>;
  updateEvaluationPeriod(id: string, period: Partial<InsertEvaluationPeriod>): Promise<EvaluationPeriod | undefined>;
  deleteEvaluationPeriod(id: string): Promise<void>;
  
  // Evaluation Period Clusters (many-to-many)
  assignClustersToPeriod(periodId: string, clusterIds: string[]): Promise<void>;
  getPeriodsClustersList(periodId: string): Promise<Cluster[]>;
  removeClusterFromPeriod(periodId: string, clusterId: string): Promise<void>;
  
  // Competition Management - Initialize units
  initializeUnitsForPeriod(periodId: string, clusterIds?: string[]): Promise<{ created: number; existing: number }>;
  
  // Evaluations
  getEvaluations(periodId?: string, unitId?: string): Promise<Evaluation[]>;
  getEvaluation(id: string): Promise<Evaluation | undefined>;
  getEvaluationByPeriodUnit(periodId: string, unitId: string): Promise<Evaluation | undefined>;
  createEvaluation(evaluation: InsertEvaluation): Promise<Evaluation>;
  updateEvaluation(id: string, evaluation: Partial<InsertEvaluation>): Promise<Evaluation | undefined>;
  
  // Recalculation (transactional)
  recalculateEvaluationScoresTx(evaluationId: string): Promise<{ scoresUpdated: number }>;
  
  // Criteria Results (New scoring system)
  getCriteriaResult(criteriaId: string, unitId: string, periodId: string): Promise<CriteriaResult | undefined>;
  upsertCriteriaResult(result: InsertCriteriaResult): Promise<CriteriaResult>;
  getCriteriaResults(periodId: string, unitId: string): Promise<CriteriaResult[]>;
  
  // Reports - Criteria Matrix
  getCriteriaMatrix(periodId: string, clusterId: string): Promise<{
    criteriaHierarchy: Array<{
      id: string;
      code: string;
      displayCode: string;
      name: string;
      parentChain: Array<{ id: string; name: string; level: number }>;
      orderIndex: number;
    }>;
    units: Array<{
      unitId: string;
      unitShortName: string;
      unitName: string;
      scoresByCriteria: Record<string, { 
        selfScore: number | null; 
        clusterScore: number | null;
        isAssigned: boolean; // Tiêu chí có được giao cho đơn vị này không (user-declared)
        hasResult: boolean; // Đã chấm điểm hay chưa
      }>;
    }>;
  }>;
  
  // NEW EVALUATION SUMMARY METHOD - Tree-based
  getEvaluationSummaryTree(periodId: string, unitId: string): Promise<{
    period: EvaluationPeriod;
    evaluation: Evaluation | null;
    criteriaGroups: Array<{
      id: string;
      name: string;
      displayOrder: number;
      criteria: Array<{
        id: string;
        name: string;
        code?: string;
        level?: number;
        criteriaType?: number;
        maxScore: number;
        displayOrder: number;
        // New criteriaResults fields
        selfScore?: number;
        calculatedScore?: number;
        actualValue?: number;
        evidenceFile?: string | null;
        evidenceFileName?: string | null;
        note?: string | null;
        status?: string;
        // Legacy fields for backwards compatibility
        selfScoreFile?: string | null;
        review1Score?: number;
        review1Comment?: string | null;
        review1File?: string | null;
        review2Score?: number;
        review2Comment?: string | null;
        review2File?: string | null;
        finalScore?: number;
      }>;
    }>;
  } | null>;
  
  // OLD EVALUATION SUMMARY METHOD - DISABLED
  // This method uses the old flat criteria_groups table structure
  /*
  getEvaluationSummary(periodId: string, unitId: string): Promise<{
    period: EvaluationPeriod;
    evaluation: Evaluation | null;
    criteriaGroups: Array<{
      id: string;
      name: string;
      displayOrder: number;
      criteria: Array<{
        id: string;
        name: string;
        maxScore: string;
        displayOrder: number;
        selfScore?: string | null;
        selfScoreFile?: string | null;
        review1Score?: string | null;
        review1Comment?: string | null;
        review1File?: string | null;
        review2Score?: string | null;
        review2Comment?: string | null;
        review2File?: string | null;
        finalScore?: string | null;
      }>;
    }>;
  } | null>;
  */
}

export class DatabaseStorage implements IStorage {
  // Users
  async getUsers(): Promise<User[]> {
    return await db.select().from(schema.users);
  }

  async getUser(id: string): Promise<User | undefined> {
    const result = await db.select().from(schema.users).where(eq(schema.users.id, id)).limit(1);
    return result[0];
  }

  async getUserByUsername(username: string): Promise<User | undefined> {
    const result = await db.select().from(schema.users).where(eq(schema.users.username, username)).limit(1);
    return result[0];
  }

  async createUser(user: InsertUser): Promise<User> {
    const result = await db.insert(schema.users).values(user).returning();
    return result[0];
  }

  async updateUser(id: string, user: Partial<InsertUser>): Promise<User | undefined> {
    const result = await db.update(schema.users).set(user).where(eq(schema.users.id, id)).returning();
    return result[0];
  }

  async deleteUser(id: string): Promise<void> {
    await db.delete(schema.users).where(eq(schema.users.id, id));
  }

  // Clusters
  async getClusters(): Promise<Cluster[]> {
    return await db.select().from(schema.clusters);
  }

  async getCluster(id: string): Promise<Cluster | undefined> {
    const result = await db.select().from(schema.clusters).where(eq(schema.clusters.id, id)).limit(1);
    return result[0];
  }

  async createCluster(cluster: InsertCluster): Promise<Cluster> {
    // Check for duplicate name
    const existingByName = await db.select().from(schema.clusters)
      .where(eq(schema.clusters.name, cluster.name))
      .limit(1);
    if (existingByName.length > 0) {
      throw new Error('Tên cụm thi đua đã tồn tại');
    }
    
    // Check for duplicate short_name
    const existingByShortName = await db.select().from(schema.clusters)
      .where(eq(schema.clusters.shortName, cluster.shortName))
      .limit(1);
    if (existingByShortName.length > 0) {
      throw new Error('Tên viết tắt cụm thi đua đã tồn tại');
    }
    
    const result = await db.insert(schema.clusters).values(cluster).returning();
    return result[0];
  }

  async updateCluster(id: string, cluster: Partial<InsertCluster>): Promise<Cluster | undefined> {
    // Check for duplicate name (excluding current cluster)
    if (cluster.name) {
      const existingByName = await db.select().from(schema.clusters)
        .where(and(
          eq(schema.clusters.name, cluster.name),
          sqlExpr`${schema.clusters.id} != ${id}`
        ))
        .limit(1);
      if (existingByName.length > 0) {
        throw new Error('Tên cụm thi đua đã tồn tại');
      }
    }
    
    // Check for duplicate short_name (excluding current cluster)
    if (cluster.shortName) {
      const existingByShortName = await db.select().from(schema.clusters)
        .where(and(
          eq(schema.clusters.shortName, cluster.shortName),
          sqlExpr`${schema.clusters.id} != ${id}`
        ))
        .limit(1);
      if (existingByShortName.length > 0) {
        throw new Error('Tên viết tắt cụm thi đua đã tồn tại');
      }
    }
    
    const result = await db.update(schema.clusters).set({
      ...cluster,
      updatedAt: new Date(),
    }).where(eq(schema.clusters.id, id)).returning();
    return result[0];
  }

  async deleteCluster(id: string): Promise<void> {
    // Check if cluster has any units
    const units = await db.select().from(schema.units)
      .where(eq(schema.units.clusterId, id))
      .limit(1);
    
    if (units.length > 0) {
      throw new Error('Không thể xóa cụm thi đua vì đang có đơn vị trực thuộc');
    }
    
    await db.delete(schema.clusters).where(eq(schema.clusters.id, id));
  }

  // Units
  async getUnits(clusterId?: string): Promise<Unit[]> {
    if (clusterId) {
      return await db.select().from(schema.units).where(eq(schema.units.clusterId, clusterId));
    }
    return await db.select().from(schema.units);
  }

  async getUnit(id: string): Promise<Unit | undefined> {
    const result = await db.select().from(schema.units).where(eq(schema.units.id, id)).limit(1);
    return result[0];
  }

  async createUnit(unit: InsertUnit): Promise<Unit> {
    // Check for duplicate name
    const existingByName = await db.select().from(schema.units)
      .where(eq(schema.units.name, unit.name))
      .limit(1);
    if (existingByName.length > 0) {
      throw new Error('Tên đơn vị đã tồn tại');
    }
    
    // Check for duplicate short_name
    const existingByShortName = await db.select().from(schema.units)
      .where(eq(schema.units.shortName, unit.shortName))
      .limit(1);
    if (existingByShortName.length > 0) {
      throw new Error('Tên viết tắt đơn vị đã tồn tại');
    }
    
    const result = await db.insert(schema.units).values(unit).returning();
    return result[0];
  }

  async updateUnit(id: string, unit: Partial<InsertUnit>): Promise<Unit | undefined> {
    // Check for duplicate name (excluding current unit)
    if (unit.name) {
      const existingByName = await db.select().from(schema.units)
        .where(and(
          eq(schema.units.name, unit.name),
          sqlExpr`${schema.units.id} != ${id}`
        ))
        .limit(1);
      if (existingByName.length > 0) {
        throw new Error('Tên đơn vị đã tồn tại');
      }
    }
    
    // Check for duplicate short_name (excluding current unit)
    if (unit.shortName) {
      const existingByShortName = await db.select().from(schema.units)
        .where(and(
          eq(schema.units.shortName, unit.shortName),
          sqlExpr`${schema.units.id} != ${id}`
        ))
        .limit(1);
      if (existingByShortName.length > 0) {
        throw new Error('Tên viết tắt đơn vị đã tồn tại');
      }
    }
    
    const result = await db.update(schema.units).set({
      ...unit,
      updatedAt: new Date(),
    }).where(eq(schema.units.id, id)).returning();
    return result[0];
  }

  async deleteUnit(id: string): Promise<void> {
    // Check if unit has any evaluations (being used in scoring)
    const evaluations = await db.select().from(schema.evaluations)
      .where(eq(schema.evaluations.unitId, id))
      .limit(1);
    
    if (evaluations.length > 0) {
      throw new Error('Không thể xóa đơn vị vì đang được sử dụng trong đánh giá');
    }
    
    // Check if unit has any users
    const users = await db.select().from(schema.users)
      .where(eq(schema.users.unitId, id))
      .limit(1);
    
    if (users.length > 0) {
      throw new Error('Không thể xóa đơn vị vì đang có người dùng trực thuộc');
    }
    
    await db.delete(schema.units).where(eq(schema.units.id, id));
  }

  // OLD CRITERIA GROUPS & CRITERIA IMPLEMENTATIONS - DISABLED
  // These methods use the old flat criteria_groups table structure
  // See server/criteriaTreeStorage.ts for new tree-based methods
  /*
  async getCriteriaGroups(clusterId: string, year: number): Promise<CriteriaGroup[]> {
    return await db.select().from(schema.criteriaGroups)
      .where(and(
        eq(schema.criteriaGroups.clusterId, clusterId),
        eq(schema.criteriaGroups.year, year)
      ));
  }

  async getCriteriaGroup(id: string): Promise<CriteriaGroup | undefined> {
    const result = await db.select().from(schema.criteriaGroups).where(eq(schema.criteriaGroups.id, id)).limit(1);
    return result[0];
  }

  async createCriteriaGroup(group: InsertCriteriaGroup): Promise<CriteriaGroup> {
    const result = await db.insert(schema.criteriaGroups).values(group).returning();
    return result[0];
  }

  async updateCriteriaGroup(id: string, group: Partial<InsertCriteriaGroup>): Promise<CriteriaGroup | undefined> {
    const result = await db.update(schema.criteriaGroups).set(group).where(eq(schema.criteriaGroups.id, id)).returning();
    return result[0];
  }

  async deleteCriteriaGroup(id: string): Promise<void> {
    await db.delete(schema.criteriaGroups).where(eq(schema.criteriaGroups.id, id));
  }

  async getCriteria(groupId: string): Promise<Criteria[]> {
    return await db.select().from(schema.criteria).where(eq(schema.criteria.groupId, groupId));
  }

  async getCriteriaById(id: string): Promise<Criteria | undefined> {
    const result = await db.select().from(schema.criteria).where(eq(schema.criteria.id, id)).limit(1);
    return result[0];
  }

  async createCriteria(criteria: InsertCriteria): Promise<Criteria> {
    const result = await db.insert(schema.criteria).values(criteria).returning();
    return result[0];
  }

  async updateCriteria(id: string, criteria: Partial<InsertCriteria>): Promise<Criteria | undefined> {
    const result = await db.update(schema.criteria).set(criteria).where(eq(schema.criteria.id, id)).returning();
    return result[0];
  }

  async deleteCriteria(id: string): Promise<void> {
    await db.delete(schema.criteria).where(eq(schema.criteria.id, id));
  }
  */

  // Evaluation Periods
  async getEvaluationPeriods(clusterId?: string): Promise<EvaluationPeriod[]> {
    if (!clusterId) {
      // Admin: return all periods
      return await db.select().from(schema.evaluationPeriods);
    }
    
    // Non-admin: return only periods assigned to this cluster via evaluationPeriodClusters
    const periodClusters = await db.select()
      .from(schema.evaluationPeriodClusters)
      .where(eq(schema.evaluationPeriodClusters.clusterId, clusterId));
    
    if (periodClusters.length === 0) {
      return [];
    }
    
    const periodIds = periodClusters.map(pc => pc.periodId);
    return await db.select()
      .from(schema.evaluationPeriods)
      .where(inArray(schema.evaluationPeriods.id, periodIds));
  }

  async getEvaluationPeriod(id: string): Promise<EvaluationPeriod | undefined> {
    const result = await db.select().from(schema.evaluationPeriods).where(eq(schema.evaluationPeriods.id, id)).limit(1);
    return result[0];
  }

  async createEvaluationPeriod(period: InsertEvaluationPeriod): Promise<EvaluationPeriod> {
    const result = await db.insert(schema.evaluationPeriods).values(period).returning();
    return result[0];
  }

  async updateEvaluationPeriod(id: string, period: Partial<InsertEvaluationPeriod>): Promise<EvaluationPeriod | undefined> {
    const result = await db.update(schema.evaluationPeriods).set(period).where(eq(schema.evaluationPeriods.id, id)).returning();
    return result[0];
  }

  async deleteEvaluationPeriod(id: string): Promise<void> {
    await db.delete(schema.evaluationPeriods).where(eq(schema.evaluationPeriods.id, id));
  }

  // Evaluation Period Clusters (many-to-many mapping)
  async assignClustersToPeriod(periodId: string, clusterIds: string[]): Promise<void> {
    // Delete existing assignments
    await db.delete(schema.evaluationPeriodClusters)
      .where(eq(schema.evaluationPeriodClusters.periodId, periodId));
    
    // Insert new assignments
    if (clusterIds.length > 0) {
      await db.insert(schema.evaluationPeriodClusters).values(
        clusterIds.map(clusterId => ({
          periodId,
          clusterId,
        }))
      );
    }
  }

  async getPeriodsClustersList(periodId: string): Promise<Cluster[]> {
    const result = await db
      .select({
        id: schema.clusters.id,
        name: schema.clusters.name,
        createdAt: schema.clusters.createdAt,
      })
      .from(schema.evaluationPeriodClusters)
      .innerJoin(schema.clusters, eq(schema.evaluationPeriodClusters.clusterId, schema.clusters.id))
      .where(eq(schema.evaluationPeriodClusters.periodId, periodId));
    
    return result as Cluster[];
  }

  async removeClusterFromPeriod(periodId: string, clusterId: string): Promise<void> {
    await db.delete(schema.evaluationPeriodClusters)
      .where(
        and(
          eq(schema.evaluationPeriodClusters.periodId, periodId),
          eq(schema.evaluationPeriodClusters.clusterId, clusterId)
        )
      );
  }

  // Competition Management - Initialize units for period
  async initializeUnitsForPeriod(periodId: string, clusterIds?: string[]): Promise<{ created: number; existing: number }> {
    // Get clusters for this period
    let targetClusters: string[];
    if (clusterIds && clusterIds.length > 0) {
      targetClusters = clusterIds;
    } else {
      const periodClusters = await db
        .select({ clusterId: schema.evaluationPeriodClusters.clusterId })
        .from(schema.evaluationPeriodClusters)
        .where(eq(schema.evaluationPeriodClusters.periodId, periodId));
      targetClusters = periodClusters.map(pc => pc.clusterId);
    }

    let created = 0;
    let existing = 0;

    // For each cluster, get all units and create evaluations
    for (const clusterId of targetClusters) {
      const units = await this.getUnits(clusterId);
      
      for (const unit of units) {
        // Check if evaluation already exists
        const existingEval = await db
          .select()
          .from(schema.evaluations)
          .where(
            and(
              eq(schema.evaluations.periodId, periodId),
              eq(schema.evaluations.unitId, unit.id)
            )
          )
          .limit(1);

        if (existingEval.length === 0) {
          await db.insert(schema.evaluations).values({
            periodId,
            clusterId,
            unitId: unit.id,
            status: "draft",
          });
          created++;
        } else {
          existing++;
        }
      }
    }

    return { created, existing };
  }

  // Evaluations
  async getEvaluations(periodId?: string, unitId?: string): Promise<Evaluation[]> {
    const conditions = [];
    if (periodId) {
      conditions.push(eq(schema.evaluations.periodId, periodId));
    }
    if (unitId) {
      conditions.push(eq(schema.evaluations.unitId, unitId));
    }
    
    if (conditions.length > 0) {
      return await db.select().from(schema.evaluations).where(and(...conditions));
    }
    return await db.select().from(schema.evaluations);
  }

  async getEvaluation(id: string): Promise<Evaluation | undefined> {
    const result = await db.select().from(schema.evaluations).where(eq(schema.evaluations.id, id)).limit(1);
    return result[0];
  }

  async getEvaluationByPeriodUnit(periodId: string, unitId: string): Promise<Evaluation | undefined> {
    const result = await db.select().from(schema.evaluations)
      .where(and(
        eq(schema.evaluations.periodId, periodId),
        eq(schema.evaluations.unitId, unitId)
      ))
      .limit(1);
    return result[0];
  }

  async createEvaluation(evaluation: InsertEvaluation): Promise<Evaluation> {
    const result = await db.insert(schema.evaluations).values(evaluation).returning();
    return result[0];
  }

  async updateEvaluation(id: string, evaluation: Partial<InsertEvaluation>): Promise<Evaluation | undefined> {
    const result = await db.update(schema.evaluations).set(evaluation).where(eq(schema.evaluations.id, id)).returning();
    return result[0];
  }

  // OLD EVALUATION SUMMARY IMPLEMENTATION - DISABLED
  // This method uses the old flat criteria_groups table structure
  /*
  async getEvaluationSummary(periodId: string, unitId: string) {
    // 1. Fetch period (fail fast if missing)
    const period = await this.getEvaluationPeriod(periodId);
    if (!period) {
      return null;
    }

    // 2. Fetch evaluation for this period and unit (may be null)
    const evaluations = await this.getEvaluations(periodId, unitId);
    const evaluation = evaluations.length > 0 ? evaluations[0] : null;

    // 3. Single query: JOIN criteria_groups, criteria, and scores
    // This eliminates N+1 queries and ensures proper ordering
    // When no evaluation exists, scores will be null (no data leak)
    const rows = await db
      .select({
        groupId: schema.criteriaGroups.id,
        groupName: schema.criteriaGroups.name,
        groupDisplayOrder: schema.criteriaGroups.displayOrder,
        criteriaId: schema.criteria.id,
        criteriaName: schema.criteria.name,
        criteriaMaxScore: schema.criteria.maxScore,
        criteriaDisplayOrder: schema.criteria.displayOrder,
        selfScore: schema.scores.selfScore,
        selfScoreFile: schema.scores.selfScoreFile,
        review1Score: schema.scores.review1Score,
        review1Comment: schema.scores.review1Comment,
        review1File: schema.scores.review1File,
        review2Score: schema.scores.review2Score,
        review2Comment: schema.scores.review2Comment,
        review2File: schema.scores.review2File,
        finalScore: schema.scores.finalScore,
      })
      .from(schema.criteriaGroups)
      .innerJoin(schema.criteria, eq(schema.criteria.groupId, schema.criteriaGroups.id))
      .leftJoin(
        schema.scores,
        evaluation
          ? and(
              eq(schema.scores.criteriaId, schema.criteria.id),
              eq(schema.scores.evaluationId, evaluation.id)
            )
          : sqlExpr`false` // No evaluation = no scores (prevents data leak)
      )
      .where(
        and(
          eq(schema.criteriaGroups.clusterId, period.clusterId),
          eq(schema.criteriaGroups.year, period.year)
        )
      )
      .orderBy(schema.criteriaGroups.displayOrder, schema.criteria.displayOrder);

    // 4. Regroup rows by criteria group
    const groupMap = new Map<string, {
      id: string;
      name: string;
      displayOrder: number;
      criteria: Array<{
        id: string;
        name: string;
        maxScore: string;
        displayOrder: number;
        selfScore?: string | null;
        selfScoreFile?: string | null;
        review1Score?: string | null;
        review1Comment?: string | null;
        review1File?: string | null;
        review2Score?: string | null;
        review2Comment?: string | null;
        review2File?: string | null;
        finalScore?: string | null;
      }>;
    }>();

    for (const row of rows) {
      let group = groupMap.get(row.groupId);
      if (!group) {
        group = {
          id: row.groupId,
          name: row.groupName,
          displayOrder: row.groupDisplayOrder,
          criteria: [],
        };
        groupMap.set(row.groupId, group);
      }

      group.criteria.push({
        id: row.criteriaId,
        name: row.criteriaName,
        maxScore: row.criteriaMaxScore,
        displayOrder: row.criteriaDisplayOrder,
        selfScore: row.selfScore,
        selfScoreFile: row.selfScoreFile,
        review1Score: row.review1Score,
        review1Comment: row.review1Comment,
        review1File: row.review1File,
        review2Score: row.review2Score,
        review2Comment: row.review2Comment,
        review2File: row.review2File,
        finalScore: row.finalScore,
      });
    }

    const criteriaGroups = Array.from(groupMap.values());

    return {
      period,
      evaluation,
      criteriaGroups,
    };
  }
  */

  // OLD RECALCULATE METHOD - DISABLED (uses deleted scores table)
  /*
  async recalculateEvaluationScoresTx(evaluationId: string): Promise<{ scoresUpdated: number }> {
    return await db.transaction(async (tx) => {
      // Fetch all scores for this evaluation within transaction
      const scores = await tx.select().from(schema.scores).where(eq(schema.scores.evaluationId, evaluationId));
      
      // Precompute finalScore and totals in memory
      let totalSelfScore = 0;
      let totalReview1Score = 0;
      let totalReview2Score = 0;
      let totalFinalScore = 0;
      
      // Track whether we have ANY review scores (to distinguish 0 from null)
      let hasAnyReview1 = false;
      let hasAnyReview2 = false;
      
      const updates: Array<{ id: string; finalScore: string }> = [];
      
      for (const score of scores) {
        const selfScore = score.selfScore ? parseFloat(score.selfScore) : 0;
        const review1Score = score.review1Score ? parseFloat(score.review1Score) : null;
        const review2Score = score.review2Score ? parseFloat(score.review2Score) : null;
        
        // Calculate finalScore using MAX logic
        let finalScore: number;
        if (review1Score !== null && review2Score !== null) {
          finalScore = Math.max(review1Score, review2Score);
        } else if (review1Score !== null) {
          finalScore = review1Score;
        } else if (review2Score !== null) {
          finalScore = review2Score;
        } else {
          finalScore = selfScore;
        }
        
        updates.push({ id: score.id, finalScore: finalScore.toString() });
        
        // Accumulate totals
        totalSelfScore += selfScore;
        if (review1Score !== null) {
          totalReview1Score += review1Score;
          hasAnyReview1 = true;
        }
        if (review2Score !== null) {
          totalReview2Score += review2Score;
          hasAnyReview2 = true;
        }
        totalFinalScore += finalScore;
      }
      
      // Update all scores within transaction
      for (const update of updates) {
        await tx.update(schema.scores).set({ finalScore: update.finalScore }).where(eq(schema.scores.id, update.id));
      }
      
      // Update evaluation totals within same transaction
      // Preserve zero totals (scored as zero) vs null (not scored)
      await tx.update(schema.evaluations).set({
        totalSelfScore: totalSelfScore.toString(),
        totalReview1Score: hasAnyReview1 ? totalReview1Score.toString() : null,
        totalReview2Score: hasAnyReview2 ? totalReview2Score.toString() : null,
        totalFinalScore: totalFinalScore.toString(),
      }).where(eq(schema.evaluations.id, evaluationId));
      
      return { scoresUpdated: scores.length };
    });
  }
  */

  // NEW EVALUATION SUMMARY METHOD - Tree-based criteria
  async getEvaluationSummaryTree(periodId: string, unitId: string) {
    // Get evaluation period
    const period = await this.getEvaluationPeriod(periodId);
    if (!period) return null;

    // Get unit to determine cluster
    const unit = await this.getUnit(unitId);
    if (!unit) return null;

    // Get evaluation (or return null if not exists yet)
    const evaluation = await this.getEvaluationByPeriodUnit(periodId, unitId) || null;

    // Get criteria tree for this period and UNIT'S cluster
    const criteriaTreeStorage = (await import('./criteriaTreeStorage')).criteriaTreeStorage;
    const criteriaTree = await criteriaTreeStorage.getCriteriaTree(periodId, unit.clusterId);

    // Get all criteria results (new system) for this period+unit
    const criteriaResults = await this.getCriteriaResults(periodId, unitId);
    const resultsMap = new Map(criteriaResults.map(r => [r.criteriaId, r]));
    
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
    
    // Old scores table removed - all data now in criteriaResults
    const scoresMap = new Map<string, any>();
    // Keep empty map for backwards compatibility with code below

    // Transform tree into flat groups by level 1 nodes
    const flattenTree = (node: any, parentPath: string = '', parentNodeId: string | null = null): any[] => {
      const currentPath = parentPath ? `${parentPath}.${node.orderIndex}` : node.code || node.id.substring(0, 8);
      const result = resultsMap.get(node.id);
      const target = targetsMap.get(node.id);
      const oldScore = scoresMap.get(node.id); // Get review data from old scores table

      // Log review score mapping
      if (result?.clusterScore || result?.finalScore) {
        console.log(`[STORAGE] Criteria ${node.id} (${node.name}) review scores:`, {
          clusterScore: result.clusterScore,
          finalScore: result.finalScore,
          oldScoreReview1: oldScore?.review1Score,
          oldScoreReview2: oldScore?.review2Score,
        });
      }

      const flatNode = {
        id: node.id,
        parentId: parentNodeId, // Use the passed parent ID from recursion
        name: node.name,
        maxScore: parseFloat(node.maxScore),
        displayOrder: node.orderIndex,
        level: node.level,
        criteriaType: node.criteriaType, // Add criteriaType to identify leaf criteria
        code: node.code || currentPath,
        // Use new criteriaResults fields
        selfScore: result?.selfScore ? parseFloat(result.selfScore) : undefined,
        calculatedScore: result?.calculatedScore ? parseFloat(result.calculatedScore) : undefined,
        actualValue: result?.actualValue ? parseFloat(result.actualValue) : undefined,
        targetValue: target?.targetValue !== null && target?.targetValue !== undefined ? parseFloat(target.targetValue) : undefined, // Add target value (handle 0)
        isAssigned: result?.isAssigned ?? true, // Add isAssigned flag (default true for backwards compatibility)
        evidenceFile: result?.evidenceFile || null,
        evidenceFileName: result?.evidenceFileName || null, // Display name for evidence file
        note: result?.note || null,
        status: result?.status || 'draft',
        // Old fields for backwards compatibility (if needed)
        selfScoreFile: result?.evidenceFile || null,
        review1Score: result?.clusterScore ? parseFloat(result.clusterScore) : undefined, // Cluster score = review1
        review1Comment: oldScore?.review1Comment || null, // Get from old scores table
        review1File: oldScore?.review1File || null, // Get from old scores table
        review2Score: result?.finalScore ? parseFloat(result.finalScore) : undefined, // Final score = review2
        review2Comment: oldScore?.review2Comment || null, // Get from old scores table
        review2File: oldScore?.review2File || null, // Get from old scores table
        finalScore: result?.finalScore ? parseFloat(result.finalScore) : undefined,
      };

      // Recursively flatten children, passing current node's ID as their parent
      const childrenFlat = (node.children || []).flatMap((child: any) => 
        flattenTree(child, currentPath, node.id)
      );

      return [flatNode, ...childrenFlat];
    };

    // Group by level 1 nodes
    const criteriaGroups = criteriaTree.map((level1Node, index) => ({
      id: level1Node.id,
      name: level1Node.name,
      displayOrder: level1Node.orderIndex,
      criteria: flattenTree(level1Node)
    }));

    return {
      period,
      evaluation,
      criteriaGroups,
    };
  }

  // Criteria Results (New scoring system)
  async getCriteriaResult(criteriaId: string, unitId: string, periodId: string): Promise<CriteriaResult | undefined> {
    const results = await db
      .select()
      .from(schema.criteriaResults)
      .where(
        and(
          eq(schema.criteriaResults.criteriaId, criteriaId),
          eq(schema.criteriaResults.unitId, unitId),
          eq(schema.criteriaResults.periodId, periodId)
        )
      )
      .limit(1);
    return results[0];
  }

  async upsertCriteriaResult(result: InsertCriteriaResult): Promise<CriteriaResult> {
    // Check if exists
    const existing = await this.getCriteriaResult(result.criteriaId, result.unitId, result.periodId);
    
    if (existing) {
      // Update: preserve status unless explicitly changed
      const updateData: any = { ...result, updatedAt: new Date() };
      if (!result.status) {
        updateData.status = existing.status; // Preserve existing status
      }
      
      const updated = await db
        .update(schema.criteriaResults)
        .set(updateData)
        .where(eq(schema.criteriaResults.id, existing.id))
        .returning();
      return updated[0];
    } else {
      // Insert: use provided status or default to 'draft'
      const insertData: any = { ...result };
      if (!insertData.status) {
        insertData.status = 'draft';
      }
      
      const inserted = await db
        .insert(schema.criteriaResults)
        .values(insertData)
        .returning();
      return inserted[0];
    }
  }

  async getCriteriaResults(periodId: string, unitId: string): Promise<CriteriaResult[]> {
    return await db
      .select()
      .from(schema.criteriaResults)
      .where(
        and(
          eq(schema.criteriaResults.periodId, periodId),
          eq(schema.criteriaResults.unitId, unitId)
        )
      );
  }

  async getCriteriaMatrix(periodId: string, clusterId: string) {
    // 1. Get all units in this cluster
    const units = await db
      .select({
        id: schema.units.id,
        shortName: schema.units.shortName,
        name: schema.units.name,
      })
      .from(schema.units)
      .where(eq(schema.units.clusterId, clusterId))
      .orderBy(schema.units.shortName);

    // 2. Get all leaf criteria (criteriaType 1-4) for this period and cluster
    const leafCriteria = await db
      .select()
      .from(schema.criteria)
      .where(
        and(
          eq(schema.criteria.periodId, periodId),
          eq(schema.criteria.clusterId, clusterId),
          sqlExpr`${schema.criteria.criteriaType} IN (1, 2, 3, 4)`
        )
      )
      .orderBy(schema.criteria.orderIndex);

    // 3. Build parent chain for each criteria
    const allCriteria = await db
      .select()
      .from(schema.criteria)
      .where(
        and(
          eq(schema.criteria.periodId, periodId),
          eq(schema.criteria.clusterId, clusterId)
        )
      );

    const criteriaMap = new Map(allCriteria.map(c => [c.id, c]));

    const buildParentChain = (criteriaId: string): Array<{ id: string; name: string; level: number }> => {
      const chain: Array<{ id: string; name: string; level: number }> = [];
      let current = criteriaMap.get(criteriaId);
      
      while (current && current.parentId) {
        const parent = criteriaMap.get(current.parentId);
        if (parent) {
          chain.unshift({ id: parent.id, name: parent.name, level: parent.level });
          current = parent;
        } else {
          break;
        }
      }
      
      return chain;
    };

    // 4. Build criteria hierarchy with display codes (TC1, TC2, ...)
    const criteriaHierarchy = leafCriteria.map((criteria, index) => ({
      id: criteria.id,
      code: criteria.code || `TC${index + 1}`,
      displayCode: `TC${index + 1}`,
      name: criteria.name,
      parentChain: buildParentChain(criteria.id),
      orderIndex: criteria.orderIndex,
    }));

    // 5. Get all criteria results for this period, cluster, and units
    const unitIds = units.map(u => u.id);
    const criteriaIds = leafCriteria.map(c => c.id);

    const criteriaResults = unitIds.length > 0 && criteriaIds.length > 0
      ? await db
          .select()
          .from(schema.criteriaResults)
          .where(
            and(
              eq(schema.criteriaResults.periodId, periodId),
              inArray(schema.criteriaResults.unitId, unitIds),
              inArray(schema.criteriaResults.criteriaId, criteriaIds)
            )
          )
      : [];

    // 5.1 Get criteria targets to check if unit has target assigned
    const criteriaTargets = unitIds.length > 0 && criteriaIds.length > 0
      ? await db
          .select()
          .from(schema.criteriaTargets)
          .where(
            and(
              eq(schema.criteriaTargets.periodId, periodId),
              inArray(schema.criteriaTargets.unitId, unitIds),
              inArray(schema.criteriaTargets.criteriaId, criteriaIds)
            )
          )
      : [];

    // Build map: unitId+criteriaId -> targetValue
    const targetMap = new Map<string, number>();
    criteriaTargets.forEach(target => {
      const key = `${target.unitId}_${target.criteriaId}`;
      targetMap.set(key, parseFloat(target.targetValue));
    });

    // 6. Group scores by unit - include ALL units even if they have no scores
    const unitsData = units.map(unit => {
      const scoresByCriteria: Record<string, { 
        selfScore: number | null; 
        clusterScore: number | null;
        isAssigned: boolean;
        hasResult: boolean; // Đã chấm điểm hay chưa
      }> = {};
      
      // Pre-fill all criteria with null scores
      leafCriteria.forEach(criteria => {
        scoresByCriteria[criteria.id] = {
          selfScore: null,
          clusterScore: null,
          isAssigned: true, // Default: assumed assigned
          hasResult: false, // Chưa chấm
        };
      });

      // Override with actual results where they exist
      criteriaResults.forEach(result => {
        if (result.unitId === unit.id && scoresByCriteria[result.criteriaId]) {
          scoresByCriteria[result.criteriaId].selfScore = result.selfScore ? parseFloat(result.selfScore) : null;
          scoresByCriteria[result.criteriaId].clusterScore = result.clusterScore ? parseFloat(result.clusterScore) : null;
          scoresByCriteria[result.criteriaId].hasResult = true; // Có kết quả rồi
          
          // Use isAssigned from database (defaults to true if not set)
          scoresByCriteria[result.criteriaId].isAssigned = result.isAssigned ?? true;
        }
      });

      return {
        unitId: unit.id,
        unitShortName: unit.shortName,
        unitName: unit.name,
        scoresByCriteria,
      };
    });

    return {
      criteriaHierarchy,
      units: unitsData,
    };
  }
}

export const storage = new DatabaseStorage();
