
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
    String searchQuery = request.getParameter("search");
    String categoryFilter = request.getParameter("category");

    // Handle form submissions
    if ("POST".equals(request.getMethod())) {
        if ("add".equals(action)) {
            String question = request.getParameter("question");
            String answer = request.getParameter("answer");
            String category = request.getParameter("category");
            String priority = request.getParameter("priority");
            
            try {
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO qa_management (question, answer, category, priority, created_by) VALUES (?, ?, ?, ?, ?)"
                );
                ps.setString(1, question);
                ps.setString(2, answer);
                ps.setString(3, category);
                ps.setString(4, priority);
                ps.setString(5, user);
                
                int result = ps.executeUpdate();
                if (result > 0) {
                    message = "Q&A entry added successfully!";
                    messageType = "success";
                } else {
                    message = "Failed to add Q&A entry.";
                    messageType = "error";
                }
                ps.close();
                con.close();
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                messageType = "error";
            }
        } else if ("edit".equals(action)) {
            String qaId = request.getParameter("qaId");
            String question = request.getParameter("question");
            String answer = request.getParameter("answer");
            String category = request.getParameter("category");
            String priority = request.getParameter("priority");
            String status = request.getParameter("status");
            
            try {
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(
                    "UPDATE qa_management SET question=?, answer=?, category=?, priority=?, status=? WHERE id=?"
                );
                ps.setString(1, question);
                ps.setString(2, answer);
                ps.setString(3, category);
                ps.setString(4, priority);
                ps.setString(5, status);
                ps.setInt(6, Integer.parseInt(qaId));
                
                int result = ps.executeUpdate();
                if (result > 0) {
                    message = "Q&A entry updated successfully!";
                    messageType = "success";
                } else {
                    message = "Failed to update Q&A entry.";
                    messageType = "error";
                }
                ps.close();
                con.close();
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                messageType = "error";
            }
        } else if ("delete".equals(action)) {
            String qaId = request.getParameter("qaId");
            
            try {
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement("DELETE FROM qa_management WHERE id=?");
                ps.setInt(1, Integer.parseInt(qaId));
                
                int result = ps.executeUpdate();
                if (result > 0) {
                    message = "Q&A entry deleted successfully!";
                    messageType = "success";
                } else {
                    message = "Failed to delete Q&A entry.";
                    messageType = "error";
                }
                ps.close();
                con.close();
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                messageType = "error";
            }
        } else if ("updateView".equals(action)) {
            String qaId = request.getParameter("qaId");
            
            try {
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement("UPDATE qa_management SET view_count = view_count + 1 WHERE id=?");
                ps.setInt(1, Integer.parseInt(qaId));
                ps.executeUpdate();
                ps.close();
                con.close();
            } catch (Exception e) {
                // Silent fail for view count update
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Q&A Management - IRCTC Professional Portal</title>
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
            --accent-orange: #F59E0B;
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
            background: linear-gradient(135deg, var(--accent-orange), #F97316);
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
            background: linear-gradient(90deg, var(--accent-orange), #F97316, #FB923C);
        }

        .page-title {
            font-size: 3rem;
            font-weight: 900;
            background: linear-gradient(135deg, var(--primary-blue), var(--accent-orange));
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

        .search-filters {
            display: grid;
            grid-template-columns: 1fr auto auto auto;
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
            border-color: var(--accent-orange);
            box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.1);
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
            border-color: var(--accent-orange);
            box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.1);
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

        .btn-primary {
            background: linear-gradient(135deg, var(--accent-blue), #6366F1);
            color: white;
        }

        .btn-success {
            background: linear-gradient(135deg, var(--success-green), #059669);
            color: white;
        }

        .btn-warning {
            background: linear-gradient(135deg, var(--warning-orange), #D97706);
            color: white;
        }

        .btn-danger {
            background: linear-gradient(135deg, var(--danger-red), #DC2626);
            color: white;
        }

        .btn-secondary {
            background: linear-gradient(135deg, #6B7280, #4B5563);
            color: white;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }

        .qa-grid {
            display: grid;
            gap: 24px;
        }

        .qa-card {
            background: linear-gradient(135deg, white, var(--background-light));
            border-radius: 20px;
            padding: 28px;
            box-shadow: var(--shadow-soft);
            border: 1px solid var(--border-light);
            transition: all 0.3s ease;
            position: relative;
        }

        .qa-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-medium);
        }

        .qa-header {
            display: flex;
            justify-content: between;
            align-items: flex-start;
            margin-bottom: 16px;
            gap: 16px;
        }

        .qa-question {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--primary-blue);
            line-height: 1.4;
            flex: 1;
        }

        .qa-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            align-items: center;
            margin-bottom: 16px;
        }

        .qa-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .priority-high {
            background: linear-gradient(135deg, #FEE2E2, #FECACA);
            color: #991B1B;
        }

        .priority-medium {
            background: linear-gradient(135deg, #FEF3C7, #FDE68A);
            color: #92400E;
        }

        .priority-low {
            background: linear-gradient(135deg, #D1FAE5, #A7F3D0);
            color: #065F46;
        }

        .category-badge {
            background: linear-gradient(135deg, var(--light-blue), #DBEAFE);
            color: #1E40AF;
        }

        .status-active {
            background: linear-gradient(135deg, #ECFDF5, #D1FAE5);
            color: #065F46;
        }

        .status-inactive {
            background: linear-gradient(135deg, #F3F4F6, #E5E7EB);
            color: #374151;
        }

        .qa-answer {
            color: var(--text-secondary);
            line-height: 1.6;
            margin-bottom: 20px;
            font-size: 1rem;
        }

        .qa-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 16px;
            border-top: 1px solid var(--border-light);
        }

        .qa-stats {
            display: flex;
            gap: 16px;
            color: var(--text-secondary);
            font-size: 0.875rem;
        }

        .qa-actions {
            display: flex;
            gap: 8px;
        }

        .btn-sm {
            padding: 8px 12px;
            font-size: 0.875rem;
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
        }

        .stat-value {
            font-size: 2rem;
            font-weight: 800;
            color: var(--accent-orange);
            margin-bottom: 4px;
        }

        .stat-label {
            color: var(--text-secondary);
            font-weight: 600;
            font-size: 0.9rem;
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

        .form-input, .form-textarea, .form-select {
            width: 100%;
            padding: 14px 16px;
            border: 2px solid var(--border-light);
            border-radius: 12px;
            font-size: 1rem;
            transition: all 0.3s ease;
            font-family: inherit;
        }

        .form-input:focus, .form-textarea:focus, .form-select:focus {
            outline: none;
            border-color: var(--accent-orange);
            box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.1);
        }

        .form-textarea {
            min-height: 120px;
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
            
            .search-filters {
                grid-template-columns: 1fr;
                gap: 12px;
            }
            
            .form-row {
                grid-template-columns: 1fr;
            }
            
            .section-header {
                flex-direction: column;
                gap: 16px;
                align-items: stretch;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .qa-header {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .qa-footer {
                flex-direction: column;
                gap: 12px;
                align-items: flex-start;
            }
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar">
        <div class="navbar-content">
            <a href="rep-dashboard.jsp" class="navbar-brand">
                <i class="fas fa-question-circle"></i>
                <div class="brand-text">
                    <span class="brand-main">Q&A Management</span>
                    <span class="brand-sub">Knowledge Base Portal</span>
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
            <h1 class="page-title">Q&A Management</h1>
            <p class="page-subtitle">Browse customer questions, search by keywords, and provide helpful answers</p>
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
                int totalQAs = 0;
                int activeQAs = 0;
                int totalViews = 0;
                int categoriesCount = 0;
                try {
                    Connection con = DBConnection.getConnection();
                    
                    // Total Q&As
                    PreparedStatement ps1 = con.prepareStatement("SELECT COUNT(*) as total FROM qa_management");
                    ResultSet rs1 = ps1.executeQuery();
                    if (rs1.next()) totalQAs = rs1.getInt("total");
                    rs1.close();
                    ps1.close();
                    
                    // Active Q&As
                    PreparedStatement ps2 = con.prepareStatement("SELECT COUNT(*) as active FROM qa_management WHERE status='Active'");
                    ResultSet rs2 = ps2.executeQuery();
                    if (rs2.next()) activeQAs = rs2.getInt("active");
                    rs2.close();
                    ps2.close();
                    
                    // Total Views
                    PreparedStatement ps3 = con.prepareStatement("SELECT SUM(view_count) as total_views FROM qa_management");
                    ResultSet rs3 = ps3.executeQuery();
                    if (rs3.next()) totalViews = rs3.getInt("total_views");
                    rs3.close();
                    ps3.close();
                    
                    // Categories
                    PreparedStatement ps4 = con.prepareStatement("SELECT COUNT(DISTINCT category) as categories FROM qa_management");
                    ResultSet rs4 = ps4.executeQuery();
                    if (rs4.next()) categoriesCount = rs4.getInt("categories");
                    rs4.close();
                    ps4.close();
                    
                    con.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>
            <div class="stat-card">
                <div class="stat-value"><%= totalQAs %></div>
                <div class="stat-label">Total Q&As</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= activeQAs %></div>
                <div class="stat-label">Active Q&As</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= totalViews %></div>
                <div class="stat-label">Total Views</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= categoriesCount %></div>
                <div class="stat-label">Categories</div>
            </div>
        </div>

        <!-- Q&A Management -->
        <div class="content-section">
            <div class="section-header">
                <h2 class="section-title">
                    <i class="fas fa-list"></i>
                    Browse Questions & Answers
                </h2>
                <button onclick="openAddModal()" class="btn btn-success">
                    <i class="fas fa-plus"></i>
                    Add New Q&A
                </button>
            </div>

            <!-- Search and Filters -->
            <form method="GET" action="qa-system.jsp" class="search-filters">
                <div class="search-box">
                    <i class="fas fa-search search-icon"></i>
                    <input type="text" name="search" class="search-input" 
                           placeholder="Search questions and answers..." 
                           value="<%= searchQuery != null ? searchQuery : "" %>">
                </div>
                
                <select name="category" class="filter-select">
                    <option value="">All Categories</option>
                    <%
                        try {
                            Connection con = DBConnection.getConnection();
                            PreparedStatement ps = con.prepareStatement("SELECT DISTINCT category FROM qa_management ORDER BY category");
                            ResultSet rs = ps.executeQuery();
                            while (rs.next()) {
                                String category = rs.getString("category");
                                String selected = category.equals(categoryFilter) ? "selected" : "";
                    %>
                    <option value="<%= category %>" <%= selected %>><%= category %></option>
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
                
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-filter"></i>
                    Filter
                </button>
                
                <a href="qa-system.jsp" class="btn btn-secondary">
                    <i class="fas fa-refresh"></i>
                    Reset
                </a>
            </form>

            <!-- Q&A Grid -->
            <div class="qa-grid">
                <%
                    try {
                        Connection con = DBConnection.getConnection();
                        
                        // Build query with search and filter
                        StringBuilder queryBuilder = new StringBuilder("SELECT * FROM qa_management WHERE 1=1");
                        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                            queryBuilder.append(" AND (question LIKE ? OR answer LIKE ?)");
                        }
                        if (categoryFilter != null && !categoryFilter.trim().isEmpty()) {
                            queryBuilder.append(" AND category = ?");
                        }
                        queryBuilder.append(" ORDER BY created_date DESC");
                        
                        PreparedStatement ps = con.prepareStatement(queryBuilder.toString());
                        
                        int paramIndex = 1;
                        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                            String searchTerm = "%" + searchQuery + "%";
                            ps.setString(paramIndex++, searchTerm);
                            ps.setString(paramIndex++, searchTerm);
                        }
                        if (categoryFilter != null && !categoryFilter.trim().isEmpty()) {
                            ps.setString(paramIndex++, categoryFilter);
                        }
                        
                        ResultSet rs = ps.executeQuery();
                        
                        boolean hasData = false;
                        while (rs.next()) {
                            hasData = true;
                            int id = rs.getInt("id");
                            String question = rs.getString("question");
                            String answer = rs.getString("answer");
                            String category = rs.getString("category");
                            String priority = rs.getString("priority");
                            String status = rs.getString("status");
                            String createdBy = rs.getString("created_by");
                            Timestamp createdDate = rs.getTimestamp("created_date");
                            int viewCount = rs.getInt("view_count");
                %>
                <div class="qa-card">
                    <div class="qa-header">
                        <div class="qa-question"><%= question %></div>
                    </div>
                    
                    <div class="qa-meta">
                        <span class="qa-badge category-badge"><%= category %></span>
                        <span class="qa-badge priority-<%= priority.toLowerCase() %>"><%= priority %> Priority</span>
                        <span class="qa-badge status-<%= status.toLowerCase() %>"><%= status %></span>
                    </div>
                    
                    <div class="qa-answer"><%= answer %></div>
                    
                    <div class="qa-footer">
                        <div class="qa-stats">
                            <span><i class="fas fa-eye"></i> <%= viewCount %> views</span>
                            <span><i class="fas fa-user"></i> <%= createdBy %></span>
                            <span><i class="fas fa-calendar"></i> <%= new java.text.SimpleDateFormat("MMM dd, yyyy").format(createdDate) %></span>
                        </div>
                        
                        <div class="qa-actions">
                            <button onclick="viewQA(<%= id %>)" class="btn btn-primary btn-sm">
                                <i class="fas fa-eye"></i>
                                View
                            </button>
                            <button onclick="editQA(<%= id %>, '<%= question.replace("'", "\\'") %>', '<%= answer.replace("'", "\\'") %>', '<%= category %>', '<%= priority %>', '<%= status %>')" 
                                    class="btn btn-warning btn-sm">
                                <i class="fas fa-edit"></i>
                                Edit
                            </button>
                            <form method="POST" action="qa-system.jsp" style="display: inline;" 
                                  onsubmit="return confirm('Are you sure you want to delete this Q&A? This action cannot be undone.')">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="qaId" value="<%= id %>">
                                <button type="submit" class="btn btn-danger btn-sm">
                                    <i class="fas fa-trash"></i>
                                    Delete
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
                <%
                        }
                        
                        if (!hasData) {
                %>
                <div class="no-data">
                    <i class="fas fa-question-circle"></i>
                    <h3>No Q&As Found</h3>
                    <p>No questions and answers match your search criteria.</p>
                    <button onclick="openAddModal()" class="btn btn-success" style="margin-top: 20px;">
                        <i class="fas fa-plus"></i>
                        Add Your First Q&A
                    </button>
                </div>
                <%
                        }
                        
                        rs.close();
                        ps.close();
                        con.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                %>
                <div class="no-data">
                    <i class="fas fa-exclamation-triangle"></i>
                    <h3>Database Error</h3>
                    <p>Please ensure the qa_management table exists in your database.</p>
                    <small style="color: #EF4444; margin-top: 8px; display: block;">
                        Error: <%= e.getMessage() %>
                    </small>
                </div>
                <%
                    }
                %>
            </div>
        </div>
    </div>

    <!-- Add Modal -->
    <div id="addModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">
                    <i class="fas fa-plus-circle"></i>
                    Add New Q&A
                </h2>
                <button class="close" onclick="closeAddModal()">&times;</button>
            </div>
            <form method="POST" action="qa-system.jsp" id="addForm">
                <input type="hidden" name="action" value="add">
                
                <div class="form-group">
                    <label class="form-label">Question</label>
                    <textarea class="form-textarea" name="question" placeholder="Enter the question..." required></textarea>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Answer</label>
                    <textarea class="form-textarea" name="answer" placeholder="Enter the detailed answer..." required></textarea>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Category</label>
                        <select class="form-select" name="category" required>
                            <option value="">Select Category</option>
                            <option value="Booking">Booking</option>
                            <option value="Cancellation">Cancellation</option>
                            <option value="Refund">Refund</option>
                            <option value="Travel Requirements">Travel Requirements</option>
                            <option value="Train Status">Train Status</option>
                            <option value="Technical Support">Technical Support</option>
                            <option value="General">General</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Priority</label>
                        <select class="form-select" name="priority" required>
                            <option value="Medium">Medium</option>
                            <option value="High">High</option>
                            <option value="Low">Low</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="button" onclick="closeAddModal()" class="btn btn-secondary">
                        <i class="fas fa-times"></i>
                        Cancel
                    </button>
                    <button type="submit" class="btn btn-success">
                        <i class="fas fa-plus"></i>
                        Add Q&A
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
                    Edit Q&A
                </h2>
                <button class="close" onclick="closeEditModal()">&times;</button>
            </div>
            <form method="POST" action="qa-system.jsp" id="editForm">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" id="editQAId" name="qaId">
                
                <div class="form-group">
                    <label class="form-label">Question</label>
                    <textarea class="form-textarea" id="editQuestion" name="question" required></textarea>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Answer</label>
                    <textarea class="form-textarea" id="editAnswer" name="answer" required></textarea>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Category</label>
                        <select class="form-select" id="editCategory" name="category" required>
                            <option value="Booking">Booking</option>
                            <option value="Cancellation">Cancellation</option>
                            <option value="Refund">Refund</option>
                            <option value="Travel Requirements">Travel Requirements</option>
                            <option value="Train Status">Train Status</option>
                            <option value="Technical Support">Technical Support</option>
                            <option value="General">General</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Priority</label>
                        <select class="form-select" id="editPriority" name="priority" required>
                            <option value="High">High</option>
                            <option value="Medium">Medium</option>
                            <option value="Low">Low</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select class="form-select" id="editStatus" name="status" required>
                        <option value="Active">Active</option>
                        <option value="Inactive">Inactive</option>
                    </select>
                </div>
                
                <div class="form-actions">
                    <button type="button" onclick="closeEditModal()" class="btn btn-secondary">
                        <i class="fas fa-times"></i>
                        Cancel
                    </button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i>
                        Update Q&A
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
            document.getElementById('addForm').reset();
            addModal.style.display = 'block';
            document.body.style.overflow = 'hidden';
        }

        function closeAddModal() {
            addModal.style.display = 'none';
            document.body.style.overflow = 'auto';
        }

        function editQA(id, question, answer, category, priority, status) {
            document.getElementById('editQAId').value = id;
            document.getElementById('editQuestion').value = question;
            document.getElementById('editAnswer').value = answer;
            document.getElementById('editCategory').value = category;
            document.getElementById('editPriority').value = priority;
            document.getElementById('editStatus').value = status;
            editModal.style.display = 'block';
            document.body.style.overflow = 'hidden';
        }

        function closeEditModal() {
            editModal.style.display = 'none';
            document.body.style.overflow = 'auto';
        }

        function viewQA(id) {
            // Update view count
            fetch('qa-system.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'action=updateView&qaId=' + id
            });
            
            // Refresh page to show updated view count
            setTimeout(() => {
                location.reload();
            }, 100);
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

        // Enhanced search functionality
        document.querySelector('.search-input').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                this.closest('form').submit();
            }
        });
    </script>
</body>
</html>