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

locale-gen en_US.UTF-8

/etc/init.d/sendmail stop

apt-get -y remove proftpd-mod-mysql
rm -rf /etc/proftpd
apt-get -y remove mariadb-server
apt-get -y remove apache
apt-get -y remove apache2
apt-get -y remove sendmail sendmail-bin procmail

apt-get -y purge mysql* && apt-get -y autoremove
apt-get -y purge mariadb* && apt-get -y autoremove
apt-get -y purge sendmail && apt-get -y autoremove
apt-get -y purge sendmail sendmail-bin

apt-get autoclean
rm -rf /etc/mysql

echo ""
echo -ne "\nUpdating Aptitude Repos: ">/dev/tty
apt-get -y update
echo -ne "\nUpgrading Aptitude Apps: ">/dev/tty
apt-get -y upgrade
echo -ne "\nBuilding Essentials and Requirements: ">/dev/tty
apt-get -y install sudo build-essential software-properties-common python-apt dialog libreadline-dev libaprutil1 libaprutil1-dev libapr1 libapr1-dev zip unzip git acl libxml2-dev libtool python-software-properties python perl libfcgi-dev libjpeg62-dbg libmcrypt-dev libssl-dev libicu-dev libcurl4-openssl-dev libbz2-dev libjpeg-dev libpng-dev freetype* libc-client-dev libpspell-dev wget curl e2fsprogs apache2-dev postfix mailutils libpcre3-dev pkg-config libkrb5-dev libpq-dev libxslt-dev
 
 
 
 
 
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
rm -f /etc/rc*/*apache
rm -f /etc/rc*/*apachectl

rm -rf /usr/local/apache2
rm -rf /var/www
 
echo -n "Downloading Apache (2.4.18):">/dev/tty
wget http://www.interior-dsgn.com/apache/httpd/httpd-2.4.18.tar.gz
tar xvf httpd-2.4.18.tar.gz
cd httpd-2.4.18/
echo -ne "\nConfiguring Apache (This will take a moment):">/dev/tty
./configure --prefix=/usr/local/apache2 --enable-mods-shared=all --enable-so --enable-ssl --enable-cgi --with-mpm=prefork --enable-suexec --with-suexec-docroot=/ --with-suexec-caller=ucp-apache-usr
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

sed -i '1,100000d' /usr/local/apache2/conf/extra/httpd-vhosts.conf

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
 
#while read line; do
 # echo "$line"
  #if [[ "$line" = "#ServerName www.example.com:80" ]]; then
   #   echo -e "\nMaxRequestsPerProcess 500\nAddHandler fcgid-script .php5 .php4 .php .php3 .php2 .phtml\nFCGIWrapper /usr/local/php/bin/php-cgi .php5\nFCGIWrapper /usr/local/php/bin/php-cgi .php4\nFCGIWrapper /usr/local/php/bin/php-cgi .php\nFCGIWrapper /usr/local/php/bin/php-cgi .php3\nFCGIWrapper /usr/local/php/bin/php-cgi .php2\nFCGIWrapper /usr/local/php/bin/php-cgi .phtml\n\nAddHandler cgi-script .cgi .pl\n\nServerSignature On"
  #fi
#done < /usr/local/apache2/conf/httpd.conf
 
perl -pi -e 's{DocumentRoot "/usr/local/apache2/htdocs}{DocumentRoot "/var/www/UWebCP/public_html}g' httpd.conf
perl -pi -e 's{<Directory "/usr/local/apache2/htdocs}{<Directory "/var/www/UWebCP/public_html}g' httpd.conf
perl -pi -e 's{Options Indexes FollowSymLinks}{Options Indexes FollowSymLinks ExecCGI}g' httpd.conf
perl -pi -e 's{User daemon}{User ucp-apache-usr}g' httpd.conf
perl -pi -e 's{Group daemon}{Group ucp-apache}g' httpd.conf
 
perl -pi -e 's/#LoadModule rewrite_module/LoadModule rewrite_module/g' httpd.conf
perl -pi -e 's/#LoadModule userdir_module/LoadModule userdir_module/g' httpd.conf
perl -pi -e 's/#LoadModule ssl_module/LoadModule ssl_module/g' httpd.conf
perl -pi -e 's/#LoadModule autoindex_module/LoadModule autoindex_module/g' httpd.conf
#perl -pi -e 's/#LoadModule suexec_module/LoadModule suexec_module/g' httpd.conf
perl -pi -e 's/#LoadModule actions_module/LoadModule actions_module/g' httpd.conf
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
 
#cd ~/UvoraWCPTMP
#echo -n "Installing FCGID:">/dev/tty
#wget http://mirrors.sonic.net/apache//httpd/mod_fcgid/mod_fcgid-2.3.9.tar.gz
#tar -zxf mod_fcgid-2.3.9.tar.gz
#cd mod_fcgid-2.3.9
#APXS=/usr/local/apache2/bin/apxs ./configure.apxs
#make -j8
#make install
cd ~/UvoraWCPTMP
echo "">/dev/tty
echo -n "Downloading MPM-ITK:">/dev/tty
wget http://mpm-itk.sesse.net/mpm-itk-2.4.7-04.tar.gz
tar -xzf mpm-itk-2.4.7-04.tar.gz
cd mpm-itk-2.4.7-04
./configure --with-apxs=/usr/local/apache2/bin/apxs
make
make install
echo "">/dev/tty


mkdir /usr/lib64
cp /usr/lib/libc-client.a /usr/lib64/
cp /usr/lib/libc-client.so /usr/lib64/
cp /usr/lib/libc-client.so.2007e /usr/lib64/

sudo mkdir /usr/kerberos
sudo ln -s /usr/lib/x86_64-linux-gnu/mit-krb5/* /usr/kerberos

cd ~/UvoraWCPTMP

echo "">/dev/tty
echo -n "Downloading/Installing PHP (7.0.3):">/dev/tty
echo -n "This is going to take a LONG LONG time:">/dev/tty
mkdir -p PHPFILES
cd PHPFILES
wget http://us1.php.net/get/php-7.0.3.tar.gz/from/this/mirror
tar -xzf mirror
cd php-7.0.3
./configure --prefix=/usr/local/php --with-apxs2=/usr/local/apache2/bin/apxs --with-zlib-dir --with-freetype-dir --enable-cgi --enable-mbstring --enable-soap --enable-calendar --with-curl --with-mcrypt --with-zlib --with-gd --with-bz2 --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --enable-zip --with-xsl --with-pcre-regex --with-mysql --with-pdo-mysql --with-mysqli --with-pgsql --with-pdo-pgsql --enable-ipv6 --with-jpeg-dir=/usr --with-png-dir=/usr --enable-gd-native-ttf --with-openssl --with-libdir=lib64 --with-libxml-dir=/usr --enable-exif --enable-dba --with-gettext --enable-shmop --enable-sysvmsg --enable-wddx --with-imap=/usr/lib --with-imap-ssl --with-kerberos --enable-bcmath --enable-ftp --enable-intl --with-pspell --with-sqlite3
make -j8
make install
echo "">/dev/tty
 
cp php.ini-production /usr/local/apache2/conf/php.ini-production 

cd /usr/local/apache2/conf
#perl -pi -e 's{LoadModule php7_module}{#LoadModule php7_module}g' httpd.conf
 
cd ~/
echo "PHP Installation Finished.">/dev/tty
echo "">/dev/tty
echo "Installing MariaDB 10.0.X (AKA MySQL 5.6):">/dev/tty
genpasswd() {
    local l=$1
        [ "$l" == "" ] && l=16
        tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}
 
MARIADB_PASS=$(genpasswd 20)
 
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
sudo add-apt-repository 'deb [arch=amd64,i386] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.1/ubuntu wily main'
apt-get update
echo mariadb-server-10.1 mysql-server/root_password password $MARIADB_PASS | sudo debconf-set-selections
echo mariadb-server-10.1 mysql-server/root_password_again password $MARIADB_PASS | sudo debconf-set-selections
apt-get -y install mariadb-server libmariadbclient-dev
echo "Installation Finished.">/dev/tty 
echo "">/dev/tty

echo "Initalizing UvoraWebCP File Structure">/dev/tty
rm -rf /etc/UWebCP
mkdir /etc/UWebCP
mkdir /etc/UWebCP/panel
mkdir /var/www/UWebCP
mkdir /var/www/UWebCP/logs
mkdir /var/www/UWebCP/public_html
chown -R ucp-apache-usr:ucp-apache /var/www
find /var/www -type d | xargs chmod 750
find /var/www -type f | xargs chmod 740

echo "Jobs Done.">/dev/tty

echo "Fetching UWebCP from github to /opt/UWebCP">/dev/tty
rm -rf /opt/UWebCP
mkdir /opt/UWebCP
cd /opt/UWebCP

git clone https://github.com/jaredjones/Uvora-wCP.git
cd Uvora-wCP
git checkout master
mkdir ../UWebCPExport
git checkout-index -a -f --prefix=../UWebCPExport/
cd ../UWebCPExport
cp -fr * /etc/UWebCP/panel
echo "UWeb files have been fetched.">/dev/tty
echo "">/dev/tty
echo "Compiling USudo">/dev/tty
cc -o /etc/UWebCP/panel/Installation/Ubuntu-14.04/usudo /etc/UWebCP/panel/Installation/Ubuntu-14.04/usudo.c
chown root /etc/UWebCP/panel/Installation/Ubuntu-14.04/usudo
chmod +s /etc/UWebCP/panel/Installation/Ubuntu-14.04/usudo
echo "Done.">/dev/tty

#NOTREADY
#echo "Installing and Configuring ProFTPD:">/dev/tty
#
#echo proftpd-basic shared/proftpd/inetd_or_standalone select standalone | debconf-set-selections
#apt-get -y install proftpd-mod-mysql 
#mysql -uroot -p$MARIADB_PASS < /etc/UWebCP/panel/Installation/ProFTPD/uwebcp_proftpd.sql
#groupadd -g 2001 ucp-ftpgroup
#useradd -u 2001 -s /bin/false -d /bin/null -c "UWebCP ProFTPD user" -g ucp-ftpgroup ucp-ftpuser
#SQL_LINE=`grep "SQLConnectInfo" /etc/UWebCP/panel/Installation/ProFTPD/proftpd-mysql.conf -n | cut -d ":" -f1`
#SQL_LINE_NO=`expr $SQL_LINE + 1`
#sed -i "$SQL_LINE s/^/#/" /etc/UWebCP/panel/Installation/ProFTPD/proftpd-mysql.conf
#sed -i "$SQL_LINE_NO i SQLConnectInfo uwebcp_proftpd@localhost root $MARIADB_PASS" /etc/UWebCP/panel/Installation/ProFTPD/proftpd-mysql.conf
#mv /etc/proftpd/proftpd.conf /etc/proftpd/proftpd.conf.bk
#touch /etc/proftpd/proftpd.conf
#echo "include /etc/UWebCP/panel/Installation/ProFTPD/proftpd-mysql.conf" >> /etc/proftpd/proftpd.conf
#mkdir /var/www/UWebCP/logs/proftpd
#chmod -R 644 /var/www/UWebCP/logs/proftpd

echo "Done.">/dev/tty


echo $MARIADB_PASS>/dev/tty



 
#exec 1>/dev/tty
 
