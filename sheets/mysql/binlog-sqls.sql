SHOW BINLOG EVENTS
-- +------------------+-----+----------------+-----------+-------------+---------------------------------------+
-- | Log_name         | Pos | Event_type     | Server_id | End_log_pos | Info                                  |
-- +------------------+-----+----------------+-----------+-------------+---------------------------------------+
-- | mysql-bin.000001 |   4 | Format_desc    |     13306 |         123 | Server ver: 5.7.20-log, Binlog ver: 4 |
-- | mysql-bin.000001 | 123 | Previous_gtids |     13306 |         150 |                                       |
-- | mysql-bin.000001 | 150 | Rotate         |     13306 |         193 | mysql-bin.000002;pos=4                |
-- +------------------+-----+----------------+-----------+-------------+---------------------------------------+

SHOW BINLOG EVENTS IN 'mysql-bin.000003'

-- syntax:
SHOW BINLOG EVENTS
   [IN 'log_name']
   [FROM pos]
   [LIMIT [offset,] row_count]



