$libDir = "$PSScriptRoot\src\main\webapp\WEB-INF\lib"

if (-not (Test-Path -Path $libDir)) {
    New-Item -ItemType Directory -Path $libDir -Force | Out-Null
}

$jars = @(
    @{
        Url = "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.3.0/mysql-connector-j-8.3.0.jar"
        Name = "mysql-connector-j-8.3.0.jar"
    },
    @{
        Url = "https://repo1.maven.org/maven2/org/mindrot/jbcrypt/0.4/jbcrypt-0.4.jar"
        Name = "jbcrypt-0.4.jar"
    },
    @{
        Url = "https://repo1.maven.org/maven2/jakarta/servlet/jsp/jstl/jakarta.servlet.jsp.jstl-api/2.0.0/jakarta.servlet.jsp.jstl-api-2.0.0.jar"
        Name = "jakarta.servlet.jsp.jstl-api-2.0.0.jar"
    },
    @{
        Url = "https://repo1.maven.org/maven2/org/glassfish/web/jakarta.servlet.jsp.jstl/2.0.0/jakarta.servlet.jsp.jstl-2.0.0.jar"
        Name = "jakarta.servlet.jsp.jstl-impl-2.0.0.jar"
    },
    @{
        Url = "https://repo1.maven.org/maven2/com/google/code/gson/gson/2.10.1/gson-2.10.1.jar"
        Name = "gson-2.10.1.jar"
    },
    @{
        Url = "https://repo1.maven.org/maven2/com/opencsv/opencsv/5.8/opencsv-5.8.jar"
        Name = "opencsv-5.8.jar"
    },
    @{
        Url = "https://repo1.maven.org/maven2/org/apache/commons/commons-lang3/3.13.0/commons-lang3-3.13.0.jar"
        Name = "commons-lang3-3.13.0.jar"
    }
)

Write-Host "Downloading JAR files to $libDir..."

foreach ($jar in $jars) {
    $dest = Join-Path -Path $libDir -ChildPath $jar.Name
    if (-not (Test-Path -Path $dest)) {
        Write-Host "Downloading $($jar.Name)..."
        Invoke-WebRequest -Uri $jar.Url -OutFile $dest
        Write-Host "Successfully downloaded $($jar.Name)"
    } else {
        Write-Host "$($jar.Name) already exists, skipping."
    }
}

Write-Host "All downloads complete!"
