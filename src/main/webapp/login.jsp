<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>College Attendance System - Login</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #ffffff;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            margin: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }
        .login-card { 
            border-radius: 20px; 
            border: none;
            background: linear-gradient(145deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05));
            backdrop-filter: blur(10px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.3), 0 5px 15px rgba(0, 0, 0, 0.1);
            color: #ffffff;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            overflow: hidden;
            position: relative;
        }
        .login-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4), 0 10px 20px rgba(0, 0, 0, 0.2);
        }
        .login-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #ff6b6b, #4ecdc4, #45b7d1, #96ceb4);
            background-size: 400% 400%;
            animation: gradientShift 4s ease infinite;
        }
        @keyframes gradientShift {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }
        .card-header { 
            background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
            color: white; 
            border-radius: 18px 18px 0 0 !important; 
            border-bottom: none;
            padding: 1.5rem;
            text-align: center;
            position: relative;
            z-index: 1;
        }
        .card-header h4 {
            margin: 0;
            font-weight: 600;
            text-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }
        .form-label {
            color: #f8f9fa;
            font-weight: 500;
            margin-bottom: 0.5rem;
        }
        .form-control, .form-select {
            background-color: rgba(255, 255, 255, 0.1);
            color: #ffffff;
            border: 2px solid rgba(255, 255, 255, 0.2);
            border-radius: 10px;
            padding: 0.75rem 1rem;
            transition: all 0.3s ease;
        }
        .form-control:focus, .form-select:focus {
            background-color: rgba(255, 255, 255, 0.15);
            color: #ffffff;
            border-color: #4ecdc4;
            box-shadow: 0 0 0 0.2rem rgba(78, 205, 196, 0.25);
            transform: translateY(-2px);
        }
        .form-control::placeholder, .form-select option {
            color: rgba(255, 255, 255, 0.7);
        }
        .form-select option {
            background-color: rgba(0, 0, 0, 0.8);
            color: #ffffff;
        }
        .btn-primary {
            background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
            border: none;
            border-radius: 10px;
            padding: 0.75rem 1.5rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, #4ecdc4 0%, #ff6b6b 100%);
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(255, 107, 107, 0.4);
        }
        .btn-primary:active {
            transform: translateY(0);
        }
        /* Header styling */
        .page-header {
            text-align: center;
            padding: 2rem 0;
            color: #ffffff;
            text-transform: uppercase;
            letter-spacing: 3px;
            font-weight: 700;
            text-shadow: 0 4px 8px rgba(0,0,0,0.5);
            margin-bottom: 2rem;
        }
        .page-header span {
            background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .form-check-input {
            background-color: rgba(255, 255, 255, 0.1);
            border-color: rgba(255, 255, 255, 0.3);
            border-radius: 4px;
        }
        .form-check-input:checked {
            background-color: #4ecdc4;
            border-color: #4ecdc4;
        }
        .form-check-label {
            color: #f8f9fa;
            font-weight: 400;
        }
        .alert {
            border-radius: 10px;
            border: none;
            font-weight: 500;
        }
        .card-body {
            padding: 2rem;
            position: relative;
            z-index: 1;
        }
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .page-header {
                padding: 1rem 0;
                font-size: 1.5rem;
            }
            .card-body {
                padding: 1.5rem;
            }
        }
    </style>
</head>
<body class="d-flex flex-column align-items-center justify-content-center vh-100">

    <div class="page-header w-100">
        <h2><span>Attendance System</span></h2>
    </div>

    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-5">
                <div class="card login-card">
                    <div class="card-header text-center py-3">
                        <h4 class="mb-0">System Login</h4>
                    </div>
                    <div class="card-body p-4">
                        <% if(request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger bg-danger text-white border-0"><%= request.getAttribute("error") %></div>
                        <% } %>
                        <% if(request.getParameter("msg") != null) { %>
                            <div class="alert alert-success bg-success text-white border-0"><%= request.getParameter("msg") %></div>
                        <% } %>

                        <form action="login" method="post">
                            <div class="mb-3">
                                <label class="form-label">Login As</label>
                                <select name="role" id="role" class="form-select" required>
                                    <option value="Student">Student</option>
                                    <option value="Teacher">Teacher / Coordinator</option>
                                    <option value="Admin">Admin / Super Admin</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label" id="identifierLabel">Email or Roll No.</label>
                                <input type="text" name="identifier" class="form-control" placeholder="Enter Email or Roll No" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Password</label>
                                <input type="password" id="password" name="password" class="form-control" placeholder="Enter Password" required>
                            </div>
                            <div class="mb-4 form-check">
                                <input type="checkbox" class="form-check-input" id="showPassword" onclick="togglePassword()">
                                <label class="form-check-label" for="showPassword">Show Password</label>
                            </div>
                            <button type="submit" class="btn btn-primary w-100 py-2">Log In</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function togglePassword() {
            var pwdInput = document.getElementById("password");
            if (pwdInput.type === "password") {
                pwdInput.type = "text";
            } else {
                pwdInput.type = "password";
            }
        }
        
        // Simple client-side script to change label based on role selection
        document.getElementById('role').addEventListener('change', function() {
            var role = this.value;
            var label = document.getElementById('identifierLabel');
            if (role === 'Student') {
                label.innerText = 'Roll No.';
                document.querySelector('input[name="identifier"]').placeholder = 'Enter Roll No.';
            } else {
                label.innerText = 'Email Address';
                document.querySelector('input[name="identifier"]').placeholder = 'Enter Email Address';
            }
        });
        
        // Trigger initial state
        document.getElementById('role').dispatchEvent(new Event('change'));
    </script>
</body>
</html>
