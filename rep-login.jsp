<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String loginError = (String) request.getAttribute("loginError");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Customer Rep Portal - IRCTC</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
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
            background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 50%, #f0f9ff 100%);
            min-height: 100vh;
            line-height: 1.6;
            color: #334155;
            position: relative;
            overflow-x: hidden;
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
                radial-gradient(circle at 25% 25%, rgba(14, 165, 233, 0.03) 0%, transparent 50%),
                radial-gradient(circle at 75% 75%, rgba(59, 130, 246, 0.02) 0%, transparent 50%),
                radial-gradient(circle at 50% 50%, rgba(147, 197, 253, 0.02) 0%, transparent 50%);
            z-index: -1;
            animation: backgroundShift 20s ease-in-out infinite;
        }

        @keyframes backgroundShift {
            0%, 100% { transform: translateX(0) translateY(0); }
            33% { transform: translateX(-8px) translateY(-12px); }
            66% { transform: translateX(8px) translateY(8px); }
        }

        /* Navigation */
        .navbar {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(226, 232, 240, 0.8);
            padding: 1rem 0;
            z-index: 1000;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
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
            color: #1e293b;
            font-weight: 800;
            font-size: 1.5rem;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .navbar-brand:hover {
            color: #0ea5e9;
            transform: translateY(-1px);
        }

        .navbar-brand i {
            font-size: 2rem;
            margin-right: 12px;
            background: linear-gradient(135deg, #0ea5e9, #3b82f6);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .role-dropdown {
            position: relative;
        }

        .dropdown-btn {
            background: white;
            color: #0ea5e9;
            border: 2px solid #bae6fd;
            padding: 12px 20px;
            border-radius: 12px;
            font-weight: 600;
            font-size: 0.95rem;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            align-items: center;
            gap: 8px;
            position: relative;
            overflow: hidden;
        }

        .dropdown-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            transition: left 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .dropdown-btn:hover::before {
            left: 100%;
        }

        .dropdown-btn:hover {
            background: #0ea5e9;
            color: white;
            border-color: #0ea5e9;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(14, 165, 233, 0.15);
        }

        .dropdown-menu {
            position: absolute;
            top: 100%;
            right: 0;
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(226, 232, 240, 0.8);
            min-width: 200px;
            opacity: 0;
            visibility: hidden;
            transform: translateY(-10px);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            z-index: 1001;
            margin-top: 8px;
        }

        .dropdown-menu.show {
            opacity: 1;
            visibility: visible;
            transform: translateY(0);
        }

        .dropdown-item {
            display: block;
            padding: 12px 20px;
            color: #64748b;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            border-radius: 8px;
            margin: 4px;
        }

        .dropdown-item:hover {
            background: #f0f9ff;
            color: #0ea5e9;
            transform: translateX(4px);
        }

        .dropdown-item.active {
            background: linear-gradient(135deg, #0ea5e9, #3b82f6);
            color: white;
        }

        /* Main Content */
        .main-content {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 120px 2rem 2rem;
        }

        .login-container {
            width: 100%;
            max-width: 460px;
            animation: fadeInUp 0.8s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .login-card {
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            padding: 48px 40px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.3);
            position: relative;
            overflow: hidden;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .login-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(14, 165, 233, 0.015), rgba(59, 130, 246, 0.015));
            pointer-events: none;
        }

        .login-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 35px 70px -12px rgba(0, 0, 0, 0.2);
        }

        .rep-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: linear-gradient(135deg, #f0f9ff, #e0f2fe);
            color: #0369a1;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 24px;
            border: 1px solid rgba(186, 230, 253, 0.6);
        }

        .login-header {
            text-align: center;
            margin-bottom: 40px;
            position: relative;
            z-index: 1;
        }

        .login-title {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 12px;
            background: linear-gradient(135deg, #1e293b, #0ea5e9);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .login-subtitle {
            color: #64748b;
            font-size: 1.1rem;
            font-weight: 500;
        }

        /* Alert Styles */
        .alert {
            padding: 16px 20px;
            border-radius: 12px;
            margin-bottom: 24px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideInDown 0.5s ease;
        }

        .alert-danger {
            background: linear-gradient(135deg, #fef2f2, #fee2e2);
            color: #dc2626;
            border: 1px solid #fecaca;
        }

        @keyframes slideInDown {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Form Styles */
        .form-group {
            margin-bottom: 24px;
            position: relative;
        }

        .form-label {
            font-weight: 600;
            color: #374151;
            margin-bottom: 8px;
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .form-control {
            width: 100%;
            padding: 16px;
            border: 2px solid #bae6fd;
            border-radius: 12px;
            font-size: 1rem;
            background: white;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
        }

        .form-control:focus {
            outline: none;
            border-color: #0ea5e9;
            box-shadow: 0 0 0 4px rgba(14, 165, 233, 0.08);
            transform: translateY(-1px);
        }

        .form-control:hover {
            border-color: #0284c7;
            transform: translateY(-1px);
        }

        .input-group {
            position: relative;
            display: flex;
        }

        .input-group .form-control {
            border-radius: 12px 0 0 12px;
            border-right: none;
        }

        .password-toggle {
            background: white;
            border: 2px solid #bae6fd;
            border-left: none;
            border-radius: 0 12px 12px 0;
            padding: 16px;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #0ea5e9;
            font-size: 1.1rem;
        }

        .password-toggle:hover {
            background: #f0f9ff;
            color: #0284c7;
        }

        .input-group:focus-within .password-toggle {
            border-color: #0ea5e9;
        }

        /* Submit Button */
        .submit-btn {
            width: 100%;
            background: linear-gradient(135deg, #0ea5e9, #3b82f6);
            color: white;
            border: none;
            padding: 18px;
            border-radius: 16px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            box-shadow: 0 8px 25px rgba(14, 165, 233, 0.2);
            margin-bottom: 24px;
        }

        .submit-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .submit-btn:hover::before {
            left: 100%;
        }

        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 35px rgba(14, 165, 233, 0.3);
        }

        .submit-btn:active {
            transform: translateY(0);
        }

        .submit-btn.loading {
            pointer-events: none;
            background: #93c5fd;
        }

        .submit-btn.loading::after {
            content: '';
            position: absolute;
            width: 20px;
            height: 20px;
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top-color: white;
            animation: spin 1s ease-in-out infinite;
            right: 20px;
            top: 50%;
            transform: translateY(-50%);
        }

        @keyframes spin {
            to { transform: translateY(-50%) rotate(360deg); }
        }

        /* Security Notice */
        .security-notice {
            background: linear-gradient(135deg, #f0f9ff, #e0f2fe);
            border: 1px solid #bae6fd;
            border-radius: 12px;
            padding: 16px;
            margin-top: 24px;
            display: flex;
            align-items: flex-start;
            gap: 12px;
            font-size: 0.9rem;
            color: #0369a1;
        }

        .security-notice i {
            color: #0ea5e9;
            margin-top: 2px;
        }

        /* Animations */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(40px);
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
                padding: 140px 1rem 2rem;
            }

            .login-card {
                padding: 32px 24px;
            }

            .login-title {
                font-size: 2rem;
            }

            .dropdown-menu {
                position: fixed;
                top: 140px;
                right: 1rem;
                left: 1rem;
                width: auto;
            }
        }

        @media (max-width: 480px) {
            .login-title {
                font-size: 1.75rem;
            }

            .form-control, .password-toggle {
                padding: 14px;
            }

            .submit-btn {
                padding: 16px;
                font-size: 1rem;
            }
        }

        /* Floating Elements */
        .floating-elements {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: -1;
        }

        .floating-element {
            position: absolute;
            background: rgba(14, 165, 233, 0.06);
            border-radius: 50%;
            animation: float 25s infinite ease-in-out;
        }

        .floating-element:nth-child(1) {
            width: 60px;
            height: 60px;
            top: 15%;
            left: 10%;
            animation-delay: 0s;
        }

        .floating-element:nth-child(2) {
            width: 40px;
            height: 40px;
            top: 70%;
            right: 15%;
            animation-delay: -8s;
        }

        .floating-element:nth-child(3) {
            width: 80px;
            height: 80px;
            bottom: 25%;
            left: 20%;
            animation-delay: -16s;
        }

        @keyframes float {
            0%, 100% {
                transform: translateY(0) rotate(0deg);
                opacity: 0.3;
            }
            50% {
                transform: translateY(-15px) rotate(180deg);
                opacity: 0.6;
            }
        }
    </style>
</head>
<body>
    <!-- Floating Background Elements -->
    <div class="floating-elements">
        <div class="floating-element"></div>
        <div class="floating-element"></div>
        <div class="floating-element"></div>
    </div>

    <!-- Navigation -->
    <nav class="navbar">
        <div class="navbar-content">
            <a href="index.html" class="navbar-brand">
                <i class="fas fa-train"></i>
                IRCTC
            </a>
            <div class="role-dropdown">
                <button class="dropdown-btn" onclick="toggleDropdown()">
                    <i class="fas fa-headset"></i>
                    <span>Login As</span>
                    <i class="fas fa-chevron-down" style="transition: transform 0.3s ease;"></i>
                </button>
                <div class="dropdown-menu" id="roleDropdown">
                    <a href="login.jsp" class="dropdown-item">
                        <i class="fas fa-user"></i> Customer
                    </a>
                    <a href="admin-login.jsp" class="dropdown-item">
                        <i class="fas fa-user-shield"></i> Admin
                    </a>
                    <a href="#" class="dropdown-item active">
                        <i class="fas fa-headset"></i> Customer Rep
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="main-content">
        <div class="login-container">
            <div class="login-card">
                <div class="login-header">
                    <div class="rep-badge">
                        <i class="fas fa-headset"></i>
                        <span>CUSTOMER REPRESENTATIVE</span>
                    </div>
                    <h1 class="login-title">Rep Portal</h1>
                    <p class="login-subtitle">Customer support and train management system</p>
                </div>

                <!-- Error Message -->
                <% if (loginError != null) { %>
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-triangle"></i>
                        <%= loginError %>
                    </div>
                <% } %>

                <!-- Login Form -->
                <form action="login" method="post" id="repLoginForm">
                    <!-- Hidden Fields -->
                    <input type="hidden" name="expectedRole" value="rep">

                    <!-- Username Field -->
                    <div class="form-group">
                        <label for="username" class="form-label">
                            <i class="fas fa-user-tie"></i>
                            Representative Username
                        </label>
                        <input 
                            type="text" 
                            class="form-control" 
                            id="username" 
                            name="username" 
                            placeholder="Enter your username" 
                            required
                            autocomplete="username"
                        >
                    </div>

                    <!-- Password Field -->
                    <div class="form-group">
                        <label for="password" class="form-label">
                            <i class="fas fa-lock"></i>
                            Password
                        </label>
                        <div class="input-group">
                            <input 
                                type="password" 
                                class="form-control" 
                                id="password" 
                                name="password" 
                                placeholder="Enter your password" 
                                required
                                autocomplete="current-password"
                            >
                            <button type="button" class="password-toggle" onclick="togglePassword()">
                                <i class="fas fa-eye" id="passwordIcon"></i>
                            </button>
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <button type="submit" class="submit-btn" id="submitBtn">
                        <i class="fas fa-sign-in-alt"></i>
                        Access Rep Portal
                    </button>
                </form>

                <!-- Security Notice -->
                <div class="security-notice">
                    <i class="fas fa-info-circle"></i>
                    <div>
                        <strong>Representative Portal:</strong> Access customer support tools, manage train schedules, and handle customer inquiries. All activities are logged for quality assurance.
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Enhanced JavaScript -->
    <script>
        // Dropdown functionality
        function toggleDropdown() {
            const dropdown = document.getElementById('roleDropdown');
            const icon = document.querySelector('.dropdown-btn i:last-child');
            
            dropdown.classList.toggle('show');
            icon.style.transform = dropdown.classList.contains('show') 
                ? 'rotate(180deg)' 
                : 'rotate(0deg)';
        }

        // Close dropdown when clicking outside
        document.addEventListener('click', function(event) {
            const dropdown = document.getElementById('roleDropdown');
            const dropdownBtn = document.querySelector('.dropdown-btn');
            
            if (!dropdownBtn.contains(event.target) && !dropdown.contains(event.target)) {
                dropdown.classList.remove('show');
                document.querySelector('.dropdown-btn i:last-child').style.transform = 'rotate(0deg)';
            }
        });

        // Password toggle functionality
        function togglePassword() {
            const passwordField = document.getElementById('password');
            const passwordIcon = document.getElementById('passwordIcon');
            
            if (passwordField.type === 'password') {
                passwordField.type = 'text';
                passwordIcon.className = 'fas fa-eye-slash';
            } else {
                passwordField.type = 'password';
                passwordIcon.className = 'fas fa-eye';
            }
        }

        // Form submission with loading state and validation
        document.getElementById('repLoginForm').addEventListener('submit', function(e) {
            const submitBtn = document.getElementById('submitBtn');
            const username = document.getElementById('username').value.trim();
            const password = document.getElementById('password').value.trim();
            
            // Validate fields
            if (!username || !password) {
                e.preventDefault();
                alert('Please fill in all fields');
                return;
            }
            
            // Set loading state
            submitBtn.classList.add('loading');
            submitBtn.innerHTML = '<i class="fas fa-sign-in-alt"></i> Authenticating...';
            submitBtn.disabled = true;
            
            // Reset loading state after 10 seconds (failsafe)
            setTimeout(() => {
                if (submitBtn.classList.contains('loading')) {
                    submitBtn.classList.remove('loading');
                    submitBtn.innerHTML = '<i class="fas fa-sign-in-alt"></i> Access Rep Portal';
                    submitBtn.disabled = false;
                }
            }, 10000);
        });

        // Auto-focus username field on page load and reset form state
        window.addEventListener('load', function() {
            // Reset form state in case user navigated back
            const submitBtn = document.getElementById('submitBtn');
            const loginForm = document.getElementById('repLoginForm');
            
            // Reset button state
            submitBtn.classList.remove('loading');
            submitBtn.innerHTML = '<i class="fas fa-sign-in-alt"></i> Access Rep Portal';
            submitBtn.disabled = false;
            
            // Reset form
            loginForm.reset();
            
            // Auto-focus username field
            setTimeout(() => {
                document.getElementById('username').focus();
            }, 500);
        });

        // Reset form state when page becomes visible (handles back button)
        document.addEventListener('visibilitychange', function() {
            if (!document.hidden) {
                const submitBtn = document.getElementById('submitBtn');
                submitBtn.classList.remove('loading');
                submitBtn.innerHTML = '<i class="fas fa-sign-in-alt"></i> Access Rep Portal';
                submitBtn.disabled = false;
            }
        });

        // Handle page show event (back button navigation)
        window.addEventListener('pageshow', function(e) {
            const submitBtn = document.getElementById('submitBtn');
            submitBtn.classList.remove('loading');
            submitBtn.innerHTML = '<i class="fas fa-sign-in-alt"></i> Access Rep Portal';
            submitBtn.disabled = false;
        });

        // Enhanced form interactions
        document.querySelectorAll('.form-control').forEach(input => {
            // Focus effects
            input.addEventListener('focus', function() {
                this.parentElement.style.transform = 'scale(1.01)';
                this.parentElement.style.transition = 'transform 0.3s cubic-bezier(0.4, 0, 0.2, 1)';
            });
            
            input.addEventListener('blur', function() {
                this.parentElement.style.transform = 'scale(1)';
            });

            // Real-time validation feedback
            input.addEventListener('input', function() {
                if (this.value.length > 0) {
                    this.style.borderColor = '#0ea5e9';
                    this.style.boxShadow = '0 0 0 3px rgba(14, 165, 233, 0.08)';
                } else {
                    this.style.borderColor = '#bae6fd';
                    this.style.boxShadow = 'none';
                }
            });
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // Alt + R to focus username field (Rep)
            if (e.altKey && e.key === 'r') {
                e.preventDefault();
                document.getElementById('username').focus();
            }
            
            // Escape to close dropdown
            if (e.key === 'Escape') {
                const dropdown = document.getElementById('roleDropdown');
                dropdown.classList.remove('show');
                document.querySelector('.dropdown-btn i:last-child').style.transform = 'rotate(0deg)';
            }
        });

        // Smooth scroll to error if present
        window.addEventListener('load', function() {
            const errorAlert = document.querySelector('.alert-danger');
            if (errorAlert) {
                errorAlert.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
        });
    </script>
</body>
</html>