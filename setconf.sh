#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
port_num=$(($num%40001+10000))
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf_bak${port_num}
read -p "install Domain：" domain_name
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

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  ${domain_name};
        
        root /usr/share/nginx/html;
        index index.html index.htm;

        location /etc {
            proxy_redirect off;
            proxy_pass http://127.0.0.1:${port_num};
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host \$http_host;
        }
        
        error_page   500 502 503 504  /50x.html;
    }
}
EOF

uuid=$(cat /proc/sys/kernel/random/uuid)
cat > /etc/v2ray/config.json << EOF
{
  "inbounds": [{
    "port": ${port_num},
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "${uuid}",
          "level": 1,
          "alterId": 64
        }
      ]
    },
    "streamSettings": {
     "network": "ws",
     "wsSettings": {
       "path": "/etc"
      }
    }
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  },{
    "protocol": "blackhole",
    "settings": {},
    "tag": "blocked"
  }],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": ["geoip:private"],
        "outboundTag": "blocked"
      }
    ]
  }
}
EOF
systemctl restart nginx && systemctl restart v2ray
Green_font_prefix="\033[32m" && Font_color_suffix="\033[0m"
echo -e "${Green_font_prefix}url: ${domain_name} 443 to: ${port_num} uuid: ${uuid}  ws-path: /etc${Font_color_suffix}"