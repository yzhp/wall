# wall
 
Operating system:	Centos 7 x86_64 

sudo -i
yum update -y #����VPS���ṩ�Ļ�׼ϵͳ����ͬ��������һ�°�
yum -y install wget unzip zip

wget https://github.com/yzhp/wall/archive/master.zip && unzip master.zip && rm -rf master.zip

bash wall-master/nginx.sh  ##���밲װnginx

bash wall-master/tls.sh    ##����Let�� s Encrypt֤�飬ǰ��׼����һ������

bash wall-master/v2ray.sh  ##������װV2RAY

bash wall-master/v2ray-nginx-websocks.sh  ##��װV2RAY��д����

bash wall-master/setconf.sh  ##��������V2RAY��nginx������

bash wall-master/tcp.sh   ##tcp�Ż�����

#ip��ǽ����CDN���