SELECT d.subject_id AS "subject", p.annotation AS "annotation", stddev(str_whl_angle) AS "SD.SWR"

FROM "2013-onrd-a".daq d INNER JOIN "2013-onrd-a".protocol_subject p USING (subject_id)

WHERE d.unique_unix_timestamp BETWEEN p.start_timestamp AND p.end_timestamp
GROUP BY d.subject_id, p.annotation
ORDER BY d.subject_id ASC