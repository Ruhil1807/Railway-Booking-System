<%@ page import="java.sql.*, java.io.PrintWriter" %>
<%@ page import="util.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>

<%
    String user = (String) session.getAttribute("username");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String firstName = "";
    String lastName = "";
    String userEmail = "";

    try {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement("SELECT First_Name, Last_Name, Email FROM customer_data WHERE Username = ?");
        ps.setString(1, user);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            firstName = rs.getString("First_Name");
            lastName = rs.getString("Last_Name");
            userEmail = rs.getString("Email");
        }

        rs.close();
        ps.close();
        con.close();
    } catch (Exception e) {
        e.printStackTrace(new PrintWriter(out));
    }

    // Handle question submission
    String message = "";
    String messageType = "";
    if ("POST".equals(request.getMethod()) && "submitQuestion".equals(request.getParameter("action"))) {
        String subject = request.getParameter("subject");
        String questionText = request.getParameter("questionText");
        String category = request.getParameter("category");
        String priority = request.getParameter("priority");

        try {
            Connection con = DBConnection.getConnection();
            
            // Generate ticket number
            String ticketNumber = "TKT-" + java.time.Year.now().getValue() + "-" + System.currentTimeMillis() % 100000;
            
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO support_tickets (ticket_number, customer_name, customer_email, customer_phone, subject, description, category, priority, status, created_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Open', NOW())"
            );
            ps.setString(1, ticketNumber);
            ps.setString(2, firstName + " " + lastName);
            ps.setString(3, userEmail);
            ps.setString(4, ""); // Phone can be empty
            ps.setString(5, subject);
            ps.setString(6, questionText);
            ps.setString(7, category);
            ps.setString(8, priority);
            
            ps.executeUpdate();
            ps.close();
            con.close();
            
            message = "Your question has been submitted successfully! Ticket Number: " + ticketNumber;
            messageType = "success";
        } catch (Exception e) {
            message = "Error submitting question: " + e.getMessage();
            messageType = "error";
            e.printStackTrace(new PrintWriter(out));
        }
    }

    // Get search parameter
    String searchQuery = request.getParameter("search");
    String categoryFilter = request.getParameter("categoryFilter");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - IRCTC</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-50: #f8fafc;
            --primary-100: #f1f5f9;
            --primary-200: #e2e8f0;
            --primary-300: #cbd5e1;
            --primary-400: #94a3b8;
            --primary-500: #64748b;
            --primary-600: #475569;
            --primary-700: #334155;
            --primary-800: #1e293b;
            --primary-900: #0f172a;
            
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
            
            --accent-blue: #3b82f6;
            --accent-green: #10b981;
            --accent-amber: #f59e0b;
            --accent-red: #ef4444;
            
            --glass-bg: rgba(255, 255, 255, 0.25);
            --glass-border: rgba(255, 255, 255, 0.18);
            --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
            --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
            --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
            --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
            --shadow-2xl: 0 25px 50px -12px rgb(0 0 0 / 0.25);
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
                radial-gradient(circle at 20% 50%, rgba(120, 119, 198, 0.05) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
                radial-gradient(circle at 40% 80%, rgba(120, 119, 198, 0.03) 0%, transparent 50%);
            pointer-events: none;
            z-index: -1;
        }

        /* Navigation */
        .navbar {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(20px) saturate(180%);
            border-bottom: 1px solid var(--neutral-200);
            padding: 1rem 2rem;
            position: sticky;
            top: 0;
            z-index: 1000;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .navbar-content {
            max-width: 1400px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .navbar-brand {
            display: flex;
            align-items: center;
            font-weight: 700;
            font-size: 1.5rem;
            color: var(--primary-800);
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .navbar-brand:hover {
            transform: translateY(-1px);
            color: var(--accent-blue);
        }

        .navbar-brand i {
            font-size: 1.8rem;
            margin-right: 12px;
            color: var(--accent-blue);
            filter: drop-shadow(0 2px 4px rgba(59, 130, 246, 0.2));
        }

        .nav-actions {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .btn-nav {
            padding: 10px 20px;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.95rem;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: none;
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--accent-blue), #2563eb);
            color: white;
            box-shadow: var(--shadow-md);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
            color: white;
            text-decoration: none;
        }

        .btn-secondary {
            background: white;
            color: var(--primary-600);
            border: 1.5px solid var(--primary-200);
            box-shadow: var(--shadow-sm);
        }

        .btn-secondary:hover {
            background: var(--primary-50);
            border-color: var(--primary-300);
            transform: translateY(-1px);
            text-decoration: none;
            box-shadow: var(--shadow-md);
        }

        /* Main Container */
        .main-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 40px 24px;
        }

        /* Welcome Section */
        .welcome-section {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px) saturate(180%);
            border: 1px solid var(--glass-border);
            border-radius: 24px;
            padding: 60px 40px;
            margin-bottom: 40px;
            box-shadow: var(--shadow-2xl);
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .welcome-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, 
                rgba(59, 130, 246, 0.03) 0%, 
                rgba(255, 255, 255, 0.05) 50%, 
                rgba(16, 185, 129, 0.03) 100%);
            pointer-events: none;
        }

        .welcome-text {
            font-size: 3.5rem;
            font-weight: 800;
            background: linear-gradient(135deg, var(--primary-800), var(--primary-600), var(--accent-blue));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 16px;
            position: relative;
            z-index: 1;
            letter-spacing: -0.02em;
        }

        .welcome-subtitle {
            font-size: 1.2rem;
            color: var(--neutral-600);
            font-weight: 400;
            position: relative;
            z-index: 1;
            max-width: 600px;
            margin: 0 auto;
        }

        /* Section Cards */
        .section-card {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(20px) saturate(180%);
            border: 1px solid var(--neutral-200);
            border-radius: 20px;
            padding: 32px;
            margin-bottom: 32px;
            box-shadow: var(--shadow-lg);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

        .section-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, var(--accent-blue), var(--accent-green));
            opacity: 0.8;
        }

        .section-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-2xl);
            border-color: var(--primary-300);
        }

        .section-card.qa::before {
            background: linear-gradient(90deg, var(--accent-green), #059669);
        }

        .section-title {
            font-size: 1.75rem;
            font-weight: 700;
            color: var(--primary-800);
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .section-title i {
            width: 44px;
            height: 44px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--accent-blue), #2563eb);
            color: white;
            border-radius: 12px;
            font-size: 1.1rem;
            box-shadow: var(--shadow-md);
        }

        .section-title.qa i {
            background: linear-gradient(135deg, var(--accent-green), #059669);
        }

        /* Professional Table */
        .reservation-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--neutral-200);
        }

        .reservation-table th {
            background: linear-gradient(135deg, var(--neutral-50), var(--primary-50));
            color: var(--primary-700);
            font-weight: 600;
            padding: 20px 24px;
            text-align: left;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            border-bottom: 1px solid var(--neutral-200);
        }

        .reservation-table td {
            padding: 20px 24px;
            border-bottom: 1px solid var(--neutral-100);
            vertical-align: middle;
            font-weight: 500;
            color: var(--neutral-700);
        }

        .reservation-table tr:last-child td {
            border-bottom: none;
        }

        .reservation-table tr:hover {
            background: linear-gradient(135deg, rgba(59, 130, 246, 0.02), rgba(16, 185, 129, 0.02));
        }

        /* Status Badges */
        .status-badge {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            display: inline-block;
            border: 1px solid transparent;
        }

        .status-active {
            background: linear-gradient(135deg, #dcfce7, #bbf7d0);
            color: #166534;
            border-color: #86efac;
        }

        .status-cancelled {
            background: linear-gradient(135deg, #fee2e2, #fecaca);
            color: #dc2626;
            border-color: #fca5a5;
        }

        .priority-urgent { 
            background: linear-gradient(135deg, #fee2e2, #fecaca); 
            color: #dc2626; 
            border-color: #fca5a5;
        }
        .priority-high { 
            background: linear-gradient(135deg, #fef3c7, #fde68a); 
            color: #92400e; 
            border-color: #fcd34d;
        }
        .priority-medium { 
            background: linear-gradient(135deg, #dbeafe, #bfdbfe); 
            color: #1e40af; 
            border-color: #93c5fd;
        }
        .priority-low { 
            background: linear-gradient(135deg, #d1fae5, #a7f3d0); 
            color: #065f46; 
            border-color: #6ee7b7;
        }

        /* Trip Type Badges */
        .trip-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .trip-oneway {
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            color: #065f46;
            border: 1px solid #6ee7b7;
        }

        .trip-roundtrip {
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            color: #1e40af;
            border: 1px solid #93c5fd;
        }

        /* Action Buttons */
        .btn-action {
            padding: 10px 18px;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.9rem;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: none;
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .btn-view {
            background: linear-gradient(135deg, var(--accent-blue), #2563eb);
            color: white;
            box-shadow: var(--shadow-md);
        }

        .btn-view:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
            color: white;
            text-decoration: none;
        }

        .btn-success {
            background: linear-gradient(135deg, var(--accent-green), #059669);
            color: white;
            box-shadow: var(--shadow-md);
        }

        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
            color: white;
            text-decoration: none;
        }

        /* Search Box */
        .search-section {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            padding: 24px;
            border-radius: 16px;
            margin-bottom: 28px;
            box-shadow: var(--shadow-md);
            border: 1px solid var(--neutral-200);
        }

        .search-form {
            display: grid;
            grid-template-columns: 2fr 1fr auto;
            gap: 16px;
            align-items: end;
        }

        .search-group {
            display: flex;
            flex-direction: column;
        }

        .search-label {
            font-weight: 600;
            margin-bottom: 8px;
            color: var(--primary-700);
            font-size: 0.9rem;
        }

        .search-input, .search-select {
            padding: 14px 16px;
            border: 1.5px solid var(--neutral-300);
            border-radius: 12px;
            font-size: 1rem;
            transition: all 0.3s ease;
            background: white;
            font-family: inherit;
        }

        .search-input:focus, .search-select:focus {
            outline: none;
            border-color: var(--accent-blue);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
            transform: translateY(-1px);
        }

        .btn-search {
            padding: 14px 28px;
            background: linear-gradient(135deg, var(--primary-600), var(--primary-700));
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            height: fit-content;
            box-shadow: var(--shadow-md);
        }

        .btn-search:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
            background: linear-gradient(135deg, var(--primary-700), var(--primary-800));
        }

        /* Q&A Cards */
        .qa-list {
            display: grid;
            gap: 20px;
        }

        .qa-card {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            border-radius: 16px;
            padding: 28px;
            box-shadow: var(--shadow-md);
            border: 1px solid var(--neutral-200);
            border-left: 4px solid var(--accent-green);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .qa-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-xl);
            border-left-color: #059669;
        }

        .qa-question {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--primary-800);
            margin-bottom: 16px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 12px;
            transition: all 0.3s ease;
        }

        .qa-question:hover {
            color: var(--accent-blue);
        }

        .qa-question i {
            transition: transform 0.3s ease;
            color: var(--accent-green);
            font-size: 0.9rem;
        }

        .qa-answer {
            color: var(--neutral-600);
            line-height: 1.7;
            margin-bottom: 20px;
            display: none;
            padding-left: 24px;
            animation: fadeIn 0.3s ease;
        }

        .qa-answer.show {
            display: block;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .qa-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.85rem;
            color: var(--neutral-500);
            padding-left: 24px;
        }

        .qa-category {
            background: linear-gradient(135deg, var(--primary-100), var(--primary-50));
            color: var(--primary-700);
            padding: 6px 12px;
            border-radius: 20px;
            font-weight: 500;
            border: 1px solid var(--primary-200);
        }

        /* Quick Actions */
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 24px;
            margin-top: 32px;
        }

        .action-card {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 32px 24px;
            text-align: center;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            border: 1px solid var(--neutral-200);
            text-decoration: none;
            color: inherit;
            cursor: pointer;
            position: relative;
            overflow: hidden;
            box-shadow: var(--shadow-md);
        }

        .action-card:hover {
            transform: translateY(-6px);
            border-color: var(--primary-300);
            box-shadow: var(--shadow-2xl);
            text-decoration: none;
            color: inherit;
        }

        .action-card i {
            font-size: 2.5rem;
            background: linear-gradient(135deg, var(--accent-blue), var(--accent-green));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 20px;
            filter: drop-shadow(0 2px 4px rgba(59, 130, 246, 0.2));
        }

        .action-card h3 {
            font-weight: 600;
            margin-bottom: 12px;
            color: var(--primary-800);
            font-size: 1.1rem;
        }

        .action-card p {
            color: var(--neutral-600);
            font-size: 0.9rem;
            line-height: 1.6;
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 2000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(8px);
            overflow-y: auto;
            padding: 20px 0;
        }

        .modal-content {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            margin: 0 auto;
            padding: 40px;
            border-radius: 24px;
            width: 90%;
            max-width: 600px;
            position: relative;
            box-shadow: var(--shadow-2xl);
            border: 1px solid var(--neutral-200);
            max-height: calc(100vh - 40px);
            overflow-y: auto;
            top: 50%;
            transform: translateY(-50%);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 32px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--neutral-200);
        }

        .modal-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary-800);
        }

        .close {
            background: var(--neutral-100);
            border: 1px solid var(--neutral-200);
            padding: 8px 12px;
            border-radius: 10px;
            font-size: 1.2rem;
            cursor: pointer;
            color: var(--neutral-600);
            transition: all 0.3s ease;
        }

        .close:hover {
            background: var(--neutral-200);
            color: var(--neutral-800);
        }

        .form-group {
            margin-bottom: 24px;
        }

        .form-label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
            color: var(--primary-700);
            font-size: 0.9rem;
        }

        .form-input, .form-textarea, .form-select {
            width: 100%;
            padding: 14px 16px;
            border: 1.5px solid var(--neutral-300);
            border-radius: 12px;
            font-size: 1rem;
            transition: all 0.3s ease;
            font-family: inherit;
            background: white;
        }

        .form-input:focus, .form-textarea:focus, .form-select:focus {
            outline: none;
            border-color: var(--accent-blue);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
            transform: translateY(-1px);
        }

        .form-textarea {
            min-height: 120px;
            resize: vertical;
        }

        .form-actions {
            display: flex;
            gap: 16px;
            justify-content: flex-end;
            margin-top: 32px;
            padding-top: 20px;
            border-top: 1px solid var(--neutral-200);
        }

        .btn-cancel {
            padding: 12px 24px;
            background: var(--neutral-100);
            color: var(--neutral-700);
            border: 1px solid var(--neutral-300);
            border-radius: 10px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-cancel:hover {
            background: var(--neutral-200);
            border-color: var(--neutral-400);
        }

        .btn-submit {
            padding: 12px 28px;
            background: linear-gradient(135deg, var(--accent-blue), #2563eb);
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: var(--shadow-md);
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
        }

        /* Alert Messages */
        .alert {
            padding: 16px 24px;
            border-radius: 16px;
            margin-bottom: 28px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-weight: 500;
            border: 1px solid transparent;
            backdrop-filter: blur(10px);
        }

        .alert.success {
            background: rgba(220, 252, 231, 0.8);
            color: #166534;
            border-color: #86efac;
        }

        .alert.error {
            background: rgba(254, 226, 226, 0.8);
            color: #dc2626;
            border-color: #fca5a5;
        }

        /* Empty States */
        .empty-state {
            text-align: center;
            padding: 80px 20px;
            color: var(--neutral-500);
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: 24px;
            color: var(--neutral-300);
        }

        .empty-state h3 {
            font-size: 1.2rem;
            margin-bottom: 12px;
            color: var(--neutral-700);
        }

        /* Footer */
        .footer {
            background: rgba(255, 255, 255, 0.6);
            backdrop-filter: blur(20px);
            padding: 40px;
            text-align: center;
            margin-top: 80px;
            border-radius: 24px;
            color: var(--neutral-600);
            font-weight: 400;
            border: 1px solid var(--neutral-200);
        }

        /* Reservation Items */
        .reservation-item {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 20px;
            box-shadow: var(--shadow-md);
            border-left: 4px solid var(--accent-blue);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            justify-content: space-between;
            align-items: center;
            border: 1px solid var(--neutral-200);
        }

        .reservation-item:hover {
            transform: translateX(6px);
            box-shadow: var(--shadow-xl);
            border-left-color: #2563eb;
        }

        .reservation-item.cancelled {
            border-left-color: var(--accent-red);
            opacity: 0.8;
        }

        .reservation-info {
            flex: 1;
        }

        .reservation-date {
            font-weight: 600;
            color: var(--primary-800);
            font-size: 1.1rem;
        }

        .reservation-details {
            color: var(--neutral-600);
            margin-top: 6px;
        }

        /* Fare Amount Styling */
        .fare-amount {
            font-weight: 700;
            color: var(--accent-green);
            font-size: 1.2rem;
        }

        /* Responsive Design */
        @media (max-width: 1024px) {
            .search-form {
                grid-template-columns: 1fr;
                gap: 20px;
            }
        }

        @media (max-width: 768px) {
            .main-container {
                padding: 20px 16px;
            }
            
            .welcome-text {
                font-size: 2.5rem;
            }
            
            .navbar-content {
                padding: 0 16px;
            }
            
            .nav-actions {
                gap: 8px;
            }
            
            .btn-nav {
                padding: 8px 16px;
                font-size: 0.9rem;
            }
            
            .section-card {
                padding: 24px;
            }
            
            .reservation-table th,
            .reservation-table td {
                padding: 16px 12px;
                font-size: 0.9rem;
            }
            
            .quick-actions {
                grid-template-columns: 1fr;
            }

            .welcome-section {
                padding: 40px 24px;
            }

            .modal-content {
                margin: 0 auto;
                padding: 32px 24px;
                width: 95%;
                max-height: calc(100vh - 20px);
                top: 50%;
                transform: translateY(-50%);
            }

            .modal {
                padding: 10px 0;
            }
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar">
        <div class="navbar-content">
            <a class="navbar-brand" href="index.html">
                <i class="fas fa-train"></i>
                IRCTC
            </a>
            <div class="nav-actions">
                <a href="profile.jsp" class="btn-nav btn-secondary">
                    <i class="fas fa-user"></i> Profile
                </a>
                <a href="logout" class="btn-nav btn-primary">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>
    </nav>

    <div class="main-container">
        <!-- Welcome Section -->
        <div class="welcome-section">
            <div class="welcome-text">
                Welcome, <%= firstName %> <%= lastName %>!
            </div>
            <p class="welcome-subtitle">
                Manage your reservations, browse Q&A, and plan your next journey with our comprehensive dashboard
            </p>
        </div>

        <!-- Alert Messages -->
        <% if (!message.isEmpty()) { %>
            <div class="alert <%= messageType %>">
                <i class="fas fa-<%= "success".equals(messageType) ? "check-circle" : "exclamation-triangle" %>"></i>
                <%= message %>
            </div>
        <% } %>

        <!-- Q&A Section -->
        <div class="section-card qa">
            <h2 class="section-title qa">
                <i class="fas fa-question-circle"></i>
                Frequently Asked Questions
            </h2>

            <!-- Search Q&A -->
            <div class="search-section">
                <form method="GET" action="welcome.jsp" class="search-form">
                    <div class="search-group">
                        <label class="search-label">Search Questions</label>
                        <input type="text" name="search" class="search-input" 
                               placeholder="Enter keywords to search..." 
                               value="<%= searchQuery != null ? searchQuery : "" %>">
                    </div>
                    <div class="search-group">
                        <label class="search-label">Category</label>
                        <select name="categoryFilter" class="search-select">
                            <option value="">All Categories</option>
                            <option value="Booking" <%= "Booking".equals(categoryFilter) ? "selected" : "" %>>Booking</option>
                            <option value="Payment" <%= "Payment".equals(categoryFilter) ? "selected" : "" %>>Payment</option>
                            <option value="Cancellation" <%= "Cancellation".equals(categoryFilter) ? "selected" : "" %>>Cancellation</option>
                            <option value="Refund" <%= "Refund".equals(categoryFilter) ? "selected" : "" %>>Refund</option>
                            <option value="General" <%= "General".equals(categoryFilter) ? "selected" : "" %>>General</option>
                        </select>
                    </div>
                    <button type="submit" class="btn-search">
                        <i class="fas fa-search"></i>
                        Search
                    </button>
                </form>
            </div>

            <!-- Display Q&A -->
            <div class="qa-list">
                <%
                    try {
                        Connection con = DBConnection.getConnection();
                        
                        // Build query with search functionality
                        StringBuilder queryBuilder = new StringBuilder(
                            "SELECT * FROM qa_management WHERE status = 'Active'"
                        );
                        
                        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                            queryBuilder.append(" AND (question LIKE ? OR answer LIKE ?)");
                        }
                        if (categoryFilter != null && !categoryFilter.trim().isEmpty()) {
                            queryBuilder.append(" AND category = ?");
                        }
                        
                        queryBuilder.append(" ORDER BY view_count DESC, created_date DESC LIMIT 10");
                        
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
                        
                        boolean hasResults = false;
                        while (rs.next()) {
                            hasResults = true;
                            int qaId = rs.getInt("id");
                            String question = rs.getString("question");
                            String answer = rs.getString("answer");
                            String category = rs.getString("category");
                            String priority = rs.getString("priority");
                            int viewCount = rs.getInt("view_count");
                            java.sql.Timestamp createdDate = rs.getTimestamp("created_date");
                            
                            // Increment view count when displaying
                            PreparedStatement updatePs = con.prepareStatement(
                                "UPDATE qa_management SET view_count = view_count + 1 WHERE id = ?"
                            );
                            updatePs.setInt(1, qaId);
                            updatePs.executeUpdate();
                            updatePs.close();
                %>
                <div class="qa-card">
                    <div class="qa-question" onclick="toggleAnswer(<%= qaId %>)">
                        <i class="fas fa-chevron-right" id="icon-<%= qaId %>"></i>
                        <%= question %>
                    </div>
                    <div class="qa-answer" id="answer-<%= qaId %>">
                        <%= answer %>
                    </div>
                    <div class="qa-meta">
                        <div>
                            <span class="qa-category"><%= category %></span>
                            <span class="status-badge priority-<%= priority.toLowerCase() %>"><%= priority %></span>
                        </div>
                        <div>
                            <i class="fas fa-eye"></i> <%= viewCount + 1 %> views
                        </div>
                    </div>
                </div>
                <%
                        }
                        
                        if (!hasResults) {
                %>
                <div class="empty-state">
                    <i class="fas fa-search"></i>
                    <h3>No Questions Found</h3>
                    <p>No questions match your search criteria. Try different keywords or ask a new question.</p>
                </div>
                <%
                        }
                        
                        rs.close();
                        ps.close();
                        con.close();
                    } catch (Exception e) {
                        out.println("<div class='empty-state'><i class='fas fa-exclamation-triangle'></i><h3>Error Loading Q&A</h3><p>Please try again later.</p></div>");
                        e.printStackTrace(new PrintWriter(out));
                    }
                %>
            </div>

            <!-- Ask Question Button -->
            <div style="text-align: center; margin-top: 32px;">
                <button onclick="openQuestionModal()" class="btn-success">
                    <i class="fas fa-question"></i>
                    Can't find your answer? Ask a question
                </button>
            </div>
        </div>

        <!-- Upcoming Reservations -->
        <div class="section-card">
            <h2 class="section-title">
                <i class="fas fa-calendar-plus"></i>
                Upcoming Reservations
            </h2>
            <%
                try {
                    Connection con = DBConnection.getConnection();
                    // Simple query that works with current database structure
                    PreparedStatement stmt = con.prepareStatement(
                        "SELECT * FROM reservation_data " +
                        "WHERE Username = ? AND Date > CURDATE() AND COALESCE(status, 'ACTIVE') = 'ACTIVE' " +
                        "AND (journey_type = 'OUT' OR journey_type IS NULL OR trip_type = 'ONE_WAY') " +
                        "ORDER BY Date"
                    );
                    stmt.setString(1, user);
                    ResultSet rs = stmt.executeQuery();

                    if (!rs.isBeforeFirst()) {
            %>
                        <div class="empty-state">
                            <i class="fas fa-calendar-times"></i>
                            <h3>No Upcoming Reservations</h3>
                            <p>You don't have any upcoming trips planned.</p>
                        </div>
            <%
                    } else {
            %>
                        <table class="reservation-table">
                            <thead>
                                <tr>
                                    <th>Trip Type</th>
                                    <th>Travel Date</th>
                                    <th>Train</th>
                                    <th>Passengers</th>
                                    <th>Total Fare</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
            <%
                        while (rs.next()) {
                            int id = rs.getInt("Reservation_Number");
                            String status = rs.getString("status");
                            if (status == null) status = "ACTIVE";
                            
                            String tripType = rs.getString("trip_type");
                            if (tripType == null) tripType = "ONE_WAY"; // Default for existing records
                            
                            String trainName = rs.getString("Transit_line_name");
                            
                            String passengerStrRaw = rs.getString("Passenger");
                            String[] parts = passengerStrRaw.split(",");
                            StringBuilder formatted = new StringBuilder();
                            for (String part : parts) {
                                if (part.contains(":")) {
                                    String[] split = part.trim().split(":");
                                    if (split.length == 2 && !split[1].trim().equals("0")) {
                                        formatted.append(split[0].trim()).append(": ").append(split[1].trim()).append(", ");
                                    }
                                }
                            }
                            if (formatted.length() > 2) {
                                formatted.setLength(formatted.length() - 2);
                            }
                            
                            double totalFare = rs.getDouble("Total_Fare");
            %>
                                <tr>
                                    <td>
                                        <% if ("ROUND_TRIP".equals(tripType)) { %>
                                            <span class="trip-badge trip-roundtrip">
                                                <i class="fas fa-exchange-alt"></i> Round Trip
                                            </span>
                                        <% } else { %>
                                            <span class="trip-badge trip-oneway">
                                                <i class="fas fa-arrow-right"></i> One Way
                                            </span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <div style="font-weight: 600;"><%= rs.getDate("Date") %></div>
                                    </td>
                                    <td>
                                        <div style="font-weight: 600;"><%= trainName != null ? trainName : "Unknown Train" %></div>
                                    </td>
                                    <td><%= formatted.toString() %></td>
                                    <td><span class="fare-amount">$<%= String.format("%.2f", totalFare) %></span></td>
                                    <td>
                                        <a class="btn-action btn-view" href="reservation-details.jsp?id=<%= id %>">
                                            <i class="fas fa-eye"></i> View Details
                                        </a>
                                    </td>
                                </tr>
            <%
                        }
            %>
                            </tbody>
                        </table>
            <%
                    }
                    rs.close();
                    stmt.close();
                    con.close();
                } catch (Exception e) {
                    out.println("<div class='empty-state'><i class='fas fa-exclamation-triangle'></i><h3>Error Loading Reservations</h3><p>Please try again later.</p></div>");
                    e.printStackTrace(new PrintWriter(out));
                }
            %>
        </div>

        <!-- Past Reservations -->
        <div class="section-card">
            <h2 class="section-title">
                <i class="fas fa-history"></i>
                Past Reservations
            </h2>
            <%
                try {
                    Connection con = DBConnection.getConnection();
                    // Simple query for past reservations
                    PreparedStatement stmt = con.prepareStatement(
                        "SELECT * FROM reservation_data " +
                        "WHERE Username = ? AND Date < CURDATE() AND COALESCE(status, 'ACTIVE') = 'ACTIVE' " +
                       "AND (journey_type = 'OUT' OR journey_type IS NULL OR trip_type = 'ONE_WAY') " +
                        "ORDER BY Date DESC LIMIT 10"
                    );
                    stmt.setString(1, user);
                    ResultSet rs = stmt.executeQuery();

                    if (!rs.isBeforeFirst()) {
            %>
                        <div class="empty-state">
                            <i class="fas fa-clock"></i>
                            <h3>No Past Trips</h3>
                            <p>Your completed journeys will appear here.</p>
                        </div>
            <%
                    } else {
            %>
                        <div class="reservation-list" style="list-style: none; padding: 0; margin: 0;">
            <%
                        while (rs.next()) {
                            int id = rs.getInt("Reservation_Number");
                            String tripType = rs.getString("trip_type");
                            if (tripType == null) tripType = "ONE_WAY"; // Default for existing records
                            
                            String trainName = rs.getString("Transit_line_name");
                            
                            String passengerStrRaw = rs.getString("Passenger");
                            String[] parts = passengerStrRaw.split(",");
                            StringBuilder formatted = new StringBuilder();
                            for (String part : parts) {
                                if (part.contains(":")) {
                                    String[] split = part.trim().split(":");
                                    if (split.length == 2 && !split[1].trim().equals("0")) {
                                        formatted.append(split[0].trim()).append(": ").append(split[1].trim()).append(", ");
                                    }
                                }
                            }
                            if (formatted.length() > 2) {
                                formatted.setLength(formatted.length() - 2);
                            }
                            
                            double totalFare = rs.getDouble("Total_Fare");
            %>
                            <div class="reservation-item">
                                <div class="reservation-info">
                                    <div class="reservation-date">
                                        <i class="fas fa-calendar-check"></i> <%= rs.getDate("Date") %>
                                        <% if ("ROUND_TRIP".equals(tripType)) { %>
                                            <span class="trip-badge trip-roundtrip" style="margin-left: 12px;">
                                                <i class="fas fa-exchange-alt"></i> Round Trip
                                            </span>
                                        <% } %>
                                    </div>
                                    <div class="reservation-details">
                                        <i class="fas fa-train"></i> <%= trainName != null ? trainName : "Unknown Train" %> • 
                                        <i class="fas fa-users"></i> <%= formatted.toString() %> • 
                                        <span class="fare-amount">$<%= String.format("%.2f", totalFare) %></span>
                                    </div>
                                </div>
                                <a href="reservation-details.jsp?id=<%= id %>" class="btn-action btn-view">
                                    <i class="fas fa-eye"></i> View
                                </a>
                            </div>
            <%
                        }
            %>
                        </div>
            <%
                    }
                    rs.close();
                    stmt.close();
                    con.close();
                } catch (Exception e) {
                    out.println("<div class='empty-state'><i class='fas fa-exclamation-triangle'></i><h3>Error Loading Past Reservations</h3><p>Please try again later.</p></div>");
                    e.printStackTrace(new PrintWriter(out));
                }
            %>
        </div>

        <!-- Quick Actions -->
        <div class="section-card">
            <h2 class="section-title">
                <i class="fas fa-bolt"></i>
                Quick Actions
            </h2>
            <div class="quick-actions">
                <a href="search.jsp" class="action-card">
                    <i class="fas fa-search"></i>
                    <h3>Book New Ticket</h3>
                    <p>Search for trains and make a new reservation</p>
                </a>
                <div class="action-card" onclick="openQuestionModal()">
                    <i class="fas fa-question-circle"></i>
                    <h3>Ask a Question</h3>
                    <p>Get help from our customer service team</p>
                </div>
                <a href="cancel.jsp" class="action-card">
                    <i class="fas fa-times-circle"></i>
                    <h3>Cancel Reservation</h3>
                    <p>Cancel or modify your existing bookings</p>
                </a>
                <a href="profile.jsp" class="action-card">
                    <i class="fas fa-user-cog"></i>
                    <h3>Manage Profile</h3>
                    <p>Update your personal information and preferences</p>
                </a>
            </div>
        </div>

        <!-- Footer -->
        <div class="footer">
            <p>&copy; 2025 IRCTC - Indian Railway Catering and Tourism Corporation</p>
            <p>Your trusted partner for railway reservations and travel</p>
        </div>
    </div>

    <!-- Question Modal -->
    <div id="questionModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">Ask a Question</h2>
                <button class="close" onclick="closeQuestionModal()">&times;</button>
            </div>
            <form method="POST" action="welcome.jsp">
                <input type="hidden" name="action" value="submitQuestion">
                
                <div class="form-group">
                    <label class="form-label">Subject</label>
                    <input type="text" name="subject" class="form-input" 
                           placeholder="Brief description of your question" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Category</label>
                    <select name="category" class="form-select" required>
                        <option value="">Select a category</option>
                        <option value="Booking">Booking Issues</option>
                        <option value="Payment">Payment Problems</option>
                        <option value="Cancellation">Cancellation & Refund</option>
                        <option value="Technical">Technical Support</option>
                        <option value="General">General Inquiry</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Priority</label>
                    <select name="priority" class="form-select" required>
                        <option value="Low">Low</option>
                        <option value="Medium" selected>Medium</option>
                        <option value="High">High</option>
                        <option value="Urgent">Urgent</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Question Details</label>
                    <textarea name="questionText" class="form-textarea" 
                              placeholder="Please provide detailed information about your question..." required></textarea>
                </div>
                
                <div class="form-actions">
                    <button type="button" onclick="closeQuestionModal()" class="btn-cancel">
                        Cancel
                    </button>
                    <button type="submit" class="btn-submit">
                        <i class="fas fa-paper-plane"></i>
                        Submit Question
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Q&A Toggle functionality
        function toggleAnswer(qaId) {
            const answer = document.getElementById('answer-' + qaId);
            const icon = document.getElementById('icon-' + qaId);
            
            if (answer.classList.contains('show')) {
                answer.classList.remove('show');
                icon.classList.remove('fa-chevron-down');
                icon.classList.add('fa-chevron-right');
            } else {
                answer.classList.add('show');
                icon.classList.remove('fa-chevron-right');
                icon.classList.add('fa-chevron-down');
            }
        }

        // Modal functionality
        function openQuestionModal() {
            document.getElementById('questionModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
        }

        function closeQuestionModal() {
            document.getElementById('questionModal').style.display = 'none';
            document.body.style.overflow = 'auto';
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('questionModal');
            if (event.target == modal) {
                closeQuestionModal();
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
    </script>
</body>
</html>