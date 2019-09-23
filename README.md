# wall
 
Operating system:	Centos 7 x86_64 
sudo -i
yum -y install wget unzip zip

wget https://github.com/yzhp/wall/archive/master.zip && unzip master.zip && rm -rf master.zip

bash code-master/nginx.sh  ##编译安装nginx
bash code-master/tls.sh    ##申请Let’ s Encrypt证书，前提准备好一个域名
bash code-master/v2ray.sh  ##单独安装V2RAY
bash code-master/v2ray-nginx-websocks.sh  ##安装V2RAY及写配置
bash code-master/tcp.sh   ##tcp优化加速

#ip被墙后套CDN挽救