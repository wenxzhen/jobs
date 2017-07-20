import org.apache.kafka.clients.producer.*;

import java.io.FileInputStream;
import java.util.Date;
import java.util.Properties;
import java.util.Random;

/**
 * Created by yangxy on 2017/7/20.
 */
public class DemoProducer {

    public static void main(String[] args) throws Exception {

        if (args == null || args.length < 1) {
            System.out.println("DemoProducer Usage: [topic]");
            System.exit(0);
        }
        String topic = args[0];
        Properties props = initConfig();
        Producer producer = new KafkaProducer(props);
        Random rnd = new Random(5);

        for (long nEvents = 0; nEvents < 5000000; nEvents++) {
            long runtime = new Date().getTime();
            String ip = "192.168.2." + rnd.nextInt(255);
            String msg = runtime + ",www.example.com/" + nEvents;
            ProducerRecord record = new ProducerRecord(topic, ip, msg);
            producer.send(record, new Callback() {
                @Override
                public void onCompletion(RecordMetadata metadata, Exception exception) {
                    System.out.println(metadata.timestamp() + "\t" + metadata.partition() + "\t" + metadata.offset());
                }
            });
            System.out.println(record);
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        producer.close();
    }

    private static Properties initConfig() throws Exception {
        String config = System.getenv("KAFKA_CLIENT_CONF");
        if (config == null || "".equals(config.trim())) {
            throw new Exception("KAFKA_CLIENT_CONF is not set !!!");
        }
        Properties prop = new Properties();
        prop.load(new FileInputStream(config));
        return prop;
    }
}
