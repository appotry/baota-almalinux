FROM centos:7
MAINTAINER andycruose@gmail.com

#设置entrypoint
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    mkdir -p /www
    
#更新系统 安装工具
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo  && \
    yum -y update && \
    yum -y install wget openssh-server

WORKDIR /www

# Build a base server and configuration if it doesnt exist, then start
CMD \
  if [ "$(ls -A /www/letsencrypt)" ]; then \
    echo "***** /www/letsencrypt directory exists and has content, continuing *****"; \
  else \
    echo "***** /www/letsencrypt directory is empty. letsencrypt映射到www文件夹下持久化 *****" && \
    mkdir -p /www/letsencrypt && \
    ln -s /www/letsencrypt /etc/letsencrypt \
  fi; \
  if [ "$(ls -A /www/init.d)" ]; then \
    echo "***** /www/init.d directory exists and has content, continuing *****"; \
  else \
    echo "***** /www/init.d directory is empty *****" && \
    rm -f /etc/init.d && \
    mkdir /www/init.d && \
    ln -s /www/init.d /etc/init.d && \
    ln -s /www/letsencrypt /etc/letsencrypt \
  fi; \
  if [ "$(ls -A /www/server/panel)" ]; then \
    echo "***** /www/server/panel directory exists and has content, continuing *****"; \
  else \
    echo "***** /www/server/panel directory is empty. install panel*****" && \
    cd /tmp && \
    wget -O install_panel.sh http://download.bt.cn/install/install_panel.sh && \
    mkdir /www/init.d && \
    echo yes | bash install_panel.sh && \
    yum clean all \
  fi; \
  if [ "$(ls -A /www/server/mysql)" ]; then \
    echo "***** /www/server/mysql directory exists and has content, continuing *****"; \
  else \
    echo "***** /www/server/mysql directory is empty. install mariadb_10.3 *****" && \
    bash /www/server/panel/install/install_soft.sh 0 install mysql mariadb_10.3 \
  fi; \
  /entrypoint.sh
  
EXPOSE 8888 888 21 20 443 3306 80

HEALTHCHECK --interval=5s --timeout=3s CMD curl -fs http://localhost:8888/ && curl -fs http://localhost/ || exit 1 
