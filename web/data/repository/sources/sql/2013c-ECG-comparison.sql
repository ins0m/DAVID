SELECT d.subject_id AS `subject`,
       p.block,
       p.task,
       d.unique_unix_timestamp AS `timestamp`,
       d.EKG AS `ECG`
FROM gsrd d INNER JOIN protocol_nback p
ON (
    d.subject_id = p.subject_id AND 
    d.unique_unix_timestamp BETWEEN p.start_timestamp AND p.end_timestamp
)
WHERE d.subject_id IN (1, 3, 4, 5, 6, 8, 9, 10, 12, 13, 14, 16, 19, 20)
AND p.block = 'AV-exp' AND p.task = 'ref'
ORDER BY d.subject_id, d.unique_unix_timestamp