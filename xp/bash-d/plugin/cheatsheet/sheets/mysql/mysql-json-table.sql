create table t (
    d json,
    k varchar(64) as (d->"$.k") STORED NOT NULL PRIMARY KEY
);

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
    `_id`      bigint                                      NOT NULL AUTO_INCREMENT,
    `data`     json,
    `username` varchar(64) as (data->"$.username") VIRTUAL NOT NULL,
    `email`    varchar(64) as (data->"$.email")    VIRTUAL NOT NULL,
    PRIMARY KEY (`_id`),
    UNIQUE KEY idx_username (`username`),
    UNIQUE KEY idx_email (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

INSERT INTO `user` (data) VALUES ('{"username": "xp", "email": "xp@bsc", "i":1}');
INSERT INTO `user` (data) VALUES ('{"username": "pp", "email": "pp@bsc", "i":2}');

UPDATE `user`
    SET data = json_set(data, "$.email", i+1)
    WHERE data->"$.username" = "xp";

UPDATE `user`
    SET data = json_set(data, "$.email", "qq")
    WHERE data->"$.username" = "xp";

SELECT data FROM `user` WHERE data->'$.username' = 'xp';
