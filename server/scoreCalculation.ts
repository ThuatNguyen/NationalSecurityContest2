/**
 * Score Calculation Logic for Quantitative Criteria (Type 1)
 * 
 * Two-step calculation:
 * 1. Preliminary (self-scoring): Apply formula 1/2 only (no leader comparison)
 * 2. Cluster recalculation: Apply formula 3/4 (with leader comparison)
 */

export interface QuantitativeScoreInput {
  actualValue: number;
  targetValue: number;
  maxScore: number;
}

export interface ClusterScoreInput extends QuantitativeScoreInput {
  unitId: string;
  allResults: Array<{
    unitId: string;
    actualValue: number;
    targetValue: number;
  }>;
}

/**
 * Formula 1: A < T (Under target)
 * Score = 0.5 × maxScore × (A / T)
 */
function calculateUnderTarget(actual: number, target: number, maxScore: number): number {
  return 0.5 * maxScore * (actual / target);
}

/**
 * Formula 2: A = T (Exact target)
 * Score = 0.5 × maxScore
 */
function calculateExactTarget(maxScore: number): number {
  return 0.5 * maxScore;
}

/**
 * Formula 3: A > T and is leader (highest A/T ratio in cluster)
 * Score = maxScore
 */
function calculateLeader(maxScore: number): number {
  return maxScore;
}

/**
 * Formula 4: A > T but not leader
 * Score = 0.5 × maxScore + 0.5 × maxScore × (A/T - 1) / (L/TL - 1)
 * Where L/TL is the leader's ratio
 */
function calculateOverTargetNotLeader(
  actual: number,
  target: number,
  maxScore: number,
  leaderRatio: number
): number {
  const unitRatio = actual / target;
  const baseScore = 0.5 * maxScore;
  const bonusScore = 0.5 * maxScore * ((unitRatio - 1) / (leaderRatio - 1));
  return baseScore + bonusScore;
}

/**
 * Step 1: Preliminary calculation (when unit saves score)
 * Only applies formula 1 & 2 (no leader comparison)
 */
export function calculatePreliminaryScore(input: QuantitativeScoreInput): number {
  const { actualValue, targetValue, maxScore } = input;
  
  // Validation
  if (targetValue <= 0) {
    return 0;
  }
  
  if (actualValue < 0) {
    return 0;
  }
  
  // Formula 1: Under target
  if (actualValue < targetValue) {
    return calculateUnderTarget(actualValue, targetValue, maxScore);
  }
  
  // Formula 2: Exact target
  if (actualValue === targetValue) {
    return calculateExactTarget(maxScore);
  }
  
  // Formula 3/4: Over target - but for preliminary, we don't know if leader yet
  // So we give 0.5 × maxScore as base score (same as exact target)
  // The cluster recalculation will adjust this later
  return calculateExactTarget(maxScore);
}

/**
 * Step 2: Cluster recalculation (when submitted or admin recalculates)
 * Applies all formulas including leader detection
 */
export function calculateClusterScore(input: ClusterScoreInput): number {
  const { actualValue, targetValue, maxScore, unitId, allResults } = input;
  
  // Validation
  if (targetValue <= 0) {
    return 0;
  }
  
  if (actualValue < 0) {
    return 0;
  }
  
  // Formula 1: Under target
  if (actualValue < targetValue) {
    return calculateUnderTarget(actualValue, targetValue, maxScore);
  }
  
  // Formula 2: Exact target
  if (actualValue === targetValue) {
    return calculateExactTarget(maxScore);
  }
  
  // Formula 3 & 4: Over target - need to check if this unit is the leader
  // Filter units that exceeded their targets and have valid data
  const overTargetUnits = allResults.filter(r => 
    r.targetValue > 0 && 
    r.actualValue > r.targetValue
  );
  
  if (overTargetUnits.length === 0) {
    // No units exceeded target (shouldn't happen if current unit is here)
    return calculateExactTarget(maxScore);
  }
  
  // Calculate ratios for all over-target units
  const ratios = overTargetUnits.map(r => ({
    unitId: r.unitId,
    ratio: r.actualValue / r.targetValue
  }));
  
  // Find the highest ratio (leader)
  const leaderRatio = Math.max(...ratios.map(r => r.ratio));
  const currentRatio = actualValue / targetValue;
  
  // Check if current unit is the leader (or tied for leader)
  const epsilon = 0.0001; // Small tolerance for floating point comparison
  if (Math.abs(currentRatio - leaderRatio) < epsilon) {
    // Formula 3: This unit is the leader
    return calculateLeader(maxScore);
  }
  
  // Formula 4: Over target but not leader
  return calculateOverTargetNotLeader(actualValue, targetValue, maxScore, leaderRatio);
}

/**
 * Round score to 2 decimal places
 */
export function roundScore(score: number): number {
  return Math.round(score * 100) / 100;
}
