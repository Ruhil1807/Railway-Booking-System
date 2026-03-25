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

    // Get admin info with CORRECT column names for your database
    String adminName = "Administrator";
    String adminEmail = "";
    int totalCustomers = 0;
    int totalReservations = 0;
    int totalReps = 0;
    double totalRevenue = 0.0;

    try {
        Connection con = DBConnection.getConnection();
        
        // Get customer count
        PreparedStatement ps1 = con.prepareStatement("SELECT COUNT(*) as total FROM customer_data");
        ResultSet rs1 = ps1.executeQuery();
        if (rs1.next()) totalCustomers = rs1.getInt("total");
        
        // Get reservation count - using your actual status field
        PreparedStatement ps2 = con.prepareStatement("SELECT COUNT(*) as total FROM reservation_data WHERE COALESCE(status, 'ACTIVE') = 'ACTIVE'");
        ResultSet rs2 = ps2.executeQuery();
        if (rs2.next()) totalReservations = rs2.getInt("total");
        
        // Get rep count - using your actual Role enum
        PreparedStatement ps3 = con.prepareStatement("SELECT COUNT(*) as total FROM employee_data WHERE Role = 'rep'");
        ResultSet rs3 = ps3.executeQuery();
        if (rs3.next()) totalReps = rs3.getInt("total");
        
        // Get total revenue - using your actual Total_Fare column
        PreparedStatement ps4 = con.prepareStatement("SELECT SUM(Total_Fare) as total FROM reservation_data WHERE COALESCE(status, 'ACTIVE') = 'ACTIVE'");
        ResultSet rs4 = ps4.executeQuery();
        if (rs4.next()) totalRevenue = rs4.getDouble("total");
        
        // Close connections
        rs1.close(); ps1.close();
        rs2.close(); ps2.close();
        rs3.close(); ps3.close();
        rs4.close(); ps4.close();
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
    <title>Admin Dashboard - IRCTC</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 50%, #f1f5f9 100%);
            min-height: 100vh;
            line-height: 1.6;
            color: #334155;
        }

        /* Subtle animated background pattern */
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: 
                radial-gradient(circle at 20% 30%, rgba(100, 116, 139, 0.03) 0%, transparent 50%),
                radial-gradient(circle at 80% 70%, rgba(71, 85, 105, 0.02) 0%, transparent 50%),
                radial-gradient(circle at 50% 20%, rgba(148, 163, 184, 0.02) 0%, transparent 50%);
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
            backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(226, 232, 240, 0.8);
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
            background-clip: text;
        }

        .admin-badge {
            background: linear-gradient(135deg, #1e293b, #475569);
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

        .user-menu {
            position: relative;
        }

        .user-button {
            background: white;
            color: #64748b;
            border: 2px solid #e2e8f0;
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
            background: #64748b;
            color: white;
            transform: translateY(-1px);
        }

        .logout-btn {
            background: linear-gradient(135deg, #dc2626, #ef4444);
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
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            padding: 40px;
            margin-bottom: 40px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.1);
            position: relative;
            overflow: hidden;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .welcome-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #64748b, #94a3b8);
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
            background: linear-gradient(135deg, #1e293b, #64748b);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 8px;
        }

        .welcome-text p {
            color: #64748b;
            font-size: 1.1rem;
            font-weight: 500;
        }

        .system-time {
            color: #64748b;
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
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 32px 24px;
            border: 1px solid rgba(255, 255, 255, 0.3);
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

        .stat-card.customers { --accent-color: linear-gradient(90deg, #3b82f6, #1d4ed8); }
        .stat-card.reservations { --accent-color: linear-gradient(90deg, #10b981, #059669); }
        .stat-card.reps { --accent-color: linear-gradient(90deg, #f59e0b, #d97706); }
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

        .stat-icon.customers { background: linear-gradient(135deg, #3b82f6, #1d4ed8); }
        .stat-icon.reservations { background: linear-gradient(135deg, #10b981, #059669); }
        .stat-icon.reps { background: linear-gradient(135deg, #f59e0b, #d97706); }
        .stat-icon.revenue { background: linear-gradient(135deg, #8b5cf6, #7c3aed); }

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

        /* Admin Functions Grid */
        .functions-section {
            margin-bottom: 40px;
        }

        .section-title {
            font-size: 2rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 32px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .section-title i {
            color: #64748b;
        }

        .functions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 24px;
        }

        .function-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 32px;
            border: 1px solid rgba(255, 255, 255, 0.3);
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

        .function-card.rep-management { --card-color: linear-gradient(90deg, #3b82f6, #1d4ed8); }
        .function-card.sales-reports { --card-color: linear-gradient(90deg, #10b981, #059669); }
        .function-card.reservations { --card-color: linear-gradient(90deg, #f59e0b, #d97706); }
        .function-card.revenue { --card-color: linear-gradient(90deg, #8b5cf6, #7c3aed); }
        .function-card.customers { --card-color: linear-gradient(90deg, #ef4444, #dc2626); }
        .function-card.transit { --card-color: linear-gradient(90deg, #06b6d4, #0891b2); }

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

        .function-icon.rep-management { background: linear-gradient(135deg, #3b82f6, #1d4ed8); }
        .function-icon.sales-reports { background: linear-gradient(135deg, #10b981, #059669); }
        .function-icon.reservations { background: linear-gradient(135deg, #f59e0b, #d97706); }
        .function-icon.revenue { background: linear-gradient(135deg, #8b5cf6, #7c3aed); }
        .function-icon.customers { background: linear-gradient(135deg, #ef4444, #dc2626); }
        .function-icon.transit { background: linear-gradient(135deg, #06b6d4, #0891b2); }

        .function-content h3 {
            font-size: 1.3rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 8px;
        }

        .function-points {
            background: linear-gradient(135deg, #f1f5f9, #e2e8f0);
            color: #475569;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 600;
            display: inline-block;
            margin-bottom: 12px;
        }

        .function-description {
            color: #64748b;
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
            color: #64748b;
            font-size: 0.9rem;
            margin-bottom: 6px;
            padding-left: 20px;
            position: relative;
        }

        .function-features li::before {
            content: '✓';
            position: absolute;
            left: 0;
            color: #10b981;
            font-weight: bold;
        }

        .function-arrow {
            position: absolute;
            top: 32px;
            right: 32px;
            color: #94a3b8;
            font-size: 1.5rem;
            transition: all 0.3s ease;
        }

        .function-card:hover .function-arrow {
            color: #64748b;
            transform: translateX(4px);
        }

        /* Quick Actions */
        .quick-actions {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 32px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            position: relative;
            overflow: hidden;
        }

        .quick-actions::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, #64748b, #94a3b8);
        }

        .quick-actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-top: 20px;
        }

        .quick-action-btn {
            background: white;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            padding: 16px;
            text-align: center;
            text-decoration: none;
            color: #64748b;
            font-weight: 600;
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
        }

        .quick-action-btn:hover {
            background: #64748b;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(100, 116, 139, 0.2);
            text-decoration: none;
        }

        .quick-action-btn i {
            font-size: 1.5rem;
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
        .functions-section,
        .quick-actions {
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
                <a href="admin.jsp" class="navbar-brand">
                    <i class="fas fa-train"></i>
                    IRCTC
                </a>
                <div class="admin-badge">
                    <i class="fas fa-shield-alt"></i>
                    <span>ADMIN PORTAL</span>
                </div>
            </div>
            <div class="nav-actions">
                <div class="user-menu">
                    <button class="user-button">
                        <i class="fas fa-user-shield"></i>
                        <span><%= user %></span>
                        <i class="fas fa-chevron-down"></i>
                    </button>
                </div>
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
                    <h1>Admin Dashboard</h1>
                    <p>Welcome back, <%= adminName %>! Manage your IRCTC system efficiently.</p>
                </div>
                <div class="system-time">
                    <i class="fas fa-clock"></i>
                    <span id="currentTime"></span>
                </div>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="stats-section">
            <div class="stat-card customers">
                <div class="stat-header">
                    <div>
                        <div class="stat-value"><%= totalCustomers %></div>
                        <div class="stat-label">Total Customers</div>
                    </div>
                    <div class="stat-icon customers">
                        <i class="fas fa-users"></i>
                    </div>
                </div>
            </div>
            <div class="stat-card reservations">
                <div class="stat-header">
                    <div>
                        <div class="stat-value"><%= totalReservations %></div>
                        <div class="stat-label">Active Reservations</div>
                    </div>
                    <div class="stat-icon reservations">
                        <i class="fas fa-ticket-alt"></i>
                    </div>
                </div>
            </div>
            <div class="stat-card reps">
                <div class="stat-header">
                    <div>
                        <div class="stat-value"><%= totalReps %></div>
                        <div class="stat-label">Customer Reps</div>
                    </div>
                    <div class="stat-icon reps">
                        <i class="fas fa-headset"></i>
                    </div>
                </div>
            </div>
            <div class="stat-card revenue">
                <div class="stat-header">
                    <div>
                        <div class="stat-value">$<%= String.format("%.0f", totalRevenue) %></div>
                        <div class="stat-label">Total Revenue</div>
                    </div>
                    <div class="stat-icon revenue">
                        <i class="fas fa-dollar-sign"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Admin Functions -->
        <div class="functions-section">
            <h2 class="section-title">
                <i class="fas fa-cogs"></i>
                Administrative Functions
            </h2>
            <div class="functions-grid">
                <!-- Customer Rep Management -->
                <a href="rep-management.jsp" class="function-card rep-management">
                    <div class="function-header">
                        <div class="function-icon rep-management">
                            <i class="fas fa-user-cog"></i>
                        </div>
                        <div class="function-content">
                            <!-- <div class="function-points">9 Points</div> -->
                            <h3>Rep Management</h3>
                        </div>
                    </div>
                    <p class="function-description">
                        Comprehensive customer representative management system with full CRUD operations.
                    </p>
                    <ul class="function-features">
                        <li>Add new customer representatives</li>
                        <li>Edit existing representative information</li>
                        <li>Delete representatives from system</li>
                        <li>View all representatives with details</li>
                    </ul>
                    <i class="fas fa-arrow-right function-arrow"></i>
                </a>

                <!-- Sales Reports -->
                <a href="sales-reports.jsp" class="function-card sales-reports">
                    <div class="function-header">
                        <div class="function-icon sales-reports">
                            <i class="fas fa-chart-line"></i>
                        </div>
                        <div class="function-content">
                            <!-- <div class="function-points">3 Points</div> -->
                            <h3>Sales Reports</h3>
                        </div>
                    </div>
                    <p class="function-description">
                        Generate detailed monthly sales reports with analytics and insights.
                    </p>
                    <ul class="function-features">
                        <li>Monthly sales data analysis</li>
                        <li>Revenue trends and patterns</li>
                        <li>Visual charts and graphs</li>
                        <li>Export reports to PDF/Excel</li>
                    </ul>
                    <i class="fas fa-arrow-right function-arrow"></i>
                </a>

                <!-- Reservation Lists -->
                <a href="reservation-lists.jsp" class="function-card reservations">
                    <div class="function-header">
                        <div class="function-icon reservations">
                            <i class="fas fa-list-alt"></i>
                        </div>
                        <div class="function-content">
                            <!-- <div class="function-points">5 Points</div> -->
                            <h3>Reservation Lists</h3>
                        </div>
                    </div>
                    <p class="function-description">
                        Advanced reservation listing with multiple filtering and sorting options.
                    </p>
                    <ul class="function-features">
                        <li>Filter by transit line</li>
                        <li>Filter by customer name</li>
                        <li>Sort by date, fare, status</li>
                        <li>Export filtered results</li>
                    </ul>
                    <i class="fas fa-arrow-right function-arrow"></i>
                </a>

                <!-- Revenue Reports -->
                <a href="revenue-reports.jsp" class="function-card revenue">
                    <div class="function-header">
                        <div class="function-icon revenue">
                            <i class="fas fa-money-bill-trend-up"></i>
                        </div>
                        <div class="function-content">
                            <!-- <div class="function-points">5 Points</div> -->
                            <h3>Revenue Analysis</h3>
                        </div>
                    </div>
                    <p class="function-description">
                        Comprehensive revenue analysis with multiple breakdown options and insights.
                    </p>
                    <ul class="function-features">
                        <li>Revenue by transit line</li>
                        <li>Revenue by customer analysis</li>
                        <li>Time-based revenue trends</li>
                        <li>Profit margin calculations</li>
                    </ul>
                    <i class="fas fa-arrow-right function-arrow"></i>
                </a>

                <!-- Best Customer Analysis -->
                <a href="customer-analysis.jsp" class="function-card customers">
                    <div class="function-header">
                        <div class="function-icon customers">
                            <i class="fas fa-crown"></i>
                        </div>
                        <div class="function-content">
                            <!-- <div class="function-points">4 Points</div> -->
                            <h3>Best Customers</h3>
                        </div>
                    </div>
                    <p class="function-description">
                        Identify and analyze top-performing customers based on various metrics.
                    </p>
                    <ul class="function-features">
                        <li>Top customers by revenue</li>
                        <li>Most frequent travelers</li>
                        <li>Customer loyalty analysis</li>
                        <li>Customer lifetime value</li>
                    </ul>
                    <i class="fas fa-arrow-right function-arrow"></i>
                </a>

                <!-- Active Transit Lines -->
                <a href="transit-analysis.jsp" class="function-card transit">
                    <div class="function-header">
                        <div class="function-icon transit">
                            <i class="fas fa-route"></i>
                        </div>
                        <div class="function-content">
                            <!-- <div class="function-points">4 Points</div> -->
                            <h3>Transit Analysis</h3>
                        </div>
                    </div>
                    <p class="function-description">
                        Analyze the most active and profitable transit lines with detailed metrics.
                    </p>
                    <ul class="function-features">
                        <li>Top 5 most active lines</li>
                        <li>Usage frequency analysis</li>
                        <li>Route performance metrics</li>
                        <li>Capacity utilization reports</li>
                    </ul>
                    <i class="fas fa-arrow-right function-arrow"></i>
                </a>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="quick-actions">
            <h3 class="section-title">
                <i class="fas fa-bolt"></i>
                Quick Actions
            </h3>
            <div class="quick-actions-grid">
                <a href="search.jsp" class="quick-action-btn">
                    <i class="fas fa-search"></i>
                    <span>Search System</span>
                </a>
                <a href="backup.jsp" class="quick-action-btn">
                    <i class="fas fa-download"></i>
                    <span>Backup Data</span>
                </a>
                <a href="settings.jsp" class="quick-action-btn">
                    <i class="fas fa-cog"></i>
                    <span>System Settings</span>
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

        // Smooth scroll for internal links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth'
                    });
                }
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