https://github.com/hortonworks-spark/shc


# Submit
```
spark-submit --verbose \
--class org.apache.spark.sql.execution.datasources.hbase.CSDNHBaseSource \
--master yarn \
--jars file:///home/hadoop/shc/shc-core-1.1.0-2.1-s_2.11.jar \
--files file:///data/bigdata/hbase/conf/hbase-site.xml \
file:///home/hadoop/shc/shc-examples-1.1.0-2.1-s_2.11.jar
```


# CSDNHBaseSource

```
package org.apache.spark.sql.execution.datasources.hbase

import org.apache.spark.sql.{DataFrame, SparkSession}

object CSDNHBaseSource {
  val cat = s"""{
            |"table":{"namespace":"default", "name":"HexStringSplitTb", "tableCoder":"PrimitiveType"},
            |"rowkey":"key",
            |"columns":{
              |"id":{"cf":"rowkey", "col":"key", "type":"string"},
              |"value":{"cf":"f1", "col":"value", "type":"int"}
            |}
          |}""".stripMargin

  def main(args: Array[String]) {
    val spark = SparkSession.builder()
      .appName("CSDNHBaseSourceExample")
      .getOrCreate()

    val sc = spark.sparkContext
    val sqlContext = spark.sqlContext

    import sqlContext.implicits._

    def withCatalog(cat: String): DataFrame = {
      sqlContext
        .read
        .options(Map(HBaseTableCatalog.tableCatalog->cat))
        .format("org.apache.spark.sql.execution.datasources.hbase")
        .load()
    }

    val df = withCatalog(cat)
    val rpdf = df.repartition(81)
    rpdf.createTempView("HexStringSplitTb")

    //spark.sql("select * from HexStringSplitTb limit 10").show()

    spark.sql("select count(*) from HexStringSplitTb").show()

    spark.stop()
  }
}
```