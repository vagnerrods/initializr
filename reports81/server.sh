#!/bin/bash


###############################################################################

# Init Variables
hostname="dataflow"
timezone="America/Sao_Paulo"

# Set Hostname
sudo hostnamectl set-hostname $hostname

# Set Timezone
sudo timedatectl set-timezone $timezone

# Set Locale
sudo locale-gen pt_BR.UTF-8
sudo locale-gen pt_BR
sudo sed -i -e 's/LANG=C.UTF-8/LANG=pt_BR.UTF-8/' /etc/default/locale
sudo dpkg-reconfigure --frontend=noninteractive locales
sudo update-locale LANG=pt_BR.UTF-8

# Permissions
sed -i -e 's/%sudo ALL=NOPASSWD:ALL/%sudo ALL=(ALL)NOPASSWD:ALL/' /etc/sudoers

###############################################################################

# Add Repositories
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

apt-key adv --keyserver keyserver.ubuntu.com --recv E0C56BD4
echo "deb https://repo.clickhouse.tech/deb/stable/ main/" | sudo tee /etc/apt/sources.list.d/clickhouse.list

sudo add-apt-repository ppa:ondrej/php -y

# Update System
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

# Install essential packages
sudo apt install -yq git-core neovim wget curl zsh tmux sed glances dstat ca-certificates
sudo apt install -yq apt-transport-https ca-certificates software-properties-common \
                     ufw git wget tmux curl binutils zlib1g-dev build-essential  \
                     libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 \
                     libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev cockpit \
                     gcc g++ make yarn nodejs
sudo apt install -yq docker-ce docker-compose-plugin
sudo apt install -yq locales util-linux-locales language-pack-pt-base language-pack-pt
sudo apt install -yq hunspell-pt-br hyphen-pt-br
sudo apt install -yq python3 python3-pip python3-venv python3-virtualenv \
                     python3-psycopg2 python3-sqlalchemy
sudo apt install -yq php8.2 php8.2-cli php8.2-common php8.2-imap php8.2-redis php8.2-snmp 
sudo apt install -yq php8.2-xml php8.2-zip php8.2-mbstring php8.2-curl php8.2-gd php8.2-mysql

###############################################################################

# Configure Firewall
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 5432
sudo ufw allow 8123
sudo ufw allow 9000
sudo ufw allow 9090
sudo ufw enable
sudo ufw logging medium

###############################################################################

# END
