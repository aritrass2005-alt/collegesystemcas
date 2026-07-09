-- B.Tech Subjects
-- Computer Science (ID 1)
INSERT INTO subject (subject_code, name, department, year, section) VALUES 
('CS301', 'Data Structures and Algorithms', 'Computer Science', 1, 'A'),
('CS302', 'Object Oriented Programming', 'Computer Science', 1, 'A'),
('CS303', 'Operating Systems', 'Computer Science', 2, 'A'),
('CS304', 'Computer Networks', 'Computer Science', 2, 'A'),
('CS305', 'Database Management Systems', 'Computer Science', 3, 'A'),
('CS306', 'Software Engineering', 'Computer Science', 3, 'A'),
('CS307', 'Theory of Computation', 'Computer Science', 4, 'A'),
('CS308', 'Artificial Intelligence', 'Computer Science', 4, 'A'),
('CS309', 'Machine Learning', 'Computer Science', 4, 'A'),
('CS310', 'Web Development', 'Computer Science', 3, 'A'),
('CS311', 'Mobile App Development', 'Computer Science', 3, 'A'),
('CS312', 'Cyber Security', 'Computer Science', 4, 'A'),
('CS313', 'Cloud Computing', 'Computer Science', 4, 'A');

-- Information Technology (ID 2)
INSERT INTO subject (subject_code, name, department, year, section) VALUES 
('IT301', 'Advanced Data Structures', 'Information Technology', 1, 'A'),
('IT302', 'Web Technologies', 'Information Technology', 1, 'A'),
('IT303', 'Cloud Computing', 'Information Technology', 2, 'A'),
('IT304', 'Network Security', 'Information Technology', 2, 'A'),
('IT305', 'Information Systems', 'Information Technology', 3, 'A'),
('IT306', 'Software Project Management', 'Information Technology', 3, 'A'),
('IT307', 'Data Mining', 'Information Technology', 4, 'A'),
('IT308', 'Artificial Intelligence', 'Information Technology', 4, 'A'),
('IT309', 'Machine Learning', 'Information Technology', 4, 'A'),
('IT310', 'Distributed Systems', 'Information Technology', 3, 'A'),
('IT311', 'IoT and Applications', 'Information Technology', 4, 'A'),
('IT312', 'Big Data Analytics', 'Information Technology', 4, 'A'),
('IT313', 'Cyber Security', 'Information Technology', 4, 'A');

-- Electronics (ID 3)
INSERT INTO subject (subject_code, name, department, year, section) VALUES 
('EC301', 'Analog Electronics', 'Electronics', 1, 'A'),
('EC302', 'Digital Logic Design', 'Electronics', 1, 'A'),
('EC303', 'Signals and Systems', 'Electronics', 2, 'A'),
('EC304', 'Microprocessors', 'Electronics', 2, 'A'),
('EC305', 'Communication Systems', 'Electronics', 3, 'A'),
('EC306', 'VLSI Design', 'Electronics', 3, 'A'),
('EC307', 'Embedded Systems', 'Electronics', 4, 'A'),
('EC308', 'Digital Signal Processing', 'Electronics', 3, 'A'),
('EC309', 'Microcontrollers', 'Electronics', 3, 'A'),
('EC310', 'Control Systems', 'Electronics', 4, 'A'),
('EC311', 'Microwave Engineering', 'Electronics', 4, 'A'),
('EC312', 'Antenna and Wave Propagation', 'Electronics', 4, 'A'),
('EC313', 'Power Electronics', 'Electronics', 4, 'A');

-- Mechanical Engineering
INSERT INTO subject (subject_code, name, department, year, section) VALUES 
('ME101', 'Engineering Mechanics', 'Mechanical', 1, 'A'),
('ME102', 'Thermodynamics', 'Mechanical', 1, 'A'),
('ME201', 'Fluid Mechanics', 'Mechanical', 2, 'A'),
('ME202', 'Strength of Materials', 'Mechanical', 2, 'A'),
('ME301', 'Heat Transfer', 'Mechanical', 3, 'A'),
('ME302', 'Manufacturing Processes', 'Mechanical', 3, 'A');

-- Civil Engineering
INSERT INTO subject (subject_code, name, department, year, section) VALUES 
('CE101', 'Building Materials', 'Civil', 1, 'A'),
('CE102', 'Engineering Geology', 'Civil', 1, 'A'),
('CE201', 'Structural Analysis', 'Civil', 2, 'A'),
('CE202', 'Fluid Mechanics', 'Civil', 2, 'A'),
('CE301', 'Geotechnical Engineering', 'Civil', 3, 'A'),
('CE302', 'Transportation Engineering', 'Civil', 3, 'A');

-- Non-B.Tech Subjects
-- BCA (ID 4)
INSERT INTO subject (subject_code, name, department, year, section) VALUES 
('BCA101', 'Programming in C', 'BCA', 1, 'A'),
('BCA102', 'Mathematics I', 'BCA', 1, 'A'),
('BCA201', 'Data Structures using C', 'BCA', 2, 'A'),
('BCA202', 'Computer Architecture', 'BCA', 2, 'A'),
('BCA301', 'Java Programming', 'BCA', 3, 'A'),
('BCA302', 'Database Systems', 'BCA', 3, 'A'),
('BCA303', 'Python Programming', 'BCA', 3, 'A');

-- MCA (ID 5)
INSERT INTO subject (subject_code, name, department, year, section) VALUES 
('MCA101', 'Advanced Java', 'MCA', 1, 'A'),
('MCA102', 'Advanced Database Systems', 'MCA', 1, 'A'),
('MCA201', 'Artificial Intelligence', 'MCA', 2, 'A'),
('MCA202', 'Machine Learning', 'MCA', 2, 'A'),
('MCA301', 'Mobile App Development', 'MCA', 3, 'A'),
('MCA302', 'Big Data Analytics', 'MCA', 3, 'A'),
('MCA303', 'Cyber Security', 'MCA', 3, 'A');

-- BBA (ID 6)
INSERT INTO subject (subject_code, name, department, year, section) VALUES 
('BBA101', 'Principles of Management', 'BBA', 1, 'A'),
('BBA102', 'Business Communication', 'BBA', 1, 'A'),
('BBA201', 'Financial Accounting', 'BBA', 2, 'A'),
('BBA202', 'Marketing Management', 'BBA', 2, 'A'),
('BBA301', 'Human Resource Management', 'BBA', 3, 'A'),
('BBA302', 'Business Economics', 'BBA', 3, 'A'),
('BBA303', 'Organizational Behavior', 'BBA', 3, 'A');

-- MBA (ID 7)
INSERT INTO subject (subject_code, name, department, year, section) VALUES 
('MBA101', 'Strategic Management', 'MBA', 1, 'A'),
('MBA102', 'Corporate Finance', 'MBA', 1, 'A'),
('MBA201', 'Operations Management', 'MBA', 2, 'A'),
('MBA202', 'Consumer Behavior', 'MBA', 2, 'A'),
('MBA301', 'International Business', 'MBA', 3, 'A'),
('MBA302', 'Investment Analysis', 'MBA', 3, 'A'),
('MBA303', 'Supply Chain Management', 'MBA', 3, 'A');

-- BHM (ID 9)
INSERT INTO subject (subject_code, name, department, year, section) VALUES 
('BHM101', 'Food Production Basics', 'BHM', 1, 'A'),
('BHM102', 'Front Office Operations', 'BHM', 1, 'A'),
('BHM201', 'Housekeeping Management', 'BHM', 2, 'A'),
('BHM202', 'Food and Beverage Service', 'BHM', 2, 'A'),
('BHM301', 'Hospitality Communication', 'BHM', 3, 'A'),
('BHM302', 'Hospitality Marketing', 'BHM', 3, 'A'),
('BHM303', 'Hotel Accountancy', 'BHM', 3, 'A');

-- BSc Physics
INSERT INTO subject (subject_code, name, department, year, section) VALUES 
('PHY101', 'Classical Mechanics', 'BSc Physics', 1, 'A'),
('PHY102', 'Electromagnetism', 'BSc Physics', 1, 'A'),
('PHY201', 'Quantum Mechanics', 'BSc Physics', 2, 'A'),
('PHY202', 'Statistical Physics', 'BSc Physics', 2, 'A'),
('PHY301', 'Solid State Physics', 'BSc Physics', 3, 'A'),
('PHY302', 'Nuclear Physics', 'BSc Physics', 3, 'A');

-- BSc Chemistry
INSERT INTO subject (subject_code, name, department, year, section) VALUES 
('CHEM101', 'Inorganic Chemistry', 'BSc Chemistry', 1, 'A'),
('CHEM102', 'Organic Chemistry', 'BSc Chemistry', 1, 'A'),
('CHEM201', 'Physical Chemistry', 'BSc Chemistry', 2, 'A'),
('CHEM202', 'Analytical Chemistry', 'BSc Chemistry', 2, 'A'),
('CHEM301', 'Biochemistry', 'BSc Chemistry', 3, 'A'),
('CHEM302', 'Environmental Chemistry', 'BSc Chemistry', 3, 'A');

-- BSc Mathematics
INSERT INTO subject (subject_code, name, department, year, section) VALUES 
('MATH101', 'Calculus', 'BSc Mathematics', 1, 'A'),
('MATH102', 'Algebra', 'BSc Mathematics', 1, 'A'),
('MATH201', 'Real Analysis', 'BSc Mathematics', 2, 'A'),
('MATH202', 'Differential Equations', 'BSc Mathematics', 2, 'A'),
('MATH301', 'Complex Analysis', 'BSc Mathematics', 3, 'A'),
('MATH302', 'Linear Algebra', 'BSc Mathematics', 3, 'A');
