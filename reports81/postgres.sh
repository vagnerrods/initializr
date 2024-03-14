#!/bin/bash


# PostgreSQL Version
pgver=16

# Adding repository keys
function add-keys(){
  sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
  wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null
}

# System update
function update(){
  apt update
}

# PostgreSQL Install
function install(){
apt install postgresql-$pgver postgresql-client-$pgver postgresql-server-dev-$pgver postgresql-plpython3-$pgver postgresql-$pgver-plpgsql-check postgresql-$pgver-plsh postgresql-$pgver-cron postgresql-$pgver-extra-window-functions postgresql-$pgver-preprepare postgresql-$pgver-tds-fdw postgresql-$pgver-prioritize -y
sleep 5
}


# PostgreSQL configs
function configs(){
sed -i -e"s/^max_connections = 100.*$/max_connections = 200/" /etc/postgresql/$pgver/main/postgresql.conf
sed -i -e"s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/$pgver/main/postgresql.conf
sed -i -e"s/^#listen_addresses = '*'/listen_addresses = '*'/" /etc/postgresql/$pgver/main/postgresql.conf


# Connections configs
rm /etc/postgresql/$pgver/main/pg_hba.conf
tee -a /etc/postgresql/$pgver/main/pg_hba.conf << END
# TYPE  DATABASE        USER            ADDRESS                 METHOD
# Database administrative login by Unix domain socket
local   all             postgres                                peer
# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    all             all             0.0.0.0/0               scram-sha-256
# IPv6 local connections:
host    all             all             ::1/128                 scram-sha-256
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            scram-sha-256
host    replication     all             ::1/128                 scram-sha-256
END

if [ ! -f /etc/apt/sources.list.d/pgdg.list ]; then
   rm /etc/postgresql/$pgver/main/pg_config.sql
fi


# Users configs
tee -a /etc/postgresql/$pgver/main/pg_config.sql << END
ALTER USER postgres PASSWORD 'f2hr7mxa';

CREATE ROLE devops LOGIN
  PASSWORD 'f2hr7mxa'
  SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;

CREATE ROLE develop LOGIN
  PASSWORD 'kdx4pnw7'
  SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;

CREATE ROLE suporte LOGIN
  PASSWORD 'aq1sw2de3'
  SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;

CREATE ROLE sync LOGIN
  PASSWORD 'aq1sw2de3'
  SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;

CREATE ROLE analytics LOGIN
  PASSWORD 'kdx4pnw7'
  SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;
END

su - postgres -c "psql -p 5432 -f '/etc/postgresql/${pgver}/main/pg_config.sql'"
} 


# Setup
function setup(){
  add-keys
  update
  install 
  systemctl start postgresql.service
  configs
  sudo systemctl restart postgresql
}

setup

# END
