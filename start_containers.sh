#!/bin/bash
set -eou pipefail

# Delete any orphans
docker compose down --remove-orphans
rm -rf ./opt/app/*
rm -rf ./opt/mysql/*

# Start conjur, lamp, cybr-cli
docker compose up -d

# Configure conjur as Leader
docker exec conjur evoke configure master \
    --accept-eula \
    --hostname host01 \
    --admin-password CYberark11@@ \
    impact2021

# Create database, user, table, and populate
docker exec lamp mysql -h localhost --port=3306 -uroot \
    -e "CREATE DATABASE conjur_demo; CREATE USER 'devapp1' IDENTIFIED BY 'Cyberark1'; GRANT ALL PRIVILEGES ON conjur_demo.* TO 'devapp1'; FLUSH PRIVILEGES; USE conjur_demo; CREATE TABLE IF NOT EXISTS conjur_demo.demo (message VARCHAR(255) NOT NULL) ENGINE=MyISAM DEFAULT CHARSET=utf8; INSERT INTO demo (message) VALUES ('If you are seeing this message, we have successfully connected PHP to our backend MySQL database!');"

clear
echo "********************************************"
echo "* When prompted, please type: CYberark11@@ *"
echo "********************************************"
echo ""
read -n 1 -s -r -p "Press any key to continue"
echo ""

# Login and pre-configure conjur with cybr-cli
docker exec -it cli cybr conjur logon -a impact2021 -b https://conjur -l admin --self-signed
docker cp ./policies/root.yml cli:/app
docker exec cli cybr conjur update-policy -b root -f root.yml > ./demouser.txt
docker exec cli cybr conjur set-secret -i devapp/db_uname -v "devapp1"
docker exec cli cybr conjur set-secret -i devapp/db_pass -v "Cyberark1"

echo ""
echo "Finished."