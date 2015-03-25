SELECT d.subject_id AS "subject",
       p.block,
       p.task,
       SUM(ABS(d.swr_minor)) AS "SWR.Minor"
FROM "2013-onrd-a".daq_edit d INNER JOIN "2013-onrd-a".protocol_nback p
ON (
    d.subject_id = p.subject_id AND 
    d.unique_unix_timestamp BETWEEN p.start_timestamp AND p.end_timestamp
)
WHERE d.subject_id IN (1, 2, 3, 4, 6, 8, 9, 11, 12, 13, 14, 15, 18, 21, 22, 23, 24, 25, 26, 27, 29, 30, 32, 34, 36, 37, 38, 39, 43, 44, 45, 48, 51, 52, 53, 54, 55, 56, 58, 60, 61, 62, 63, 65, 66, 67, 69, 70, 71, 72, 73, 75, 76, 79, 80, 82, 83, 84, 85, 87, 88, 89, 90, 91)
GROUP BY d.subject_id, block, task
ORDER BY d.subject_id, block, task