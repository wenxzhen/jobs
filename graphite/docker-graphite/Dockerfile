FROM centos:7
MAINTAINER yangxy <yangxy@csdn.net>

RUN yum install epel-release -y && yum clean all 

RUN yum install python-carbon python-whisper  graphite-web supervisor expect -y && yum clean all

RUN /usr/lib/python2.7/site-packages/graphite/manage.py syncdb --noinput

# ADD scripts/django_admin_init.exp /usr/local/bin/django_admin_init.exp
# RUN /usr/local/bin/django_admin_init.exp

add	conf/supervisord.conf /etc/supervisord.d/supervisord.conf

add	conf/storage-schemas.conf /etc/carbon/storage-schemas.conf

# Nginx
expose	8000
# Carbon line receiver port
expose	2003
# Carbon UDP receiver port
expose	2003/udp
# Carbon pickle receiver port
expose	2004
# Carbon cache query port
expose	7002

cmd	/usr/bin/supervisord -c /etc/supervisord.d/supervisord.conf