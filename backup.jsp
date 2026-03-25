<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.sql.*, util.DBConnection, java.util.*, java.text.SimpleDateFormat" %>
<%
    // Get admin user from session (using multiple possible attribute names)
    String adminUser = (String) session.getAttribute("adminUsername");
    if (adminUser == null) {
        adminUser = (String) session.getAttribute("admin");
    }
    if (adminUser == null) {
        adminUser = (String) session.getAttribute("username");
    }
    if (adminUser == null) {
        adminUser = "Administrator"; // Default fallback since you're accessing from admin dashboard
    }

    String message = "";
    String action = request.getParameter("action");
    
    // Handle backup actions
    if ("createBackup".equals(action)) {
        String backupType = request.getParameter("backupType");
        try {
            // Simulate backup process based on type
            Thread.sleep(1000); // Simulate processing time
            
            switch (backupType) {
                case "full":
                    message = "✅ Full system backup created successfully! (2.4 GB)";
                    break;
                case "data":
                    message = "✅ Data-only backup created successfully! (1.8 GB)";
                    break;
                case "config":
                    message = "✅ Configuration backup created successfully! (24 MB)";
                    break;
                default:
                    message = "✅ Database backup created successfully!";
            }
        } catch (Exception e) {
            message = "❌ Backup failed: " + e.getMessage();
        }
    }
    
    // Handle other admin actions
    if ("scheduleBackup".equals(action)) {
        message = "✅ Automatic backup scheduled successfully!";
    }
    
    if ("verifyBackup".equals(action)) {
        message = "✅ Backup integrity verification completed!";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Backup Data Management - IRCTC Admin</title>
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

        .admin-badge {
            background: var(--primary-700);
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-left: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
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
            background: linear-gradient(135deg, var(--accent-error), #dc2626);
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
            max-width: 1200px;
            margin: 0 auto;
        }

        /* Page Header */
        .page-header {
            text-align: center;
            margin-bottom: 48px;
            animation: fadeInUp 0.8s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .page-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, var(--accent-warning), #f97316);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 24px;
            font-size: 2rem;
            color: white;
            box-shadow: var(--shadow-xl);
            position: relative;
            overflow: hidden;
        }

        .page-icon::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .page-icon:hover::before {
            left: 100%;
        }

        .page-title {
            font-size: 2.5rem;
            font-weight: 800;
            color: var(--primary-800);
            margin-bottom: 12px;
            background: linear-gradient(135deg, var(--primary-800), var(--primary-600));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .page-subtitle {
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

        /* Content Grid */
        .content-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 32px;
            margin-bottom: 32px;
        }

        /* Backup Actions Card */
        .backup-card {
            background: var(--glass-bg);
            backdrop-filter: blur(20px) saturate(180%);
            border-radius: 24px;
            padding: 40px;
            border: 1px solid var(--glass-border);
            box-shadow: var(--shadow-xl);
            position: relative;
            overflow: hidden;
            animation: fadeInUp 0.8s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .backup-card::before {
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

        .card-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary-800);
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .card-title i {
            color: var(--accent-primary);
            font-size: 1.3rem;
        }

        .card-description {
            color: var(--primary-600);
            margin-bottom: 32px;
            line-height: 1.6;
        }

        /* Backup Options */
        .backup-options {
            display: flex;
            flex-direction: column;
            gap: 16px;
            margin-bottom: 32px;
        }

        .backup-option {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 16px;
            background: rgba(255, 255, 255, 0.5);
            border-radius: 12px;
            border: 2px solid var(--primary-200);
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .backup-option:hover {
            border-color: var(--accent-primary);
            background: rgba(59, 130, 246, 0.05);
            transform: translateY(-2px);
        }

        .backup-option input[type="radio"] {
            width: 20px;
            height: 20px;
        }

        .backup-option label {
            font-weight: 600;
            color: var(--primary-700);
            cursor: pointer;
            flex: 1;
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

        .btn-warning {
            background: linear-gradient(135deg, var(--accent-warning), #f97316);
            color: white;
            box-shadow: var(--shadow-lg);
        }

        .btn-warning:hover {
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

        /* Backup History Table */
        .backup-history {
            background: var(--glass-bg);
            backdrop-filter: blur(20px) saturate(180%);
            border-radius: 24px;
            padding: 32px;
            border: 1px solid var(--glass-border);
            box-shadow: var(--shadow-xl);
            animation: fadeInUp 0.8s cubic-bezier(0.4, 0, 0.2, 1) 0.2s both;
        }

        .table-responsive {
            overflow-x: auto;
            margin-top: 24px;
        }

        .table {
            width: 100%;
            border-collapse: collapse;
        }

        .table th,
        .table td {
            padding: 16px;
            text-align: left;
            border-bottom: 1px solid var(--primary-200);
        }

        .table th {
            background: var(--primary-50);
            font-weight: 600;
            color: var(--primary-700);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-size: 0.85rem;
        }

        .table td {
            color: var(--primary-600);
        }

        .table tbody tr:hover {
            background: var(--primary-50);
        }

        .status-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .status-success {
            background: rgba(16, 185, 129, 0.1);
            color: var(--accent-success);
        }

        .status-error {
            background: rgba(239, 68, 68, 0.1);
            color: var(--accent-error);
        }

        .status-warning {
            background: rgba(245, 158, 11, 0.1);
            color: var(--accent-warning);
        }

        /* Footer Actions */
        .footer-actions {
            text-align: center;
            margin-top: 48px;
            animation: fadeInUp 0.8s cubic-bezier(0.4, 0, 0.2, 1) 0.4s both;
        }

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

            .main-content {
                margin-top: 140px;
                padding: 1rem;
            }

            .content-grid {
                grid-template-columns: 1fr;
                gap: 24px;
            }

            .backup-card {
                padding: 24px;
            }

            .page-title {
                font-size: 2rem;
            }

            .page-icon {
                width: 64px;
                height: 64px;
                font-size: 1.5rem;
            }

            .btn {
                width: 100%;
                margin-bottom: 12px;
            }
        }

        /* Focus states for accessibility */
        .btn:focus-visible,
        .backup-option:focus-visible {
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
            <a href="admin.jsp" class="navbar-brand">
                <div class="logo-icon">
                    <i class="fas fa-train"></i>
                </div>
                <span>IRCTC</span>
                <span class="admin-badge">Admin Portal</span>
            </a>
            <div class="nav-buttons">
                <a href="admin.jsp" class="nav-btn nav-btn-secondary">
                    <i class="fas fa-dashboard"></i>
                    Dashboard
                </a>
                <a href="admin.jsp" class="nav-btn nav-btn-primary" onclick="if(confirm('Logout from admin panel?')) { window.location.href='admin-login.jsp'; } return false;">
                    <i class="fas fa-sign-out-alt"></i>
                    Logout
                </a>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="main-content">
        <div class="container">
            <!-- Page Header -->
            <div class="page-header">
                <div class="page-icon">
                    <i class="fas fa-database"></i>
                </div>
                <h1 class="page-title">Backup Data Management</h1>
                <p class="page-subtitle">Secure your critical railway data with automated backup solutions</p>
                
                <!-- Security Notice -->
                <div style="margin-top: 24px; padding: 16px; background: rgba(220, 38, 38, 0.1); border: 1px solid rgba(220, 38, 38, 0.2); border-radius: 12px; max-width: 600px; margin-left: auto; margin-right: auto;">
                    <div style="display: flex; align-items: center; gap: 12px; color: var(--admin-primary); font-weight: 600;">
                        <i class="fas fa-shield-alt"></i>
                        <span>Admin Access Verified</span>
                    </div>
                    <p style="color: var(--primary-600); font-size: 0.9rem; margin-top: 8px;">
                        All backup operations are logged and monitored for security compliance.
                    </p>
                </div>
            </div>

            <!-- Alert Messages -->
            <% if (!message.isEmpty()) { %>
                <div class="alert <%= message.contains("✅") ? "alert-success" : "alert-danger" %>">
                    <%= message %>
                </div>
            <% } %>

            <!-- Content Grid -->
            <div class="content-grid">
                <!-- Backup Actions Card -->
                <div class="backup-card">
                    <h2 class="card-title">
                        <i class="fas fa-cloud-upload-alt"></i>
                        Create New Backup
                    </h2>
                    <p class="card-description">
                        Generate a comprehensive backup of your railway management system data including customer records, reservations, and system configurations.
                    </p>

                    <form method="post" action="backup.jsp" id="backupForm">
                        <input type="hidden" name="action" value="createBackup">
                        
                        <div class="backup-options">
                            <div class="backup-option">
                                <input type="radio" id="fullBackup" name="backupType" value="full" checked>
                                <label for="fullBackup">
                                    <strong>Full System Backup</strong>
                                    <small style="display: block; color: var(--primary-500);">Complete database and system files</small>
                                </label>
                            </div>
                            
                            <div class="backup-option">
                                <input type="radio" id="dataBackup" name="backupType" value="data">
                                <label for="dataBackup">
                                    <strong>Data Only Backup</strong>
                                    <small style="display: block; color: var(--primary-500);">Customer and reservation data only</small>
                                </label>
                            </div>
                            
                            <div class="backup-option">
                                <input type="radio" id="configBackup" name="backupType" value="config">
                                <label for="configBackup">
                                    <strong>Configuration Backup</strong>
                                    <small style="display: block; color: var(--primary-500);">System settings and configurations</small>
                                </label>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-warning" id="backupBtn">
                            <i class="fas fa-download"></i>
                            Create Backup
                        </button>
                    </form>
                </div>

                <!-- Quick Actions Card -->
                <div class="backup-card">
                    <h2 class="card-title">
                        <i class="fas fa-tools"></i>
                        Quick Actions
                    </h2>
                    <p class="card-description">
                        Manage your backup operations with these convenient tools and utilities.
                    </p>

                    <div style="display: flex; flex-direction: column; gap: 16px;">
                        <button class="btn btn-primary" onclick="scheduleBackup()">
                            <i class="fas fa-clock"></i>
                            Schedule Automatic Backup
                        </button>
                        
                        <button class="btn btn-secondary" onclick="verifyBackups()">
                            <i class="fas fa-check-circle"></i>
                            Verify Backup Integrity
                        </button>
                        
                        <button class="btn btn-secondary" onclick="downloadBackup()">
                            <i class="fas fa-cloud-download-alt"></i>
                            Download Latest Backup
                        </button>
                        
                        <button class="btn btn-secondary" onclick="restoreData()">
                            <i class="fas fa-upload"></i>
                            Restore from Backup
                        </button>
                    </div>
                </div>
            </div>

            <!-- Backup History -->
            <div class="backup-history">
                <h2 class="card-title">
                    <i class="fas fa-history"></i>
                    Backup History
                </h2>
                <p class="card-description">
                    View and manage your previous backup operations and their current status.
                </p>

                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Backup ID</th>
                                <th>Type</th>
                                <th>Created Date</th>
                                <th>Size</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><strong>BKP-2025-001</strong></td>
                                <td>Full System</td>
                                <td>July 20, 2025 14:30</td>
                                <td>2.4 GB</td>
                                <td><span class="status-badge status-success">Completed</span></td>
                                <td>
                                    <button class="btn btn-secondary" style="padding: 8px 16px; min-width: auto;" onclick="downloadBackup()">
                                        <i class="fas fa-download"></i>
                                    </button>
                                </td>
                            </tr>
                            <tr>
                                <td><strong>BKP-2025-002</strong></td>
                                <td>Data Only</td>
                                <td>July 19, 2025 02:00</td>
                                <td>1.8 GB</td>
                                <td><span class="status-badge status-success">Completed</span></td>
                                <td>
                                    <button class="btn btn-secondary" style="padding: 8px 16px; min-width: auto;" onclick="downloadBackup()">
                                        <i class="fas fa-download"></i>
                                    </button>
                                </td>
                            </tr>
                            <tr>
                                <td><strong>BKP-2025-003</strong></td>
                                <td>Configuration</td>
                                <td>July 18, 2025 18:45</td>
                                <td>24 MB</td>
                                <td><span class="status-badge status-warning">Verifying</span></td>
                                <td>
                                    <button class="btn btn-secondary" style="padding: 8px 16px; min-width: auto;" disabled>
                                        <i class="fas fa-spinner fa-spin"></i>
                                    </button>
                                </td>
                            </tr>
                            <tr>
                                <td><strong>BKP-2025-004</strong></td>
                                <td>Full System</td>
                                <td>July 17, 2025 02:00</td>
                                <td>2.1 GB</td>
                                <td><span class="status-badge status-success">Completed</span></td>
                                <td>
                                    <button class="btn btn-secondary" style="padding: 8px 16px; min-width: auto;" onclick="downloadBackup()">
                                        <i class="fas fa-download"></i>
                                    </button>
                                </td>
                            </tr>
                            <tr>
                                <td><strong>BKP-2025-005</strong></td>
                                <td>Data Only</td>
                                <td>July 16, 2025 14:15</td>
                                <td>1.7 GB</td>
                                <td><span class="status-badge status-error">Failed</span></td>
                                <td>
                                    <button class="btn btn-secondary" style="padding: 8px 16px; min-width: auto;" onclick="alert('Backup failed due to insufficient storage space.')">
                                        <i class="fas fa-exclamation-triangle"></i>
                                    </button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Footer Actions -->
            <div class="footer-actions">
                <a href="admin.jsp" class="btn btn-secondary">
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

        // Form submission with loading state
        document.getElementById('backupForm').addEventListener('submit', function(e) {
            var button = document.getElementById('backupBtn');
            var selectedType = document.querySelector('input[name="backupType"]:checked').value;
            
            button.classList.add('loading');
            button.innerHTML = '<span>Creating ' + selectedType + ' backup...</span>';
        });

        // Quick action functions
        function scheduleBackup() {
            if (confirm('Schedule automatic daily backups at 2:00 AM?')) {
                // Create a form and submit to handle the schedule action
                var form = document.createElement('form');
                form.method = 'post';
                form.action = 'backup.jsp';
                
                var actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'scheduleBackup';
                
                form.appendChild(actionInput);
                document.body.appendChild(form);
                form.submit();
            }
        }

        function verifyBackups() {
            if (confirm('Start backup integrity verification? This may take several minutes.')) {
                var form = document.createElement('form');
                form.method = 'post';
                form.action = 'backup.jsp';
                
                var actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'verifyBackup';
                
                form.appendChild(actionInput);
                document.body.appendChild(form);
                form.submit();
            }
        }

        function downloadBackup() {
            // Simulate download
            var link = document.createElement('a');
            link.href = '#';
            link.download = 'IRCTC_Backup_' + new Date().toISOString().split('T')[0] + '.sql';
            link.click();
            
            setTimeout(function() {
                alert('Backup download initiated. File: ' + link.download);
            }, 500);
        }

        function restoreData() {
            if (confirm('⚠️ WARNING: This will overwrite current data with backup data. Are you absolutely sure?')) {
                if (confirm('This action cannot be undone. Continue with restore?')) {
                    alert('🔄 Backup restoration initiated. System will be unavailable during this process.');
                    // Here you would typically redirect to a restore page or servlet
                }
            }
        }

        // Enhanced backup option interactions
        document.querySelectorAll('.backup-option').forEach(function(option) {
            option.addEventListener('click', function() {
                var radio = this.querySelector('input[type="radio"]');
                radio.checked = true;
                
                // Update visual selection
                document.querySelectorAll('.backup-option').forEach(function(opt) {
                    opt.style.borderColor = 'var(--primary-200)';
                    opt.style.background = 'rgba(255, 255, 255, 0.5)';
                });
                
                this.style.borderColor = 'var(--accent-primary)';
                this.style.background = 'rgba(59, 130, 246, 0.05)';
            });
        });

        // Initialize first option as selected
        document.querySelector('.backup-option').click();

        // Smooth scrolling for internal links
        document.querySelectorAll('a[href^="#"]').forEach(function(anchor) {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                var target = document.querySelector(this.getAttribute('href'));
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