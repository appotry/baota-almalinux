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
CMD /entrypoint.sh
  
EXPOSE 8888 888 21 20 443 3306 80

HEALTHCHECK --interval=5s --timeout=3s CMD curl -fs http://localhost:8888/ && curl -fs http://localhost/ || exit 1 
