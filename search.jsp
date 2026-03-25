<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Search Train Schedules - IRCTC</title>
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
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 50%, #f1f5f9 100%);
            min-height: 100vh;
            line-height: 1.6;
            color: #334155;
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
                radial-gradient(circle at 20% 50%, rgba(120, 119, 198, 0.03) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(255, 255, 255, 0.05) 0%, transparent 50%),
                radial-gradient(circle at 40% 80%, rgba(120, 119, 198, 0.02) 0%, transparent 50%);
            z-index: -1;
            animation: backgroundShift 20s ease-in-out infinite;
        }

        @keyframes backgroundShift {
            0%, 100% { transform: translateX(0) translateY(0); }
            33% { transform: translateX(-5px) translateY(-10px); }
            66% { transform: translateX(5px) translateY(5px); }
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

        .navbar.scrolled {
            background: rgba(255, 255, 255, 0.98);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
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
            position: relative;
        }

        .navbar-brand::after {
            content: '';
            position: absolute;
            bottom: -4px;
            left: 0;
            width: 0;
            height: 2px;
            background: linear-gradient(90deg, #64748b, #94a3b8);
            transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .navbar-brand:hover {
            color: #64748b;
            transform: translateY(-1px);
        }

        .navbar-brand:hover::after {
            width: 100%;
        }

        .logo-icon {
            width: 48px;
            height: 48px;
            background: linear-gradient(135deg, #64748b, #94a3b8);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 16px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            transition: all 0.3s ease;
        }

        .logo-icon i {
            font-size: 1.5rem;
            color: white;
        }

        .navbar-brand:hover .logo-icon {
            transform: scale(1.05) rotate(2deg);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }

        .navbar-brand span {
            font-weight: 800;
            font-size: 1.5rem;
            color: #1e293b;
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
            color: #64748b;
            border: 2px solid #e2e8f0;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
        }

        .nav-btn-secondary:hover {
            background: #64748b;
            color: white;
            border-color: #64748b;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(100, 116, 139, 0.2);
        }

        .nav-btn-primary {
            background: linear-gradient(135deg, #64748b, #94a3b8);
            color: white;
            border: 2px solid transparent;
            box-shadow: 0 4px 14px rgba(100, 116, 139, 0.3);
        }

        .nav-btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(100, 116, 139, 0.4);
            color: white;
        }

        /* Welcome Section */
        .welcome-section {
            margin-top: 100px;
            padding: 0 2rem;
            margin-bottom: 40px;
        }

        .welcome-banner {
            max-width: 1000px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 32px 40px;
            text-align: center;
            border: 1px solid rgba(226, 232, 240, 0.8);
            box-shadow: 0 12px 32px rgba(0, 0, 0, 0.06);
            animation: fadeInUp 0.8s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .welcome-title {
            font-size: 2.2rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 12px;
            background: linear-gradient(135deg, #1e293b, #64748b);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .welcome-subtitle {
            font-size: 1.1rem;
            color: #64748b;
            font-weight: 500;
        }

        /* Main Content */
        .main-content {
            padding: 0 2rem;
        }

        .container-main {
            max-width: 1000px;
            margin: 0 auto;
            padding: 0;
        }

        /* Search Form Section */
        .search-section {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            padding: 40px;
            border: 1px solid rgba(226, 232, 240, 0.8);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.08);
            animation: fadeInUp 0.8s cubic-bezier(0.4, 0, 0.2, 1) 0.3s both;
        }

        .search-title {
            font-size: 2rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 32px;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
        }

        .search-title i {
            color: #64748b;
        }

        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 24px;
            margin-bottom: 24px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .form-label {
            font-weight: 600;
            color: #475569;
            margin-bottom: 8px;
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: color 0.3s ease;
        }

        .form-label i {
            color: #64748b;
            transition: all 0.3s ease;
        }

        .form-group:hover .form-label {
            color: #64748b;
        }

        .form-group:hover .form-label i {
            transform: scale(1.1);
        }

        .form-control, .form-select {
            padding: 16px;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            font-size: 1rem;
            background: white;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            color: #334155;
            font-weight: 500;
        }

        .form-control:focus, .form-select:focus {
            outline: none;
            border-color: #64748b;
            box-shadow: 0 0 0 4px rgba(100, 116, 139, 0.1);
            transform: translateY(-1px);
            background: rgba(255, 255, 255, 1);
        }

        .form-control:hover, .form-select:hover {
            border-color: #94a3b8;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }

        .form-control.valid, .form-select.valid {
            border-color: #10b981;
            background: rgba(16, 185, 129, 0.02);
        }

        .form-control.invalid, .form-select.invalid {
            border-color: #ef4444;
            background: rgba(239, 68, 68, 0.02);
        }

        /* Enhanced Select Styling */
        .form-select {
            appearance: none;
            -webkit-appearance: none;
            -moz-appearance: none;
            cursor: pointer;
        }

        .form-select option {
            background: white;
            color: #334155;
            padding: 12px 16px;
            font-size: 1rem;
            font-weight: 500;
            line-height: 1.5;
            border: none;
        }

        .form-select option:first-child {
            color: #94a3b8;
            font-style: italic;
            font-weight: 400;
        }

        .form-select option:hover {
            background: #f8fafc;
        }

        .form-select option:checked {
            background: #64748b;
            color: white;
        }

        /* Date Input Enhancement */
        .form-control[type="date"] {
            cursor: pointer;
        }

        .form-control[type="date"]::-webkit-calendar-picker-indicator {
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath fill='%2364748b' d='M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zM4 9h12v7H4V9z'/%3e%3c/svg%3e");
            background-size: 20px;
            cursor: pointer;
            opacity: 0.7;
            transition: opacity 0.3s ease;
            margin-left: 8px;
        }

        .form-control[type="date"]:hover::-webkit-calendar-picker-indicator {
            opacity: 1;
        }

        .sort-section {
            background: rgba(248, 250, 252, 0.8);
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 32px;
            border: 1px solid rgba(226, 232, 240, 0.6);
        }

        .search-button {
            background: linear-gradient(135deg, #64748b, #94a3b8);
            color: white;
            padding: 18px 40px;
            border: none;
            border-radius: 16px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            margin: 0 auto;
            box-shadow: 0 8px 25px rgba(100, 116, 139, 0.3);
            position: relative;
            overflow: hidden;
            min-width: 200px;
        }

        .search-button::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .search-button:hover::before {
            left: 100%;
        }

        .search-button:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 35px rgba(100, 116, 139, 0.4);
        }

        .search-button:active {
            transform: translateY(-1px);
        }

        .search-button:disabled {
            opacity: 0.7;
            cursor: not-allowed;
            transform: none;
        }

        /* Loading animation */
        .search-button.loading {
            pointer-events: none;
        }

        .search-button.loading .search-icon {
            animation: spin 1s ease-in-out infinite;
        }

        .search-button.loading::after {
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

            .nav-buttons {
                width: 100%;
                justify-content: center;
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

            .welcome-section {
                margin-top: 140px;
                padding: 0 1rem;
            }

            .main-content {
                padding: 0 1rem;
            }

            .welcome-banner {
                padding: 24px;
            }

            .welcome-title {
                font-size: 1.8rem;
            }

            .search-section {
                padding: 24px;
            }

            .form-row {
                grid-template-columns: 1fr;
                gap: 16px;
            }

            .search-title {
                font-size: 1.5rem;
            }

            .search-button {
                padding: 16px 32px;
                font-size: 1rem;
            }
        }

        @media (max-width: 480px) {
            .welcome-title {
                font-size: 1.6rem;
            }

            .nav-btn {
                padding: 10px 20px;
                font-size: 0.9rem;
            }

            .navbar-brand {
                flex-direction: column;
                gap: 4px;
            }

            .logo-icon {
                margin-right: 0;
                margin-bottom: 4px;
            }
        }

        /* Scroll indicator */
        .scroll-indicator {
            position: fixed;
            top: 0;
            left: 0;
            width: 0%;
            height: 3px;
            background: linear-gradient(90deg, #64748b, #94a3b8);
            z-index: 1001;
            transition: width 0.3s ease;
        }

        /* Focus states for accessibility */
        .search-button:focus-visible,
        .form-control:focus-visible,
        .form-select:focus-visible {
            outline: 2px solid #64748b;
            outline-offset: 2px;
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
                <a href="profile.jsp" class="nav-btn nav-btn-secondary">
                    <i class="fas fa-user"></i>
                    Profile
                </a>
                <a href="logout" class="nav-btn nav-btn-primary">
                    <i class="fas fa-sign-out-alt"></i>
                    Logout
                </a>
            </div>
        </div>
    </nav>

    <!-- Welcome Section -->
    <div class="welcome-section">
        <div class="welcome-banner">
            <h1 class="welcome-title">
                <i class="fas fa-search"></i>
                Train Search
            </h1>
            <p class="welcome-subtitle">
                Welcome back, <%= username %>! Find and book your perfect train journey with ease.
            </p>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <div class="container-main">
            <!-- Search Form Section -->
            <section class="search-section">
                <h2 class="search-title">
                    <i class="fas fa-route"></i>
                    Plan Your Journey
                </h2>
                
                <form action="search" method="get" id="searchForm">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="origin" class="form-label">
                                <i class="fas fa-map-marker-alt"></i>
                                Origin Station
                            </label>
                            <select class="form-select" name="origin" id="origin" required>
                                <option value="">Select Origin Station</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="destination" class="form-label">
                                <i class="fas fa-flag-checkered"></i>
                                Destination Station
                            </label>
                            <select class="form-select" name="destination" id="destination" required>
                                <option value="">Select Destination Station</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="travelDate" class="form-label">
                                <i class="fas fa-calendar-alt"></i>
                                Date of Travel
                            </label>
                            <input type="date" class="form-control" name="travelDate" id="travelDate" required>
                        </div>
                    </div>

                    <!-- Sorting Option -->
                    <div class="sort-section">
                        <div class="form-group">
                            <label for="sortBy" class="form-label">
                                <i class="fas fa-sort"></i>
                                Sort Results By
                            </label>
                            <select class="form-select" name="sortBy" id="sortBy">
                                <option value="arrival">Arrival Time</option>
                                <option value="departure">Departure Time</option>
                                <option value="fare">Fare (Lowest First)</option>
                            </select>
                        </div>
                    </div>

                    <button type="submit" class="search-button" id="searchBtn">
                        <i class="fas fa-search search-icon"></i>
                        <span>Search Trains</span>
                    </button>
                </form>
            </section>
        </div>
    </div>

    <!-- Enhanced JavaScript -->
    <script>
        // Navbar scroll effect
        window.addEventListener('scroll', function() {
            const navbar = document.getElementById('navbar');
            const scrollIndicator = document.querySelector('.scroll-indicator');
            
            if (window.scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
            
            // Update scroll indicator
            const scrolled = (window.scrollY / (document.documentElement.scrollHeight - window.innerHeight)) * 100;
            scrollIndicator.style.width = scrolled + '%';
        });

        // Set minimum date to today
        document.getElementById('travelDate').min = new Date().toISOString().split('T')[0];

        // Form submission with loading state
        document.getElementById('searchForm').addEventListener('submit', function(e) {
            let isValid = true;
            const inputs = this.querySelectorAll('input[required], select[required]');
            
            // Validate all required fields
            inputs.forEach(input => {
                if (input.value.trim() === '') {
                    input.classList.add('invalid');
                    isValid = false;
                } else {
                    input.classList.remove('invalid');
                    input.classList.add('valid');
                }
            });
            
            if (isValid) {
                const searchBtn = document.getElementById('searchBtn');
                searchBtn.classList.add('loading');
                searchBtn.innerHTML = '<i class="fas fa-spinner search-icon"></i><span>Searching...</span>';
            } else {
                e.preventDefault();
                // Scroll to first invalid field
                const firstInvalid = this.querySelector('.invalid');
                if (firstInvalid) {
                    firstInvalid.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    firstInvalid.focus();
                }
            }
        });

        // Enhanced dropdown loading with fallback data
        window.onload = function () {
            const originSelect = document.getElementById('origin');
            const destinationSelect = document.getElementById('destination');
            
            // Fallback station data
            const fallbackStations = [
                'New Delhi', 'Mumbai Central', 'Chennai Central', 'Kolkata', 'Bangalore City',
                'Hyderabad', 'Pune', 'Ahmedabad', 'Surat', 'Kanpur Central', 'Jaipur',
                'Lucknow', 'Nagpur', 'Indore', 'Thane', 'Bhopal', 'Visakhapatnam',
                'Patna', 'Vadodara', 'Ghaziabad', 'Ludhiana', 'Agra', 'Nashik',
                'Varanasi', 'Amritsar', 'Allahabad', 'Ranchi', 'Howrah', 'Coimbatore'
            ].sort();
            
            // Add loading options
            originSelect.innerHTML = '<option value="">Loading stations...</option>';
            destinationSelect.innerHTML = '<option value="">Loading stations...</option>';
            
            fetch('stationData')
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    console.log('Station data loaded successfully:', data);
                    
                    // Clear loading options
                    originSelect.innerHTML = '<option value="">Select Origin Station</option>';
                    destinationSelect.innerHTML = '<option value="">Select Destination Station</option>';
                    
                    // Populate origins
                    if (data.origins && data.origins.length > 0) {
                        data.origins.forEach((origin, index) => {
                            setTimeout(() => {
                                const option = document.createElement('option');
                                option.value = origin;
                                option.text = origin;
                                originSelect.appendChild(option);
                            }, index * 20);
                        });
                    }

                    // Populate destinations
                    if (data.destinations && data.destinations.length > 0) {
                        data.destinations.forEach((destination, index) => {
                            setTimeout(() => {
                                const option = document.createElement('option');
                                option.value = destination;
                                option.text = destination;
                                destinationSelect.appendChild(option);
                            }, index * 20);
                        });
                    }
                })
                .catch(error => {
                    console.error('Failed to load station data from server:', error);
                    console.log('Using fallback station data');
                    
                    // Use fallback data
                    setTimeout(() => {
                        originSelect.innerHTML = '<option value="">Select Origin Station</option>';
                        destinationSelect.innerHTML = '<option value="">Select Destination Station</option>';
                        
                        fallbackStations.forEach((station, index) => {
                            setTimeout(() => {
                                // Add to origin
                                const originOption = document.createElement('option');
                                originOption.value = station;
                                originOption.text = station;
                                originSelect.appendChild(originOption);
                                
                                // Add to destination
                                const destOption = document.createElement('option');
                                destOption.value = station;
                                destOption.text = station;
                                destinationSelect.appendChild(destOption);
                            }, index * 30);
                        });
                    }, 500);
                });
        };

        // Enhanced form interactions
        document.querySelectorAll('.form-control, .form-select').forEach(element => {
            element.addEventListener('focus', function() {
                this.parentElement.style.transform = 'scale(1.02)';
                this.parentElement.style.transition = 'transform 0.3s cubic-bezier(0.4, 0, 0.2, 1)';
                this.parentElement.style.zIndex = '10';
            });
            
            element.addEventListener('blur', function() {
                this.parentElement.style.transform = 'scale(1)';
                this.parentElement.style.zIndex = '1';
                
                // Validation feedback
                if (this.value.trim() !== '') {
                    this.classList.add('valid');
                    this.classList.remove('invalid');
                } else if (this.required) {
                    this.classList.remove('valid');
                }
            });
            
            // Real-time validation
            element.addEventListener('input', function() {
                this.classList.remove('invalid');
                if (this.value.trim() !== '') {
                    this.classList.add('valid');
                } else {
                    this.classList.remove('valid');
                }
            });
        });

        // Smooth scrolling for internal links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
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