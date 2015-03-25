SELECT d.subject_id AS "subject",
       p.annotation AS "task",
       avg(d.hr) AS "HR"
FROM "2009-onrd-pta".qrs d INNER JOIN "2009-onrd-pta".protocol_subject p
ON (
    d.subject_id = p.subject_id AND 
    d.unique_unix_timestamp BETWEEN p.start_timestamp AND p.end_timestamp
)
WHERE "session" = ( SELECT MAX("session") FROM "2009-onrd-pta".qrs _inner WHERE _inner.subject_id = d.subject_id )
AND NOT EXISTS (
	SELECT 1
	FROM "2009-onrd-pta".invalid_data i
	WHERE i.subject_id = d.subject_id
	AND d.unique_unix_timestamp BETWEEN i.start_unix_timestamp AND i.end_unix_timestamp
	AND i.columnname = 'EKG'
	AND i.tablename = 'gsrd'
)
AND (
  p.annotation IN ('2-min-baseline', '0-back verbal', '0-back touch', '2-back') OR
  p.annotation LIKE 'recovery%'
)
group by d.subject_id, p.annotation
ORDER BY d.subject_id, p.annotation