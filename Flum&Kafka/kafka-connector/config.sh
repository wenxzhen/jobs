curl -X PUT -i  -H "Content-Type: application/json" -H "Accept: application/json" \
    --data @config.json \
    http://node05.csdn.net:8083/connectors/jdbc-souce-connector-demo/config