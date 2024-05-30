#!/bin/bash
#Project address: https://github.com/Shirley-Jones/daloradius-boya
#Thank you very much for using this project!
#博雅情韵QQ: 2223139086
#Shirley后期修复编写

Download_address_selection()
{
	
	echo
	echo "请选择下载地址"
	echo "1、Github"
	echo "2、私有源"
	read -p "请选择[1-2]: " Download_address_Option
	
	while [[ ${Download_address_Option} == "" ]]
	do
		echo -e "\033[31m检测到下载地址没有选择，请重新尝试！\033[0m"
		echo "请选择下载地址"
		echo "1、Github"
		echo "2、私有源"
		read -p "请选择[1-2]: " Download_address_Option
	done
	
	
	#请直接在此处修改您的下载地址
	
	if [[ ${Download_address_Option} == "1" ]];then
		echo "已选择【Github】"
		Download_Host="https://raw.githubusercontent.com/Shirley-Jones/daloradius-boya/main/source/$Boya_Version"
	fi
	
	if [[ ${Download_address_Option} == "2" ]];then
		echo "已选择【私有源】"
		Download_Host=""
	fi
	
	return 0;
	
}

System_Check()
{
	
	if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
		Linux_OS='CentOS'
		PM='yum'
	elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
		Linux_OS='RHEL'
		PM='yum'
	elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
		Linux_OS='Aliyun'
		PM='yum'
	elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
		Linux_OS='Fedora'
		PM='yum'
	elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
		Linux_OS='Debian'
		PM='apt'
	elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
		Linux_OS='Ubuntu'
		PM='apt'
	elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
		Linux_OS='Raspbian'
		PM='apt'
	else
		Linux_OS='Unknown'
	fi
	
	if [[ !${Linux_OS} ==  "CentOS" ]]; then 
		echo "当前的Linux系统不支持安装博雅DALO!!!"
		exit 1;
	fi
	
	
	#获取Linux发行版 版本号
	#加载文件
	source /etc/os-release
	Linux_Version=${VERSION_ID}
	
	if [[ !${Linux_Version} ==  "7" ]]; then 
		echo "当前的Linux CentOS系统不支持安装博雅DALO!!!"
		exit 1;
	fi
	
	
	if [[ "$EUID" -ne 0 ]]; then  
		echo "对不起，您需要以root身份运行"  
		exit 1;
	fi
	
	
	if [[ ! -e /dev/net/tun ]]; then  
		echo "TUN不可用"  
		exit 1;
	fi
	
	ALL_RAM_free=$(echo `free | grep Mem | awk '{print $2 / 1024}'`|sed "s/\..*//g")
	
	if [[ ${ALL_RAM_free} -lt "800" ]]; then
		echo "警告, 系统RAM少于800MB(当前 "${ALL_RAM_free}"MB),只能安装节点服务器!!!"
		sleep 3
	fi
	
	
	return 0;
}


Detect_server_IP_address()
{
	clear
	echo
	echo -e "\033[1;32m==========================================================================\033[0m"
	echo -e "\033[1;32m                       博雅-DALO 稳定版 安装开始                          \033[0m"
	echo -e ""
	echo -e "\033[1;32m                            QQ：2223139086                                \033[0m"
	echo -e "\033[1;32m                       Welcome to use this program                        \033[0m"
	echo -e ""
	echo -e "\033[1;32m                                         版权所有 博雅Dalo                \033[0m"
	echo -e "\033[1;32m==========================================================================\033[0m"
	sleep 3
	echo -e ""
	echo "正在检测您的服务器IP地址！"
	Server_IP=`wget http://members.3322.org/dyndns/getip -O - -q ; echo`;
	if [ ${Server_IP} = "" ]; then
		#空白
		echo -e "\033[31m我们无法检测您的服务器IP地址，会影响到您接下来的搭建工作，强制退出程序！！！~\033[0m"
		exit 1;
	else
		#已获取到信息
		Auth_MD5=$(echo -n "${Server_IP}" | md5sum | awk '{print $1}');
		echo
		echo -e "检测到您的IP为: \033[1;33m"${Server_IP}"\033[0m 如不正确请立刻停止搭建，回车继续！"
		read
		sleep 1
		return 0;
	fi
}

Installation_requires_software()
{
	#lsb_release -a
	
	if [ ! -f /usr/bin/wget ]; then
		yum install wget -y >/dev/null 2>&1
		if [ ! -f /usr/bin/wget ]; then
			echo "wget 安装失败，强制退出程序!!!"
			exit 1;
		fi
	fi
	
	if [ ! -f /usr/bin/curl ]; then
		yum install curl -y >/dev/null 2>&1
		if [ ! -f /usr/bin/curl ]; then
			echo "curl 安装失败，强制退出程序!!!"
			exit 1;
		fi
	fi
	
	if [ ! -f /usr/sbin/ifconfig ]; then
		yum install net-tools -y >/dev/null 2>&1
		if [ ! -f /usr/sbin/ifconfig ]; then
			echo "net-tools 安装失败，强制退出程序!!!"
			exit 1;
		fi
	fi
	
	
	if [ ! -f /usr/bin/rm ] && [ ! -f /usr/sbin/rm ] && [ ! -f /bin/rm ] && [ ! -f /sbin/rm ]; then
		echo "系统环境异常，强制退出程序 -1!!!"
		exit 1;
	fi
	
	
	
	if [ ! -f /usr/bin/cp ] && [ ! -f /usr/sbin/cp ] && [ ! -f /bin/cp ] && [ ! -f /sbin/cp ]; then
		echo "系统环境异常，强制退出程序 -2!!!"
		exit 1;
	fi
	
	
	if [ ! -f /usr/bin/mv ] && [ ! -f /usr/sbin/mv ] && [ ! -f /bin/mv ] && [ ! -f /sbin/mv ]; then
		echo "系统环境异常，强制退出程序 -3!!!"
		exit 1;
	fi
	
	
	if [ ! -f /usr/bin/chmod ] && [ ! -f /usr/sbin/chmod ] && [ ! -f /bin/chmod ] && [ ! -f /sbin/chmod ]; then
		echo "系统环境异常，强制退出程序 -4!!!"
		exit 1;
	fi
	
	
	Read_network_card_information=`ifconfig`;
	Read_main_network_card_information=`echo $Read_network_card_information|awk '{print $1}'`;
	Main_network_card_name=`printf ${Read_main_network_card_information/:/}`
	if [[ ${Main_network_card_name} == "" ]]; then 
		echo "无法获取主网卡信息，强制退出程序!!!"
		exit 1;
	fi
	
	

	return 0;
}


daloradius_INSTALL_Check()
{

	if [ -f /usr/local/etc/raddb/radiusd.conf ]; then
		echo "检测到您已安装博雅DALO，不能重复安装 -1!!!"
		exit 1;
	fi
	
	if [ -f /etc/raddb/radiusd.conf ]; then
		echo "检测到您已安装博雅DALO，不能重复安装 -2!!!"
		exit 1;
	fi
	
	if [ -f /boya/bin/vpn ]; then
		echo "检测到您已安装博雅DALO，不能重复安装 -3!!!"
		exit 1;
	fi
	
	if [ -f /Shirley/bin/vpn ]; then
		echo "检测到您已安装博雅DALO，不能重复安装 -4!!!"
		exit 1;
	fi
	
	if [ -f /usr/bin/mysql ] && [ -f /usr/sbin/mysql ] && [ -f /bin/mysql ] && [ -f /sbin/mysql ]; then
		echo "检测到您已安装博雅DALO/MySQL，不能重复安装 -5!!!"
		exit 1;
	fi
	
	return 0;
}

New_installation_guide()
{
	#主机+节点服务器
	clear
	sleep 1
	echo
	
	daloradius_INSTALL_Check
	
	echo "Tips:"
	echo "后台管理路径如果不懂什么意思请直接输入 admin 即可！乱输入会导致不能打开后台!!!"
	echo
	read -p "请设置后台管理路径: " DaloRadius_file
	while [[ ${DaloRadius_file} == "" ]]
	do
		echo -e "\033[31m检测到后台管理路径没有输入，请重新尝试！\033[0m"
		read -p "请设置后台管理路径: " DaloRadius_file
	done
	
	echo
	read -p "请设置后台账号: " DaloRadius_Username
	while [[ ${DaloRadius_Username} == "" ]]
	do
		echo -e "\033[31m检测到后台账号没有输入，请重新尝试！\033[0m"
		read -p "请设置后台账号: " DaloRadius_Username
	done
	
	echo
	read -p "请设置后台密码: " DaloRadius_Password
	while [[ ${DaloRadius_Password} == "" ]]
	do
		echo -e "\033[31m检测到后台密码没有输入，请重新尝试！\033[0m"
		read -p "请设置后台密码: " DaloRadius_Password
	done
	
	echo
	read -p "请输入SSH端口号: " SSH_Port
	while [[ ${SSH_Port} == "" ]]
	do
		echo -e "\033[31m检测到SSH端口号没有输入，请重新尝试！\033[0m"
		read -p "请输入SSH端口号: " SSH_Port
	done
	
	echo
	read -p "请设置Apache端口: " Apache_Port
	while [[ ${Apache_Port} == "" ]]
	do
		echo -e "\033[31m检测到Apache端口没有输入，请重新尝试！\033[0m"
		read -p "请设置Apache端口: " Apache_Port
	done
	
	echo
	read -p "请设置数据库密码: " Database_Password
	while [[ ${Database_Password} == "" ]]
	do
		echo -e "\033[31m检测到数据库密码没有输入，请重新尝试！\033[0m"
		read -p "请设置数据库密码: " Database_Password
	done
	
	echo
	echo "请选择DNS地址"
	echo "1、阿里云 DNS"
	echo "2、114 DNS"
	echo "3、Google DNS"
	read -p "请选择[1-3]: " DNS_Option
	
	while [[ ${DNS_Option} == "" ]]
	do
		echo -e "\033[31m检测到DNS地址没有输入，请重新尝试！\033[0m"
		echo "请选择DNS地址"
		echo "1、阿里云 DNS"
		echo "2、114 DNS"
		echo "3、Google DNS"
		read -p "请选择[1-3]: " DNS_Option
	done
	
	if [[ ${DNS_Option} == "1" ]];then
		echo "已选择【阿里云 DNS】"
		DNS_TYPE="223.5.5.5"
	fi
	
	if [[ ${DNS_Option} == "2" ]];then
		echo "已选择【114 DNS】"
		DNS_TYPE="114.114.114.114"
	fi
	
	if [[ ${DNS_Option} == "3" ]];then
		echo "已选择【Google DNS】"
		DNS_TYPE="8.8.8.8"
	fi
	
	
	Download_address_selection
	
	sleep 1
	echo
	echo "安装信息收集已完成，即将开始安装！"
	sleep 3
	
	
	return 0;
}


Install_node_guide()
{
	#节点服务器
	clear
	sleep 1
	echo
	
	daloradius_INSTALL_Check
	
	echo
	read -p "请输入SSH端口号: " SSH_Port
	while [[ ${SSH_Port} == "" ]]
	do
		echo -e "\033[31m检测到SSH端口号没有输入，请重新尝试！\033[0m"
		read -p "请输入SSH端口号: " SSH_Port
	done
	
	echo
	read -p "请输入主机IP: " radius_address
	while [[ ${radius_address} == "" ]]
	do
		echo -e "\033[31m检测到主机IP没有输入，请重新尝试！\033[0m"
		read -p "请输入主机IP: " radius_address
	done
	
	sleep 1
	echo "-------------流量监控数据库配置-------------"
	sleep 1
	echo
	read -p "请输入主机/云数据库地址: " Database_Address
	while [[ ${Database_Address} == "" ]]
	do
		echo -e "\033[31m检测到数据库地址没有输入，请重新尝试！\033[0m"
		read -p "请输入主机/云数据库地址: " Database_Address
	done
	
	echo
	read -p "请输入主机/云数据库端口: " Database_Port
	while [[ ${Database_Port} == "" ]]
	do
		echo -e "\033[31m检测到数据库端口没有输入，请重新尝试！\033[0m"
		read -p "请输入主机/云数据库端口: " Database_Port
	done
	
	echo
	read -p "请输入主机/云数据库账户: " Database_Username
	while [[ ${Database_Username} == "" ]]
	do
		echo -e "\033[31m检测到数据库账户没有输入，请重新尝试！\033[0m"
		read -p "请输入主机/云数据库账户: " Database_Username
	done
	echo
	read -p "请输入主机/云数据库密码: " Database_Password
	while [[ ${Database_Password} == "" ]]
	do
		echo -e "\033[31m检测到数据库密码没有输入，请重新尝试！\033[0m"
		read -p "请输入主机/云数据库密码: " Database_Password
	done
	sleep 1
	echo "-------------已完成流量监控数据库配置-------------"
	sleep 1
	echo "请选择DNS地址"
	echo "1、阿里云 DNS"
	echo "2、114 DNS"
	echo "3、Google DNS"
	read -p "请选择[1-3]: " DNS_Option
	
	while [[ ${DNS_Option} == "" ]]
	do
		echo -e "\033[31m检测到DNS地址没有输入，请重新尝试！\033[0m"
		echo "请选择DNS地址"
		echo "1、阿里云 DNS"
		echo "2、114 DNS"
		echo "3、Google DNS"
		read -p "请选择[1-3]: " DNS_Option
	done
	
	if [[ ${DNS_Option} == "1" ]];then
		echo "已选择【阿里云 DNS】"
		DNS_TYPE="223.5.5.5"
	fi
	
	if [[ ${DNS_Option} == "2" ]];then
		echo "已选择【114 DNS】"
		DNS_TYPE="114.114.114.114"
	fi
	
	if [[ ${DNS_Option} == "3" ]];then
		echo "已选择【Google DNS】"
		DNS_TYPE="8.8.8.8"
	fi
	
	
	Download_address_selection
	
	sleep 1
	echo
	echo "安装信息收集已完成，即将开始安装！"
	sleep 3
	return 0;
}



Install_boya_daloradius()
{
	#Installation_mode
	
	#----------开始安装----------
	
	clear
	sleep 1
	
	echo
	echo "正在初始化环境..."
	
	if [[ ${ALL_RAM_free} -lt "800" ]]; then
		#内存少于800MB  创建虚拟内存Swap 1GB
		fallocate -l 1G /ZeroSwap
		ls -lh /ZeroSwap >/dev/null 2>&1
		chmod 600 /ZeroSwap
		mkswap /ZeroSwap >/dev/null 2>&1
		swapon /ZeroSwap >/dev/null 2>&1
		echo "/ZeroSwap none swap sw 0 0" >> /etc/fstab
	fi
	
	#设置SELinux宽容模式
	setenforce 0 >/dev/null 2>&1
	sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config >/dev/null 2>&1
	
	
	echo "正在安装运行库等文件..."
	yum groupinstall Development tools -y >/dev/null 2>&1
	yum install make openssl gcc gdb net-tools unzip psmisc wget curl zip vim telnet -y >/dev/null 2>&1
	yum install nss telnet avahi openssl openssl-libs openssl-devel lzo lzo-devel pam pam-devel automake pkgconfig gawk tar zip unzip net-tools psmisc gcc pkcs11-helper libxml2 libxml2-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel --skip-broken -y >/dev/null 2>&1
	yum install epel-release -y >/dev/null 2>&1
	
	
	if [[ ${Installation_mode} ==  "ALL" ]]; then 
		#add php 国内服务器安装较慢请耐心等待
		yum install yum-utils -y >/dev/null 2>&1
		rpm -ivh https://rpms.remirepo.net/enterprise/remi-release-7.rpm >/dev/null 2>&1
		if [ ! -f /etc/yum.repos.d/remi.repo ] && [ ! -f /etc/yum.repos.d/remi-modular.repo ] && [ ! -f remi-safe.repo ]; then
			#不存在 重新安装
			echo "remi-release安装失败，强制退出程序 -1"
			exit 1;
		fi
		#yum-config-manager --enable remi-php56 -y >/dev/null 2>&1
		#创建新缓存 国内服务器安装较慢请耐心等待
		yum clean all >/dev/null 2>&1
		yum makecache >/dev/null 2>&1
		
		echo "正在安装LAMP..."
		yum install httpd httpd-tools -y >/dev/null 2>&1
		if [ ! -f /etc/httpd/conf/httpd.conf ]; then
			echo "Apache(httpd)软件包安装失败，可能是源站点错误请反馈给Shirley！程序强制退出!!!"
			exit 1;
		fi
		yum remove php* -y >/dev/null 2>&1
		yum install --enablerepo=remi --enablerepo=remi-php56 php php-mbstring php-gd php-mysql php-pear php-pear-DB php-cli php-common php-ldap php-odbc php-xmlrpc -y >/dev/null 2>&1
		#需要安装DB拓展 否则daloradius打不开
		pear install MDB2 >/dev/null 2>&1
		sed -i "s/#ServerName www.example.com:80/ServerName localhost:"${Apache_Port}"/g" /etc/httpd/conf/httpd.conf
		sed -i "s/Listen 80/Listen "${Apache_Port}"/g" /etc/httpd/conf/httpd.conf
		sed -i "s/ServerTokens OS/ServerTokens Prod/g" /etc/httpd/conf/httpd.conf
		sed -i "s/ServerSignature On/ServerSignature Off/g" /etc/httpd/conf/httpd.conf
		sed -i "s/Options Indexes MultiViews FollowSymLinks/Options MultiViews FollowSymLinks/g" /etc/httpd/conf/httpd.conf
		sed -i "s/magic_quotes_gpc = Off/magic_quotes_gpc = On/g" /etc/php.ini
		setsebool httpd_can_network_connect 1 >/dev/null 2>&1
		systemctl restart httpd.service
		systemctl enable httpd.service >/dev/null 2>&1
		
		if [ ! -f /usr/bin/php ] && [ ! -f /usr/sbin/php ] && [ ! -f /bin/php ] && [ ! -f /sbin/php ]; then
			echo "PHP软件包安装失败，可能是源站点错误请反馈给Shirley！程序强制退出!!!"
			exit 1;
		fi
		
		#安装Database
		yum install mariadb mariadb-server mariadb-devel -y >/dev/null 2>&1
		if [ ! -f /usr/bin/mysql ] && [ ! -f /usr/sbin/mysql ] && [ ! -f /bin/mysql ] && [ ! -f /sbin/mysql ]; then
			echo "Database(Mariadb)软件包安装失败，可能是源站点错误请反馈给Shirley！程序强制退出!!!"
			exit 1;
		fi
		systemctl start mariadb.service >/dev/null 2>&1
		mysqladmin -uroot password ${Database_Password}
		mysql -uroot -p${Database_Password} -e 'create database radius;'
		mysql -uroot -p${Database_Password} -e "use mysql;GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '"${Database_Password}"' WITH GRANT OPTION;flush privileges;"
		systemctl restart mariadb.service
		systemctl enable mariadb.service >/dev/null 2>&1
		
		
		#安装FreeRadius-server
		echo "正在安装FreeRadius..."
		yum install freeradius freeradius-devel freeradius-utils freeradius-mysql freeradius-doc -y >/dev/null 2>&1
		rm -rf /etc/raddb/mods-available/sql
		rm -rf /etc/raddb/mods-available/sqlcounter
		rm -rf /etc/raddb/sites-available/default
		rm -rf /etc/raddb/mods-config/files/authorize
		rm -rf /etc/raddb/mods-enabled/sql
		rm -rf /etc/raddb/mods-enabled/sqlcounter
		rm -rf /etc/raddb/sites-enabled/default
		rm -rf /etc/raddb/radiusd.conf
		rm -rf /etc/raddb/clients.conf
		rm -rf /etc/raddb/dictionary
		rm -rf /etc/raddb/users
		cd /etc/raddb
		wget -q ${Download_Host}/raddb.zip -P /etc/raddb
		unzip -o /etc/raddb/raddb.zip >/dev/null 2>&1
		rm -rf /etc/raddb/raddb.zip
		ln -s /etc/raddb/mods-config/files/authorize /etc/raddb/users
		ln -s /etc/raddb/mods-available/sql /etc/raddb/mods-enabled/sql
		ln -s /etc/raddb/mods-available/sqlcounter /etc/raddb/mods-enabled/sqlcounter
		ln -s /etc/raddb/sites-available/default /etc/raddb/sites-enabled/default
		mysql -uroot -p${Database_Password} radius < /etc/raddb/mods-config/sql/main/mysql/extras/wimax/schema.sql
		mysql -uroot -p${Database_Password} radius < /etc/raddb/mods-config/sql/cui/mysql/schema.sql
		mysql -uroot -p${Database_Password} radius < /etc/raddb/mods-config/sql/main/mysql/schema.sql
		sed -i 's/MySQL_Host/localhost/g' /etc/raddb/mods-available/sql
		sed -i 's/MySQL_Port/3306/g' /etc/raddb/mods-available/sql
		sed -i 's/MySQL_User/root/g' /etc/raddb/mods-available/sql
		sed -i 's/MySQL_Pass/'${Database_Password}'/g' /etc/raddb/mods-available/sql
		#启动RADIUS
		#修改启动模块 必须启动先mariadb，然后才能启动RADIUS，否则开机不能正常启动
		sed -i '3s/$/ mariadb.service /' /usr/lib/systemd/system/radiusd.service
		systemctl start radiusd.service
		systemctl enable radiusd.service >/dev/null 2>&1
		
		echo "正在安装博雅DALO Panel..."
		#安装daloradius panel
		rm -rf /var/www/html/*
		cd /var/www/html/
		wget -q ${Download_Host}/daloradius_panel.zip -P /var/www/html
		wget -q ${Download_Host}/phpmyadmin_panel.zip -P /var/www/html
		unzip -o /var/www/html/daloradius_panel.zip >/dev/null 2>&1
		unzip -o /var/www/html/phpmyadmin_panel.zip >/dev/null 2>&1
		rm -rf /var/www/html/daloradius_panel.zip
		rm -rf /var/www/html/phpmyadmin_panel.zip
		#修改daloradius数据库信息
		sed -i 's/MySQL_Host/localhost/g' /var/www/html/daloradius/library/daloradius.conf.php
		sed -i 's/MySQL_Port/3306/g' /var/www/html/daloradius/library/daloradius.conf.php
		sed -i 's/MySQL_User/root/g' /var/www/html/daloradius/library/daloradius.conf.php
		sed -i 's/MySQL_Pass/'${Database_Password}'/g' /var/www/html/daloradius/library/daloradius.conf.php
		chmod -R 0777 /var/www/html/daloradius/library/daloradius.conf.php
		#需要先导入daloradius数据库后再删除dictionary表  然后导入新的dictionary表
		sed -i "s/'Dalo_User','Dalo_Pass'/'$DaloRadius_Username','$DaloRadius_Password'/g" /var/www/html/daloradius/contrib/db/mysql-daloradius.sql
		mysql -uroot -p${Database_Password} radius < /var/www/html/daloradius/contrib/db/mysql-daloradius.sql
		mysql -uroot -p${Database_Password} -e 'USE radius;DROP TABLE IF EXISTS dictionary;'
		mysql -uroot -p${Database_Password} -e 'USE radius;DROP TABLE IF EXISTS radgroupcheck;'
		mysql -uroot -p${Database_Password} radius < /etc/raddb/dictionary.sql
		mysql -uroot -p${Database_Password} radius < /etc/raddb/radgroupcheck.sql
		
		mv /var/www/html/daloradius /var/www/html/${DaloRadius_file}
		
		
		#修改查询流量数据库信息
		sed -i 's/MySQL_Host/localhost/g' /var/www/html/user/info.php
		sed -i 's/MySQL_Port/3306/g' /var/www/html/user/info.php
		sed -i 's/MySQL_User/root/g' /var/www/html/user/info.php
		sed -i 's/MySQL_Pass/'${Database_Password}'/g' /var/www/html/user/info.php
	fi
	
	echo "正在安装防火墙..."
	echo '127.0.0.1 localhost' >> /etc/hosts
	systemctl stop firewalld.service >/dev/null 2>&1
	systemctl disable firewalld.service >/dev/null 2>&1
	systemctl stop iptables.service >/dev/null 2>&1
	yum install iptables iptables-services -y >/dev/null 2>&1
	systemctl restart iptables.service
	iptables -F
	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -t nat -P PREROUTING ACCEPT
	iptables -t nat -P POSTROUTING ACCEPT
	iptables -t nat -P OUTPUT ACCEPT
	iptables -t nat -F
	iptables -X
	iptables -t nat -X
	iptables -A INPUT -s 127.0.0.1/32  -j ACCEPT
	iptables -A INPUT -d 127.0.0.1/32  -j ACCEPT
	#SSH端口
	iptables -A INPUT -p tcp -m tcp --dport ${SSH_Port} -j ACCEPT
	if [[ ${Installation_mode} ==  "ALL" ]]; then 
		#Apache端口
		iptables -A INPUT -p tcp -m tcp --dport ${Apache_Port} -j ACCEPT
	fi
	#OpenVPN端口
	iptables -A INPUT -p tcp -m tcp --dport 1194 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 1195 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 1196 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 1197 -j ACCEPT
	iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
	#OpenVPN Proxy端口
	iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 3389 -j ACCEPT
	#Proxy端口
	iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
	#OpenVPN 内网IP
	iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o ${Main_network_card_name} -j MASQUERADE
	iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o ${Main_network_card_name} -j MASQUERADE
	iptables -t nat -A POSTROUTING -s 10.10.0.0/24 -o ${Main_network_card_name} -j MASQUERADE
	iptables -t nat -A POSTROUTING -s 10.11.0.0/24 -o ${Main_network_card_name} -j MASQUERADE
	iptables -t nat -A POSTROUTING -s 10.12.0.0/24 -o ${Main_network_card_name} -j MASQUERADE
	#dnsmasq端口
	iptables -A INPUT -p tcp -m tcp --dport 5353 -j ACCEPT
	iptables -A INPUT -p udp -m udp --dport 5353 -j ACCEPT
	iptables -t nat -A PREROUTING --dst 10.8.0.1 -p udp --dport 53 -j DNAT --to-destination 10.8.0.1:5353
	iptables -t nat -A PREROUTING --dst 10.9.0.1 -p udp --dport 53 -j DNAT --to-destination 10.9.0.1:5353
	iptables -t nat -A PREROUTING --dst 10.10.0.1 -p udp --dport 53 -j DNAT --to-destination 10.10.0.1:5353
	iptables -t nat -A PREROUTING --dst 10.11.0.1 -p udp --dport 53 -j DNAT --to-destination 10.11.0.1:5353
	iptables -t nat -A PREROUTING --dst 10.12.0.1 -p udp --dport 53 -j DNAT --to-destination 10.12.0.1:5353
	#RADIUS通讯端口
	iptables -A INPUT -p udp -m udp --dport 1812 -j ACCEPT
	iptables -A INPUT -p udp -m udp --dport 1813 -j ACCEPT
	#其他
	iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	service iptables save >/dev/null 2>&1
	systemctl restart iptables.service
	systemctl enable iptables.service >/dev/null 2>&1
	
	
	echo "正在安装博雅DALO Core..."
	
	#安装daloradius core
	rm -rf /Shirley
	mkdir /Shirley
	wget -q ${Download_Host}/Core.zip -P /Shirley
	cd /Shirley && unzip -o /Shirley/Core.zip >/dev/null 2>&1
	rm -rf /Shirley/Core.zip
	chmod -R 0777 /Shirley/*
	
	
	#修改监控数据库配置
	if [[ ${Installation_mode} ==  "ALL" ]]; then 
		sed -i 's/content1/127.0.0.1/g' /Shirley/Config/MySQL.conf
		sed -i 's/content2/3306/g' /Shirley/Config/MySQL.conf
		sed -i 's/content3/root/g' /Shirley/Config/MySQL.conf
		sed -i 's/content4/'${Database_Password}'/g' /Shirley/Config/MySQL.conf
		sed -i 's/content1/Install_All/g' /Shirley/Config/Config.conf
		#修改流量监控配置
		sed -i 's/content1/127.0.0.1/g' /Shirley/Config/auth_config.conf
		sed -i 's/content2/3306/g' /Shirley/Config/auth_config.conf
		sed -i 's/content3/root/g' /Shirley/Config/auth_config.conf
		sed -i 's/content4/'${Database_Password}'/g' /Shirley/Config/auth_config.conf
		sed -i 's/content5/'${Auth_MD5}'/g' /Shirley/Config/auth_config.conf
	fi
	
	
	#配置sysctl
	rm -rf /etc/sysctl.conf
	mv /Shirley/Config/sysctl.conf /etc/sysctl.conf
	sysctl -p >/dev/null 2>&1
	
	
	#安装openvpn
	yum install openvpn openvpn-devel -y >/dev/null 2>&1
	rm -rf /etc/openvpn
	mv /Shirley/openvpn /etc/openvpn
	
	#节点版本修改对接
	if [[ ${Installation_mode} ==  "Node" ]]; then 
		sed -i 's/name=localhost/name='${radius_address}'/g' /etc/openvpn/radiusplugin_server1194.cnf
		sed -i 's/name=localhost/name='${radius_address}'/g' /etc/openvpn/radiusplugin_server1195.cnf
		sed -i 's/name=localhost/name='${radius_address}'/g' /etc/openvpn/radiusplugin_server1196.cnf
		sed -i 's/name=localhost/name='${radius_address}'/g' /etc/openvpn/radiusplugin_server1197.cnf
		sed -i 's/name=localhost/name='${radius_address}'/g' /etc/openvpn/radiusplugin_server-udp.cnf
		sed -i 's/content1/Install_Node/g' /Shirley/Config/Config.conf
		#修改流量监控配置
		sed -i 's/content1/'${Database_Address}'/g' /Shirley/Config/auth_config.conf
		sed -i 's/content2/'${Database_Port}'/g' /Shirley/Config/auth_config.conf
		sed -i 's/content3/'${Database_Username}'/g' /Shirley/Config/auth_config.conf
		sed -i 's/content4/'${Database_Password}'/g' /Shirley/Config/auth_config.conf
		sed -i 's/content5/'${Auth_MD5}'/g' /Shirley/Config/auth_config.conf
	fi
	
	#重启openvpn
	systemctl restart openvpn@server1194.service
	systemctl restart openvpn@server1195.service
	systemctl restart openvpn@server1196.service
	systemctl restart openvpn@server1197.service
	systemctl restart openvpn@server-udp.service
	systemctl enable openvpn@server1194.service >/dev/null 2>&1
	systemctl enable openvpn@server1195.service >/dev/null 2>&1
	systemctl enable openvpn@server1196.service >/dev/null 2>&1
	systemctl enable openvpn@server1197.service >/dev/null 2>&1
	systemctl enable openvpn@server-udp.service >/dev/null 2>&1
	
	
	
	#安装dnsmasq
	yum install dnsmasq -y >/dev/null 2>&1
	rm -rf /etc/dnsmasq.conf
	mv /Shirley/Config/dnsmasq.conf /etc/dnsmasq.conf
	sed -i 's/DNS_ADDRESS/'${DNS_TYPE}'/g' /etc/dnsmasq.conf
	systemctl restart dnsmasq.service
	systemctl enable dnsmasq.service >/dev/null 2>&1
	
	
	
	#创建软连接（快捷方式）
	ln -s /Shirley/bin/* /usr/bin
	
	#配置服务并设置FAS proxy开机自启
	mv /Shirley/proxy.service /lib/systemd/system/proxy.service
	#添加开机自动执行shell服务 
	mv /Shirley/auto_run.service /lib/systemd/system/auto_run.service
	#重新加载所有服务
	systemctl daemon-reload >/dev/null 2>&1
	#启动服务
	systemctl restart proxy.service >/dev/null 2>&1
	#设置开机自启
	systemctl enable auto_run.service >/dev/null 2>&1
	systemctl enable proxy.service >/dev/null 2>&1
	
	#修改亚洲香港时区
	#列出全球时区 timedatectl list-timezones
	#以下为常用时区
	#韩国首尔 Asia/Seoul
	#台湾台北 Asia/Taipei
	#香港 Asia/Hong_Kong
	#中国上海 Asia/Shanghai
	#美国纽约 America/New_York
	#日本东京 Asia/Tokyo
	Time_zone_detection=$(timedatectl | grep "Asia/Hong_Kong")
	if [[ ${Time_zone_detection} == "" ]]; then 
		timedatectl set-local-rtc 0 >/dev/null 2>&1
		timedatectl set-timezone Asia/Hong_Kong >/dev/null 2>&1
	fi
	
	
	
	echo "所有文件安装已完成，即将结束安装...."
	sleep 3
	
	/Shirley/bin/vpn clean
	/Shirley/bin/vpn restart
	sleep 3
	
	#验证安装模式
	if [[ ${Installation_mode} == "ALL" ]]; then
		#主机模式
		clear
		echo "问候！"
		echo "您的博雅DALO系统安装完成，以下是您的安装信息"
		echo "---------------------------------------------------------------"
		echo "主要信息: "
		echo "后台管理: http://"${Server_IP}":"${Apache_Port}"/"${DaloRadius_file}""
		echo "后台账户: "${DaloRadius_Username}"   后台密码: "${DaloRadius_Password}""
		echo "用户流量查询: http://"${Server_IP}":"${Apache_Port}"/user"
		echo "APP下载: http://"${Server_IP}":"${Apache_Port}"/myapp (脑残勿用此链接) "
		echo "数据库管理: http://"${Server_IP}":"${Apache_Port}"/phpMyAdmin"
		echo "数据库账号: root    数据库密码: "${Database_Password}"                  "
		echo "线路模板: http://"${Server_IP}":"${Apache_Port}"/template.ovpn ) "
		echo "---------------------------------------------------------------"
		echo "端口信息"
		echo "请您在服务器后台面板 防火墙/安全组 中 开启以下端口"
		echo "TCP 1194 1195 1196 1197 8080 80 443 3389 "${SSH_Port}" "${Apache_Port}" "
		echo "UDP 53 5353"
		echo "---------------------------------------------------------------"
		echo "命令信息"
		echo "博雅DALO服务管理命令: vpn restart/start/stop/state"
		echo "博雅DALO 开端口命令: vpn port"
		echo "小工具命令； vpn tools "
		echo "自定义开机自启文件 /Shirley/Config/auto_run"
		echo "---------------------------------------------------------------"
		echo "其他信息"
		echo "项目地址: https://github.com/Shirley-Jones/daloradius-boya"
		echo "因旧版daloradius's OpenVPN 证书过期，这个版本已经更新了OpenVPN服务端证书，已经不兼容老版本证书，请注意更新您的线路文件!!!"
		echo "这个版本已经删除了博雅(情韵)预留的数据库账户 “radius  hehe123” 所以此账户已不可用，请使用root账户登录到您的数据库!!!"
		echo "系统时区已修改为:"$(timedatectl | grep "Asia/Hong_Kong")" "
		echo "安装后有问题联系技术  "
		echo "谢谢您!"
		echo "---------------------------------------------------------------"
	else
		clear
		echo "问候！"
		echo "您的博雅DALO节点系统安装完成，以下是您的安装信息"
		echo "---------------------------------------------------------------"
		echo "主要信息: "
		echo "节点版本没有任何后台管理以及数据库！"
		echo "---------------------------------------------------------------"
		echo "端口信息"
		echo "请您在服务器后台面板 防火墙/安全组 中 开启以下端口"
		echo "TCP 1194 1195 1196 1197 8080 80 443 3389 "${SSH_Port}" "
		echo "UDP 53 5353"
		echo "---------------------------------------------------------------"
		echo "命令信息"
		echo "博雅DALO服务管理命令: vpn restart/start/stop/state"
		echo "博雅DALO 开端口命令: vpn port"
		echo "小工具命令； vpn tools "
		echo "自定义开机自启文件 /Shirley/Config/auto_run"
		echo "---------------------------------------------------------------"
		echo "其他信息"
		echo "项目地址: https://github.com/Shirley-Jones/daloradius-boya"
		echo "因旧版daloradius's OpenVPN 证书过期，这个版本已经更新了OpenVPN服务端证书，已经不兼容老版本证书，请注意更新您的线路文件!!!"
		echo "这个版本已经删除了博雅(情韵)预留的数据库账户 “radius  hehe123” 所以此账户已不可用，请使用root账户登录到您的数据库!!!"
		echo "系统时区已修改为:"$(timedatectl | grep "Asia/Hong_Kong")" "
		echo "安装后有问题联系技术  "
		echo "谢谢您!"
		echo "---------------------------------------------------------------"
	fi
	
	
	return 0;
}




Install_boya_daloradius_dingd()
{
	#安装流量卫士
	clear 
	echo
	
	if [ ! -f /etc/raddb/radiusd.conf ] && [ ! -f /usr/local/etc/raddb/radiusd.conf ]; then
		echo "您还未安装博雅DALO，不能执行这个操作 -1!!!"
		exit 1;
	fi
	
	if [ -f /var/www/html/config.php ]; then
		echo "检测到您已安装流量卫士，不能重复安装 -2!!!"
		exit 1;
	fi
	
	if [ -d /var/www/html/admin_app ]; then
		echo "检测到您已安装流量卫士，不能重复安装 -3!!!"
		exit 1;
	fi
	
	if [ -f /var/www/html/app_api/config.php ]; then
		echo "检测到您已安装流量卫士，不能重复安装 -4!!!"
		exit 1;
	fi
	
	if [ -f /var/www/html/app_api/api.php ]; then
		echo "检测到您已安装流量卫士，不能重复安装 -5!!!"
		exit 1;
	fi
	
	
	echo "请选择数据库连接方式"
	echo "1、本机数据库"
	echo "2、云数据库"
	read -p "请选择[1-2]: " database_Option
	
	while [[ ${database_Option} == "" ]]
	do
		echo -e "\033[31m检测到数据库连接方式没有选择，请重新尝试！\033[0m"
		echo "请选择数据库连接方式"
		echo "1、本机数据库"
		echo "2、云数据库"
		read -p "请选择[1-2]: " database_Option
	done
	
	if [[ ${database_Option} == "1" ]];then
		Database_Address="localhost";
		Database_Port="3306";
		Database_Username="root";
		echo
		read -p "请输入数据库密码: " Database_Password
		while [[ ${Database_Password} == "" ]]
		do
			echo -e "\033[31m检测到数据库密码没有输入，请重新尝试！\033[0m"
			read -p "请输入数据库密码: " Database_Password
		done
		Database_connection_method="local"
	fi
	
	if [[ ${database_Option} == "2" ]];then
		echo
		read -p "请输入数据库地址: " Database_Address
		while [[ ${Database_Address} == "" ]]
		do
			echo -e "\033[31m检测到数据库地址没有输入，请重新尝试！\033[0m"
			read -p "请输入数据库地址: " Database_Address
		done
		
		echo
		read -p "请输入数据库端口号: " Database_Port
		while [[ ${Database_Port} == "" ]]
		do
			echo -e "\033[31m检测到数据库端口号没有输入，请重新尝试！\033[0m"
			read -p "请输入数据库端口号: " Database_Port
		done
		
		echo
		read -p "请输入数据库账户: " Database_Username
		while [[ ${Database_Username} == "" ]]
		do
			echo -e "\033[31m检测到数据库账户没有输入，请重新尝试！\033[0m"
			read -p "请输入数据库账户: " Database_Username
		done
		
		echo
		read -p "请输入数据库密码: " Database_Password
		while [[ ${Database_Password} == "" ]]
		do
			echo -e "\033[31m检测到数据库密码没有输入，请重新尝试！\033[0m"
			read -p "请输入数据库密码: " Database_Password
		done
		
		Database_connection_method="remote"
	fi
	
	
	echo
	read -p "请输入Apache端口号: " Apache_Port
	while [[ ${Apache_Port} == "" ]]
	do
		echo -e "\033[31m检测到Apache端口号没有输入，请重新尝试！\033[0m"
		read -p "请输入Apache端口号: " Apache_Port
	done
	
	
	echo
	read -p "请设置APP后台账户: " APP_Username
	while [[ ${APP_Username} == "" ]]
	do
		echo -e "\033[31m检测到APP后台账户没有输入，请重新尝试！\033[0m"
		read -p "请设置APP后台账户: " APP_Username
	done
	
	
	echo
	read -p "请设置APP后台密码: " APP_Password
	while [[ ${APP_Password} == "" ]]
	do
		echo -e "\033[31m检测到APP后台密码没有输入，请重新尝试！\033[0m"
		read -p "请设置APP后台密码: " APP_Password
	done
	
	echo
	read -p "请设置APP名称: " APP_Name
	while [[ ${APP_Name} == "" ]]
	do
		echo -e "\033[31m检测到APP名称没有输入，请重新尝试！\033[0m"
		read -p "请设置APP名称: " APP_Name
	done
	
	
	Download_address_selection
	
	sleep 2
	clear
	echo
	echo "正在安装博雅DALO(FAS)流量卫士..."
	
	rm -rf /var/www/html/user
	cd /var/www/html/
	wget -q ${Download_Host}/new_llws.zip -P /var/www/html
	unzip -o /var/www/html/new_llws.zip >/dev/null 2>&1
	rm -rf /var/www/html/new_llws.zip
	sed -i 's/server_address_port/'${Apache_Port}'/g' /var/www/html/vpndata.sql
	sed -i 's/server_address/'${Server_IP}'/g' /var/www/html/vpndata.sql
	sed -i 's/app_user/'${APP_Username}'/g' /var/www/html/vpndata.sql
	sed -i 's/app_pass/'${APP_Password}'/g' /var/www/html/vpndata.sql
	sed -i 's/MySQL_Host/'${Database_Address}'/g' /var/www/html/config.php
	sed -i 's/MySQL_Port/'${Database_Port}'/g' /var/www/html/config.php
	sed -i 's/MySQL_User/'${Database_Username}'/g' /var/www/html/config.php
	sed -i 's/MySQL_Pass/'${Database_Password}'/g' /var/www/html/config.php
	mysql -h${Database_Address} -P${Database_Port} -u${Database_Username} -p${Database_Password} radius < /var/www/html/vpndata.sql
	chmod -R 0777 /var/www/html/*
	echo "${RANDOM}${RANDOM}" > /var/www/auth_key.access
	kouling=`cat /var/www/auth_key.access`;
	
	echo "正在制作APP..."
	
	rm -rf /Shirley/app
	mkdir /Shirley/app
	cd /Shirley/app
	yum install java -y >/dev/null 2>&1
	wget --no-check-certificate -O llws_app.zip ${Download_Host}/llws_app.zip >/dev/null 2>&1
	wget --no-check-certificate -O apktool.zip ${Download_Host}/apktool.zip >/dev/null 2>&1
	unzip -o llws_app.zip >/dev/null 2>&1
	unzip -o apktool.zip >/dev/null 2>&1
	java -jar apktool.jar d old_app.apk >/dev/null 2>&1
	java -jar apktool.jar d new_app.apk >/dev/null 2>&1
	sed -i 's/demo.dingd.cn:80/'${Server_IP}':'${Apache_Port}'/g' `grep demo.dingd.cn:80 -rl /Shirley/app/old_app/smali/net/openvpn/openvpn/` 
	sed -i 's/叮咚流量卫士/'${APP_Name}'/g' /Shirley/app/old_app/res/values/strings.xml
	sed -i 's/demo.dingd.cn:80/'${Server_IP}':'${Apache_Port}'/g' /Shirley/app/new_app/res/values/strings.xml
	sed -i 's/叮咚流量卫士/'${APP_Name}'/g' /Shirley/app/new_app/res/values/strings.xml
	java -jar apktool.jar b old_app >/dev/null 2>&1
	java -jar apktool.jar b new_app >/dev/null 2>&1
	java -jar signapk.jar testkey.x509.pem testkey.pk8 /Shirley/app/old_app/dist/old_app.apk /var/www/html/old_app_sign.apk >/dev/null 2>&1
	java -jar signapk.jar testkey.x509.pem testkey.pk8 /Shirley/app/new_app/dist/new_app.apk /var/www/html/new_app_sign.apk >/dev/null 2>&1
	
	clear
	echo 
	echo "已安装完成"
	echo
	echo "在此声明!后台源码非博雅原创!我们只是修改了一些地方!勿喷!"
	echo
	echo "流量卫士后台地址: http://"${Server_IP}":"${Apache_Port}"/admin_app"
	echo
	echo "流量卫士后台账号: "${APP_Username}"  后台密码: "${APP_Password}"  口令: "${kouling}""
	echo
	echo "苹果下载线路地址: http://"${Server_IP}":"${Apache_Port}"/user"
	echo 
	echo "安卓4+APP下载地址: http://"${Server_IP}":"${Apache_Port}"/old_app_sign.apk"
	echo
	echo "安卓7+APP下载地址: http://"${Server_IP}":"${Apache_Port}"/new_app_sign.apk"
	echo
	echo "如果需要更换流量卫士数据库请修改文件/var/www/html/config.php"
	echo
	#echo "APP请进博雅总群下载!自己手动对接下~后续再更新自动对接的~!"
	
	return 0;
}


Uninstall_boya_daloradius()
{
	clear 
	echo
	
	if [ ! -f /etc/raddb/radiusd.conf ] && [ ! -f /usr/local/etc/raddb/radiusd.conf ]; then
		echo "您还未安装博雅DALO，不能执行这个操作 -1!!!"
		exit 1;
	fi
	
	if [ ! -f /etc/openvpn/radiusplugin.so ] && [ ! -f /etc/openvpn/radiusplugin_server1194.cnf ]; then
		echo "您还未安装博雅DALO，不能执行这个操作 -2!!!"
		exit 1;
	fi
	
	read -p "确认卸载博雅DALO程序吗[Y/N]: " Uninstall_Confirmation
	
	if [[ ${Uninstall_Confirmation} == "y" ]] || [[ ${Uninstall_Confirmation} == "Y" ]]; then
		vpn stop
		rpm -e remi-release-7.9-6.el7.remi.noarch
		yum remove php* -y
		yum remove httpd httpd-tools mariadb mariadb-server mariadb-devel -y
		yum remove freeradius freeradius-devel freeradius-utils freeradius-mysql freeradius-doc -y
		yum remove dnsmasq openvpn openvpn-devel -y 
		yum remove epel-release -y
		systemctl disable proxy.service
		systemctl disable auto_run.service
		rm -rf /lib/systemd/system/auto_run.service
		rm -rf /lib/systemd/system/proxy.service
		systemctl daemon-reload
		rm -rf /Shirley
		rm -rf /etc/httpd
		rm -rf /etc/raddb
		rm -rf /etc/sysctl.conf
		rm -rf /bin/vpn
		rm -rf /var/www/*
		rm -rf /etc/openvpn
		rm -rf /etc/dnsmasq.conf
		rm -rf /etc/my.cnf
		rm -rf /var/lib/mysql
		rm -rf /var/lib64/mysql
		iptables -F
		iptables -P INPUT ACCEPT
		iptables -P FORWARD ACCEPT
		iptables -P OUTPUT ACCEPT
		iptables -t nat -P PREROUTING ACCEPT
		iptables -t nat -P POSTROUTING ACCEPT
		iptables -t nat -P OUTPUT ACCEPT
		iptables -t nat -F
		iptables -X
		iptables -t nat -X
		service iptables save >/dev/null 2>&1
		systemctl restart iptables.service
		echo "卸载完成，回车重启服务器保证MYSQL完整卸载!!!"
		read
		reboot
		exit 0;
	else
		echo "用户取消卸载!!!"
		exit 0;
	fi
	
	
}



Installation_Selection()
{
	clear
	echo
	#选项栏
	echo -e "\033[1;34m使用说明\033[0m"
	echo -e ""
	echo -e "\033[1;34m当前博雅DALO流控为Shirley后期修复编写，并且它只支持CentOS7 X64 !!! \033[0m"
	echo -e ""
	echo -e "\033[1;34m具体的更新日志请访问 https://github.com/Shirley-Jones/daloradius-boya/blob/main/Update_log.md \033[0m"
	echo -e ""
	echo -e "\033[1;34m当前版本: $Boya_Version\033[0m"
	echo -e ""
	echo "请根据下方提示输入相对应序号："
	echo "1.安装博雅DALO稳定版"
	echo "2.安装博雅DALO稳定版(节点服务器)"
	echo "3.安装博雅DALO流量卫士"
	echo "4.系统负载/修改数据库信息"
	echo "5.重新制作APP"
	echo "6.卸载博雅DALO"
	echo "7.退出脚本"
	echo
	read -p "请选择[1-6]: " Install_options

	case "${Install_options}" in
		"1")
			if [[ ${ALL_RAM_free} -lt "800" ]]; then
				echo "警告, 系统RAM少于800MB(当前 "${ALL_RAM_free}"MB),不能选择【博雅DALO稳定版】!!!"
				exit 1;
			fi
			Installation_mode="ALL";
			New_installation_guide
			Install_boya_daloradius
			return 0
			;;

		"2")
			Installation_mode="Node";
			Install_node_guide
			Install_boya_daloradius
			return 0
			;;

		"3")
			Install_boya_daloradius_dingd
			return 0
			;;

		"4")
			if [ ! -f /Shirley/bin/vpn ]; then
				echo "您还未安装博雅DALO，不能执行这个操作 -1!!!"
				exit 1;
			else
				/Shirley/bin/vpn radius;
			fi
			return 0
			;;
		
		"5")
			if [ ! -f /Shirley/bin/vpn ]; then
				echo "您还未安装博雅DALO，不能执行这个操作 -1!!!"
				exit 1;
			else
				/Shirley/bin/vpn app;
			fi
			return 0
			;;
		
		"6")
			Uninstall_boya_daloradius
			return 0
			;;
			
			
		"7")
			echo "感谢您的使用，再见！"
			exit 0
			;;
		*)
			echo "输入错误！请重新运行脚本！"
			exit 1
			;;
	esac
	
	exit 0;
}


Main()
{
	rm -rf /root/test.log
	rm -rf $0
	echo "Loading...";
	Boya_Version="20240520"
	System_Check
	Installation_requires_software
	Detect_server_IP_address
	Installation_Selection
	return 0;
}


Main
exit 0;