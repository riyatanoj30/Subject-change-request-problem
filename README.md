📚 College Subject Allotment System
This project demonstrates a SQL-based Subject Allotment Workflow System for a college. It includes a schema, procedures to manage subject requests, and logic to process allotments based on student requests.


📌 Overview
- Manage current subject allotments for students.
- Allow students to request a change in subject.
- Automatically process and switch active subjects.
- Maintain history of subject changes (active/inactive).


⚙️ Database Setup
1. Create Database and Use It
CREATE DATABASE IF NOT EXISTS college_system;
USE college_system;


🗂️ Table Structures
2. SubjectAllotments
Stores each student's subject history and tracks the currently valid subject.
CREATE TABLE IF NOT EXISTS SubjectAllotments (
    StudentID VARCHAR(10) NOT NULL,
    SubjectID VARCHAR(10) NOT NULL,
    Is_Valid BIT DEFAULT 1,
    PRIMARY KEY (StudentID, SubjectID)
);

3. SubjectRequest
Stores new subject change requests from students.
CREATE TABLE IF NOT EXISTS SubjectRequest (
    StudentID VARCHAR(10) NOT NULL,
    SubjectID VARCHAR(10) NOT NULL,
    RequestDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (StudentID, SubjectID)
);


🧪 Sample Data
-- Subject allotments
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid) VALUES
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 0),
('159103036', 'PO1493', 0),
('159103036', 'PO1494', 0),
('159103036', 'PO1495', 0);

-- Subject request
INSERT INTO SubjectRequest (StudentID, SubjectID) VALUES
('159103036', 'PO1496');


🔁 Main Stored Procedure
ProcessSubjectAllotment
Handles validation and switching of subjects for a student.
CALL ProcessSubjectAllotment('159103036', 'PO1496');


🔍 Helper Procedures
View Allotments of a Student
CALL ViewStudentAllotments('159103036');

View Pending Requests
CALL ViewPendingRequests();


🧪 Additional Test Cases
Test Case 1: Student requests already allotted (but inactive) subject
INSERT INTO SubjectRequest (StudentID, SubjectID) VALUES ('159103036', 'PO1492');
CALL ProcessSubjectAllotment('159103036', 'PO1492');

Test Case 2: New student, new subject
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid) VALUES ('159103037', 'PO1491', 1);
INSERT INTO SubjectRequest (StudentID, SubjectID) VALUES ('159103037', 'PO1497');
CALL ProcessSubjectAllotment('159103037', 'PO1497');


✅ Verification Queries
SELECT * FROM SubjectAllotments ORDER BY StudentID, SubjectID;
SELECT * FROM SubjectRequest ORDER BY StudentID, SubjectID;


♻️ Reset Data (For Testing)
CALL ResetTestData();


📄 Notes
- Ensures only one active subject per student at a time.
- Requests are processed only if recorded in the SubjectRequest table.
- System is transactional and ensures data consistency.


👨‍💻 Author
SQL Workflow by: Riya Mhatre
Project for: College Subject Allotment Automation