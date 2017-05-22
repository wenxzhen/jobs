# Install
```
ansible-playbook -i hosts install.yml
```

# Init django db
```
[root@master graphite]# pwd
/opt/graphite/webapp/graphite
[root@master graphite]# python manage.py syncdb
/opt/graphite/webapp/graphite/settings.py:246: UserWarning: SECRET_KEY is set to an unsafe default. This should be set in local_settings.py for better security
  warn('SECRET_KEY is set to an unsafe default. This should be set in local_settings.py for better security')
Creating tables ...
Creating table account_profile
Creating table account_variable
Creating table account_view
Creating table account_window
Creating table account_mygraph
Creating table dashboard_dashboard_owners
Creating table dashboard_dashboard
Creating table events_event
Creating table url_shortener_link
Creating table auth_permission
Creating table auth_group_permissions
Creating table auth_group
Creating table auth_user_groups
Creating table auth_user_user_permissions
Creating table auth_user
Creating table django_session
Creating table django_admin_log
Creating table django_content_type
Creating table tagging_tag
Creating table tagging_taggeditem

You just installed Django's auth system, which means you don't have any superusers defined.
Would you like to create one now? (yes/no): yes 
Username (leave blank to use 'root'): root
Email address: root@csdn.net
Password: 
Password (again): 
Superuser created successfully.
Installing custom SQL ...
Installing indexes ...
Installed 0 object(s) from 0 fixture(s)
```

# python manage.py syncdb --noinput
```
[root@master graphite]# pwd
/opt/graphite/webapp/graphite
[root@master graphite]# python manage.py syncdb --noinput
/opt/graphite/webapp/graphite/settings.py:246: UserWarning: SECRET_KEY is set to an unsafe default. This should be set in local_settings.py for better security
  warn('SECRET_KEY is set to an unsafe default. This should be set in local_settings.py for better security')
Creating tables ...
Installing custom SQL ...
Installing indexes ...
Installed 0 object(s) from 0 fixture(s)
```

# init django admin
```
$ cd /opt/graphite/webapp/graphite
$ sudo python manage.py createsuperuser
```

启动 statsd
https://github.com/etsy/statsd
```
node /opt/statsd/stats.js /opt/statsd/config.js 2>&1 >> /var/log/statsd.log
```

启动
```
supervisord -c /etc/supervisord.d/supervisord.conf
```

http://www.cnblogs.com/jasonkoo/articles/3750638.html

【启动supervisord】

确保配置无误后可以在每台主机上使用下面的命令启动supervisor的服务器端supervisord

supervisord
【停止supervisord】     

supervisorctl shutdown
【重新加载配置文件】

supervisorctl reload
 

【进程管理】

1. 启动supervisord管理的所有进程

supervisorctl start all
2. 停止supervisord管理的所有进程

supervisorctl stop all
3. 启动supervisord管理的某一个特定进程

supervisorctl start program-name // program-name为[program:xx]中的xx
4.  停止supervisord管理的某一个特定进程 

supervisorctl stop program-name  // program-name为[program:xx]中的xx
5.  重启所有进程或所有进程

supervisorctl restart all  // 重启所有
supervisorctl reatart program-name // 重启某一进程，program-name为[program:xx]中的xx
6. 查看supervisord当前管理的所有进程的状态

supervisorctl status




pip install twisted==13.1.0