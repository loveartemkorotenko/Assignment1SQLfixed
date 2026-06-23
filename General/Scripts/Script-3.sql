
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