# wall
 
Operating system:	Centos 7 x86_64 
sudo -i
yum -y install wget unzip zip

wget https://github.com/yzhp/wall/archive/master.zip && unzip master.zip && rm -rf master.zip

bash code-master/nginx.sh  ##���밲װnginx
bash code-master/tls.sh    ##����Let�� s Encrypt֤�飬ǰ��׼����һ������
bash code-master/v2ray.sh  ##������װV2RAY
bash code-master/v2ray-nginx-websocks.sh  ##��װV2RAY��д����
bash code-master/tcp.sh   ##tcp�Ż�����

#ip��ǽ����CDN���