-- Migration: Add is_assigned column to criteria_results table
-- Purpose: Mark whether a criteria is assigned to a unit for scoring calculation
-- Các tiêu chí type 2,3,4 có thể không được giao cho một số đơn vị
-- → Cần trường này để tính "tổng điểm được giao" khi tính % hoàn thành

BEGIN;

-- Add is_assigned column with default true (backwards compatible)
ALTER TABLE criteria_results 
ADD COLUMN IF NOT EXISTS is_assigned BOOLEAN NOT NULL DEFAULT true;

COMMENT ON COLUMN criteria_results.is_assigned IS 
'Tiêu chí có được giao cho đơn vị này không? Default = true. Nếu false thì không tính vào tổng điểm được giao.';

COMMIT;
