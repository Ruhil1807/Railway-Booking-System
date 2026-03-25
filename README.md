# 🚆 Railway Booking System

A multitier, full-stack railway ticketing platform built with **Java**, **JSP**, **MySQL**, and **JDBC** — featuring separate portals for customers, administrators, and sales representatives, with role-based access control, concurrent seat reservation logic, and banking-grade security.

---

## 📌 Overview

The Railway Booking System is a web-based ticketing application that supports three distinct user roles — **customers**, **admins**, and **sales representatives** — each with dedicated dashboards and workflows. The system handles real-world challenges like concurrent seat reservations without double-booking, revenue and sales reporting, schedule management, and customer analytics, all backed by an ACID-compliant relational database.

---

## ✨ Features

### 👤 Customer Portal
- User signup, login, and profile management
- Train search and search results browsing
- Seat reservation and booking confirmation
- Reservation details and reservation history
- Booking cancellation
- Station schedules and train details
- Account settings

### 🛠️ Admin Portal
- Secure admin login and dashboard
- Schedule management
- Revenue reports and sales reports
- Customer analysis and transit analysis
- Transit customer management
- Customer service tools
- QA system for quality assurance
- Data backup tools

### 🧑‍💼 Sales Representative Portal
- Rep login and dashboard
- Rep management tools

### 🔒 Security
- Role-based access control (RBAC) across all three portals
- Parameterized queries and prepared statements (SQL injection prevention)
- Input validation and encryption for sensitive user data
- Dedicated error handling page

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Language | Java |
| Frontend | JSP (JavaServer Pages), HTML/CSS |
| Entry Point | HTML (`index.html`) |
| Backend | Java Servlets |
| Database | MySQL |
| DB Connectivity | JDBC |
|App ServerApache | Tomcat 9/10 |
| Architecture | Multitier MVC (Presentation → Business Logic → Data Access) |
| Version Control | Git |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│           Presentation Layer             │
│   JSP Pages + index.html (UI Views)     │
├─────────────────────────────────────────┤
│           Business Logic Layer           │
│   Java Servlets & Controllers (src/)    │
├─────────────────────────────────────────┤
│           Data Access Layer              │
│   JDBC + MySQL (DAO Pattern)            │
└─────────────────────────────────────────┘
```

---

## 📂 Project Structure

```
railway-booking-system/
├── images of project/          # Project screenshots
├── src/                        # Java source (Servlets, DAOs, Models)
├── WEB-INF/                    # Web config (web.xml, lib/)
├── index.html                  # Application entry point
│
├── -- Customer Pages --
├── signup.jsp                  # User registration
├── login.jsp                   # Customer login
├── profile.jsp                 # Profile management
├── settings.jsp                # Account settings
├── search.jsp                  # Train search
├── search-result.jsp           # Search results
├── reserve.jsp                 # Seat reservation
├── reservation-details.jsp     # Booking details
├── reservation-lists.jsp       # Booking history
├── cancel.jsp                  # Booking cancellation
├── station-schedules.jsp       # Station schedule viewer
├── train-details.jsp           # Train information
├── welcome.jsp                 # Welcome/landing page
│
├── -- Admin Pages --
├── admin-login.jsp             # Admin authentication
├── admin.jsp                   # Admin dashboard
├── schedule-management.jsp     # Train schedule management
├── revenue-reports.jsp         # Revenue analytics
├── sales-reports.jsp           # Sales analytics
├── customer-analysis.jsp       # Customer analytics
├── transit-analysis.jsp        # Transit analytics
├── transit-customers.jsp       # Transit customer management
├── customer-service.jsp        # Customer service tools
├── qa-system.jsp               # Quality assurance
├── backup.jsp                  # Data backup
├── error.jsp                   # Error handling
│
├── -- Sales Rep Pages --
├── rep-login.jsp               # Rep authentication
├── rep-dashboard.jsp           # Rep dashboard
├── rep-management.jsp          # Rep management tools
│
└── README.md
```

---

## 🗄️ Database Design

- **Normalized relational schema** to eliminate redundancy and maintain data integrity
- **ACID-compliant transactions** for concurrent seat reservations — ensuring zero double-bookings under simultaneous load
- Supports complex reporting queries powering revenue, sales, customer, and transit analytics dashboards

---

## 🧪 Key Engineering Challenges

- **Concurrency** — Implemented transaction locking to handle simultaneous reservation requests with zero double-bookings
- **Multi-role system** — Designed three fully separate portals (customer, admin, rep) with strict RBAC enforcement
- **Analytics & reporting** — Built revenue, sales, customer, and transit analysis views for operational decision-making
- **Security hardening** — Parameterized queries, input sanitization, and encryption applied across all user-facing flows
- **Data integrity** — ACID-compliant transactions ensure partial bookings are automatically rolled back on failure

---

## 🚀 Getting Started

### Prerequisites

- Java JDK 8+
- Apache Tomcat 9+
- MySQL 8+
- Any IDE (IntelliJ IDEA, Eclipse, or NetBeans)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Ruhil1807/Railway-Booking-System.git
   cd railway-booking-system
   ```

2. **Configure the database**
   ```sql
   CREATE DATABASE railway_db;
   ```
   Import the schema:
   ```bash
   mysql -u root -p railway_db < schema.sql
   ```
   Update your DB credentials in the connection config inside `src/`.

3. **Deploy to Tomcat**
   - Build the project as a `.war` file
   - Deploy to your local Tomcat server
   - Access at `http://localhost:8080/railway-booking-system`

---

📜 License
Personal/academic project. Choose a license (MIT/Apache-2.0) if you plan to accept contributions.

---
## 👤 Author

**Ruhil Patel**
- Email: ruhilpatel0718@gmail.com
- LinkedIn: [linkedin.com/in/ruhil-patel-955101271](https://www.linkedin.com/in/ruhil-patel-955101271/)
- GitHub: github.com/Ruhil1807
