SELECT d.subject_id AS "subject",
       p.block,
       p.task,
       d.timestamp,
       d.ibi as "IBI",
       d.hr as "HR"
FROM "2013-sim-c".wheel_hr d INNER JOIN "2013-sim-c".protocol_nback p
ON (
    d.subject_id = p.subject_id AND 
    d.timestamp BETWEEN p.start_timestamp AND p.end_timestamp
)
WHERE d.subject_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 29, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 54, 55, 56, 57, 58, 60, 62, 63, 64, 65, 66, 67, 68, 69)
order by d.subject_id, p.block, p.task