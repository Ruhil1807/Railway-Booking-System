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
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transit Analysis - IRCTC Admin</title>
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

        .top-routes-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 24px;
            margin-bottom: 32px;
        }

        .route-card {
            background: #f8fafc;
            border-radius: 16px;
            padding: 24px;
            position: relative;
            border: 2px solid transparent;
            transition: all 0.3s ease;
        }

        .route-card:hover {
            border-color: #06b6d4;
            transform: translateY(-2px);
        }

        .route-rank {
            position: absolute;
            top: -12px;
            left: 20px;
            background: linear-gradient(135deg, #06b6d4, #0891b2);
            color: white;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 700;
        }

        .route-name {
            font-size: 1.3rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 16px;
            margin-top: 8px;
        }

        .route-stats {
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
            color: #06b6d4;
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

        .performance-bar {
            background: linear-gradient(135deg, #06b6d4, #0891b2);
            height: 8px;
            border-radius: 4px;
            margin-top: 8px;
        }

        .performance-indicator {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .perf-excellent {
            background: #dcfce7;
            color: #166534;
        }

        .perf-good {
            background: #fef3c7;
            color: #92400e;
        }

        .perf-average {
            background: #e0e7ff;
            color: #3730a3;
        }

        .perf-poor {
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
            border-left: 4px solid #06b6d4;
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

        .capacity-chart {
            background: white;
            border-radius: 12px;
            padding: 20px;
            margin-top: 20px;
        }

        .capacity-bar-container {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 16px;
        }

        .capacity-bar {
            flex: 1;
            height: 20px;
            background: #e5e7eb;
            border-radius: 10px;
            overflow: hidden;
        }

        .capacity-fill {
            height: 100%;
            background: linear-gradient(135deg, #06b6d4, #0891b2);
            border-radius: 10px;
            transition: width 0.3s ease;
        }

        .capacity-label {
            min-width: 120px;
            font-weight: 600;
            color: #374151;
        }

        .capacity-percentage {
            min-width: 60px;
            text-align: right;
            font-weight: 700;
            color: #06b6d4;
        }

        @media (max-width: 768px) {
            .main-container {
                padding: 20px 1rem;
            }
            .top-routes-grid {
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
            <h1 class="page-title">Transit Line Analysis</h1>
            <p class="page-subtitle">Top 5 most active transit lines with performance metrics and capacity analysis</p>
        </div>

     <!-- Top 5 Most Active Routes -->
        <div class="card">
            <h2 class="card-title">
                <i class="fas fa-trophy"></i>
                Top 5 Most Active Routes
            </h2>
            
            <div class="top-routes-grid">
                <%
                    try {
                        Connection con = DBConnection.getConnection();
                        // FIXED: JOIN reservation_data with train_schedule_data to get routes
                        PreparedStatement ps = con.prepareStatement(
                            "SELECT CONCAT(t.Origin, ' → ', t.Destination) as route, " +
                            "t.Origin, t.Destination, COUNT(*) as trip_count, " +
                            "SUM(r.Total_Fare) as total_revenue, AVG(r.Total_Fare) as avg_fare " +
                            "FROM reservation_data r " +
                            "JOIN train_schedule_data t ON r.Transit_line_name = t.Transit_line_name " +
                            "WHERE COALESCE(r.status, 'ACTIVE') = 'ACTIVE' " +
                            "GROUP BY t.Origin, t.Destination " +
                            "ORDER BY trip_count DESC LIMIT 5"
                        );
                        ResultSet rs = ps.executeQuery();
                        
                        int rank = 1;
                        while (rs.next()) {
                            String route = rs.getString("route");
                            int tripCount = rs.getInt("trip_count");
                            double revenue = rs.getDouble("total_revenue");
                            double avgFare = rs.getDouble("avg_fare");
                %>
                <div class="route-card">
                    <div class="route-rank">#<%= rank %></div>
                    <div class="route-name"><%= route %></div>
                    <div class="route-stats">
                        <div class="stat-item">
                            <div class="stat-value"><%= tripCount %></div>
                            <div class="stat-label">Total Trips</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">$<%= String.format("%.0f", revenue) %></div>
                            <div class="stat-label">Revenue</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">$<%= String.format("%.0f", avgFare) %></div>
                            <div class="stat-label">Avg Fare</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value"><%= String.format("%.1f", revenue / tripCount) %></div>
                            <div class="stat-label">Per Trip</div>
                        </div>
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
                        out.println("Error: " + e.getMessage());
                    }
                %>
            </div>
        </div>

        <!-- Route Performance Analysis -->
        <div class="card">
            <h2 class="card-title">
                <i class="fas fa-chart-line"></i>
                Route Performance Metrics
            </h2>
            
            <table class="table">
                <thead>
                    <tr>
                        <th>Route</th>
                        <th>Usage Frequency</th>
                        <th>Revenue</th>
                        <th>Performance Score</th>
                        <th>Market Share</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Connection con = DBConnection.getConnection();
                            
                            // Get total trips for market share calculation
                            PreparedStatement totalPs = con.prepareStatement(
                                "SELECT COUNT(*) as total_trips FROM reservation_data WHERE COALESCE(status, 'ACTIVE') = 'ACTIVE'"
                            );
                            ResultSet totalRs = totalPs.executeQuery();
                            int totalTrips = 0;
                            if (totalRs.next()) totalTrips = totalRs.getInt("total_trips");
                            
                            // FIXED: JOIN to get actual routes
                            PreparedStatement ps = con.prepareStatement(
                                "SELECT CONCAT(t.Origin, ' → ', t.Destination) as route, " +
                                "COUNT(*) as frequency, SUM(r.Total_Fare) as revenue, AVG(r.Total_Fare) as avg_fare " +
                                "FROM reservation_data r " +
                                "JOIN train_schedule_data t ON r.Transit_line_name = t.Transit_line_name " +
                                "WHERE COALESCE(r.status, 'ACTIVE') = 'ACTIVE' " +
                                "GROUP BY t.Origin, t.Destination " +
                                "ORDER BY frequency DESC LIMIT 15"
                            );
                            ResultSet rs = ps.executeQuery();
                            
                            while (rs.next()) {
                                String route = rs.getString("route");
                                int frequency = rs.getInt("frequency");
                                double revenue = rs.getDouble("revenue");
                                double avgFare = rs.getDouble("avg_fare");
                                
                                // Calculate performance score (frequency + revenue factor)
                                double performanceScore = (frequency * 10) + (revenue / 100);
                                double marketShare = totalTrips > 0 ? (double)frequency / totalTrips * 100 : 0;
                                
                                String status = "Poor";
                                String statusClass = "perf-poor";
                                if (performanceScore >= 100) {
                                    status = "Excellent";
                                    statusClass = "perf-excellent";
                                } else if (performanceScore >= 50) {
                                    status = "Good";
                                    statusClass = "perf-good";
                                } else if (performanceScore >= 25) {
                                    status = "Average";
                                    statusClass = "perf-average";
                                }
                    %>
                    <tr>
                        <td><strong><%= route %></strong></td>
                        <td><%= frequency %> trips</td>
                        <td>$<%= String.format("%.2f", revenue) %></td>
                        <td>
                            <%= String.format("%.0f", performanceScore) %>
                            <div class="performance-bar" style="width: <%= Math.min(performanceScore / 2, 100) %>%;"></div>
                        </td>
                        <td><%= String.format("%.1f", marketShare) %>%</td>
                        <td><span class="performance-indicator <%= statusClass %>"><%= status %></span></td>
                    </tr>
                    <%
                            }
                            totalRs.close();
                            totalPs.close();
                            rs.close();
                            ps.close();
                            con.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                            out.println("Error: " + e.getMessage());
                        }
                    %>
                </tbody>
            </table>
        </div>

        <!-- Capacity Utilization -->
        <div class="card">
            <h2 class="card-title">
                <i class="fas fa-tachometer-alt"></i>
                Route Capacity Analysis
            </h2>
            
            <div class="capacity-chart">
                <h3 style="margin-bottom: 20px; color: #374151;">Route Capacity Analysis</h3>
                <%
                    try {
                        Connection con = DBConnection.getConnection();
                        // FIXED: JOIN to show route capacity
                        PreparedStatement ps = con.prepareStatement(
                            "SELECT CONCAT(t.Origin, ' → ', t.Destination) as route, COUNT(*) as bookings " +
                            "FROM reservation_data r " +
                            "JOIN train_schedule_data t ON r.Transit_line_name = t.Transit_line_name " +
                            "WHERE COALESCE(r.status, 'ACTIVE') = 'ACTIVE' " +
                            "GROUP BY t.Origin, t.Destination " +
                            "ORDER BY bookings DESC LIMIT 8"
                        );
                        ResultSet rs = ps.executeQuery();
                        
                        while (rs.next()) {
                            String route = rs.getString("route");
                            int bookings = rs.getInt("bookings");
                            
                            // Assume capacity of 30 bookings per route for optimal operation
                            int assumedCapacity = 15; // Assuming each route can handle 15 bookings optimally
                            double utilizationPercent = Math.min((double)bookings / assumedCapacity * 100, 100);
                %>
                <div class="capacity-bar-container">
                    <div class="capacity-label"><%= route %></div>
                    <div class="capacity-bar">
                        <div class="capacity-fill" style="width: <%= utilizationPercent %>%;"></div>
                    </div>
                    <div class="capacity-percentage"><%= String.format("%.0f", utilizationPercent) %>%</div>
                </div>
                <%
                        }
                        rs.close();
                        ps.close();
                        con.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("Error: " + e.getMessage());
                    }
                %>
            </div>
        </div>

        <!-- Transit Insights -->
        <div class="card">
            <h2 class="card-title">
                <i class="fas fa-lightbulb"></i>
                Transit System Insights
            </h2>
            
            <div class="insights-section">
                <h3 style="margin-bottom: 16px; color: #374151;">Key Transit Metrics</h3>
                
                <%
                    // Calculate overall transit metrics with actual data
                    int totalRoutes = 0;
                    double avgRouteRevenue = 0.0;
                    int avgTripsPerRoute = 0;
                    String mostPopularOrigin = "";
                    String mostPopularDestination = "";
                    int totalReservations = 0;
                    
                    try {
                        Connection con = DBConnection.getConnection();
                        
                        // Total unique routes
                        PreparedStatement ps1 = con.prepareStatement(
                            "SELECT COUNT(DISTINCT CONCAT(t.Origin, '-', t.Destination)) as total_routes " +
                            "FROM reservation_data r " +
                            "JOIN train_schedule_data t ON r.Transit_line_name = t.Transit_line_name " +
                            "WHERE COALESCE(r.status, 'ACTIVE') = 'ACTIVE'"
                        );
                        ResultSet rs1 = ps1.executeQuery();
                        if (rs1.next()) totalRoutes = rs1.getInt("total_routes");
                        
                        // Total reservations
                        PreparedStatement ps5 = con.prepareStatement(
                            "SELECT COUNT(*) as total_reservations FROM reservation_data WHERE COALESCE(status, 'ACTIVE') = 'ACTIVE'"
                        );
                        ResultSet rs5 = ps5.executeQuery();
                        if (rs5.next()) totalReservations = rs5.getInt("total_reservations");
                        
                        // Average route metrics
                        PreparedStatement ps2 = con.prepareStatement(
                            "SELECT AVG(route_revenue) as avg_revenue, AVG(route_trips) as avg_trips FROM " +
                            "(SELECT SUM(r.Total_Fare) as route_revenue, COUNT(*) as route_trips " +
                            "FROM reservation_data r " +
                            "JOIN train_schedule_data t ON r.Transit_line_name = t.Transit_line_name " +
                            "WHERE COALESCE(r.status, 'ACTIVE') = 'ACTIVE' " +
                            "GROUP BY t.Origin, t.Destination) as route_stats"
                        );
                        ResultSet rs2 = ps2.executeQuery();
                        if (rs2.next()) {
                            avgRouteRevenue = rs2.getDouble("avg_revenue");
                            avgTripsPerRoute = rs2.getInt("avg_trips");
                        }
                        
                        // Most popular origin
                        PreparedStatement ps3 = con.prepareStatement(
                            "SELECT t.Origin, COUNT(*) as count " +
                            "FROM reservation_data r " +
                            "JOIN train_schedule_data t ON r.Transit_line_name = t.Transit_line_name " +
                            "WHERE COALESCE(r.status, 'ACTIVE') = 'ACTIVE' " +
                            "GROUP BY t.Origin ORDER BY count DESC LIMIT 1"
                        );
                        ResultSet rs3 = ps3.executeQuery();
                        if (rs3.next()) mostPopularOrigin = rs3.getString("Origin");
                        
                        // Most popular destination
                        PreparedStatement ps4 = con.prepareStatement(
                            "SELECT t.Destination, COUNT(*) as count " +
                            "FROM reservation_data r " +
                            "JOIN train_schedule_data t ON r.Transit_line_name = t.Transit_line_name " +
                            "WHERE COALESCE(r.status, 'ACTIVE') = 'ACTIVE' " +
                            "GROUP BY t.Destination ORDER BY count DESC LIMIT 1"
                        );
                        ResultSet rs4 = ps4.executeQuery();
                        if (rs4.next()) mostPopularDestination = rs4.getString("Destination");
                        
                        rs1.close(); ps1.close();
                        rs2.close(); ps2.close();
                        rs3.close(); ps3.close();
                        rs4.close(); ps4.close();
                        rs5.close(); ps5.close();
                        con.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("Error: " + e.getMessage());
                    }
                %>
                
                <div class="insights-grid">
                    <div class="insight-box">
                        <div class="insight-value"><%= totalRoutes %></div>
                        <div class="insight-label">Active Routes</div>
                    </div>
                    
                    <div class="insight-box">
                        <div class="insight-value">$<%= String.format("%.0f", avgRouteRevenue) %></div>
                        <div class="insight-label">Avg Route Revenue</div>
                    </div>
                    
                    <div class="insight-box">
                        <div class="insight-value"><%= avgTripsPerRoute %></div>
                        <div class="insight-label">Avg Trips per Route</div>
                    </div>
                    
                    <div class="insight-box">
                        <div class="insight-value"><%= totalReservations %></div>
                        <div class="insight-label">Total Reservations</div>
                    </div>
                    
                    <div class="insight-box">
                        <div class="insight-value" style="font-size: 1rem;"><%= mostPopularOrigin %></div>
                        <div class="insight-label">Top Origin Station</div>
                    </div>
                    
                    <div class="insight-box">
                        <div class="insight-value" style="font-size: 1rem;"><%= mostPopularDestination %></div>
                        <div class="insight-label">Top Destination</div>
                    </div>
                </div>
                
                <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #e5e7eb;">
                    <strong>Operational Recommendations:</strong>
                    <ul style="margin-top: 8px; padding-left: 20px; color: #64748b;">
                        <li><strong>Capacity Optimization:</strong> Increase frequency on routes with >80% utilization</li>
                        <li><strong>Revenue Enhancement:</strong> Implement dynamic pricing for high-demand routes</li>
                        <li><strong>Route Planning:</strong> Consider new routes connecting <%= mostPopularOrigin %> and <%= mostPopularDestination %></li>
                        <li><strong>Performance Monitoring:</strong> Review underperforming routes for optimization opportunities</li>
                        <li><strong>Customer Experience:</strong> Focus service improvements on top 5 busiest routes</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</body>
</html>