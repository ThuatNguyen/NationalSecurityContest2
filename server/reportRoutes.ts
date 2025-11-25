import type { Express, Request, Response, NextFunction } from "express";
import { storage } from "./storage";
import { db } from "./db";
import { eq, and, inArray } from "drizzle-orm";
import * as schema from "@shared/schema";
import { z } from "zod";
import ExcelJS from "exceljs";

/**
 * Report Routes for comprehensive reporting system
 * - Summary reports (overview by groups)
 * - Detailed reports (vertical layout with criteria tree)
 * - Excel export with multiple sheets
 */

interface RequireAuthMiddleware {
  (req: Request, res: Response, next: NextFunction): void;
}

export function registerReportRoutes(app: Express, requireAuth: RequireAuthMiddleware) {
  
  /**
   * GET /api/reports/summary
   * Get summary report - overview of all groups with total scores
   * Query params: periodId, clusterId
   */
  app.get("/api/reports/summary", requireAuth, async (req, res, next) => {
    try {
      const { periodId, clusterId } = z.object({
        periodId: z.string(),
        clusterId: z.string(),
      }).parse(req.query);

      // Permission check
      if (req.user!.role !== "admin") {
        const userClusterId = req.user!.role === "cluster_leader" 
          ? req.user!.clusterId 
          : (await storage.getUnit(req.user!.unitId!))?.clusterId;

        if (userClusterId !== clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xem báo cáo cụm của mình" });
        }
      }

      // Get period and cluster info
      const period = await storage.getEvaluationPeriod(periodId);
      const cluster = await storage.getCluster(clusterId);
      if (!period || !cluster) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua hoặc cụm" });
      }

      // Get units in cluster
      const units = await db
        .select()
        .from(schema.units)
        .where(eq(schema.units.clusterId, clusterId))
        .orderBy(schema.units.name);

      // Get criteria tree (level 1 groups)
      const criteriaTreeStorage = (await import('./criteriaTreeStorage')).criteriaTreeStorage;
      const criteriaTree = await criteriaTreeStorage.getCriteriaTree(periodId, clusterId);

      // Get all criteria results for all units
      const criteriaResults = await db
        .select()
        .from(schema.criteriaResults)
        .where(
          and(
            eq(schema.criteriaResults.periodId, periodId),
            inArray(schema.criteriaResults.unitId, units.map(u => u.id))
          )
        );

      // Build results map: unitId -> criteriaId -> result
      const resultsMap = new Map<string, Map<string, any>>();
      for (const result of criteriaResults) {
        if (!resultsMap.has(result.unitId)) {
          resultsMap.set(result.unitId, new Map());
        }
        resultsMap.get(result.unitId)!.set(result.criteriaId, result);
      }

      // Calculate summary for each unit
      const calculateGroupScore = (groupNode: any, unitResults: Map<string, any>): any => {
        let selfScore = 0;
        let clusterScore = 0;
        let finalScore = 0;
        let hasData = false;

        const processNode = (node: any): void => {
          if (node.children && node.children.length > 0) {
            // Parent node - recursively process children
            node.children.forEach((child: any) => processNode(child));
          } else {
            // Leaf node - get actual score
            const result = unitResults.get(node.id);
            if (result) {
              if (result.selfScore) {
                selfScore += parseFloat(result.selfScore);
                hasData = true;
              }
              if (result.clusterScore) {
                clusterScore += parseFloat(result.clusterScore);
                hasData = true;
              }
              if (result.finalScore) {
                finalScore += parseFloat(result.finalScore);
                hasData = true;
              }
            }
          }
        };

        processNode(groupNode);

        return {
          selfScore: hasData ? selfScore : null,
          clusterScore: hasData ? clusterScore : null,
          finalScore: hasData ? finalScore : null,
        };
      };

      // Build summary data
      const summaryData = units.map(unit => {
        const unitResults = resultsMap.get(unit.id) || new Map();
        
        const groups = criteriaTree.map(groupNode => {
          const scores = calculateGroupScore(groupNode, unitResults);
          return {
            groupId: groupNode.id,
            groupName: groupNode.name,
            groupMaxScore: parseFloat(groupNode.maxScore),
            ...scores,
          };
        });

        // Calculate totals
        const totals = {
          selfScore: groups.reduce((sum, g) => sum + (g.selfScore || 0), 0),
          clusterScore: groups.reduce((sum, g) => sum + (g.clusterScore || 0), 0),
          finalScore: groups.reduce((sum, g) => sum + (g.finalScore || 0), 0),
        };

        return {
          unitId: unit.id,
          unitName: unit.name,
          groups,
          totals,
        };
      });

      res.json({
        period,
        cluster,
        units: summaryData,
        criteriaGroups: criteriaTree.map(g => ({
          id: g.id,
          name: g.name,
          maxScore: parseFloat(g.maxScore),
        })),
      });
    } catch (error) {
      console.error("Error in /api/reports/summary:", error);
      next(error);
    }
  });

  /**
   * GET /api/reports/group-detail
   * Get detailed report for a specific group (vertical layout with criteria tree)
   * Query params: periodId, clusterId, groupId (optional - if not provided, return all groups)
   */
  app.get("/api/reports/group-detail", requireAuth, async (req, res, next) => {
    try {
      const { periodId, clusterId, groupId } = z.object({
        periodId: z.string(),
        clusterId: z.string(),
        groupId: z.string().optional(),
      }).parse(req.query);

      // Permission check
      if (req.user!.role !== "admin") {
        const userClusterId = req.user!.role === "cluster_leader" 
          ? req.user!.clusterId 
          : (await storage.getUnit(req.user!.unitId!))?.clusterId;

        if (userClusterId !== clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xem báo cáo cụm của mình" });
        }
      }

      // Get period and cluster info
      const period = await storage.getEvaluationPeriod(periodId);
      const cluster = await storage.getCluster(clusterId);
      if (!period || !cluster) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua hoặc cụm" });
      }

      // Get units in cluster
      const units = await db
        .select()
        .from(schema.units)
        .where(eq(schema.units.clusterId, clusterId))
        .orderBy(schema.units.name);

      // Get criteria tree
      const criteriaTreeStorage = (await import('./criteriaTreeStorage')).criteriaTreeStorage;
      const fullTree = await criteriaTreeStorage.getCriteriaTree(periodId, clusterId);

      // Filter to specific group if requested
      const criteriaTree = groupId 
        ? fullTree.filter(g => g.id === groupId)
        : fullTree;

      if (criteriaTree.length === 0) {
        return res.status(404).json({ message: "Không tìm thấy nhóm tiêu chí" });
      }

      // Get all criteria IDs in the tree (flatten)
      const getAllCriteriaIds = (node: any): string[] => {
        const ids = [node.id];
        if (node.children) {
          node.children.forEach((child: any) => {
            ids.push(...getAllCriteriaIds(child));
          });
        }
        return ids;
      };

      const criteriaIds = criteriaTree.flatMap(g => getAllCriteriaIds(g));

      // Get all criteria results for these criteria and units
      const criteriaResults = await db
        .select()
        .from(schema.criteriaResults)
        .where(
          and(
            eq(schema.criteriaResults.periodId, periodId),
            inArray(schema.criteriaResults.unitId, units.map(u => u.id)),
            inArray(schema.criteriaResults.criteriaId, criteriaIds)
          )
        );

      // Get criteria targets
      const criteriaTargets = await db
        .select()
        .from(schema.criteriaTargets)
        .where(
          and(
            eq(schema.criteriaTargets.periodId, periodId),
            inArray(schema.criteriaTargets.unitId, units.map(u => u.id)),
            inArray(schema.criteriaTargets.criteriaId, criteriaIds)
          )
        );

      // Build maps
      const resultsMap = new Map<string, Map<string, any>>();
      for (const result of criteriaResults) {
        const key = `${result.unitId}-${result.criteriaId}`;
        if (!resultsMap.has(result.unitId)) {
          resultsMap.set(result.unitId, new Map());
        }
        resultsMap.get(result.unitId)!.set(result.criteriaId, result);
      }

      const targetsMap = new Map<string, any>();
      for (const target of criteriaTargets) {
        const key = `${target.unitId}-${target.criteriaId}`;
        targetsMap.set(key, target);
      }

      // Build hierarchical criteria rows with unit scores
      const buildCriteriaRows = (node: any, level: number = 1, parentNumber: string = ""): any[] => {
        const nodeNumber = parentNumber ? `${parentNumber}.${node.orderIndex || ''}` : `${node.orderIndex || ''}`;
        
        // Parent row
        const parentRow: any = {
          criteriaId: node.id,
          criteriaNumber: nodeNumber,
          criteriaName: node.name,
          level,
          maxScore: parseFloat(node.maxScore),
          criteriaType: node.criteriaType,
          isParent: node.children && node.children.length > 0,
          units: {} as any,
        };

        // Add unit scores for this criteria
        units.forEach(unit => {
          const result = resultsMap.get(unit.id)?.get(node.id);
          const target = targetsMap.get(`${unit.id}-${node.id}`);
          
          parentRow.units[unit.id] = {
            isAssigned: result?.isAssigned ?? true,
            targetValue: target?.targetValue,
            actualValue: result?.actualValue ? parseFloat(result.actualValue) : null,
            selfScore: result?.selfScore ? parseFloat(result.selfScore) : null,
            clusterScore: result?.clusterScore ? parseFloat(result.clusterScore) : null,
            finalScore: result?.finalScore ? parseFloat(result.finalScore) : null,
            note: result?.note || null,
          };
        });

        const rows = [parentRow];

        // Recursively add children
        if (node.children && node.children.length > 0) {
          node.children.forEach((child: any) => {
            rows.push(...buildCriteriaRows(child, level + 1, nodeNumber));
          });
        }

        return rows;
      };

      const detailData = criteriaTree.map(groupNode => ({
        groupId: groupNode.id,
        groupName: groupNode.name,
        groupMaxScore: parseFloat(groupNode.maxScore),
        criteriaRows: buildCriteriaRows(groupNode, 1),
      }));

      res.json({
        period,
        cluster,
        units: units.map(u => ({ id: u.id, name: u.name })),
        groups: detailData,
      });
    } catch (error) {
      console.error("Error in /api/reports/group-detail:", error);
      next(error);
    }
  });

  /**
   * GET /api/reports/export-excel
   * Export comprehensive report to Excel with multiple sheets
   * Query params: periodId, clusterId
   */
  app.get("/api/reports/export-excel", requireAuth, async (req, res, next) => {
    try {
      const { periodId, clusterId } = z.object({
        periodId: z.string(),
        clusterId: z.string(),
      }).parse(req.query);

      // Permission check
      if (req.user!.role !== "admin") {
        const userClusterId = req.user!.role === "cluster_leader" 
          ? req.user!.clusterId 
          : (await storage.getUnit(req.user!.unitId!))?.clusterId;

        if (userClusterId !== clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xuất báo cáo cụm của mình" });
        }
      }

      // Get data using the same logic as summary and detail endpoints
      const period = await storage.getEvaluationPeriod(periodId);
      const cluster = await storage.getCluster(clusterId);
      if (!period || !cluster) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua hoặc cụm" });
      }

      const units = await db
        .select()
        .from(schema.units)
        .where(eq(schema.units.clusterId, clusterId))
        .orderBy(schema.units.name);

      const criteriaTreeStorage = (await import('./criteriaTreeStorage')).criteriaTreeStorage;
      const criteriaTree = await criteriaTreeStorage.getCriteriaTree(periodId, clusterId);

      // Get all criteria results
      const getAllCriteriaIds = (node: any): string[] => {
        const ids = [node.id];
        if (node.children) {
          node.children.forEach((child: any) => ids.push(...getAllCriteriaIds(child)));
        }
        return ids;
      };

      const criteriaIds = criteriaTree.flatMap(g => getAllCriteriaIds(g));

      const criteriaResults = await db
        .select()
        .from(schema.criteriaResults)
        .where(
          and(
            eq(schema.criteriaResults.periodId, periodId),
            inArray(schema.criteriaResults.unitId, units.map(u => u.id)),
            inArray(schema.criteriaResults.criteriaId, criteriaIds)
          )
        );

      const criteriaTargets = await db
        .select()
        .from(schema.criteriaTargets)
        .where(
          and(
            eq(schema.criteriaTargets.periodId, periodId),
            inArray(schema.criteriaTargets.unitId, units.map(u => u.id)),
            inArray(schema.criteriaTargets.criteriaId, criteriaIds)
          )
        );

      // Build maps
      const resultsMap = new Map<string, Map<string, any>>();
      for (const result of criteriaResults) {
        if (!resultsMap.has(result.unitId)) {
          resultsMap.set(result.unitId, new Map());
        }
        resultsMap.get(result.unitId)!.set(result.criteriaId, result);
      }

      const targetsMap = new Map<string, any>();
      for (const target of criteriaTargets) {
        targetsMap.set(`${target.unitId}-${target.criteriaId}`, target);
      }

      // Create Excel workbook
      const workbook = new ExcelJS.Workbook();

      // === SHEET 1: SUMMARY (Tổng quan) ===
      const summarySheet = workbook.addWorksheet("Tổng quan");
      
      // Header
      summarySheet.mergeCells('A1', 'Z1');
      summarySheet.getCell('A1').value = `BẢNG TỔNG HỢP ĐIỂM THI ĐUA - ${cluster.name}`;
      summarySheet.getCell('A1').font = { bold: true, size: 14 };
      summarySheet.getCell('A1').alignment = { horizontal: 'center' };

      summarySheet.getCell('A2').value = `Kỳ thi đua: ${period.name}`;
      summarySheet.getCell('A2').font = { italic: true };

      // Calculate group scores for summary
      const calculateGroupScore = (groupNode: any, unitResults: Map<string, any>): any => {
        let selfScore = 0, clusterScore = 0, finalScore = 0, hasData = false;
        
        const processNode = (node: any): void => {
          if (node.children && node.children.length > 0) {
            node.children.forEach((child: any) => processNode(child));
          } else {
            const result = unitResults.get(node.id);
            if (result) {
              if (result.selfScore) { selfScore += parseFloat(result.selfScore); hasData = true; }
              if (result.clusterScore) { clusterScore += parseFloat(result.clusterScore); hasData = true; }
              if (result.finalScore) { finalScore += parseFloat(result.finalScore); hasData = true; }
            }
          }
        };
        
        processNode(groupNode);
        return { selfScore: hasData ? selfScore : null, clusterScore: hasData ? clusterScore : null, finalScore: hasData ? finalScore : null };
      };

      // Build summary table
      let currentRow = 4;
      
      // Header row
      summarySheet.getCell(`A${currentRow}`).value = "Đơn vị";
      summarySheet.getCell(`A${currentRow}`).font = { bold: true };
      summarySheet.getCell(`A${currentRow}`).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFD9D9D9' } };
      
      let currentCol = 2; // Column B
      criteriaTree.forEach(group => {
        const colLetter = String.fromCharCode(64 + currentCol);
        summarySheet.getCell(`${colLetter}${currentRow}`).value = group.name;
        summarySheet.getCell(`${colLetter}${currentRow}`).font = { bold: true };
        summarySheet.getCell(`${colLetter}${currentRow}`).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFD9D9D9' } };
        summarySheet.getColumn(currentCol).width = 15;
        currentCol++;
      });
      
      // Total column
      const totalColLetter = String.fromCharCode(64 + currentCol);
      summarySheet.getCell(`${totalColLetter}${currentRow}`).value = "Tổng";
      summarySheet.getCell(`${totalColLetter}${currentRow}`).font = { bold: true };
      summarySheet.getCell(`${totalColLetter}${currentRow}`).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFD9D9D9' } };
      
      currentRow++;

      // Data rows for each unit
      units.forEach(unit => {
        const unitResults = resultsMap.get(unit.id) || new Map();
        
        // Unit name row
        summarySheet.getCell(`A${currentRow}`).value = unit.name;
        summarySheet.getCell(`A${currentRow}`).font = { bold: true };
        currentRow++;
        
        // ĐTC row
        summarySheet.getCell(`A${currentRow}`).value = "  ĐTC";
        currentCol = 2;
        let totalSelf = 0;
        criteriaTree.forEach(group => {
          const scores = calculateGroupScore(group, unitResults);
          const colLetter = String.fromCharCode(64 + currentCol);
          summarySheet.getCell(`${colLetter}${currentRow}`).value = scores.selfScore;
          summarySheet.getCell(`${colLetter}${currentRow}`).numFmt = '0.0';
          if (scores.selfScore) totalSelf += scores.selfScore;
          currentCol++;
        });
        summarySheet.getCell(`${totalColLetter}${currentRow}`).value = totalSelf;
        summarySheet.getCell(`${totalColLetter}${currentRow}`).numFmt = '0.0';
        summarySheet.getCell(`${totalColLetter}${currentRow}`).font = { bold: true };
        currentRow++;
        
        // TĐ1 row
        summarySheet.getCell(`A${currentRow}`).value = "  TĐ1";
        currentCol = 2;
        let totalCluster = 0;
        criteriaTree.forEach(group => {
          const scores = calculateGroupScore(group, unitResults);
          const colLetter = String.fromCharCode(64 + currentCol);
          summarySheet.getCell(`${colLetter}${currentRow}`).value = scores.clusterScore;
          summarySheet.getCell(`${colLetter}${currentRow}`).numFmt = '0.0';
          if (scores.clusterScore) totalCluster += scores.clusterScore;
          currentCol++;
        });
        summarySheet.getCell(`${totalColLetter}${currentRow}`).value = totalCluster;
        summarySheet.getCell(`${totalColLetter}${currentRow}`).numFmt = '0.0';
        summarySheet.getCell(`${totalColLetter}${currentRow}`).font = { bold: true };
        currentRow++;
        
        // TĐ2 row
        summarySheet.getCell(`A${currentRow}`).value = "  TĐ2";
        currentCol = 2;
        let totalFinal = 0;
        criteriaTree.forEach(group => {
          const scores = calculateGroupScore(group, unitResults);
          const colLetter = String.fromCharCode(64 + currentCol);
          summarySheet.getCell(`${colLetter}${currentRow}`).value = scores.finalScore;
          summarySheet.getCell(`${colLetter}${currentRow}`).numFmt = '0.0';
          if (scores.finalScore) totalFinal += scores.finalScore;
          currentCol++;
        });
        summarySheet.getCell(`${totalColLetter}${currentRow}`).value = totalFinal;
        summarySheet.getCell(`${totalColLetter}${currentRow}`).numFmt = '0.0';
        summarySheet.getCell(`${totalColLetter}${currentRow}`).font = { bold: true };
        currentRow++;
      });

      // Column widths
      summarySheet.getColumn(1).width = 20;

      // === SHEET 2+: GROUP DETAILS (Chi tiết từng nhóm) ===
      const buildCriteriaRows = (node: any, level: number = 1, parentNumber: string = ""): any[] => {
        const nodeNumber = parentNumber ? `${parentNumber}.${node.orderIndex || ''}` : `${node.orderIndex || ''}`;
        
        const parentRow: any = {
          criteriaId: node.id,
          criteriaNumber: nodeNumber,
          criteriaName: node.name,
          level,
          maxScore: parseFloat(node.maxScore),
          criteriaType: node.criteriaType,
          isParent: node.children && node.children.length > 0,
          units: {} as any,
        };

        units.forEach(unit => {
          const result = resultsMap.get(unit.id)?.get(node.id);
          const target = targetsMap.get(`${unit.id}-${node.id}`);
          
          parentRow.units[unit.id] = {
            isAssigned: result?.isAssigned ?? true,
            targetValue: target?.targetValue,
            actualValue: result?.actualValue ? parseFloat(result.actualValue) : null,
            selfScore: result?.selfScore ? parseFloat(result.selfScore) : null,
            clusterScore: result?.clusterScore ? parseFloat(result.clusterScore) : null,
            finalScore: result?.finalScore ? parseFloat(result.finalScore) : null,
          };
        });

        const rows = [parentRow];

        if (node.children && node.children.length > 0) {
          node.children.forEach((child: any) => {
            rows.push(...buildCriteriaRows(child, level + 1, nodeNumber));
          });
        }

        return rows;
      };

      // Create a sheet for each group
      criteriaTree.forEach((groupNode, groupIndex) => {
        const sheetName = `Nhóm ${groupIndex + 1}`;
        const sheet = workbook.addWorksheet(sheetName);

        // Header
        sheet.mergeCells('A1', 'Z1');
        sheet.getCell('A1').value = `${groupNode.name} (${groupNode.maxScore} điểm)`;
        sheet.getCell('A1').font = { bold: true, size: 12 };
        sheet.getCell('A1').alignment = { horizontal: 'center' };

        // Column headers
        let row = 3;
        sheet.getCell(`A${row}`).value = "Tiêu chí";
        sheet.getCell(`A${row}`).font = { bold: true };
        sheet.getCell(`A${row}`).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFD9D9D9' } };
        sheet.getColumn(1).width = 50;

        let col = 2;
        units.forEach(unit => {
          const colLetter = String.fromCharCode(64 + col);
          sheet.getCell(`${colLetter}${row}`).value = unit.name;
          sheet.getCell(`${colLetter}${row}`).font = { bold: true };
          sheet.getCell(`${colLetter}${row}`).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFD9D9D9' } };
          sheet.getColumn(col).width = 12;
          col++;
        });

        row++;

        // Build criteria rows
        const criteriaRows = buildCriteriaRows(groupNode, 1);

        criteriaRows.forEach(criteriaRow => {
          // Indent based on level
          const indent = '  '.repeat(criteriaRow.level - 1);
          const prefix = criteriaRow.isParent ? '●' : '•';
          const criteriaLabel = `${indent}${prefix} ${criteriaRow.criteriaNumber} ${criteriaRow.criteriaName} (${criteriaRow.maxScore}đ)`;
          
          sheet.getCell(`A${row}`).value = criteriaLabel;
          if (criteriaRow.isParent) {
            sheet.getCell(`A${row}`).font = { bold: true };
          }

          // Add unit scores
          col = 2;
          units.forEach(unit => {
            const unitData = criteriaRow.units[unit.id];
            const colLetter = String.fromCharCode(64 + col);
            
            if (!unitData.isAssigned) {
              sheet.getCell(`${colLetter}${row}`).value = "KP";
            } else if (criteriaRow.isParent) {
              // For parent nodes, show aggregated scores
              sheet.getCell(`${colLetter}${row}`).value = unitData.clusterScore || "";
            } else {
              // For leaf nodes, show detail scores
              const scoreText = [
                unitData.selfScore !== null ? `ĐTC:${unitData.selfScore}` : null,
                unitData.clusterScore !== null ? `TĐ1:${unitData.clusterScore}` : null,
                unitData.finalScore !== null ? `TĐ2:${unitData.finalScore}` : null,
              ].filter(Boolean).join(" | ");
              
              sheet.getCell(`${colLetter}${row}`).value = scoreText || "-";
            }
            
            col++;
          });

          row++;
        });
      });

      // Set response headers for Excel download
      const fileName = `BaoCaoChiTiet_${cluster.name}_${period.name}_${new Date().toISOString().split('T')[0]}.xlsx`;
      res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      res.setHeader('Content-Disposition', `attachment; filename="${encodeURIComponent(fileName)}"`);

      // Write to response
      await workbook.xlsx.write(res);
      res.end();
    } catch (error) {
      console.error("Error in /api/reports/export-excel:", error);
      next(error);
    }
  });
}
