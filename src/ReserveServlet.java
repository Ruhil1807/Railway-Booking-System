import util.DBConnection;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

public class ReserveServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        
        if (username == null) {
            response.sendRedirect("login.jsp?redirect=reserve.jsp");
            return;
        }

        // Debug: Print all parameters
        System.out.println("=== DEBUGGING PARAMETERS ===");
        java.util.Enumeration<String> params = request.getParameterNames();
        while (params.hasMoreElements()) {
            String param = params.nextElement();
            System.out.println(param + " = " + request.getParameter(param));
        }
        System.out.println("=== END DEBUGGING ===");

        try {
            // Get basic parameters
            String trainName = request.getParameter("trainName");
            String origin = request.getParameter("origin");
            String destination = request.getParameter("destination");
            String fareParam = request.getParameter("fare");
            String travelDate = request.getParameter("travelDate");
            
            // Get trip type and return date
            String tripType = request.getParameter("tripType");
            if (tripType == null || tripType.trim().isEmpty()) {
                tripType = "ONE_WAY"; // Default
            }
            String returnDate = request.getParameter("returnDate");
            
            // Check if required parameters are missing
            if (trainName == null || origin == null || destination == null || 
                fareParam == null || travelDate == null) {
                
                System.out.println("Missing parameters detected!");
                response.sendRedirect("reserve.jsp?error=Missing required train details");
                return;
            }
            
            // For round trips, validate return date
            if ("ROUND_TRIP".equals(tripType)) {
                if (returnDate == null || returnDate.trim().isEmpty()) {
                    response.sendRedirect("reserve.jsp?error=Return date required for round trips");
                    return;
                }
            }
            
            // Get passenger counts (default to 0 if not provided)
            int adults = getIntParameter(request, "adults", 1); // Default 1 adult
            int children = getIntParameter(request, "children", 0);
            int seniors = getIntParameter(request, "seniors", 0);
            int disabled = getIntParameter(request, "disabled", 0);
            
            // Validate at least one passenger
            if (adults + children + seniors + disabled == 0) {
                response.sendRedirect("reserve.jsp?error=At least one passenger required");
                return;
            }
            
            // Parse fare
            double baseFare = Double.parseDouble(fareParam);
            
            // Calculate total fare
            double totalFare = (adults * baseFare) + 
                              (children * baseFare * 0.5) + 
                              (seniors * baseFare * 0.6) + 
                              (disabled * baseFare * 0.25);
            
            // Format passenger string
            String passengerStr = String.format("Adults: %d, Children: %d, Seniors: %d, Disabled: %d", 
                                               adults, children, seniors, disabled);
            
            // Database operations with transaction
            try (Connection con = DBConnection.getConnection()) {
                con.setAutoCommit(false);
                
                try {
                    // Insert OUTBOUND journey (using shorter codes)
                    boolean outboundSuccess = insertJourney(con, username, travelDate, passengerStr, 
                                                          totalFare, trainName, tripType, "OUT");
                    
                    boolean inboundSuccess = true;
                    // If round trip, insert INBOUND journey
                    if ("ROUND_TRIP".equals(tripType)) {
                        inboundSuccess = insertJourney(con, username, returnDate, passengerStr, 
                                                     totalFare, trainName, tripType, "IN");
                    }
                    
                    if (outboundSuccess && inboundSuccess) {
                        con.commit();
                        String message = "ROUND_TRIP".equals(tripType) ? 
                                       "Round trip reservation successful!" : 
                                       "One way reservation successful!";
                        response.sendRedirect("welcome.jsp?message=" + message + "&type=success");
                    } else {
                        con.rollback();
                        response.sendRedirect("reserve.jsp?error=Failed to create reservation");
                    }
                    
                } catch (SQLException e) {
                    con.rollback();
                    throw e;
                } finally {
                    con.setAutoCommit(true);
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("reserve.jsp?error=Error: " + e.getMessage());
        }
    }
    
    // Helper method to safely parse integer parameters
    private int getIntParameter(HttpServletRequest request, String paramName, int defaultValue) {
        String param = request.getParameter(paramName);
        if (param == null || param.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(param.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
    
    /**
     * Inserts a journey record into the database
     */
    private boolean insertJourney(Connection con, String username, String date, String passengers, 
                                 double fare, String trainName, String tripType, String journeyType) 
                                 throws SQLException {
        
        String sql = "INSERT INTO reservation_data (Username, Date, Passenger, Total_Fare, Transit_line_name, " +
                    "status, trip_type, journey_type) VALUES (?, ?, ?, ?, ?, 'ACTIVE', ?, ?)";
        
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setDate(2, java.sql.Date.valueOf(date));
            ps.setString(3, passengers);
            ps.setDouble(4, fare);
            ps.setString(5, trainName);
            ps.setString(6, tripType);
            ps.setString(7, journeyType);
            
            return ps.executeUpdate() > 0;
        }
    }
}