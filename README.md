# wall
 
Operating system:	Centos 7 x86_64 

sudo -i
yum update -y #各大VPS商提供的基准系统不相同，还是升一下吧
yum -y install wget unzip zip

wget https://github.com/yzhp/wall/archive/master.zip && unzip master.zip && rm -rf master.zip

bash wall-master/nginx.sh  ##编译安装nginx

bash wall-master/tls.sh    ##申请Let’ s Encrypt证书，前提准备好一个域名

bash wall-master/v2ray.sh  ##单独安装V2RAY

bash wall-master/v2ray-nginx-websocks.sh  ##安装V2RAY及写配置

bash wall-master/setconf.sh  ##重新配置V2RAY与nginx的配置

bash wall-master/tcp.sh   ##tcp优化加速

#ip被墙后套CDN挽救