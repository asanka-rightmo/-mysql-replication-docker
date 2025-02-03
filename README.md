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

STOP REPLICA;
RESET REPLICA ALL;

CHANGE REPLICATION SOURCE TO 
    SOURCE_HOST='68.183.60.155',
    SOURCE_USER='repl_user',
    SOURCE_PASSWORD='rootpass',
    SOURCE_PORT=3307,
    GET_SOURCE_PUBLIC_KEY=1;

START REPLICA;

sudo ufw allow 3307/tcp
sudo ufw allow 3308/tcp

CHANGE MASTER TO MASTER_HOST='68.183.60.155', MASTER_PORT=3307, MASTER_USER='repl_user', MASTER_PASSWORD='rootpass', MASTER_LOG_FILE='mysql-bin.000003', MASTER_LOG_POS=1688;

docker exec -i mysql-master mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS qr_gen;"

docker exec -i mysql-master mysql -u root -p qr_gen < mydatabase.sql

docker exec -i mysql-slave mysql -h 127.0.0.1 -P 3307 -u root -prootpass qr_gen < mydatabase.sql




CREATE USER repl_user@68.183.60.155 IDENTIFIED  BY 'repl_pass';
GRANT REPLICATION SLAVE ON *.* to repl_user@68.183.60.155;
SHOW GRANTS FOR repl_user@68.183.60.155;

master = 68.183.60.155
slave = 68.183.60.155


CHANGE MASTER TO MASTER_HOST='68.183.60.155',
MASTER_USER='repl_user',
MASTER_PASSWORD='repl_user',
MASTER_LOG_FILE='mysql-bin.000001',
MASTER_LOG_POS=202509;

sudo ufw allow from 54.175.231.127 to any port 3306

CREATE USER 'qr-web-r'@'%' IDENTIFIED BY 'slave_server';
GRANT ALL PRIVILEGES ON *.* TO 'qr-web-r'@'%' WITH GRANT OPTION;

CREATE USER 'qr-web-w'@'%' IDENTIFIED BY 'master_server';
GRANT ALL PRIVILEGES ON *.* TO 'qr-web-w'@'%' WITH GRANT OPTION;