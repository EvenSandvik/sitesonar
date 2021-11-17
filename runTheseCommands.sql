/* Create these indexes */
CREATE INDEX updated_and_name_idx ON sitesonar_tests (last_updated, test_name);

CREATE INDEX host_idx ON sitesonar_hosts (host_id);

/* EXPLAIN ANALYZE of typical query done by site sonar */
EXPLAIN ANALYZE SELECT sitesonar_tests.host_id, test_message_json -> 'SINGULARITY_CVMFS_SUPPORTED', ce_name, test_name FROM sitesonar_tests INNER JOIN sitesonar_hosts ON sitesonar_hosts.host_id = sitesonar_tests.host_id WHERE last_updated > '1635860606' AND test_name='singularity';
