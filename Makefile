# Makefile for MySQL Master-Slave Replication Setup

DOCKER_COMPOSE = docker compose
MASTER_CONTAINER = mysql-master
SLAVE_CONTAINER = mysql-slave

MYSQL_ROOT_PASSWORD = rootpass
MYSQL_REPLICATION_USER = repl_user
MYSQL_REPLICATION_PASSWORD = repl_pass
MYSQL_DATABASE = replicadb
MYSQL_MASTER_IP = $(shell docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(MASTER_CONTAINER))
MYSQL_SLAVE_IP = $(shell docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(SLAVE_CONTAINER))

# Step 1: Build and start Docker containers
up:
	@echo "Starting MySQL Master-Slave containers..."
	$(DOCKER_COMPOSE) up -d

# Step 2: Set up Master replication
setup-master:
	@echo "Setting up Master configuration..."
	docker exec -it $(MASTER_CONTAINER) mysql -u root -p$(MYSQL_ROOT_PASSWORD) -e "CREATE USER IF NOT EXISTS '$(MYSQL_REPLICATION_USER)'@'%' IDENTIFIED BY '$(MYSQL_REPLICATION_PASSWORD)';"
	docker exec -it $(MASTER_CONTAINER) mysql -u root -p$(MYSQL_ROOT_PASSWORD) -e "GRANT REPLICATION SLAVE ON *.* TO '$(MYSQL_REPLICATION_USER)'@'%';"
	docker exec -it $(MASTER_CONTAINER) mysql -u root -p$(MYSQL_ROOT_PASSWORD) -e "FLUSH PRIVILEGES;"

# Step 3: Set up Slave replication
setup-slave:
	@echo "Setting up Slave replication..."
	docker exec -it $(SLAVE_CONTAINER) mysql -u root -p$(MYSQL_ROOT_PASSWORD) -e "CHANGE MASTER TO MASTER_HOST='$(MYSQL_MASTER_IP)', MASTER_USER='$(MYSQL_REPLICATION_USER)', MASTER_PASSWORD='$(MYSQL_REPLICATION_PASSWORD)', MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=154;"
	docker exec -it $(SLAVE_CONTAINER) mysql -u root -p$(MYSQL_ROOT_PASSWORD) -e "START SLAVE;"

# Step 4: Allow remote access (grant privileges)
allow-remote-access:
	@echo "Allowing remote access for root user..."
	docker exec -it $(MASTER_CONTAINER) mysql -u root -p$(MYSQL_ROOT_PASSWORD) -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$(MYSQL_ROOT_PASSWORD)' WITH GRANT OPTION;"
	docker exec -it $(SLAVE_CONTAINER) mysql -u root -p$(MYSQL_ROOT_PASSWORD) -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$(MYSQL_ROOT_PASSWORD)' WITH GRANT OPTION;"
	docker exec -it $(MASTER_CONTAINER) mysql -u root -p$(MYSQL_ROOT_PASSWORD) -e "FLUSH PRIVILEGES;"
	docker exec -it $(SLAVE_CONTAINER) mysql -u root -p$(MYSQL_ROOT_PASSWORD) -e "FLUSH PRIVILEGES;"

# Step 5: Open ports in firewall (for UFW)
open-ports:
	@echo "Opening MySQL ports in firewall..."
	sudo ufw allow 3306/tcp  # Master port
	sudo ufw allow 3307/tcp  # Slave port
	sudo ufw reload

# Step 6: Show replication status
show-status:
	@echo "Checking Slave replication status..."
	docker exec -it $(SLAVE_CONTAINER) mysql -u root -p$(MYSQL_ROOT_PASSWORD) -e "SHOW SLAVE STATUS\G"

# Step 7: Bring down containers
down:
	@echo "Stopping and removing containers..."
	$(DOCKER_COMPOSE) down

hi-master:
	@echo "Setting up Master configuration..."
	docker exec -it mysql-master bash -c "mysql -u root -pYourPassword -e \"CREATE USER IF NOT EXISTS 'repl_user'@'%' IDENTIFIED BY 'repl_pass';\" && \
	mysql -u root -pYourPassword -e \"GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';\" && \
	mysql -u root -pYourPassword -e \"FLUSH PRIVILEGES;\""

.PHONY: up setup-master setup-slave allow-remote-access open-ports show-status down

bslave:
	docker exec -it $(SLAVE_CONTAINER) bash

bmaster:
	docker exec -it $(MASTER_CONTAINER) bash