#!/bin/bash
#Project address: https://github.com/Shirley-Jones/daloradius-boya
#Thank you very much for using this project!
#博雅情韵QQ: 2223139086
#Shirley后期修复编写

Download_address_selection()
{
	
	clear 
	echo 
	echo "正在加载下载节点,请稍等..."
	
	
	#--------------下载地址配置--------------#
	
	
	# 如果你想启用mysql自定义下载地址,请在以下变量输入“true”来启用它,然后将mysql文件上传到您的自定义服务器 并在以下“Download_Host_Two”设置您的自定义服务器地址
	# 如果理解不了那你就不要修改
	MySQL_enables_custom_download_links="false"
	
	# 下载地址请在此设置，其他配置请不要乱动。
	Download_Host_One="https://raw.githubusercontent.com/Shirley-Jones/daloradius-boya/main/source/$Boya_Version"
	Download_Host_Two="https://api.qiaouu.top/shell/daloradius-boya/$Boya_Version"
	
	# 下载地址备注/名称
	Download_Host_One_Name="Github";
	Download_Host_Two_Name="私有源(请您先设置)";
	
	
	#--------------下载地址配置--------------#
	
	
	
	#--------------以下配置请勿修改--------------#
	hostname_One="${Download_Host_One#*//}"
	hostname_One="${hostname_One%%/*}"
	
	hostname_Two="${Download_Host_Two#*//}"
	hostname_Two="${hostname_Two%%/*}"
	
	# 使用ping命令检测One连通性
	PING_OUTPUT_One=$(ping -c 4 $hostname_One)
	# 使用ping命令检测Two连通性
	PING_OUTPUT_Two=$(ping -c 4 $hostname_Two)
	
	#获取One延迟
	AVG_DELAY_One=$(echo "$PING_OUTPUT_One" | grep "avg" | awk '{print $4}' | cut -d'/' -f2 | cut -d'=' -f2 | cut -d'.' -f1)
	#获取Two延迟
	AVG_DELAY_Two=$(echo "$PING_OUTPUT_Two" | grep "avg" | awk '{print $4}' | cut -d'/' -f2 | cut -d'=' -f2 | cut -d'.' -f1)
	
	
	# 输出One平均延迟时间，并根据延迟时间设置颜色
	if [ -n "$AVG_DELAY_One" ] && [ "$AVG_DELAY_One" -le 100 ]; then
		Delay_One="[\e[32m$AVG_DELAY_One ms\e[0m] 推荐"
	elif [ -n "$AVG_DELAY_One" ] && [ "$AVG_DELAY_One" -le 200 ]; then
		Delay_One="[\e[33m$AVG_DELAY_One ms\e[0m]"
	elif [ -n "$AVG_DELAY_One" ]; then
		Delay_One="[\e[31m$AVG_DELAY_One ms\e[0m]"
	else
		Delay_One="[\e[31mN/A\e[0m]"
	fi
	
	# 输出Two平均延迟时间，并根据延迟时间设置颜色
	if [ -n "$AVG_DELAY_Two" ] && [ "$AVG_DELAY_Two" -le 100 ]; then
		Delay_Two="[\e[32m$AVG_DELAY_Two ms\e[0m] 推荐"
	elif [ -n "$AVG_DELAY_Two" ] && [ "$AVG_DELAY_Two" -le 200 ]; then
		Delay_Two="[\e[33m$AVG_DELAY_Two ms\e[0m]"
	elif [ -n "$AVG_DELAY_Two" ]; then
		Delay_Two="[\e[31m$AVG_DELAY_Two ms\e[0m]"
	else
		Delay_Two="[\e[31mN/A\e[0m]"
	fi
	
	
	echo
	echo "请选择下载节点"
	echo -e "1、${Download_Host_One_Name} ${Delay_One}"
	echo -e "2、${Download_Host_Two_Name} ${Delay_Two}"
	read -p "请选择[1-2]: " Download_address_Option
	while [[ ${Download_address_Option} == "" ]]
	do
		echo -e "\033[31m检测到下载节点没有选择，请重新尝试！\033[0m"
		echo "请选择下载节点"
		echo -e "1、${Download_Host_One_Name} ${Delay_One}"
		echo -e "2、${Download_Host_Two_Name} ${Delay_Two}"
		read -p "请选择[1-2]: " Download_address_Option
	done
	
	if [[ ${Download_address_Option} == "1" ]];then
		echo "已选择【${Download_Host_One_Name}】"
		Download_Host=${Download_Host_One}
	fi
	
	if [[ ${Download_address_Option} == "2" ]];then
		echo "已选择【${Download_Host_Two_Name}】"
		Download_Host=${Download_Host_Two}
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
	
	source /etc/os-release
	Linux_Version=${VERSION_ID}
	
	if [[ ${Linux_OS} ==  "CentOS" ]]; then
		# 支持的
		if [[ !${Linux_Version} ==  "7" ]]; then 
			echo "当前Linux系统不支持安装博雅DALO,请更换系统后重新尝试!!! error -1"
			exit 1;
		fi
	elif [[ ${Linux_OS} ==  "Ubuntu" ]]; then
		# 支持的
		result=$(echo "$Linux_Version < 20.04" | bc -l)
		if [ $result -eq 1 ]; then
			echo "当前Linux系统不支持安装博雅DALO,请更换系统后重新尝试!!! error -2"
			exit 1;
		fi
	elif [[ ${Linux_OS} ==  "Debian" ]]; then
		# 支持的
		result=$(echo "$Linux_Version < 11" | bc -l)
		if [ $result -eq 1 ]; then
			echo "当前Linux系统不支持安装博雅DALO,请更换系统后重新尝试!!! error -3"
			exit 1;
		fi
	else
		echo "当前的Linux系统不支持安装博雅DALO,请更换系统后重新尝试!!! error -4"
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
	
	
	
	if [[ ${Linux_OS} ==  "CentOS" ]]; then
		# 支持的
		# 使用if语句和-f运算符来判断
		# 检查wget是否存在于系统的几个常见路径中
		if [ ! -f /usr/bin/wget ] && [ ! -f /bin/wget ] && [ ! -f /usr/sbin/wget ] && [ ! -f /sbin/wget ]; then
			# 尝试安装wget
			yum install wget -y >/dev/null 2>&1

			# 再次检查wget是否安装成功
			if [ ! -f /usr/bin/wget ] && [ ! -f /bin/wget ] && [ ! -f /usr/sbin/wget ] && [ ! -f /sbin/wget ]; then
				echo "wget 安装失败，强制退出程序!!!"
				exit 1
			fi
		fi
		
		# 检查curl是否存在于系统的几个常见路径中
		if [ ! -f /usr/bin/curl ] && [ ! -f /bin/curl ] && [ ! -f /usr/sbin/curl ] && [ ! -f /sbin/curl ]; then
			# 尝试安装curl
			yum install curl -y >/dev/null 2>&1

			# 再次检查curl是否安装成功
			if [ ! -f /usr/bin/curl ] && [ ! -f /bin/curl ] && [ ! -f /usr/sbin/curl ] && [ ! -f /sbin/curl ]; then
				echo "curl 安装失败，强制退出程序!!!"
				exit 1
			fi
		fi
		
		# 检查net-tools是否存在于系统的几个常见路径中
		if [ ! -f /usr/bin/ifconfig ] && [ ! -f /bin/ifconfig ] && [ ! -f /usr/sbin/ifconfig ] && [ ! -f /sbin/ifconfig ]; then
			# 尝试安装net-tools
			yum install net-tools -y >/dev/null 2>&1

			# 再次检查net-tools是否安装成功
			if [ ! -f /usr/bin/ifconfig ] && [ ! -f /bin/ifconfig ] && [ ! -f /usr/sbin/ifconfig ] && [ ! -f /sbin/ifconfig ]; then
				echo "net-tools 安装失败，强制退出程序!!!"
				exit 1
			fi
		fi
	elif [[ ${Linux_OS} ==  "Ubuntu" ]] || [[ ${Linux_OS} ==  "Debian" ]]; then
		# 支持的
		# 使用if语句和-f运算符来判断
		# 检查wget是否存在于系统的几个常见路径中
		if [ ! -f /usr/bin/wget ] && [ ! -f /bin/wget ] && [ ! -f /usr/sbin/wget ] && [ ! -f /sbin/wget ]; then
			# 尝试安装wget
			apt-get update >/dev/null 2>&1
			apt-get install wget -y >/dev/null 2>&1

			# 再次检查wget是否安装成功
			if [ ! -f /usr/bin/wget ] && [ ! -f /bin/wget ] && [ ! -f /usr/sbin/wget ] && [ ! -f /sbin/wget ]; then
				echo "wget 安装失败，强制退出程序!!!"
				exit 1
			fi
		fi
		
		# 检查curl是否存在于系统的几个常见路径中
		if [ ! -f /usr/bin/curl ] && [ ! -f /bin/curl ] && [ ! -f /usr/sbin/curl ] && [ ! -f /sbin/curl ]; then
			# 尝试安装curl
			apt-get update >/dev/null 2>&1
			apt-get install curl -y >/dev/null 2>&1

			# 再次检查curl是否安装成功
			if [ ! -f /usr/bin/curl ] && [ ! -f /bin/curl ] && [ ! -f /usr/sbin/curl ] && [ ! -f /sbin/curl ]; then
				echo "curl 安装失败，强制退出程序!!!"
				exit 1
			fi
		fi
		
		# 检查net-tools是否存在于系统的几个常见路径中
		if [ ! -f /usr/bin/ifconfig ] && [ ! -f /bin/ifconfig ] && [ ! -f /usr/sbin/ifconfig ] && [ ! -f /sbin/ifconfig ]; then
			# 尝试安装net-tools
			apt-get update >/dev/null 2>&1
			apt-get install net-tools -y >/dev/null 2>&1

			# 再次检查net-tools是否安装成功
			if [ ! -f /usr/bin/ifconfig ] && [ ! -f /bin/ifconfig ] && [ ! -f /usr/sbin/ifconfig ] && [ ! -f /sbin/ifconfig ]; then
				echo "net-tools 安装失败，强制退出程序!!!"
				exit 1
			fi
		fi
	else
		echo "当前的Linux系统不支持安装博雅DALO!!!"
		exit 1;
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
	
	ALL_RAM_free=$(echo `free | grep Mem | awk '{print $2 / 1024}'`|sed "s/\..*//g")

	return 0;
}


DALORADIUS_INSTALL_Check()
{

	if [ -f /usr/local/etc/raddb/radiusd.conf ] && [ -f /etc/raddb/radiusd.conf ] && [ -f /boya/bin/vpn ] && [ -f /Shirley/bin/vpn ] && [ -f /etc/freeradius/radiusd.conf ]; then
		echo "检测到您已安装博雅DALO，不能重复安装 -1!!!"
		exit 1;
	fi
	
	if [ -f /usr/bin/mysql ] && [ -f /usr/sbin/mysql ] && [ -f /bin/mysql ] && [ -f /sbin/mysql ]; then
		echo "检测到您已安装博雅DALO/MySQL，不能重复安装 -2!!!"
		exit 1;
	fi
	
	return 0;
}

Install_boya_daloradius_guide()
{
	clear
	sleep 1
	echo
	
	DALORADIUS_INSTALL_Check
	
	if [[ ${Installation_mode} ==  "ALL" ]]; then 
		#相同
		if [[ ${ALL_RAM_free} -lt "800" ]]; then
			echo "警告,系统RAM小于800MB(当前 "${ALL_RAM_free}"MB),不推荐您安装【博雅DALO稳定版】!!!"
			echo "因为安装后服务器会很卡顿,会影响正常使用,但是您可以选择强制安装，这将由您决定~"
			read -p "是否强制安装?[Y/N]: " Force_installation_Option
			if [[ $Force_installation_Option == "Y" ]] || [[ $Force_installation_Option == "y" ]];then
				echo "操作继续..."
			else
				echo "脚本已终止..."
				exit 0;
			fi
		fi
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
		
	elif [[ ${Installation_mode} ==  "Node" ]]; then 
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
	else
		echo "程序逻辑错误，脚本已被终止..."
		exit 1;
	fi
	
	echo
	read -p "请输入SSH端口号: " SSH_Port
	while [[ ${SSH_Port} == "" ]]
	do
		echo -e "\033[31m检测到SSH端口号没有输入，请重新尝试！\033[0m"
		read -p "请输入SSH端口号: " SSH_Port
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



Install_boya_daloradius()
{
	#Installation_mode
	
	#----------开始安装----------
	
	clear
	sleep 1
	
	echo
	echo -e "\033[1;34m-------------安装过程中如果没有报错就请耐心等待-------------\033[0m"
	sleep 3
	echo
	echo
	echo
	echo "正在初始化环境..."
	# 清理内存
	sync
	echo 1 > /proc/sys/vm/drop_caches
	echo 2 > /proc/sys/vm/drop_caches
	echo 3 > /proc/sys/vm/drop_caches
	# 扫描总内存
	if [[ ${ALL_RAM_free} -lt "800" ]]; then
		# 内存少于800MB  创建虚拟内存Swap 1GB
		# 扫描SWAP内存
		ALL_Swap_free=$(echo `free | grep Swap | awk '{print $2 / 1024}'`|sed "s/\..*//g")
		if [[ ${ALL_Swap_free} -lt "1024" ]]; then
			fallocate -l 1G /ZeroSwap
			ls -lh /ZeroSwap >/dev/null 2>&1
			chmod 600 /ZeroSwap
			mkswap /ZeroSwap >/dev/null 2>&1
			swapon /ZeroSwap >/dev/null 2>&1
			echo "/ZeroSwap none swap sw 0 0" >> /etc/fstab
		fi
	fi
	
	if [[ ${Linux_OS} ==  "CentOS" ]]; then
		# 相同
		#设置SELinux宽容模式
		setenforce 0 >/dev/null 2>&1
		sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config >/dev/null 2>&1
	elif [[ ${Linux_OS} ==  "Ubuntu" ]] || [[ ${Linux_OS} ==  "Debian" ]]; then
		# 相同
		# 强制APT网络走IPV4模式 
		#echo 'Acquire::ForceIPv4 "true";' >> /etc/apt/apt.conf
		# 设置SELinux宽容模式
		apt update >/dev/null 2>&1
		apt install selinux-utils -y >/dev/null 2>&1
		setenforce 0 >/dev/null 2>&1
	else
		echo "程序逻辑错误，脚本已被终止..."
		exit 1;
	fi
	
	
	echo "正在安装运行库文件..."
	
	if [[ ${Linux_OS} ==  "CentOS" ]]; then
		# 相同
		yum groupinstall Development tools -y >/dev/null 2>&1
		yum install make openssl gcc gdb net-tools unzip psmisc wget curl zip vim telnet -y >/dev/null 2>&1
		yum install nss telnet avahi openssl openssl-libs openssl-devel lzo lzo-devel pam pam-devel automake pkgconfig gawk tar zip unzip net-tools psmisc gcc pkcs11-helper libxml2 libxml2-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel --skip-broken -y >/dev/null 2>&1
		yum install epel-release -y >/dev/null 2>&1
	elif [[ ${Linux_OS} ==  "Ubuntu" ]]; then
		apt install zlib* build-essential make gcc gdb g++ net-tools unzip psmisc wget curl zip vim telnet libgcrypt20-dev libpng-dev libjpeg-dev libmcrypt4 libmcrypt-dev libmysqlclient-dev cmake libncurses5-dev bison telnet openssl libssl-dev automake gawk tar zip unzip net-tools psmisc gcc libxml2 libxml2-dev bzip2 libcurl4-openssl-dev autoconf g++ pkg-config libsasl2-dev libcurl4-openssl-dev -y >/dev/null 2>&1
	elif [[ ${Linux_OS} ==  "Debian" ]]; then
		# 相同
		apt install zlib* build-essential make gcc gdb g++ net-tools unzip psmisc wget curl zip vim telnet libgcrypt20-dev libpng-dev libjpeg-dev libmcrypt4 libmcrypt-dev libmariadb-dev-compat libmariadb-dev cmake libncurses5 libncurses5-dev bison telnet openssl libssl-dev automake gawk tar zip unzip net-tools psmisc gcc libxml2 libxml2-dev bzip2 libcurl4-openssl-dev autoconf g++ pkg-config libsasl2-dev libcurl4-openssl-dev -y >/dev/null 2>&1
	else
		echo "程序逻辑错误，脚本已被终止..."
		exit 1;
	fi
	
	
	if [[ ${Installation_mode} ==  "ALL" ]]; then 
		if [[ ${Linux_OS} ==  "CentOS" ]]; then
			# 相同
			echo "正在添加Remi-release PHP..."
			#add php 国内服务器安装较慢请耐心等待
			yum install yum-utils -y >/dev/null 2>&1
			rpm -ivh https://rpms.remirepo.net/enterprise/remi-release-7.rpm >/dev/null 2>&1
			remi_retry_count="1"
			while [ ! -f /etc/yum.repos.d/remi.repo ] && [ ! -f /etc/yum.repos.d/remi-modular.repo ] && [ ! -f remi-safe.repo ]; do
				# 检查重试次数是否大于或等于15
				if [[ ${remi_retry_count} -ge "15" ]]; then
					echo "[Remi-release] PHP 添加失败,请检查服务器网络环境或Remi网站正在维护~"
					echo "安装失败，强制退出程序!!!"
					exit 1
				else
					# 增加重试计数
					remi_retry_count=$((${remi_retry_count}+1))
					# 添加 remi-release-7
					rpm -ivh https://rpms.remirepo.net/enterprise/remi-release-7.rpm >/dev/null 2>&1
				fi
				sleep 3
			done
			
			#yum-config-manager --enable remi-php56 -y >/dev/null 2>&1
			#创建新缓存 国内服务器安装较慢请耐心等待
			yum clean all >/dev/null 2>&1
			yum makecache >/dev/null 2>&1
			
			
			echo "正在安装Apache..."
			yum install httpd httpd-tools -y >/dev/null 2>&1
			apache2_retry_count="1"
			while [ ! -f /usr/bin/httpd ] && [ ! -f /usr/sbin/httpd ] && [ ! -f /bin/httpd ] && [ ! -f /sbin/httpd ]; do
				# 检查重试次数是否大于或等于15
				if [[ ${apache2_retry_count} -ge "15" ]]; then
					echo "Apache(httpd)软件包安装失败,请检查服务器网络环境或YUM安装源配置错误~"
					echo "安装失败，强制退出程序!!!"
					exit 1
				else
					# 增加重试计数
					apache2_retry_count=$((${apache2_retry_count}+1))
					# 安装 apache2
					yum install httpd httpd-tools -y >/dev/null 2>&1
				fi
				sleep 3
			done
			
			echo "正在安装PHP5.6..."
			yum remove php* -y >/dev/null 2>&1
			yum install --enablerepo=remi --enablerepo=remi-php56 php php-mbstring php-gd php-mysql php-pear php-pear-DB php-cli php-common php-ldap php-odbc php-xmlrpc -y >/dev/null 2>&1
			php5_retry_count="1"
			while [ ! -f /usr/bin/php ] && [ ! -f /usr/sbin/php ] && [ ! -f /bin/php ] && [ ! -f /sbin/php ]; do
				# 检查重试次数是否大于或等于15
				if [[ ${php5_retry_count} -ge "15" ]]; then
					echo "PHP5.6安装失败,请检查服务器网络环境或Remi网站正在维护~"
					echo "安装失败，强制退出程序!!!"
					exit 1
				else
					# 增加重试计数
					php5_retry_count=$((${php5_retry_count}+1))
					# 安装 PHP5.6
					yum install --enablerepo=remi --enablerepo=remi-php56 php php-mbstring php-gd php-mysql php-pear php-pear-DB php-cli php-common php-ldap php-odbc php-xmlrpc -y >/dev/null 2>&1
				fi
				sleep 3
			done
			
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
			
			echo "正在安装MariaDB..."
			yum install mariadb mariadb-server mariadb-devel -y >/dev/null 2>&1
			MariaDB_retry_count="1"
			while [ ! -f /usr/bin/mysql ] && [ ! -f /usr/sbin/mysql ] && [ ! -f /bin/mysql ] && [ ! -f /sbin/mysql ]; do
				# 检查重试次数是否大于或等于15
				if [[ ${MariaDB_retry_count} -ge "15" ]]; then
					echo "MariaDB安装失败,请检查服务器网络环境或YUM安装源配置错误~"
					echo "安装失败，强制退出程序!!!"
					exit 1
				else
					# 增加重试计数
					MariaDB_retry_count=$((${MariaDB_retry_count}+1))
					# 安装 MariaDB
					yum install mariadb mariadb-server mariadb-devel -y >/dev/null 2>&1
				fi
				sleep 3
			done
			
			systemctl start mariadb.service >/dev/null 2>&1
			mysqladmin -uroot password ${Database_Password}
			mysql -uroot -p${Database_Password} -e 'create database radius;'
			mysql -uroot -p${Database_Password} -e "use mysql;GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '"${Database_Password}"' WITH GRANT OPTION;flush privileges;"
			systemctl restart mariadb.service
			systemctl enable mariadb.service >/dev/null 2>&1
			
			
			#安装FreeRadius-server
			echo "正在安装FreeRadius..."
			yum install freeradius freeradius-devel freeradius-utils freeradius-mysql freeradius-doc -y >/dev/null 2>&1
			radius_retry_count="1"
			while [ ! -f /usr/bin/radiusd ] && [ ! -f /usr/sbin/radiusd ] && [ ! -f /bin/radiusd ] && [ ! -f /sbin/radiusd ]; do
				# 检查重试次数是否大于或等于15
				if [[ ${radius_retry_count} -ge "15" ]]; then
					echo "FreeRadius安装失败,请检查服务器网络环境或YUM安装源配置错误~"
					echo "安装失败，强制退出程序!!!"
					exit 1
				else
					# 增加重试计数
					radius_retry_count=$((${radius_retry_count}+1))
					# 安装 freeradius
					yum install freeradius freeradius-devel freeradius-utils freeradius-mysql freeradius-doc -y >/dev/null 2>&1
				fi
				sleep 3
			done
			
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
			wget -q ${Download_Host}/freeradius3-centos7.zip -P /etc/raddb
			unzip -o /etc/raddb/freeradius3-centos7.zip >/dev/null 2>&1
			rm -rf /etc/raddb/freeradius3-centos7.zip
			ln -s /etc/raddb/mods-config/files/authorize /etc/raddb/users
			ln -s /etc/raddb/mods-available/sql /etc/raddb/mods-enabled/sql
			ln -s /etc/raddb/mods-available/sqlcounter /etc/raddb/mods-enabled/sqlcounter
			ln -s /etc/raddb/sites-available/default /etc/raddb/sites-enabled/default
			mysql -uroot -p${Database_Password} radius < /etc/raddb/mods-config/sql/main/mysql/extras/wimax/schema.sql
			mysql -uroot -p${Database_Password} radius < /etc/raddb/mods-config/sql/cui/mysql/schema.sql
			mysql -uroot -p${Database_Password} radius < /etc/raddb/mods-config/sql/main/mysql/schema.sql
			sed -i 's/content1/localhost/g' /etc/raddb/mods-available/sql
			sed -i 's/content2/3306/g' /etc/raddb/mods-available/sql
			sed -i 's/content3/root/g' /etc/raddb/mods-available/sql
			sed -i 's/content4/'${Database_Password}'/g' /etc/raddb/mods-available/sql
			#chown -R freerad:freerad /etc/freeradius/3.0
			#启动RADIUS
			#修改启动模块 必须启动先mariadb，然后才能启动RADIUS，否则开机不能正常启动
			sed -i '3s/$/ mariadb.service /' /usr/lib/systemd/system/radiusd.service
			systemctl start radiusd.service
			systemctl enable radiusd.service >/dev/null 2>&1
		elif [[ ${Linux_OS} ==  "Ubuntu" ]] || [[ ${Linux_OS} ==  "Debian" ]]; then
			# 相同
			if [[ ${Linux_OS} ==  "Debian" ]]; then
				echo "正在添加Sury PHP..."
				apt install software-properties-common ca-certificates lsb-release apt-transport-https -y >/dev/null 2>&1
				echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
				wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add - >/dev/null 2>&1
				apt-key adv --fetch-keys 'https://packages.sury.org/php/apt.gpg' >/dev/null 2>&1
			else
				echo "正在添加ondrej/php PPA..."
				# 安装software-properties-common软件管理器（这一步不是必须，有些发行版本已经安装好了）
				apt install software-properties-common -y >/dev/null 2>&1
				# 增加 ondrej/php PPA，提供了多个 PHP 版本
				add-apt-repository ppa:ondrej/php -y >/dev/null 2>&1
				ondrej_retry_count="1"
				while [ ! -f /etc/apt/sources.list.d/ondrej-ubuntu-php-${VERSION_CODENAME}.list ]; do
					# 检查重试次数是否大于或等于15
					if [[ ${ondrej_retry_count} -ge "15" ]]; then
						echo "[Ondrej/php] PPA 添加失败,请检查服务器网络环境或ondrej网站正在维护~"
						echo "安装失败，强制退出程序!!!"
						exit 1
					else
						# 增加重试计数
						ondrej_retry_count=$((${ondrej_retry_count}+1))
						# 添加 PPA
						add-apt-repository ppa:ondrej/php -y >/dev/null 2>&1
					fi
					sleep 3
				done
			fi
			
			# 再次更新
			apt update >/dev/null 2>&1
			
			
			
			
			echo "正在安装Apache..."
			apt install apache2 -y >/dev/null 2>&1
			apache2_retry_count="1"
			while [ ! -f /usr/bin/apache2 ] && [ ! -f /usr/sbin/apache2 ] && [ ! -f /bin/apache2 ] && [ ! -f /sbin/apache2 ]; do
				# 检查重试次数是否大于或等于15
				if [[ ${apache2_retry_count} -ge "15" ]]; then
					echo "Apache2安装失败,请检查服务器网络环境或apt安装源配置错误~"
					echo "安装失败，强制退出程序!!!"
					exit 1
				else
					# 增加重试计数
					apache2_retry_count=$((${apache2_retry_count}+1))
					# 安装 apache2
					apt install apache2 -y >/dev/null 2>&1
				fi
				sleep 3
			done
			
			echo "正在安装PHP5.6..."
			apt install php5.6 php5.6-cli php5.6-common php5.6-gd php5.6-ldap php5.6-mysql php5.6-odbc php5.6-xmlrpc php5.6-xml php5.6-mbstring php-pear -y >/dev/null 2>&1
			php5_retry_count="1"
			while [ ! -f /usr/bin/php ] && [ ! -f /usr/sbin/php ] && [ ! -f /bin/php ] && [ ! -f /sbin/php ]; do
				# 检查重试次数是否大于或等于15
				if [[ ${php5_retry_count} -ge "15" ]]; then
					echo "PHP5.6安装失败,请检查服务器网络环境或Ondrej/Sury网站正在维护~"
					echo "安装失败，强制退出程序!!!"
					exit 1
				else
					# 增加重试计数
					php5_retry_count=$((${php5_retry_count}+1))
					# 安装 PHP5.6
					apt install php5.6 php5.6-cli php5.6-common php5.6-gd php5.6-ldap php5.6-mysql php5.6-odbc php5.6-xmlrpc php5.6-xml php5.6-mbstring php-pear -y >/dev/null 2>&1
				fi
				sleep 3
			done
			
			
			#需要安装DB拓展 否则daloradius打不开
			pear install DB >/dev/null 2>&1
			#pear install MDB2 >/dev/null 2>&1
			sed -i "s/80/"${Apache_Port}"/g" /etc/apache2/sites-enabled/000-default.conf
			sed -i "s/Listen 80/Listen "${Apache_Port}"/g" /etc/apache2/ports.conf
			#禁用Apache目录浏览
			sed -i "s/Options Indexes FollowSymLinks/Options FollowSymLinks/g" /etc/apache2/apache2.conf
			systemctl restart apache2.service
			systemctl enable apache2.service >/dev/null 2>&1
			
			
			#安装Database
			if [[ ${MySQL_enables_custom_download_links} == "true" ]];then
				#启用自定义下载地址
				echo "正在从您的自定义地址下载MySQL..."
				rm -rf /usr/local/mysql-5.6.40-linux-glibc2.12-x86_64.tar.gz
				cd /usr/local
				wget -q ${Download_Host}/mysql-5.6.40-linux-glibc2.12-x86_64.tar.gz -P /usr/local >/dev/null 2>&1
			else
				#从官网下载
				echo "正在从官网下载MySQL(大约313MB)..."
				rm -rf /usr/local/mysql-5.6.40-linux-glibc2.12-x86_64.tar.gz
				cd /usr/local
				wget -q https://cdn.mysql.com/archives/mysql-5.6/mysql-5.6.40-linux-glibc2.12-x86_64.tar.gz -P /usr/local >/dev/null 2>&1
			fi
			
			if [ ! -f /usr/local/mysql-5.6.40-linux-glibc2.12-x86_64.tar.gz ]; then
				echo "MySQL软件包下载失败，强制退出程序!!!"
				exit 1;
			fi
			get_file_md5=$(md5sum -b /usr/local/mysql-5.6.40-linux-glibc2.12-x86_64.tar.gz | cut -d' ' -f1)
			uppercase_md5=$(echo $get_file_md5 | tr '[:lower:]' '[:upper:]')
			mysql56_file_md5="10F61E60F8C42B6635E5C1F423BCE8BE";
			if [[ ${uppercase_md5} == ${mysql56_file_md5} ]];then
				#MD5正确 
				tar -zxvf /usr/local/mysql-5.6.40-linux-glibc2.12-x86_64.tar.gz >/dev/null 2>&1
				rm -rf /usr/local/mysql-5.6.40-linux-glibc2.12-x86_64.tar.gz
			else
				#不相同
				echo "MySQL软件包MD5验证失败，文件可能下载不完整或被篡改，请检查您的网络环境!!!"
				exit 1;
			fi
			echo "正在安装MySQL..."
			groupadd mysql >/dev/null 2>&1
			useradd -M -g mysql -s /sbin/nologin mysql >/dev/null 2>&1
			mv /usr/local/mysql-5.6.40-linux-glibc2.12-x86_64 /usr/local/mysql
			echo 'export MYSQL_HOME=/usr/local/mysql
export PATH=$PATH:$MYSQL_HOME/bin
'>>/etc/profile
			source /etc/profile
			mkdir /run/mysqld/
			echo "d /var/run/mysqld 0755 mysql mysql -" > /usr/lib/tmpfiles.d/mysql.conf
			chown -R mysql:mysql /run/mysqld/
			chown -R mysql:mysql /usr/local/mysql/
			chown -R mysql:mysql /usr/lib/tmpfiles.d/mysql.conf
			#初始化数据库
			/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql/ --datadir=/usr/local/mysql/data/ >/dev/null 2>&1
			rm -rf /usr/local/mysql/my.cnf
			cat >> /usr/local/mysql/my.cnf <<EOF
[client]
port = 3306
socket = /var/run/mysqld/mysqld.sock

[mysqld]
port = 3306
socket = /var/run/mysqld/mysqld.sock
skip-external-locking
key_buffer_size = 256M
max_allowed_packet = 1024M
table_open_cache = 256
sort_buffer_size = 1M
read_buffer_size = 1M
read_rnd_buffer_size = 4M
myisam_sort_buffer_size = 64M
thread_cache_size = 8
query_cache_size= 16M
thread_concurrency = 8
log-bin=mysql-bin
binlog_format=mixed
server-id	= 1

[mysqldump]
quick
max_allowed_packet = 1024M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 128M
sort_buffer_size = 128M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout

EOF


			cat >> /lib/systemd/system/mysql.service <<EOF
[Unit]
Description=mysql
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/mysql/support-files/mysql.server start
ExecReload=/usr/local/mysql/support-files/mysql.server restart
ExecStop=/usr/local/mysql/support-files/mysql.server stop
PrivateTmp=true

[Install]
WantedBy=multi-user.target

EOF
			systemctl daemon-reload >/dev/null 2>&1
			
			#启动数据库
			systemctl restart mysql.service
			#设置root密码
			mysqladmin -uroot password ${Database_Password} >/dev/null 2>&1
			# 尝试连接MySQL数据库
			mysql -h127.0.0.1 -P3306 -uroot -p${Database_Password} -e "exit" >/dev/null 2>&1
			# 检查命令的返回值
			if [ $? -eq 0 ]; then
				# 连接MySQL数据库成功。
				mysql -h127.0.0.1 -P3306 -uroot -p${Database_Password} -e 'create database radius;' >/dev/null 2>&1
				mysql -h127.0.0.1 -P3306 -uroot -p${Database_Password} -e "use mysql;GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '"${Database_Password}"' WITH GRANT OPTION;flush privileges;" >/dev/null 2>&1
				systemctl restart mysql.service
				systemctl enable mysql.service >/dev/null 2>&1
			else
				echo "连接MySQL数据库失败。请重装系统后重新尝试!"
				exit 1;
			fi
			
			#安装FreeRadius-server
			echo "正在安装FreeRadius..."
			apt install freeradius freeradius-utils freeradius-mysql -y >/dev/null 2>&1
			radius_retry_count="1"
			while [ ! -f /usr/bin/freeradius ] && [ ! -f /usr/sbin/freeradius ] && [ ! -f /bin/freeradius ] && [ ! -f /sbin/freeradius ]; do
				# 检查重试次数是否大于或等于15
				if [[ ${radius_retry_count} -ge "15" ]]; then
					echo "FreeRadius安装失败,请检查服务器网络环境或apt安装源配置错误~"
					echo "安装失败，强制退出程序!!!"
					exit 1
				else
					# 增加重试计数
					radius_retry_count=$((${radius_retry_count}+1))
					# 安装 freeradius
					apt install freeradius freeradius-utils freeradius-mysql -y >/dev/null 2>&1
				fi
				sleep 3
			done
			rm -rf /etc/freeradius/3.0/mods-available/sql
			rm -rf /etc/freeradius/3.0/mods-available/sqlcounter
			rm -rf /etc/freeradius/3.0/sites-available/default
			rm -rf /etc/freeradius/3.0/mods-config/files/authorize
			rm -rf /etc/freeradius/3.0/mods-enabled/sql
			rm -rf /etc/freeradius/3.0/mods-enabled/sqlcounter
			rm -rf /etc/freeradius/3.0/sites-enabled/default
			rm -rf /etc/freeradius/3.0/radiusd.conf
			rm -rf /etc/freeradius/3.0/clients.conf
			rm -rf /etc/freeradius/3.0/dictionary
			rm -rf /etc/freeradius/3.0/users
			cd /etc/freeradius/3.0
			wget -q ${Download_Host}/freeradius3-ubuntu.zip -P /etc/freeradius/3.0
			unzip -o /etc/freeradius/3.0/freeradius3-ubuntu.zip >/dev/null 2>&1
			rm -rf /etc/freeradius/3.0/freeradius3-ubuntu.zip
			ln -s /etc/freeradius/3.0/mods-config/files/authorize /etc/freeradius/3.0/users
			ln -s /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/sql
			ln -s /etc/freeradius/3.0/mods-available/sqlcounter /etc/freeradius/3.0/mods-enabled/sqlcounter
			ln -s /etc/freeradius/3.0/sites-available/default /etc/freeradius/3.0/sites-enabled/default
			mysql -uroot -p${Database_Password} radius < /etc/freeradius/3.0/mods-config/sql/main/mysql/extras/wimax/schema.sql >/dev/null 2>&1
			mysql -uroot -p${Database_Password} radius < /etc/freeradius/3.0/mods-config/sql/cui/mysql/schema.sql >/dev/null 2>&1
			mysql -uroot -p${Database_Password} radius < /etc/freeradius/3.0/mods-config/sql/main/mysql/schema.sql >/dev/null 2>&1
			sed -i 's/content1/localhost/g' /etc/freeradius/3.0/mods-available/sql
			sed -i 's/content2/3306/g' /etc/freeradius/3.0/mods-available/sql
			sed -i 's/content3/root/g' /etc/freeradius/3.0/mods-available/sql
			sed -i 's/content4/'${Database_Password}'/g' /etc/freeradius/3.0/mods-available/sql
			chown -R freerad:freerad /etc/freeradius/3.0
			#启动RADIUS
			systemctl start freeradius.service
			systemctl enable freeradius.service >/dev/null 2>&1
		else
			echo "程序逻辑错误，脚本已被终止..."
			exit 1;
		fi
		
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
		mysql -uroot -p${Database_Password} radius < /var/www/html/daloradius/contrib/db/mysql-daloradius.sql >/dev/null 2>&1
		mysql -uroot -p${Database_Password} -e 'USE radius;DROP TABLE IF EXISTS dictionary;' >/dev/null 2>&1
		mysql -uroot -p${Database_Password} -e 'USE radius;DROP TABLE IF EXISTS radgroupcheck;' >/dev/null 2>&1
		if [[ ${Linux_OS} ==  "CentOS" ]]; then
			# 相同
			mysql -uroot -p${Database_Password} radius < /etc/raddb/dictionary.sql >/dev/null 2>&1
			mysql -uroot -p${Database_Password} radius < /etc/raddb/radgroupcheck.sql >/dev/null 2>&1
		elif [[ ${Linux_OS} ==  "Ubuntu" ]] || [[ ${Linux_OS} ==  "Debian" ]]; then
			# 相同
			mysql -uroot -p${Database_Password} radius < /etc/freeradius/3.0/dictionary.sql >/dev/null 2>&1
			mysql -uroot -p${Database_Password} radius < /etc/freeradius/3.0/radgroupcheck.sql >/dev/null 2>&1
		else
			echo "程序逻辑错误，脚本已被终止..."
			exit 1;
		fi
		mv /var/www/html/daloradius /var/www/html/${DaloRadius_file}
		
		
		#修改查询流量数据库信息
		sed -i 's/MySQL_Host/localhost/g' /var/www/html/user/info.php
		sed -i 's/MySQL_Port/3306/g' /var/www/html/user/info.php
		sed -i 's/MySQL_User/root/g' /var/www/html/user/info.php
		sed -i 's/MySQL_Pass/'${Database_Password}'/g' /var/www/html/user/info.php
	fi
	
	
	
	
	echo "正在安装博雅DALO Core..."
	
	
	#安装daloradius core
	rm -rf /Shirley
	mkdir /Shirley
	wget -q ${Download_Host}/Core.zip -P /Shirley
	cd /Shirley && unzip -o /Shirley/Core.zip >/dev/null 2>&1
	rm -rf /Shirley/Core.zip
	chmod -R 0777 /Shirley/*
	
	
	
	
	if [[ ${Linux_OS} ==  "CentOS" ]]; then
		# 相同
		systemctl stop firewalld.service >/dev/null 2>&1
		systemctl disable firewalld.service >/dev/null 2>&1
		systemctl stop iptables.service >/dev/null 2>&1
		yum install iptables iptables-services -y >/dev/null 2>&1
		iptables_retry_count="1"
		while [ ! -f /usr/bin/iptables ] && [ ! -f /usr/sbin/iptables ] && [ ! -f /bin/iptables ] && [ ! -f /sbin/iptables ]; do
			# 检查重试次数是否大于或等于15
			if [[ ${iptables_retry_count} -ge "15" ]]; then
				echo "iptables安装失败,请检查服务器网络环境或YUM安装源配置错误~"
				echo "安装失败，强制退出程序!!!"
				exit 1
			else
				# 增加重试计数
				iptables_retry_count=$((${iptables_retry_count}+1))
				# 安装 iptables
				yum install iptables iptables-services -y >/dev/null 2>&1
			fi
			sleep 3
		done
	elif [[ ${Linux_OS} ==  "Ubuntu" ]] || [[ ${Linux_OS} ==  "Debian" ]]; then
		# 相同
		#安装iptables
		apt install iptables -y >/dev/null 2>&1
		iptables_retry_count="1"
		while [ ! -f /usr/bin/iptables ] && [ ! -f /usr/sbin/iptables ] && [ ! -f /bin/iptables ] && [ ! -f /sbin/iptables ]; do
			# 检查重试次数是否大于或等于15
			if [[ ${iptables_retry_count} -ge "15" ]]; then
				echo "iptables安装失败,请检查服务器网络环境或apt安装源配置错误~"
				echo "安装失败，强制退出程序!!!"
				exit 1
			else
				# 增加重试计数
				iptables_retry_count=$((${iptables_retry_count}+1))
				# 安装 iptables
				apt install iptables -y >/dev/null 2>&1
			fi
			sleep 3
		done
	else
		echo "程序逻辑错误，脚本已被终止..."
		exit 1;
	fi
	
	
	echo '127.0.0.1 localhost' >> /etc/hosts
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
	iptables -A INPUT -s 127.0.0.1/32 -j ACCEPT
	iptables -A INPUT -d 127.0.0.1/32 -j ACCEPT
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
	#RADIUS通讯端口
	iptables -A INPUT -p udp -m udp --dport 1812 -j ACCEPT
	iptables -A INPUT -p udp -m udp --dport 1813 -j ACCEPT
	#其他
	iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	
	if [[ ${Linux_OS} ==  "CentOS" ]]; then
		# 相同
		service iptables save >/dev/null 2>&1
		systemctl restart iptables.service
		systemctl enable iptables.service >/dev/null 2>&1
	elif [[ ${Linux_OS} ==  "Ubuntu" ]] || [[ ${Linux_OS} ==  "Debian" ]]; then
		# 相同
		# 保存规则
		iptables-save > /Shirley/iptables/daloradius_rules.v4
		echo 'iptables-restore < /Shirley/iptables/daloradius_rules.v4 ' >> /Shirley/Config/auto_run
	else
		echo "程序逻辑错误，脚本已被终止..."
		exit 1;
	fi
	
	
	#配置sysctl
	rm -rf /etc/sysctl.conf
	mv /Shirley/Config/sysctl.conf /etc/sysctl.conf
	sysctl -p >/dev/null 2>&1
	
	
	#安装openvpn
	if [[ ${Linux_OS} ==  "CentOS" ]]; then
		# 相同
		yum install openvpn openvpn-devel -y >/dev/null 2>&1
		openvpn_retry_count="1"
		while [ ! -f /usr/bin/openvpn ] && [ ! -f /usr/sbin/openvpn ] && [ ! -f /bin/openvpn ] && [ ! -f /sbin/openvpn ]; do
			# 检查重试次数是否大于或等于15
			if [[ ${openvpn_retry_count} -ge "15" ]]; then
				echo "OpenVPN安装失败,请检查服务器网络环境或YUM安装源配置错误~"
				echo "安装失败，强制退出程序!!!"
				exit 1
			else
				# 增加重试计数
				openvpn_retry_count=$((${openvpn_retry_count}+1))
				# 安装 openvpn
				yum install openvpn openvpn-devel -y >/dev/null 2>&1
			fi
			sleep 3
		done
	elif [[ ${Linux_OS} ==  "Ubuntu" ]] || [[ ${Linux_OS} ==  "Debian" ]]; then
		# 相同
		apt install openvpn -y >/dev/null 2>&1
		openvpn_retry_count="1"
		while [ ! -f /usr/bin/openvpn ] && [ ! -f /usr/sbin/openvpn ] && [ ! -f /bin/openvpn ] && [ ! -f /sbin/openvpn ]; do
			# 检查重试次数是否大于或等于15
			if [[ ${openvpn_retry_count} -ge "15" ]]; then
				echo "OpenVPN安装失败,请检查服务器网络环境或apt安装源配置错误~"
				echo "安装失败，强制退出程序!!!"
				exit 1
			else
				# 增加重试计数
				openvpn_retry_count=$((${openvpn_retry_count}+1))
				# 安装 openvpn
				apt install openvpn -y >/dev/null 2>&1
			fi
			sleep 3
		done
	else
		echo "程序逻辑错误，脚本已被终止..."
		exit 1;
	fi
	
	
	rm -rf /etc/openvpn
	mv /Shirley/openvpn /etc/openvpn
	
	#修改监控数据库配置
	if [[ ${Installation_mode} ==  "ALL" ]]; then 
		sed -i 's/content1/Install_All/g' /Shirley/Config/Config.conf
		#修改流量监控配置
		sed -i 's/content1/127.0.0.1/g' /Shirley/Config/auth_config.conf
		sed -i 's/content2/3306/g' /Shirley/Config/auth_config.conf
		sed -i 's/content3/root/g' /Shirley/Config/auth_config.conf
		sed -i 's/content4/'${Database_Password}'/g' /Shirley/Config/auth_config.conf
	elif [[ ${Installation_mode} ==  "Node" ]]; then 
		#节点版本修改对接
		sed -i 's/content1/Install_Node/g' /Shirley/Config/Config.conf
		sed -i 's/name=localhost/name='${radius_address}'/g' /etc/openvpn/radiusplugin_server1194.cnf
		sed -i 's/name=localhost/name='${radius_address}'/g' /etc/openvpn/radiusplugin_server1195.cnf
		sed -i 's/name=localhost/name='${radius_address}'/g' /etc/openvpn/radiusplugin_server1196.cnf
		sed -i 's/name=localhost/name='${radius_address}'/g' /etc/openvpn/radiusplugin_server1197.cnf
		sed -i 's/name=localhost/name='${radius_address}'/g' /etc/openvpn/radiusplugin_server-udp.cnf
		#修改流量监控配置
		sed -i 's/content1/'${Database_Address}'/g' /Shirley/Config/auth_config.conf
		sed -i 's/content2/'${Database_Port}'/g' /Shirley/Config/auth_config.conf
		sed -i 's/content3/'${Database_Username}'/g' /Shirley/Config/auth_config.conf
		sed -i 's/content4/'${Database_Password}'/g' /Shirley/Config/auth_config.conf
	else
		echo "程序逻辑错误，脚本已被终止..."
		exit 1;
	fi
	sed -i 's/content5/'${Server_IP}'/g' /Shirley/Config/auth_config.conf
	sed -i 's/content2/'${Linux_OS}'/g' /Shirley/Config/Config.conf
	sed -i 's/content3/'${Server_IP}'/g' /Shirley/Config/Config.conf
	
	#编译radius认证插件
	cd /etc/openvpn/radiusplugin_v2.1a_beta1
	make >/dev/null 2>&1
	if [ ! -f /etc/openvpn/radiusplugin_v2.1a_beta1/radiusplugin.so ]; then
		echo "OpenVPN Radius认证插件编译失败,请等待脚本运行完成后尝试手动编译文件到 /etc/openvpn/radiusplugin_v2.1a_beta1/radiusplugin.so"
		exit 1;
	else
		mv /etc/openvpn/radiusplugin_v2.1a_beta1/radiusplugin.so /etc/openvpn/radiusplugin.so
		chmod -R 0777 /etc/openvpn/radiusplugin.so
	fi
	
	sed -i 's/content_dns/'${DNS_TYPE}'/g' /etc/openvpn/server1194.conf
	sed -i 's/content_dns/'${DNS_TYPE}'/g' /etc/openvpn/server1195.conf
	sed -i 's/content_dns/'${DNS_TYPE}'/g' /etc/openvpn/server1196.conf
	sed -i 's/content_dns/'${DNS_TYPE}'/g' /etc/openvpn/server1197.conf
	sed -i 's/content_dns/'${DNS_TYPE}'/g' /etc/openvpn/server-udp.conf
		
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
	
	
	# 编译 ZeroAUTH
	if [[ ${Linux_OS} ==  "CentOS" ]]; then
		# 相同
		gcc -std=gnu99 /Shirley/Core/ZeroAUTH.c -o /Shirley/Core/ZeroAUTH.bin -L/usr/lib64/mysql/ -lmysqlclient -lcurl -lcrypto >/dev/null 2>&1
	elif [[ ${Linux_OS} ==  "Ubuntu" ]] || [[ ${Linux_OS} ==  "Debian" ]]; then
		# 相同
		gcc -o /Shirley/Core/ZeroAUTH.bin /Shirley/Core/ZeroAUTH.c -lmysqlclient -lcurl -lcrypto >/dev/null 2>&1
	else
		echo "程序逻辑错误，脚本已被终止..."
		exit 1;
	fi
	
	if [ ! -f /Shirley/Core/ZeroAUTH.bin ]; then
		echo "ZeroAUTH文件编译失败,请等待脚本运行完成后尝试手动编译文件到 /Shirley/Core/ZeroAUTH.bin"
		echo "否则监控无法启动!!!"
	else
		rm -rf /Shirley/Core/ZeroAUTH.c
		chmod -R 0777 /Shirley/Core/ZeroAUTH.bin
	fi
	
	
	# 编译 Proxy
	gcc -o /Shirley/Core/Proxy.bin /Shirley/Core/Proxy.c >/dev/null 2>&1
	if [ ! -f /Shirley/Core/Proxy.bin ]; then
		echo "Proxy文件编译失败,请等待脚本运行完成后尝试手动编译文件到 /Shirley/Core/Proxy.bin"
		echo "否则OpenVPN Proxy无法启动!!!"
	else
		rm -rf /Shirley/Core/Proxy.c
		chmod -R 0777 /Shirley/Core/Proxy.bin
	fi
	
	
	
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
		echo "UDP 54"
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
	elif [[ ${Installation_mode} == "Node" ]]; then
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
		echo "UDP 54"
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
		echo "程序逻辑错误，脚本已被终止..."
		exit 1;
	fi
	
	
	return 0;
}




Install_boya_daloradius_dingd()
{
	#安装流量卫士
	clear 
	echo
	
	if [ -f /usr/local/etc/raddb/radiusd.conf ] && [ -f /etc/raddb/radiusd.conf ] && [ -f /boya/bin/vpn ] && [ -f /Shirley/bin/vpn ] && [ -f /etc/freeradius/radiusd.conf ]; then
		echo "检测到您已安装博雅DALO，不能重复安装 -1!!!"
		exit 1;
	fi
	
	if [ -f /usr/bin/mysql ] && [ -f /usr/sbin/mysql ] && [ -f /bin/mysql ] && [ -f /sbin/mysql ]; then
		echo "检测到您已安装博雅DALO/MySQL，不能重复安装 -2!!!"
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
	echo "这个卸载选项还没有完善，请您先使用 重装系统 进行卸载，谢谢。"
	exit 0;
	
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
	echo -e "\033[1;34m当前博雅DALO流控为Shirley后期修复编写!!! \033[0m"
	echo -e ""
	echo -e "\033[1;34m具体的更新日志请访问 https://github.com/Shirley-Jones/daloradius-boya/blob/main/Update_log.md \033[0m"
	echo -e ""
	echo -e "\033[1;34m当前版本: $Boya_Version\033[0m"
	echo -e ""
	echo "请根据下方提示输入相对应序号："
	echo "1.安装博雅DALO稳定版(主控+节点 完整安装)"
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
			Installation_mode="ALL";
			Install_boya_daloradius_guide
			Install_boya_daloradius
			return 0
			;;

		"2")
			Installation_mode="Node";
			Install_boya_daloradius_guide
			Install_boya_daloradius
			return 0
			;;

		"3")
			Install_boya_daloradius_dingd
			return 0
			;;

		"4")
			if [ ! -f /Shirley/bin/vpn ]; then
				echo "您还未安装博雅DALO，不能执行这个操作 error -1!!!"
				exit 1;
			else
				/Shirley/bin/vpn radius;
			fi
			return 0
			;;
		
		"5")
			if [ ! -f /Shirley/bin/vpn ]; then
				echo "您还未安装博雅DALO，不能执行这个操作 error -2!!!"
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
	# 设置全局变量，它可以自动处理安装时弹出的交互界面，仅本次脚本有效 Ubuntu Debian有效
	export DEBIAN_FRONTEND=noninteractive
	# 解决临时无网络问题 针对Ubuntu Debian系统
	echo "nameserver 8.8.8.8" >> /etc/resolv.conf
	Boya_Version="20241018"
	System_Check
	Installation_requires_software
	Detect_server_IP_address
	Installation_Selection
	return 0;
}


Main
exit 0;