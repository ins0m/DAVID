select
  d.subject_id as "subject",
  d.unique_unix_timestamp as "timestamp",
  p.annotation AS "task",
  d.scl_edit as "SCL_edit",
  l.direction,
  l.start_lane,
  l.end_lane,
  dense_rank() over (order by l.start) as "index",
  case when d.unique_unix_timestamp < l.start then 'pre' else 'post' end as "type"

from "2009-onrd-pta".daq_edit d inner join "2009-onrd-pta".lanechanges l on (
  d.subject_id = l.subject and
  d.unique_unix_timestamp between l.start - 10 and l.start + 10
) LEFT OUTER JOIN "2009-onrd-pta".protocol_subject p ON (
  d.subject_id = p.subject_id AND
  d.unique_unix_timestamp BETWEEN p.start_timestamp AND p.end_timestamp AND
  p.annotation <> '495-drive'
)

ORDER BY d.subject_id, d.unique_unix_timestamp