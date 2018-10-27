create table t (
    d json,
    k varchar(64) as (d->"$.k") stored not null primary key
);
