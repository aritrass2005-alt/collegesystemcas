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
            background-color: #121212; /* Black background */
            color: #ffffff; /* White text */
        }
        .login-card { 
            border-radius: 10px; 
            border: 1px solid #dc3545; /* Red border */
            background-color: #1e1e1e; /* Darker card background */
            box-shadow: 0 4px 15px rgba(220, 53, 69, 0.3); /* Red shadow */
            color: #ffffff;
        }
        .card-header { 
            background-color: #dc3545; /* Red header */
            color: white; 
            border-radius: 9px 9px 0 0 !important; 
            border-bottom: none;
        }
        .form-label {
            color: #f8f9fa;
        }
        .form-control, .form-select {
            background-color: #2b2b2b;
            color: #ffffff;
            border: 1px solid #444;
        }
        .form-control:focus, .form-select:focus {
            background-color: #333;
            color: #ffffff;
            border-color: #dc3545;
            box-shadow: 0 0 0 0.25rem rgba(220, 53, 69, 0.25);
        }
        /* Customizing select options */
        .form-select option {
            background-color: #2b2b2b;
            color: #ffffff;
        }
        .btn-primary {
            background-color: #dc3545;
            border-color: #dc3545;
        }
        .btn-primary:hover {
            background-color: #c82333;
            border-color: #bd2130;
        }
        /* Header styling */
        .page-header {
            text-align: center;
            padding: 2rem 0;
            color: #ffffff;
            text-transform: uppercase;
            letter-spacing: 2px;
        }
        .page-header span {
            color: #dc3545; /* Red accent in header */
        }
        .form-check-input {
            background-color: #2b2b2b;
            border-color: #444;
        }
        .form-check-input:checked {
            background-color: #dc3545;
            border-color: #dc3545;
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
