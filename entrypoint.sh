  if [ "$(ls -A /www/letsencrypt)" ]; then 
    echo "***** /www/letsencrypt directory exists and has content, continuing *****"; 
  else 
    echo "***** /www/letsencrypt directory is empty. letsencrypt映射到www文件夹下持久化 *****"
    mkdir -p /www/letsencrypt 
    ln -s /www/letsencrypt /etc/letsencrypt 
  fi; 
  if [ "$(ls -A /www/init.d)" ]; then 
    echo "***** /www/init.d directory exists and has content, continuing *****"; 
  else 
    echo "***** /www/init.d directory is empty. init.d 映射到www文件夹下持久化*****" 
    rm -f /etc/init.d 
    mkdir /www/init.d 
    ln -s /www/init.d /etc/init.d 
  fi;
  if [ "$(ls -A /www/server/panel)" ]; then 
    echo "***** /www/server/panel directory exists and has content, continuing *****"; 
  else 
    echo "***** /www/server/panel directory is empty. install panel*****" 
    cd /tmp 
    wget -O install_panel.sh http://download.bt.cn/install/install_panel.sh 
    mkdir /www/init.d 
    echo yes | bash install_panel.sh 
    yum clean all
  fi;


if [ ! -f "/etc/ssh/ssh_host_rsa_key" ];then
    ssh-keygen -t rsa -N '' -q -f /etc/ssh/ssh_host_rsa_key
fi
if [ ! -f "/root/.ssh/id_rsa_63322" ];then
    ssh-keygen -t rsa -N '' -q -f /root/.ssh/id_rsa_63322
    cat /root/.ssh/id_rsa_63322.pub >> /root/.ssh/authorized_keys
    _f1='{"username": "root", "pkey": "'
    _f2=$(sed s/$/'\\n'/ /root/.ssh/id_rsa_63322 | tr -d '\r\n')
    _f3='", "is_save": "1", "c_type": "True", "host": "127.0.0.1", "password": "", "port": 63322}'
    echo "${_f1}${_f2}${_f3}" | base64 | tr -d '\r\n '| od -An -tx1 | tr -d '\r\n ' > "/www/server/panel/config/t_info.json"
fi

/usr/sbin/sshd
/usr/sbin/crond

for file in `ls /etc/init.d`
do if [ -x /etc/init.d/${file} ];  then 
    /etc/init.d/$file restart
fi done
bt default

tail -f /dev/null
