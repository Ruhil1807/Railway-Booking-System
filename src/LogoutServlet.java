import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;


public class LogoutServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
        request.getSession().invalidate();
        response.sendRedirect("login.jsp");
    }
}