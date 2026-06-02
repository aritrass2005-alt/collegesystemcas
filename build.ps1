$workspace = "c:\Users\91820\Desktop\collegeatt\cas"
$srcDir = "$workspace\src\main\java"
$webappDir = "$workspace\src\main\webapp"
$libDir = "$webappDir\WEB-INF\lib"
$classesDir = "$webappDir\WEB-INF\classes"
$buildLibDir = "$workspace\build-lib"

# Create necessary directories
if (-not (Test-Path -Path $classesDir)) {
    New-Item -ItemType Directory -Path $classesDir -Force | Out-Null
}
if (-not (Test-Path -Path $buildLibDir)) {
    New-Item -ItemType Directory -Path $buildLibDir -Force | Out-Null
}

# Download Servlet API for compilation (Tomcat 9 uses Servlet 4.0)
$servletApiJar = "$buildLibDir\javax.servlet-api-4.0.1.jar"
if (-not (Test-Path -Path $servletApiJar)) {
    Write-Host "Downloading Servlet API for compilation..."
    Invoke-WebRequest -Uri "https://repo1.maven.org/maven2/javax/servlet/javax.servlet-api/4.0.1/javax.servlet-api-4.0.1.jar" -OutFile $servletApiJar
}

# Download WebSocket API
$websocketApiJar = "$buildLibDir\javax.websocket-api-1.1.jar"
if (-not (Test-Path -Path $websocketApiJar)) {
    Write-Host "Downloading WebSocket API for compilation..."
    Invoke-WebRequest -Uri "https://repo1.maven.org/maven2/javax/websocket/javax.websocket-api/1.1/javax.websocket-api-1.1.jar" -OutFile $websocketApiJar
}

# Build Classpath
$jars = Get-ChildItem -Path $libDir -Filter *.jar | Select-Object -ExpandProperty FullName
$jars += $servletApiJar
$jars += $websocketApiJar
$classpath = $jars -join ";"

# Find all Java files
$javaFiles = Get-ChildItem -Path $srcDir -Filter *.java -Recurse | Select-Object -ExpandProperty FullName
$javaFilesList = $javaFiles -join " "

# Compile
Write-Host "Compiling Java files for Java 11 compatibility..."
$compileCmd = "javac --release 11 -cp `"$classpath`" -d `"$classesDir`" $javaFilesList"
Invoke-Expression $compileCmd

if ($LASTEXITCODE -eq 0) {
    Write-Host "Compilation successful! Classes are in $classesDir"
} else {
    Write-Host "Compilation failed."
}
