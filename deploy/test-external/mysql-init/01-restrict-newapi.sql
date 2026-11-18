-- temporary test setup: newapi may only manage the new-api database.
-- Runs once on first MySQL data-dir init (after the image creates MYSQL_USER).

REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'newapi'@'%';
GRANT ALL PRIVILEGES ON `new-api`.* TO 'newapi'@'%';
FLUSH PRIVILEGES;
