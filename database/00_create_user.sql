CREATE USER IF NOT EXISTS 'kelet_user'@'%' IDENTIFIED BY 'kelet_user';

GRANT ALL PRIVILEGES ON kelet_baranya_db.* 
TO 'kelet_user'@'%';

FLUSH PRIVILEGES;