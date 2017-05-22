from	centos:7

run	yum install epel-release -y && yum clean all && yum makecache

# Install required packages
run	yum install expect python python-devel nodejs \
 python-cairocffi python-gunicorn python-django python-django-tagging \
 python-twisted-core fontconfig pytz gcc wget supervisor nginx git  -y

run wget -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py && python /tmp/get-pip.py

# python dependencies
# RUN pip install django==1.4\
#  python-memcached==1.53\
#  django-tagging==0.3.1\
#  whisper==0.9.13\
#  twisted==11.1.0\
#  txAMQP==0.6.2

# install graphite
RUN git clone -b 0.9.15 https://github.com/graphite-project/graphite-web.git /usr/local/src/graphite-web
WORKDIR /usr/local/src/graphite-web
RUN python ./setup.py install
ADD conf/graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
ADD conf/graphite/ /opt/graphite/conf/

# install whisper
RUN git clone -b 0.9.15 https://github.com/graphite-project/whisper.git /usr/local/src/whisper
WORKDIR /usr/local/src/whisper
RUN python ./setup.py install


# install carbon
RUN git clone -b 0.9.15 https://github.com/graphite-project/carbon.git /usr/local/src/carbon
WORKDIR /usr/local/src/carbon
RUN python ./setup.py install

# install statsd
RUN git clone -b v0.8.0 https://github.com/etsy/statsd.git /opt/statsd
ADD conf/statsd/config.js /opt/statsd/config.js

# config nginx
ADD conf/nginx/nginx.conf /etc/nginx/nginx.conf

# init django admin
ADD scripts/django_admin_init.exp /usr/local/bin/django_admin_init.exp
RUN chmod u+x /usr/local/bin/django_admin_init.exp
RUN /usr/bin/expect /usr/local/bin/django_admin_init.exp

# logging support
RUN mkdir -p /var/log/supervisor
ADD conf/logrotate /etc/logrotate.d/graphite

add	./supervisord.conf /etc/supervisord.d/supervisord.conf

# Nginx
expose	80
# Carbon line receiver port
expose	2003
# Carbon UDP receiver port
expose	2003/udp
# Carbon pickle receiver port
expose	2004
# Carbon cache query port
expose	7002

cmd	/usr/bin/supervisord -c /etc/supervisord.d/supervisord.conf

# vim:ts=8:noet:
