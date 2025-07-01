-- 1. Create the database and tables
CREATE DATABASE IF NOT EXISTS college_system;
USE college_system;

-- 2. Create SubjectAllotments table
CREATE TABLE IF NOT EXISTS SubjectAllotments (
    StudentID VARCHAR(10) NOT NULL,
    SubjectID VARCHAR(10) NOT NULL,
    Is_Valid BIT DEFAULT 1,
    PRIMARY KEY (StudentID, SubjectID)
);

-- 3. Create SubjectRequest table
CREATE TABLE IF NOT EXISTS SubjectRequest (
    StudentID VARCHAR(10) NOT NULL,
    SubjectID VARCHAR(10) NOT NULL,
    RequestDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (StudentID, SubjectID)
);

-- 4. Insert sample data into SubjectAllotments table (as shown in the problem)
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid) VALUES
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 0),
('159103036', 'PO1493', 0),
('159103036', 'PO1494', 0),
('159103036', 'PO1495', 0);

-- 5. Insert sample data into SubjectRequest table (as shown in the problem)
INSERT INTO SubjectRequest (StudentID, SubjectID) VALUES
('159103036', 'PO1496');

-- 6. Main Stored Procedure to handle subject allotment workflow
DELIMITER //

CREATE PROCEDURE ProcessSubjectAllotment(
    IN p_StudentID VARCHAR(10),
    IN p_RequestedSubjectID VARCHAR(10)
)
BEGIN
    DECLARE v_current_subject VARCHAR(10);
    DECLARE v_request_exists INT DEFAULT 0;
    DECLARE v_allotment_exists INT DEFAULT 0;
    
    -- Start transaction for data consistency
    START TRANSACTION;
    
    -- Check if the requested subject exists in SubjectRequest table
    SELECT COUNT(*) INTO v_request_exists
    FROM SubjectRequest 
    WHERE StudentID = p_StudentID AND SubjectID = p_RequestedSubjectID;
    
    -- If request doesn't exist, exit
    IF v_request_exists = 0 THEN
        SELECT 'No request found for this student and subject' AS Result;
        ROLLBACK;
    ELSE
        -- Get the current valid subject for the student
        SELECT SubjectID INTO v_current_subject
        FROM SubjectAllotments 
        WHERE StudentID = p_StudentID AND Is_Valid = 1
        LIMIT 1;
        
        -- Check if the requested subject already exists in SubjectAllotments
        SELECT COUNT(*) INTO v_allotment_exists
        FROM SubjectAllotments 
        WHERE StudentID = p_StudentID AND SubjectID = p_RequestedSubjectID;
        
        IF v_allotment_exists > 0 THEN
            -- Subject exists, just update Is_Valid to 1
            UPDATE SubjectAllotments 
            SET Is_Valid = 1 
            WHERE StudentID = p_StudentID AND SubjectID = p_RequestedSubjectID;
            
            -- Set previous valid subject to invalid
            IF v_current_subject IS NOT NULL AND v_current_subject != p_RequestedSubjectID THEN
                UPDATE SubjectAllotments 
                SET Is_Valid = 0 
                WHERE StudentID = p_StudentID AND SubjectID = v_current_subject;
            END IF;
            
            SELECT CONCAT('Subject ', p_RequestedSubjectID, ' allotment updated for student ', p_StudentID) AS Result;
        ELSE
            -- Subject doesn't exist, insert new record
            INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid) 
            VALUES (p_StudentID, p_RequestedSubjectID, 1);
            
            -- Set previous valid subject to invalid
            IF v_current_subject IS NOT NULL THEN
                UPDATE SubjectAllotments 
                SET Is_Valid = 0 
                WHERE StudentID = p_StudentID AND SubjectID = v_current_subject;
            END IF;
            
            SELECT CONCAT('New subject ', p_RequestedSubjectID, ' allotted to student ', p_StudentID) AS Result;
        END IF;
        
        COMMIT;
    END IF;
    
END //

DELIMITER ;

-- 7. Additional helper procedures and queries

-- Procedure to view current allotments for a student
DELIMITER //
CREATE PROCEDURE ViewStudentAllotments(IN p_StudentID VARCHAR(10))
BEGIN
    SELECT 
        StudentID,
        SubjectID,
        CASE 
            WHEN Is_Valid = 1 THEN 'Active'
            ELSE 'Inactive'
        END AS Status
    FROM SubjectAllotments 
    WHERE StudentID = p_StudentID
    ORDER BY Is_Valid DESC, SubjectID;
END //
DELIMITER ;

-- Procedure to view all pending requests
DELIMITER //
CREATE PROCEDURE ViewPendingRequests()
BEGIN
    SELECT 
        sr.StudentID,
        sr.SubjectID,
        sr.RequestDate,
        CASE 
            WHEN sa.SubjectID IS NULL THEN 'Not Processed'
            WHEN sa.Is_Valid = 1 THEN 'Approved'
            ELSE 'Exists but Inactive'
        END AS Status
    FROM SubjectRequest sr
    LEFT JOIN SubjectAllotments sa ON sr.StudentID = sa.StudentID AND sr.SubjectID = sa.SubjectID
    ORDER BY sr.RequestDate;
END //
DELIMITER ;

-- 8. Test the stored procedure with the given example
CALL ProcessSubjectAllotment('159103036', 'PO1496');

-- 9. View results after processing
SELECT 'Current Allotments After Processing:' AS Info;
CALL ViewStudentAllotments('159103036');

-- 10. Additional test cases

-- Test case 1: Student requests a subject that already exists but is inactive
INSERT INTO SubjectRequest (StudentID, SubjectID) VALUES ('159103036', 'PO1492');
CALL ProcessSubjectAllotment('159103036', 'PO1492');

-- Test case 2: New student with new request
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid) VALUES ('159103037', 'PO1491', 1);
INSERT INTO SubjectRequest (StudentID, SubjectID) VALUES ('159103037', 'PO1497');
CALL ProcessSubjectAllotment('159103037', 'PO1497');

-- 11. Verification queries to check final state
SELECT 'Final SubjectAllotments Table:' AS Info;
SELECT * FROM SubjectAllotments ORDER BY StudentID, SubjectID;

SELECT 'SubjectRequest Table:' AS Info;
SELECT * FROM SubjectRequest ORDER BY StudentID, SubjectID;

-- 12. Clean up procedures (optional - for testing purposes)
DELIMITER //
CREATE PROCEDURE ResetTestData()
BEGIN
    DELETE FROM SubjectAllotments;
    DELETE FROM SubjectRequest;
    
    -- Restore original test data
    INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid) VALUES
    ('159103036', 'PO1491', 1),
    ('159103036', 'PO1492', 0),
    ('159103036', 'PO1493', 0),
    ('159103036', 'PO1494', 0),
    ('159103036', 'PO1495', 0);
    
    INSERT INTO SubjectRequest (StudentID, SubjectID) VALUES
    ('159103036', 'PO1496');
    
    SELECT 'Test data reset successfully' AS Result;
END //
DELIMITER ;