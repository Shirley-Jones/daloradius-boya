## 2024.02.16
* 更新了一个全新的启动器，未来的所有更新都需要它。

## 2024.01.22
* 博雅DALO它现在正式支持CentOS7了,弃用了CentOS6.
* 更新了freeradius2.2.10安装方式，它现在支持CentOS7了
* 更新了openvpn配置文件 现在是四个tcp配置文件+一个udp配置文件
* 更新了openvpn proxy 现在使用的是FAS Proxy 它支持每个配置IP循环分配
* 更新了openvpn 服务器证书，现在的证书有效期是100年，（注意，老版本的证书它不再受支持！）
* 更新了VPN 文件模块 现在它支持 开端口、重置防火墙、系统负载 等功能
* 添加了openvpn 限速插件，它现在可以全局限制用户的网络速度 配置文件位于/etc/openvpn/bwlimitplugin.cnf
* 添加了openvpn 高级日志，它现在可以更详细的记录openvpn的错误日志
* 优化了dnsmasq 配置文件，它现在可以正常拦截网址了
* 优化了sysctl 配置文件
* 添加了自定义开机自启模块！ 文件位于 /boya/Config/auto_run
* 添加了phpmyadmin管理
* 重新优化了脚本安装逻辑，现在它安装的更快了
* 移除了博雅DALO haproxy squid 等无用模块
* 移除了daloradius后台广告 恢复原版 保留博雅版权
* 移除了博雅DALO遗留的数据库账户 “radius hehe123” 因为它不安全，现在使用root账户进行数据库管理
