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

    String analysisType = request.getParameter("analysisType");
    if (analysisType == null) analysisType = "transit";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Revenue Analysis - IRCTC Admin</title>
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

        .analysis-tabs {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 32px;
            margin-bottom: 32px;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .tab-buttons {
            display: flex;
            gap: 16px;
            margin-bottom: 32px;
            flex-wrap: wrap;
        }

        .tab-btn {
            padding: 12px 24px;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .tab-btn.active {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
            color: white;
        }

        .tab-btn:not(.active) {
            background: #f1f5f9;
            color: #64748b;
        }

        .tab-btn:not(.active):hover {
            background: #e2e8f0;
            color: #475569;
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

        .revenue-bar {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
            height: 8px;
            border-radius: 4px;
            margin-top: 8px;
        }

        .stats-summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 32px;
        }

        .stat-box {
            background: #f8fafc;
            padding: 20px;
            border-radius: 12px;
            text-align: center;
        }

        .stat-value {
            font-size: 2rem;
            font-weight: 800;
            color: #1e293b;
        }

        .stat-label {
            color: #64748b;
            font-weight: 600;
            font-size: 0.9rem;
        }

        .status-filter {
            background: #f8fafc;
            padding: 16px;
            border-radius: 12px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
        }

        .status-btn {
            padding: 8px 16px;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            background: white;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            font-size: 0.9rem;
        }

        .status-btn.active {
            background: #8b5cf6;
            color: white;
            border-color: #8b5cf6;
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

        @media (max-width: 768px) {
            .main-container {
                padding: 20px 1rem;
            }
            .tab-buttons {
                flex-direction: column;
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
            <h1 class="page-title">Revenue Analysis</h1>
            <p class="page-subtitle">Comprehensive revenue breakdown and profit analysis</p>
        </div>

        <!-- Analysis Tabs -->
        <div class="analysis-tabs">
            <div class="tab-buttons">
                <a href="revenue-reports.jsp?analysisType=transit" 
                   class="tab-btn <%= "transit".equals(analysisType) ? "active" : "" %>">
                    <i class="fas fa-route"></i>
                    By Transit Line
                </a>
                <a href="revenue-reports.jsp?analysisType=customer" 
                   class="tab-btn <%= "customer".equals(analysisType) ? "active" : "" %>">
                    <i class="fas fa-users"></i>
                    By Customer
                </a>
                <a href="revenue-reports.jsp?analysisType=time" 
                   class="tab-btn <%= "time".equals(analysisType) ? "active" : "" %>">
                    <i class="fas fa-calendar-alt"></i>
                    By Time Period
                </a>
            </div>

            <%
                if ("transit".equals(analysisType)) {
                    // Revenue by Transit Line Analysis
            %>
                <div class="card">
                    <h2 class="card-title">
                        <i class="fas fa-route"></i>
                        Revenue by Transit Line
                    </h2>
                    
                    <%
                        double totalRevenue = 0.0;
                        double activeRevenue = 0.0;
                        int totalRoutes = 0;
                        
                        try {
                            Connection con = DBConnection.getConnection();
                            
                            // Get total revenue - CORRECTED
                            PreparedStatement totalPs = con.prepareStatement(
                                "SELECT SUM(Total_Fare) as total_revenue, COUNT(DISTINCT Transit_line_name) as total_routes " +
                                "FROM reservation_data"
                            );
                            ResultSet totalRs = totalPs.executeQuery();
                            if (totalRs.next()) {
                                totalRevenue = totalRs.getDouble("total_revenue");
                                totalRoutes = totalRs.getInt("total_routes");
                            }
                            
                            // Get active revenue
                            PreparedStatement activePs = con.prepareStatement(
                                "SELECT SUM(Total_Fare) as active_revenue FROM reservation_data WHERE COALESCE(status, 'ACTIVE') = 'ACTIVE'"
                            );
                            ResultSet activeRs = activePs.executeQuery();
                            if (activeRs.next()) {
                                activeRevenue = activeRs.getDouble("active_revenue");
                            }
                            
                            totalRs.close();
                            totalPs.close();
                            activeRs.close();
                            activePs.close();
                            con.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    %>
                    
                    <div class="status-filter">
                        <span style="font-weight: 600; color: #374151;">Show Revenue:</span>
                        <button class="status-btn active" onclick="showAllRevenue()">All Revenue</button>
                        <button class="status-btn" onclick="showActiveRevenue()">Active Only</button>
                    </div>
                    
                    <div class="stats-summary">
                        <div class="stat-box">
                            <div class="stat-value">$<%= String.format("%.0f", totalRevenue) %></div>
                            <div class="stat-label">Total Revenue</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-value">$<%= String.format("%.0f", activeRevenue) %></div>
                            <div class="stat-label">Active Revenue</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-value"><%= totalRoutes %></div>
                            <div class="stat-label">Transit Lines</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-value">$<%= totalRoutes > 0 ? String.format("%.0f", totalRevenue / totalRoutes) : "0" %></div>
                            <div class="stat-label">Avg Per Line</div>
                        </div>
                    </div>
                    
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Transit Line</th>
                                <th>Route</th>
                                <th>Total Bookings</th>
                                <th>Active Bookings</th>
                                <th>Total Revenue</th>
                                <th>Active Revenue</th>
                                <th>Average Fare</th>
                                <th>Revenue Share</th>
                            </tr>
                        </thead>
                        <tbody id="transitRevenueTable">
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    PreparedStatement ps = con.prepareStatement(
                                        "SELECT r.Transit_line_name, t.Origin, t.Destination, " +
                                        "COUNT(*) as total_bookings, " +
                                        "SUM(CASE WHEN COALESCE(r.status, 'ACTIVE') = 'ACTIVE' THEN 1 ELSE 0 END) as active_bookings, " +
                                        "SUM(r.Total_Fare) as total_revenue, " +
                                        "SUM(CASE WHEN COALESCE(r.status, 'ACTIVE') = 'ACTIVE' THEN r.Total_Fare ELSE 0 END) as active_revenue, " +
                                        "AVG(r.Total_Fare) as avg_fare " +
                                        "FROM reservation_data r " +
                                        "LEFT JOIN train_schedule_data t ON r.Transit_line_name = t.Transit_line_name " +
                                        "GROUP BY r.Transit_line_name, t.Origin, t.Destination " +
                                        "ORDER BY total_revenue DESC"
                                    );
                                    ResultSet rs = ps.executeQuery();
                                    
                                    while (rs.next()) {
                                        String transitLine = rs.getString("Transit_line_name");
                                        String origin = rs.getString("Origin");
                                        String destination = rs.getString("Destination");
                                        String route = (origin != null && destination != null) ? 
                                                      origin + " → " + destination : "Route Info N/A";
                                        int totalBookings = rs.getInt("total_bookings");
                                        int activeBookings = rs.getInt("active_bookings");
                                        double totalRev = rs.getDouble("total_revenue");
                                        double activeRev = rs.getDouble("active_revenue");
                                        double avgFare = rs.getDouble("avg_fare");
                                        double sharePercentage = totalRevenue > 0 ? (totalRev / totalRevenue) * 100 : 0;
                            %>
                            <tr data-total-revenue="<%= totalRev %>" data-active-revenue="<%= activeRev %>">
                                <td><strong><%= transitLine %></strong></td>
                                <td><%= route %></td>
                                <td><%= totalBookings %></td>
                                <td><%= activeBookings %></td>
                                <td>$<%= String.format("%.2f", totalRev) %></td>
                                <td>$<%= String.format("%.2f", activeRev) %></td>
                                <td>$<%= String.format("%.2f", avgFare) %></td>
                                <td>
                                    <span class="revenue-percentage"><%= String.format("%.1f", sharePercentage) %>%</span>
                                    <div class="revenue-bar" style="width: <%= Math.min(sharePercentage, 100) %>%;"></div>
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

            <%
                } else if ("customer".equals(analysisType)) {
                    // Revenue by Customer Analysis
            %>
                <div class="card">
                    <h2 class="card-title">
                        <i class="fas fa-users"></i>
                        Revenue by Customer
                    </h2>
                    
                    <%
                        double totalRevenue = 0.0;
                        double activeRevenue = 0.0;
                        int totalCustomers = 0;
                        
                        try {
                            Connection con = DBConnection.getConnection();
                            
                            // Get totals - CORRECTED
                            PreparedStatement totalPs = con.prepareStatement(
                                "SELECT SUM(Total_Fare) as total_revenue, COUNT(DISTINCT Username) as total_customers " +
                                "FROM reservation_data"
                            );
                            ResultSet totalRs = totalPs.executeQuery();
                            if (totalRs.next()) {
                                totalRevenue = totalRs.getDouble("total_revenue");
                                totalCustomers = totalRs.getInt("total_customers");
                            }
                            
                            // Get active revenue
                            PreparedStatement activePs = con.prepareStatement(
                                "SELECT SUM(Total_Fare) as active_revenue FROM reservation_data WHERE COALESCE(status, 'ACTIVE') = 'ACTIVE'"
                            );
                            ResultSet activeRs = activePs.executeQuery();
                            if (activeRs.next()) {
                                activeRevenue = activeRs.getDouble("active_revenue");
                            }
                            
                            totalRs.close();
                            totalPs.close();
                            activeRs.close();
                            activePs.close();
                            con.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    %>
                    
                    <div class="stats-summary">
                        <div class="stat-box">
                            <div class="stat-value">$<%= String.format("%.0f", totalRevenue) %></div>
                            <div class="stat-label">Total Revenue</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-value">$<%= String.format("%.0f", activeRevenue) %></div>
                            <div class="stat-label">Active Revenue</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-value"><%= totalCustomers %></div>
                            <div class="stat-label">Total Customers</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-value">$<%= totalCustomers > 0 ? String.format("%.0f", totalRevenue / totalCustomers) : "0" %></div>
                            <div class="stat-label">Avg Per Customer</div>
                        </div>
                    </div>
                    
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Customer</th>
                                <th>Total Bookings</th>
                                <th>Active Bookings</th>
                                <th>Total Revenue</th>
                                <th>Active Revenue</th>
                                <th>Average Fare</th>
                                <th>Customer Tier</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    PreparedStatement ps = con.prepareStatement(
                                        "SELECT Username, " +
                                        "COUNT(*) as total_bookings, " +
                                        "SUM(CASE WHEN COALESCE(status, 'ACTIVE') = 'ACTIVE' THEN 1 ELSE 0 END) as active_bookings, " +
                                        "SUM(Total_Fare) as total_revenue, " +
                                        "SUM(CASE WHEN COALESCE(status, 'ACTIVE') = 'ACTIVE' THEN Total_Fare ELSE 0 END) as active_revenue, " +
                                        "AVG(Total_Fare) as avg_fare " +
                                        "FROM reservation_data " +
                                        "GROUP BY Username ORDER BY total_revenue DESC"
                                    );
                                    ResultSet rs = ps.executeQuery();
                                    
                                    while (rs.next()) {
                                        String username = rs.getString("Username");
                                        int totalBookings = rs.getInt("total_bookings");
                                        int activeBookings = rs.getInt("active_bookings");
                                        double totalRev = rs.getDouble("total_revenue");
                                        double activeRev = rs.getDouble("active_revenue");
                                        double avgFare = rs.getDouble("avg_fare");
                                        
                                        String customerTier = "Standard";
                                        String tierColor = "#64748b";
                                        if (totalRev > 10000) {
                                            customerTier = "Platinum";
                                            tierColor = "#8b5cf6";
                                        } else if (totalRev > 5000) {
                                            customerTier = "Gold";
                                            tierColor = "#f59e0b";
                                        } else if (totalRev > 1000) {
                                            customerTier = "Silver";
                                            tierColor = "#64748b";
                                        }
                            %>
                            <tr>
                                <td><strong><%= username %></strong></td>
                                <td><%= totalBookings %></td>
                                <td><%= activeBookings %></td>
                                <td>$<%= String.format("%.2f", totalRev) %></td>
                                <td>$<%= String.format("%.2f", activeRev) %></td>
                                <td>$<%= String.format("%.2f", avgFare) %></td>
                                <td>
                                    <span style="background: <%= tierColor %>; color: white; padding: 4px 8px; border-radius: 6px; font-size: 0.8rem; font-weight: 600;">
                                        <%= customerTier %>
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
                </div>

            <%
                } else if ("time".equals(analysisType)) {
                    // Revenue by Time Period Analysis
            %>
                <div class="card">
                    <h2 class="card-title">
                        <i class="fas fa-calendar-alt"></i>
                        Revenue by Time Period
                    </h2>
                    
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Period</th>
                                <th>Total Bookings</th>
                                <th>Active Bookings</th>
                                <th>Total Revenue</th>
                                <th>Active Revenue</th>
                                <th>Average Fare</th>
                                <th>Growth Rate</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                String[] monthNames = {"", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                                      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
                                
                                try {
                                    Connection con = DBConnection.getConnection();
                                    PreparedStatement ps = con.prepareStatement(
                                        "SELECT YEAR(Date) as year, MONTH(Date) as month, " +
                                        "COUNT(*) as total_bookings, " +
                                        "SUM(CASE WHEN COALESCE(status, 'ACTIVE') = 'ACTIVE' THEN 1 ELSE 0 END) as active_bookings, " +
                                        "SUM(Total_Fare) as total_revenue, " +
                                        "SUM(CASE WHEN COALESCE(status, 'ACTIVE') = 'ACTIVE' THEN Total_Fare ELSE 0 END) as active_revenue, " +
                                        "AVG(Total_Fare) as avg_fare " +
                                        "FROM reservation_data " +
                                        "GROUP BY YEAR(Date), MONTH(Date) " +
                                        "ORDER BY year DESC, month DESC"
                                    );
                                    ResultSet rs = ps.executeQuery();
                                    
                                    double previousRevenue = 0.0;
                                    boolean firstRow = true;
                                    
                                    while (rs.next()) {
                                        int year = rs.getInt("year");
                                        int month = rs.getInt("month");
                                        int totalBookings = rs.getInt("total_bookings");
                                        int activeBookings = rs.getInt("active_bookings");
                                        double totalRevenue = rs.getDouble("total_revenue");
                                        double activeRevenue = rs.getDouble("active_revenue");
                                        double avgFare = rs.getDouble("avg_fare");
                                        
                                        double growth = 0.0;
                                        if (!firstRow && previousRevenue > 0) {
                                            growth = ((totalRevenue - previousRevenue) / previousRevenue) * 100;
                                        }
                            %>
                            <tr>
                                <td><strong><%= monthNames[month] %> <%= year %></strong></td>
                                <td><%= totalBookings %></td>
                                <td><%= activeBookings %></td>
                                <td>$<%= String.format("%.2f", totalRevenue) %></td>
                                <td>$<%= String.format("%.2f", activeRevenue) %></td>
                                <td>$<%= String.format("%.2f", avgFare) %></td>
                                <td>
                                    <% if (!firstRow) { %>
                                        <span style="color: <%= growth >= 0 ? "#10b981" : "#ef4444" %>; font-weight: 600;">
                                            <%= growth >= 0 ? "+" : "" %><%= String.format("%.1f", growth) %>%
                                        </span>
                                    <% } else { %>
                                        <span style="color: #64748b;">-</span>
                                    <% } %>
                                </td>
                            </tr>
                            <%
                                        previousRevenue = totalRevenue;
                                        firstRow = false;
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
            <%
                }
            %>
        </div>

        <!-- Profit Margin Analysis -->
        <div class="card">
            <h2 class="card-title">
                <i class="fas fa-chart-pie"></i>
                Profit Margin Analysis
            </h2>
            
            <div style="background: #f8fafc; padding: 24px; border-radius: 12px;">
                <%
                    double totalRevenue = 0.0;
                    double activeRevenue = 0.0;
                    double estimatedCosts = 0.0;
                    double profitMargin = 0.0;
                    
                    try {
                        Connection con = DBConnection.getConnection();
                        
                        // Get total and active revenue
                        PreparedStatement ps1 = con.prepareStatement(
                            "SELECT SUM(Total_Fare) as total_revenue FROM reservation_data"
                        );
                        ResultSet rs1 = ps1.executeQuery();
                        if (rs1.next()) {
                            totalRevenue = rs1.getDouble("total_revenue");
                        }
                        
                        PreparedStatement ps2 = con.prepareStatement(
                            "SELECT SUM(Total_Fare) as active_revenue FROM reservation_data WHERE COALESCE(status, 'ACTIVE') = 'ACTIVE'"
                        );
                        ResultSet rs2 = ps2.executeQuery();
                        if (rs2.next()) {
                            activeRevenue = rs2.getDouble("active_revenue");
                        }
                        
                        // Estimate costs as 70% of active revenue (only for active bookings)
                        estimatedCosts = activeRevenue * 0.70;
                        profitMargin = activeRevenue > 0 ? ((activeRevenue - estimatedCosts) / activeRevenue) * 100 : 0;
                        
                        rs1.close(); ps1.close();
                        rs2.close(); ps2.close();
                        con.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>
                
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px;">
                    <div>
                        <strong>Total Bookings Revenue:</strong><br>
                        <span style="color: #64748b; font-size: 1.5rem; font-weight: 700;">$<%= String.format("%.2f", totalRevenue) %></span>
                    </div>
                    
                    <div>
                        <strong>Active Revenue:</strong><br>
                        <span style="color: #10b981; font-size: 1.5rem; font-weight: 700;">$<%= String.format("%.2f", activeRevenue) %></span>
                    </div>
                    
                    <div>
                        <strong>Estimated Costs:</strong><br>
                        <span style="color: #ef4444; font-size: 1.5rem; font-weight: 700;">$<%= String.format("%.2f", estimatedCosts) %></span>
                    </div>
                    
                    <div>
                        <strong>Estimated Profit:</strong><br>
                        <span style="color: #8b5cf6; font-size: 1.5rem; font-weight: 700;">$<%= String.format("%.2f", activeRevenue - estimatedCosts) %></span>
                    </div>
                    
                    <div>
                        <strong>Profit Margin:</strong><br>
                        <span style="color: #f59e0b; font-size: 1.5rem; font-weight: 700;"><%= String.format("%.1f", profitMargin) %>%</span>
                    </div>
                    
                    <div>
                        <strong>Cancelled Revenue:</strong><br>
                        <span style="color: #dc2626; font-size: 1.5rem; font-weight: 700;">$<%= String.format("%.2f", totalRevenue - activeRevenue) %></span>
                    </div>
                </div>
                
                <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #e5e7eb;">
                    <strong>Financial Insights:</strong>
                    <ul style="margin-top: 8px; padding-left: 20px; color: #64748b;">
                        <li>Only active reservations contribute to actual revenue ($<%= String.format("%.0f", activeRevenue) %> vs $<%= String.format("%.0f", totalRevenue) %> total bookings)</li>
                        <li>Cancelled bookings represent $<%= String.format("%.0f", totalRevenue - activeRevenue) %> in lost revenue</li>
                        <li>Profit margin of <%= String.format("%.1f", profitMargin) %>% <%= profitMargin > 25 ? "indicates healthy" : profitMargin > 15 ? "shows reasonable" : "suggests room for improvement in" %> profitability</li>
                        <li>Focus on reducing cancellation rates to improve actual revenue realization</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <script>
        function showAllRevenue() {
            // This would toggle to show all revenue including cancelled
            updateStatusButtons('all');
        }

        function showActiveRevenue() {
            // This would filter to show only active revenue
            updateStatusButtons('active');
        }

        function updateStatusButtons(type) {
            document.querySelectorAll('.status-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            
            if (type === 'all') {
                document.querySelectorAll('.status-btn')[0].classList.add('active');
            } else {
                document.querySelectorAll('.status-btn')[1].classList.add('active');
            }
        }
    </script>
</body>
</html>