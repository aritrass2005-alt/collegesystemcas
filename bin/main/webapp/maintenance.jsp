<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Under Maintenance – CAS</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #0f2240 0%, #1e3a5f 40%, #2c5282 100%);
            color: #fff;
            overflow: hidden;
        }
        .maintenance-container {
            text-align: center;
            padding: 40px;
            max-width: 560px;
        }
        .gear-icon {
            font-size: 80px;
            display: inline-block;
            animation: spin 4s linear infinite;
            margin-bottom: 30px;
            opacity: 0.9;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        h1 {
            font-size: 2.2rem;
            font-weight: 800;
            margin-bottom: 16px;
            letter-spacing: -0.5px;
        }
        p {
            font-size: 1.1rem;
            line-height: 1.7;
            color: rgba(255,255,255,0.75);
            margin-bottom: 30px;
        }
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 24px;
            background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.15);
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 600;
            backdrop-filter: blur(10px);
        }
        .pulse-dot {
            width: 10px; height: 10px;
            border-radius: 50%;
            background: #f59e0b;
            animation: pulse 1.5s ease-in-out infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.5; transform: scale(1.3); }
        }
        .login-link {
            display: inline-block;
            margin-top: 24px;
            color: rgba(255,255,255,0.6);
            font-size: 0.85rem;
            text-decoration: none;
        }
        .login-link:hover { color: #fff; text-decoration: underline; }
    </style>
</head>
<body>
    <div class="maintenance-container">
        <div class="gear-icon">⚙️</div>
        <h1>We'll Be Back Soon</h1>
        <p>
            The College Attendance System is currently undergoing scheduled maintenance.
            We're working to improve your experience. Please check back shortly.
        </p>
        <div class="status-badge">
            <div class="pulse-dot"></div>
            Maintenance in Progress
        </div>
        <br>
        <a href="login.jsp" class="login-link">Admin Login →</a>
    </div>
</body>
</html>
