<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login – College Attendance System</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="css/theme.css?v=5" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Inter', sans-serif;
            min-height: 100vh;
            display: flex;
            background: #f0f2f5;
        }

        /* ── Left Panel ── */
        .left-panel {
            width: 45%;
            background: linear-gradient(160deg, #1e3a5f 0%, #0f2240 60%, #071629 100%);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: 48px 52px;
            position: relative;
            overflow: hidden;
            color: #fff;
        }

        .left-panel::before {
            content: '';
            position: absolute;
            width: 420px; height: 420px;
            background: rgba(255,255,255,0.03);
            border-radius: 50%;
            top: -80px; left: -80px;
        }

        .left-panel::after {
            content: '';
            position: absolute;
            width: 300px; height: 300px;
            background: rgba(255,255,255,0.03);
            border-radius: 50%;
            bottom: -60px; right: -60px;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 14px;
            position: relative;
            z-index: 1;
        }

        .brand-icon {
            width: 46px; height: 46px;
            background: rgba(255,255,255,0.12);
            border: 1px solid rgba(255,255,255,0.2);
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.3rem;
            backdrop-filter: blur(10px);
        }

        .brand-name {
            font-size: 1.1rem;
            font-weight: 700;
            letter-spacing: 0.5px;
        }

        .brand-tagline {
            font-size: 0.72rem;
            color: rgba(255,255,255,0.55);
            letter-spacing: 1.5px;
            text-transform: uppercase;
            margin-top: 2px;
        }

        .panel-center {
            position: relative;
            z-index: 1;
        }

        .quote-block {
            background: rgba(255,255,255,0.06);
            border: 1px solid rgba(255,255,255,0.1);
            border-left: 4px solid #4f9cf9;
            border-radius: 0 12px 12px 0;
            padding: 24px 26px;
            margin-bottom: 32px;
            transition: all 0.5s ease;
        }

        .quote-text {
            font-size: 1.05rem;
            font-weight: 300;
            line-height: 1.7;
            color: rgba(255,255,255,0.88);
            font-style: italic;
        }

        .quote-author {
            font-size: 0.78rem;
            color: rgba(255,255,255,0.45);
            margin-top: 12px;
            letter-spacing: 0.5px;
            font-style: normal;
        }

        .role-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(79,156,249,0.15);
            border: 1px solid rgba(79,156,249,0.3);
            border-radius: 50px;
            padding: 6px 16px;
            font-size: 0.8rem;
            color: #7bb8fb;
            letter-spacing: 0.5px;
            font-weight: 500;
        }

        .panel-footer {
            position: relative;
            z-index: 1;
        }

        .footer-info {
            font-size: 0.75rem;
            color: rgba(255,255,255,0.3);
            line-height: 1.8;
        }

        .right-panel {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 48px 40px;
            background: #fff;
            position: relative;
        }

        .btn-home {
            position: absolute;
            top: 24px;
            right: 32px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 18px;
            background: #f3f4f6;
            color: #4b5563;
            border-radius: 50px;
            text-decoration: none;
            font-size: 0.85rem;
            font-weight: 600;
            transition: all 0.2s;
        }

        .btn-home:hover {
            background: #e5e7eb;
            color: #1f2937;
        }

        .login-box {
            width: 100%;
            max-width: 400px;
        }

        .login-heading {
            font-size: 1.75rem;
            font-weight: 700;
            color: #0f2240;
            margin-bottom: 6px;
            letter-spacing: -0.5px;
        }

        .login-subtext {
            font-size: 0.88rem;
            color: #6b7280;
            margin-bottom: 36px;
        }

        .form-label-custom {
            display: block;
            font-size: 0.78rem;
            font-weight: 600;
            color: #374151;
            letter-spacing: 0.8px;
            text-transform: uppercase;
            margin-bottom: 7px;
        }

        .input-wrap {
            position: relative;
            margin-bottom: 20px;
        }

        .input-icon {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #9ca3af;
            font-size: 1rem;
            pointer-events: none;
        }

        .form-input {
            width: 100%;
            border: 1.5px solid #e5e7eb;
            border-radius: 10px;
            padding: 12px 14px 12px 42px;
            font-size: 0.93rem;
            font-family: 'Inter', sans-serif;
            color: #111827;
            background: #f9fafb;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
            appearance: none;
        }

        .form-input:focus {
            border-color: #1e3a5f;
            background: #fff;
            box-shadow: 0 0 0 4px rgba(30,58,95,0.07);
        }

        select.form-input {
            cursor: pointer;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%236b7280' d='M6 8L1 3h10z'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 14px center;
            padding-right: 36px;
        }

        .password-toggle {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: #9ca3af;
            font-size: 1rem;
            padding: 0;
            line-height: 1;
        }

        .password-toggle:hover { color: #374151; }

        .form-row-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 28px;
            margin-top: -6px;
        }

        .remember-label {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            font-size: 0.83rem;
            color: #6b7280;
        }

        .remember-label input[type="checkbox"] {
            width: 15px; height: 15px;
            accent-color: #1e3a5f;
            cursor: pointer;
        }

        .forgot-link {
            font-size: 0.83rem;
            color: #1e3a5f;
            text-decoration: none;
            font-weight: 500;
        }

        .forgot-link:hover { text-decoration: underline; }

        .btn-login {
            width: 100%;
            padding: 13px;
            background: #1e3a5f;
            color: #fff;
            border: none;
            border-radius: 10px;
            font-size: 0.95rem;
            font-weight: 600;
            font-family: 'Inter', sans-serif;
            cursor: pointer;
            letter-spacing: 0.3px;
            transition: background 0.2s, transform 0.15s, box-shadow 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .btn-login:hover {
            background: #0f2240;
            transform: translateY(-1px);
            box-shadow: 0 6px 20px rgba(30,58,95,0.3);
        }

        .btn-login:active { transform: translateY(0); }

        .divider {
            display: flex;
            align-items: center;
            gap: 14px;
            margin: 28px 0;
            color: #d1d5db;
            font-size: 0.8rem;
        }

        .divider::before, .divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: #e5e7eb;
        }

        .register-row {
            text-align: center;
            font-size: 0.86rem;
            color: #6b7280;
        }

        .register-row a {
            color: #1e3a5f;
            font-weight: 600;
            text-decoration: none;
        }

        .register-row a:hover { text-decoration: underline; }

        .alert-custom {
            border-radius: 10px;
            padding: 11px 15px;
            font-size: 0.85rem;
            margin-bottom: 22px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .alert-error {
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #b91c1c;
        }

        .alert-success {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            color: #166534;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .left-panel { display: none; }
            .right-panel { background: #f0f2f5; padding: 32px 24px; }
            .login-box {
                background: #fff;
                padding: 32px 28px;
                border-radius: 20px;
                box-shadow: 0 4px 30px rgba(0,0,0,0.08);
            }
        }
    </style>
</head>
<body>

    <!-- LEFT PANEL -->
    <div class="left-panel">
        <div class="brand">
            <div class="brand-icon" style="background: transparent; border: none;"><img src="img/main_logo.jpg" alt="Logo" style="height: 40px; width: 40px; object-fit: contain; border-radius: 10px;"></div>
            <div>
                <div class="brand-name">CAS Portal</div>
                <div class="brand-tagline">College Attendance System</div>
            </div>
        </div>

        <div class="panel-center">
            <div class="quote-block" id="quoteBlock">
                <p class="quote-text" id="quoteText">"Education is the most powerful weapon which you can use to change the world."</p>
                <p class="quote-author" id="quoteAuthor">— Nelson Mandela</p>
            </div>
            <div class="role-badge" id="roleBadge">
                <i class="bi bi-person-circle"></i>
                <span id="roleBadgeText">Student Portal</span>
            </div>
        </div>

        <div class="panel-footer">
            <p class="footer-info">
                © 2026 College Attendance System<br>
                Secure · Reliable · Transparent<br>
                All access is logged and monitored.
            </p>
        </div>
    </div>

    <!-- RIGHT PANEL -->
    <div class="right-panel">
        <a href="index.jsp" class="btn-home"><i class="bi bi-arrow-left"></i> Back to Home</a>
        <div class="login-box">

            <h1 class="login-heading">Welcome back</h1>
            <p class="login-subtext" id="loginSubtext">Please sign in to your student account to continue.</p>

            <% if(request.getAttribute("error") != null) { %>
                <div class="alert-custom alert-error">
                    <i class="bi bi-exclamation-circle-fill"></i>
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            <% if(request.getParameter("msg") != null) { %>
                <div class="alert-custom alert-success">
                    <i class="bi bi-check-circle-fill"></i>
                    <%= request.getParameter("msg") %>
                </div>
            <% } %>

            <form action="login" method="post">

                <div>
                    <label class="form-label-custom" for="role">Login as</label>
                    <div class="input-wrap">
                        <i class="bi bi-shield-check input-icon"></i>
                        <select name="role" id="role" class="form-input" required>
                            <option value="Student">Student</option>
                            <option value="Teacher">Faculty / Coordinator</option>
                            <option value="Admin">Administrator</option>
                        </select>
                    </div>
                </div>

                <div>
                    <label class="form-label-custom" for="identifier" id="identifierLabel">Roll Number</label>
                    <div class="input-wrap">
                        <i class="bi bi-person input-icon"></i>
                        <input type="text" name="identifier" id="identifier"
                               class="form-input" placeholder="e.g. 22641001" required autocomplete="username">
                    </div>
                </div>

                <div>
                    <label class="form-label-custom" for="password">Password</label>
                    <div class="input-wrap">
                        <i class="bi bi-lock input-icon"></i>
                        <input type="password" name="password" id="password"
                               class="form-input" placeholder="Enter your password" required autocomplete="current-password" style="padding-right: 44px;">
                        <button type="button" class="password-toggle" id="togglePassword" aria-label="Toggle password">
                            <i class="bi bi-eye" id="eyeIcon"></i>
                        </button>
                    </div>
                </div>

                <div class="form-row-meta">
                    <label class="remember-label">
                        <input type="checkbox" id="rememberMe"> Remember me
                    </label>
                    <a href="#" class="forgot-link">Forgot password?</a>
                </div>

                <button type="submit" class="btn-login" id="loginBtn">
                    <i class="bi bi-box-arrow-in-right"></i>
                    <span id="loginBtnText">Sign In as Student</span>
                </button>
            </form>

            <div class="divider">or</div>

            <div class="register-row">
                New faculty member? <a href="teacher_register.jsp">Request access here</a>
            </div>

        </div>
    </div>

    <script>
        const quotes = {
            Student: [
                { text: "Education is the most powerful weapon which you can use to change the world.", author: "Nelson Mandela" },
                { text: "The beautiful thing about learning is that no one can take it away from you.", author: "B.B. King" },
                { text: "Success is the sum of small efforts, repeated day in and day out.", author: "Robert Collier" },
                { text: "Strive for progress, not perfection. Every class attended is a step forward.", author: "Anonymous" }
            ],
            Teacher: [
                { text: "A good teacher can inspire hope, ignite the imagination, and instill a love of learning.", author: "Brad Henry" },
                { text: "Teaching is the one profession that creates all other professions.", author: "Unknown" },
                { text: "The art of teaching is the art of assisting discovery.", author: "Mark Van Doren" },
                { text: "Teachers plant seeds of knowledge that grow forever.", author: "Anonymous" }
            ],
            Admin: [
                { text: "Good management is the art of making problems so interesting that everyone wants to work on them.", author: "Paul Hawken" },
                { text: "Leadership is the capacity to translate vision into reality.", author: "Warren Bennis" },
                { text: "The function of leadership is to produce more leaders, not more followers.", author: "Ralph Nader" },
                { text: "Administration is about organizing excellence, not just managing tasks.", author: "Anonymous" }
            ]
        };

        const roleConfig = {
            Student: {
                badge: "Student Portal",
                subtext: "Please sign in to your student account to continue.",
                idLabel: "Roll Number",
                idPlaceholder: "e.g. 22641001",
                btnText: "Sign In as Student",
                badgeIcon: "bi-mortarboard"
            },
            Teacher: {
                badge: "Faculty Portal",
                subtext: "Welcome back, Faculty. Sign in to manage your classes and attendance.",
                idLabel: "Email Address",
                idPlaceholder: "yourname@college.edu",
                btnText: "Sign In as Faculty",
                badgeIcon: "bi-person-workspace"
            },
            Admin: {
                badge: "Admin Portal",
                subtext: "Restricted access. Please authenticate with your administrator credentials.",
                idLabel: "Admin Email",
                idPlaceholder: "admin@college.edu",
                btnText: "Sign In as Administrator",
                badgeIcon: "bi-shield-lock"
            }
        };

        function updateUI(role) {
            const cfg = roleConfig[role];
            const qList = quotes[role];
            const q = qList[Math.floor(Math.random() * qList.length)];

            // Update quote
            document.getElementById('quoteText').textContent = '\u201c' + q.text + '\u201d';
            document.getElementById('quoteAuthor').textContent = '\u2014 ' + q.author;

            // Update badge
            document.getElementById('roleBadgeText').textContent = cfg.badge;
            document.getElementById('roleBadge').querySelector('i').className = 'bi ' + cfg.badgeIcon;

            // Update form labels
            document.getElementById('loginSubtext').textContent = cfg.subtext;
            document.getElementById('identifierLabel').textContent = cfg.idLabel;
            document.getElementById('identifier').placeholder = cfg.idPlaceholder;
            document.getElementById('loginBtnText').textContent = cfg.btnText;
        }

        // Init on load
        updateUI('Student');

        document.getElementById('role').addEventListener('change', function() {
            updateUI(this.value);
        });

        // Password toggle
        document.getElementById('togglePassword').addEventListener('click', function() {
            const pwd = document.getElementById('password');
            const icon = document.getElementById('eyeIcon');
            if (pwd.type === 'password') {
                pwd.type = 'text';
                icon.className = 'bi bi-eye-slash';
            } else {
                pwd.type = 'password';
                icon.className = 'bi bi-eye';
            }
        });
    </script>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        setTimeout(function() {
            var alerts = document.querySelectorAll(".alert, .alert-custom");
            alerts.forEach(function(alert) {
                alert.style.transition = "opacity 0.5s ease";
                alert.style.opacity = "0";
                setTimeout(function() { alert.remove(); }, 500);
            });
        }, 3000);
    });
</script>
</body>
</html>

