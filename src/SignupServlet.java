import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;
import util.DBConnection;

public class SignupServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");

        try {
            Connection con = DBConnection.getConnection();

            // Check for existing username/email
            PreparedStatement check = con.prepareStatement(
                "SELECT Username, Email FROM customer_data WHERE Username = ? OR Email = ?"
            );
            check.setString(1, username);
            check.setString(2, email);
            ResultSet rs = check.executeQuery();

            boolean usernameExists = false;
            boolean emailExists = false;

            while (rs.next()) {
                if (username.equals(rs.getString("Username"))) {
                    usernameExists = true;
                }
                if (email.equals(rs.getString("Email"))) {
                    emailExists = true;
                }
            }

            if (usernameExists && emailExists) {
                response.sendRedirect("signup.jsp?status=exists_both");
            } else if (usernameExists) {
                response.sendRedirect("signup.jsp?status=exists_username");
            } else if (emailExists) {
                response.sendRedirect("signup.jsp?status=exists_email");
            } else {
                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO customer_data (Username, Password, First_Name, Last_Name, Email) VALUES (?, ?, ?, ?, ?)"
                );
                ps.setString(1, username);
                ps.setString(2, password);
                ps.setString(3, firstName);
                ps.setString(4, lastName);
                ps.setString(5, email);

                int rows = ps.executeUpdate();
                if (rows > 0) {
                    response.sendRedirect("signup.jsp?status=success");
                } else {
                    response.sendRedirect("signup.jsp?status=error");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("signup.jsp?status=error");
        }
    }
}
