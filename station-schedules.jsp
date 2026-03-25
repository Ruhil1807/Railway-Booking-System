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
    String originFilter = request.getParameter("origin");
    String destinationFilter = request.getParameter("destination");
    String dateFilter = request.getParameter("date");
    String searchQuery = request.getParameter("search");
    String viewType = request.getParameter("view");
    if (viewType == null) viewType = "all";

    // Handle export functionality
    if ("export".equals(action)) {
        try {
            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", "attachment; filename=\"station_schedules_" + new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) + ".csv\"");
            
            PrintWriter csvWriter = response.getWriter();
            csvWriter.println("Transit Line,Origin,Destination,Stops,Fare,Departure,Arrival,Status");
            
            Connection con = DBConnection.getConnection();
            StringBuilder queryBuilder = new StringBuilder("SELECT * FROM train_schedule_data WHERE 1=1");
            
            // Apply filters for export
            if (originFilter != null && !originFilter.trim().isEmpty()) {
                queryBuilder.append(" AND Origin LIKE ?");
            }
            if (destinationFilter != null && !destinationFilter.trim().isEmpty()) {
                queryBuilder.append(" AND Destination LIKE ?");
            }
            if (dateFilter != null && !dateFilter.trim().isEmpty()) {
                queryBuilder.append(" AND DATE(Departure_datetime) = ?");
            }
            queryBuilder.append(" ORDER BY Departure_datetime");
            
            PreparedStatement ps = con.prepareStatement(queryBuilder.toString());
            int paramIndex = 1;
            if (originFilter != null && !originFilter.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + originFilter + "%");
            }
            if (destinationFilter != null && !destinationFilter.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + destinationFilter + "%");
            }
            if (dateFilter != null && !dateFilter.trim().isEmpty()) {
                ps.setString(paramIndex++, dateFilter);
            }
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                csvWriter.printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%.2f\",\"%s\",\"%s\",\"Active\"%n",
                    rs.getString("Transit_line_name"),
                    rs.getString("Origin"),
                    rs.getString("Destination"),
                    rs.getString("Stops") != null ? rs.getString("Stops") : "",
                    rs.getDouble("Fare"),
                    rs.getTimestamp("Departure_datetime"),
                    rs.getTimestamp("Arrival_datetime")
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
    <title>Station Schedules - IRCTC Professional Portal</title>
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
            --accent-purple: #8B5CF6;
            --light-purple: #F3F4F6;
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
            color: var(--accent-purple);
        }

        .navbar-brand i {
            font-size: 2rem;
            margin-right: 12px;
            background: linear-gradient(135deg, var(--accent-purple), #A855F7);
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
            background: linear-gradient(90deg, var(--accent-purple), #A855F7, #C084FC);
        }

        .page-title {
            font-size: 3rem;
            font-weight: 900;
            background: linear-gradient(135deg, var(--primary-blue), var(--accent-purple));
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

        .view-tabs {
            display: flex;
            gap: 8px;
            background: var(--background-light);
            padding: 6px;
            border-radius: 12px;
            margin-bottom: 24px;
        }

        .view-tab {
            padding: 12px 20px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .view-tab.active {
            background: var(--accent-purple);
            color: white;
            box-shadow: var(--shadow-soft);
        }

        .view-tab:hover {
            background: rgba(139, 92, 246, 0.1);
            color: var(--accent-purple);
            text-decoration: none;
        }

        .view-tab.active:hover {
            background: var(--accent-purple);
            color: white;
        }

        .filters-section {
            background: var(--background-light);
            padding: 24px;
            border-radius: 16px;
            margin-bottom: 32px;
        }

        .filters-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 20px;
        }

        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .filter-label {
            font-weight: 600;
            color: var(--text-primary);
            font-size: 0.9rem;
        }

        .filter-input, .filter-select {
            padding: 12px 16px;
            border: 2px solid var(--border-light);
            border-radius: 8px;
            font-size: 1rem;
            transition: all 0.3s ease;
            background: white;
        }

        .filter-input:focus, .filter-select:focus {
            outline: none;
            border-color: var(--accent-purple);
            box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
        }

        .filter-actions {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            align-items: center;
        }

        .btn {
            padding: 12px 20px;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            font-size: 0.95rem;
            box-shadow: var(--shadow-soft);
        }

        .btn-primary { background: linear-gradient(135deg, var(--accent-purple), #A855F7); color: white; }
        .btn-success { background: linear-gradient(135deg, var(--success-green), #059669); color: white; }
        .btn-warning { background: linear-gradient(135deg, var(--warning-orange), #D97706); color: white; }
        .btn-danger { background: linear-gradient(135deg, var(--danger-red), #DC2626); color: white; }
        .btn-secondary { background: linear-gradient(135deg, #6B7280, #4B5563); color: white; }
        .btn-outline { background: white; color: var(--accent-purple); border: 2px solid var(--accent-purple); }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
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
            color: var(--accent-purple);
        }

        .stat-label {
            color: var(--text-secondary);
            font-weight: 600;
            font-size: 0.9rem;
        }

        .schedules-table {
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

        .route-info {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .route-main {
            font-weight: 700;
            color: var(--primary-blue);
            font-size: 1.1rem;
        }

        .route-details {
            font-size: 0.85rem;
            color: var(--text-secondary);
        }

        .schedule-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .badge-express { background: linear-gradient(135deg, #FEE2E2, #FECACA); color: #991B1B; }
        .badge-local { background: linear-gradient(135deg, #DBEAFE, #BFDBFE); color: #1E40AF; }
        .badge-superfast { background: linear-gradient(135deg, #FEF3C7, #FDE68A); color: #92400E; }

        .fare-display {
            font-weight: 800;
            color: var(--success-green);
            font-size: 1.2rem;
        }

        .time-info {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .time-main {
            font-weight: 700;
            color: var(--primary-blue);
            font-size: 1rem;
        }

        .time-date {
            font-size: 0.8rem;
            color: var(--text-secondary);
        }

        .duration-badge {
            background: linear-gradient(135deg, #F3E8FF, #E9D5FF);
            color: #7C2D12;
            padding: 4px 8px;
            border-radius: 8px;
            font-size: 0.75rem;
            font-weight: 600;
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

        .station-summary {
            background: var(--background-light);
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 20px;
        }

        .station-name {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--primary-blue);
            margin-bottom: 8px;
        }

        .station-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 12px;
            font-size: 0.9rem;
            color: var(--text-secondary);
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
            
            .filters-grid {
                grid-template-columns: 1fr;
            }
            
            .filter-actions {
                justify-content: stretch;
                flex-direction: column;
            }
            
            .view-tabs {
                flex-direction: column;
            }
            
            .section-header {
                flex-direction: column;
                gap: 16px;
                align-items: stretch;
            }
            
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar">
        <div class="navbar-content">
            <a href="rep-dashboard.jsp" class="navbar-brand">
                <i class="fas fa-map-marker-alt"></i>
                <div class="brand-text">
                    <span class="brand-main">Station Schedules</span>
                    <span class="brand-sub">Train Schedule Management</span>
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
            <h1 class="page-title">Station Schedules</h1>
            <p class="page-subtitle">Generate lists of train schedules for specific stations as origin or destination</p>
        </div>

        <!-- Alert Messages -->
        <% if (!message.isEmpty()) { %>
            <div class="alert <%= messageType %>">
                <i class="fas fa-<%= "success".equals(messageType) ? "check-circle" : "exclamation-triangle" %>"></i>
                <%= message %>
            </div>
        <% } %>

        <!-- Statistics -->
        <div class="stats-grid">
            <%
                int totalSchedules = 0;
                int uniqueOrigins = 0;
                int uniqueDestinations = 0;
                double avgFare = 0.0;
                try {
                    Connection con = DBConnection.getConnection();
                    
                    // Total schedules
                    PreparedStatement ps1 = con.prepareStatement("SELECT COUNT(*) as total FROM train_schedule_data");
                    ResultSet rs1 = ps1.executeQuery();
                    if (rs1.next()) totalSchedules = rs1.getInt("total");
                    rs1.close(); ps1.close();
                    
                    // Unique origins
                    PreparedStatement ps2 = con.prepareStatement("SELECT COUNT(DISTINCT Origin) as origins FROM train_schedule_data");
                    ResultSet rs2 = ps2.executeQuery();
                    if (rs2.next()) uniqueOrigins = rs2.getInt("origins");
                    rs2.close(); ps2.close();
                    
                    // Unique destinations
                    PreparedStatement ps3 = con.prepareStatement("SELECT COUNT(DISTINCT Destination) as destinations FROM train_schedule_data");
                    ResultSet rs3 = ps3.executeQuery();
                    if (rs3.next()) uniqueDestinations = rs3.getInt("destinations");
                    rs3.close(); ps3.close();
                    
                    // Average fare
                    PreparedStatement ps4 = con.prepareStatement("SELECT AVG(Fare) as avg_fare FROM train_schedule_data");
                    ResultSet rs4 = ps4.executeQuery();
                    if (rs4.next()) avgFare = rs4.getDouble("avg_fare");
                    rs4.close(); ps4.close();
                    
                    con.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>
            <div class="stat-card">
                <div class="stat-value"><%= totalSchedules %></div>
                <div class="stat-label">Total Schedules</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= uniqueOrigins %></div>
                <div class="stat-label">Origin Stations</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= uniqueDestinations %></div>
                <div class="stat-label">Destination Stations</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">$<%= String.format("%.0f", avgFare) %></div>
                <div class="stat-label">Average Fare</div>
            </div>
        </div>

        <!-- View Tabs -->
        <div class="view-tabs">
            <a href="station-schedules.jsp?view=all" class="view-tab <%= "all".equals(viewType) ? "active" : "" %>">
                <i class="fas fa-list"></i>
                All Schedules
            </a>
            <a href="station-schedules.jsp?view=origin" class="view-tab <%= "origin".equals(viewType) ? "active" : "" %>">
                <i class="fas fa-play"></i>
                By Origin
            </a>
            <a href="station-schedules.jsp?view=destination" class="view-tab <%= "destination".equals(viewType) ? "active" : "" %>">
                <i class="fas fa-stop"></i>
                By Destination
            </a>
        </div>

        <!-- Filters Section -->
        <div class="content-section">
            <div class="section-header">
                <h2 class="section-title">
                    <i class="fas fa-filter"></i>
                    Filter & Search
                </h2>
                <div class="filter-actions">
                    <form method="GET" action="station-schedules.jsp" style="display: inline;">
                        <input type="hidden" name="action" value="export">
                        <input type="hidden" name="origin" value="<%= originFilter != null ? originFilter : "" %>">
                        <input type="hidden" name="destination" value="<%= destinationFilter != null ? destinationFilter : "" %>">
                        <input type="hidden" name="date" value="<%= dateFilter != null ? dateFilter : "" %>">
                        <button type="submit" class="btn btn-success">
                            <i class="fas fa-download"></i>
                            Export CSV
                        </button>
                    </form>
                </div>
            </div>

            <form method="GET" action="station-schedules.jsp" class="filters-section">
                <input type="hidden" name="view" value="<%= viewType %>">
                
                <div class="filters-grid">
                    <div class="filter-group">
                        <label class="filter-label">Search Trains</label>
                        <input type="text" name="search" class="filter-input" 
                               placeholder="Search by train name, route..." 
                               value="<%= searchQuery != null ? searchQuery : "" %>">
                    </div>
                    
                    <div class="filter-group">
                        <label class="filter-label">Origin Station</label>
                        <select name="origin" class="filter-select">
                            <option value="">All Origins</option>
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    PreparedStatement ps = con.prepareStatement("SELECT DISTINCT Origin FROM train_schedule_data ORDER BY Origin");
                                    ResultSet rs = ps.executeQuery();
                                    while (rs.next()) {
                                        String origin = rs.getString("Origin");
                                        String selected = origin.equals(originFilter) ? "selected" : "";
                            %>
                            <option value="<%= origin %>" <%= selected %>><%= origin %></option>
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
                    </div>
                    
                    <div class="filter-group">
                        <label class="filter-label">Destination Station</label>
                        <select name="destination" class="filter-select">
                            <option value="">All Destinations</option>
                            <%
                                try {
                                    Connection con = DBConnection.getConnection();
                                    PreparedStatement ps = con.prepareStatement("SELECT DISTINCT Destination FROM train_schedule_data ORDER BY Destination");
                                    ResultSet rs = ps.executeQuery();
                                    while (rs.next()) {
                                        String destination = rs.getString("Destination");
                                        String selected = destination.equals(destinationFilter) ? "selected" : "";
                            %>
                            <option value="<%= destination %>" <%= selected %>><%= destination %></option>
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
                    </div>
                    
                    <div class="filter-group">
                        <label class="filter-label">Date</label>
                        <input type="date" name="date" class="filter-input" 
                               value="<%= dateFilter != null ? dateFilter : "" %>">
                    </div>
                </div>
                
                <div class="filter-actions">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-search"></i>
                        Apply Filters
                    </button>
                    <a href="station-schedules.jsp?view=<%= viewType %>" class="btn btn-outline">
                        <i class="fas fa-times"></i>
                        Clear All
                    </a>
                </div>
            </form>
        </div>

        <!-- Schedules Table -->
        <div class="content-section">
            <div class="section-header">
                <h2 class="section-title">
                    <i class="fas fa-train"></i>
                    <%= "origin".equals(viewType) ? "Schedules by Origin Station" : 
                        "destination".equals(viewType) ? "Schedules by Destination Station" : "All Train Schedules" %>
                </h2>
            </div>

            <div class="schedules-table">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Train Details</th>
                            <th>Route</th>
                            <th>Departure</th>
                            <th>Arrival</th>
                            <th>Duration</th>
                            <th>Fare</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Connection con = DBConnection.getConnection();
                                
                                // Build dynamic query based on filters
                                StringBuilder queryBuilder = new StringBuilder("SELECT * FROM train_schedule_data WHERE 1=1");
                                
                                if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                                    queryBuilder.append(" AND (Transit_line_name LIKE ? OR Origin LIKE ? OR Destination LIKE ?)");
                                }
                                if (originFilter != null && !originFilter.trim().isEmpty()) {
                                    queryBuilder.append(" AND Origin = ?");
                                }
                                if (destinationFilter != null && !destinationFilter.trim().isEmpty()) {
                                    queryBuilder.append(" AND Destination = ?");
                                }
                                if (dateFilter != null && !dateFilter.trim().isEmpty()) {
                                    queryBuilder.append(" AND DATE(Departure_datetime) = ?");
                                }
                                
                                // Order by based on view type
                                if ("origin".equals(viewType)) {
                                    queryBuilder.append(" ORDER BY Origin, Departure_datetime");
                                } else if ("destination".equals(viewType)) {
                                    queryBuilder.append(" ORDER BY Destination, Departure_datetime");
                                } else {
                                    queryBuilder.append(" ORDER BY Departure_datetime");
                                }
                                
                                PreparedStatement ps = con.prepareStatement(queryBuilder.toString());
                                
                                // Set parameters
                                int paramIndex = 1;
                                if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                                    String searchTerm = "%" + searchQuery + "%";
                                    ps.setString(paramIndex++, searchTerm);
                                    ps.setString(paramIndex++, searchTerm);
                                    ps.setString(paramIndex++, searchTerm);
                                }
                                if (originFilter != null && !originFilter.trim().isEmpty()) {
                                    ps.setString(paramIndex++, originFilter);
                                }
                                if (destinationFilter != null && !destinationFilter.trim().isEmpty()) {
                                    ps.setString(paramIndex++, destinationFilter);
                                }
                                if (dateFilter != null && !dateFilter.trim().isEmpty()) {
                                    ps.setString(paramIndex++, dateFilter);
                                }
                                
                                ResultSet rs = ps.executeQuery();
                                
                                boolean hasData = false;
                                String currentGroup = "";
                                
                                while (rs.next()) {
                                    hasData = true;
                                    String transitLine = rs.getString("Transit_line_name");
                                    String origin = rs.getString("Origin");
                                    String destination = rs.getString("Destination");
                                    String stops = rs.getString("Stops");
                                    double fare = rs.getDouble("Fare");
                                    Timestamp departure = rs.getTimestamp("Departure_datetime");
                                    Timestamp arrival = rs.getTimestamp("Arrival_datetime");
                                    
                                    // Group headers for origin/destination views
                                    String groupBy = "";
                                    if ("origin".equals(viewType)) {
                                        groupBy = origin;
                                    } else if ("destination".equals(viewType)) {
                                        groupBy = destination;
                                    }
                                    
                                    if (!groupBy.isEmpty() && !groupBy.equals(currentGroup)) {
                                        currentGroup = groupBy;
                            %>
                            <tr style="background: var(--background-light);">
                                <td colspan="6">
                                    <div class="station-summary">
                                        <div class="station-name">
                                            <i class="fas fa-<%= "origin".equals(viewType) ? "play" : "stop" %>"></i>
                                            <%= groupBy %> Station
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                    
                                    // Calculate duration
                                    long durationMillis = arrival.getTime() - departure.getTime();
                                    long hours = durationMillis / (1000 * 60 * 60);
                                    long minutes = (durationMillis % (1000 * 60 * 60)) / (1000 * 60);
                                    String duration = hours + "h " + minutes + "m";
                                    
                                    // Determine train type badge
                                    String trainType = "local";
                                    String badgeClass = "badge-local";
                                    if (transitLine.toLowerCase().contains("express")) {
                                        trainType = "express";
                                        badgeClass = "badge-express";
                                    } else if (transitLine.toLowerCase().contains("superfast")) {
                                        trainType = "superfast";
                                        badgeClass = "badge-superfast";
                                    }
                        %>
                        <tr>
                            <td>
                                <div class="route-info">
                                    <div class="route-main"><%= transitLine %></div>
                                    <div class="route-details">
                                        <span class="schedule-badge <%= badgeClass %>"><%= trainType.toUpperCase() %></span>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="route-info">
                                    <div class="route-main">
                                        <i class="fas fa-arrow-right" style="color: var(--accent-purple); margin: 0 8px;"></i>
                                        <%= origin %> → <%= destination %>
                                    </div>
                                    <% if (stops != null && !stops.trim().isEmpty()) { %>
                                        <div class="route-details">
                                            <i class="fas fa-map-marker-alt"></i>
                                            Via: <%= stops.length() > 50 ? stops.substring(0, 50) + "..." : stops %>
                                        </div>
                                    <% } %>
                                </div>
                            </td>
                            <td>
                                <div class="time-info">
                                    <div class="time-main">
                                        <%= new SimpleDateFormat("HH:mm").format(departure) %>
                                    </div>
                                    <div class="time-date">
                                        <%= new SimpleDateFormat("MMM dd, yyyy").format(departure) %>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="time-info">
                                    <div class="time-main">
                                        <%= new SimpleDateFormat("HH:mm").format(arrival) %>
                                    </div>
                                    <div class="time-date">
                                        <%= new SimpleDateFormat("MMM dd, yyyy").format(arrival) %>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <span class="duration-badge">
                                    <i class="fas fa-clock"></i>
                                    <%= duration %>
                                </span>
                            </td>
                            <td>
                                <div class="fare-display">$<%= String.format("%.2f", fare) %></div>
                            </td>
                        </tr>
                        <%
                                }
                                
                                if (!hasData) {
                        %>
                        <tr>
                            <td colspan="6">
                                <div class="no-data">
                                    <i class="fas fa-search"></i>
                                    <h3>No Schedules Found</h3>
                                    <p>No train schedules match your current search criteria.</p>
                                    <a href="station-schedules.jsp?view=<%= viewType %>" class="btn btn-primary" style="margin-top: 20px;">
                                        <i class="fas fa-refresh"></i>
                                        Clear Filters
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
                                    <p>Unable to load schedule data. Please check your database connection.</p>
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

        // Enhanced form interactions
        document.querySelectorAll('.filter-input, .filter-select').forEach(element => {
            element.addEventListener('focus', function() {
                this.parentElement.style.transform = 'translateY(-2px)';
            });
            
            element.addEventListener('blur', function() {
                this.parentElement.style.transform = 'translateY(0)';
            });
        });

        // Smooth scrolling for view tabs
        document.querySelectorAll('.view-tab').forEach(tab => {
            tab.addEventListener('click', function(e) {
                if (this.classList.contains('active')) {
                    e.preventDefault();
                    document.querySelector('.content-section').scrollIntoView({
                        behavior: 'smooth'
                    });
                }
            });
        });

        // Auto-set today's date if no date filter is selected
        const dateInput = document.querySelector('input[name="date"]');
        if (dateInput && !dateInput.value) {
            const today = new Date().toISOString().split('T')[0];
            dateInput.min = today;
        }

        // Export confirmation
        document.querySelector('button[type="submit"]:has(.fa-download)').addEventListener('click', function(e) {
            const confirmExport = confirm('Export current filtered data to CSV?');
            if (!confirmExport) {
                e.preventDefault();
            }
        });
    </script>
</body>
</html>