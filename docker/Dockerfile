FROM centos:latest
MAINTAINER yangxy <yangxy@csdn.net>

RUN yum -y update && yum -y install openssh-server openssh-clients net-tools && yum clean all

RUN echo 'root:root' | chpasswd

RUN ssh-keygen -A

RUN mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && chown -R root:root ~/.ssh && chmod -R 700 ~/.ssh 

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
