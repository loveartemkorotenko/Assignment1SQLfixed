DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS fitnessClasses;
DROP TABLE IF EXISTS trainers;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS memberships;

CREATE DATABASE FitnessCenter;
USE FitnessCenter;

CREATE TABLE Memberships (
    MembershipID INT AUTO_INCREMENT PRIMARY KEY,
    TypeName VARCHAR(50) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Members (
    MemberID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    MembershipID INT,
    FOREIGN KEY (MembershipID) REFERENCES Memberships(MembershipID)
);

CREATE TABLE Trainers (
    TrainerID INT AUTO_INCREMENT PRIMARY KEY,
    TrainerName VARCHAR(100) NOT NULL,
    Specialization VARCHAR(50)
);


CREATE TABLE FitnessClasses (
    ClassID INT AUTO_INCREMENT PRIMARY KEY,
    ClassName VARCHAR(100) NOT NULL,
    TrainerID INT,
    ClassDate DATETIME NOT NULL,
    FOREIGN KEY (TrainerID) REFERENCES Trainers(TrainerID)
);

CREATE TABLE Enrollments (
    EnrollmentID INT AUTO_INCREMENT PRIMARY KEY,
    MemberID INT,
    ClassID INT,
    Status VARCHAR(20) DEFAULT 'Confirmed',
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    FOREIGN KEY (ClassID) REFERENCES FitnessClasses(ClassID)
);


WITH TrainerStats AS (
    SELECT 
        t.TrainerName, 
        t.Specialization, 
        COUNT(e.EnrollmentID) AS TotalEnrollments, 
        SUM(ms.Price) AS TotalMembershipRevenue
    FROM 
        Trainers t

    JOIN 
        FitnessClasses fc ON t.TrainerID = fc.TrainerID
    JOIN 
        Enrollments e ON fc.ClassID = e.ClassID
    JOIN 
        Members m ON e.MemberID = m.MemberID
    JOIN 
        Memberships ms ON m.MembershipID = ms.MembershipID
 
    WHERE 
        e.Status = 'Confirmed' 
        AND fc.ClassDate >= '2024-01-01'

    GROUP BY 
        t.TrainerName, 
        t.Specialization
)

SELECT 
    TrainerName, 
    Specialization, 
    TotalEnrollments, 
    TotalMembershipRevenue
FROM 
    TrainerStats

UNION ALL

SELECT 
    '--- ALL TRAINERS (TOTAL) ---' AS TrainerName, 
    '---' AS Specialization, 
    SUM(TotalEnrollments), 
    SUM(TotalMembershipRevenue)
FROM 
    TrainerStats
ORDER BY 
    TotalMembershipRevenue DESC;