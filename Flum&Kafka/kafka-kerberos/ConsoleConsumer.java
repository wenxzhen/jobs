import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;

import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;

/**
 * Created by yangxy on 2017/7/20.
 */
public class ConsoleConsumer {


    public static void main(String[] args) throws Exception {

        if (args == null || args.length < 1) {
            System.out.println("ConsoleConsumerDemo Usage: [topic]");
            System.exit(0);
        }

        Properties props = initConfig();
        KafkaConsumer<String, String> consumer = new KafkaConsumer<String, String>(props);
        String topic = args[0];
        consumer.subscribe(Arrays.asList(topic));
        int commitInterval = 20;
        List<ConsumerRecord<String, String>> buffer = new ArrayList<ConsumerRecord<String, String>>();
        while (true) {
            ConsumerRecords<String, String> records = consumer.poll(10);

            for (ConsumerRecord<String, String> record : records) {
                buffer.add(record);
                if (buffer.size() >= commitInterval) {
                    for (ConsumerRecord<String, String> rcd : buffer) {
                        System.out.println(rcd.topic() + "\t" + rcd.partition() + "\t" + rcd.offset() + "\t" + rcd.key() + "\t" + rcd.value());
                    }
                    consumer.commitSync();
                    buffer.clear();
                }
            }

        }
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

