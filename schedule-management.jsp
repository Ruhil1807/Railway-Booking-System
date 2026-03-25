<%@ page import="java.sql.*, java.io.PrintWriter" %>
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

    // Handle form submissions
    if ("POST".equals(request.getMethod())) {
        if ("add".equals(action)) {
            // Add new schedule
            String transitLine = request.getParameter("transitLine");
            String fare = request.getParameter("fare");
            String origin = request.getParameter("origin");
            String destination = request.getParameter("destination");
            String stops = request.getParameter("stops");
            String departureDateTime = request.getParameter("departureDateTime");
            String arrivalDateTime = request.getParameter("arrivalDateTime");
            
            try {
                Connection con = DBConnection.getConnection();
                
                // Check if transit line already exists
                PreparedStatement checkPs = con.prepareStatement(
                    "SELECT COUNT(*) FROM train_schedule_data WHERE Transit_line_name=?"
                );
                checkPs.setString(1, transitLine);
                ResultSet checkRs = checkPs.executeQuery();
                checkRs.next();
                
                if (checkRs.getInt(1) > 0) {
                    message = "Transit line already exists. Please use a different name.";
                    messageType = "error";
                } else {
                    PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO train_schedule_data (Transit_line_name, Fare, Origin, Destination, Stops, Departure_datetime, Arrival_datetime) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?)"
                    );
                    ps.setString(1, transitLine);
                    ps.setDouble(2, Double.parseDouble(fare));
                    ps.setString(3, origin);
                    ps.setString(4, destination);
                    ps.setString(5, stops);
                    ps.setString(6, departureDateTime);
                    ps.setString(7, arrivalDateTime);
                    
                    int result = ps.executeUpdate();
                    if (result > 0) {
                        message = "New train schedule added successfully!";
                        messageType = "success";
                    } else {
                        message = "Failed to add new schedule.";
                        messageType = "error";
                    }
                    ps.close();
                }
                checkRs.close();
                checkPs.close();
                con.close();
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                messageType = "error";
            }
        } else if ("edit".equals(action)) {
            // Edit existing schedule
            String transitLine = request.getParameter("transitLine");
            String fare = request.getParameter("fare");
            String origin = request.getParameter("origin");
            String destination = request.getParameter("destination");
            String stops = request.getParameter("stops");
            String departureDateTime = request.getParameter("departureDateTime");
            String arrivalDateTime = request.getParameter("arrivalDateTime");
            
            try {
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(
                    "UPDATE train_schedule_data SET Fare=?, Origin=?, Destination=?, Stops=?, " +
                    "Departure_datetime=?, Arrival_datetime=? WHERE Transit_line_name=?"
                );
                ps.setDouble(1, Double.parseDouble(fare));
                ps.setString(2, origin);
                ps.setString(3, destination);
                ps.setString(4, stops);
                ps.setString(5, departureDateTime);
                ps.setString(6, arrivalDateTime);
                ps.setString(7, transitLine);
                
                int result = ps.executeUpdate();
                if (result > 0) {
                    message = "Schedule updated successfully!";
                    messageType = "success";
                } else {
                    message = "Failed to update schedule.";
                    messageType = "error";
                }
                ps.close();
                con.close();
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                messageType = "error";
            }
        } else if ("delete".equals(action)) {
            // Delete schedule
            String transitLine = request.getParameter("transitLine");
            
            try {
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement("DELETE FROM train_schedule_data WHERE Transit_line_name=?");
                ps.setString(1, transitLine);
                
                int result = ps.executeUpdate();
                if (result > 0) {
                    message = "Schedule deleted successfully!";
                    messageType = "success";
                } else {
                    message = "Failed to delete schedule.";
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
    <title>Schedule Management - IRCTC Professional Portal</title>
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
            --accent-blue: #3B82F6;
            --light-blue: #EBF8FF;
            --success-green: #10B981;
            --warning-orange: #F59E0B;
            --danger-red: #EF4444;
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
            color: var(--accent-blue);
        }

        .navbar-brand i {
            font-size: 2rem;
            margin-right: 12px;
            background: linear-gradient(135deg, var(--accent-blue), #6366F1);
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
            background: linear-gradient(135deg, var(--accent-blue), #6366F1);
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
            background: linear-gradient(90deg, var(--accent-blue), #6366F1, #8B5CF6);
        }

        .page-title {
            font-size: 3rem;
            font-weight: 900;
            background: linear-gradient(135deg, var(--primary-blue), var(--accent-blue));
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

        .add-schedule-btn {
            background: linear-gradient(135deg, var(--success-green), #059669);
            color: white;
            border: none;
            padding: 14px 28px;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s ease;
            box-shadow: var(--shadow-soft);
            font-size: 1rem;
        }

        .add-schedule-btn:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }

        .table-container {
            overflow-x: auto;
            border-radius: 16px;
            border: 1px solid var(--border-light);
        }

        .table {
            width: 100%;
            border-collapse: collapse;
            background: white;
        }

        .table th {
            background: linear-gradient(135deg, var(--background-light), #F1F5F9);
            padding: 20px 16px;
            text-align: left;
            font-weight: 700;
            color: var(--primary-blue);
            border-bottom: 2px solid var(--border-light);
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .table td {
            padding: 20px 16px;
            border-bottom: 1px solid var(--border-light);
            vertical-align: middle;
        }

        .table tr:hover {
            background: var(--background-light);
        }

        .table tr:last-child td {
            border-bottom: none;
        }

        .transit-line-name {
            font-weight: 700;
            color: var(--primary-blue);
            font-size: 1.1rem;
        }

        .route-info {
            background: linear-gradient(135deg, var(--light-blue), #DBEAFE);
            padding: 12px 16px;
            border-radius: 10px;
            font-size: 0.95rem;
            color: #1E40AF;
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 600;
        }

        .stops-info {
            color: var(--text-secondary);
            font-size: 0.85rem;
            margin-top: 6px;
            font-style: italic;
        }

        .fare-display {
            font-weight: 800;
            color: var(--success-green);
            font-size: 1.3rem;
            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
        }

        .datetime-display {
            font-weight: 600;
            color: var(--text-primary);
            line-height: 1.4;
        }

        .action-buttons {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .btn {
            padding: 10px 16px;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            text-decoration: none;
            font-size: 0.875rem;
            box-shadow: var(--shadow-soft);
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--accent-blue), #6366F1);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }

        .btn-danger {
            background: linear-gradient(135deg, var(--danger-red), #DC2626);
            color: white;
        }

        .btn-danger:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }

        .btn-secondary {
            background: linear-gradient(135deg, #6B7280, #4B5563);
            color: white;
        }

        .btn-secondary:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }

        .btn-success {
            background: linear-gradient(135deg, var(--success-green), #059669);
            color: white;
        }

        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }

        .modal {
            display: none;
            position: fixed;
            z-index: 2000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(8px);
            animation: fadeIn 0.3s ease-out;
        }

        .modal-content {
            background: white;
            margin: 3% auto;
            padding: 40px;
            border-radius: 24px;
            width: 90%;
            max-width: 700px;
            position: relative;
            max-height: 85vh;
            overflow-y: auto;
            box-shadow: var(--shadow-large);
            animation: slideUp 0.3s ease-out;
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 32px;
            padding-bottom: 20px;
            border-bottom: 2px solid var(--background-light);
        }

        .modal-title {
            font-size: 1.8rem;
            font-weight: 800;
            color: var(--primary-blue);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .close {
            background: var(--background-light);
            border: none;
            padding: 10px;
            border-radius: 10px;
            font-size: 1.2rem;
            cursor: pointer;
            color: var(--text-secondary);
            transition: all 0.3s ease;
        }

        .close:hover {
            background: var(--border-light);
            color: var(--text-primary);
            transform: scale(1.1);
        }

        .form-group {
            margin-bottom: 24px;
        }

        .form-label {
            display: block;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 8px;
            font-size: 0.95rem;
        }

        .form-input, .form-textarea {
            width: 100%;
            padding: 14px 16px;
            border: 2px solid var(--border-light);
            border-radius: 12px;
            font-size: 1rem;
            transition: all 0.3s ease;
            font-family: inherit;
        }

        .form-input:focus, .form-textarea:focus {
            outline: none;
            border-color: var(--accent-blue);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }

        .form-textarea {
            min-height: 100px;
            resize: vertical;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .form-actions {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            margin-top: 32px;
            padding-top: 20px;
            border-top: 2px solid var(--background-light);
        }

        .stops-container {
            display: flex;
            flex-direction: column;
            gap: 12px;
            margin-bottom: 16px;
        }

        .stop-entry {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .stop-input {
            flex: 1;
            margin-bottom: 0;
        }

        .btn-remove-stop {
            background: linear-gradient(135deg, var(--danger-red), #DC2626);
            color: white;
            border: none;
            padding: 12px;
            border-radius: 8px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            min-width: 44px;
            height: 44px;
            transition: all 0.3s ease;
            box-shadow: var(--shadow-soft);
        }

        .btn-remove-stop:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }

        .add-stop-btn {
            background: linear-gradient(135deg, var(--success-green), #059669);
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
            box-shadow: var(--shadow-soft);
            align-self: flex-start;
            margin-bottom: 8px;
        }

        .add-stop-btn:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
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
        }

        .stat-value {
            font-size: 2rem;
            font-weight: 800;
            color: var(--accent-blue);
        }

        .stat-label {
            color: var(--text-secondary);
            font-weight: 600;
            margin-top: 4px;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideUp {
            from { transform: translateY(30px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
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
            
            .form-row {
                grid-template-columns: 1fr;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .section-header {
                flex-direction: column;
                gap: 16px;
                align-items: stretch;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar">
        <div class="navbar-content">
            <a href="rep-dashboard.jsp" class="navbar-brand">
                <i class="fas fa-train"></i>
                <div class="brand-text">
                    <span class="brand-main">IRCTC Professional</span>
                    <span class="brand-sub">Railway Management Portal</span>
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
            <h1 class="page-title">Train Schedule Management</h1>
            <p class="page-subtitle">Comprehensive management of train schedules, routes, and operational data</p>
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
                int totalSchedules = 0;
                double avgFare = 0.0;
                try {
                    Connection con = DBConnection.getConnection();
                    PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) as total, AVG(Fare) as avg_fare FROM train_schedule_data");
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        totalSchedules = rs.getInt("total");
                        avgFare = rs.getDouble("avg_fare");
                    }
                    rs.close();
                    ps.close();
                    con.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>
            <div class="stat-card">
                <div class="stat-value"><%= totalSchedules %></div>
                <div class="stat-label">Active Schedules</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">$<%= String.format("%.2f", avgFare) %></div>
                <div class="stat-label">Average Fare</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= new java.text.SimpleDateFormat("MMM dd").format(new java.util.Date()) %></div>
                <div class="stat-label">Last Updated</div>
            </div>
        </div>

        <!-- Schedules Management -->
        <div class="content-section">
            <div class="section-header">
                <h2 class="section-title">
                    <i class="fas fa-calendar-alt"></i>
                    All Train Schedules
                </h2>
                <button onclick="openAddModal()" class="add-schedule-btn">
                    <i class="fas fa-plus"></i>
                    Add New Schedule
                </button>
            </div>
            
            <div class="table-container">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Transit Line</th>
                            <th>Route Information</th>
                            <th>Fare</th>
                            <th>Departure</th>
                            <th>Arrival</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Connection con = DBConnection.getConnection();
                                PreparedStatement ps = con.prepareStatement("SELECT * FROM train_schedule_data ORDER BY Transit_line_name");
                                ResultSet rs = ps.executeQuery();
                                
                                boolean hasData = false;
                                while (rs.next()) {
                                    hasData = true;
                                    String transitLine = rs.getString("Transit_line_name");
                                    double fare = rs.getDouble("Fare");
                                    String origin = rs.getString("Origin");
                                    String destination = rs.getString("Destination");
                                    String stops = rs.getString("Stops");
                                    Timestamp departure = rs.getTimestamp("Departure_datetime");
                                    Timestamp arrival = rs.getTimestamp("Arrival_datetime");
                        %>
                        <tr>
                            <td>
                                <div class="transit-line-name"><%= transitLine %></div>
                            </td>
                            <td>
                                <div class="route-info">
                                    <i class="fas fa-route"></i>
                                    <%= origin %> → <%= destination %>
                                </div>
                                <% if (stops != null && !stops.trim().isEmpty()) { %>
                                    <div class="stops-info">
                                        <i class="fas fa-map-marker-alt"></i>
                                        Stops: <%= stops %>
                                    </div>
                                <% } %>
                            </td>
                            <td>
                                <div class="fare-display">$<%= String.format("%.2f", fare) %></div>
                            </td>
                            <td>
                                <div class="datetime-display">
                                    <%= departure != null ? new java.text.SimpleDateFormat("MMM dd, yyyy").format(departure) : "N/A" %><br>
                                    <small style="color: #6B7280;"><%= departure != null ? new java.text.SimpleDateFormat("HH:mm").format(departure) : "" %></small>
                                </div>
                            </td>
                            <td>
                                <div class="datetime-display">
                                    <%= arrival != null ? new java.text.SimpleDateFormat("MMM dd, yyyy").format(arrival) : "N/A" %><br>
                                    <small style="color: #6B7280;"><%= arrival != null ? new java.text.SimpleDateFormat("HH:mm").format(arrival) : "" %></small>
                                </div>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <button onclick="editSchedule('<%= transitLine %>', '<%= fare %>', '<%= origin %>', '<%= destination %>', '<%= stops != null ? stops.replace("'", "\\'") : "" %>', '<%= departure != null ? new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(departure) : "" %>', '<%= arrival != null ? new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(arrival) : "" %>')" 
                                            class="btn btn-primary">
                                        <i class="fas fa-edit"></i>
                                        Edit
                                    </button>
                                    <form method="POST" action="schedule-management.jsp" style="display: inline;" 
                                          onsubmit="return confirm('Are you sure you want to delete this schedule? This action cannot be undone.')">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="transitLine" value="<%= transitLine %>">
                                        <button type="submit" class="btn btn-danger">
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
                            <td colspan="6">
                                <div class="no-data">
                                    <i class="fas fa-calendar-times"></i>
                                    <h3>No Schedules Found</h3>
                                    <p>No train schedules are currently available in the system.</p>
                                    <button onclick="openAddModal()" class="btn btn-success" style="margin-top: 20px;">
                                        <i class="fas fa-plus"></i>
                                        Add Your First Schedule
                                    </button>
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
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Add Modal -->
    <div id="addModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">
                    <i class="fas fa-plus-circle"></i>
                    Add New Train Schedule
                </h2>
                <button class="close" onclick="closeAddModal()">&times;</button>
            </div>
            <form method="POST" action="schedule-management.jsp" id="addForm">
                <input type="hidden" name="action" value="add">
                
                <div class="form-group">
                    <label class="form-label">Transit Line Name</label>
                    <input type="text" class="form-input" name="transitLine" placeholder="e.g., Express #12345" required>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Origin Station</label>
                        <input type="text" class="form-input" name="origin" placeholder="e.g., New Delhi" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Destination Station</label>
                        <input type="text" class="form-input" name="destination" placeholder="e.g., Mumbai Central" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Fare Amount ($)</label>
                    <input type="number" step="0.01" min="0" class="form-input" name="fare" placeholder="0.00" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Intermediate Stops</label>
                    <div id="addStopsContainer" class="stops-container">
                        <div class="stop-entry">
                            <input type="text" class="form-input stop-input" placeholder="Enter station name" data-stop-index="0">
                            <button type="button" class="btn-remove-stop" onclick="removeStop(this)" style="display: none;">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </div>
                    <button type="button" class="add-stop-btn" onclick="addStop('addStopsContainer')">
                        <i class="fas fa-plus"></i>
                        Add Another Stop
                    </button>
                    <input type="hidden" name="stops" id="addStopsHidden">
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Departure Date & Time</label>
                        <input type="datetime-local" class="form-input" name="departureDateTime" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Arrival Date & Time</label>
                        <input type="datetime-local" class="form-input" name="arrivalDateTime" required>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="button" onclick="closeAddModal()" class="btn btn-secondary">
                        <i class="fas fa-times"></i>
                        Cancel
                    </button>
                    <button type="submit" class="btn btn-success">
                        <i class="fas fa-plus"></i>
                        Add Schedule
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit Modal -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">
                    <i class="fas fa-edit"></i>
                    Edit Train Schedule
                </h2>
                <button class="close" onclick="closeEditModal()">&times;</button>
            </div>
            <form method="POST" action="schedule-management.jsp" id="editForm">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" id="editTransitLine" name="transitLine">
                
                <div class="form-group">
                    <label class="form-label">Transit Line Name</label>
                    <input type="text" class="form-input" id="editTransitLineName" readonly 
                           style="background: var(--background-light); color: var(--text-secondary);">
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Origin Station</label>
                        <input type="text" class="form-input" id="editOrigin" name="origin" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Destination Station</label>
                        <input type="text" class="form-input" id="editDestination" name="destination" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Fare Amount ($)</label>
                    <input type="number" step="0.01" min="0" class="form-input" id="editFare" name="fare" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Intermediate Stops</label>
                    <div id="editStopsContainer" class="stops-container">
                        <div class="stop-entry">
                            <input type="text" class="form-input stop-input" placeholder="Enter station name" data-stop-index="0">
                            <button type="button" class="btn-remove-stop" onclick="removeStop(this)" style="display: none;">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </div>
                    <button type="button" class="add-stop-btn" onclick="addStop('editStopsContainer')">
                        <i class="fas fa-plus"></i>
                        Add Another Stop
                    </button>
                    <input type="hidden" name="stops" id="editStopsHidden">
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Departure Date & Time</label>
                        <input type="datetime-local" class="form-input" id="editDeparture" name="departureDateTime" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Arrival Date & Time</label>
                        <input type="datetime-local" class="form-input" id="editArrival" name="arrivalDateTime" required>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="button" onclick="closeEditModal()" class="btn btn-secondary">
                        <i class="fas fa-times"></i>
                        Cancel
                    </button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i>
                        Update Schedule
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Modal functionality
        const addModal = document.getElementById('addModal');
        const editModal = document.getElementById('editModal');

        function openAddModal() {
            // Reset form
            document.getElementById('addForm').reset();
            
            // Reset stops container
            const addContainer = document.getElementById('addStopsContainer');
            addContainer.innerHTML = '';
            addStop('addStopsContainer', '', 0);
            
            addModal.style.display = 'block';
            document.body.style.overflow = 'hidden';
        }

        function closeAddModal() {
            addModal.style.display = 'none';
            document.body.style.overflow = 'auto';
        }

        function editSchedule(transitLine, fare, origin, destination, stops, departure, arrival) {
            document.getElementById('editTransitLine').value = transitLine;
            document.getElementById('editTransitLineName').value = transitLine;
            document.getElementById('editFare').value = fare;
            document.getElementById('editOrigin').value = origin;
            document.getElementById('editDestination').value = destination;
            
            // Clear existing stops
            const editContainer = document.getElementById('editStopsContainer');
            editContainer.innerHTML = '';
            
            // Populate stops
            if (stops && stops.trim()) {
                const stopsArray = stops.split('|').filter(stop => stop.trim());
                stopsArray.forEach((stop, index) => {
                    addStop('editStopsContainer', stop.trim(), index);
                });
            } else {
                // Add empty stop if no stops exist
                addStop('editStopsContainer', '', 0);
            }
            
            document.getElementById('editDeparture').value = departure;
            document.getElementById('editArrival').value = arrival;
            editModal.style.display = 'block';
            document.body.style.overflow = 'hidden';
        }

        // Dynamic stops management
        function addStop(containerId, value = '', index = null) {
            const container = document.getElementById(containerId);
            const currentStops = container.querySelectorAll('.stop-entry').length;
            const stopIndex = index !== null ? index : currentStops;
            
            const stopEntry = document.createElement('div');
            stopEntry.className = 'stop-entry';
            
            const removeButtonDisplay = currentStops > 0 ? 'flex' : 'none';
            
            stopEntry.innerHTML = `
                <input type="text" class="form-input stop-input" placeholder="Enter station name" 
                       data-stop-index="${stopIndex}" value="${value}">
                <button type="button" class="btn-remove-stop" onclick="removeStop(this)" style="display: ${removeButtonDisplay};">
                    <i class="fas fa-times"></i>
                </button>
            `;
            
            container.appendChild(stopEntry);
            
            // Show remove buttons for all entries if there's more than one
            updateRemoveButtons(containerId);
        }

        function removeStop(button) {
            const stopEntry = button.parentElement;
            const container = stopEntry.parentElement;
            stopEntry.remove();
            
            // Update remove button visibility
            updateRemoveButtons(container.id);
        }

        function updateRemoveButtons(containerId) {
            const container = document.getElementById(containerId);
            const stopEntries = container.querySelectorAll('.stop-entry');
            
            stopEntries.forEach((entry, index) => {
                const removeBtn = entry.querySelector('.btn-remove-stop');
                if (stopEntries.length > 1) {
                    removeBtn.style.display = 'flex';
                } else {
                    removeBtn.style.display = 'none';
                }
            });
        }

        function collectStops(containerId) {
            const container = document.getElementById(containerId);
            const stopInputs = container.querySelectorAll('.stop-input');
            const stops = [];
            
            stopInputs.forEach(input => {
                const value = input.value.trim();
                if (value) {
                    stops.push(value);
                }
            });
            
            return stops.join('|');
        }

        function closeEditModal() {
            editModal.style.display = 'none';
            document.body.style.overflow = 'auto';
        }

        // Close modals when clicking outside
        window.onclick = function(event) {
            if (event.target == addModal) {
                closeAddModal();
            }
            if (event.target == editModal) {
                closeEditModal();
            }
        }

        // Auto-hide alerts after 5 seconds
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                alert.style.opacity = '0';
                alert.style.transform = 'translateX(-20px)';
                setTimeout(() => alert.remove(), 300);
            });
        }, 5000);

        // Form validation
        document.getElementById('addForm').addEventListener('submit', function(e) {
            const departure = new Date(document.querySelector('[name="departureDateTime"]').value);
            const arrival = new Date(document.querySelector('[name="arrivalDateTime"]').value);
            
            if (departure >= arrival) {
                e.preventDefault();
                alert('⚠️ Arrival time must be after departure time!');
                return false;
            }
            
            // Collect stops and populate hidden field
            const stopsValue = collectStops('addStopsContainer');
            document.getElementById('addStopsHidden').value = stopsValue;
        });

        document.getElementById('editForm').addEventListener('submit', function(e) {
            const departure = new Date(document.getElementById('editDeparture').value);
            const arrival = new Date(document.getElementById('editArrival').value);
            
            if (departure >= arrival) {
                e.preventDefault();
                alert('⚠️ Arrival time must be after departure time!');
                return false;
            }
            
            // Collect stops and populate hidden field
            const stopsValue = collectStops('editStopsContainer');
            document.getElementById('editStopsHidden').value = stopsValue;
        });

        // Set minimum date to today
        const today = new Date();
        const todayString = today.toISOString().slice(0, 16);
        const dateInputs = document.querySelectorAll('input[type="datetime-local"]');
        dateInputs.forEach(input => {
            input.min = todayString;
        });

        // Smooth scrolling for better UX
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                document.querySelector(this.getAttribute('href')).scrollIntoView({
                    behavior: 'smooth'
                });
            });
        });
    </script>
</body>
</html>