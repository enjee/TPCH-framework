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

#place the data files into hadoop
print "Creating all Hadoop directories"
print "Creating /tpch/"
os.system("hadoop   fs -mkdir -p /tpch/")
print "Creating /tpch/customer"
os.system("hadoop   fs -mkdir -p /tpch/customer")
print "Creating /tpch/lineitem"
os.system("hadoop   fs -mkdir -p /tpch/lineitem")
print "Creating /tpch/nation"
os.system("hadoop   fs -mkdir -p /tpch/nation")
print "Creating /tpch/orders"
os.system("hadoop   fs -mkdir -p /tpch/orders")
print "Creating /tpch/part"
os.system("hadoop   fs -mkdir -p /tpch/part")
print "Creating /tpch/partsupp"
os.system("hadoop   fs -mkdir -p /tpch/partsupp")
print "Creating /tpch/region"
os.system("hadoop   fs -mkdir -p /tpch/region")
print "Creating /tpch/supplier"
os.system("hadoop   fs -mkdir -p /tpch/supplier")

print "Place all tables into the Hadoop cluster"
os.system("hadoop   fs -rm -f /tpch/customer/customer.tbl")
print "Placing customer table into /tpch/customer/"
os.system("hadoop   fs -copyFromLocal ~/dataset/customer.tbl /tpch/customer/")

os.system("hadoop   fs -rm -f /tpch/lineitem/lineitem.tbl")
print "Placing lineitem table into /tpch/lineitem/"
os.system("hadoop   fs -copyFromLocal ~/dataset/lineitem.tbl /tpch/lineitem/")

os.system("hadoop   fs -rm -f /tpch/nation/nation.tbl")
print "Placing nation table into /tpch/nation/"
os.system("hadoop   fs -copyFromLocal ~/dataset/nation.tbl /tpch/nation/")

os.system("hadoop   fs -rm -f /tpch/orders/orders.tbl")
print "Placing orders table into /tpch/orders/"
os.system("hadoop   fs -copyFromLocal ~/dataset/orders.tbl /tpch/orders/")

os.system("hadoop   fs -rm -f /tpch/part/part.tbl")
print "Placing part table into /tpch/part/"
os.system("hadoop   fs -copyFromLocal ~/dataset/part.tbl /tpch/part/")

os.system("hadoop   fs -rm -f /tpch/partsupp/partsupp.tbl")
print "Placing partsupp table into /tpch/partsupp/"
os.system("hadoop   fs -copyFromLocal ~/dataset/partsupp.tbl /tpch/partsupp/")

os.system("hadoop   fs -rm -f /tpch/region/region.tbl")
print "Placing region table into /tpch/region/"
os.system("hadoop   fs -copyFromLocal ~/dataset/region.tbl /tpch/region/")

os.system("hadoop   fs -rm -f /tpch/supplier/supplier.tbl")
print "Placing supplier table into /tpch/supplier/"
os.system("hadoop   fs -copyFromLocal ~/dataset/supplier.tbl /tpch/supplier/")


print "Removing generated tables from the local directory"
#ramove data from current dir
os.system("rm ~/dataset/*.tbl")

print "Finished generating tables and storing them in the hadoop filesystem"



url = 'http://40.115.29.85:8000/api/benchmark/new'
data = {"uuid": uuid,"provider":"Azure", "test_size": test_size, "head_node_type": head_node_type, "head_node_count": head_node_count, "worker_node_type": worker_node_type, "worker_node_count": worker_node_count, "tag": tag}
r = requests.post(url, data = data)

if r.status_code == 200:
	print "uuid already exist, try again with another uuid"
	sys.exit()

# Run .hive files and time every bechmark
print "Starting the benchmark"
hive_queries = natsorted(glob.glob("TPCH-framework/scripts/tpch_hive_queries/*.hive"))
run = 0

for run in range(times):
	log_file = open("benchmark_output.txt", "w")
	url = 'http://52.169.163.208/api/measurement/new'
	data = {"successful":"1", "uuid": str(uuid)}
	query_num = 0
	run += 1
	data["run"] = str(run)
	for query in hive_queries:
		print "Starting benchmark"+ query
		query_num += 1
		start_time = time.time()
		#Run hive query
		os.system('hive -f ' + query + ' &>> benchmark_output.txt')
		end_time = time.time()
		data["q" +str(query_num)] = str(round(end_time - start_time, 2))
	log_file = open('benchmark_output.txt', 'rb').read()
	data["log"] = log_file
	r = requests.post(url, data = json.dumps(data))

