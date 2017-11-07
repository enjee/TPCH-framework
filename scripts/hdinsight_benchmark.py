import requests
import sys
import json

def add_param(url, param_name, param):
    return url + '&' + param_name + "=" + param



uuid = sys.argv[1]

url = 'http://193.70.6.75:7778/api/benchmark/new?uuid=' + uuid
url = add_param(url, 'provider', 'Azure')
url = add_param(url, 'test_size', '10GB')
print url
r = requests.post(url)

# Response, status etc
print r.status_code
print r.text


url = 'http://193.70.6.75:7778/api/measurement/new?uuid=' + uuid
url = add_param(url, 'run', '1')
url = add_param(url, 'successful', '1')
url = add_param(url, 'q1', '3232')
url = add_param(url, 'q2', '3232')
url = add_param(url, 'q3', '3232')
url = add_param(url, 'q4', '3232')
url = add_param(url, 'q5', '3232')
url = add_param(url, 'q6', '3232')
url = add_param(url, 'q7', '3232')
url = add_param(url, 'q8', '3232')
url = add_param(url, 'q9', '3232')
url = add_param(url, 'q10', '3232')
url = add_param(url, 'q11', '3232')
url = add_param(url, 'q12', '3232')
url = add_param(url, 'q13', '3232')
url = add_param(url, 'q14', '3232')
url = add_param(url, 'q15', '3232')
url = add_param(url, 'q16', '3232')
url = add_param(url, 'q17', '3232')
url = add_param(url, 'q18', '3232')
url = add_param(url, 'q19', '3232')
url = add_param(url, 'q20', '3232')
url = add_param(url, 'q21', '3232')
url = add_param(url, 'q22', '3232')
print url
r = requests.post(url)


# Response, status etc
print r.status_code
print r.text

url = 'http://193.70.6.75:7778/api/measurement/new?uuid=' + uuid
url = add_param(url, 'run', '2')
url = add_param(url, 'successful', '1')
url = add_param(url, 'q1', '3232')
url = add_param(url, 'q2', '3232')
url = add_param(url, 'q3', '3232')
url = add_param(url, 'q4', '3232')
url = add_param(url, 'q5', '3232')
url = add_param(url, 'q6', '3232')
url = add_param(url, 'q7', '3232')
url = add_param(url, 'q8', '3232')
url = add_param(url, 'q9', '3232')
url = add_param(url, 'q10', '3232')
url = add_param(url, 'q11', '3232')
url = add_param(url, 'q12', '3232')
url = add_param(url, 'q13', '3232')
url = add_param(url, 'q14', '3232')
url = add_param(url, 'q15', '3232')
url = add_param(url, 'q16', '3232')
url = add_param(url, 'q17', '3232')
url = add_param(url, 'q18', '3232')
url = add_param(url, 'q19', '3232')
url = add_param(url, 'q20', '3232')
url = add_param(url, 'q21', '3232')
url = add_param(url, 'q22', '3232')
print url
r = requests.post(url)


# Response, status etc
print r.status_code
print r.text


url = 'http://193.70.6.75:7778/api/measurement/new?uuid=' + uuid
url = add_param(url, 'run', '3')
url = add_param(url, 'successful', '1')
url = add_param(url, 'q1', '3232')
url = add_param(url, 'q2', '3232')
url = add_param(url, 'q3', '3232')
url = add_param(url, 'q4', '3232')
url = add_param(url, 'q5', '3232')
url = add_param(url, 'q6', '3232')
url = add_param(url, 'q7', '3232')
url = add_param(url, 'q8', '3232')
url = add_param(url, 'q9', '3232')
url = add_param(url, 'q10', '3232')
url = add_param(url, 'q11', '3232')
url = add_param(url, 'q12', '3232')
url = add_param(url, 'q13', '3232')
url = add_param(url, 'q14', '3232')
url = add_param(url, 'q15', '3232')
url = add_param(url, 'q16', '3232')
url = add_param(url, 'q17', '3232')
url = add_param(url, 'q18', '3232')
url = add_param(url, 'q19', '3232')
url = add_param(url, 'q20', '3232')
url = add_param(url, 'q21', '3232')
url = add_param(url, 'q22', '3232')
print url
r = requests.post(url)


# Response, status etc
print r.status_code
print r.text