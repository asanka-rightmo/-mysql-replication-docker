 Master 
 mysql -u root -p

rootpass

CREATE USER IF NOT EXISTS 'repl_user'@'%' IDENTIFIED BY 'repl_pass';

GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';

	FLUSH PRIVILEGES;

68.183.60.155


Slave

STOP REPLICA;
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='68.183.60.155',    -- Master server IP
  SOURCE_PORT=3307,                -- Port where the master is running
  SOURCE_USER='repl_user',         -- Replication user
  SOURCE_PASSWORD='repl_pass',     -- Replication password
  SOURCE_LOG_FILE='mysql-bin.000001',
  SOURCE_LOG_POS=154,              -- Binary log file and position from SHOW MASTER STATUS on the master
  SOURCE_SSL=0;                    -- Disable SSL

START REPLICA;

 STOP REPLICA;
 SHOW REPLICA STATUS\G


ALTER USER 'repl_user'@'%' IDENTIFIED WITH mysql_native_password BY 'rootpass';
FLUSH PRIVILEGES;

ALTER USER 'repl_user'@'%' IDENTIFIED WITH mysql_native_password BY 'rootpass';
