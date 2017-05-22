# Parquet  Partition Discovery


scala> `spark.read.parquet("/tmp/resources/people/gender=male/country=CN/data.parquet").show()`
```
+-------+---+
|   name|age|
+-------+---+
|Michael| 29|
|   Andy| 30|
| Justin| 19|
+-------+---+
```

scala> `spark.read.parquet("/tmp/resources/people").show()`
```
+-------+---+------+-------+
|   name|age|gender|country|
+-------+---+------+-------+
|Michael| 29|  male|     CN|
|   Andy| 30|  male|     CN|
| Justin| 19|  male|     CN|
+-------+---+------+-------+
```
