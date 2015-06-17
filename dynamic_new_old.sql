CREATE OR REPLACE PACKAGE dynamic_new_old IS
PROCEDURE clear;
PROCEDURE populate_with_rowid (p_rowid ROWID);
FUNCTION rowid_exists RETURN BOOLEAN;
FUNCTION current_rowid RETURN ROWID;
PROCEDURE set_table_name (p_table VARCHAR2);
PROCEDURE set_log_table_name (p_table VARCHAR2);
PROCEDURE set_log_table_seq_name (p_seq VARCHAR2);
PROCEDURE create_column_names;
PROCEDURE save_diff_log (p_rowid ROWID);
END;
/

CREATE OR REPLACE PACKAGE BODY dynamic_new_old IS
TYPE type_plsql_table IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
m_plsql_table type_plsql_table;
m_rec_number BINARY_INTEGER;
TYPE type_column_table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
m_column_table type_column_table;
m_column_number BINARY_INTEGER;
m_table VARCHAR2 (30);
m_log_table VARCHAR2 (30);
m_log_table_seq VARCHAR2(30);
m_update_time TIMESTAMP;

PROCEDURE clear IS
BEGIN
m_rec_number := 0;
END;

PROCEDURE populate_with_rowid (p_rowid ROWID) IS
BEGIN
m_rec_number := m_rec_number + 1;
m_plsql_table (m_rec_number) := p_rowid;
END;

FUNCTION rowid_exists RETURN BOOLEAN IS
BEGIN
RETURN (m_rec_number > 0);
END;

FUNCTION current_rowid RETURN ROWID IS
v_rowid VARCHAR2 (18);
BEGIN
v_rowid := m_plsql_table (m_rec_number);
m_rec_number := m_rec_number - 1;
RETURN v_rowid;
END;

PROCEDURE clear_columns IS
BEGIN
m_column_number := 0;
END;

PROCEDURE populate_with_column_name (p_column_name VARCHAR2) IS
BEGIN
m_column_number := m_column_number + 1;
m_column_table (m_column_number) := p_column_name;
END;

FUNCTION column_name_exists RETURN BOOLEAN IS
BEGIN
RETURN (m_column_number > 0);
END;

FUNCTION current_column_name RETURN VARCHAR2 IS
v_column_name VARCHAR2(30);
BEGIN
v_column_name := m_column_table (m_column_number);
m_column_number := m_column_number - 1;
RETURN v_column_name;
END;

PROCEDURE set_table_name (p_table VARCHAR2) IS
BEGIN
m_table := UPPER (p_table);
END;

PROCEDURE set_log_table_name (p_table VARCHAR2) IS
BEGIN
m_log_table := UPPER (p_table);
END;

PROCEDURE set_log_table_seq_name (p_seq VARCHAR2) IS
BEGIN
m_log_table_seq := UPPER (p_seq);
END;

PROCEDURE create_column_names IS
BEGIN
  clear_columns;
  FOR rec IN
  (SELECT column_name
  FROM user_tab_columns
  WHERE table_name = m_table)
  LOOP
  populate_with_column_name(rec.column_name);
  END LOOP;
END;

PROCEDURE insert_diff (p_old_value VARCHAR2, p_new_value VARCHAR2, p_column_name VARCHAR2) IS
v_sql_statement VARCHAR2(4000);
BEGIN
  v_sql_statement := 'INSERT INTO ' || m_log_table || ' (ID, OLD, NEW, FIELD_NAME, DATE_CHANGE) VALUES (' || m_log_table_seq || '.nextval, '''
  || p_old_value || ''', ''' || p_new_value || ''', ''' || p_column_name || ''', ''' || m_update_time || ''')';
  execute immediate v_sql_statement;
END;

FUNCTION get_value (p_rowid ROWID, p_column_name VARCHAR2) RETURN VARCHAR2 IS
v_value VARCHAR2 (4000);
v_sql_statement VARCHAR2(4000);
BEGIN
  v_sql_statement := 'SELECT ' || p_column_name || ' FROM ' || m_table || ' WHERE ROWID = ''' || p_rowid || '''';
  execute immediate v_sql_statement INTO v_value;
  RETURN v_value;
END;

FUNCTION get_old_value (p_rowid ROWID, p_column_name VARCHAR2)  RETURN VARCHAR2 IS
PRAGMA AUTONOMOUS_TRANSACTION;
v_column_name VARCHAR2 (30);
v_old_value VARCHAR2 (4000);
BEGIN
  v_old_value := get_value (p_rowid, p_column_name);
  RETURN v_old_value;
END;

FUNCTION get_new_value (p_rowid ROWID, p_column_name VARCHAR2)  RETURN VARCHAR2 IS
v_column_name VARCHAR2 (30);
v_new_value VARCHAR2 (4000);
BEGIN
  v_new_value := get_value (p_rowid, p_column_name);
  RETURN v_new_value;
END;

PROCEDURE save_diff_log (p_rowid ROWID) IS
v_column_name VARCHAR2 (30);
v_old_value VARCHAR2 (4000);
v_new_value VARCHAR2 (4000);
BEGIN
  execute immediate 'SELECT SYSTIMESTAMP FROM DUAL' INTO m_update_time;
  WHILE column_name_exists LOOP
    v_column_name := current_column_name;
    v_old_value := get_old_value(p_rowid, v_column_name);
    v_new_value := get_new_value(p_rowid, v_column_name);
    IF v_old_value <> v_new_value THEN
      insert_diff (v_old_value, v_new_value, v_column_name);
    END IF;
  END LOOP;
END;

END;
/

CREATE OR REPLACE TRIGGER TG_TEST
AFTER UPDATE ON TEST
DECLARE
v_current_rowid ROWID;
BEGIN
  dynamic_new_old.set_table_name ('TEST');
  dynamic_new_old.set_log_table_name('TEST_LOG');
  dynamic_new_old.set_log_table_seq_name('SQ_TEST_LOG');
  WHILE dynamic_new_old.rowid_exists LOOP
    dynamic_new_old.create_column_names;
    v_current_rowid := dynamic_new_old.current_rowid;
    dynamic_new_old.save_diff_log (v_current_rowid);
  END LOOP;
END;
/

CREATE OR REPLACE TRIGGER TG_CLEAR
BEFORE UPDATE ON TEST
BEGIN
dynamic_new_old.clear;
END;
/

CREATE OR REPLACE TRIGGER TG_POPULATE
BEFORE UPDATE ON TEST
FOR EACH ROW
BEGIN
dynamic_new_old.populate_with_rowid (:OLD.ROWID);
END;
/