select
  _start.subject_id as "subject",
  _start.unique_unix_timestamp as "start",
  _cross.unique_unix_timestamp as "cross",
  _end.unique_unix_timestamp as "end",
  _start.duration as "duration",
  left(_type_code.description, 1) as "direction",
  split_part(_type_code.description, '-', 2) as "start_lane",
  split_part(_type_code.description, '-', 3) as "end_lane"
from "2009-onrd-pta".annotated_data _start
inner join "2009-onrd-pta".annotated_data _end
on (
  _end.unique_unix_timestamp = _start.unique_unix_timestamp + _start.duration
  and _start.code = _end.code
)
inner join "2009-onrd-pta".annotated_data _cross
on (
  _cross.unique_unix_timestamp > _start.unique_unix_timestamp
  and _cross.unique_unix_timestamp < _end.unique_unix_timestamp
  and _start.code = _cross.code
  and _end.code = _cross.code
)
inner join "2009-onrd-pta".annotated_type_code _type_code
on (
  _start.code = _type_code.code_id
)

where _start.code in (
  select code_id
  from "2009-onrd-pta".annotated_type_code
  where annotated_type = ( select type_id from "2009-onrd-pta".annotated_type where description = 'lane' )
)