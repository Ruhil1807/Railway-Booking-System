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

    // Get rep info and statistics
    String repName = "Customer Representative";
    String repSSN = "";
    int totalQuestions = 0;
    int pendingQuestions = 0;
    int totalSchedules = 0;
    int activeReservations = 0;
    double todayRevenue = 0.0;

    try {
        Connection con = DBConnection.getConnection();
        
        // Get rep information
        PreparedStatement ps0 = con.prepareStatement("SELECT First_Name, Last_Name, SSN FROM employee_data WHERE Username = ? AND Role = 'rep'");
        ps0.setString(1, user);
        ResultSet rs0 = ps0.executeQuery();
        if (rs0.next()) {
            String firstName = rs0.getString("First_Name");
            String lastName = rs0.getString("Last_Name");
            repSSN = rs0.getString("SSN");
            if (firstName != null && lastName != null) {
                repName = firstName + " " + lastName;
            }
        }
        rs0.close(); ps0.close();
        
        // FIXED: Get total questions from support_tickets table
        try {
            PreparedStatement ps1 = con.prepareStatement("SELECT COUNT(*) as total FROM support_tickets");
            ResultSet rs1 = ps1.executeQuery();
            if (rs1.next()) totalQuestions = rs1.getInt("total");
            rs1.close(); ps1.close();
        } catch (Exception e) {
            System.out.println("Error getting total questions: " + e.getMessage());
        }
        
        // FIXED: Get pending questions (tickets without responses or with status 'Open')
        try {
            PreparedStatement ps2 = con.prepareStatement(
                "SELECT COUNT(DISTINCT st.id) as pending " +
                "FROM support_tickets st " +
                "LEFT JOIN ticket_responses tr ON st.id = tr.ticket_id " +
                "WHERE tr.id IS NULL OR st.status = 'Open'"
            );
            ResultSet rs2 = ps2.executeQuery();
            if (rs2.next()) pendingQuestions = rs2.getInt("pending");
            rs2.close(); ps2.close();
        } catch (Exception e) {
            // Fallback: just count tickets with status 'Open'
            try {
                PreparedStatement ps2b = con.prepareStatement("SELECT COUNT(*) as pending FROM support_tickets WHERE status = 'Open'");
                ResultSet rs2b = ps2b.executeQuery();
                if (rs2b.next()) pendingQuestions = rs2b.getInt("pending");
                rs2b.close(); ps2b.close();
            } catch (Exception e2) {
                System.out.println("Error getting pending questions: " + e2.getMessage());
            }
        }
        
        // Get train schedules count (unique transit lines)
        try {
            PreparedStatement ps3 = con.prepareStatement("SELECT COUNT(DISTINCT Transit_line_name) as total FROM train_schedule_data");
            ResultSet rs3 = ps3.executeQuery();
            if (rs3.next()) totalSchedules = rs3.getInt("total");
            rs3.close(); ps3.close();
        } catch (Exception e) {
            System.out.println("Error getting train schedules: " + e.getMessage());
        }
        
        // Get active reservations count
        try {
            PreparedStatement ps4 = con.prepareStatement("SELECT COUNT(*) as total FROM reservation_data WHERE COALESCE(status, 'ACTIVE') = 'ACTIVE'");
            ResultSet rs4 = ps4.executeQuery();
            if (rs4.next()) activeReservations = rs4.getInt("total");
            rs4.close(); ps4.close();
        } catch (Exception e) {
            System.out.println("Error getting active reservations: " + e.getMessage());
        }
        
        // FIXED: Get today's revenue with better date handling
        try {
            PreparedStatement ps5 = con.prepareStatement(
                "SELECT COALESCE(SUM(Total_Fare), 0) as revenue " +
                "FROM reservation_data " +
                "WHERE DATE(created_date) = CURDATE() AND COALESCE(status, 'ACTIVE') = 'ACTIVE'"
            );
            ResultSet rs5 = ps5.executeQuery();
            if (rs5.next()) {
                todayRevenue = rs5.getDouble("revenue");
            }
            rs5.close(); ps5.close();
        } catch (Exception e) {
            // Fallback: try with Date column if created_date doesn't exist
            try {
                PreparedStatement ps5b = con.prepareStatement(
                    "SELECT COALESCE(SUM(Total_Fare), 0) as revenue " +
                    "FROM reservation_data " +
                    "WHERE DATE(Date) = CURDATE() AND COALESCE(status, 'ACTIVE') = 'ACTIVE'"
                );
                ResultSet rs5b = ps5b.executeQuery();
                if (rs5b.next()) {
                    todayRevenue = rs5b.getDouble("revenue");
                }
                rs5b.close(); ps5b.close();
            } catch (Exception e2) {
                System.out.println("Error getting today's revenue: " + e2.getMessage());
            }
        }
        
        con.close();
        
    } catch (Exception e) {
        e.printStackTrace(new PrintWriter(out));
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Rep Dashboard - IRCTC</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-50: #f0f9ff;
            --primary-100: #e0f2fe;
            --primary-200: #bae6fd;
            --primary-300: #7dd3fc;
            --primary-400: #38bdf8;
            --primary-500: #0ea5e9;
            --primary-600: #0284c7;
            --primary-700: #0369a1;
            --primary-800: #075985;
            --primary-900: #0c4a6e;
            
            --neutral-50: #fafafa;
            --neutral-100: #f5f5f5;
            --neutral-200: #e5e5e5;
            --neutral-300: #d4d4d4;
            --neutral-400: #a3a3a3;
            --neutral-500: #737373;
            --neutral-600: #525252;
            --neutral-700: #404040;
            --neutral-800: #262626;
            --neutral-900: #171717;
            
            --success: #10b981;
            --warning: #f59e0b;
            --error: #ef4444;
            --info: #3b82f6;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, var(--primary-50) 0%, var(--neutral-100) 50%, var(--primary-100) 100%);
            min-height: 100vh;
            line-height: 1.6;
            color: var(--neutral-800);
            position: relative;
        }

        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: 
                radial-gradient(circle at 20% 30%, rgba(14, 165, 233, 0.03) 0%, transparent 50%),
                radial-gradient(circle at 80% 70%, rgba(59, 130, 246, 0.02) 0%, transparent 50%),
                radial-gradient(circle at 50% 20%, rgba(147, 197, 253, 0.02) 0%, transparent 50%);
            z-index: -1;
            animation: backgroundShift 25s ease-in-out infinite;
        }

        @keyframes backgroundShift {
            0%, 100% { transform: translateX(0) translateY(0); }
            33% { transform: translateX(-8px) translateY(-12px); }
            66% { transform: translateX(8px) translateY(8px); }
        }

        /* Navigation */
        .navbar {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px) saturate(180%);
            border-bottom: 1px solid var(--neutral-200);
            padding: 1rem 0;
            position: sticky;
            top: 0;
            z-index: 1000;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
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
            color: var(--neutral-800);
            font-weight: 800;
            font-size: 1.5rem;
            text-decoration: none;
        }

        .navbar-brand i {
            font-size: 2rem;
            margin-right: 12px;
            color: var(--primary-500);
        }

        .rep-badge {
            background: linear-gradient(135deg, var(--primary-500), var(--info));
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            margin-left: 20px;
        }

        .nav-actions {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .user-button {
            background: white;
            color: var(--primary-500);
            border: 2px solid var(--primary-200);
            padding: 12px 20px;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .user-button:hover {
            background: var(--primary-500);
            color: white;
            transform: translateY(-1px);
        }

        .logout-btn {
            background: linear-gradient(135deg, var(--error), #dc2626);
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .logout-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(220, 38, 38, 0.3);
            color: white;
            text-decoration: none;
        }

        /* Main Container */
        .main-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 40px 2rem;
        }

        /* Welcome Section */
        .welcome-section {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(20px) saturate(180%);
            border: 1px solid var(--neutral-200);
            border-radius: 24px;
            padding: 40px;
            margin-bottom: 40px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.1);
            position: relative;
            overflow: hidden;
        }

        .welcome-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--primary-500), var(--info));
        }

        .welcome-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }

        .welcome-text h1 {
            font-size: 2.5rem;
            font-weight: 800;
            background: linear-gradient(135deg, var(--neutral-800), var(--primary-500));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 8px;
        }

        .welcome-text p {
            color: var(--neutral-600);
            font-size: 1.1rem;
            font-weight: 500;
        }

        .system-time {
            color: var(--neutral-600);
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* Stats Cards */
        .stats-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 24px;
            margin-bottom: 40px;
        }

        .stat-card {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(20px) saturate(180%);
            border: 1px solid var(--neutral-200);
            border-radius: 20px;
            padding: 32px 24px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
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

        .stat-card.questions { --accent-color: linear-gradient(90deg, var(--warning), #d97706); }
        .stat-card.pending { --accent-color: linear-gradient(90deg, var(--error), #dc2626); }
        .stat-card.schedules { --accent-color: linear-gradient(90deg, var(--primary-500), var(--info)); }
        .stat-card.reservations { --accent-color: linear-gradient(90deg, var(--success), #059669); }
        .stat-card.revenue { --accent-color: linear-gradient(90deg, #8b5cf6, #7c3aed); }

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

        .stat-icon.questions { background: linear-gradient(135deg, var(--warning), #d97706); }
        .stat-icon.pending { background: linear-gradient(135deg, var(--error), #dc2626); }
        .stat-icon.schedules { background: linear-gradient(135deg, var(--primary-500), var(--info)); }
        .stat-icon.reservations { background: linear-gradient(135deg, var(--success), #059669); }
        .stat-icon.revenue { background: linear-gradient(135deg, #8b5cf6, #7c3aed); }

        .stat-value {
            font-size: 2.5rem;
            font-weight: 800;
            color: var(--neutral-800);
            line-height: 1;
            margin-bottom: 8px;
        }

        .stat-label {
            color: var(--neutral-600);
            font-weight: 600;
            font-size: 0.95rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        /* Functions Grid */
        .functions-section {
            margin-bottom: 40px;
        }

        .section-title {
            font-size: 2rem;
            font-weight: 700;
            color: var(--neutral-800);
            margin-bottom: 32px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .section-title i {
            color: var(--primary-500);
        }

        .functions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 24px;
        }

        .function-card {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(20px) saturate(180%);
            border: 1px solid var(--neutral-200);
            border-radius: 20px;
            padding: 32px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            cursor: pointer;
            position: relative;
            overflow: hidden;
            text-decoration: none;
            color: inherit;
        }

        .function-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: var(--card-color);
        }

        .function-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.15);
            text-decoration: none;
            color: inherit;
        }

        .function-card.schedule-management { --card-color: linear-gradient(90deg, var(--primary-500), var(--info)); }
        .function-card.qa-system { --card-color: linear-gradient(90deg, var(--warning), #d97706); }
        .function-card.customer-service { --card-color: linear-gradient(90deg, var(--success), #059669); }
        .function-card.station-schedules { --card-color: linear-gradient(90deg, #8b5cf6, #7c3aed); }
        .function-card.customer-lists { --card-color: linear-gradient(90deg, var(--error), #dc2626); }

        .function-header {
            display: flex;
            align-items: flex-start;
            gap: 16px;
            margin-bottom: 20px;
        }

        .function-icon {
            width: 56px;
            height: 56px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: white;
            flex-shrink: 0;
        }

        .function-icon.schedule-management { background: linear-gradient(135deg, var(--primary-500), var(--info)); }
        .function-icon.qa-system { background: linear-gradient(135deg, var(--warning), #d97706); }
        .function-icon.customer-service { background: linear-gradient(135deg, var(--success), #059669); }
        .function-icon.station-schedules { background: linear-gradient(135deg, #8b5cf6, #7c3aed); }
        .function-icon.customer-lists { background: linear-gradient(135deg, var(--error), #dc2626); }

        .function-content h3 {
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--neutral-800);
            margin-bottom: 8px;
        }

        .function-points {
            background: linear-gradient(135deg, var(--primary-50), var(--primary-100));
            color: var(--primary-700);
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 600;
            display: inline-block;
            margin-bottom: 12px;
        }

        .function-description {
            color: var(--neutral-600);
            font-size: 0.95rem;
            line-height: 1.5;
            margin-bottom: 16px;
        }

        .function-features {
            list-style: none;
            margin: 0;
            padding: 0;
        }

        .function-features li {
            color: var(--neutral-600);
            font-size: 0.9rem;
            margin-bottom: 6px;
            padding-left: 20px;
            position: relative;
        }

        .function-features li::before {
            content: '✓';
            position: absolute;
            left: 0;
            color: var(--primary-500);
            font-weight: bold;
        }

        .function-arrow {
            position: absolute;
            top: 32px;
            right: 32px;
            color: var(--neutral-400);
            font-size: 1.5rem;
            transition: all 0.3s ease;
        }

        .function-card:hover .function-arrow {
            color: var(--primary-500);
            transform: translateX(4px);
        }



        /* Debug info */
        .debug-info {
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid var(--neutral-300);
            border-radius: 8px;
            padding: 16px;
            margin: 20px 0;
            font-family: monospace;
            font-size: 0.9rem;
            color: var(--neutral-700);
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .main-container {
                padding: 20px 1rem;
            }

            .navbar-content {
                padding: 0 1rem;
                flex-direction: column;
                gap: 16px;
            }

            .welcome-content {
                flex-direction: column;
                text-align: center;
            }

            .welcome-text h1 {
                font-size: 2rem;
            }

            .stats-section {
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            }

            .functions-grid {
                grid-template-columns: 1fr;
            }

            .function-header {
                flex-direction: column;
                align-items: center;
                text-align: center;
            }
        }

        /* Animations */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .stats-section,
        .functions-section {
            animation: fadeInUp 0.6s ease-out;
        }

        .function-card:nth-child(even) {
            animation-delay: 0.1s;
        }

        .function-card:nth-child(odd) {
            animation-delay: 0.2s;
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar">
        <div class="navbar-content">
            <div style="display: flex; align-items: center;">
                <a href="rep-dashboard.jsp" class="navbar-brand">
                    <i class="fas fa-train"></i>
                    IRCTC
                </a>
                <div class="rep-badge">
                    <i class="fas fa-headset"></i>
                    <span>CUSTOMER REP</span>
                </div>
            </div>
            <div class="nav-actions">
                <button class="user-button">
                    <i class="fas fa-user-tie"></i>
                    <span><%= repName %></span>
                    <i class="fas fa-chevron-down"></i>
                </button>
                <a href="logout" class="logout-btn">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Logout</span>
                </a>
            </div>
        </div>
    </nav>

    <!-- Main Container -->
    <div class="main-container">
        <!-- Welcome Section -->
        <div class="welcome-section">
            <div class="welcome-content">
                <div class="welcome-text">
                    <h1>Rep Dashboard</h1>
                    <p>Welcome, <%= repName %>! Manage customer support and train operations.</p>
                </div>
                <div class="system-time">
                    <i class="fas fa-clock"></i>
                    <span id="currentTime"></span>
                </div>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="stats-section">
            <div class="stat-card questions">
                <div class="stat-header">
                    <div>
                        <div class="stat-value"><%= totalQuestions %></div>
                        <div class="stat-label">Total Questions</div>
                    </div>
                    <div class="stat-icon questions">
                        <i class="fas fa-question-circle"></i>
                    </div>
                </div>
            </div>
            <div class="stat-card pending">
                <div class="stat-header">
                    <div>
                        <div class="stat-value"><%= pendingQuestions %></div>
                        <div class="stat-label">Pending Replies</div>
                    </div>
                    <div class="stat-icon pending">
                        <i class="fas fa-clock"></i>
                    </div>
                </div>
            </div>
            <div class="stat-card schedules">
                <div class="stat-header">
                    <div>
                        <div class="stat-value"><%= totalSchedules %></div>
                        <div class="stat-label">Train Schedules</div>
                    </div>
                    <div class="stat-icon schedules">
                        <i class="fas fa-calendar-alt"></i>
                    </div>
                </div>
            </div>
            <div class="stat-card reservations">
                <div class="stat-header">
                    <div>
                        <div class="stat-value"><%= activeReservations %></div>
                        <div class="stat-label">Active Bookings</div>
                    </div>
                    <div class="stat-icon reservations">
                        <i class="fas fa-ticket-alt"></i>
                    </div>
                </div>
            </div>
            <div class="stat-card revenue">
                <div class="stat-header">
                    <div>
                        <div class="stat-value">$<%= String.format("%.0f", todayRevenue) %></div>
                        <div class="stat-label">Today's Revenue</div>
                    </div>
                    <div class="stat-icon revenue">
                        <i class="fas fa-dollar-sign"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Rep Functions -->
        <div class="functions-section">
            <h2 class="section-title">
                <i class="fas fa-tools"></i>
                Customer Representative Functions
            </h2>
            <div class="functions-grid">
                <!-- Train Schedule Management -->
                <a href="schedule-management.jsp" class="function-card schedule-management">
                    <div class="function-header">
                        <div class="function-icon schedule-management">
                            <i class="fas fa-edit"></i>
                        </div>
                        <div class="function-content">
                            <!-- <div class="function-points">6 Points</div> -->
                            <h3>Schedule Management</h3>
                        </div>
                    </div>
                    <p class="function-description">
                        Edit and delete train schedule information with comprehensive management tools.
                    </p>
                    <ul class="function-features">
                        <li>Edit train schedule details</li>
                        <li>Delete outdated schedules</li>
                        <li>Update timing and routes</li>
                        <li>Manage schedule availability</li>
                    </ul>
                    <i class="fas fa-arrow-right function-arrow"></i>
                </a>

                <!-- Q&A System -->
                <a href="qa-system.jsp" class="function-card qa-system">
                    <div class="function-header">
                        <div class="function-icon qa-system">
                            <i class="fas fa-comments"></i>
                        </div>
                        <div class="function-content">
                            <!-- <div class="function-points">7 Points</div> -->
                            <h3>Q&A Management</h3>
                        </div>
                    </div>
                    <p class="function-description">
                        Browse customer questions, search by keywords, and provide helpful answers.
                    </p>
                    <ul class="function-features">
                        <li>Browse all questions and answers</li>
                        <li>Search questions by keywords</li>
                        <li>View question categories</li>
                        <li>Manage Q&A database</li>
                    </ul>
                    <i class="fas fa-arrow-right function-arrow"></i>
                </a>

                <!-- Customer Service -->
                <a href="customer-service.jsp" class="function-card customer-service">
                    <div class="function-header">
                        <div class="function-icon customer-service">
                            <i class="fas fa-user-headset"></i>
                        </div>
                        <div class="function-content">
                            <!-- <div class="function-points">6 Points</div> -->
                            <h3>Customer Support</h3>
                        </div>
                    </div>
                    <p class="function-description">
                        Handle customer questions, send responses, and manage support tickets.
                    </p>
                    <ul class="function-features">
                        <li>Receive customer questions</li>
                        <li>Reply to support tickets</li>
                        <li>Send questions to service team</li>
                        <li>Track response times</li>
                    </ul>
                    <i class="fas fa-arrow-right function-arrow"></i>
                </a>

                <!-- Station Schedule Reports -->
                <a href="station-schedules.jsp" class="function-card station-schedules">
                    <div class="function-header">
                        <div class="function-icon station-schedules">
                            <i class="fas fa-map-marker-alt"></i>
                        </div>
                        <div class="function-content">
                            <!-- <div class="function-points">5 Points</div> -->
                            <h3>Station Schedules</h3>
                        </div>
                    </div>
                    <p class="function-description">
                        Generate lists of train schedules for specific stations as origin or destination.
                    </p>
                    <ul class="function-features">
                        <li>List schedules by origin station</li>
                        <li>List schedules by destination</li>
                        <li>Filter by date and time</li>
                        <li>Export schedule reports</li>
                    </ul>
                    <i class="fas fa-arrow-right function-arrow"></i>
                </a>

                <!-- Customer Lists by Transit Line -->
                <a href="transit-customers.jsp" class="function-card customer-lists">
                    <div class="function-header">
                        <div class="function-icon customer-lists">
                            <i class="fas fa-users"></i>
                        </div>
                        <div class="function-content">
                            <!-- <div class="function-points">5 Points</div> -->
                            <h3>Transit Customers</h3>
                        </div>
                    </div>
                    <p class="function-description">
                        View all customers with reservations on specific transit lines and dates.
                    </p>
                    <ul class="function-features">
                        <li>List customers by transit line</li>
                        <li>Filter by specific dates</li>
                        <li>View reservation details</li>
                        <li>Export customer lists</li>
                    </ul>
                    <i class="fas fa-arrow-right function-arrow"></i>
                </a>
            </div>
        </div>
    </div>

    <!-- JavaScript -->
    <script>
        // Update current time
        function updateTime() {
            const now = new Date();
            const timeString = now.toLocaleString('en-US', {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            });
            document.getElementById('currentTime').textContent = timeString;
        }

        // Update time every second
        updateTime();
        setInterval(updateTime, 1000);

        // Add hover effects to stats cards
        document.querySelectorAll('.stat-card').forEach(card => {
            card.addEventListener('mouseenter', function() {
                this.style.transform = 'translateY(-6px) scale(1.02)';
            });
            
            card.addEventListener('mouseleave', function() {
                this.style.transform = 'translateY(0) scale(1)';
            });
        });

        // Add click effects to function cards
        document.querySelectorAll('.function-card').forEach(card => {
            card.addEventListener('mousedown', function() {
                this.style.transform = 'translateY(-4px) scale(0.98)';
            });
            
            card.addEventListener('mouseup', function() {
                this.style.transform = 'translateY(-6px) scale(1)';
            });
        });

        // Add loading state to function cards when clicked
        document.querySelectorAll('.function-card').forEach(card => {
            card.addEventListener('click', function(e) {
                // Add a subtle loading effect
                this.style.opacity = '0.8';
                this.style.transform = 'translateY(-2px)';
                
                // Reset after a short delay
                setTimeout(() => {
                    this.style.opacity = '1';
                    this.style.transform = 'translateY(-6px)';
                }, 200);
            });
        });
    </script>
</body>
</html>