# nps-socks5服务一键搭建脚本
- [x] 稳定版V1.0

## 介绍 ##
基于nps的Shell脚本，集成socks5搭建，管理，启动，添加账号等基本操作。方便用户操作，并且支持快速构建socks5服务环境。
- 默认管理页面ip:18080<br>
- 默认管理员账号密码:admin admin<br>
- 默认socks5账号信息:账号socks5  密码socks5 端口5555
- 支持多端口、多账号管理<br>
- 服务端、客户端分离安装、可实现国内中专代理，降低被和谐概率<br>
- 脚本只提供学习交流，请在法律允许范围内使用！！！！<br>
![image](https://github.com/wyx176/nps-socks5/blob/main/server.png)
![image](https://github.com/wyx176/nps-socks5/blob/main/port.png)
## 系统支持 ##
* centos 
* 其它版本系统的需要构建，目前手里只有centos，需要其它系统的到群里反馈联系


## 功能 ##
 全自动无人值守安装，服务端部署只需一条命令）
- 全新的web端管理，支持多端口、多账号、多服务器、以及中转代理
- 添加账户，删除用户，开启账户验证，关闭账户验证，一键修改端口

## 一键安装或更新到最新 ##
 <pre><code>wget -q -N --no-check-certificate https://raw.githubusercontent.com/wyx176/nps-socks5/main/install.sh && chmod 777 install.sh && bash install.sh</code></pre>

## 相关文件路径 ##
- 1.后台管理的配置文件<br>
 /etc/nps/conf<br>
 登录账号web_username=admin<br>
 登录密码web_password=admin<br>
 web管理端口web_port = 18080<br>
 
## 更新日志 ##
-2022.10.03 v2.0<br>
1、增加多端口、多账号设置
-2022.09.03 v1.0<br>

## 写在最后 ##
Telegram交流群:https://t.me/Socks55555
