SELECT subject_id AS "subject",
       block,
       task_name AS task,
       RANK() OVER(PARTITION BY subject_id, block, task_name ORDER BY play_timestamp) as "rank",
       CASE WHEN task_duration < 10 THEN task_duration ELSE NULL END AS "response.time"
FROM "2013-sim-c".nbacks
WHERE subject_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 29, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 54, 55, 56, 57, 58, 60, 62, 63, 64, 65, 66, 67, 68, 69)
AND block LIKE '%M-exp'
AND task_name LIKE '%back'
AND prompt_number NOT LIKE 'prompt%'
ORDER BY "subject", block, task_name, play_timestamp;