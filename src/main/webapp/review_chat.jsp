<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Student" %>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="com.college.attendance.model.AttendanceReview" %>
<%@ page import="com.college.attendance.model.ReviewChat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    AttendanceReview review = (AttendanceReview) request.getAttribute("review");
    List<ReviewChat> chats = (List<ReviewChat>) request.getAttribute("chats");
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM, hh:mm a");
    
    boolean isCoordinator = false;
    if ("Teacher".equals(role)) {
        Boolean isCoordAttr = (Boolean) session.getAttribute("isCoordinator");
        isCoordinator = (isCoordAttr != null && isCoordAttr);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Review Chat – CAS</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="css/theme.css">
    <style>
        .chat-container {
            height: 400px;
            overflow-y: auto;
            background: #f8f9fa;
            border-radius: 8px;
            padding: 15px;
        }
        .chat-bubble {
            max-width: 75%;
            padding: 10px 15px;
            border-radius: 15px;
            margin-bottom: 10px;
            position: relative;
        }
        .chat-mine {
            background-color: #0d6efd;
            color: white;
            align-self: flex-end;
            border-bottom-right-radius: 0;
        }
        .chat-other {
            background-color: #e9ecef;
            color: black;
            align-self: flex-start;
            border-bottom-left-radius: 0;
        }
        .chat-time {
            font-size: 0.75rem;
            margin-top: 5px;
            opacity: 0.8;
        }
    </style>
</head>
<body class="dashboard-body">

    <% if (isCoordinator) { %>
        <!-- Sidebar -->
        <jsp:include page="includes/coordinator_sidebar.jsp" />
    <% } else { %>
        <!-- Sidebar -->
        <jsp:include page="includes/student_sidebar.jsp" />
    <% } %>

    <!-- Main Content -->
    <div id="content-wrapper">
        <% if (isCoordinator) { %>
            <!-- Top Header -->
            <jsp:include page="includes/coordinator_header.jsp" />
        <% } else { %>
            <!-- Top Header -->
            <jsp:include page="includes/student_header.jsp" />
        <% } %>

        <div class="container-fluid p-4 p-md-5">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="fw-bold mb-0">Review Chat</h2>
                <a href="<%= isCoordinator ? "coordinatorReviews" : "studentReviews" %>" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left me-2"></i>Back to Reviews
                </a>
            </div>

            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success"><%= request.getParameter("msg") %></div>
            <% } %>
            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger"><%= request.getParameter("error") %></div>
            <% } %>

            <div class="row">
                <!-- Review Details -->
                <div class="col-md-4 mb-4">
                    <div class="card shadow-sm border-0">
                        <div class="card-header bg-white py-3">
                            <h5 class="mb-0 fw-bold">Request Details</h5>
                        </div>
                        <div class="card-body">
                            <p><strong>Student:</strong> <%= review.getStudentName() %> (<%= review.getStudentRollNo() %>)</p>
                            <p><strong>Subject:</strong> <%= review.getSubjectName() != null ? review.getSubjectName() : "All Subjects" %></p>
                            <p><strong>Date:</strong> <%= new SimpleDateFormat("dd MMM yyyy").format(review.getReviewDate()) %></p>
                            <p><strong>Status:</strong> 
                                <% if("Pending".equals(review.getStatus())) { %>
                                    <span class="badge bg-warning text-dark">Pending</span>
                                <% } else if("In Review".equals(review.getStatus())) { %>
                                    <span class="badge bg-info">In Review</span>
                                <% } else if("Approved".equals(review.getStatus())) { %>
                                    <span class="badge bg-success">Approved</span>
                                <% } else { %>
                                    <span class="badge bg-danger">Rejected</span>
                                <% } %>
                            </p>
                            <hr>
                            <h6>Original Reason:</h6>
                            <p class="text-muted"><%= review.getReason() %></p>
                            
                            <% if (isCoordinator && ("Pending".equals(review.getStatus()) || "In Review".equals(review.getStatus()))) { %>
                                <hr>
                                <h6>Actions</h6>
                                <form action="reviewChat" method="post" class="d-flex gap-2">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="reviewId" value="<%= review.getId() %>">
                                    <button type="submit" name="status" value="Approved" class="btn btn-success flex-grow-1" onclick="return confirm('Approve this request?');">Approve</button>
                                    <button type="submit" name="status" value="Rejected" class="btn btn-danger flex-grow-1" onclick="return confirm('Reject this request?');">Reject</button>
                                </form>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- Chat Section -->
                <div class="col-md-8 mb-4">
                    <div class="card shadow-sm border-0 h-100">
                        <div class="card-header bg-white py-3">
                            <h5 class="mb-0 fw-bold">Discussion</h5>
                        </div>
                        <div class="card-body d-flex flex-column p-0">
                            <div class="chat-container d-flex flex-column flex-grow-1" id="chatContainer">
                                <jsp:include page="review_chat_messages.jsp">
                                    <jsp:param name="id" value="<%= review.getId() %>" />
                                </jsp:include>
                            </div>
                            
                            <% if ("Pending".equals(review.getStatus()) || "In Review".equals(review.getStatus())) { %>
                                <div class="p-3 bg-white border-top">
                                    <div id="imagePreviewContainer" style="display:none; position: relative; margin-bottom: 10px; width: fit-content;">
                                        <img id="imagePreview" src="" alt="Image Preview" style="max-height: 150px; border-radius: 8px;">
                                        <button type="button" class="btn-close" style="position: absolute; top: -10px; right: -10px; background-color: white; border-radius: 50%; padding: 0.25rem; box-shadow: 0 2px 4px rgba(0,0,0,0.2);" aria-label="Close" onclick="clearAttachment()"></button>
                                    </div>
                                    <form id="chatForm" action="reviewChat" method="post" enctype="multipart/form-data" class="d-flex gap-2 align-items-center">
                                        <input type="hidden" name="action" value="sendMessage">
                                        <input type="hidden" name="reviewId" value="<%= review.getId() %>">
                                        <label class="btn btn-outline-secondary mb-0" title="Attach file" style="cursor: pointer;">
                                            <i class="bi bi-paperclip"></i>
                                            <input type="file" name="attachment" style="display:none" onchange="updateFileName(this)">
                                        </label>
                                        <input type="text" name="message" class="form-control" placeholder="Type a message..." required autocomplete="off">
                                        <button type="submit" class="btn btn-primary"><i class="bi bi-send"></i></button>
                                    </form>
                                    <small id="fileNameDisplay" class="text-muted ms-1 mt-1 d-block"></small>
                                </div>
                            <% } else { %>
                                <div class="p-3 bg-light border-top text-center text-muted">
                                    Discussion closed. This request has been <%= review.getStatus().toLowerCase() %>.
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        var chatContainer = document.getElementById("chatContainer");
        function scrollToBottom() {
            if (chatContainer) chatContainer.scrollTop = chatContainer.scrollHeight;
        }
        scrollToBottom();

        function updateFileName(input) {
            var previewContainer = document.getElementById('imagePreviewContainer');
            var previewImage = document.getElementById('imagePreview');
            var fileDisplay = document.getElementById('fileNameDisplay');
            
            if (input.files && input.files.length > 0) {
                var file = input.files[0];
                document.querySelector('input[name="message"]').removeAttribute('required');
                
                if (file.type.startsWith('image/')) {
                    var reader = new FileReader();
                    reader.onload = function(e) {
                        previewImage.src = e.target.result;
                        if(previewContainer) previewContainer.style.display = 'block';
                        if(fileDisplay) fileDisplay.textContent = "";
                    }
                    reader.readAsDataURL(file);
                } else {
                    if(previewContainer) previewContainer.style.display = 'none';
                    if(previewImage) previewImage.src = "";
                    if(fileDisplay) fileDisplay.textContent = "Attached: " + file.name;
                }
            } else {
                clearAttachment();
            }
        }

        function clearAttachment() {
            var input = document.querySelector('input[name="attachment"]');
            if(input) input.value = "";
            var previewContainer = document.getElementById('imagePreviewContainer');
            if(previewContainer) previewContainer.style.display = 'none';
            var previewImage = document.getElementById('imagePreview');
            if(previewImage) previewImage.src = "";
            var fileDisplay = document.getElementById('fileNameDisplay');
            if(fileDisplay) fileDisplay.textContent = "";
            var messageInput = document.querySelector('input[name="message"]');
            if(messageInput) messageInput.setAttribute('required', 'required');
        }

        // Real-time polling
        setInterval(function() {
            fetch('review_chat_messages.jsp?id=<%= review.getId() %>')
                .then(response => response.text())
                .then(html => {
                    if (html.trim() === 'SESSION_EXPIRED') {
                        window.location.href = 'login.jsp';
                        return;
                    }
                    var isAtBottom = chatContainer.scrollHeight - chatContainer.scrollTop <= chatContainer.clientHeight + 50;
                    chatContainer.innerHTML = html;
                    if (isAtBottom) scrollToBottom();
                });
        }, 3000); // poll every 3 seconds

        // Ajax form submit
        const chatForm = document.getElementById('chatForm');
        if (chatForm) {
            chatForm.addEventListener('submit', function(e) {
                e.preventDefault();
                var formData = new FormData(chatForm);
                fetch('reviewChat', {
                    method: 'POST',
                    body: formData
                }).then(response => {
                    // clear form
                    chatForm.reset();
                    clearAttachment();
                    // fetch immediately
                    return fetch('review_chat_messages.jsp?id=<%= review.getId() %>');
                }).then(response => response.text())
                .then(html => {
                    if (html.trim() === 'SESSION_EXPIRED') {
                        window.location.href = 'login.jsp';
                        return;
                    }
                    chatContainer.innerHTML = html;
                    scrollToBottom();
                });
            });
        }
    </script>
</body>
</html>
