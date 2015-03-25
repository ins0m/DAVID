select
  d.subject_id as "subject",
  d.unique_unix_timestamp as "timestamp",
  p.annotation as "task",
  d.hr as "HR",
  l.direction,
  l.start_lane,
  l.end_lane,
  dense_rank() over (order by l.start) as "index",
  case when d.unique_unix_timestamp < l.start then 'pre' else 'post' end as "type"

from "2009-onrd-pta".qrs d inner join "2009-onrd-pta".lanechanges l on (
  d.subject_id = l.subject and
  d.unique_unix_timestamp between l.start - 10 and l.start + 10 AND
  d.session = (
    select max("session")
    from "2009-onrd-pta".qrs i
    where i.subject_id = d.subject_id
  )
) LEFT OUTER JOIN "2009-onrd-pta".protocol_subject p ON (
  d.subject_id = p.subject_id AND
  d.unique_unix_timestamp BETWEEN p.start_timestamp AND p.end_timestamp AND
  p.annotation <> '495-drive'
)

WHERE not exists (
  SELECT 1
  FROM "2009-onrd-pta".invalid_data i
  WHERE i.subject_id = d.subject_id
  AND d.unique_unix_timestamp BETWEEN i.start_unix_timestamp AND i.end_unix_timestamp
  AND i.columnname = 'EKG'
  AND i.tablename = 'gsrd' 
)

ORDER BY d.subject_id, l.start, d.unique_unix_timestamp