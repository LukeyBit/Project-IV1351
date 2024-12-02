WITH booked AS (
	SELECT 
        lesson, 
        COUNT(*) AS attending 
    FROM attendances
    GROUP BY lesson
)
SELECT 
    TO_CHAR(lesson_start, 'YYYY-MM-DD') AS "Date",
    EXTRACT(WEEK FROM lesson_start) AS "Week",
    TO_CHAR(lesson_start, 'Day') AS "Day", 
    genre AS "Genre", 
    CASE 
        WHEN maximum_students - COALESCE(attending, 0) = 0 THEN 'none'
        WHEN maximum_students - COALESCE(attending, 0) <= 2 THEN '1-2'
        ELSE 'many'
    END AS "Nr open slots"
FROM ensemble_lessons 
LEFT JOIN booked ON lesson_id=lesson
WHERE EXTRACT(WEEK FROM lesson_start) = 49
ORDER BY lesson_start, "Genre";