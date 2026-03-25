<%@ page import="java.sql.*, util.DBConnection" %>
<%@ page session="true" %>
<%
    String currentUser = (String) session.getAttribute("username");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String message = "";
    String action = request.getParameter("action");

    if ("updateUsername".equals(action)) {
        String newUsername = request.getParameter("newUsername");

        if (newUsername != null && !newUsername.trim().isEmpty()) {
            Connection con = null;
            try {
                con = DBConnection.getConnection();
                con.setAutoCommit(false); // Start transaction
                
                // Check if new username already exists
                PreparedStatement check = con.prepareStatement("SELECT Username FROM customer_data WHERE Username=?");
                check.setString(1, newUsername);
                ResultSet rs = check.executeQuery();

                if (rs.next()) {
                    message = "❌ Username already exists. Please choose another.";
                    rs.close();
                    check.close();
                } else {
                    rs.close();
                    check.close();
                    
                    // Temporarily disable foreign key checks
                    PreparedStatement disableFK = con.prepareStatement("SET FOREIGN_KEY_CHECKS = 0");
                    disableFK.executeUpdate();
                    disableFK.close();
                    
                    // Update customer_data first
                    PreparedStatement updateCustomer = con.prepareStatement(
                        "UPDATE customer_data SET Username=? WHERE Username=?"
                    );
                    updateCustomer.setString(1, newUsername);
                    updateCustomer.setString(2, currentUser);
                    int customerResult = updateCustomer.executeUpdate();
                    updateCustomer.close();
                    
                    // Update reservation_data if customer update was successful
                    int reservationResult = 0;
                    if (customerResult > 0) {
                        PreparedStatement updateReservations = con.prepareStatement(
                            "UPDATE reservation_data SET Username=? WHERE Username=?"
                        );
                        updateReservations.setString(1, newUsername);
                        updateReservations.setString(2, currentUser);
                        reservationResult = updateReservations.executeUpdate();
                        updateReservations.close();
                    }
                    
                    // Re-enable foreign key checks
                    PreparedStatement enableFK = con.prepareStatement("SET FOREIGN_KEY_CHECKS = 1");
                    enableFK.executeUpdate();
                    enableFK.close();

                    if (customerResult > 0) {
                        con.commit(); // Commit transaction
                        session.setAttribute("username", newUsername);
                        message = "✅ Username updated successfully!";
                        if (reservationResult > 0) {
                            message += " (" + reservationResult + " reservations updated)";
                        }
                        currentUser = newUsername;
                    } else {
                        con.rollback(); // Rollback on failure
                        message = "❌ Failed to update username.";
                    }
                }
                
            } catch (Exception e) {
                try {
                    if (con != null) {
                        // Make sure to re-enable foreign key checks even on error
                        PreparedStatement enableFK = con.prepareStatement("SET FOREIGN_KEY_CHECKS = 1");
                        enableFK.executeUpdate();
                        enableFK.close();
                        con.rollback(); // Rollback on error
                    }
                } catch (Exception rollbackEx) {
                    // Log rollback error if needed
                }
                message = "❌ Error: " + e.getMessage();
            } finally {
                try {
                    if (con != null) {
                        con.setAutoCommit(true); // Reset auto-commit
                        con.close();
                    }
                } catch (Exception closeEx) {
                    // Log close error if needed
                }
            }
        }
    }

    if ("updatePassword".equals(action)) {
        String pass1 = request.getParameter("newPassword");
        String pass2 = request.getParameter("confirmPassword");

        if (pass1 != null && pass1.equals(pass2)) {
            try {
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement("UPDATE customer_data SET Password=? WHERE Username=?");
                ps.setString(1, pass1);
                ps.setString(2, currentUser);
                int updated = ps.executeUpdate();

                if (updated > 0) {
                    message = "✅ Password updated successfully!";
                } else {
                    message = "❌ Failed to update password.";
                }
                ps.close();
                con.close();
            } catch (Exception e) {
                message = "❌ Error: " + e.getMessage();
            }
        } else {
            message = "❌ Passwords do not match.";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile Management - IRCTC</title>
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
            
            --accent-primary: #3b82f6;
            --accent-secondary: #6366f1;
            --accent-success: #10b981;
            --accent-warning: #f59e0b;
            --accent-error: #ef4444;
            
            --glass-bg: rgba(255, 255, 255, 0.9);
            --glass-border: rgba(255, 255, 255, 0.2);
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            --shadow-2xl: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, var(--primary-50) 0%, var(--primary-100) 50%, var(--primary-200) 100%);
            min-height: 100vh;
            line-height: 1.6;
            color: var(--primary-800);
            overflow-x: hidden;
        }

        /* Sophisticated background pattern */
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: 
                radial-gradient(circle at 20% 80%, rgba(59, 130, 246, 0.03) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(99, 102, 241, 0.03) 0%, transparent 50%),
                radial-gradient(circle at 40% 40%, rgba(16, 185, 129, 0.02) 0%, transparent 50%);
            z-index: -1;
            animation: subtleFloat 30s ease-in-out infinite;
        }

        @keyframes subtleFloat {
            0%, 100% { transform: translateY(0px) scale(1); }
            50% { transform: translateY(-10px) scale(1.02); }
        }

        /* Advanced Navbar */
        .navbar {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            background: var(--glass-bg);
            backdrop-filter: blur(20px) saturate(180%);
            border-bottom: 1px solid var(--glass-border);
            padding: 1rem 0;
            z-index: 1000;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .navbar.scrolled {
            background: rgba(255, 255, 255, 0.98);
            box-shadow: var(--shadow-lg);
        }

        .navbar-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .navbar-brand {
            display: flex;
            align-items: center;
            text-decoration: none;
            color: var(--primary-800);
            font-weight: 800;
            font-size: 1.5rem;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
        }

        .navbar-brand::after {
            content: '';
            position: absolute;
            bottom: -4px;
            left: 0;
            width: 0;
            height: 2px;
            background: linear-gradient(90deg, var(--accent-primary), var(--accent-secondary));
            transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .navbar-brand:hover {
            color: var(--accent-primary);
            transform: translateY(-1px);
        }

        .navbar-brand:hover::after {
            width: 100%;
        }

        .logo-icon {
            width: 48px;
            height: 48px;
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 16px;
            box-shadow: var(--shadow-md);
            transition: all 0.3s ease;
        }

        .logo-icon i {
            font-size: 1.5rem;
            color: white;
        }

        .navbar-brand:hover .logo-icon {
            transform: scale(1.05) rotate(2deg);
            box-shadow: var(--shadow-lg);
        }

        .navbar-brand span {
            font-weight: 800;
            font-size: 1.5rem;
            color: var(--primary-800);
        }

        .nav-buttons {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .nav-btn {
            padding: 12px 24px;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .nav-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .nav-btn:hover::before {
            left: 100%;
        }

        .nav-btn-secondary {
            background: white;
            color: var(--primary-600);
            border: 2px solid var(--primary-200);
            box-shadow: var(--shadow-sm);
        }

        .nav-btn-secondary:hover {
            background: var(--primary-600);
            color: white;
            border-color: var(--primary-600);
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
        }

        .nav-btn-primary {
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            color: white;
            border: 2px solid transparent;
            box-shadow: var(--shadow-md);
        }

        .nav-btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-xl);
            color: white;
        }

        /* Main Content */
        .main-content {
            margin-top: 100px;
            padding: 2rem;
            min-height: calc(100vh - 100px);
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
        }

        /* Profile Header */
        .profile-header {
            text-align: center;
            margin-bottom: 48px;
            animation: fadeInUp 0.8s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .profile-avatar {
            width: 120px;
            height: 120px;
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 24px;
            font-size: 3rem;
            color: white;
            box-shadow: var(--shadow-xl);
            position: relative;
            overflow: hidden;
        }

        .profile-avatar::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .profile-avatar:hover::before {
            left: 100%;
        }

        .profile-title {
            font-size: 2.5rem;
            font-weight: 800;
            color: var(--primary-800);
            margin-bottom: 8px;
            background: linear-gradient(135deg, var(--primary-800), var(--primary-600));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .profile-subtitle {
            font-size: 1.2rem;
            color: var(--primary-600);
            font-weight: 500;
        }

        /* Alert Messages */
        .alert {
            padding: 20px 24px;
            border-radius: 16px;
            margin-bottom: 32px;
            font-weight: 500;
            font-size: 1rem;
            display: flex;
            align-items: center;
            gap: 12px;
            border: 1px solid transparent;
            animation: slideIn 0.5s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

        .alert::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 4px;
            background: currentColor;
        }

        .alert-success {
            background: rgba(16, 185, 129, 0.1);
            color: var(--accent-success);
            border-color: rgba(16, 185, 129, 0.2);
        }

        .alert-danger {
            background: rgba(239, 68, 68, 0.1);
            color: var(--accent-error);
            border-color: rgba(239, 68, 68, 0.2);
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Form Sections */
        .form-section {
            background: var(--glass-bg);
            backdrop-filter: blur(20px) saturate(180%);
            border-radius: 24px;
            padding: 40px;
            margin-bottom: 32px;
            border: 1px solid var(--glass-border);
            box-shadow: var(--shadow-xl);
            position: relative;
            overflow: hidden;
            animation: fadeInUp 0.8s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .form-section:nth-child(2) { animation-delay: 0.1s; }
        .form-section:nth-child(3) { animation-delay: 0.2s; }

        .form-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 1px;
            background: linear-gradient(90deg, 
                transparent, 
                var(--accent-primary), 
                var(--accent-secondary), 
                transparent
            );
            animation: shimmer 3s ease-in-out infinite;
        }

        @keyframes shimmer {
            0%, 100% { opacity: 0.5; transform: translateX(-100%); }
            50% { opacity: 1; transform: translateX(100%); }
        }

        .form-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary-800);
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .form-title i {
            color: var(--accent-primary);
            font-size: 1.3rem;
        }

        .form-group {
            margin-bottom: 24px;
            position: relative;
        }

        .form-label {
            font-weight: 600;
            color: var(--primary-700);
            margin-bottom: 8px;
            display: block;
            font-size: 0.95rem;
            transition: color 0.3s ease;
        }

        .form-control {
            width: 100%;
            padding: 16px 20px;
            border: 2px solid var(--primary-200);
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 500;
            color: var(--primary-800);
            background: rgba(255, 255, 255, 0.8);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            backdrop-filter: blur(10px);
        }

        .form-control:focus {
            outline: none;
            border-color: var(--accent-primary);
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
            background: rgba(255, 255, 255, 1);
            transform: translateY(-1px);
        }

        .form-control:hover {
            border-color: var(--primary-300);
            transform: translateY(-1px);
            box-shadow: var(--shadow-md);
        }

        .form-control.valid {
            border-color: var(--accent-success);
            background: rgba(16, 185, 129, 0.02);
        }

        .form-control.invalid {
            border-color: var(--accent-error);
            background: rgba(239, 68, 68, 0.02);
        }

        /* Enhanced Checkbox */
        .form-check {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 24px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .form-check:hover {
            transform: translateX(4px);
        }

        .form-check-input {
            width: 20px;
            height: 20px;
            border: 2px solid var(--primary-300);
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            appearance: none;
            background: white;
        }

        .form-check-input:checked {
            background: var(--accent-primary);
            border-color: var(--accent-primary);
            transform: scale(1.1);
        }

        .form-check-input:checked::after {
            content: '✓';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: white;
            font-size: 12px;
            font-weight: bold;
        }

        .form-check-label {
            color: var(--primary-600);
            font-weight: 500;
            cursor: pointer;
            user-select: none;
            transition: color 0.3s ease;
        }

        .form-check:hover .form-check-label {
            color: var(--primary-800);
        }

        /* Premium Buttons */
        .btn {
            padding: 16px 32px;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            text-decoration: none;
            min-width: 160px;
        }

        .btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .btn:hover::before {
            left: 100%;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            color: white;
            box-shadow: var(--shadow-lg);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-xl);
        }

        .btn-secondary {
            background: white;
            color: var(--primary-600);
            border: 2px solid var(--primary-200);
            box-shadow: var(--shadow-sm);
        }

        .btn-secondary:hover {
            background: var(--primary-600);
            color: white;
            border-color: var(--primary-600);
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
        }

        .btn:active {
            transform: translateY(0);
        }

        /* Footer Actions */
        .footer-actions {
            text-align: center;
            margin-top: 48px;
            animation: fadeInUp 0.8s cubic-bezier(0.4, 0, 0.2, 1) 0.4s both;
        }

        /* Password Strength Indicator */
        .password-strength {
            margin-top: 8px;
            height: 4px;
            background: var(--primary-200);
            border-radius: 2px;
            overflow: hidden;
            transition: all 0.3s ease;
        }

        .password-strength-bar {
            height: 100%;
            width: 0%;
            border-radius: 2px;
            transition: all 0.3s ease;
        }

        .strength-weak { background: var(--accent-error); width: 25%; }
        .strength-fair { background: var(--accent-warning); width: 50%; }
        .strength-good { background: var(--accent-primary); width: 75%; }
        .strength-strong { background: var(--accent-success); width: 100%; }

        /* Loading States */
        .btn.loading {
            pointer-events: none;
            opacity: 0.8;
        }

        .btn.loading::after {
            content: '';
            position: absolute;
            width: 20px;
            height: 20px;
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top-color: white;
            animation: spin 1s ease-in-out infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
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

        /* Responsive Design */
        @media (max-width: 768px) {
            .navbar-content {
                padding: 0 1rem;
                flex-direction: column;
                gap: 16px;
            }

            .navbar-brand span {
                font-size: 1.25rem;
            }

            .logo-icon {
                width: 40px;
                height: 40px;
                margin-right: 12px;
            }

            .logo-icon i {
                font-size: 1.25rem;
            }

            .main-content {
                margin-top: 140px;
                padding: 1rem;
            }

            .form-section {
                padding: 24px;
            }

            .profile-title {
                font-size: 2rem;
            }

            .profile-avatar {
                width: 100px;
                height: 100px;
                font-size: 2.5rem;
            }

            .btn {
                width: 100%;
                margin-bottom: 12px;
            }
        }

        @media (max-width: 480px) {
            .navbar-brand {
                flex-direction: column;
                gap: 4px;
            }

            .logo-icon {
                margin-right: 0;
                margin-bottom: 4px;
            }

            .profile-title {
                font-size: 1.8rem;
            }

            .nav-btn {
                padding: 10px 16px;
                font-size: 0.9rem;
            }
        }

        /* Focus states for accessibility */
        .btn:focus-visible,
        .form-control:focus-visible,
        .form-check-input:focus-visible {
            outline: 2px solid var(--accent-primary);
            outline-offset: 2px;
        }

        /* Scroll indicator */
        .scroll-indicator {
            position: fixed;
            top: 0;
            left: 0;
            width: 0%;
            height: 3px;
            background: linear-gradient(90deg, var(--accent-primary), var(--accent-secondary));
            z-index: 1001;
            transition: width 0.3s ease;
        }
    </style>
</head>
<body>
    <!-- Scroll Indicator -->
    <div class="scroll-indicator"></div>

    <!-- Navigation -->
    <nav class="navbar" id="navbar">
        <div class="navbar-content">
            <a href="welcome.jsp" class="navbar-brand">
                <div class="logo-icon">
                    <i class="fas fa-train"></i>
                </div>
                <span>IRCTC</span>
            </a>
            <div class="nav-buttons">
                <a href="search.jsp" class="nav-btn nav-btn-secondary">
                    <i class="fas fa-search"></i>
                    Search Trains
                </a>
                <a href="logout" class="nav-btn nav-btn-primary">
                    <i class="fas fa-sign-out-alt"></i>
                    Logout
                </a>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="main-content">
        <div class="container">
            <!-- Profile Header -->
            <div class="profile-header">
                <div class="profile-avatar">
                    <i class="fas fa-user"></i>
                </div>
                <h1 class="profile-title">Profile Management</h1>
                <p class="profile-subtitle">Welcome back, <strong><%= currentUser %></strong></p>
            </div>

            <!-- Alert Messages -->
            <% if (!message.isEmpty()) { %>
                <div class="alert <%= message.contains("✅") ? "alert-success" : "alert-danger" %>">
                    <%= message %>
                </div>
            <% } %>

            <!-- Update Username Section -->
            <div class="form-section">
                <h2 class="form-title">
                    <i class="fas fa-user-edit"></i>
                    Change Username
                </h2>
                <form method="post" action="profile.jsp" id="usernameForm">
                    <input type="hidden" name="action" value="updateUsername" />
                    <div class="form-group">
                        <label for="newUsername" class="form-label">New Username</label>
                        <input type="text" name="newUsername" id="newUsername" class="form-control" 
                               placeholder="Enter your new username" required minlength="3" maxlength="20">
                    </div>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i>
                        Update Username
                    </button>
                </form>
            </div>

            <!-- Update Password Section -->
            <div class="form-section">
                <h2 class="form-title">
                    <i class="fas fa-lock"></i>
                    Change Password
                </h2>
                <form method="post" action="profile.jsp" id="passwordForm">
                    <input type="hidden" name="action" value="updatePassword" />
                    <div class="form-group">
                        <label for="newPassword" class="form-label">New Password</label>
                        <input type="password" name="newPassword" id="newPassword" class="form-control" 
                               placeholder="Enter your new password" required minlength="6">
                        <div class="password-strength">
                            <div class="password-strength-bar" id="strengthBar"></div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="confirmPassword" class="form-label">Confirm New Password</label>
                        <input type="password" name="confirmPassword" id="confirmPassword" class="form-control" 
                               placeholder="Confirm your new password" required>
                    </div>
                    <div class="form-check">
                        <input type="checkbox" id="showPassword" class="form-check-input">
                        <label for="showPassword" class="form-check-label">Show passwords</label>
                    </div>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-shield-alt"></i>
                        Update Password
                    </button>
                </form>
            </div>

            <!-- Footer Actions -->
            <div class="footer-actions">
                <a href="welcome.jsp" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i>
                    Back to Dashboard
                </a>
            </div>
        </div>
    </div>

    <!-- Enhanced JavaScript -->
    <script>
        // Navbar scroll effect
        window.addEventListener('scroll', function() {
            var navbar = document.getElementById('navbar');
            var scrollIndicator = document.querySelector('.scroll-indicator');
            
            if (window.scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
            
            // Update scroll indicator
            var scrolled = (window.scrollY / (document.documentElement.scrollHeight - window.innerHeight)) * 100;
            scrollIndicator.style.width = scrolled + '%';
        });

        // Password visibility toggle
        document.getElementById('showPassword').addEventListener('change', function() {
            var newPassword = document.getElementById('newPassword');
            var confirmPassword = document.getElementById('confirmPassword');
            
            if (this.checked) {
                newPassword.type = 'text';
                confirmPassword.type = 'text';
            } else {
                newPassword.type = 'password';
                confirmPassword.type = 'password';
            }
        });

        // Password strength indicator
        document.getElementById('newPassword').addEventListener('input', function() {
            var password = this.value;
            var strengthBar = document.getElementById('strengthBar');
            
            // Remove existing classes
            strengthBar.className = 'password-strength-bar';
            
            if (password.length === 0) {
                return;
            }
            
            var strength = 0;
            if (password.length >= 6) strength++;
            if (password.match(/[a-z]/) && password.match(/[A-Z]/)) strength++;
            if (password.match(/\d/)) strength++;
            if (password.match(/[^a-zA-Z\d]/)) strength++;
            
            switch (strength) {
                case 1:
                    strengthBar.classList.add('strength-weak');
                    break;
                case 2:
                    strengthBar.classList.add('strength-fair');
                    break;
                case 3:
                    strengthBar.classList.add('strength-good');
                    break;
                case 4:
                    strengthBar.classList.add('strength-strong');
                    break;
            }
        });

        // Enhanced form validation
        function validatePasswords() {
            var newPassword = document.getElementById('newPassword').value;
            var confirmPassword = document.getElementById('confirmPassword').value;
            
            if (newPassword !== confirmPassword) {
                showNotification('Passwords do not match', 'error');
                return false;
            }
            
            if (newPassword.length < 6) {
                showNotification('Password should be at least 6 characters', 'error');
                return false;
            }
            
            return true;
        }

        // Form submissions with loading states
        document.getElementById('usernameForm').addEventListener('submit', function(e) {
            const button = this.querySelector('.btn');
            const username = document.getElementById('newUsername').value;
            
            if (username.length < 3) {
                e.preventDefault();
                showNotification('Username should be at least 3 characters', 'error');
                return;
            }
            
            button.classList.add('loading');
            button.innerHTML = '<span>Updating...</span>';
        });

        document.getElementById('passwordForm').addEventListener('submit', function(e) {
            if (!validatePasswords()) {
                e.preventDefault();
                return;
            }
            
            const button = this.querySelector('.btn');
            button.classList.add('loading');
            button.innerHTML = '<span>Updating...</span>';
        });

        // Enhanced form interactions
        document.querySelectorAll('.form-control').forEach(function(input) {
            input.addEventListener('focus', function() {
                this.parentElement.style.transform = 'scale(1.02)';
                this.parentElement.style.transition = 'transform 0.3s cubic-bezier(0.4, 0, 0.2, 1)';
            });
            
            input.addEventListener('blur', function() {
                this.parentElement.style.transform = 'scale(1)';
                
                // Validation feedback
                if (this.value.trim() !== '') {
                    this.classList.add('valid');
                    this.classList.remove('invalid');
                } else if (this.required) {
                    this.classList.add('invalid');
                    this.classList.remove('valid');
                }
            });

            input.addEventListener('input', function() {
                this.classList.remove('invalid');
                if (this.value.trim() !== '') {
                    this.classList.add('valid');
                } else {
                    this.classList.remove('valid');
                }
            });
        });

        // Password match validation
        document.getElementById('confirmPassword').addEventListener('input', function() {
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = this.value;
            
            if (confirmPassword && newPassword !== confirmPassword) {
                this.classList.add('invalid');
                this.classList.remove('valid');
            } else if (confirmPassword) {
                this.classList.add('valid');
                this.classList.remove('invalid');
            }
        });

        // Notification system
        function showNotification(message, type) {
            const notification = document.createElement('div');
            const alertClass = 'alert alert-' + (type === 'error' ? 'danger' : 'success');
            notification.className = alertClass;
            notification.innerHTML = message;
            notification.style.position = 'fixed';
            notification.style.top = '120px';
            notification.style.right = '20px';
            notification.style.zIndex = '10000';
            notification.style.minWidth = '300px';
            
            document.body.appendChild(notification);
            
            setTimeout(function() {
                notification.style.opacity = '0';
                notification.style.transform = 'translateX(100%)';
                setTimeout(function() {
                    document.body.removeChild(notification);
                }, 300);
            }, 4000);
        }

        // Smooth scrolling for internal links
        document.querySelectorAll('a[href^="#"]').forEach(function(anchor) {
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
    </script>
</body>
</html>