#!/bin/bash

echo 'export SWIFTENV_ROOT="/.swiftenv"' > /home/vagrant/.bash_profile
echo 'export PATH="$SWIFTENV_ROOT/bin:$PATH"' >> /home/vagrant/.bash_profile
echo 'eval "$(swiftenv init -)"' >> /home/vagrant/.bash_profile
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/prj/.build/debug' >> /home/vagrant/.bash_profile

if test -f '/etc/bootstrapped'; then
   source /home/vagrant/.bash_profile
   cd /prj
   cp /vagrant/Package.swift /prj
   cp -r /vagrant/Sources/* /prj/Sources
   make build
   exit
fi

cd /
if test -d '~/prj'; then
  echo "/prj exists"
else
  mkdir prj
  chmod 777 /prj -R
fi
cd prj

sudo apt-get update
sudo apt-get -y install git --fix-missing
sudo apt-get -y install git cmake ninja-build clang python uuid-dev libicu-dev icu-devtools libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev libncurses5-dev pkg-config --fix-missing
sudo apt-get -y install libmysqlclient-dev mysql-client --fix-missing
git clone https://github.com/kylef/swiftenv.git /.swiftenv
sudo chmod 777 /.swiftenv -R

source  /home/vagrant/.bash_profile

cp /vagrant/Package.swift /prj/
cp -r /vagrant/Sources /prj/
cp /vagrant/Makefile /prj/
cp /vagrant/.swift-version /prj/
sudo chmod 777 /prj -R

swiftenv install swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a
make clean build

if test -d '/prj/.build/debug'; then
  sudo date > /etc/bootstrapped
fi
