import type { 
  Criteria, 
  CriteriaFormula, 
  CriteriaFixedScore, 
  CriteriaBonusPenalty,
  CriteriaTarget,
  CriteriaResult
} from "@shared/schema";

/**
 * Service xử lý logic tính điểm theo 4 loại tiêu chí
 * 
 * Loại 1: Định lượng (criteria_type = 1)
 * Loại 2: Định tính (criteria_type = 2)
 * Loại 3: Chấm thẳng (criteria_type = 3)
 * Loại 4: Cộng/Trừ điểm (criteria_type = 4)
 */
export class CriteriaScoreService {
  
  /**
   * Tính điểm cho tiêu chí ĐỊNH LƯỢNG (criteria_type = 1)
   * Algorithm based on exceed percentage instead of absolute values
   * 
   * @param actual - A = actual_value (giá trị thực tế)
   * @param target - T = target_value (chỉ tiêu được giao)
   * @param maxScore - MS = max_score (điểm tối đa)
   * @param formulaType - Loại công thức (1-4)
   * @param leaderExceedPercent - exceed percent của đơn vị dẫn đầu (cho formula_type = 4)
   * @returns Điểm được tính
   */
  static calculateQuantitativeScore(
    actual: number,
    target: number,
    maxScore: number,
    formulaType: number,
    leaderExceedPercent?: number
  ): number {
    if (target === 0) return 0;
    
    // Compute unit's exceed percentage: (A - T) / T
    const unitExceedPercent = (actual - target) / target;
    
    switch (formulaType) {
      case 1: // Not meeting target (A < T)
        // score = 0.5 × MS × (A / T)
        return Number((0.5 * maxScore * (actual / target)).toFixed(2));
      
      case 2: // Meeting target (A >= T)
        // score = 0.5 × MS
        return Number((0.5 * maxScore).toFixed(2));
      
      case 3: // Leader (highest exceed %)
        // score = MS
        return maxScore;
      
      case 4: // Exceeded but not leader
        // score = 0.5 × MS + (unit_exceed_percent / leader_exceed_percent) × (0.5 × MS)
        if (!leaderExceedPercent || leaderExceedPercent <= 0) {
          // No valid leader exceed percent -> treat as meeting target
          return Number((0.5 * maxScore).toFixed(2));
        }
        
        if (unitExceedPercent <= 0) {
          // Not exceeding target -> use Case 1 formula
          return Number((0.5 * maxScore * (actual / target)).toFixed(2));
        }
        
        const ratio = unitExceedPercent / leaderExceedPercent;
        const score = 0.5 * maxScore + ratio * (0.5 * maxScore);
        return Number(Math.min(score, maxScore).toFixed(2));
      
      default:
        return 0;
    }
  }
  
  /**
   * Tính điểm cho tiêu chí ĐỊNH TÍNH (criteria_type = 2)
   * @param isAchieved - Có đạt hay không (true/false)
   * @param maxScore - Điểm tối đa
   * @returns Điểm: maxScore nếu đạt, 0 nếu không đạt
   */
  static calculateQualitativeScore(isAchieved: boolean, maxScore: number): number {
    return isAchieved ? maxScore : 0;
  }
  
  /**
   * Tính điểm cho tiêu chí CHẤM THẲNG (criteria_type = 3)
   * @param count - Số lần/số lượng
   * @param pointPerUnit - Điểm cho mỗi lần
   * @param maxScoreLimit - Giới hạn điểm tối đa (optional)
   * @returns Điểm = count × pointPerUnit (chặn bởi maxScoreLimit nếu có)
   */
  static calculateFixedScore(
    count: number,
    pointPerUnit: number,
    maxScoreLimit?: number
  ): number {
    const score = count * pointPerUnit;
    
    if (maxScoreLimit && score > maxScoreLimit) {
      return maxScoreLimit;
    }
    
    return Number(score.toFixed(2));
  }
  
  /**
   * Tính điểm cho tiêu chí CỘNG/TRỪ (criteria_type = 4)
   * @param bonusCount - Số lần cộng điểm
   * @param penaltyCount - Số lần trừ điểm
   * @param bonusPoint - Điểm cộng mỗi lần
   * @param penaltyPoint - Điểm trừ mỗi lần
   * @param minScore - Điểm tối thiểu (optional)
   * @param maxScore - Điểm tối đa (optional)
   * @returns Điểm = (bonusCount × bonusPoint) - (penaltyCount × penaltyPoint)
   */
  static calculateBonusPenaltyScore(
    bonusCount: number,
    penaltyCount: number,
    bonusPoint: number = 0,
    penaltyPoint: number = 0,
    minScore?: number,
    maxScore?: number
  ): number {
    let score = (bonusCount * bonusPoint) - (penaltyCount * penaltyPoint);
    
    // Áp dụng giới hạn min/max
    if (minScore !== undefined && score < minScore) {
      score = minScore;
    }
    if (maxScore !== undefined && score > maxScore) {
      score = maxScore;
    }
    
    return Number(score.toFixed(2));
  }
  
  /**
   * Tính điểm tự động dựa vào loại tiêu chí và dữ liệu đầu vào
   * @param criteria - Thông tin tiêu chí
   * @param result - Kết quả đã nhập (actual_value, self_score, bonus_count, penalty_count)
   * @param formulaDetail - Chi tiết công thức (CriteriaFormula | CriteriaFixedScore | CriteriaBonusPenalty)
   * @param target - Chỉ tiêu được giao (cho định lượng)
   * @param leaderActual - Giá trị của đơn vị dẫn đầu (cho formula_type = 4)
   * @returns Điểm được tính toán
   */
  static calculateScore(
    criteria: Criteria,
    result: Partial<CriteriaResult>,
    formulaDetail?: CriteriaFormula | CriteriaFixedScore | CriteriaBonusPenalty,
    target?: CriteriaTarget,
    leaderActual?: number
  ): number {
    const maxScore = Number(criteria.maxScore);
    
    switch (criteria.criteriaType) {
      case 1: // Định lượng
        if (!result.actualValue || !target?.targetValue) {
          return 0;
        }
        return this.calculateQuantitativeScore(
          Number(result.actualValue),
          Number(target.targetValue),
          maxScore,
          criteria.formulaType || 1,
          leaderActual
        );
      
      case 2: // Định tính
        // selfScore sẽ là 0 (không đạt) hoặc maxScore (đạt)
        return result.selfScore ? Number(result.selfScore) : 0;
      
      case 3: // Chấm thẳng
        if (!result.actualValue || !formulaDetail) {
          return 0;
        }
        const fixedDetail = formulaDetail as CriteriaFixedScore;
        return this.calculateFixedScore(
          Number(result.actualValue),
          Number(fixedDetail.pointPerUnit),
          fixedDetail.maxScoreLimit ? Number(fixedDetail.maxScoreLimit) : undefined
        );
      
      case 4: // Cộng/Trừ
        if (!formulaDetail) {
          return 0;
        }
        const bonusPenaltyDetail = formulaDetail as CriteriaBonusPenalty;
        return this.calculateBonusPenaltyScore(
          result.bonusCount || 0,
          result.penaltyCount || 0,
          bonusPenaltyDetail.bonusPoint ? Number(bonusPenaltyDetail.bonusPoint) : 0,
          bonusPenaltyDetail.penaltyPoint ? Number(bonusPenaltyDetail.penaltyPoint) : 0,
          bonusPenaltyDetail.minScore ? Number(bonusPenaltyDetail.minScore) : undefined,
          bonusPenaltyDetail.maxScore ? Number(bonusPenaltyDetail.maxScore) : undefined
        );
      
      default:
        return 0;
    }
  }
  
  /**
   * Tính tổng điểm của tiêu chí cha (tổng điểm các con)
   * @param childrenScores - Mảng điểm của các tiêu chí con
   * @returns Tổng điểm
   */
  static calculateParentScore(childrenScores: number[]): number {
    const total = childrenScores.reduce((sum, score) => sum + score, 0);
    return Number(total.toFixed(2));
  }
  
  /**
   * Xác định đơn vị dẫn đầu cụm cho tiêu chí định lượng
   * Leader is determined by HIGHEST exceed percentage: (A - T) / T
   * 
   * @param results - Mảng kết quả của tất cả đơn vị (phải có actualValue)
   * @param targets - Map của unitId -> targetValue
   * @returns Leader info: unitId, actualValue, targetValue, exceedPercent
   */
  static findClusterLeader(
    results: CriteriaResult[],
    targets: Map<string, number>
  ): { unitId: string; actualValue: number; targetValue: number; exceedPercent: number } | null {
    if (results.length === 0) return null;
    
    let leader: { unitId: string; actualValue: number; targetValue: number; exceedPercent: number } | null = null;
    let maxExceedPercent = -Infinity;
    
    for (const result of results) {
      const actual = Number(result.actualValue || 0);
      const target = targets.get(result.unitId) || 0;
      
      if (target === 0) continue; // Skip if no target
      
      // Calculate exceed percentage: (A - T) / T
      const exceedPercent = (actual - target) / target;
      
      if (exceedPercent > maxExceedPercent) {
        maxExceedPercent = exceedPercent;
        leader = {
          unitId: result.unitId,
          actualValue: actual,
          targetValue: target,
          exceedPercent: exceedPercent
        };
      }
    }
    
    return leader;
  }

  /**
   * Batch calculate scores for all units in a cluster for a specific quantitative criteria
   * This implements the full algorithm with leader detection and proper formula assignment
   * 
   * @param criteriaId - ID của tiêu chí định lượng
   * @param results - Mảng tất cả results của các đơn vị cho tiêu chí này
   * @param targets - Map unitId -> targetValue
   * @param maxScore - Điểm tối đa của tiêu chí
   * @returns Map unitId -> calculatedScore
   */
  static batchCalculateQuantitativeScores(
    results: CriteriaResult[],
    targets: Map<string, number>,
    maxScore: number
  ): Map<string, number> {
    const scores = new Map<string, number>();
    
    // Step 1: Find the leader (highest exceed %)
    const leader = this.findClusterLeader(results, targets);
    
    if (!leader) {
      // No valid leader, all scores = 0
      for (const result of results) {
        scores.set(result.unitId, 0);
      }
      return scores;
    }
    
    // Step 2: Calculate score for each unit
    for (const result of results) {
      const actual = Number(result.actualValue || 0);
      const target = targets.get(result.unitId) || 0;
      
      if (target === 0) {
        scores.set(result.unitId, 0);
        continue;
      }
      
      // Determine formula type for this unit
      let formulaType: number;
      
      if (actual < target) {
        // Case 1: Not meeting target
        formulaType = 1;
      } else if (actual === target) {
        // Case 2: Meeting target exactly
        formulaType = 2;
      } else if (result.unitId === leader.unitId) {
        // Case 3: Leader (highest exceed %)
        formulaType = 3;
      } else {
        // Case 4: Exceeded but not leader
        formulaType = 4;
      }
      
      // Calculate score using the appropriate formula
      const score = this.calculateQuantitativeScore(
        actual,
        target,
        maxScore,
        formulaType,
        leader.exceedPercent
      );
      
      scores.set(result.unitId, score);
    }
    
    return scores;
  }
}
