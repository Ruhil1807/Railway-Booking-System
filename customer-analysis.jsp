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
    if (analysisType == null) analysisType = "revenue";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Best Customers - IRCTC Admin</title>
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
            background: linear-gradient(135deg, #ef4444, #dc2626);
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

        .customer-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 24px;
            margin-bottom: 32px;
        }

        .customer-card {
            background: #f8fafc;
            border-radius: 16px;
            padding: 24px;
            position: relative;
            border: 2px solid transparent;
            transition: all 0.3s ease;
        }

        .customer-card:hover {
            border-color: #ef4444;
            transform: translateY(-2px);
        }

        .customer-rank {
            position: absolute;
            top: -12px;
            left: 20px;
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 700;
        }

        .customer-name {
            font-size: 1.3rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 16px;
            margin-top: 8px;
        }

        .customer-stats {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .stat-item {
            text-align: center;
        }

        .stat-value {
            font-size: 1.8rem;
            font-weight: 800;
            color: #ef4444;
        }

        .stat-label {
            color: #64748b;
            font-size: 0.85rem;
            font-weight: 600;
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

        .customer-badge {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .badge-platinum {
            background: #e0e7ff;
            color: #3730a3;
        }

        .badge-gold {
            background: #fef3c7;
            color: #92400e;
        }

        .badge-silver {
            background: #f3f4f6;
            color: #374151;
        }

        .badge-bronze {
            background: #fecaca;
            color: #991b1b;
        }

        .insights-section {
            background: #f8fafc;
            padding: 24px;
            border-radius: 12px;
            margin-top: 24px;
        }

        .insights-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 16px;
        }

        .insight-box {
            background: white;
            padding: 20px;
            border-radius: 8px;
            border-left: 4px solid #ef4444;
        }

        .insight-value {
            font-size: 1.5rem;
            font-weight: 700;
            color: #1e293b;
        }

        .insight-label {
            color: #64748b;
            font-size: 0.9rem;
        }

        .booking-timeline {
            background: white;
            border-radius: 12px;
            padding: 20px;
            margin-top: 20px;
        }

        .timeline-item {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 12px 0;
            border-bottom: 1px solid #e5e7eb;
        }

        .timeline-item:last-child {
            border-bottom: none;
        }

        .timeline-date {
            font-weight: 600;
            color: #374151;
            min-width: 100px;
        }

        .timeline-details {
            flex: 1;
        }

        .timeline-amount {
            font-weight: 700;
            color: #ef4444;
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
            .customer-grid {
                grid-template-columns: 1fr;
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
            <h1 class="page-title">Best Customers Analysis</h1>
            <p class="page-subtitle">Identify and analyze top-performing customers across multiple metrics</p>
        </div>

        <!-- Analysis Tabs -->
        <div class="analysis-tabs">
            <div class="tab-buttons">
                <a href="customer-analysis.jsp?analysisType=revenue" 
                   class="tab-btn <%= "revenue".equals(analysisType) ? "active" : "" %>">
                    <i class="fas fa-dollar-sign"></i>
                    By Revenue
                </a>
                <a href="customer-analysis.jsp?analysisType=frequency" 
                   class="tab-btn <%= "frequency".equals(analysisType) ? "active" : "" %>">
                    <i class="fas fa-repeat"></i>
                    By Frequency
                </a>
                <a href="customer-analysis.jsp?analysisType=loyalty" 
                   class="tab-btn <%= "loyalty".equals(analysisType) ? "active" : "" %>">
                    <i class="fas fa-heart"></i>
                    By Loyalty
                </a>
                <a href="customer-analysis.jsp?analysisType=lifetime" 
                   class="tab-btn <%= "lifetime".equals(analysisType) ? "active" : "" %>">
                    <i class="fas fa-crown"></i>
                    Lifetime Value
                </a>
            </div>

            <%
                if ("revenue".equals(analysisType)) {
                    // Top Customers by Revenue
            %>
                <div class="card">
                    <h2 class="card-title">
                        <i class="fas fa-trophy"></i>
                        Top Customers by Revenue
                    </h2>
                    
                    <div class="customer-grid">
                        <%
                            try {
                                Connection con = DBConnection.getConnection();
                                PreparedStatement ps = con.prepareStatement(
                                    "SELECT r.Username, c.First_Name, c.Last_Name, c.Email, " +
                                    "COUNT(*) as total_bookings, " +
                                    "SUM(CASE WHEN COALESCE(r.status, 'ACTIVE') = 'ACTIVE' THEN 1 ELSE 0 END) as active_bookings, " +
                                    "SUM(r.Total_Fare) as total_revenue, " +
                                    "SUM(CASE WHEN COALESCE(r.status, 'ACTIVE') = 'ACTIVE' THEN r.Total_Fare ELSE 0 END) as active_revenue, " +
                                    "AVG(r.Total_Fare) as avg_fare, MAX(r.Date) as last_booking " +
                                    "FROM reservation_data r " +
                                    "LEFT JOIN customer_data c ON r.Username = c.Username " +
                                    "GROUP BY r.Username, c.First_Name, c.Last_Name, c.Email " +
                                    "ORDER BY total_revenue DESC LIMIT 10"
                                );
                                ResultSet rs = ps.executeQuery();
                                
                                int rank = 1;
                                while (rs.next()) {
                                    String username = rs.getString("Username");
                                    String firstName = rs.getString("First_Name");
                                    String lastName = rs.getString("Last_Name");
                                    String email = rs.getString("Email");
                                    int totalBookings = rs.getInt("total_bookings");
                                    int activeBookings = rs.getInt("active_bookings");
                                    double totalRevenue = rs.getDouble("total_revenue");
                                    double activeRevenue = rs.getDouble("active_revenue");
                                    double avgFare = rs.getDouble("avg_fare");
                                    java.sql.Date lastBooking = rs.getDate("last_booking");
                                    
                                    String displayName = (firstName != null && lastName != null) ? 
                                                        firstName + " " + lastName : username;
                        %>
                        <div class="customer-card">
                            <div class="customer-rank">#<%= rank %></div>
                            <div class="customer-name"><%= displayName %></div>
                            <div style="color: #64748b; font-size: 0.9rem; margin-bottom: 16px;">
                                @<%= username %> 
                                <% if (email != null) { %>
                                    | <%= email %>
                                <% } %>
                            </div>
                            <div class="customer-stats">
                                <div class="stat-item">
                                    <div class="stat-value">$<%= String.format("%.0f", totalRevenue) %></div>
                                    <div class="stat-label">Total Revenue</div>
                                </div>
                                <div class="stat-item">
                                    <div class="stat-value"><%= totalBookings %></div>
                                    <div class="stat-label">Total Bookings</div>
                                </div>
                                <div class="stat-item">
                                    <div class="stat-value">$<%= String.format("%.0f", activeRevenue) %></div>
                                    <div class="stat-label">Active Revenue</div>
                                </div>
                                <div class="stat-item">
                                    <div class="stat-value"><%= activeBookings %></div>
                                    <div class="stat-label">Active Bookings</div>
                                </div>
                            </div>
                            <div style="margin-top: 16px; padding-top: 16px; border-top: 1px solid #e5e7eb; font-size: 0.85rem; color: #64748b;">
                                <strong>Last Booking:</strong> <%= lastBooking %><br>
                                <strong>Avg Fare:</strong> $<%= String.format("%.2f", avgFare) %><br>
                                <strong>Success Rate:</strong> <%= String.format("%.1f", (double)activeBookings / totalBookings * 100) %>%
                            </div>
                        </div>
                        <%
                                    rank++;
                                }
                                rs.close();
                                ps.close();
                                con.close();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        %>
                    </div>

            <%
                } else if ("frequency".equals(analysisType)) {
                    // Most Frequent Travelers
            %>
                <div class="card">
                    <h2 class="card-title">
                        <i class="fas fa-plane"></i>
                        Most Frequent Travelers
                    </h2>
                    
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Rank</th>
                                <th>Customer</th>
                                <th>Total Trips</th>
                                <th>Active Trips</th>
                                <th>Total Revenue</th>
                                <th>Success Rate</th>
                                <th>Frequency Tier</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    PreparedStatement ps = con.prepareStatement(
                                        "SELECT r.Username, c.First_Name, c.Last_Name, " +
                                        "COUNT(*) as trip_count, " +
                                        "SUM(CASE WHEN COALESCE(r.status, 'ACTIVE') = 'ACTIVE' THEN 1 ELSE 0 END) as active_trips, " +
                                        "SUM(r.Total_Fare) as total_revenue " +
                                        "FROM reservation_data r " +
                                        "LEFT JOIN customer_data c ON r.Username = c.Username " +
                                        "GROUP BY r.Username, c.First_Name, c.Last_Name " +
                                        "ORDER BY trip_count DESC LIMIT 15"
                                    );
                                    ResultSet rs = ps.executeQuery();
                                    
                                    int rank = 1;
                                    while (rs.next()) {
                                        String username = rs.getString("Username");
                                        String firstName = rs.getString("First_Name");
                                        String lastName = rs.getString("Last_Name");
                                        int tripCount = rs.getInt("trip_count");
                                        int activeTrips = rs.getInt("active_trips");
                                        double revenue = rs.getDouble("total_revenue");
                                        double successRate = (double)activeTrips / tripCount * 100;
                                        
                                        String displayName = (firstName != null && lastName != null) ? 
                                                            firstName + " " + lastName : username;
                                        
                                        String tier = "Regular";
                                        String tierClass = "badge-bronze";
                                        if (tripCount >= 10) {
                                            tier = "Platinum";
                                            tierClass = "badge-platinum";
                                        } else if (tripCount >= 6) {
                                            tier = "Gold";
                                            tierClass = "badge-gold";
                                        } else if (tripCount >= 3) {
                                            tier = "Silver";
                                            tierClass = "badge-silver";
                                        }
                            %>
                            <tr>
                                <td><strong>#<%= rank %></strong></td>
                                <td>
                                    <strong><%= displayName %></strong><br>
                                    <small style="color: #64748b;">@<%= username %></small>
                                </td>
                                <td><%= tripCount %></td>
                                <td><%= activeTrips %></td>
                                <td>$<%= String.format("%.2f", revenue) %></td>
                                <td>
                                    <span style="color: <%= successRate >= 50 ? "#10b981" : "#ef4444" %>; font-weight: 600;">
                                        <%= String.format("%.1f", successRate) %>%
                                    </span>
                                </td>
                                <td><span class="customer-badge <%= tierClass %>"><%= tier %></span></td>
                            </tr>
                            <%
                                        rank++;
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
                } else if ("loyalty".equals(analysisType)) {
                    // Customer Loyalty Analysis
            %>
                <div class="card">
                    <h2 class="card-title">
                        <i class="fas fa-heart"></i>
                        Customer Loyalty Analysis
                    </h2>
                    
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Customer</th>
                                <th>Member Since</th>
                                <th>Total Bookings</th>
                                <th>Active Bookings</th>
                                <th>Booking Span (Days)</th>
                                <th>Loyalty Score</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    PreparedStatement ps = con.prepareStatement(
                                        "SELECT r.Username, c.First_Name, c.Last_Name, " +
                                        "MIN(r.Date) as first_booking, MAX(r.Date) as last_booking, " +
                                        "COUNT(*) as total_bookings, " +
                                        "SUM(CASE WHEN COALESCE(r.status, 'ACTIVE') = 'ACTIVE' THEN 1 ELSE 0 END) as active_bookings, " +
                                        "SUM(r.Total_Fare) as total_revenue, " +
                                        "DATEDIFF(MAX(r.Date), MIN(r.Date)) as span_days " +
                                        "FROM reservation_data r " +
                                        "LEFT JOIN customer_data c ON r.Username = c.Username " +
                                        "GROUP BY r.Username, c.First_Name, c.Last_Name " +
                                        "ORDER BY span_days DESC, total_bookings DESC LIMIT 20"
                                    );
                                    ResultSet rs = ps.executeQuery();
                                    
                                    while (rs.next()) {
                                        String username = rs.getString("Username");
                                        String firstName = rs.getString("First_Name");
                                        String lastName = rs.getString("Last_Name");
                                        java.sql.Date firstBooking = rs.getDate("first_booking");
                                        java.sql.Date lastBooking = rs.getDate("last_booking");
                                        int totalBookings = rs.getInt("total_bookings");
                                        int activeBookings = rs.getInt("active_bookings");
                                        double totalRevenue = rs.getDouble("total_revenue");
                                        int spanDays = rs.getInt("span_days");
                                        
                                        String displayName = (firstName != null && lastName != null) ? 
                                                            firstName + " " + lastName : username;
                                        
                                        // Calculate loyalty score (combination of span, bookings, and revenue)
                                        double loyaltyScore = (spanDays * 0.3) + (totalBookings * 20) + (totalRevenue * 0.01);
                                        
                                        String status = "New";
                                        String statusClass = "badge-bronze";
                                        if (loyaltyScore >= 500) {
                                            status = "VIP Loyal";
                                            statusClass = "badge-platinum";
                                        } else if (loyaltyScore >= 200) {
                                            status = "Loyal";
                                            statusClass = "badge-gold";
                                        } else if (loyaltyScore >= 100) {
                                            status = "Regular";
                                            statusClass = "badge-silver";
                                        }
                            %>
                            <tr>
                                <td>
                                    <strong><%= displayName %></strong><br>
                                    <small style="color: #64748b;">@<%= username %></small>
                                </td>
                                <td><%= firstBooking %></td>
                                <td><%= totalBookings %></td>
                                <td><%= activeBookings %></td>
                                <td><%= spanDays %> days</td>
                                <td><%= String.format("%.0f", loyaltyScore) %></td>
                                <td><span class="customer-badge <%= statusClass %>"><%= status %></span></td>
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
                } else if ("lifetime".equals(analysisType)) {
                    // Customer Lifetime Value
            %>
                <div class="card">
                    <h2 class="card-title">
                        <i class="fas fa-crown"></i>
                        Customer Lifetime Value Analysis
                    </h2>
                    
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Customer</th>
                                <th>Total Value</th>
                                <th>Active Value</th>
                                <th>Bookings</th>
                                <th>Avg Order Value</th>
                                <th>Customer Since</th>
                                <th>Projected Annual Value</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    PreparedStatement ps = con.prepareStatement(
                                        "SELECT r.Username, c.First_Name, c.Last_Name, " +
                                        "SUM(r.Total_Fare) as lifetime_value, " +
                                        "SUM(CASE WHEN COALESCE(r.status, 'ACTIVE') = 'ACTIVE' THEN r.Total_Fare ELSE 0 END) as active_value, " +
                                        "COUNT(*) as total_bookings, " +
                                        "AVG(r.Total_Fare) as avg_order_value, " +
                                        "MIN(r.Date) as customer_since, " +
                                        "DATEDIFF(CURDATE(), MIN(r.Date)) as days_as_customer " +
                                        "FROM reservation_data r " +
                                        "LEFT JOIN customer_data c ON r.Username = c.Username " +
                                        "GROUP BY r.Username, c.First_Name, c.Last_Name " +
                                        "ORDER BY lifetime_value DESC LIMIT 20"
                                    );
                                    ResultSet rs = ps.executeQuery();
                                    
                                    while (rs.next()) {
                                        String username = rs.getString("Username");
                                        String firstName = rs.getString("First_Name");
                                        String lastName = rs.getString("Last_Name");
                                        double lifetimeValue = rs.getDouble("lifetime_value");
                                        double activeValue = rs.getDouble("active_value");
                                        int totalBookings = rs.getInt("total_bookings");
                                        double avgOrderValue = rs.getDouble("avg_order_value");
                                        java.sql.Date customerSince = rs.getDate("customer_since");
                                        int daysAsCustomer = rs.getInt("days_as_customer");
                                        
                                        String displayName = (firstName != null && lastName != null) ? 
                                                            firstName + " " + lastName : username;
                                        
                                        // Project annual value based on current activity (use active value for realistic projection)
                                        double annualProjection = daysAsCustomer > 0 ? (activeValue / daysAsCustomer) * 365 : 0;
                            %>
                            <tr>
                                <td>
                                    <strong><%= displayName %></strong><br>
                                    <small style="color: #64748b;">@<%= username %></small>
                                </td>
                                <td>$<%= String.format("%.2f", lifetimeValue) %></td>
                                <td>$<%= String.format("%.2f", activeValue) %></td>
                                <td><%= totalBookings %></td>
                                <td>$<%= String.format("%.2f", avgOrderValue) %></td>
                                <td><%= customerSince %></td>
                                <td>$<%= String.format("%.0f", annualProjection) %></td>
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
                    
                    <!-- Customer Booking Timeline -->
                    <div class="booking-timeline">
                        <h3 style="margin-bottom: 16px; color: #374151;">Recent Customer Activity</h3>
                        <%
                            try {
                                Connection con = DBConnection.getConnection();
                                PreparedStatement ps = con.prepareStatement(
                                    "SELECT r.Username, c.First_Name, c.Last_Name, r.Date, r.Total_Fare, r.Transit_line_name, r.status " +
                                    "FROM reservation_data r " +
                                    "LEFT JOIN customer_data c ON r.Username = c.Username " +
                                    "ORDER BY r.Date DESC LIMIT 10"
                                );
                                ResultSet rs = ps.executeQuery();
                                
                                while (rs.next()) {
                                    String username = rs.getString("Username");
                                    String firstName = rs.getString("First_Name");
                                    String lastName = rs.getString("Last_Name");
                                    java.sql.Date bookingDate = rs.getDate("Date");
                                    double fare = rs.getDouble("Total_Fare");
                                    String transitLine = rs.getString("Transit_line_name");
                                    String status = rs.getString("status");
                                    if (status == null) status = "ACTIVE";
                                    
                                    String displayName = (firstName != null && lastName != null) ? 
                                                        firstName + " " + lastName : username;
                        %>
                        <div class="timeline-item">
                            <div class="timeline-date"><%= bookingDate %></div>
                            <div class="timeline-details">
                                <strong><%= displayName %></strong> booked <%= transitLine %><br>
                                <small style="color: #64748b;">Status: 
                                    <span style="color: <%= "ACTIVE".equals(status) ? "#10b981" : "#ef4444" %>; font-weight: 600;">
                                        <%= status %>
                                    </span>
                                </small>
                            </div>
                            <div class="timeline-amount">$<%= String.format("%.2f", fare) %></div>
                        </div>
                        <%
                                }
                                rs.close();
                                ps.close();
                                con.close();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        %>
                    </div>
                </div>
            <%
                }
            %>
        </div>

        <!-- Customer Insights -->
        <div class="card">
            <h2 class="card-title">
                <i class="fas fa-lightbulb"></i>
                Customer Insights & Recommendations
            </h2>
            
            <div class="insights-section">
                <h3 style="margin-bottom: 16px; color: #374151;">Key Customer Metrics</h3>
                
                <%
                    // Calculate overall customer metrics
                    int totalCustomers = 0;
                    double avgCustomerValue = 0.0;
                    double avgActiveCustomerValue = 0.0;
                    double avgBookingsPerCustomer = 0.0;
                    int repeatCustomers = 0;
                    double cancellationRate = 0.0;
                    
                    try {
                        Connection con = DBConnection.getConnection();
                        
                        // Total customers
                        PreparedStatement ps1 = con.prepareStatement(
                            "SELECT COUNT(DISTINCT Username) as total_customers FROM reservation_data"
                        );
                        ResultSet rs1 = ps1.executeQuery();
                        if (rs1.next()) totalCustomers = rs1.getInt("total_customers");
                        
                        // Average customer value
                        PreparedStatement ps2 = con.prepareStatement(
                            "SELECT AVG(customer_value) as avg_value, AVG(active_value) as avg_active_value, AVG(customer_bookings) as avg_bookings " +
                            "FROM (SELECT SUM(Total_Fare) as customer_value, " +
                            "SUM(CASE WHEN COALESCE(status, 'ACTIVE') = 'ACTIVE' THEN Total_Fare ELSE 0 END) as active_value, " +
                            "COUNT(*) as customer_bookings FROM reservation_data GROUP BY Username) as customer_stats"
                        );
                        ResultSet rs2 = ps2.executeQuery();
                        if (rs2.next()) {
                            avgCustomerValue = rs2.getDouble("avg_value");
                            avgActiveCustomerValue = rs2.getDouble("avg_active_value");
                            avgBookingsPerCustomer = rs2.getDouble("avg_bookings");
                        }
                        
                        // Repeat customers
                        PreparedStatement ps3 = con.prepareStatement(
                            "SELECT COUNT(*) as repeat_customers FROM " +
                            "(SELECT Username FROM reservation_data GROUP BY Username HAVING COUNT(*) > 1) as repeats"
                        );
                        ResultSet rs3 = ps3.executeQuery();
                        if (rs3.next()) repeatCustomers = rs3.getInt("repeat_customers");
                        
                        // Cancellation rate
                        PreparedStatement ps4 = con.prepareStatement(
                            "SELECT (SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) as cancel_rate " +
                            "FROM reservation_data"
                        );
                        ResultSet rs4 = ps4.executeQuery();
                        if (rs4.next()) cancellationRate = rs4.getDouble("cancel_rate");
                        
                        rs1.close(); ps1.close();
                        rs2.close(); ps2.close();
                        rs3.close(); ps3.close();
                        rs4.close(); ps4.close();
                        con.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>
                
                <div class="insights-grid">
                    <div class="insight-box">
                        <div class="insight-value"><%= totalCustomers %></div>
                        <div class="insight-label">Total Customers</div>
                    </div>
                    
                    <div class="insight-box">
                        <div class="insight-value">$<%= String.format("%.0f", avgCustomerValue) %></div>
                        <div class="insight-label">Avg Customer Value</div>
                    </div>
                    
                    <div class="insight-box">
                        <div class="insight-value">$<%= String.format("%.0f", avgActiveCustomerValue) %></div>
                        <div class="insight-label">Avg Active Value</div>
                    </div>
                    
                    <div class="insight-box">
                        <div class="insight-value"><%= String.format("%.1f", avgBookingsPerCustomer) %></div>
                        <div class="insight-label">Avg Bookings per Customer</div>
                    </div>
                    
                    <div class="insight-box">
                        <div class="insight-value"><%= totalCustomers > 0 ? String.format("%.1f", (double)repeatCustomers / totalCustomers * 100) : "0" %>%</div>
                        <div class="insight-label">Repeat Customer Rate</div>
                    </div>
                    
                    <div class="insight-box">
                        <div class="insight-value"><%= String.format("%.1f", cancellationRate) %>%</div>
                        <div class="insight-label">Cancellation Rate</div>
                    </div>
                </div>
                
                <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #e5e7eb;">
                    <strong>Strategic Recommendations:</strong>
                    <ul style="margin-top: 8px; padding-left: 20px; color: #64748b;">
                        <li><strong>High Cancellation Rate:</strong> <%= String.format("%.1f", cancellationRate) %>% cancellation rate suggests need for booking flexibility or better customer support</li>
                        <li><strong>Customer Retention:</strong> Focus on converting one-time bookers to repeat customers with loyalty programs</li>
                        <li><strong>Revenue Recovery:</strong> Implement policies to reduce cancellations and recover lost revenue</li>
                        <li><strong>VIP Program:</strong> Create exclusive benefits for high-value customers (>$10K annual spend)</li>
                        <li><strong>Win-back Campaign:</strong> Re-engage customers who cancelled their bookings with incentives</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</body>
</html>