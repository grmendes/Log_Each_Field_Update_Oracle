insert into test (id, field1, field2, field3, field4) values ('1', 'f11', 'f21', 'f31', 'f41');
insert into test (id, field1, field2, field3, field4) values ('2', 'f12', 'f22', 'f32', 'f42');
insert into test (id, field1, field2, field3, field4) values ('3', 'f13', 'f23', 'f33', 'f43');
insert into test (id, field1, field2, field3, field4) values ('4', 'f14', 'f24', 'f34', 'f44');
insert into test (id, field1, field2, field3, field4) values ('5', 'f15', 'f25', 'f35', 'f45');
insert into test (id, field1, field2, field3, field4) values ('6', 'f16', 'f26', 'f36', 'f46');
insert into test (id, field1, field2, field3, field4) values ('7', 'f17', 'f27', 'f37', 'f47');
insert into test (id, field1, field2, field3, field4) values ('8', 'f18', 'f28', 'f38', 'f48');
insert into test (id, field1, field2, field3, field4) values ('9', 'f19', 'f29', 'f39', 'f49');
insert into test (id, field1, field2, field3, field4) values ('10', 'f10', 'f20', 'f30', 'f40');
commit;

update test set field1 = 'field1', field2 = 'field2', field3 = 'field3', field4 = 'field4' where id = 1;
commit;
update test set field1 = 'field1', field2 = 'field2', field3 = 'field3', field4 = 'field4' where id between '2' and '5';
commit;