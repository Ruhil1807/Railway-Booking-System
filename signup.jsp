<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <title>Sign Up - IRCTC</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
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
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: linear-gradient(135deg, var(--primary-50) 0%, var(--primary-100) 50%, var(--primary-200) 100%);
      min-height: 100vh;
      overflow-x: hidden;
      position: relative;
      color: var(--primary-800);
      line-height: 1.6;
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
      width: 100%;
      height: 72px;
      background: var(--glass-bg);
      backdrop-filter: blur(20px) saturate(180%);
      border-bottom: 1px solid var(--glass-border);
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 48px;
      box-shadow: var(--shadow-sm);
      position: fixed;
      top: 0;
      z-index: 1000;
      transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    }

    .navbar.scrolled {
      background: rgba(255, 255, 255, 0.95);
      box-shadow: var(--shadow-lg);
      height: 64px;
    }

    .nav-left, .nav-right {
      flex: 1;
      display: flex;
      align-items: center;
    }

    .nav-left {
      justify-content: flex-start;
    }

    .nav-right {
      justify-content: flex-end;
    }

    .back-button, .login-link {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 12px 20px;
      border-radius: 12px;
      text-decoration: none;
      font-weight: 600;
      font-size: 0.95rem;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      position: relative;
      overflow: hidden;
    }

    .back-button {
      background: rgba(255, 255, 255, 0.8);
      color: var(--primary-600);
      border: 1px solid var(--primary-200);
    }

    .back-button:hover {
      background: var(--primary-600);
      color: white;
      border-color: var(--primary-600);
      transform: translateY(-2px);
      box-shadow: var(--shadow-lg);
    }

    .login-link {
      background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
      color: white;
      border: 1px solid transparent;
    }

    .login-link:hover {
      transform: translateY(-2px);
      box-shadow: var(--shadow-lg);
      color: white;
    }

    .back-button::before, .login-link::before {
      content: '';
      position: absolute;
      top: 0;
      left: -100%;
      width: 100%;
      height: 100%;
      background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
      transition: left 0.6s cubic-bezier(0.4, 0, 0.2, 1);
    }

    .back-button:hover::before, .login-link:hover::before {
      left: 100%;
    }

    .logo {
      display: flex;
      align-items: center;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      position: relative;
      flex: 0 0 auto;
    }

    .logo::after {
      content: '';
      position: absolute;
      bottom: -2px;
      left: 0;
      width: 0;
      height: 2px;
      background: linear-gradient(90deg, var(--accent-primary), var(--accent-secondary));
      transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }

    .logo:hover::after {
      width: 100%;
    }

    .logo:hover {
      transform: translateY(-1px);
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

    .logo:hover .logo-icon {
      transform: scale(1.05) rotate(2deg);
      box-shadow: var(--shadow-lg);
    }

    .logo span {
      font-weight: 700;
      font-size: 1.5rem;
      color: var(--primary-800);
      position: relative;
    }

    /* Main Container */
    .main-container {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 120px 24px 48px;
    }

    /* Professional Signup Card */
    .signup-card {
      width: 100%;
      max-width: 480px;
      background: var(--glass-bg);
      backdrop-filter: blur(20px) saturate(180%);
      border-radius: 24px;
      border: 1px solid var(--glass-border);
      box-shadow: var(--shadow-2xl);
      overflow: hidden;
      position: relative;
      animation: cardEntrance 0.8s cubic-bezier(0.4, 0, 0.2, 1);
    }

    @keyframes cardEntrance {
      from {
        opacity: 0;
        transform: translateY(40px) scale(0.95);
      }
      to {
        opacity: 1;
        transform: translateY(0) scale(1);
      }
    }

    .signup-card::before {
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

    .signup-header {
      padding: 48px 48px 24px;
      text-align: center;
      background: linear-gradient(135deg, 
        rgba(59, 130, 246, 0.02) 0%, 
        rgba(99, 102, 241, 0.02) 100%
      );
      position: relative;
    }

    .signup-header::after {
      content: '';
      position: absolute;
      bottom: 0;
      left: 50%;
      width: 60px;
      height: 1px;
      background: linear-gradient(90deg, var(--accent-primary), var(--accent-secondary));
      transform: translateX(-50%);
    }

    .signup-header .icon-wrapper {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 64px;
      height: 64px;
      background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
      border-radius: 20px;
      margin-bottom: 24px;
      box-shadow: var(--shadow-lg);
      position: relative;
      overflow: hidden;
    }

    .signup-header .icon-wrapper::before {
      content: '';
      position: absolute;
      top: 0;
      left: -100%;
      width: 100%;
      height: 100%;
      background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
      transition: left 0.6s;
    }

    .signup-header .icon-wrapper:hover::before {
      left: 100%;
    }

    .signup-header .icon-wrapper i {
      font-size: 1.5rem;
      color: white;
      z-index: 1;
    }

    .signup-header h2 {
      font-weight: 700;
      font-size: 2rem;
      color: var(--primary-800);
      margin-bottom: 8px;
      letter-spacing: -0.025em;
    }

    .signup-header p {
      color: var(--primary-600);
      font-size: 0.95rem;
      font-weight: 400;
      max-width: 320px;
      margin: 0 auto;
    }

    .signup-body {
      padding: 24px 48px 48px;
    }

    /* Enhanced Form Styling */
    .form-group {
      margin-bottom: 24px;
      position: relative;
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
      position: relative;
    }

    .form-control:focus {
      outline: none;
      border-color: var(--accent-primary);
      box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
      background: rgba(255, 255, 255, 1);
      transform: translateY(-1px);
    }

    .form-control.valid {
      border-color: var(--accent-success);
    }

    .form-control.invalid {
      border-color: var(--accent-error);
    }

    .form-control::placeholder {
      color: var(--primary-400);
      font-weight: 400;
      transition: all 0.3s ease;
    }

    .form-control:focus::placeholder {
      color: var(--primary-300);
      transform: translateX(4px);
    }

    /* Advanced Password Field */
    .password-field {
      position: relative;
    }

    .password-toggle {
      position: absolute;
      right: 16px;
      top: 50%;
      transform: translateY(-50%);
      background: none;
      border: none;
      color: var(--primary-400);
      cursor: pointer;
      padding: 8px;
      border-radius: 8px;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      z-index: 10;
    }

    .password-toggle:hover {
      color: var(--accent-primary);
      background: rgba(59, 130, 246, 0.1);
      transform: translateY(-50%) scale(1.1);
    }

    /* Enhanced Checkbox */
    .form-check {
      margin-bottom: 32px;
      display: flex;
      align-items: center;
      gap: 12px;
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

    /* Premium Button */
    .btn-signup {
      width: 100%;
      padding: 18px 24px;
      background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
      border: none;
      border-radius: 12px;
      color: white;
      font-weight: 600;
      font-size: 1.1rem;
      cursor: pointer;
      transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
      position: relative;
      overflow: hidden;
      box-shadow: var(--shadow-md);
    }

    .btn-signup::before {
      content: '';
      position: absolute;
      top: 0;
      left: -100%;
      width: 100%;
      height: 100%;
      background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
      transition: left 0.6s cubic-bezier(0.4, 0, 0.2, 1);
    }

    .btn-signup:hover {
      transform: translateY(-2px);
      box-shadow: var(--shadow-xl);
    }

    .btn-signup:hover::before {
      left: 100%;
    }

    .btn-signup:active {
      transform: translateY(0);
      transition: transform 0.1s;
    }

    .btn-signup:disabled {
      opacity: 0.7;
      cursor: not-allowed;
      transform: none;
    }

    /* Professional Alerts */
    .alert {
      border: none;
      border-radius: 12px;
      padding: 16px 20px;
      margin-bottom: 24px;
      font-weight: 500;
      position: relative;
      overflow: hidden;
      animation: alertSlide 0.5s cubic-bezier(0.4, 0, 0.2, 1);
      display: flex;
      align-items: center;
      gap: 12px;
    }

    @keyframes alertSlide {
      from {
        opacity: 0;
        transform: translateY(-20px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
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
      border: 1px solid rgba(16, 185, 129, 0.2);
    }

    .alert-warning {
      background: rgba(245, 158, 11, 0.1);
      color: var(--accent-warning);
      border: 1px solid rgba(245, 158, 11, 0.2);
    }

    .alert-danger {
      background: rgba(239, 68, 68, 0.1);
      color: var(--accent-error);
      border: 1px solid rgba(239, 68, 68, 0.2);
    }

    /* Loading Animation */
    .loading {
      display: none;
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
    }

    .loading.active {
      display: block;
    }

    .spinner {
      width: 20px;
      height: 20px;
      border: 2px solid rgba(255, 255, 255, 0.3);
      border-top: 2px solid white;
      border-radius: 50%;
      animation: spin 1s linear infinite;
    }

    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }

    /* Responsive Design */
    @media (max-width: 768px) {
      .navbar {
        padding: 0 24px;
        height: 64px;
        flex-wrap: wrap;
      }

      .nav-left, .nav-right {
        flex: none;
      }

      .back-button, .login-link {
        padding: 10px 16px;
        font-size: 0.9rem;
      }

      .back-button span, .login-link span {
        display: none;
      }

      .logo span {
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

      .main-container {
        padding: 100px 16px 32px;
      }

      .signup-card {
        border-radius: 20px;
      }

      .signup-header,
      .signup-body {
        padding: 32px 24px;
      }

      .signup-header h2 {
        font-size: 1.75rem;
      }

      .signup-header .icon-wrapper {
        width: 56px;
        height: 56px;
        margin-bottom: 20px;
      }
    }

    @media (max-width: 480px) {
      .navbar {
        padding: 0 16px;
      }

      .logo {
        flex-direction: column;
        gap: 4px;
      }

      .logo-icon {
        margin-right: 0;
        margin-bottom: 4px;
      }

      .main-container {
        padding: 120px 12px 24px;
      }
    }

    /* Micro-interactions */
    .form-group {
      transform: translateZ(0);
    }

    .form-group:hover .form-control {
      border-color: var(--primary-300);
    }

    /* Focus states for accessibility */
    .btn-signup:focus-visible,
    .form-control:focus-visible,
    .form-check-input:focus-visible {
      outline: 2px solid var(--accent-primary);
      outline-offset: 2px;
    }
  </style>

  <script>
    function togglePassword() {
      const pwd = document.getElementById("password");
      const icon = document.getElementById("password-toggle-icon");
      
      if (pwd.type === "password") {
        pwd.type = "text";
        icon.className = "fas fa-eye-slash";
      } else {
        pwd.type = "password";
        icon.className = "fas fa-eye";
      }
    }

    function showLoading() {
      const btn = document.querySelector('.btn-signup');
      const loading = document.querySelector('.loading');
      const btnText = document.querySelector('.btn-text');
      
      btn.disabled = true;
      loading.classList.add('active');
      btnText.style.opacity = '0';
    }

    // Advanced form validation with visual feedback
    document.addEventListener('DOMContentLoaded', function() {
      const form = document.querySelector('form');
      const inputs = form.querySelectorAll('input[required]');
      
      // Navbar scroll effect
      window.addEventListener('scroll', function() {
        const navbar = document.querySelector('.navbar');
        if (window.scrollY > 20) {
          navbar.classList.add('scrolled');
        } else {
          navbar.classList.remove('scrolled');
        }
      });
      
      inputs.forEach(input => {
        input.addEventListener('blur', function() {
          if (this.value.trim() === '') {
            this.classList.remove('valid');
            this.classList.add('invalid');
          } else {
            this.classList.remove('invalid');
            this.classList.add('valid');
          }
        });
        
        input.addEventListener('input', function() {
          this.classList.remove('invalid', 'valid');
          if (this.value.trim() !== '') {
            // Real-time validation
            if (this.type === 'email') {
              const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
              if (emailRegex.test(this.value)) {
                this.classList.add('valid');
              }
            } else {
              this.classList.add('valid');
            }
          }
        });
      });
      
      form.addEventListener('submit', function(e) {
        let isValid = true;
        inputs.forEach(input => {
          if (input.value.trim() === '') {
            input.classList.add('invalid');
            isValid = false;
          }
        });
        
        if (isValid) {
          showLoading();
        } else {
          e.preventDefault();
          // Smooth scroll to first invalid field
          const firstInvalid = form.querySelector('.invalid');
          if (firstInvalid) {
            firstInvalid.scrollIntoView({ behavior: 'smooth', block: 'center' });
            firstInvalid.focus();
          }
        }
      });

      // Enhanced checkbox interaction
      const checkbox = document.querySelector('.form-check-input');
      const passwordField = document.querySelector('#password');
      
      checkbox.addEventListener('change', function() {
        if (this.checked) {
          passwordField.type = 'text';
          document.getElementById('password-toggle-icon').className = 'fas fa-eye-slash';
        } else {
          passwordField.type = 'password';
          document.getElementById('password-toggle-icon').className = 'fas fa-eye';
        }
      });
    });

    // Redirect to login after success
    window.onload = function () {
      const params = new URLSearchParams(window.location.search);
      if (params.get("status") === "success") {
        setTimeout(() => {
          window.location.href = "login.jsp";
        }, 3000);
      }
    };
  </script>
</head>
<body>

  <!-- Professional Navbar -->
  <div class="navbar">
    <div class="nav-left">
      <a href="index.html" class="back-button">
        <i class="fas fa-arrow-left"></i>
        <span>Back</span>
      </a>
    </div>
    
    <div class="logo">
      <a href="index.html" style="text-decoration: none; display: flex; align-items: center;">
        <div class="logo-icon">
          <i class="fas fa-train"></i>
        </div>
        <span>IRCTC</span>
      </a>
    </div>
    
    <div class="nav-right">
      <a href="login.jsp" class="login-link">
        <i class="fas fa-sign-in-alt"></i>
        <span>Login</span>
      </a>
    </div>
  </div>

  <!-- Main Container -->
  <div class="main-container">
    <div class="signup-card">
      <div class="signup-header">
        <div class="icon-wrapper">
          <i class="fas fa-user-plus"></i>
        </div>
        <h2>Create Account</h2>
        <p>Join millions of travelers on India's premier railway platform</p>
      </div>

      <div class="signup-body">
        <%
          String status = request.getParameter("status");
          if ("exists_both".equals(status)) {
        %>
          <div class="alert alert-warning">
            <i class="fas fa-exclamation-triangle"></i>
            <span>An account already exists with the same username and email.</span>
          </div>
        <%
          } else if ("exists_username".equals(status)) {
        %>
          <div class="alert alert-warning">
            <i class="fas fa-user-times"></i>
            <span>Username already exists. Please choose a different one.</span>
          </div>
        <%
          } else if ("exists_email".equals(status)) {
        %>
          <div class="alert alert-warning">
            <i class="fas fa-envelope"></i>
            <span>Email is already registered. Use another email.</span>
          </div>
        <%
          } else if ("success".equals(status)) {
        %>
          <div class="alert alert-success">
            <i class="fas fa-check-circle"></i>
            <span>Account created successfully! Redirecting to login...</span>
          </div>
        <%
          } else if ("error".equals(status)) {
        %>
          <div class="alert alert-danger">
            <i class="fas fa-times-circle"></i>
            <span>Something went wrong. Please try again.</span>
          </div>
        <%
          }
        %>

        <form action="signup" method="post">
          <div class="form-group">
            <input type="text" name="username" class="form-control" placeholder="Enter your username" required>
          </div>
          
          <div class="form-group">
            <input type="text" name="firstName" class="form-control" placeholder="First name" required>
          </div>
          
          <div class="form-group">
            <input type="text" name="lastName" class="form-control" placeholder="Last name" required>
          </div>
          
          <div class="form-group">
            <input type="email" name="email" class="form-control" placeholder="Email address" required>
          </div>
          
          <div class="form-group password-field">
            <input type="password" name="password" class="form-control" placeholder="Create a strong password" id="password" required>
            <button type="button" class="password-toggle" onclick="togglePassword()">
              <i class="fas fa-eye" id="password-toggle-icon"></i>
            </button>
          </div>
          
          <div class="form-check">
            <input type="checkbox" class="form-check-input" id="showPassword">
            <label class="form-check-label" for="showPassword">
              Show password
            </label>
          </div>
          
          <button type="submit" class="btn-signup">
            <span class="btn-text">Create Account</span>
            <div class="loading">
              <div class="spinner"></div>
            </div>
          </button>
        </form>
      </div>
    </div>
  </div>

</body>
</html>