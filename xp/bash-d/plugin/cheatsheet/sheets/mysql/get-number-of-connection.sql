show status where `variable_name` = 'Threads_connected';
-- +-------------------+-------+
-- | Variable_name     | Value |
-- +-------------------+-------+
-- | Threads_connected | 123   |
-- +-------------------+-------+

show status like "%hread%";

-- +------------------------------------------+---------+
-- | Variable_name                            | Value   |
-- +------------------------------------------+---------+
-- | Delayed_insert_threads                   | 0       |
-- | Performance_schema_thread_classes_lost   | 0       |
-- | Performance_schema_thread_instances_lost | 0       |
-- | Slow_launch_threads                      | 6308    |
-- | Threads_cached                           | 55      |
-- | Threads_connected                        | 125     |
-- | Threads_created                          | 1971978 |
-- | Threads_running                          | 9       |
-- +------------------------------------------+---------+
