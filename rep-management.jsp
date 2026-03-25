<%@ page import="java.sql.*, java.io.PrintWriter" %>
<%@ page import="util.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>

<%
    String user = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    
    if (user == null || !"admin".equals(role)) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    String action = request.getParameter("action");
    String message = "";
    String messageType = "";

    // Handle form submissions
    if ("POST".equals(request.getMethod())) {
        if ("add".equals(action)) {
            // Add new rep - FIXED to use SSN as primary key
            String ssn = request.getParameter("ssn");
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            
            try {
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO employee_data (SSN, First_Name, Last_Name, Username, Password, Role) VALUES (?, ?, ?, ?, ?, 'rep')"
                );
                ps.setString(1, ssn);
                ps.setString(2, firstName);
                ps.setString(3, lastName);
                ps.setString(4, username);
                ps.setString(5, password);
                
                int result = ps.executeUpdate();
                if (result > 0) {
                    message = "Customer representative added successfully!";
                    messageType = "success";
                } else {
                    message = "Failed to add representative.";
                    messageType = "error";
                }
                ps.close();
                con.close();
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                messageType = "error";
            }
        } else if ("edit".equals(action)) {
            // Edit existing rep - FIXED to use SSN
            String ssn = request.getParameter("ssn");
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String username = request.getParameter("username");
            
            try {
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(
                    "UPDATE employee_data SET First_Name=?, Last_Name=?, Username=? WHERE SSN=? AND Role='rep'"
                );
                ps.setString(1, firstName);
                ps.setString(2, lastName);
                ps.setString(3, username);
                ps.setString(4, ssn);
                
                int result = ps.executeUpdate();
                if (result > 0) {
                    message = "Representative updated successfully!";
                    messageType = "success";
                } else {
                    message = "Failed to update representative.";
                    messageType = "error";
                }
                ps.close();
                con.close();
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                messageType = "error";
            }
        } else if ("delete".equals(action)) {
            // Delete rep - FIXED to use SSN
            String ssn = request.getParameter("ssn");
            
            try {
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement("DELETE FROM employee_data WHERE SSN=? AND Role='rep'");
                ps.setString(1, ssn);
                
                int result = ps.executeUpdate();
                if (result > 0) {
                    message = "Representative deleted successfully!";
                    messageType = "success";
                } else {
                    message = "Failed to delete representative.";
                    messageType = "error";
                }
                ps.close();
                con.close();
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                messageType = "error";
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rep Management - IRCTC Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 50%, #f1f5f9 100%);
            min-height: 100vh;
            color: #334155;
        }

        .navbar {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(226, 232, 240, 0.8);
            padding: 1rem 0;
            position: sticky;
            top: 0;
            z-index: 1000;
        }

        .navbar-content {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .navbar-brand {
            display: flex;
            align-items: center;
            color: #1e293b;
            font-weight: 800;
            font-size: 1.5rem;
            text-decoration: none;
        }

        .navbar-brand i {
            font-size: 2rem;
            margin-right: 12px;
            background: linear-gradient(135deg, #64748b, #94a3b8);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .back-btn {
            background: #64748b;
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }

        .back-btn:hover {
            background: #475569;
            transform: translateY(-2px);
            color: white;
            text-decoration: none;
        }

        .main-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 40px 2rem;
        }

        .page-header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 32px;
            margin-bottom: 32px;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .page-title {
            font-size: 2.5rem;
            font-weight: 800;
            background: linear-gradient(135deg, #1e293b, #64748b);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 8px;
        }

        .page-subtitle {
            color: #64748b;
            font-size: 1.1rem;
            font-weight: 500;
        }

        .alert {
            padding: 16px 20px;
            border-radius: 12px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-weight: 600;
        }

        .alert.success {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }

        .alert.error {
            background: #fef2f2;
            color: #dc2626;
            border: 1px solid #fecaca;
        }

        .content-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 32px;
            margin-bottom: 32px;
        }

        .card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 32px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.1);
        }

        .card-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            font-weight: 600;
            color: #374151;
            margin-bottom: 8px;
        }

        .form-input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        .form-input:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }

        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }

        .btn-primary {
            background: linear-gradient(135deg, #3b82f6, #1d4ed8);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(59, 130, 246, 0.3);
        }

        .btn-secondary {
            background: #6b7280;
            color: white;
        }

        .btn-secondary:hover {
            background: #4b5563;
            transform: translateY(-2px);
        }

        .btn-danger {
            background: linear-gradient(135deg, #dc2626, #ef4444);
            color: white;
        }

        .btn-danger:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(220, 38, 38, 0.3);
        }

        .reps-table {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 32px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.1);
        }

        .table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .table th,
        .table td {
            padding: 16px;
            text-align: left;
            border-bottom: 1px solid #e5e7eb;
        }

        .table th {
            background: #f8fafc;
            font-weight: 600;
            color: #374151;
        }

        .table tr:hover {
            background: #f8fafc;
        }

        .action-buttons {
            display: flex;
            gap: 8px;
        }

        .btn-sm {
            padding: 6px 12px;
            font-size: 0.875rem;
        }

        .modal {
            display: none;
            position: fixed;
            z-index: 2000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(5px);
        }

        .modal-content {
            background: white;
            margin: 10% auto;
            padding: 32px;
            border-radius: 20px;
            width: 90%;
            max-width: 500px;
            position: relative;
        }

        .close {
            position: absolute;
            right: 20px;
            top: 20px;
            font-size: 1.5rem;
            cursor: pointer;
            color: #6b7280;
        }

        .close:hover {
            color: #374151;
        }

        @media (max-width: 768px) {
            .content-grid {
                grid-template-columns: 1fr;
            }
            
            .main-container {
                padding: 20px 1rem;
            }
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar">
        <div class="navbar-content">
            <a href="admin.jsp" class="navbar-brand">
                <i class="fas fa-train"></i>
                IRCTC Admin
            </a>
            <a href="admin.jsp" class="back-btn">
                <i class="fas fa-arrow-left"></i>
                Back to Dashboard
            </a>
        </div>
    </nav>

    <!-- Main Container -->
    <div class="main-container">
        <!-- Page Header -->
        <div class="page-header">
            <h1 class="page-title">Customer Representative Management</h1>
            <p class="page-subtitle">Add, edit, and delete customer representative information</p>
        </div>

        <!-- Alert Messages -->
        <% if (!message.isEmpty()) { %>
            <div class="alert <%= messageType %>">
                <i class="fas fa-<%= "success".equals(messageType) ? "check-circle" : "exclamation-circle" %>"></i>
                <%= message %>
            </div>
        <% } %>

        <!-- Content Grid -->
        <div class="content-grid">
            <!-- Add Rep Form -->
            <div class="card">
                <h2 class="card-title">
                    <i class="fas fa-user-plus"></i>
                    Add New Representative
                </h2>
                <form method="POST" action="rep-management.jsp">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="form-group">
                        <label class="form-label">SSN</label>
                        <input type="text" class="form-input" name="ssn" placeholder="XXX-XX-XXXX" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">First Name</label>
                        <input type="text" class="form-input" name="firstName" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Last Name</label>
                        <input type="text" class="form-input" name="lastName" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Username</label>
                        <input type="text" class="form-input" name="username" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Password</label>
                        <input type="password" class="form-input" name="password" required>
                    </div>
                    
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-plus"></i>
                        Add Representative
                    </button>
                </form>
            </div>

            <!-- Quick Stats -->
            <div class="card">
                <h2 class="card-title">
                    <i class="fas fa-chart-bar"></i>
                    Representative Statistics
                </h2>
                <%
                    int totalReps = 0;
                    try {
                        Connection con = DBConnection.getConnection();
                        PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) as total FROM employee_data WHERE Role = 'rep'");
                        ResultSet rs = ps.executeQuery();
                        if (rs.next()) totalReps = rs.getInt("total");
                        rs.close();
                        ps.close();
                        con.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>
                <div style="text-align: center; padding: 40px 0;">
                    <div style="font-size: 3rem; font-weight: 800; color: #3b82f6;"><%= totalReps %></div>
                    <div style="color: #64748b; font-weight: 600;">Total Representatives</div>
                </div>
                
                <div style="background: #f8fafc; padding: 20px; border-radius: 12px; margin-top: 20px;">
                    <h3 style="margin-bottom: 12px; color: #374151;">Quick Actions</h3>
                    <button onclick="location.reload()" class="btn btn-secondary" style="width: 100%; margin-bottom: 8px;">
                        <i class="fas fa-sync-alt"></i>
                        Refresh Data
                    </button>
                </div>
            </div>
        </div>

        <!-- Representatives Table -->
        <div class="reps-table">
            <h2 class="card-title">
                <i class="fas fa-users"></i>
                All Representatives
            </h2>
            
            <table class="table">
                <thead>
                    <tr>
                        <th>SSN</th>
                        <th>Name</th>
                        <th>Username</th>
                        <th>Role</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Connection con = DBConnection.getConnection();
                            PreparedStatement ps = con.prepareStatement("SELECT * FROM employee_data WHERE Role = 'rep' ORDER BY SSN");
                            ResultSet rs = ps.executeQuery();
                            
                            boolean hasData = false;
                            while (rs.next()) {
                                hasData = true;
                                String ssn = rs.getString("SSN");
                                String firstName = rs.getString("First_Name");
                                String lastName = rs.getString("Last_Name");
                                String username = rs.getString("Username");
                                String empRole = rs.getString("Role");
                    %>
                    <tr>
                        <td><%= ssn %></td>
                        <td><strong><%= firstName %> <%= lastName %></strong></td>
                        <td><%= username %></td>
                        <td>
                            <span style="background: #dcfce7; color: #166534; padding: 4px 8px; border-radius: 6px; font-size: 0.85rem; font-weight: 600; text-transform: uppercase;">
                                <%= empRole %>
                            </span>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <button onclick="editRep('<%= ssn %>', '<%= firstName %>', '<%= lastName %>', '<%= username %>')" 
                                        class="btn btn-secondary btn-sm">
                                    <i class="fas fa-edit"></i>
                                    Edit
                                </button>
                                <form method="POST" action="rep-management.jsp" style="display: inline;" 
                                      onsubmit="return confirm('Are you sure you want to delete this representative?')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="ssn" value="<%= ssn %>">
                                    <button type="submit" class="btn btn-danger btn-sm">
                                        <i class="fas fa-trash"></i>
                                        Delete
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <%
                            }
                            
                            if (!hasData) {
                    %>
                    <tr>
                        <td colspan="5" style="text-align: center; padding: 40px; color: #64748b;">
                            <i class="fas fa-users" style="font-size: 3rem; margin-bottom: 16px; opacity: 0.3;"></i>
                            <div style="font-size: 1.2rem; font-weight: 600;">No Representatives Found</div>
                            <div>Add a new representative using the form above.</div>
                        </td>
                    </tr>
                    <%
                            }
                            
                            rs.close();
                            ps.close();
                            con.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Edit Modal -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <span class="close">&times;</span>
            <h2 style="margin-bottom: 24px;">Edit Representative</h2>
            <form method="POST" action="rep-management.jsp">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" id="editSSN" name="ssn">
                
                <div class="form-group">
                    <label class="form-label">First Name</label>
                    <input type="text" class="form-input" id="editFirstName" name="firstName" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Last Name</label>
                    <input type="text" class="form-input" id="editLastName" name="lastName" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Username</label>
                    <input type="text" class="form-input" id="editUsername" name="username" required>
                </div>
                
                <div style="display: flex; gap: 12px; justify-content: flex-end;">
                    <button type="button" onclick="closeModal()" class="btn btn-secondary">Cancel</button>
                    <button type="submit" class="btn btn-primary">Update Representative</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Modal functionality
        const modal = document.getElementById('editModal');
        const closeBtn = document.querySelector('.close');

        function editRep(ssn, firstName, lastName, username) {
            document.getElementById('editSSN').value = ssn;
            document.getElementById('editFirstName').value = firstName;
            document.getElementById('editLastName').value = lastName;
            document.getElementById('editUsername').value = username;
            modal.style.display = 'block';
        }

        function closeModal() {
            modal.style.display = 'none';
        }

        closeBtn.onclick = closeModal;

        window.onclick = function(event) {
            if (event.target == modal) {
                closeModal();
            }
        }

        // Auto-hide alerts after 5 seconds
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                alert.style.opacity = '0';
                setTimeout(() => alert.remove(), 300);
            });
        }, 5000);
    </script>
</body>
</html>