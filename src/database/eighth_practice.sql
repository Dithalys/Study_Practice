ALTER SYSTEM SET track_io_timing = on;
ALTER SYSTEM SET track_functions = 'all';
SELECT pg_reload_conf();

SELECT 
    relname AS table_name,
    seq_scan AS full_table_scans,
    seq_tup_read AS rows_read_by_full_scan,
    idx_scan AS index_scans,
    n_tup_ins AS rows_inserted,
    n_tup_upd AS rows_updated
FROM pg_stat_user_tables;

SELECT 
    relname AS table_name,
    indexrelname AS index_name,
    idx_scan AS number_of_scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched
FROM pg_stat_user_indexes;

SELECT 
    datname AS database_name,
    blk_read_time AS total_read_time_ms,
    blk_write_time AS total_write_time_ms
FROM pg_stat_database
WHERE datname = current_database();

SELECT 
    funcname AS function_name,
    calls AS total_calls,
    total_time AS total_execution_time_ms,
    self_time AS self_execution_time_ms
FROM pg_stat_user_functions;
