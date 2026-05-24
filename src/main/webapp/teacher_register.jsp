<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Registration - College Attendance System</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --bg-color: #0f0c29;
            --accent-color: #302b63;
            --highlight-color: #24243e;
            --glass-bg: rgba(255, 255, 255, 0.1);
            --text-color: #ffffff;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Outfit', sans-serif;
        }

        body {
            background: linear-gradient(135deg, #2c1b4d 0%, #1a0b2e 50%, #0d041a 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            position: relative;
            color: var(--text-color);
            padding: 20px 0;
        }

        /* Animated Blobs */
        .blob {
            position: absolute;
            width: 500px;
            height: 500px;
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            filter: blur(80px);
            border-radius: 50%;
            z-index: -1;
            opacity: 0.3;
            animation: move 20s infinite alternate;
        }

        .blob-1 {
            top: -100px;
            left: -100px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .blob-2 {
            bottom: -150px;
            right: -100px;
            width: 600px;
            height: 600px;
            background: linear-gradient(135deg, #a18cd1 0%, #fbc2eb 100%);
            animation-delay: -5s;
        }

        .blob-3 {
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 400px;
            height: 400px;
            background: linear-gradient(135deg, #84fab0 0%, #8fd3f4 100%);
            animation-duration: 15s;
        }

        .blob-4 {
            top: 10%;
            right: 20%;
            width: 300px;
            height: 300px;
            background: linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%);
            animation-delay: -2s;
        }

        .blob-5 {
            bottom: 20%;
            left: 10%;
            width: 350px;
            height: 350px;
            background: linear-gradient(135deg, #a6c0fe 0%, #f68084 100%);
            animation-delay: -8s;
        }

        @keyframes move {
            from { transform: translate(-10%, -10%) scale(1); }
            to { transform: translate(10%, 10%) scale(1.1); }
        }

        /* Snow Canvas */
        #snow-canvas {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 0;
            pointer-events: none;
        }

        .register-wrapper {
            z-index: 10;
            width: 100%;
            max-width: 500px;
            padding: 20px;
            text-align: center;
            /* Allow vertical scrolling if content is too tall */
            max-height: 100vh;
            overflow-y: auto;
            scrollbar-width: none; /* Firefox */
        }
        
        .register-wrapper::-webkit-scrollbar {
            display: none; /* Chrome, Safari, Opera */
        }

        .welcome-text {
            font-size: 2.2rem;
            font-weight: 700;
            margin-bottom: 10px;
            text-shadow: 0 4px 10px rgba(0,0,0,0.3);
        }

        .register-card {
            background: var(--glass-bg);
            backdrop-filter: blur(25px);
            -webkit-backdrop-filter: blur(25px);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 30px;
            padding: 30px;
            box-shadow: 0 25px 50px rgba(0,0,0,0.4);
        }

        .register-card h3 {
            font-size: 1.3rem;
            font-weight: 600;
            margin-bottom: 10px;
            color: #fff;
        }

        .register-card p {
            font-size: 0.9rem;
            margin-bottom: 20px;
            opacity: 0.8;
            color: #eee;
        }

        .input-group {
            background: #ffffff;
            border-radius: 50px;
            margin-bottom: 15px;
            padding: 2px 20px;
            display: flex;
            align-items: center;
            flex-wrap: nowrap !important;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        .input-group i:not(#togglePassword) {
            color: #555;
            margin-right: 12px;
            font-size: 1.1rem;
            width: 25px;
            text-align: center;
        }

        .input-group input {
            border: none;
            background: transparent;
            flex: 1;
            padding: 12px 0;
            font-size: 0.95rem;
            color: #333;
            outline: none;
            min-width: 0;
        }

        .register-btn {
            background: #ffffff;
            color: #1a0b2e;
            border: none;
            border-radius: 50px;
            padding: 12px;
            width: 100%;
            max-width: 200px;
            font-weight: 700;
            font-size: 1.05rem;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 10px 20px rgba(0,0,0,0.2);
            margin: 10px auto 0;
            display: block;
        }

        .register-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.3);
            background: #f0f0f0;
        }

        .footer-text {
            margin-top: 20px;
            font-size: 0.85rem;
            opacity: 0.8;
        }

        .footer-text a {
            color: #fff;
            font-weight: 600;
            text-decoration: underline;
        }

        .alert {
            border-radius: 15px;
            margin-bottom: 15px;
            font-size: 0.85rem;
            padding: 10px 15px;
        }
    </style>
</head>
<body>

    <!-- Background Blobs -->
    <div class="blob blob-1"></div>
    <div class="blob blob-2"></div>
    <div class="blob blob-3"></div>
    <div class="blob blob-4"></div>
    <div class="blob blob-5"></div>

    <!-- Snow Particles Canvas -->
    <canvas id="snow-canvas"></canvas>

    <div class="register-wrapper">
        <h1 class="welcome-text">Join Our Community</h1>

        <div class="register-card">
            <h3>Teacher Registration</h3>
            <p>Create your account to access the system. Your account will require Admin approval.</p>

            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger bg-danger text-white border-0"><%= request.getParameter("error") %></div>
            <% } %>

            <form action="registerTeacher" method="post">
                <div class="input-group">
                    <i class="fas fa-user"></i>
                    <input type="text" name="name" id="name" placeholder="Full Name" required>
                </div>

                <div class="input-group">
                    <i class="fas fa-envelope"></i>
                    <input type="email" name="email" id="email" placeholder="Email Address" required>
                </div>

                <div class="input-group">
                    <i class="fas fa-phone"></i>
                    <input type="text" name="phone" id="phone" placeholder="Phone Number" required>
                </div>

                <div class="input-group">
                    <i class="fas fa-building"></i>
                    <input type="text" name="department" id="department" placeholder="Department (e.g. Computer Science)" required>
                </div>

                <div class="input-group">
                    <i class="fas fa-lock"></i>
                    <input type="password" name="password" id="password" placeholder="Password" required>
                    <i class="fas fa-eye" id="togglePassword" style="cursor: pointer; margin-left: 10px; color: #777;"></i>
                </div>

                <button type="submit" class="register-btn">Register</button>
            </form>
        </div>

        <p class="footer-text">
            Already registered? <a href="login.jsp">Log in here.</a>
        </p>
    </div>

    <!-- JavaScript -->
    <script>
        // Snow Particles Logic
        const canvas = document.getElementById('snow-canvas');
        const ctx = canvas.getContext('2d');
        let particles = [];
        const particleCount = 150;
        const mouse = { x: -100, y: -100, radius: 100 };

        window.addEventListener('resize', resizeCanvas);
        window.addEventListener('mousemove', (e) => {
            mouse.x = e.clientX;
            mouse.y = e.clientY;
        });

        function resizeCanvas() {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        }

        class Particle {
            constructor() {
                this.reset();
            }

            reset() {
                this.x = Math.random() * canvas.width;
                this.y = Math.random() * canvas.height;
                this.size = Math.random() * 3 + 1;
                this.speedX = Math.random() * 1 - 0.5;
                this.speedY = Math.random() * 1 + 0.5;
                this.baseX = this.x;
                this.baseY = this.y;
                this.density = (Math.random() * 30) + 1;
            }

            update() {
                // Horizontal movement
                this.x += this.speedX;
                // Vertical movement (falling)
                this.y += this.speedY;

                if (this.y > canvas.height) {
                    this.y = -10;
                    this.x = Math.random() * canvas.width;
                }
                if (this.x > canvas.width) this.x = 0;
                if (this.x < 0) this.x = canvas.width;

                // Mouse interaction (repulsion)
                let dx = mouse.x - this.x;
                let dy = mouse.y - this.y;
                let distance = Math.sqrt(dx * dx + dy * dy);
                let forceDirectionX = dx / distance;
                let forceDirectionY = dy / distance;
                let maxDistance = mouse.radius;
                let force = (maxDistance - distance) / maxDistance;
                let directionX = forceDirectionX * force * this.density;
                let directionY = forceDirectionY * force * this.density;

                if (distance < mouse.radius) {
                    this.x -= directionX;
                    this.y -= directionY;
                }
            }

            draw() {
                ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
                ctx.closePath();
                ctx.fill();
            }
        }

        function init() {
            resizeCanvas();
            particles = [];
            for (let i = 0; i < particleCount; i++) {
                particles.push(new Particle());
            }
        }

        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            particles.forEach(p => {
                p.update();
                p.draw();
            });
            requestAnimationFrame(animate);
        }

        init();
        animate();

        // Password Toggle
        const togglePassword = document.querySelector('#togglePassword');
        const password = document.querySelector('#password');
        togglePassword.addEventListener('click', function (e) {
            const type = password.getAttribute('type') === 'password' ? 'text' : 'password';
            password.setAttribute('type', type);
            this.classList.toggle('fa-eye-slash');
        });
    </script>
</body>
</html>

