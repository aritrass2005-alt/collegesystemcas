<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Faculty Registration – College Attendance System</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="css/theme.css?v=6" rel="stylesheet">
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
            width: 42%;
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

        .steps-list {
            margin-top: 32px;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .step-item {
            display: flex;
            align-items: flex-start;
            gap: 14px;
        }

        .step-num {
            width: 30px; height: 30px;
            min-width: 30px;
            background: rgba(79,156,249,0.2);
            border: 1px solid rgba(79,156,249,0.4);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.75rem;
            font-weight: 700;
            color: #7bb8fb;
        }

        .step-info h4 {
            font-size: 0.85rem;
            font-weight: 600;
            color: rgba(255,255,255,0.9);
            margin-bottom: 2px;
        }

        .step-info p {
            font-size: 0.75rem;
            color: rgba(255,255,255,0.45);
            line-height: 1.5;
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

        /* ── Right Panel ── */
        .right-panel {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 40px;
            background: #fff;
            overflow-y: auto;
        }

        .register-box {
            width: 100%;
            max-width: 440px;
        }

        .register-heading {
            font-size: 1.75rem;
            font-weight: 700;
            color: #0f2240;
            margin-bottom: 6px;
            letter-spacing: -0.5px;
        }

        .register-subtext {
            font-size: 0.88rem;
            color: #6b7280;
            margin-bottom: 32px;
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
            margin-bottom: 18px;
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

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        .btn-register {
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
            margin-top: 8px;
        }

        .btn-register:hover {
            background: #0f2240;
            transform: translateY(-1px);
            box-shadow: 0 6px 20px rgba(30,58,95,0.3);
        }

        .btn-register:active { transform: translateY(0); }

        .divider {
            display: flex;
            align-items: center;
            gap: 14px;
            margin: 24px 0;
            color: #d1d5db;
            font-size: 0.8rem;
        }

        .divider::before, .divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: #e5e7eb;
        }

        .login-row {
            text-align: center;
            font-size: 0.86rem;
            color: #6b7280;
        }

        .login-row a {
            color: #1e3a5f;
            font-weight: 600;
            text-decoration: none;
        }

        .login-row a:hover { text-decoration: underline; }

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

        .info-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            border-radius: 8px;
            padding: 8px 14px;
            font-size: 0.8rem;
            color: #1e40af;
            margin-bottom: 24px;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .left-panel { display: none; }
            .right-panel { background: #f0f2f5; padding: 32px 24px; }
            .register-box {
                background: #fff;
                padding: 32px 28px;
                border-radius: 20px;
                box-shadow: 0 4px 30px rgba(0,0,0,0.08);
            }
            .form-row {
                grid-template-columns: 1fr;
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
            <div class="quote-block">
                <p class="quote-text">"A good teacher can inspire hope, ignite the imagination, and instill a love of learning."</p>
                <p class="quote-author">— Brad Henry</p>
            </div>
            <div class="role-badge">
                <i class="bi bi-person-workspace"></i>
                <span>Faculty Registration</span>
            </div>

            <div class="steps-list">
                <div class="step-item">
                    <div class="step-num">1</div>
                    <div class="step-info">
                        <h4>Fill Your Details</h4>
                        <p>Enter your name, email, department and set a password.</p>
                    </div>
                </div>
                <div class="step-item">
                    <div class="step-num">2</div>
                    <div class="step-info">
                        <h4>Submit Application</h4>
                        <p>Your registration request will be sent to the admin.</p>
                    </div>
                </div>
                <div class="step-item">
                    <div class="step-num">3</div>
                    <div class="step-info">
                        <h4>Admin Approval</h4>
                        <p>Once approved, you can log in and start using the system.</p>
                    </div>
                </div>
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
        <div class="register-box">

            <h1 class="register-heading">Create Account</h1>
            <p class="register-subtext">Register as a faculty member to access the attendance system.</p>

            <div class="info-badge">
                <i class="bi bi-info-circle-fill"></i>
                Your account will require administrator approval before first login.
            </div>

            <% if(request.getParameter("error") != null) { %>
                <div class="alert-custom alert-error">
                    <i class="bi bi-exclamation-circle-fill"></i>
                    <%= request.getParameter("error") %>
                </div>
            <% } %>
            <% if(request.getParameter("msg") != null) { %>
                <div class="alert-custom alert-success">
                    <i class="bi bi-check-circle-fill"></i>
                    <%= request.getParameter("msg") %>
                </div>
            <% } %>

            <form action="registerTeacher" method="post" id="registerForm">

                <div>
                    <label class="form-label-custom" for="name">Full Name</label>
                    <div class="input-wrap">
                        <i class="bi bi-person input-icon"></i>
                        <input type="text" name="name" id="name"
                               class="form-input" placeholder="e.g. Dr. John Doe" required autocomplete="name">
                    </div>
                </div>

                <div>
                    <label class="form-label-custom" for="email">Email Address</label>
                    <div class="input-wrap">
                        <i class="bi bi-envelope input-icon"></i>
                        <input type="email" name="email" id="email"
                               class="form-input" placeholder="yourname@college.edu" required autocomplete="email">
                    </div>
                </div>

                <div class="form-row">
                    <div>
                        <label class="form-label-custom" for="phone">Phone Number</label>
                        <div class="input-wrap">
                            <i class="bi bi-telephone input-icon"></i>
                            <input type="tel" name="phone" id="phone"
                                   class="form-input" placeholder="e.g. 9876543210" required autocomplete="tel">
                        </div>
                    </div>
                    <div>
                        <label class="form-label-custom" for="department">Department</label>
                        <div class="input-wrap">
                            <i class="bi bi-building input-icon"></i>
                            <input type="text" name="department" id="department"
                                   class="form-input" placeholder="e.g. BCA" required>
                        </div>
                    </div>
                </div>

                <div>
                    <label class="form-label-custom" for="password">Password</label>
                    <div class="input-wrap">
                        <i class="bi bi-lock input-icon"></i>
                        <input type="password" name="password" id="password"
                               class="form-input" placeholder="Create a strong password" required autocomplete="new-password" style="padding-right: 44px;" minlength="6">
                        <button type="button" class="password-toggle" id="togglePassword" aria-label="Toggle password">
                            <i class="bi bi-eye" id="eyeIcon"></i>
                        </button>
                    </div>
                </div>

                <div>
                    <label class="form-label-custom" for="confirmPassword">Confirm Password</label>
                    <div class="input-wrap">
                        <i class="bi bi-lock-fill input-icon"></i>
                        <input type="password" name="confirmPassword" id="confirmPassword"
                               class="form-input" placeholder="Re-enter your password" required autocomplete="new-password" style="padding-right: 44px;" minlength="6">
                        <button type="button" class="password-toggle" id="toggleConfirmPassword" aria-label="Toggle confirm password">
                            <i class="bi bi-eye" id="eyeIcon2"></i>
                        </button>
                    </div>
                </div>

                <button type="submit" class="btn-register" id="registerBtn">
                    <i class="bi bi-person-plus-fill"></i>
                    <span>Request Access</span>
                </button>
            </form>

            <div class="divider">or</div>

            <div class="login-row">
                Already have an account? <a href="login.jsp">Sign in here</a>
            </div>

        </div>
    </div>

    <script>
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

        document.getElementById('toggleConfirmPassword').addEventListener('click', function() {
            const pwd = document.getElementById('confirmPassword');
            const icon = document.getElementById('eyeIcon2');
            if (pwd.type === 'password') {
                pwd.type = 'text';
                icon.className = 'bi bi-eye-slash';
            } else {
                pwd.type = 'password';
                icon.className = 'bi bi-eye';
            }
        });

        // Form validation
        document.getElementById('registerForm').addEventListener('submit', function(e) {
            const pwd = document.getElementById('password').value;
            const confirm = document.getElementById('confirmPassword').value;

            if (pwd !== confirm) {
                e.preventDefault();
                alert('Passwords do not match. Please try again.');
                document.getElementById('confirmPassword').focus();
                return false;
            }

            if (pwd.length < 6) {
                e.preventDefault();
                alert('Password must be at least 6 characters long.');
                document.getElementById('password').focus();
                return false;
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

