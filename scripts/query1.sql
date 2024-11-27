SELECT TO_CHAR(lesson_start, 'Mon') AS Month, COUNT(DISTINCT lesson_id) AS Total,
COUNT(DISTINCT lesson_id) FILTER (WHERE lesson_type='individual') AS Individual,
COUNT(DISTINCT lesson_id) FILTER (WHERE lesson_type='group') AS Group,
COUNT(DISTINCT lesson_id) FILTER (WHERE lesson_type='ensemble') AS Ensemble
FROM lessons WHERE EXTRACT (YEAR FROM lesson_start) = 2024
GROUP BY TO_CHAR(lesson_start, 'Mon'), EXTRACT(MONTH FROM lesson_start) 
ORDER BY EXTRACT(MONTH FROM lesson_start);