<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Scheduled Maintenance – College Attendance System</title>
    <!-- Google Fonts & Bootstrap -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <style>
        :root {
            --bg-base: #020617;
            --bg-surface: rgba(15, 23, 42, 0.65);
            --accent: #3b82f6;
            --accent-glow: rgba(59, 130, 246, 0.15);
            --text-primary: #f8fafc;
            --text-secondary: #94a3b8;
        }

        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: var(--bg-base);
            color: var(--text-primary);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
            overflow-x: hidden;
            position: relative;
        }

        /* Ambient Glowing Background Elements */
        .glow-sphere {
            position: absolute;
            width: 400px;
            height: 400px;
            background: radial-gradient(circle, rgba(59, 130, 246, 0.2) 0%, rgba(0,0,0,0) 70%);
            border-radius: 50%;
            z-index: 1;
            filter: blur(40px);
        }
        .glow-sphere-1 { top: -100px; left: -100px; }
        .glow-sphere-2 { bottom: -100px; right: -100px; }

        /* Premium Glassmorphic Container */
        .maintenance-card {
            background: var(--bg-surface);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 24px;
            padding: 3rem;
            max-width: 620px;
            width: 90%;
            z-index: 10;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5), inset 0 1px 0 rgba(255, 255, 255, 0.1);
            text-align: center;
            animation: cardAppear 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards;
            position: relative;
        }

        @keyframes cardAppear {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Tech-styled glowing check center */
        .icon-wrapper {
            width: 96px;
            height: 96px;
            background: radial-gradient(circle, rgba(59, 130, 246, 0.15) 0%, rgba(59, 130, 246, 0.03) 70%);
            border: 1px dashed rgba(59, 130, 246, 0.4);
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 2rem;
            position: relative;
            animation: pulseDashed 4s linear infinite;
        }

        .icon-wrapper i {
            font-size: 2.5rem;
            color: var(--accent);
            animation: iconFloat 3s ease-in-out infinite alternate;
            filter: drop-shadow(0 0 10px rgba(59, 130, 246, 0.5));
        }

        @keyframes pulseDashed {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        @keyframes iconFloat {
            0% { transform: translateY(2px) rotate(0deg); }
            100% { transform: translateY(-4px) rotate(-10deg); }
        }

        h1 {
            font-size: 2.25rem;
            font-weight: 700;
            letter-spacing: -0.025em;
            margin-bottom: 1rem;
            background: linear-gradient(135deg, #ffffff 0%, #cbd5e1 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .subtitle {
            font-size: 1.1rem;
            color: var(--accent);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.1em;
            margin-bottom: 1.5rem;
        }

        p.desc {
            color: var(--text-secondary);
            font-size: 1rem;
            line-height: 1.6;
            margin-bottom: 2.5rem;
        }

        /* Status Indicator Pill */
        .status-badge {
            background: rgba(234, 179, 8, 0.1);
            border: 1px solid rgba(234, 179, 8, 0.2);
            color: #facc15;
            padding: 8px 16px;
            border-radius: 100px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 2.5rem;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            background-color: #eab308;
            border-radius: 50%;
            display: inline-block;
            box-shadow: 0 0 8px #eab308;
            animation: pulseStatus 1.5s infinite;
        }

        @keyframes pulseStatus {
            0% { opacity: 0.4; }
            50% { opacity: 1; }
            100% { opacity: 0.4; }
        }

        /* System diagnostics status grid */
        .diagnostics-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 12px;
            border-top: 1px solid rgba(255, 255, 255, 0.05);
            padding-top: 2rem;
            margin-bottom: 1.5rem;
        }

        .diagnostic-item {
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid rgba(255, 255, 255, 0.04);
            border-radius: 12px;
            padding: 12px;
        }

        .diagnostic-label {
            font-size: 0.7rem;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 4px;
        }

        .diagnostic-value {
            font-size: 0.85rem;
            font-weight: 600;
            color: #f8fafc;
        }

        .diagnostic-value.status-ok {
            color: #10b981;
        }

        /* Discreet super admin anchor point */
        .admin-bypass {
            font-size: 0.8rem;
            color: rgba(255,255,255,0.15);
            text-decoration: none;
            transition: all 0.3s ease;
            position: absolute;
            bottom: 15px;
            left: 50%;
            transform: translateX(-50%);
        }

        .admin-bypass:hover {
            color: var(--accent);
            text-shadow: 0 0 10px rgba(59, 130, 246, 0.4);
        }
    </style>
</head>
<body>

    <!-- Ambient Glowing Spheres -->
    <div class="glow-sphere glow-sphere-1"></div>
    <div class="glow-sphere glow-sphere-2"></div>

    <!-- Main Card -->
    <div class="maintenance-card">
        
        <div class="status-badge">
            <span class="status-dot"></span> System Status: Scheduled Maintenance
        </div>

        <br>

        <div class="icon-wrapper">
            <i class="bi bi-cpu"></i>
        </div>

        <p class="subtitle">Platform Upgrades</p>
        <h1>We'll be right back</h1>
        <p class="desc">
            The College Attendance Management System is currently undergoing routine maintenance and software upgrades to bring you a faster and more secure academic experience. We apologize for any temporary inconvenience.
        </p>

        <!-- System Diagnostics Stats -->
        <div class="diagnostics-grid">
            <div class="diagnostic-item">
                <div class="diagnostic-label">Database</div>
                <div class="diagnostic-value status-ok"><i class="bi bi-check-circle-fill"></i> Standby</div>
            </div>
            <div class="diagnostic-item">
                <div class="diagnostic-label">Security</div>
                <div class="diagnostic-value status-ok"><i class="bi bi-shield-fill-check"></i> Encrypted</div>
            </div>
            <div class="diagnostic-item">
                <div class="diagnostic-label">ETA</div>
                <div class="diagnostic-value">30 Mins</div>
            </div>
        </div>

        <!-- Super Admin discreet entrance -->
        <a href="login.jsp" class="admin-bypass"><i class="bi bi-shield-lock-fill"></i> Faculty Portal</a>

    </div>

</body>
</html>
