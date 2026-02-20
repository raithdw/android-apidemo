param(
    [switch]$Headless  # Pass -Headless for headless emulator
)

# =========================
# CONFIGURATION
# =========================
$ANDROID_SDK = "D:\AndroidSDK"        # Change if your SDK path differs
$EMULATOR = "$ANDROID_SDK\emulator\emulator.exe"
$ADB = "$ANDROID_SDK\platform-tools\adb.exe"

$AVD_NAME = if ($env:AVD_NAME) { $env:AVD_NAME } else { "Medium_Phone_API_36.1" }
$ANDROID_VERSION = if ($env:ANDROID_VERSION) { $env:ANDROID_VERSION } else { "16" }

$WDIO_CONFIG = ".\wdio.conf.ts"
$APPIUM_PORT = 4723
$BOOT_TIMEOUT = 180  # seconds

# =========================
# CLEAN ALLURE RESULTS
# =========================
Write-Host "Cleaning previous Allure results..."
if (Test-Path "./allure-results") { Remove-Item -Recurse -Force "./allure-results" }
if (Test-Path "./allure-report") { Remove-Item -Recurse -Force "./allure-report" }

# =========================
# START EMULATOR IF NOT RUNNING
# =========================
$emulatorRunning = & $ADB devices | Select-String "emulator"
$startedEmulator = $false

if (-not $emulatorRunning) {
    Write-Host "Starting Android emulator: $AVD_NAME"
    $emulatorArgs = "-avd $AVD_NAME -netdelay none -netspeed full -no-snapshot-load"
    if ($Headless) { $emulatorArgs += " -no-window -no-audio" }

    Start-Process $EMULATOR `
        -ArgumentList $emulatorArgs `
        -PassThru `
        -NoNewWindow

    $startedEmulator = $true
} else {
    Write-Host "Emulator already running"
}

# =========================
# WAIT FOR ADB DEVICE
# =========================
Write-Host "Waiting for adb device..."
& $ADB wait-for-device
Write-Host "adb device connected"

# =========================
# WAIT FOR ANDROID BOOT
# =========================
Write-Host "Waiting for Android to finish booting..."
$startTime = Get-Date
do {
    $boot = (& $ADB shell getprop sys.boot_completed 2>$null)
    if ($boot) { $boot = $boot.Trim() }
    Start-Sleep -Seconds 5
    $elapsed = (Get-Date) - $startTime
    if ($elapsed.TotalSeconds -ge $BOOT_TIMEOUT) {
        Write-Host "Timeout reached waiting for Android to boot"
        exit 1
    }
} while ($boot -ne "1")
Write-Host "Android fully booted"

# Unlock screen
& $ADB shell input keyevent 82

# =========================
# START APPIUM SERVER
# =========================
Write-Host "Starting Appium server..."
$AppiumProcess = Start-Process `
    -FilePath "cmd.exe" `
    -ArgumentList "/c npx appium --port $APPIUM_PORT --relaxed-security" `
    -PassThru `
    -WindowStyle Hidden

# =========================
# WAIT FOR APPIUM TO BE READY
# =========================
Write-Host "Waiting for Appium server to be ready..."
$maxWait = 30
$startTime = Get-Date
$AppiumReady = $false

while (-not $AppiumReady -and ((Get-Date) - $startTime).TotalSeconds -lt $maxWait) {
    Start-Sleep -Milliseconds 500
    try {
        $response = Invoke-RestMethod -Uri "http://127.0.0.1:$APPIUM_PORT/status" -TimeoutSec 1
        if ($response.value.ready -eq $true) {
            $AppiumReady = $true
        }
    } catch { }
}

if (-not $AppiumReady) {
    Write-Host "Timeout waiting for Appium server!"
    if ($AppiumProcess -and !$AppiumProcess.HasExited) {
        Stop-Process -Id $AppiumProcess.Id -Force
    }
    exit 1
}
Write-Host "Appium server is ready!"

# =========================
# RUN WDIO TESTS
# =========================
Write-Host "Running WebdriverIO tests..."
npm run wdio -- $WDIO_CONFIG
$wdioExitCode = $LASTEXITCODE

# =========================
# GENERATE ALLURE REPORT
# =========================
Write-Host "Generating Allure report..."
if (Test-Path "./allure-results") {
    npm run allure:generate
} else {
    Write-Host "No allure-results found, skipping report generation"
}

# =========================
# STOP APPIUM
# =========================
Write-Host "Stopping Appium server..."
if ($AppiumProcess -and !$AppiumProcess.HasExited) {
    Stop-Process -Id $AppiumProcess.Id -Force
}

# =========================
# STOP EMULATOR
# =========================
if ($startedEmulator) {
    Write-Host "Stopping emulator..."
    $serial = (& $ADB devices | Select-String "emulator" | ForEach-Object { ($_ -split "\s+")[0] })
    if ($serial) { 
        Write-Host "Killing emulator via adb: $serial" 
        & $ADB -s $serial emu kill 
    }
    
    # Fallback: forcibly kill any leftover emulator + qemu processes
    $emulators = Get-Process | Where-Object { $_.ProcessName -like "emulator*" -or $_.ProcessName -like "qemu-system*" } 
    if ($emulators) {
        Write-Host "Forcibly stopping leftover emulator processes..."
        $emulators | ForEach-Object { Stop-Process -Id $_.Id -Force }
    }
    Write-Host "Emulator stopped"
}

Write-Host "All done!"
exit $wdioExitCode