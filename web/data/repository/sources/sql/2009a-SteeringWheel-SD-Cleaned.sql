SELECT
	d.subject_id AS "subject",
	p.annotation AS "annotation",
	stddev_samp(steering_angle) AS "SD.SteeringAngle"

FROM "2009-onrd-pta".daq d INNER JOIN "2009-onrd-pta".protocol_subject p ON (
        d.subject_id = p.subject_id
        AND d.unique_unix_timestamp BETWEEN p.start_timestamp AND p.end_timestamp )
LEFT JOIN "2009-onrd-pta".lanechanges lc ON (
        d.subject_id = lc.subject
        AND NOT (d.unique_unix_timestamp BETWEEN lc."start" and lc."end" ) )
WHERE p.annotation <> '495-drive'
GROUP BY d.subject_id, p.annotation
ORDER BY d.subject_id, p.annotation