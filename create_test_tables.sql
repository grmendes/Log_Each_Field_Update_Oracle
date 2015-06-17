DROP TABLE OW_SUS_DEV.TEST;
CREATE TABLE OW_SUS_DEV.TEST
(
   Id int NOT NULL,
   field1 varchar(255) NOT NULL,
   field2 varchar(255),
   field3 varchar(255),
   field4 varchar(255),
   PRIMARY KEY (Id)
);

DROP TABLE OW_SUS_DEV.TEST_LOG;
CREATE TABLE OW_SUS_DEV.TEST_LOG
(
   Id int NOT NULL,
   Old varchar(255) NOT NULL,
   NEW varchar(255) NOT NULL,
   FIELD_NAME varchar(255) NOT NULL,
   DATE_CHANGE TIMESTAMP NOT NULL,
   PRIMARY KEY (Id)
);

DROP SEQUENCE OW_SUS_DEV.SQ_TEST_LOG;
CREATE SEQUENCE OW_SUS_DEV.SQ_TEST_LOG
 START WITH     1
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;