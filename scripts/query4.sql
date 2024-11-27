WITH booked AS (
	SELECT lesson, COUNT(*) AS attending FROM attendances GROUP BY lesson
)
SELECT TO_CHAR(lesson_start, 'Day') AS "Day", 
genre AS "Genre", 
maximum_students - attending AS "Nr open slots"
FROM ensemble_lessons JOIN booked ON lesson_id=lesson
WHERE EXTRACT (WEEK FROM lesson_start) = 48
ORDER BY "Day", "Genre";