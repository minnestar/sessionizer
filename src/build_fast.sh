#!/bin/bash

PG_VERSION="$(ls /etc/postgresql)"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"

echo '-------------------'
echo "Configuring $PG_HBA"

sudo bash -c "echo '# TYPE  DATABASE        USER            ADDRESS                 METHOD' > $PG_HBA"
sudo bash -c "echo '' >> $PG_HBA"
sudo bash -c "echo '# Allow vagrant user to connect to database without password' >> $PG_HBA"
sudo bash -c "echo 'local   all             vagrant                                 trust' >> $PG_HBA"
sudo bash -c "echo '' >> $PG_HBA"
sudo bash -c "echo '# Allow postgres user to connect to database without password' >> $PG_HBA"
sudo bash -c "echo 'local   all             postgres                                trust' >> $PG_HBA"
sudo bash -c "echo '' >> $PG_HBA"
sudo bash -c "echo 'local   all             all                                     trust' >> $PG_HBA"
sudo bash -c "echo '' >> $PG_HBA"
sudo bash -c "echo '# IPv4 local connections:' >> $PG_HBA"
sudo bash -c "echo 'host    all             all             0.0.0.0/0               trust' >> $PG_HBA"
sudo bash -c "echo '' >> $PG_HBA"
sudo bash -c "echo '# IPv6 local connections:' >> $PG_HBA"
sudo bash -c "echo 'host    all             all             ::1/128                 trust' >> $PG_HBA"

echo '-----------------------------'
echo 'sudo service postgresql start'
sudo service postgresql start

echo '----------------------------------'
echo 'sudo /etc/init.d/postgresql reload'
sudo /etc/init.d/postgresql reload

export TEST_DATABASE_USERNAME=postgres

echo '--------------'
echo 'bundle install'
bundle install

echo '--------------------------------------'
echo 'sudo -u postgres createuser -d vagrant'
sudo -u postgres createuser -d vagrant

echo '------------------------------------------------------'
echo "'create database sessionizer_development;' -U postgres"
psql -c 'create database sessionizer_development;' -U postgres

echo '-------------------------------------------------------'
echo "psql -c 'create database sessionizer_test;' -U postgres"
psql -c 'create database sessionizer_test;' -U postgres

sh test_app.sh
