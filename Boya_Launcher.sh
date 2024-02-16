#!/bin/bash
#Project address: https://github.com/Shirley-Jones/daloradius-boya
#Thank you very much for using this project!
#博雅情韵QQ: 2223139086
#Shirley后期修复编写

Installation_Selection()
{
	clear
	echo
	#选项栏
	echo -e "\033[1;34m使用说明\033[0m"
	echo -e ""
	echo -e "\033[1;34m这个版本为Shirley后期修复编写，并且它只支持CentOS7 X64 !!! \033[0m"
	echo -e ""
	echo -e "\033[1;34m具体的更新日志请访问 https://github.com/Shirley-Jones/daloradius-boya/blob/main/Update_log.md \033[0m"
	echo -e ""
	echo "请根据下方提示输入相对应序号："
	echo "1.安装博雅DALO最新版"
	echo "2.安装博雅DALO历史版"
	echo "3.退出脚本"
	echo
	read -p "请选择[1-3]: " Install_options

	case "${Install_options}" in
		1)
			Installation_mode="Latest";
			Get_version
			return 0
		;;

		2)
			Installation_mode="History";
			Get_version
			return 0
		;;

		3)
			echo "感谢您的使用，再见！"
			exit 0
		;;
		*)
			echo "输入错误！请重新运行脚本！"
			exit 1
		;;
	esac
	
	
	
}


Get_version()
{
	echo "正在从Github加载配置文件..."
	rm -rf ${Script_file_directory}
	rm -rf ${Configuration_file_directory}
	curl -o ${Configuration_file_directory} https://raw.githubusercontent.com/Shirley-Jones/daloradius-boya/main/Boya_Version.conf >/dev/null 2>&1
	#wget -q --no-check-certificate --no-cache --no-cookies https://raw.githubusercontent.com/Shirley-Jones/daloradius-boya/main/Boya_Version.conf -P /root
	if [ ! -f ${Configuration_file_directory} ]; then
		echo "配置文件下载失败，请检查您的网络环境!!!"
		exit 1;
	fi
	
	clear
	echo
	
	case "${Installation_mode}" in
		"Latest")
			#序号 1
			Serial_Number=`cat $Configuration_file_directory |grep "Latest" |grep -v "grep" |awk '{print $1}'`;
			#版本类型 2
			Version_Type=`cat $Configuration_file_directory |grep "Latest" |grep -v "grep" |awk '{print $2}'`;
			#项目名字 3
			Project_Name=`cat $Configuration_file_directory |grep "Latest" |grep -v "grep" |awk '{print $3}'`;
			#更新时间 4
			update_time=`cat $Configuration_file_directory |grep "Latest" |grep -v "grep" |awk '{print $4}'`;
			#下载地址 5
			Download_address=`cat $Configuration_file_directory |grep "Latest" |grep -v "grep" |awk '{print $5}'`;
			#MD5 6
			Boya_md5=`cat $Configuration_file_directory |grep "Latest" |grep -v "grep" |awk '{print $6}'`;
			echo -e ""
			echo "正在从Github获取最新的安装脚本 [$Version_Type]$Project_Name $update_time..."
			#wget -q --no-check-certificate --no-cache --no-cookies https://${Download_address} -P /root
			curl -o ${Script_file_directory} https://${Download_address} >/dev/null 2>&1
			if [ -f ${Script_file_directory} ]; then
				get_file_md5=$(md5sum -b $Script_file_directory | cut -d' ' -f1)
				uppercase_md5=$(echo $get_file_md5 | tr '[:lower:]' '[:upper:]')
				if [[ ${uppercase_md5} == ${Boya_md5} ]];then
					#MD5正确  执行脚本
					chmod -R 0777 ${Script_file_directory}
					${Script_file_directory}
				else
					#不相同
					echo "脚本MD5验证失败，文件可能被篡改，请检查您的网络环境!!!"
					exit 1;
				fi
			else
				echo "脚本下载失败，请检查您的网络环境!!!"
				exit 1;
			fi
			
			return 0
		;;

		"History")
			echo -e ""
			echo "请根据下方提示输入相对应序号："
			echo
			cat $Configuration_file_directory | while read line
			do
				#序号 1
				Serial_Number=`echo $line | cut -d \  -f 1`
				#版本类型 2
				Version_Type=`echo $line | cut -d \  -f 2`
				#项目名字 3
				Project_Name=`echo $line | cut -d \  -f 3`
				#更新时间 4
				update_time=`echo $line | cut -d \  -f 4`
				#下载地址 5
				Download_address=`echo $line | cut -d \  -f 5`
				echo "$Serial_Number、[$Version_Type]$Project_Name $update_time" ;
			done

			echo
			read -p "请选择序号: " Install_Type
			echo "请稍等..."
			#序号 1
			Serial_Number=`cat $Configuration_file_directory |grep "$Install_Type" |grep -v "grep" |awk '{print $1}'`;
			#版本类型 2
			Version_Type=`cat $Configuration_file_directory |grep "$Install_Type" |grep -v "grep" |awk '{print $2}'`;
			#项目名字 3
			Project_Name=`cat $Configuration_file_directory |grep "$Install_Type" |grep -v "grep" |awk '{print $3}'`;
			#更新时间 4
			update_time=`cat $Configuration_file_directory |grep "$Install_Type" |grep -v "grep" |awk '{print $4}'`;
			#下载地址 5
			Download_address=`cat $Configuration_file_directory |grep "$Install_Type" |grep -v "grep" |awk '{print $5}'`;
			#MD5 6
			Boya_md5=`cat $Configuration_file_directory |grep "$Install_Type" |grep -v "grep" |awk '{print $6}'`;
			read -p  "您已选择: $Serial_Number、[$Version_Type]$Project_Name $update_time 正确请回车继续！"
			
			#下载脚本
			echo
			echo "正在从Github获取您选择的安装脚本 [$Version_Type]$Project_Name $update_time..."
			
			curl -o ${Script_file_directory} https://${Download_address} >/dev/null 2>&1
			if [ -f ${Script_file_directory} ]; then
				get_file_md5=$(md5sum -b $Script_file_directory | cut -d' ' -f1)
				uppercase_md5=$(echo $get_file_md5 | tr '[:lower:]' '[:upper:]')
				if [[ ${uppercase_md5} == ${Boya_md5} ]];then
					#MD5正确  执行脚本
					chmod -R 0777 ${Script_file_directory}
					${Script_file_directory}
				else
					#不相同
					echo "脚本MD5验证失败，文件可能被篡改，请检查您的网络环境!!!"
					exit 1;
				fi
			else
				echo "脚本下载失败，请检查您的网络环境!!!"
				exit 1;
			fi
			
			
			return 0
		;;
		
		*)
			echo "程序逻辑错误！脚本已被中止！"
			exit 1
		;;
	esac
	
	
}




Main()
{
	rm -rf /root/test.log
	rm -rf $0
	echo "Loading...";
	Configuration_file_directory="/root/Boya_Version.conf"
	Script_file_directory="/root/Boya.sh"
	Installation_Selection
	return 0;
}


Main
exit 0;