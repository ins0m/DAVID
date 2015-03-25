SELECT
  _times.*,
  string_agg(DISTINCT p.annotation, '/')
  
FROM
(
        select 
                _start.subject as "subject",
                _start.end_lane as "lane",
                _start.cross as "cross_previous_lane_change",
                min(_end.cross) as "cross_next_lane_change",
                min(_end.cross) - _start.cross as "time_in_lane"
                
        from "2009-onrd-pta".lanechanges as _start join "2009-onrd-pta".lanechanges as _end on (
                _start.subject = _end.subject AND
                _start.end_lane = _end.start_lane)
                
        where _end.start > _start.end
        group by _start.subject, _start.cross, _start.end_lane
        order by subject, cross_previous_lane_change
) _times LEFT OUTER JOIN "2009-onrd-pta".protocol_subject p ON (
  _times.subject = p.subject_id AND
  (p.start_timestamp BETWEEN _times.cross_previous_lane_change AND _times.cross_next_lane_change OR
  p.end_timestamp BETWEEN _times.cross_previous_lane_change AND _times.cross_next_lane_change) AND
  p.annotation <> '495-drive'
)

GROUP BY _times.subject, _times.lane, _times.cross_previous_lane_change, _times.cross_next_lane_change, _times.time_in_lane
ORDER BY _times.subject, _times.cross_previous_lane_change