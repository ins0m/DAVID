select
  d.subject_id as "subject",
  d.unique_unix_timestamp as "timestamp",
  p.annotation as "task",
  d.vehicle_speed_abs as "velocity",
  l.direction,
  l.start_lane,
  l.end_lane,
  dense_rank() over (order by l.start) as "index",
  case row_number() over (partition by l.start) when 1 then 'before' when 2 then 'start' else 'end' end as "type"

from "2009-onrd-pta".daq d inner join "2009-onrd-pta".lanechanges l on (
  d.subject_id = l.subject and
  d.unique_unix_timestamp in (l.start - 15, l.start, l.end)
) LEFT OUTER JOIN "2009-onrd-pta".protocol_subject p ON (
  d.subject_id = p.subject_id AND
  d.unique_unix_timestamp BETWEEN p.start_timestamp AND p.end_timestamp AND
  p.annotation <> '495-drive'
)

ORDER BY d.subject_id, l.start, d.unique_unix_timestamp