package hive.metastore;

import org.apache.hadoop.hive.conf.HiveConf;
import org.apache.hadoop.hive.metastore.*;
import org.apache.hadoop.hive.metastore.api.MetaException;
import org.apache.hadoop.hive.metastore.api.Table;
import org.apache.hadoop.hive.ql.metadata.HiveException;
import org.apache.hadoop.hive.ql.metadata.HiveStorageHandler;
import org.apache.hadoop.hive.ql.metadata.HiveUtils;
import org.apache.hadoop.util.StringUtils;

import java.util.List;

import static org.apache.hadoop.hive.metastore.HiveMetaStore.HMSHandler.LOG;
import static org.apache.hadoop.hive.metastore.api.hive_metastoreConstants.META_TABLE_STORAGE;

/**
 * Created by yangxy on 2016/6/30.
 */
public class HiveMetaStoreClientTest {

    private static IMetaStoreClient getClient() throws MetaException {
        final HiveConf conf = new HiveConf();
        conf.addResource("hive-site.xml");
        IMetaStoreClient client = new HiveMetaStoreClient(conf);
        return client;
    }

    public static void main(String[] args) throws InterruptedException {

        System.setProperty("hadoop.home.dir", "D:\\0\\hadoop-2.6.4");
        IMetaStoreClient client = null;
        try {

            client = getClient();
            for (int i = 0; i < 1000; i++) {
                Thread.sleep(1000);
                System.out.println("================================================");
                try {
                    List<String> list = client.getTables("default", "user*");
                    client.reconnect();
                    for (String name : list) {
                        System.out.println(name);
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }

            }

            client.close();
        } catch (MetaException e) {
            e.printStackTrace();
        }


    }
}
//            client = RetryingMetaStoreClient.getProxy(conf, new HiveMetaHookLoader() {
//                public HiveMetaHook getHook(Table tbl) throws MetaException {
//                    try {
//                        if (tbl == null) {
//                            return null;
//                        }
//                        HiveStorageHandler storageHandler =
//                                HiveUtils.getStorageHandler(conf,
//                                        tbl.getParameters().get(META_TABLE_STORAGE));
//                        if (storageHandler == null) {
//                            return null;
//                        }
//                        return storageHandler.getMetaHook();
//                    } catch (HiveException ex) {
//                        LOG.error(StringUtils.stringifyException(ex));
//                        throw new MetaException(
//                                "Failed to load storage handler:  " + ex.getMessage());
//                    }
//                }
//            }, HiveMetaStoreClient.class.getName());