# 博雅DALO流控|Shirley后期修复编写|CentOS7+freeradius3.0.12新版来袭!

## 准备工作
* 准备一台CentOS7 x64服务器 (推荐腾讯云 阿里云 IDC大宽带)
* CPU/内存：服务器配置最低1核1G
* 带宽：推荐8Mbps以上
* 网络：必须具有固定公网IP（IPV4）

## 更新日志
* 支持centos7，freeradius3.0.12，修复了超多问题!!!详细点击下方链接
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
* 这个版本为Shirley后期修复编写，并且它只支持CentOS7 X64 !!!
* 本脚本仅用于学习交流，禁止商业，下载安装后请在24小时内删除！
* 流控版权为情韵(博雅)所有！！
* 博雅DALO流控官网: https://www.52hula.cn (已下线)

## 关于源码
* 项目基于博雅Dalo开源而来，我个人没有加入任何后门，脚本已全部开源，欢迎检查，不放心的不要用，谢谢！
* Proxy代理文件基于 FAS的Proxy代理 (这个是C语言文件 FAS作者: 筑梦冬瓜 没有开放源码，我也没有!!!) 
* 用户流量监控文件暂时不考虑开源，谢谢，如果不放心怕有后门什么的，请直接删除即可 rm -rf /Shirley/Core/Zero_Auth.bin (这个只是监控用户流量和天数的作用)

  
## 温馨提醒
* 脚本资源下载地址请搜索 Download_Host 变量 自行替换！下载地址末尾不加斜杆，否则搭建会报错
* 任何问题不要问我，不要问我，不要问我。
* 任何问题不要问我，不要问我，不要问我。
* 任何问题不要问我，不要问我，不要问我。



