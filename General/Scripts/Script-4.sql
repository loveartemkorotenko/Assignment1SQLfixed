DROP TABLE IF EXISTS Enrollments;
DROP TABLE IF EXISTS FitnessClasses;
DROP TABLE IF EXISTS Trainers;
DROP TABLE IF EXISTS Members;
DROP TABLE IF EXISTS Memberships;

CREATE TABLE Memberships (
    MembershipID SERIAL PRIMARY KEY,
    TypeName VARCHAR(50) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Members (
    MemberID SERIAL PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    MembershipID INT,
    FOREIGN KEY (MembershipID) REFERENCES Memberships(MembershipID)
);

CREATE TABLE Trainers (
    TrainerID SERIAL PRIMARY KEY,
    TrainerName VARCHAR(100) NOT NULL,
    Specialization VARCHAR(50)
);

CREATE TABLE FitnessClasses (
    ClassID SERIAL PRIMARY KEY,
    ClassName VARCHAR(100) NOT NULL,
    TrainerID INT,
    ClassDate TIMESTAMP NOT NULL,
    FOREIGN KEY (TrainerID) REFERENCES Trainers(TrainerID)
);

CREATE TABLE Enrollments (
    EnrollmentID SERIAL PRIMARY KEY,
    MemberID INT,
    ClassID INT,
    Status VARCHAR(20) DEFAULT 'Confirmed',
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    FOREIGN KEY (ClassID) REFERENCES FitnessClasses(ClassID)
);
TRUNCATE TABLE Enrollments, FitnessClasses, Trainers, Members, Memberships RESTART IDENTITY CASCADE;

INSERT INTO Memberships (TypeName, Price) VALUES
('Basic', 50.00), 
('Premium', 100.00), 
('VIP', 150.00);

INSERT INTO Trainers (TrainerName, Specialization)
SELECT 
    'Trainer ' || i,
    (ARRAY['Йога', 'Кросфіт', 'Пілатес', 'Бокс', 'Танці'])[floor(random() * 5 + 1)]
FROM generate_series(1, 1000) AS i;

INSERT INTO Members (FullName, Email, MembershipID)
SELECT 
    'Client ' || i,
    'client' || i || '@example.com',
    floor(random() * 3 + 1)::INT
FROM generate_series(1, 10000) AS i;

INSERT INTO FitnessClasses (ClassName, TrainerID, ClassDate)
SELECT 
    'Class ' || i,
    floor(random() * 1000 + 1)::INT,
    timestamp '2024-01-01 00:00:00' + random() * (timestamp '2026-12-31 23:59:59' - timestamp '2024-01-01 00:00:00')
FROM generate_series(1, 10000) AS i;

INSERT INTO Enrollments (MemberID, ClassID, Status)
SELECT 
    floor(random() * 10000 + 1)::INT,
    floor(random() * 10000 + 1)::INT,
    (ARRAY['Confirmed', 'Confirmed', 'Canceled'])[floor(random() * 3 + 1)]
FROM generate_series(1, 15000) AS i;

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
        AND fc.ClassDate >= '2025-05-01'

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
    'ALL TRAINERS' AS TrainerName, 
    '-' AS Specialization, 
    SUM(TotalEnrollments), 
    SUM(TotalMembershipRevenue)
FROM 
    TrainerStats
ORDER BY 
    TotalMembershipRevenue DESC;