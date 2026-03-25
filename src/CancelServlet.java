import util.DBConnection;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;

public class CancelServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");

        if (username == null) {
            response.sendRedirect("login.jsp?redirect=cancel.jsp");
            return;
        }

        String reservationIdStr = request.getParameter("reservationId");
        
        if (reservationIdStr == null || reservationIdStr.trim().isEmpty()) {
            response.sendRedirect("cancel.jsp?message=Invalid reservation ID&type=warning");
            return;
        }

        Connection conn = null;
        PreparedStatement checkStmt = null;
        PreparedStatement updateStmt = null;
        ResultSet rs = null;

        try {
            int reservationId = Integer.parseInt(reservationIdStr);
            conn = DBConnection.getConnection();

            // First, verify the reservation belongs to this user and is eligible for cancellation
            String checkQuery = "SELECT Reservation_Number, Username, Date, COALESCE(status, 'ACTIVE') as status " +
                               "FROM reservation_data " +
                               "WHERE Reservation_Number = ? AND Username = ?";
            
            checkStmt = conn.prepareStatement(checkQuery);
            checkStmt.setInt(1, reservationId);
            checkStmt.setString(2, username);
            rs = checkStmt.executeQuery();

            if (!rs.next()) {
                // Reservation not found or doesn't belong to this user
                response.sendRedirect("cancel.jsp?message=Reservation not found or access denied&type=warning");
                return;
            }

            String currentStatus = rs.getString("status");
            Date travelDate = rs.getDate("Date");
            Date today = Date.valueOf(LocalDate.now());

            // Check if reservation is already cancelled
            if ("CANCELLED".equals(currentStatus)) {
                response.sendRedirect("cancel.jsp?message=This reservation is already cancelled&type=warning");
                return;
            }

            // Check if travel date is in the past
            if (travelDate.before(today)) {
                response.sendRedirect("cancel.jsp?message=Cannot cancel past reservations&type=warning");
                return;
            }

            // Check if travel date is today (optional business rule - some systems don't allow same-day cancellation)
            if (travelDate.equals(today)) {
                response.sendRedirect("cancel.jsp?message=Cannot cancel reservations on the day of travel&type=warning");
                return;
            }

            rs.close();
            checkStmt.close();

            // Update the reservation status to CANCELLED
            String updateQuery = "UPDATE reservation_data SET status = 'CANCELLED' WHERE Reservation_Number = ?";
            updateStmt = conn.prepareStatement(updateQuery);
            updateStmt.setInt(1, reservationId);
            
            int rowsUpdated = updateStmt.executeUpdate();

            if (rowsUpdated > 0) {
                // Successfully cancelled
                response.sendRedirect("cancel.jsp?message=Reservation #" + reservationId + " has been successfully cancelled&type=success");
            } else {
                // Unexpected error
                response.sendRedirect("cancel.jsp?message=Failed to cancel reservation. Please try again&type=warning");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("cancel.jsp?message=Invalid reservation ID format&type=warning");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("cancel.jsp?message=Database error occurred. Please try again later&type=warning");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("cancel.jsp?message=An unexpected error occurred. Please try again&type=warning");
        } finally {
            // Clean up resources
            try {
                if (rs != null) rs.close();
                if (checkStmt != null) checkStmt.close();
                if (updateStmt != null) updateStmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // Handle GET requests by redirecting to the cancel page
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        response.sendRedirect("cancel.jsp");
    }
}