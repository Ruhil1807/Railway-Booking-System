<%@ page import="java.sql.*, java.io.PrintWriter, java.util.*" %>
<%@ page import="util.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>

<%
    String user = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    
    if (user == null || !"admin".equals(role)) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    // Get filter parameters
    String filterType = request.getParameter("filterType");
    String filterValue = request.getParameter("filterValue");
    String sortBy = request.getParameter("sortBy");
    String sortOrder = request.getParameter("sortOrder");
    
    if (filterType == null) filterType = "all";
    if (sortBy == null) sortBy = "Date";
    if (sortOrder == null) sortOrder = "DESC";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservation Lists - IRCTC Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 50%, #f1f5f9 100%);
            min-height: 100vh;
            color: #334155;
        }

        .navbar {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(226, 232, 240, 0.8);
            padding: 1rem 0;
            position: sticky;
            top: 0;
            z-index: 1000;
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
            color: #1e293b;
            font-weight: 800;
            font-size: 1.5rem;
            text-decoration: none;
        }

        .navbar-brand i {
            font-size: 2rem;
            margin-right: 12px;
            background: linear-gradient(135deg, #64748b, #94a3b8);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .back-btn {
            background: #64748b;
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }

        .back-btn:hover {
            background: #475569;
            transform: translateY(-2px);
            color: white;
            text-decoration: none;
        }

        .main-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 40px 2rem;
        }

        .page-header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 32px;
            margin-bottom: 32px;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .page-title {
            font-size: 2.5rem;
            font-weight: 800;
            background: linear-gradient(135deg, #1e293b, #64748b);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 8px;
        }

        .page-subtitle {
            color: #64748b;
            font-size: 1.1rem;
            font-weight: 500;
        }

        .filter-section {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 32px;
            margin-bottom: 32px;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            align-items: end;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-label {
            font-weight: 600;
            color: #374151;
        }

        .form-select, .form-input {
            padding: 12px 16px;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 1rem;
            background: white;
        }

        .form-select:focus, .form-input:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }

        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }

        .btn-primary {
            background: linear-gradient(135deg, #3b82f6, #1d4ed8);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(59, 130, 246, 0.3);
        }

        .btn-secondary {
            background: #6b7280;
            color: white;
        }

        .btn-secondary:hover {
            background: #4b5563;
            transform: translateY(-2px);
        }

        .stats-bar {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 24px 32px;
            margin-bottom: 32px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }

        .stat-item {
            text-align: center;
        }

        .stat-value {
            font-size: 2rem;
            font-weight: 800;
            color: #1e293b;
        }

        .stat-label {
            color: #64748b;
            font-weight: 600;
            font-size: 0.9rem;
        }

        .reservations-table {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 32px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.1);
        }

        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 16px;
        }

        .card-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: #1e293b;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .table th, .table td {
            padding: 16px;
            text-align: left;
            border-bottom: 1px solid #e5e7eb;
        }

        .table th {
            background: #f8fafc;
            font-weight: 600;
            color: #374151;
            cursor: pointer;
            user-select: none;
            position: relative;
        }

        .table th:hover {
            background: #f1f5f9;
        }

        .table tr:hover {
            background: #f8fafc;
        }

        .status-badge {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .status-active {
            background: #dcfce7;
            color: #166534;
        }

        .status-cancelled {
            background: #fef2f2;
            color: #dc2626;
        }

        .no-data {
            text-align: center;
            padding: 60px 20px;
            color: #64748b;
        }

        .no-data i {
            font-size: 4rem;
            margin-bottom: 20px;
            opacity: 0.3;
        }

        @media (max-width: 768px) {
            .filter-grid {
                grid-template-columns: 1fr;
            }
            .main-container {
                padding: 20px 1rem;
            }
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar">
        <div class="navbar-content">
            <a href="admin.jsp" class="navbar-brand">
                <i class="fas fa-train"></i>
                IRCTC Admin
            </a>
            <a href="admin.jsp" class="back-btn">
                <i class="fas fa-arrow-left"></i>
                Back to Dashboard
            </a>
        </div>
    </nav>

    <!-- Main Container -->
    <div class="main-container">
        <!-- Page Header -->
        <div class="page-header">
            <h1 class="page-title">Reservation Lists</h1>
            <p class="page-subtitle">Advanced reservation filtering by transit line and customer name</p>
        </div>

        <!-- Filter Section -->
        <div class="filter-section">
            <form class="filter-grid" method="GET" action="reservation-lists.jsp">
                <div class="form-group">
                    <label class="form-label">Filter Type</label>
                    <select name="filterType" class="form-select" onchange="toggleFilterInput()">
                        <option value="all" <%= "all".equals(filterType) ? "selected" : "" %>>All Reservations</option>
                        <option value="transit_line" <%= "transit_line".equals(filterType) ? "selected" : "" %>>By Transit Line</option>
                        <option value="customer" <%= "customer".equals(filterType) ? "selected" : "" %>>By Customer Name</option>
                        <option value="status" <%= "status".equals(filterType) ? "selected" : "" %>>By Status</option>
                        <option value="date" <%= "date".equals(filterType) ? "selected" : "" %>>By Date</option>
                    </select>
                </div>
                
                <div class="form-group" id="filterValueGroup" style="<%= "all".equals(filterType) ? "display:none;" : "" %>">
                    <label class="form-label">Filter Value</label>
                    <input type="text" name="filterValue" class="form-input" 
                           value="<%= filterValue != null ? filterValue : "" %>" 
                           placeholder="Enter filter value">
                </div>
                
                <div class="form-group">
                    <label class="form-label">Sort By</label>
                    <select name="sortBy" class="form-select">
                        <option value="Date" <%= "Date".equals(sortBy) ? "selected" : "" %>>Date</option>
                        <option value="Total_Fare" <%= "Total_Fare".equals(sortBy) ? "selected" : "" %>>Fare</option>
                        <option value="Username" <%= "Username".equals(sortBy) ? "selected" : "" %>>Customer</option>
                        <option value="Transit_line_name" <%= "Transit_line_name".equals(sortBy) ? "selected" : "" %>>Transit Line</option>
                        <option value="Reservation_Number" <%= "Reservation_Number".equals(sortBy) ? "selected" : "" %>>Reservation ID</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Order</label>
                    <select name="sortOrder" class="form-select">
                        <option value="ASC" <%= "ASC".equals(sortOrder) ? "selected" : "" %>>Ascending</option>
                        <option value="DESC" <%= "DESC".equals(sortOrder) ? "selected" : "" %>>Descending</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-filter"></i>
                        Apply Filters
                    </button>
                </div>
            </form>
        </div>

        <%
            // Build SQL query based on filters - CORRECTED for your database structure
            StringBuilder queryBuilder = new StringBuilder();
            queryBuilder.append("SELECT r.*, t.Origin, t.Destination FROM reservation_data r ");
            queryBuilder.append("LEFT JOIN train_schedule_data t ON r.Transit_line_name = t.Transit_line_name ");
            queryBuilder.append("WHERE 1=1");
            
            if (!"all".equals(filterType) && filterValue != null && !filterValue.trim().isEmpty()) {
                switch(filterType) {
                    case "transit_line":
                        queryBuilder.append(" AND (t.Origin LIKE ? OR t.Destination LIKE ? OR r.Transit_line_name LIKE ?)");
                        break;
                    case "customer":
                        queryBuilder.append(" AND r.Username LIKE ?");
                        break;
                    case "status":
                        queryBuilder.append(" AND COALESCE(r.status, 'ACTIVE') LIKE ?");
                        break;
                    case "date":
                        queryBuilder.append(" AND DATE(r.Date) = ?");
                        break;
                }
            }
            
            queryBuilder.append(" ORDER BY r.").append(sortBy).append(" ").append(sortOrder);
            
            // Get statistics
            int totalReservations = 0;
            int activeReservations = 0;
            int cancelledReservations = 0;
            double totalRevenue = 0.0;
            int filteredCount = 0;
            
            List<Map<String, Object>> reservations = new ArrayList<>();
            
            try {
                Connection con = DBConnection.getConnection();
                
                // Get statistics - CORRECTED
                PreparedStatement statsPs = con.prepareStatement("SELECT COUNT(*) as total, SUM(Total_Fare) as revenue FROM reservation_data");
                ResultSet statsRs = statsPs.executeQuery();
                if (statsRs.next()) {
                    totalReservations = statsRs.getInt("total");
                    totalRevenue = statsRs.getDouble("revenue");
                }
                
                PreparedStatement activePs = con.prepareStatement("SELECT COUNT(*) as active FROM reservation_data WHERE COALESCE(status, 'ACTIVE') = 'ACTIVE'");
                ResultSet activeRs = activePs.executeQuery();
                if (activeRs.next()) {
                    activeReservations = activeRs.getInt("active");
                }
                
                cancelledReservations = totalReservations - activeReservations;
                
                // Get filtered reservations
                PreparedStatement ps = con.prepareStatement(queryBuilder.toString());
                int paramIndex = 1;
                
                if (!"all".equals(filterType) && filterValue != null && !filterValue.trim().isEmpty()) {
                    switch(filterType) {
                        case "transit_line":
                            ps.setString(paramIndex++, "%" + filterValue + "%");
                            ps.setString(paramIndex++, "%" + filterValue + "%");
                            ps.setString(paramIndex++, "%" + filterValue + "%");
                            break;
                        case "customer":
                        case "status":
                            ps.setString(paramIndex++, "%" + filterValue + "%");
                            break;
                        case "date":
                            ps.setString(paramIndex++, filterValue);
                            break;
                    }
                }
                
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String, Object> reservation = new HashMap<>();
                    reservation.put("id", rs.getInt("Reservation_Number"));
                    reservation.put("username", rs.getString("Username"));
                    reservation.put("date", rs.getDate("Date"));
                    reservation.put("transitLine", rs.getString("Transit_line_name"));
                    reservation.put("origin", rs.getString("Origin"));
                    reservation.put("destination", rs.getString("Destination"));
                    reservation.put("fare", rs.getDouble("Total_Fare"));
                    reservation.put("passenger", rs.getString("Passenger"));
                    String status = rs.getString("status");
                    reservation.put("status", status != null ? status : "ACTIVE");
                    reservations.add(reservation);
                }
                
                filteredCount = reservations.size();
                
                rs.close();
                ps.close();
                statsRs.close();
                statsPs.close();
                activeRs.close();
                activePs.close();
                con.close();
                
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>

        <!-- Statistics Bar -->
        <div class="stats-bar">
            <div class="stat-item">
                <div class="stat-value"><%= totalReservations %></div>
                <div class="stat-label">Total Reservations</div>
            </div>
            <div class="stat-item">
                <div class="stat-value"><%= activeReservations %></div>
                <div class="stat-label">Active</div>
            </div>
            <div class="stat-item">
                <div class="stat-value"><%= cancelledReservations %></div>
                <div class="stat-label">Cancelled</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">$<%= String.format("%.0f", totalRevenue) %></div>
                <div class="stat-label">Total Revenue</div>
            </div>
            <div class="stat-item">
                <div class="stat-value"><%= filteredCount %></div>
                <div class="stat-label">Filtered Results</div>
            </div>
        </div>

        <!-- Reservations Table -->
        <div class="reservations-table">
            <div class="table-header">
                <h2 class="card-title">
                    <i class="fas fa-list-alt"></i>
                    Reservation Details
                    <% if (!"all".equals(filterType) && filterValue != null && !filterValue.trim().isEmpty()) { %>
                        <span style="font-size: 1rem; color: #64748b; font-weight: 500;">
                            (Filtered by <%= filterType.replace("_", " ") %>: <%= filterValue %>)
                        </span>
                    <% } %>
                </h2>
                <button onclick="exportToCSV()" class="btn btn-secondary">
                    <i class="fas fa-download"></i>
                    Export CSV
                </button>
            </div>
            
            <% if (!reservations.isEmpty()) { %>
                <table class="table" id="reservationsTable">
                    <thead>
                        <tr>
                            <th>Reservation ID</th>
                            <th>Customer</th>
                            <th>Date</th>
                            <th>Route</th>
                            <th>Transit Line</th>
                            <th>Passenger</th>
                            <th>Fare</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> reservation : reservations) { %>
                        <tr>
                            <td><strong><%= reservation.get("id") %></strong></td>
                            <td><%= reservation.get("username") %></td>
                            <td><%= reservation.get("date") %></td>
                            <td>
                                <% 
                                    String origin = (String) reservation.get("origin");
                                    String destination = (String) reservation.get("destination");
                                    if (origin != null && destination != null) {
                                %>
                                    <%= origin %> → <%= destination %>
                                <% } else { %>
                                    <span style="color: #64748b; font-style: italic;">Route Info N/A</span>
                                <% } %>
                            </td>
                            <td><%= reservation.get("transitLine") %></td>
                            <td><%= reservation.get("passenger") %></td>
                            <td>$<%= String.format("%.2f", (Double)reservation.get("fare")) %></td>
                            <td>
                                <span class="status-badge <%= "ACTIVE".equals(reservation.get("status")) ? "status-active" : "status-cancelled" %>">
                                    <%= reservation.get("status") %>
                                </span>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <div class="no-data">
                    <i class="fas fa-search"></i>
                    <h3>No Reservations Found</h3>
                    <% if (!"all".equals(filterType) && filterValue != null && !filterValue.trim().isEmpty()) { %>
                        <p>No reservations match your filter criteria: <%= filterType.replace("_", " ") %> = "<%= filterValue %>"</p>
                        <a href="reservation-lists.jsp" class="btn btn-primary" style="margin-top: 16px;">
                            <i class="fas fa-times"></i>
                            Clear Filters
                        </a>
                    <% } else { %>
                        <p>No reservations found in the system.</p>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>

    <script>
        function toggleFilterInput() {
            const filterType = document.querySelector('select[name="filterType"]').value;
            const filterValueGroup = document.getElementById('filterValueGroup');
            
            if (filterType === 'all') {
                filterValueGroup.style.display = 'none';
            } else {
                filterValueGroup.style.display = 'block';
                
                const input = document.querySelector('input[name="filterValue"]');
                switch(filterType) {
                    case 'transit_line':
                        input.placeholder = 'Enter transit line name, origin, or destination';
                        input.type = 'text';
                        break;
                    case 'customer':
                        input.placeholder = 'Enter customer username';
                        input.type = 'text';
                        break;
                    case 'status':
                        input.placeholder = 'ACTIVE or CANCELLED';
                        input.type = 'text';
                        break;
                    case 'date':
                        input.type = 'date';
                        input.placeholder = '';
                        break;
                    default:
                        input.placeholder = 'Enter filter value';
                        input.type = 'text';
                }
            }
        }

        function exportToCSV() {
            const table = document.getElementById('reservationsTable');
            if (!table) return;
            
            let csv = [];
            const rows = table.querySelectorAll('tr');
            
            for (let i = 0; i < rows.length; i++) {
                const row = rows[i];
                const cols = row.querySelectorAll('td, th');
                let csvRow = [];
                
                for (let j = 0; j < cols.length; j++) {
                    let cellText = cols[j].innerText.replace(/"/g, '""');
                    csvRow.push('"' + cellText + '"');
                }
                
                csv.push(csvRow.join(','));
            }
            
            const csvString = csv.join('\n');
            const blob = new Blob([csvString], { type: 'text/csv' });
            const url = window.URL.createObjectURL(blob);
            
            const a = document.createElement('a');
            a.href = url;
            a.download = 'reservations_' + new Date().toISOString().split('T')[0] + '.csv';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);
        }

        // Initialize filter input visibility
        toggleFilterInput();
    </script>
</body>
</html>