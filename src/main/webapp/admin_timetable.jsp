<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.*,java.util.*,java.text.SimpleDateFormat" %>
<%
    if (session.getAttribute("user")==null||(!("Admin".equals(session.getAttribute("role")))&&!("SuperAdmin".equals(session.getAttribute("role"))))) {
        response.sendRedirect("login.jsp"); return;
    }
    List<Timetable>  timetables  = (List<Timetable>)  request.getAttribute("timetables");
    List<Subject>    subjects    = (List<Subject>)    request.getAttribute("subjects");
    List<ConfigData> departments = (List<ConfigData>) request.getAttribute("departments");
    List<ConfigData> sections    = (List<ConfigData>) request.getAttribute("sections");
    List<ConfigData> years       = (List<ConfigData>) request.getAttribute("years");
    List<Teacher> teachers       = (List<Teacher>) request.getAttribute("teachers");
    String fd = request.getAttribute("filterDept")    != null ? (String)request.getAttribute("filterDept")    : "";
    String fy = request.getAttribute("filterYear")    != null ? (String)request.getAttribute("filterYear")    : "";
    String fs = request.getAttribute("filterSection") != null ? (String)request.getAttribute("filterSection") : "";
    boolean hasFilter = !fd.isEmpty() && !fy.isEmpty();
    String[] DAYS = {"Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
    SimpleDateFormat tf = new SimpleDateFormat("hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Routine Builder – CAS Admin</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
<link href="css/theme.css?v=3" rel="stylesheet">
<style>
/* ── Step wizard ── */
.step-wizard{display:flex;gap:0;margin-bottom:28px;border:1px solid var(--border);border-radius:var(--radius-lg);overflow:hidden;background:var(--bg-card);box-shadow:var(--shadow-card);}
.step{flex:1;padding:16px 20px;display:flex;align-items:center;gap:12px;border-right:1px solid var(--border);cursor:default;}
.step:last-child{border-right:none;}
.step-num{width:32px;height:32px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:.8rem;font-weight:700;flex-shrink:0;background:var(--border);color:var(--text-muted);}
.step.active .step-num{background:var(--primary);color:#fff;}
.step.done .step-num{background:#16a34a;color:#fff;}
.step-label{font-size:.82rem;font-weight:600;color:var(--text-muted);line-height:1.3;}
.step.active .step-label{color:var(--primary);}
.step.done .step-label{color:#16a34a;}

/* ── Filter card ── */
.filter-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-lg);padding:20px 24px;margin-bottom:20px;box-shadow:var(--shadow-card);}
.filter-card h6{font-weight:700;color:var(--text-heading);margin-bottom:14px;}

/* ── Day grid ── */
.day-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:16px;}
.day-col{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-lg);overflow:visible;box-shadow:var(--shadow-card);}
.day-col-header{padding:12px 16px;background:linear-gradient(135deg,#1e3a5f,#0f2240);display:flex;align-items:center;justify-content:space-between;}
.day-col-header span{color:#fff;font-weight:700;font-size:.9rem;}
.day-slots{padding:10px;}
.slot-item{background:var(--bg-input);border:1px solid var(--border);border-radius:var(--radius-md);padding:10px 12px;margin-bottom:8px;display:flex;align-items:center;justify-content:space-between;gap:8px;}
.slot-item:last-child{margin-bottom:0;}
.slot-info{flex:1;}
.slot-subject{font-weight:700;font-size:.85rem;color:var(--text-heading);}
.slot-time{font-size:.75rem;color:var(--text-muted);margin-top:1px;}
.slot-teacher{font-size:.75rem;color:#16a34a;margin-top:1px;}
.slot-room{display:inline-block;font-size:.7rem;background:rgba(30,58,95,.08);color:var(--primary);padding:1px 7px;border-radius:50px;margin-top:3px;}
.no-slots{text-align:center;padding:20px;color:var(--text-muted);font-size:.82rem;opacity:.7;}

/* ── Add slot btn ── */
.btn-add-slot{width:100%;border:1.5px dashed var(--border);border-radius:var(--radius-md);padding:8px;background:transparent;color:var(--text-muted);font-size:.82rem;cursor:pointer;transition:all .2s;margin-top:8px;}
.btn-add-slot:hover{border-color:var(--primary);color:var(--primary);background:rgba(30,58,95,.04);}

/* ── Modal ── */
.modal-content{border-radius:var(--radius-xl)!important;border:0;}
.modal-header{background:linear-gradient(135deg,#1e3a5f,#0f2240);border-radius:var(--radius-xl) var(--radius-xl) 0 0!important;padding:18px 24px;}
.modal-title{color:#fff;font-weight:700;}
.modal-body{padding:22px;}
.modal-footer{border-top:1px solid var(--border);padding:14px 22px;}
.teacher-autofill{background:#f0fdf4;border:1px solid #bbf7d0;border-radius:var(--radius-md);padding:8px 12px;font-size:.82rem;color:#166534;display:none;margin-top:6px;}

/* ── Info panels ── */
.prompt-card{background:linear-gradient(135deg,rgba(30,58,95,.07),rgba(79,156,249,.06));border:1px solid rgba(30,58,95,.12);border-radius:var(--radius-lg);padding:32px;text-align:center;color:var(--text-muted);}
.prompt-card i{font-size:3rem;opacity:.3;display:block;margin-bottom:12px;}

/* subject count badge */
.subject-count{display:inline-flex;align-items:center;gap:5px;padding:3px 10px;background:rgba(79,156,249,.12);color:#2563eb;border-radius:50px;font-size:.75rem;font-weight:600;}
</style>
</head>
<body>
<jsp:include page="includes/admin_sidebar.jsp"/>
<div id="content-wrapper">
<jsp:include page="includes/admin_header.jsp"/>
<div class="container-fluid p-0">

<!-- Page Title -->
<div class="page-title-row">
  <div>
    <h1 class="page-title"><i class="bi bi-calendar2-week-fill me-2 text-primary"></i>Routine Builder</h1>
    <p class="page-subtitle">Build and manage class routines per department, year &amp; section</p>
  </div>
  <% if(hasFilter){ %>
  <div class="d-flex gap-2 align-items-center">
    <span class="subject-count"><i class="bi bi-journals"></i><%= subjects!=null?subjects.size():0 %> subjects</span>
    <span class="subject-count" style="background:rgba(22,163,74,.1);color:#166534;"><i class="bi bi-clock-history"></i><%= timetables!=null?timetables.size():0 %> slots</span>
    <form action="manageTimetable" method="post" onsubmit="return confirm('Clear ALL routine slots for this group? This cannot be undone.');">
      <input type="hidden" name="action"  value="clear_group">
      <input type="hidden" name="dept"    value="<%= fd %>">
      <input type="hidden" name="year"    value="<%= fy %>">
      <input type="hidden" name="section" value="<%= fs %>">
      <button type="submit" class="btn btn-sm btn-outline-danger"><i class="bi bi-trash3"></i> Clear All</button>
    </form>
  </div>
  <% } %>
</div>

<!-- Alerts -->
<% if(request.getParameter("msg")!=null){ %><div class="alert-cas alert-cas-success mb-3"><i class="bi bi-check-circle-fill"></i> <%=request.getParameter("msg")%></div><% } %>
<% if(request.getParameter("error")!=null){ %><div class="alert-cas alert-cas-error mb-3"><i class="bi bi-exclamation-circle-fill"></i> <%=request.getParameter("error")%></div><% } %>

<!-- Step Wizard -->
<div class="step-wizard">
  <div class="step <%= hasFilter?"done":"active" %>">
    <div class="step-num"><%= hasFilter?"<i class='bi bi-check-lg'></i>":"1" %></div>
    <div><div class="step-label">Select Group</div><div style="font-size:.72rem;color:var(--text-muted);">Dept · Year · Section</div></div>
  </div>
  <div class="step <%= hasFilter?"active":"" %>">
    <div class="step-num">2</div>
    <div><div class="step-label">Build Routine</div><div style="font-size:.72rem;color:var(--text-muted);">Add slots across 6 days</div></div>
  </div>
  <div class="step">
    <div class="step-num">3</div>
    <div><div class="step-label">Published</div><div style="font-size:.72rem;color:var(--text-muted);">Students &amp; teachers see it</div></div>
  </div>
</div>

<!-- STEP 1: Filter Bar -->
<div class="filter-card">
  <h6><i class="bi bi-funnel-fill me-2 text-primary"></i>Step 1 — Select the Class Group</h6>
  <form action="manageTimetable" method="get" id="filterForm">
    <div class="row g-3 align-items-end">
      <div class="col-md-3">
        <label class="form-label small fw-semibold">Department *</label>
        <select name="dept" class="form-select" required onchange="this.form.submit()">
          <option value="">— Choose Department —</option>
          <% if(departments!=null){for(ConfigData d:departments){ %>
            <option value="<%=d.getName()%>" <%=fd.equals(d.getName())?"selected":""%>><%=d.getName()%></option>
          <%}} %>
        </select>
      </div>
      <div class="col-md-3">
        <label class="form-label small fw-semibold">Year *</label>
        <select name="year" class="form-select" required onchange="this.form.submit()">
          <option value="">— Choose Year —</option>
          <% if(years!=null){for(ConfigData y:years){ %>
            <option value="<%=y.getName()%>" <%=fy.equals(y.getName())?"selected":""%>><%=y.getName()%></option>
          <%}} %>
        </select>
      </div>
      <div class="col-md-3">
        <label class="form-label small fw-semibold">Section <span class="text-muted">(optional)</span></label>
        <select name="section" class="form-select" onchange="this.form.submit()">
          <option value="">All Sections</option>
          <% if(sections!=null){for(ConfigData s:sections){ %>
            <option value="<%=s.getName()%>" <%=fs.equals(s.getName())?"selected":""%>><%=s.getName()%></option>
          <%}} %>
        </select>
      </div>
      <div class="col-md-3 d-flex gap-2">
        <button type="submit" class="btn-cas-primary flex-fill"><i class="bi bi-check2-circle"></i> Apply</button>
        <% if(hasFilter){ %><a href="manageTimetable" class="btn-cas-outline"><i class="bi bi-x-lg"></i></a><% } %>
      </div>
    </div>
  </form>
</div>

<!-- STEP 2: Weekly Grid -->
<% if(hasFilter){ %>

<!-- Quick-add subject link -->
<div class="d-flex align-items-center gap-2 mb-3">
  <span class="text-muted small">Need a new subject?</span>
  <a href="manageSubjects?dept=<%=fd%>&year=<%=fy%>&section=<%=fs%>" class="btn btn-sm btn-outline-primary" style="border-radius:6px;">
    <i class="bi bi-journal-plus"></i> Add Subject for this Group
  </a>
</div>

<div class="day-grid">
  <% for(String day : DAYS) {
       // collect slots for this day
       List<Timetable> daySlots = new ArrayList<>();
       if(timetables!=null){ for(Timetable t:timetables){ if(day.equals(t.getDayOfWeek())) daySlots.add(t); }}
       // sort by start time
       daySlots.sort((a,b)->{ if(a.getStartTime()==null) return 1; if(b.getStartTime()==null) return -1; return a.getStartTime().compareTo(b.getStartTime()); });
  %>
  <div class="day-col">
    <div class="day-col-header">
      <span><i class="bi bi-calendar-day me-2"></i><%=day%></span>
      <span style="font-size:.72rem;color:rgba(255,255,255,.6);"><%=daySlots.size()%> class<%=daySlots.size()==1?"":"es"%></span>
    </div>
    <div class="day-slots">
      <% if(daySlots.isEmpty()){ %>
        <div class="no-slots"><i class="bi bi-moon-stars" style="font-size:1.4rem;display:block;margin-bottom:6px;"></i>No classes</div>
      <% } else { for(Timetable t:daySlots){ %>
        <div class="slot-item">
          <div class="slot-info">
            <div class="slot-subject"><%=t.getSubjectName()!=null?t.getSubjectName():"—"%> <% if(t.getSubjectCode()!=null){ %><span style="font-size:.7rem;font-weight:400;color:var(--text-muted);">(<%=t.getSubjectCode()%>)</span><% } %></div>
            <div class="slot-time"><i class="bi bi-clock me-1"></i><%=t.getStartTime()!=null?tf.format(t.getStartTime()):"?"%> – <%=t.getEndTime()!=null?tf.format(t.getEndTime()):"?"%></div>
            <% if(t.getTeacherName()!=null){ %><div class="slot-teacher"><i class="bi bi-person-fill me-1"></i><%=t.getTeacherName()%></div><% } %>
            <% if(t.getRoomNo()!=null&&!t.getRoomNo().isEmpty()){ %><span class="slot-room"><i class="bi bi-door-open me-1"></i><%=t.getRoomNo()%></span><% } %>
          </div>
          <form action="manageTimetable" method="post" onsubmit="return confirm('Delete this slot?');">
            <input type="hidden" name="action" value="delete_slot">
            <input type="hidden" name="id" value="<%=t.getId()%>">
            <input type="hidden" name="dept" value="<%=fd%>">
            <input type="hidden" name="year" value="<%=fy%>">
            <input type="hidden" name="section" value="<%=fs%>">
            <button type="submit" class="btn btn-sm btn-outline-danger" style="padding:4px 8px;"><i class="bi bi-trash3"></i></button>
          </form>
        </div>
      <% }} %>
      <!-- Add slot button -->
      <button class="btn-add-slot" onclick="openAddSlot('<%=day%>')">
        <i class="bi bi-plus-circle me-1"></i>Add Class
      </button>
    </div>
  </div>
  <% } %>
</div>

<% } else { %>
<div class="prompt-card">
  <i class="bi bi-arrow-up-circle-fill"></i>
  <h5 class="fw-bold" style="color:var(--text-heading);">Select Department &amp; Year to begin</h5>
  <p class="mb-0">Choose a class group above to view and build the weekly routine.</p>
</div>
<% } %>

</div><!-- /container -->
</div><!-- /content-wrapper -->

<!-- ═══════════════════════════════════════════════════════ -->
<!-- Add Slot Modal                                          -->
<!-- ═══════════════════════════════════════════════════════ -->
<div class="modal fade" id="addSlotModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <form action="manageTimetable" method="post" id="slotForm">
        <input type="hidden" name="action"  value="add_slot">
        <input type="hidden" name="dept"    value="<%=fd%>">
        <input type="hidden" name="year"    value="<%=fy%>">
        <input type="hidden" name="section" value="<%=fs%>">

        <div class="modal-header">
          <h5 class="modal-title"><i class="bi bi-clock-history me-2"></i>Add Class Slot</h5>
          <button type="button" class="btn-close" style="filter:invert(1)" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="row g-3">
            <div class="col-12">
              <label class="form-label small fw-semibold">Day of Week *</label>
              <select name="day_of_week" id="slotDay" class="form-select" required>
                <% for(String d:DAYS){ %><option value="<%=d%>"><%=d%></option><% } %>
              </select>
            </div>
            <div class="col-12">
              <label class="form-label small fw-semibold">Subject *</label>
              <select name="subject_id" id="slotSubject" class="form-select" required >
                <option value="">— Select Subject —</option>
                <% if(subjects!=null){for(Subject s:subjects){ %>
                  <option value="<%=s.getId()%>"
                    data-teacher="<%=s.getTeacherName()!=null?s.getTeacherName():""%>"
                    data-code="<%=s.getSubjectCode()!=null?s.getSubjectCode():""%>">
                    <%=s.getName()%> (<%=s.getSubjectCode()%>)
                  </option>
                <%}} %>
              </select>
              <div class="col-12">
              <label class="form-label small fw-semibold">Assigned Teacher *</label>
              <select name="teacher_id" id="slotTeacher" class="form-select" required>
                <option value="">� Select Teacher �</option>
                <% if(teachers!=null){for(Teacher t:teachers){ %>
                  <option value="<%=t.getId()%>"><%=t.getName()%> (<%=t.getDepartment()%>)</option>
                <%}} %>
              </select>

            </div>
            </div>
            <div class="col-6">
              <label class="form-label small fw-semibold">Start Time *</label>
              <input type="time" name="start_time" class="form-control" required>
            </div>
            <div class="col-6">
              <label class="form-label small fw-semibold">End Time *</label>
              <input type="time" name="end_time" class="form-control" required>
            </div>
            <div class="col-12">
              <label class="form-label small fw-semibold">Room No</label>
              <input type="text" name="room_no" class="form-control" placeholder="e.g. 204, Lab-3">
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn-cas-outline" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn-cas-primary"><i class="bi bi-plus-circle-fill"></i> Add Slot</button>
        </div>
      </form>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
var slotModal = new bootstrap.Modal(document.getElementById('addSlotModal'));

function openAddSlot(day) {
    document.getElementById('slotDay').value = day;
    document.getElementById('slotSubject').value = '';
    
    slotModal.show();
}

 else {
        div.style.display = 'none';
    }
}

// Auto-dismiss alerts
setTimeout(function(){
    document.querySelectorAll('.alert-cas').forEach(function(e){
        e.style.transition='opacity .4s'; e.style.opacity='0';
        setTimeout(function(){e.remove();},400);
    });
}, 5000);
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





