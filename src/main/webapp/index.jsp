<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>CAS - College Attendance System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- Import the global theme CSS to match the rest of the application -->
    <link href="css/theme.css?v=4" rel="stylesheet">
    <style>
        body, html {
            overflow-x: hidden;
            scroll-behavior: smooth;
        }

        /* Dynamic Wallpaper Background - Kept from previous request */
        .bg-animated {
            position: fixed;
            top: 0; left: 0;
            width: 100vw; height: 100vh;
            z-index: -1;
            background-size: 400% 400%;
            animation: gradientBG 15s ease infinite;
            opacity: 0.15; /* Reduced opacity so it acts as a subtle pattern behind white cards */
        }
        
        .theme-ocean     { background: linear-gradient(135deg, #0f172a, #1e3a5f, #0d9488, #4f9cf9, #0f172a); }
        .theme-purple    { background: linear-gradient(135deg, #2e0249, #570a57, #a91079, #f806cc, #2e0249); }
        .theme-forest    { background: linear-gradient(135deg, #013220, #004d40, #00897b, #10b981, #013220); }
        .theme-sunset    { background: linear-gradient(135deg, #4c0519, #9f1239, #be123c, #fb7185, #4c0519); }
        .theme-midnight  { background: linear-gradient(135deg, #090d16, #0f172a, #1e293b, #334155, #090d16); }

        @keyframes gradientBG {
            0%   { background-position: 0%   50%; }
            50%  { background-position: 100% 50%; }
            100% { background-position: 0%   50%; }
        }

        /* Navigation Bar aligned with top-header from theme.css */
        .landing-nav {
            position: fixed;
            top: 0; width: 100%;
            background: var(--bg-card);
            border-bottom: 1px solid var(--border);
            padding: 12px 0;
            z-index: 1000;
            box-shadow: var(--shadow-header);
        }

        .landing-nav .nav-links a {
            color: var(--text-body);
            font-weight: 600;
            text-decoration: none;
            margin: 0 15px;
            transition: color 0.2s;
        }

        .landing-nav .nav-links a:hover {
            color: var(--accent);
        }

        /* Marquee aligned with theme */
        .marquee-container {
            background: var(--primary);
            color: #fff;
            padding: 10px 0;
            overflow: hidden;
            position: relative;
            margin-top: 65px; /* Offset for navbar */
        }
        .marquee-content {
            display: inline-block;
            white-space: nowrap;
            animation: marquee 25s linear infinite;
            font-weight: 600;
            letter-spacing: 0.5px;
        }

        @keyframes marquee {
            0%   { transform: translateX(100vw); }
            100% { transform: translateX(-100%); }
        }

        /* Hero Section */
        .hero-section {
            padding: 100px 20px;
            text-align: center;
        }

        .hero-title {
            font-size: 3.5rem;
            font-weight: 800;
            color: var(--primary);
            line-height: 1.15;
            margin-bottom: 20px;
            animation: slideUp 1s ease-out;
        }

        .hero-subtitle {
            font-size: 1.15rem;
            color: var(--text-muted);
            max-width: 650px;
            margin: 0 auto 35px;
            animation: slideUp 1.2s ease-out;
        }

        /* Animations */
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(40px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .reveal { opacity: 0; transform: translateY(60px); transition: all 0.9s cubic-bezier(0.25, 0.46, 0.45, 0.94); }
        .reveal.active { opacity: 1; transform: translateY(0); }
        .reveal-left { opacity: 0; transform: translateX(-80px); transition: all 0.9s cubic-bezier(0.25, 0.46, 0.45, 0.94); }
        .reveal-left.active { opacity: 1; transform: translateX(0); }
        .reveal-right { opacity: 0; transform: translateX(80px); transition: all 0.9s cubic-bezier(0.25, 0.46, 0.45, 0.94); }
        .reveal-right.active { opacity: 1; transform: translateX(0); }
        .delay-1 { transition-delay: 0.1s; }
        .delay-2 { transition-delay: 0.2s; }
        .delay-3 { transition-delay: 0.3s; }

        .content-section {
            padding: 60px 0;
            overflow: hidden;
        }

        .section-title {
            font-size: 2rem;
            font-weight: 800;
            color: var(--primary);
            text-align: center;
            margin-bottom: 40px;
        }

        footer {
            background: var(--primary);
            color: rgba(255,255,255,0.7);
            padding: 40px 0;
            text-align: center;
            margin-top: 50px;
        }
    </style>
</head>
<body>

    <!-- Animated Wallpaper Background (Set to subtle opacity behind the theme elements) -->
    <div class="bg-animated" id="dynamic-bg"></div>

    <!-- Theme-Aligned Navbar -->
    <nav class="landing-nav">
        <div class="container d-flex justify-content-between align-items-center">
            <a href="#" class="d-flex align-items-center text-decoration-none" style="color: var(--primary); font-weight: 800; font-size: 1.3rem;">
                <img src="img/logo.png" alt="CAS Logo" style="height: 40px; width: 40px; object-fit: contain; margin-right: 8px;"> CAS Portal
            </a>
            <div class="d-none d-md-flex nav-links">
                <a href="#about">About</a>
                <a href="#modules">Modules</a>
                <a href="#benefits">Benefits</a>
                <a href="#contact">Contact</a>
                <a href="#developers">Developers</a>
            </div>
            <div>
                <!-- Using the standard btn-cas-primary from theme.css -->
                <a href="login.jsp" class="btn-cas-primary shadow-sm"><i class="bi bi-box-arrow-in-right"></i> Login</a>
            </div>
        </div>
    </nav>

    <!-- Marquee -->
    <div class="marquee-container shadow-sm">
        <div class="marquee-content">
            <i class="bi bi-stars"></i> Welcome to Techno India College Attendance System (CAS) &nbsp;&bull;&nbsp; 
            Smart tracking, instant reports, and seamless management &nbsp;&bull;&nbsp; 
            Empowering faculties and students at Sector-V, Salt Lake &nbsp;&bull;&nbsp; 
            <i class="bi bi-lightning-charge-fill text-warning"></i> Fast, Secure, and Reliable!
        </div>
    </div>

    <!-- Hero Section -->
    <section class="hero-section">
        <div class="container">
            <h1 class="hero-title">Smart Attendance.<br>Simplified.</h1>
            <p class="hero-subtitle">
                Experience the future of academic management. Track attendance, manage routines, and generate insightful reports instantly with our state-of-the-art platform designed for Techno India.
            </p>
            <div style="animation: slideUp 1.4s ease-out;">
                <a href="login.jsp" class="btn-cas-primary" style="padding: 12px 35px; font-size: 1.1rem;">
                    Access Portal <i class="bi bi-arrow-right"></i>
                </a>
            </div>
        </div>
    </section>

    <!-- About Section -->
    <section id="about" class="content-section">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-10 reveal">
                    <h2 class="section-title">About CAS</h2>
                    <!-- Using panel-card from theme.css -->
                    <div class="panel-card p-4 p-md-5">
                        <p style="color: var(--text-body); font-size: 1.05rem; line-height: 1.8;" class="text-center mb-5">
                            The College Attendance System (CAS) is designed to streamline the academic workflow for administrators, faculty, and students. By moving away from manual roll calls and paper-based tracking, CAS introduces a fully digital, highly secure, and instant attendance management ecosystem.
                        </p>
                        <div class="row g-4">
                            <div class="col-md-4 reveal delay-1">
                                <!-- Standard theme metric card layout -->
                                <div class="metric-card h-100 flex-column align-items-center text-center p-4">
                                    <div class="metric-icon icon-green mb-3"><i class="bi bi-calendar-check"></i></div>
                                    <div class="metric-info">
                                        <h6 class="fw-bold m-0" style="color: var(--text-heading);">Automated Routine</h6>
                                        <p class="mt-2 text-muted">Live timetable integration directly from the administrative database.</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4 reveal delay-2">
                                <div class="metric-card h-100 flex-column align-items-center text-center p-4">
                                    <div class="metric-icon icon-amber mb-3"><i class="bi bi-graph-up-arrow"></i></div>
                                    <div class="metric-info">
                                        <h6 class="fw-bold m-0" style="color: var(--text-heading);">Defaulter Tracking</h6>
                                        <p class="mt-2 text-muted">Real-time attendance metrics ensuring compliance with university standards.</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4 reveal delay-3">
                                <div class="metric-card h-100 flex-column align-items-center text-center p-4">
                                    <div class="metric-icon icon-navy mb-3"><i class="bi bi-shield-lock"></i></div>
                                    <div class="metric-info">
                                        <h6 class="fw-bold m-0" style="color: var(--text-heading);">Secure Access</h6>
                                        <p class="mt-2 text-muted">Strict role-based management isolating student, teacher, and admin data.</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Modules Section -->
    <section id="modules" class="content-section" style="background: rgba(255,255,255,0.4); border-top: 1px solid var(--border); border-bottom: 1px solid var(--border);">
        <div class="container">
            <h2 class="section-title reveal">System Modules</h2>
            <div class="row g-4 justify-content-center">
                <!-- Admin Module -->
                <div class="col-md-4 reveal-left">
                    <div class="panel-card h-100 text-center p-4">
                        <div class="metric-icon icon-rose mx-auto mb-3" style="width:60px;height:60px;font-size:2rem;"><i class="bi bi-person-gear"></i></div>
                        <h5 class="fw-bold mb-3" style="color: var(--primary);">Administrator</h5>
                        <ul class="list-unstyled text-start text-muted mb-0 mx-auto" style="max-width: 250px; font-size: 0.95rem;">
                            <li class="mb-2"><i class="bi bi-check2-circle text-success me-2"></i> Manage students & faculty</li>
                            <li class="mb-2"><i class="bi bi-check2-circle text-success me-2"></i> Dynamic timetable builder</li>
                            <li class="mb-2"><i class="bi bi-check2-circle text-success me-2"></i> Global notification system</li>
                            <li class="mb-0"><i class="bi bi-check2-circle text-success me-2"></i> System configuration</li>
                        </ul>
                    </div>
                </div>
                <!-- Faculty Module -->
                <div class="col-md-4 reveal delay-1">
                    <div class="panel-card h-100 text-center p-4 border-primary shadow-sm" style="border-width: 2px;">
                        <div class="metric-icon icon-blue mx-auto mb-3" style="width:60px;height:60px;font-size:2rem;"><i class="bi bi-person-workspace"></i></div>
                        <h5 class="fw-bold mb-3" style="color: var(--primary);">Faculty</h5>
                        <ul class="list-unstyled text-start text-muted mb-0 mx-auto" style="max-width: 250px; font-size: 0.95rem;">
                            <li class="mb-2"><i class="bi bi-check2-circle text-success me-2"></i> Real-time attendance</li>
                            <li class="mb-2"><i class="bi bi-check2-circle text-success me-2"></i> Auto defaulter lists</li>
                            <li class="mb-2"><i class="bi bi-check2-circle text-success me-2"></i> Manage student leaves</li>
                            <li class="mb-0"><i class="bi bi-check2-circle text-success me-2"></i> Personalized routine</li>
                        </ul>
                    </div>
                </div>
                <!-- Student Module -->
                <div class="col-md-4 reveal-right">
                    <div class="panel-card h-100 text-center p-4">
                        <div class="metric-icon icon-teal mx-auto mb-3" style="width:60px;height:60px;font-size:2rem;"><i class="bi bi-mortarboard"></i></div>
                        <h5 class="fw-bold mb-3" style="color: var(--primary);">Students</h5>
                        <ul class="list-unstyled text-start text-muted mb-0 mx-auto" style="max-width: 250px; font-size: 0.95rem;">
                            <li class="mb-2"><i class="bi bi-check2-circle text-success me-2"></i> Live attendance tracker</li>
                            <li class="mb-2"><i class="bi bi-check2-circle text-success me-2"></i> View class timetable</li>
                            <li class="mb-2"><i class="bi bi-check2-circle text-success me-2"></i> Digital leave application</li>
                            <li class="mb-0"><i class="bi bi-check2-circle text-success me-2"></i> Teacher announcements</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Benefits Section -->
    <section id="benefits" class="content-section">
        <div class="container">
            <h2 class="section-title reveal">Why Choose CAS?</h2>
            <div class="row g-4 align-items-center mt-3">
                <div class="col-lg-6 reveal-left">
                    <div class="panel-card h-100 d-flex align-items-center justify-content-center" style="background: var(--bg-card); min-height: 380px;">
                        <div style="width: 280px; height: 280px; background: rgba(79,156,249,0.1); border-radius: 30px; display: flex; align-items: center; justify-content: center; border: 2px solid rgba(79,156,249,0.3); box-shadow: 0 0 40px rgba(79,156,249,0.15);">
                            <img src="img/logo.png" alt="CAS Logo" style="width: 200px; height: 200px; object-fit: contain;">
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 reveal-right ps-lg-5 mt-5 mt-lg-0">
                    <div class="mb-4 panel-card p-4">
                        <div class="d-flex align-items-center mb-2">
                            <div class="metric-icon icon-blue me-3" style="width:40px;height:40px;font-size:1.2rem;"><i class="bi bi-cloud-check-fill"></i></div>
                            <h5 class="fw-bold m-0" style="color: var(--primary);">100% Cloud-Based</h5>
                        </div>
                        <p class="text-muted ms-5 mb-0" style="font-size: 0.95rem;">No installation required. Access the portal securely from any device, anywhere, at any time.</p>
                    </div>
                    <div class="mb-4 panel-card p-4">
                        <div class="d-flex align-items-center mb-2">
                            <div class="metric-icon icon-amber me-3" style="width:40px;height:40px;font-size:1.2rem;"><i class="bi bi-lightning-charge-fill"></i></div>
                            <h5 class="fw-bold m-0" style="color: var(--primary);">Instant Synchronization</h5>
                        </div>
                        <p class="text-muted ms-5 mb-0" style="font-size: 0.95rem;">As soon as a teacher marks attendance, it instantly reflects on the student and coordinator dashboards.</p>
                    </div>
                    <div class="mb-0 panel-card p-4">
                        <div class="d-flex align-items-center mb-2">
                            <div class="metric-icon icon-green me-3" style="width:40px;height:40px;font-size:1.2rem;"><i class="bi bi-tree-fill"></i></div>
                            <h5 class="fw-bold m-0" style="color: var(--primary);">Eco-Friendly & Paperless</h5>
                        </div>
                        <p class="text-muted ms-5 mb-0" style="font-size: 0.95rem;">Completely eliminate paper-based roll calls, physical leave letters, and manual data entry errors.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Contact Us Section -->
    <section id="contact" class="content-section">
        <div class="container">
            <h2 class="section-title reveal">Contact Us</h2>
            <div class="row g-4 justify-content-center">
                
                <!-- Campus Address -->
                <div class="col-lg-6 reveal-left">
                    <div class="panel-card h-100">
                        <div class="panel-card-header bg-light">
                            <h5 class="m-0"><i class="bi bi-geo-alt-fill me-2 text-primary"></i>Campus Details</h5>
                        </div>
                        <div class="panel-card-body">
                            <div class="mb-4">
                                <span class="form-label-custom">Campus Address</span>
                                <h6 class="fw-bold" style="color: var(--primary);">TECHNO INDIA</h6>
                                <p class="text-muted mb-2">EM-4/1, Sector-V, Salt Lake,<br>Kolkata-700091, WB</p>
                                <p class="mb-1"><i class="bi bi-telephone-fill me-2 text-primary"></i> 033-23575683 / 84 / 86</p>
                                <p class="mb-0"><i class="bi bi-envelope-fill me-2 text-primary"></i> info@ticollege.ac.in, principal@ticollege.ac.in</p>
                            </div>

                            <hr style="border-color: var(--border);">

                            <div class="row mt-4">
                                <div class="col-sm-6 mb-3 mb-sm-0">
                                    <span class="form-label-custom">Helpline No</span>
                                    <p class="text-muted small mb-0 fw-semibold">91 9836544416 / 91 9836544417</p>
                                    <p class="text-muted small mb-0 fw-semibold">91 9836544418 / 91 9836544419</p>
                                </div>
                                <div class="col-sm-6">
                                    <span class="form-label-custom" style="color: #16a34a;">WhatsApp</span>
                                    <p class="small mb-0 fw-bold" style="color: #16a34a;">+91 8335061253</p>
                                    <p class="small mb-0 fw-bold" style="color: #16a34a;">+91 9836544419</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Admission Office -->
                <div class="col-lg-6 reveal-right">
                    <div class="panel-card h-100">
                        <div class="panel-card-header bg-light">
                            <h5 class="m-0"><i class="bi bi-building me-2 text-primary"></i>Admission Office</h5>
                        </div>
                        <div class="panel-card-body">
                            <div class="mb-4 p-3 rounded" style="background: var(--bg-input); border: 1px solid var(--border);">
                                <h6 class="fw-bold" style="color: var(--primary);">1. TECHNO INDIA CHINGRIGHATA CAMPUS</h6>
                                <p class="text-muted mb-1" style="font-size: 0.9rem;">
                                    LB 10, EM Bypass, Sector 3, Chingrighata, Kolkata 700098, WB.
                                </p>
                                <span class="badge-cas badge-warning"><i class="bi bi-info-circle me-1"></i>Beside Leather Technology College [Service Road]</span>
                            </div>

                            <div class="p-3 rounded" style="background: var(--bg-input); border: 1px solid var(--border);">
                                <h6 class="fw-bold" style="color: var(--primary);">2. TECHNO INDIA (2nd Floor)</h6>
                                <p class="text-muted mb-0" style="font-size: 0.9rem;">
                                    EM-4/1, Sector-V, Salt Lake, Kolkata-700091, WB.
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </section>

    <!-- Developers Section -->
    <section id="developers" class="content-section">
        <div class="container text-center">
            <h2 class="section-title reveal">Meet The Developers</h2>
            <div class="d-flex flex-wrap justify-content-center gap-3 reveal delay-1">
                <!-- Using badge-cas from theme.css -->
                <span class="badge-cas badge-navy px-3 py-2 fs-6"><i class="bi bi-code-slash"></i> Aritra Paul</span>
                <span class="badge-cas badge-navy px-3 py-2 fs-6"><i class="bi bi-cpu-fill"></i> Aritra Sengupta</span>
                <span class="badge-cas badge-navy px-3 py-2 fs-6"><i class="bi bi-palette-fill"></i> Anika Zahin</span>
                <span class="badge-cas badge-navy px-3 py-2 fs-6"><i class="bi bi-database-fill"></i> Ankan Shamanta</span>
            </div>
        </div>
    </section>

    <footer>
        <div class="container">
            <div class="d-flex align-items-center justify-content-center mb-3">
                <i class="bi bi-fingerprint me-2" style="font-size: 1.5rem;"></i>
                <span class="fw-bold fs-5">CAS</span>
            </div>
            <p style="font-size: 0.85rem; margin: 0;">
                &copy; <%= java.util.Calendar.getInstance().get(java.util.Calendar.YEAR) %> Techno India College Attendance System. All rights reserved.
            </p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Dynamic Wallpaper logic - changes on refresh
        const themes = ['theme-ocean', 'theme-purple', 'theme-forest', 'theme-sunset', 'theme-midnight'];
        const lastTheme = localStorage.getItem('cas-theme');
        const availableThemes = themes.filter(t => t !== lastTheme);
        const picked = availableThemes[Math.floor(Math.random() * availableThemes.length)];
        
        localStorage.setItem('cas-theme', picked);
        document.getElementById('dynamic-bg').classList.add(picked);

        // Slide-In Animations Observer
        const observerOptions = { threshold: 0.1, rootMargin: "0px 0px -50px 0px" };
        const observer = new IntersectionObserver(function(entries, observer) {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('active');
                    observer.unobserve(entry.target);
                }
            });
        }, observerOptions);

        const reveals = document.querySelectorAll('.reveal, .reveal-left, .reveal-right');
        reveals.forEach(el => observer.observe(el));
    </script>
</body>
</html>
