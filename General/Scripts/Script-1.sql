DROP TABLE IF EXISTS Enrollments, FitnessClasses, Trainers, Members, Memberships CASCADE;

CREATE TABLE Memberships (
    MembershipID SERIAL PRIMARY KEY,
    TypeName VARCHAR(50) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Members (
    MemberID SERIAL PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    MembershipID INT REFERENCES Memberships(MembershipID)
);

CREATE TABLE Trainers (
    TrainerID SERIAL PRIMARY KEY,
    TrainerName VARCHAR(100) NOT NULL,
    Specialization VARCHAR(50)
);

CREATE TABLE FitnessClasses (
    ClassID SERIAL PRIMARY KEY,
    ClassName VARCHAR(100) NOT NULL,
    TrainerID INT REFERENCES Trainers(TrainerID),
    ClassDate TIMESTAMP NOT NULL
);

CREATE TABLE Enrollments (
    EnrollmentID SERIAL PRIMARY KEY,
    MemberID INT REFERENCES Members(MemberID),
    ClassID INT REFERENCES FitnessClasses(ClassID),
    Status VARCHAR(20) DEFAULT 'Confirmed'
);

TRUNCATE TABLE Enrollments, FitnessClasses, Trainers, Members, Memberships RESTART IDENTITY CASCADE;

INSERT INTO Memberships (TypeName, Price)
SELECT 
    'Абонемент типу ' || i,
    (random() * 9000 + 1000)::numeric(10,2) 
FROM generate_series(1, 10000) AS s(i);

INSERT INTO Members (FullName, Email, MembershipID)
SELECT 
    'Клієнт ' || i, 
    'client' || i || '@kse-test.com', 
    floor(random() * 10000 + 1)::int
FROM generate_series(1, 10000) AS s(i);

INSERT INTO Trainers (TrainerName, Specialization)
SELECT 
    'Тренер ' || i,
    (ARRAY['Кросфіт', 'Йога', 'Бокс', 'Пілатес', 'Бодібілдинг'])[floor(random() * 5 + 1)]
FROM generate_series(1, 10000) AS s(i);

INSERT INTO FitnessClasses (ClassName, TrainerID, ClassDate)
SELECT 
    'Групове заняття ' || s.i::text,
    floor(random() * 10000 + 1)::int,
    NOW() + (random() * (interval '60 days'))
FROM generate_series(1, 10000) AS s(i);


INSERT INTO Enrollments (MemberID, ClassID, Status)
SELECT 
    floor(random() * 10000 + 1)::int, 
    floor(random() * 10000 + 1)::int, 
    (ARRAY['Confirmed', 'Cancelled', 'Waitlist'])[floor(random() * 3 + 1)]
FROM generate_series(1, 10000) AS s(i);






WITH ConfirmedEnrollments AS (

    SELECT 
        m.FullName AS ClientName,
        ms.TypeName AS MembershipType,
        fc.ClassName,
        t.TrainerName,
        fc.ClassDate
    FROM Enrollments e
    JOIN Members m ON e.MemberID = m.MemberID
    JOIN Memberships ms ON m.MembershipID = ms.MembershipID
    JOIN FitnessClasses fc ON e.ClassID = fc.ClassID
    JOIN Trainers t ON fc.TrainerID = t.TrainerID
    WHERE e.Status = 'Confirmed'
)
SELECT 
    ClientName,
    MembershipType,
    COUNT(ClassName) AS TotalClasses,
    COUNT(DISTINCT TrainerName) AS UniqueTrainersCount
FROM ConfirmedEnrollments

WHERE ClassDate >= '2026-06-01 00:00:00' 
GROUP BY 
    ClientName, 
    MembershipType

ORDER BY 
    TotalClasses DESC, 
    ClientName ASC
LIMIT 100;

SELECT 
    FullName AS PersonName, 
    Email AS ContactInfo, 
    'Клієнт' AS Role 
FROM Members
UNION ALL
SELECT 
    TrainerName AS PersonName, 
    Specialization AS ContactInfo, 
    'Тренер' AS Role 
FROM Trainers
LIMIT 100;