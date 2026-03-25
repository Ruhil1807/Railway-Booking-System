<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.sql.*, util.DBConnection, java.util.*, java.text.SimpleDateFormat" %>
<%
    // Get admin user from session (flexible approach)
    String adminUser = (String) session.getAttribute("adminUsername");
    if (adminUser == null) {
        adminUser = (String) session.getAttribute("admin");
    }
    if (adminUser == null) {
        adminUser = (String) session.getAttribute("username");
    }
    if (adminUser == null) {
        adminUser = "Administrator"; // Default fallback
    }

    String message = "";
    String action = request.getParameter("action");
    
    // Handle settings updates
    if ("updateSettings".equals(action)) {
        String settingType = request.getParameter("settingType");
        try {
            switch (settingType) {
                case "theme":
                    String theme = request.getParameter("theme");
                    message = "✅ Theme updated to " + theme + " mode successfully!";
                    break;
                case "notifications":
                    String notifications = request.getParameter("notifications");
                    message = "✅ Notification preferences updated successfully!";
                    break;
                case "security":
                    String security = request.getParameter("security");
                    message = "✅ Security settings updated successfully!";
                    break;
                case "display":
                    String display = request.getParameter("display");
                    message = "✅ Display preferences updated successfully!";
                    break;
                case "system":
                    String system = request.getParameter("system");
                    message = "✅ System settings updated successfully!";
                    break;
                default:
                    message = "✅ Settings updated successfully!";
            }
        } catch (Exception e) {
            message = "❌ Settings update failed: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Settings - IRCTC</title>
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
            
            --admin-primary: #dc2626;
            --admin-secondary: #b91c1c;
            
            --glass-bg: rgba(255, 255, 255, 0.9);
            --glass-border: rgba(255, 255, 255, 0.2);
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            --shadow-2xl: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
        }

        [data-theme="dark"] {
            --primary-50: #0f172a;
            --primary-100: #1e293b;
            --primary-200: #334155;
            --primary-300: #475569;
            --primary-400: #64748b;
            --primary-500: #94a3b8;
            --primary-600: #cbd5e1;
            --primary-700: #e2e8f0;
            --primary-800: #f1f5f9;
            --primary-900: #f8fafc;
            --glass-bg: rgba(30, 41, 59, 0.9);
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
            transition: all 0.3s ease;
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

        [data-theme="dark"] .navbar.scrolled {
            background: rgba(30, 41, 59, 0.98);
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
            background: linear-gradient(135deg, var(--accent-secondary), var(--accent-primary));
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

        /* Settings Grid */
        .settings-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(380px, 1fr));
            gap: 32px;
            margin-bottom: 32px;
        }

        /* Setting Cards */
        .setting-card {
            background: var(--glass-bg);
            backdrop-filter: blur(20px) saturate(180%);
            border-radius: 24px;
            padding: 32px;
            border: 1px solid var(--glass-border);
            box-shadow: var(--shadow-xl);
            position: relative;
            overflow: hidden;
            animation: fadeInUp 0.8s cubic-bezier(0.4, 0, 0.2, 1);
            transition: all 0.3s ease;
        }

        .setting-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-2xl);
        }

        .setting-card::before {
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

        .setting-header {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 24px;
        }

        .setting-icon {
            width: 56px;
            height: 56px;
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: white;
            box-shadow: var(--shadow-md);
        }

        .setting-info h3 {
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--primary-800);
            margin-bottom: 4px;
        }

        .setting-info p {
            color: var(--primary-600);
            font-size: 0.9rem;
        }

        /* Settings Options */
        .setting-options {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .setting-option {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px;
            background: rgba(255, 255, 255, 0.5);
            border-radius: 12px;
            border: 2px solid var(--primary-200);
            transition: all 0.3s ease;
        }

        .setting-option:hover {
            border-color: var(--accent-primary);
            background: rgba(59, 130, 246, 0.05);
            transform: translateY(-1px);
        }

        .option-info {
            flex: 1;
        }

        .option-title {
            font-weight: 600;
            color: var(--primary-700);
            margin-bottom: 4px;
        }

        .option-description {
            font-size: 0.85rem;
            color: var(--primary-500);
        }

        /* Toggle Switch */
        .toggle-switch {
            position: relative;
            width: 60px;
            height: 30px;
            background: var(--primary-300);
            border-radius: 15px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .toggle-switch.active {
            background: var(--accent-success);
        }

        .toggle-switch::before {
            content: '';
            position: absolute;
            top: 3px;
            left: 3px;
            width: 24px;
            height: 24px;
            background: white;
            border-radius: 50%;
            transition: all 0.3s ease;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        .toggle-switch.active::before {
            transform: translateX(30px);
        }

        /* Select Dropdown */
        .custom-select {
            padding: 12px 16px;
            border: 2px solid var(--primary-200);
            border-radius: 8px;
            background: white;
            color: var(--primary-700);
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            appearance: none;
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%2364748b' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m6 8 4 4 4-4'/%3e%3c/svg%3e");
            background-position: right 12px center;
            background-repeat: no-repeat;
            background-size: 16px;
            padding-right: 40px;
        }

        .custom-select:focus {
            outline: none;
            border-color: var(--accent-primary);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }

        /* Premium Buttons */
        .btn {
            padding: 14px 28px;
            border: none;
            border-radius: 12px;
            font-size: 0.95rem;
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

        /* Footer Actions */
        .footer-actions {
            text-align: center;
            margin-top: 48px;
            animation: fadeInUp 0.8s cubic-bezier(0.4, 0, 0.2, 1) 0.4s both;
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

            .settings-grid {
                grid-template-columns: 1fr;
                gap: 24px;
            }

            .setting-card {
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
        }

        /* Focus states for accessibility */
        .btn:focus-visible,
        .toggle-switch:focus-visible,
        .custom-select:focus-visible {
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

        /* Dark mode specific adjustments */
        [data-theme="dark"] .setting-card {
            background: rgba(30, 41, 59, 0.9);
        }

        [data-theme="dark"] .setting-option {
            background: rgba(51, 65, 85, 0.5);
            border-color: var(--primary-300);
        }

        [data-theme="dark"] .custom-select {
            background: var(--primary-700);
            border-color: var(--primary-300);
            color: var(--primary-100);
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
                    <i class="fas fa-cogs"></i>
                </div>
                <h1 class="page-title">Admin Settings</h1>
                <p class="page-subtitle">Customize your admin portal experience and system preferences</p>
            </div>

            <!-- Alert Messages -->
            <% if (!message.isEmpty()) { %>
                <div class="alert <%= message.contains("✅") ? "alert-success" : "alert-danger" %>">
                    <%= message %>
                </div>
            <% } %>

            <!-- Settings Grid -->
            <div class="settings-grid">
                <!-- Theme & Appearance Settings -->
                <div class="setting-card">
                    <div class="setting-header">
                        <div class="setting-icon">
                            <i class="fas fa-palette"></i>
                        </div>
                        <div class="setting-info">
                            <h3>Theme & Appearance</h3>
                            <p>Customize the visual appearance of your admin portal</p>
                        </div>
                    </div>
                    
                    <div class="setting-options">
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Dark Mode</div>
                                <div class="option-description">Switch between light and dark themes</div>
                            </div>
                            <div class="toggle-switch" id="darkModeToggle" onclick="toggleDarkMode()"></div>
                        </div>
                        
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Color Scheme</div>
                                <div class="option-description">Choose your preferred color palette</div>
                            </div>
                            <select class="custom-select" onchange="updateColorScheme(this.value)">
                                <option value="blue">Ocean Blue</option>
                                <option value="purple">Royal Purple</option>
                                <option value="green">Forest Green</option>
                                <option value="red">Admin Red</option>
                            </select>
                        </div>
                        
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Compact Mode</div>
                                <div class="option-description">Reduce spacing for more content</div>
                            </div>
                            <div class="toggle-switch" id="compactModeToggle" onclick="toggleCompactMode()"></div>
                        </div>
                    </div>
                </div>

                <!-- Notification Settings -->
                <div class="setting-card">
                    <div class="setting-header">
                        <div class="setting-icon">
                            <i class="fas fa-bell"></i>
                        </div>
                        <div class="setting-info">
                            <h3>Notifications</h3>
                            <p>Manage your notification preferences and alerts</p>
                        </div>
                    </div>
                    
                    <div class="setting-options">
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Email Notifications</div>
                                <div class="option-description">Receive important updates via email</div>
                            </div>
                            <div class="toggle-switch active" id="emailNotificationsToggle" onclick="toggleEmailNotifications()"></div>
                        </div>
                        
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">System Alerts</div>
                                <div class="option-description">Get notified about system issues</div>
                            </div>
                            <div class="toggle-switch active" id="systemAlertsToggle" onclick="toggleSystemAlerts()"></div>
                        </div>
                        
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Backup Reminders</div>
                                <div class="option-description">Receive backup completion notifications</div>
                            </div>
                            <div class="toggle-switch active" id="backupRemindersToggle" onclick="toggleBackupReminders()"></div>
                        </div>
                    </div>
                </div>

                <!-- Security Settings -->
                <div class="setting-card">
                    <div class="setting-header">
                        <div class="setting-icon">
                            <i class="fas fa-shield-alt"></i>
                        </div>
                        <div class="setting-info">
                            <h3>Security</h3>
                            <p>Configure security and access control settings</p>
                        </div>
                    </div>
                    
                    <div class="setting-options">
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Two-Factor Authentication</div>
                                <div class="option-description">Add extra security to your account</div>
                            </div>
                            <div class="toggle-switch" id="twoFactorToggle" onclick="toggleTwoFactor()"></div>
                        </div>
                        
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Session Timeout</div>
                                <div class="option-description">Automatic logout after inactivity</div>
                            </div>
                            <select class="custom-select" onchange="updateSessionTimeout(this.value)">
                                <option value="15">15 minutes</option>
                                <option value="30" selected>30 minutes</option>
                                <option value="60">1 hour</option>
                                <option value="120">2 hours</option>
                            </select>
                        </div>
                        
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Login Monitoring</div>
                                <div class="option-description">Track login attempts and locations</div>
                            </div>
                            <div class="toggle-switch active" id="loginMonitoringToggle" onclick="toggleLoginMonitoring()"></div>
                        </div>
                    </div>
                </div>

                <!-- Display Settings -->
                <div class="setting-card">
                    <div class="setting-header">
                        <div class="setting-icon">
                            <i class="fas fa-desktop"></i>
                        </div>
                        <div class="setting-info">
                            <h3>Display Preferences</h3>
                            <p>Customize how data and content is displayed</p>
                        </div>
                    </div>
                    
                    <div class="setting-options">
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Items Per Page</div>
                                <div class="option-description">Number of records to show in tables</div>
                            </div>
                            <select class="custom-select" onchange="updateItemsPerPage(this.value)">
                                <option value="10">10 items</option>
                                <option value="25" selected>25 items</option>
                                <option value="50">50 items</option>
                                <option value="100">100 items</option>
                            </select>
                        </div>
                        
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Auto-refresh Data</div>
                                <div class="option-description">Automatically update dashboard data</div>
                            </div>
                            <div class="toggle-switch active" id="autoRefreshToggle" onclick="toggleAutoRefresh()"></div>
                        </div>
                        
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Advanced Charts</div>
                                <div class="option-description">Enable interactive data visualizations</div>
                            </div>
                            <div class="toggle-switch active" id="advancedChartsToggle" onclick="toggleAdvancedCharts()"></div>
                        </div>
                    </div>
                </div>

                <!-- System Settings -->
                <div class="setting-card">
                    <div class="setting-header">
                        <div class="setting-icon">
                            <i class="fas fa-server"></i>
                        </div>
                        <div class="setting-info">
                            <h3>System Configuration</h3>
                            <p>Manage system-wide settings and preferences</p>
                        </div>
                    </div>
                    
                    <div class="setting-options">
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Maintenance Mode</div>
                                <div class="option-description">Enable maintenance mode for system updates</div>
                            </div>
                            <div class="toggle-switch" id="maintenanceModeToggle" onclick="toggleMaintenanceMode()"></div>
                        </div>
                        
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Debug Mode</div>
                                <div class="option-description">Show detailed error information</div>
                            </div>
                            <div class="toggle-switch" id="debugModeToggle" onclick="toggleDebugMode()"></div>
                        </div>
                        
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Cache Duration</div>
                                <div class="option-description">How long to cache system data</div>
                            </div>
                            <select class="custom-select" onchange="updateCacheDuration(this.value)">
                                <option value="5">5 minutes</option>
                                <option value="15" selected>15 minutes</option>
                                <option value="30">30 minutes</option>
                                <option value="60">1 hour</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- Data Management -->
                <div class="setting-card">
                    <div class="setting-header">
                        <div class="setting-icon">
                            <i class="fas fa-database"></i>
                        </div>
                        <div class="setting-info">
                            <h3>Data Management</h3>
                            <p>Configure data retention and backup settings</p>
                        </div>
                    </div>
                    
                    <div class="setting-options">
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Auto Backup</div>
                                <div class="option-description">Automatically backup data daily</div>
                            </div>
                            <div class="toggle-switch active" id="autoBackupToggle" onclick="toggleAutoBackup()"></div>
                        </div>
                        
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Data Retention</div>
                                <div class="option-description">Keep log data for specified period</div>
                            </div>
                            <select class="custom-select" onchange="updateDataRetention(this.value)">
                                <option value="30">30 days</option>
                                <option value="90" selected>90 days</option>
                                <option value="180">6 months</option>
                                <option value="365">1 year</option>
                            </select>
                        </div>
                        
                        <div class="setting-option">
                            <div class="option-info">
                                <div class="option-title">Export Format</div>
                                <div class="option-description">Default format for data exports</div>
                            </div>
                            <select class="custom-select" onchange="updateExportFormat(this.value)">
                                <option value="csv" selected>CSV</option>
                                <option value="excel">Excel</option>
                                <option value="pdf">PDF</option>
                                <option value="json">JSON</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer Actions -->
            <div class="footer-actions">
                <button class="btn btn-primary" onclick="saveAllSettings()">
                    <i class="fas fa-save"></i>
                    Save All Settings
                </button>
                <button class="btn btn-secondary" onclick="resetToDefaults()">
                    <i class="fas fa-undo"></i>
                    Reset to Defaults
                </button>
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

        // Dark Mode Toggle
        function toggleDarkMode() {
            var toggle = document.getElementById('darkModeToggle');
            var body = document.body;
            
            toggle.classList.toggle('active');
            
            if (toggle.classList.contains('active')) {
                body.setAttribute('data-theme', 'dark');
                localStorage.setItem('theme', 'dark');
                showNotification('Dark mode enabled', 'success');
            } else {
                body.removeAttribute('data-theme');
                localStorage.setItem('theme', 'light');
                showNotification('Light mode enabled', 'success');
            }
        }

        // Initialize theme from localStorage
        function initializeTheme() {
            var savedTheme = localStorage.getItem('theme');
            if (savedTheme === 'dark') {
                document.body.setAttribute('data-theme', 'dark');
                document.getElementById('darkModeToggle').classList.add('active');
            }
        }

        // Toggle Functions
        function toggleCompactMode() {
            var toggle = document.getElementById('compactModeToggle');
            toggle.classList.toggle('active');
            showNotification('Compact mode ' + (toggle.classList.contains('active') ? 'enabled' : 'disabled'), 'success');
        }

        function toggleEmailNotifications() {
            var toggle = document.getElementById('emailNotificationsToggle');
            toggle.classList.toggle('active');
            showNotification('Email notifications ' + (toggle.classList.contains('active') ? 'enabled' : 'disabled'), 'success');
        }

        function toggleSystemAlerts() {
            var toggle = document.getElementById('systemAlertsToggle');
            toggle.classList.toggle('active');
            showNotification('System alerts ' + (toggle.classList.contains('active') ? 'enabled' : 'disabled'), 'success');
        }

        function toggleBackupReminders() {
            var toggle = document.getElementById('backupRemindersToggle');
            toggle.classList.toggle('active');
            showNotification('Backup reminders ' + (toggle.classList.contains('active') ? 'enabled' : 'disabled'), 'success');
        }

        function toggleTwoFactor() {
            var toggle = document.getElementById('twoFactorToggle');
            if (!toggle.classList.contains('active')) {
                if (confirm('Enable Two-Factor Authentication? You will need to set up an authenticator app.')) {
                    toggle.classList.add('active');
                    showNotification('Two-Factor Authentication enabled', 'success');
                }
            } else {
                if (confirm('Disable Two-Factor Authentication? This will reduce account security.')) {
                    toggle.classList.remove('active');
                    showNotification('Two-Factor Authentication disabled', 'warning');
                }
            }
        }

        function toggleLoginMonitoring() {
            var toggle = document.getElementById('loginMonitoringToggle');
            toggle.classList.toggle('active');
            showNotification('Login monitoring ' + (toggle.classList.contains('active') ? 'enabled' : 'disabled'), 'success');
        }

        function toggleAutoRefresh() {
            var toggle = document.getElementById('autoRefreshToggle');
            toggle.classList.toggle('active');
            showNotification('Auto-refresh ' + (toggle.classList.contains('active') ? 'enabled' : 'disabled'), 'success');
        }

        function toggleAdvancedCharts() {
            var toggle = document.getElementById('advancedChartsToggle');
            toggle.classList.toggle('active');
            showNotification('Advanced charts ' + (toggle.classList.contains('active') ? 'enabled' : 'disabled'), 'success');
        }

        function toggleMaintenanceMode() {
            var toggle = document.getElementById('maintenanceModeToggle');
            if (!toggle.classList.contains('active')) {
                if (confirm('⚠️ Enable Maintenance Mode? This will make the system unavailable to users.')) {
                    toggle.classList.add('active');
                    showNotification('Maintenance mode enabled', 'warning');
                }
            } else {
                toggle.classList.remove('active');
                showNotification('Maintenance mode disabled', 'success');
            }
        }

        function toggleDebugMode() {
            var toggle = document.getElementById('debugModeToggle');
            toggle.classList.toggle('active');
            showNotification('Debug mode ' + (toggle.classList.contains('active') ? 'enabled' : 'disabled'), 'success');
        }

        function toggleAutoBackup() {
            var toggle = document.getElementById('autoBackupToggle');
            toggle.classList.toggle('active');
            showNotification('Auto backup ' + (toggle.classList.contains('active') ? 'enabled' : 'disabled'), 'success');
        }

        // Update Functions
        function updateColorScheme(value) {
            showNotification('Color scheme updated to ' + value, 'success');
        }

        function updateSessionTimeout(value) {
            showNotification('Session timeout set to ' + value + ' minutes', 'success');
        }

        function updateItemsPerPage(value) {
            showNotification('Items per page set to ' + value, 'success');
        }

        function updateCacheDuration(value) {
            showNotification('Cache duration set to ' + value + ' minutes', 'success');
        }

        function updateDataRetention(value) {
            showNotification('Data retention set to ' + value + ' days', 'success');
        }

        function updateExportFormat(value) {
            showNotification('Export format set to ' + value.toUpperCase(), 'success');
        }

        // Save All Settings
        function saveAllSettings() {
            var formData = new FormData();
            formData.append('action', 'updateSettings');
            formData.append('settingType', 'all');
            
            // Simulate saving
            setTimeout(function() {
                showNotification('All settings saved successfully!', 'success');
            }, 1000);
        }

        // Reset to Defaults
        function resetToDefaults() {
            if (confirm('Reset all settings to default values? This cannot be undone.')) {
                // Reset all toggles and selects to default state
                location.reload();
            }
        }

        // Notification System
        function showNotification(message, type) {
            var notification = document.createElement('div');
            notification.className = 'alert alert-' + (type === 'warning' ? 'danger' : 'success');
            notification.innerHTML = '<i class="fas fa-' + (type === 'success' ? 'check' : 'exclamation') + '-circle"></i> ' + message;
            notification.style.position = 'fixed';
            notification.style.top = '120px';
            notification.style.right = '20px';
            notification.style.zIndex = '10000';
            notification.style.minWidth = '300px';
            notification.style.maxWidth = '400px';
            
            document.body.appendChild(notification);
            
            setTimeout(function() {
                notification.style.opacity = '0';
                notification.style.transform = 'translateX(100%)';
                setTimeout(function() {
                    if (notification.parentNode) {
                        document.body.removeChild(notification);
                    }
                }, 300);
            }, 4000);
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            initializeTheme();
        });
    </script>
</body>
</html>