<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Reservation Details - IRCTC</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            /* Enhanced Color System */
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
            --warning-400: #fbbf24;
            --warning-500: #f59e0b;
            --warning-600: #d97706;
            
            --error-50: #fef2f2;
            --error-100: #fee2e2;
            --error-500: #ef4444;
            --error-600: #dc2626;
            --error-700: #b91c1c;
            
            /* Shadows */
            --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
            --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
            --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
            --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
            --shadow-2xl: 0 25px 50px -12px rgb(0 0 0 / 0.25);
            
            /* Glass morphism */
            --glass-bg: rgba(255, 255, 255, 0.25);
            --glass-border: rgba(255, 255, 255, 0.18);
            
            /* Border radius */
            --radius-sm: 0.375rem;
            --radius-md: 0.5rem;
            --radius-lg: 0.75rem;
            --radius-xl: 1rem;
            --radius-2xl: 1.5rem;
            --radius-3xl: 2rem;
            
            /* Spacing */
            --space-xs: 0.25rem;
            --space-sm: 0.5rem;
            --space-md: 1rem;
            --space-lg: 1.5rem;
            --space-xl: 2rem;
            --space-2xl: 3rem;
            --space-3xl: 4rem;
            
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
            padding: var(--space-xl) 0;
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

        .container { 
            max-width: 1000px; 
            margin: 0 auto; 
            background: var(--glass-bg);
            backdrop-filter: blur(24px) saturate(180%);
            border: 1px solid var(--glass-border);
            border-radius: var(--radius-3xl);
            overflow: hidden;
            box-shadow: var(--shadow-2xl);
            animation: slideUp 0.8s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(40px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .header { 
            background: linear-gradient(135deg, var(--primary-600) 0%, var(--primary-700) 100%);
            color: white; 
            padding: var(--space-3xl) var(--space-2xl);
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="25" cy="25" r="1" fill="white" opacity="0.1"/><circle cx="75" cy="75" r="1" fill="white" opacity="0.1"/><circle cx="50" cy="10" r="0.5" fill="white" opacity="0.1"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
            pointer-events: none;
        }

        .header h1 {
            font-size: clamp(2rem, 4vw, 2.75rem);
            font-weight: 800;
            margin-bottom: var(--space-sm);
            text-shadow: 0 2px 4px rgba(0,0,0,0.3);
            position: relative;
            z-index: 1;
            letter-spacing: -0.02em;
        }

        .header.cancelled {
            background: linear-gradient(135deg, var(--error-600) 0%, var(--error-700) 100%);
        }

        .header .subtitle {
            font-size: 1.125rem;
            opacity: 0.9;
            font-weight: 500;
            position: relative;
            z-index: 1;
            max-width: 600px;
            margin: 0 auto;
        }

        .content-wrapper {
            padding: var(--space-2xl);
        }

        /* Trip Type Banner */
        .trip-type-banner {
            background: linear-gradient(135deg, var(--success-50), var(--primary-50));
            border: 2px solid var(--success-200);
            border-radius: var(--radius-xl);
            padding: var(--space-lg) var(--space-xl);
            margin-bottom: var(--space-xl);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: var(--space-md);
            box-shadow: var(--shadow-md);
        }

        .trip-type-banner.round-trip {
            background: linear-gradient(135deg, var(--primary-50), var(--secondary-50));
            border-color: var(--primary-200);
        }

        .trip-type-icon {
            width: 48px;
            height: 48px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--success-500), var(--success-600));
            color: white;
            border-radius: var(--radius-lg);
            font-size: 1.25rem;
            box-shadow: var(--shadow-md);
        }

        .trip-type-banner.round-trip .trip-type-icon {
            background: linear-gradient(135deg, var(--primary-500), var(--primary-600));
        }

        .trip-type-info h3 {
            font-size: 1.25rem;
            font-weight: 800;
            color: var(--success-700);
            margin-bottom: var(--space-xs);
        }

        .trip-type-banner.round-trip .trip-type-info h3 {
            color: var(--primary-700);
        }

        .trip-type-info p {
            color: var(--secondary-600);
            font-weight: 500;
        }

        /* Journey Cards for Round Trip */
        .journey-container {
            display: grid;
            gap: var(--space-xl);
            margin-bottom: var(--space-xl);
        }

        .journey-card {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(12px);
            border: 1px solid var(--secondary-200);
            border-radius: var(--radius-2xl);
            padding: var(--space-xl);
            box-shadow: var(--shadow-lg);
            transition: all var(--transition-base);
            position: relative;
            overflow: hidden;
        }

        .journey-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--primary-500), var(--success-500));
            border-radius: var(--radius-2xl) var(--radius-2xl) 0 0;
        }

        .journey-card.return::before {
            background: linear-gradient(90deg, var(--success-500), var(--primary-500));
        }

        .journey-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-2xl);
        }

        .journey-header {
            display: flex;
            align-items: center;
            gap: var(--space-md);
            margin-bottom: var(--space-lg);
            padding-bottom: var(--space-md);
            border-bottom: 2px solid var(--secondary-100);
        }

        .journey-icon {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--primary-500), var(--primary-600));
            color: white;
            border-radius: var(--radius-lg);
            font-size: 1.1rem;
            box-shadow: var(--shadow-md);
        }

        .journey-card.return .journey-icon {
            background: linear-gradient(135deg, var(--success-500), var(--success-600));
        }

        .journey-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--secondary-800);
        }

        .details-section { 
            margin-bottom: var(--space-2xl);
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(12px);
            border-radius: var(--radius-2xl);
            padding: var(--space-xl);
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--secondary-200);
            transition: all var(--transition-base);
            position: relative;
            overflow: hidden;
        }

        .details-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--primary-500), var(--success-500));
            border-radius: var(--radius-2xl) var(--radius-2xl) 0 0;
        }

        .details-section.cancelled::before {
            background: linear-gradient(90deg, var(--error-500), var(--error-600));
        }

        .details-section:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-xl);
        }

        .details-section h3 { 
            font-size: 1.375rem;
            font-weight: 700;
            color: var(--secondary-800);
            margin-bottom: var(--space-lg);
            display: flex;
            align-items: center;
            gap: var(--space-md);
        }

        .details-section h3 i {
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

        .detail-row { 
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: var(--space-lg) 0;
            border-bottom: 1px solid var(--secondary-100);
            transition: all var(--transition-fast);
        }

        .detail-row:last-child {
            border-bottom: none;
        }

        .detail-row:hover {
            background-color: rgba(59, 130, 246, 0.02);
            border-radius: var(--radius-lg);
            margin: 0 calc(-1 * var(--space-sm));
            padding-left: var(--space-lg);
            padding-right: var(--space-lg);
        }

        .detail-label { 
            font-weight: 600;
            color: var(--secondary-600);
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: var(--space-sm);
        }

        .detail-label i {
            width: 20px;
            color: var(--primary-500);
        }

        .detail-value { 
            color: var(--secondary-800);
            font-weight: 600;
            font-size: 1rem;
            text-align: right;
            max-width: 60%;
        }

        /* Enhanced Status and Value Styling */
        .reservation-id {
            background: linear-gradient(135deg, var(--primary-600), var(--success-600));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-size: 1.125rem;
            font-weight: 800;
        }

        .fare-amount {
            background: linear-gradient(135deg, var(--success-600), var(--success-700));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-size: 1.25rem;
            font-weight: 800;
        }

        .train-name {
            color: var(--primary-700);
            font-weight: 700;
            font-size: 1.125rem;
        }

        .route {
            color: var(--success-600);
            font-weight: 600;
        }

        .datetime {
            color: var(--error-600);
            font-weight: 600;
            font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
        }

        /* Status Badge */
        .status-badge {
            padding: var(--space-sm) var(--space-lg);
            border-radius: var(--radius-xl);
            font-size: 0.875rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            border: 1px solid transparent;
        }

        .status-active {
            background: linear-gradient(135deg, var(--success-100), var(--success-200));
            color: var(--success-800);
            border-color: var(--success-300);
        }

        .status-cancelled {
            background: linear-gradient(135deg, var(--error-100), var(--error-200));
            color: var(--error-800);
            border-color: var(--error-300);
        }

        /* Fare Breakdown Section */
        .fare-breakdown-section {
            background: linear-gradient(135deg, var(--success-50), var(--primary-50));
            border: 2px solid var(--success-200);
            border-radius: var(--radius-xl);
            padding: var(--space-xl);
            margin-top: var(--space-xl);
        }

        .fare-breakdown-title {
            font-size: 1.25rem;
            font-weight: 800;
            color: var(--secondary-800);
            margin-bottom: var(--space-lg);
            display: flex;
            align-items: center;
            gap: var(--space-md);
        }

        .fare-breakdown-title i {
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

        .fare-line {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: var(--space-md) 0;
            font-weight: 600;
            color: var(--secondary-700);
        }

        .fare-line.total {
            border-top: 2px solid var(--success-200);
            margin-top: var(--space-md);
            padding-top: var(--space-lg);
            font-size: 1.125rem;
            font-weight: 800;
            color: var(--success-700);
        }

        /* Buttons */
        .back-btn { 
            background: linear-gradient(135deg, var(--primary-500), var(--primary-600));
            color: white; 
            padding: var(--space-lg) var(--space-2xl);
            text-decoration: none; 
            border-radius: var(--radius-xl);
            display: inline-flex;
            align-items: center;
            gap: var(--space-sm);
            font-weight: 600;
            font-size: 0.95rem;
            transition: all var(--transition-base);
            box-shadow: var(--shadow-lg);
            border: none;
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .back-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
        }

        .back-btn:hover::before {
            left: 100%;
        }

        .back-btn:hover { 
            transform: translateY(-2px);
            box-shadow: var(--shadow-xl);
            text-decoration: none;
            color: white;
        }

        .back-btn:active {
            transform: translateY(0);
        }

        .error, .success { 
            padding: var(--space-lg) var(--space-xl);
            border-radius: var(--radius-xl);
            margin: var(--space-xl) 0;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: var(--space-md);
            backdrop-filter: blur(12px);
            border: 1px solid transparent;
        }

        .error {
            background: rgba(239, 68, 68, 0.1);
            color: var(--error-700);
            border-color: var(--error-200);
        }

        .success {
            background: rgba(16, 185, 129, 0.1);
            color: var(--success-700);
            border-color: var(--success-200);
        }

        .stops-container {
            max-width: 100%;
            overflow-x: auto;
        }

        .stops-list {
            display: flex;
            gap: var(--space-sm);
            flex-wrap: wrap;
        }

        .stop-item {
            background: linear-gradient(135deg, var(--secondary-100), var(--secondary-200));
            padding: var(--space-sm) var(--space-md);
            border-radius: var(--radius-lg);
            font-size: 0.875rem;
            color: var(--secondary-700);
            font-weight: 600;
            white-space: nowrap;
            box-shadow: var(--shadow-sm);
        }

        .passenger-summary {
            display: flex;
            gap: var(--space-md);
            flex-wrap: wrap;
        }

        .passenger-item {
            background: linear-gradient(135deg, var(--primary-100), var(--primary-200));
            padding: var(--space-sm) var(--space-lg);
            border-radius: var(--radius-lg);
            color: var(--primary-800);
            font-weight: 600;
            font-size: 0.9rem;
            box-shadow: var(--shadow-sm);
        }

        .action-buttons {
            display: flex;
            gap: var(--space-lg);
            margin-top: var(--space-2xl);
            flex-wrap: wrap;
            justify-content: center;
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.9);
            color: var(--primary-600);
            border: 2px solid var(--primary-200);
            padding: var(--space-md) var(--space-xl);
            border-radius: var(--radius-xl);
            text-decoration: none;
            font-weight: 600;
            transition: all var(--transition-base);
            display: inline-flex;
            align-items: center;
            gap: var(--space-sm);
            backdrop-filter: blur(8px);
        }

        .btn-secondary:hover {
            background: var(--primary-50);
            border-color: var(--primary-300);
            color: var(--primary-700);
            transform: translateY(-1px);
            box-shadow: var(--shadow-md);
            text-decoration: none;
        }

        .btn-cancel {
            border-color: var(--error-300);
            color: var(--error-600);
        }

        .btn-cancel:hover {
            background: var(--error-50);
            border-color: var(--error-400);
            color: var(--error-700);
        }

        /* Responsive Design */
        @media (max-width: 1024px) {
            .journey-container {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .container {
                margin: var(--space-sm);
                border-radius: var(--radius-2xl);
            }
            
            .header {
                padding: var(--space-2xl) var(--space-lg);
            }
            
            .content-wrapper {
                padding: var(--space-xl) var(--space-lg);
            }
            
            .detail-row {
                flex-direction: column;
                align-items: flex-start;
                gap: var(--space-sm);
            }
            
            .detail-value {
                text-align: left;
                max-width: 100%;
            }
            
            .action-buttons {
                flex-direction: column;
            }

            .trip-type-banner {
                flex-direction: column;
                text-align: center;
            }
        }

        /* Enhanced Animations */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .details-section,
        .journey-card {
            animation: fadeInUp 0.6s ease-out;
        }

        .details-section:nth-child(even) {
            animation-delay: 0.1s;
        }

        .journey-card:nth-child(even) {
            animation-delay: 0.15s;
        }
    </style>
</head>
<body>
    <div class="container">
        <%
            String reservationId = request.getParameter("id");
            
            if (reservationId == null || reservationId.trim().isEmpty()) {
        %>
                <div class="header">
                    <h1><i class="fas fa-train"></i> IRCTC Reservation Details</h1>
                    <p class="subtitle">Your journey details and booking information</p>
                </div>
                <div class="content-wrapper">
                    <div class="error">
                        <i class="fas fa-exclamation-triangle"></i> 
                        No reservation ID provided!
                    </div>
                    <div class="action-buttons">
                        <a href="welcome.jsp" class="back-btn">
                            <i class="fas fa-arrow-left"></i> Back to Dashboard
                        </a>
                    </div>
                </div>
        <%
                return;
            }

            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            
            // Data structures to hold reservation information
            Map<String, Object> mainReservation = new HashMap<>();
            List<Map<String, Object>> journeys = new ArrayList<>();
            boolean isRoundTrip = false;
            String tripType = "ONE_WAY";
            double totalFareAmount = 0.0;
            
            try {
                conn = DBConnection.getConnection();
                
                // First, get the main reservation to determine trip type
                String mainQuery = "SELECT r.Reservation_Number, r.Username, r.Date, r.Passenger, r.Total_Fare, r.Transit_line_name, " +
                                  "COALESCE(r.status, 'ACTIVE') as status, COALESCE(r.trip_type, 'ONE_WAY') as trip_type, " +
                                  "COALESCE(r.journey_type, 'OUT') as journey_type, " +
                                  "t.Origin, t.Destination, t.Departure_datetime, t.Arrival_datetime, t.Stops " +
                                  "FROM reservation_data r " +
                                  "LEFT JOIN train_schedule_data t ON r.Transit_line_name = t.Transit_line_name " +
                                  "WHERE r.Reservation_Number = ?";
                
                ps = conn.prepareStatement(mainQuery);
                ps.setInt(1, Integer.parseInt(reservationId));
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    // Store main reservation details
                    mainReservation.put("id", rs.getInt("Reservation_Number"));
                    mainReservation.put("username", rs.getString("Username"));
                    mainReservation.put("status", rs.getString("status"));
                    mainReservation.put("passengers", rs.getString("Passenger"));
                    mainReservation.put("trainName", rs.getString("Transit_line_name"));
                    
                    tripType = rs.getString("trip_type");
                    isRoundTrip = "ROUND_TRIP".equals(tripType);
                    
                    // For round trips, get all related journeys
                    if (isRoundTrip) {
                        rs.close();
                        ps.close();
                        
                        // Get both outbound and inbound journeys for round trip
                        String roundTripQuery = "SELECT r.Reservation_Number, r.Username, r.Date, r.Passenger, r.Total_Fare, r.Transit_line_name, " +
                                              "COALESCE(r.status, 'ACTIVE') as status, COALESCE(r.trip_type, 'ONE_WAY') as trip_type, " +
                                              "COALESCE(r.journey_type, 'OUT') as journey_type, " +
                                              "t.Origin, t.Destination, t.Departure_datetime, t.Arrival_datetime, t.Stops " +
                                              "FROM reservation_data r " +
                                              "LEFT JOIN train_schedule_data t ON r.Transit_line_name = t.Transit_line_name " +
                                              "WHERE r.Transit_line_name = ? AND r.Username = ? AND r.trip_type = 'ROUND_TRIP' " +
                                              "ORDER BY r.journey_type, r.Date";
                        
                        ps = conn.prepareStatement(roundTripQuery);
                        ps.setString(1, mainReservation.get("trainName").toString());
                        ps.setString(2, mainReservation.get("username").toString());
                        rs = ps.executeQuery();
                        
                        while (rs.next()) {
                            Map<String, Object> journey = new HashMap<>();
                            journey.put("id", rs.getInt("Reservation_Number"));
                            journey.put("date", rs.getDate("Date"));
                            journey.put("fare", rs.getDouble("Total_Fare"));
                            journey.put("journeyType", rs.getString("journey_type"));
                            journey.put("origin", rs.getString("Origin"));
                            journey.put("destination", rs.getString("Destination"));
                            journey.put("departure", rs.getString("Departure_datetime"));
                            journey.put("arrival", rs.getString("Arrival_datetime"));
                            journey.put("stops", rs.getString("Stops"));
                            journeys.add(journey);
                            totalFareAmount += rs.getDouble("Total_Fare");
                        }
                    } else {
                        // For one-way trips, add the single journey
                        Map<String, Object> journey = new HashMap<>();
                        journey.put("id", rs.getInt("Reservation_Number"));
                        journey.put("date", rs.getDate("Date"));
                        journey.put("fare", rs.getDouble("Total_Fare"));
                        journey.put("journeyType", "OUT");
                        journey.put("origin", rs.getString("Origin"));
                        journey.put("destination", rs.getString("Destination"));
                        journey.put("departure", rs.getString("Departure_datetime"));
                        journey.put("arrival", rs.getString("Arrival_datetime"));
                        journey.put("stops", rs.getString("Stops"));
                        journeys.add(journey);
                        totalFareAmount = rs.getDouble("Total_Fare");
                    }
                    
                    boolean isCancelled = "CANCELLED".equals(mainReservation.get("status"));
        %>
                    <div class="header <%= isCancelled ? "cancelled" : "" %>">
                        <h1><i class="fas fa-train"></i> IRCTC Reservation Details</h1>
                        <p class="subtitle">
                            <%= isCancelled ? "Cancelled Reservation" : "Your journey details and booking information" %>
                        </p>
                    </div>

                    <div class="content-wrapper">
                        <div class="<%= isCancelled ? "error" : "success" %>">
                            <i class="fas fa-<%= isCancelled ? "times-circle" : "check-circle" %>"></i>
                            <%= isCancelled ? "This reservation has been cancelled." : "Reservation found successfully! Your booking is confirmed." %>
                        </div>

                        <!-- Trip Type Banner -->
                        <div class="trip-type-banner <%= isRoundTrip ? "round-trip" : "" %>">
                            <div class="trip-type-icon">
                                <i class="fas fa-<%= isRoundTrip ? "exchange-alt" : "arrow-right" %>"></i>
                            </div>
                            <div class="trip-type-info">
                                <h3><%= isRoundTrip ? "Round Trip Journey" : "One Way Journey" %></h3>
                                <p><%= isRoundTrip ? "Outbound and return journeys included" : "Single direction journey" %></p>
                            </div>
                        </div>

                        <!-- Journey Details -->
                        <% if (isRoundTrip) { %>
                            <div class="journey-container">
                                <% for (Map<String, Object> journey : journeys) { 
                                    boolean isReturn = "IN".equals(journey.get("journeyType"));
                                %>
                                <div class="journey-card <%= isReturn ? "return" : "" %>">
                                    <div class="journey-header">
                                        <div class="journey-icon">
                                            <i class="fas fa-<%= isReturn ? "plane-arrival" : "plane-departure" %>"></i>
                                        </div>
                                        <h4 class="journey-title"><%= isReturn ? "Return Journey" : "Outbound Journey" %></h4>
                                    </div>
                                    
                                    <div class="detail-row">
                                        <span class="detail-label"><i class="fas fa-calendar"></i> Travel Date:</span>
                                        <span class="detail-value datetime"><%= journey.get("date") %></span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label"><i class="fas fa-map-marker-alt"></i> From:</span>
                                        <span class="detail-value route"><%= journey.get("origin") != null ? journey.get("origin") : "N/A" %></span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label"><i class="fas fa-flag-checkered"></i> To:</span>
                                        <span class="detail-value route"><%= journey.get("destination") != null ? journey.get("destination") : "N/A" %></span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label"><i class="fas fa-clock"></i> Departure:</span>
                                        <span class="detail-value datetime"><%= journey.get("departure") != null ? journey.get("departure") : "N/A" %></span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label"><i class="fas fa-clock"></i> Arrival:</span>
                                        <span class="detail-value datetime"><%= journey.get("arrival") != null ? journey.get("arrival") : "N/A" %></span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label"><i class="fas fa-dollar-sign"></i> Journey Fare:</span>
                                        <span class="detail-value fare-amount">$<%= String.format("%.2f", (Double)journey.get("fare")) %></span>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                        <% } %>

                        <!-- Main Reservation Information -->
                        <div class="details-section <%= isCancelled ? "cancelled" : "" %>">
                            <h3><i class="fas fa-receipt"></i> Reservation Information</h3>
                            <div class="detail-row">
                                <span class="detail-label"><i class="fas fa-hashtag"></i> Reservation ID:</span>
                                <span class="detail-value reservation-id"><%= mainReservation.get("id") %></span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label"><i class="fas fa-info-circle"></i> Status:</span>
                                <span class="detail-value">
                                    <span class="status-badge <%= isCancelled ? "status-cancelled" : "status-active" %>">
                                        <%= mainReservation.get("status") %>
                                    </span>
                                </span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label"><i class="fas fa-user"></i> Passenger Name:</span>
                                <span class="detail-value"><%= mainReservation.get("username") %></span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label"><i class="fas fa-route"></i> Trip Type:</span>
                                <span class="detail-value">
                                    <span style="padding: 6px 12px; border-radius: 12px; font-size: 0.9rem; font-weight: 600; background: <%= isRoundTrip ? "#dbeafe; color: #1e40af" : "#dcfce7; color: #166534" %>;">
                                        <%= isRoundTrip ? "Round Trip" : "One Way" %>
                                    </span>
                                </span>
                            </div>
                        </div>

                        <!-- Train Information -->
                        <div class="details-section">
                            <h3><i class="fas fa-train"></i> Train Information</h3>
                            <div class="detail-row">
                                <span class="detail-label"><i class="fas fa-tag"></i> Train Name:</span>
                                <span class="detail-value train-name"><%= mainReservation.get("trainName") %></span>
                            </div>
                            <% if (!isRoundTrip && !journeys.isEmpty()) { 
                                Map<String, Object> singleJourney = journeys.get(0);
                            %>
                            <div class="detail-row">
                                <span class="detail-label"><i class="fas fa-calendar-alt"></i> Travel Date:</span>
                                <span class="detail-value datetime"><%= singleJourney.get("date") %></span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label"><i class="fas fa-map-marker-alt"></i> From:</span>
                                <span class="detail-value route"><%= singleJourney.get("origin") != null ? singleJourney.get("origin") : "N/A" %></span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label"><i class="fas fa-flag-checkered"></i> To:</span>
                                <span class="detail-value route"><%= singleJourney.get("destination") != null ? singleJourney.get("destination") : "N/A" %></span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label"><i class="fas fa-clock"></i> Departure:</span>
                                <span class="detail-value datetime"><%= singleJourney.get("departure") != null ? singleJourney.get("departure") : "N/A" %></span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label"><i class="fas fa-clock"></i> Arrival:</span>
                                <span class="detail-value datetime"><%= singleJourney.get("arrival") != null ? singleJourney.get("arrival") : "N/A" %></span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label"><i class="fas fa-route"></i> Stops:</span>
                                <span class="detail-value">
                                    <div class="stops-container">
                                        <%
                                            String stops = (String) singleJourney.get("stops");
                                            if (stops != null && !stops.trim().isEmpty()) {
                                                String[] stopArray = stops.split("\\|");
                                        %>
                                            <div class="stops-list">
                                                <% for (String stop : stopArray) { %>
                                                    <span class="stop-item"><%= stop.trim() %></span>
                                                <% } %>
                                            </div>
                                        <% } else { %>
                                            <span style="color: #6b7280;">No stops information</span>
                                        <% } %>
                                    </div>
                                </span>
                            </div>
                            <% } %>
                        </div>

                        <!-- Passenger Details -->
                        <div class="details-section">
                            <h3><i class="fas fa-users"></i> Passenger Details</h3>
                            <div class="detail-row">
                                <span class="detail-label"><i class="fas fa-ticket-alt"></i> Passengers:</span>
                                <span class="detail-value">
                                    <div class="passenger-summary">
                                        <%
                                            String passengerString = (String) mainReservation.get("passengers");
                                            if (passengerString != null) {
                                                String[] parts = passengerString.split(", ");
                                                boolean hasPassengers = false;
                                                
                                                for (String part : parts) {
                                                    String[] keyValue = part.split(": ");
                                                    if (keyValue.length == 2) {
                                                        String category = keyValue[0].trim();
                                                        int count = Integer.parseInt(keyValue[1].trim());
                                                        
                                                        if (count > 0) {
                                                            hasPassengers = true;
                                                            out.print("<span class='passenger-item'>" + category + ": " + count + "</span>");
                                                        }
                                                    }
                                                }
                                                
                                                if (!hasPassengers) {
                                                    out.print("<span style='color: #6b7280; font-style: italic;'>No passengers recorded</span>");
                                                }
                                            } else {
                                                out.print("<span style='color: #6b7280; font-style: italic;'>No passenger information available</span>");
                                            }
                                        %>
                                    </div>
                                </span>
                            </div>

                            <!-- Enhanced Fare Breakdown -->
                            <div class="fare-breakdown-section">
                                <div class="fare-breakdown-title">
                                    <i class="fas fa-calculator"></i>
                                    Fare Breakdown
                                </div>
                                
                                <% if (isRoundTrip) { %>
                                    <% for (int i = 0; i < journeys.size(); i++) { 
                                        Map<String, Object> journey = journeys.get(i);
                                        boolean isReturn = "IN".equals(journey.get("journeyType"));
                                    %>
                                    <div class="fare-line">
                                        <span><%= isReturn ? "Return Journey" : "Outbound Journey" %> Fare</span>
                                        <span>$<%= String.format("%.2f", (Double)journey.get("fare")) %></span>
                                    </div>
                                    <% } %>
                                    <div class="fare-line total">
                                        <span>Total Amount (Round Trip)</span>
                                        <span>$<%= String.format("%.2f", totalFareAmount) %></span>
                                    </div>
                                <% } else { %>
                                    <div class="fare-line">
                                        <span>One Way Journey Fare</span>
                                        <span>$<%= String.format("%.2f", totalFareAmount) %></span>
                                    </div>
                                    <div class="fare-line total">
                                        <span>Total Amount</span>
                                        <span>$<%= String.format("%.2f", totalFareAmount) %></span>
                                    </div>
                                <% } %>
                            </div>
                        </div>

                        <div class="action-buttons">
                            <a href="welcome.jsp" class="back-btn">
                                <i class="fas fa-arrow-left"></i> Back to Dashboard
                            </a>
                            <a href="index.html" class="btn-secondary">
                                <i class="fas fa-search"></i> New Search
                            </a>
                            <%
                                // Only show cancel button for active future reservations
                                if (!isCancelled && !journeys.isEmpty()) {
                                    java.util.Date travelDate = (java.util.Date) journeys.get(0).get("date");
                                    java.util.Date today = new java.util.Date();
                                    
                                    if (travelDate.after(today)) {
                            %>
                                        <a href="cancel.jsp" class="btn-secondary btn-cancel">
                                            <i class="fas fa-times"></i> Cancel Reservation
                                        </a>
                            <%
                                    }
                                }
                            %>
                        </div>
                    </div>
        <%
                } else {
                    // Reservation not found
        %>
                    <div class="header">
                        <h1><i class="fas fa-train"></i> IRCTC Reservation Details</h1>
                        <p class="subtitle">Reservation not found</p>
                    </div>
                    <div class="content-wrapper">
                        <div class="error">
                            <i class="fas fa-exclamation-triangle"></i> 
                            Reservation not found for ID: <%= reservationId %>
                        </div>
                        <p style="color: #6b7280; text-align: center; margin: 20px 0;">
                            Please check if the reservation ID is correct or if the reservation exists in the database.
                        </p>
                        <div class="action-buttons">
                            <a href="welcome.jsp" class="back-btn">
                                <i class="fas fa-arrow-left"></i> Back to Dashboard
                            </a>
                        </div>
                    </div>
        <%
                }
                
            } catch (SQLException e) {
                // Database error
        %>
                <div class="header">
                    <h1><i class="fas fa-train"></i> IRCTC Reservation Details</h1>
                    <p class="subtitle">Database Error</p>
                </div>
                <div class="content-wrapper">
                    <div class="error">
                        <i class="fas fa-database"></i> 
                        Database Error: <%= e.getMessage() %>
                    </div>
                    <p style="color: #6b7280; text-align: center; margin: 20px 0;">
                        There was an issue connecting to the database. Please try again later.
                    </p>
                    <div class="action-buttons">
                        <a href="welcome.jsp" class="back-btn">
                            <i class="fas fa-arrow-left"></i> Back to Dashboard
                        </a>
                    </div>
                </div>
        <%
                e.printStackTrace();
            } catch (NumberFormatException e) {
                // Invalid reservation ID format
        %>
                <div class="header">
                    <h1><i class="fas fa-train"></i> IRCTC Reservation Details</h1>
                    <p class="subtitle">Invalid Reservation ID</p>
                </div>
                <div class="content-wrapper">
                    <div class="error">
                        <i class="fas fa-hashtag"></i> 
                        Invalid reservation ID format!
                    </div>
                    <p style="color: #6b7280; text-align: center; margin: 20px 0;">
                        Please provide a valid numeric reservation ID.
                    </p>
                    <div class="action-buttons">
                        <a href="welcome.jsp" class="back-btn">
                            <i class="fas fa-arrow-left"></i> Back to Dashboard
                        </a>
                    </div>
                </div>
        <%
            } catch (Exception e) {
                // General error
        %>
                <div class="header">
                    <h1><i class="fas fa-train"></i> IRCTC Reservation Details</h1>
                    <p class="subtitle">System Error</p>
                </div>
                <div class="content-wrapper">
                    <div class="error">
                        <i class="fas fa-exclamation-circle"></i> 
                        Unexpected Error: <%= e.getMessage() %>
                    </div>
                    <div class="action-buttons">
                        <a href="welcome.jsp" class="back-btn">
                            <i class="fas fa-arrow-left"></i> Back to Dashboard
                        </a>
                    </div>
                </div>
        <%
                e.printStackTrace();
            } finally {
                // Clean up resources
                try {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        %>
    </div>
</body>
</html>