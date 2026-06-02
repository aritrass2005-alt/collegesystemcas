import os

file_path = 'src/main/webapp/teacher_dashboard.jsp'
with open(file_path, 'r', encoding='utf-8') as f:
    data = f.read()

button_html = """
                            <a href="chat.jsp" class="btn text-start d-flex align-items-center justify-content-between p-3" style="background-color: #f0fdf4; color: #166534; border: 1px solid #bbf7d0;">
                                <div>
                                    <i class="bi bi-chat-dots fs-5 me-2"></i>
                                    <span class="fw-bold">Department Chat</span>
                                </div>
                                <i class="bi bi-chevron-right"></i>
                            </a>
"""

if "Department Chat" not in data:
    target = '                                </div>\n                                <i class="bi bi-chevron-right"></i>\n                            </a>\n                        </div>'
    replacement = '                                </div>\n                                <i class="bi bi-chevron-right"></i>\n                            </a>' + button_html + '                        </div>'
    data = data.replace(target, replacement)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(data)
