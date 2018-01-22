import sys, os

public_dir = os.path.dirname(os.path.abspath(__file__)) + "/../cap-api/public/"
data_dir = os.path.dirname(os.path.abspath(__file__)) + "/analytics_data/"
blade_dir = os.path.dirname(os.path.abspath(__file__)) + "/../cap-api/resources/views/"
target_dir = os.path.dirname(os.path.abspath(__file__)) + "/../../TPCH-analytics/"
if not os.path.isdir(target_dir):
    os.mkdir(target_dir)
    os.mkdir(target_dir + "js")
    os.mkdir(target_dir + "css")

for root, dirs, files in os.walk(public_dir + "js"):
    for filename in files:
        s = open(public_dir + "js/" + filename).read()
        f = open(target_dir + "js/" + filename, 'w')
        f.write(s)
        f.close()

for root, dirs, files in os.walk(public_dir + "css"):
    for filename in files:
        s = open(public_dir + "css/" + filename).read()
        f = open(target_dir + "css/" + filename, 'w')
        f.write(s)
        f.close()

for root, dirs, files in os.walk(data_dir):
    for filename in files:
        s = open(data_dir + filename).read()
        f = open(target_dir + filename, 'w')
        f.write(s)
        f.close()


s = open(blade_dir + "analytics.blade.php").read()
analytics = ""
reading = False
for line in s.split("\n"):
    if reading:
        if "@extends" in line:
            continue
        if "</body>" in line:
            reading = False
            continue

        analytics += line.replace("') }}", "").replace("{{ asset('", "") + "\n"


    if "<body>" in line:
        reading = True

s = open(blade_dir + "base.blade.php").read()
base = ""
for line in s.split("\n"):
    if "@section('content')" in line:
        base += analytics + "\n"
        continue
    if "@" in line:
        continue
    base += line.replace("') }}", "").replace("{{ asset('", "").replace("href=\"/timeline\"", "href=\"/index.html\"").replace("href=\"/analytics\"", "href=\"/index\"") + "\n"
f = open(target_dir + "index.html", 'w')
f.write(base)
f.close()



