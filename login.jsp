<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String redirect = request.getParameter("redirect");
    String scheduleId = request.getParameter("scheduleId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sign In - IRCTC</title>
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
            background: linear-gradient(135deg, #0ea5e9 0%, #3b82f6 50%, #6366f1 100%);
            min-height: 100vh;
            line-height: 1.6;
            color: #334155;
            position: relative;
            overflow-x: hidden;
        }

        /* Animated background elements */
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: 
                radial-gradient(circle at 25% 25%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
                radial-gradient(circle at 75% 75%, rgba(255, 255, 255, 0.05) 0%, transparent 50%),
                radial-gradient(circle at 50% 50%, rgba(14, 165, 233, 0.1) 0%, transparent 50%);
            z-index: -1;
            animation: backgroundShift 15s ease-in-out infinite;
        }

        @keyframes backgroundShift {
            0%, 100% { transform: translateX(0) translateY(0) rotate(0deg); }
            33% { transform: translateX(-10px) translateY(-15px) rotate(1deg); }
            66% { transform: translateX(10px) translateY(10px) rotate(-1deg); }
        }

        /* Navigation */
        .navbar {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
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
            color: #64748b;
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

        .navbar-brand img {
            height: 45px;
            margin-right: 12px;
            border-radius: 8px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .navbar-brand:hover img {
            transform: scale(1.05) rotate(2deg);
        }

        .role-dropdown {
            position: relative;
        }

        .dropdown-btn {
            background: white;
            color: #64748b;
            border: 2px solid #e2e8f0;
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
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .dropdown-btn:hover::before {
            left: 100%;
        }

        .dropdown-btn:hover {
            background: #64748b;
            color: white;
            border-color: #64748b;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(100, 116, 139, 0.2);
        }

        .dropdown-menu {
            position: absolute;
            top: 100%;
            right: 0;
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
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
            background: #f8fafc;
            color: #1e293b;
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
            max-width: 440px;
            animation: fadeInUp 0.8s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .login-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            padding: 48px 40px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            border: 1px solid rgba(255, 255, 255, 0.2);
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
            background: linear-gradient(135deg, rgba(14, 165, 233, 0.02), rgba(59, 130, 246, 0.02));
            pointer-events: none;
        }

        .login-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 35px 70px -12px rgba(0, 0, 0, 0.3);
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
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            font-size: 1rem;
            background: white;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
        }

        .form-control:focus {
            outline: none;
            border-color: #0ea5e9;
            box-shadow: 0 0 0 4px rgba(14, 165, 233, 0.1);
            transform: translateY(-1px);
        }

        .form-control:hover {
            border-color: #94a3b8;
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
            border: 2px solid #e2e8f0;
            border-left: none;
            border-radius: 0 12px 12px 0;
            padding: 16px;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #64748b;
            font-size: 1.1rem;
        }

        .password-toggle:hover {
            background: #f8fafc;
            color: #374151;
        }

        .input-group:focus-within .password-toggle {
            border-color: #0ea5e9;
        }

        /* Hidden Inputs */
        .hidden-inputs {
            display: none;
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
            box-shadow: 0 8px 25px rgba(14, 165, 233, 0.3);
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
            box-shadow: 0 12px 35px rgba(14, 165, 233, 0.4);
        }

        .submit-btn:active {
            transform: translateY(0);
        }

        .submit-btn.loading {
            pointer-events: none;
            background: #94a3b8;
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

        /* Footer Links */
        .form-footer {
            text-align: center;
            position: relative;
            z-index: 1;
        }

        .form-footer p {
            color: #64748b;
            font-weight: 500;
        }

        .form-footer a {
            color: #0ea5e9;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            position: relative;
        }

        .form-footer a::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            width: 0;
            height: 2px;
            background: #0ea5e9;
            transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .form-footer a:hover::after {
            width: 100%;
        }

        .form-footer a:hover {
            color: #0284c7;
            transform: translateY(-1px);
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
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            animation: float 20s infinite ease-in-out;
        }

        .floating-element:nth-child(1) {
            width: 60px;
            height: 60px;
            top: 20%;
            left: 10%;
            animation-delay: 0s;
        }

        .floating-element:nth-child(2) {
            width: 40px;
            height: 40px;
            top: 60%;
            right: 10%;
            animation-delay: -7s;
        }

        .floating-element:nth-child(3) {
            width: 80px;
            height: 80px;
            bottom: 20%;
            left: 15%;
            animation-delay: -14s;
        }

        @keyframes float {
            0%, 100% {
                transform: translateY(0) rotate(0deg);
                opacity: 0.5;
            }
            50% {
                transform: translateY(-20px) rotate(180deg);
                opacity: 0.8;
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
                    <i class="fas fa-user-circle"></i>
                    <span>Login As</span>
                    <i class="fas fa-chevron-down" style="transition: transform 0.3s ease;"></i>
                </button>
                <div class="dropdown-menu" id="roleDropdown">
                    <a href="#" class="dropdown-item active">
                        <i class="fas fa-user"></i> Customer
                    </a>
                    <a href="admin-login.jsp" class="dropdown-item">
                        <i class="fas fa-user-shield"></i> Admin
                    </a>
                    <a href="rep-login.jsp" class="dropdown-item">
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
                    <h1 class="login-title">Welcome Back</h1>
                    <p class="login-subtitle">Sign in to your IRCTC account</p>
                </div>

                <!-- Error Message -->
                <%
                    String loginError = (String) request.getAttribute("loginError");
                    if (loginError != null) {
                %>
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-triangle"></i>
                        <%= loginError %>
                    </div>
                <%
                    }
                %>

                <!-- Login Form -->
                <form action="login" method="post" id="loginForm">
                    <!-- Hidden Fields -->
                    <div class="hidden-inputs">
                        <input type="hidden" name="expectedRole" value="customer">
                        <% if (redirect != null) { %>
                            <input type="hidden" name="redirect" value="<%= redirect %>">
                        <% } %>
                        <% if (scheduleId != null) { %>
                            <input type="hidden" name="scheduleId" value="<%= scheduleId %>">
                        <% } %>
                    </div>

                    <!-- Username Field -->
                    <div class="form-group">
                        <label for="username" class="form-label">
                            <i class="fas fa-user"></i>
                            Username
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
                        Sign In
                    </button>

                    <!-- Footer Links -->
                    <div class="form-footer">
                        <p>
                            Don't have an account? 
                            <a href="signup.jsp">Create Account</a>
                        </p>
                    </div>
                </form>
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

        // Form submission with loading state
        document.getElementById('loginForm').addEventListener('submit', function(e) {
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
            submitBtn.innerHTML = '<i class="fas fa-sign-in-alt"></i> Signing In...';
            submitBtn.disabled = true;
            
            // Reset loading state after 10 seconds (failsafe)
            setTimeout(() => {
                if (submitBtn.classList.contains('loading')) {
                    submitBtn.classList.remove('loading');
                    submitBtn.innerHTML = '<i class="fas fa-sign-in-alt"></i> Sign In';
                    submitBtn.disabled = false;
                }
            }, 10000);
        });

        // Enhanced form interactions
        document.querySelectorAll('.form-control').forEach(input => {
            // Focus effects
            input.addEventListener('focus', function() {
                this.parentElement.style.transform = 'scale(1.02)';
                this.parentElement.style.transition = 'transform 0.3s cubic-bezier(0.4, 0, 0.2, 1)';
            });
            
            input.addEventListener('blur', function() {
                this.parentElement.style.transform = 'scale(1)';
            });

            // Real-time validation feedback
            input.addEventListener('input', function() {
                if (this.value.length > 0) {
                    this.style.borderColor = '#10b981';
                    this.style.boxShadow = '0 0 0 3px rgba(16, 185, 129, 0.1)';
                } else {
                    this.style.borderColor = '#e2e8f0';
                    this.style.boxShadow = 'none';
                }
            });
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // Alt + L to focus username field
            if (e.altKey && e.key === 'l') {
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

        // Auto-focus username field on page load and reset form state
        window.addEventListener('load', function() {
            // Reset form state in case user navigated back
            const submitBtn = document.getElementById('submitBtn');
            const loginForm = document.getElementById('loginForm');
            
            // Reset button state
            submitBtn.classList.remove('loading');
            submitBtn.innerHTML = '<i class="fas fa-sign-in-alt"></i> Sign In';
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
                const loginForm = document.getElementById('loginForm');
                
                submitBtn.classList.remove('loading');
                submitBtn.innerHTML = '<i class="fas fa-sign-in-alt"></i> Sign In';
                submitBtn.disabled = false;
            }
        });

        // Handle page show event (back button navigation)
        window.addEventListener('pageshow', function(e) {
            const submitBtn = document.getElementById('submitBtn');
            const loginForm = document.getElementById('loginForm');
            
            submitBtn.classList.remove('loading');
            submitBtn.innerHTML = '<i class="fas fa-sign-in-alt"></i> Sign In';
            submitBtn.disabled = false;
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