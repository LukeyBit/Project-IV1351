SELECT instructor_id, name, COUNT(DISTINCT instructor) AS lessons FROM instructors 
JOIN lessons ON instructor_id=instructor GROUP BY instructor_id ORDER BY instructor_id;