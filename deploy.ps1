$env:CATALINA_HOME = "C:\Program Files\Apache Software Foundation\Tomcat 10.0_Tomcat10.0"
net stop Tomcat10.0
Start-Sleep -Seconds 5
Remove-Item "$env:CATALINA_HOME\work\Catalina\localhost\webapp" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:CATALINA_HOME\webapps\webapp" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item -Path "c:\Users\Aritra2004\Downloads\collegesystemcas-master (1)\collegesystemcas-master\src\main\webapp" -Destination "$env:CATALINA_HOME\webapps\webapp" -Recurse -Force
net start Tomcat10.0
