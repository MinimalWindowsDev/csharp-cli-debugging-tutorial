@echo off
setlocal enabledelayedexpansion

:: Default values
set "build_type=release"
set "compiler_source=windows"
set "compiler=csc"
set "clean="
set "run="

:: Parse arguments
set argCount=0
for %%x in (%*) do (
    set /A argCount+=1
    set "arg[!argCount!]=%%~x"
)

:: Process arguments
for /L %%i in (1,1,%argCount%) do (
    if /I "!arg[%%i]!"=="debug" set "build_type=debug"
    if /I "!arg[%%i]!"=="release" set "build_type=release"
    if /I "!arg[%%i]!"=="windows" set "compiler_source=windows"
    if /I "!arg[%%i]!"=="vs2019" set "compiler_source=vs2019"
    if /I "!arg[%%i]!"=="dotnet" (
        set "compiler_source=dotnet"
        set "compiler=dotnet"
    )
    if /I "!arg[%%i]!"=="csc" set "compiler=csc"
    if /I "!arg[%%i]!"=="msbuild" set "compiler=msbuild"
    if /I "!arg[%%i]!"=="devenv" set "compiler=devenv"
    if /I "!arg[%%i]!"=="clean" set "clean=true"
    if /I "!arg[%%i]!"=="run" set "run=true"
)

:: Validate arguments for dotnet
if /I "%compiler_source%"=="dotnet" (
    if %argCount% LSS 2 (
        echo Error: When using dotnet, at least two arguments are required.
        echo Usage: %0 [debug^|release] dotnet [clean] [run]
        exit /b 1
    )
)

:: Set paths based on compiler source
if /I "%compiler_source%"=="windows" (
    set "csc_path=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
    set "msbuild_path=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe"
) else if /I "%compiler_source%"=="vs2019" (
    set "csc_path=C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\Roslyn\csc.exe"
    set "msbuild_path=C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\amd64\MSBuild.exe"
    set "devenv_path=C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\IDE\devenv.com"
)

:: Clean if requested
if defined clean (
    if /I "%compiler%"=="dotnet" (
        dotnet clean
    ) else (
        if exist "build" rmdir /S /Q "build"
        if exist "bin" rmdir /S /Q "bin"
        if exist "obj" rmdir /S /Q "obj"
    )
    echo Cleaned output directories.
)

:: Create build directory for csc if it doesn't exist
if /I "%compiler%"=="csc" if not exist "build" mkdir "build"

:: Compile based on selected options
if /I "%compiler%"=="csc" (
    if /I "%build_type%"=="debug" (
        "%csc_path%" /nologo /debug /pdb:build\Program.pdb /out:build\Program.exe Program.cs
    ) else (
        "%csc_path%" /nologo /optimize+ /out:build\Program.exe Program.cs
    )
) else if /I "%compiler%"=="msbuild" (
    "%msbuild_path%" Program.csproj /p:Configuration=%build_type% /p:Platform="Any CPU"
) else if /I "%compiler%"=="devenv" (
    "%devenv_path%" Program.sln /Build "%build_type%|Any CPU"
) else if /I "%compiler%"=="dotnet" (
    dotnet build -c %build_type%
) else (
    echo Error: Invalid compiler option.
    exit /b 1
)

echo Compilation completed.

:: Run if requested
if defined run (
    if /I "%compiler%"=="csc" (
        if /I "%build_type%"=="debug" (
            mdbg build\Program.exe
        ) else (
            build\Program.exe
        )
    ) else if /I "%compiler%"=="msbuild" (
        if /I "%build_type%"=="debug" (
            mdbg bin\%build_type%\Program.exe
        ) else (
            bin\%build_type%\Program.exe
        )
    ) else if /I "%compiler%"=="devenv" (
        if /I "%build_type%"=="debug" (
            mdbg bin\%build_type%\Program.exe
        ) else (
            bin\%build_type%\Program.exe
        )
    ) else if /I "%compiler%"=="dotnet" (
        if /I "%build_type%"=="debug" (
            mdbg bin\%build_type%\net5.0\Program.exe
        ) else (
            dotnet bin\%build_type%\net5.0\Program.exe
        )
    )
)