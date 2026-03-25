import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.DBConnection;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.HashSet;
import java.util.Set;

@WebServlet("/stationData")
public class StationDataServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        Set<String> origins = new HashSet<>();
        Set<String> destinations = new HashSet<>();

        String sql = "SELECT DISTINCT Origin, Destination FROM train_project.train_schedule_data";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                origins.add(rs.getString("Origin"));
                destinations.add(rs.getString("Destination"));
            }

            // JSON format manually built
            StringBuilder json = new StringBuilder("{");
            json.append("\"origins\":[");
            int i = 0;
            for (String origin : origins) {
                json.append("\"").append(origin).append("\"");
                if (++i < origins.size()) json.append(",");
            }
            json.append("],");

            json.append("\"destinations\":[");
            int j = 0;
            for (String dest : destinations) {
                json.append("\"").append(dest).append("\"");
                if (++j < destinations.size()) json.append(",");
            }
            json.append("]}");

            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Failed to fetch data.\"}");
        }
    }
}
