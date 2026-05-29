
import urllib.request
import urllib.parse
from http.cookiejar import CookieJar

cj = CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))

url = "http://localhost:8080/webapp/login"
data = urllib.parse.urlencode({"role": "Student", "identifier": "22642723052", "password": "32012006"}).encode("utf-8")
req = urllib.request.Request(url, data=data)

try:
    with opener.open(req) as response:
        print("Status:", response.status)
        print("URL:", response.url)
        content = response.read().decode("utf-8")
        if "Unauthorized" in content:
            print("Failed: Unauthorized")
        elif "Invalid" in content:
            print("Failed: Invalid Credentials")
        else:
            print("Success! Content length:", len(content))
except urllib.error.HTTPError as e:
    print("HTTP Error:", e.code)

