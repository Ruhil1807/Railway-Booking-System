<%@ page import="java.sql.*, java.io.PrintWriter" %>
<%@ page import="util.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>

<%
    String user = (String) session.getAttribute("username");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Cancel Reservation - IRCTC</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px 0;
            line-height: 1.6;
        }

        .container {
            max-width: 900px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            overflow: hidden;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            animation: slideUp 0.8s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .header {
            background: linear-gradient(135deg, #dc2626 0%, #ef4444 100%);
            color: white;
            padding: 40px;
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
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 8px;
            text-shadow: 0 2px 4px rgba(0,0,0,0.3);
            position: relative;
            z-index: 1;
        }

        .header .subtitle {
            font-size: 1.1rem;
            opacity: 0.9;
            font-weight: 400;
            position: relative;
            z-index: 1;
        }

        .content-wrapper {
            padding: 40px;
        }

        .section {
            margin-bottom: 32px;
            background: white;
            border-radius: 16px;
            padding: 28px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            border: 1px solid rgba(229, 231, 235, 0.8);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #dc2626, #ef4444);
            border-radius: 16px 16px 0 0;
        }

        .section:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 25px -5px rgba(0, 0, 0, 0.15), 0 8px 10px -6px rgba(0, 0, 0, 0.1);
        }

        .section h2 {
            font-size: 1.4rem;
            font-weight: 600;
            color: #1f2937;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .section h2 i {
            width: 24px;
            text-align: center;
            color: #dc2626;
        }

        .reservations-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 16px;
        }

        .reservations-table th {
            background: linear-gradient(135deg, #f8fafc, #e2e8f0);
            color: #374151;
            font-weight: 600;
            padding: 16px;
            text-align: left;
            border-bottom: 2px solid #e5e7eb;
            font-size: 0.9rem;
        }

        .reservations-table td {
            padding: 16px;
            border-bottom: 1px solid #f3f4f6;
            vertical-align: middle;
        }

        .reservations-table tr:hover {
            background-color: rgba(239, 68, 68, 0.02);
        }

        .cancel-btn {
            background: linear-gradient(135deg, #dc2626, #ef4444);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .cancel-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(220, 38, 38, 0.4);
        }

        .cancel-btn:disabled {
            background: #d1d5db;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .status-badge {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 500;
            text-transform: uppercase;
        }

        .status-active {
            background: #dcfce7;
            color: #166534;
        }

        .status-cancelled {
            background: #fee2e2;
            color: #dc2626;
        }

        .back-btn {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 14px 28px;
            text-decoration: none;
            border-radius: 12px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-weight: 500;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            box-shadow: 0 4px 14px 0 rgba(102, 126, 234, 0.39);
            border: none;
            cursor: pointer;
        }

        .back-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px 0 rgba(102, 126, 234, 0.5);
            text-decoration: none;
            color: white;
        }

        .alert {
            padding: 16px 20px;
            border-radius: 12px;
            margin: 20px 0;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .alert-info {
            color: #1e40af;
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            border: 1px solid #93c5fd;
        }

        .alert-success {
            color: #166534;
            background: linear-gradient(135deg, #dcfce7, #bbf7d0);
            border: 1px solid #86efac;
        }

        .alert-warning {
            color: #d97706;
            background: linear-gradient(135deg, #fef3c7, #fde68a);
            border: 1px solid #fcd34d;
        }

        .no-reservations {
            text-align: center;
            padding: 40px;
            color: #6b7280;
        }

        .no-reservations i {
            font-size: 3rem;
            margin-bottom: 16px;
            color: #d1d5db;
        }

        @media (max-width: 768px) {
            .container {
                margin: 10px;
                border-radius: 16px;
            }

            .header {
                padding: 24px 20px;
            }

            .header h1 {
                font-size: 2rem;
            }

            .content-wrapper {
                padding: 24px 20px;
            }

            .reservations-table {
                font-size: 0.9rem;
            }

            .reservations-table th,
            .reservations-table td {
                padding: 12px 8px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1><i class="fas fa-times-circle"></i> Cancel Reservation</h1>
            <p class="subtitle">Manage your active reservations</p>
        </div>

        <div class="content-wrapper">
            <%
                String message = request.getParameter("message");
                String type = request.getParameter("type");
                if (message != null) {
            %>
                <div class="alert alert-<%= type != null ? type : "info" %>">
                    <i class="fas fa-<%= "success".equals(type) ? "check-circle" : "info-circle" %>"></i>
                    <%= message %>
                </div>
            <%
                }
            %>

            <div class="section">
                <h2><i class="fas fa-list"></i> Your Active Reservations</h2>
                
                <%
                    try {
                        Connection con = DBConnection.getConnection();
                        PreparedStatement stmt = con.prepareStatement(
                            "SELECT r.Reservation_Number, r.Date, r.Passenger, r.Total_Fare, r.Transit_line_name, " +
                            "COALESCE(r.status, 'ACTIVE') as status, " +
                            "t.Origin, t.Destination " +
                            "FROM reservation_data r " +
                            "LEFT JOIN train_schedule_data t ON r.Transit_line_name = t.Transit_line_name " +
                            "WHERE r.Username = ? AND r.Date >= CURDATE() AND COALESCE(r.status, 'ACTIVE') = 'ACTIVE' " +
                            "ORDER BY r.Date ASC"
                        );
                        stmt.setString(1, user);
                        ResultSet rs = stmt.executeQuery();

                        if (!rs.isBeforeFirst()) {
                %>
                            <div class="no-reservations">
                                <i class="fas fa-calendar-times"></i>
                                <h3>No Active Reservations</h3>
                                <p>You don't have any upcoming reservations that can be cancelled.</p>
                            </div>
                <%
                        } else {
                %>
                            <div class="alert alert-info">
                                <i class="fas fa-info-circle"></i>
                                You can only cancel reservations for future dates. Past trips cannot be cancelled.
                            </div>
                            
                            <table class="reservations-table">
                                <thead>
                                    <tr>
                                        <th>Reservation ID</th>
                                        <th>Route</th>
                                        <th>Travel Date</th>
                                        <th>Passengers</th>
                                        <th>Fare</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        while (rs.next()) {
                                            int reservationId = rs.getInt("Reservation_Number");
                                            String status = rs.getString("status");
                                            String passengerStrRaw = rs.getString("Passenger");
                                            
                                            // Format passengers (hide zero counts)
                                            StringBuilder formatted = new StringBuilder();
                                            if (passengerStrRaw != null) {
                                                String[] parts = passengerStrRaw.split(",");
                                                for (String part : parts) {
                                                    if (part.contains(":")) {
                                                        String[] split = part.trim().split(":");
                                                        if (split.length == 2 && !split[1].trim().equals("0")) {
                                                            if (formatted.length() > 0) formatted.append(", ");
                                                            formatted.append(split[0].trim()).append(": ").append(split[1].trim());
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            String route = "";
                                            if (rs.getString("Origin") != null && rs.getString("Destination") != null) {
                                                route = rs.getString("Origin") + " → " + rs.getString("Destination");
                                            } else {
                                                route = rs.getString("Transit_line_name");
                                            }
                                    %>
                                    <tr>
                                        <td><strong>#<%= reservationId %></strong></td>
                                        <td><%= route %></td>
                                        <td><%= rs.getDate("Date") %></td>
                                        <td><%= formatted.toString() %></td>
                                        <td><strong>₹<%= String.format("%.2f", rs.getDouble("Total_Fare")) %></strong></td>
                                        <td>
                                            <span class="status-badge status-<%= status.toLowerCase() %>">
                                                <%= status %>
                                            </span>
                                        </td>
                                        <td>
                                            <%
                                                if ("ACTIVE".equals(status)) {
                                            %>
                                                <form action="CancelServlet" method="post" style="display: inline;" 
                                                      onsubmit="return confirm('Are you sure you want to cancel this reservation? This action cannot be undone.');">
                                                    <input type="hidden" name="reservationId" value="<%= reservationId %>">
                                                    <button type="submit" class="cancel-btn">
                                                        <i class="fas fa-times"></i> Cancel
                                                    </button>
                                                </form>
                                            <%
                                                } else {
                                            %>
                                                <button class="cancel-btn" disabled>
                                                    <i class="fas fa-ban"></i> Cancelled
                                                </button>
                                            <%
                                                }
                                            %>
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                </tbody>
                            </table>
                <%
                        }
                        rs.close();
                        stmt.close();
                        con.close();
                    } catch (Exception e) {
                        out.println("<div class='alert alert-warning'><i class='fas fa-exclamation-triangle'></i> Error loading reservations: " + e.getMessage() + "</div>");
                        e.printStackTrace(new PrintWriter(out));
                    }
                %>
            </div>

            <div style="text-align: center; margin-top: 32px;">
                <a href="welcome.jsp" class="back-btn">
                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                </a>
            </div>
        </div>
    </div>
</body>
</html>