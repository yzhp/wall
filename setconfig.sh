#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

wget https://install.direct/go.sh
bash go.sh >> /root/nginx-tls-ws.log 2>&1

num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
port_num=$(($num%40001+10000))
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf_bak${port_num}
echo "install Domain："
read domain_name
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
        
#        ssl_certificate      /etc/letsencrypt/live/${domain_name}/fullchain.pem;
#        ssl_certificate_key  /etc/letsencrypt/live/${domain_name}/privkey.pem;
        
#        ssl_protocols    TLSv1.3;
#        ssl_ciphers      TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256;
#        ssl_prefer_server_ciphers  on;
#        ssl_session_cache shared:SSL:10m;
#        ssl_session_timeout 60m;
        
        location /etc {
            proxy_redirect off;
            proxy_pass https://127.0.0.1:${port_num};
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
colorEcho(){
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}
colorEcho 32m  "url: ${domain_name} 443 to: ${port_num} uuid: ${uuid}  ws-path: /etc"