#!/bin/bash

sudo yum update

# TODO: opprette og bytte til riktig bruker? nha satt som user i production-server

# Create filesystem
root_dir='/nha'
printf "Creating filesystem at $root_dir... "
mkdir -p $root_dir
cd $root_dir
mkdir -p spj/{innboks,logger,validert}
mkdir -p dpj/{generert,logger}
mkdir -p sip/{generert,logger}
mkdir tmp
echo "Completed"

# Get EPJ repo
echo "Cloning EPJ repo"
sudo yum install -y git
git clone https://github.com/piql/epj.git

# Install xidel
sudo yum install -y wget
mkdir xidel_install
pushd xidel_install
wget https://sourceforge.net/projects/videlibri/files/Xidel/Xidel%200.9.8/xidel-0.9.8.linux64.tar.gz
tar -xf xidel-0.9.8.linux64.tar.gz
sudo ./install.sh
popd
rm -r xidel_install


# Get Job Monitor repo
echo "Cloning Jobb Monitor repo"
git clone https://github.com/piql/nha-jobb-monitor.git jobb-monitor
mkdir jobb-monitor/{tmp,logs}

# Install php, dos2unix, composer
sudo yum install php
sudo yum install dos2unix

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php

# Setup job-monitor files
cd /nha/jobb-monitor
composer install
dos2unix bin/*
dos2unix scripts/*
chmod +x bin/*
chmod +x scripts/*

# Setup epj files
cd /nha/epj
composer install
dos2unix *.sh
dos2unix epj2sip/epj2sip.sh
dos2unix spj2dpj/spj2dpj.sh
chmod +x *.sh
chmod +x epj2sip/epj2sip.sh
chmod +x spj2dpj/spj2dpj.sh

echo Done
exit 0