sudo docker build -t graphite:v1 -f Dockerfile .

docker run -d \
  --name graphite \
  -p 8000:8000 \
  -p 2003:2003 \
  graphite:v1


[root@master01 ~]# docker stop graphite 
graphite
[root@master01 ~]# docker start graphite 
graphite
[root@master01 ~]# docker logs -f graphite 
[root@master01 ~]# docker exec -it graphite bash


/var/lib/carbon/whisper
sudo docker exec -it graphite bash

[hadoop@master01 ~]$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                                                          NAMES
69523a26459d        graphite:v1         "/bin/sh -c '/usr/..."   2 hours ago         Up 2 hours          2004/tcp, 0.0.0.0:2003->2003/tcp, 2003/udp, 0.0.0.0:8000->8000/tcp, 7002/tcp   dockergraphite_graphite_1
[hadoop@master01 ~]$ sudo docker exec -it dockergraphite_graphite_1 bash

[root@graphite ~]# /usr/lib/python2.7/site-packages/graphite/manage.py createsuperuser
/usr/lib/python2.7/site-packages/graphite/settings.py:246: UserWarning: SECRET_KEY is set to an unsafe default. This should be set in local_settings.py for better security
  warn('SECRET_KEY is set to an unsafe default. This should be set in local_settings.py for better security')
Username (leave blank to use 'root'): 
Email address: root@csdn.net
Password: 
Password (again): 
Superuser created successfully.
[root@graphite ~]# 
