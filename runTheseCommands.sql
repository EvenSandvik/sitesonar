/* Only need to run and create an index on test_names. Queries are done by getting tests by test_name*/
CREATE INDEX test_name_idx ON sitesonar_tests(test_name, test_message_json);

/*Possibly run EXPLAIN ANALYZE to see results*/
EXPLAIN ANALYZE SELECT sitesonar_tests.host_id, test_message_json -> 'SINGULARITY_CVMFS_SUPPORTED', ce_name, test_name FROM sitesonar_tests INNER JOIN sitesonar_hosts ON sitesonar_hosts.host_id = sitesonar_tests.host_id WHERE test_name='singularity';