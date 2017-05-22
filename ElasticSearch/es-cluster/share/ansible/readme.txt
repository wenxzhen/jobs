ansible-playbook -i hosts install.yml --become-user=root --become-method=su -b --ask-su-pass


ansible -i hosts all -m shell -a "nohup /opt/elasticsearch-5.2.1/bin/elasticsearch &"

ansible -i hosts all -m shell -a "/sbin/sysctl -w vm.max_map_count=262144" --become-user=root --become-method=su -b --ask-su-pass


You probably need to set vm.max_map_count in /etc/sysctl.conf on the host itself, so that Elasticsearch does not attempt to do that from inside the container.
If you don't know the desired value, try doubling the current setting and keep going until Elasticsearch starts successfully. Documentation recommends at least 262144.
https://www.elastic.co/guide/en/elasticsearch/reference/5.1/docker.html#docker-cli-run-prod-mode