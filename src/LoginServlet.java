import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String expectedRole = request.getParameter("expectedRole");

        String redirect = request.getParameter("redirect");
        String scheduleId = request.getParameter("scheduleId");

        HttpSession session = request.getSession();

        Connection con = null;
        PreparedStatement psCustomer = null;
        PreparedStatement psEmployee = null;
        ResultSet rsCustomer = null;
        ResultSet rsEmployee = null;

        try {
            con = DBConnection.getConnection();

            // ✅ Check customer login
            psCustomer = con.prepareStatement(
                "SELECT * FROM customer_data WHERE Username=? AND Password=?"
            );
            psCustomer.setString(1, username);
            psCustomer.setString(2, password);
            rsCustomer = psCustomer.executeQuery();

            if (rsCustomer.next()) {
                if (!"customer".equalsIgnoreCase(expectedRole)) {
                    request.setAttribute("loginError", "Customers must log in from the Customer login page.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }

                session.setAttribute("username", username);
                session.setAttribute("role", "customer");

                // ✅ Redirect back to reservation page if needed
                if ("reserve".equalsIgnoreCase(redirect) && scheduleId != null && !scheduleId.isEmpty()) {
                    response.sendRedirect("reserve.jsp?scheduleId=" + scheduleId);
                } else {
                    response.sendRedirect("welcome.jsp");
                }
                return;
            }

            // ✅ Check employee (admin or rep)
            psEmployee = con.prepareStatement(
                "SELECT * FROM employee_data WHERE Username=? AND Password=?"
            );
            psEmployee.setString(1, username);
            psEmployee.setString(2, password);
            rsEmployee = psEmployee.executeQuery();

            if (rsEmployee.next()) {
                String role = rsEmployee.getString("Role");
                String firstName = rsEmployee.getString("First_Name");
                String lastName = rsEmployee.getString("Last_Name");

                if (!role.equalsIgnoreCase(expectedRole)) {
                    String errorMsg = role.substring(0, 1).toUpperCase() + role.substring(1) +
                                      "s must log in from the " + role + " login page.";

                    request.setAttribute("loginError", errorMsg);

                    if ("admin".equalsIgnoreCase(expectedRole)) {
                        request.getRequestDispatcher("admin-login.jsp").forward(request, response);
                    } else if ("rep".equalsIgnoreCase(expectedRole)) {
                        request.getRequestDispatcher("rep-login.jsp").forward(request, response);
                    } else {
                        request.getRequestDispatcher("login.jsp").forward(request, response);
                    }
                    return;
                }

                session.setAttribute("username", username);
                session.setAttribute("role", role);
                session.setAttribute("firstName", firstName);
                session.setAttribute("lastName", lastName);

                if ("admin".equalsIgnoreCase(role)) {
                    response.sendRedirect("admin.jsp");
                } else if ("rep".equalsIgnoreCase(role)) {
                    response.sendRedirect("rep-dashboard.jsp");
                } else {
                    request.setAttribute("loginError", "Unrecognized role.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
                return;
            }

            // ❌ No match found
            request.setAttribute("loginError", "Invalid username or password.");
            if ("admin".equalsIgnoreCase(expectedRole)) {
                request.getRequestDispatcher("admin-login.jsp").forward(request, response);
            } else if ("rep".equalsIgnoreCase(expectedRole)) {
                request.getRequestDispatcher("rep-login.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("loginError", "An internal error occurred.");
            request.getRequestDispatcher("login.jsp").forward(request, response);

        } finally {
            try { if (rsCustomer != null) rsCustomer.close(); } catch (Exception ignored) {}
            try { if (psCustomer != null) psCustomer.close(); } catch (Exception ignored) {}
            try { if (rsEmployee != null) rsEmployee.close(); } catch (Exception ignored) {}
            try { if (psEmployee != null) psEmployee.close(); } catch (Exception ignored) {}
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}
