import requests
import sys
import json
import os
import glob
import time

def add_param(url, param_name, param):
	return url + '&' + param_name + "=" + param

times = 3

uuid = sys.argv[1]

url = 'http://193.70.6.75:7778/api/benchmark/new?uuid=' + uuid
url = add_param(url, 'provider', 'Azure')
url = add_param(url, 'test_size', '10GB')
print url
r = requests.post(url)

# Response, status etc
print r.status_code
# print r.text


url = 'http://193.70.6.75:7778/api/measurement/new?uuid=' + uuid
url = add_param(url, 'successful', '1')
# Run .hive files and time every bechmark
print "Starting the benchmark"
hive_queries = sorted(glob.glob("tpch_hive_queries/*.hive"))
query_num = 0
run = 0
for run in range(times):
	run += 1
	url = add_param(url, 'run', str(run))
	for query in hive_queries:
		query_num += 1
		start_time = time.time()
		os.system('hive -f ' + query)
		end_time = time.time()
		url = add_param(url, 'q'+ str(query_num) , str(end_time - start_time))
	r = requests.post(url)
	print r.status_code


