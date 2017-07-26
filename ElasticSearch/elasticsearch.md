# Cluster Info

```
export ES_HOST=localhost
集群健康
# curl -G $ES_HOST:9200/_cluster/health?pretty=true
集群状态
# curl -G $ES_HOST:9200/_cluster/state?pretty=true
集群统计
# curl -G $ES_HOST:9200/_cluster/stats?pretty=true
集群任务管理
# curl -G $ES_HOST:9200/_tasks?pretty=true

curl -G $ES_HOST:9200/_cat/nodes?v
curl -G $ES_HOST:9200/_cat/health?v

curl -G $ES_HOST:9200/_nodes?pretty=true

```

# 索引信息
```
https://github.com/elastic/elasticsearch/blob/master/docs/src/test/resources/accounts.json?raw=true

# curl -XPOST 'localhost:9200/bank/account/_bulk?pretty&refresh' --data-binary "@accounts.json"
# curl 'localhost:9200/_cat/indices?v

索引列表
# curl -G  $ES_HOST:9200/_cat/indices?v

查看bank索引
# curl -G  $ES_HOST:9200/bank?pretty
查询索引为bank,type为account,ID 为 1的文档
# curl -G  $ES_HOST:9200/bank/account/1?pretty
{
  "_index" : "bank",
  "_type" : "account",
  "_id" : "1",
  "_version" : 1,
  "found" : true,
  "_source" : {
    "account_number" : 1,
    "balance" : 39225,
    "firstname" : "Amber",
    "lastname" : "Duke",
    "age" : 32,
    "gender" : "M",
    "address" : "880 Holmes Lane",
    "employer" : "Pyrami",
    "email" : "amberduke@pyrami.com",
    "city" : "Brogan",
    "state" : "IL"
}

# curl -G  $ES_HOST:9200/bank/account/1/_source?pretty
{
  "account_number" : 1,
  "balance" : 39225,
  "firstname" : "Amber",
  "lastname" : "Duke",
  "age" : 32,
  "gender" : "M",
  "address" : "880 Holmes Lane",
  "employer" : "Pyrami",
  "email" : "amberduke@pyrami.com",
  "city" : "Brogan",
  "state" : "IL"
}


```