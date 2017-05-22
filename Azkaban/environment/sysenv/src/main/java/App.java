import java.util.Map;

/**
 * Created by meng on 2016/10/14.
 */
public class App {

    public static void main(String[] args) {
        Map<String, String> envs = System.getenv();


        for (Map.Entry<String,String> k : envs.entrySet()) {

            System.out.println(k.getKey() + "\t" + k.getValue());

        }


    }
}
