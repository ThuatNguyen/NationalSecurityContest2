-- Migration: Add evidence_file_name column to criteria_results
-- Date: 2025-11-25

ALTER TABLE criteria_results 
ADD COLUMN IF NOT EXISTS evidence_file_name TEXT;

COMMENT ON COLUMN criteria_results.evidence_file_name IS 'Tên file gốc (hiển thị cho user)';
