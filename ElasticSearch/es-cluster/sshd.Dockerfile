FROM centos:7
MAINTAINER yangxy <yangxy@csdn.net>

RUN yum install -y epel-release.noarch

RUN yum -y update && yum -y install ansible openssh-server openssh-clients net-tools telnet which lsof && yum clean all

RUN echo 'root:root' | chpasswd

RUN useradd es

RUN echo 'es:es' | chpasswd

RUN ssh-keygen -A

RUN mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && chown -R root:root ~/.ssh && chmod -R 700 ~/.ssh 

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

