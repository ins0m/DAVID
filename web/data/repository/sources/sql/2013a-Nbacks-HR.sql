SELECT d.subject_id AS "subject",
       p.block,
       p.task,
       d.unique_unix_timestamp AS "timestamp",
       d.hr AS "HR"
FROM "2013-onrd-a".qrs d INNER JOIN "2013-onrd-a".protocol_nback p
ON (
    d.subject_id = p.subject_id AND 
    d.unique_unix_timestamp BETWEEN p.start_timestamp AND p.end_timestamp
)
WHERE "session" = ( SELECT MAX("session") FROM "2013-onrd-a".qrs _inner WHERE _inner.subject_id = d.subject_id )
AND NOT EXISTS (
	SELECT 1
	FROM "2013-onrd-a".invalid_data i
	WHERE i.subject_id = d.subject_id
	AND d.unique_unix_timestamp BETWEEN i.start_unix_timestamp AND i.end_unix_timestamp
	AND i.columnname = 'EKG'
	AND i.tablename = 'gsrd'
)
AND d.subject_id IN (1, 2, 3, 4, 6, 8, 9, 11, 12, 13, 14, 15, 18, 21, 22, 23, 24, 25, 26, 27, 29, 30, 32, 34, 36, 37, 38, 39, 43, 44, 45, 48, 51, 52, 53, 54, 55, 56, 58, 60, 61, 62, 63, 65, 66, 67, 69, 70, 71, 72, 73, 75, 76, 79, 80, 82, 83, 84, 85, 87, 88, 89, 90, 91)
ORDER BY d.subject_id, p.block, p.task