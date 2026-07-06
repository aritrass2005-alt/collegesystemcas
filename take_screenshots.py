"""
Comprehensive Screenshot Testing Script for College Attendance System (CAS)
Takes screenshots of ALL pages with correct and incorrect inputs.
Organized into folders by role.
"""
import asyncio
from playwright.async_api import async_playwright
import os
import time

BASE_URL = "http://localhost:8080/webapp"
SCREENSHOT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "screenshots")

# Credentials
ADMIN_EMAIL = "super@college.edu"
ADMIN_PASS = "admin123"
TEACHER_EMAIL = "sarbanis472@gmail.com"
TEACHER_PASS = "123456"  # common test password
STUDENT_ROLL = "22642723053"
STUDENT_PASS = "123456"  # common test password

async def ensure_dir(folder):
    path = os.path.join(SCREENSHOT_DIR, folder)
    os.makedirs(path, exist_ok=True)
    return path

async def screenshot(page, name, folder):
    path = os.path.join(SCREENSHOT_DIR, folder, f"{name}.png")
    os.makedirs(os.path.join(SCREENSHOT_DIR, folder), exist_ok=True)
    await page.screenshot(path=path, full_page=True)
    print(f"  [OK] {folder}/{name}.png")

async def login(page, role, identifier, password):
    """Login helper - returns True if login succeeded (redirected away from login page)"""
    await page.goto(f"{BASE_URL}/login.jsp", wait_until="networkidle")
    await page.wait_for_timeout(500)
    
    # Select role
    await page.select_option("select[name='role']", role)
    await page.wait_for_timeout(300)
    
    # Fill credentials
    await page.fill("input[name='identifier']", identifier)
    await page.fill("input[name='password']", password)
    await page.click("button[type='submit']")
    await page.wait_for_timeout(2000)
    
    return "login" not in page.url.lower()

async def logout(page):
    try:
        await page.goto(f"{BASE_URL}/logout", wait_until="networkidle")
        await page.wait_for_timeout(500)
    except:
        pass

async def run():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(viewport={'width': 1366, 'height': 768})
        page = await context.new_page()

        # ================================================================
        # 00 - INDEX / LANDING PAGE
        # ================================================================
        print("\n=== 00_Index ===")
        await ensure_dir("00_Index")
        await page.goto(f"{BASE_URL}/", wait_until="networkidle")
        await page.wait_for_timeout(1000)
        await screenshot(page, "01_landing_page", "00_Index")

        # ================================================================
        # 01 - LOGIN PAGE
        # ================================================================
        print("\n=== 01_Login ===")
        await ensure_dir("01_Login")
        
        # Login page (blank)
        await page.goto(f"{BASE_URL}/login.jsp", wait_until="networkidle")
        await page.wait_for_timeout(1000)
        await screenshot(page, "01_login_page_student", "01_Login")
        
        # Switch to Teacher view
        await page.select_option("select[name='role']", "Teacher")
        await page.wait_for_timeout(500)
        await screenshot(page, "02_login_page_teacher", "01_Login")
        
        # Switch to Admin view
        await page.select_option("select[name='role']", "Admin")
        await page.wait_for_timeout(500)
        await screenshot(page, "03_login_page_admin", "01_Login")
        
        # Wrong login - Student (wrong roll)
        await page.select_option("select[name='role']", "Student")
        await page.wait_for_timeout(300)
        await page.fill("input[name='identifier']", "WRONG12345")
        await page.fill("input[name='password']", "wrongpass")
        await page.click("button[type='submit']")
        await page.wait_for_timeout(1500)
        await screenshot(page, "04_login_wrong_student", "01_Login")
        
        # Wrong login - Admin (wrong email)
        await page.goto(f"{BASE_URL}/login.jsp", wait_until="networkidle")
        await page.select_option("select[name='role']", "Admin")
        await page.wait_for_timeout(300)
        await page.fill("input[name='identifier']", "wrong@college.edu")
        await page.fill("input[name='password']", "wrongpass")
        await page.click("button[type='submit']")
        await page.wait_for_timeout(1500)
        await screenshot(page, "05_login_wrong_admin", "01_Login")
        
        # Wrong login - Teacher (wrong email)
        await page.goto(f"{BASE_URL}/login.jsp", wait_until="networkidle")
        await page.select_option("select[name='role']", "Teacher")
        await page.wait_for_timeout(300)
        await page.fill("input[name='identifier']", "wrong@college.edu")
        await page.fill("input[name='password']", "wrongpass")
        await page.click("button[type='submit']")
        await page.wait_for_timeout(1500)
        await screenshot(page, "06_login_wrong_teacher", "01_Login")

        # Teacher Register page
        await page.goto(f"{BASE_URL}/teacher_register.jsp", wait_until="networkidle")
        await page.wait_for_timeout(1000)
        await screenshot(page, "07_teacher_register_page", "01_Login")

        # ================================================================
        # 02 - ADMIN PAGES
        # ================================================================
        print("\n=== 02_Admin ===")
        await ensure_dir("02_Admin")
        
        success = await login(page, "Admin", ADMIN_EMAIL, ADMIN_PASS)
        if success:
            print("  Admin login successful!")
            
            # Dashboard
            await screenshot(page, "01_admin_dashboard", "02_Admin")
            
            # Manage Students
            await page.goto(f"{BASE_URL}/manageStudents", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "02_admin_manage_students", "02_Admin")
            
            # Manage Teachers
            await page.goto(f"{BASE_URL}/manageTeachers", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "03_admin_manage_teachers", "02_Admin")
            
            # Manage Subjects
            await page.goto(f"{BASE_URL}/manageSubjects", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "04_admin_manage_subjects", "02_Admin")
            
            # Manage Coordinators
            await page.goto(f"{BASE_URL}/manageCoordinator", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "05_admin_manage_coordinators", "02_Admin")
            
            # Admin Attendance Override
            await page.goto(f"{BASE_URL}/adminAttendance", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "06_admin_attendance_override", "02_Admin")
            
            # Faculty Attendance
            await page.goto(f"{BASE_URL}/adminFacultyAttendance", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "07_admin_faculty_attendance", "02_Admin")
            
            # Bulk Upload
            await page.goto(f"{BASE_URL}/bulkUpload", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "08_admin_bulk_upload", "02_Admin")
            
            # Admin Notifications
            await page.goto(f"{BASE_URL}/sendNotification", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "09_admin_notifications", "02_Admin")
            
            # Manage Admins
            await page.goto(f"{BASE_URL}/manageAdmins", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "10_admin_manage_admins", "02_Admin")
            
            # Admin Config
            await page.goto(f"{BASE_URL}/admin_config.jsp", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "11_admin_config", "02_Admin")
            
            # Admin Timetable
            await page.goto(f"{BASE_URL}/manageTimetable", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "12_admin_timetable", "02_Admin")
            
            # Admin Activity Log
            await page.goto(f"{BASE_URL}/adminLogs", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "13_admin_activity_log", "02_Admin")
            
            # Admin Appeals
            await page.goto(f"{BASE_URL}/adminAppeals", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "14_admin_appeals", "02_Admin")
            
            # Admin Profile
            await page.goto(f"{BASE_URL}/adminProfile", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "15_admin_profile", "02_Admin")
            
            # DB Tools
            await page.goto(f"{BASE_URL}/dbTools", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "16_admin_db_tools", "02_Admin")
            
            await logout(page)
        else:
            print("  [WARN] Admin login failed - skipping admin pages")

        # ================================================================
        # 03 - FACULTY/TEACHER PAGES
        # ================================================================
        print("\n=== 03_Faculty ===")
        await ensure_dir("03_Faculty")
        
        # Try multiple teacher passwords
        teacher_logged_in = False
        for pwd in [TEACHER_PASS, "teacher123", "Sarbani@123", "password"]:
            success = await login(page, "Teacher", TEACHER_EMAIL, pwd)
            if success:
                print(f"  Teacher login successful with password!")
                teacher_logged_in = True
                break
            await page.goto(f"{BASE_URL}/login.jsp", wait_until="networkidle")
        
        # Try alternate teacher
        if not teacher_logged_in:
            for pwd in ["teacher123", "123456", "password"]:
                success = await login(page, "Teacher", "john.doe@college.edu", pwd)
                if success:
                    print(f"  Teacher login successful with john.doe!")
                    teacher_logged_in = True
                    break
                await page.goto(f"{BASE_URL}/login.jsp", wait_until="networkidle")
        
        if teacher_logged_in:
            # Dashboard
            await page.goto(f"{BASE_URL}/teacher_dashboard.jsp", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "01_teacher_dashboard", "03_Faculty")
            
            # Take Attendance
            await page.goto(f"{BASE_URL}/takeAttendance", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "02_teacher_take_attendance", "03_Faculty")
            
            # View Attendance
            await page.goto(f"{BASE_URL}/teacherAttendanceView", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "03_teacher_view_attendance", "03_Faculty")
            
            # Defaulter List
            await page.goto(f"{BASE_URL}/teacherDefaulterList", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "04_teacher_defaulter_list", "03_Faculty")
            
            # Student View
            await page.goto(f"{BASE_URL}/teacherStudentView", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "05_teacher_student_view", "03_Faculty")
            
            # My Attendance (Faculty Attendance)
            await page.goto(f"{BASE_URL}/facultyAttendance", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "06_teacher_my_attendance", "03_Faculty")
            
            # Teacher Timetable
            await page.goto(f"{BASE_URL}/teacherTimetable", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "07_teacher_timetable", "03_Faculty")
            
            # Teacher Profile
            await page.goto(f"{BASE_URL}/teacherProfile", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "08_teacher_profile", "03_Faculty")
            
            await logout(page)
        else:
            print("  [WARN] Teacher login failed - skipping teacher pages")

        # ================================================================
        # 04 - STUDENT PAGES
        # ================================================================
        print("\n=== 04_Student ===")
        await ensure_dir("04_Student")
        
        student_logged_in = False
        for roll, pwd in [(STUDENT_ROLL, "123456"), (STUDENT_ROLL, "password"), 
                           ("22642723053", "Aritra@123"), ("22642723053", "aritra2005"),
                           ("CS202001", "15082002"), ("CS202001", "123456")]:
            success = await login(page, "Student", roll, pwd)
            if success:
                print(f"  Student login successful with roll={roll}!")
                student_logged_in = True
                break
            await page.goto(f"{BASE_URL}/login.jsp", wait_until="networkidle")
        
        if student_logged_in:
            # Dashboard
            await screenshot(page, "01_student_dashboard", "04_Student")
            
            # View Attendance
            await page.goto(f"{BASE_URL}/viewAttendance", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "02_student_view_attendance", "04_Student")
            
            # Leave Application
            await page.goto(f"{BASE_URL}/studentLeave", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "03_student_leave_application", "04_Student")
            
            # Timetable
            await page.goto(f"{BASE_URL}/studentTimetable", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "04_student_timetable", "04_Student")
            
            # Student Notifications
            await page.goto(f"{BASE_URL}/student_notifications.jsp", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "05_student_notifications", "04_Student")
            
            # Student Profile
            await page.goto(f"{BASE_URL}/studentProfile", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "06_student_profile", "04_Student")
            
            await logout(page)
        else:
            print("  [WARN] Student login failed - skipping student pages")

        # ================================================================
        # 05 - COORDINATOR PAGES
        # ================================================================
        print("\n=== 05_Coordinator ===")
        await ensure_dir("05_Coordinator")
        
        # Coordinator is a teacher with coordinator role
        coord_logged_in = False
        for email, pwd in [("sarbanis472@gmail.com", "123456"), ("sarbanis472@gmail.com", "teacher123"),
                            ("john.doe@college.edu", "teacher123"), ("john.doe@college.edu", "123456")]:
            success = await login(page, "Teacher", email, pwd)
            if success:
                # Check if coordinator pages work
                await page.goto(f"{BASE_URL}/coordinatorDashboard", wait_until="networkidle")
                await page.wait_for_timeout(1000)
                if "error" not in page.url.lower() and "login" not in page.url.lower():
                    print(f"  Coordinator login successful with {email}!")
                    coord_logged_in = True
                    break
            await logout(page)
            await page.goto(f"{BASE_URL}/login.jsp", wait_until="networkidle")
        
        if coord_logged_in:
            # Dashboard
            await screenshot(page, "01_coordinator_dashboard", "05_Coordinator")
            
            # Coordinator Attendance View
            await page.goto(f"{BASE_URL}/coordinatorAttendanceView", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "02_coordinator_attendance_view", "05_Coordinator")
            
            # Coordinator Defaulters
            await page.goto(f"{BASE_URL}/coordinatorDefaulterList", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "03_coordinator_defaulters", "05_Coordinator")
            
            # Coordinator Leaves
            await page.goto(f"{BASE_URL}/coordinatorLeaves", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "04_coordinator_leaves", "05_Coordinator")
            
            # Coordinator Students
            await page.goto(f"{BASE_URL}/coordinatorStudents", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "05_coordinator_students", "05_Coordinator")
            
            # Coordinator Notifications
            await page.goto(f"{BASE_URL}/coordinator_notifications.jsp", wait_until="networkidle")
            await page.wait_for_timeout(1000)
            await screenshot(page, "06_coordinator_notifications", "05_Coordinator")
            
            await logout(page)
        else:
            print("  [WARN] Coordinator login failed - skipping coordinator pages")

        await browser.close()
        
        # ================================================================
        # SUMMARY
        # ================================================================
        print("\n" + "="*60)
        print("SCREENSHOT SUMMARY")
        print("="*60)
        total = 0
        for folder in sorted(os.listdir(SCREENSHOT_DIR)):
            folder_path = os.path.join(SCREENSHOT_DIR, folder)
            if os.path.isdir(folder_path):
                files = [f for f in os.listdir(folder_path) if f.endswith('.png')]
                total += len(files)
                print(f"  {folder}: {len(files)} screenshots")
                for f in sorted(files):
                    print(f"    - {f}")
        print(f"\nTotal screenshots: {total}")
        print(f"Location: {SCREENSHOT_DIR}")

if __name__ == '__main__':
    asyncio.run(run())
