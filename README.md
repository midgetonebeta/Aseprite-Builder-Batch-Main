# Aseprite Auto-Builder
### By Midgetonebeta — Built for my daughter ♥

A PowerShell script that automatically builds [Aseprite](https://github.com/aseprite/aseprite) from source on Windows. It checks for new commits, cleans the old build, configures, compiles, and backs up your working exe — all in one command.

> **What is Aseprite?**  
> Aseprite is an animated sprite editor and pixel art tool. My daughter uses it to draw and create pixel art. This script exists so she always has the latest version built from source — for free.

---

## ⚠ READ THIS FIRST (Yes, you. The car guy.)

There are **two files** in this folder. You run them **in order**. That's it.

```
STEP1-Get-Files.bat       <-- Run this FIRST. Downloads the source code.
STEP2-BUILD-Click ME!.bat <-- Run this SECOND. Compiles Aseprite.
```

**Do not skip Step 1.**  
**Do not run Step 2 before Step 1.**  
**Do not close the black window while it's running.**  
**If something goes wrong, take a screenshot and send it to dad.**

---

## Before You Start — Install These First

### 1. Git (REQUIRED for STEP1)
Without Git, STEP1 will fail immediately.

Download from: https://git-scm.com/download/win  
Click the big green download button. Install it. Default options are fine.

### 2. Visual Studio 2022 Community (free, REQUIRED for STEP2)
Download from: https://visualstudio.microsoft.com/vs/community/

During install, when it asks what to install, select **"Desktop development with C++"**. Without this it will not compile.

> You need version **17.8 or newer**. If you installed it a while ago, open **Visual Studio Installer** from the Start Menu and click Update.

### 3. CMake
Download from: https://cmake.org/download/

Extract to: `E:\python310\ToolsControl\cmake\`

### 4. Skia Prebuilt (m124 — Windows x64)
Download `Skia-Windows-Release-x64.zip` from:  
https://github.com/aseprite/skia/releases/tag/m124-08a5439a6b

Extract to: `E:\python310\ToolsControl\skia\`

Expected structure after extracting:
```
E:\python310\ToolsControl\skia\
    include\
    modules\
    out\
        Release-x64\
            skia.lib    <-- this file must exist
    src\
    third_party\
```

### 5. Windows SDK
Already installed if you have Visual Studio. If the build fails with an OpenGL error, check:
```powershell
dir "C:\Program Files (x86)\Windows Kits\10\Lib"
```
Update the `$OpenGLLib` path in `Build-Aseprite.ps1` to match your version.

---

## Usage — Step by Step

### Step 1 — Get the source code
Double-click `STEP1-Get-Files.bat`

This downloads the Aseprite source to `E:\aseprite\`. Takes a few minutes depending on your internet. The black window will say **Done!** when finished.

> If you already ran Step 1 before, running it again is safe — it just pulls the latest changes instead of cloning fresh.

### Step 2 — Build it
Double-click `STEP2-BUILD-Click ME!.bat`

This compiles Aseprite. Takes about **35 minutes total**. The black window will show a lot of text — **this is normal, do not close it.**

When done, Aseprite launches automatically.

---

## Folder Structure After Build

```
E:\aseprite\
    build\
        bin\
            aseprite.exe        <-- your compiled Aseprite
            data\
            icudtl.dat
    Build-WW\                   <-- backup of last working build
        aseprite.exe
        data\
    laf\                        <-- submodule (don't touch)
    src\                        <-- source code (don't touch)
    STEP1-Get-Files.bat
    STEP2-BUILD-Click ME!.bat
    Build-Aseprite.ps1
    Build-Aseprite_README.md
```

---

## Updating to a New Version

Just run both steps again in order. The script is smart enough to skip the rebuild if nothing has changed.

---

## Common Errors and Fixes

### `'git' is not recognized as an internal or external command`
Git is not installed. Go install it from https://git-scm.com/download/win and run Step 1 again.

### `fatal error LNK1181: cannot open input file 'SKIA_OPENGL_LIBRARY-NOTFOUND.lib'`
CMake failed to find `opengl32.lib`. Check your Windows SDK version:
```powershell
dir "C:\Program Files (x86)\Windows Kits\10\Lib"
```
Update the `$OpenGLLib` path in `Build-Aseprite.ps1` to match.

### `error LNK2001: unresolved external symbol __std_minmax_f`
Visual Studio is too old. Update to **17.8 or newer** via Visual Studio Installer.

### `fatal: detected dubious ownership`
Run this once in PowerShell:
```powershell
git config --global --add safe.directory E:/aseprite
```

### Build folder won't delete
```powershell
Remove-Item -Recurse -Force E:\aseprite\build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force E:\aseprite\build -ErrorAction SilentlyContinue
```

### Black window disappeared before I could read it
Take a screenshot next time. Or send it to dad.

---

## Important Notes

- Do **not** redistribute the compiled `aseprite.exe`. Building for personal use is legal per the [Aseprite license](https://github.com/aseprite/aseprite/blob/main/LICENSE.txt). Distribution is not.
- `Build-WW` (Build - Will Work) is your safety net — always has the last successful build.
- The tools folder (`cmake`, `skia`) is **not** included in this repo — download separately via links above.
- Do **not** include `E:\python310\ToolsControl\` in your GitHub repo — Skia alone is 300MB.

---

## Tested On

- Windows 10 / 11
- Visual Studio 2022 v17.14.27
- CMake 4.3
- Skia m124
- Aseprite source: main branch (Feb 2026 / v1.3.17-dev)

---

*By Midgetonebeta — Built with love. o7*
