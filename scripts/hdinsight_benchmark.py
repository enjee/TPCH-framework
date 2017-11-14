import requests
import sys
import json
import os
import glob
import time
from natsort import natsorted, ns

def add_param(url, param_name, param):
	return url + '&' + param_name + "=" + param

uuid = sys.argv[1]
test_size = sys.argv[2]
times = int(sys.argv[3])


#place the data files into hadoop
print "Creating all Hadoop directories"
print "Creating /" + test_size + "gb_tpch/"
os.system("hadoop   fs -mkdir -p /" + test_size + "gb_tpch/")
print "Creating /" + test_size + "gb_tpch/customer"
os.system("hadoop   fs -mkdir -p /" + test_size + "gb_tpch/customer")
print "Creating /" + test_size + "gb_tpch/lineitem"
os.system("hadoop   fs -mkdir -p /" + test_size + "gb_tpch/lineitem")
print "Creating /" + test_size + "gb_tpch/nation"
os.system("hadoop   fs -mkdir -p /" + test_size + "gb_tpch/nation")
print "Creating /" + test_size + "gb_tpch/orders"
os.system("hadoop   fs -mkdir -p /" + test_size + "gb_tpch/orders")
print "Creating /" + test_size + "gb_tpch/part"
os.system("hadoop   fs -mkdir -p /" + test_size + "gb_tpch/part")
print "Creating /" + test_size + "gb_tpch/partsupp"
os.system("hadoop   fs -mkdir -p /" + test_size + "gb_tpch/partsupp")
print "Creating /" + test_size + "gb_tpch/region"
os.system("hadoop   fs -mkdir -p /" + test_size + "gb_tpch/region")
print "Creating /" + test_size + "gb_tpch/supplier"
os.system("hadoop   fs -mkdir -p /" + test_size + "gb_tpch/supplier")

print "Place all tables into the Hadoop cluster"
os.system("hadoop   fs -rm -f /" + test_size + "gb_tpch/customer/customer.tbl")
print "Placing newly generated customer table into /" + test_size + "gb_tpch/customer/"
os.system("hadoop   fs -copyFromLocal ../dataset/customer.tbl /" + test_size + "gb_tpch/customer/")

os.system("hadoop   fs -rm -f /" + test_size + "gb_tpch/lineitem/lineitem.tbl")
print "Placing newly generated lineitem table into /" + test_size + "gb_tpch/lineitem/"
os.system("hadoop   fs -copyFromLocal ../dataset/lineitem.tbl /" + test_size + "gb_tpch/lineitem/")

os.system("hadoop   fs -rm -f /" + test_size + "gb_tpch/nation/nation.tbl")
print "Placing newly generated nation table into /" + test_size + "gb_tpch/nation/"
os.system("hadoop   fs -copyFromLocal ../dataset/nation.tbl /" + test_size + "gb_tpch/nation/")

os.system("hadoop   fs -rm -f /" + test_size + "gb_tpch/orders/orders.tbl")
print "Placing newly generated orders table into /" + test_size + "gb_tpch/orders/"
os.system("hadoop   fs -copyFromLocal ../dataset/orders.tbl /" + test_size + "gb_tpch/orders/")

os.system("hadoop   fs -rm -f /" + test_size + "gb_tpch/part/part.tbl")
print "Placing newly generated part table into /" + test_size + "gb_tpch/part/"
os.system("hadoop   fs -copyFromLocal ../dataset/part.tbl /" + test_size + "gb_tpch/part/")

os.system("hadoop   fs -rm -f /" + test_size + "gb_tpch/partsupp/partsupp.tbl")
print "Placing newly generated partsupp table into /" + test_size + "gb_tpch/partsupp/"
os.system("hadoop   fs -copyFromLocal ../dataset/partsupp.tbl /" + test_size + "gb_tpch/partsupp/")

os.system("hadoop   fs -rm -f /" + test_size + "gb_tpch/region/region.tbl")
print "Placing newly generated region table into /" + test_size + "gb_tpch/region/"
os.system("hadoop   fs -copyFromLocal ../dataset/region.tbl /" + test_size + "gb_tpch/region/")

os.system("hadoop   fs -rm -f /" + test_size + "gb_tpch/supplier/supplier.tbl")
print "Placing newly generated supplier table into /" + test_size + "gb_tpch/supplier/"
os.system("hadoop   fs -copyFromLocal ../dataset/supplier.tbl /" + test_size + "gb_tpch/supplier/")


print "Removing generated tables from the local directory"
#ramove data from current dir
os.system("rm dataset/*.tbl")

print "Finished generating tables and storing them in the hadoop filesystem"



url = 'http://40.115.29.85:8000/api/benchmark/new?uuid=' + uuid
url = add_param(url, 'provider', 'Azure')
url = add_param(url, 'test_size', test_size)
print url
r = requests.post(url)

if r.status_code == 200:
	print "uuid already exist, try again with another uuid"
	sys.exit()

# Run .hive files and time every bechmark
print "Starting the benchmark"
hive_queries = natsorted(glob.glob("tpch_hive_queries/*.hive"))

run = 0
for run in range(times):
	url = 'http://40.115.29.85:8000/api/measurement/new?uuid=' + uuid
	url = add_param(url, 'successful', '1')
	query_num = 0
	run += 1
	url = add_param(url, 'run', str(run))
	for query in hive_queries:
		print "Starting benchmark"+ query
		query_num += 1
		start_time = time.time()
		#Run hive query
		os.system('hive -f ' + query)
		end_time = time.time()
		url = add_param(url, 'q'+ str(query_num) , str(round(end_time - start_time, 2)))
	r = requests.post(url)

