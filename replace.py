import re

with open('src/main/webapp/student_dashboard.jsp', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add modal
modal_html = '''    </div>
</div>

<!-- Calendar Event Details & Appeal Modal -->
<div class="modal fade" id="eventDetailsModal" tabindex="-1" aria-hidden="true" style="z-index: 1060;">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 rounded-4 shadow-lg">
            <div class="modal-header text-white" style="background: linear-gradient(135deg, #1e3a5f, #0f2240);">
                <h5 class="modal-title fw-bold"><i class="bi bi-info-circle me-2"></i> Attendance Details</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">
                <div class="mb-3">
                    <h6 class="text-muted mb-1">Subject</h6>
                    <div id="appealSubjectName" class="fw-bold fs-5"></div>
                </div>
                <div class="row mb-4">
                    <div class="col-6">
                        <h6 class="text-muted mb-1">Date & Time</h6>
                        <div id="appealDateDisplay" class="fw-medium"></div>
                    </div>
                    <div class="col-6">
                        <h6 class="text-muted mb-1">Status</h6>
                        <div id="appealStatus" class="fw-bold"></div>
                    </div>
                </div>
                
                <form id="calendarAppealForm" action="studentReviews" method="post">
                    <input type="hidden" name="action" value="create">
                    <input type="hidden" name="subjectId" id="appealSubjectId">
                    <input type="hidden" name="reviewDate" id="appealReviewDate">
                    
                    <div id="appealReasonGroup" style="display:none;">
                        <hr>
                        <h6 class="text-primary mb-2"><i class="bi bi-pencil-square me-1"></i> Appeal Absence</h6>
                        <p class="small text-muted mb-2">You can request an attendance review if you believe this was marked incorrectly or if you have a valid reason.</p>
                        <textarea name="reason" class="form-control mb-3" rows="3" placeholder="Provide your reason here..." required></textarea>
                    </div>
                    
                    <div class="d-flex justify-content-end gap-2 mt-2">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Close</button>
                        <button type="submit" id="appealSubmitBtn" class="btn btn-primary" style="display:none;">Submit Appeal</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
'''

content = content.replace('    </div>\n\n<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>', modal_html + '\n<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>')
content = content.replace('    </div>\r\n\r\n<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>', modal_html.replace('\n', '\r\n') + '\r\n<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>')

# 2. Add extendedProps
old_props = '''            extendedProps: {
                subject: '<%= subjectName %>',
                status: '<%= a.getStatus() %>',
                time: '<%= timeStr %>'
            }'''
new_props = '''            extendedProps: {
                subject: '<%= subjectName %>',
                subjectId: '<%= a.getSubjectId() %>',
                status: '<%= a.getStatus() %>',
                time: '<%= timeStr %>',
                dateOnly: '<%= sdf.format(a.getDateTime()) %>'
            }'''
content = content.replace(old_props, new_props)
content = content.replace(old_props.replace('\n', '\r\n'), new_props.replace('\n', '\r\n'))

# 3. Update eventClick
old_click = '''            eventClick: function(info) {
                var props = info.event.extendedProps;
                var dateStr = info.event.start.toLocaleDateString('en-IN', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
                alert(props.subject + '\\n' + props.status + '\\nTime: ' + props.time + '\\nDate: ' + dateStr);
            }'''
new_click = '''            eventClick: function(info) {
                var props = info.event.extendedProps;
                var dateStr = info.event.start.toLocaleDateString('en-IN', { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric' });
                
                document.getElementById('appealSubjectId').value = props.subjectId;
                document.getElementById('appealReviewDate').value = props.dateOnly;
                document.getElementById('appealSubjectName').textContent = props.subject;
                document.getElementById('appealDateDisplay').textContent = dateStr + ' at ' + props.time;
                
                var statusEl = document.getElementById('appealStatus');
                statusEl.textContent = props.status;
                if (props.status === 'Present') statusEl.className = 'fw-bold text-success';
                else if (props.status === 'Absent') statusEl.className = 'fw-bold text-danger';
                else statusEl.className = 'fw-bold text-secondary';
                
                var appealBtn = document.getElementById('appealSubmitBtn');
                var reasonGroup = document.getElementById('appealReasonGroup');
                var reasonInput = document.querySelector('#appealReasonGroup textarea');
                
                if (props.status === 'Absent') {
                    appealBtn.style.display = 'block';
                    reasonGroup.style.display = 'block';
                    if (reasonInput) reasonInput.setAttribute('required', 'required');
                } else {
                    appealBtn.style.display = 'none';
                    reasonGroup.style.display = 'none';
                    if (reasonInput) reasonInput.removeAttribute('required');
                }
                
                var eventModal = new bootstrap.Modal(document.getElementById('eventDetailsModal'));
                eventModal.show();
            }'''
content = content.replace(old_click, new_click)
content = content.replace(old_click.replace('\n', '\r\n'), new_click.replace('\n', '\r\n'))

with open('src/main/webapp/student_dashboard.jsp', 'w', encoding='utf-8') as f:
    f.write(content)
print("Done!")
