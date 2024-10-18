# 博雅DALO流控|Shirley后期修复编写|全新用户流量监控|支持Ubuntu、Debian、CentOS|新版freeradius3.0

## 推荐的服务器配置
* 系统: Ubuntu20+ Debian11+ CentOS7
* CPU/内存：1核512M (512M内存 推荐使用CentOS7系统)
* 带宽：推荐5Mbps以上
* 网络：必须具有固定公网IP (IPV4)
* 经过测试通过的系统版本 Ubuntu20.04、Ubuntu22.04、Debian11、Debian12、CentOS7 (尽量不要使用老系统,CentOS7除外~)

## 更新日志
* 新版本支持Ubuntu、Debian、CentOS，freeradius3.0，修复了超多问题!!!详细点击下方链接
* 具体的更新日志请访问 https://github.com/Shirley-Jones/daloradius-boya/blob/main/Update_log.md


## 安装脚本
如果出现安装失败，请全格重装系统，手动更新yum源后重新执行安装脚本即可。
```shell script
wget --no-check-certificate -O Boya_Launcher.sh https://raw.githubusercontent.com/Shirley-Jones/daloradius-boya/main/Boya_Launcher.sh && chmod +x ./Boya_Launcher.sh && ./Boya_Launcher.sh
```

## 常用命令
> 重启流控 vpn restart

> 开端口 vpn port

> 系统工具 vpn tools

> 系统负载 vpn tools 选择系统负载选项


## 免责声明
* 脚本写的很辣鸡，还请大佬多多包涵。
* 这个版本为Shirley后期修复编写!!!
* 本脚本仅用于学习交流，禁止商业，下载安装后请在24小时内删除！
* 流控版权为情韵(博雅)所有！！
* 博雅DALO流控官网: https://www.52hula.cn (已下线)

## 关于源码
* 项目基于博雅Dalo开源而来，我个人没有加入任何后门，脚本已全部开源(包括C文件)，欢迎检查，不放心的不要用，谢谢！
* 用户流量监控已开源，如果你需要二开重新编译详情下方



## 用户流量监控文件说明
* 编译说明
* CentOS7 
* 先安装支持库: yum install mariadb-devel curl libcurl-devel openssl openssl-devel gcc gcc++ gdb -y
* 编译 gcc -std=gnu99 监控源码文件 -o 编译后的文件名 -L/usr/lib64/mysql/ -lmysqlclient -lcurl -lcrypto
* 举个例子 gcc -std=gnu99 /Shirley/Core/ZeroAUTH.c -o /Shirley/Core/ZeroAUTH.bin -L/usr/lib64/mysql/ -lmysqlclient -lcurl -lcrypto

* Ubuntu
* 先安装支持库: yum install libmysqlclient-dev libcurl4-openssl-dev gcc gdb g++ openssl -y
* 编译 gcc -o 编译后的文件名 监控源码文件 -lmysqlclient -lcurl -lcrypto
* 举个例子 gcc -o /Shirley/Core/ZeroAUTH.bin /Shirley/Core/ZeroAUTH.c -lmysqlclient -lcurl -lcrypto

* Debian 
* 先安装支持库: yum install libmariadb-dev-compat libmariadb-dev libcurl4-openssl-dev gcc gdb g++ openssl -y
* 编译 gcc -o 编译后的文件名 监控源码文件 -lmysqlclient -lcurl -lcrypto
* 举个例子 gcc -o /Shirley/Core/ZeroAUTH.bin /Shirley/Core/ZeroAUTH.c -lmysqlclient -lcurl -lcrypto


  
## 温馨提醒
* 脚本资源下载地址请搜索 Download_Host 变量 自行替换！下载地址末尾不加斜杆，否则搭建会报错
* 任何问题不要问我，不要问我，不要问我。
* 任何问题不要问我，不要问我，不要问我。
* 任何问题不要问我，不要问我，不要问我。



