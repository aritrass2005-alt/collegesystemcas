$workspace = "c:\Users\91820\Desktop\collegeatt\cas"
$webappDir = "$workspace\src\main\webapp"
$libDir = "$webappDir\WEB-INF\lib"
$classesDir = "$webappDir\WEB-INF\classes"

$jars = Get-ChildItem -Path $libDir -Filter *.jar | Select-Object -ExpandProperty FullName
$classpath = ($jars -join ";") + ";$classesDir"

Write-Host "Compiling FixDB.java..."
javac -cp $classpath -d $classesDir "$workspace\src\main\java\FixDB.java"

Write-Host "Running FixDB..."
java -cp $classpath FixDB
