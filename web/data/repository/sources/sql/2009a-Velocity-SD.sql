SELECT
	d.subject_id AS "subject",
	p.annotation AS "annotation",
	stddev_samp(vehicle_speed_abs) AS "SD.Velocity"

FROM "2009-onrd-pta".daq d INNER JOIN "2009-onrd-pta".protocol_subject p ON (
  d.subject_id = p.subject_id AND
  d.unique_unix_timestamp BETWEEN p.start_timestamp AND p.end_timestamp
)
GROUP BY d.subject_id, p.annotation
ORDER BY d.subject_id, p.annotation