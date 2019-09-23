#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
cd /usr/local/src/
wget  https://github.com/certbot/certbot/archive/v0.38.0.tar.gz && tar xzvf v0.38.0.tar.gz
cd /usr/local/src/certbot-0.38.0
echo "Let’ s Encrypt-admin-email："
read admin_mail
echo "install Domain："
read domain_name
systemctl stop nginx
./certbot-auto certonly --standalone --email ${admin_mail} -d ${domain_name}
systemctl start nginx
cat > /root/certbotrenew.sh << EOF
#!/bin/sh
#停止 nginx 服务,使用 --standalone 独立服务器验证需要停止当前 web server.
systemctl stop nginx
if ! /usr/local/src/certbot-0.38.0/certbot-auto renew -nvv --standalone > /var/log/letsencrypt/renew.log 2>&1 ; then
    echo Automated renewal failed:
    cat /var/log/letsencrypt/renew.log
    exit 1
fi
#启动 nginx
systemctl start nginx
EOF
chmod + /root/certbotrenew.sh
colorEcho(){
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}
colorEcho 32m "crobtab -e install  0 23 28 * * /bin/sh /root/certbotrenew.sh"