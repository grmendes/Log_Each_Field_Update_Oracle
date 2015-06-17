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
