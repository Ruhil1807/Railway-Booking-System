<%@ page import="java.sql.*, java.io.PrintWriter, java.text.SimpleDateFormat, java.util.Calendar" %>
<%@ page import="util.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>

<%
    String user = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    
    if (user == null || !"admin".equals(role)) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    // Get current month and year
    Calendar cal = Calendar.getInstance();
    int currentYear = cal.get(Calendar.YEAR);
    int currentMonth = cal.get(Calendar.MONTH) + 1;
    
    // Get requested month/year from parameters
    String yearParam = request.getParameter("year");
    String monthParam = request.getParameter("month");
    
    int selectedYear = yearParam != null ? Integer.parseInt(yearParam) : currentYear;
    int selectedMonth = monthParam != null ? Integer.parseInt(monthParam) : currentMonth;
    
    // Month names
    String[] monthNames = {"", "January", "February", "March", "April", "May", "June",
                          "July", "August", "September", "October", "November", "December"};
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sales Reports - IRCTC Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

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

        .filter-section {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 32px;
            margin-bottom: 32px;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .filter-form {
            display: flex;
            gap: 20px;
            align-items: end;
            flex-wrap: wrap;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-label {
            font-weight: 600;
            color: #374151;
        }

        .form-select {
            padding: 12px 16px;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 1rem;
            min-width: 120px;
            background: white;
        }

        .form-select:focus {
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

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 24px;
            margin-bottom: 32px;
        }

        .stat-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 32px 24px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: var(--accent-color);
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.12);
        }

        .stat-card.revenue { --accent-color: linear-gradient(90deg, #10b981, #059669); }
        .stat-card.bookings { --accent-color: linear-gradient(90deg, #3b82f6, #1d4ed8); }
        .stat-card.avg-fare { --accent-color: linear-gradient(90deg, #f59e0b, #d97706); }
        .stat-card.customers { --accent-color: linear-gradient(90deg, #8b5cf6, #7c3aed); }

        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 16px;
        }

        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: white;
        }

        .stat-icon.revenue { background: linear-gradient(135deg, #10b981, #059669); }
        .stat-icon.bookings { background: linear-gradient(135deg, #3b82f6, #1d4ed8); }
        .stat-icon.avg-fare { background: linear-gradient(135deg, #f59e0b, #d97706); }
        .stat-icon.customers { background: linear-gradient(135deg, #8b5cf6, #7c3aed); }

        .stat-value {
            font-size: 2.5rem;
            font-weight: 800;
            color: #1e293b;
            line-height: 1;
            margin-bottom: 8px;
        }

        .stat-label {
            color: #64748b;
            font-weight: 600;
            font-size: 0.95rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 32px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.1);
            margin-bottom: 32px;
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

        .table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .table th, .table td {
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

        .no-data {
            text-align: center;
            padding: 60px 20px;
            color: #64748b;
        }

        .no-data i {
            font-size: 4rem;
            margin-bottom: 20px;
            opacity: 0.3;
        }

        .status-toggle {
            background: #f8fafc;
            padding: 16px;
            border-radius: 12px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .toggle-btn {
            padding: 8px 16px;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            background: white;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .toggle-btn.active {
            background: #3b82f6;
            color: white;
            border-color: #3b82f6;
        }

        @media (max-width: 768px) {
            .filter-form {
                flex-direction: column;
                align-items: stretch;
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
            <h1 class="page-title">Monthly Sales Reports</h1>
            <p class="page-subtitle">Comprehensive sales analysis and revenue insights</p>
        </div>

        <!-- Filter Section -->
        <div class="filter-section">
            <form class="filter-form" method="GET" action="sales-reports.jsp">
                <div class="form-group">
                    <label class="form-label">Month</label>
                    <select name="month" class="form-select">
                        <% for (int i = 1; i <= 12; i++) { %>
                            <option value="<%= i %>" <%= i == selectedMonth ? "selected" : "" %>><%= monthNames[i] %></option>
                        <% } %>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Year</label>
                    <select name="year" class="form-select">
                        <% for (int year = currentYear; year >= currentYear - 5; year--) { %>
                            <option value="<%= year %>" <%= year == selectedYear ? "selected" : "" %>><%= year %></option>
                        <% } %>
                    </select>
                </div>
                
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-chart-bar"></i>
                    Generate Report
                </button>
            </form>
        </div>

        <%
            // Fetch data for selected month/year - CORRECTED to use your actual column names
            double totalRevenue = 0.0;
            double activeRevenue = 0.0;
            double cancelledRevenue = 0.0;
            int totalBookings = 0;
            int activeBookings = 0;
            int cancelledBookings = 0;
            double avgFare = 0.0;
            int uniqueCustomers = 0;
            
            try {
                Connection con = DBConnection.getConnection();
                
                // Total revenue for the month (ALL statuses)
                PreparedStatement ps1 = con.prepareStatement(
                    "SELECT SUM(Total_Fare) as revenue FROM reservation_data " +
                    "WHERE YEAR(Date) = ? AND MONTH(Date) = ?"
                );
                ps1.setInt(1, selectedYear);
                ps1.setInt(2, selectedMonth);
                ResultSet rs1 = ps1.executeQuery();
                if (rs1.next()) totalRevenue = rs1.getDouble("revenue");
                
                // Active revenue for the month
                PreparedStatement ps1a = con.prepareStatement(
                    "SELECT SUM(Total_Fare) as revenue FROM reservation_data " +
                    "WHERE YEAR(Date) = ? AND MONTH(Date) = ? AND COALESCE(status, 'ACTIVE') = 'ACTIVE'"
                );
                ps1a.setInt(1, selectedYear);
                ps1a.setInt(2, selectedMonth);
                ResultSet rs1a = ps1a.executeQuery();
                if (rs1a.next()) activeRevenue = rs1a.getDouble("revenue");
                
                // Cancelled revenue for the month
                PreparedStatement ps1b = con.prepareStatement(
                    "SELECT SUM(Total_Fare) as revenue FROM reservation_data " +
                    "WHERE YEAR(Date) = ? AND MONTH(Date) = ? AND status = 'CANCELLED'"
                );
                ps1b.setInt(1, selectedYear);
                ps1b.setInt(2, selectedMonth);
                ResultSet rs1b = ps1b.executeQuery();
                if (rs1b.next()) cancelledRevenue = rs1b.getDouble("revenue");
                
                // Total bookings for the month (ALL statuses)
                PreparedStatement ps2 = con.prepareStatement(
                    "SELECT COUNT(*) as bookings FROM reservation_data " +
                    "WHERE YEAR(Date) = ? AND MONTH(Date) = ?"
                );
                ps2.setInt(1, selectedYear);
                ps2.setInt(2, selectedMonth);
                ResultSet rs2 = ps2.executeQuery();
                if (rs2.next()) totalBookings = rs2.getInt("bookings");
                
                // Active bookings
                PreparedStatement ps2a = con.prepareStatement(
                    "SELECT COUNT(*) as bookings FROM reservation_data " +
                    "WHERE YEAR(Date) = ? AND MONTH(Date) = ? AND COALESCE(status, 'ACTIVE') = 'ACTIVE'"
                );
                ps2a.setInt(1, selectedYear);
                ps2a.setInt(2, selectedMonth);
                ResultSet rs2a = ps2a.executeQuery();
                if (rs2a.next()) activeBookings = rs2a.getInt("bookings");
                
                cancelledBookings = totalBookings - activeBookings;
                
                // Average fare
                if (totalBookings > 0) {
                    avgFare = totalRevenue / totalBookings;
                }
                
                // Unique customers
                PreparedStatement ps3 = con.prepareStatement(
                    "SELECT COUNT(DISTINCT Username) as customers FROM reservation_data " +
                    "WHERE YEAR(Date) = ? AND MONTH(Date) = ?"
                );
                ps3.setInt(1, selectedYear);
                ps3.setInt(2, selectedMonth);
                ResultSet rs3 = ps3.executeQuery();
                if (rs3.next()) uniqueCustomers = rs3.getInt("customers");
                
                rs1.close(); ps1.close();
                rs1a.close(); ps1a.close();
                rs1b.close(); ps1b.close();
                rs2.close(); ps2.close();
                rs2a.close(); ps2a.close();
                rs3.close(); ps3.close();
                con.close();
                
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>

        <!-- Statistics Cards -->
        <div class="stats-grid">
            <div class="stat-card revenue">
                <div class="stat-header">
                    <div>
                        <div class="stat-value">$<%= String.format("%.0f", totalRevenue) %></div>
                        <div class="stat-label">Total Revenue</div>
                        <div style="font-size: 0.8rem; color: #059669; margin-top: 4px;">
                            Active: $<%= String.format("%.0f", activeRevenue) %>
                        </div>
                    </div>
                    <div class="stat-icon revenue">
                        <i class="fas fa-dollar-sign"></i>
                    </div>
                </div>
            </div>
            
            <div class="stat-card bookings">
                <div class="stat-header">
                    <div>
                        <div class="stat-value"><%= totalBookings %></div>
                        <div class="stat-label">Total Bookings</div>
                        <div style="font-size: 0.8rem; color: #1d4ed8; margin-top: 4px;">
                            Active: <%= activeBookings %> | Cancelled: <%= cancelledBookings %>
                        </div>
                    </div>
                    <div class="stat-icon bookings">
                        <i class="fas fa-ticket-alt"></i>
                    </div>
                </div>
            </div>
            
            <div class="stat-card avg-fare">
                <div class="stat-header">
                    <div>
                        <div class="stat-value">$<%= String.format("%.0f", avgFare) %></div>
                        <div class="stat-label">Average Fare</div>
                    </div>
                    <div class="stat-icon avg-fare">
                        <i class="fas fa-calculator"></i>
                    </div>
                </div>
            </div>
            
            <div class="stat-card customers">
                <div class="stat-header">
                    <div>
                        <div class="stat-value"><%= uniqueCustomers %></div>
                        <div class="stat-label">Unique Customers</div>
                    </div>
                    <div class="stat-icon customers">
                        <i class="fas fa-users"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Detailed Sales Data -->
        <div class="card">
            <h2 class="card-title">
                <i class="fas fa-list-alt"></i>
                Sales Details for <%= monthNames[selectedMonth] %> <%= selectedYear %>
            </h2>
            
            <% if (totalBookings > 0) { %>
                <div class="status-toggle">
                    <span style="font-weight: 600; color: #374151;">Show:</span>
                    <button class="toggle-btn active" onclick="showAll()">All Reservations</button>
                    <button class="toggle-btn" onclick="showActive()">Active Only</button>
                    <button class="toggle-btn" onclick="showCancelled()">Cancelled Only</button>
                </div>
                
                <table class="table" id="salesTable">
                    <thead>
                        <tr>
                            <th>Reservation ID</th>
                            <th>Customer</th>
                            <th>Date</th>
                            <th>Transit Line</th>
                            <th>Fare</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Connection con = DBConnection.getConnection();
                                PreparedStatement ps = con.prepareStatement(
                                    "SELECT * FROM reservation_data " +
                                    "WHERE YEAR(Date) = ? AND MONTH(Date) = ? " +
                                    "ORDER BY Date DESC, Reservation_Number DESC"
                                );
                                ps.setInt(1, selectedYear);
                                ps.setInt(2, selectedMonth);
                                ResultSet rs = ps.executeQuery();
                                
                                while (rs.next()) {
                                    int resId = rs.getInt("Reservation_Number");
                                    String username = rs.getString("Username");
                                    java.sql.Date reservationDate = rs.getDate("Date");
                                    String transitLine = rs.getString("Transit_line_name");
                                    double fare = rs.getDouble("Total_Fare");
                                    String status = rs.getString("status");
                                    if (status == null) status = "ACTIVE";
                                    
                                    String statusClass = "ACTIVE".equals(status) ? "status-active" : "status-cancelled";
                                    String statusColor = "ACTIVE".equals(status) ? "#166534" : "#dc2626";
                                    String statusBg = "ACTIVE".equals(status) ? "#dcfce7" : "#fef2f2";
                        %>
                        <tr class="reservation-row" data-status="<%= status %>">
                            <td><strong><%= resId %></strong></td>
                            <td><%= username %></td>
                            <td><%= reservationDate %></td>
                            <td><%= transitLine != null ? transitLine : "N/A" %></td>
                            <td>$<%= String.format("%.2f", fare) %></td>
                            <td>
                                <span style="background: <%= statusBg %>; color: <%= statusColor %>; padding: 4px 8px; border-radius: 6px; font-size: 0.85rem; font-weight: 600;">
                                    <%= status %>
                                </span>
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
            <% } else { %>
                <div class="no-data">
                    <i class="fas fa-chart-line"></i>
                    <h3>No Sales Data Found</h3>
                    <p>No bookings were made in <%= monthNames[selectedMonth] %> <%= selectedYear %>.</p>
                </div>
            <% } %>
        </div>

        <!-- Summary Report -->
        <div class="card">
            <h2 class="card-title">
                <i class="fas fa-file-alt"></i>
                Sales Summary Report
            </h2>
            
            <div style="background: #f8fafc; padding: 24px; border-radius: 12px;">
                <h3 style="margin-bottom: 16px; color: #374151;">Report Summary for <%= monthNames[selectedMonth] %> <%= selectedYear %></h3>
                
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px;">
                    <div>
                        <strong>Total Revenue:</strong><br>
                        <span style="color: #059669; font-size: 1.2rem; font-weight: 700;">$<%= String.format("%.2f", totalRevenue) %></span>
                    </div>
                    
                    <div>
                        <strong>Active Revenue:</strong><br>
                        <span style="color: #1d4ed8; font-size: 1.2rem; font-weight: 700;">$<%= String.format("%.2f", activeRevenue) %></span>
                    </div>
                    
                    <div>
                        <strong>Cancelled Revenue:</strong><br>
                        <span style="color: #dc2626; font-size: 1.2rem; font-weight: 700;">$<%= String.format("%.2f", cancelledRevenue) %></span>
                    </div>
                    
                    <div>
                        <strong>Average Fare:</strong><br>
                        <span style="color: #d97706; font-size: 1.2rem; font-weight: 700;">$<%= String.format("%.2f", avgFare) %></span>
                    </div>
                    
                    <div>
                        <strong>Unique Customers:</strong><br>
                        <span style="color: #7c3aed; font-size: 1.2rem; font-weight: 700;"><%= uniqueCustomers %></span>
                    </div>
                </div>
                
                <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #e5e7eb;">
                    <strong>Performance Insights:</strong>
                    <ul style="margin-top: 8px; padding-left: 20px; color: #64748b;">
                        <% if (totalBookings > 0) { %>
                            <li>Revenue per customer: $<%= String.format("%.2f", totalRevenue / uniqueCustomers) %></li>
                            <li>Bookings per customer: <%= String.format("%.1f", (double)totalBookings / uniqueCustomers) %></li>
                            <li>Cancellation rate: <%= String.format("%.1f", (double)cancelledBookings / totalBookings * 100) %>%</li>
                            <% if (avgFare > 1000) { %>
                                <li>High-value transactions indicate premium service preference</li>
                            <% } else { %>
                                <li>Competitive fare pricing attracting diverse customer segments</li>
                            <% } %>
                        <% } else { %>
                            <li>No bookings recorded for this period</li>
                            <li>Consider promotional activities to boost sales</li>
                        <% } %>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Filter functionality
        function showAll() {
            document.querySelectorAll('.reservation-row').forEach(row => {
                row.style.display = '';
            });
            updateToggleButtons('all');
        }

        function showActive() {
            document.querySelectorAll('.reservation-row').forEach(row => {
                if (row.dataset.status === 'ACTIVE') {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
            updateToggleButtons('active');
        }

        function showCancelled() {
            document.querySelectorAll('.reservation-row').forEach(row => {
                if (row.dataset.status === 'CANCELLED') {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
            updateToggleButtons('cancelled');
        }

        function updateToggleButtons(active) {
            document.querySelectorAll('.toggle-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            
            if (active === 'all') {
                document.querySelectorAll('.toggle-btn')[0].classList.add('active');
            } else if (active === 'active') {
                document.querySelectorAll('.toggle-btn')[1].classList.add('active');
            } else if (active === 'cancelled') {
                document.querySelectorAll('.toggle-btn')[2].classList.add('active');
            }
        }

        // Auto-submit form when month/year changes
        document.querySelector('select[name="month"]').addEventListener('change', function() {
            this.form.submit();
        });
        
        document.querySelector('select[name="year"]').addEventListener('change', function() {
            this.form.submit();
        });
    </script>
</body>
</html>