-- +migrate Up

-- CoreRoller schema

alter database coreroller set timezone = 'utc';

create extension if not exists "uuid-ossp";

alter table instance add column hostname varchar(50) default 'unresolvable';

-- +migrate Down

alter table instance drop column hostname;
