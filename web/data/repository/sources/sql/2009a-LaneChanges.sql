SELECT
  subject,
  p.annotation as "task",
  "start", "cross", "end", duration,
  direction, start_lane, end_lane
  
FROM "2009-onrd-pta".lanechanges l LEFT OUTER JOIN "2009-onrd-pta".protocol_subject p ON (
  l.subject = p.subject_id AND
  l.start BETWEEN p.start_timestamp AND p.end_timestamp AND
  p.annotation <> '495-drive'
)

order by subject, "start"