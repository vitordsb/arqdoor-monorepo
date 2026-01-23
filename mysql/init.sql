-- ArqDoor Database Initialization Script
-- This script runs automatically when MySQL container starts for the first time

-- Create development database
CREATE DATABASE IF NOT EXISTS arqdoor_dev 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

-- Create test database
CREATE DATABASE IF NOT EXISTS arqdoor_test 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

-- Grant privileges to arqdoor user
GRANT ALL PRIVILEGES ON arqdoor_dev.* TO 'arqdoor'@'%';
GRANT ALL PRIVILEGES ON arqdoor_test.* TO 'arqdoor'@'%';

-- Flush privileges to apply changes
FLUSH PRIVILEGES;

-- Log initialization
SELECT 'ArqDoor databases initialized successfully!' AS message;
