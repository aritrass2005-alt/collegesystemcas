
import urllib.request
import urllib.parse

url = "http://localhost:8080/webapp/login"
data = urllib.parse.urlencode({"role": "Student", "identifier": "22642723052", "password": "32012006"}).encode("utf-8")
req = urllib.request.Request(url, data=data)
try:
    with urllib.request.urlopen(req) as response:
        print("Status:", response.status)
        print("URL:", response.url)
except urllib.error.HTTPError as e:
    print("HTTP Error:", e.code)

