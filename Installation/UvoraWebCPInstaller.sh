#!/bin/bash
if [ "$(whoami)" != "root" ]; then
	echo "Sorry, you are not root."
	exit 1
fi
clear
cd ~/
mkdir -p ~/UWebCPInstallerLogs
INSTALL_LOG=~/UWebCPInstallerLogs/UWebCPInstaller_$(date +%s).log

echo "#######################################################"
echo "########WELCOME TO THE UVORA WEB CONTROL PANEL#########"
echo "########             (Uvora wCP)              #########"
echo "#########Designed and Developed By: Uvora LLC##########"
echo "#######################################################"
echo ""
echo ""
echo "The Uvora wCP is owned property of Uvora LLC and is"
echo "distributed under an open source GNU GPL v3 license,"
echo "by using our software you agree to all aspects of the"
echo "license."
echo "         http://www.gnu.org/licenses/gpl.html          "
echo ""
echo "Do you accept the terms of the license agreement?"
select yn in "Yes" "No"; do
	case $yn in
		Yes ) break;;
		No ) exit;;
	esac
done
echo -e "\nBOOYA! I'm sooo glad you decided to accept our terms."
echo "You sure won't regret it, let's get started..."
echo ""
echo "Hmm... before we begin I think it would be a good idea"
echo "if I update your application repository and install some"
echo "updates. This shouldn't take long... SIT TIGHT! :)"

#exec &>$INSTALL_LOG

echo ""
echo -ne "\nUpdating Aptitude Repos: ">/dev/tty
apt-get -y update
echo -ne "\nUpgrading Aptitude Apps: ">/dev/tty
apt-get -y upgrade
echo -ne "\nBuilding Essentials and Requirements: ">/dev/tty
apt-get -y install build-essential libaprutil1 libaprutil1-dev libapr1 libapr1-dev zip unzip git acl libxml2-dev libtool python-software-properties libfcgi-dev libjpeg62-dbg libmcrypt-dev libssl-dev libicu-dev libcurl4-openssl-dev libbz2-dev libjpeg-dev libpng-dev freetype* libc-client-dev libpspell-dev

#add-apt-repository ppa:ondrej/php5
#apt-get update


echo -e "\nDone! Let's continue.">/dev/tty
echo "">/dev/tty
installapache=true

if [ -e /usr/local/apache2/bin/apachectl ]; then
echo "We have detected that Apache already exists.">/dev/tty
echo "If this is a prior uWebCP Apache Install you">/dev/tty
echo "may skip this step. If it isn't YOU NEED TO RUN">/dev/tty
echo "THIS or else the installer will break.">/dev/tty
echo "">/dev/tty
echo "NOTE: THIS WILL DELETE AND REMOVE ANY PRIOR APACHE INSTALL">/dev/tty
echo "AND THE WEB DATA ASSOCIATED WITH THEM!!!">/dev/tty
while true; do
echo -n "(Y)es or (N)o:">/dev/tty
read yn
case $yn in
	[Yy]* ) installapache=true;break;;
	[Nn]* ) installapache=false;break;;
	* ) echo "Please answer yes or no.">dev/tty;;
esac
done
fi


rm -rf ~/UvoraWCPTMP
mkdir -p ~/UvoraWCPTMP
cd ~/UvoraWCPTMP
service apache2 stop
/etc/init.d/apache2 stop
/etc/init.d/apache stop
/etc/init.d/apachectl stop
/etc/init.d/httpd stop

if $installapache; then

rm -f /etc/init.d/apache2
rm -f /etc/init.d/apache
rm -f /etc/init.d/apachectl
rm -f /etc/init.d/httpd
rm -f /etc/rc*/*apache2

rm -rf /usr/local/apache2
rm -rf /var/www

echo -n "Downloading Apache (2.4.6):">/dev/tty
wget http://www.interior-dsgn.com/apache/httpd/httpd-2.4.6.tar.gz
tar xvf httpd-2.4.6.tar.gz
cd httpd-2.4.6/
echo -ne "\nConfiguring Apache (This will take a moment):">/dev/tty
./configure --prefix=/usr/local/apache2 --enable-mods-shared=all --enable-so --enable-cgi --enable-suexec --with-suexec-docroot=/ --with-suexec-caller=ucp-apache-usr
echo -ne "\nBuilding Apache (This will take SERVERAL moments):">/dev/tty
make -j8
echo -ne "\nInstalling Apache:">/dev/tty
make install
cd ../
echo "">/dev/tty
echo "Apache Installation Finished.">/dev/tty
echo "">/dev/tty
echo -n "Creating Init.D and RCs.D SymLinks:">/dev/tty

ln -s /usr/local/apache2/bin/apachectl /etc/init.d/apache2 
update-rc.d apache2 defaults

groupadd ucp-apache
useradd -g ucp-apache ucp-apache-usr
echo "">/dev/tty
echo -n "Restructuring Apache:">/dev/tty

chown -R root:ucp-apache /usr/local/apache2

find /usr/local/apache2 -type d | xargs chmod 771
find /usr/local/apache2 -type f | xargs chmod 770
find /usr/local/apache2/cgi-bin -type d | xargs chmod 755
find /usr/local/apache2/cgi-bin -type f | xargs chmod 744

rm -rf /usr/local/apache2/htdocs
mkdir -p /var/www
chown ucp-apache-usr:ucp-apache /var/www
chown -R ucp-apache-usr:ucp-apache /var/www
find /var/www -type d | xargs chmod 750
find /var/www -type f | xargs chmod 740

cd /usr/local/apache2/conf

while read line; do
  echo "$line"
  if [[ "$line" = "#ServerName www.example.com:80" ]]; then
      echo -e "\nMaxRequestsPerProcess 500\nAddHandler fcgid-script .php5 .php4 .php .php3 .php2 .phtml\nFCGIWrapper /usr/local/php/bin/php-cgi .php5\nFCGIWrapper /usr/local/php/bin/php-cgi .php4\nFCGIWrapper /usr/local/php/bin/php-cgi .php\nFCGIWrapper /usr/local/php/bin/php-cgi .php3\nFCGIWrapper /usr/local/php/bin/php-cgi .php2\nFCGIWrapper /usr/local/php/bin/php-cgi .phtml\n\nAddHandler cgi-script .cgi .pl\n\nServerSignature On"
  fi
done < /usr/local/apache2/conf/httpd.conf

perl -pi -e 's{DocumentRoot "/usr/local/apache2/htdocs}{DocumentRoot "/var/www}g' httpd.conf
perl -pi -e 's{<Directory "/usr/local/apache2/htdocs}{<Directory "/var/www}g' httpd.conf
perl -pi -e 's{Options Indexes FollowSymLinks}{Options Indexes FollowSymLinks ExecCGI}g' httpd.conf
perl -pi -e 's{User daemon}{User ucp-apache-usr}g' httpd.conf
perl -pi -e 's{Group daemon}{Group ucp-apache}g' httpd.conf

perl -pi -e 's/#LoadModule rewrite_module/LoadModule rewrite_module/g' httpd.conf
perl -pi -e 's/#LoadModule userdir_module/LoadModule userdir_module/g' httpd.conf
perl -pi -e 's/#LoadModule ssl_module/LoadModule ssl_module/g' httpd.conf
perl -pi -e 's/#LoadModule autoindex_module/LoadModule autoindex_module/g' httpd.conf
perl -pi -e 's/#LoadModule suexec_module/LoadModule suexec_module/g' httpd.conf
perl -pi -e 's/#LoadModule actions_module/LoadModule actions_module/g' httpd.conf
perl -pi -e 's{#Include conf/extra/httpd-userdir.conf}{Include conf/extra/httpd-userdir.conf}g' httpd.conf
perl -pi -e 's{#Include conf/extra/httpd-vhosts.conf}{Include conf/extra/httpd-vhosts.conf}s' httpd.conf
perl -pi -e 's{#LoadModule cgi_module}{LoadModule cgi_module}g' httpd.conf
perl -pi -e 's{#AddHandler cgi-script .cgi}{AddHandler cgi-script .cgi .pl}g' httpd.conf
perl -pi -e 's{DirectoryIndex index.html}{DirectoryIndex Priority\nDirectoryIndex index.html.var index.htm index.html index.shtml index.xhtml index.wml index.perl index.pl index.plx index.ppl index.cgi index.jsp index.js index.jp index.php4 index.php3 index.php index.phtml default.htm default.html home.htm index.php5 Default.html Default.htm home.html}g' httpd.conf

perl -pi -e 's{Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec}{Options MultiViews Indexes SymLinksIfOwnerMatch ExecCGI}g' extra/httpd-userdir.conf
perl -pi -e 's{AllowOverride FileInfo AuthConfig Limit Indexes}{AllowOverride All}g' extra/httpd-userdir.conf

fi

echo "">/dev/tty
echo -n "Changing SuExec Permissions:">/dev/tty
chgrp ucp-apache /usr/local/apache2/bin/suexec
chmod 4750 /usr/local/apache2/bin/suexec
echo "">/dev/tty

cd ~/UvoraWCPTMP
echo -n "Installing FCGID:">/dev/tty
wget http://mirrors.sonic.net/apache//httpd/mod_fcgid/mod_fcgid-2.3.9.tar.gz
tar -zxf mod_fcgid-2.3.9.tar.gz
cd mod_fcgid-2.3.9
APXS=/usr/local/apache2/bin/apxs ./configure.apxs
make -j8
make install
cd ~/UvoraWCPTMP

echo "">/dev/tty
echo -n "Downloading PHP (5.5.5):">/dev/tty
rm -rf mirror

#wget http://us1.php.net/get/php-5.5.5.tar.gz/from/this/mirror
#tar xvf mirror
#cd php-5.5.5
#echo -ne "\nConfiguring PHP (This will take a moment):">/dev/tty
#./configure --with-apxs2=/usr/local/apache2/bin/apxs --enable-cgi --enable-mbstring --with-curl --with-openssl --with-xmlrpc --enable-soap --enable-zip --with-gd --with-jpeg-dir --with-png-dir --with-mysql --with-pgsql --enable-embedded-mysqli --with-freetype-dir --with-ldap --enable-intl --with-xsl --with-zlib
#echo -ne "\nBuilding PHP (This will take an EVEN LONGER TIME):">/dev/tty
#make
#echo -ne "\nInstalling PHP:">/dev/tty
#make install
#libtool --finish /root/php-5.5.5/libs


cd /usr/local/apache2/conf
perl -pi -e 's{LoadModule php5_module}{#LoadModule php5_module}g' httpd.conf

cd ~/
echo "PHP Installation Finished.">/dev/tty
echo "">/dev/tty
echo "Installing MariaDB 10.0 (AKA MySQL 5.6):">/dev/tty
genpasswd() {
	local l=$1
       	[ "$l" == "" ] && l=16
      	tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}
 
MARIADB_PASS=$(genpasswd 20)

apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
add-apt-repository 'deb http://ftp.osuosl.org/pub/mariadb/repo/10.0/ubuntu saucy main'
apt-get update
echo mariadb-server-10.0 mysql-server/root_password password $MARIADB_PASS | sudo debconf-set-selections
echo mariadb-server-10.0 mysql-server/root_password_again password $MARIADB_PASS | sudo debconf-set-selections
apt-get -y install mariadb-server

echo $MARIADB_PASS>/dev/tty

#exec 1>/dev/tty