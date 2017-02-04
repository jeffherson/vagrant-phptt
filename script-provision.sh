#!/bin/bash
echo "**********************"
echo "apt-spy-2-bootstrap.sh"
echo "**********************"
# apt-spy-2-bootstrap.sh
# Uses the Ruby gem apt-spy2 to ensure the apt sources.list file is configured appropriately for this location, and that it selects mirrors that are currently functional

# Do the initial apt-get update
echo "Initial apt-get update..."
apt-get update >/dev/null

echo "Installing 'apt-spy2'. This tool lets us autoconfigure your 'apt' sources.list to a nearby location."
echo "  This may take a while..."

# Ensure dependencies are installed (These are needed to dynamically determine your country code).
# (Note: ruby >= 1.9.2 is needed for apt-spy2)
apt-get install -y ruby1.9.3 curl geoip-bin >/dev/null

# figure out the two-letter country code for the current locale, based on IP address
# (Only return something that looks like an IP address: i.e. ###.###.###.###)
export CURRENTIP=`curl -s http://ipecho.net/plain | grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"`

export COUNTRY=`geoiplookup $CURRENTIP | awk -F:\  '{print $2}' | sed 's/,.*//'`

#If country code is empty or != 2 characters, then use "US" as a default
if [ -z "$COUNTRY" ] || [ "${#COUNTRY}" -ne "2" ]; then
   COUNTRY = "BR"
fi

if [ "$(gem search -i apt-spy2)" = "false" ]; then
  gem install apt-spy2
  echo "... apt-spy2 installed!"
  echo "... Setting 'apt' sources.list for closest mirror to country=$COUNTRY"
  apt-spy2 fix --launchpad --commit --country=$COUNTRY ; true
else
  echo "... Setting 'apt' sources.list for closest mirror to country=$COUNTRY"
  apt-spy2 fix --launchpad --commit --country=$COUNTRY ; true
fi

echo "*************************"
echo "Updating system packages"
echo "*************************"

sudo add-apt-repository ppa:webupd8team/sublime-text-3
sudo apt-get -y update
sudo apt-get -y upgrade
sudo locale-gen pt_BR.UTF-8

echo "******************************"
echo "Installing supporting packages"
echo "******************************"

sudo apt-get -y install build-essential wget curl git vim autoconf
sudo apt-get -y install libcurl4-gnutls-dev libreadline-dev libxml2-dev libxslt1-dev re2c libpng-dev libjpeg-dev m4 lcov libicu-dev
sudo apt-get -y install sublime-text-installer

echo "*********************"
echo "Installing oh-my-zsh"
echo "*********************"

sudo apt-get -y install zsh
sudo su - vagrant -c 'curl -L http://install.ohmyz.sh | zsh'
sudo sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' /home/vagrant/.zshrc
sudo sed -i 's=:/bin:=:/bin:/sbin:/usr/sbin:=' /home/vagrant/.zshrc
chsh vagrant -s $(which zsh);

echo "****************************"
echo "Installing php7 dev packages"
echo "****************************"

sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update -y
sudo apt-get -y install php7.1

echo "*********************************"
echo "Installing bison required version"
echo "*********************************"

wget http://launchpadlibrarian.net/140087287/libbison-dev_2.7.1.dfsg-1_i386.deb
wget http://launchpadlibrarian.net/140087286/bison_2.7.1.dfsg-1_i386.deb
sudo dpkg -i libbison-dev_2.7.1.dfsg-1_i386.deb
sudo dpkg -i bison_2.7.1.dfsg-1_i386.deb
rm -rf libbison-dev_2.7.1.dfsg-1_i386.deb
rm -rf bison_2.7.1.dfsg-1_i386.deb

echo "************************************"
echo "Installing other supporting packages"
echo "************************************"
sudo apt-get -y install libxml2-dev libevent-dev zlib1g-dev libbz2-dev libgmp3-dev libssl-dev libcurl4-openssl-dev libjpeg-dev libpng-dev libxpm-dev libgd2-xpm-dev libmcrypt-dev memcached libmemcached-dev libpcre3-dev libc-client-dev libkrb5-dev libsasl2-dev libmysqlclient-dev libpspell-dev libsnmp-dev libxslt-dev libtool libc-client2007e libc-client2007e-dev libenchant-dev libgmp-dev librecode-dev libmm-dev libmm14 libzip-dev snmp snmp-mibs-downloader
sudo ln -fs /usr/include/linux/igmp.h /usr/include/gmp.h
sudo ln -fs /usr/lib/i386-linux-gnu/libldap.so /usr/lib/

echo "********************************"
echo "Cloning and compiling PHP source"
echo "********************************"
sudo -u vagrant git clone https://github.com/php/php-src /home/vagrant/php-src
cd /home/vagrant/php-src
sudo -u vagrant ./buildconf
sudo -u vagrant ./configure --enable-gcov --enable-debug --enable-sigchild --enable-libgcc --with-openssl --with-kerberos --with-pcre-regex --enable-bcmath --with-bz2 --enable-calendar --with-curl --with-enchant --enable-exif --enable-ftp --with-gd --enable-gd-jis-conv --with-gettext --with-mhash --with-kerberos --with-imap-ssl --enable-intl --enable-mbstring --with-libmbfl --with-onig --with-pspell --with-recode --with-mm --enable-shmop --with-snmp --enable-soap --enable-sockets --enable-sysvsem --enable-wddx --with-xmlrpc --with-xsl --enable-zip --with-zlib
sudo -u vagrant make

echo "**********************************************************"
echo "All requirements were installed. You can start your tests!"
echo "**********************************************************"
