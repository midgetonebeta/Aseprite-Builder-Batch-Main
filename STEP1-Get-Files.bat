@echo off
title Aseprite - Get Source Files
echo.
echo  +======================================================+
echo  |        ASEPRITE SOURCE DOWNLOADER                    |
echo  |        By Midgetonebeta                              |
echo  +======================================================+
echo.
echo  This will download the Aseprite source code to E:\aseprite\
echo  Requires: Git installed and internet connection
echo  Size: ~1.5GB  -  May take a few minutes
echo.
pause

if exist E:\aseprite\src (
    echo.
    echo  Aseprite source already exists at E:\aseprite\
    echo  Skipping clone - pulling latest instead...
    echo.
    cd /d E:\aseprite
    git pull origin main
    git submodule update --init --recursive
) else (
    echo.
    echo  Creating E:\aseprite folder...
    mkdir E:\aseprite
    cd /d E:\aseprite
    echo  Cloning Aseprite - do NOT close this window!
    echo.
    git clone --recursive https://github.com/aseprite/aseprite.git .
)

echo.
echo  +======================================================+
echo  |  Done! Now run STEP2-BUILD-Click ME!.bat             |
echo  +======================================================+
echo.
pause
