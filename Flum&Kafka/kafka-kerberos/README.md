1、准备pricaple 及其 keytab文件

2、JAAS配置文件 kafka-client.jaas
```
KafkaClient {
    com.sun.security.auth.module.Krb5LoginModule required
    useKeyTab=true
    storeKey=true
    keyTab="/etc/security/keytab/kylin.service.keytab"
    principal="kylin@DATASERVICE.NET";
};
```

3、在 producer 或 consumer 中配置以下属性

```
security.protocol=SASL_PLAINTEXT (or SASL_SSL)
sasl.mechanism=GSSAPI
sasl.kerberos.service.name=kafka
```

4、
```
JAVA_OPTS=-Djava.security.auth.login.config=/path/kafka-client.jaas
java $JAVA_OPTS -cp $CLASSPATH DemoProducer $1
```