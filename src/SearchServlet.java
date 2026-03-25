import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import model.TrainSchedule;
import util.DBConnection;

public class SearchServlet extends HttpServlet {

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        String origin = request.getParameter("origin");
        String destination = request.getParameter("destination");
        String travelDate = request.getParameter("travelDate");
        String sortBy = request.getParameter("sortBy");

        System.out.println("=== Search Request Received ===");
        System.out.println("Origin: " + origin);
        System.out.println("Destination: " + destination);
        System.out.println("Travel Date: " + travelDate);
        System.out.println("Sort By: " + sortBy);

        String sortClause = "";
        if ("fare".equalsIgnoreCase(sortBy)) sortClause = " ORDER BY Fare";
        else if ("arrival".equalsIgnoreCase(sortBy)) sortClause = " ORDER BY Arrival_datetime";
        else if ("departure".equalsIgnoreCase(sortBy)) sortClause = " ORDER BY Departure_datetime";

        ArrayList<TrainSchedule> results = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT * FROM train_schedule_data WHERE Origin = ? AND Destination = ? AND DATE(Departure_datetime) = ?" + sortClause;
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, origin);
            ps.setString(2, destination);
            ps.setString(3, travelDate);

            System.out.println("Executing SQL: " + ps);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                TrainSchedule ts = new TrainSchedule();
                // ts.setScheduleId(rs.getInt("Schedule_id"));
                ts.setTrainName(rs.getString("Transit_line_name"));
                ts.setFare(rs.getDouble("Fare"));
                ts.setOrigin(rs.getString("Origin"));
                ts.setDestination(rs.getString("Destination"));
                ts.setStops(rs.getString("Stops"));
                ts.setDepartureTime(rs.getTimestamp("Departure_datetime").toString());
                ts.setArrivalTime(rs.getTimestamp("Arrival_datetime").toString());
                ts.setTravelDate(travelDate);

                results.add(ts);
            }

            System.out.println("Results found: " + results.size());

            request.setAttribute("results", results);
            RequestDispatcher rd = request.getRequestDispatcher("search-result.jsp");
            rd.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error retrieving schedules.");
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        processRequest(request, response);
    }
}
