# ============================================================
#  Build-Aseprite.ps1
#  Aseprite Auto-Builder v2.0 - By Midgetonebeta
#  For my daughter, with love <3
#
#  HOW TO RUN:
#  1. Right-click this file
#  2. Click "Run with PowerShell"
#  3. That's it. Go get a coffee.
# ============================================================

$ErrorActionPreference = "Stop"

# ============================================================
#  STARTUP BANNER
# ============================================================
Clear-Host
Write-Host ""
Write-Host "  +======================================================+" -ForegroundColor Magenta
Write-Host "  |        ASEPRITE AUTO-BUILDER by Midgetonebeta        |" -ForegroundColor Magenta
Write-Host "  |             For my daughter, with love  <3           |" -ForegroundColor Magenta
Write-Host "  +======================================================+" -ForegroundColor Magenta
Write-Host ""
Write-Host "  HOW TO USE:" -ForegroundColor Yellow
Write-Host "  1. This script must be in the Aseprite root folder" -ForegroundColor White
Write-Host "  2. Right-click it and select 'Run with PowerShell'" -ForegroundColor White
Write-Host "  3. Press ENTER when asked" -ForegroundColor White
Write-Host "  4. Wait ~35 minutes" -ForegroundColor White
Write-Host "  5. Done! Aseprite will launch automatically" -ForegroundColor White
Write-Host ""
Write-Host "  +------------------------------------------------------+" -ForegroundColor DarkGray
Write-Host "  | Required tools in E:\python310\ToolsControl\:        |" -ForegroundColor DarkGray
Write-Host "  |   cmake\    skia\                                     |" -ForegroundColor DarkGray
Write-Host "  | Visual Studio 2022 v17.8 or newer required           |" -ForegroundColor DarkGray
Write-Host "  +------------------------------------------------------+" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Press ENTER to start or close this window to cancel..." -ForegroundColor Cyan
Read-Host | Out-Null

# ============================================================
#  VALIDATE CORRECT FOLDER
# ============================================================
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not (Test-Path "$ScriptDir\src") -or -not (Test-Path "$ScriptDir\laf")) {
    Write-Host ""
    Write-Host "  +======================================================+" -ForegroundColor Red
    Write-Host "  |  ERROR: Wrong folder!                                |" -ForegroundColor Red
    Write-Host "  |  Move Build-Aseprite.ps1 to the Aseprite folder      |" -ForegroundColor Red
    Write-Host "  |  Example: E:\aseprite\Build-Aseprite.ps1             |" -ForegroundColor Red
    Write-Host "  +======================================================+" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Press ENTER to close..." -ForegroundColor Gray
    Read-Host | Out-Null
    exit 1
}

# ============================================================
#  VALIDATE TOOLS
# ============================================================
Write-Host "  Checking requirements..." -ForegroundColor Cyan

$missing = @()
if (-not (Test-Path "E:\python310\ToolsControl\cmake\bin\cmake.exe"))            { $missing += "CMake not found at E:\python310\ToolsControl\cmake\bin\" }
if (-not (Test-Path "E:\python310\ToolsControl\skia\out\Release-x64\skia.lib")) { $missing += "Skia not found at E:\python310\ToolsControl\skia\out\Release-x64\" }

$vsPath = "C:\Program Files\Microsoft Visual Studio\2022"
if (-not (Test-Path $vsPath)) {
    $missing += "Visual Studio 2022 not found - download from visualstudio.microsoft.com"
}

if ($missing.Count -gt 0) {
    Write-Host ""
    Write-Host "  MISSING REQUIREMENTS - Cannot build:" -ForegroundColor Red
    foreach ($m in $missing) { Write-Host "    x $m" -ForegroundColor Red }
    Write-Host ""
    Write-Host "  See README.md for setup instructions." -ForegroundColor Yellow
    Write-Host "  Press ENTER to close..." -ForegroundColor Gray
    Read-Host | Out-Null
    exit 1
}

Write-Host "  OK - All requirements found!" -ForegroundColor Green

# ============================================================
#  AUTO-INITIALIZE VISUAL STUDIO ENVIRONMENT
#  (Works from ANY PowerShell window - no Developer Prompt needed)
# ============================================================
Write-Host ""
Write-Host "  Initializing Visual Studio compiler environment..." -ForegroundColor Cyan

$vcvarsOptions = @(
    "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat",
    "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat",
    "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
)

$vcvars = $null
foreach ($path in $vcvarsOptions) {
    if (Test-Path $path) { $vcvars = $path; break }
}

if ($null -eq $vcvars) {
    Write-Host "  ERROR: Could not find vcvars64.bat - is VS 2022 installed with C++ workload?" -ForegroundColor Red
    Write-Host "  Press ENTER to close..." -ForegroundColor Gray
    Read-Host | Out-Null
    exit 1
}

# Import VS environment into current PowerShell session
cmd /c "`"$vcvars`" && set" | ForEach-Object {
    if ($_ -match "^(.*?)=(.*)$") {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
    }
}
Write-Host "  OK - VS compiler environment ready!" -ForegroundColor Green

# ============================================================
#  PATHS
# ============================================================
$AsepriteDir   = $ScriptDir
$BuildDir      = "$AsepriteDir\build"
$BuildWW       = "$AsepriteDir\Build-WW"
$CmakeExe      = "E:\python310\ToolsControl\cmake\bin\cmake.exe"
$SkiaDir       = "E:\python310\ToolsControl\skia"
$SkiaLibDir    = "E:\python310\ToolsControl\skia\out\Release-x64"
$SkiaLib       = "E:\python310\ToolsControl\skia\out\Release-x64\skia.lib"
$OpenGLLib     = "C:/Program Files (x86)/Windows Kits/10/Lib/10.0.19041.0/um/x64/opengl32.lib"
$VersionFile   = "$BuildDir\src\ver\generated_version.h"
$CustomVersion = "1.3.17-dev By Midgetonebeta"
$Cores         = 8

# ============================================================
#  STEP 1: Check for new commits
# ============================================================
Write-Host ""
Write-Host "  [1/5] Checking for updates..." -ForegroundColor Cyan
Set-Location $AsepriteDir
git config --global --add safe.directory $AsepriteDir 2>$null

$before = git rev-parse HEAD 2>$null
git pull origin main 2>&1 | Out-Null
git submodule update --init --recursive 2>&1 | Out-Null
$after = git rev-parse HEAD 2>$null

if ($before -eq $after) {
    if (Test-Path "$BuildDir\bin\aseprite.exe") {
        Write-Host ""
        Write-Host "  No new commits and build already exists!" -ForegroundColor Green
        Write-Host "  Your copy of Aseprite is already up to date." -ForegroundColor Green
        Write-Host ""
        Write-Host "  Launching Aseprite..." -ForegroundColor Cyan
        Start-Process "$BuildDir\bin\aseprite.exe"
        Start-Sleep 2
        exit 0
    }
    Write-Host "  No new commits but no build found - building fresh!" -ForegroundColor Yellow
} else {
    Write-Host "  New version available! Rebuilding..." -ForegroundColor Green
}

# ============================================================
#  STEP 2: Nuke old build
# ============================================================
Write-Host ""
Write-Host "  [2/5] Cleaning old build (this is normal)..." -ForegroundColor Cyan
if (Test-Path $BuildDir) {
    Remove-Item -Recurse -Force $BuildDir -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force $BuildDir -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $BuildDir | Out-Null
Write-Host "  OK!" -ForegroundColor Green

# ============================================================
#  STEP 3: CMake Configure
# ============================================================
Write-Host ""
Write-Host "  [3/5] Configuring build (~12 minutes, please wait)..." -ForegroundColor Cyan
Write-Host "        Do NOT close this window!" -ForegroundColor Yellow
Set-Location $BuildDir

$cmakeArgs = @(
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo",
    "-DLAF_BACKEND=skia",
    "-DSKIA_DIR=$SkiaDir",
    "-DSKIA_LIBRARY_DIR=$SkiaLibDir",
    "-DSKIA_LIBRARY=$SkiaLib",
    "-DSKIA_OPENGL_LIBRARY=$OpenGLLib",
    "-DLAF_WITH_EXAMPLES=OFF",
    "-G", "Visual Studio 17 2022",
    "-A", "x64",
    ".."
)

& $CmakeExe @cmakeArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  ERROR: Configuration failed! See errors above." -ForegroundColor Red
    Write-Host "  Press ENTER to close..." -ForegroundColor Gray
    Read-Host | Out-Null
    exit 1
}
Write-Host "  OK - Configured!" -ForegroundColor Green

# ============================================================
#  STEP 4: Inject version string
# ============================================================
Write-Host ""
Write-Host "  [4/5] Setting version info..." -ForegroundColor Cyan
if (Test-Path $VersionFile) {
    $content = Get-Content $VersionFile
    $content = $content -replace '#define VERSION ".*"', "#define VERSION `"$CustomVersion`""
    Set-Content $VersionFile $content
    Write-Host "  OK - Version: $CustomVersion" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Version file not found - skipping" -ForegroundColor Yellow
}

# ============================================================
#  STEP 5: Build
# ============================================================
Write-Host ""
Write-Host "  [5/5] Compiling Aseprite with $Cores cores..." -ForegroundColor Cyan
Write-Host "        This takes about 25 minutes." -ForegroundColor Yellow
Write-Host "        Go make a coffee - we will handle this!" -ForegroundColor DarkGray
Write-Host ""

& $CmakeExe --build . --config RelWithDebInfo --parallel $Cores
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  +======================================================+" -ForegroundColor Red
    Write-Host "  |  BUILD FAILED! See errors above.                     |" -ForegroundColor Red
    Write-Host "  |  Take a screenshot and send it to dad.               |" -ForegroundColor Red
    Write-Host "  +======================================================+" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Press ENTER to close..." -ForegroundColor Gray
    Read-Host | Out-Null
    exit 1
}

# ============================================================
#  SUCCESS
# ============================================================
Write-Host ""
Write-Host "  +======================================================+" -ForegroundColor Green
Write-Host "  |              BUILD SUCCESSFUL!                       |" -ForegroundColor Green
Write-Host "  |  Aseprite is ready for your daughter!                |" -ForegroundColor Green
Write-Host "  |           Or Who Ever       needs it!                |" -ForegroundColor Green
Write-Host "  +======================================================+" -ForegroundColor Green
Write-Host ""

# Backup to Build-WW
Write-Host "  Saving backup to Build-WW..." -ForegroundColor Cyan
if (Test-Path $BuildWW) {
    Remove-Item -Recurse -Force $BuildWW -ErrorAction SilentlyContinue
}
Copy-Item -Recurse "$BuildDir\bin" "$BuildWW"
Write-Host "  OK - Backup saved!" -ForegroundColor Green
Write-Host ""

# Auto launch
Write-Host "  Launching Aseprite..." -ForegroundColor Cyan
Start-Process "$BuildDir\bin\aseprite.exe"
Start-Sleep 3

Write-Host ""
Write-Host "  Built with love. By Midgetonebeta o7" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Press ENTER to close..." -ForegroundColor Gray
Read-Host | Out-Null
