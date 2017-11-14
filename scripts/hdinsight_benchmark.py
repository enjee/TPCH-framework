import requests
import sys
import json
import os
import glob
import time
from natsort import natsort

def add_param(url, param_name, param):
	return url + '&' + param_name + "=" + param

times = 3

uuid = sys.argv[1]

url = 'http://40.115.29.85:8000/api/benchmark/new?uuid=' + uuid
url = add_param(url, 'provider', 'Azure')
url = add_param(url, 'test_size', '10GB')
print url
r = requests.post(url)

if r.status_code == 200:
	print "uuid already exist, try again with another uuid"
	sys.exit()

# Run .hive files and time every bechmark
print "Starting the benchmark"
hive_queries = natsort(glob.glob("tpch_hive_queries/*.hive"))

run = 0
for run in range(times):
	url = 'http://40.115.29.85:8000/api/measurement/new?uuid=' + uuid
	query_num = 0
	run += 1
	url = add_param(url, 'run', str(run))
	for query in hive_queries:
		query_num += 1
		start_time = time.time()
		#Run hive query
		os.system('hive -f ' + query)
		end_time = time.time()
		url = add_param(url, 'q'+ str(query_num) , str(round(end_time - start_time, 2)))
	r = requests.post(url)
	if r.status_code == 201:
		url = add_param(url, 'successful', '1')
	elif r.status_code == 200:
		url = add_param(url, 'successful', '0')


