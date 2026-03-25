<%@ page import="java.util.*, model.TrainSchedule" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
  <title>Train Search Results - IRCTC</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    :root {
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
      
      --neutral-50: #fafafa;
      --neutral-100: #f5f5f5;
      --neutral-200: #e5e5e5;
      --neutral-300: #d4d4d4;
      --neutral-400: #a3a3a3;
      --neutral-500: #737373;
      --neutral-600: #525252;
      --neutral-700: #404040;
      --neutral-800: #262626;
      --neutral-900: #171717;
      
      --success: #10b981;
      --warning: #f59e0b;
      --error: #ef4444;
      
      --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
      --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
      --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
      --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
      --shadow-2xl: 0 25px 50px -12px rgb(0 0 0 / 0.25);
    }

    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: linear-gradient(135deg, var(--primary-50) 0%, var(--neutral-100) 50%, var(--primary-100) 100%);
      min-height: 100vh;
      line-height: 1.6;
      color: var(--neutral-800);
      position: relative;
    }

    body::before {
      content: '';
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: 
        radial-gradient(circle at 20% 30%, rgba(14, 165, 233, 0.03) 0%, transparent 50%),
        radial-gradient(circle at 80% 70%, rgba(59, 130, 246, 0.02) 0%, transparent 50%),
        radial-gradient(circle at 50% 20%, rgba(147, 197, 253, 0.02) 0%, transparent 50%);
      z-index: -1;
      pointer-events: none;
    }

    .container {
      max-width: 1400px;
      margin: 0 auto;
      padding: 40px 24px;
    }

    /* Header Section */
    .header-section {
      background: rgba(255, 255, 255, 0.8);
      backdrop-filter: blur(20px) saturate(180%);
      border: 1px solid var(--neutral-200);
      border-radius: 20px;
      padding: 32px;
      margin-bottom: 32px;
      box-shadow: var(--shadow-lg);
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 20px;
    }

    .header-content h1 {
      font-size: 2rem;
      font-weight: 700;
      color: var(--neutral-800);
      margin-bottom: 8px;
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .header-content h1 i {
      color: var(--primary-500);
      font-size: 1.8rem;
    }

    .header-content p {
      color: var(--neutral-600);
      font-size: 1rem;
      font-weight: 500;
    }

    .back-btn {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      background: linear-gradient(135deg, var(--primary-500), var(--primary-600));
      color: white;
      padding: 12px 24px;
      text-decoration: none;
      border-radius: 12px;
      font-weight: 600;
      font-size: 0.95rem;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      box-shadow: var(--shadow-md);
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
      color: white;
      text-decoration: none;
    }

    /* Results Section */
    .results-section {
      background: rgba(255, 255, 255, 0.8);
      backdrop-filter: blur(20px) saturate(180%);
      border: 1px solid var(--neutral-200);
      border-radius: 20px;
      overflow: hidden;
      box-shadow: var(--shadow-lg);
      position: relative;
    }

    .results-section::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      height: 3px;
      background: linear-gradient(90deg, var(--primary-500), var(--primary-600));
    }

    /* Table Styling */
    .table-container {
      overflow-x: auto;
      max-width: 100%;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      background: transparent;
    }

    th {
      background: linear-gradient(135deg, var(--neutral-50), var(--primary-50));
      color: var(--neutral-700);
      font-weight: 600;
      padding: 20px 16px;
      text-align: left;
      font-size: 0.9rem;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      border-bottom: 2px solid var(--neutral-200);
      position: sticky;
      top: 0;
      z-index: 10;
    }

    td {
      padding: 20px 16px;
      border-bottom: 1px solid var(--neutral-100);
      vertical-align: middle;
      font-weight: 500;
      color: var(--neutral-700);
      transition: all 0.3s ease;
    }

    tr:hover td {
      background: linear-gradient(135deg, var(--primary-25), rgba(14, 165, 233, 0.02));
      transform: scale(1.005);
    }

    tr:last-child td {
      border-bottom: none;
    }

    /* Train Info Styling */
    .train-name {
      font-weight: 700;
      color: var(--primary-700);
      font-size: 1rem;
    }

    .station-name {
      font-weight: 600;
      color: var(--neutral-800);
    }

    .fare-amount {
      font-weight: 700;
      color: var(--success);
      font-size: 1.1rem;
    }

    .time-display {
      font-weight: 600;
      color: var(--neutral-700);
      font-family: 'Courier New', monospace;
    }

    .date-display {
      font-weight: 500;
      color: var(--neutral-600);
      background: var(--neutral-100);
      padding: 4px 8px;
      border-radius: 6px;
      font-size: 0.9rem;
    }

    /* Action Button */
    .btn-reserve {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      background: linear-gradient(135deg, var(--success), #059669);
      color: white;
      padding: 10px 20px;
      text-decoration: none;
      border-radius: 10px;
      font-weight: 600;
      font-size: 0.9rem;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      box-shadow: var(--shadow-sm);
      border: none;
      cursor: pointer;
      position: relative;
      overflow: hidden;
    }

    .btn-reserve::before {
      content: '';
      position: absolute;
      top: 0;
      left: -100%;
      width: 100%;
      height: 100%;
      background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
      transition: left 0.5s;
    }

    .btn-reserve:hover::before {
      left: 100%;
    }

    .btn-reserve:hover {
      transform: translateY(-2px);
      box-shadow: var(--shadow-lg);
      color: white;
      text-decoration: none;
      background: linear-gradient(135deg, #059669, #047857);
    }

    .btn-reserve:active {
      transform: translateY(0);
    }

    /* No Results Styling */
    .no-results {
      text-align: center;
      padding: 80px 40px;
      background: transparent;
    }

    .no-results-icon {
      font-size: 4rem;
      color: var(--neutral-300);
      margin-bottom: 24px;
    }

    .no-results h3 {
      font-size: 1.5rem;
      font-weight: 700;
      color: var(--neutral-700);
      margin-bottom: 12px;
    }

    .no-results p {
      font-size: 1rem;
      color: var(--neutral-600);
      max-width: 500px;
      margin: 0 auto;
      line-height: 1.6;
    }

    /* Search Summary */
    .search-summary {
      background: linear-gradient(135deg, var(--primary-50), var(--neutral-50));
      border: 1px solid var(--primary-200);
      border-radius: 12px;
      padding: 16px 20px;
      margin-bottom: 24px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      flex-wrap: wrap;
      gap: 16px;
    }

    .search-info {
      display: flex;
      align-items: center;
      gap: 16px;
      flex-wrap: wrap;
    }

    .search-detail {
      display: flex;
      align-items: center;
      gap: 6px;
      color: var(--primary-700);
      font-weight: 500;
      font-size: 0.9rem;
    }

    .search-detail i {
      color: var(--primary-500);
    }

    .results-count {
      background: var(--primary-500);
      color: white;
      padding: 6px 12px;
      border-radius: 20px;
      font-weight: 600;
      font-size: 0.85rem;
    }

    /* Status Indicators */
    .status-available {
      color: var(--success);
      font-weight: 600;
    }

    .status-limited {
      color: var(--warning);
      font-weight: 600;
    }

    .status-full {
      color: var(--error);
      font-weight: 600;
    }

    /* Responsive Design */
    @media (max-width: 1024px) {
      .container {
        padding: 20px 16px;
      }

      .header-section {
        flex-direction: column;
        text-align: center;
      }

      .table-container {
        border-radius: 12px;
        box-shadow: var(--shadow-md);
      }
    }

    @media (max-width: 768px) {
      .header-content h1 {
        font-size: 1.5rem;
      }

      th, td {
        padding: 12px 8px;
        font-size: 0.85rem;
      }

      .btn-reserve {
        padding: 8px 16px;
        font-size: 0.8rem;
      }

      .search-summary {
        flex-direction: column;
        align-items: flex-start;
      }
    }

    @media (max-width: 640px) {
      .table-container {
        font-size: 0.8rem;
      }

      th, td {
        padding: 10px 6px;
      }

      .train-name,
      .station-name {
        font-size: 0.85rem;
      }

      .fare-amount {
        font-size: 1rem;
      }
    }

    /* Animation */
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

    .results-section,
    .header-section {
      animation: fadeInUp 0.6s ease-out;
    }

    table tr {
      animation: fadeInUp 0.4s ease-out;
    }

    table tr:nth-child(even) {
      animation-delay: 0.1s;
    }

    table tr:nth-child(odd) {
      animation-delay: 0.05s;
    }

    /* Loading State */
    .loading {
      opacity: 0.7;
      pointer-events: none;
    }

    /* Improved hover effects */
    .table-container:hover {
      box-shadow: var(--shadow-xl);
    }

    /* Custom scrollbar */
    .table-container::-webkit-scrollbar {
      height: 8px;
    }

    .table-container::-webkit-scrollbar-track {
      background: var(--neutral-100);
      border-radius: 4px;
    }

    .table-container::-webkit-scrollbar-thumb {
      background: var(--neutral-300);
      border-radius: 4px;
    }

    .table-container::-webkit-scrollbar-thumb:hover {
      background: var(--neutral-400);
    }
  </style>
</head>
<body>
  <div class="container">
    <!-- Header Section -->
    <div class="header-section">
      <div class="header-content">
        <h1>
          <i class="fas fa-search"></i>
          Train Search Results
        </h1>
        <p>Find and book your perfect train journey</p>
      </div>
      <a href="index.html" class="back-btn">
        <i class="fas fa-arrow-left"></i>
        Back to Search
      </a>
    </div>

    <%
      ArrayList<TrainSchedule> results = (ArrayList<TrainSchedule>) request.getAttribute("results");
    %>

    <!-- Results Section -->
    <div class="results-section">
      <%
        if (results == null || results.isEmpty()) {
      %>
        <div class="no-results">
          <div class="no-results-icon">
            <i class="fas fa-search"></i>
          </div>
          <h3>No trains found</h3>
          <p>Sorry, no trains match your search criteria. Please try different dates, destinations, or expand your search parameters.</p>
        </div>
      <% } else { %>
        <!-- Search Summary -->
        <div class="search-summary">
          <div class="search-info">
            <div class="search-detail">
              <i class="fas fa-train"></i>
              <span>Available Trains</span>
            </div>
            <div class="search-detail">
              <i class="fas fa-calendar"></i>
              <span>Today's Schedule</span>
            </div>
            <div class="search-detail">
              <i class="fas fa-route"></i>
              <span>Multiple Routes</span>
            </div>
          </div>
          <div class="results-count">
            <%= results.size() %> trains found
          </div>
        </div>

        <!-- Table Container -->
        <div class="table-container">
          <table>
            <thead>
              <tr>
                <th><i class="fas fa-train"></i> Transit Line</th>
                <th><i class="fas fa-map-marker-alt"></i> Origin</th>
                <th><i class="fas fa-flag-checkered"></i> Destination</th>
                <th><i class="fas fa-rupee-sign"></i> Fare</th>
                <th><i class="fas fa-clock"></i> Departure</th>
                <th><i class="fas fa-clock"></i> Arrival</th>
                <th><i class="fas fa-calendar-day"></i> Travel Date</th>
                <th><i class="fas fa-ticket-alt"></i> Action</th>
              </tr>
            </thead>
            <tbody>
              <% for (TrainSchedule ts : results) { %>
                <tr>
                  <td>
                    <div class="train-name"><%= ts.getTrainName() %></div>
                  </td>
                  <td>
                    <div class="station-name"><%= ts.getOrigin() %></div>
                  </td>
                  <td>
                    <div class="station-name"><%= ts.getDestination() %></div>
                  </td>
                  <td>
                    <div class="fare-amount">$<%= ts.getFare() %></div>
                  </td>
                  <td>
                    <div class="time-display"><%= ts.getDepartureTime() %></div>
                  </td>
                  <td>
                    <div class="time-display"><%= ts.getArrivalTime() %></div>
                  </td>
                  <td>
                    <div class="date-display"><%= ts.getTravelDate() %></div>
                  </td>
                  <td>
                    <a href="reserve.jsp?trainName=<%= java.net.URLEncoder.encode(ts.getTrainName(), "UTF-8") %>&origin=<%= java.net.URLEncoder.encode(ts.getOrigin(), "UTF-8") %>&destination=<%= java.net.URLEncoder.encode(ts.getDestination(), "UTF-8") %>&fare=<%= ts.getFare() %>&departure=<%= java.net.URLEncoder.encode(ts.getDepartureTime(), "UTF-8") %>&arrival=<%= java.net.URLEncoder.encode(ts.getArrivalTime(), "UTF-8") %>&travelDate=<%= ts.getTravelDate() %>" 
                       class="btn-reserve">
                      <i class="fas fa-ticket-alt"></i>
                      Reserve Now
                    </a>
                  </td>
                </tr>
              <% } %>
            </tbody>
          </table>
        </div>
      <% } %>
    </div>
  </div>

  <script>
    // Add smooth loading animation
    document.addEventListener('DOMContentLoaded', function() {
      const table = document.querySelector('table');
      if (table) {
        const rows = table.querySelectorAll('tbody tr');
        rows.forEach((row, index) => {
          row.style.animationDelay = `${index * 0.05}s`;
        });
      }
    });

    // Add click effect to reserve buttons
    document.querySelectorAll('.btn-reserve').forEach(btn => {
      btn.addEventListener('click', function(e) {
        // Add loading state
        this.style.opacity = '0.8';
        this.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
        
        // Reset after a short delay (the page will navigate anyway)
        setTimeout(() => {
          this.style.opacity = '1';
          this.innerHTML = '<i class="fas fa-ticket-alt"></i> Reserve Now';
        }, 1000);
      });
    });

    // Add hover effects to table rows
    document.querySelectorAll('tbody tr').forEach(row => {
      row.addEventListener('mouseenter', function() {
        this.style.transform = 'translateX(4px)';
      });
      
      row.addEventListener('mouseleave', function() {
        this.style.transform = 'translateX(0)';
      });
    });
  </script>
</body>
</html>