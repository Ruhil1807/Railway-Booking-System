<%--
FIRST: Create these tables in your database before using this page

CREATE TABLE support_tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_number VARCHAR(20) UNIQUE NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100) NOT NULL,
    customer_phone VARCHAR(20),
    subject VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) DEFAULT 'General',
    priority ENUM('Low', 'Medium', 'High', 'Urgent') DEFAULT 'Medium',
    status ENUM('Open', 'In Progress', 'Pending Customer', 'Resolved', 'Closed') DEFAULT 'Open',
    assigned_to VARCHAR(100),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    first_response_date TIMESTAMP NULL,
    resolved_date TIMESTAMP NULL,
    response_time_minutes INT DEFAULT 0,
    resolution_time_hours DECIMAL(10,2) DEFAULT 0,
    escalated BOOLEAN DEFAULT FALSE,
    escalation_reason TEXT,
    satisfaction_rating INT DEFAULT 0
);

CREATE TABLE ticket_responses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    response_type ENUM('Customer', 'Agent', 'System', 'Escalation') DEFAULT 'Agent',
    response_text TEXT NOT NULL,
    responder_name VARCHAR(100),
    responder_email VARCHAR(100),
    response_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_internal BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (ticket_id) REFERENCES support_tickets(id) ON DELETE CASCADE
);

-- Insert sample data (run these separately after table creation)
INSERT INTO support_tickets (ticket_number, customer_name, customer_email, customer_phone, subject, description, category, priority, status, assigned_to) VALUES
('TKT-2025-001', 'John Smith', 'john.smith@email.com', '+1-555-0101', 'Unable to book train ticket', 'I am getting an error message when trying to book a ticket from Delhi to Mumbai. The payment page is not loading properly.', 'Booking Issues', 'High', 'Open', 'rep1'),
('TKT-2025-002', 'Mary Johnson', 'mary.j@email.com', '+1-555-0102', 'Refund not received', 'I cancelled my ticket 3 days ago but haven\'t received the refund yet. Ticket number was 12345.', 'Refund', 'Medium', 'In Progress', 'rep1'),
('TKT-2025-003', 'David Wilson', 'david.w@email.com', '+1-555-0103', 'Train delay information', 'Can you provide information about train delays for route Mumbai-Pune today?', 'General Inquiry', 'Low', 'Open', 'rep1');

INSERT INTO ticket_responses (ticket_id, response_type, response_text, responder_name, responder_email) VALUES
(1, 'Agent', 'Thank you for contacting us. We are investigating the payment issue you reported. Our technical team is working on a fix.', 'rep1', 'rep1@irctc.com'),
(2, 'Agent', 'We have located your cancellation request. The refund will be processed within 2-3 business days.', 'rep1', 'rep1@irctc.com');

--%>

<%@ page import="java.sql.*, java.io.PrintWriter, java.util.*" %>
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
    String priorityFilter = request.getParameter("priority");
    String searchQuery = request.getParameter("search");

    // Handle form submissions
    if ("POST".equals(request.getMethod())) {
        if ("respond".equals(action)) {
            String ticketId = request.getParameter("ticketId");
            String responseText = request.getParameter("responseText");
            String isInternal = request.getParameter("isInternal");
            
            try {
                Connection con = DBConnection.getConnection();
                
                // Add response
                PreparedStatement ps1 = con.prepareStatement(
                    "INSERT INTO ticket_responses (ticket_id, response_type, response_text, responder_name, responder_email, is_internal) VALUES (?, 'Agent', ?, ?, ?, ?)"
                );
                ps1.setInt(1, Integer.parseInt(ticketId));
                ps1.setString(2, responseText);
                ps1.setString(3, user);
                ps1.setString(4, user + "@irctc.com");
                ps1.setBoolean(5, isInternal != null && "true".equals(isInternal));
                ps1.executeUpdate();
                ps1.close();
                
                // Update ticket status and first response time if needed
                PreparedStatement ps2 = con.prepareStatement(
                    "UPDATE support_tickets SET status='In Progress', first_response_date=COALESCE(first_response_date, NOW()), assigned_to=? WHERE id=? AND first_response_date IS NULL"
                );
                ps2.setString(1, user);
                ps2.setInt(2, Integer.parseInt(ticketId));
                ps2.executeUpdate();
                ps2.close();
                
                con.close();
                message = "Response added successfully!";
                messageType = "success";
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                messageType = "error";
            }
        } else if ("updateStatus".equals(action)) {
            String ticketId = request.getParameter("ticketId");
            String newStatus = request.getParameter("newStatus");
            
            try {
                Connection con = DBConnection.getConnection();
                String updateQuery = "UPDATE support_tickets SET status=?";
                
                if ("Resolved".equals(newStatus) || "Closed".equals(newStatus)) {
                    updateQuery += ", resolved_date=NOW(), resolution_time_hours=TIMESTAMPDIFF(HOUR, created_date, NOW())";
                }
                updateQuery += " WHERE id=?";
                
                PreparedStatement ps = con.prepareStatement(updateQuery);
                ps.setString(1, newStatus);
                ps.setInt(2, Integer.parseInt(ticketId));
                
                ps.executeUpdate();
                ps.close();
                con.close();
                
                message = "Ticket status updated to " + newStatus + "!";
                messageType = "success";
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                messageType = "error";
            }
        } else if ("escalate".equals(action)) {
            String ticketId = request.getParameter("ticketId");
            String escalationReason = request.getParameter("escalationReason");
            
            try {
                Connection con = DBConnection.getConnection();
                
                // Update ticket as escalated
                PreparedStatement ps1 = con.prepareStatement(
                    "UPDATE support_tickets SET escalated=TRUE, escalation_reason=?, priority='Urgent' WHERE id=?"
                );
                ps1.setString(1, escalationReason);
                ps1.setInt(2, Integer.parseInt(ticketId));
                ps1.executeUpdate();
                ps1.close();
                
                // Add escalation response
                PreparedStatement ps2 = con.prepareStatement(
                    "INSERT INTO ticket_responses (ticket_id, response_type, response_text, responder_name, is_internal) VALUES (?, 'Escalation', ?, ?, TRUE)"
                );
                ps2.setInt(1, Integer.parseInt(ticketId));
                ps2.setString(2, "Ticket escalated to service team. Reason: " + escalationReason);
                ps2.setString(3, user);
                ps2.executeUpdate();
                ps2.close();
                
                con.close();
                message = "Ticket escalated to service team successfully!";
                messageType = "success";
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                messageType = "error";
            }
        } else if ("assign".equals(action)) {
            String ticketId = request.getParameter("ticketId");
            
            try {
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement("UPDATE support_tickets SET assigned_to=? WHERE id=?");
                ps.setString(1, user);
                ps.setInt(2, Integer.parseInt(ticketId));
                ps.executeUpdate();
                ps.close();
                con.close();
                
                message = "Ticket assigned to you successfully!";
                messageType = "success";
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
    <title>Customer Support - IRCTC Professional Portal</title>
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
            --accent-green: #10B981;
            --light-green: #ECFDF5;
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
            color: var(--accent-green);
        }

        .navbar-brand i {
            font-size: 2rem;
            margin-right: 12px;
            background: linear-gradient(135deg, var(--accent-green), #059669);
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
            background: linear-gradient(90deg, var(--accent-green), #059669, #047857);
        }

        .page-title {
            font-size: 3rem;
            font-weight: 900;
            background: linear-gradient(135deg, var(--primary-blue), var(--accent-green));
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

        .stat-open { color: var(--info-blue); }
        .stat-progress { color: var(--warning-orange); }
        .stat-resolved { color: var(--success-green); }
        .stat-urgent { color: var(--danger-red); }

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
            border-color: var(--accent-green);
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
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
            border-color: var(--accent-green);
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
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

        .btn-primary { background: linear-gradient(135deg, var(--info-blue), #6366F1); color: white; }
        .btn-success { background: linear-gradient(135deg, var(--success-green), #059669); color: white; }
        .btn-warning { background: linear-gradient(135deg, var(--warning-orange), #D97706); color: white; }
        .btn-danger { background: linear-gradient(135deg, var(--danger-red), #DC2626); color: white; }
        .btn-secondary { background: linear-gradient(135deg, #6B7280, #4B5563); color: white; }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }

        .btn-sm {
            padding: 8px 12px;
            font-size: 0.875rem;
        }

        .tickets-grid {
            display: grid;
            gap: 24px;
        }

        .ticket-card {
            background: linear-gradient(135deg, white, var(--background-light));
            border-radius: 20px;
            padding: 28px;
            box-shadow: var(--shadow-soft);
            border: 1px solid var(--border-light);
            transition: all 0.3s ease;
            position: relative;
        }

        .ticket-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-medium);
        }

        .ticket-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 16px;
        }

        .ticket-number {
            font-size: 1.1rem;
            font-weight: 800;
            color: var(--primary-blue);
        }

        .ticket-subject {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--primary-blue);
            margin: 8px 0;
            line-height: 1.3;
        }

        .ticket-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            align-items: center;
            margin-bottom: 16px;
        }

        .ticket-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .priority-urgent { background: linear-gradient(135deg, #FEE2E2, #FECACA); color: #991B1B; }
        .priority-high { background: linear-gradient(135deg, #FEF3C7, #FDE68A); color: #92400E; }
        .priority-medium { background: linear-gradient(135deg, #DBEAFE, #BFDBFE); color: #1E40AF; }
        .priority-low { background: linear-gradient(135deg, #D1FAE5, #A7F3D0); color: #065F46; }

        .status-open { background: linear-gradient(135deg, #DBEAFE, #BFDBFE); color: #1E40AF; }
        .status-in-progress { background: linear-gradient(135deg, #FEF3C7, #FDE68A); color: #92400E; }
        .status-pending-customer { background: linear-gradient(135deg, #F3E8FF, #E9D5FF); color: #7C2D12; }
        .status-resolved { background: linear-gradient(135deg, #D1FAE5, #A7F3D0); color: #065F46; }
        .status-closed { background: linear-gradient(135deg, #F3F4F6, #E5E7EB); color: #374151; }

        .ticket-description {
            color: var(--text-secondary);
            line-height: 1.6;
            margin-bottom: 16px;
            font-size: 1rem;
        }

        .customer-info {
            background: var(--light-green);
            padding: 16px;
            border-radius: 12px;
            margin-bottom: 16px;
        }

        .customer-name {
            font-weight: 700;
            color: var(--primary-blue);
            margin-bottom: 4px;
        }

        .customer-details {
            font-size: 0.9rem;
            color: var(--text-secondary);
        }

        .ticket-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 16px;
            border-top: 1px solid var(--border-light);
            flex-wrap: wrap;
            gap: 12px;
        }

        .ticket-stats {
            display: flex;
            gap: 16px;
            color: var(--text-secondary);
            font-size: 0.875rem;
        }

        .ticket-actions {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .escalated-banner {
            position: absolute;
            top: 16px;
            right: 16px;
            background: var(--danger-red);
            color: white;
            padding: 4px 8px;
            border-radius: 6px;
            font-size: 0.75rem;
            font-weight: 600;
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
            border-color: var(--accent-green);
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
        }

        .form-textarea {
            min-height: 120px;
            resize: vertical;
        }

        .form-actions {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            margin-top: 32px;
            padding-top: 20px;
            border-top: 2px solid var(--background-light);
        }

        .response-history {
            background: var(--background-light);
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 20px;
            max-height: 300px;
            overflow-y: auto;
        }

        .response-item {
            background: white;
            padding: 16px;
            border-radius: 8px;
            margin-bottom: 12px;
            border-left: 4px solid var(--accent-green);
        }

        .response-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
        }

        .response-author {
            font-weight: 600;
            color: var(--primary-blue);
        }

        .response-date {
            font-size: 0.875rem;
            color: var(--text-secondary);
        }

        .response-text {
            color: var(--text-primary);
            line-height: 1.5;
        }

        .conversation-timeline {
            position: relative;
            padding-left: 24px;
        }

        .conversation-timeline::before {
            content: '';
            position: absolute;
            left: 8px;
            top: 0;
            bottom: 0;
            width: 2px;
            background: var(--border-light);
        }

        .timeline-item {
            position: relative;
            margin-bottom: 20px;
        }

        .timeline-item::before {
            content: '';
            position: absolute;
            left: -20px;
            top: 8px;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: var(--accent-green);
            border: 3px solid white;
            box-shadow: 0 0 0 2px var(--border-light);
        }

        .detail-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
        }

        .detail-item {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px;
            background: white;
            border-radius: 8px;
            border: 1px solid var(--border-light);
        }

        .detail-icon {
            color: var(--accent-green);
            font-size: 1.1rem;
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
            
            .section-header {
                flex-direction: column;
                gap: 16px;
                align-items: stretch;
            }
            
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .ticket-footer {
                flex-direction: column;
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
                <i class="fas fa-headset"></i>
                <div class="brand-text">
                    <span class="brand-main">Customer Support</span>
                    <span class="brand-sub">Support Ticket Management</span>
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
            <h1 class="page-title">Customer Support</h1>
            <p class="page-subtitle">Handle customer questions, send responses, and manage support tickets</p>
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
                int openTickets = 0, inProgressTickets = 0, resolvedTickets = 0, urgentTickets = 0;
                double avgResponseTime = 0;
                try {
                    Connection con = DBConnection.getConnection();
                    
                    // Open tickets
                    PreparedStatement ps1 = con.prepareStatement("SELECT COUNT(*) as count FROM support_tickets WHERE status='Open'");
                    ResultSet rs1 = ps1.executeQuery();
                    if (rs1.next()) openTickets = rs1.getInt("count");
                    rs1.close(); ps1.close();
                    
                    // In Progress tickets
                    PreparedStatement ps2 = con.prepareStatement("SELECT COUNT(*) as count FROM support_tickets WHERE status='In Progress'");
                    ResultSet rs2 = ps2.executeQuery();
                    if (rs2.next()) inProgressTickets = rs2.getInt("count");
                    rs2.close(); ps2.close();
                    
                    // Resolved tickets
                    PreparedStatement ps3 = con.prepareStatement("SELECT COUNT(*) as count FROM support_tickets WHERE status IN ('Resolved', 'Closed')");
                    ResultSet rs3 = ps3.executeQuery();
                    if (rs3.next()) resolvedTickets = rs3.getInt("count");
                    rs3.close(); ps3.close();
                    
                    // Urgent tickets
                    PreparedStatement ps4 = con.prepareStatement("SELECT COUNT(*) as count FROM support_tickets WHERE priority='Urgent' AND status NOT IN ('Resolved', 'Closed')");
                    ResultSet rs4 = ps4.executeQuery();
                    if (rs4.next()) urgentTickets = rs4.getInt("count");
                    rs4.close(); ps4.close();
                    
                    // Average response time
                    PreparedStatement ps5 = con.prepareStatement("SELECT AVG(response_time_minutes) as avg_time FROM support_tickets WHERE response_time_minutes > 0");
                    ResultSet rs5 = ps5.executeQuery();
                    if (rs5.next()) avgResponseTime = rs5.getDouble("avg_time");
                    rs5.close(); ps5.close();
                    
                    con.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>
            <div class="stat-card">
                <div class="stat-value stat-open"><%= openTickets %></div>
                <div class="stat-label">Open Tickets</div>
            </div>
            <div class="stat-card">
                <div class="stat-value stat-progress"><%= inProgressTickets %></div>
                <div class="stat-label">In Progress</div>
            </div>
            <div class="stat-card">
                <div class="stat-value stat-resolved"><%= resolvedTickets %></div>
                <div class="stat-label">Resolved</div>
            </div>
            <div class="stat-card">
                <div class="stat-value stat-urgent"><%= urgentTickets %></div>
                <div class="stat-label">Urgent</div>
            </div>
            <div class="stat-card">
                <div class="stat-value stat-progress"><%= String.format("%.1f", avgResponseTime) %>m</div>
                <div class="stat-label">Avg Response</div>
            </div>
        </div>

        <!-- Support Tickets -->
        <div class="content-section">
            <div class="section-header">
                <h2 class="section-title">
                    <i class="fas fa-ticket-alt"></i>
                    Support Tickets
                </h2>
            </div>

            <!-- Search and Filters -->
            <form method="GET" action="customer-service.jsp" class="search-filters">
                <div class="search-box">
                    <i class="fas fa-search search-icon"></i>
                    <input type="text" name="search" class="search-input" 
                           placeholder="Search tickets..." 
                           value="<%= searchQuery != null ? searchQuery : "" %>">
                </div>
                
                <select name="status" class="filter-select">
                    <option value="">All Status</option>
                    <option value="Open" <%= "Open".equals(statusFilter) ? "selected" : "" %>>Open</option>
                    <option value="In Progress" <%= "In Progress".equals(statusFilter) ? "selected" : "" %>>In Progress</option>
                    <option value="Pending Customer" <%= "Pending Customer".equals(statusFilter) ? "selected" : "" %>>Pending Customer</option>
                    <option value="Resolved" <%= "Resolved".equals(statusFilter) ? "selected" : "" %>>Resolved</option>
                    <option value="Closed" <%= "Closed".equals(statusFilter) ? "selected" : "" %>>Closed</option>
                </select>
                
                <select name="priority" class="filter-select">
                    <option value="">All Priority</option>
                    <option value="Urgent" <%= "Urgent".equals(priorityFilter) ? "selected" : "" %>>Urgent</option>
                    <option value="High" <%= "High".equals(priorityFilter) ? "selected" : "" %>>High</option>
                    <option value="Medium" <%= "Medium".equals(priorityFilter) ? "selected" : "" %>>Medium</option>
                    <option value="Low" <%= "Low".equals(priorityFilter) ? "selected" : "" %>>Low</option>
                </select>
                
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-filter"></i>
                    Filter
                </button>
                
                <a href="customer-service.jsp" class="btn btn-secondary">
                    <i class="fas fa-refresh"></i>
                    Reset
                </a>
            </form>

            <!-- Tickets Grid -->
            <div class="tickets-grid">
                <%
                    try {
                        Connection con = DBConnection.getConnection();
                        
                        // Build query with search and filter
                        StringBuilder queryBuilder = new StringBuilder("SELECT * FROM support_tickets WHERE 1=1");
                        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                            queryBuilder.append(" AND (subject LIKE ? OR description LIKE ? OR customer_name LIKE ? OR ticket_number LIKE ?)");
                        }
                        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                            queryBuilder.append(" AND status = ?");
                        }
                        if (priorityFilter != null && !priorityFilter.trim().isEmpty()) {
                            queryBuilder.append(" AND priority = ?");
                        }
                        queryBuilder.append(" ORDER BY CASE WHEN priority='Urgent' THEN 1 WHEN priority='High' THEN 2 WHEN priority='Medium' THEN 3 ELSE 4 END, created_date DESC");
                        
                        PreparedStatement ps = con.prepareStatement(queryBuilder.toString());
                        
                        int paramIndex = 1;
                        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                            String searchTerm = "%" + searchQuery + "%";
                            ps.setString(paramIndex++, searchTerm);
                            ps.setString(paramIndex++, searchTerm);
                            ps.setString(paramIndex++, searchTerm);
                            ps.setString(paramIndex++, searchTerm);
                        }
                        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                            ps.setString(paramIndex++, statusFilter);
                        }
                        if (priorityFilter != null && !priorityFilter.trim().isEmpty()) {
                            ps.setString(paramIndex++, priorityFilter);
                        }
                        
                        ResultSet rs = ps.executeQuery();
                        
                        boolean hasData = false;
                        while (rs.next()) {
                            hasData = true;
                            int id = rs.getInt("id");
                            String ticketNumber = rs.getString("ticket_number");
                            String customerName = rs.getString("customer_name");
                            String customerEmail = rs.getString("customer_email");
                            String customerPhone = rs.getString("customer_phone");
                            String subject = rs.getString("subject");
                            String description = rs.getString("description");
                            String category = rs.getString("category");
                            String priority = rs.getString("priority");
                            String status = rs.getString("status");
                            String assignedTo = rs.getString("assigned_to");
                            Timestamp createdDate = rs.getTimestamp("created_date");
                            Timestamp firstResponseDate = rs.getTimestamp("first_response_date");
                            boolean escalated = rs.getBoolean("escalated");
                            double resolutionTime = rs.getDouble("resolution_time_hours");
                            
                            String statusClass = status.toLowerCase().replace(" ", "-");
                            String priorityClass = priority.toLowerCase();
                %>
                <div class="ticket-card">
                    <% if (escalated) { %>
                        <div class="escalated-banner">
                            <i class="fas fa-exclamation-triangle"></i> ESCALATED
                        </div>
                    <% } %>
                    
                    <div class="ticket-header">
                        <div>
                            <div class="ticket-number">#<%= ticketNumber %></div>
                            <div class="ticket-subject"><%= subject %></div>
                        </div>
                    </div>
                    
                    <div class="ticket-meta">
                        <span class="ticket-badge priority-<%= priorityClass %>"><%= priority %> Priority</span>
                        <span class="ticket-badge status-<%= statusClass %>"><%= status %></span>
                        <span class="ticket-badge" style="background: linear-gradient(135deg, #F3E8FF, #E9D5FF); color: #7C2D12;"><%= category %></span>
                    </div>
                    
                    <div class="customer-info">
                        <div class="customer-name">
                            <i class="fas fa-user"></i> <%= customerName %>
                        </div>
                        <div class="customer-details">
                            <i class="fas fa-envelope"></i> <%= customerEmail %>
                            <% if (customerPhone != null && !customerPhone.trim().isEmpty()) { %>
                                | <i class="fas fa-phone"></i> <%= customerPhone %>
                            <% } %>
                        </div>
                    </div>
                    
                    <div class="ticket-description">
                        <%= description.length() > 200 ? description.substring(0, 200) + "..." : description %>
                    </div>
                    
                    <div class="ticket-footer">
                        <div class="ticket-stats">
                            <span><i class="fas fa-calendar"></i> <%= new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm").format(createdDate) %></span>
                            <% if (assignedTo != null) { %>
                                <span><i class="fas fa-user-tie"></i> Assigned to <%= assignedTo %></span>
                            <% } %>
                            <% if (firstResponseDate != null) { %>
                                <span><i class="fas fa-reply"></i> First response sent</span>
                            <% } %>
                        </div>
                        
                        <div class="ticket-actions">
                            <button onclick="viewTicket(<%= id %>)" class="btn btn-primary btn-sm">
                                <i class="fas fa-eye"></i>
                                View
                            </button>
                            <button onclick="respondToTicket(<%= id %>, '<%= ticketNumber %>', '<%= subject.replace("'", "\\'") %>')" class="btn btn-success btn-sm">
                                <i class="fas fa-reply"></i>
                                Respond
                            </button>
                            <% if (assignedTo == null || !assignedTo.equals(user)) { %>
                                <form method="POST" action="customer-service.jsp" style="display: inline;">
                                    <input type="hidden" name="action" value="assign">
                                    <input type="hidden" name="ticketId" value="<%= id %>">
                                    <button type="submit" class="btn btn-warning btn-sm">
                                        <i class="fas fa-hand-paper"></i>
                                        Assign to Me
                                    </button>
                                </form>
                            <% } %>
                            <button onclick="updateStatus(<%= id %>, '<%= status %>')" class="btn btn-secondary btn-sm">
                                <i class="fas fa-edit"></i>
                                Update Status
                            </button>
                            <% if (!escalated && !"Resolved".equals(status) && !"Closed".equals(status)) { %>
                                <button onclick="escalateTicket(<%= id %>)" class="btn btn-danger btn-sm">
                                    <i class="fas fa-arrow-up"></i>
                                    Escalate
                                </button>
                            <% } %>
                        </div>
                    </div>
                </div>
                <%
                        }
                        
                        if (!hasData) {
                %>
                <div class="no-data">
                    <i class="fas fa-ticket-alt"></i>
                    <h3>No Support Tickets Found</h3>
                    <p>No tickets match your current search criteria.</p>
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
                    <p>Please ensure the support_tickets table exists in your database.</p>
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

    <!-- Detailed Ticket View Modal -->
    <div id="detailModal" class="modal">
        <div class="modal-content" style="max-width: 900px;">
            <div class="modal-header">
                <h2 class="modal-title" id="detailModalTitle">
                    <i class="fas fa-ticket-alt"></i>
                    Ticket Details
                </h2>
                <button class="close" onclick="closeDetailModal()">&times;</button>
            </div>
            
            <div id="detailContent">
                <!-- Ticket details will be loaded here -->
            </div>
        </div>
    </div>

    <!-- Respond Modal -->
    <div id="respondModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">
                    <i class="fas fa-reply"></i>
                    Respond to Ticket
                </h2>
                <button class="close" onclick="closeRespondModal()">&times;</button>
            </div>
            
            <div id="responseHistory" class="response-history" style="display: none;">
                <h4 style="margin-bottom: 16px; color: var(--primary-blue);">
                    <i class="fas fa-history"></i> Response History
                </h4>
                <div id="responseList"></div>
            </div>
            
            <form method="POST" action="customer-service.jsp" id="respondForm">
                <input type="hidden" name="action" value="respond">
                <input type="hidden" id="respondTicketId" name="ticketId">
                
                <div class="form-group">
                    <label class="form-label">Response</label>
                    <textarea class="form-textarea" name="responseText" placeholder="Enter your response to the customer..." required></textarea>
                </div>
                
                <div class="form-group">
                    <label style="display: flex; align-items: center; gap: 8px; cursor: pointer;">
                        <input type="checkbox" name="isInternal" value="true" style="margin-right: 8px;">
                        Internal note (not visible to customer)
                    </label>
                </div>
                
                <div class="form-actions">
                    <button type="button" onclick="closeRespondModal()" class="btn btn-secondary">
                        <i class="fas fa-times"></i>
                        Cancel
                    </button>
                    <button type="submit" class="btn btn-success">
                        <i class="fas fa-paper-plane"></i>
                        Send Response
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Status Update Modal -->
    <div id="statusModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">
                    <i class="fas fa-edit"></i>
                    Update Ticket Status
                </h2>
                <button class="close" onclick="closeStatusModal()">&times;</button>
            </div>
            <form method="POST" action="customer-service.jsp" id="statusForm">
                <input type="hidden" name="action" value="updateStatus">
                <input type="hidden" id="statusTicketId" name="ticketId">
                
                <div class="form-group">
                    <label class="form-label">New Status</label>
                    <select class="form-select" id="newStatus" name="newStatus" required>
                        <option value="Open">Open</option>
                        <option value="In Progress">In Progress</option>
                        <option value="Pending Customer">Pending Customer</option>
                        <option value="Resolved">Resolved</option>
                        <option value="Closed">Closed</option>
                    </select>
                </div>
                
                <div class="form-actions">
                    <button type="button" onclick="closeStatusModal()" class="btn btn-secondary">
                        <i class="fas fa-times"></i>
                        Cancel
                    </button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i>
                        Update Status
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Escalation Modal -->
    <div id="escalationModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">
                    <i class="fas fa-arrow-up"></i>
                    Escalate to Service Team
                </h2>
                <button class="close" onclick="closeEscalationModal()">&times;</button>
            </div>
            <form method="POST" action="customer-service.jsp" id="escalationForm">
                <input type="hidden" name="action" value="escalate">
                <input type="hidden" id="escalationTicketId" name="ticketId">
                
                <div class="form-group">
                    <label class="form-label">Escalation Reason</label>
                    <textarea class="form-textarea" name="escalationReason" placeholder="Explain why this ticket needs to be escalated..." required></textarea>
                </div>
                
                <div class="form-actions">
                    <button type="button" onclick="closeEscalationModal()" class="btn btn-secondary">
                        <i class="fas fa-times"></i>
                        Cancel
                    </button>
                    <button type="submit" class="btn btn-danger">
                        <i class="fas fa-arrow-up"></i>
                        Escalate Ticket
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Modal functionality
        const respondModal = document.getElementById('respondModal');
        const statusModal = document.getElementById('statusModal');
        const escalationModal = document.getElementById('escalationModal');

        function respondToTicket(ticketId, ticketNumber, subject) {
            document.getElementById('respondTicketId').value = ticketId;
            document.querySelector('#respondModal .modal-title').innerHTML = 
                '<i class="fas fa-reply"></i> Respond to #' + ticketNumber + ' - ' + subject;
            
            // Load response history
            loadResponseHistory(ticketId);
            
            respondModal.style.display = 'block';
            document.body.style.overflow = 'hidden';
        }

        function closeRespondModal() {
            respondModal.style.display = 'none';
            document.body.style.overflow = 'auto';
            document.getElementById('respondForm').reset();
        }

        function updateStatus(ticketId, currentStatus) {
            document.getElementById('statusTicketId').value = ticketId;
            document.getElementById('newStatus').value = currentStatus;
            statusModal.style.display = 'block';
            document.body.style.overflow = 'hidden';
        }

        function closeStatusModal() {
            statusModal.style.display = 'none';
            document.body.style.overflow = 'auto';
        }

        function escalateTicket(ticketId) {
            document.getElementById('escalationTicketId').value = ticketId;
            escalationModal.style.display = 'block';
            document.body.style.overflow = 'hidden';
        }

        function closeEscalationModal() {
            escalationModal.style.display = 'none';
            document.body.style.overflow = 'auto';
            document.getElementById('escalationForm').reset();
        }

        function viewTicket(ticketId) {
            // Load detailed ticket view
            loadTicketDetails(ticketId);
        }

        function loadTicketDetails(ticketId) {
            // Show loading state
            document.getElementById('detailContent').innerHTML = `
                <div style="text-align: center; padding: 40px;">
                    <i class="fas fa-spinner fa-spin" style="font-size: 2rem; color: var(--accent-green);"></i>
                    <p style="margin-top: 16px; color: var(--text-secondary);">Loading ticket details...</p>
                </div>
            `;
            
            // Open modal
            document.getElementById('detailModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
            
            // Simulate loading ticket details (in real implementation, this would be an AJAX call)
            setTimeout(() => {
                // Mock data - in real implementation, fetch from server
                const ticketData = {
                    ticketNumber: 'TKT-2025-001',
                    subject: 'Unable to book train ticket',
                    customer: {
                        name: 'John Smith',
                        email: 'john.smith@email.com',
                        phone: '+1-555-0101'
                    },
                    description: 'I am getting an error message when trying to book a ticket from Delhi to Mumbai. The payment page is not loading properly.',
                    priority: 'High',
                    status: 'In Progress',
                    category: 'Booking Issues',
                    createdDate: 'Jul 20, 2025 14:23',
                    assignedTo: 'rep1',
                    responses: [
                        {
                            type: 'System',
                            author: 'System',
                            date: 'Jul 20, 2025 14:23',
                            text: 'Ticket created and assigned to rep1',
                            isInternal: true
                        },
                        {
                            type: 'Agent',
                            author: 'rep1',
                            date: 'Jul 20, 2025 14:30',
                            text: 'Thank you for contacting us. We are investigating the payment issue you reported. Our technical team is working on a fix.',
                            isInternal: false
                        },
                        {
                            type: 'Agent',
                            author: 'rep1',
                            date: 'Jul 20, 2025 15:45',
                            text: 'Internal note: Escalated to payment gateway team for investigation.',
                            isInternal: true
                        }
                    ]
                };
                
                displayTicketDetails(ticketData);
            }, 1000);
        }

        function displayTicketDetails(ticket) {
            const priorityClass = ticket.priority.toLowerCase();
            const statusClass = ticket.status.toLowerCase().replace(' ', '-');
            
            // Build responses HTML
            let responsesHTML = '';
            for (let i = 0; i < ticket.responses.length; i++) {
                const response = ticket.responses[i];
                const bgColor = response.isInternal ? '#FEF3C7' : '#F0F9FF';
                const borderColor = response.isInternal ? '#F59E0B' : '#3B82F6';
                const iconClass = response.type === 'System' ? 'cog' : (response.type === 'Agent' ? 'user-tie' : 'user');
                const internalBadge = response.isInternal ? '<span style="background: #F59E0B; color: white; padding: 2px 6px; border-radius: 4px; font-size: 0.7rem; margin-left: 8px;">INTERNAL</span>' : '';
                
                responsesHTML += 
                    '<div style="background: ' + bgColor + '; padding: 16px; border-radius: 12px; border-left: 4px solid ' + borderColor + ';">' +
                        '<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">' +
                            '<div style="font-weight: 600; color: var(--primary-blue);">' +
                                '<i class="fas fa-' + iconClass + '"></i> ' + response.author + internalBadge +
                            '</div>' +
                            '<div style="font-size: 0.875rem; color: var(--text-secondary);">' + response.date + '</div>' +
                        '</div>' +
                        '<div style="color: var(--text-primary); line-height: 1.5;">' + response.text + '</div>' +
                    '</div>';
            }
            
            const detailHTML = 
                '<div style="display: grid; gap: 24px;">' +
                    '<!-- Ticket Header -->' +
                    '<div style="background: var(--light-green); padding: 24px; border-radius: 16px;">' +
                        '<div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 16px;">' +
                            '<div>' +
                                '<h3 style="margin: 0; color: var(--primary-blue); font-size: 1.5rem;">#' + ticket.ticketNumber + '</h3>' +
                                '<h4 style="margin: 8px 0 0 0; color: var(--text-primary); font-size: 1.2rem;">' + ticket.subject + '</h4>' +
                            '</div>' +
                            '<div style="display: flex; gap: 8px;">' +
                                '<span class="ticket-badge priority-' + priorityClass + '">' + ticket.priority + ' Priority</span>' +
                                '<span class="ticket-badge status-' + statusClass + '">' + ticket.status + '</span>' +
                                '<span class="ticket-badge" style="background: linear-gradient(135deg, #F3E8FF, #E9D5FF); color: #7C2D12;">' + ticket.category + '</span>' +
                            '</div>' +
                        '</div>' +
                        
                        '<!-- Customer Info -->' +
                        '<div style="background: white; padding: 16px; border-radius: 12px; margin-bottom: 16px;">' +
                            '<h5 style="margin: 0 0 8px 0; color: var(--primary-blue);"><i class="fas fa-user"></i> Customer Information</h5>' +
                            '<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px;">' +
                                '<div><strong>Name:</strong> ' + ticket.customer.name + '</div>' +
                                '<div><strong>Email:</strong> ' + ticket.customer.email + '</div>' +
                                '<div><strong>Phone:</strong> ' + ticket.customer.phone + '</div>' +
                            '</div>' +
                        '</div>' +
                        
                        '<!-- Ticket Details -->' +
                        '<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 16px; font-size: 0.9rem; color: var(--text-secondary);">' +
                            '<div><i class="fas fa-calendar"></i> Created: ' + ticket.createdDate + '</div>' +
                            '<div><i class="fas fa-user-tie"></i> Assigned: ' + ticket.assignedTo + '</div>' +
                        '</div>' +
                    '</div>' +
                    
                    '<!-- Original Description -->' +
                    '<div style="background: white; padding: 24px; border-radius: 16px; border-left: 4px solid var(--accent-green);">' +
                        '<h5 style="margin: 0 0 12px 0; color: var(--primary-blue);"><i class="fas fa-comment-dots"></i> Original Message</h5>' +
                        '<p style="margin: 0; line-height: 1.6; color: var(--text-primary);">' + ticket.description + '</p>' +
                    '</div>' +
                    
                    '<!-- Conversation History -->' +
                    '<div style="background: white; padding: 24px; border-radius: 16px;">' +
                        '<h5 style="margin: 0 0 20px 0; color: var(--primary-blue);"><i class="fas fa-history"></i> Conversation History</h5>' +
                        '<div style="display: flex; flex-direction: column; gap: 16px;">' +
                            responsesHTML +
                        '</div>' +
                    '</div>' +
                    
                    '<!-- Quick Actions -->' +
                    '<div style="background: var(--background-light); padding: 20px; border-radius: 16px; text-align: center;">' +
                        '<h5 style="margin: 0 0 16px 0; color: var(--primary-blue);">Quick Actions</h5>' +
                        '<div style="display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;">' +
                            '<button onclick="respondToTicket(' + ticket.ticketNumber.split('-')[2] + ', \'' + ticket.ticketNumber + '\', \'' + ticket.subject + '\')" class="btn btn-success btn-sm">' +
                                '<i class="fas fa-reply"></i> Add Response' +
                            '</button>' +
                            '<button onclick="updateStatus(' + ticket.ticketNumber.split('-')[2] + ', \'' + ticket.status + '\')" class="btn btn-secondary btn-sm">' +
                                '<i class="fas fa-edit"></i> Update Status' +
                            '</button>' +
                            '<button onclick="escalateTicket(' + ticket.ticketNumber.split('-')[2] + ')" class="btn btn-danger btn-sm">' +
                                '<i class="fas fa-arrow-up"></i> Escalate' +
                            '</button>' +
                            '<button onclick="closeDetailModal()" class="btn btn-primary btn-sm">' +
                                '<i class="fas fa-times"></i> Close' +
                            '</button>' +
                        '</div>' +
                    '</div>' +
                '</div>';
            
            document.getElementById('detailContent').innerHTML = detailHTML;
            document.getElementById('detailModalTitle').innerHTML = 
                '<i class="fas fa-ticket-alt"></i> ' + ticket.ticketNumber + ' - ' + ticket.subject;
        }

        function closeDetailModal() {
            document.getElementById('detailModal').style.display = 'none';
            document.body.style.overflow = 'auto';
        }

        function loadResponseHistory(ticketId) {
            // This would typically be an AJAX call to fetch response history
            // For now, we'll show a placeholder
            const responseHistory = document.getElementById('responseHistory');
            const responseList = document.getElementById('responseList');
            
            responseList.innerHTML = `
                <div class="response-item">
                    <div class="response-header">
                        <div class="response-author">System</div>
                        <div class="response-date">Loading...</div>
                    </div>
                    <div class="response-text">Loading response history...</div>
                </div>
            `;
            
            responseHistory.style.display = 'block';
        }

        // Close modals when clicking outside
        window.onclick = function(event) {
            if (event.target == respondModal) {
                closeRespondModal();
            }
            if (event.target == statusModal) {
                closeStatusModal();
            }
            if (event.target == escalationModal) {
                closeEscalationModal();
            }
            if (event.target == detailModal) {
                closeDetailModal();
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

        // Auto-refresh for real-time updates (every 30 seconds)
        setInterval(function() {
            // Only refresh if no modals are open
            if (!respondModal.style.display || respondModal.style.display === 'none') {
                // window.location.reload();
            }
        }, 30000);
    </script>
</body>
</html>