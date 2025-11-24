-- Migration: Drop legacy scores table
-- The scores table has been replaced by criteriaResults which provides
-- more detailed tracking including:
-- - Fixed scores (from scoring forms)
-- - Formula-calculated scores
-- - Bonus/penalty scores
-- - Final scores with aggregation

-- Drop the legacy scores table
DROP TABLE IF EXISTS "scores";
