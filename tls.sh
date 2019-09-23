#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
cd /usr/local/src/
wget  https://github.com/certbot/certbot/archive/v0.38.0.tar.gz && tar xzvf v0.38.0.tar.gz
cd /usr/local/src/certbot-0.38.0 
read -p "Let’ s Encrypt-admin-email：" admin_mail
read -p "install Domain：" domain_name
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
Green_font_prefix="\033[32m" && Font_color_suffix="\033[0m"
echo -e "${Green_font_prefix}crobtab -e install  0 23 28 * * /bin/sh /root/certbotrenew.sh${Font_color_suffix}"
cat > /etc/nginx/nginx.conf << EOF
user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
    #                  '\$status \$body_bytes_sent "\$http_referer" '
    #                  '"\$http_user_agent" "\$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  ${domain_name};
#        add_header Strict-Transport-Security max-age=15768000;
#        return 301 https://\$server_name\$request_uri;
    }
    
    server {
        listen       443 ssl http2 default_server;
        server_name  ${domain_name};
        
        index  index.php index.html index.htm;
        root   /etc/nginx/html;
        
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        
        ssl_certificate      /etc/letsencrypt/live/${domain_name}/fullchain.pem;
        ssl_certificate_key  /etc/letsencrypt/live/${domain_name}/privkey.pem;
        
        ssl_protocols    TLSv1.3;
        ssl_ciphers      TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256;
        ssl_prefer_server_ciphers  on;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 60m;
                
        error_page   500 502 503 504  /50x.html;
    }
}
EOF
systemctl restart nginx