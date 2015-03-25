SELECT
	d.subject_id AS "subject",
	p.annotation AS "task",
	avg(scl_edit) AS "SCL"

FROM "2009-onrd-pta".daq_edit d INNER JOIN "2009-onrd-pta".protocol_subject p ON (
        d.subject_id = p.subject_id AND
        d.unique_unix_timestamp BETWEEN p.start_timestamp AND p.end_timestamp )
WHERE p.annotation = '495-drive'

GROUP BY d.subject_id, p.annotation
ORDER BY d.subject_id, p.annotation