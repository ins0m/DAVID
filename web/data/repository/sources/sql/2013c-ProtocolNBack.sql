select
        subject_id as subject,
        block,
        task,
        start_timestamp as "start",
        end_timestamp as "end"
from "2013-sim-c".protocol_nback
where block like '%-exp'
order by subject_id, block, task