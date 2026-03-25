<%@ page import="java.sql.*, java.io.PrintWriter, java.util.*, java.text.*" %>
<%@ page import="util.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>

<%
    String user = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    
    if (user == null || !"rep".equals(role)) {
        response.sendRedirect("rep-login.jsp");
        return;
    }

    String action = request.getParameter("action");
    String message = "";
    String messageType = "";
    String statusFilter = request.getParameter("status");
    String searchQuery = request.getParameter("search");

    // Handle export functionality
    if ("export".equals(action)) {
        try {
            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", "attachment; filename=\"transit_customers_" + new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) + ".csv\"");
            
            PrintWriter csvWriter = response.getWriter();
            csvWriter.println("Username,Total Reservations,Total Spent,Last Booking Date,Status,Active Reservations");
            
            Connection con = DBConnection.getConnection();
            StringBuilder queryBuilder = new StringBuilder(
                "SELECT Username, COUNT(*) as total_reservations, SUM(Total_Fare) as total_spent, " +
                "MAX(Date) as last_booking, " +
                "SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) as active_reservations " +
                "FROM reservation_data WHERE 1=1"
            );
            
            if (request.getParameter("transitLine") != null && !request.getParameter("transitLine").trim().isEmpty()) {
                queryBuilder.append(" AND Transit_line_name = ?");
            }
            if (request.getParameter("reservationDate") != null && !request.getParameter("reservationDate").trim().isEmpty()) {
                queryBuilder.append(" AND DATE(Date) = ?");
            }
            queryBuilder.append(" GROUP BY Username ORDER BY total_spent DESC");
            
            PreparedStatement ps = con.prepareStatement(queryBuilder.toString());
            
            int paramIndex = 1;
            if (request.getParameter("transitLine") != null && !request.getParameter("transitLine").trim().isEmpty()) {
                ps.setString(paramIndex++, request.getParameter("transitLine"));
            }
            if (request.getParameter("reservationDate") != null && !request.getParameter("reservationDate").trim().isEmpty()) {
                ps.setString(paramIndex++, request.getParameter("reservationDate"));
            }
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                csvWriter.printf("\"%s\",%d,\"%.2f\",\"%s\",\"%s\",%d%n",
                    rs.getString("Username"),
                    rs.getInt("total_reservations"),
                    rs.getDouble("total_spent"),
                    rs.getDate("last_booking"),
                    "Active",
                    rs.getInt("active_reservations")
                );
            }
            
            rs.close();
            ps.close();
            con.close();
            csvWriter.close();
            return;
        } catch (Exception e) {
            message = "Error exporting data: " + e.getMessage();
            messageType = "error";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transit Customers - IRCTC Professional Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --primary-blue: #0F172A;
            --secondary-blue: #1E293B;
            --accent-teal: #14B8A6;
            --light-teal: #F0FDFA;
            --success-green: #10B981;
            --warning-orange: #F59E0B;
            --danger-red: #EF4444;
            --info-blue: #3B82F6;
            --text-primary: #0F172A;
            --text-secondary: #64748B;
            --border-light: #E2E8F0;
            --background-light: #F8FAFC;
            --pure-white: #FFFFFF;
            --shadow-soft: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-medium: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            --shadow-large: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #F1F5F9 0%, #E2E8F0 100%);
            min-height: 100vh;
            color: var(--text-primary);
            line-height: 1.6;
        }

        .navbar {
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(20px);
            border-bottom: 1px solid var(--border-light);
            padding: 1rem 0;
            position: sticky;
            top: 0;
            z-index: 1000;
            box-shadow: var(--shadow-soft);
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
            color: var(--primary-blue);
            font-weight: 800;
            font-size: 1.5rem;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .navbar-brand:hover {
            transform: translateY(-1px);
            text-decoration: none;
            color: var(--accent-teal);
        }

        .navbar-brand i {
            font-size: 2rem;
            margin-right: 12px;
            background: linear-gradient(135deg, var(--accent-teal), #0D9488);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .navbar-brand .brand-text {
            display: flex;
            flex-direction: column;
            line-height: 1.2;
        }

        .navbar-brand .brand-main {
            font-size: 1.5rem;
            font-weight: 800;
        }

        .navbar-brand .brand-sub {
            font-size: 0.75rem;
            font-weight: 500;
            color: var(--text-secondary);
            margin-top: -2px;
        }

        .back-btn {
            background: linear-gradient(135deg, var(--info-blue), #6366F1);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
            box-shadow: var(--shadow-soft);
        }

        .back-btn:hover {
            transform: translateY(-2px);
            color: white;
            text-decoration: none;
            box-shadow: var(--shadow-medium);
        }

        .main-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 40px 2rem;
        }

        .page-header {
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            padding: 40px;
            margin-bottom: 32px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: var(--shadow-medium);
            position: relative;
            overflow: hidden;
        }

        .page-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--accent-teal), #0D9488, #0F766E);
        }

        .page-title {
            font-size: 3rem;
            font-weight: 900;
            background: linear-gradient(135deg, var(--primary-blue), var(--accent-teal));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 12px;
            letter-spacing: -0.02em;
        }

        .page-subtitle {
            color: var(--text-secondary);
            font-size: 1.2rem;
            font-weight: 500;
        }

        .alert {
            padding: 20px 24px;
            border-radius: 16px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-weight: 600;
            box-shadow: var(--shadow-soft);
            animation: slideIn 0.3s ease-out;
        }

        .alert.success {
            background: linear-gradient(135deg, #ECFDF5, #D1FAE5);
            color: #065F46;
            border: 1px solid #A7F3D0;
        }

        .alert.error {
            background: linear-gradient(135deg, #FEF2F2, #FECACA);
            color: #991B1B;
            border: 1px solid #FCA5A5;
        }

        .content-section {
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            padding: 40px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: var(--shadow-medium);
            margin-bottom: 32px;
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 32px;
            padding-bottom: 20px;
            border-bottom: 2px solid var(--background-light);
        }

        .section-title {
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--primary-blue);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 32px;
        }

        .stat-card {
            background: linear-gradient(135deg, white, var(--background-light));
            padding: 24px;
            border-radius: 16px;
            box-shadow: var(--shadow-soft);
            border: 1px solid var(--border-light);
            text-align: center;
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }

        .stat-value {
            font-size: 2rem;
            font-weight: 800;
            margin-bottom: 4px;
        }

        .stat-label {
            color: var(--text-secondary);
            font-weight: 600;
            font-size: 0.9rem;
        }

        .stat-customers { color: var(--accent-teal); }
        .stat-bookings { color: var(--info-blue); }
        .stat-revenue { color: var(--success-green); }
        .stat-active { color: var(--warning-orange); }

        .search-filters {
            display: grid;
            grid-template-columns: 1fr auto auto auto auto;
            gap: 16px;
            margin-bottom: 32px;
            align-items: end;
        }

        .search-box {
            position: relative;
        }

        .search-input {
            width: 100%;
            padding: 14px 16px 14px 48px;
            border: 2px solid var(--border-light);
            border-radius: 12px;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        .search-input:focus {
            outline: none;
            border-color: var(--accent-teal);
            box-shadow: 0 0 0 3px rgba(20, 184, 166, 0.1);
        }

        .search-icon {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-secondary);
        }

        .filter-select {
            padding: 14px 16px;
            border: 2px solid var(--border-light);
            border-radius: 12px;
            font-size: 1rem;
            background: white;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .filter-select:focus {
            outline: none;
            border-color: var(--accent-teal);
            box-shadow: 0 0 0 3px rgba(20, 184, 166, 0.1);
        }

        .btn {
            padding: 14px 20px;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            font-size: 1rem;
            box-shadow: var(--shadow-soft);
        }

        .btn-primary { background: linear-gradient(135deg, var(--accent-teal), #0D9488); color: white; }
        .btn-success { background: linear-gradient(135deg, var(--success-green), #059669); color: white; }
        .btn-warning { background: linear-gradient(135deg, var(--warning-orange), #D97706); color: white; }
        .btn-danger { background: linear-gradient(135deg, var(--danger-red), #DC2626); color: white; }
        .btn-secondary { background: linear-gradient(135deg, #6B7280, #4B5563); color: white; }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }

        .customers-table {
            overflow-x: auto;
            border-radius: 16px;
            border: 1px solid var(--border-light);
            background: white;
        }

        .table {
            width: 100%;
            border-collapse: collapse;
        }

        .table th {
            background: linear-gradient(135deg, var(--background-light), #F1F5F9);
            padding: 16px;
            text-align: left;
            font-weight: 700;
            color: var(--primary-blue);
            border-bottom: 2px solid var(--border-light);
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .table td {
            padding: 16px;
            border-bottom: 1px solid var(--border-light);
            vertical-align: middle;
        }

        .table tr:hover {
            background: var(--background-light);
        }

        .table tr:last-child td {
            border-bottom: none;
        }

        .customer-info {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .customer-name {
            font-weight: 700;
            color: var(--primary-blue);
            font-size: 1.1rem;
        }

        .customer-details {
            font-size: 0.85rem;
            color: var(--text-secondary);
        }

        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .status-active { background: linear-gradient(135deg, #ECFDF5, #D1FAE5); color: #065F46; }
        .status-cancelled { background: linear-gradient(135deg, #FEF2F2, #FECACA); color: #991B1B; }

        .stats-display {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .stat-number {
            font-weight: 700;
            color: var(--primary-blue);
        }

        .stat-currency {
            font-weight: 800;
            color: var(--success-green);
            font-size: 1.1rem;
        }

        .action-buttons {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .btn-sm {
            padding: 8px 12px;
            font-size: 0.875rem;
        }

        .no-data {
            text-align: center;
            padding: 80px 20px;
            color: var(--text-secondary);
        }

        .no-data i {
            font-size: 5rem;
            margin-bottom: 24px;
            opacity: 0.3;
        }

        .no-data h3 {
            font-size: 1.5rem;
            margin-bottom: 12px;
            color: var(--text-primary);
        }

        @keyframes slideIn {
            from { transform: translateX(-20px); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }

        @media (max-width: 768px) {
            .main-container {
                padding: 20px 1rem;
            }
            
            .page-title {
                font-size: 2rem;
            }
            
            .search-filters {
                grid-template-columns: 1fr;
                gap: 12px;
            }
            
            .section-header {
                flex-direction: column;
                gap: 16px;
                align-items: stretch;
            }
            
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .action-buttons {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar">
        <div class="navbar-content">
            <a href="rep-dashboard.jsp" class="navbar-brand">
                <i class="fas fa-users"></i>
                <div class="brand-text">
                    <span class="brand-main">Transit Customers</span>
                    <span class="brand-sub">Customer Analytics & Management</span>
                </div>
            </a>
            <a href="rep-dashboard.jsp" class="back-btn">
                <i class="fas fa-arrow-left"></i>
                Back to Dashboard
            </a>
        </div>
    </nav>

    <!-- Main Container -->
    <div class="main-container">
        <!-- Page Header -->
        <div class="page-header">
            <h1 class="page-title">Transit Customers</h1>
            <p class="page-subtitle">Customer analytics, reservation reports, and transit line passenger lists</p>
        </div>

        <!-- Alert Messages -->
        <% if (!message.isEmpty()) { %>
            <div class="alert <%= messageType %>">
                <i class="fas fa-<%= "success".equals(messageType) ? "check-circle" : "exclamation-triangle" %>"></i>
                <%= message %>
            </div>
        <% } %>

        <!-- Statistics Cards -->
        <div class="stats-grid">
            <%
                int uniqueCustomers = 0;
                int totalReservations = 0;
                double totalRevenue = 0.0;
                int activeReservations = 0;
                try {
                    Connection con = DBConnection.getConnection();
                    
                    // Unique customers
                    PreparedStatement ps1 = con.prepareStatement("SELECT COUNT(DISTINCT Username) as customers FROM reservation_data");
                    ResultSet rs1 = ps1.executeQuery();
                    if (rs1.next()) uniqueCustomers = rs1.getInt("customers");
                    rs1.close(); ps1.close();
                    
                    // Total reservations
                    PreparedStatement ps2 = con.prepareStatement("SELECT COUNT(*) as reservations FROM reservation_data");
                    ResultSet rs2 = ps2.executeQuery();
                    if (rs2.next()) totalReservations = rs2.getInt("reservations");
                    rs2.close(); ps2.close();
                    
                    // Total revenue
                    PreparedStatement ps3 = con.prepareStatement("SELECT SUM(Total_Fare) as revenue FROM reservation_data");
                    ResultSet rs3 = ps3.executeQuery();
                    if (rs3.next()) totalRevenue = rs3.getDouble("revenue");
                    rs3.close(); ps3.close();
                    
                    // Active reservations
                    PreparedStatement ps4 = con.prepareStatement("SELECT COUNT(*) as active FROM reservation_data WHERE status='ACTIVE'");
                    ResultSet rs4 = ps4.executeQuery();
                    if (rs4.next()) activeReservations = rs4.getInt("active");
                    rs4.close(); ps4.close();
                    
                    con.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>
            <div class="stat-card">
                <div class="stat-value stat-customers"><%= uniqueCustomers %></div>
                <div class="stat-label">Unique Customers</div>
            </div>
            <div class="stat-card">
                <div class="stat-value stat-bookings"><%= totalReservations %></div>
                <div class="stat-label">Total Reservations</div>
            </div>
            <div class="stat-card">
                <div class="stat-value stat-revenue">$<%= String.format("%.0f", totalRevenue) %></div>
                <div class="stat-label">Total Revenue</div>
            </div>
            <div class="stat-card">
                <div class="stat-value stat-active"><%= activeReservations %></div>
                <div class="stat-label">Active Bookings</div>
            </div>
        </div>

        <!-- Customer Management -->
        <div class="content-section">
            <div class="section-header">
                <h2 class="section-title">
                    <i class="fas fa-chart-line"></i>
                    Customer Analytics & Transit Line Reports
                </h2>
                <div style="display: flex; gap: 12px;">
                    <form method="GET" action="transit-customers.jsp" style="display: inline;">
                        <input type="hidden" name="action" value="export">
                        <input type="hidden" name="transitLine" value="<%= request.getParameter("transitLine") != null ? request.getParameter("transitLine") : "" %>">
                        <input type="hidden" name="reservationDate" value="<%= request.getParameter("reservationDate") != null ? request.getParameter("reservationDate") : "" %>">
                        <button type="submit" class="btn btn-success">
                            <i class="fas fa-download"></i>
                            Export CSV
                        </button>
                    </form>

            <!-- Filter Status Display -->
            <%
                if ((request.getParameter("transitLine") != null && !request.getParameter("transitLine").trim().isEmpty()) || 
                    (request.getParameter("reservationDate") != null && !request.getParameter("reservationDate").trim().isEmpty())) {
            %>
            <div style="background: linear-gradient(135deg, #EBF8FF, #DBEAFE); padding: 16px; border-radius: 12px; margin-bottom: 20px; border-left: 4px solid var(--accent-teal);">
                <h4 style="margin: 0 0 8px 0; color: var(--primary-blue);">
                    <i class="fas fa-filter"></i> Active Filters
                </h4>
                <p style="margin: 0; color: var(--text-primary);">
                    <% if (request.getParameter("transitLine") != null && !request.getParameter("transitLine").trim().isEmpty()) { %>
                        <strong>Transit Line:</strong> <%= request.getParameter("transitLine") %>
                    <% } %>
                    <% if (request.getParameter("reservationDate") != null && !request.getParameter("reservationDate").trim().isEmpty()) { %>
                        <% if (request.getParameter("transitLine") != null && !request.getParameter("transitLine").trim().isEmpty()) { %> | <% } %>
                        <strong>Date:</strong> <%= request.getParameter("reservationDate") %>
                    <% } %>
                </p>
            </div>
            <% } %>
                </div>
            </div>

            <!-- Search and Filters -->
            <form method="GET" action="transit-customers.jsp" class="search-filters">
                <div class="search-box">
                    <i class="fas fa-search search-icon"></i>
                    <input type="text" name="search" class="search-input" 
                           placeholder="Search by username..." 
                           value="<%= searchQuery != null ? searchQuery : "" %>">
                </div>
                
                <select name="transitLine" class="filter-select">
                    <option value="">All Transit Lines</option>
                    <%
                        String currentTransitLineFilter = request.getParameter("transitLine");
                        try {
                            Connection con = DBConnection.getConnection();
                            PreparedStatement ps = con.prepareStatement("SELECT DISTINCT Transit_line_name FROM reservation_data ORDER BY Transit_line_name");
                            ResultSet rs = ps.executeQuery();
                            while (rs.next()) {
                                String transitLine = rs.getString("Transit_line_name");
                                String selected = transitLine.equals(currentTransitLineFilter) ? "selected" : "";
                    %>
                    <option value="<%= transitLine %>" <%= selected %>><%= transitLine %></option>
                    <%
                            }
                            rs.close();
                            ps.close();
                            con.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    %>
                </select>
                
                <input type="date" name="reservationDate" class="filter-select" 
                       value="<%= request.getParameter("reservationDate") != null ? request.getParameter("reservationDate") : "" %>"
                       style="padding: 14px 16px;">
                
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-search"></i>
                    Search
                </button>
                
                <a href="transit-customers.jsp" class="btn btn-secondary">
                    <i class="fas fa-refresh"></i>
                    Reset
                </a>
            </form>

            <!-- Customers Table -->
            <div class="customers-table">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Customer</th>
                            <th>Total Reservations</th>
                            <th>Total Spent</th>
                            <th>Last Booking</th>
                            <th>Active Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Connection con = DBConnection.getConnection();
                                
                                // Build query with customer aggregation
                                StringBuilder queryBuilder = new StringBuilder(
                                    "SELECT Username, " +
                                    "COUNT(*) as total_reservations, " +
                                    "SUM(Total_Fare) as total_spent, " +
                                    "MAX(Date) as last_booking, " +
                                    "SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) as active_reservations, " +
                                    "SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) as cancelled_reservations " +
                                    "FROM reservation_data WHERE 1=1"
                                );
                                
                                if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                                    queryBuilder.append(" AND Username LIKE ?");
                                }
                                if (request.getParameter("transitLine") != null && !request.getParameter("transitLine").trim().isEmpty()) {
                                    queryBuilder.append(" AND Transit_line_name = ?");
                                }
                                if (request.getParameter("reservationDate") != null && !request.getParameter("reservationDate").trim().isEmpty()) {
                                    queryBuilder.append(" AND DATE(Date) = ?");
                                }
                                
                                queryBuilder.append(" GROUP BY Username ORDER BY total_spent DESC");
                                
                                PreparedStatement ps = con.prepareStatement(queryBuilder.toString());
                                
                                int paramIndex = 1;
                                if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                                    ps.setString(paramIndex++, "%" + searchQuery + "%");
                                }
                                if (request.getParameter("transitLine") != null && !request.getParameter("transitLine").trim().isEmpty()) {
                                    ps.setString(paramIndex++, request.getParameter("transitLine"));
                                }
                                if (request.getParameter("reservationDate") != null && !request.getParameter("reservationDate").trim().isEmpty()) {
                                    ps.setString(paramIndex++, request.getParameter("reservationDate"));
                                }
                                
                                ResultSet rs = ps.executeQuery();
                                
                                boolean hasData = false;
                                while (rs.next()) {
                                    hasData = true;
                                    String username = rs.getString("Username");
                                    int totalReservationsCustomer = rs.getInt("total_reservations");
                                    double totalSpent = rs.getDouble("total_spent");
                                    java.sql.Date lastBooking = rs.getDate("last_booking");
                                    int activeReservationsCustomer = rs.getInt("active_reservations");
                                    int cancelledReservations = rs.getInt("cancelled_reservations");
                                    
                                    // Determine customer status
                                    String customerStatus = activeReservationsCustomer > 0 ? "Active" : "Inactive";
                                    String statusClass = activeReservationsCustomer > 0 ? "status-active" : "status-cancelled";
                        %>
                        <tr>
                            <td>
                                <div class="customer-info">
                                    <div class="customer-name"><%= username %></div>
                                    <div class="customer-details">
                                        <i class="fas fa-ticket-alt"></i>
                                        <%= totalReservationsCustomer %> total bookings
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="stats-display">
                                    <div class="stat-number"><%= totalReservationsCustomer %></div>
                                    <div class="customer-details">
                                        Active: <%= activeReservationsCustomer %> | Cancelled: <%= cancelledReservations %>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="stat-currency">$<%= String.format("%.2f", totalSpent) %></div>
                                <div class="customer-details">
                                    Avg: $<%= String.format("%.2f", totalSpent / totalReservationsCustomer) %>
                                </div>
                            </td>
                            <td>
                                <div class="customer-details">
                                    <%= lastBooking != null ? new SimpleDateFormat("MMM dd, yyyy").format(lastBooking) : "No bookings" %>
                                </div>
                            </td>
                            <td>
                                <span class="status-badge <%= statusClass %>"><%= customerStatus %></span>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <button onclick="viewCustomerDetails('<%= username %>')" class="btn btn-primary btn-sm">
                                        <i class="fas fa-eye"></i>
                                        View Details
                                    </button>
                                    <button onclick="viewCustomerHistory('<%= username %>')" class="btn btn-warning btn-sm">
                                        <i class="fas fa-history"></i>
                                        History
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                                
                                if (!hasData) {
                        %>
                        <tr>
                            <td colspan="6">
                                <div class="no-data">
                                    <i class="fas fa-users"></i>
                                    <h3>No Customers Found</h3>
                                    <p>No customers match your current search criteria.</p>
                                    <a href="transit-customers.jsp" class="btn btn-primary" style="margin-top: 20px;">
                                        <i class="fas fa-refresh"></i>
                                        Show All Customers
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                                
                                rs.close();
                                ps.close();
                                con.close();
                            } catch (Exception e) {
                                e.printStackTrace();
                        %>
                        <tr>
                            <td colspan="6">
                                <div class="no-data">
                                    <i class="fas fa-exclamation-triangle"></i>
                                    <h3>Database Error</h3>
                                    <p>Unable to load customer data. Please check your database connection.</p>
                                    <small style="color: #EF4444; margin-top: 8px; display: block;">
                                        Error: <%= e.getMessage() %>
                                    </small>
                                </div>
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        // Auto-hide alerts after 5 seconds
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                alert.style.opacity = '0';
                alert.style.transform = 'translateX(-20px)';
                setTimeout(() => alert.remove(), 300);
            });
        }, 5000);

        function viewCustomerDetails(username) {
            alert('Customer Details for: ' + username + '\n\nThis would show detailed customer information including:\n- Contact details\n- Booking preferences\n- Payment history\n- Special requirements');
        }

        function viewCustomerHistory(username) {
            alert('Booking History for: ' + username + '\n\nThis would show:\n- All past reservations\n- Travel patterns\n- Favorite routes\n- Cancellation history');
        }

        // Enhanced search functionality
        document.querySelector('.search-input').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                this.closest('form').submit();
            }
        });

        // Export confirmation
        document.querySelector('button[type="submit"]:has(.fa-download)').addEventListener('click', function(e) {
            const confirmExport = confirm('Export customer analytics data to CSV?');
            if (!confirmExport) {
                e.preventDefault();
            }
        });
    </script>
</body>
</html>