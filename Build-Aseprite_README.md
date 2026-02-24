# Aseprite Auto-Builder
### By Midgetonebeta — Built for my daughter ♥

A PowerShell script that automatically builds [Aseprite](https://github.com/aseprite/aseprite) from source on Windows. It checks for new commits, cleans the old build, configures, compiles, and backs up your working exe — all in one command.

> **What is Aseprite?**  
> Aseprite is an animated sprite editor and pixel art tool. My daughter uses it to draw and create pixel art. This script exists so she always has the latest version built from source — for free.

---

## Why Build From Source?

Aseprite's source code is free and open. The compiled binary costs money on Steam/Itch. Building it yourself from the official source is **100% legal** per their [license](https://github.com/aseprite/aseprite/blob/main/LICENSE.txt) — you just can't redistribute the compiled binary.

---

## What This Script Does

1. Pulls latest Aseprite source from GitHub
2. Updates all submodules
3. **Skips the build entirely if no new commits exist and a working exe is already present**
4. Nukes the old build folder
5. Configures with CMake using the correct flags
6. Injects a custom version string
7. Compiles with all available CPU cores
8. Backs up the working exe to `Build-WW` folder

---

## Requirements

### 1. Visual Studio 2022 Community (free)
Download from: https://visualstudio.microsoft.com/vs/community/

During install, select the **"Desktop development with C++"** workload.

> **IMPORTANT:** You need version **17.8 or newer**. Older versions are missing required MSVC runtime symbols that Skia depends on. Update via Visual Studio Installer if needed.

### 2. CMake 4.x
Download from: https://cmake.org/download/

Extract to: `E:\python310\ToolsControl\cmake\`

Expected path: `E:\python310\ToolsControl\cmake\bin\cmake.exe`

### 3. Skia Prebuilt (m124 — Windows x64)
Download `Skia-Windows-Release-x64.zip` from:  
https://github.com/aseprite/skia/releases/tag/m124-08a5439a6b

Extract to: `E:\python310\ToolsControl\skia\`

Expected structure:
```
E:\python310\ToolsControl\skia\
    include\
    modules\
    out\
        Release-x64\
            skia.lib       <-- this is the key file
            freetype2.lib
            harfbuzz.lib
    src\
    third_party\
```

### 4. Windows SDK
The script uses `opengl32.lib` from the Windows SDK. It expects:  
`C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x64\opengl32.lib`

If your SDK version is different, edit the `$OpenGLLib` path in the script.

Check your installed SDK version with:
```powershell
dir "C:\Program Files (x86)\Windows Kits\10\Lib"
```

### 5. Git
Download from: https://git-scm.com/download/win

---

## Setup

### Clone Aseprite Source
```powershell
cd E:\
git clone --recursive https://github.com/aseprite/aseprite.git
```

> `--recursive` is **required**. Without it the laf submodule won't be populated and the build will fail.

### Place the Script
Copy `Build-Aseprite.ps1` to your Aseprite root folder:
```
E:\aseprite\Build-Aseprite.ps1
```

The script validates it is in the correct folder by checking for `src\` and `laf\` directories. It will refuse to run from anywhere else.

---

## Usage

Open **Visual Studio 2022 Developer PowerShell** (search for it in Start Menu) and run:

```powershell
cd E:\aseprite
.\Build-Aseprite.ps1
```

The script prints a requirements checklist on startup and asks you to confirm before doing anything.

---

## Folder Structure After Build

```
E:\aseprite\
    build\
        bin\
            aseprite.exe    <-- your fresh build
            data\
            icudtl.dat
    Build-WW\               <-- backup of last working build
        aseprite.exe
        data\
    laf\                    <-- submodule
    src\                    <-- source code
    Build-Aseprite.ps1      <-- this script
    README.md
```

---

## Customizing the Version String

The script injects a custom version string into `generated_version.h` before compiling.  
Edit this line in the script:
```powershell
$CustomVersion = "1.3.17-dev By Midgetonebeta"
```

This shows up in Aseprite under **Help → About**.

---

## Common Errors and Fixes

### `fatal error LNK1181: cannot open input file 'SKIA_OPENGL_LIBRARY-NOTFOUND.lib'`
CMake failed to auto-detect `opengl32.lib`. Make sure your `$OpenGLLib` path in the script points to the actual file:
```powershell
dir "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x64\opengl32.lib"
```
Update the version number in the path to match what you have installed.

### `error LNK2001: unresolved external symbol __std_minmax_f`
Your Visual Studio is too old. Update to **17.8 or newer** via Visual Studio Installer. These symbols were added in 17.8.

### `fatal: detected dubious ownership`
Run this once:
```powershell
git config --global --add safe.directory E:/aseprite
```

### Build folder won't delete
Run Remove-Item twice:
```powershell
Remove-Item -Recurse -Force E:\aseprite\build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force E:\aseprite\build -ErrorAction SilentlyContinue
```

---

## Important Notes

- Do **not** redistribute the compiled `aseprite.exe`. Building for personal use is legal, distribution is not.
- The `Build-WW` folder (Build - Will Work) is your safety net — always has the last successful build.
- CMake configure takes ~12 minutes. Compile takes ~25 minutes. This is normal.
- The tools folder (`cmake`, `skia`) is **not** included in this repo — download them separately via the links above.

---

## Tested On

- Windows 10 / 11
- Visual Studio 2022 v17.14.27
- CMake 4.3
- Skia m124
- Aseprite source: main branch (Feb 2026 / v1.3.17-dev)

---

*By Midgetonebeta — Built with love. o7*
