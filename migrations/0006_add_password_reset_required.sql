-- Migration: Add password reset tracking
-- Purpose: Force users to change password on first login for security

-- Add require_password_reset flag
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS require_password_reset BOOLEAN NOT NULL DEFAULT false;

-- Add last_password_change tracking
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS last_password_change TIMESTAMP;

-- Optional: Force all existing users to reset password (uncomment if needed)
-- UPDATE users SET require_password_reset = true WHERE last_password_change IS NULL;

-- Add comment
COMMENT ON COLUMN users.require_password_reset IS 'Flag to force password change on next login (used for first-time users)';
COMMENT ON COLUMN users.last_password_change IS 'Timestamp of last password change for audit purposes';
