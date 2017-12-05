import requests
import sys
import json
import os
import glob
import time
from natsort import natsorted, ns

uuid = sys.argv[1]
test_size = sys.argv[2]
times = int(sys.argv[3])
worker_node_count = sys.argv[4]
worker_node_type = sys.argv[5]
head_node_type = sys.argv[6]
head_node_count = 2
tag = sys.argv[7]

url = 'http://52.169.163.208/api/benchmark/new'
data = {"uuid": uuid, "provider": "Azure", "test_size": test_size, "head_node_type": head_node_type,
        "head_node_count": head_node_count, "worker_node_type": worker_node_type,
        "worker_node_count": worker_node_count, "tag": tag}
r = requests.post(url, data=data)

if r.status_code == 200:
    print "uuid already exist, try again with another uuid"
    sys.exit()

# Run .hive files and time every bechmark
print "Starting the benchmark"
hive_queries = natsorted(glob.glob("TPCH-framework/scripts/tpch_hive_queries/*.hive"))
run = 0
for query in hive_queries:
    print "Starting benchmark" + query
    with open(query, 'r') as file:
        filedata = file.read()
    newdata = filedata.replace("size_placeholder", test_size)
    with open(query, 'w') as file:
        file.write(newdata)

for run in range(times):
    os.system('hadoop fs -rm -r  -f /hive/warehouse')
    log_file = open("benchmark_output.txt", "w")
    os.system('hive -f TPCH-framework/scripts/prepare_tables.hive &>> table_creation_output.txt')
    url = 'http://52.169.163.208/api/measurement/new'
    data = {"successful": "1", "uuid": str(uuid)}
    query_num = 0
    run += 1
    data["run"] = str(run)

    for query in hive_queries:
        print "Starting benchmark" + query
        query_num += 1
        start_time = time.time()
        # Run hive query
        os.system('hive -f ' + query + ' &>> benchmark_output.txt')
        end_time = time.time()
        data["q" + str(query_num)] = str(round(end_time - start_time, 2))
        log_file = open('benchmark_output.txt', 'rb').read()
        data["log"] = log_file
        r = requests.post(url, data=json.dumps(data))
