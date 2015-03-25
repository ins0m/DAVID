SELECT d.subject_id AS "subject",
       p.annotation AS "task",
       d.unique_unix_timestamp AS "timestamp",
       d.hr AS "HR"
FROM "2009-onrd-pta".qrs d INNER JOIN "2009-onrd-pta".protocol_subject p
ON (
    d.subject_id = p.subject_id AND 
    d.unique_unix_timestamp BETWEEN p.start_timestamp AND p.end_timestamp
)
WHERE "session" = ( SELECT MAX("session") FROM "2009-onrd-pta".qrs _inner WHERE _inner.subject_id = d.subject_id )
and p.annotation = '495-drive'
AND NOT EXISTS (
	SELECT 1
	FROM "2009-onrd-pta".invalid_data i
	WHERE i.subject_id = d.subject_id
	AND d.unique_unix_timestamp BETWEEN i.start_unix_timestamp AND i.end_unix_timestamp
	AND i.columnname = 'EKG'
	AND i.tablename = 'gsrd'
)
ORDER BY d.subject_id, p.annotation