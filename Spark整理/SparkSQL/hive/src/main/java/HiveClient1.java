import java.sql.*;
import java.util.Date;

public class HiveClient1 {
    public static void main(String[] args) throws Exception {
        searchJob(args[0], args[1], args[2]);
    }

    private static void searchJob(String url, String user, String pass) throws ClassNotFoundException, SQLException {
        Class.forName("org.apache.hive.jdbc.HiveDriver");
        Connection con = DriverManager.getConnection(url, user, pass);
        Statement stmt = con.createStatement();
        System.out.print(stmt.execute("show databases"));
        stmt.close();
        con.close();
    }
}
