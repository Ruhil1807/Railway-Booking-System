<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String transitLineName = request.getParameter("trainName");
    String origin = request.getParameter("origin");
    String destination = request.getParameter("destination");
    String fare = request.getParameter("fare");
    String departure = request.getParameter("departure");
    String arrival = request.getParameter("arrival");
    String travelDate = request.getParameter("travelDate");
    String sortBy = request.getParameter("sortBy");
    String stops = request.getParameter("stops");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Train Details</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        <%-- (Keep your existing CSS as-is here, omitted for brevity) --%>
    </style>
</head>
<body>
<div class="container">
    <div class="detail-box">

        <!-- 🔙 Back Button -->
        <a href="search?origin=<%= origin %>&destination=<%= destination %>&travelDate=<%= travelDate %>&sortBy=<%= sortBy %>"
           class="back-btn">← Back to Search</a>

        <h2>Train Details</h2>

        <!-- 🚆 Train + Date -->
        <div class="train-info-grid">
            <div class="info-card">
                <div class="info-label">🚆 Train</div>
                <div class="info-value train-name">
                    <%= transitLineName %>
                    <span class="badge">Express</span>
                </div>
            </div>
            <div class="info-card">
                <div class="info-label">📅 Travel Date</div>
                <div class="info-value"><%= travelDate %></div>
            </div>
        </div>

        <!-- 🗺 Route Info -->
        <div class="route-info">
            <div class="info-label" style="text-align: center; margin-bottom: 15px;">🗺 Route Information</div>
            <div class="route-stops">
                <%= stops != null ? stops.replace("|", " <span class='route-arrow'>→</span> ") : "No stops listed" %>
            </div>
        </div>

        <!-- 🕒 Times -->
        <div class="time-container">
            <div class="time-info">
                <div class="time-label">🕐 Departure</div>
                <div class="time-value"><%= departure %></div>
                <div style="font-size: 0.9rem; color: #666; margin-top: 5px;"><%= origin %></div>
            </div>
            <div style="display: flex; align-items: center; justify-content: center; color: #0078d7; font-size: 1.5rem;">❯❯❯❯</div>
            <div class="time-info">
                <div class="time-label">🕐 Arrival</div>
                <div class="time-value"><%= arrival %></div>
                <div style="font-size: 0.9rem; color: #666; margin-top: 5px;"><%= destination %></div>
            </div>
        </div>

        <!-- 💰 Fare -->
        <div class="fare-highlight">
            <div class="info-label">💰 Total Fare</div>
            <div class="info-value fare">$<%= fare %></div>
            <div style="font-size: 0.85rem; color: #666; margin-top: 5px;">*Including all taxes and fees</div>
        </div>

        <!-- ✅ Reserve Button -->
        <%
            String loggedInUser = (String) session.getAttribute("username");
            String reserveLink = "reserve.jsp?trainName=" + transitLineName
                                + "&origin=" + origin
                                + "&destination=" + destination
                                + "&fare=" + fare
                                + "&departure=" + departure
                                + "&arrival=" + arrival;
            String finalLink = (loggedInUser == null)
                               ? "login.jsp?redirect=" + java.net.URLEncoder.encode(reserveLink, "UTF-8")
                               : reserveLink;
        %>

        <a href="<%= finalLink %>" class="reserve-btn">
            Reserve This Train
        </a>
    </div>
</div>
</body>
</html>
