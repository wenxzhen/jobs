import java.sql.*;
import java.util.Date;

public class HiveClient {
	public static void main(String[] args) throws Exception {


//		String querySQL = "select dt,expid(curl,'pid9.properties') as pid,ip from file_pv_track where pdate='2016-01-23' limit 10 ";
		String querySQL = "select count(id) from users";
		run(querySQL);


	}

	public static void run(final String querySQL) throws InterruptedException {

		Thread thread = new Thread(new Runnable() {
			public void run() {
				try {
					searchJob(querySQL);
				} catch (ClassNotFoundException e) {
					e.printStackTrace();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		});
		thread.start();
		System.out.println(new Date());
		System.out.println("start job...........");
		thread.join();
		System.out.println(new Date());
	}

	private static void searchJob(String querySQL) throws ClassNotFoundException, SQLException {
		Class.forName("org.apache.hive.jdbc.HiveDriver");
//		Connection con = DriverManager.getConnection("jdbc:hive2://192.168.6.80:10000/default", "hadoop", "");
		Connection con = DriverManager.getConnection("jdbc:hive2://mysql.csdn.net:10000/default", "hadoop", "");
		Statement stmt = con.createStatement();

//		System.out.println(stmt.execute("add jar /data/bigData/spark-1.6.0-bin-cdh4/lib/guava-11.0.2.jar"));
//		System.out.println(stmt.execute("add jar /data/bigData/spark-1.6.0-bin-cdh4/lib/ezmorph-1.0.4.jar"));
//		System.out.println(stmt.execute("add jar /data/bigData/spark-1.6.0-bin-cdh4/lib/commons-beanutils-1.7.0.jar"));
//		System.out.println(stmt.execute("add jar /data/bigData/spark-1.6.0-bin-cdh4/lib/json-lib-2.2.2-jdk15.jar"));
//		System.out.println(stmt.execute("add jar /data/bigData/spark-1.6.0-bin-cdh4/lib/logpig.jar"));
//		System.out.println(stmt.execute("add jar /data/bigData/spark-1.6.0-bin-cdh4/lib/hive_udf.jar"));
//		System.out.println(stmt.execute("CREATE TEMPORARY FUNCTION expid AS 'net.csdn.hive.cf2.ExtractProduct2' "));

		ResultSet res = stmt.executeQuery(querySQL);

		ResultSetMetaData mt = res.getMetaData();
		int cCount = mt.getColumnCount();

		for(int i =1;i<= cCount;i++){
			System.out.print(mt.getColumnName(i) + "\t");
		}
		System.out.println();

		while (res.next()) {
			for(int i =1;i<= cCount;i++){
				System.out.print(res.getObject(i) + "\t");
			}
			System.out.println();
		}
		res.close();
		stmt.close();
		con.close();
	}
}
