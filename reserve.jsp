<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.time.*, java.time.format.*" %>
<%
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp?redirect=reserve.jsp");
        return;
    }

    // Capture train details from GET parameters
    String trainName = request.getParameter("trainName");
    String origin = request.getParameter("origin");
    String destination = request.getParameter("destination");
    String fare = request.getParameter("fare");
    String departure = request.getParameter("departure");
    String arrival = request.getParameter("arrival");
    String travelDate = request.getParameter("travelDate");
    
    // Check for error messages
    String errorMessage = request.getParameter("error");
    String successMessage = request.getParameter("message");
    
    // Validate required train details
    boolean missingDetails = (trainName == null || origin == null || destination == null || fare == null || travelDate == null);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reserve Your Train - IRCTC</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            /* Color System */
            --primary-50: #f0f9ff;
            --primary-100: #e0f2fe;
            --primary-200: #bae6fd;
            --primary-300: #7dd3fc;
            --primary-400: #38bdf8;
            --primary-500: #0ea5e9;
            --primary-600: #0284c7;
            --primary-700: #0369a1;
            --primary-800: #075985;
            --primary-900: #0c4a6e;
            
            --secondary-50: #f8fafc;
            --secondary-100: #f1f5f9;
            --secondary-200: #e2e8f0;
            --secondary-300: #cbd5e1;
            --secondary-400: #94a3b8;
            --secondary-500: #64748b;
            --secondary-600: #475569;
            --secondary-700: #334155;
            --secondary-800: #1e293b;
            --secondary-900: #0f172a;
            
            --success-50: #ecfdf5;
            --success-100: #d1fae5;
            --success-200: #a7f3d0;
            --success-300: #6ee7b7;
            --success-400: #34d399;
            --success-500: #10b981;
            --success-600: #059669;
            --success-700: #047857;
            --success-800: #065f46;
            --success-900: #064e3b;
            
            --warning-50: #fffbeb;
            --warning-100: #fef3c7;
            --warning-200: #fde68a;
            --warning-300: #fcd34d;
            --warning-400: #fbbf24;
            --warning-500: #f59e0b;
            --warning-600: #d97706;
            --warning-700: #b45309;
            --warning-800: #92400e;
            --warning-900: #78350f;
            
            --error-50: #fef2f2;
            --error-100: #fee2e2;
            --error-200: #fecaca;
            --error-300: #fca5a5;
            --error-400: #f87171;
            --error-500: #ef4444;
            --error-600: #dc2626;
            --error-700: #b91c1c;
            --error-800: #991b1b;
            --error-900: #7f1d1d;
            
            /* Shadows */
            --shadow-xs: 0 1px 2px 0 rgb(0 0 0 / 0.05);
            --shadow-sm: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
            --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
            --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
            --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
            --shadow-2xl: 0 25px 50px -12px rgb(0 0 0 / 0.25);
            --shadow-inner: inset 0 2px 4px 0 rgb(0 0 0 / 0.05);
            
            /* Glass morphism */
            --glass-bg: rgba(255, 255, 255, 0.25);
            --glass-border: rgba(255, 255, 255, 0.18);
            
            /* Typography */
            --font-mono: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
            
            /* Spacing */
            --space-xs: 0.25rem;
            --space-sm: 0.5rem;
            --space-md: 1rem;
            --space-lg: 1.5rem;
            --space-xl: 2rem;
            --space-2xl: 3rem;
            --space-3xl: 4rem;
            
            /* Border radius */
            --radius-sm: 0.375rem;
            --radius-md: 0.5rem;
            --radius-lg: 0.75rem;
            --radius-xl: 1rem;
            --radius-2xl: 1.5rem;
            --radius-3xl: 2rem;
            
            /* Transitions */
            --transition-fast: 150ms cubic-bezier(0.4, 0, 0.2, 1);
            --transition-base: 250ms cubic-bezier(0.4, 0, 0.2, 1);
            --transition-slow: 350ms cubic-bezier(0.4, 0, 0.2, 1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html {
            scroll-behavior: smooth;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
            background: linear-gradient(135deg, 
                var(--primary-50) 0%, 
                var(--secondary-100) 25%, 
                var(--primary-100) 50%, 
                var(--secondary-50) 75%, 
                var(--primary-50) 100%);
            min-height: 100vh;
            line-height: 1.6;
            color: var(--secondary-800);
            position: relative;
            overflow-x: hidden;
        }

        /* Enhanced background effects */
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: 
                radial-gradient(circle at 20% 30%, rgba(14, 165, 233, 0.08) 0%, transparent 50%),
                radial-gradient(circle at 80% 70%, rgba(59, 130, 246, 0.06) 0%, transparent 50%),
                radial-gradient(circle at 40% 90%, rgba(16, 185, 129, 0.05) 0%, transparent 50%),
                radial-gradient(circle at 90% 10%, rgba(147, 197, 253, 0.04) 0%, transparent 50%);
            z-index: -2;
            pointer-events: none;
        }

        body::after {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%2364748b' fill-opacity='0.02'%3E%3Ccircle cx='30' cy='30' r='4'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
            z-index: -1;
            pointer-events: none;
        }

        /* Navigation */
        .navbar {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(24px) saturate(180%);
            border-bottom: 1px solid var(--secondary-200);
            padding: var(--space-lg) 0;
            position: sticky;
            top: 0;
            z-index: 1000;
            transition: all var(--transition-base);
        }

        .navbar-content {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 var(--space-xl);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .navbar-brand {
            display: flex;
            align-items: center;
            color: var(--secondary-800);
            font-weight: 800;
            font-size: 1.75rem;
            text-decoration: none;
            transition: all var(--transition-fast);
        }

        .navbar-brand:hover {
            transform: translateY(-1px);
            color: var(--primary-600);
            text-decoration: none;
        }

        .navbar-brand i {
            font-size: 2rem;
            margin-right: var(--space-md);
            background: linear-gradient(135deg, var(--primary-600), var(--success-500));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            filter: drop-shadow(0 2px 4px rgba(14, 165, 233, 0.2));
        }

        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: var(--space-sm);
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            color: var(--primary-700);
            padding: var(--space-md) var(--space-xl);
            text-decoration: none;
            border: 1px solid var(--glass-border);
            border-radius: var(--radius-xl);
            font-weight: 600;
            font-size: 0.95rem;
            transition: all var(--transition-base);
            box-shadow: var(--shadow-sm);
        }

        .back-btn:hover {
            background: rgba(255, 255, 255, 0.4);
            border-color: var(--primary-300);
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
            text-decoration: none;
            color: var(--primary-800);
        }

        /* Container */
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: var(--space-3xl) var(--space-xl);
        }

        /* Header Section */
        .header-section {
            background: var(--glass-bg);
            backdrop-filter: blur(24px) saturate(180%);
            border: 1px solid var(--glass-border);
            border-radius: var(--radius-3xl);
            padding: var(--space-3xl) var(--space-2xl);
            margin-bottom: var(--space-2xl);
            box-shadow: var(--shadow-2xl);
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .header-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, 
                rgba(14, 165, 233, 0.05) 0%, 
                rgba(16, 185, 129, 0.03) 50%, 
                rgba(59, 130, 246, 0.05) 100%);
            pointer-events: none;
        }

        .header-section h1 {
            font-size: clamp(2rem, 4vw, 3rem);
            font-weight: 900;
            background: linear-gradient(135deg, var(--success-600), var(--primary-600), var(--success-500));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: var(--space-sm);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: var(--space-md);
            position: relative;
            z-index: 1;
            letter-spacing: -0.02em;
        }

        .header-section h1 i {
            background: linear-gradient(135deg, var(--success-500), var(--primary-500));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            filter: drop-shadow(0 4px 8px rgba(16, 185, 129, 0.3));
        }

        .header-section p {
            color: var(--secondary-600);
            font-size: 1.25rem;
            font-weight: 500;
            position: relative;
            z-index: 1;
            max-width: 600px;
            margin: 0 auto;
        }

        /* Alert Messages */
        .alert {
            padding: var(--space-lg) var(--space-xl);
            border-radius: var(--radius-xl);
            margin-bottom: var(--space-xl);
            display: flex;
            align-items: center;
            gap: var(--space-md);
            font-weight: 600;
            font-size: 1rem;
            backdrop-filter: blur(12px);
            border: 1px solid transparent;
            box-shadow: var(--shadow-lg);
            transition: all var(--transition-base);
        }

        .alert-danger {
            background: rgba(239, 68, 68, 0.1);
            border-color: var(--error-200);
            color: var(--error-700);
        }

        .alert-success {
            background: rgba(16, 185, 129, 0.1);
            border-color: var(--success-200);
            color: var(--success-700);
        }

        .alert i {
            font-size: 1.25rem;
        }

        /* Train Info Card */
        .train-info-card {
            background: var(--glass-bg);
            backdrop-filter: blur(24px) saturate(180%);
            border: 1px solid var(--glass-border);
            border-radius: var(--radius-2xl);
            padding: var(--space-2xl);
            margin-bottom: var(--space-2xl);
            box-shadow: var(--shadow-xl);
            position: relative;
            overflow: hidden;
            transition: all var(--transition-base);
        }

        .train-info-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-2xl);
        }

        .train-info-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--primary-500), var(--success-500), var(--primary-600));
            border-radius: var(--radius-md) var(--radius-md) 0 0;
        }

        .train-info-header {
            display: flex;
            align-items: center;
            gap: var(--space-md);
            margin-bottom: var(--space-xl);
            padding-bottom: var(--space-lg);
            border-bottom: 2px solid var(--primary-100);
        }

        .train-info-header h3 {
            font-size: 1.5rem;
            font-weight: 800;
            color: var(--primary-700);
        }

        .train-info-header i {
            width: 48px;
            height: 48px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--primary-500), var(--primary-600));
            color: white;
            border-radius: var(--radius-lg);
            font-size: 1.25rem;
            box-shadow: var(--shadow-md);
        }

        .train-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: var(--space-lg);
        }

        .detail-item {
            display: flex;
            align-items: center;
            gap: var(--space-md);
            padding: var(--space-lg);
            background: rgba(255, 255, 255, 0.7);
            border-radius: var(--radius-lg);
            transition: all var(--transition-fast);
            border: 1px solid var(--secondary-200);
        }

        .detail-item:hover {
            background: rgba(255, 255, 255, 0.9);
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        .detail-item i {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--primary-100), var(--primary-200));
            color: var(--primary-600);
            border-radius: var(--radius-md);
            font-size: 1.1rem;
        }

        .detail-content {
            flex: 1;
        }

        .detail-label {
            font-weight: 700;
            color: var(--secondary-600);
            font-size: 0.875rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: var(--space-xs);
        }

        .detail-value {
            font-weight: 600;
            color: var(--secondary-800);
            font-size: 1.1rem;
        }

        .fare-highlight {
            background: linear-gradient(135deg, var(--success-500), var(--success-600));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-weight: 800;
            font-size: 1.25rem;
        }

        /* Form Container */
        .form-container {
            background: var(--glass-bg);
            backdrop-filter: blur(24px) saturate(180%);
            border: 1px solid var(--glass-border);
            border-radius: var(--radius-2xl);
            padding: var(--space-2xl);
            box-shadow: var(--shadow-xl);
            position: relative;
            overflow: hidden;
        }

        .form-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, 
                rgba(255, 255, 255, 0.1) 0%, 
                rgba(255, 255, 255, 0.05) 100%);
            pointer-events: none;
        }

        .form-section {
            margin-bottom: var(--space-2xl);
            position: relative;
            z-index: 1;
        }

        .form-section h4 {
            font-size: 1.375rem;
            font-weight: 800;
            color: var(--secondary-800);
            margin-bottom: var(--space-lg);
            display: flex;
            align-items: center;
            gap: var(--space-md);
        }

        .form-section h4 i {
            width: 44px;
            height: 44px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--primary-500), var(--primary-600));
            color: white;
            border-radius: var(--radius-lg);
            font-size: 1.1rem;
            box-shadow: var(--shadow-md);
        }

        /* Trip Type Selection */
        .trip-type-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: var(--space-lg);
            margin-bottom: var(--space-xl);
        }

        .trip-option {
            position: relative;
        }

        .trip-option input[type="radio"] {
            position: absolute;
            opacity: 0;
            pointer-events: none;
        }

        .trip-option label {
            display: block;
            padding: var(--space-xl) var(--space-lg);
            background: rgba(255, 255, 255, 0.7);
            border: 2px solid var(--secondary-200);
            border-radius: var(--radius-xl);
            cursor: pointer;
            transition: all var(--transition-base);
            text-align: center;
            font-weight: 700;
            font-size: 1.1rem;
            color: var(--secondary-700);
            position: relative;
            overflow: hidden;
        }

        .trip-option label::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            transition: left 0.5s;
        }

        .trip-option input[type="radio"]:checked + label {
            background: linear-gradient(135deg, var(--primary-50), var(--primary-100));
            border-color: var(--primary-500);
            color: var(--primary-700);
            box-shadow: var(--shadow-lg);
        }

        .trip-option input[type="radio"]:checked + label::before {
            left: 100%;
        }

        .trip-option label:hover {
            border-color: var(--primary-300);
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        .trip-option label i {
            margin-right: var(--space-sm);
            font-size: 1.25rem;
        }

        /* Return Date */
        .return-date-container {
            margin-top: var(--space-lg);
            opacity: 0;
            transform: translateY(-20px);
            transition: all var(--transition-base);
            max-height: 0;
            overflow: hidden;
        }

        .return-date-container.show {
            opacity: 1;
            transform: translateY(0);
            max-height: 200px;
        }

        /* Input Groups */
        .passenger-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: var(--space-xl);
        }

        .input-group {
            display: flex;
            flex-direction: column;
            gap: var(--space-sm);
        }

        .input-group label {
            font-weight: 700;
            color: var(--secondary-700);
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: var(--space-sm);
            margin-bottom: var(--space-xs);
        }

        .input-group label i {
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-500);
            font-size: 1rem;
        }

        .input-group small {
            color: var(--success-600);
            font-weight: 600;
            font-size: 0.8rem;
        }

        .input-group input,
        .input-group select {
            padding: var(--space-lg) var(--space-lg);
            border: 2px solid var(--secondary-200);
            border-radius: var(--radius-lg);
            font-size: 1rem;
            font-weight: 600;
            font-family: inherit;
            transition: all var(--transition-base);
            background: rgba(255, 255, 255, 0.9);
            color: var(--secondary-800);
            backdrop-filter: blur(8px);
        }

        .input-group input:focus,
        .input-group select:focus {
            outline: none;
            border-color: var(--primary-500);
            box-shadow: 0 0 0 4px rgba(14, 165, 233, 0.1);
            background: rgba(255, 255, 255, 1);
            transform: translateY(-1px);
        }

        .input-group input:hover,
        .input-group select:hover {
            border-color: var(--primary-300);
        }

        /* Fare Summary */
        .fare-summary {
            background: linear-gradient(135deg, 
                rgba(16, 185, 129, 0.08) 0%, 
                rgba(14, 165, 233, 0.05) 100%);
            border: 2px solid var(--success-200);
            border-radius: var(--radius-xl);
            padding: var(--space-xl);
            margin-top: var(--space-xl);
            backdrop-filter: blur(12px);
            box-shadow: var(--shadow-lg);
            transition: all var(--transition-base);
        }

        .fare-summary:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-xl);
        }

        .fare-summary h5 {
            font-size: 1.25rem;
            font-weight: 800;
            color: var(--secondary-800);
            margin-bottom: var(--space-lg);
            display: flex;
            align-items: center;
            gap: var(--space-md);
        }

        .fare-summary h5 i {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--success-500), var(--success-600));
            color: white;
            border-radius: var(--radius-md);
            font-size: 1.1rem;
            box-shadow: var(--shadow-md);
        }

        .fare-breakdown {
            display: flex;
            flex-direction: column;
            gap: var(--space-md);
        }

        .fare-line {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-weight: 600;
            font-size: 1rem;
            padding: var(--space-sm) 0;
            color: var(--secondary-700);
        }

        .fare-total {
            border-top: 2px solid var(--success-200);
            padding-top: var(--space-lg);
            margin-top: var(--space-lg);
            font-weight: 900;
            font-size: 1.375rem;
            background: linear-gradient(135deg, var(--success-600), var(--success-700));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        /* Submit Button */
        .submit-container {
            text-align: center;
            margin-top: var(--space-2xl);
            position: relative;
            z-index: 1;
        }

        .btn-submit {
            display: inline-flex;
            align-items: center;
            gap: var(--space-md);
            background: linear-gradient(135deg, var(--success-500), var(--success-600));
            color: white;
            padding: var(--space-xl) var(--space-3xl);
            text-decoration: none;
            border-radius: var(--radius-xl);
            font-weight: 800;
            font-size: 1.125rem;
            transition: all var(--transition-base);
            box-shadow: var(--shadow-xl);
            border: none;
            cursor: pointer;
            min-width: 280px;
            position: relative;
            overflow: hidden;
        }

        .btn-submit::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
        }

        .btn-submit:hover::before {
            left: 100%;
        }

        .btn-submit:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-2xl);
            background: linear-gradient(135deg, var(--success-600), var(--success-700));
        }

        .btn-submit:active {
            transform: translateY(-1px);
        }

        .btn-submit:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
            box-shadow: var(--shadow-md);
        }

        .btn-submit:disabled:hover {
            transform: none;
            box-shadow: var(--shadow-md);
        }

        .btn-submit i {
            font-size: 1.25rem;
        }

        /* Responsive Design */
        @media (max-width: 1024px) {
            .container {
                padding: var(--space-2xl) var(--space-lg);
            }

            .train-details {
                grid-template-columns: 1fr;
            }

            .passenger-grid {
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            }
        }

        @media (max-width: 768px) {
            .navbar-content {
                padding: 0 var(--space-lg);
            }

            .container {
                padding: var(--space-xl) var(--space-md);
            }

            .header-section {
                padding: var(--space-2xl) var(--space-lg);
                margin-bottom: var(--space-xl);
            }

            .train-info-card,
            .form-container {
                padding: var(--space-xl);
            }

            .trip-type-container {
                grid-template-columns: 1fr;
            }

            .passenger-grid {
                grid-template-columns: 1fr;
            }

            .btn-submit {
                min-width: 240px;
                padding: var(--space-lg) var(--space-2xl);
            }
        }

        @media (max-width: 480px) {
            .navbar-brand {
                font-size: 1.5rem;
            }

            .header-section h1 {
                font-size: 2rem;
                flex-direction: column;
                gap: var(--space-sm);
            }

            .detail-item {
                flex-direction: column;
                text-align: center;
                gap: var(--space-sm);
            }

            .fare-line {
                font-size: 0.9rem;
            }
        }

        /* Enhanced Animations */
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

        @keyframes slideInRight {
            from {
                opacity: 0;
                transform: translateX(30px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @keyframes pulse {
            0%, 100% {
                transform: scale(1);
            }
            50% {
                transform: scale(1.05);
            }
        }

        .train-info-card,
        .form-container {
            animation: fadeInUp 0.8s ease-out;
        }

        .form-section {
            animation: slideInRight 0.6s ease-out;
        }

        .form-section:nth-child(2) {
            animation-delay: 0.1s;
        }

        .form-section:nth-child(3) {
            animation-delay: 0.2s;
        }

        .btn-submit:not(:disabled):hover {
            animation: pulse 2s infinite;
        }

        /* Loading state */
        .loading {
            opacity: 0.8;
            pointer-events: none;
        }

        /* Custom scrollbar */
        ::-webkit-scrollbar {
            width: 8px;
        }

        ::-webkit-scrollbar-track {
            background: var(--secondary-100);
        }

        ::-webkit-scrollbar-thumb {
            background: var(--primary-400);
            border-radius: var(--radius-md);
        }

        ::-webkit-scrollbar-thumb:hover {
            background: var(--primary-500);
        }

        /* Focus visible for accessibility */
        button:focus-visible,
        input:focus-visible,
        select:focus-visible,
        a:focus-visible {
            outline: 2px solid var(--primary-500);
            outline-offset: 2px;
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar">
        <div class="navbar-content">
            <a href="index.html" class="navbar-brand">
                <i class="fas fa-train"></i>
                IRCTC
            </a>
            <a href="javascript:history.back()" class="back-btn">
                <i class="fas fa-arrow-left"></i>
                Back to Search
            </a>
        </div>
    </nav>

    <div class="container">
        <!-- Header Section -->
        <div class="header-section">
            <h1>
                <i class="fas fa-ticket-alt"></i>
                Reserve Your Train
            </h1>
            <p>Complete your booking by selecting trip type, passengers and confirming details</p>
        </div>

        <% if (missingDetails) { %>
            <!-- Error Message for Missing Details -->
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-triangle"></i>
                <div>
                    <strong>Missing Train Details</strong><br>
                    Required train information is missing. Please search for trains again.
                </div>
            </div>
            
            <div class="submit-container">
                <a href="index.html" class="back-btn">
                    <i class="fas fa-search"></i>
                    Back to Search
                </a>
            </div>
        <% } else { %>
            <!-- Display Error/Success Messages -->
            <% if (errorMessage != null) { %>
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-triangle"></i>
                    <div>
                        <strong>Reservation Error</strong><br>
                        <%= errorMessage %>
                    </div>
                </div>
            <% } %>
            
            <% if (successMessage != null) { %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i>
                    <div>
                        <strong>Success!</strong><br>
                        <%= successMessage %>
                    </div>
                </div>
            <% } %>

            <!-- Selected Train Information -->
            <div class="train-info-card">
                <div class="train-info-header">
                    <i class="fas fa-info-circle"></i>
                    <h3>Selected Train Details</h3>
                </div>
                <div class="train-details">
                    <div class="detail-item">
                        <i class="fas fa-train"></i>
                        <div class="detail-content">
                            <div class="detail-label">Train</div>
                            <div class="detail-value"><%= trainName %></div>
                        </div>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-route"></i>
                        <div class="detail-content">
                            <div class="detail-label">Route</div>
                            <div class="detail-value"><%= origin %> → <%= destination %></div>
                        </div>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-calendar"></i>
                        <div class="detail-content">
                            <div class="detail-label">Travel Date</div>
                            <div class="detail-value"><%= travelDate %></div>
                        </div>
                    </div>
                    <% if (departure != null) { %>
                    <div class="detail-item">
                        <i class="fas fa-clock"></i>
                        <div class="detail-content">
                            <div class="detail-label">Departure</div>
                            <div class="detail-value"><%= departure %></div>
                        </div>
                    </div>
                    <% } %>
                    <% if (arrival != null) { %>
                    <div class="detail-item">
                        <i class="fas fa-clock"></i>
                        <div class="detail-content">
                            <div class="detail-label">Arrival</div>
                            <div class="detail-value"><%= arrival %></div>
                        </div>
                    </div>
                    <% } %>
                    <div class="detail-item">
                        <i class="fas fa-dollar-sign"></i>
                        <div class="detail-content">
                            <div class="detail-label">Base Fare</div>
                            <div class="detail-value fare-highlight">$<%= fare %></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Reservation Form -->
            <div class="form-container">
                <form action="ReserveServlet" method="POST" id="reservationForm">
                    <!-- Hidden fields to preserve train details -->
                    <input type="hidden" name="trainName" value="<%= trainName %>">
                    <input type="hidden" name="origin" value="<%= origin %>">
                    <input type="hidden" name="destination" value="<%= destination %>">
                    <input type="hidden" name="fare" value="<%= fare %>">
                    <% if (departure != null) { %>
                    <input type="hidden" name="departure" value="<%= departure %>">
                    <% } %>
                    <% if (arrival != null) { %>
                    <input type="hidden" name="arrival" value="<%= arrival %>">
                    <% } %>
                    <input type="hidden" name="travelDate" value="<%= travelDate %>">

                    <!-- Trip Type Selection -->
                    <div class="form-section">
                        <h4>
                            <i class="fas fa-route"></i>
                            Trip Type
                        </h4>
                        <div class="trip-type-container">
                            <div class="trip-option">
                                <input type="radio" name="tripType" value="ONE_WAY" id="oneWay" checked>
                                <label for="oneWay">
                                    <i class="fas fa-arrow-right"></i>
                                    One Way
                                </label>
                            </div>
                            <div class="trip-option">
                                <input type="radio" name="tripType" value="ROUND_TRIP" id="roundTrip">
                                <label for="roundTrip">
                                    <i class="fas fa-exchange-alt"></i>
                                    Round Trip
                                </label>
                            </div>
                        </div>
                        
                        <!-- Return Date (hidden by default) -->
                        <div class="return-date-container" id="returnDateContainer">
                            <div class="input-group">
                                <label for="returnDate">
                                    <i class="fas fa-calendar-alt"></i>
                                    Return Date
                                </label>
                                <input type="date" name="returnDate" id="returnDate" min="<%= travelDate %>">
                            </div>
                        </div>
                    </div>

                    <!-- Passenger Details -->
                    <div class="form-section">
                        <h4>
                            <i class="fas fa-users"></i>
                            Passenger Details
                        </h4>
                        <div class="passenger-grid">
                            <div class="input-group">
                                <label for="adults">
                                    <i class="fas fa-user"></i>
                                    Adults (12+ years)
                                </label>
                                <input type="number" name="adults" id="adults" min="1" max="10" value="1" required>
                            </div>
                            <div class="input-group">
                                <label for="children">
                                    <i class="fas fa-child"></i>
                                    Children (5-11 years) <small>(50% off)</small>
                                </label>
                                <input type="number" name="children" id="children" min="0" max="10" value="0">
                            </div>
                            <div class="input-group">
                                <label for="seniors">
                                    <i class="fas fa-user-plus"></i>
                                    Seniors (60+ years) <small>(40% off)</small>
                                </label>
                                <input type="number" name="seniors" id="seniors" min="0" max="10" value="0">
                            </div>
                            <div class="input-group">
                                <label for="disabled">
                                    <i class="fas fa-wheelchair"></i>
                                    Disabled <small>(75% off)</small>
                                </label>
                                <input type="number" name="disabled" id="disabled" min="0" max="10" value="0">
                            </div>
                        </div>

                        <!-- Fare Summary -->
                        <div class="fare-summary" id="fareSummary">
                            <h5>
                                <i class="fas fa-calculator"></i>
                                Fare Breakdown
                            </h5>
                            <div class="fare-breakdown" id="fareBreakdown">
                                <!-- Fare details will be populated by JavaScript -->
                            </div>
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <div class="submit-container">
                        <button type="submit" class="btn-submit" id="submitBtn">
                            <i class="fas fa-ticket-alt"></i>
                            Complete Reservation
                        </button>
                    </div>
                </form>
            </div>
        <% } %>
    </div>

 <script>
        // Trip type handling
        const oneWayRadio = document.getElementById('oneWay');
        const roundTripRadio = document.getElementById('roundTrip');
        const returnDateContainer = document.getElementById('returnDateContainer');
        const returnDateInput = document.getElementById('returnDate');

        function toggleReturnDate() {
            if (roundTripRadio.checked) {
                returnDateContainer.classList.add('show');
                returnDateInput.required = true;
            } else {
                returnDateContainer.classList.remove('show');
                returnDateInput.required = false;
                returnDateInput.value = '';
            }
            calculateFare();
        }

        oneWayRadio.addEventListener('change', toggleReturnDate);
        roundTripRadio.addEventListener('change', toggleReturnDate);

        // FIXED: Robust fare parsing
        console.log('=== FARE DEBUG INFO ===');
        
        let baseFare = 0;
        const jspFareOutput = '<%= fare %>';
        console.log('JSP fare output:', jspFareOutput);
        
        // Parse the fare with multiple fallbacks
        if (jspFareOutput && jspFareOutput !== 'null' && jspFareOutput.trim() !== '') {
            baseFare = parseFloat(jspFareOutput.toString());
        }
        
        // Fallback to URL parameter
        if (!baseFare || isNaN(baseFare)) {
            const urlParams = new URLSearchParams(window.location.search);
            const urlFare = urlParams.get('fare');
            if (urlFare) {
                baseFare = parseFloat(urlFare);
            }
        }
        
        // Fallback to DOM extraction
        if (!baseFare || isNaN(baseFare)) {
            const fareElements = document.querySelectorAll('.fare-highlight');
            if (fareElements.length > 0) {
                const displayedFare = fareElements[0].textContent.replace(/[^0-9.]/g, '');
                baseFare = parseFloat(displayedFare);
            }
        }
        
        console.log('Final base fare:', baseFare);
        console.log('=== END FARE DEBUG ===');
        
        const passengerInputs = ['adults', 'children', 'seniors', 'disabled'];
        
        function calculateFare() {
            console.log('Starting fare calculation...');
            
            // Get passenger counts with explicit parsing
            const adults = parseInt(document.getElementById('adults').value) || 0;
            const children = parseInt(document.getElementById('children').value) || 0;
            const seniors = parseInt(document.getElementById('seniors').value) || 0;
            const disabled = parseInt(document.getElementById('disabled').value) || 0;
            
            console.log('Passengers:', {adults, children, seniors, disabled});
            console.log('Base fare for calculation:', baseFare);
            
            // Calculate individual fares with explicit conversion
            const adultFare = Number(adults * baseFare);
            const childFare = Number(children * baseFare * 0.5);
            const seniorFare = Number(seniors * baseFare * 0.6);
            const disabledFare = Number(disabled * baseFare * 0.25);
            
            console.log('Calculated fares:', {adultFare, childFare, seniorFare, disabledFare});
            
            const subtotal = Number(adultFare + childFare + seniorFare + disabledFare);
            const isRoundTrip = roundTripRadio.checked;
            const total = Number(isRoundTrip ? subtotal * 2 : subtotal);
            
            console.log('Subtotal:', subtotal, 'Total:', total);
            
            // FIXED: Build HTML string using explicit concatenation
            const fareBreakdown = document.getElementById('fareBreakdown');
            let breakdown = '';
            
            // Format numbers safely
            const formatMoney = (amount) => {
                return '$' + Number(amount).toFixed(2);
            };
            
            const formatBaseFare = formatMoney(baseFare);
            
            if (adults > 0) {
                breakdown += '<div class="fare-line">' +
                    '<span>Adults (' + adults + ' × ' + formatBaseFare + ')</span>' +
                    '<span>' + formatMoney(adultFare) + '</span>' +
                    '</div>';
            }
            
            if (children > 0) {
                breakdown += '<div class="fare-line">' +
                    '<span>Children (' + children + ' × ' + formatBaseFare + ' × 50%)</span>' +
                    '<span>' + formatMoney(childFare) + '</span>' +
                    '</div>';
            }
            
            if (seniors > 0) {
                breakdown += '<div class="fare-line">' +
                    '<span>Seniors (' + seniors + ' × ' + formatBaseFare + ' × 60%)</span>' +
                    '<span>' + formatMoney(seniorFare) + '</span>' +
                    '</div>';
            }
            
            if (disabled > 0) {
                breakdown += '<div class="fare-line">' +
                    '<span>Disabled (' + disabled + ' × ' + formatBaseFare + ' × 25%)</span>' +
                    '<span>' + formatMoney(disabledFare) + '</span>' +
                    '</div>';
            }
            
            if (subtotal > 0) {
                breakdown += '<div class="fare-line">' +
                    '<span>Subtotal</span>' +
                    '<span>' + formatMoney(subtotal) + '</span>' +
                    '</div>';
                
                if (isRoundTrip) {
                    breakdown += '<div class="fare-line">' +
                        '<span>Round Trip (× 2)</span>' +
                        '<span>' + formatMoney(subtotal) + '</span>' +
                        '</div>';
                }
                
                breakdown += '<div class="fare-line fare-total">' +
                    '<span>Total Amount</span>' +
                    '<span>' + formatMoney(total) + '</span>' +
                    '</div>';
            } else {
                breakdown = '<div class="fare-line">' +
                    '<span>Select passengers to see fare breakdown</span>' +
                    '<span>$0.00</span>' +
                    '</div>';
            }
            
            console.log('Final breakdown HTML:', breakdown);
            fareBreakdown.innerHTML = breakdown;
            
            // Enable/disable submit button
            const submitBtn = document.getElementById('submitBtn');
            const totalPassengers = adults + children + seniors + disabled;
            submitBtn.disabled = totalPassengers === 0;
        }

        // Add event listeners to passenger inputs
        passengerInputs.forEach(inputId => {
            const input = document.getElementById(inputId);
            if (input) {
                input.addEventListener('input', calculateFare);
                input.addEventListener('change', calculateFare);
            }
        });

        // Form submission handling
        document.getElementById('reservationForm').addEventListener('submit', function(e) {
            const totalPassengers = passengerInputs.reduce((sum, inputId) => {
                const input = document.getElementById(inputId);
                return sum + (input ? (parseInt(input.value) || 0) : 0);
            }, 0);
            
            if (totalPassengers === 0) {
                e.preventDefault();
                alert('Please select at least one passenger.');
                return;
            }
            
            if (roundTripRadio.checked && (!returnDateInput.value || returnDateInput.value.trim() === '')) {
                e.preventDefault();
                alert('Please select a return date for round trip.');
                return;
            }
            
            // Show loading state
            const submitBtn = document.getElementById('submitBtn');
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
            
            // Add loading class to form
            document.querySelector('.form-container').classList.add('loading');
        });

        // Initialize fare calculation
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Page loaded, initializing fare calculation...');
            calculateFare();
        });

        // Call immediately as well
        setTimeout(calculateFare, 100);

        // Enhanced input animations
        document.querySelectorAll('input, select').forEach(input => {
            input.addEventListener('focus', function() {
                this.parentElement.style.transform = 'translateY(-2px)';
            });
            
            input.addEventListener('blur', function() {
                this.parentElement.style.transform = 'translateY(0)';
            });
        });

        // Add ripple effect
        document.querySelectorAll('.btn-submit, .trip-option label').forEach(button => {
            button.addEventListener('click', function(e) {
                let ripple = document.createElement('span');
                let rect = this.getBoundingClientRect();
                let size = Math.max(rect.width, rect.height);
                let x = e.clientX - rect.left - size / 2;
                let y = e.clientY - rect.top - size / 2;
                
                ripple.style.width = ripple.style.height = size + 'px';
                ripple.style.left = x + 'px';
                ripple.style.top = y + 'px';
                ripple.classList.add('ripple');
                
                this.appendChild(ripple);
                
                setTimeout(() => {
                    if (ripple.parentNode) {
                        ripple.parentNode.removeChild(ripple);
                    }
                }, 600);
            });
        });

        // Add CSS for ripple effect
        const style = document.createElement('style');
        style.textContent = `
            .ripple {
                position: absolute;
                border-radius: 50%;
                background: rgba(255, 255, 255, 0.3);
                transform: scale(0);
                animation: ripple 0.6s linear;
                pointer-events: none;
            }
            
            @keyframes ripple {
                to {
                    transform: scale(4);
                    opacity: 0;
                }
            }
        `;
        document.head.appendChild(style);
    </script>
</body>
</html>