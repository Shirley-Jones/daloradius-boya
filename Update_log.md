## 2024.05.20
* 更新了freeradius-3.0.12版本
* 现在daloradius后台中的设备在线数量（Simultaneous-Use）可以正常控制了
* 现在在线用户可以正常显示每60秒刷新一次用户数据了
* 添加了Android7+的新版APP
* 添加了Android7+的新版APP的API
* 添加了自动对接APP（旧版+新版app）
* 2024.01.22版本中线路安装有一个bug，无法记录用户选择的节点，目前已经修复（它被绑定在radius->userinfo->notes上）。
* 添加了流控卸载功能
* 添加了修改数据库信息的功能
* 添加了扫描异常用户掉线无法重新连接的监控（它将每120秒扫描一次180内没有数据的用户并清理）
* 修改了boya配置目录，现在目录位于/Shirley
* 优化了脚本安装逻辑
* 更改了APP后台内的证书密钥，现在安装后台即可使用，您无需再次修改
* 添加了一个新版的示例线路模板
* 
* 目前仍然有一个bug，用户的用户组为空时，freeradius验证还是能通过，这个等有空修复，如果需要禁用用户直接将用户分配到用户组（daloRADIUS-Disabled-Users）上，在这个用户组上的用户会被freeradius拒绝验证（身份验证失败）！


## 2024.05.19
* 好消息，基于CentOS7系统的freeradius3.0适配openvpn认证版本即将发布！
* 目前已经适配了 天数、流量、用户在线数，但仍然有其他的小bug，敬请期待！

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
