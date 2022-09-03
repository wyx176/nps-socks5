#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
webPort=18080
errorMsg=反馈群t.me/Scoks55555
version=v1.0
downLoadUrl=https://github.com/wyx176/nps-socks5/releases/download/
serverSoft=linux_amd64_server
clientSoft=linux_amd64_client
serverUrl=${downLoadUrl}${version}/${serverSoft}.tar.gz
clientUrl=${downLoadUrl}${version}/${clientSoft}.tar.gz
s5Path=/opt/nps-socks5/
ipAdd=检测失败

clearData(){
	cd ${s5Path}${clientSoft} && nps uninstall
	cd ${s5Path}${clientSoft} && ./npc uninstall
   
	#删除之前的
	rm -rf ${s5Path}
}

checkIp(){
yum -y install curl
ipAdd=`curl http://ifconfig.info -s --connect-timeout 10`
clear
echo "当前ip地址："${ipAdd}
read -p "如果不对请停止安装或者手动输入服务器ip：(y/n/ip)： " choice
	
	if [[ "$choice" == 'n' || "$choice" == 'N' ]]; then
			echo "安装结束"
			exit 0
	elif [[ "${choice}" == '' && "${ipAdd}" == '检测失败' ]]; then
			echo "安装失败：ip不正确"
			exit 0
	
	elif [[ "$choice" != 'y' && "$choice" != 'Y' && "${choice}" != '' ]]; then
		check_ip "${choice}"
	fi
	
	clearData
}

#2.下载Socks5服务
Download()
{
yum install git unzip wget -y
echo ""
echo "下载nps-socks5服务中请耐心等待..."
if [[ ! -d ${s5Path} ]];then
	mkdir -p ${s5Path}	
fi

#服务端
wget -P ${s5Path} --no-cookie --no-check-certificate ${serverUrl} 2>&1 | progressfilt
#客户端
wget -P ${s5Path} --no-cookie --no-check-certificate ${clientUrl} 2>&1 | progressfilt

if [[ ! -f ${s5Path}${serverSoft}.tar.gz ]]; then
	echo "服务端文件下载失败"${errorMsg}
	exit 0
fi

if [[ ! -f ${s5Path}${clientSoft}.tar.gz ]]; then
	echo "客户端文件下载失败"${errorMsg}
	exit 0
fi
}


#3.安装Socks5服务端程序
InstallServer()
{
echo ""
echo "服务端文件解压中..."

tar zxvf ${s5Path}${serverSoft}.tar.gz -C ${s5Path}

cd ${s5Path}${serverSoft}
sudo  ./nps install && nps start
}

InstallClient()
{

echo ""
echo "客户端文件解压中..."
if [[ ! -d ${s5Path}${clientSoft} ]]; then
echo "-------------"${s5Path}${clientSoft}
mkdir -p ${s5Path}${clientSoft}
fi
tar zxvf ${s5Path}${clientSoft}.tar.gz -C ${s5Path}${clientSoft}

echo "客户端文件安装中..."
cd ${s5Path}${clientSoft}
./npc install  -server=${ipAdd}:8025 -vkey=ij7poeu2d9btjbd3 -type=tcp && npc start
}

checkInstall(){
#检查服务端是否安装成功
SPID=`ps -ef|grep nps |grep -v grep|awk '{print $2}'`
if [[ -z ${SPID} ]]; then
echo ${SPID}"SPID----------------------"
echo "服务端安装失败"${errorMsg}
clearData
exit 0
fi

CPID=`ps -ef|grep npc |grep -v grep|awk '{print $2}'`
if [[ -z ${CPID} ]]; then
echo "客户端安装失败"${errorMsg}
exit 0
clearData
fi

clear
echo "--安装成功------"${errorMsg}
echo "--后台管理地址"${ipAdd}":"${webPort}
echo "--登录账号admin"
echo "--登录密码admin"
echo "如需修改后台管理端口以及账号密码请看github"
}

function check_ip(){
        IP=$1
        VALID_CHECK=$(echo $IP|awk -F. '$1<=255 && $2<=255 && $3<=255 && $4<=255 {print "yes"}')
        
        if echo $IP|grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$">/dev/null; then
                if [[ $VALID_CHECK == "yes" ]]; then
                        return "$IP"
                else
                        echo "安装失败：ip不正确"
						exit 0
                fi
        else
               echo "安装失败：非ip"
			   exit 0
        fi
}

progressfilt ()
{
    local flag=false c count cr=$'\r' nl=$'\n'
    while IFS='' read -d '' -rn 1 c
    do
        if $flag
        then
            printf '%s' "$c"
        else
            if [[ $c != $cr && $c != $nl ]]
            then
                count=0
            else
                ((count++))
                if ((count > 1))
                then
                    flag=true
                fi
            fi
        fi
    done
}

checkIp
Download
InstallServer
InstallClient
checkInstall