# Install Docker
```
$ sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

$ sudo yum install docker-engine

$ sudo systemctl enable docker.service

$ sudo systemctl start docker
```

# Add firewall
```
firewall-cmd --permanent --add-port={2377/tcp,7946/udp,4789/udp}
firewall-cmd --reload
```

# Init Swarm
```
docker swarm init --advertise-addr <MANAGER-IP>

[root@manager01 ~]# docker swarm init --advertise-addr 192.168.88.136
Swarm initialized: current node (04kopint8acp7o8nkpmognpyp) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-3n4q9ilj5edlhxcl99wcda5z0swb4m84836ddn98ef1fes8zpd-4xemoglrpy0euml1xk3pd9ysq \
    192.168.88.136:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

[root@manager01 ~]# docker swarm join-token worker
To add a worker to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-3n4q9ilj5edlhxcl99wcda5z0swb4m84836ddn98ef1fes8zpd-4xemoglrpy0euml1xk3pd9ysq \
    192.168.88.136:2377

[root@localhost docker01]#     docker swarm join \
>     --token SWMTKN-1-3n4q9ilj5edlhxcl99wcda5z0swb4m84836ddn98ef1fes8zpd-4xemoglrpy0euml1xk3pd9ysq \
>     192.168.88.136:2377
This node joined a swarm as a worker.

[root@localhost docker02]#     docker swarm join \
>     --token SWMTKN-1-3n4q9ilj5edlhxcl99wcda5z0swb4m84836ddn98ef1fes8zpd-4xemoglrpy0euml1xk3pd9ysq \
>     192.168.88.136:2377
This node joined a swarm as a worker.


```
# Attach services to an overlay network
```
[root@manager01 ~]# docker network create \
  --driver overlay \
  --subnet 10.0.9.0/24 \
  --opt encrypted \
  multi-host-network

273d53261bcdfda5f198587974dae3827e947ccd7e74a41bf1f482ad17fa0d33

[root@manager01 ~]# docker service create \
  --replicas 3 \
  --name my-web \
  --network multi-host-network \
  nginx
```

