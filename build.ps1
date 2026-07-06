$workspace = $PSScriptRoot
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

# Download Servlet API for compilation (Tomcat 10 uses Servlet 5.0)
$servletApiJar = "$buildLibDir\jakarta.servlet-api-5.0.0.jar"
if (-not (Test-Path -Path $servletApiJar)) {
    Write-Host "Downloading Jakarta Servlet API for compilation..."
    Invoke-WebRequest -Uri "https://repo1.maven.org/maven2/jakarta/servlet/jakarta.servlet-api/5.0.0/jakarta.servlet-api-5.0.0.jar" -OutFile $servletApiJar
}

# Build Classpath
$jars = Get-ChildItem -Path $libDir -Filter *.jar | Select-Object -ExpandProperty FullName
$jars += $servletApiJar

# Add WebSocket API from Tomcat for compilation (needed for @ServerEndpoint)
$tomcatLib = "C:\Program Files\Apache Software Foundation\Tomcat 10.0_Tomcat10.0\lib"
$wsApiJar = "$tomcatLib\websocket-api.jar"
if (Test-Path -Path $wsApiJar) {
    $jars += $wsApiJar
    Write-Host "Added WebSocket API from Tomcat."
} else {
    Write-Host "WARNING: websocket-api.jar not found in Tomcat lib. WebSocket endpoints may not compile."
}

$classpath = $jars -join ";"

# Find all Java files
$javaFiles = Get-ChildItem -Path $srcDir -Filter *.java -Recurse | Select-Object -ExpandProperty FullName
$javaFilesList = $javaFiles | ForEach-Object { "`"$_`"" }
$javaFilesList = $javaFilesList -join " "

# Compile
Write-Host "Compiling Java files for Java 8 compatibility..."
$compileCmd = "javac --release 8 -cp `"$classpath`" -d `"$classesDir`" $javaFilesList"
Invoke-Expression $compileCmd

if ($LASTEXITCODE -eq 0) {
    Write-Host "Compilation successful! Classes are in $classesDir"
} else {
    Write-Host "Compilation failed."
}
