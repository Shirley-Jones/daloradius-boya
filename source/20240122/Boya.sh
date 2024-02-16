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

New_installation_guide()
{
	#主机+节点服务器
	clear
	sleep 1
	echo
	
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
	
	if [ -f /usr/local/etc/raddb/radiusd.conf ]; then
		echo "检测到您已安装博雅DALO，不能重复安装 -1!!!"
		exit 1;
	fi
	
	if [ -f /boya/bin/vpn ]; then
		echo "检测到您已安装博雅DALO，不能重复安装 -1!!!"
		exit 1;
	fi
	
	if [ -f /usr/bin/mysql ] && [ -f /usr/sbin/mysql ] && [ -f /bin/mysql ] && [ -f /sbin/mysql ]; then
		echo "检测到您已安装博雅DALO/MySQL，不能重复安装 -1!!!"
		exit 1;
	fi
	
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
		
		echo "正在安装LAMP(国内服务器安装较慢请耐心等待 海外无视)..."
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
		wget -q ${Download_Host}/freeradius-server-2.2.10.tar.gz -P /root
		cd /root && tar -zxvf /root/freeradius-server-2.2.10.tar.gz >/dev/null 2>&1
		chmod -R 0777 /root/freeradius-server-2.2.10 >/dev/null 2>&1
		cd /root/freeradius-server-2.2.10 && ./configure >/dev/null 2>&1
		cd /root/freeradius-server-2.2.10 && make >/dev/null 2>&1 && make install >/dev/null 2>&1
		#安装FreeRadius-mysql
		cd /root/freeradius-server-2.2.10/src/modules/rlm_sql/drivers/rlm_sql_mysql && ./configure --with-mysql-dir=/var/lib/mysql --with-mysql-lib-dir=/var/lib/mysql/lib --with-mysql-include-dir=/var/lib/mysql/include >/dev/null 2>&1 && make >/dev/null 2>&1 && make install >/dev/null 2>&1
		if [ ! -f /usr/local/etc/raddb/sql.conf ] && [ ! -f /usr/local/etc/raddb/radiusd.conf ] && [ ! -f /usr/local/etc/raddb/clients.conf ]; then
			echo "FreeRadius-server软件包安装失败，请反馈给Shirley！程序强制退出!!!"
			exit 1;
		fi
		rm -rf /usr/local/etc/raddb/*
		wget -q ${Download_Host}/raddb.zip -P /root
		cd /usr/local/etc/raddb && unzip -o /root/raddb.zip >/dev/null 2>&1
		groupadd radiusd >/dev/null 2>&1
		useradd -g radiusd radiusd -s /sbin/nologin >/dev/null 2>&1
		#文件夹需要0777权限 否则 RADIUS 不能正常启动
		chmod -R 0777 /usr/local/var >/dev/null 2>&1
		
		sed -i "s/'Dalo_User','Dalo_Pass'/'$DaloRadius_Username','$DaloRadius_Password'/g" /usr/local/etc/raddb/radius.sql
		mysql -uroot -p${Database_Password} radius < /usr/local/etc/raddb/radius.sql
		sed -i 's/MySQL_Host/localhost/g' /usr/local/etc/raddb/sql.conf
		sed -i 's/MySQL_Port/3306/g' /usr/local/etc/raddb/sql.conf
		sed -i 's/MySQL_User/root/g' /usr/local/etc/raddb/sql.conf
		sed -i 's/MySQL_Pass/'${Database_Password}'/g' /usr/local/etc/raddb/sql.conf
	
		#启动RADIUS
		/usr/local/sbin/rc.radiusd start >/dev/null 2>&1
		
		
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
		mv /var/www/html/daloradius /var/www/html/${DaloRadius_file}
		#修改daloradius数据库信息
		sed -i 's/MySQL_Host/localhost/g' /var/www/html/${DaloRadius_file}/library/daloradius.conf.php
		sed -i 's/MySQL_Port/3306/g' /var/www/html/${DaloRadius_file}/library/daloradius.conf.php
		sed -i 's/MySQL_User/root/g' /var/www/html/${DaloRadius_file}/library/daloradius.conf.php
		sed -i 's/MySQL_Pass/'${Database_Password}'/g' /var/www/html/${DaloRadius_file}/library/daloradius.conf.php
		
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
	systemctl start iptables.service
	iptables -F
	iptables -A INPUT -s 127.0.0.1/32  -j ACCEPT
	iptables -A INPUT -d 127.0.0.1/32  -j ACCEPT
	#SSH端口
	iptables -A INPUT -p tcp -m tcp --dport ${SSH_Port} -j ACCEPT
	#Apache端口
	iptables -A INPUT -p tcp -m tcp --dport ${Apache_Port} -j ACCEPT
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
	rm -rf /boya
	mkdir /boya
	wget -q ${Download_Host}/boya_core.zip -P /boya
	cd /boya && unzip -o /boya/boya_core.zip >/dev/null 2>&1
	chmod -R 0777 /boya/*
	
	
	#配置sysctl
	rm -rf /etc/sysctl.conf
	mv /boya/Config/sysctl.conf /etc/sysctl.conf
	sysctl -p >/dev/null 2>&1
	
	
	#安装openvpn
	yum install openvpn openvpn-devel -y >/dev/null 2>&1
	rm -rf /etc/openvpn
	mv /boya/openvpn /etc/openvpn
	
	#节点版本修改对接
	if [[ ${Installation_mode} ==  "Node" ]]; then 
		sed -i 's/name=localhost/name='${radius_address}'/g' /etc/openvpn/radiusplugin_server1194.cnf
		sed -i 's/name=localhost/name='${radius_address}'/g' /etc/openvpn/radiusplugin_server1195.cnf
		sed -i 's/name=localhost/name='${radius_address}'/g' /etc/openvpn/radiusplugin_server1196.cnf
		sed -i 's/name=localhost/name='${radius_address}'/g' /etc/openvpn/radiusplugin_server1197.cnf
		sed -i 's/name=localhost/name='${radius_address}'/g' /etc/openvpn/radiusplugin_server-udp.cnf
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
	mv /boya/Config/dnsmasq.conf /etc/dnsmasq.conf
	sed -i 's/DNS_ADDRESS/'${DNS_TYPE}'/g' /etc/dnsmasq.conf
	systemctl restart dnsmasq.service
	systemctl enable dnsmasq.service >/dev/null 2>&1
	
	
	
	#创建软连接（快捷方式）
	ln -s /boya/bin/* /usr/bin
	
	#配置服务并设置FAS proxy开机自启
	mv /boya/proxy.service /lib/systemd/system/proxy.service
	#添加开机自动执行shell服务 
	mv /boya/auto_run.service /lib/systemd/system/auto_run.service
	#配置RADIUS服务并设置RADIUS开机自启
	mv /boya/radius.service /lib/systemd/system/radius.service
	#重新加载所有服务
	systemctl daemon-reload >/dev/null 2>&1
	#启动服务
	systemctl start auto_run.service >/dev/null 2>&1
	systemctl restart proxy.service >/dev/null 2>&1
	systemctl restart radius.service >/dev/null 2>&1
	#设置开机自启
	systemctl enable auto_run.service >/dev/null 2>&1
	systemctl enable proxy.service >/dev/null 2>&1
	systemctl enable radius.service >/dev/null 2>&1
	
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
	
	/boya/bin/vpn clean
	/boya/bin/vpn restart
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
		echo "自定义开机自启文件 /boya/Config/auto_run"
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
		echo "您的博雅Dalo节点系统安装完成，以下是您的安装信息"
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
		echo "自定义开机自启文件 /boya/Config/auto_run"
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


Uninstall_boya_daloradius()
{
	#卸载Zero
	
	echo "此功能暂未开放，请直接重装系统进行卸载...";
	exit 1;
	
	read -p "确认卸载博雅DALO吗? [Y/N]: " Uninstall_Zero_Option
	if [[ $Uninstall_Zero_Option == "Y" ]] || [[ $Uninstall_Zero_Option == "y" ]];then
		rm -rf /ZeroSwap
		rm -rf /etc/openvpn
		rm -rf /usr/local/etc/raddb
		rm -rf /var/www/html
		yum groupremove Development tools -y
		yum remove make openssl gcc gdb net-tools unzip psmisc wget curl zip vim telnet -y
		yum remove nss telnet avahi openssl openssl-libs openssl-devel lzo lzo-devel pam pam-devel automake pkgconfig gawk tar zip unzip net-tools psmisc gcc pkcs11-helper libxml2 libxml2-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel --skip-broken -y
		yum remove epel-release -y 
		echo "操作已完成...";
	else
		echo "操作已取消...";
	fi
	
	return 0;
}



Install_boya_daloradius_dingd()
{
	#安装流量卫士
	clear 
	echo
	
	if [ ! -f /usr/local/etc/raddb/radiusd.conf ]; then
		echo "您还未安装博雅DALO，不能执行这个操作 -1!!!"
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
	
	
	Download_address_selection
	
	sleep 2
	
	echo "正在安装博雅DALO(FAS)流量卫士请稍等..."
	
	rm -rf /var/www/html/user
	cd /var/www/html/
	wget -q ${Download_Host}/new_llws.zip -P /var/www/html
	unzip -o /var/www/html/new_llws.zip >/dev/null 2>&1
	rm -rf /var/www/html/new_llws.zip
	sed -i 's/server_address/'${Server_IP}'/g' /var/www/html/vpndata.sql
	sed -i 's/server_address:server_address_port/'${radius_address}':'${Apache_Port}'/g' /var/www/html/vpndata.sql
	sed -i 's/app_user/'${APP_Username}'/g' /var/www/html/vpndata.sql
	sed -i 's/app_pass/'${APP_Password}'/g' /var/www/html/vpndata.sql
	sed -i 's/MySQL_Host/localhost/g' /var/www/html/config.php
	sed -i 's/MySQL_Port/3306/g' /var/www/html/config.php
	sed -i 's/MySQL_User/root/g' /var/www/html/config.php
	sed -i 's/MySQL_Pass/'${Database_Password}'/g' /var/www/html/config.php
	mysql -h${Database_Address} -P${Database_Port} -u${Database_Username} -p${Database_Password} radius < /var/www/html/vpndata.sql
	chmod -R 0777 /var/www/html/*
	echo "${RANDOM}${RANDOM}" > /var/www/auth_key.access
	kouling=`cat /var/www/auth_key.access`;
	
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
	echo "如果需要更换流量卫士数据库请修改文件/var/www/html/config.php"
	echo
	echo "APP请进博雅总群下载!自己手动对接下~后续再更新自动对接的~!"
	
	return 0;
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
	echo "2.安装博雅DALO稳定版节点端"
	echo "3.安装博雅DALO流量卫士"
	echo "4.卸载博雅DALO"
	echo "5.退出脚本"
	echo
	read -p "请选择[1-5]: " Install_options

	case "${Install_options}" in
		1)
			if [[ ${ALL_RAM_free} -lt "800" ]]; then
				echo "警告, 系统RAM少于800MB(当前 "${ALL_RAM_free}"MB),不能选择【博雅DALO稳定版】!!!"
				exit 1;
			fi
			Installation_mode="ALL";
			New_installation_guide
			Install_boya_daloradius
			return 0
			;;

		2)
			Installation_mode="Node";
			Install_node_guide
			Install_boya_daloradius
			return 0
			;;

		3)
			Install_boya_daloradius_dingd
			return 0
			;;

		4)
			Uninstall_boya_daloradius
			return 0
			;;

		5)
			echo "感谢您的使用，再见！"
			exit 0
			;;
		*)
			echo "输入错误！请重新运行脚本！"
			exit 1
			;;
	esac
	
	
	
}


Main()
{
	rm -rf /root/test.log
	rm -rf $0
	echo "Loading...";
	Boya_Version="20240122"
	System_Check
	Installation_requires_software
	Detect_server_IP_address
	Installation_Selection
	return 0;
}


Main
exit 0;